------------------------------------------------------------------------------------------------------
----------------------------------------------- Healing ----------------------------------------------
------------------------------------------------------------------------------------------------------

-- Switch the values below if you want to increase/decrease when Priests/Druids casts HOTS and Shields.
MB_priestRenewLowRandomPercentage = 0.66 -- Renew randoms if they are below 66% health.
MB_priestRenewLowRandomRank = "Rank 4" -- Rank for all priests to use on random.

MB_priestRenewAggroedPlayerPercentage = 0.90 -- Renew person with aggro and below 90% health.
MB_priestRenewAggroedPlayerRank = "Rank 7" -- Rank for all priests to use on person with aggro.

MB_priestShieldLowRandomPercentage = 0.33 -- Shield randoms if they are below 33% health.
MB_priestShieldAggroedPlayerPercentage = 0.25 -- Shield person with aggro and below 25% health.

MB_druidRejuvenationLowRandomMovingPercentage = 0.75 -- Rejuvenate randoms if they are below 75% health.
MB_druidRejuvenationLowRandomMovingRank = "Rank 3" -- Rank for all druids to use on random when moving.

MB_druidRejuvenationLowRandomPercentage = 0.45 -- Rejuvenate randoms if they are below 45% health.
MB_druidRejuvenationLowRandomRank = "Rank 5" -- Rank for all druids to use on random.

MB_druidRejuvenationAggroedPlayerPercentage = 0.9 -- Rejuvenates person with aggro and below 80% health.
MB_druidRejuvenationAggroedPlayerRank = "Rank 9" -- Rank for all druids to use on person with aggro.

MB_paladinDivineFavorPercentage = 0.8 -- Paladin when below 90% mana will selfbuff Divine Favor
MB_priestInnerFocusPercentage = 0.3 -- Priest when below 30% mana will selfbuff Inner Focus

-- Swiftmend specced Druids settings:
MB_druidSwiftmendRejuvenationLowRandomPercentage = 0.7 -- Swiftmend specced druid rejuvenates raid much more.
MB_druidSwiftmendRejuvenationLowRandomRank = "Rank 6" -- Rank for swiftmend druids rejuvenation on low random.

MB_druidSwiftmendAtPercentage = 0.7 -- Percentage of when to blast Swiftmend.
MB_druidSwiftmendRegrowthLowRandomPercentage = 0.2 -- Casts highest rank of regrowth if player is below 20% health and the druid has 4 or more talents in improved regrowth.

MB_druidSwiftmendRegrowthAggroedPlayerPercentage = 0.75 -- Regrowth person with aggro and below 27% health.
MB_druidSwiftmendRegrowthAggroedPlayerRank = "Rank 4" -- Rank for swiftmend druids regrowth on person with aggro.

MB_lowestSpellDmgFromGearToScorchToKeepIgnitesUp = 565 -- MAGES WILL NOT DO ANY FUCKING IGNITE SHIT IF THEY ARE BELOW THIS SPELLPOWER

----------------------------------------------- Healing ----------------------------------------------

	MB_myInnervateHealerList = { -- Innervate
		"Draub",
		"Ayag",
		"Healdealz",
		"Corinn",
		"Midavellir",
		"Ez",

		"Murdrum",
		"Wiccana",
		"Hms",
		"Nouveele",
		"Luxic"
	}

	MB_myFlashHealerList = { -- Flashhealers default list
		"Draub",
		-- "Ayag",
		-- "Corinn",
		-- "Healdealz",
		"Midavellir",
		-- "Ez",

		-- "Murdrum",
		-- "Wiccana",
		-- "Hms",
		-- "Nouveele",
		-- "Luxic"
	}
	
	----------------------------------------- Healing Idea's -----------------------------------------
	-- MainTankHealingTables are for what bossfight the healers will ONLY heal the maintank with precasting.
	-- MB_instructorRazuviousAddHealer => Healers who heal adds
	--------------------------------------------------------------------------------------------------

	MB_myInstructorRazuviousAddHealer = {

		-- Horde
		"Mvenna", -- 8T1 Shammy
		"Azøg", -- 8T1 Shammy 
		"Chimando", -- 8T1 Shammy
		--"Purges", -- 8T1 Shammy
		"Superkoe", -- 8T1 Shammy
		"Bogeycrap", -- 8T1 Shammy

		"Laitelaismo", -- 8T3 Shammy
		"Shamuk", -- 8T3 Shammy

		"Corinn", -- 8T2 Priest
		"Healdealz", -- 8T2 Priest
		"Draub", -- 8T2 Priest
		"Ayag", -- T3 Priest

		"Smalheal", -- Druid
		"Drushgor", -- Druid

		-- Alliance
		"Bubblebumm", -- Pala never oom
		"Breachedhull", -- Pala never oom
		"Candylane", -- Pala never oom
		"Fatnun", -- Pala never oom

		"Murdrum", -- 8T3 Priest
		"Wiccana", -- 8T2 Priest
		"Nouveele", -- 8T2 Priest
		"Hms", -- 8T2 Priest

		"Jahetsu", -- Druid
		"Kusch" -- Druid
	}

	MB_myMainTankOverhealingPrecentage = 0.89 --> 15% overheal

	MB_myDruidMainTankHealingRank = "Rank 7" -- Healing Touch
	MB_myDruidMainTankHealingBossList = {

		-- Default bosses
		"Ossirian the Unscarred",
		"Patchwerk",

		-- Extra bosses
			-- MC
			"Magmadar",
			"Ragnaros",

			-- Naxx
			"Maexxna",
			"Gluth",
			"Heigan the Unclean",
			"Grobbulus",

			-- AQ40
			"Princess Huhuran",
			"Fankriss the Unyielding",

			-- BWL
			"Chromaggus",
			"Firemaw"
	}
	
	MB_myPriestMainTankHealingRank = "Rank 1" -- Greater Heal
	MB_myPriestMainTankHealingBossList = {

		-- Default bosses
		"Ossirian the Unscarred",
		"Patchwerk",

		-- Extra bosses
			-- Naxx
			"Gluth",
	}
	
	MB_myShamanMainTankHealingRank = "Rank 7" -- Healing Wave
	MB_myShamanMainTankHealingBossList = {

		-- Default bosses
		"Ossirian the Unscarred",
		"Patchwerk",

		-- Extra bosses
			-- Raidheal other bosses
	}
	
	MB_myPaladinMainTankHealingRank = "Rank 6" -- Flash of Light
	MB_myPaladinMainTankHealingBossList = {
		-- Default bosses
		"Ossirian the Unscarred",
		"Patchwerk",

		-- Extra bosses
			-- Naxx
			"Maexxna",
			"Gluth",
	}

----------------------------------------------- Healing ----------------------------------------------

function mb_changeHots(value) -- Change hots if needed
	
	local myClass = UnitClass("player")

	if value == "HIGH" then
		
		MB_priestRenewLowRandomPercentage = 0.66
		MB_priestRenewLowRandomRank = "Rank 10"

		MB_priestRenewAggroedPlayerPercentage = 0.90
		MB_priestRenewAggroedPlayerRank = "Rank 10"

		MB_priestShieldLowRandomPercentage = 0.45
		MB_priestShieldAggroedPlayerPercentage = 0.25

		MB_druidRejuvenationLowRandomPercentage = 0.66
		MB_druidRejuvenationLowRandomRank = "Rank 11"

		MB_druidRejuvenationAggroedPlayerPercentage = 0.9
		MB_druidRejuvenationAggroedPlayerRank = "Rank 11"

		MB_paladinDivineFavorPercentage = 0.9
		MB_priestInnerFocusPercentage = 0.66

		-- Swiftmend specced Druids settings:
		MB_druidSwiftmendRejuvenationLowRandomPercentage = 0.75
		MB_druidSwiftmendRejuvenationLowRandomRank = "Rank 11"

		MB_druidSwiftmendAtPercentage = 0.5
		MB_druidSwiftmendRegrowthLowRandomPercentage = 0.3

		MB_druidSwiftmendRegrowthAggroedPlayerPercentage = 0.90
		MB_druidSwiftmendRegrowthAggroedPlayerRank = "Rank 9"

		if (myClass == "Druid" or myClass == "Priest" or mb_iamFocus()) then 
			Print("Hots changed to: "..value)
		end
		
	elseif value == "MEDIUM" then
		
		MB_priestRenewLowRandomPercentage = 0.66
		MB_priestRenewLowRandomRank = "Rank 4"
		
		MB_priestRenewAggroedPlayerPercentage = 0.90
		MB_priestRenewAggroedPlayerRank = "Rank 7"
		
		MB_priestShieldLowRandomPercentage = 0.33
		MB_priestShieldAggroedPlayerPercentage = 0.25
		
		MB_druidRejuvenationLowRandomPercentage = 0.45
		MB_druidRejuvenationLowRandomRank = "Rank 5"
		
		MB_druidRejuvenationAggroedPlayerPercentage = 0.9
		MB_druidRejuvenationAggroedPlayerRank = "Rank 9"
		
		MB_paladinDivineFavorPercentage = 0.8
		MB_priestInnerFocusPercentage = 0.4

		-- Swiftmend specced Druids settings:
		MB_druidSwiftmendRejuvenationLowRandomPercentage = 0.7
		MB_druidSwiftmendRejuvenationLowRandomRank = "Rank 6"
		
		MB_druidSwiftmendAtPercentage = 0.45
		MB_druidSwiftmendRegrowthLowRandomPercentage = 0.2
		
		MB_druidSwiftmendRegrowthAggroedPlayerPercentage = 0.75
		MB_druidSwiftmendRegrowthAggroedPlayerRank = "Rank 4"

		if (myClass == "Druid" or myClass == "Priest" or mb_iamFocus()) then 
			Print("Hots changed to: "..value)
		end

	elseif value == "LOW" then
		
		MB_priestRenewLowRandomPercentage = 0.33
		MB_priestRenewLowRandomRank = "Rank 3"

		MB_priestRenewAggroedPlayerPercentage = 0.75
		MB_priestRenewAggroedPlayerRank = "Rank 6"

		MB_priestShieldLowRandomPercentage = 0.2
		MB_priestShieldAggroedPlayerPercentage = 0.25

		MB_druidRejuvenationLowRandomPercentage = 0.33
		MB_druidRejuvenationLowRandomRank = "Rank 3"

		MB_druidRejuvenationAggroedPlayerPercentage = 0.75
		MB_druidRejuvenationAggroedPlayerRank = "Rank 6"

		MB_paladinDivineFavorPercentage = 0.8
		MB_priestInnerFocusPercentage = 0.3

		-- Swiftmend specced Druids settings:
		MB_druidSwiftmendRejuvenationLowRandomPercentage = 0.4
		MB_druidSwiftmendRejuvenationLowRandomRank = "Rank 4"

		MB_druidSwiftmendAtPercentage = 0.33
		MB_druidSwiftmendRegrowthLowRandomPercentage = 0.2

		MB_druidSwiftmendRegrowthAggroedPlayerPercentage = 0.75
		MB_druidSwiftmendRegrowthAggroedPlayerRank = "Rank 4"

		if (myClass == "Druid" or myClass == "Priest" or mb_iamFocus()) then 
			Print("Hots changed to: "..value)
		end
		
	elseif value == "OFF" then
		
		MB_priestRenewLowRandomPercentage = 0.01
		MB_priestRenewLowRandomRank = "Rank 4"

		MB_priestRenewAggroedPlayerPercentage = 0.01
		MB_priestRenewAggroedPlayerRank = "Rank 7"

		MB_priestShieldLowRandomPercentage = 0.01
		MB_priestShieldAggroedPlayerPercentage = 0.01

		MB_druidRejuvenationLowRandomPercentage = 0.01
		MB_druidRejuvenationLowRandomRank = "Rank 5"

		MB_druidRejuvenationAggroedPlayerPercentage = 0.01
		MB_druidRejuvenationAggroedPlayerRank = "Rank 9"

		MB_paladinDivineFavorPercentage = 0.8
		MB_priestInnerFocusPercentage = 0.3

		-- Swiftmend specced Druids settings:
		MB_druidSwiftmendRejuvenationLowRandomPercentage = 0.01
		MB_druidSwiftmendRejuvenationLowRandomRank = "Rank 6"

		MB_druidSwiftmendAtPercentage = 0.01
		MB_druidSwiftmendRegrowthLowRandomPercentage = 0.01

		MB_druidSwiftmendRegrowthAggroedPlayerPercentage = 0.01
		MB_druidSwiftmendRegrowthAggroedPlayerRank = "Rank 4"

		if (myClass == "Druid" or myClass == "Priest" or mb_iamFocus()) then 
			Print("Hots changed to: "..value)
		end
	end
end