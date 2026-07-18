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
    RaidLeader                              = nil,

    -- [[ Rotations ]] --
    PlayerSpecc                             = nil,
    WarriorBinds                            = "Fury",

    -- [[ Healing ]] --
    HealSpell                               = nil,
    AssignedHealTarget                      = nil,
    LieutenantAndorovIsNotHealable          = { Active = false, Time = 0 },

    -- [[ Cooldowns ]]
    TrackCooldowns                          = {},
    UseCooldowns                            = { Active = false, Time = 0 },
    UseBigCooldowns                         = { Active = false, Time = 0 },

    -- [[ Target Marking ]] --
    CurrentRaidTarget                       = 1,
    RaidTargetNames                         = {
        [8] = "Skull",
        [7] = "Cross",
        [6] = "Square",
        [5] = "Moon",
        [4] = "Triangle",
        [3] = "Diamond",
        [2] = "Circle",
        [1] = "Star"
    },
    TargetMarkCycle                         = function(self)
        self.CurrentRaidTarget = mod(self.CurrentRaidTarget, 8) + 1
    end,
    TargetWrongWayOrTooFar                  = { Active = false, Time = 0 },
    RazorgoreNewTargetBecauseTargetIsBehind = { Active = false, Time = 0 },

    -- [[ Interrupts ]]
    InterruptTarget                         = nil,
    InterruptSpell                          = {
        Rogue = "Kick",
        Shaman = "Earth Shock",
        Mage = "Counterspell",
        Warrior = "Pummel",
        Priest = "Silence",
        Paladin = "Hammer of Justice"
    },
    DoInterrupt                             = { Active = false, Time = 0 },
    CurrentInterrupt                        = { Rogue = 1, Mage = 1, Shaman = 1 },
    CycleInterrupt                          = function(self, class, num)
        self.CurrentInterrupt[class] = mod(self.CurrentInterrupt[class], num) + 1
        return self.CurrentInterrupt[class] == 1
    end,

    -- [[ Tanking ]] --
    OffTankIndex                            = 1,
    OffTankTarget                           = nil,

    -- [[ CC ]] --
    AutoToggleCC                            = { Active = false, Time = 0 },
    SheepingMageNr                          = 1,
    SheepingWarlockNr                       = 1,
    -- CrowdControl
    CrowdControlTarget                      = nil,
    CrowdControlSpell                       = {
        Priest = "Shackle Undead",
        Mage = "Polymorph",
        Warlock = "Banish",
        Druid = "Hibernate"
    },
    CurrentCC                               = { Mage = 1, Warlock = 1, Priest = 1, Druid = 1 },
    CycleCC                                 = function(self, class, num)
        self.CurrentCC[class] = mod(self.CurrentCC[class], num) + 1
        return self.CurrentCC[class] == 1
    end,
    -- Fear
    FearTarget                              = nil,
    FearSpell                               = {
        Warlock = "Fear"
    },
    CurrentFear                             = { Warlock = 1 },
    CycleFear                               = function(self, class, num)
        self.CurrentFear[class] = mod(self.CurrentFear[class], num) + 1
        return self.CurrentFear[class] == 1
    end,

    -- [[ Ignite ]] --
    Ignite                                  = { Active = nil, Starter = nil, Amount = 0, Stacks = 0 },

    -- [[ Extra ]] --
    TradeOpen                               = false,
    IsMoving                                = { Active = false, Time = 0 },
    AutoSoulStone                           = { Active = false, Time = 0 },
    HunterFeign                             = { Active = false, Time = 0 },
    PaladinHOJ                              = { Active = false, Time = 0 }
}

function getConfig()
    return MoronBox.Config
end

function getConfigState()
    return MoronBox.Config.ConfigState
end
