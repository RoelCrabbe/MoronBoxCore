-- [[ Config & Constants ]] --

MoronBox.Core.Gear = MoronBox.Core.Gear or {}

local GearSets = {}

function getGear()
    return MoronBox.Core.Gear
end

-- [[ Gear Sets ]] --

function MoronBox.Core.Gear.EquippedSetCount(set)
    local item_slots = { 1, 3, 5, 6, 7, 8, 9, 10, 11, 12 }
    local count = 0

    for i = 1, 10 do
        local link = GetInventoryItemLink("player", item_slots[i])
        if link == nil then
            getApi().CdPrint("Missing gear in slots, can't decide proper healspell based on gear.", 30)
            return 0
        end

        local _, _, item_name = string.find(link, "|h%[(.-)%]|h")
        if item_name == GearSets[set][i] then
            count = count + 1
        end
    end

    return count
end

function MoronBox.Core.Gear.EquipRackSet(set)
    local _, _, _, Enabled = GetAddOnInfo("ItemRack")

    if Enabled then
        EquipSet(set)
        return
    end

    getRaid().CdPrint("No ItemRack Addon Found")
end

function MoronBox.Core.Gear.TankGear()
    getConfigState().PlayerSpecc = "Furytank"
    getConfigState().WarriorBinds = nil
    getGear().EquipRackSet("TANK")
end

function MoronBox.Core.Gear.FuryGear()
    getConfigState().PlayerSpecc = "BT"
    getConfigState().WarriorBinds = "Fury"
    getGear().EquipRackSet("DPS")
end

function MoronBox.Core.Gear.EvoGear()
    MB_evoGear = true
    getGear().EquipRackSet("EVO")
end

function MoronBox.Core.Gear.MageGear()
    MB_evoGear = false
    getGear().EquipRackSet("DPS")
end

-- [[ Annilathor ]] --

local AnnihilatorWeaverWeapons = {
    -- Horde
    ["Jokamok"] = {
        ["BMH"] = "Annihilator",           -- HM
        ["BOH"] = "The Hungering Cold",    -- OH

        ["NMH"] = "Gressil, Dawn of Ruin", -- HM
        ["NOH"] = "The Hungering Cold"     -- OH
    },

    ["Crymeariver"] = {
        ["BMH"] = "Annihilator",           -- HM
        ["BOH"] = "The Hungering Cold",    -- OH

        ["NMH"] = "Gressil, Dawn of Ruin", -- HM
        ["NOH"] = "The Hungering Cold"     -- OH
    },

    -- Alliance
    ["Miksmaks"] = {
        ["BMH"] = "Annihilator",         -- HM
        ["BOH"] = "Harbinger of Doom",   -- OH

        ["NMH"] = "Misplaced Servo Arm", -- HM
        ["NOH"] = "Harbinger of Doom"    -- OH
    },
}

function MoronBox.Core.Gear.GetWeaverWeapon(name, type)
    return AnnihilatorWeaverWeapons[name][type]
end

-- [[ Gear Sets Table ]] --

GearSets["Earthfury"] = {
    "Earthfury Helmet",
    "Earthfury Epaulets",
    "Earthfury Vestments",
    "Earthfury Belt",
    "Earthfury Legguards",
    "Earthfury Boots",
    "Earthfury Bracers",
    "Earthfury Gauntlets",
    "Ring Placeholder",
    "Ring Placeholder"
}

GearSets["The Ten Storms"] = {
    "Helmet of Ten Storms",
    "Epaulets of Ten Storms",
    "Breastplate of Ten Storms",
    "Belt of Ten Storms",
    "Legplates of Ten Storms",
    "Greaves of Ten Storms",
    "Bracers of Ten Storms",
    "Gauntlets of Ten Storms",
    "Ring Placeholder",
    "Ring Placeholder"
}

GearSets["Stormcaller's Garb"] = {
    "Stormcaller\'s Diadem",
    "Stormcaller\'s Pauldrons",
    "Stormcaller\'s Hauberk",
    "Belt Placeholder",
    "Stormcaller\'s Leggings",
    "Stormcaller\'s Footguards",
    "Bracer Placeholder",
    "Gloves Placeholder",
    "Ring Placeholder",
    "Ring Placeholder"
}

GearSets["Vestments of Transcendence"] = {
    "Halo of Transcendence",
    "Pauldrons of Transcendence",
    "Robes of Transcendence",
    "Belt of Transcendence",
    "Leggings of Transcendence",
    "Boots of Transcendence",
    "Bindings of Transcendence",
    "Handguards of Transcendence",
    "Ring Placeholder",
    "Ring Placeholder"
}

GearSets["Dreamwalker Raiment"] = {
    "Dreamwalker Headpiece",
    "Dreamwalker Spaulders",
    "Dreamwalker Tunic",
    "Dreamwalker Girdle",
    "Dreamwalker Legguards",
    "Dreamwalker Boots",
    "Dreamwalker Wristguards",
    "Dreamwalker Handguards",
    "Ring of The Dreamwalker",
    "Ring of The Dreamwalker"
}

GearSets["The Earthshatter"] = {
    "Earthshatter Headpiece",
    "Earthshatter Spaulders",
    "Earthshatter Tunic",
    "Earthshatter Girdle",
    "Earthshatter Legguards",
    "Earthshatter Boots",
    "Earthshatter Wristguards",
    "Earthshatter Handguards",
    "Ring of The Earthshatterer",
    "Ring of The Earthshatterer"
}
