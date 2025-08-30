--[####################################################################################################]--
--[######################################## CREATE MACROS #############################################]--
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

function mb_createBinds()
	LoadBindings(1) -- Load binds.
	mb_unbindAllKeys() -- Unbind all keys.

	SetBinding("B", "OPENALLBAGS") -- Open all bags.
	SetBinding("SHIFT-R", "REPLY") -- Reply whisper.
	SetBinding("O", "TOGGLERAIDTAB") -- O, Opens Raidtab instead of friendlist.
	SetBinding("M", "TOGGLEWORLDMAP") -- Toggle minimap.

	-- Movement binds
	SetBinding("Z", "MOVEFORWARD") -- Forward.
	SetBinding("S", "MOVEBACKWARD") -- Backward.
	SetBinding("Q", "STRAFELEFT") -- Left.
	SetBinding("D", "STRAFERIGHT") -- Right.

	-- Extra's
	SetBinding("SHIFT-V", "NAMEPLATES") -- Show all Nameplates.
	SetBinding("MINUS", "SM_MACRO31") -- ReloadUI.

	-- Set Custom Macro Binds
	SetBinding("PAGEDOWN", "SM_MACRO1") -- Setup / Buffs.
	SetBinding("2", "SM_MACRO2") -- Single DPS.
	SetBinding("3", "SM_MACRO3") -- Multi DPS.
	SetBinding("L", "SM_MACRO4") -- Cooldowns.
	SetBinding("4", "SM_MACRO5") -- AOE.
	SetBinding("Y", "SM_MACRO6") -- Mount.
	SetBinding("F3", "SM_MACRO7") -- Request invites / Request summon / Promote.
	SetBinding("T", "SM_MACRO30") -- Precast.

	SetBinding("F2", "SM_MACRO8") -- CC on pull, AltKeyDown => PowerWord: Shield Tanks, ShiftKeyDown => Target Raidleader.
	SetBinding("F4", "SM_MACRO9") -- FocusME (Do not broadcast!), ShiftKeyDown => Focus Previous FocusME.
	SetBinding("F5", "SM_MACRO10") -- Assign Offtanks to target, ShiftKeyDown => Assign interrupt to target.
	SetBinding("F6", "SM_MACRO11") -- Assign CC to target, ShiftKeyDown => assign fear.
	SetBinding("F7", "SM_MACRO12") -- Clear assign to target.
	SetBinding("PAGEUP", "SM_MACRO13") -- Make water on mages.
	SetBinding("A", "SM_MACRO14") -- Drink and Trade for water.
	SetBinding("CTRL-A", "SM_MACRO14") -- Drink and Trade for water.
	SetBinding("F", "SM_MACRO15") -- Breakfear, ShiftKeyDown => Poison/Disease Cleanse Totem.
	SetBinding("SHIFT-X", "SM_MACRO16") -- Follow Focus.
	SetBinding("N", "SM_MACRO17") -- DropTotems.
	
	SetBinding("V", "SM_MACRO19") -- Tanks and Healers ONLY, no dps.
	SetBinding("9", "SM_MACRO20") -- Craftable Cooldowns.	
	SetBinding("SHIFT-T", "SM_MACRO21") -- Interrupt Focus target.

	SetBinding("SHIFT-G", "SM_MACRO22") -- Casters Follow.
	SetBinding("1", "SM_MACRO23") -- Melees Follow.
	SetBinding("SHIFT-H", "SM_MACRO24") -- Healers Follow.
	SetBinding("SHIFT-C", "SM_MACRO25") -- Tank Follow.

	SetBinding("6", "SM_MACRO26") -- Manual Recklessness.
	SetBinding("0", "SM_MACRO27") -- Reports Cooldowns of Certain spells.
	SetBinding("K", "SM_MACRO28") -- Tank Shoot.

	if myClass == "Druid" or myClass == "Shaman" or myClass == "Priest" or myClass == "Paladin" then
		SetBinding("J", "SM_MACRO18") -- Ress with MoronHeal. (Add delay in HKN).
	end

	if myClass == "Warrior" or MB_mySpecc == "Feral" then
		SetBinding("R", "SM_MACRO29") -- Warrior / Feral Taunt.
	end

	SaveBindings(1)
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--
