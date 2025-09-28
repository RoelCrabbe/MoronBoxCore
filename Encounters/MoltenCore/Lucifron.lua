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
local MB_myLucifronKillAddsStrategy = false 

-- Alliance Preparations
local MB_myLucifronFearwardPreparation = true

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

local LUCI_ACTIVE = false

function LUCI_IsAtLucifron()
	if LUCI_ACTIVE then
        UseShadowPotsOnLucifron()
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
    if not MB_myLucifronKillAddsStrategy then
        return false
    end

	if LUCI_IsAtLucifron() and MB_myLucifronBoxStrategy then
        if ImTank() then				
            if not MB_targetNearestDistanceChanged then						
				SetCVar("targetNearestDistance", "10")
				MB_targetNearestDistanceChanged = true
			end

			GetTargetNotOnTank()
			return true

		elseif ImRangedDPS() or ImMeleeDPS() or ImHealer() then
            if LockOnTarget("Flamewaker Protector") then
                return true
            end

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

-- ZUL'GURUB 3 LOOT SUMMARY
-- ----------------------

-- Bat:
--   - Shoulders

-- Snake:
--   - Hit Cloak
--   - Attack Cloak

-- Raptor:
--   - Defender
--   - Bow

-- Thekal:
--   - Claws
--   - Offhand

-- Spider:
--   - Band of Jin

-- Jin'do:
--   - Hexxer Mace
--   - Bloodsoaked Gloves

-- Hakkar:
--   - Peacekeeper
--   - Wand

-- General/Other:
--   - Priest Token Bracers x2
--   - Druid Tabard Token
--   - Heal Mace
--   - DPS Gloves x2
--   - Priest Chest Token
--   - Priest Belt Token


-- ZUL'GURUB 4 LOOT SUMMARY
-- ----------------------

-- Bat:
--   - Healing Helm
--   - Shield

-- Snake:
--   - Rogue Chest Token

-- Raptor:
--   - Defender
--   - Caster Legs
--   - Warrior Armsplint

-- Spider:
--   - DPS Gloves

-- Tiger:
--   - Priest Bracer Token
--   - Gurubashi AP Ring

-- Panther:
--   - Will of Arlok
--   - Caster Cloak
--   - Priest Bracer Token

-- Jin'do:
--   - Warrior Chest Token
--   - Caster Staff
--   - Mail Legs

-- Hakkar:
--   - Gun
--   - Warblade


-- ZUL'GURUB 5 LOOT SUMMARY
-- ----------------------

-- Bat:
--   - Random Caster Ring

-- Snake:
--   - Random Healing Helm
--   - Caster Dagger
--   - Priest Waist Token

-- Raptor:
--   - Mage Bracer Token
--   - Defender Ring
--   - Caster Ring

-- Spider:
--   - Warrior Chest Token

-- Tiger:
--   - Fist Weapon
--   - DPS Gloves

-- Panther:
--   - Mage Bracers
--   - Tank Ring
--   - Mail Gloves

-- Jin'do:
--   - Warrior Chest Token
--   - Leather Boots
--   - Leather Legs

-- Hakkar:
--   - 1H Axe
--   - Dagger


-- AQ20 2 LOOT SUMMARY
-- -----------------

-- Kurinaxx:
--   - Warrior Ring Token

-- Rajaxx:
--   - 2H Sword
--   - Warlock Ring Token

-- Moam:
--   - Dustwind Turban

-- Ossirian:
--   - Mail Bindings
--   - Mail Shoulders

-- Ayamiss:
--   - Stinger
--   - Warrior Ring Token

-- Buru:
--   - Leather Bracers

-- AQ20 LOOT SUMMARY
-- -----------------

-- Kurinaxx:
--   - Dagger

-- Rajaxx:
--   - Warrior Cloak Token
--   - Vanguard Boots

-- Moam:
--   - Dustwind Turban
--   - Warrior Ring Token

-- Ossirian:
--   - Caster Legs
--   - Plate Shoulders

-- Ayamiss:
--   - Stinger
--   - Warrior Cloak Token

-- Buru:
--   - Slime Kickers
--   - Warrior Cloak Token


-- Panther, dps gloves, will of arlokk
-- Tiger, fist wep
-- Raptor, off hand wep, leahter legs, warrior bracer token,
-- Spider, band of jin
-- Snake, mail chest, random caster ring
-- Bat, random healing mace


-- Kuri, defence belt
-- Rajexx, 2H sword, warlock ring
-- Moam, Ring of Fury, offhand
-- Buru, leahter bracers
-- Ayamiss, stinger, warrior ring