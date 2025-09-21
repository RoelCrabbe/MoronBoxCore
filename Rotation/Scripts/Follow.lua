--[####################################################################################################]--
--[######################################### START FOLLOW CODE! #######################################]--
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

local CasterFollow = mb_casterFollow
local FollowFocus = mb_followFocus
local HasBuffOrDebuff = mb_hasBuffOrDebuff
local HealerFollow = mb_healerFollow
local ImFocus = mb_imFocus
local ImHealer = mb_imHealer
local ImMeleeDPS = mb_imMeleeDPS
local ImRangedDPS = mb_imRangedDPS
local ImTank = mb_imTank
local IsAtRazorgore = mb_isAtRazorgore
local IsAtRazorgorePhase = mb_isAtRazorgorePhase
local IsAtTwinsEmps = mb_isAtTwinsEmps
local MeleeFollow = mb_meleeFollow
local MyNameInTable = mb_myNameInTable
local ReturnPlayerInRaidFromTable = mb_returnPlayerInRaidFromTable
local TankFollow = mb_tankFollow
local TankTarget = mb_tankTarget

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local function SpecialFollowing()
    if Instance.AQ40() and HasBuffOrDebuff("Plague", "player", "debuff") and TankTarget("Anubisath Defender") then
        return true
	elseif Instance.MC() and TankTarget("Baron Geddon") and MyNameInTable(MB_raidAssist.GTFO.Baron) then
		return true
	elseif Instance.ONY() and TankTarget("Onyxia") and myName == MB_myOnyxiaMainTank then
		return true
	end

    return false
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local function FollowRaidLeader()
	if MB_raidLeader then
		FollowByName(MB_raidLeader, 1)
		SetView(5)
	end
end

function mb_followFocus()
    if SpecialFollowing() then
        return
    end

	if myClass == "Warlock" and HasBuffOrDebuff("Hellfire", "player", "buff") then
		CastSpellByName("Life Tap(Rank 1)")
	end

	if ImFocus() then
		return
	end

	if Instance.NAXX() and THAD_IsFollowThaddius() then
	else
		FollowRaidLeader()
	end
end

function mb_casterFollow()
    if SpecialFollowing() then
        return
    end

	if myClass == "Warlock" and HasBuffOrDebuff("Hellfire", "player", "buff") then
		CastSpellByName("Life Tap(Rank 1)")
	end

	if ImFocus() then
		return
	end

	if not ImRangedDPS() then
		return
	end

	FollowRaidLeader()
end

function mb_meleeFollow()
    if SpecialFollowing() then
        return
    end

	if ImFocus() then
		return
	end

	if Instance.AQ40() then	
		if SKERAM_IsFollowSkeram() then
			return
		end

	elseif Instance.BWL() and IsAtRazorgore() and IsAtRazorgorePhase() and MB_myRazorgoreBoxStrategy then
		if myName == ReturnPlayerInRaidFromTable(MB_myRazorgoreLeftTank) then
			return
		end

		if myName == ReturnPlayerInRaidFromTable(MB_myRazorgoreRightTank) then
			return
		end
			
		if MyNameInTable(MB_myRazorgoreLeftDPSERS) then
			FollowByName(ReturnPlayerInRaidFromTable(MB_myRazorgoreLeftTank), 1)
			return
		end

		if MyNameInTable(MB_myRazorgoreRightDPSERS) then
			FollowByName(ReturnPlayerInRaidFromTable(MB_myRazorgoreRightTank), 1)
			return
		end
    else
        if ImMeleeDPS() then		
            FollowRaidLeader()
        end

        if ImTank() and not MB_myOTTarget
            and not (TankTarget("Instructor Razuvious") or TankTarget("Razorgore the Untamed") 
            or TankTarget("Chromaggus") or IsAtTwinsEmps()) then
            FollowRaidLeader()
        end
    end
end

function mb_tankFollow()
    if SpecialFollowing() then
        return
    end

	if ImFocus() then
		return
	end

	if ImTank() then		
		FollowRaidLeader()
	end
end

function mb_healerFollow()
    if SpecialFollowing() then
        return
    end

	if ImFocus() then
		return
	end

	if not ImHealer() then
		return
	end

	if Instance.NAXX() and THAD_IsAtThaddiusP1() then 
		THAD_IsFollowThaddiusHealers()
	else
		FollowRaidLeader()
	end
end
