-- [[ Environment ]] --

---@class MoronBox: Frame
MoronBox = CreateFrame("Frame", nil, UIParent)
MoronBox:RegisterEvent("ADDON_LOADED")
MoronBox:RegisterEvent("RAID_ROSTER_UPDATE")
MoronBox:RegisterEvent("PARTY_MEMBERS_CHANGED")
MoronBox:RegisterEvent("PLAYER_ENTERING_WORLD")

---@class MoronBoxTooltip: GameTooltip
MoronBoxTooltip = CreateFrame("GameTooltip", "MoronBoxTooltip", UIParent, "GameTooltipTemplate")

---@class MBx: Frame
MBx = CreateFrame("Frame")
MBx.ACE = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0")
MBx.ACE.ItemBonus = AceLibrary("ItemBonusLib-1.0")
MBx.ACE.Banzai = AceLibrary("Banzai-1.0")
MBx.ACE.HealComm = AceLibrary("HealComm-1.0")

-- Flag to track initialization state
MoronBox.BootUp = true
MoronBox.CurrentModule = nil

-- Core storage structures
MoronBox.Modules = {}           -- Holds the init functions ("Recipes")
MoronBox.Registry = {}          -- Holds the public API tables ("Exposed APIs")
MoronBox.ModuleNames = {}       -- Holds the list of strings ("Keys")

MoronBox.Settings = {}          -- Custom Config | Tables
MoronBox.Config = {}            -- Config | Tables

MoronBox.Debugger = {}          -- Debugger
MoronBox.Api = {}               -- Extra functions
MoronBox.Bag = {}
MoronBox.Unit = {}              -- All unit state and configuration

MoronBox.Core = {}              -- All core state and configuration
MoronBox.Core.Aura = {}         -- Subsection from Core
MoronBox.Core.Spells = {}       -- Subsection from Core
MoronBox.Core.Buffs = {}        -- Subsection from Core
MoronBox.Core.Raid = {}         -- Subsection from Core
MoronBox.Core.Dispel = {}       -- Subsection from Core
MoronBox.Core.Gear = {}         -- Subsection from Core
MoronBox.Core.Attack = {}       -- Subsection from Core
MoronBox.Core.Rotation = {}     -- Subsection from Core
MoronBox.Core.Report = {}       -- Subsection from Core
MoronBox.Core.CrowdControl = {} -- Subsection from Core

--- Creates a unique, isolated environment (sandbox) for a module.
--- Each module receives a dedicated table instance, ensuring that global
--- state changes within one module do not leak into another.
---
--- The environment uses a metatable to implement a fallback chain:
--- 1. Module-specific API (self.Api)
--- 2. Global environment (_G / getfenv(0))
---
--- @return table: A unique environment table with metatable fallback
function MoronBox:GetEnvironment()
    local env = {}
    local seen = {}

    local namespaces = {
        -- Config
        self.Settings,
        self.Config,
        self.Config.Tables,
        -- Api
        self.Debugger,
        self.Api,
        self.Bag,
        self.Unit,
        -- Core
        self.Core,
        self.Core.Aura,
        self.Core.Spells,
        self.Core.Raid,
        self.Core.Dispel,
        self.Core.Gear,
        self.Core.Attack,
        self.Core.Rotation,
        self.Core.Report,
        self.Core.Buffs,
        self.Core.CrowdControl,
        self.Core.Cons
    }

    for _, ns in ipairs(namespaces) do
        if ns then
            for key, _ in pairs(ns) do
                if seen[key] then
                    getDebugger().WarnMsg("GetEnvironment: naming conflict for '" .. key .. "'")
                    break
                end
                seen[key] = true
            end
        end
    end

    setmetatable(env, {
        __index = function(_, key)
            for _, ns in ipairs(namespaces) do
                if ns and ns[key] ~= nil then
                    return ns[key]
                end
            end
            return getfenv(0)[key]
        end
    })

    return env
end

--- Applies a sandboxed environment to a variable number of functions.
--- This ensures that any module-specific code (onBoot, onLoad, etc.) executes
--- within the isolated scope provided by the MoronBox environment,
--- preventing leakage of global variables and maintaining strict modularity.
---
--- @param env table: The sandboxed environment table to apply.
--- @param ... function: A variable number of functions to be sandboxed.
local function SandboxAll(env, ...)
    -- Iterate through all passed function arguments
    for i = 1, table.getn(arg) do
        local fn = arg[i]

        -- Only process non-nil arguments
        if fn ~= nil then
            -- Validate type to prevent runtime errors in setfenv
            if type(fn) ~= "function" then
                error("MoronBox: Argument #" .. i .. " is not a function (got " .. type(fn) .. ")")
            end

            -- Apply the sandbox environment to the function
            setfenv(fn, env)
        end
    end
end

--- Registers a new module for the addon
--- @param name string: Unique identifier for the module
--- @param func function: The module's initialization function
--- @param check (fun():boolean|nil)? : Optional function that returns a boolean or nil.
--- @param unloadFunc function?: The module's unload function
function MoronBox:RegisterModule(name, func, check, unloadFunc)
    if self.Modules[name] then
        error("MoronBox: Module '" .. name .. "' is already registered.")
    end

    table.insert(self.ModuleNames, name) -- Strictly for tracking keys/order
    self.Modules[name] = {
        onBoot = func,
        onLoad = check,
        onUnload = unloadFunc,
        isLoaded = false
    }

    SandboxAll(self:GetEnvironment(), func, check, unloadFunc)

    -- If the system is already booted, load the module immediately
    if not MoronBox.BootUp then
        MoronBox:LoadModule(name)
    end
end

--- Loads and executes a registered module within the sandboxed environment.
--- This function handles dependency checks, sandbox initialization, and
--- error-protected execution of the module's boot sequence.
--- @param name string: The unique identifier of the module to load.
function MoronBox:LoadModule(name)
    local module = self.Modules[name]
    if not module then
        error("MoronBox: Cannot load module '" .. name .. "'. Module does not exist.")
    end

    -- Exit early if the module is already initialized to prevent duplicate execution
    if module.isLoaded then
        return
    end

    -- Run the optional conditional check (onLoad) if defined
    -- pcall ensures that a failure in the check does not crash the entire addon
    if module.onLoad then
        local status, result = pcall(module.onLoad)

        -- Abort loading if the check encountered an error or explicitly returned false
        if not status or result == false then
            return
        end
    end

    -- Prepare the module: set the current loading context for RegisterExpose
    self.CurrentModule = name

    -- Execute the boot process within a protected call
    local status, err = pcall(module.onBoot)

    -- Reset the load context
    self.CurrentModule = nil

    if not status then
        -- Log to our centralized Debugger instead of crashing
        getDebugger().ErrorMsg("Module '" .. name .. "' failed to load: " .. tostring(err))
        return
    end

    -- Mark as initialized to prevent re-execution
    module.isLoaded = true
end

--- Exposes a module's public API to the MoronBox.Registry Modules
--- @param apiTable table: The table containing public functions
function MoronBox:RegisterExpose(apiTable)
    if not self.CurrentModule then
        error("RegisterExpose called outside of module load context")
    end

    self.Registry[self.CurrentModule] = apiTable
end

--- Unloads a registered module, triggering cleanup and removing its public API.
--- This function ensures that if a module is currently loaded, it is given the
--- opportunity to clean up its local resources (like frames or events)
--- before being disabled.
--- @param name string: The unique identifier of the module to unload.
function MoronBox:UnloadModule(name)
    -- Verify module existence to prevent runtime indexing errors
    local module = self.Modules[name]
    if not module then
        error("MoronBox: Cannot unload module '" .. name .. "'. Module does not exist.")
    end

    -- Only proceed if the module is currently marked as loaded
    if module.isLoaded then
        -- Execute optional cleanup logic defined by the module
        if module.onUnload then
            local status, err = pcall(module.onUnload)
            -- If the cleanup fails, we want an explicit error instead of silently ignoring it
            if not status then
                error("MoronBox: Error during cleanup of module '" .. name .. "': " .. tostring(err))
            end
        end

        -- Update state: mark as unloaded and revoke public API access
        module.isLoaded = false
        self.Registry[name] = nil
    end
end

local function AlwaysLoad() return true end

--- Iterates through all registered modules and synchronizes their state
--- with the system requirements. Loads or unloads modules as necessary.
function MoronBox:UpdateModules()
    for _, name in ipairs(self.ModuleNames) do
        local mod = self.Modules[name]

        -- Evaluate condition: defaults to true if no check is defined
        local status, shouldBeLoaded = pcall(mod.onLoad or AlwaysLoad)

        -- Fallback: if pcall fails, treat as false for safety
        if not status then
            shouldBeLoaded = false
            getDebugger().ErrorMsg("Module condition check failed for: " .. name)
        end

        -- State Machine: Synchronize module state
        if shouldBeLoaded and not mod.isLoaded then
            self:LoadModule(name)
        elseif not shouldBeLoaded and mod.isLoaded then
            self:UnloadModule(name)
        end
    end
end

-- [[ Deferred / Queued Execution ]] --

--- @class MoronBoxQueueTimer : Frame
--- @field queue table
--- @field interval number
--- @field sinceLast number
--- @field DeQueue fun(self: MoronBoxQueueTimer)

--- @type MoronBoxQueueTimer
local queueTimer

--- Queues a function (with up to 9 optional arguments) to run after a short
--- delay, spread out via a shared OnUpdate ticker. Multiple queued functions
--- run one per tick (interval ~TOOLTIP_UPDATE_TIME), not all at once — pass a
--- single closure wrapping multiple calls if they must run together, in order.
--- @param a1 function: The function to call.
--- @param a2 any|nil
--- @param a3 any|nil
--- @param a4 any|nil
--- @param a5 any|nil
--- @param a6 any|nil
--- @param a7 any|nil
--- @param a8 any|nil
--- @param a9 any|nil
function MoronBox.QueueFunction(a1, a2, a3, a4, a5, a6, a7, a8, a9)
    if not queueTimer then
        queueTimer = CreateFrame("Frame") --[[@as MoronBoxQueueTimer]]
        queueTimer.queue = {}
        queueTimer.interval = TOOLTIP_UPDATE_TIME

        queueTimer.DeQueue = function()
            local item = table.remove(queueTimer.queue, 1)
            if item then
                item[1](item[2], item[3], item[4], item[5], item[6], item[7], item[8], item[9])
            end

            if table.getn(queueTimer.queue) == 0 then
                queueTimer:Hide()
            end
        end

        queueTimer:SetScript("OnUpdate", function()
            this.sinceLast = (this.sinceLast or 0) + arg1
            while this.sinceLast > this.interval do
                this.DeQueue()
                this.sinceLast = this.sinceLast - this.interval
            end
        end)
    end

    table.insert(queueTimer.queue, { a1, a2, a3, a4, a5, a6, a7, a8, a9 })
    queueTimer:Show()
end

MoronBox:SetScript("OnEvent", function()
    -- Only act when our specific addon is fully loaded by the client
    if event == "ADDON_LOADED" and arg1 == "MoronBoxCore" then
        MoronBox:UpdateModules()

        MoronBox.QueueFunction(function()
            DEFAULT_CHAT_FRAME:AddMessage("|cffFF8000Welcome to MoronBox! |cffffffffCreated by MoroN.", 1, 1, 1)
            DEFAULT_CHAT_FRAME:AddMessage(
                "|cffFF8000MoronBox: |r|cff00ff00Scripts loaded succesfully. |cffffffffIssues? Let me know!", 1, 1, 1)

            UIErrorsFrame:Hide()

            MoronBox.Core.InitializeClasslists()
            MoronBox.Core.GetMySpecc()
            MoronBox.Core.Attack.SetAttackButton()
            MoronBox.Core.Healing.GetHealSpell()

            if MB_raidAssist.AutoEquipSet.Active then
                MoronBox.Core.Gear.EquipRackSet(MB_raidAssist.AutoEquipSet.Set)
            end
        end)

        MoronBox.BootUp = nil
    elseif event == "RAID_ROSTER_UPDATE" or event == "PARTY_MEMBERS_CHANGED" or event == "PLAYER_ENTERING_WORLD" then
        MoronBox.Core.InitializeClasslists()
        MoronBox:UpdateModules()
    end
end)
