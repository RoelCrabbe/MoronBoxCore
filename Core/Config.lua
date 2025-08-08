------------------------------------------------------------------------------------------------------
----------------------------------------------- Config! ----------------------------------------------
------------------------------------------------------------------------------------------------------

MB_raidInviter = "Moron" -- Handling Raidinvites
MB_tankList = {}

MB_raidAssist = { -- Raid tools
	AutoTurnToTarget = false, -- Auto-turning to raid leader, copied from 5MMB (Never used, but thought it was cool)
	Frameflash = true, -- Change this to nil if you do not want the frames to flash when you are out of range, etc.
	Use40yardHealingRangeOnInstants = false, -- Can cause massive lag and freezing if activated and raid is low on health. If nil = 28 yards, if true = 40 yards.
	FollowTheLeaderTaxi = true, -- Change this to nil if you do not want followers to automatically fly where the raid leader flies.

	AutoEquipSet = { -- Automatically equips your gear set on login
		Active = true, -- Set to true to enable, false to disable
		Set = "NRML" -- Name of your default gear set
	},

	GTFO = { -- If you get Baron bomb or Vaelastrasz bomb, follow this person.
		Active = true, -- Set to true to enable, false to disable

		-- Encounter, follower
		Baron = { -- Baron bomb
			"Suecia", -- Horde
			"Alliance Soak 1" -- Alliance
		},
		Vaelastrasz = { -- Vaelastrasz
			"Suecia", -- Horde
			"Alliance Soak 1" -- Alliance
		},
		Grobbulus = { -- Grobbulus
			"Bloodbatz", -- Horde
			"Alliance Priest 1", -- Alliance
		},
		Onyxia = { -- Onyxia Phase 2 (Character that gets fireballed moves out to reduce damage)
			"Moron", -- Horde
			"Alliance Soak 1" -- Alliance
		}
	},

	Shaman = { -- Shaman options
		DefaultToHealingWave = true, -- If you don't have a specific set, will default to Healing Wave
		NSLowHealthAggroedPlayers = true, -- Change to nil if you experience lag
	},

	Warlock = { -- Warlock options
		ShouldBeWhores = false, -- Set to true to use Shadowburn on targets with 5x Shadoweaving and Improved Shadowbolt
		FarmSoulStones = false -- On HealAndTank, warlocks will Drain Soul
	},

	Rogue = { -- Rogue options
		SaveEnergyForInterrupt = false, -- Will not use attacks if below 65 energy, to always be ready with Kick on GCD
	},

	Paladin = { -- Paladin options
		HolyShockLowHealthAggroedPlayers = true -- Change to nil if you experience lag
	},

	Druid = { -- Druid options
		BuffTanksWithThorns = false, -- No longer buffs tanks with Thorns
		PrioritizePriestsAtieshBuff = true -- If enabled, prevents druid from re-equipping Atiesh so priest can keep the buff
	},

	Priest = { -- Priest options
		PowerInfusionList = { -- Players in this list can receive Power Infusion (randomly selected)
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

	Warrior = { -- Warrior options, only for Annihilator
		Active = true, -- Set to true to enable, false to disable
		AnnihilatorWeavers = { -- All warriors who use Annihilator (also update weapons database in WarriorData.lua)
			-- Horde
			"Jokamok",

			"Suecia", -- Tank
			"Ajlano", -- Tank
			"Almisael", -- Tank

			-- Alliance
			"Alliance Warrior 1",
		}
	},

	Mage = {
		StarterIgniteTick = 500, -- Represents the threshold tick value for the Ignite debuff
		AllowIgniteToDropWhenBadTick = false, -- Indicates whether Ignite should be allowed to drop when its tick value is below the specified threshold
		SpellToKeepIgniteUp = "Scorch", -- Specifies the spell that should be cast to keep the Ignite debuff up
		AllowInstantCast = true, -- Indicates whether instant cast spells should be allowed		

		--[[
			When running multiple different spec mages in one team, the following problems occurred:
			Your Frost/Arcane mages have more mana than your Fire mages.
			This caused my Fire mages to do nothing.

			Why? My Fire mages wait for 5 stacks of Scorch before casting Fireball.
			How it used to work is that the 5 mages with the highest mana would cast Scorch first.
			With the extra Arcane mages, those 5 will be Frost, and therefore Scorch will never be up.

			This is why there are two tables: FireMages and FrostMages.
			You will need to fill those in for Fire mages; Frost currently has no usage yet but is there for reference.
			(Solution to running multiple mage specs)

			(Also tried my best at controlling Ignite, but you can't really do it
		]]

		FireMages = {
			-- Horde Main Team --
			"Thehatter",
			"Rotonic",
			"Trinali",
			"Schoffie",
			"Mizea",

			-- Alliance Main Team --
			"Alliance Mage 1",
		},

		FrostMages = {
			-- Horde Main Team --
			"Xlimidrizer",
			"Kelseran",
			"Damacon",
			"Salka",
			"Umek",
			"Oxg",

			-- Horde Shatter --
			"Bluedabadee",

			-- Alliance Main Team --
			"Alliance Mage 2",
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

	PotionTraders = { -- When buffing and holding Ctrl, these characters will collect potions
		Active = true, -- Set to true to enable, false to disable
		MajorMana = "Smalheal", -- The character that will distribute mana potions to all healers who need them
	}
}

MB_sortingBags = { -- Automatically sorts bags and bank if enabled
    Active = true, -- Set to true to enable, false to disable
    Bank = false -- Set to true to also sort the bank
}

MB_tankList = { -- Add your tanks to this list for the login tank list
    -- Horde
    "Moron",
    "Suecia",
    "Ajlano",
    "Almisael",
    "Rows", 
	"Sabo",

    -- Alliance
    "Alliance Tank 1"
}

MB_extraTanks = { -- These tanks will be added to the 'no taunt off' list
    "Deathknight Understudy",
    "Extra Tank 1"
}

MB_furysThatCanTank = { -- DPS warriors with a tank set (create ItemRack sets named "TANK" and "DPS" to use this). Also add these names to the tank list.
    -- Horde
    "Crymeariver",
    "Jokamok",

    -- Alliance
    "Alliance Fury 1"
}

function mb_tankList(encounter)
    -- DO NOT PUT OTHER / GUEST TANKS ON HERE, ADD THEM in MB_extraTanks!!
    -- /tanklist <encounter> will trigger this function and run a preset list

    if not encounter or encounter == "" then
        Print("Usage: /tanklist <encounter>")
        return
    end

	local faction = UnitFactionGroup("player")
    local presets = {
		Horde = {
			NRML   = { "Moron", "Suecia", "Ajlano", "Almisael", "Rows", "Sabo" },
			NAXX   = { "Moron", "Suecia", "Ajlano", "Almisael", "Rows", "Sabo", "Crymeariver", "Jokamok" },
			HEIGAN = { "Moron", "Suecia", "Ajlano", "Almisael", "Rows", "Sabo" },
			DEFAULT= { "Moron", "Suecia", "Ajlano", "Almisael", "Rows", "Sabo" }
		},
        Alliance = {
            NRML   = { "Deadgods", "Drudish", "Gupy", "Bellamaya" },
            NAXX   = { "Deadgods", "Drudish", "Gupy", "Bellamaya", "Akileys", "Bestguy" },
            HEIGAN = { "Deadgods", "Drudish", "Gupy", "Bellamaya" },
            DEFAULT= { "Deadgods", "Drudish", "Gupy", "Bellamaya" }
        }
    }

	local tanks = presets[faction] and presets[faction][encounter] or presets[faction] and presets[faction].DEFAULT or {}
    MB_tankList = tanks

    if IsRaidLeader() then
        mb_message(encounter.." Tanklist loaded.")
        for i, tank in ipairs(MB_tankList) do
            mb_message(GetColors(MB_raidTargetNames[i]).." => "..tank..".")
        end
    end

    mb_initializeClasslists()
end

--------------------------------------------- End Globals! -------------------------------------------