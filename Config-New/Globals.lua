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
    RaidLeader         = nil,

    -- [[ Rotations ]] --
    PlayerSpecc        = nil,
    WarriorBinds       = "Fury",

    -- [[ Cooldowns ]]
    UseCooldowns       = { Active = false, Time = 0 },
    UseBigCooldowns    = { Active = false, Time = 0 },

    -- [[ Interrupts ]]
    InterruptTarget    = nil,
    DoInterrupt        = { Active = false, Time = 0 },
    InterruptSpell     = {
        Rogue = "Kick",
        Shaman = "Earth Shock",
        Mage = "Counterspell",
        Warrior = "Pummel",
        Priest = "Silence",
        Paladin = "Hammer of Justice"
    },

    -- [[ Tanking ]] --
    OffTankTarget      = nil,

    -- [[ CC ]] --
    CrowdControlTarget = nil,
    CrowdControlSpell  = {
        Priest = "Shackle Undead",
        Mage = "Polymorph",
        Warlock = "Banish",
        Druid = "Hibernate"
    },
    AutoToggleCC       = { Active = false, Time = 0 },
    SheepingMageNr     = 1,

    -- [[ Ignite ]] --
    Ignite             = { Active = nil, Starter = nil, Amount = 0, Stacks = 0 },

    -- [[ Extra ]] --
    IsMoving           = { Active = false, Time = 0 }
}

function getConfig()
    return MoronBox.Config
end

function getConfigState()
    return MoronBox.Config.ConfigState
end
