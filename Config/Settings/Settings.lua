-- [[ Assist.lua ]] --

--[[
    This file contains the foundational configuration, data tables, and lookup utilities for the addon.

    Structure:
    - Namespace initialization (MoronBox.Config.Tables)
    - API aliasing for performance
    - Global state containers and registry lists
    - Logic definitions for instance detection, faction checks, and targeting
--]]

MoronBox.Settings = MoronBox.Settings or {}

MoronBox.Settings.SettingsState = {
    -- [[ Start Up ]] --
    RAID = "The Solution To Pollution",                     -- Change this to something UNIQUE for you!
    InviteMessage = "Invite please, spot for raid please?", -- Invite message that raidinviter above listens and autoinvites to.
    RaidInviter = "Moron",
    AllianceRaidInviter = "Sceto",

    -- [[ SpeedRun ]] --
    SpeedRunEnabled = true,
    SteroidWorlBuffs = true,

    -- [[ GTFO ]] --
    GTFO = {                  -- If you get Baron bomb or Vaelastrasz bomb, follow this person.
        Active = true,        -- Set to true to enable, false to disable
        -- Encounter, follower
        Baron = {             -- Baron bomb
            "Suecia",         -- Horde
            "Laty"            -- Alliance
        },
        Vaelastrasz = {       -- Vaelastrasz
            "Suecia",         -- Horde
            "Alliance Soak 1" -- Alliance
        },
        Onyxia = {            -- Onyxia Phase 2 (Character that gets fireballed moves out to reduce damage)
            "Moron",          -- Horde
            "Alliance Soak 1" -- Alliance
        }
    },

    -- [[ Warrior ]] --
    Warrior = {
        AnnihilatorActive = true,
        AnnihilatorWeavers = {
            -- Horde
            "Jokamok",
            "Crymeariver",

            "Suecia",   -- Tank
            "Ajlano",   -- Tank
            "Almisael", -- Tank

            -- Alliance
            "Miksmaks",
        }
    },

    -- [[ Mage ]] --
    Mage = {
        -- Fire
        StarterIgniteTick = 425,             -- Represents the threshold tick value for the Ignite debuff
        AllowIgniteToDropWhenBadTick = true, -- Indicates whether Ignite should be allowed to drop when its tick value is below the specified threshold
        SpellToKeepIgniteUp = "Scorch",      -- Specifies the spell that should be cast to keep the Ignite debuff up
        AllowFireBlastDuringIgnite = true,   -- Indicates whether instant cast spells should be allowed like fireblast when igniting
        -- Frost
        SpellToKeepWintersChillUp = "Frostbolt(Rank 1)",
    },

    -- [[ Shaman ]] --
    Shaman = {
        DefaultToHealingWave = true,      -- If you don't have a specific set, will default to Healing Wave
        NSLowHealthAggroedPlayers = true, -- Change to nil if you experience lag
    },

    -- [[ Warlock ]] --
    Warlock = {
        ShouldBeWhores = false, -- Set to true to use Shadowburn on targets with 5x Shadoweaving and Improved Shadowbolt
    },

    -- [[ Priest ]] --
    Priest = {
        PrioritizePriestsAtieshBuff = true -- If enabled, prevents druid from re-equipping Atiesh so priest can keep the buff
    },

    -- [[ Item Rack ]] --
    AutoEquipSet = {   -- Automatically equips your gear set on login
        Active = true, -- Set to true to enable, false to disable
        Set = "NRML"   -- Name of your default gear set
    },

    -- [[ Extra's ]] --
    AutoTurnToTarget = false,                -- Auto-turning to raid leader, copied from 5MMB (Never used, but thought it was cool)
    Frameflash = true,                       -- Change this to nil if you do not want the frames to flash when you are out of range, etc.
    Use40yardHealingRangeOnInstants = false, -- Can cause massive lag and freezing if activated and raid is low on health. If nil = 28 yards, if true = 40 yards.

    -- [[ Fury Tanks ]] --
    FurysThatCanTank = {
        -- Horde
        "Crymeariver",
        "Jokamok",

        -- Alliance
        "Alliance Fury 1"
    },

    -- [[ All Tanks ]] --
    TankList = {
        -- Horde
        "Moron",

        -- Avoid Tanks
        "Kungen",
        "Tyamies",

        -- Normal Tanks
        "Suecia",
        "Ajlano",
        "Almisael",
        "Rows",
        "Sabo",

        -- Alliance
        "Sceto",

        -- Normal Tanks
        "Laty",
        "Myosin",
        "Droodood",
        "Subsmash",
        "Algoritam"
    }
}

function getSettings()
    return MoronBox.Settings
end

function getSettingsState()
    return MoronBox.Settings.SettingsState
end

function getRaidId()
    return string.upper(string.gsub(getSettingsState().RAID, " ", "_"))
end
