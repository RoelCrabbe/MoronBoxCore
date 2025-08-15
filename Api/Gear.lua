local GearSets = {}
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

function mb_equippedSetCount(set)
	local item_slots = { 1, 3, 5, 6, 7, 8, 9, 10, 11, 12 }
	local count = 0

	for i = 1, 10 do
		local link = GetInventoryItemLink("player", item_slots[i])
		if link == nil then 
			mb_coolDownPrint("Missing gear in slots, can\'t decide proper healspell based on gear.", 30)
			return 0
		end
		local _, _, item_name = string.find(link, "%[(.*)%]", 27)
		if item_name == GearSets[set][i] then
			count = count + 1
		end
	end
	return count
end

function mb_equipSet(set)
	local _, _, _, Enabled = GetAddOnInfo("ItemRack")
	if Enabled then
        EquipSet(set)
        return 
    end

    mb_coolDownPrint("No ItemRack Addon Found")
end

function mb_tankGear()
	mb_equipSet("TANK")
	MB_mySpecc = "Furytank"
	MB_warriorBinds = nil
end

function mb_furyGear()
	mb_equipSet("DPS")
	MB_mySpecc = "BT"
	MB_warriorBinds = "Fury"
end

function mb_evoGear()
	MB_evoGear = true
	mb_equipSet("EVO")
end

function mb_mageGear()
	MB_evoGear = nil
	mb_equipSet("DPS")
end