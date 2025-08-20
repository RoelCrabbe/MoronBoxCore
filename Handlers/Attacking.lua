--[####################################################################################################]--
--[####################################### Auto Attacking Utils #######################################]--
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

local function FindActionSlot(spellName)
    for i = 1, 132 do
        MMBTooltip:SetOwner(UIParent, "ANCHOR_NONE")
        MMBTooltip:SetAction(i)
        if MMBTooltipTextLeft1:GetText() == spellName then
            return i
        end
    end
    return nil
end

function mb_autoAttack()
    local atkSlot = tonumber(MB_attackSlot)
    if atkSlot and not IsCurrentAction(atkSlot) then
        CastSpellByName("Attack")
    end
end

function mb_autoRangedAttack()
    local atkSlot = tonumber(MB_attackRangedSlot)
    if atkSlot and not IsAutoRepeatAction(atkSlot) then
        CastSpellByName("Auto Shot")
    end
end

function mb_autoWandAttack()
    local wndSlot = tonumber(MB_attackWandSlot)
    if wndSlot and not IsAutoRepeatAction(wndSlot) then
        CastSpellByName("Shoot")
    end
end

function mb_healerWand()
	if mb_imBusy() or not mb_inCombat("player") then
		return
	end

	mb_assistFocus()
	mb_autoWandAttack()
end

function mb_setAttackButton()
    MB_attackSlot = FindActionSlot("Attack")
    if not MB_attackSlot then
        mb_cdMessage("No Auto-Attack on my bars.")
    end

    if myClass == "Mage" or myClass == "Warlock" or myClass == "Priest" then
        MB_attackWandSlot = FindActionSlot("Shoot")

        if not MB_attackWandSlot then
            mb_cdMessage("No Shoot on my bars.")
        end
    elseif myClass == "Hunter" then
        MB_attackRangedSlot = FindActionSlot("Auto Shot")

        if not MB_attackRangedSlot then
            mb_cdMessage("No Ranged Auto-Attack on my bars.")
        end
    end
end