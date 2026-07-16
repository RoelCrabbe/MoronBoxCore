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
    -- [[ SpeedRun ]] --
    SpeedRunEnabled = false,

    -- [[ GTFO ]] --
    GTFO = {
        Vaelastrasz = {       -- Vaelastrasz
            "Suecia",         -- Horde
            "Alliance Soak 1" -- Alliance
        },
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
    Mage = {
        -- Fire
        StarterIgniteTick = 425,             -- Represents the threshold tick value for the Ignite debuff
        AllowIgniteToDropWhenBadTick = true, -- Indicates whether Ignite should be allowed to drop when its tick value is below the specified threshold
        SpellToKeepIgniteUp = "Scorch",      -- Specifies the spell that should be cast to keep the Ignite debuff up
        AllowFireBlastDuringIgnite = true,   -- Indicates whether instant cast spells should be allowed like fireblast when igniting
        -- Frost
        SpellToKeepWintersChillUp = "Frostbolt(Rank 1)",
    },
    Warlock = {
        ShouldBeWhores = false, -- Set to true to use Shadowburn on targets with 5x Shadoweaving and Improved Shadowbolt

    },

    -- [[ Fury Tanks ]] --
    FurysThatCanTank = {
        -- Horde
        "Crymeariver",
        "Jokamok",

        -- Alliance
        "Alliance Fury 1"
    }
}

function getSettings()
    return MoronBox.Settings
end

function getSettingsState()
    return MoronBox.Settings.SettingsState
end
