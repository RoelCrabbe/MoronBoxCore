---------------------------------------------- Patchwerk ---------------------------------------------
	-- MB_myPatchwerkBoxStrategyHeal => True or False (Work or Not)

	MB_myPatchwerkBoxStrategy = true

	--------------------------------------- Patchwerk Tactics ----------------------------------------
	-- MB_myThreatPWSoaker, MB_myFirstPWSoaker !! MUST BE ASSIGNED !! Heal dependent
	-- MB_mySecondPWSoaker, MB_myThirdPWSoaker !! MUST BE ASSIGNED !! Heal dependent
	-- Place healers into HealerList and they will heal thier tank
	-- Alliance doesn't need this shit, they have Devine Intervention
	--------------------------------------------------------------------------------------------------

	MB_myThreatPWSoaker = "Moron"
	MB_myThreatPWSoakerHealerList = {
		"Bogeycrap", -- 8T1 Shaman
		"Midavellir", -- Priest
		"Pyqmi" -- Druid
	}

	MB_myFirstPWSoaker = "Rows"
	MB_myFirstPWSoakerHealerList = {
		"Shamuk", -- 6T3+ Shaman for BUFF
		"Draub", -- 8T2 Priest
		"Mvenna", -- 8T1 Shaman
		"Superkoe", -- 8T1 Shammy	
	}
	
	MB_mySecondPWSoaker = "Almisael"
	MB_mySecondPWSoakerHealerList = {
		"Laitelaismo", -- 6T3+ Shaman for BUFF
		"Ayag", -- 8T2 Priest
		"Chimando", -- 8T1 Shaman
		"Smalheal", -- Druid
	}
		
	MB_myThirdPWSoaker = "Ajlano"
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
	-- MB_myMaexxnaMainTank !! MUST BE ASSIGNED !! Will remove certain useless buffs so u stay below
	-- the readable buffcap. Can be removed tbh since healers heal TargetOfTarget
	-- MB_myMaexxnaDruidHealer !! MUST BE ASSIGNED !! Regro, Reju, Abolish
	-- MB_myMaexxnaPriestHealer !! MUST BE ASSIGNED !! Renew
	--------------------------------------------------------------------------------------------------

	MB_myMaexxnaMainTank = {

		-- Horde Team 1
		"Moron",

		-- Horde Team 2
		"Hondtje",

		-- Alliance
		"Klawss"
	}

	MB_myMaexxnaDruidHealer = {
		
		-- Horde Team 1
		"Pyqmi",
		"Smalheal",

		-- Horde Team 2
		"Drshakaloo",
		"Hornanimal",

		-- Alliance
		"Jahetsu",
		"Kusch"
	}

	MB_myMaexxnaPriestHealer = {
		
		-- Horde Team 1
		"Healdealz",

		-- Horde Team 2
		"Schmuk",

		-- Alliance
		"Murdrum"
	}

----------------------------------------------- Maexxna ----------------------------------------------



--------------------------------------------- Grobbulus ----------------------------------------------
	-- MB_myGrobbulusBoxStrategy => True or False (Work or Not)

	MB_myGrobbulusBoxStrategy = true 

	---------------------------------------- Grobbulus Tactics ---------------------------------------
	-- MB_myGrobbulusMainTank !! MUST BE ASSIGNED !! Targets Boss
	-- MB_myGrobbulusSlimeTankOne !! MUST BE ASSIGNED !! Targets Blobs Caster Assist
	-- MB_myGrobbulusSlimeTankTwo !! MUST BE ASSIGNED !! Targets Blobs Caster Assist
	--------------------------------------------------------------------------------------------------

	MB_myGrobbulusFollowTarget = "Ajlano"
	MB_myGrobbulusSecondFollowTarget = "Rows"

	MB_myGrobbulusMainTank = "Moron"
	MB_myGrobbulusSlimeTankOne = "Faceplate"
	MB_myGrobbulusSlimeTankTwo = "Rows"

--------------------------------------------- Grobbulus ----------------------------------------------



----------------------------------------------- Skeram -----------------------------------------------
	-- MB_mySkeramBoxStrategyFollow => True or False (Work or Not)
	-- MB_mySkeramBoxStrategyTotem => True or False (Work or Not), Grounding Totem
	-- MB_mySkeramBoxStrategyWarlock => True or False (Work or Not), Warlock Fear
	
	MB_mySkeramBoxStrategyFollow = true
	MB_mySkeramBoxStrategyTotem = false
	MB_mySkeramBoxStrategyWarlock = false

	------------------------------------------- Skeram Tactics ---------------------------------------
	-- Target Skeram and Press Meleefollow
	-- The LeftOFFTANKS, MiddleDPSERS, RightOFFTANKS will follow thier Tank
	-- Place Tanks on thier platform
	--------------------------------------------------------------------------------------------------

	MB_mySkeramLeftTank = {

		-- Horde
		"Ajlano",

		-- Alliance
		"Gupy"	
	}

	MB_mySkeramLeftOFFTANKS = { -- To Help Marking Boss
		
		-- Horde
		"Tauror",

		-- Alliance
		"Bestguy"		
	}

	MB_mySkeramMiddleTank = {

		-- Horde
		"Moron",

		-- Alliance
		"Deadgods"	
	}

	MB_mySkeramMiddlOFFTANKS = { -- To Help Marking Boss

		-- Horde
		"Almisael",

		-- Alliance
		"Bellamaya"	
	}

	MB_mySkeramMiddleDPSERS = {

		-- Horde DPS
		"Miagi", -- Rogue
		"Levski", -- Rogue
		"Invictivus",
		"Chabalala", -- Warr
		"Angerissues", -- Warr
		"Gogopwranger", -- Warr
		"Tazmahdingo", -- Warr
		"Maximumzug", -- Warr
		"Cornanimal", -- Warr
		"Badhatter", -- Warr
		"Uzug", -- Warr
		"Xoncharr",
		"Dl",

		-- Alliance DPS
		"Spessu", -- Rogue
		"Insanette", -- Warr
		"Starnight", -- Warr
		"Klaidas", -- Warr
		"Croglust", -- Warr
		"Pinkyz", -- Warr
		"Miksmaks", -- Rogue
		"Arkius", -- Warr
		"Arent", -- Warr
		"Uvu", -- Warr
		"Hutao"
	}

	MB_mySkeramRightTank = { 

		-- Horde
		"Rows",

		-- Alliance
		"Drudish"	
	}

	MB_mySkeramRightOFFTANKS = { -- To Help Marking Boss
		
		-- Horde
		"Hondtje",

		-- Alliance
		"Akileys"	
	}

----------------------------------------------- Skeram -----------------------------------------------



---------------------------------------------- Fankriss ----------------------------------------------
	-- MB_fankrissBoxStrategy => True or False (Work or Not)

	MB_myFankrissBoxStrategy = true -- Active or not

	----------------------------------------- Fankriss Tactics ---------------------------------------
	-- MB_myFankrissOFFTANKS !! MUST BE ASSIGNED !! Targets Boss (Taunt is manual)
	-- MB_myFankrissSnakeTankOne !! MUST BE ASSIGNED !! Target Snakes Caster Assist
	-- MB_myFankrissSnakeTankTwo !! MUST BE ASSIGNED !! Target Snakes Caster Assist
	--------------------------------------------------------------------------------------------------
	
	MB_myFankrissOFFTANKS = {

		-- Horde
		"Ajlano",

		-- Alliance
		"Drudish"	
	}

	MB_myFankrissSnakeTankOne = {

		-- Horde
		"Rows",

		-- Alliance
		"Gupy",
	}

	MB_myFankrissSnakeTankTwo = {

		-- Horde
		"Almisael",

		-- Alliance
		"Bellamaya"
	}

---------------------------------------------- Fankriss ----------------------------------------------



---------------------------------------------- Huhuran ----------------------------------------------
	-- MB_myHuhuranBoxStrategy => True or False (Work or Not)

	MB_myHuhuranBoxStrategy = false -- Active or not

	----------------------------------------- Huhuran Tactics ----------------------------------------
	-- MB_myHuhuranMainTank !! MUST BE ASSIGNED !! Buff dependent
	-- MB_myHuhuranFirstDruidHealer !! MUST BE ASSIGNED !! Regro
	-- MB_myHuhuranMainTank uses SW/LS at MB_myHuhuranTankDefensivePrecentage
	--------------------------------------------------------------------------------------------------

	MB_myHuhuranMainTank = "Moron"
	MB_myHuhuranTankDefensivePrecentage = 0.25
	MB_myHuhuranFirstDruidHealer = "Smalheal"

---------------------------------------------- Huhuran ----------------------------------------------



---------------------------------------------- Razorgore ---------------------------------------------
	-- MB_myRazorgoreBoxStrategy => True or False (Work or Not)
	-- MB_myRazorgoreBoxHealerStrategy => True or False (Work or Not), Mana Pots

	MB_myRazorgoreBoxStrategy = true
	MB_myRazorgoreBoxHealerStrategy = false

	--------------------------------------- Razorgore Tactics ----------------------------------------
	-- When MB_myRazorgoreORBtank controls the Orb u can split the raid with melee follow
	-- Further issue here is that 420 used to track the debuff u get when controlling the orb
	-- This worked fine, BUT
	-- The orbchannel is 90s and the debuff lasts for 60s. (90 - 60 = 30) This means that every 60
	-- My dps stopped one 1 side for 30s. Now i fixed this by simpely tracking the mobs you are fighting
	-- BUT U WILL STILL NEED A ORB CONTROLLER ASSIGNED (Just for the setup part, can't see mobs for X secs)
	--------------------------------------------------------------------------------------------------

	MB_myRazorgoreORBtank = {

		-- Horde
		"Tauror",

		-- Alliance
		"Pureblood"
	}

	MB_myRazorgoreLeftTank = { -- Tank Left

		-- Horde
		"Moron",

		-- Alliance
		"Deadgods"
	}
	MB_myRazorgoreLeftDPSERS = {

		-- Horde Offtank
		"Almisael", -- TF Tank

		-- Horde DPS
		"Invivtivus", -- Rogue

		"Angerissues", -- Warr
		"Xoncharr", -- Warr
		"Maximumzug", -- Warr
		"Uzug", -- Warr
		"Axhole", -- Warr
		"Kyrielle", -- Warr

		-- Alliance Offtank
		"Bellamaya", -- No TF

		-- Alliance DPS
		"Spessu", -- Rogue
		"Klaidas", -- Warr
		"Starnight", -- Warr
		"Arent", -- Warr
		"Croglust", -- Warr
		"Akileys", -- Warr
	}
	
	MB_myRazorgoreRightTank = { -- Tank Right

		-- Horde
		"Ajlano",

		-- Alliance
		"Drudish"
	}
	MB_myRazorgoreRightDPSERS = {
		
		-- Horde Offtank
		"Rows", -- TF

		-- Horde DPS
		"Miagi", -- Rogue

		"Chabalala", -- Warr
		"Gogopwranger", -- Warr
		"Tazmahdingo", -- Warr
		"Cornanimal", -- Warr
		"Rapenaattori", -- Warr
		"Goodbeef", -- Warr

		-- Alliance Offtank
		"Gupy", -- No TF

		-- Alliance DPS
		"Pinkyz", -- Rogue
		"Insanette", -- Warr
		"Nyka", -- Warr
		"Miksmaks", -- Warr
		"Arkius", -- Warr
		"Uvu", -- Warr
		"Bestguy" -- Warr
	}

---------------------------------------------- Razorgore ---------------------------------------------



-------------------------------------------- Vaelastrasz ---------------------------------------------
	-- MB_myVaelastraszBoxStrategy => True or False (Work or Not)

	MB_myVaelastraszBoxStrategy = true 

	-------------------------------------- Vaelastrasz Tactics ---------------------------------------
	-- Deticated Healers to heal/hot the MT
	--------------------------------------------------------------------------------------------------

	MB_myVaelastraszShamanHealing = true -- (These need to be T1)
	MB_myVaelastraszShamanOne = "Mvenna"
	MB_myVaelastraszShamanTwo = "Chimando"
	MB_myVaelastraszShamanThree = "Azøg"

	MB_myVaelastraszPaladinHealing = true -- (These need to be T1)
	MB_myVaelastraszPaladinOne = "Fatnun"
	MB_myVaelastraszPaladinTwo = "Breachedhull"
	MB_myVaelastraszPaladinThree = "Fatnun"

	MB_myVaelastraszPriestHealing = true -- (Renew / Shield MT)
	MB_myVaelastraszPriestOne = "Healdealz" -- "Murdrum"
	MB_myVaelastraszPriestTwo = "Corinn" -- "Hms"
	MB_myVaelastraszPriestThree = "Midavellir" -- "Wiccana"

	MB_myVaelastraszDruidHealing = true -- (Regrow / Rejuv MT)
	MB_myVaelastraszDruidOne = "Pyqmi" -- "Jahetsu"
	MB_myVaelastraszDruidTwo = "Smalheal" -- "Kursch"
	MB_myVaelastraszDruidThree = "Osaurus" -- "Droodish"

-------------------------------------------- Vaelastrasz ---------------------------------------------



---------------------------------------------- Ossirian ----------------------------------------------
	-- MB_myOssirianBoxStrategy => True or False (Work or Not)

	MB_myOssirianBoxStrategy = true -- Special totem dropping 

	----------------------------------------- Ossirian Tactics ---------------------------------------
	-- MB_myHuhuranMainTank !! MUST BE ASSIGNED !! Totem dependent
	-- Shield Wall when low HP whe boss is below MB_myOssirianTankDefensivePrecentage
	--------------------------------------------------------------------------------------------------

	MB_myOssirianMainTank = "Moron"
	MB_myOssirianTankDefensivePrecentage = 0.35

---------------------------------------------- Ossirian ----------------------------------------------



---------------------------------------------- Onyxia ----------------------------------------------
	-- MB_myOnyxiaBoxStrategy => True or False (Work or Not)

	MB_myOnyxiaBoxStrategy = true 

	----------------------------------------- Onyxia Tactics ---------------------------------------
	-- MB_myOnyxiaFollowTarget !! MUST BE ASSIGNED !! The followback target
	--------------------------------------------------------------------------------------------------

	MB_myOnyxiaMainTank = "Moron"
	MB_myOnyxiaFollowTarget = "Ajlano"

---------------------------------------------- Onyxia ----------------------------------------------



---------------------------------------------- Razuvious ----------------------------------------------
	-- MB_myRazuviousBoxStrategy => True or False (Work or Not)

	MB_myRazuviousBoxStrategy = true 

	----------------------------------------- Razuvious Tactics ---------------------------------------
	-- MB_myRazuviousPriest !! MUST BE ASSIGNED !! Mindcontrolling
	--------------------------------------------------------------------------------------------------

	MB_myRazuviousPriest = {

		-- Horde Team 1
		"Trumptvänty",
		"Ez",		

		-- Alliance
		"Captivity"	
	}

---------------------------------------------- Razuvious ----------------------------------------------



---------------------------------------------- Faerlina ----------------------------------------------
	-- MB_myFaerlinaBoxStrategy => True or False (Work or Not)
	-- MB_myFaerlinaRuneStrategy => True or False (Work or Not) Frozen Runes

	MB_myFaerlinaBoxStrategy = true 
	MB_myFaerlinaRuneStrategy = false

	----------------------------------------- Faerlina Tactics ---------------------------------------
	-- MB_myFaerlinaPriest !! MUST BE ASSIGNED !! Mindcontrolling
	--------------------------------------------------------------------------------------------------

	MB_myFaerlinaPriest = {
		
		-- Horde Team 1
		"Midavellir",

		-- Horde Team 2
		"Schmuk",

		-- Alliance
		"Captivity"
	}

---------------------------------------------- Faerlina ----------------------------------------------



----------------------------------------------- Twins ------------------------------------------------
	-- MB_myRazuviousBoxStrategy => True or False (Work or Not)

	MB_myTwinsBoxStrategy = true 

	---------------------------------------- Twins Tactics -------------------------------------------
	-- MB_myRazuviousFirstPriest !! MUST BE ASSIGNED !!
	-- MB_myRazuviousSecondPriest
	--------------------------------------------------------------------------------------------------

	MB_myTwinsWarlockTank = {

		-- Horde 1
		"Akaaka",		

		-- Alliance
		"Trachyt"	
	}

----------------------------------------------- Twins ------------------------------------------------

-- Loatheb is verry gay

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