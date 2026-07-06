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
--    │ └─ Queue: Add to MB_FWQueue[unitId]=prio  │
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
-- MB_FWQueue = {
--     ["party1"] = 1,    -- unitId → priority (LOCAL to each priest)
--     ["raid5"] = 2      -- Uses MBID system for targeting
-- }
--
-- MB_FWClaimedQueue = {
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
local CdMessage = mb_cdMessage
local CdPrint = mb_cdPrint
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
    } do
        FW:RegisterEvent(event)
    end
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local MB_FWQueue = {}
local MB_FWClaimedQueue = {}
local MB_FWRegistry = {}

local function GlobalFearWardPriority()
    local PRIORITY = {
        HIGH   = 10,
        MEDIUM = 20,
        LOW    = 30,
        NONE   = 40
    }

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

local function GetMyFearWardPriority()
    local targetName = nil
    local focId = MBID[MB_raidLeader]

    if focId then
        targetName = UnitName(focId .. "target")
    end

    if targetName and MB_FWRegistry[targetName] then
        return MB_FWRegistry[targetName]()
    end

    return GlobalFearWardPriority()
end

local function GetNextFearWardTarget()
    local bestUnitId = nil
    local bestPriority = nil

    for unitId, priority in pairs(MB_FWQueue) do
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
                local unitId = "raid" .. i
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
            local pName = UnitName("party" .. i)
            local pClass = UnitClass("party" .. i)
            local pRace = UnitRace("party" .. i)

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

local function HandleFearWardRequest(message, sender)
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
        CdAddonMessage(MB_RAID .. "BUFFED_FEARWARD", "BUFFED:" .. requestPlayer)
        return
    end

    if MB_FWQueue[requestPlayerId] then
        return
    end

    if MB_FWClaimedQueue[requestPlayer] and MB_FWClaimedQueue[requestPlayer] ~= myName then
        return
    end

    MB_FWQueue[requestPlayerId] = tonumber(priority)
    CdAddonMessage(MB_RAID .. "CLAIM_FEARWARD", "CLAIMING:" .. requestPlayer)
end

local function HandleFearWardClaim(message, claimer)
    local _, _, requestPlayer = string.find(message, "CLAIMING:(.+)")
    if not requestPlayer then return end

    MB_FWClaimedQueue[requestPlayer] = claimer
end

local function HandleFearWardBuffed(message, sender)
    local _, _, requestPlayer = string.find(message, "BUFFED:(.+)")
    if not requestPlayer then return end

    if myName == sender then
        MB_FWQueue[MBID[requestPlayer]] = nil
    end

    MB_FWClaimedQueue[requestPlayer] = nil
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function FW:OnEvent()
    if (event == "CHAT_MSG_ADDON") then
        local message, sender = arg2, arg4

        if (arg1 == MB_RAID .. "NEED_FEARWARD") then
            HandleFearWardRequest(message, sender)
        elseif (arg1 == MB_RAID .. "CLAIM_FEARWARD") then
            HandleFearWardClaim(message, sender)
        elseif (arg1 == MB_RAID .. "BUFFED_FEARWARD") then
            HandleFearWardBuffed(message, sender)
        end
    end
end

FW:SetScript("OnEvent", FW.OnEvent)

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function FW_RegisterFearWardPriority(fightName, fn)
    MB_FWRegistry[fightName] = fn
end

function FW_RequestFearWard()
    if Faction.IsHorde() or HasBuffOrDebuff("Fear Ward", "player", "buff") then
        return false
    end

    local myBuffingPriest = GetDwarfPriestInGroup()
    local myPriority = GetMyFearWardPriority()

    if myName == myBuffingPriest then
        return
    end

    if not myBuffingPriest or not myPriority then
        return
    end

    local message = "BUFF_INFO:" .. myPriority .. ":" .. myBuffingPriest
    CdAddonMessage(MB_RAID .. "NEED_FEARWARD", message, 15)
end

function FW_ProcessFearWardQueue()
    if Faction.IsHorde() or myClass ~= "Priest" then
        return false
    end

    local spellName = "Fear Ward"
    local targetUnitId, priority = GetNextFearWardTarget()

    if not targetUnitId or not priority then
        return false
    end

    local targetName = UnitName(targetUnitId)

    if ImBusy() or not SpellReady(spellName) then
        return false
    end

    if IsValidFriendlyTarget(targetUnitId, spellName) and not HasBuffOrDebuff(spellName, targetUnitId, "buff") then
        if UnitIsFriend("player", targetUnitId) then
            ClearTarget()
        end

        CastSpellByName(spellName, false)
        CdMessage(spellName .. " on " .. GetColors(targetName) .. "!")

        SpellTargetUnit(targetUnitId)
        SpellStopTargeting()
        return true
    end

    local message = "BUFFED:" .. targetName
    CdAddonMessage(MB_RAID .. "BUFFED_FEARWARD", message)
    return false
end
