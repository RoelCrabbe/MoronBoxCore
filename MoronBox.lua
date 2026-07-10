    -- [[ Environment ]] --

---@class MoronBox: Frame
MoronBox = CreateFrame("Frame", nil, UIParent)
MoronBox:RegisterEvent("ADDON_LOADED")
MoronBox:RegisterEvent("RAID_ROSTER_UPDATE")
MoronBox:RegisterEvent("PARTY_MEMBERS_CHANGED")
MoronBox:RegisterEvent("PLAYER_ENTERING_WORLD")

-- Flag to track initialization state
MoronBox.BootUp = true
MoronBox.CurrentModule = nil

-- Core storage structures
MoronBox.Modules = {}     -- Holds the init functions ("Recipes")
MoronBox.Registry = {}    -- Holds the public API tables ("Exposed APIs")
MoronBox.ModuleNames = {} -- Holds the list of strings ("Keys")
MoronBox.Api = {}         -- Empty

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

    setmetatable(env, {
        __index = function(_, key)
            -- Prioritize internal API, fallback to WoW/Lua global space
            local v = self.Api[key]
            if v ~= nil then return v end
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
        self.Debugger:Error("Module '" .. name .. "' failed to load: " .. tostring(err))
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
            self.Debugger:Error("Module condition check failed for: " .. name)
        end

        -- State Machine: Synchronize module state
        if shouldBeLoaded and not mod.isLoaded then
            self:LoadModule(name)
        elseif not shouldBeLoaded and mod.isLoaded then
            self:UnloadModule(name)
        end
    end
end

MoronBox:SetScript("OnEvent", function()
    -- Only act when our specific addon is fully loaded by the client
    if event == "ADDON_LOADED" and arg1 == "MoronBoxCore" then
        MoronBox:UpdateModules()
        MoronBox.BootUp = nil
    elseif event == "RAID_ROSTER_UPDATE" or event == "PARTY_MEMBERS_CHANGED" or event == "PLAYER_ENTERING_WORLD" then
        MoronBox:UpdateModules()
    end
end)

-- [[ Debugger & Logging ]] --

--- @section Debugger
--- The Debugger provides centralized, deduplicated logging across all modules.
--- It includes an error handler that intercepts WoW-native Lua exceptions.

MoronBox.Debugger = {
    Enabled = true,        -- Toggle overall logging
    Inline_Enabled = true, -- Print logs to chat frame
    History = {},          -- Persistent log storage for session review
    Seen = {}              -- Deduplication cache (prevents chat spam)
}

--- Extracts the call stack to identify the origin of a log or error call.
--- @return string: "FunctionName - Filename:LineNumber"
function MoronBox.Debugger:GetShortStack()
    local trace = debugstack(4, 2, 0)
    local _, _, line1, line2 = string.find(trace, "(.-)\n(.-)\n")
    if not line1 then line1 = trace end
    local _, _, funcName = string.find(line1, "`([^`]+)'")
    local _, _, file, line = string.find(line2, "([%w%.]+%.lua):(%d+):")
    return (funcName or "Unknown") .. " - " .. (file or "Unknown") .. ":" .. (line or "0")
end

--- Returns the color code string for a given log level.
--- @param level string: Severity level ("INFO", "WARN", "ERROR")
--- @return string: WoW color hex code
function MoronBox.Debugger:GetColor(level)
    if level == "INFO" then return "|cFF00FF00" end
    if level == "WARN" then return "|cFFFFFF00" end
    return "|cFFFF0000" -- ERROR
end

--- Records, deduplicates, and optionally prints log entries to the chat.
--- @param level "INFO"|"WARN"|"ERROR": Log severity level.
--- @param message string: The diagnostic message to log.
function MoronBox.Debugger:Log(level, message)
    if not self.Enabled then return end

    local source = self:GetShortStack()
    local key = level .. ":" .. source .. ":" .. message

    -- Discard duplicates to prevent chat spam
    if self.Seen[key] then return end
    self.Seen[key] = true

    local h, m = GetGameTime()
    table.insert(self.History, {
        level = level,
        source = source,
        message = message,
        time = string.format("%02d:%02d", h, m)
    })

    if self.Inline_Enabled then
        local color = self:GetColor(level)
        print(color .. "[" .. level .. "]|r (" .. source .. ") " .. message)
    end
end

-- Public logging API methods
function MoronBox.Debugger:Warn(msg) self:Log("WARN", msg) end

function MoronBox.Debugger:Error(msg) self:Log("ERROR", msg) end

function MoronBox.Debugger:Info(msg) self:Log("INFO", msg) end

--- Prints all unique warnings/errors captured during the current session.
--- Useful for reviewing issues without scrolling through chat history.
function MoronBox.Debugger:PrintHistory()
    if table.getn(self.History) == 0 then
        print("|cffcccc33[MoronBox]|r No warnings or errors logged this session.")
        return
    end

    print("|cffcccc33[MoronBox]|r Session History:")
    for _, entry in ipairs(self.History) do
        local color = self:GetColor(entry.level)
        print(color .. "[" .. entry.time .. " " .. entry.level .. "]|r (" .. entry.source .. ") " .. entry.message)
    end
end

--- Clears the session history table.
--- Note: This does not affect the deduplication memory (Seen table),
--- so you won't be spammed by the same errors again even after clearing history.
function MoronBox.Debugger:ClearHistory()
    self.History = {}
    print("|cffcccc33[MoronBox]|r History cleared.")
end

-- Slash command registratie
SLASH_MBLOG1 = "/mblog"
SlashCmdList["MBLOG"] = function()
    MoronBox.Debugger:PrintHistory()
end

-- [[ Global Environment Handling ]] --

--- Routes standard 'print' calls to the MoronBox chat output.
local function PrintHandler(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cffcccc33INFO:|r |cffffffff" .. tostring(msg))
end

print = print or PrintHandler

--- Intercepts Lua exceptions to prevent engine popups and log to MoronBox.
--- @param msg string: Raw error message from the WoW client.
local function ErrorHandler(msg)
    if MoronBox.Debugger.Inline_Enabled then
        print(debugstack(1, 12, 10))
    end

    -- Only handle errors related to our workspace
    if string.find(msg, "AddOns\\MoronBoxCore") then
        MoronBox.Debugger:Log("ERROR", msg)
    end
end

seterrorhandler(ErrorHandler)
