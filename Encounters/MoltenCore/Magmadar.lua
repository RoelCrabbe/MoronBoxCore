--[####################################################################################################]--
--[########################################### MAGMADAR CODE ##########################################]--
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
local myClass = UnitClass("player") --[[@as string]]
local myName = UnitName("player") --[[@as string]]
local myRace = UnitRace("player") --[[@as string]]
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
local ImBusy = mb_imBusy
local ImHealer = mb_imHealer
local ImMeleeDPS = mb_imMeleeDPS
local ImRangedDPS = mb_imRangedDPS
local ImTank = mb_imTank
local InCombat = mb_inCombat
local IsAlive = mb_isAlive
local LockOnTarget = mb_lockOnTarget
local MyNameInTable = mb_myNameInTable
local TakePotionsWhenPossible = mb_takePotionsWhenPossible
local TankTarget = mb_tankTarget
local TankTargetHealth = mb_tankTargetHealth
local TargetFromSpecificPlayer = mb_targetFromSpecificPlayer
local UnitInRange = mb_unitInRange

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local MAGMADAR = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0")

function MAGMADAR:OnInitialize()
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
local MB_myMagmadarBoxStrategy = true
local MB_myMagmadarFirePotStrategy = true

-- Strategy Configuration -- No changes below this line
local MagmadarEncounter = {
    Active = false
}

function MAGMADAR:OnEnable()
    MagmadarEncounter.Active = true
end

function MAGMADAR:OnReset()
    MagmadarEncounter.Active = false
end

function MAGMADAR:OnCleanUp()
    self:OnReset()
    self:UnregisterAllEvents()
    CdPrint(">> MAGMADAR - CLEANUP <<")
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local function UseFirePotsOnMagmadar()
    if not MB_myMagmadarFirePotStrategy then
        return
    end

    TakePotionsWhenPossible("Greater Fire Protection Potion")
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local function PriorityOnMagmadar()
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
    elseif myClass == "Rogue" then
        return PRIORITY.LOW
    elseif myClass == "Priest" then
        return PRIORITY.NONE
    end
end

local function PrepareOnMagmadar()
    FW_RequestFearWard()
    FW_ProcessFearWardQueue()
end

FW_RegisterFearWardPriority("Magmadar", PriorityOnMagmadar)

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local function MAGMADAR_CheckEncounter()
    if MagmadarEncounter.Active then
        UseFirePotsOnMagmadar()
        PrepareOnMagmadar()
        return true
    end

    local inF = false
    local tName = UnitName("target")

    if TankTarget("Magmadar") then
        inF = true
    else
        if tName and tName == "Magmadar" then
            inF = true
        end
    end

    if inF then
        CdAddonMessage(MB_RAID .. "MAGMADAR", "ENGAGE", 30)
        MagmadarEncounter.Active = true
        return true
    end

    return false
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function MAGMADAR:CHAT_MSG_ADDON()
    if arg1 == MB_RAID .. "MAGMADAR" then
        if arg2 == "ENGAGE" then
            CdRaidWarning(">> Fighting Magmadar! <<")
            self:OnEnable()
        elseif arg2 == "DISENGAGE" then
            CdRaidWarning(">> Magmadar has died! <<")
            self:ScheduleEvent("MAGMADAR_CLEANUP", self.OnCleanUp, 15, self)
        end
    end
end

function MAGMADAR:CHAT_MSG_COMBAT_HOSTILE_DEATH()
    if string.find(arg1, "Magmadar dies") and MagmadarEncounter.Active then
        CdAddonMessage(MB_RAID .. "MAGMADAR", "DISENGAGE", 30)
    end
end

function MAGMADAR:ZONE_CHANGED_NEW_AREA()
    self:OnReset()
end

function MAGMADAR:PLAYER_ENTERING_WORLD()
    self:OnReset()
end

function MAGMADAR:PLAYER_REGEN_ENABLED()
    self:OnReset()
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function MAGMADAR_TargetingPostFocus()
    if MAGMADAR_CheckEncounter() and MB_myMagmadarBoxStrategy then
        if ImTank() then
            if not MB_targetNearestDistanceChanged then
                SetCVar("targetNearestDistance", "10")
                MB_targetNearestDistanceChanged = true
            end

            GetTargetNotOnTank()
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

MAGMADAR:OnInitialize()
