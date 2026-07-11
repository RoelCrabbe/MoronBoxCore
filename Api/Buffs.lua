-- [[ Config & Constants ]] --

MoronBox.Api.Buffs = MoronBox.Api.Buffs or {}
MoronBox.Api.Buffs.LoadedBuffs = {}

local DEFAULT_PRIORITY = "NONE"
MoronBox.Api.Buffs.BuffPriority = {
    ["HIGH"] = 10,
    ["MEDIUM"] = 20,
    ["LOW"] = 30,
    [DEFAULT_PRIORITY] = 40,
}

local myClass = UnitClass("player") --[[@as string]]
local myName = UnitName("player") --[[@as string]]

local BUFF_AURA_NAMES = {
    ["Fortitude"] = {
        "Power Word: Fortitude",
        "Prayer of Fortitude"
    },
}

local BUFF_CAST_SPELLS = {
    ["Fortitude"] = {
        PriorityBuff = "Prayer of Fortitude",
        SecondaryBuff = "Power Word: Fortitude",
    },
}

local ADDON_MESSAGE_SCHEMA = {
    ["BUFF_INFO"] = {
        fields = { "priority", "groupNum", "assigned" },
        handler = "Request"
    },
    ["CLAIMING_GROUP"] = {
        fields = { "groupNum" },
        handler = "Claim"
    },
    ["BUFFED"] = {
        fields = { "requestPlayerId", "groupNum" },
        handler = "Buffed"
    }
}

--- @alias BuffKey
--- | "Fortitude"

-- [[ Lifecycle ]] --

--- Registers a new buff frame and enables addon message listening.
--- @param name string: The unique name identifier for the buff.
--- @return table: The frame object associated with the buff.
function MoronBox.Api.Buffs.Register(name)
    if MoronBox.Api.Buffs.LoadedBuffs[name] then
        return MoronBox.Api.Buffs.LoadedBuffs[name]
    end

    local buffFrame = CreateFrame("Frame", name)
    buffFrame:RegisterEvent("CHAT_MSG_ADDON")
    MoronBox.Api.Buffs.LoadedBuffs[name] = buffFrame
    return buffFrame
end

--- Unregisters a buff frame, cleans up events, and removes it from the loaded list.
--- @param name string: The unique name identifier of the buff to unregister.
function MoronBox.Api.Buffs.Unregister(name)
    local buffFrame = MoronBox.Api.Buffs.LoadedBuffs[name]
    if not buffFrame then return end

    buffFrame:UnregisterAllEvents()
    buffFrame:SetScript("OnEvent", nil)
    buffFrame:SetScript("OnUpdate", nil)
    buffFrame:Hide()

    MoronBox.Api.Buffs.LoadedBuffs[name] = nil
end

--- Determines if the buff module should be unloaded for a specific class.
--- @param className string: The class name to evaluate.
--- @return boolean: Returns true if the player is the class or if there are members of that class in the raid.
function MoronBox.Api.Buffs.UnLoad(className)
    if myClass == className then return true end
    local members = MB_classList[className]
    if not members then
        return false
    end

    return table.getn(members) > 0
end

-- [[ State Queries ]] --

--- Checks if the player currently has any of the buffs associated with the given key.
--- @param buffKey BuffKey: The key used to look up the buff definitions.
--- @param unitId nil|string: The unit ID to check for the buff.
--- @return boolean: True if at least one buff is active on the player, otherwise false.
function MoronBox.Api.Buffs.HasActiveBuff(buffKey, unitId)
    local list = BUFF_AURA_NAMES[buffKey]
    if not list then return false end

    if not unitId then
        unitId = "player"
    end

    for _, buffName in pairs(list) do
        if mb_hasBuffOrDebuff(buffName, unitId, "buff") then
            return true
        end
    end

    return false
end

--- Checks if the player meets the permissions and requirements to cast a specific buff.
--- @param buffKey BuffKey: The key used to look up the buff definitions.
--- @param requiredClass string: The class required to be able to cast the buff.
--- @return boolean: True if the class matches, the player is not busy, and the spell is ready; otherwise false.
function MoronBox.Api.Buffs.HasBuffPremissions(buffKey, requiredClass)
    if myClass ~= requiredClass then
        return false
    end

    if mb_imBusy() then
        return false
    end

    local list = BUFF_AURA_NAMES[buffKey]
    if not list then return false end

    for _, spellName in pairs(list) do
        if mb_spellReady(spellName) then
            return true
        end
    end

    return false
end

--- Determines the appropriate spell to cast based on group status and buff configuration.
--- @param name BuffKey: The buff key (e.g., "Fortitude").
--- @return string: The selected spell name.
function MoronBox.Api.Buffs.GetBuffSpell(name)
    local config = BUFF_CAST_SPELLS[name]
    if not config then
        error("Unknown buff: " .. tostring(name))
    end

    if MoronBox.Api.GetGroupStatus() then
        return config.PriorityBuff
    else
        return config.SecondaryBuff
    end
end

-- [[ Targeting & Priority Helpers ]] --

--- Determines the priority value for the player's class based on a provided priority map.
--- @param map table: A table mapping class names to priority keys (e.g., { ["Shaman"] = "HIGH" }).
--- @return number: The numerical priority value associated with the player's class or the default priority.
function MoronBox.Api.Buffs.GetPriority(map)
    local pName = map[myClass] or DEFAULT_PRIORITY
    return MoronBox.Api.Buffs.BuffPriority[pName]
end

--- Determines the next target in the queue based on the lowest priority value.
--- @param queue table: A nested table containing group numbers, unit IDs, and their priorities.
--- @return string|nil: The unit ID of the best target, or nil if the queue is empty.
--- @return number: The group number associated with the best target, default 1.
function MoronBox.Api.Buffs.GetNextTarget(queue)
    local bestPriority = nil
    local bestUnitId, bestGroup = nil, 1

    for groupNum, players in pairs(queue) do
        for unitId, priority in pairs(players) do
            -- Lower Number = High Priority
            if not bestPriority or priority < bestPriority then
                bestPriority, bestUnitId, bestGroup = priority, unitId, groupNum
            end
        end
    end

    return bestUnitId, bestGroup
end

--- Determines the assigned class member for a group, filtered by aliveness and mana, then evenly distributed via round-robin.
--- @param className string: The class to search within (e.g., "Priest").
--- @param groupNum number: The group number, used as a deterministic seed for even distribution.
--- @param requiredMana number: The minimum mana required for a member to be considered valid.
--- @return string|nil
function MoronBox.Api.Buffs.GetClassMemberForGroup(className, groupNum, requiredMana)
    local members = MB_classList[className]
    if not members or table.getn(members) == 0 then
        if myClass == className then return myName end
        return nil
    end

    local eligible = {}
    for _, name in pairs(members) do
        local unitId = MBID[name]
        if mb_isAlive(unitId) and mb_manaOfUnit(name) >= requiredMana then
            table.insert(eligible, name)
        end
    end

    local pool = eligible
    if table.getn(pool) == 0 then
        pool = members
    end

    local count = table.getn(pool)
    local index = mod(groupNum - 1, count) + 1
    return pool[index]
end

--- Retrieves the current group number for the player from the cached group list.
--- @return number: The group number (defaults to 1 if not found).
function MoronBox.Api.Buffs.GetGroupNumber()
    return MB_groupID[myName] or 1
end

-- [[ Casting ]] --

--- Attempts to cast a buff on the player if not in a group and the buff is not already active.
--- @param name BuffKey: Buff key (e.g., "Fortitude"), used for HasActiveBuff check.
--- @param spell string: The exact spell name to cast.
--- @return boolean|nil: true if cast successfully, false if already active or solo-condition met but no action, nil if in a group.
function MoronBox.Api.Buffs.SoloBuff(name, spell)
    if MoronBox.Api.GetGroupStatus() then
        return nil
    end

    ClearTarget()

    if MoronBox.Api.Buffs.HasActiveBuff(name) then
        return false
    end

    CastSpellByName(spell, nil)
    SpellTargetUnit("player")
    SpellStopTargeting()
    return true
end

-- [[ Messaging / Cross-client Sync ]] --

--- Creates a set of event handlers for buff-related communication.
--- @param buffConfig table: The configuration table for the specific buff.
--- Expected schema:
---   {
---     AddonPrefix: string, -- The unique identifier for addon messages.
---     BuffKey: BuffKey,     -- The name of the buff to check for.
---     Queue: table,        -- Local storage for pending buff requests by group.
---     ClaimedQueue: table  -- Tracks which class has claimed which group.
---   }
--- @return table: The handlers table containing logic for messages and queue management.
function MoronBox.Api.Buffs.CreateHandlers(buffConfig)
    local handlers = {}

    -- Checks if the received prefix belongs to the current buff config.
    handlers.IsOwnMessage = function(prefix)
        return string.find(prefix, "_" .. buffConfig.AddonPrefix .. "$") ~= nil
    end

    -- Generates a standardized addon communication prefix.
    handlers.GetPrefix = function(name)
        return MB_RAID .. "_" .. name .. "_" .. buffConfig.AddonPrefix
    end

    -- Sends an addon message using the predefined cooldown API.
    handlers.SendMessage = function(prefix, message, cooldown)
        MoronBox.Api.CdAddonMessage(handlers.GetPrefix(prefix), message, cooldown)
    end

    -- Handles incoming buff requests from other players.
    -- Processes validation, buff state checking, and group queue assignment.
    handlers.Request = function(data, sender)
        local priority = tonumber(data.priority)
        local groupNum = tonumber(data.groupNum)
        local assignedPlayer = data.assigned or myName
        local requestPlayerId = MBID[sender] or "player"

        -- Validate required packet data and ensure this player is the assigned target.
        if not requestPlayerId or not groupNum or not priority then
            return
        end

        if MoronBox.Api.GetGroupStatus() and assignedPlayer ~= myName then
            return
        end

        -- Verify if the player already has the buff; if so, notify the requester.
        if MoronBox.Api.Buffs.HasActiveBuff(buffConfig.BuffKey, requestPlayerId) then
            handlers.SendMessage("BUFFED", string.format("BUFFED:%s:%d", requestPlayerId, groupNum))
            return
        end

        -- Queue management: add requester to the group queue if not already claimed by another player.
        if not buffConfig.Queue[groupNum] then buffConfig.Queue[groupNum] = {} end
        if buffConfig.Queue[groupNum][requestPlayerId] then return end
        if buffConfig.ClaimedQueue[groupNum] and buffConfig.ClaimedQueue[groupNum] ~= myName then return end

        buffConfig.Queue[groupNum][requestPlayerId] = priority
        handlers.SendMessage("CLAIM", string.format("CLAIMING_GROUP:%g", groupNum))
    end

    -- Processes group claim synchronization messages to prevent multiple players from serving the same group.
    handlers.Claim = function(data, sender)
        local groupNum = tonumber(data.groupNum)
        if not groupNum or buffConfig.ClaimedQueue[groupNum] then
            return
        end

        buffConfig.ClaimedQueue[groupNum] = sender
    end

    -- Handles successful buff confirmation from the group to clear the queue and release the claim.
    handlers.Buffed = function(data, sender)
        local requestPlayerId = data.requestPlayerId
        local groupNum = tonumber(data.groupNum)

        if not requestPlayerId or not groupNum then
            return
        end

        -- Remove player from local queue if we were the one processing the request.
        if myName == sender then
            if buffConfig.Queue[groupNum] then
                buffConfig.Queue[groupNum][requestPlayerId] = nil
            end
        end

        -- Free the group claim.
        buffConfig.ClaimedQueue[groupNum] = nil
    end

    return handlers
end

--- Parses an incoming addon message based on a defined schema and dispatches it to the appropriate handler.
--- @param message string: The raw addon message string received.
--- @param sender string: The name of the player who sent the message.
--- @param handlers table: The table of function handlers (e.g., Request, Claim, Buffed).
--- Expected structure for ADDON_MESSAGE_SCHEMA[msgType]:
---   {
---     handler: string, -- The key in the handlers table to execute (e.g., "Request").
---     fields: table    -- An array of strings representing the data keys to map the message parts to.
---   }
function MoronBox.Api.Buffs.DispatchMessage(message, sender, handlers)
    local parts = { MoronBox.Api.StringSplit(message) }
    local msgType = parts[1]
    local schema = ADDON_MESSAGE_SCHEMA[msgType]

    -- Validate that the message type is registered and the handler exists.
    if not schema or not handlers[schema.handler] then return end

    -- Map message parts to their corresponding field names defined in the schema.
    -- parts[1] is the msgType, so data mapping starts at parts[2].
    local data = {}
    for i, fieldName in ipairs(schema.fields) do
        data[fieldName] = parts[i + 1]
    end

    -- Invoke the handler with the mapped data table and the original sender.
    handlers[schema.handler](data, sender)
end
