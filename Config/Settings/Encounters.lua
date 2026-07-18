-- [[ Boss Encounters ]] --

MoronBox.Encounters = MoronBox.Encounters or {}

--[[
    This file contains all boss encounter strategies and player assignments.

    Configuration Structure:
    - Each boss has strategy toggles (true/false)
    - Player assignments are organized by role
    - Comments explain tactics and requirements
    - Horde/Alliance assignments are clearly separated

    Note: All variables are global and accessible throughout the addon's
--]]

MoronBox.Encounters.EncountersState = {
    -- [[ Naxxramas ]] --
    Patchwerk = {
        Active = true,
        --[[
            Patchwerk Tactics:
            - Alliance doesn't need this setup, they have Divine Intervention
            - Healers will automatically heal their assigned tank
            - All assignments MUST be configured for proper execution
        --]]

        ThreatSoaker = "Moron",
        ThreatSoakerHealerList = {
            "Bogeycrap",  -- 8T1 Shaman
            "Midavellir", -- Priest
            "Pyqmi"       -- Druid
        },
        FirstSoaker = "Suecia",
        FirstSoakerHealerList = {
            "Shamuk",  -- 6T3+ Shaman for BUFF
            "Draub",   -- 8T2 Priest
            "Mvenna",  -- 8T1 Shaman
            "Superkoe" -- 8T1 Shaman
        },
        SecondSoaker = "Ajlano",
        SecondSoakerHealerList = {
            "Laitelaismo", -- 6T3+ Shaman for BUFF
            "Ayag",        -- 8T2 Priest
            "Chimando",    -- 8T1 Shaman
            "Smalheal"     -- Druid
        },
        ThirdSoaker = "Almisael",
        ThirdSoakerHealerList = {
            "Ootskar",   -- 6T3+ Shaman for BUFF
            "Healdealz", -- Priest
            "Purges",    -- 8T1 Shaman
            "Zwartje"    -- 8T1 Shaman
        }
    },
    Maexxna = {
        Active = true,
        --[[
            Maexxna Tactics:
            - Main tank will remove useless buffs to stay below readable buff cap
            - Druid healers: Regrowth, Rejuvenation, Abolish
            - Priest healers: Renew
            - Healers heal TargetOfTarget automatically
        --]]

        DruidHealers = {
            "Smalheal",        -- Horde Team 1
            "Pyqmi",           -- Horde Team 1
            "Alliance Druid 1" -- Alliance
        },
        PriestHealers = {
            "Midavellir",       -- Horde Team 1
            "Alliance Priest 1" -- Alliance
        }
    },
    Razuvious = {
        Active = true,
        --[[
            Razuvious Tactics:
            - Priests mind control the Understudies
            - Requires precise timing and positioning
        --]]

        MindControlPriests = {
            "Moronpriest",      -- Horde Team 1
            "Alliance Priest 1" -- Alliance
        }
    },
    Faerlina = {
        Active = true,
        FirePots = true,
        --[[
            Faerlina Tactics:
            - Priests mind control the Worshippers
            - Optional frozen rune strategy available
        --]]

        MindControlPriests = {
            "Moronpriest",      -- Horde Team 1
            "Alliance Priest 1" -- Alliance
        }
    },
    -- [[ Ahn Qiraji ]] --
    Huhuran = {
        Active = true,
        NaturePots = true,
        --[[
            Huhuran Tactics:
            - Tank uses defensive abilities at 25% health
            - Currently disabled - enable when needed
        --]]

        TankDefensivePercentage = 0.25 -- SW/LS usage threshold
    },
    TwinEmps = {
        Active = true,
        --[[
            Twins Tactics:
            - Warlock tanks one of the twins
            - Requires specific positioning and timing
        --]]

        WarlockTanks = {
            "Akaaka",            -- Horde 1
            "Alliance Warlock 1" -- Alliance
        }
    },
    -- [[ Blackwing Lair ]] --
    Razorgore = {
        Active = true,
        --[[
            Razorgore Tactics:
            - Orb controller manages the mind control (90s channel, 60s debuff)
            - Raid splits left/right with melee follow
            - DPS tracking handles the 30s gap issue
            - Orb controller still needed for initial setup
        --]]

        ORBtank = {
            "Kungen",             -- Horde
            "Alliance Orb Tank 1" -- Alliance
        },
        LeftMainTank = {
            "Moron",          -- Horde
            "Alliance Tank 1" -- Alliance
        },
        LeftSideDPSERS = {
            "Rows",  -- Horde Offtank (TF Tank)
            "Miagi", -- Rogue
            -- Warriors
            "Gogopwranger",
            "Angerissues",
            "Moonspawn",
            "Opticalfiber",
            "Maximumzug",
            "Hornagaur"
        },
        RightMainTank = {
            "Suecia",         -- Horde
            "Alliance Tank 2" -- Alliance
        },
        RightSideDPSERS = {
            "Sabo",   -- Horde Offtank (TF)
            "Weedzy", -- Rogue
            -- Warriors
            "Chabalala",
            "Tazmahdingo",
            "Likez",
            "Anatomic",
            "Vandalus",
            "Xoncharr",
            "Insanette"
        }
    },
    Vaelastrasz = {
        Active = true,
        FirePots = true,
        --[[
            Vaelastrasz Tactics:
            - Dedicated healers maintain HoTs on MT
            - T1 gear requirements for Shamans/Paladins
            - Priests handle Renew and Shield duties
            - High healing throughput required
        --]]

        ShamanHealing = true,
        ShamanHealers = {
            "Shaitan",
            "Bayo",
            "Lillifee"
        },
        PaladinHealing = true,
        PaladinHealers = {
            "Fatnun",
            "Breachedhull",
            "Fatnun"
        },
        PriestHealing = true, -- Renew/Shield MT
        PriestHealers = {
            "Healdealz",
            "Corinn",
            "Midavellir"
        },
        DruidHealing = true,
        DruidHealers = {
            "Smalheal",
            "Pyqmi",
            "Maxvoldson"
        }
    },
    -- [[ Onyxia ]] --
    Onyxia = {
        Active = true,
        --[[
            Onyxia Tactics:
            - Main tank holds Onyxia
            - Follow target for air phase positioning
            - Phase management critical
        --]]

        MainTank = "Moron",
        FollowTarget = "Suecia" -- Follow-back target
    },
    -- [[ Ruins of Ahn Qiraji ]] --
    Ossirian = {
        Active = true,
        --[[
            Ossirian Tactics:
            - Special totem dropping mechanics
            - Tank uses Shield Wall at 35% boss health
            - Weakness rotation management required
        --]]

        MainTank = "Moron",
        TankDefensivePercentage = 0.35 -- Shield Wall threshold
    }
}

function getEncounters()
    return MoronBox.Encounters
end

function getEncountersState()
    return MoronBox.Encounters.EncountersState
end
