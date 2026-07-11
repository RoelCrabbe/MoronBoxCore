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
