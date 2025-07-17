------------------------------------------------------------------------------------------------------
----------------------------------------------- Config! ----------------------------------------------
------------------------------------------------------------------------------------------------------

MB_raidinviter = "Moron" -- Handling Raidinvites

MB_raidAssist = { -- Raid tools
	AutoTurnToTarget = false, -- AutoTurning to raidLeader, copied from 5MMB (Never used lol but tought it was cool)
	Frameflash = true, -- Change this to nil if you do not want the frames to flash when you are out of range etc.
	Use40yardHealingRangeOnInstants = false, -- Can cause massive lag and freezing if activated and raid is low on health. if nil = 28 yards, if true = 40 yards.
	FollowTheLeaderTaxi = true, --Change this to nil if you do not want slaves to automatically fly where mb_raidleader flies!

	AutoEquipSet = { -- Auto Equip Set on login
		Active = true, -- True or false, work or not
		Set = "NRML" -- Your normal set name
	},

	GTFO = { -- If you get baron bomb, Vaelastraz bomb you follow this person.
		Active = true, -- True or false, work or not

		-- Encounter, follower
		Baron = { -- Baron bom
			"Rows", -- Horde
			"Bellamaya" -- Alliance
		},
		Vaelastrasz = { -- Vaelastraz
			"Tauror", -- Horde
			"Bellamaya" -- Alliance
		},
		Grobbulus = { -- Grobbulus
			"Bloodbatz", -- Horde
			"Murdrum", -- Alliance
		},
		Onyxia = { -- Ony Phase 2 (Toon that gets fireballed moves out to reduce dmg)
			"Suecia", -- Horde
			"Carden" -- Alliance
		}
	},

	Shaman = { -- Shamans options
		DefaultToHealingWave = true, -- If you don't have a given setpart will default to heal wave
		NSLowHealthAggroedPlayers = true, -- Change to nil if you experience lag

		-- Will use Chain Heals in certain encounters wheb RaidHP is between High and Low %
		AdjustiveChainHeals = { 
			Active = true, -- true or false

			Razorgore = true,
			FaerlinaTrash = true,
			SuppressionRoom = true,
			Normal = true	
		},
	},

	Warlock = { -- Warlock options
		ShouldBeWhores = false, -- Change this to true if you want warlocks to use shadowburn on targets with 5x shadoweaving and improved shadowbolt on target.
		FarmSoulStones = false -- On HealAndTank, warlocks will Drain Soul
	},

	Rogue = { -- Rogue options
		SaveEnergyForInterrupt = false, -- Will not use attacks if below 65energy, to always be ready with kick on GCD.
	},

	Paladin = {
		HolyShockLowHealthAggroedPlayers = true -- Change to nil if you experience lag
	},

	Druid = {
		BuffTanksWithThorns = false, -- No more buffing with Thorns
		PrioritizePriestsAtieshBuff = true -- My raid has 1 priest, 1 druid in a grp with Atiesh. Turned on this will not re-equip druid atiesh so priest can have his
	},

	Priest = {
		PowerInfusionList = { -- People in this list can get Power Infusion (Random).
			-- Horde
			"Thehatter",
			"Trinali",
			"Akaaka",
			"Ayaag",

			-- Alliance
			"Salka",
			"Bluedabadee",
			"Trachyt"
		}
	},

	Warrior = { -- Warriors only, only for Annihilator
		Active = true, -- True or false, work or not
				
		AnnihilatorWeavers = { -- Everyone that does Anni in here + Fix weapons database (WarriorData.lua)
			-- Horde
			--"Tazmahdingo",
			"Dl",

			"Ajlano", -- Tank
			"Rows", -- Tank
			"Almisael", -- Tank
			"Tauror", -- Tank

			-- Alliance
			"Hutao",
			"Uvu",
			"Drudish" -- Tank
		}
	},

	Mage = {

		StarterIgniteTick = 500, -- Represents the threshold tick value for the Ignite debuff
		AllowIgniteToDropWhenBadTick = false, -- Indicates whether Ignite should be allowed to drop when its tick value is below the specified threshold
		SpellToKeepIgniteUp = "Scorch", -- Specifies the spell that should be cast to keep the Ignite debuff up
		AllowInstantCast = true, -- Indicates whether instant cast spells should be allowed		
		
		--[[
			When running multiple DIFFERENT SPECC mages in 1 teams following problems occurred :
			You're Frost / Arcane mages have more mana then you're Fire mages.
			This caused my firemages to do nothing

			Why? My firemages wait for 5 stacks of scorch before fireballing.
			How it used to be is that the 5 BIGGEST mages (The 5 mages with highest mana) cast scorch first.
			With the extra arcane mages I run those 5 will be frost and therefore scorch will never be up.

			This is why there are 2 tables FireMages and FrostMages
			You will need to fill those in For Firemages, frost currently has no usage yet but is there for show :-). (Solution to running multiplemages)

			(Also tried my best at controlling ignite, but lol u can't :D)
		]]

		FireMages = {

			-- Horde Main Team --
			"Thehatter", -- 41.8
			"Trinali", -- 38.3
			"Rotonic", -- 38.3
			"Schoffie", -- 37.9
			"Excold", -- 36.9
			"Mizea", -- 35.9

			-- Horde Extra --
			"Wizea",
			"Mivea",

			"Ytru",
			"Zadazdaa",

			-- Alliance Main Team --
			"Salka",
			"Pienipyöreä",
			"Bluedabadee", -- 27.9
			"Seamount"
		},

		FrostMages = {

			-- Horde Main Team --
			"Oponn", -- 30.7
			"Naturka",
			"Kl",
			"Caribbean",

			-- Horde Extra --
			"Goodfella",
			"Hjälp",

			-- Horde Shatter --
			"Mmhm",
			"Mycah",

			-- Alliance Main Team --
			"Lilfker",
			"Drplum",
			"Drgrean",
			"Drzoidburg",
			"Drfarnsworth"
		}
	},

	Debugger = { -- Tells me some stuff on X and Y encounters
		Active = true, -- True or false, work or not

		-- Class, Name
		Warrior = "Angerissues",
		Mage = "Thehatter", 
		Priest = "Midavellir", 
		Druid = "Smalheal", 
		Warlock = "Akaaka",
		Rogue = "Miagi",
		Shaman = "Mvenna",
		Razorgore = "Akaaka"
	},

	PotionTraders = { -- When ur buffingand ctrlkeydown, these toons will collect those pots
		Active = true, -- Working or not
		MajorMana = "Smalheal", -- The toon that will be giving out mana pots to all healers that need it
	}
}

MB_sortingBags = { -- Auto sorts bags and Bank, if enabled
	Active = true, 
	Bank = false 
}

-- https://guybrushgit.github.io/WarriorSim/

MB_tanklist = {}

MB_tanklist = { -- Fill your tanks in this list for a login tanklist

	-- Horde
	"Moron",
	"Suecia",
	"Ajlano",
	"Rows",
	"Almisael",
	"Tauror",
	"Hondtje",

	-- Alliance
	"Deadgods",
	"Drudish",
	"Gupy",
	"Bellamaya"
}

MB_extraTanks = { --> These tanks will be added inside the no 'taunt off' list
	"Deathknight Understudy",
	"Bendorama",
	"Empada",
	"Underkraftet",
	"Carden",
	"Goldgoldgold",
	"Faceplate",
	"Moronbox",
	"Klawss"
}

function mb_tankList(encounter) --> DO NOT PUT OTHER / GUEST TANKS ON HERE, ADD THEM in MB_extraTanks!!

	-- /tanklist <encouter> will trigger this function and run a preset list
	if not encounter or encounter == "" then Print("Usage /tanklist < encounter >.") return end

	MB_tanklist = {}

	if UnitFactionGroup("player") == "Horde" then

		if encounter == "NRML" then 		

			MB_tanklist = {
				"Suecia",
				"Ajlano",
				"Rows",
				"Almisael",
				"Tauror",
				"Hondtje",
			}

		elseif encounter == "NAXX" then 

			MB_tanklist = {
				"Suecia",
				"Ajlano",
				"Rows",
				"Almisael",
				"Tauror",

				"Goodbeef",
				"Axhole"
			}

		elseif encounter == "HEIGAN" then

			MB_tanklist = {
				"Suecia",
				"Ajlano",
				"Rows",
				"Almisael",
				"Tauror",
			}

		else

			encounter = "DEFAULT"

			MB_tanklist = {
				"Suecia",
				"Ajlano",
				"Rows",
				"Almisael",
				"Tauror",
				"Hondtje",
			}
		end

	elseif UnitFactionGroup("player") == "Alliance" then

		if encounter == "NRML" then 		

			MB_tanklist = {
				"Deadgods",
				"Drudish",
				"Gupy",
				"Bellamaya",
			}

		elseif encounter == "NAXX" then 

			MB_tanklist = {
				"Deadgods",
				"Drudish",
				"Gupy",
				"Bellamaya",

				"Akileys",
				"Bestguy"
			}

		elseif encounter == "HEIGAN" then

			MB_tanklist = {
				"Deadgods",
				"Drudish",
				"Gupy",
				"Bellamaya",
			}

		else

			encounter = "DEFAULT"

			MB_tanklist = {
				"Deadgods",
				"Drudish",
				"Gupy",
				"Bellamaya",
			}
		end
	end

	if IsRaidLeader() then 
		mb_message(encounter.." Tanklist loaded.")
		
		for i,tank in pairs(MB_tanklist) do
			mb_message(GetColors(MB_raidTargetNames[i]).." => "..tank..".")
		end
	end

	mb_initializeClasslists()
end

MB_furysThatCanTank = { -- DPS warriors, with tank set (Make an ItemRack called "TANK" and "DPS" to make it work), also ass this name in Tanklist ofc :V
	-- Horde
	"Goodbeef",
	"Axhole",

	-- Alliance
	"Akileys",
	"Bestguy"
}

--------------------------------------------- End Globals! -------------------------------------------