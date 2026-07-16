-- [[ Globals.lua ]] --

--[[
    This file contains the foundational configuration, data tables, and lookup utilities for the addon.

    Structure:
    - Namespace initialization (MoronBox.Config.Tables)
    - API aliasing for performance
    - Global state containers and registry lists
    - Logic definitions for instance detection, faction checks, and targeting
--]]

MoronBox.Config = MoronBox.Config or {}

MoronBox.Config.ConfigState = {
    -- [[ Raid Leader ]] --
    RaidLeader      = nil,

    -- [[ Rotations ]] --
    PlayerSpecc     = nil,
    WarriorBinds    = "Fury",

    -- [[ Cooldowns ]]
    UseCooldowns    = { Active = false, Time = 0 },
    UseBigCooldowns = { Active = false, Time = 0 },

    -- [[ Interrupts ]]
    DoInterrupt     = { Active = false, Time = 0 },
    InterruptSpell  = {
        Rogue = "Kick",
        Shaman = "Earth Shock",
        Mage = "Counterspell",
        Warrior = "Pummel",
        Priest = "Silence",
        Paladin = "Hammer of Justice"
    },

    -- [[ Tanking ]] --
    OffTankTarget   = nil
}

function getConfig()
    return MoronBox.Config
end

function getConfigState()
    return MoronBox.Config.ConfigState
end
