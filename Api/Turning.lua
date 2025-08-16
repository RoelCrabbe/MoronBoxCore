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

local MB_savedBinding = { Active = false, Time = 0, Binding2 = "SM_MACRO2", Binding3 = "SM_MACRO3" }

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local MAT = CreateFrame("Button", "XFTF", UIParent)

for _, event in ipairs({"UI_ERROR_MESSAGE", "AUTOFOLLOW_END"}) do
    MAT:RegisterEvent(event)
end

local function HandleFollow(delay)
	if not mb_iamFocus() and mb_imRangedDPS() and mb_unitInRange(MBID[MB_raidLeader]) then
		FollowByName(MB_raidLeader, 1)
		local now = GetTime()
		MB_savedBinding.Time = now + delay
		SetBinding("2", "MOVEBACKWARD")
		SetBinding("3", "MOVEBACKWARD")
		MB_savedBinding.Active = true
	end
end

function MAT:OnEvent(event, arg1)
	if not MB_raidAssist.AutoTurnToTarget then return end

	if event == "UI_ERROR_MESSAGE" then
		if arg1 == "Target needs to be in front of you" then
			HandleFollow(1.5)
		elseif arg1 == "Can't do that while moving" then
			local now = GetTime()
			if not MB_savedBinding.Active and (now > MB_savedBinding.Time) and (now < MB_savedBinding.Time + 0.5) and mb_unitInRange(MBID[MB_raidLeader]) then
				HandleFollow(0.75)
			end
		end
	elseif event == "AUTOFOLLOW_END" then
		MB_savedBinding.Time = GetTime() + 0.15
		MB_savedBinding.Active = true
	end
end

function MAT:OnUpdate()
	if not MB_savedBinding.Active then return end

	if GetTime() > MB_savedBinding.Time then
		SetBinding("2", MB_savedBinding.Binding2)
		SetBinding("3", MB_savedBinding.Binding3)
		MB_savedBinding.Active = false
	end
end

MAT:SetScript("OnEvent", MAT.OnEvent)
MAT:SetScript("OnUpdate", MAT.OnUpdate)