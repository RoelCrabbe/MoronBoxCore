--[####################################################################################################]--
--[########################################### LUCIFRON CODE ##########################################]--
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

local LUCI = CreateFrame("Button", "LUCI", UIParent)

do
	for _, event in {
		"CHAT_MSG_ADDON",
        "CHAT_MSG_COMBAT_HOSTILE_DEATH",
        "ZONE_CHANGED_NEW_AREA",
        "PLAYER_ENTERING_WORLD",
        "PLAYER_REGEN_ENABLED"
		} do LUCI:RegisterEvent(event)
	end
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

-- Strategy Configuration
local MB_myLucifronBoxStrategy = true 
local MB_myLucifronShadowPotStrategy = false

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local function UseShadowPotsOnLucifron()
    if not MB_myLucifronShadowPotStrategy then
        return
    end

    if ImBusy() or not InCombat("player") then
		return
	end

    TakePotionsWhenPossible("Greater Shadow Protection Potion")
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

local function PrepareMagmadarOnLucifron()
    FW_RequestFearward()
    FW_ProcessFearwardQueue()
end

FW_RegisterFearwardPriority("Lucifron", PriorityOnMagmadar)
FW_RegisterFearwardPriority("Flamewaker Protector", PriorityOnMagmadar)

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local LUCI_ACTIVE = false

function LUCI_IsAtLucifron()
	if LUCI_ACTIVE then
        UseShadowPotsOnLucifron()
        PrepareMagmadarOnLucifron()
        return true
    end

	local inF = false
    local tName = UnitName("target")

    if (TankTarget("Lucifron") or TankTarget("Flamewaker Protector")) then
        inF = true
    else
        if tName and (tName == "Lucifron" or tName == "Flamewaker Protector") then
            inF = true
        end
    end

    if inF then
        CdAddonMessage(MB_RAID.."LUCIFRON", "ENGAGE", 30)
        LUCI_ACTIVE = true
        return true
    end

	return LUCI_ACTIVE
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function LUCI:OnEvent()
	if (event == "CHAT_MSG_ADDON") then
		if (arg1 == MB_RAID.."LUCIFRON" and arg2 == "ENGAGE") then
            CdRaidWarning(">> Lucifron Engaged! <<")
            LUCI_ACTIVE = true
        end

	elseif (event == "CHAT_MSG_COMBAT_HOSTILE_DEATH") then
        if string.find(arg1, "Lucifron dies") then
            CdRaidWarning(">> Lucifron Died! <<")
            LUCI_ACTIVE = false
        end

    elseif (event == "ZONE_CHANGED_NEW_AREA" or event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_REGEN_ENABLED") then
        LUCI_ACTIVE = false
    end
end

LUCI:SetScript("OnEvent", LUCI.OnEvent) 

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function LUCI_TargetingPostFocus()
	if LUCI_IsAtLucifron() and MB_myLucifronBoxStrategy then
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
