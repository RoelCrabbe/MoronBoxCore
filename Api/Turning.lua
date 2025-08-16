--[####################################################################################################]--
--[####################################### AUTO TURN TO TARGET ########################################]--
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

if not MB_raidAssist.AutoTurnToTarget then
	return
end

local SavedBinding = { Active = false, Time = 0, Binding2 = "SM_MACRO2", Binding3 = "SM_MACRO3" }

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local MAT = CreateFrame("Button", "XFTF", UIParent)

do
	for _, event in {
			"UI_ERROR_MESSAGE",
			"AUTOFOLLOW_END"
		} 
		do MAT:RegisterEvent(event)
	end
end

local function HandleFollow(delay)
	local now = GetTime()

	if not MB_raidLeader then
		return
	end

	if mb_iamFocus() then
		return
	end

	if mb_imRangedDPS() and mb_unitInRange(MBID[MB_raidLeader]) then
		FollowByName(MB_raidLeader, 1)
		SavedBinding.Time = now + delay
		SetBinding("2", "MOVEBACKWARD")
		SetBinding("3", "MOVEBACKWARD")
		SavedBinding.Active = true
	end
end

function MAT:OnEvent()
	local now = GetTime()

	if (event == "UI_ERROR_MESSAGE") then
		if (arg1 == "Target needs to be in front of you") then
			HandleFollow(1.5)
		elseif (arg1 == "Can't do that while moving" and mb_unitInRange(MBID[MB_raidLeader])) then
			if not SavedBinding.Active and (now > SavedBinding.Time) and (now < SavedBinding.Time + 0.5) then
				HandleFollow(0.75)
			end
		end
	elseif (event == "AUTOFOLLOW_END") then
		SavedBinding.Time = now + 0.25
		SavedBinding.Active = true
	end
end

function MAT:OnUpdate()
	local now = GetTime()

	if now > SavedBinding.Time then
		SetBinding("2", SavedBinding.Binding2)
		SetBinding("3", SavedBinding.Binding3)
		SavedBinding.Active = false
	end
end

MAT:SetScript("OnEvent", MAT.OnEvent)
MAT:SetScript("OnUpdate", MAT.OnUpdate)