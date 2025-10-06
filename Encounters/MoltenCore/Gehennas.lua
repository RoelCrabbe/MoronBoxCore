--[####################################################################################################]--
--[########################################### GEHENNAS CODE ##########################################]--
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

local GEHENNAS = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0")

function GEHENNAS:OnInitialize()
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
local MB_myGehennasBoxStrategy = true
local MB_myGehennasFirePotStrategy = true
local MB_myGehennasFAPPotStrategy = true

-- Strategy Configuration -- No changes below this line
local GehennasEncounter = {
    Active = false
}

function GEHENNAS:OnEnable()
    GehennasEncounter.Active = true
end

function GEHENNAS:OnReset()
    GehennasEncounter.Active = false
end

function GEHENNAS:OnCleanUp()
    self:OnReset()
    self:UnregisterAllEvents()
    CdPrint(">> GEHENNAS - CLEANUP <<")
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local function UseFirePotsOnGehennas()
    if not MB_myGehennasFirePotStrategy then
        return
    end

    if ImMeleeDPS() or ImTank() then
        return
    end

    TakePotionsWhenPossible("Greater Fire Protection Potion")
end

local function UseFAPPotsOnGehennas()
    if not MB_myGehennasFAPPotStrategy then
        return
    end

    if ImRangedDPS() or ImHealer() then
        return
    end

    TakePotionsWhenPossible("Free Action Potion")
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local function GEHENNAS_CheckEncounter()
	if GehennasEncounter.Active then
        UseFirePotsOnGehennas()
        UseFAPPotsOnGehennas()
        return true
    end

	local inF = false
    local tName = UnitName("target")

    if (TankTarget("Gehennas") or TankTarget("Flamewaker")) then
        inF = true
    else
        if tName and (tName == "Gehennas" or tName == "Flamewaker") then
            inF = true
        end
    end

    if inF then
        CdAddonMessage(MB_RAID.."GEHENNAS", "ENGAGE", 30)
        GehennasEncounter.Active = true
        return true
    end

	return false
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function GEHENNAS:CHAT_MSG_ADDON()
    if arg1 == MB_RAID.."GEHENNAS" then
        if arg2 == "ENGAGE" then
            CdRaidWarning(">> Fighting Gehennas! <<")
            self:OnEnable()
        elseif arg2 == "DISENGAGE" then
            CdRaidWarning(">> Gehennas has died! <<")
            self:ScheduleEvent("GEHENNAS_CLEANUP", self.OnCleanUp, 15, self)
        end
    end
end

function GEHENNAS:CHAT_MSG_COMBAT_HOSTILE_DEATH()
    if string.find(arg1, "Gehennas dies") and GehennasEncounter.Active then
        CdAddonMessage(MB_RAID.."GEHENNAS", "DISENGAGE", 30)
    end
end

function GEHENNAS:ZONE_CHANGED_NEW_AREA()
    self:OnReset()
end

function GEHENNAS:PLAYER_ENTERING_WORLD()
    self:OnReset()
end

function GEHENNAS:PLAYER_REGEN_ENABLED()
    self:OnReset()
    self:CancelScheduledEvent("GEHENNAS_CLEANUP")
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function GEHENNAS_TargetingPostFocus()
	if GEHENNAS_CheckEncounter() and MB_myGehennasBoxStrategy then
        if ImTank() then			
            if not MB_targetNearestDistanceChanged then						
				SetCVar("targetNearestDistance", "10")
				MB_targetNearestDistanceChanged = true
			end

			GetTargetNotOnTank()
			return true

		elseif ImRangedDPS() or ImMeleeDPS() or ImHealer() then
			if not tName or Dead("target") then
				AssistFocus()
			end
			return true
		end
    end

    return false
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

GEHENNAS:OnInitialize()
