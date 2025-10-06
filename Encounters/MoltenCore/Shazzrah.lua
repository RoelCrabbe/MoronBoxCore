--[####################################################################################################]--
--[########################################### SHAZZRAH CODE ##########################################]--
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
local MyClassAlphabeticalOrder = mb_myClassAlphabeticalOrder
local TakePotionsWhenPossible = mb_takePotionsWhenPossible
local TankTarget = mb_tankTarget
local TankTargetHealth = mb_tankTargetHealth
local TargetFromSpecificPlayer = mb_targetFromSpecificPlayer
local UnitInRange = mb_unitInRange

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local SHAZZRAH = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0")

function SHAZZRAH:OnInitialize()
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
local MB_myShazzrahBoxStrategy = true
local MB_myShazzrahArcanePotStrategy = true

-- Strategy Configuration -- No changes below this line
local ShazzrahEncounter = {
    Active = false
}

function SHAZZRAH:OnEnable()
    ShazzrahEncounter.Active = true
end

function SHAZZRAH:OnReset()
    ShazzrahEncounter.Active = false
end

function SHAZZRAH:OnCleanUp()
    self:OnReset()
    self:UnregisterAllEvents()
    CdPrint(">> SHAZZRAH - CLEANUP <<")
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local function UseArcanePotsOnShazzrah()
    if not MB_myShazzrahArcanePotStrategy then
        return
    end

    TakePotionsWhenPossible("Greater Arcane Protection Potion")
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local function SHAZZRAH_CheckEncounter()
	if ShazzrahEncounter.Active then
        UseArcanePotsOnShazzrah()
        SHAZZRAH_DetectDebuff()
        SHAZZRAH_DispellDebuff()
        return true
    end

	local inF = false
    local tName = UnitName("target")

    if TankTarget("Shazzrah") then
        inF = true
    else
        if tName and tName == "Shazzrah" then
            inF = true
        end
    end

    if inF then
        CdAddonMessage(MB_RAID.."SHAZZRAH", "ENGAGE", 30)
        ShazzrahEncounter.Active = true
        return true
    end

	return false
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function SHAZZRAH_DetectDebuff()
    if myClass ~= "Mage" then
        return false
    end

    if MyClassAlphabeticalOrder() == 1 then
        return false
    end

    if UnitName("target") ~= "Shazzrah" then
        return false
    end

    if not HasBuffOrDebuff("Detect Magic", "target", "debuff") then		
        CastSpellByName("Detect Magic")
        return true
	end

    return false
end

function SHAZZRAH_DispellDebuff()
    if myClass ~= "Priest" then
        return false
    end

    if MyClassAlphabeticalOrder() == 1 then
        return false
    end

    local focId = MBID[MB_raidLeader]
    if not focId then
        return false
    end
    
    local targetId = focId.."target"
    if not targetId then
        return false
    end

    local targetName = UnitName(targetId)
    if not targetName then
        return false
    end

    if HasBuffOrDebuff("Deaden Magic", targetId, "buff") then
        TargetUnit(targetId)
        CastSpellByName("Dispel Magic")
        return true
    end

    return false
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function SHAZZRAH:CHAT_MSG_ADDON()
    if arg1 == MB_RAID.."SHAZZRAH" then
        if arg2 == "ENGAGE" then
            CdRaidWarning(">> Fighting Shazzrah! <<")
            self:OnEnable()
        elseif arg2 == "DISENGAGE" then
            CdRaidWarning(">> Shazzrah has died! <<")
            self:ScheduleEvent("SHAZZRAH_CLEANUP", self.OnCleanUp, 15, self)
        end
    end
end

function SHAZZRAH:CHAT_MSG_COMBAT_HOSTILE_DEATH()
    if string.find(arg1, "Shazzrah dies") and ShazzrahEncounter.Active then
        CdAddonMessage(MB_RAID.."SHAZZRAH", "DISENGAGE", 30)
    end
end

function SHAZZRAH:ZONE_CHANGED_NEW_AREA()
    self:OnReset()
end

function SHAZZRAH:PLAYER_ENTERING_WORLD()
    self:OnReset()
end

function SHAZZRAH:PLAYER_REGEN_ENABLED()
    self:OnReset()
    self:CancelScheduledEvent("SHAZZRAH_CLEANUP")
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function SHAZZRAH_TargetingPostFocus()
	if SHAZZRAH_CheckEncounter() and MB_myShazzrahBoxStrategy then
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

SHAZZRAH:OnInitialize()
