---------------------------------------------- Patchwerk ---------------------------------------------
	-- MB_myPatchwerkBoxStrategyHeal => True or False (Work or Not)

	MB_myPatchwerkBoxStrategy = true

    --------------------------------------- Patchwerk Tactics ----------------------------------------
    -- MB_myThreatPWSoaker, MB_myFirstPWSoaker !! MUST BE ASSIGNED !! Heal dependent
    -- MB_mySecondPWSoaker, MB_myThirdPWSoaker !! MUST BE ASSIGNED !! Heal dependent
    -- Place healers into HealerList and they will heal their tank
    -- Alliance doesn't need this, they have Divine Intervention
    --------------------------------------------------------------------------------------------------

    MB_myThreatPWSoaker = "Moron"
    MB_myThreatPWSoakerHealerList = {
        "Bogeycrap", -- 8T1 Shaman
        "Midavellir", -- Priest
        "Pyqmi" -- Druid
    }

    MB_myFirstPWSoaker = "Suecia"
    MB_myFirstPWSoakerHealerList = {
        "Shamuk", -- 6T3+ Shaman for BUFF
        "Draub", -- 8T2 Priest
        "Mvenna", -- 8T1 Shaman
        "Superkoe", -- 8T1 Shaman	
    }
    
    MB_mySecondPWSoaker = "Ajlano"
    MB_mySecondPWSoakerHealerList = {
        "Laitelaismo", -- 6T3+ Shaman for BUFF
        "Ayag", -- 8T2 Priest
        "Chimando", -- 8T1 Shaman
        "Smalheal", -- Druid
    }
        
    MB_myThirdPWSoaker = "Almisael"
    MB_myThirdPWSoakerHealerList = {
        "Ootskar", -- 6T3+ Shaman for BUFF
        "Healdealz", -- Priest
        "Purges", -- 8T1 Shaman
        "Zwartje"
    }

---------------------------------------------- Patchwerk ---------------------------------------------



----------------------------------------------- Maexxna ----------------------------------------------
    -- MB_myMaexxnaBoxStrategy => True or False (Work or Not)

    MB_myMaexxnaBoxStrategy = true

    ------------------------------------------ Maexxna Tactics ---------------------------------------
    -- MB_myMaexxnaMainTank !! MUST BE ASSIGNED !! Will remove certain useless buffs so you stay below
    -- the readable buff cap. Can be removed to be honest since healers heal TargetOfTarget
    -- MB_myMaexxnaDruidHealer !! MUST BE ASSIGNED !! Regrowth, Rejuvenation, Abolish
    -- MB_myMaexxnaPriestHealer !! MUST BE ASSIGNED !! Renew
    --------------------------------------------------------------------------------------------------

    MB_myMaexxnaMainTank = {
        -- Horde Team 1
        "Moron",

        -- Alliance
        "Alliance Tank 1"
    }

    MB_myMaexxnaDruidHealer = {        
        -- Horde Team 1
        "Smalheal",
        "Pyqmi",

        -- Alliance
        "Alliance Druid 1"
    }

    MB_myMaexxnaPriestHealer = {        
        -- Horde Team 1
        "Midavellir",

        -- Alliance
        "Alliance Priest 1"
    }

----------------------------------------------- Maexxna ----------------------------------------------



--------------------------------------------- Grobbulus ----------------------------------------------
    -- MB_myGrobbulusBoxStrategy => True or False (Work or Not)

    MB_myGrobbulusBoxStrategy = true 

    ---------------------------------------- Grobbulus Tactics ---------------------------------------
    -- MB_myGrobbulusMainTank !! MUST BE ASSIGNED !! Targets boss
    -- MB_myGrobbulusSlimeTankOne !! MUST BE ASSIGNED !! Targets blobs, caster assist
    -- MB_myGrobbulusSlimeTankTwo !! MUST BE ASSIGNED !! Targets blobs, caster assist
    --------------------------------------------------------------------------------------------------

    MB_myGrobbulusFollowTarget = "Suecia"
    MB_myGrobbulusSecondFollowTarget = "Ajlano"

    MB_myGrobbulusMainTank = "Moron"
    MB_myGrobbulusSlimeTankOne = "Suecia"
    MB_myGrobbulusSlimeTankTwo = "Ajlano"

--------------------------------------------- Grobbulus ----------------------------------------------



----------------------------------------------- Skeram -----------------------------------------------
    -- MB_mySkeramBoxStrategyFollow => True or False (Work or Not)
    -- MB_mySkeramBoxStrategyTotem => True or False (Work or Not), Grounding Totem
    -- MB_mySkeramBoxStrategyWarlock => True or False (Work or Not), Warlock Fear
    
    MB_mySkeramBoxStrategyFollow = true
    MB_mySkeramBoxStrategyTotem = false
    MB_mySkeramBoxStrategyWarlock = false

    ------------------------------------------- Skeram Tactics ---------------------------------------
    -- Target Skeram and press Melee follow
    -- The Left OFFTANKS, Middle DPSERS, Right OFFTANKS will follow their tank
    -- Place tanks on their platform
    --------------------------------------------------------------------------------------------------

    MB_mySkeramLeftTank = {
        -- Horde
        "Suecia",

        -- Alliance
        "Alliance Tank 1"	
    }

    MB_mySkeramLeftOFFTANKS = { -- To help marking boss        
        -- Horde
        "Rows",

        -- Alliance
        "Alliance Offtank 1"		
    }

    MB_mySkeramMiddleTank = {
        -- Horde
        "Moron",

        -- Alliance
        "Alliance Tank 2"	
    }

    MB_mySkeramMiddleOFFTANKS = { -- To help marking boss
        -- Horde
        "Almisael",

        -- Alliance
        "Alliance Offtank 2"	
    }

    MB_mySkeramMiddleDPSERS = {
        -- Horde DPS
        "Moonspawn",
        "Likez",
        "Angerissues",
        "Tazmahdingo",
        "Gogopwranger",
        "Chabalala",
        "Weedzy",
        "Miagi",

        -- Alliance DPS
        "Alliance Melee 1"
    }

    MB_mySkeramRightTank = { 
        -- Horde
        "Ajlano",

        -- Alliance
        "Alliance Tank 3"	
    }

    MB_mySkeramRightOFFTANKS = { -- To help marking boss        
        -- Horde
        "Sabo",

        -- Alliance
        "Alliance Offtank 3"	
    }

----------------------------------------------- Skeram -----------------------------------------------



---------------------------------------------- Fankriss ----------------------------------------------
    -- MB_myFankrissBoxStrategy => True or False (Work or Not)

    MB_myFankrissBoxStrategy = true -- Active or not

    ----------------------------------------- Fankriss Tactics ---------------------------------------
    -- MB_myFankrissOFFTANKS !! MUST BE ASSIGNED !! Targets boss (Taunt is manual)
    -- MB_myFankrissSnakeTankOne !! MUST BE ASSIGNED !! Targets snakes, caster assist
    -- MB_myFankrissSnakeTankTwo !! MUST BE ASSIGNED !! Targets snakes, caster assist
    --------------------------------------------------------------------------------------------------
    
    MB_myFankrissOFFTANKS = {
        -- Horde
        "Suecia",

        -- Alliance
        "Alliance Offtank 1"	
    }

    MB_myFankrissSnakeTankOne = {
        -- Horde
        "Ajlano",

        -- Alliance
        "Alliance Snake Tank 1"
    }

    MB_myFankrissSnakeTankTwo = {
        -- Horde
        "Almisael",

        -- Alliance
        "Alliance Snake Tank 2"
    }

---------------------------------------------- Fankriss ----------------------------------------------



---------------------------------------------- Huhuran ----------------------------------------------
    -- MB_myHuhuranBoxStrategy => True or False (Work or Not)

    MB_myHuhuranBoxStrategy = false -- Active or not

    ----------------------------------------- Huhuran Tactics ----------------------------------------
    -- MB_myHuhuranMainTank !! MUST BE ASSIGNED !! Buff dependent
    -- MB_myHuhuranFirstDruidHealer !! MUST BE ASSIGNED !! Regrowth
    -- MB_myHuhuranMainTank uses SW/LS at MB_myHuhuranTankDefensivePercentage
    --------------------------------------------------------------------------------------------------

    MB_myHuhuranMainTank = "Moron"
    MB_myHuhuranTankDefensivePercentage = 0.25
    MB_myHuhuranFirstDruidHealer = "Smalheal"

---------------------------------------------- Huhuran ----------------------------------------------



---------------------------------------------- Razorgore ---------------------------------------------
    -- MB_myRazorgoreBoxStrategy => True or False (Work or Not)
    -- MB_myRazorgoreBoxHealerStrategy => True or False (Work or Not), Mana Pots

    MB_myRazorgoreBoxStrategy = true
    MB_myRazorgoreBoxHealerStrategy = false

    --------------------------------------- Razorgore Tactics ----------------------------------------
    -- When MB_myRazorgoreORBtank controls the Orb you can split the raid with melee follow
    -- Further issue here is that 420 used to track the debuff you get when controlling the orb
    -- This worked fine, BUT
    -- The orb channel is 90s and the debuff lasts for 60s. (90 - 60 = 30) This means that every 60s
    -- My DPS stopped on one side for 30s. Now I fixed this by simply tracking the mobs you are fighting
    -- BUT YOU WILL STILL NEED AN ORB CONTROLLER ASSIGNED (Just for the setup part, can't see mobs for X secs)
    --------------------------------------------------------------------------------------------------

    MB_myRazorgoreORBtank = {
        -- Horde
        "Rows",

        -- Alliance
        "Alliance Orb Tank 1"
    }

    MB_myRazorgoreLeftTank = { -- Tank Left
        -- Horde
        "Moron",

        -- Alliance
        "Alliance Tank 1"
    }
    MB_myRazorgoreLeftDPSERS = {
        -- Horde Offtank
        "Almisael", -- TF Tank

        -- Horde DPS
        "Invictivus", -- Rogue

        "Angerissues", -- Warr
        "Xoncharr", -- Warr
        "Maximumzug", -- Warr
        "Uzug", -- Warr
        "Axhole", -- Warr
        "Kyrielle", -- Warr
    }
    
    MB_myRazorgoreRightTank = { -- Tank Right
        -- Horde
        "Suecia",

        -- Alliance
        "Alliance Tank 2"
    }
    MB_myRazorgoreRightDPSERS = {        
        -- Horde Offtank
        "Ajlano", -- TF

        -- Horde DPS
        "Miagi", -- Rogue

        "Chabalala", -- Warr
        "Gogopwranger", -- Warr
        "Tazmahdingo", -- Warr
        "Cornanimal", -- Warr
        "Rapenaattori", -- Warr
        "Goodbeef", -- Warr
    }

---------------------------------------------- Razorgore ---------------------------------------------



-------------------------------------------- Vaelastrasz ---------------------------------------------
    -- MB_myVaelastraszBoxStrategy => True or False (Work or Not)

    MB_myVaelastraszBoxStrategy = true 

    -------------------------------------- Vaelastrasz Tactics ---------------------------------------
    -- Dedicated healers to heal/HoT the MT
    --------------------------------------------------------------------------------------------------

    MB_myVaelastraszShamanHealing = true -- (These need to be T1)
    MB_myVaelastraszShamans = {
        "Shaitan",
        "Bayo",
        "Lillifee"
    }

    MB_myVaelastraszPaladinHealing = true -- (These need to be T1)
    MB_myVaelastraszPaladins = {
        "Fatnun",
        "Breachedhull",
        "Fatnun"
    }

    MB_myVaelastraszPriestHealing = true -- (Renew / Shield MT)
    MB_myVaelastraszPriests = {
        "Healdealz",
        "Corinn",
        "Midavellir",
    }

    MB_myVaelastraszDruidHealing = true
    MB_myVaelastraszDruids = {
        "Smalheal",
        "Pyqmi",
        "Maxvoldson",
    }

-------------------------------------------- Vaelastrasz ---------------------------------------------



---------------------------------------------- Ossirian ----------------------------------------------
    -- MB_myOssirianBoxStrategy => True or False (Work or Not)

    MB_myOssirianBoxStrategy = true -- Special totem dropping 

    ----------------------------------------- Ossirian Tactics ---------------------------------------
    -- MB_myOssirianMainTank !! MUST BE ASSIGNED !! Totem dependent
    -- Shield Wall when low HP when boss is below MB_myOssirianTankDefensivePercentage
    --------------------------------------------------------------------------------------------------

    MB_myOssirianMainTank = "Moron"
    MB_myOssirianTankDefensivePercentage = 0.35

---------------------------------------------- Ossirian ----------------------------------------------


---------------------------------------------- Onyxia ----------------------------------------------
    -- MB_myOnyxiaBoxStrategy => True or False (Work or Not)

    MB_myOnyxiaBoxStrategy = true 

    ----------------------------------------- Onyxia Tactics ---------------------------------------
    -- MB_myOnyxiaFollowTarget !! MUST BE ASSIGNED !! The follow-back target
    --------------------------------------------------------------------------------------------------

    MB_myOnyxiaMainTank = "Moron"
    MB_myOnyxiaFollowTarget = "Ajlano"

---------------------------------------------- Onyxia ----------------------------------------------



---------------------------------------------- Razuvious ----------------------------------------------
    -- MB_myRazuviousBoxStrategy => True or False (Work or Not)

    MB_myRazuviousBoxStrategy = true 

    ----------------------------------------- Razuvious Tactics ---------------------------------------
    -- MB_myRazuviousPriest !! MUST BE ASSIGNED !! Mind controlling
    --------------------------------------------------------------------------------------------------

    MB_myRazuviousPriest = {
        -- Horde Team 1
        "Trumptvänty",
        "Ez",		

        -- Alliance
        "Alliance Priest 1"	
    }

---------------------------------------------- Razuvious ----------------------------------------------



---------------------------------------------- Faerlina ----------------------------------------------
    -- MB_myFaerlinaBoxStrategy => True or False (Work or Not)
    -- MB_myFaerlinaRuneStrategy => True or False (Work or Not) Frozen Runes

    MB_myFaerlinaBoxStrategy = true 
    MB_myFaerlinaRuneStrategy = false

    ----------------------------------------- Faerlina Tactics ---------------------------------------
    -- MB_myFaerlinaPriest !! MUST BE ASSIGNED !! Mind controlling
    --------------------------------------------------------------------------------------------------

    MB_myFaerlinaPriest = {		
        -- Horde Team 1
        "Midavellir",

        -- Alliance
        "Alliance Priest 1"
    }

---------------------------------------------- Faerlina ----------------------------------------------



----------------------------------------------- Twins ------------------------------------------------
    -- MB_myTwinsBoxStrategy => True or False (Work or Not)

    MB_myTwinsBoxStrategy = true 

    ---------------------------------------- Twins Tactics -------------------------------------------
    -- MB_myTwinsFirstPriest !! MUST BE ASSIGNED !!
    -- MB_myTwinsSecondPriest
    --------------------------------------------------------------------------------------------------

    MB_myTwinsWarlockTank = {
        -- Horde 1
        "Akaaka",		

		-- Alliance
        "Alliance Warlock 1"	
    }

----------------------------------------------- Twins ------------------------------------------------



---------------------------------------------- Loatheb ----------------------------------------------
    -- MB_myLoathebBoxStrategy => True or False (Work or Not)

    MB_myLoathebBoxStrategy = true

    ----------------------------------------- Loatheb Tactics ----------------------------------------
    -- MB_myLoathebMainTank !! MUST BE ASSIGNED !!
    -- MB_myLoathebSealPaladin !! MUST BE ASSIGNED !! (Seal of Light/Seal of Wisdom)
    -- MB_myLoathebHealer !! MUST BE ASSIGNED !! List of healers
    -- MB_myLoathebHealSpell !! MUST BE ASSIGNED !! Healing spell per class
    -- MB_myLoathebHealSpellRank !! MUST BE ASSIGNED !! Spell rank per class
    --------------------------------------------------------------------------------------------------

    MB_myLoathebMainTank = "Klawss"
    MB_myLoathebSealPaladin = "Bubblebumm"

    MB_myLoathebHealer = {
        -- Priests
        "Wiccana",
        "Nouveele",
        "Luxic",
        "Hms",
        "Murdrum",
        --"Joulupukki",
        "Captivity",

        -- Paladins
        "Bubblebumm",
        "Breachedhull",
        "Fatnun",
        "Candylane",
        "Adobe",

        -- Druids
        "Jahetsu",
        "Kusch",
        "Droodish"
    }

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

---------------------------------------------- Loatheb ----------------------------------------------