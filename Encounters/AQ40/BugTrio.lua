--[####################################################################################################]--
--[########################################## BUG TRIO CODE ###########################################]--
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

local AssistFocus = mb_assistFocus
local AssistSpecificTargetFromPlayer = mb_assistSpecificTargetFromPlayer
local CdAddonMessage = mb_cdAddonMessage
local CdMessage = mb_cdMessage
local CdPrint = mb_cdPrint
local CdRaidWarning = mb_cdRaidWarning
local Dead = mb_dead
local GetTargetNotOnTank = mb_getTargetNotOnTank
local HasBuffOrDebuff = mb_hasBuffOrDebuff
local HaveInBags = mb_haveInBags
local HealthPct = mb_healthPct
local ImBusy = mb_imBusy
local ImFocus = mb_imFocus
local ImHealer = mb_imHealer
local ImMeleeDPS = mb_imMeleeDPS
local ImRangedDPS = mb_imRangedDPS
local ImTank = mb_imTank
local InCombat = mb_inCombat
local InMeleeRange = mb_inMeleeRange
local IsAlive = mb_isAlive
local IsDruidShapeShifted = mb_isDruidShapeShifted
local IsItemInBagCoolDown = mb_isItemInBagCoolDown
local In28yardRange = mb_in28yardRange
local LockOnTarget = mb_lockOnTarget
local MyNameInTable = mb_myNameInTable
local MyClassAlphabeticalOrder = mb_myClassAlphabeticalOrder
local ReturnPlayerInRaidFromTable = mb_returnPlayerInRaidFromTable
local SpellReady = mb_spellReady
local TakePotionsWhenPossible = mb_takePotionsWhenPossible
local TankTarget = mb_tankTarget
local TankTargetHealth = mb_tankTargetHealth
local TargetFromSpecificPlayer = mb_targetFromSpecificPlayer
local UnitInRange = mb_unitInRange
local UseFromBags = mb_useFromBags

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local BUGTRIO = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0")

function BUGTRIO:OnInitialize()
    self:RegisterEvent("CHAT_MSG_ADDON")
    self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

-- Strategy Configuration
local MB_myBugTrioBoxStrategy = true
local MB_myBugTrioNaturePotStrategy = true

-- Strategy Configuration -- No changes below this line
local BugTrioEncounter = {
    Active = false
}

function BUGTRIO:OnEnable()
    BugTrioEncounter.Active = true
end

function BUGTRIO:OnReset()
    BugTrioEncounter.Active = false
end

function BUGTRIO:OnCleanUp()
    self:OnReset()
    self:UnregisterAllEvents()
    CdPrint(">> BUGTRIO - CLEANUP <<")
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local function UseNaturePotsOnBugTrio()
    if not MB_myBugTrioNaturePotStrategy then
        return
    end

    TakePotionsWhenPossible("Greater Nature Protection Potion")
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local function PriorityOnBugTrio()
    local PRIORITY = {
        HIGH   = 10,
        MEDIUM = 20,
        LOW    = 30,
        NONE   = 40
    }

    if FindInTable(MB_raidTanks, myName) then
        if myClass == "Druid" then
            return PRIORITY.HIGH
        end

        return PRIORITY.MEDIUM
    elseif myClass == "Priest" then
        return PRIORITY.LOW
    end
end

local function PrepareOnBugTrio()
    FW_RequestFearWard()
    FW_ProcessFearWardQueue()
end

FW_RegisterFearWardPriority("Lord Kri", PriorityOnBugTrio)
FW_RegisterFearWardPriority("Princess Yauj", PriorityOnBugTrio)
FW_RegisterFearWardPriority("Vem", PriorityOnBugTrio)

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local function BUGTRIO_CheckEncounter()
    if BugTrioEncounter.Active then
        UseNaturePotsOnBugTrio()
        PrepareOnBugTrio()
        return true
    end

    local inF = false
    local tName = UnitName("target")

    if (TankTarget("Lord Kri") or TankTarget("Princess Yauj") or TankTarget("Vem")) then
        inF = true
    else
        if tName and (tName == "Lord Kri" or tName == "Princess Yauj" or tName == "Vem") then
            inF = true
        end
    end

    if inF then
        CdAddonMessage(MB_RAID .. "BUGTRIO", "ENGAGE", 30)
        BugTrioEncounter.Active = true
        return true
    end

    return false
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function BUGTRIO:CHAT_MSG_ADDON()
    if arg1 == MB_RAID .. "BUGTRIO" then
        if arg2 == "ENGAGE" then
            CdRaidWarning(">> Fighting Bug Trio! <<")
            self:OnEnable()
        elseif arg2 == "DISENGAGE" then
            CdRaidWarning(">> Bug Trio has died! <<")
            self:ScheduleEvent("BUGTRIO_CLEANUP", self.OnCleanUp, 15, self)
        end
    end
end

function BUGTRIO:CHAT_MSG_COMBAT_HOSTILE_DEATH()
    if string.find(arg1, "Vem dies") and BugTrioEncounter.Active then
        CdAddonMessage(MB_RAID .. "BUGTRIO", "DISENGAGE", 30)
    end
end

function BUGTRIO:ZONE_CHANGED_NEW_AREA()
    self:OnReset()
end

function BUGTRIO:PLAYER_ENTERING_WORLD()
    self:OnReset()
end

function BUGTRIO:PLAYER_REGEN_ENABLED()
    self:OnReset()
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function BUGTRIO_TargetingPreFocus()
    local tName = UnitName("target")

    if BUGTRIO_CheckEncounter() and MB_myBugTrioBoxStrategy then
        -- This is pretty much only for my main tank to request his FW
        -- Might need to find a proper way
    end

    return false
end

local function TankSurvive()
    if HealthPct("player") <= 0.25 then
        SelfBuff("Last Stand")
    end

    if HealthPct("player") <= 0.2 then
        SelfBuff("Shield Wall")
    end
end

function BUGTRIO_TargetingPostFocus()
    local tName = UnitName("target")

    if BUGTRIO_CheckEncounter() and MB_myBugTrioBoxStrategy then
        if ImTank() then
            TankSurvive()

            if not MB_targetNearestDistanceChanged then
                SetCVar("targetNearestDistance", "15")
                MB_targetNearestDistanceChanged = true
            end

            if tName == nil or Dead("target") or not InMeleeRange() then
                TargetNearestEnemy()
            end
            return true
        elseif ImRangedDPS() or ImMeleeDPS() or ImHealer() then
            AssistFocus()
            return true
        end
    end

    return false
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

BUGTRIO:OnInitialize()
