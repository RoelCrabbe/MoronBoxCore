-- [[ Config & Constants ]] --

MoronBox.Bag = MoronBox.Bag or {}

local myClass = UnitClass("player")

local Bag = MoronBox.Bag

-- [[ Bag ]] --

function MoronBox.Bag.GetItemLink(itemName)
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local link = GetContainerItemLink(bag, slot)
            if link and string.find(link, itemName) then
                return link
            end
        end
    end
    return nil
end

function MoronBox.Bag.IsItemInBagCoolDown(itemName)
    local bag, slot = Bag.GetItemLocation(itemName)
    if not bag then
        return nil
    end

    local _, duration, enable = GetContainerItemCooldown(bag, slot)
    return (enable == 1 and duration > 1.5)
end

function MoronBox.Bag.HaveInBags(itemName)
    return Bag.GetItemLink(itemName) ~= nil
end

function MoronBox.Bag.UseFromBags(itemName)
    local bag, slot = Bag.GetItemLocation(itemName)
    if bag then
        UseContainerItem(bag, slot)
        return true
    end
    return false
end

function MoronBox.Bag.GetAllContainerFreeSlots()
    local sum = 0
    for bag = 0, 4 do
        sum = sum + Bag.GetContainerNumFreeSlots(bag)
    end
    return sum
end

function MoronBox.Bag.GetContainerNumFreeSlots(bag)
    local count = 0
    for slot = 1, GetContainerNumSlots(bag) do
        if not GetContainerItemLink(bag, slot) then
            count = count + 1
        end
    end
    return count
end

function MoronBox.Bag.HasAmmoBag()
    for bag = 1, 4 do
        local bagName = GetBagName(bag)
        if bagName and (string.find(bagName, "Quiver") or string.find(bagName, "Ammo Pouch")) then
            return true
        end
    end
    return false
end

function MoronBox.Bag.HasItem(itemName)
    local count = 0

    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local _, itemCount, _, _, _, _, link = GetContainerItemInfo(bag, slot)

            if link and string.find(link, itemName) then
                count = count + (itemCount or 1)
            end
        end
    end

    if count == 0 then
        MoronBox.Api.CdMessage("I'm out of " .. itemName)
    end

    return count
end

function MoronBox.Bag.CountItem(itemName)
    local count = 0
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local link = GetContainerItemLink(bag, slot)
            if link and string.find(link, itemName, 1, true) then
                local _, itemCount = GetContainerItemInfo(bag, slot)
                count = count + (itemCount or 1)
            end
        end
    end
    return count
end

function MoronBox.Bag.NumShards()
    return Bag.CountItem("Soul Shard")
end

function MoronBox.Bag.NumManapots()
    return Bag.CountItem("Major Mana Potion")
end

function MoronBox.Bag.NumDemonicRunes()
    return Bag.CountItem("Demonic Rune")
end

function MoronBox.Bag.NumSands()
    return Bag.CountItem("Hourglass Sand")
end

function MoronBox.Bag.GetItemNameOfEquippedSlot(slotId)
    local link = GetInventoryItemLink("player", slotId)
    if not link then
        return nil
    end

    local _, _, itemName = string.find(link, "|c%x+|Hitem:%d+:%d+:%d+:%d+|h%[(.-)%]|h|r")
    return itemName
end

function MoronBox.Bag.GetEquippedItemSubType(slotId)
    local itemLink = GetInventoryItemLink("player", slotId)
    if not itemLink then
        return "Bow"
    end

    local bsNum = string.gsub(itemLink, ".-\124H([^\124]*)\124h.*", "%1")
    local _, _, _, _, _, itemSubType = GetItemInfo(bsNum)
    _, _, itemSubType = string.find(itemSubType, "(.*)s")
    return itemSubType
end

local HasAnAtieshEquipped = nil

function MoronBox.Bag.ReEquipAtieshIfNoAtieshBuff()
    if (myClass == "Warrior" or myClass == "Rogue" or (myClass == "Druid" and MB_raidAssist.Druid.PrioritizePriestsAtieshBuff)) then
        return
    end

    local atiesh = "Atiesh, Greatstaff of the Guardian"
    local equippedItem = Bag.GetItemNameOfEquippedSlot(16)

    if equippedItem == atiesh then
        HasAnAtieshEquipped = true
    end

    if equippedItem == atiesh and not Aura.HasBuffOrDebuff("Atiesh", "player", "buff") and MoronBox.Unit.IsAlive("player") then
        if Bag.GetAllContainerFreeSlots() >= 1 then
            PickupInventoryItem(16)
            PutItemInBackpack()
            ClearCursor()
        else
            MoronBox.Api.CdMessage("I don't have bagspace to requip Atiesh, sort it!")
        end
    end

    if HasAnAtieshEquipped and not GetInventoryItemLink("player", 16) and MoronBox.Unit.IsAlive("player") then
        UseItemByName(atiesh)
    end
end

function MoronBox.Bag.TrinketOnCD(slotId)
    if not GetInventoryItemLink("player", slotId) then
        return false
    end

    local _, duration, enable = GetInventoryItemCooldown("player", slotId)
    return (enable == 1 and duration > 1.5)
end

local HealerTrinkets = {
    "Eye of the Dead",
    "Zandalarian Hero Charm",
    "Talisman of Ephemeral Power",
    "Hibernation Crystal",
    "Scarab Brooch",
    "Warmth of Forgiveness",
    "Natural Alignment Crystal",
    "Mar\'li\'s Eye",
    "Hazza\'rah\'s Charm of Healing",
    "Wushoolay\'s Charm of Nature",
    "Draconic Infused Emblem",
    "Talisman of Ascendance",
    "Second Wind",
    "Burst of Knowledge"
}

local CasterTrinkets = {
    "Zandalarian Hero Charm",
    "Talisman of Ephemeral Power",
    "Burst of Knowledge",
    "Fetish of the Sand Reaver",
    "Eye of Diminution",
    "The Restrained Essence of Sapphiron",
    "Mind Quickening Gem",
    "Eye of Moam",
    "Mar\'li\'s Eye",
    "Draconic Infused Emblem",
    "Talisman of Ascendance",
    "Second Wind"
}

local MeleeTrinkets = {
    "Earthstrike",
    "Kiss of the Spider",
    "Badge of the Swarmguard",
    "Diamond Flask",
    "Slayer\'s Crest",
    "Jom Gabbar",
    "Glyph of Deflection",
    "Zandalarian Hero Badge",
    "Zandalarian Hero Medallion",
    "Gri\'lek\'s Charm of Might",
    "Renataki\'s Charm of Trickery",
    "Devilsaur Eye"
}

local function useTrinket(slotId, trinketList)
    if not MoronBox.Unit.InCombat() or Bag.TrinketOnCD(slotId) then
        return
    end

    local equippedName = Bag.GetItemNameOfEquippedSlot(slotId)
    if not equippedName then
        return
    end

    for _, name in pairs(trinketList) do
        if equippedName == name then
            use(slotId)
            break
        end
    end
end

function MoronBox.Bag.HealerTrinkets()
    useTrinket(13, HealerTrinkets)
    useTrinket(14, HealerTrinkets)
end

function MoronBox.Bag.CasterTrinkets()
    useTrinket(13, CasterTrinkets)
    useTrinket(14, CasterTrinkets)
end

function MoronBox.Bag.MeleeTrinkets()
    useTrinket(13, MeleeTrinkets)
    useTrinket(14, MeleeTrinkets)
end
