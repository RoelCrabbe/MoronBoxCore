-- [[ Boss Tables ]] --

--[[
    This file contains all data tables and lookup functions for the addon.

    Structure:
    - Shared locals (API functions)
    - Data tables organized by category
    - Accessor functions for each table
    - Complex logic functions
--]]

MoronBox.Config.Tables = MoronBox.Config.Tables or {}

local myClass = UnitClass("player")

function getTables()
    return MoronBox.Config.Tables
end

-- [[ Boss Mechanics ]] --

-- Recklessness Usage Thresholds
local RecklessnessTargetsSet      = {
    ["Patchwerk"] = 0.19,
    ["Maexxna"] = 0.19,
    ["Loatheb"] = 0.19,
    ["Noth the Plaguebringer"] = 0.19,
    ["Ragnaros"] = 0.19,
    ["Chromaggus"] = 0.19,
    ["Nefarian"] = 0.19,
    ["Fankriss the Unyielding"] = 0.19,
    ["Princess Yauj"] = 0.30,
    ["Heigan the Unclean"] = 0.25,
    ["Vaelastrasz the Corrupt"] = 0.11,
    ["Grand Widow Faerlina"] = 0.19
}

-- Bandage Usage by Class
local BandageBossesForWarlock     = {
    ["Patchwerk"] = true,
    ["Lady Blaumeux"] = true,
    ["Sir Zeliek"] = true,
    ["Thane Korth\'azz"] = true,
    ["Highlord Alexandros Mograine"] = true
}

local BandageBossesForMage        = {
    ["Lady Blaumeux"] = true,
    ["Sir Zeliek"] = true,
    ["Thane Korth\'azz"] = true,
    ["Highlord Alexandros Mograine"] = true
}

-- Healing Interrupt Immunity
local BossToNeverInterruptHealSet = {
    ["Vaelastrasz the Corrupt"] = true,
    ["Maexxna"] = true,
    ["Ossirian the Unscarred"] = true
}

-- Tranquilizing Shot Targets
local UseTranquilizingShotSet     = {
    ["Gluth"] = true,
    ["Princess Huhuran"] = true,
    ["Flamegor"] = true,
    ["Chromaggus"] = true,
    ["Magmadar"] = true
}

-- [[ Combat ]] --

-- Debuff Restrictions
local MobsNoCursesSet             = {
    ["Blackwing Mage"] = true,
    ["Blackwing Legionnaire"] = true,
    ["Corrupted Green Whelp"] = true,
    ["Corrupted Red Whelp"] = true,
    ["Corrupted Bronze Whelp"] = true,
    ["Corrupted Blue Whelp"] = true,
    ["Mutated Grub"] = true,
    ["Frenzied Bat"] = true,
    ["Plagued Bat"] = true
}

local MobsNoSundersSet            = {
    ["Blackwing Mage"] = true,
    ["Blackwing Legionnaire"] = true,
    ["Death Talon Dragonspawn"] = true,
    ["Deathknight Understudy"] = true,
    ["Corrupted Green Whelp"] = true,
    ["Corrupted Red Whelp"] = true,
    ["Corrupted Bronze Whelp"] = true,
    ["Corrupted Blue Whelp"] = true,
    ["Mutated Grub"] = true,
    ["Frenzied Bat"] = true,
    ["Plague Beast"] = true,
    ["Plagued Bat"] = true
}

-- Blood Fury Blacklist
local UseBloodFuryBlacklistSet    = {
    ["Shade of Naxxramas"] = true,
    ["Necro Knight"] = true,
    ["Stoneskin Gargoyle"] = true,
    ["Shazzrah"] = true,
    ["Grand Widow Faerlina"] = true,
    ["Magmadar"] = true,
    ["Corrupted Green Whelp"] = true,
    ["Corrupted Red Whelp"] = true,
    ["Corrupted Bronze Whelp"] = true,
    ["Corrupted Blue Whelp"] = true,
    ["Death Talon Hatcher"] = true,
    ["Princess Huhuran"] = true,
    ["Blackwing Taskmaster"] = true
}

-- Excluded Whirlwind Targets
local ExcludedTargetsSet          = {
    ["Emperor Vek'lor"] = true,
    ["Emperor Vek'nilash"] = true,
    ["The Prophet Skeram"] = true
}

-- [[ Protective Magic ]] --

-- Ward Requirements
local MobsToFireWardSet           = {
    ["High Priestess Jeklik"] = true,
    ["Necro Night"] = true,
    ["Grand Widow Faerlina"] = true,
    ["Gehennas"] = true,
    ["Magmadar"] = true,
    ["Ragnaros"] = true,
    ["Firemaw"] = true,
    ["Blackwing Warlock"] = true,
    ["Blackwing Technician"] = true,
    ["Vaelastrasz the Corrupt"] = true,
    ["Flame Imp"] = true
}

local MobsToShadowWardSet         = {
    ["Death Lord"] = true,
    ["Necropolis Acolyte"] = true,
    ["Deathknight Cavalier"] = true,
    ["Shade of Naxxramas"] = true,
    ["Spirit of Naxxramas"] = true,
    ["Lord Kazzak"] = true,
    ["Hakkar"] = true,
    ["Necro Knight"] = true
}

local ShadowWardDebuffsSet        = {
    "Corruption",
    "Curse of Agony",
    "Siphon Life",
    "Impending Doom",
    "Inevitable Doom",
    "Aura of Agony",
    "Shadow Word: Pain",
    "Corruption of the Earth"
}

-- Magic Detection/Manipulation
local MobsToDetectMagicSet        = {
    ["Anubisath Sentinel"] = true,
    ["Anubisath Guardian"] = true,
    ["Anubisath Defender"] = true,
    ["Shazzrah"] = true
}

local MobsToDampenMagicSet        = {
    ["Grethok the Controller"] = true,
}

local MobsToAmplifyMagicSet       = {
    ["Patchwerk"] = true,
    ["Noth the Plaguebringer"] = true,
    ["Maexxna"] = true
}

-- [[ Boss Triggers ]] --

-- Auto-Turn Requirements (fear immunity)
local MobsToAutoTurnSet           = {
    ["Magmadar"] = true,
    ["Ancient Core Hound"] = true,
    ["Onyxia"] = true,
    ["Deathknight"] = true,
    ["Gurubashi Berserker"] = true
}

-- Auto-Break Fear Requirements
local MobsToAutoBreakFearSet      = {
    ["Deathknight"] = true,
    ["Princess Yauj"] = true
}

-- [[ Totems ]] --

-- Totem Restrictions
local MobsNoTotemsSet             = {
    ["Onyxian Warder"] = true,
    ["Corrupted Green Whelp"] = true,
    ["Corrupted Red Whelp"] = true,
    ["Corrupted Bronze Whelp"] = true,
    ["Corrupted Blue Whelp"] = true,
    ["Death Talon Hatcher"] = true,
    ["Blackwing Taskmaster"] = true,
    ["Mutated Grub"] = true,
    ["Frenzied Bat"] = true,
    ["Plague Beast"] = true,
    ["Plagued Bat"] = true,
    ["Vekniss Drone"] = true,
    ["Vekniss Soldier"] = true,
    ["Anvilrage Reservist"] = true,
    ["Shadowforge Flame Keeper"] = true
}

-- AoE Totem Requirements
local MobsToAoeTotemSet           = {
    ["Plague Beast"] = true,
    ["Mutated Grub"] = true,
    ["Frenzied Bat"] = true,
    ["Plagued Bat"] = true,
    ["Vekniss Drone"] = true,
    ["Vekniss Soldier"] = true,
    ["Fankriss the Unyielding"] = true,
    ["Corrupted Green Whelp"] = true,
    ["Corrupted Red Whelp"] = true,
    ["Corrupted Bronze Whelp"] = true,
    ["Corrupted Blue Whelp"] = true,
    ["Death Talon Hatcher"] = true,
    ["Blackwing Taskmaster"] = true,
    ["Poisonous Skitterer"] = true
}

-- Corrupted Totems (enemies)
local CorruptedTotemsSet          = {
    ["Corrupted Healing Stream Totem"] = true,
    ["Corrupted Windfury Totem"] = true,
    ["Corrupted Stoneskin Totem"] = true,
    ["Corrupted Fire Nova Totem"] = true
}

-- [[ Damage Immune ]] --

-- Fire Immunity
local FireImmuneSet               = {
    ["Baron Geddon"] = true,
    ["Flameguard"] = true,
    ["Firewalker"] = true,
    ["Firelord"] = true,
    ["Lava Spawn"] = true,
    ["Son of Flame"] = true,
    ["Ragnaros"] = true,
    ["Corrupted Infernal"] = true,
    ["Vaelastrasz the Corrupt"] = true,
    ["Corrupted Red Whelp"] = true,
    ["Firemaw"] = true,
    ["Prince Skaldrenox"] = true,
    ["Ebonroc"] = true,
    ["Onyxia"] = true,
    ["Black Drakonid"] = true,
    ["Red Drakonid"] = true,
    ["Onyxian Warder"] = true,
    ["Blazing Fireguard"] = true,
    ["Lord Incendius"] = true,
    ["Fireguard"] = true,
    ["Pyroguard Emberseer"] = true,
    ["Fireguard Destroyer"] = true,
    ["Flamegor"] = true
}

-- Frost Immunity
local FrostImmuneSet              = {
    ["Ras Frostwhisper"] = true,
    ["Frostmaul Giant"] = true,
    ["Ice Thistle Yeti"] = true,
    ["Highborne Lichling"] = true
}

-- [[ Boss Categories ]] --

-- Elemental Boss Categories
local NatureBossSet               = {
    ["The Nature Boss"] = true,
    ["Princess Yauj"] = true,
    ["Lord Kri"] = true,
    ["Vem"] = true,
    ["Princess Huhuran"] = true,
    ["Buru the Gorger"] = true,
    ["High Priestess Mar'li"] = true,
    ["Spawn of Mar'li"] = true,
    ["Witherbark Speaker"] = true,
    ["High Priest Venoxis"] = true,
    ["Razzashi Cobra"] = true,
    ["Razzashi Serpent"] = true,
    ["Razzashi Adder"] = true
}

local FireBossSet                 = {
    ["The Fire Boss"] = true,
    ["Death Talon Overseer"] = true,
    ["Blackwing Spellbinder"] = true,
    ["Blackwing Technician"] = true,
    ["Blackwing Warlock"] = true,
    ["Razorgore the Untamed"] = true,
    ["Vaelastrasz the Corrupt"] = true,
    ["Firemaw"] = true,
    ["Flamegor"] = true,
    ["Ebonroc"] = true,
    ["Ancient Core Hound"] = true,
    ["Firelord"] = true,
    ["Lava Spawn"] = true,
    ["Lava Elemental"] = true,
    ["Firewalker"] = true,
    ["Flame Imp"] = true,
    ["Magmadar"] = true,
    ["Gehennas"] = true,
    ["Baron Geddon"] = true,
    ["Sulfuron Harbinger"] = true,
    ["Golemagg the Incinerator"] = true,
    ["Majordomo Executus"] = true,
    ["Ragnaros"] = true,
    ["High Priestess Jeklik"] = true,
    ["Grand Widow Faerlina"] = true,
    ["Naxxramas Follower"] = true,
    ["Naxxramas Worshipper"] = true,
    ["Chromatic Dragonspawn"] = true,
    ["Chromatic Drakonid"] = true,
    ["Chromatic Elite Guard"] = true,
    ["Chromatic Whelp"] = true,
    ["Rage Talon Dragon Guard"] = true,
    ["Rage Talon Dragonspawn"] = true,
    ["Death Talon Dragonspawn"] = true,
    ["Anubisath Warder"] = true,
    ["Onyxia"] = true
}

-- Totem-Specific Boss Categories
local TremorBossSet               = {
    ["The Termor Boss"] = true,
    ["Magmadar"] = true,
    ["Emeriss"] = true,
    ["Taerar"] = true,
    ["Lethon"] = true,
    ["Ysondre"] = true,
    ["Nefarian"] = true,
    ["Princess Yauj"] = true,
    ["Onyxia"] = true
}

local GroundingBossSet            = {
    ["The Grounding Boss"] = true,
    ["Ossirian the Unscarred"] = true
}

local PoisonBossSet               = {
    ["The Poison Boss"] = true,
    ["Princess Yauj"] = true,
    ["Lord Kri"] = true,
    ["Vem"] = true,
    ["Viscidus"] = true,
    ["Princess Huhuran"] = true,
    ["Chromaggus"] = true,
    ["High Priestess Mar'li"] = true,
    ["Spawn of Mar'li"] = true,
    ["Witherbark Speaker"] = true,
    ["High Priest Venoxis"] = true,
    ["Razzashi Cobra"] = true,
    ["Razzashi Serpent"] = true,
    ["Razzashi Adder"] = true
}

local FAPBossSet                  = {
    ["Gehennas"] = true,
    ["Flamewaker"] = true,
    ["Lava Elemental"] = true
}

-- [[ NPCs ]] --

-- Vendor Categories
local ReagentVendorsSet           = {
    ["Khur Hornstriker"] = true,
    ["Barim Jurgenstaad"] = true,
    ["Rekkul"] = true,
    ["Trak'gen"] = true,
    ["Horthus"] = true,
    ["Hannah Akeley"] = true,
    ["Alyssa Eva"] = true,
    ["Thomas Mordan"] = true,
    ["Reagents"] = true,
    ["Consumables"] = true
}

-- [[ Region ]] --
Instance                          = {
    NAXX        = function()
        return GetRealZoneText() == "Naxxramas"
    end,
    AQ40        = function()
        return GetRealZoneText() == "Ahn\'Qiraj"
    end,
    AQ20        = function()
        return GetRealZoneText() == "Ruins of Ahn\'Qiraj"
    end,
    MC          = function()
        return GetRealZoneText() == "Molten Core"
    end,
    BWL         = function()
        return GetRealZoneText() == "Blackwing Lair"
    end,
    ONY         = function()
        return GetRealZoneText() == "Onyxia\'s Lair"
    end,
    ZG          = function()
        return GetRealZoneText() == "Zul\'Gurub"
    end,
    IsWorldBoss = function()
        return UnitClassification("target") == "worldboss"
    end,
    IsInRaid    = function(self)
        return self.NAXX() or self.AQ40() or self.AQ20()
            or self.MC() or self.BWL() or self.ONY() or self.ZG()
    end
}

Faction                           = {
    IsHorde = function()
        return UnitFactionGroup("player") == "Horde"
    end
}

-- [[ Functions ]] --

function MoronBox.Config.Tables.BossesIShouldUseBandageOn()
    if myClass == "Warlock" then
        return getRaid().TankTargetInSet(BandageBossesForWarlock)
    elseif myClass == "Mage" then
        return getRaid().TankTargetInSet(BandageBossesForMage)
    end
    return false
end

function MoronBox.Config.Tables.BossesIShouldUseRecklessnessOn()
    local raidLeaderId = getCoreState().MBID[getConfigState().RaidLeader]
    if raidLeaderId and UnitName(raidLeaderId .. "target") then
        local tankTargetName = UnitName(raidLeaderId .. "target")
        local healthThreshold = RecklessnessTargetsSet[tankTargetName]

        if healthThreshold then
            return getRaid().TargetHealthFromRaidleader(tankTargetName, healthThreshold)
        end
    end
    return false
end

-- Combat Restriction Functions
function MoronBox.Config.Tables.MobsNoCurses()
    local targetName = UnitName("target")
    return targetName and MobsNoCursesSet[targetName] == true
end

function MoronBox.Config.Tables.MobsNoSunders()
    local targetName = UnitName("target")
    return targetName and MobsNoSundersSet[targetName] == true
end

function MoronBox.Config.Tables.UseBloodFury()
    return not getRaid().TankTargetInSet(UseBloodFuryBlacklistSet)
end

function MoronBox.Config.Tables.IsExcludedWW()
    local targetName = UnitName("target")
    return targetName and ExcludedTargetsSet[targetName] == true
end

function MoronBox.Config.Tables.BossNeverInterruptHeal()
    return getRaid().TankTargetInSet(BossToNeverInterruptHealSet)
end

function MoronBox.Config.Tables.UseTranquilizingShot()
    return getRaid().TankTargetInSet(UseTranquilizingShotSet)
end

-- Protective Magic Functions
function MoronBox.Config.Tables.MobsToFireWard()
    return getRaid().TankTargetInSet(MobsToFireWardSet)
end

function MoronBox.Config.Tables.MobsToShadowWard()
    return getRaid().TankTargetInSet(MobsToShadowWardSet)
end

function MoronBox.Config.Tables.DebuffsToShadowWard()
    for _, debuffName in ipairs(ShadowWardDebuffsSet) do
        if getAura().HasBuffOrDebuff(debuffName, "player", "debuff") then
            return true
        end
    end

    return getAura().HasBuffNamed("Shadow and Frost Reflect", "target")
end

function MoronBox.Config.Tables.MobsToDetectMagic()
    local targetName = UnitName("target")
    return targetName and MobsToDetectMagicSet[targetName] == true
end

function MoronBox.Config.Tables.MobsToDampenMagic()
    return getRaid().TankTargetInSet(MobsToDampenMagicSet) or LOA_IsAtLoatheb()
end

function MoronBox.Config.Tables.MobsToAmplifyMagic()
    return getRaid().TankTargetInSet(MobsToAmplifyMagicSet)
end

-- Behavioral Functions
function MoronBox.Config.Tables.MobsToAutoTurn()
    return getRaid().TankTargetInSet(MobsToAutoTurnSet)
end

function MoronBox.Config.Tables.MobsToAutoBreakFear()
    return getRaid().TankTargetInSet(MobsToAutoBreakFearSet)
end

-- Totem Functions
function MoronBox.Config.Tables.MobsNoTotems()
    return getRaid().TankTargetInSet(MobsNoTotemsSet)
end

function MoronBox.Config.Tables.MobsToAoeTotem()
    return getRaid().TankTargetInSet(MobsToAoeTotemSet)
end

function MoronBox.Config.Tables.CorruptedTotems()
    local targetName = UnitName("target")
    return targetName and CorruptedTotemsSet[targetName] == true
end

-- Immunity Functions
function MoronBox.Config.Tables.IsFireImmune()
    local targetName = UnitName("target")
    return targetName and FireImmuneSet[targetName] == true
end

function MoronBox.Config.Tables.IsFrostImmune()
    local targetName = UnitName("target")
    return targetName and FrostImmuneSet[targetName] == true
end

-- Boss Category Functions
function MoronBox.Config.Tables.IsNatureBoss()
    return getRaid().TankTargetInSet(NatureBossSet)
end

function MoronBox.Config.Tables.IsTremorBoss()
    return getRaid().TankTargetInSet(TremorBossSet)
end

function MoronBox.Config.Tables.IsGroundingBoss()
    return getRaid().TankTargetInSet(GroundingBossSet)
end

function MoronBox.Config.Tables.IsPoisonBoss()
    return getRaid().TankTargetInSet(PoisonBossSet)
end

function MoronBox.Config.Tables.IsFireBoss()
    return getRaid().TankTargetInSet(FireBossSet)
end

-- Vendor Functions
function MoronBox.Config.Tables.ReagentVendors()
    local targetName = UnitName("target")
    return targetName and ReagentVendorsSet[targetName] == true
end

function MoronBox.Config.Tables.BossUseFAPon()
    return getRaid().TankTargetInSet(FAPBossSet)
end

-- [[ Complex Get Stunnable Mobs ]] --

function MoronBox.Config.Tables.StunnableMob()
    local targetName = UnitName("target")
    if not targetName then
        return false
    end

    -- Check if already stunned
    local stunDebuffs = {
        "Kidney Shot", "Blackout", "Hammer of Justice", "Mace Stun",
        "Concussion Blow", "Bash", "War Stomp"
    }

    for _, debuff in ipairs(stunDebuffs) do
        if getAura().HasBuffOrDebuff(debuff, "target", "debuff") then
            return false
        end
    end

    -- Always stunnable mobs
    local alwaysStun = {
        "Gurubashi Blood Drinker", "Gurubashi Axe Thrower", "Hakkari Priest",
        "Gurubashi Champion", "Gurubashi Headhunter", "Shade of Naxxramas",
        "Spirit of Naxxramas", "Plagued Construct", "Deathknight Servant",
        "Sartura's Royal Guard", "Battleguard Sartura", "Deathchill Servant"
    }

    for _, name in ipairs(alwaysStun) do
        if targetName == name then
            return true
        end
    end

    -- Health-dependent stunning
    local targetHealth = getUnit().HealthPct("target")

    if targetHealth < 0.6 then
        local hp60 = { "Plagued Champion", "Plagued Guardian" }
        for _, name in ipairs(hp60) do
            if targetName == name then
                return true
            end
        end
    end

    if targetHealth < 0.4 then
        local hp40 = { "Infectious Ghoul", "Spawn of Fankriss", "Plagued Ghoul" }
        for _, name in ipairs(hp40) do
            if targetName == name then
                return true
            end
        end
    end

    return false
end
