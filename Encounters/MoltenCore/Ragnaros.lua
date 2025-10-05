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

local RAG = CreateFrame("Button", "RAG", UIParent)

do
	for _, event in {
		"CHAT_MSG_ADDON",
        "CHAT_MSG_COMBAT_HOSTILE_DEATH",
        "CHAT_MSG_MONSTER_YELL",
        "ZONE_CHANGED_NEW_AREA",
        "PLAYER_ENTERING_WORLD",
        "PLAYER_REGEN_ENABLED"
		} do RAG:RegisterEvent(event)
	end
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

-- Strategy Configuration
local MB_myRagnarosBoxStrategy = true
local MB_myRagnarosFirePotStrategy = true

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local function UseFirePotsOnRagnaros()
    if not MB_myRagnarosFirePotStrategy then
        return
    end

    if ImBusy() or not InCombat("player") then
		return
	end

    TakePotionsWhenPossible("Greater Fire Protection Potion")
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local RAG_ACTIVE = false

function RAG_IsAtRagnaros()
	if RAG_ACTIVE then
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
        RAG_ACTIVE = true
        return true
    end

	return RAG_ACTIVE
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function RAG:OnEvent()
	if (event == "CHAT_MSG_ADDON") then
		if (arg1 == MB_RAID.."RAGNAROS") then
            if (arg2 == "ENGAGE") then
                CdRaidWarning(">> Ragnaros Engaged! <<")
                RAG_ACTIVE = true
            elseif (arg2 == "DISENGAGE") then
                CdRaidWarning(">> Ragnaros Died! <<")
                RAG_ACTIVE = false
            end
        end

	elseif (event == "CHAT_MSG_COMBAT_HOSTILE_DEATH") then
        if string.find(arg1, "Ragnaros dies") and RAG_ACTIVE then
            CdAddonMessage(MB_RAID.."RAGNAROS", "DISENGAGE", 30)
        end

    elseif (event == "ZONE_CHANGED_NEW_AREA" or event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_REGEN_ENABLED") then
        RAG_ACTIVE = false
    end
end

RAG:SetScript("OnEvent", RAG.OnEvent) 

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function RAG_TargetingPostFocus()
	if RAG_IsAtRagnaros() and MB_myRagnarosBoxStrategy then
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
