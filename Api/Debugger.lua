-- [[ Debugger & Logging ]] --

MoronBox.Debugger = MoronBox.Debugger or {}

function getDebugger()
    return MoronBox.Debugger
end

--- @section Debugger
--- The Debugger provides centralized, deduplicated logging across all modules.
--- It includes an error handler that intercepts WoW-native Lua exceptions.

local DebuggerState = {
    Enabled = true,        -- Toggle overall logging
    Inline_Enabled = true, -- Print logs to chat frame
    History = {},          -- Persistent log storage for session review
    Seen = {}              -- Deduplication cache (prevents chat spam)
}

--- Extracts the call stack to identify the origin of a log or error call.
--- @return string: "FunctionName - Filename:LineNumber"
function MoronBox.Debugger.GetShortStack()
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
function MoronBox.Debugger.GetColor(level)
    if level == "INFO" then return "|cFF00FF00" end
    if level == "WARN" then return "|cFFFFFF00" end
    return "|cFFFF0000" -- ERROR
end

--- Records, deduplicates, and optionally prints log entries to the chat.
--- @param level "INFO"|"WARN"|"ERROR": Log severity level.
--- @param message string: The diagnostic message to log.
function MoronBox.Debugger.Log(level, message)
    if not DebuggerState.Enabled then return end

    local source = getDebugger().GetShortStack()
    local key = level .. ":" .. source .. ":" .. message

    -- Discard duplicates to prevent chat spam
    if DebuggerState.Seen[key] then return end
    DebuggerState.Seen[key] = true

    local h, m = GetGameTime()
    table.insert(DebuggerState.History, {
        level = level,
        source = source,
        message = message,
        time = string.format("%02d:%02d", h, m)
    })

    if DebuggerState.Inline_Enabled then
        local color = getDebugger().GetColor(level)
        print(color .. "[" .. level .. "]|r (" .. source .. ") " .. message)
    end
end

-- Public logging API methods
function MoronBox.Debugger.WarnMsg(msg) getDebugger().Log("WARN", msg) end

function MoronBox.Debugger.ErrorMsg(msg) getDebugger().Log("ERROR", msg) end

function MoronBox.Debugger.InfoMsg(msg) getDebugger().Log("INFO", msg) end

--- Prints all unique warnings/errors captured during the current session.
--- Useful for reviewing issues without scrolling through chat history.
function MoronBox.Debugger.PrintHistory()
    if table.getn(DebuggerState.History) == 0 then
        print("|cffcccc33[MoronBox]|r No warnings or errors logged this session.")
        return
    end

    print("|cffcccc33[MoronBox]|r Session History:")
    for _, entry in ipairs(DebuggerState.History) do
        local color = getDebugger().GetColor(entry.level)
        print(color .. "[" .. entry.time .. " " .. entry.level .. "]|r (" .. entry.source .. ") " .. entry.message)
    end
end

--- Clears the session history table.
--- Note: This does not affect the deduplication memory (Seen table),
--- so you won't be spammed by the same errors again even after clearing history.
function MoronBox.Debugger.ClearHistory()
    DebuggerState.History = {}
    print("|cffcccc33[MoronBox]|r History cleared.")
end

-- Slash command registratie
SLASH_MBLOG1 = "/mblog"
SlashCmdList["MBLOG"] = function()
    MoronBox.Debugger.PrintHistory()
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
    if DebuggerState.Inline_Enabled then
        print(debugstack(1, 12, 10))
    end

    -- Only handle errors related to our workspace
    if string.find(msg, "AddOns\\MoronBoxCore") then
        getDebugger().ErrorMsg(msg)
    end
end

seterrorhandler(ErrorHandler)

--- Recursively prints the full contents of a table, including nested tables.
--- @param t table: The table to print.
--- @param indent? string|nil: Internal use — current indentation prefix (leave nil when calling).
--- @param seen? table|nil: Internal use — tracks visited tables to avoid infinite loops on circular references.
function MoronBox.Debugger.DumpTable(t, indent, seen)
    indent = indent or ""
    seen = seen or {}

    if type(t) ~= "table" then
        print(indent .. tostring(t))
        return
    end

    if next(t) == nil then
        print(indent .. "Table is empty.")
        return
    end

    if seen[t] then
        print(indent .. "*circular reference*")
        return
    end

    seen[t] = true

    for key, value in pairs(t) do
        if type(value) == "table" then
            print(indent .. tostring(key) .. ":")
            getDebugger().DumpTable(value, indent .. "  ", seen)
        else
            print(indent .. tostring(key) .. " = " .. tostring(value))
        end
    end
end
