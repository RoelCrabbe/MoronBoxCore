-- [[ Config & Constants ]] --

MoronBox.Api = MoronBox.Api or {}

-- [[ AddonMessages ]] --

local CdAddonMessage = {
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

    local history = CdAddonMessage.History
    local lenght = table.getn(history)

    for i = 1, lenght do
        local entry = history[i]
        if entry.key == messageKey and (entry.time + coolDown) > time then
            return
        end
    end

    if lenght >= CdAddonMessage.MaxHistory then
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

local CdMessage = {
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

    local history = CdMessage.History
    local lenght = table.getn(history)

    for i = 1, lenght do
        local entry = history[i]
        if entry.key == messageKey and (entry.time + coolDown) > time then
            return
        end
    end

    if lenght >= CdMessage.MaxHistory then
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

local CdPrint = {
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

    local history = CdPrint.History
    local lenght = table.getn(history)

    for i = 1, lenght do
        local entry = history[i]
        if entry.key == messageKey and (entry.time + coolDown) > time then
            return
        end
    end

    if lenght >= CdPrint.MaxHistory then
        table.remove(history, 1)
    end

    table.insert(history,
        {
            key = messageKey,
            time = time
        }
    )

    Print(message)
end

local CdRaidWarning = {
    History = {},
    MaxHistory = 10,
}

--- Sends a message with a cooldown restriction.
--- @param message string: The payload to be sent.
--- @param timer number|nil: The cooldown in seconds (default 15).
function MoronBox.Api.CdRaidWarning(message, timer)
    if not mb_imFocus() then
        return
    end

    if not IsRaidLeader() then
        MoronBox.Api.CdMessage(message, timer)
        return
    end

    local coolDown = timer or 15
    local time = GetTime()
    local messageKey = (message or "")

    local history = CdRaidWarning.History
    local lenght = table.getn(history)

    for i = 1, lenght do
        local entry = history[i]
        if entry.key == messageKey and (entry.time + coolDown) > time then
            return
        end
    end

    if lenght >= CdRaidWarning.MaxHistory then
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

local CdSay = {
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

    local history = CdSay.History
    local lenght = table.getn(history)

    for i = 1, lenght do
        local entry = history[i]
        if entry.key == messageKey and (entry.time + coolDown) > time then
            return
        end
    end

    if lenght >= CdSay.MaxHistory then
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
