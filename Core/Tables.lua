--[####################################################################################################]--
--[######################################## ADDON DATA TABLES #########################################]--
--[####################################################################################################]--

--[[
    This file contains all data tables and lookup functions for the addon.
    
    Structure:
    - Shared locals (API functions)
    - Data tables organized by category
    - Accessor functions for each table
    - Complex logic functions
--]]

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
--[############################################ BOSS MECHANICS ########################################]--
--[####################################################################################################]--

-- Recklessness Usage Thresholds
local MB_recklessnessTargetsSet = {
    ["Patchwerk"] = 0.19,
    ["Maexxna"] = 0.19,
    ["Noth the Plaguebringer"] = 0.19,
    ["Ragnaros"] = 0.19,
    ["Chromaggus"] = 0.19,
    ["Nefarian"] = 0.19,
    ["Fankriss the Unyielding"] = 0.19,
    ["Princess Yauj"] = 0.30,
    ["Heigan the Unclean"] = 0.25,
    ["Magmadar"] = 0.25,
    ["Vaelastrasz the Corrupt"] = 0.11,
    ["Grand Widow Faerlina"] = 0.19,
}

-- Bandage Usage by Class
local MB_bandageBossesForWarlock = {
    ["Patchwerk"] = true,
    ["Lady Blaumeux"] = true,
    ["Sir Zeliek"] = true,
    ["Thane Korth\'azz"] = true,
    ["Highlord Alexandros Mograine"] = true,
}

local MB_bandageBossesForMage = {
    ["Lady Blaumeux"] = true,
    ["Sir Zeliek"] = true,
    ["Thane Korth\'azz"] = true,
    ["Highlord Alexandros Mograine"] = true,
}

-- Healing Interrupt Immunity
local MB_bossToNeverInterruptHealSet = {
    ["Vaelastrasz the Corrupt"] = true,
    ["Maexxna"] = true,
    ["Ossirian the Unscarred"] = true
}

-- Tranquilizing Shot Targets
local MB_useTranquilizingShotSet = {
    ["Gluth"] = true,
    ["Princess Huhuran"] = true,
    ["Flamegor"] = true,
    ["Chromaggus"] = true,
    ["Magmadar"] = true,
}

--[####################################################################################################]--
--[########################################## COMBAT RESTRICTIONS #####################################]--
--[####################################################################################################]--

-- Debuff Restrictions
local MB_mobsNoCursesSet = {
    ["Blackwing Mage"] = true,
    ["Blackwing Legionnaire"] = true,
    ["Corrupted Green Whelp"] = true,
    ["Corrupted Red Whelp"] = true,
    ["Corrupted Bronze Whelp"] = true,
    ["Corrupted Blue Whelp"] = true,
    ["Mutated Grub"] = true,
    ["Frenzied Bat"] = true,
    ["Plagued Bat"] = true,
}

local MB_mobsNoSundersSet = {
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
    ["Plagued Bat"] = true,
}

-- Blood Fury Blacklist
local MB_useBloodFuryBlacklistSet = {
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
    ["Blackwing Taskmaster"] = true,
}

-- Excluded Whirlwind Targets
local MB_excludedTargetsSet = {
    ["Emperor Vek'lor"] = true,
    ["Emperor Vek'nilash"] = true,
    ["The Prophet Skeram"] = true,
}

--[####################################################################################################]--
--[######################################### PROTECTIVE MAGIC #########################################]--
--[####################################################################################################]--

-- Ward Requirements
local MB_mobsToFireWardSet = {
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
    ["Flame Imp"] = true,
}

local MB_mobsToShadowWardSet = {
    ["Death Lord"] = true,
    ["Necropolis Acolyte"] = true,
    ["Deathknight Cavalier"] = true,
    ["Shade of Naxxramas"] = true,
    ["Spirit of Naxxramas"] = true,
    ["Lord Kazzak"] = true,
    ["Hakkar"] = true,
    ["Necro Knight"] = true,
}

local MB_shadowWardDebuffsSet = {
    "Corruption", 
    "Curse of Agony", 
    "Siphon Life", 
    "Impending Doom",
    "Inevitable Doom", 
    "Aura of Agony", 
    "Shadow Word: Pain", 
    "Corruption of the Earth"
}

local MB_mobsToFearWardSet = {
    ["Nefarian"] = true,
    ["Magmadar"] = true,
    ["Princess Yauj"] = true,
    ["Lord Kri"] = true,
    ["Vem"] = true,
    ["Onyxia"] = true,
    ["Deathknight"] = true,
    ["High Priestess Jeklik"] = true,
    ["Gurubashi Berserker"] = true,
    ["Gluth"] = true,
}

-- Magic Detection/Manipulation
local MB_mobsToDetectMagicSet = {
    ["Anubisath Sentinel"] = true,
    ["Anubisath Guardian"] = true,
    ["Anubisath Defender"] = true,
    ["Death Talon Wyrmguard"] = true,
    ["Shazzrah"] = true,
}

local MB_mobsToDampenMagicSet = {
    ["Grethok the Controller"] = true,
}

local MB_mobsToAmplifyMagicSet = {
    ["Patchwerk"] = true,
    ["Noth the Plaguebringer"] = true,
    ["Gluth"] = true,
    ["Maexxna"] = true,
}

--[####################################################################################################]--
--[####################################### BEHAVIORAL TRIGGERS #######{{###############################]--
--[####################################################################################################]--

-- Auto-Turn Requirements (fear immunity)
local MB_mobsToAutoTurnSet = {
    ["Magmadar"] = true,
    ["Ancient Core Hound"] = true,
    ["Onyxia"] = true,
    ["Deathknight"] = true,
}

-- Auto-Break Fear Requirements
local MB_mobsToAutoBreakFearSet = {
    ["Deathknight"] = true,
    ["Princess Yauj"] = true
}

--[####################################################################################################]--
--[########################################## TOTEM MANAGEMENT #####{{{################################]--
--[####################################################################################################]--

-- Totem Restrictions
local MB_mobsNoTotemsSet = {
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
    ["Shadowforge Flame Keeper"] = true,
}

-- AoE Totem Requirements
local MB_mobsToAoeTotemSet = {
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
    ["Poisonous Skitterer"] = true,
}

-- Corrupted Totems (enemies)
local MB_corruptedTotemsSet = {
    ["Corrupted Healing Stream Totem"] = true,
    ["Corrupted Windfury Totem"] = true,
    ["Corrupted Stoneskin Totem"] = true,
    ["Corrupted Fire Nova Totem"] = true
}

--[####################################################################################################]--
--[######################################## DAMAGE IMMUNITIES ###########{{{{{#########################]--
--[####################################################################################################]--

-- Fire Immunity
local MB_fireImmuneSet = {
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
local MB_frostImmuneSet = {
    ["Ras Frostwhisper"] = true,
    ["Frostmaul Giant"] = true,
    ["Ice Thistle Yeti"] = true,
    ["Highborne Lichling"] = true
}

--[####################################################################################################]--
--[######################################### BOSS CATEGORIES ##########################################]--
--[####################################################################################################]--

-- Elemental Boss Categories
local MB_NatureBossSet = {
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
    ["Razzashi Adder"] = true,
}

local MB_FireBossSet = {
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
    ["Onyxia"] = true,
}

-- Totem-Specific Boss Categories
local MB_TremorBossSet = {
    ["The Termor Boss"] = true,
    ["Magmadar"] = true,
    ["Emeriss"] = true,
    ["Taerar"] = true,
    ["Lethon"] = true,
    ["Ysondre"] = true,
    ["Nefarian"] = true,
    ["Princess Yauj"] = true,
    ["Lord Kri"] = true,
    ["Vem"] = true,
    ["Onyxia"] = true,
}

local MB_GroundingBossSet = {
    ["The Grounding Boss"] = true,
    ["Ossirian the Unscarred"] = true,
}

local MB_PoisonBossSet = {
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
    ["Razzashi Adder"] = true,
}

--[####################################################################################################]--
--[############################################ NPC CATEGORIES #######################################]--
--[####################################################################################################]--

-- Vendor Categories
local MB_reagentVendorsSet = {
    ["Khur Hornstriker"] = true,
    ["Barim Jurgenstaad"] = true,
    ["Rekkul"] = true,
    ["Trak'gen"] = true,
    ["Horthus"] = true,
    ["Hannah Akeley"] = true,
    ["Alyssa Eva"] = true,
    ["Thomas Mordan"] = true
}

local MB_sunfruitVendorsSet = {
    ["Quartermaster Miranda Breechlock"] = true,
    ["Argent Quartermaster Lightspark"] = true,
    ["Argent Quartermaster Hasana"] = true
}

--[####################################################################################################]--
--[########################################## SPELL/ABILITY LISTS ####################################]--
--[####################################################################################################]--

-- Spells to Interrupt
MB_spellsToInt = {
    -- Basic Damage Spells
    "Frostbolt",
    "Shadow Bolt",
    "Mind Flay",        -- PW trash
    "Mind Blast",       -- AQ40, Mindslayers
    "Holy Fire",
    "Drain Life",       -- Spider ZG

    -- Healing Spells
    "Greater Heal",
    "Great Heal",       -- Tiger heal
    "Heal",
    "Healing Wave",
    "Dark Mending",     -- Flamewalker Priest

    -- Crowd Control
    "Banish",
    "Polymorph",

    -- Debuffs
    "Cripple",

    -- Instance-Specific Spells
    "Healing Circle",   -- Suppression Room
    "Flamestrike",      -- Suppression Room
    "Demon Portal",     -- Blackwing Warlock
    "Rain of Fire",     -- Blackwing Warlock
    "Arcane Explosion", -- Razorgore First Phase
    "Fireball",         -- Razorgore First Phase

    -- AoE Spells
    "Fireball Volley",      -- Packs behind Vaelastrasz
    "Shadow Bolt Volley",
    "Frostbolt Volley",
    "Venom Spit",          -- Snake AOE
}

-- Auto-Trade Items
MB_itemToAutoTrade = {
    -- Crafting Materials
    "Arcanite Bar",
    "Mooncloth",
    "Refined Deeprock Salt",
    "Deeprock Salt",
    "Cured Rugged Hide",
    "Arcane Crystal",
    "Thorium Bar",
    "Hourglass Sand",
    "Felcloth",

    -- Essences
    "Essence of Air",
    "Essence of Undeath",
    "Living Essence",
    "Essence of Water",
    "Essence of Earth",

    -- Consumables
    "Major Mana Potion",
    "Elixir of the Mongoose",
    "Greater Stoneshield Potion",
    "Greater Nature Protection Potion",
    "Greater Shadow Protection Potion",
    "Gift of Arthas",

    -- Food & Drink
    "Conjured.*Water",
    "Rumsey Rum Black Label",
    "Dirge\'s Kickin\' Chimaerok Chops",

    -- ZG Items
    ".*Hakkari Bijou",
}

--[####################################################################################################]--
--[######################################### ACCESSOR FUNCTIONS #####################################]--
--[####################################################################################################]--

-- Boss Mechanics Functions
function mb_bossIShouldUseRunesAndManapotsOn()
    return mb_targetHealthFromRaidleader("Big Boss", 0.95)
end

function mb_bossIShouldUseManapotsOn()
    return mb_targetHealthFromRaidleader("Big Boss", 0.65) or
           mb_targetHealthFromRaidleader("Patchwerk", 0.95)
end

function mb_bossIShouldUseBandageOn()
    local myClass = UnitClass("player")
    
    if myClass == "Warlock" then
        return mb_tankTargetInSet(MB_bandageBossesForWarlock)
    elseif myClass == "Mage" then
        return mb_tankTargetInSet(MB_bandageBossesForMage)
    end
    
    return false
end

function mb_bossIShouldUseRecklessnessOn()
    if MBID[MB_raidLeader] and UnitName(MBID[MB_raidLeader].."target") then
        local tankTargetName = UnitName(MBID[MB_raidLeader].."target")
        local healthThreshold = MB_recklessnessTargetsSet[tankTargetName]
        
        if healthThreshold then
            return mb_targetHealthFromRaidleader(tankTargetName, healthThreshold)
        end
    end
    return false
end

-- Combat Restriction Functions
function mb_mobsNoCurses()
    local targetName = UnitName("target")
    return targetName and MB_mobsNoCursesSet[targetName] == true
end

function mb_mobsNoSunders()
    local targetName = UnitName("target")
    return targetName and MB_mobsNoSundersSet[targetName] == true
end

function mb_useBloodFury()
    return not mb_tankTargetInSet(MB_useBloodFuryBlacklistSet)
end

function mb_isExcludedWW()
    local targetName = UnitName("target")
    return targetName and MB_excludedTargetsSet[targetName] == true
end

function mb_bossNeverInterruptHeal()
    return mb_tankTargetInSet(MB_bossToNeverInterruptHealSet)
end

function mb_useTranquilizingShot()
    return mb_tankTargetInSet(MB_useTranquilizingShotSet)
end

-- Protective Magic Functions
function mb_mobsToFireWard()
    return mb_tankTargetInSet(MB_mobsToFireWardSet)
end

function mb_mobsToShadowWard()
    return mb_tankTargetInSet(MB_mobsToShadowWardSet)
end

function mb_debuffsToShadowWard()
    for _, debuffName in ipairs(MB_shadowWardDebuffsSet) do
        if mb_hasBuffOrDebuff(debuffName, "player", "debuff") then
            return true
        end
    end
    
    return mb_hasBuffNamed("Shadow and Frost Reflect", "target")
end

function mb_mobsToFearWard()
    return mb_tankTargetInSet(MB_mobsToFearWardSet)
end

function mb_mobsToDetectMagic()
    local targetName = UnitName("target")
    return targetName and MB_mobsToDetectMagicSet[targetName] == true
end

function mb_mobsToDampenMagic()
    return mb_tankTargetInSet(MB_mobsToDampenMagicSet) or mb_isAtLoatheb()
end

function mb_mobsToAmplifyMagic()
    return mb_tankTargetInSet(MB_mobsToAmplifyMagicSet)
end

-- Behavioral Functions
function mb_mobsToAutoTurn()
    return mb_tankTargetInSet(MB_mobsToAutoTurnSet)
end

function mb_mobsToAutoBreakFear()
    return mb_tankTargetInSet(MB_mobsToAutoBreakFearSet)
end

-- Totem Functions
function mb_mobsNoTotems()
    return mb_tankTargetInSet(MB_mobsNoTotemsSet)
end

function mb_mobsToAoeTotem()
    return mb_tankTargetInSet(MB_mobsToAoeTotemSet)
end

function mb_corruptedTotems()
    local targetName = UnitName("target")
    return targetName and MB_corruptedTotemsSet[targetName] == true
end

-- Immunity Functions
function mb_isFireImmune()
    local targetName = UnitName("target")
    return targetName and MB_fireImmuneSet[targetName] == true
end

function mb_isFrostImmune()
    local targetName = UnitName("target")
    return targetName and MB_frostImmuneSet[targetName] == true
end

-- Boss Category Functions
function mb_isNatureBoss()
    return mb_tankTargetInSet(MB_NatureBossSet)
end

function mb_isTremorBoss()
    return mb_tankTargetInSet(MB_TremorBossSet)
end

function mb_isGroundingBoss()
    return mb_tankTargetInSet(MB_GroundingBossSet)
end

function mb_isPoisonBoss()
    return mb_tankTargetInSet(MB_PoisonBossSet)
end

function mb_isFireBoss()
    return mb_tankTargetInSet(MB_FireBossSet)
end

-- Vendor Functions
function mb_reagentVendors()
    local targetName = UnitName("target")
    return targetName and MB_reagentVendorsSet[targetName] == true
end

function mb_sunfruitVendors()
    local targetName = UnitName("target")
    return targetName and MB_sunfruitVendorsSet[targetName] == true
end

--[####################################################################################################]--
--[######################################### COMPLEX LOGIC FUNCTIONS ################################]--
--[####################################################################################################]--

-- Stunnable Mob Logic
function mb_stunnableMob()
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
        if mb_hasBuffOrDebuff(debuff, "target", "debuff") then
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
        if targetName == name then return true end
    end

    -- Health-dependent stunning
    local targetHealth = mb_healthPct("target")
    
    if targetHealth < 0.6 then
        local hp60 = { "Plagued Champion", "Plagued Guardian" }
        for _, name in ipairs(hp60) do
            if targetName == name then return true end
        end
    end

    if targetHealth < 0.4 then
        local hp40 = { "Infectious Ghoul", "Spawn of Fankriss", "Plagued Ghoul" }
        for _, name in ipairs(hp40) do
            if targetName == name then return true end
        end
    end

    return false
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--