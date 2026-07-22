-- [[ Environment ]] --

---@class MoronBox: Frame
MoronBox = CreateFrame("Frame", nil, UIParent)
MoronBox:RegisterEvent("ADDON_LOADED")
MoronBox:RegisterEvent("RAID_ROSTER_UPDATE")
MoronBox:RegisterEvent("PARTY_MEMBERS_CHANGED")
MoronBox:RegisterEvent("PLAYER_ENTERING_WORLD")
MoronBox:RegisterEvent("PLAYER_LOGIN")
MoronBox:RegisterEvent("UNIT_INVENTORY_CHANGED")
MoronBox:RegisterEvent("ZONE_CHANGED_NEW_AREA")

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
MoronBox.Config = {}            -- Config
MoronBox.Config.Tables = {}     -- Tables
MoronBox.Encounters = {}        -- Encouter config

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

--- @class MoronBoxDelayTimer : Frame
--- @field steps table
--- @field index number
--- @field timer number
--- @field delay number

--- Executes a list of functions sequentially with a specific time delay
--- between each step, using an OnUpdate ticker.
--- @param funcList table: A list (array) of functions to call in order.
--- @param delay number|nil: The delay in seconds between steps (defaults to 0.1).
function MoronBox.DelayExecutionOrder(funcList, delay)
    local frame = CreateFrame("Frame") --[[@as MoronBoxDelayTimer]]
    frame.steps = funcList
    frame.index = 1
    frame.timer = 0
    frame.delay = delay or TOOLTIP_UPDATE_TIME

    frame:SetScript("OnUpdate", function()
        this.timer = this.timer + arg1
        if this.timer >= this.delay then
            this.timer = 0
            if this.steps[this.index] then
                this.steps[this.index]()
                this.index = this.index + 1
            else
                this:Hide()
            end
        end
    end)
end

--- @class MoronBoxSequencer : Frame
--- @field timer number
--- @field delay number
--- @field maxRetries number
--- @field retries number

--- Executes a function repeatedly until the GossipFrame is closed or retries are exhausted.
--- @param func function: The logic to execute.
--- @param delay number|nil: The delay in seconds (defaults to 0.3).
function MoronBox.ExecuteSequenced(func, delay)
    local frame = CreateFrame("Frame") --[[@as MoronBoxSequencer]]
    frame.timer = 0
    frame.delay = delay or TOOLTIP_UPDATE_TIME
    frame.maxRetries = 10
    frame.retries = 0

    frame:SetScript("OnUpdate", function()
        local f = this --[[@as MoronBoxSequencer]]

        f.timer = f.timer + arg1

        if f.timer >= f.delay then
            f.timer = 0
            f.retries = f.retries + 1

            func()

            if not GossipFrame:IsShown() then
                f:Hide()
            elseif f.retries >= f.maxRetries then
                f:Hide()
            end
        end
    end)
end

--- @class MoronBoxCoreHook : Frame
--- @field func function
--- @field foundConfig boolean
--- @field hookedUpdate boolean

--- Executes a function once MoronBoxCore is fully loaded and its boot sequence is complete.
--- @param func function: The logic to execute.
function MoronBox.HookCore(func)
    local lurker = CreateFrame("Frame", nil) --[[@as MoronBoxCoreHook]]
    lurker.func = func
    lurker:RegisterEvent("ADDON_LOADED")
    lurker:RegisterEvent("VARIABLES_LOADED")
    lurker:RegisterEvent("PLAYER_ENTERING_WORLD")
    lurker:SetScript("OnEvent", function()
        local f = this --[[@as MoronBoxCoreHook]]

        if event == "ADDON_LOADED" and not f.foundConfig then
            return
        elseif event == "VARIABLES_LOADED" then
            f.foundConfig = true
        end

        if IsAddOnLoaded("MoronBoxCore") or _G["MoronBoxCore"] then
            if MoronBox and MoronBox.BootUp then
                if not f.hookedUpdate then
                    f.hookedUpdate = true
                    f:SetScript("OnUpdate", function()
                        local uf = this --[[@as MoronBoxCoreHook]]
                        if not MoronBox.BootUp then
                            uf:SetScript("OnUpdate", nil)
                            uf:func()
                            uf:UnregisterAllEvents()
                        end
                    end)
                end
                return
            end

            f:func()
            f:UnregisterAllEvents()
        end
    end)
end

MoronBox:SetScript("OnEvent", function()
    -- Only act when our specific addon is fully loaded by the client
    if event == "ADDON_LOADED" and arg1 == "MoronBoxCore" then
        MoronBox:UpdateModules()

        MoronBox.DelayExecutionOrder({
            -- Task 1
            getCore().GetMySpecc,
            getHealing().GetHealSpell,
            getAttack().SetAttackButton,
            getCore().InitializeClasslists,

            function()
                if getSettingsState().AutoEquipSet.Active then
                    getGear().EquipRackSet(getSettingsState().AutoEquipSet.Set)
                end
            end,

            -- Task 2
            function()
                DEFAULT_CHAT_FRAME:AddMessage("|cffFF8000Welcome to MoronBox! |cffffffffCreated by |r|cffDA70D6MoroN.", 1,
                    1, 1)
                DEFAULT_CHAT_FRAME:AddMessage(
                    "|cffFF8000MoronBox: |r|cff00ff00Scripts loaded succesfully. |cffffffffIssues? Let me know!", 1, 1, 1)
                UIErrorsFrame:Hide()
            end,

            -- Tasnk 3
            function()
                -- No extentions can load
                MoronBox.BootUp = nil
            end
        }, 0.25)
    elseif event == "PLAYER_LOGIN" then
        getCore().GetMySpecc()
        getCore().InitializeClasslists()
    elseif event == "UNIT_INVENTORY_CHANGED" and getCore().ImHealer() then
        getHealing().GetHealSpell()
    elseif event == "RAID_ROSTER_UPDATE" or event == "PARTY_MEMBERS_CHANGED" or event == "PLAYER_ENTERING_WORLD" then
        getCore().InitializeClasslists()
        MoronBox:UpdateModules()
    elseif event == "ZONE_CHANGED_NEW_AREA" then
        -- TODO: Only zone based modules need to reload
        MoronBox:UpdateModules()
    end
end)
