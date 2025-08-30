--[####################################################################################################]--
--[######################################## Addon Messages ! ##########################################]--
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

function mb_setFocus()
	if IsShiftKeyDown() then 
		local targetLeader = UnitName("target")
		MB_raidLeader = targetLeader
		SendAddonMessage(MB_RAID.."_FTAR", MB_raidLeader.." "..myName, "RAID")
	else
		MB_raidLeader = myName
		if UnitInRaid("player") then
			SendAddonMessage(MB_RAID, "MB_FOCUSME", "RAID")
		else
			SendAddonMessage(MB_RAID, "MB_FOCUSME")
		end
	end
end

function mb_clearRaidTarget()
	if not mb_imFocus() then
		return
	end
	
	local id = GetRaidTargetIndex("target")
	if UnitInRaid("player") then
		SendAddonMessage(MB_RAID.."CLR_TARG", UnitName("player"), "RAID")
	else
		SendAddonMessage(MB_RAID.."CLR_TARG", UnitName("player"))
	end

	SetRaidTarget("target", 0)
end

function mb_cooldowns()
	if not MB_raidLeader and (TableLength(MBID) > 1) then 
        mb_cdPrint("WARNING: You have not chosen a raid leader")
    end

	if mb_dead("player") then
		return
	end

	if Instance.ZG() then
		if mb_mandokirGaze() then
			return
		end
	end

	if not mb_imFocus() then
		return
	end

	if UnitInRaid("player") then
		if mb_inCombat("player") then			
			if not MB_useCooldowns.Active then
				mb_cdPrint("Sending out request to use Cooldowns.")
			else
				mb_cdPrint("Stop Cooldown Requesting, still "..math.round(MB_useCooldowns.Time - GetTime()).."s remaining")
			end
		end

		SendAddonMessage(MB_RAID, "MB_USECOOLDOWNS", "RAID")
	else
		SendAddonMessage(MB_RAID, "MB_USECOOLDOWNS")
	end
end

function mb_useManualRecklessness()
	if not MB_raidLeader and (TableLength(MBID) > 1) then 
        mb_cdPrint("WARNING: You have not chosen a raid leader")
    end

	if mb_dead("player") then
		return
	end

	if Instance.ZG() then
		if mb_mandokirGaze() then
			return
		end
	end

	if mb_mobsNoTotems() then
		return
	end

	if not mb_imFocus() then
		return
	end

	if UnitInRaid("player") then		
		if mb_inCombat("player") then			
			if not MB_useBigCooldowns.Active then
				mb_cdPrint("Sending out request to use Recklessness.")
			else
				mb_cdPrint("Stop Recklessness Requesting, still "..math.round(MB_useBigCooldowns.Time - GetTime()).."s remaining")
			end
		end

		SendAddonMessage(MB_RAID, "MB_USERECKLESSNESS", "RAID")
	else
		SendAddonMessage(MB_RAID, "MB_USERECKLESSNESS")
	end
end

function mb_reportCooldowns()
	if not MB_raidLeader and (TableLength(MBID) > 1) then 
        mb_cdPrint("WARNING: You have not chosen a raid leader")
    end

	if mb_dead("player") then
		return
	end

	if Instance.ZG() then
		if mb_mandokirGaze() then
			return
		end
	end

	if not mb_imFocus() or mb_inCombat("player") then
		return
	end

	if UnitInRaid("player") then		
		SendAddonMessage(MB_RAID, "MB_REPORTCOOLDOWNS", "RAID")
		Print("Sending out request to report Cooldowns.")
	else
		SendAddonMessage(MB_RAID, "MB_REPORTCOOLDOWNS")
	end
end