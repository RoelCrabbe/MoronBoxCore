--[####################################################################################################]--
--[################################### Global Values for Rotation #####################################]--
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

MMB = CreateFrame("Button", "MMB", UIParent)
MMBTooltip = CreateFrame("GAMETOOLTIP", "MMBTooltip", UIParent, "GameTooltipTemplate")

MBx = CreateFrame("Frame")
MBx.ACE = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0")
MBx.ACE.ItemBonus = AceLibrary("ItemBonusLib-1.0")
MBx.ACE.Banzai = AceLibrary("Banzai-1.0")
MBx.ACE.HealComm = AceLibrary("HealComm-1.0")

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

MB_mySpeccList = {}
MB_mySingleList = {}
MB_myMultiList = {}
MB_myAOEList = {}
MB_mySetupList = {}
MB_myPreCastList = {}
MB_myLoathebList = {}

Instance = {
    Naxx  = (GetRealZoneText() == "Naxxramas"),
    AQ40  = (GetRealZoneText() == "Ahn'Qiraj"),
    AQ20  = (GetRealZoneText() == "Ruins of Ahn'Qiraj"),
    MC    = (GetRealZoneText() == "Molten Core"),
    BWL   = (GetRealZoneText() == "Blackwing Lair"),
    ONY   = (GetRealZoneText() == "Onyxia's Lair"),
    ZG    = (GetRealZoneText() == "Zul'Gurub");
    IsWorldBoss = function()
        return UnitClassification("target") == "worldboss"
    end
}

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

MBID = {}
MB_toonsInGroup = {}
MB_offTanks = {}
MB_raidTanks = {}
MB_noneDruidTanks = {}
MB_groupID = {}
MB_classList = { 
    Warrior = {},
    Mage = {},
    Shaman = {},
    Paladin = {},
    Priest = {},
    Rogue = {},
    Druid = {},
    Hunter = {},
    Warlock = {}
}

for i = 1, 8 do
    MB_toonsInGroup[i] = {}
end

MB_raidLeader = nil
MB_mySpecc = nil
MB_myHealSpell = nil
MB_attackSlot = nil
MB_attackRangedSlot = nil
MB_attackWandSlot = nil

MB_warriorBinds = "Fury"
MB_evoGear = nil

MB_cooldowns = {}

MB_druidTankInParty = nil
MB_warriorTankInParty = nil

MB_myCCTarget = nil
MB_myInterruptTarget = nil
MB_doInterrupt = { Active = false, Time = 0 }
MB_myOTTarget = nil

MB_myAssignedHealTarget = nil

MB_currentCC = { Mage = 1, Warlock = 1, Priest = 1, Druid = 1 }
MB_currentInterrupt  = { Rogue = 1, Mage = 1, Shaman = 1 }
MB_currentFear = { Warlock = 1 }
MB_currentRaidTarget = 1
MB_Ot_Index = 1

MB_myCCSpell = {
    Priest = "Shackle Undead", 
    Mage = "Polymorph", 
    Warlock = "Banish", 
    Druid = "Hibernate"
}

MB_myInterruptSpell = {
    Rogue = "Kick", 
    Shaman = "Earth Shock", 
    Mage = "Counterspell", 
    Warrior = "Pummel", 
    Priest = "Silence",
    Paladin = "Hammer of Justice"
}

MB_myFearSpell = {
    Warlock = "Fear"
}

MB_classSpellManaCost = {
    -- Fire Magus
    ["Fireball"] = 410,
    ["Pyroblast"] = 440,
    ["Scorch"] = 150,
    ["Blast Wave"] = 545,

    -- Frost Magus
    ["Frostbolt"] = 290,
    ["Frostbolt(Rank 1)"] = 25,
    ["Cone of Cold"] = 555,

    -- Arcane Magus
    ["Arcane Explosion"] = 390,
    ["Arcane Explosion(Rank 1)"] = 75,
    ["Arcane Missiles"] = 655,

    -- Warlock
    ["Searing Pain"] = 168,
    ["Shadow Bolt"] = 380,
    ["Soul Fire"] = 335,
    ["Immolate"] = 380,
    ["Corruption"] = 340,
    ["Drain Mana"] = 225,

    -- Priest
    ["Smite"] = 280,
    ["Mind Flay"] = 205,
    ["Mind Blast"] = 250,
    ["Mana Burn"] = 270,

    -- Druid
    ["Starfire"] = 309,
    ["Wrath"] = 163,

    -- Shaman
    ["Chain Lightning"] = 544,
    ["Lightning Bolt"] = 238
}

MB_raidTargetNames = {
    [8] = "Skull", 
    [7] = "Cross", 
    [6] = "Square", 
    [5] = "Moon", 
    [4] = "Triangle", 
    [3] = "Diamond", 
    [2] = "Circle", 
    [1] = "Star"
}

MB_isCasting = nil
MB_isChanneling = nil
MB_isCastingMyCCSpell = nil

MB_ignite = { Active = nil, Starter = nil, Amount = 0, Stacks = 0 }

MB_isMoving = { Active = false, Time = 0 }

MB_buffingCounterWarlock = 1
MB_buffingCounterDruid = 1
MB_buffingCounterMage = 1
MB_buffingCounterPriest = 1
MB_buffingCounterPaladin = 1

MB_DMFWeek = { Active = false, Time = 0 }
MB_MCEnter = { Active = false, Time = 0 }

MB_tradeOpen = nil
MB_tradeOpenOnUpdate = { Active = false, Time = 0 }

MB_razorgoreNewTargetBecauseTargetIsBehindOrOutOfRange = { Active = false, Time = 0 }
MB_razorgoreNewTargetBecauseTargetIsBehind = { Active = false, Time = 0 }
MB_lieutenantAndorovIsNotHealable = { Active = false, Time = 0 }
MB_targetWrongWayOrTooFar = { Active = false, Time = 0 }
MB_autoToggleSheeps = { Active = false, Time = 0 }
MB_autoBuff = { Active = false, Time = 0 }
MB_useCooldowns = { Active = false, Time = 0 }
MB_useBigCooldowns = { Active = false, Time = 0 }
MB_hunterFeign = { Active = false, Time = 0 }
MB_autoBuyReagents = { Active = false, Time = 0 }
