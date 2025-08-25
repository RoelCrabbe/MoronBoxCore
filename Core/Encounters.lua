--[####################################################################################################]--
--[#################################### BOSS ENCOUNTER CONFIGURATIONS ###{#############################]--
--[####################################################################################################]--

--[[
    This file contains all boss encounter strategies and player assignments.
    
    Configuration Structure:
    - Each boss has strategy toggles (true/false)
    - Player assignments are organized by role
    - Comments explain tactics and requirements
    - Horde/Alliance assignments are clearly separated
    
    Note: All variables are global and accessible throughout the addon's
--]]

--[####################################################################################################]--
--[############################################ NAXXRAMAS #############################################]--
--[####################################################################################################]--

-- Strategy Configuration
MB_myPatchwerkBoxStrategy = true

-- Tank Assignments (REQUIRED - Heal dependent)
MB_myThreatPWSoaker = "Moron"
MB_myFirstPWSoaker = "Suecia"
MB_mySecondPWSoaker = "Ajlano"
MB_myThirdPWSoaker = "Almisael"

-- Healer Assignments per Tank
MB_myThreatPWSoakerHealerList = {
    "Bogeycrap",    -- 8T1 Shaman
    "Midavellir",   -- Priest
    "Pyqmi"         -- Druid
}

MB_myFirstPWSoakerHealerList = {
    "Shamuk",       -- 6T3+ Shaman for BUFF
    "Draub",        -- 8T2 Priest
    "Mvenna",       -- 8T1 Shaman
    "Superkoe"      -- 8T1 Shaman	
}

MB_mySecondPWSoakerHealerList = {
    "Laitelaismo",  -- 6T3+ Shaman for BUFF
    "Ayag",         -- 8T2 Priest
    "Chimando",     -- 8T1 Shaman
    "Smalheal"      -- Druid
}
    
MB_myThirdPWSoakerHealerList = {
    "Ootskar",      -- 6T3+ Shaman for BUFF
    "Healdealz",    -- Priest
    "Purges",       -- 8T1 Shaman
    "Zwartje"
}

--[[
    Patchwerk Tactics:
    - Alliance doesn't need this setup, they have Divine Intervention
    - Healers will automatically heal their assigned tank
    - All assignments MUST be configured for proper execution
--]]

-- Strategy Configuration
MB_myMaexxnaBoxStrategy = true

-- Tank Assignment (REQUIRED)
MB_myMaexxnaMainTank = {
    "Moron",            -- Horde Team 1
    "Alliance Tank 1"   -- Alliance
}

-- Healer Assignments (REQUIRED)
MB_myMaexxnaDruidHealer = {        
    "Smalheal",         -- Horde Team 1
    "Pyqmi",            -- Horde Team 1
    "Alliance Druid 1"  -- Alliance
}

MB_myMaexxnaPriestHealer = {        
    "Midavellir",       -- Horde Team 1
    "Alliance Priest 1" -- Alliance
}

--[[
    Maexxna Tactics:
    - Main tank will remove useless buffs to stay below readable buff cap
    - Druid healers: Regrowth, Rejuvenation, Abolish
    - Priest healers: Renew
    - Healers heal TargetOfTarget automatically
--]]

-- Strategy Configuration
MB_myGrobbulusBoxStrategy = true 

-- Tank Assignments (REQUIRED)
MB_myGrobbulusMainTank = "Moron"        -- Targets boss
MB_myGrobbulusSlimeTankOne = "Suecia"   -- Targets blobs, caster assist
MB_myGrobbulusSlimeTankTwo = "Ajlano"   -- Targets blobs, caster assist

-- Follow Targets
MB_myGrobbulusFollowTarget = "Suecia"
MB_myGrobbulusSecondFollowTarget = "Ajlano"

--[[
    Grobbulus Tactics:
    - Main tank holds boss
    - Slime tanks handle blob spawns
    - Casters assist slime tanks
--]]

-- Strategy Configuration
MB_myRazuviousBoxStrategy = true 

-- Priest Assignments (REQUIRED - Mind Control)
MB_myRazuviousPriest = {
    "Moronpriest",      -- Horde Team 1
    "Alliance Priest 1" -- Alliance
}

--[[
    Razuvious Tactics:
    - Priests mind control the Understudies
    - Requires precise timing and positioning
--]]

-- Strategy Configuration
MB_myFaerlinaBoxStrategy = true 
MB_myFaerlinaFirePotStrategy = true

-- Priest Assignments (REQUIRED - Mind Control)
MB_myFaerlinaPriest = {		
    "Moronpriest",       -- Horde Team 1
    "Alliance Priest 1" -- Alliance
}

--[[
    Faerlina Tactics:
    - Priests mind control the Worshippers
    - Optional frozen rune strategy available
--]]

-- Strategy Configuration
MB_myLoathebBoxStrategy = true
MB_myLoathebShadowPotStrategy = true

-- Tank and Paladin Assignments (REQUIRED)
MB_myLoathebMainTank = "Klawss"
MB_myLoathebSealPaladin = "Bubblebumm" -- Seal of Light/Wisdom

-- Healer Assignments (REQUIRED)
MB_myLoathebHealer = {
    -- Priests
    "Wiccana", "Nouveele", "Luxic", "Hms", "Murdrum", "Captivity",
    -- Paladins  
    "Bubblebumm", "Breachedhull", "Fatnun", "Candylane", "Adobe",
    -- Druids
    "Jahetsu", "Kusch", "Droodish"
}

-- Healing Spell Configuration (REQUIRED)
MB_myLoathebHealSpell = {
    Shaman = "Healing Wave", 
    Priest = "Greater Heal",
    Paladin = "Holy Light",
    Druid = "Healing Touch"
}

MB_myLoathebHealSpellRank = {
    Shaman = "Rank 10", 
    Priest = "Rank 5",
    Paladin = "Rank 9",
    Druid = "Rank 11"
}

--[[
    Loatheb Tactics:
    - Healing restricted to 4-second windows
    - Paladin manages seals for raid
    - Specific spell ranks optimize mana efficiency
--]]

--[####################################################################################################]--
--[######################################## TEMPLE OF AHN'QIRAJ #######################################]--
--[####################################################################################################]--

-- Strategy Configuration
MB_mySkeramBoxStrategyFollow = true
MB_mySkeramBoxStrategyWarlock = false -- Warlock Fear

-- Platform Assignments
MB_mySkeramLeftTank = {
    "Suecia",           -- Horde
    "Alliance Tank 1"   -- Alliance
}

MB_mySkeramLeftOFFTANKS = {
    "Rows",             -- Horde
    "Alliance Offtank 1" -- Alliance
}

MB_mySkeramMiddleTank = {
    "Moron",            -- Horde
    "Alliance Tank 2"   -- Alliance
}

MB_mySkeramMiddleOFFTANKS = {
    "Almisael",         -- Horde
    "Alliance Offtank 2" -- Alliance
}

MB_mySkeramMiddleDPSERS = {
    -- Horde DPS
    "Moonspawn", "Likez", "Angerissues", "Tazmahdingo", 
    "Gogopwranger", "Chabalala", "Weedzy", "Miagi",
    -- Alliance DPS
    "Alliance Melee 1"
}

MB_mySkeramRightTank = { 
    "Ajlano",           -- Horde
    "Alliance Tank 3"   -- Alliance
}

MB_mySkeramRightOFFTANKS = {
    "Sabo",             -- Horde
    "Alliance Offtank 3" -- Alliance
}

--[[
    Skeram Tactics:
    - Target Skeram and press Melee follow
    - Left/Right: Offtanks follow their tank
    - Middle: DPSers follow middle tank
    - Platform assignments are critical
--]]

-- Strategy Configuration
MB_myFankrissBoxStrategy = true

-- Tank Assignments (REQUIRED)
MB_myFankrissOFFTANKS = {
    "Suecia",               -- Horde (Targets boss, manual taunt)
    "Alliance Offtank 1"    -- Alliance
}

MB_myFankrissSnakeTankOne = {
    "Ajlano",              -- Horde (Targets snakes, caster assist)
    "Alliance Snake Tank 1" -- Alliance
}

MB_myFankrissSnakeTankTwo = {
    "Almisael",            -- Horde (Targets snakes, caster assist)  
    "Alliance Snake Tank 2" -- Alliance
}

--[[
    Fankriss Tactics:
    - Offtanks handle boss taunting manually
    - Snake tanks manage add spawns
    - Casters assist snake tanks
--]]

-- Strategy Configuration
MB_myHuhuranBoxStrategy = true
MB_myHuhuranNaturePotStrategy = true

-- Tank Assignments (REQUIRED when active)
MB_myHuhuranTankDefensivePercentage = 0.25 -- SW/LS usage threshold

--[[
    Huhuran Tactics:
    - Tank uses defensive abilities at 25% health
    - Currently disabled - enable when needed
--]]

-- Strategy Configuration
MB_myTwinsBoxStrategy = true 

-- Warlock Tank Assignment
MB_myTwinsWarlockTank = {
    "Akaaka",           -- Horde 1
    "Alliance Warlock 1" -- Alliance
}

--[[
    Twins Tactics:
    - Warlock tanks one of the twins
    - Requires specific positioning and timing
--]]

--[####################################################################################################]--
--[####################################### RUINS OF AHN'QIRAJ #########################################]--
--[####################################################################################################]--

-- Strategy Configuration
MB_myOssirianBoxStrategy = true -- Special totem dropping 

-- Tank Assignment (REQUIRED)
MB_myOssirianMainTank = "Moron"
MB_myOssirianTankDefensivePercentage = 0.35 -- Shield Wall threshold

--[[
    Ossirian Tactics:
    - Special totem dropping mechanics
    - Tank uses Shield Wall at 35% boss health
    - Weakness rotation management required
--]]

--[####################################################################################################]--
--[######################################### BLACKWING LAIR ###########################################]--
--[####################################################################################################]--

-- Strategy Configuration
MB_myRazorgoreBoxStrategy = true
MB_myRazorgoreBoxHealerStrategy = true -- Mana Pots

-- Orb Controller Assignment (REQUIRED)
MB_myRazorgoreORBtank = {
    "Kungen",             -- Horde
    "Alliance Orb Tank 1" -- Alliance
}

-- Left Side Assignments
MB_myRazorgoreLeftTank = {
    "Moron",            -- Horde
    "Alliance Tank 1"   -- Alliance
}

MB_myRazorgoreLeftDPSERS = {
    "Rows",         -- Horde Offtank (TF Tank)
    "Miagi",       -- Rogue
    -- Warriors
    "Gogopwranger", "Angerissues", "Moonspawn", 
    "Opticalfiber", "Maximumzug", "Hornagaur"
}

-- Right Side Assignments  
MB_myRazorgoreRightTank = {
    "Suecia",           -- Horde
    "Alliance Tank 2"   -- Alliance
}

MB_myRazorgoreRightDPSERS = {        
    "Sabo",           -- Horde Offtank (TF)
    "Weedzy",            -- Rogue
    -- Warriors
    "Chabalala", "Tazmahdingo", "Likez", "Anatomic",
    "Vandalus", "Xoncharr", "Insanette"
}

--[[
    Razorgore Tactics:
    - Orb controller manages the mind control (90s channel, 60s debuff)
    - Raid splits left/right with melee follow
    - DPS tracking handles the 30s gap issue
    - Orb controller still needed for initial setup
--]]

-- Strategy Configuration
MB_myVaelastraszBoxStrategy = true 
MB_myVaelastraszFirePotStrategy = true

-- Healer Class Toggles
MB_myVaelastraszShamanHealing = true   -- T1 requirement
MB_myVaelastraszPaladinHealing = true  -- T1 requirement  
MB_myVaelastraszPriestHealing = true   -- Renew/Shield MT
MB_myVaelastraszDruidHealing = true

-- Healer Assignments (dedicated MT healers/HoTs)
MB_myVaelastraszShamans = {
    "Shaitan", "Bayo", "Lillifee"
}

MB_myVaelastraszPaladins = {
    "Fatnun", "Breachedhull", "Fatnun"
}

MB_myVaelastraszPriests = {
    "Healdealz", "Corinn", "Midavellir"
}

MB_myVaelastraszDruids = {
    "Smalheal", "Pyqmi", "Maxvoldson"
}

--[[
    Vaelastrasz Tactics:
    - Dedicated healers maintain HoTs on MT
    - T1 gear requirements for Shamans/Paladins
    - Priests handle Renew and Shield duties
    - High healing throughput required
--]]

--[####################################################################################################]--
--[############################################### ONYXIA'S LAIR ####################################]--
--[####################################################################################################]--

-- Strategy Configuration
MB_myOnyxiaBoxStrategy = true 

-- Tank and Follow Assignments (REQUIRED)
MB_myOnyxiaMainTank = "Moron"
MB_myOnyxiaFollowTarget = "Suecia" -- Follow-back target

--[[
    Onyxia Tactics:
    - Main tank holds Onyxia
    - Follow target for air phase positioning
    - Phase management critical
--]]

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--
