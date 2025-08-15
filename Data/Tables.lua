------------------------------------------------------------------------------------------------------
------------------------------------------------ Lookup Tables ---------------------------------------
------------------------------------------------------------------------------------------------------

local UnitName = UnitName

-- Boss/General tables
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

-- Combat/Debuff tables
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

-- Ward/Protection tables
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

-- Magic/Spell tables
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

-- Utility tables
local MB_mobsToAutoTurnSet = {
    ["Magmadar"] = true,
    ["Ancient Core Hound"] = true,
    ["Onyxia"] = true,
    ["Deathknight"] = true,
}

local MB_mobsToAutoBreakFearSet = {
    ["Deathknight"] = true,
    ["Princess Yauj"] = true
}

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

-- Totem tables
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

-- Bosses no Interrupts
local MB_bossToNeverInterruptHealSet = {
    ["Vaelastrasz the Corrupt"] = true,
    ["Maexxna"] = true,
    ["Ossirian the Unscarred"] = true
}

-- Fire Immunity Set
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

-- Frost Immunity Set
local MB_frostImmuneSet = {
    ["Ras Frostwhisper"] = true,
    ["Frostmaul Giant"] = true,
    ["Ice Thistle Yeti"] = true,
    ["Highborne Lichling"] = true
}

-- Corrupted Totems Set
local MB_corruptedTotemsSet = {
    ["Corrupted Healing Stream Totem"] = true,
    ["Corrupted Windfury Totem"] = true,
    ["Corrupted Stoneskin Totem"] = true,
    ["Corrupted Fire Nova Totem"] = true
}

-- Excluded WW Targets
local MB_excludedTargetsSet = {
    ["Emperor Vek'lor"] = true,
    ["Emperor Vek'nilash"] = true,
    ["The Prophet Skeram"] = true,
}

-- Tranq Shot Targets
local MB_useTranquilizingShotSet = {
    ["Gluth"] = true,
    ["Princess Huhuran"] = true,
    ["Flamegor"] = true,
    ["Chromaggus"] = true,
    ["Magmadar"] = true,
}

-- Nature bosses
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

-- Tremor bosses
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

-- Grounding bosses
local MB_GroundingBossSet = {
    ["The Grounding Boss"] = true,
    ["Ossirian the Unscarred"] = true,
}

-- Poison bosses
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

-- Fire bosses
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

------------------------------------------------------------------------------------------------------
------------------------------------------------ Functions ------------------------------------------
------------------------------------------------------------------------------------------------------

-- Boss/General functions
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

-- Combat/Debuff functions
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

-- Ward/Protection functions
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

-- Magic/Spell functions
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

-- Utility functions
function mb_mobsToAutoTurn()
    return mb_tankTargetInSet(MB_mobsToAutoTurnSet)
end

function mb_mobsToAutoBreakFear()
    return mb_tankTargetInSet(MB_mobsToAutoBreakFearSet)
end

-- Totem functions
function mb_mobsNoTotems()
    return mb_tankTargetInSet(MB_mobsNoTotemsSet)
end

function mb_mobsToAoeTotem()
    return mb_tankTargetInSet(MB_mobsToAoeTotemSet)
end

-- Healing Functions
function mb_bossNeverInterruptHeal()
    return mb_tankTargetInSet(MB_bossToNeverInterruptHealSet)
end

-- Fire Immunity Functions
function mb_isFireImmune()
    local targetName = UnitName("target")
    return targetName and MB_fireImmuneSet[targetName] == true
end

-- Frost Immunity Functions
function mb_isFrostImmune()
    local targetName = UnitName("target")
    return targetName and MB_frostImmuneSet[targetName] == true
end

-- Corrupted Totems Functions
function mb_corruptedTotems()
    local targetName = UnitName("target")
    return targetName and MB_corruptedTotemsSet[targetName] == true
end

-- Excluded WW Targets
function mb_isExcludedWW()
    local targetName = UnitName("target")
    return targetName and MB_excludedTargetsSet[targetName] == true
end

-- Tranq Shot Functions
function mb_useTranquilizingShot()
    return mb_tankTargetInSet(MB_useTranquilizingShotSet)
end

-- Nature Boss Functions
function mb_isNatureBoss()
    return mb_tankTargetInSet(MB_NatureBossSet)
end

-- Tremor Boss Functions
function mb_isTremorBoss()
    return mb_tankTargetInSet(MB_TremorBossSet)
end

-- Grounding Boss Functions
function mb_isGroundingBoss()
    return mb_tankTargetInSet(MB_GroundingBossSet)
end

-- Poison Boss Functions
function mb_isPoisonBoss()
    return mb_tankTargetInSet(MB_PoisonBossSet)
end

-- Fire Boss Functions
function mb_isFireBoss()
    return mb_tankTargetInSet(MB_FireBossSet)
end

function mb_reagentVendors()
    local targetName = UnitName("target")
    return targetName and MB_reagentVendorsSet[targetName] == true
end

function mb_sunfruitVendors()
    local targetName = UnitName("target")
    return targetName and MB_sunfruitVendorsSet[targetName] == true
end

function mb_stunnableMob()
    local targetName = UnitName("target")
    if not targetName then
        return false
    end

    local stunDebuffs = {
        "Kidney Shot",
        "Blackout",
        "Hammer of Justice",
        "Mace Stun",
        "Concussion Blow",
        "Bash",
        "War Stomp"
    }

    for _, debuff in ipairs(stunDebuffs) do
        if mb_hasBuffOrDebuff(debuff, "target", "debuff") then
            return false
        end
    end

    local alwaysStun = {
        "Gurubashi Blood Drinker",
        "Gurubashi Axe Thrower",
        "Hakkari Priest",
        "Gurubashi Champion",
        "Gurubashi Headhunter",
        "Shade of Naxxramas",
        "Spirit of Naxxramas",
        "Plagued Construct",
        "Deathknight Servant",
        "Sartura's Royal Guard",
        "Battleguard Sartura",
        "Deathchill Servant"
    }

    for _, name in ipairs(alwaysStun) do
        if targetName == name then return true end
    end

    local hp60 = { "Plagued Champion", "Plagued Guardian" }
    if mb_healthPct("target") < 0.6 then
        for _, name in ipairs(hp60) do
            if targetName == name then return true end
        end
    end

    local hp40 = { "Infectious Ghoul", "Spawn of Fankriss", "Plagued Ghoul" }
    if mb_healthPct("target") < 0.4 then
        for _, name in ipairs(hp40) do
            if targetName == name then return true end
        end
    end

    return false
end

-- Spells to Intterupt --

MB_spellsToInt = { -- These spells will automatically be interrupted

	-- Normal Spells
	"Frostbolt",
	"Shadow Bolt",

	"Mind Flay", -- PW trash
	"Mind Blast", -- AQ40, Mindslayers

	"Holy Fire",
	"Drain Life", -- Spider ZG

	-- Heals
	"Greater Heal",
	"Great Heal", -- Tiger heal
	"Heal",
	"Healing Wave",
	"Dark Mending", -- Flamewalker Priest

	-- CC's
	"Banish",
	"Polymorph",

	-- Slows
	"Cripple",

	-- Supression Room
	"Healing Circle",
	"Flamestrike",

	-- Blackwing Warlock
	"Shadow Bolt",
	"Demon Portal",
	"Rain of Fire",

	-- Razorgore First Phase
	"Arcane Explosion",
	"Fireball",

	-- AOE's
	"Fireball Volley", -- Packs behind Vaelstraz
	"Shadow Bolt Volley",
	"Frostbolt Volley",
	"Venom Spit", -- Snake AOE
}

-- Auto Trader --

MB_itemToAutoTrade = {
	"Arcanite Bar",
	"Mooncloth",
	"Refined Deeprock Salt",
	"Essence of Air",
	"Essence of Undeath",
	"Living Essence",
	"Essence of Water",
	"Essence of Earth",
	"Cured Rugged Hide",
	"Arcane Crystal",
	"Thorium Bar",
	"Hourglass Sand",
	"Felcloth",
	"Major Mana Potion",
	"Elixir of the Mongoose",
	"Greater Stoneshield Potion",
	"Gift of Arthas",
	"Conjured.*Water",
	"Rumsey Rum Black Label",
	".*Hakkari Bijou",
	"Dirge\'s Kickin\' Chimaerok Chops",
	"Deeprock Salt",
	"Greater Nature Protection Potion",
	"Greater Shadow Protection Potion"
}