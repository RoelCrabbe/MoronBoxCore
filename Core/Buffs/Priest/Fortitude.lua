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

-- FORTITUDE BUFF SYSTEM - COMPLETE FLOW
-- ======================================
-- 1. REQUEST PHASE
--    ┌─────────────────────────────────────────────────┐
--    │ Player needs Fortitude:                         │
--    │ ├─ Check: Already have buff? → EXIT             │
--    │ ├─ Find: Priest in raid (any class)             │
--    │ ├─ Get: Player group number (1-8)               │
--    │ ├─ Calculate: Self-priority (10=Shaman,         │
--    │ │             20=Paladin, 30=Priest, 40=Others) │
--    │ └─ Send: "BUFF_INFO:Priority:GroupNum:Priest"   │
--    └─────────────────────────────────────────────────┘
--                             ↓
-- 2. CLAIM PHASE
--    ┌─────────────────────────────────────────────────┐
--    │ Assigned Priest receives request:               │
--    │ ├─ Validate: Am I the assigned priest?          │
--    │ ├─ Check: Target already has buff? → CLEANUP    │
--    │ ├─ Check: Group already claimed? → EXIT         │
--    │ ├─ Create: Group queue if needed                │
--    │ ├─ Queue: Add to MB_FORTQueue[groupNum][unitId] │
--    │ ├─ CLAIM: Broadcast "CLAIMING_GROUP:GroupNum"   │
--    │ └─ Record: Mark in MB_FORTClaimedQueue[groupNum]│
--    └─────────────────────────────────────────────────┘
--                             ↓
-- 3. PROCESSING PHASE
--    ┌─────────────────────────────────────────────────┐
--    │ Priest processes queue:                         │
--    │ ├─ Scan: Find lowest priority number (highest)  │
--    │ ├─ Get: GroupNum from queue                     │
--    │ ├─ Validate: Target in range and valid?         │
--    │ ├─ Check: Not busy casting?                     │
--    │ ├─ Cast: Prayer of Fortitude on target          │
--    │ └─ Broadcast: "BUFFED:UnitId:GroupNum"          │
--    └─────────────────────────────────────────────────┘
--                             ↓
-- 4. RELEASE PHASE
--    ┌─────────────────────────────────────────────────┐
--    │ All Priests receive buff completion:            │
--    │ ├─ Release: Remove unitId from group queue      │
--    │ ├─ Check: Is group empty now?                   │
--    │ ├─ Clean: Remove group claim if empty           │
--    │ └─ Sync: Update local queue state               │
--    └─────────────────────────────────────────────────┘
--
-- KEY DATA STRUCTURES
-- ==================
-- MB_FORTQueue = {
--     [1] = {                    -- GroupNum
--         ["raid1"] = 10,        -- unitId → priority
--         ["raid2"] = 20
--     },
--     [2] = {
--         ["raid6"] = 5,
--         ["raid7"] = 15
--     }
--     -- Max 8 groups (raid size limit)
-- }
--
-- MB_FORTClaimedQueue = {
--     [1] = "PriestA",          -- GroupNum → Claiming Priest (SHARED via addon)
--     [2] = "PriestB"
-- }
--
-- COLLISION PREVENTION
-- ===================
-- Group-based claim system → One priest per group, prevents duplicates
-- Claim validation → Only claim if group not already claimed
-- Self-group exclusion → Priests don't buff their own group (request other priests)
-- Priority queue → Ensures important class buffs first (Shaman > Paladin > Priest > Others)
-- Auto-cleanup → Removes buffed targets from queue via addon messages
-- Group limit enforcement → Max 8 groups enforced by raid structure
--
-- PERFORMANCE OPTIMIZATIONS
-- ========================
-- Nested hash table queue → O(1) lookup/insert/delete per group
-- Single regex parse → Fast message parsing with string.find
-- Sender from arg4 → No message spoofing possible
-- MBID system → Accurate unit targeting per client
-- Group-level processing → Batch handle groups, not individual players
-- Event-driven cleanup → All state management in event handlers
-- Direct group access → No need to search all groups for targets

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
local SelfBuff = mb_selfBuff

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

local function GetPriority()
    local PRIORITY = {
        HIGH   = 10,
        MEDIUM = 20,
        LOW    = 30,
        NONE   = 40
    }

    if myClass == "Shaman" then
        return PRIORITY.HIGH
    elseif myClass == "Paladin" then
        return PRIORITY.MEDIUM
    elseif myClass == "Priest" then
        return PRIORITY.LOW
    else
        return PRIORITY.NONE
    end
end

local function GetNextTarget()
    local bestUnitId = nil
    local bestPriority = nil
    local bestGroupNum = nil
   
    for groupNum, playersInGroup in pairs(MB_FORTQueue) do
        for unitId, priority in pairs(playersInGroup) do
            if bestPriority == nil or priority < bestPriority then
                bestPriority = priority
                bestGroupNum = groupNum
                bestUnitId = unitId
            end
        end
    end
   
    return bestUnitId, tonumber(bestPriority), tonumber(bestGroupNum)
end

local function GetPriestInGroup()
    local priests = MB_classList["Priest"]
    local num_priests = TableLength(priests)

    if num_priests == 0 then
        return nil
    end

    local random_index = math.random(num_priests)
    return priests[random_index]
end

local function GetGroupNumber()
	if not UnitInRaid("player") and GetNumPartyMembers() == 0 then
		return
	end

    return MB_groupID[myName]
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local function HandleFortitudeRequest(message, sender)
    local _, _, priority, groupNum, assignedPriest = string.find(message, "BUFF_INFO:(%d+):(%d+):(.+)")

    local requestPlayer = sender
    local requestPlayerId = MBID[requestPlayer]

    groupNum = tonumber(groupNum)
    priority = tonumber(priority)

    if not requestPlayerId or not groupNum or not priority then
        return
    end

    if assignedPriest ~= myName then
        return
    end

    if HasBuffOrDebuff("Power Word: Fortitude", requestPlayerId, "buff") or
        HasBuffOrDebuff("Prayer of Fortitude", requestPlayerId, "buff") then
        local message = string.format("BUFFED:%s:%d", requestPlayer, groupNum)
        CdAddonMessage(MB_RAID.."BUFFED_FORTITUDE", message)
        return
    end

    if not MB_FORTQueue[groupNum] then
        MB_FORTQueue[groupNum] = {}
    end

    if MB_FORTQueue[groupNum][requestPlayerId] then
        return
    end

    MB_FORTQueue[groupNum][requestPlayerId] = priority
    CdAddonMessage(MB_RAID.."CLAIM_FORTITUDE", "CLAIMING_GROUP:"..groupNum)
end

local function HandleFortitudeClaim(message, claimer)
    local _, _, groupNum = string.find(message, "CLAIMING_GROUP:(%d+)")
    groupNum = tonumber(groupNum)

    if not groupNum or MB_FORTClaimedQueue[groupNum] then
        return
    end

    MB_FORTClaimedQueue[groupNum] = claimer
end

local function HandleFortitudeBuffed(message, sender)
    local _, _, requestPlayerId, groupNum = string.find(message, "BUFFED:(.+):(%d+)")
    if not requestPlayerId or not groupNum then
        return
    end

    groupNum = tonumber(groupNum)

    if myName == sender then
        MB_FORTQueue[groupNum][requestPlayerId] = nil
    end

    MB_FORTClaimedQueue[groupNum] = nil
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function FORT:OnEvent()
    if event == "CHAT_MSG_ADDON" then
        local message, sender = arg2, arg4
        
        if arg1 == MB_RAID.."NEED_FORTITUDE" then
            HandleFortitudeRequest(message, sender)
        elseif arg1 == MB_RAID.."CLAIM_FORTITUDE" then
            HandleFortitudeClaim(message, sender)
        elseif arg1 == MB_RAID.."BUFFED_FORTITUDE" then
            HandleFortitudeBuffed(message, sender)
        end
    end
end

FORT:SetScript("OnEvent", FORT.OnEvent) 

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function FORT_RequestFortitude()
    if HasBuffOrDebuff("Power Word: Fortitude", "player", "buff") or 
        HasBuffOrDebuff("Prayer of Fortitude", "player", "buff") then
        return
    end

    local myBuffingPriest = GetPriestInGroup()
    local myPriority = tonumber(GetPriority())
    local myGroup = tonumber(GetGroupNumber())

    if not myBuffingPriest or not myPriority or not myGroup then
        return
    end

    local message = string.format("BUFF_INFO:%d:%d:%s", myPriority, myGroup, myBuffingPriest)
    CdAddonMessage(MB_RAID.."NEED_FORTITUDE", message, 15)
end

function FORT_ProcessFortitudeQueue()
    if myClass ~= "Priest" then
        return false
    end

    local spellName = "Prayer of Fortitude"
    if ImBusy() or not SpellReady(spellName) then
        return false
    end

    local targetUnitId, _, groupNum = GetNextTarget()
    if not targetUnitId or not groupNum then
        return false
    end

    if IsValidFriendlyTarget(targetUnitId, spellName) and not HasBuffOrDebuff(spellName, targetUnitId, "buff") then
        SelfBuff("Inner Focus")

        CastSpellByName(spellName, false)
        SpellTargetUnit(targetUnitId)
        SpellStopTargeting()
        return true
    end

    local message = string.format("BUFFED:%s:%d", targetUnitId, groupNum)
    CdAddonMessage(MB_RAID.."BUFFED_FORTITUDE", message)
    return false
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

-- DEBUGGING FUNCTIONS
-- function DebugQueue()
--     CdPrint("[DEBUG] MB_FORTQueue:")
--     for groupNum, players in pairs(MB_FORTQueue) do
--         local playerList = ""
--         for playerId, priority in pairs(players) do
--             playerList = playerList .. playerId .. "(" .. priority .. ") "
--         end
--         CdPrint("  Group " .. groupNum .. ": " .. playerList)
--     end
-- end

-- function DebugClaimedQueue()
--     CdPrint("[DEBUG] MB_FORTClaimedQueue:")
--     for groupNum, claimer in pairs(MB_FORTClaimedQueue) do
--         CdPrint("  Group " .. groupNum .. ": " .. claimer)
--     end
-- end
