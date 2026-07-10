MoronBox.Api.Buffs = {}
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
local myRace = UnitRace("player") --[[@as string]]

local BUFF_EVENTS = {
    "CHAT_MSG_ADDON",
    "ZONE_CHANGED_NEW_AREA",
    "PLAYER_ENTERING_WORLD",
    "PLAYER_REGEN_ENABLED"
}

local function RegisterEvents(frame)
    for _, event in BUFF_EVENTS do
        frame:RegisterEvent(event)
    end
end

--- @param name string: Name of the buff to register
MoronBox.Api.Buffs.Register = function(name)
    if MoronBox.Api.Buffs.LoadedBuffs[name] then
        return MoronBox.Api.Buffs.LoadedBuffs[name]
    end

    local buffFrame = CreateFrame("Frame", name)
    RegisterEvents(buffFrame)
    MoronBox.Api.Buffs.LoadedBuffs[name] = buffFrame
    return buffFrame
end

--- @param name string: Name of the buff to unregister
MoronBox.Api.Buffs.Unregister = function(name)
    local buffFrame = MoronBox.Api.Buffs.LoadedBuffs[name]
    if not buffFrame then return end

    buffFrame:UnregisterAllEvents()
    buffFrame:SetScript("OnEvent", nil)
    buffFrame:SetScript("OnUpdate", nil)
    buffFrame:Hide()

    MoronBox.Api.Buffs.LoadedBuffs[name] = nil
end

--- @param map table
--- @return number
MoronBox.Api.Buffs.GetPriority = function(map)
    local pName = map[myClass] or DEFAULT_PRIORITY
    return MoronBox.Api.Buffs.BuffPriority[pName]
end

local function printTable(t, indent)
    indent = indent or ""
    for k, v in pairs(t) do
        print(k .. " = " .. tostring(v))
        if type(v) == "table" then
            print(indent .. tostring(k) .. ":")
            printTable(v, indent .. "  ")
        else
            print(indent .. tostring(k) .. " = " .. tostring(v))
        end
    end
end

--- @param queue table
--- @return string|nil, number|nil, number|nil
MoronBox.Api.Buffs.GetNextTarget = function(queue)
    local bestUnitId, bestPriority, bestGroup = nil, nil, nil

    for groupNum, players in pairs(queue) do
        for unitId, priority in pairs(players) do
            -- Lower Number = High Priority
            if not bestPriority or priority < bestPriority then
                bestPriority, bestGroup, bestUnitId = priority, groupNum, unitId
            end
        end
    end

    return bestUnitId, bestPriority, bestGroup
end

--- @param className string
--- @return nil|string
MoronBox.Api.Buffs.GetRandomClassMember = function(className)
    local members = MB_classList[className]
    if not members or table.getn(members) == 0 then
        return myName
    end

    return members[math.random(table.getn(members))]
end

--- @return number|nil
MoronBox.Api.Buffs.GetGroupNumber = function()
    return MB_groupID[myName] or 1
end

-- De blauwdruk voor je communicatie
local MessageSchema = {
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

MoronBox.Api.Buffs.strsplit = function(delimiter, subject)
    if not subject then return nil end
    delimiter, fields = delimiter or ":", {}
    local pattern = string.format("([^%s]+)", delimiter)
    string.gsub(subject, pattern, function(c) fields[table.getn(fields) + 1] = c end)
    return unpack(fields)
end

--- @param buffConfig table: { BuffName, AddonPrefix, Queue, ClaimedQueue }
MoronBox.Api.Buffs.CreateHandlers = function(buffConfig)
    local handlers = {}

    handlers.GetPrefix = function(name)
        return MB_RAID .. "_" .. name .. "_" .. buffConfig.AddonPrefix
    end

    handlers.SendMessage = function(prefix, message, cooldown)
        mb_cdAddonMessage(handlers.GetPrefix(prefix), message, cooldown)
    end

    handlers.Request = function(data, sender)
        -- parts[1] is "BUFF_INFO", dus we beginnen bij parts[2]
        -- Schema: { "priority", "groupNum", "assigned" }
        local priority = tonumber(data.priority)
        local groupNum = tonumber(data.groupNum)
        local assignedPriest = data.assigned or myName
        local requestPlayerId = MBID[sender] or "player"

        -- Validatie
        if not requestPlayerId or not groupNum or not priority then -- or assignedPriest ~= myName then
            return
        end

        local inGroup = UnitInRaid("player") or GetNumPartyMembers() > 2
        if inGroup and assignedPriest ~= myName then
            return
        end

        -- Check buff
        if mb_hasBuffOrDebuff(buffConfig.BuffName, requestPlayerId, "buff") then
            handlers.SendMessage("BUFFED", string.format("BUFFED:%s:%d", requestPlayerId, groupNum))
            return
        end

        -- Queue logic
        if not buffConfig.Queue[groupNum] then buffConfig.Queue[groupNum] = {} end
        if buffConfig.Queue[groupNum][requestPlayerId] then return end
        if buffConfig.ClaimedQueue[groupNum] and buffConfig.ClaimedQueue[groupNum] ~= myName then return end

        buffConfig.Queue[groupNum][requestPlayerId] = priority
        handlers.SendMessage("CLAIM", string.format("CLAIMING_GROUP:%g", groupNum))
    end

    handlers.Claim = function(data, sender)
        -- Schema: { "CLAIMING_GROUP", "groupNum" }
        local groupNum = tonumber(data.groupNum)
        if not groupNum or buffConfig.ClaimedQueue[groupNum] then
            return
        end

        buffConfig.ClaimedQueue[groupNum] = sender
    end

    handlers.Buffed = function(data, sender)
        -- Schema: { "BUFFED", "requestPlayerId", "groupNum" }
        local requestPlayerId = data.requestPlayerId
        local groupNum = tonumber(data.groupNum)

        if not requestPlayerId or not groupNum then
            return
        end

        if myName == sender then
            if buffConfig.Queue[groupNum] then
                buffConfig.Queue[groupNum][requestPlayerId] = nil
            end
        end

        buffConfig.ClaimedQueue[groupNum] = nil
    end

    return handlers
end

MoronBox.Api.Buffs.DispatchMessage = function(message, sender, handlers)
    local parts = { MoronBox.Api.Buffs.strsplit(":", message) }
    local msgType = parts[1]
    local schema = MessageSchema[msgType]

    if not schema or not handlers[schema.handler] then return end

    -- Automatisch mappen van velden naar namen
    local data = {}
    for i, fieldName in ipairs(schema.fields) do
        data[fieldName] = parts[i + 1]
    end

    -- Stuur de 'data' tabel en 'sender' door naar de handler
    handlers[schema.handler](data, sender)
end

local BuffDefinitions = {
    ["Fortitude"] = {
        "Power Word: Fortitude",
        "Prayer of Fortitude"
    },
}

--- @param buffKey string: De sleutel (bijv. "Fortitude")
--- @return boolean: true als je een van de buffs hebt, anders false
MoronBox.Api.Buffs.HasActiveBuff = function(buffKey)
    local list = BuffDefinitions[buffKey]
    if not list then return false end

    for _, buffName in pairs(list) do
        if mb_hasBuffOrDebuff(buffName, "player", "buff") then
            return true
        end
    end

    return false
end

--- @param buffKey string
--- @param requiredClass string
--- @return boolean
MoronBox.Api.Buffs.HasBuffPremissions = function(buffKey, requiredClass)
    if myClass ~= requiredClass then
        return false
    end

    if mb_imBusy() then
        return false
    end

    local list = BuffDefinitions[buffKey]
    if not list then return false end

    for _, spellName in pairs(list) do
        if mb_spellReady(spellName) then
            return true
        end
    end

    return false
end
