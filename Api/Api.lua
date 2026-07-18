-- [[ Config & Constants ]] --

MoronBox.Api = MoronBox.Api or {}

local myName = UnitName("player")

function getApi()
    return MoronBox.Api
end

-- [[ AddonMessages ]] --

local CdAddonMessageStore = {
    History = {},
    MaxHistory = 10,
}

--- Sends a message to the appropriate channel with a cooldown restriction.
--- @param prefix string: The unique channel prefix for the message.
--- @param message string: The payload to be sent.
--- @param timer number|nil: The cooldown in seconds (default 5).
function MoronBox.Api.CdAddonMessage(prefix, message, timer)
    local coolDown = timer or 5
    local time = GetTime()
    local messageKey = prefix .. ":" .. (message or "")

    local history = CdAddonMessageStore.History
    local lenght = table.getn(history)

    for i = 1, lenght do
        local entry = history[i]
        if entry.key == messageKey and (entry.time + coolDown) > time then
            return
        end
    end

    if lenght >= CdAddonMessageStore.MaxHistory then
        table.remove(history, 1)
    end

    table.insert(history,
        {
            key = messageKey,
            time = time
        }
    )

    MoronBox.Api.SendAddonMessage(prefix, message)
end

--- Abstraction for sending Addon messages based on group status.
--- @param prefix string: The unique channel prefix for the message.
--- @param message string: The payload to be sent.
function MoronBox.Api.SendAddonMessage(prefix, message)
    if UnitInRaid("player") then
        SendAddonMessage(prefix, message, "RAID")
    elseif GetNumPartyMembers() > 0 then
        SendAddonMessage(prefix, message, "PARTY")
    else
        -- How do we send a message? If not in raid nor party
    end
end

-- [[ Messages ]] --

local CdMessageStore = {
    History = {},
    MaxHistory = 10,
}

--- Sends a message to the appropriate channel with a cooldown restriction.
--- @param message string: The payload to be sent.
--- @param timer number|nil: The cooldown in seconds (default 5).
function MoronBox.Api.CdMessage(message, timer)
    local coolDown = timer or 5
    local time = GetTime()
    local messageKey = (message or "")

    local history = CdMessageStore.History
    local lenght = table.getn(history)

    for i = 1, lenght do
        local entry = history[i]
        if entry.key == messageKey and (entry.time + coolDown) > time then
            return
        end
    end

    if lenght >= CdMessageStore.MaxHistory then
        table.remove(history, 1)
    end

    table.insert(history,
        {
            key = messageKey,
            time = time
        }
    )

    MoronBox.Api.SendChatMessage(message)
end

--- Abstraction for sending messages based on group status.
--- @param message string: The payload to be sent.
function MoronBox.Api.SendChatMessage(message)
    if UnitInRaid("player") then
        SendChatMessage(message, "RAID")
    elseif GetNumPartyMembers() > 0 then
        SendChatMessage(message, "PARTY")
    else
        -- How do we send a message? If not in raid nor party
    end
end

local CdPrintStore = {
    History = {},
    MaxHistory = 10,
}

--- Sends a message with a cooldown restriction.
--- @param message string: The payload to be sent.
--- @param timer number|nil: The cooldown in seconds (default 15).
function MoronBox.Api.CdPrint(message, timer)
    local coolDown = timer or 15
    local time = GetTime()
    local messageKey = (message or "")

    local history = CdPrintStore.History
    local lenght = table.getn(history)

    for i = 1, lenght do
        local entry = history[i]
        if entry.key == messageKey and (entry.time + coolDown) > time then
            return
        end
    end

    if lenght >= CdPrintStore.MaxHistory then
        table.remove(history, 1)
    end

    table.insert(history,
        {
            key = messageKey,
            time = time
        }
    )

    print(message)
end

local CdRaidWarningStore = {
    History = {},
    MaxHistory = 10,
}

--- Sends a message with a cooldown restriction.
--- @param message string: The payload to be sent.
--- @param timer number|nil: The cooldown in seconds (default 15).
function MoronBox.Api.CdRaidWarning(message, timer)
    if not getRaid().ImFocus() then
        return
    end

    if not IsRaidLeader() then
        MoronBox.Api.CdMessage(message, timer)
        return
    end

    local coolDown = timer or 15
    local time = GetTime()
    local messageKey = (message or "")

    local history = CdRaidWarningStore.History
    local lenght = table.getn(history)

    for i = 1, lenght do
        local entry = history[i]
        if entry.key == messageKey and (entry.time + coolDown) > time then
            return
        end
    end

    if lenght >= CdRaidWarningStore.MaxHistory then
        table.remove(history, 1)
    end

    table.insert(history,
        {
            key = messageKey,
            time = time
        }
    )

    SendChatMessage(message, "RAID_WARNING")
end

local CdSayStore = {
    History = {},
    MaxHistory = 10,
}

--- Sends a say message with a cooldown restriction.
--- @param message string: The payload to be sent.
--- @param timer number|nil: The cooldown in seconds (default 5).
function MoronBox.Api.CdSay(message, timer)
    local coolDown = timer or 5
    local time = GetTime()
    local messageKey = (message or "")

    local history = CdSayStore.History
    local lenght = table.getn(history)

    for i = 1, lenght do
        local entry = history[i]
        if entry.key == messageKey and (entry.time + coolDown) > time then
            return
        end
    end

    if lenght >= CdSayStore.MaxHistory then
        table.remove(history, 1)
    end

    table.insert(history,
        {
            key = messageKey,
            time = time
        }
    )

    SendChatMessage(message, "SAY")
end

-- [[ String Extentions ]] --

--- Splits a string based on a delimiter.
--- @param subject string: The string to be split.
--- @param delimiter string|nil: The separator (default ":").
--- @return ...: The individual segments of the string.
function MoronBox.Api.StringSplit(subject, delimiter)
    local fields = {}
    local pattern = string.format("([^%s]+)", delimiter or ":")
    string.gsub(subject, pattern, function(c)
        fields[table.getn(fields) + 1] = c
    end)
    return unpack(fields)
end

-- [[ Group ]] --

--- Checks if the player is in a group or raid with other members present.
--- @return boolean: True if the player is in a Raid or Party with at least one other member, otherwise false.
function MoronBox.Api.GetGroupStatus()
    local inGroup = (UnitInRaid("player") or GetNumPartyMembers() > 0)
    local isAlone = (GetNumRaidMembers() == 0 and GetNumPartyMembers() == 0)
    return inGroup and not isAlone
end

-- [[ Table Extentions ]] --

--- Performs a deep copy of a table, recursively copying nested tables so the
--- result shares no references with the original (unlike a plain `=` assignment,
--- which only copies the reference and leaves both variables pointing at the
--- same underlying table).
--- Handles circular references safely via an internal lookup table, and
--- preserves metatables on copied tables.
--- @param src any: The value to copy. Non-table values are returned as-is.
--- @return any: A deep copy of src, or src itself if it isn't a table.
function MoronBox.Api.CopyTable(src)
    -- Tracks already-copied tables (original -> copy) so that circular
    -- references (a table that directly or indirectly contains itself)
    -- don't cause infinite recursion — we reuse the existing copy instead.
    local lookup_table = {}

    local function _copy(value)
        -- Non-table values (numbers, strings, booleans, nil) are copied by value already.
        if type(value) ~= "table" then
            return value
        elseif lookup_table[value] then
            -- Already copied this exact table elsewhere in the structure — reuse it.
            return lookup_table[value]
        end

        local new_table = {}
        lookup_table[value] = new_table

        -- Recursively copy both keys and values, in case a key is itself a table.
        for k, v in pairs(value) do
            new_table[_copy(k)] = _copy(v)
        end

        -- Preserve the original table's metatable (e.g. custom __index behavior),
        -- so the copy behaves the same way the original did.
        return setmetatable(new_table, getmetatable(value))
    end

    return _copy(src)
end

--- Sorts an array of strings alphabetically in-place.
--- @param list table: The array to sort.
function MoronBox.Api.SortAlphabetically(list)
    table.sort(list, function(a, b)
        return a < b
    end)
end

--- Empties a table in-place (removes all entries) without breaking existing
--- references to it — unlike `t = {}`, which only rebinds the local variable
--- and leaves anything holding the old reference (e.g. a closure) unaffected.
--- @param t table
function MoronBox.Api.ClearTable(t)
    for i = table.getn(t), 1, -1 do
        table.remove(t, i)
    end
end

function MoronBox.Api.sPairs(t, order)
    local keys = {}
    local size

    for k in pairs(t) do
        size = MoronBox.Api.TableLength(keys)
        keys[size + 1] = k
    end

    if order then
        table.sort(keys, function(a, b)
            return order(t, a, b)
        end)
    else
        table.sort(keys)
    end

    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

function MoronBox.Api.IncrementIndex(tab, len)
    if tab == len then
        return 1
    end
    return tab + 1
end

function MoronBox.Api.DecrementIndex(tab, len)
    if tab == 1 then
        return len
    end
    return tab - 1
end

function MoronBox.Api.TableInvert(tbl)
    local rv = {}
    for key, val in pairs(tbl) do
        rv[val] = key
    end
    return rv
end

---
--- Rounds `number` to the nearest integer, rounding half away from zero.
---
--- @param x number
--- @return number
--- @nodiscard
function math.round(x)
    return x >= 0 and math.floor(x + 0.5) or math.ceil(x - 0.5)
end

---@param tab table?
---@return integer
function MoronBox.Api.TableLength(tab)
    if not tab then
        return 0
    end
    local n = table.getn(tab)
    local count = 0
    for _ in pairs(tab) do
        count = count + 1
    end
    if count == n then
        getDebugger().WarnMsg(
            "Called on a sequential table — could use ArrayLength() instead for better performance.")
    end
    return count
end

---@param tab table?
---@return integer
function MoronBox.Api.ArrayLength(tab)
    if not tab then
        return 0
    end
    local n = table.getn(tab)
    local count = 0
    for _ in pairs(tab) do
        count = count + 1
    end
    if count ~= n then
        getDebugger().ErrorMsg(
            "Called on a non-sequential table — result may be wrong! Should use TableLength() instead.")
    end
    return n
end

--- Searches a table for a given value and returns true if found.
--- Logs an error via the Debugger and returns false if list is not a valid table.
--- @param list table: The table to search within.
--- @param needle? string|nil: The value to search for.
--- @return boolean: True if needle is found anywhere in list, false otherwise (including invalid input).
function MoronBox.Api.FindInTable(list, needle)
    if type(list) ~= "table" then
        getDebugger().ErrorMsg("FindInTable: expected a table, got " .. type(list))
        return false
    end

    for _, value in pairs(list) do
        if value == needle then
            return true
        end
    end

    return false
end

--- Convenience wrapper around FindInTable that checks for the current player's
--- own name specifically, e.g. to check if the player is already in a role/list
--- @param list table: The table to search within.
--- @return boolean: True if the player's own name is found in list, false otherwise.
function MoronBox.Api.FindMyNameInTable(list)
    return MoronBox.Api.FindInTable(list, myName)
end

function GetTankDefenceStats()
    local dodge, parry, block = GetDodgeChance(), GetParryChance(), GetBlockChance()
    local total = dodge + parry + block
    print(format("Def-Values: %.2f%% + %.2f%% + %.2f%% = %.2f%%", dodge, parry, block, total))
end

local CLASS_COLORS = {
    ["Warrior"] = "|cffC79C6E",
    ["Hunter"] = "|cffABD473",
    ["Mage"] = "|cff69CCF0",
    ["Rogue"] = "|cffFFF569",
    ["Warlock"] = "|cff9482C9",
    ["Druid"] = "|cffFF7D0A",
    ["Shaman"] = "|cff0070DE",
    ["Priest"] = "|cffFFFFFF",
    ["Paladin"] = "|cffF58CBA"
}

local RAID_MARKERS = {
    ["Skull"] = "|cffFFFFFF",
    ["Cross"] = "|cffFF0000",
    ["Square"] = "|cff00B4FF",
    ["Moon"] = "|cffCEECF5",
    ["Triangle"] = "|cff66FF00",
    ["Diamond"] = "|cffCC00FF",
    ["Circle"] = "|cffFF9900",
    ["Star"] = "|cffFFFF00"
}

local function applyColor(color, text)
    return color .. text .. "|r"
end

local function getUnitClassColor(unit, text)
    local _, unitClass = UnitClass(unit)
    if unitClass and CLASS_COLORS[unitClass] then
        return applyColor(CLASS_COLORS[unitClass], text)
    end
    return nil
end

function MoronBox.Api.GetColors(note)
    if note == myName then
        return getUnitClassColor("player", note)
    end

    if UnitInRaid("player") then
        for i = 1, GetNumRaidMembers() do
            local unit = "raid" .. i
            if UnitName(unit) == note then
                return getUnitClassColor(unit, note)
            end
        end
    end

    if UnitInParty("player") then
        for i = 1, GetNumPartyMembers() do
            local unit = "party" .. i
            if UnitName(unit) == note then
                return getUnitClassColor(unit, note)
            end
        end
    end

    if UnitName("target") == note then
        return getUnitClassColor("target", note)
    end

    if RAID_MARKERS[note] then
        return applyColor(RAID_MARKERS[note], note)
    end

    return note
end
