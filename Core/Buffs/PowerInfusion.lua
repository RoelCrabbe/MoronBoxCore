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

-- POWER INFUSION BUFF SYSTEM - COMPLETE FLOW
-- ===========================================
-- 
-- 0. DISCOVERY PHASE (Only if MB_PIList empty)
--    ┌─────────────────────────────────────────────────┐
--    │ No known PI priests available:                  │
--    │ ├─ Check: MB_PIList empty?                      │
--    │ ├─ Broadcast: "NO_PRIEST_POWERINFUSION"         │
--    │ └─ Wait: PI priests will respond                │
--    └─────────────────────────────────────────────────┘
--                             ↓
--    ┌─────────────────────────────────────────────────┐
--    │ PI Priests respond to discovery:                │
--    │ ├─ Validate: KnowSpell("Power Infusion")?       │
--    │ ├─ Validate: myClass == "Priest"?               │
--    │ └─ Broadcast: "PRIEST_INFO:MyName"              │
--    └─────────────────────────────────────────────────┘
--                             ↓
--    ┌─────────────────────────────────────────────────┐
--    │ All players receive priest info:                │
--    │ └─ Add: TableAddUnique(MB_PIList, priestName)   │
--    └─────────────────────────────────────────────────┘
--                             ↓
-- 1. REQUEST PHASE
--    ┌─────────────────────────────────────────────────┐
--    │ Player needs Power Infusion:                    │
--    │ ├─ Check: Already have buff? → EXIT             │
--    │ ├─ Calculate: Self-priority via boss/global     │
--    │ │   ├─ Boss Override? Use MB_PIRegistry[boss]() │
--    │ │   └─ Global Priority:                         │
--    │ │       ├─ In MB_magePowerInfusionList?         │
--    │ │       │   ├─ Mage: 10 (HIGH)                  │
--    │ │       │   ├─ Warlock: 20 (MEDIUM)             │
--    │ │       │   └─ Other: 30 (LOW)                  │
--    │ │       ├─ Not in list, Mage: 20 (MEDIUM)       │
--    │ │       ├─ Not in list, Warlock: 40 (NONE)      │
--    │ │       └─ Other classes: nil → No request      │
--    │ ├─ Find: Random Priest from MB_PIList           │
--    │ ├─ Validate: Priority exists? → Else EXIT       │
--    │ ├─ Validate: Not self-buffing? → Else EXIT      │
--    │ └─ Send: "NEED_POWERINFUSION:Priority:Priest"   │
--    └─────────────────────────────────────────────────┘
--                             ↓
-- 2. CLAIM PHASE
--    ┌─────────────────────────────────────────────────┐
--    │ Assigned Priest receives request:               │
--    │ ├─ Validate: Am I the assigned priest?          │
--    │ ├─ Validate: Can resolve MBID[requestPlayer]?   │
--    │ ├─ Check: Target already has buff? → CLEANUP    │
--    │ ├─ Check: Already in my queue? → EXIT           │
--    │ ├─ Check: Someone else claimed? → EXIT          │
--    │ ├─ CLAIM: Broadcast "CLAIMING_POWERINFUSION"    │
--    │ └─ Queue: MB_PIQueue[unitId] = priority         │
--    └─────────────────────────────────────────────────┘
--                             ↓
-- 3. PROCESSING PHASE
--    ┌─────────────────────────────────────────────────┐
--    │ Priest processes queue:                         │
--    │ ├─ Validate: KnowSpell("Power Infusion")?       │
--    │ ├─ Scan: Find lowest priority number (highest)  │
--    │ ├─ Validate: Target in range and valid?         │
--    │ ├─ Check: Not busy casting?                     │
--    │ ├─ Check: Spell ready (not on cooldown)?        │
--    │ ├─ Cast: Power Infusion on target               │
--    │ └─ Message: "Power Infusion on [Target]!"       │
--    └─────────────────────────────────────────────────┘
--                             ↓
-- 4. RELEASE PHASE
--    ┌─────────────────────────────────────────────────┐
--    │ Cleanup after cast or invalid target:           │
--    │ ├─ Broadcast: "BUFFED_POWERINFUSION:Player"     │
--    │ ├─ All Priests receive:                         │
--    │ │   ├─ If sender == me: Remove from MB_PIQueue  │
--    │ │   └─ Remove from MB_PIClaimedQueue            │
--    │ └─ Ready for next request                       │
--    └─────────────────────────────────────────────────┘
--
-- KEY DATA STRUCTURES
-- ===================
-- MB_PIList = {
--     "PriestName1",         -- Available PI priests (SHARED via discovery)
--     "PriestName2"          -- Populated on-demand, persists per session
-- }
--
-- MB_PIQueue = {
--     ["party1"] = 10,       -- unitId → priority (LOCAL to each priest)
--     ["raid15"] = 20        -- Uses MBID system for targeting
-- }
--
-- MB_PIClaimedQueue = {
--     ["PlayerName"] = "ClaimingPriest"  -- Who claimed who (SHARED)
-- }
--
-- MB_PIRegistry = {
--     ["Onyxia"] = function() return 10 end  -- Boss-specific overrides
-- }
--
-- MB_magePowerInfusionList = {
--     "MageName1",           -- Priority mages/warlocks (manual config)
--     "MageName2"
-- }
--
-- PRIORITY SYSTEM
-- ===============
-- Lower number = Higher priority (processed first)
--
-- 10 (HIGH)   - Mages/Warlocks in MB_magePowerInfusionList (Mage class)
-- 20 (MEDIUM) - Mages/Warlocks in list (Warlock) OR Mages not in list
-- 30 (LOW)    - Other classes in MB_magePowerInfusionList
-- 40 (NONE)   - Warlocks not in list (rarely used)
-- nil         - All other classes (no request sent)
--
-- Boss overrides can return any priority via PI_RegisterPowerInfusionPriority()
--
-- COLLISION PREVENTION
-- ====================
-- Dynamic priest discovery → Self-healing if no priests known
-- Random priest assignment → Distributes load across PI priests
-- Claim system → Prevents duplicate processing
-- Self-exclusion → Priests don't buff themselves
-- Priority queue → Important targets processed first
-- Nil priority → Non-caster classes automatically excluded
--
-- PERFORMANCE OPTIMIZATIONS
-- =========================
-- Lazy discovery → Only broadcasts when MB_PIList empty
-- Hash table queue → O(1) lookup/insert/delete operations
-- Single regex parse → Fast message parsing with string.find
-- Sender from arg4 → No message spoofing possible
-- MBID system → Accurate unit targeting per client
-- Priority scan → Always finds best target efficiently
-- TableAddUnique → Prevents duplicate priests in list
--
-- DISCOVERY FLOW (Self-Healing)
-- =============================
-- Initial state: MB_PIList = {} (empty)
-- ├─ Player requests PI → No priests known
-- ├─ Broadcasts "NO_PRIEST_POWERINFUSION"
-- ├─ All PI priests respond with "PRIEST_INFO:Name"
-- ├─ Everyone builds their local MB_PIList
-- └─ Future requests use populated list (no re-discovery)

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local CdAddonMessage = mb_cdAddonMessage
local CdMessage = mb_cdMessage
local CdPrint = mb_cdPrint
local HasBuffOrDebuff = mb_hasBuffOrDebuff
local ImBusy = mb_imBusy
local IsValidFriendlyTarget = mb_isValidFriendlyTarget
local KnowSpell = mb_knowSpell
local SpellReady = mb_spellReady

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local PI = CreateFrame("Button", "PI", UIParent)

do
	for _, event in {
		"CHAT_MSG_ADDON",
        "CHAT_MSG_COMBAT_HOSTILE_DEATH",
        "ZONE_CHANGED_NEW_AREA",
        "PLAYER_ENTERING_WORLD",
        "PLAYER_REGEN_ENABLED"
		} do PI:RegisterEvent(event)
	end
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local MB_PIList = {}
local MB_PIQueue = {}
local MB_PIClaimedQueue = {}
local MB_PIRegistry = {}

local function GlobalPowerInfusionPriority()
    local PRIORITY = {
        HIGH   = 10,
        MEDIUM = 20,
        LOW    = 30,
        NONE   = 40
    }

    if FindInTable(MB_raidAssist.Mage.PowerInfusionPriority, myName) then
        if myClass == "Mage" then
            return PRIORITY.HIGH
        else
            return PRIORITY.LOW
        end
    elseif myClass == "Mage" then
        return PRIORITY.MEDIUM
    elseif myClass == "Warlock" then
        return PRIORITY.NONE
    end
end

local function GetMyPowerInfusionPriority()
    local targetName = nil
    local focId = MBID[MB_raidLeader]

    if focId then
        targetName = UnitName(focId.."target")
    end
    
    if targetName and MB_PIRegistry[targetName] then
        return MB_PIRegistry[targetName]()
    end
    
    return GlobalPowerInfusionPriority()
end

local function GetNextPowerInfusionTarget()
    local bestUnitId = nil
    local bestPriority = nil
    
    for unitId, priority in pairs(MB_PIQueue) do
        if bestPriority == nil or priority < bestPriority then
            bestPriority = priority
            bestUnitId = unitId
        end
    end
    
    return bestUnitId, bestPriority
end

local function GetPriestInGroup()
    if TableLength(MB_PIList) > 0 then
        return MB_PIList[math.random(TableLength(MB_PIList))]
    end

    local message = "ANY_PRIEST_POWERINFUSION"
    CdAddonMessage(MB_RAID.."NO_PRIEST_POWERINFUSION", message, 15)
    return nil
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local function HandlePowerInfusionRequest(message, sender)
    local _, _, priority, assignedPriest = string.find(message, "BUFF_INFO:(%d+):(.+)")
    
    local requestPlayer = sender
    local requestPlayerId = MBID[requestPlayer]

    if not requestPlayerId then
        return
    end

    if assignedPriest ~= myName then
        return
    end

    if HasBuffOrDebuff("Power Infusion", requestPlayerId, "buff") then
        CdAddonMessage(MB_RAID.."BUFFED_POWERINFUSION", "BUFFED:"..requestPlayer)
        return
    end

    if MB_PIQueue[requestPlayerId] then
        return
    end

    if MB_PIClaimedQueue[requestPlayer] and MB_PIClaimedQueue[requestPlayer] ~= myName then
        return
    end

    MB_PIQueue[requestPlayerId] = tonumber(priority)
    CdAddonMessage(MB_RAID.."CLAIM_POWERINFUSION", "CLAIMING:"..requestPlayer)
end

local function HandlePowerInfusionClaim(message, claimer)
    local _, _, requestPlayer = string.find(message, "CLAIMING:(.+)")
    if not requestPlayer then return end

    MB_PIClaimedQueue[requestPlayer] = claimer
end

local function HandlePowerInfusionBuffed(message, sender)
    local _, _, requestPlayer = string.find(message, "BUFFED:(.+)")
    if not requestPlayer then return end

    if myName == sender then
        MB_PIQueue[MBID[requestPlayer]] = nil
    end

    MB_PIClaimedQueue[requestPlayer] = nil
end

local function HandlePowerInfusionPostPriest(message, claimer)
    if not KnowSpell("Power Infusion") or myClass ~= "Priest" then
        return false
    end

    local message = "PRIEST_INFO:"..myName
    CdAddonMessage(MB_RAID.."PRIEST_POWERINFUSION", message, 15)
end

local function HandlePowerInfusionGetPriest(message, claimer)
    local _, _, requestPlayer = string.find(message, "PRIEST_INFO:(.+)")
    if not requestPlayer then return end

    TableAddUnique(MB_PIList, requestPlayer)
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function PI:OnEvent()
	if (event == "CHAT_MSG_ADDON") then
        local message, sender = arg2, arg4

        if (arg1 == MB_RAID.."NEED_POWERINFUSION") then
            HandlePowerInfusionRequest(message, sender)
        elseif (arg1 == MB_RAID.."CLAIM_POWERINFUSION") then
            HandlePowerInfusionClaim(message, sender)
        elseif (arg1 == MB_RAID.."BUFFED_POWERINFUSION") then
            HandlePowerInfusionBuffed(message, sender)
        end

        if (arg1 == MB_RAID.."NO_PRIEST_POWERINFUSION") then
            HandlePowerInfusionPostPriest(message, sender)
        elseif (arg1 == MB_RAID.."PRIEST_POWERINFUSION") then
            HandlePowerInfusionGetPriest(message, sender)
        end
    end
end

PI:SetScript("OnEvent", PI.OnEvent) 

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function PI_RegisterPowerInfusionPriority(fightName, fn)
    MB_PIRegistry[fightName] = fn
end

function PI_RequestPowerInfusion()
    if HasBuffOrDebuff("Power Infusion", "player", "buff") then
        return false
    end

    local myBuffingPriest = GetPriestInGroup()
    local myPriority = GetMyPowerInfusionPriority()

    if myName == myBuffingPriest then
        return
    end

    if not myBuffingPriest or not myPriority then
        return
    end

    local message = "BUFF_INFO:"..myPriority..":"..myBuffingPriest
    CdAddonMessage(MB_RAID.."NEED_POWERINFUSION", message, 15)
end

function PI_ProcessPowerInfusionQueue()
    if not KnowSpell("Power Infusion") or myClass ~= "Priest" then
        return false
    end

    local spellName = "Power Infusion"
    local targetUnitId, priority = GetNextPowerInfusionTarget()

    if not targetUnitId or not priority then
        return false
    end

    local targetName = UnitName(targetUnitId)

    if ImBusy() or not SpellReady(spellName) then
        return false
    end

    if HasBuffOrDebuff("Arcane Power", targetUnitId, "buff") then
        return false
    end

    if IsValidFriendlyTarget(targetUnitId, spellName) and not HasBuffOrDebuff(spellName, targetUnitId, "buff") then
        CastSpellByName(spellName, false)
        CdMessage(spellName.." on "..GetColors(targetName).."!")

        SpellTargetUnit(targetUnitId)
        SpellStopTargeting()
        return true
    end

    local message = "BUFFED:"..targetName
    CdAddonMessage(MB_RAID.."BUFFED_POWERINFUSION", message)
    return false
end
