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
