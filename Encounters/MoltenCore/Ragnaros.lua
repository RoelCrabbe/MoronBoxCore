--[####################################################################################################]--
--[########################################### RAGNAROS CODE ##########################################]--
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

local RAGNAROS = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0")

function RAGNAROS:OnInitialize()
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
local MB_myRagnarosBoxStrategy = true
local MB_myRagnarosFirePotStrategy = true

-- Strategy Configuration -- No changes below this line
local RagnarosEncounter = {
    Active = false
}

function RAGNAROS:OnEnable()
    RagnarosEncounter.Active = true
end

function RAGNAROS:OnReset()
    RagnarosEncounter.Active = false
end

function RAGNAROS:OnCleanUp()
    self:OnReset()
    self:UnregisterAllEvents()
    CdPrint(">> RAGNAROS - CLEANUP <<")
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local function UseFirePotsOnRagnaros()
    if not MB_myRagnarosFirePotStrategy then
        return
    end

    TakePotionsWhenPossible("Greater Fire Protection Potion")
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local function RAGNAROS_CheckEncounter()
	if RagnarosEncounter.Active then
        UseFirePotsOnRagnaros()
        return true
    end

	local inF = false
    local tName = UnitName("target")

    if TankTarget("Ragnaros") then
        inF = true
    else
        if tName and tName == "Ragnaros" then
            inF = true
        end
    end

    if inF then
        CdAddonMessage(MB_RAID.."RAGNAROS", "ENGAGE", 30)
        RagnarosEncounter.Active = true
        return true
    end

	return false
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function RAGNAROS:CHAT_MSG_ADDON()
    if arg1 == MB_RAID.."RAGNAROS" then
        if arg2 == "ENGAGE" then
            CdRaidWarning(">> Fighting Ragnaros! <<")
            self:OnEnable()
        elseif arg2 == "DISENGAGE" then
            CdRaidWarning(">> Ragnaros has died! <<")
            self:ScheduleEvent("RAGNAROS_CLEANUP", self.OnCleanUp, 15, self)
        end
    end
end

function RAGNAROS:CHAT_MSG_COMBAT_HOSTILE_DEATH()
    if string.find(arg1, "Ragnaros dies") and RagnarosEncounter.Active then
        CdAddonMessage(MB_RAID.."RAGNAROS", "DISENGAGE", 30)
    end
end

function RAGNAROS:ZONE_CHANGED_NEW_AREA()
    self:OnReset()
end

function RAGNAROS:PLAYER_ENTERING_WORLD()
    self:OnReset()
end

function RAGNAROS:PLAYER_REGEN_ENABLED()
    self:OnReset()
    self:CancelScheduledEvent("RAGNAROS_CLEANUP")
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function RAGNAROS_TargetingPostFocus()
	if RAGNAROS_CheckEncounter() and MB_myRagnarosBoxStrategy then
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

RAGNAROS:OnInitialize()
