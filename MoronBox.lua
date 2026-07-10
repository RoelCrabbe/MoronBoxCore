-- [[ Environment ]] --

---@class MoronBox: Frame
MoronBox = CreateFrame("Frame", nil, UIParent)
MoronBox:RegisterEvent("ADDON_LOADED")

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

--- Registers a new module for the addon
--- @param name string: Unique identifier for the module
--- @param func function: The module's initialization function
function MoronBox:RegisterModule(name, func)
    if self.Modules[name] then
        error("MoronBox: Module '" .. name .. "' is already registered.")
    end

    self.Modules[name] = func
    table.insert(self.ModuleNames, name) -- Strictly for tracking keys/order

    -- If the system is already booted, load the module immediately
    if not MoronBox.BootUp then
        MoronBox:LoadModule(name)
    end
end

--- Loads and executes a registered module within the sandboxed environment
--- @param name string: The name of the module to load
function MoronBox:LoadModule(name)
    if not self.Modules[name] then
        error("MoronBox: Cannot load module '" .. name .. "'. Module does not exist.")
    end

    self.CurrentModule = name
    setfenv(self.Modules[name], self:GetEnvironment())

    local status, err = pcall(self.Modules[name])
    if not status then
        error("MoronBox: Error during initialization of module '" .. name .. "': " .. tostring(err))
    end

    self.CurrentModule = nil
end

--- Exposes a module's public API to the MoronBox.Registry Modules
--- @param apiTable table: The table containing public functions
function MoronBox:RegisterExpose(apiTable)
    if not self.CurrentModule then
        error("RegisterExpose called outside of module load context")
    end

    self.Registry[self.CurrentModule] = apiTable
end

MoronBox:SetScript("OnEvent", function()
    -- Only act when our specific addon is fully loaded by the client
    if event == "ADDON_LOADED" and arg1 == "MoronBoxCore" then
        -- MoronBox:LoadConfig()

        for _, name in ipairs(MoronBox.ModuleNames) do
            -- Optional: Add a check if the module is disabled in config
            -- if not MoronBox_Config.disabled[name] then
            MoronBox:LoadModule(name)
            -- end
        end

        MoronBox.BootUp = nil
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
