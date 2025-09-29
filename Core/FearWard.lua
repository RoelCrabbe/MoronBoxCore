--[####################################################################################################]--
--[###################################### FEARWARD BUFF SYSTEM ########################################]--
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

-- FEARWARD BUFF SYSTEM - COMPLETE FLOW
-- ====================================
-- 
-- 1. REQUEST PHASE
--    ┌─────────────────────────────────────────────────┐
--    │ Player needs Fear Ward:                         │
--    │ ├─ Check: Already have buff? → EXIT             │
--    │ ├─ Find: Random Dwarf Priest (exclude self)     │
--    │ ├─ Calculate: Self-priority (1=Rogue, 2=Tank,   │
--    │ │             3=Priest, 4=Others)               │
--    │ └─ Send: "NEED_FEARWARD:Priority:PriestName"    │
--    └─────────────────────────────────────────────────┘
--                             ↓
-- 2. CLAIM PHASE
--    ┌─────────────────────────────────────────────────┐
--    │ Assigned Priest receives request:               │
--    │ ├─ Validate: Am I the assigned priest?          │
--    │ ├─ Check: Target already has buff? → CLEANUP    │
--    │ ├─ Check: Someone else claimed target? → EXIT   │
--    │ ├─ CLAIM: Broadcast "CLAIMING_FEARWARD:Player"  │
--    │ └─ Queue: Add to MB_fearwardQueue[unitId]=prio  │
--    └─────────────────────────────────────────────────┘
--                             ↓
-- 3. PROCESSING PHASE
--    ┌─────────────────────────────────────────────────┐
--    │ Priest processes queue:                         │
--    │ ├─ Scan: Find lowest priority number (highest)  │
--    │ ├─ Validate: Target in range and valid?         │
--    │ ├─ Check: Not busy casting?                     │
--    │ ├─ Cast: Fear Ward on target                    │
--    │ └─ Cleanup: Broadcast "BUFFED_FEARWARD:Player"  │
--    └─────────────────────────────────────────────────┘
--                             ↓
-- 4. RELEASE PHASE
--    ┌─────────────────────────────────────────────────┐
--    │ All Priests receive buff completion:            │
--    │ ├─ Release: Remove from claimedTargets          │
--    │ └─ Clean: Remove from local queue               │
--    └─────────────────────────────────────────────────┘
--
-- KEY DATA STRUCTURES
-- ==================
-- MB_fearwardQueue = {
--     ["party1"] = 1,    -- unitId → priority (LOCAL to each priest)
--     ["raid5"] = 2      -- Uses MBID system for targeting
-- }
--
-- MB_fearwardClaimedQueue = {
--     ["PlayerName"] = "ClaimingPriest"  -- Who claimed who (SHARED via addon messages)
-- }
--
-- COLLISION PREVENTION
-- ===================
-- Random priest assignment → Distributes load across priests
-- Claim system → Prevents duplicate processing  
-- Self-exclusion → Priests don't buff themselves
-- Priority queue → Ensures important targets first (Rogue > Tank > Priest > Others)
-- Auto-cleanup → Removes invalid/buffed targets via events
--
-- PERFORMANCE OPTIMIZATIONS  
-- ========================
-- Hash table queue → O(1) lookup/insert/delete operations
-- Single regex parse → Fast message parsing with string.find
-- Sender from arg4 → No message spoofing possible
-- MBID system → Accurate unit targeting per client
-- Priority scan → Always finds best target efficiently
-- Event-driven cleanup → All state management in event handlers

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local CdAddonMessage = mb_cdAddonMessage
local HasBuffOrDebuff = mb_hasBuffOrDebuff
local ImBusy = mb_imBusy
local IsValidFriendlyTarget = mb_isValidFriendlyTarget
local SpellReady = mb_spellReady

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local FW = CreateFrame("Button", "FW", UIParent)

do
	for _, event in {
		"CHAT_MSG_ADDON",
        "CHAT_MSG_COMBAT_HOSTILE_DEATH",
        "ZONE_CHANGED_NEW_AREA",
        "PLAYER_ENTERING_WORLD",
        "PLAYER_REGEN_ENABLED"
		} do FW:RegisterEvent(event)
	end
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local MB_fearwardQueue = {} -- local priest only, unitId is the key because its not shared.
local MB_fearwardClaimedQueue = {} -- local list BUT its filled with addonMessage broadcast, unitId is not the key because its shared.
local MB_bossFearwardRegistry = {}

local PRIORITY = {
    HIGH   = 10,
    MEDIUM = 20,
    LOW    = 30,
    NONE   = 40,
}

local function GlobalFearwardPriority()
    if FindInTable(MB_raidTanks, myName) then
        return PRIORITY.MEDIUM
    elseif myClass == "Rogue" then
        return PRIORITY.HIGH
    elseif myClass == "Priest" then
        return PRIORITY.LOW
    else
        return PRIORITY.NONE
    end
end

local function GetMyFearwardPriority()
    local targetName = nil
    local focId = MBID[MB_raidLeader]

    if focId then
        targetName = UnitName(focId.."target")
    end
    
    if targetName and MB_bossFearwardRegistry[targetName] then
        return MB_bossFearwardRegistry[targetName]()
    end
    
    return GlobalFearwardPriority()
end

local function GetNextFearwardTarget()
    local bestUnitId = nil
    local bestPriority = nil
    
    for unitId, priority in pairs(MB_fearwardQueue) do
        if bestPriority == nil or priority < bestPriority then
            bestPriority = priority
            bestUnitId = unitId
        end
    end
    
    return bestUnitId, bestPriority
end

local function GetDwarfPriestInGroup()
    local dwarfPriests = {}

    if UnitInRaid("player") then
        for i = 1, GetNumRaidMembers() do
            local rName, _, _, _, rClass = GetRaidRosterInfo(i)
            if rClass == "Priest" then
                local unitId = "raid"..i
                if UnitRace(unitId) == "Dwarf" then
                    table.insert(dwarfPriests, rName)
                end
            end
        end
    else
        if myClass == "Priest" and myRace == "Dwarf" then
            table.insert(dwarfPriests, myName)
        end
           
        for i = 1, 4 do
            local pName = UnitName("party"..i)
            local pClass = UnitClass("party"..i)
            local pRace = UnitRace("party"..i)

            if pName and pClass == "Priest" and pRace == "Dwarf" then
                table.insert(dwarfPriests, pName)
            end
        end
    end
   
    if TableLength(dwarfPriests) == 0 then
        return nil
    else
        return dwarfPriests[math.random(TableLength(dwarfPriests))]
    end
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local function HandleFearwardRequest(message, sender)
    local _, _, priority, assignedPriest = string.find(message, "BUFF_INFO:(%d+):(.+)")
    
    local requestPlayer = sender
    local requestPlayerId = MBID[requestPlayer]

    if not requestPlayerId then
        return
    end

    if assignedPriest ~= myName then
        return
    end

    if HasBuffOrDebuff("Fear Ward", requestPlayerId, "buff") then
        CdAddonMessage(MB_RAID.."BUFFED_FEARWARD", "BUFFED:"..requestPlayer)
        return
    end

    if MB_fearwardQueue[requestPlayerId] then
        return
    end

    if MB_fearwardClaimedQueue[requestPlayer] and MB_fearwardClaimedQueue[requestPlayer] ~= myName then
        return
    end

    MB_fearwardQueue[requestPlayerId] = tonumber(priority)
    CdAddonMessage(MB_RAID.."CLAIM_FEARWARD", "CLAIMING:"..requestPlayer)
end

local function HandleFearwardClaim(message, claimer)
    local _, _, requestPlayer = string.find(message, "CLAIMING:(.+)")
    MB_fearwardClaimedQueue[requestPlayer] = claimer
end

local function HandleFearwardBuffed(message, sender)
    local _, _, requestPlayer = string.find(message, "BUFFED:(.+)")
    MB_fearwardClaimedQueue[requestPlayer] = nil
    MB_fearwardQueue[MBID[requestPlayer]] = nil
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function FW:OnEvent()
	if (event == "CHAT_MSG_ADDON") then
        local message, sender = arg2, arg4

        if (arg1 == MB_RAID.."NEED_FEARWARD") then
            HandleFearwardRequest(message, sender)
        elseif (arg1 == MB_RAID.."CLAIM_FEARWARD") then
            HandleFearwardClaim(message, sender)
        elseif (arg1 == MB_RAID.."BUFFED_FEARWARD") then
            HandleFearwardBuffed(message, sender)
        end
    end
end

FW:SetScript("OnEvent", FW.OnEvent) 

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function FW_RegisterFearwardPriority(fightName, fn)
    MB_bossFearwardRegistry[fightName] = fn
end

function FW_RequestFearward()
    if HasBuffOrDebuff("Fear Ward", "player", "buff") then
        return false
    end

    local myBuffingPriest = GetDwarfPriestInGroup()
    if not myBuffingPriest or myName == myBuffingPriest then
        return
    end

    local myPriority = GetMyFearwardPriority()
    local message = "BUFF_INFO:"..myPriority..":"..myBuffingPriest

    CdAddonMessage(MB_RAID.."NEED_FEARWARD", message, 15)
end

function FW_ProcessFearwardQueue()
    if myClass ~= "Priest" then
        return false
    end

    local targetUnitId, priority = GetNextFearwardTarget()
    
    if not targetUnitId or not priority then
        return false
    end

    local spellName = "Fear Ward"    
    local tName = UnitName(targetUnitId)

    if not tName then
        return false
    end

    if ImBusy() or not SpellReady(spellName) then
        return false
    end

    local spell = "Fear Ward"
    if IsValidFriendlyTarget(targetUnitId, spellName) and not HasBuffOrDebuff(spellName, targetUnitId, "buff") then
        CastSpellByName(spellName, false)
        SpellTargetUnit(targetUnitId)
        SpellStopTargeting()
        return true
    end

    CdAddonMessage(MB_RAID.."BUFFED_FEARWARD", "BUFFED:"..tName)
    return false
end

-- function FW_DebugQueues()
--     Print("=== FEARWARD QUEUES ===")
--     Print("My Queue:")
--     for unitId, priority in pairs(MB_fearwardQueue) do
--         local name = UnitName(unitId) or "Unknown"
--         Print("  "..name.." ("..unitId..") = priority "..priority)
--     end
    
--     Print("Claimed Queue:")
--     for playerName, claimer in pairs(MB_fearwardClaimedQueue) do
--         Print("  "..playerName.." claimed by "..claimer)
--     end
-- end

-- function FW_ClearQueues()
--     MB_fearwardQueue = {}
--     MB_fearwardClaimedQueue = {}
--     Print("Queues cleared")
-- end
