-- [[ Config & Constants ]] --

MoronBox.Core.Buffs = MoronBox.Core.Buffs or {}
MoronBox.Core.Buffs.LoadedBuffs = {}

local DEFAULT_PRIORITY = "NONE"
MoronBox.Core.Buffs.BuffPriority = {
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
    ["MarkOfTheWild"] = {
        "Mark of the Wild",
        "Gift of the Wild"
    },
    ["Spirit"] = {
        "Divine Spirit",
        "Prayer of Spirit",
    },
    ["ShadowProtection"] = {
        "Shadow Protection",
        "Prayer of Shadow Protection"
    },
    ["FearWard"] = {
        "Fear Ward",
    },
    ["Intellect"] = {
        "Arcane Intellect",
        "Arcane Brilliance"
    },
    ["PowerInfusion"] = {
        "Arcane Power",
        "Power Infusion",
    },
}

local BUFF_CAST_SPELLS = {
    ["Fortitude"] = {
        PriorityBuff = "Prayer of Fortitude",
        SecondaryBuff = "Power Word: Fortitude",
    },
    ["MarkOfTheWild"] = {
        PriorityBuff = "Gift of the Wild",
        SecondaryBuff = "Mark of the Wild",
    },
    ["Spirit"] = {
        PriorityBuff = "Prayer of Spirit",
        SecondaryBuff = "Divine Spirit",
    },
    ["ShadowProtection"] = {
        PriorityBuff = "Prayer of Shadow Protection",
        SecondaryBuff = "Shadow Protection",
    },
    ["FearWard"] = {
        PriorityBuff = "Fear Ward",
        SecondaryBuff = "Fear Ward",
    },
    ["Intellect"] = {
        PriorityBuff = "Arcane Brilliance",
        SecondaryBuff = "Arcane Intellect",
    },
    ["PowerInfusion"] = {
        PriorityBuff = "Power Infusion",
        SecondaryBuff = "Power Infusion",
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
    },
    ["ANYONE_CAPABLE_TO_CAST"] = {
        fields = { "spellName" },
        handler = "WhoCanCast"
    },
    ["CAPABLE_TO_CAST"] = {
        fields = { "playerName" },
        handler = "ICanCast"
    },
}

--- @alias BuffKey
--- | "Fortitude"
--- | "MarkOfTheWild"
--- | "Spirit"
--- | "ShadowProtection"
--- | "FearWard"
--- | "Intellect"
--- | "PowerInfusion"

-- [[ Lifecycle ]] --

--- Registers a new buff frame and enables addon message listening.
--- @param name string: The unique name identifier for the buff.
--- @return table: The frame object associated with the buff.
function MoronBox.Core.Buffs.Register(name)
    if MoronBox.Core.Buffs.LoadedBuffs[name] then
        return MoronBox.Core.Buffs.LoadedBuffs[name]
    end

    local buffFrame = CreateFrame("Frame", name)
    buffFrame:RegisterEvent("CHAT_MSG_ADDON")
    MoronBox.Core.Buffs.LoadedBuffs[name] = buffFrame
    return buffFrame
end

--- Unregisters a buff frame, cleans up events, and removes it from the loaded list.
--- @param name string: The unique name identifier of the buff to unregister.
function MoronBox.Core.Buffs.Unregister(name)
    local buffFrame = MoronBox.Core.Buffs.LoadedBuffs[name]
    if not buffFrame then return end

    buffFrame:UnregisterAllEvents()
    buffFrame:SetScript("OnEvent", nil)
    buffFrame:SetScript("OnUpdate", nil)
    buffFrame:Hide()

    MoronBox.Core.Buffs.LoadedBuffs[name] = nil
end

--- Determines if the buff module should be unloaded for a specific class.
--- @param className string: The class name to evaluate.
--- @return boolean: Returns true if the player is the class or if there are members of that class in the raid.
function MoronBox.Core.Buffs.UnLoad(className)
    if myClass == className then
        return true
    end

    local members = MoronBox.Core.State.ClassList[className]
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
function MoronBox.Core.Buffs.HasActiveBuff(buffKey, unitId)
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
function MoronBox.Core.Buffs.HasBuffPremissions(buffKey, requiredClass)
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
function MoronBox.Core.Buffs.GetBuffSpell(name)
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
function MoronBox.Core.Buffs.GetPriority(map)
    local pName = map[myClass] or DEFAULT_PRIORITY
    return MoronBox.Core.Buffs.BuffPriority[pName]
end

--- Determines the priority value for the player's class based on a provided priority map.
--- @param map table: A table mapping class names to priority keys (e.g., { ["Shaman"] = "HIGH" }).
--- @return number: The numerical priority value associated with the player's class or the default priority.
function MoronBox.Core.Buffs.GetCustomPriority(overwrites, map)
    local focId = MoronBox.Core.State.MBID[MB_raidLeader]
    local targetName = focId and UnitName(focId .. "target")

    if targetName and overwrites[targetName] then
        return overwrites[targetName]()
    end

    return MoronBox.Core.Buffs.GetPriority(map)
end

--- Determines the next target in the queue based on the lowest priority value.
--- @param queue table: A nested table containing group numbers, unit IDs, and their priorities.
--- @return string|nil: The unit ID of the best target, or nil if the queue is empty.
--- @return number: The group number associated with the best target, default 1.
function MoronBox.Core.Buffs.GetNextTarget(queue)
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

--- Filters an arbitrary list of candidate players by aliveness, mana, and
--- optionally race, then deterministically selects one via round-robin based
--- on groupNum. This is the shared selection core used both by class-derived
--- lookups (GetClassMemberForGroup) and by discovery-based candidate pools
--- (e.g. Power Infusion, where the eligible set isn't derivable from class
--- alone and must be built at runtime via addon-message discovery).
--- @param members table: Array of candidate player names to select from.
--- @param groupNum number: The group number, used as a deterministic seed for even distribution.
--- @param raceName nil|string: The race to filter by (e.g., "Dwarf"). Pass nil to skip race filtering.
--- @param requiredMana number: The minimum mana required for a member to be considered valid.
--- @return string|nil: The selected player name, or nil if no eligible candidate was found.
function MoronBox.Core.Buffs.GetMemberForGroup(members, groupNum, raceName, requiredMana)
    if not members or table.getn(members) == 0 then
        return nil
    end

    local eligible = {}
    for _, name in pairs(members) do
        local unitId = MoronBox.Core.State.MBID[name]
        local isAlive = mb_isAlive(unitId)
        local hasMana = mb_manaOfUnit(name) >= requiredMana
        local matchesRace = (raceName == nil) or (UnitRace(unitId) == raceName)

        if isAlive and hasMana and matchesRace then
            table.insert(eligible, name)
        end
    end

    local count = table.getn(eligible)
    if count == 0 then
        return nil
    end

    local index = mod(groupNum - 1, count) + 1
    return eligible[index]
end

--- Determines the assigned class member for a group, filtered by aliveness,
--- mana, and optionally race, then evenly distributed via round-robin.
--- Thin wrapper around GetMemberForGroup that resolves the candidate pool
--- from a class name instead of an arbitrary list.
--- @param className string: The class to search within (e.g., "Priest").
--- @param groupNum number: The group number, used as a deterministic seed for even distribution.
--- @param raceName nil|string: The race to filter by (e.g., "Dwarf").
--- @param requiredMana number: The minimum mana required for a member to be considered valid.
--- @return string|nil: The selected player name, or nil if no eligible candidate was found.
function MoronBox.Core.Buffs.GetClassMemberForGroup(className, groupNum, raceName, requiredMana)
    local members = MoronBox.Core.State.ClassList[className]
    if not members or table.getn(members) == 0 then
        if myClass == className then
            return myName
        end
        return nil
    end

    return MoronBox.Core.Buffs.GetMemberForGroup(members, groupNum, raceName, requiredMana)
end

--- Retrieves the current group number for the player from the cached group list.
--- @return number: The group number (defaults to 1 if not found).
function MoronBox.Core.Buffs.GetGroupNumber()
    return MoronBox.Core.State.GroupID[myName] or 1
end

-- [[ Casting ]] --

--- Attempts to cast a buff on the player if not in a group and the buff is not already active.
--- @param buffKey BuffKey: Buff key (e.g., "Fortitude"), used for HasActiveBuff check.
--- @param spellName string: The exact spell name to cast.
--- @return boolean|nil: true if cast successfully, false if already active or solo-condition met but no action, nil if in a group.
function MoronBox.Core.Buffs.SoloBuff(buffKey, spellName)
    if MoronBox.Api.GetGroupStatus() then
        return nil
    end

    ClearTarget()

    if MoronBox.Core.Buffs.HasActiveBuff(buffKey) then
        return false
    end

    CastSpellByName(spellName, nil)
    SpellTargetUnit("player")
    SpellStopTargeting()
    return true
end

-- [[ Messaging / Cross-client Sync ]] --

--- Creates a set of event handlers for buff-related communication.
--- @param buffConfig table: The configuration table for the specific buff.
--- Expected schema:
---   {
---     AddonPrefix: string,       -- The unique identifier for addon messages.
---     BuffKey: BuffKey,          -- The buff key used to look up aura names / cast spells.
---     Queue: table,              -- Local storage for pending buff requests by group.
---     ClaimedQueue: table,       -- Tracks which class has claimed which group.
---     CapableList: table|nil,    -- Optional: local list of players discovered to know a given spell.
---   }
--- @return table: The handlers table containing logic for messages and queue management.
function MoronBox.Core.Buffs.CreateHandlers(buffConfig)
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
        local requestPlayerId = MoronBox.Core.State.MBID[sender] or "player"

        -- Validate required packet data and ensure this player is the assigned target.
        if not requestPlayerId or not groupNum or not priority then
            return
        end

        if MoronBox.Api.GetGroupStatus() and assignedPlayer ~= myName then
            return
        end

        -- Verify if the player already has the buff; if so, notify the requester.
        if MoronBox.Core.Buffs.HasActiveBuff(buffConfig.BuffKey, requestPlayerId) then
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

    -- [[ Discovery ]] --

    -- Step 1: broadcast the question. Fire-and-forget, no response handling here.
    handlers.RequestCapable = function(spellName)
        handlers.SendMessage("ANYONE_CAPABLE", string.format("ANYONE_CAPABLE_TO_CAST:%s", spellName), 15)
    end

    -- Step 2: someone received the question. If I know the spell, announce myself.
    handlers.WhoCanCast = function(data)
        if mb_knowSpell(data.spellName) then
            handlers.SendMessage("CAPABLE", string.format("CAPABLE_TO_CAST:%s", myName), 9)
        end
    end

    -- Step 3: someone received an announcement. Record the player if not already known.
    handlers.ICanCast = function(data)
        if buffConfig.CapableList and not FindInTable(buffConfig.CapableList, data.playerName) then
            table.insert(buffConfig.CapableList, data.playerName)
            MoronBox.Api.SortAlphabetically(buffConfig.CapableList)
        end
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
function MoronBox.Core.Buffs.DispatchMessage(message, sender, handlers)
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

-- [[ Debugging ]] --

--- Prints the current Queue and ClaimedQueue state for a buff module, for debugging.
--- @param moduleName string: Display name for the debug header (e.g., MODULE_NAME).
--- @param queue table: The module's Queue table (groupNum -> { [unitId] = priority }).
--- @param claimedQueue table: The module's ClaimedQueue table (groupNum -> claiming player name).
function MoronBox.Core.Buffs.DebugTables(moduleName, queue, claimedQueue)
    MoronBox.Debugger:Info("--- " .. moduleName .. " Debug State ---")

    -- Queue Debug
    local queueCount = 0
    for groupNum, players in pairs(queue) do
        for player, prio in pairs(players) do
            queueCount = queueCount + 1
            MoronBox.Debugger:Info(string.format("Queue: Group %d | Player %s | Prio %d", groupNum, player, prio))
        end
    end
    if queueCount == 0 then
        MoronBox.Debugger:Info("Queue is empty.")
    end

    -- ClaimedQueue Debug
    local claimCount = 0
    for groupNum, priest in pairs(claimedQueue) do
        claimCount = claimCount + 1
        MoronBox.Debugger:Info(string.format("Claim: Group %d | Claimed by %s", groupNum, priest))
    end
    if claimCount == 0 then
        MoronBox.Debugger:Info("ClaimedQueue is empty.")
    end
end
