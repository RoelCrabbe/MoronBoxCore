--[####################################################################################################]--
--[###################################### FORTITUDE BUFF SYSTEM ########################################]--
--[####################################################################################################]--

-- Unit Functions
local UnitName = UnitName
local UnitClass = UnitClass
local UnitRace = UnitRace
local UnitLevel = UnitLevel
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitMana = UnitMana
local UnitManaMax = UnitManaMax
local UnitPowerType = UnitPowerType
local UnitExists = UnitExists
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitIsDead = UnitIsDead
local UnitIsGhost = UnitIsGhost
local UnitIsConnected = UnitIsConnected
local UnitInParty = UnitInParty
local UnitInRaid = UnitInRaid
local UnitCanAttack = UnitCanAttack
local UnitIsFriend = UnitIsFriend
local UnitIsEnemy = UnitIsEnemy
local UnitIsVisible = UnitIsVisible
local UnitAffectingCombat = UnitAffectingCombat
local UnitCreatureType = UnitCreatureType
local UnitClassification = UnitClassification

-- Buff/Debuff Functions
local UnitBuff = UnitBuff
local UnitDebuff = UnitDebuff

-- Spell Functions
local CastSpellByName = CastSpellByName
local GetSpellCooldown = GetSpellCooldown
local IsCurrentAction = IsCurrentAction

-- Target Functions
local TargetUnit = TargetUnit
local TargetByName = TargetByName
local ClearTarget = ClearTarget
local AssistUnit = AssistUnit

-- Party/Raid Functions
local GetNumPartyMembers = GetNumPartyMembers
local GetNumRaidMembers = GetNumRaidMembers
local GetRaidRosterInfo = GetRaidRosterInfo
local IsRaidLeader = IsRaidLeader

-- Player Position/Info Functions
local GetRealZoneText = GetRealZoneText
local GetSubZoneText = GetSubZoneText

-- Addon Communication (if supported on your server)
local SendAddonMessage = SendAddonMessage

-- Misc Utility Functions
local IsShiftKeyDown = IsShiftKeyDown
local IsControlKeyDown = IsControlKeyDown
local IsAltKeyDown = IsAltKeyDown

-- Common Names
local myClass = UnitClass("player")
local myName = UnitName("player")
local myRace = UnitRace("player")

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local CdAddonMessage = mb_cdAddonMessage
local CdMessage = mb_cdMessage
local CdPrint = mb_cdPrint
local HasBuffOrDebuff = mb_hasBuffOrDebuff
local ImBusy = mb_imBusy
local IsValidFriendlyTarget = mb_isValidFriendlyTarget
local SpellReady = mb_spellReady

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local FORT = CreateFrame("Button", "FORT", UIParent)

do
	for _, event in {
		"CHAT_MSG_ADDON",
        "CHAT_MSG_COMBAT_HOSTILE_DEATH",
        "ZONE_CHANGED_NEW_AREA",
        "PLAYER_ENTERING_WORLD",
        "PLAYER_REGEN_ENABLED"
		} do FORT:RegisterEvent(event)
	end
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local MB_FORTQueue = {}
local MB_FORTClaimedQueue = {}

local function FortitudePriority()
    local PRIORITY = {
        HIGH   = 10,
        MEDIUM = 20,
        LOW    = 30,
        NONE   = 40
    }

    if FindInTable(MB_raidTanks, myName) then
        return PRIORITY.HIGH
    elseif myClass == "Mage" then
        return PRIORITY.MEDIUM
    elseif myClass == "Priest" then
        return PRIORITY.LOW
    else
        return PRIORITY.NONE
    end
end

local function GetNextFortitudeTarget()
    local bestGroupNum = nil
    local bestPriority = nil
    local bestUnitId = nil
    
    for groupNum, playersInGroup in pairs(MB_FORTQueue) do
        for unitId, priority in pairs(playersInGroup) do
            if bestPriority == nil or priority < bestPriority then
                bestPriority = priority
                bestGroupNum = groupNum
                bestUnitId = unitId
            end
        end
    end
    
    if not bestGroupNum or not bestUnitId then
        return nil, nil
    end
    
    return bestUnitId, bestPriority, bestGroupNum
end

local function GetPriestInGroup()
    local priests = {}

    if UnitInRaid("player") then
        for i = 1, GetNumRaidMembers() do
            local rName, _, _, _, rClass = GetRaidRosterInfo(i)
            if rClass == "Priest" then
                table.insert(priests, rName)
            end
        end
    else
        if myClass == "Priest" then
            table.insert(priests, myName)
        end
           
        for i = 1, 4 do
            local pName = UnitName("party"..i)
            local pClass = UnitClass("party"..i)

            if pName and pClass == "Priest" then
                table.insert(priests, pName)
            end
        end
    end

    if TableLength(priests) == 0 then
        return nil
    else
        return priests[math.random(TableLength(priests))]
    end
end

local function GetMyRaidGroup()
    if not UnitInRaid("player") then
        return 1
    end

    for i = 1, GetNumRaidMembers() do
        local name, _, subgroup = GetRaidRosterInfo(i)
        if name == myName then
            return subgroup
        end
    end
    
    return nil
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local function HandleFortitudeRequest(message, sender)
    local _, _, priority, groupNum, assignedPriest = string.find(message, "BUFF_INFO:(%d+):(%d+):(.+)")
    
    local requestPlayer = sender
    local requestPlayerId = MBID[requestPlayer]
    
    if not requestPlayerId or not groupNum then
        return
    end
    
    if assignedPriest ~= myName then
        return
    end
    
    if HasBuffOrDebuff("Power Word: Fortitude", requestPlayerId, "buff") then
        CdAddonMessage(MB_RAID.."BUFFED_FORTITUDE", "BUFFED:"..requestPlayer)
        return
    end
    
    if HasBuffOrDebuff("Prayer of Fortitude", requestPlayerId, "buff") then
        CdAddonMessage(MB_RAID.."BUFFED_FORTITUDE", "BUFFED:"..requestPlayer)
        return
    end

    local groupNumInt = tonumber(groupNum)
    local priorityInt = tonumber(priority)
    
    if not MB_FORTQueue[groupNumInt] then
        MB_FORTQueue[groupNumInt] = {}
    end
    
    if MB_FORTQueue[groupNumInt][requestPlayerId] then
        return
    end

    MB_FORTQueue[groupNumInt][requestPlayerId] = priorityInt
    CdAddonMessage(MB_RAID.."CLAIM_FORTITUDE", "CLAIMING_GROUP:"..groupNum)
end

local function HandleFortitudeClaim(message, claimer)
    local _, _, groupNum = string.find(message, "CLAIMING_GROUP:(%d+)")
    if not groupNum then return end
    
    local groupNumInt = tonumber(groupNum)

    MB_FORTClaimedQueue[groupNumInt] = claimer
end

local function HandleFortitudeBuffed(message, sender)
    local _, _, requestPlayer, groupNum = string.find(message, "BUFFED:(%d+):(.+)")
    if not requestPlayer then return end

    local groupNumInt = tonumber(groupNum)
    local requestPlayerId = MBID[requestPlayer]

    if myName == sender then
        MB_FORTQueue[groupNumInt][requestPlayerId] = nil
    end

    MB_FORTClaimedQueue[groupNumInt] = nil
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function FORT:OnEvent()
	if (event == "CHAT_MSG_ADDON") then
        local message, sender = arg2, arg4

        if (arg1 == MB_RAID.."NEED_FORTITUDE") then
            HandleFortitudeRequest(message, sender)
        elseif (arg1 == MB_RAID.."CLAIM_FORTITUDE") then
            HandleFortitudeClaim(message, sender)
        elseif (arg1 == MB_RAID.."BUFFED_FORTITUDE") then
            HandleFortitudeBuffed(message, sender)
        end
    end
end

FORT:SetScript("OnEvent", FORT.OnEvent) 

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function FORT_RequestFortitude()
    if HasBuffOrDebuff("Power Word: Fortitude", "player", "buff") then
        return
    end

    if HasBuffOrDebuff("Prayer of Fortitude", "player", "buff") then
        return
    end

    local myBuffingPriest = GetPriestInGroup()
    local myPriority = FortitudePriority()
    local myGroup = GetMyRaidGroup()

    if not myBuffingPriest or not myPriority or not myGroup then
        return
    end

    local message = "BUFF_INFO:"..myPriority..":"..myGroup..":"..myBuffingPriest
    CdAddonMessage(MB_RAID.."NEED_FORTITUDE", message, 15)
end

function FORT_ProcessFortitudeQueue()
    if myClass ~= "Priest" then
        return false
    end

    local spellName = "Prayer of Fortitude"
    local targetUnitId, priority, groupNum = GetNextFortitudeTarget()

    if not targetUnitId or not priority or not groupNum then
        return false
    end

    local targetName = UnitName(targetUnitId)
    local groupNumInt = tonumber(groupNum)

    if ImBusy() or not SpellReady(spellName) then
        return false
    end

    if IsValidFriendlyTarget(targetUnitId, spellName) and not HasBuffOrDebuff(spellName, targetUnitId, "buff") then
        CastSpellByName(spellName, false)
        SpellTargetUnit(targetUnitId)
        SpellStopTargeting()
        return true
    end

    local message = "BUFFED:"..targetName..":"..groupNumInt
    CdAddonMessage(MB_RAID.."BUFFED_FORTITUDE", message)
    return false
end
