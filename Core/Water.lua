-- [[ Config & Constants ]] --

MoronBox.Core.Water = MoronBox.Core.Water or {}

local myClass = UnitClass("player")
local myName = UnitName("player")
local myRace = UnitRace("player")

function getWater()
    return MoronBox.Core.Water
end

-- [[ Mage Water Trading ]] --

local MageWater = {
    [60] = "Conjured Crystal Water",
    [50] = "Conjured Sparkling Water"
}

function MoronBox.Core.Water.MageWater()
    local waterRanks = getApi().TableInvert(MageWater)
    local bestRank = 1
    local bestWater = nil
    local count = 0

    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local texture, stack = GetContainerItemInfo(bag, slot)

            if texture then
                local link = GetContainerItemLink(bag, slot)
                local bsNum = string.gsub(link, ".-\124H([^\124]*)\124h.*", "%1")
                local itemName = GetItemInfo(bsNum)

                if getApi().FindInTable(MageWater, itemName) then
                    if waterRanks[itemName] > bestRank then
                        bestWater = itemName
                        bestRank = waterRanks[itemName]
                        count = stack
                    elseif waterRanks[itemName] == bestRank then
                        count = count + stack
                    end
                end
            end
        end
    end

    return count, bestWater
end

function MoronBox.Core.Water.PickUpWater()
    local waterRanks = getApi().TableInvert(MageWater)
    local bestRank = 1
    local bestWater = nil

    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local texture = GetContainerItemInfo(bag, slot)

            if texture then
                local link = GetContainerItemLink(bag, slot)
                local bsNum = string.gsub(link, ".-\124H([^\124]*)\124h.*", "%1")
                local itemName = GetItemInfo(bsNum)

                if getApi().FindInTable(MageWater, itemName) then
                    if waterRanks[itemName] > bestRank then
                        bestRank = waterRanks[itemName]
                        bestWater = itemName .. " " .. bag .. " " .. slot
                    end
                end
            end
        end
    end

    if bestRank > 0 and bestWater then
        local _, _, water, bag, slot = string.find(bestWater, "(.-) (%d+) (%d+)")
        getApi().CdPrint("Found " .. water .. " in bag " .. bag .. " in slot " .. slot)
        PickupContainerItem(bag, slot)
        return water
    end
end

-- [[ Make & Drink ]] --

function MoronBox.Core.Water.MakeWater()
    if myClass ~= "Mage" then
        return
    end

    if getAura().HasBuffOrDebuff("Evocation", "player", "buff") then
        return
    end

    if getSpells().ImBusy() then
        return
    end

    if getUnit().ManaPct("player") > 0.8 and getAura().HasBuffNamed("Drink", "player") then
        DoEmote("Stand")
        return
    end

    if UnitMana("player") < 780 then
        if getSpells().IsSpellReady("Evocation") then
            getGear().EvoGear()
            CastSpellByName("Evocation")
            return
        end

        getGear().MageGear()
        getWater().SmartDrink()
    end

    if getBag().GetAllContainerFreeSlots() > 0 then
        CastSpellByName("Conjure Water")
    else
        getApi().CdMessage("My bags are full, can\'t conjure more stuff", 60)
    end
end

function MoronBox.Core.Macro.SmartDrink()
    if getUnit().ManaPct("player") > 0.99 and getAura().HasBuffNamed("Drink", "player") then
        DoEmote("Stand")
        return
    end

    if not getUnit().IsManaUser() then
        return
    end

    if myClass == "Mage" and MB_tradeOpen then
        if MoronBox.Core.Macro.MageWater() > 20 and GetTradePlayerItemLink(1) and string.find(GetTradePlayerItemLink(1), "Conjured.*Water") then
            return
        end

        if MoronBox.Core.Macro.MageWater() < 21 and GetTradePlayerItemLink(1) and string.find(GetTradePlayerItemLink(1), "Conjured.*Water") then
            getApi().CdPrint("Not enough water to trade!")
            CancelTrade()
            return
        end
    end

    if myClass ~= "Mage" and not MB_tradeOpen then
        local waterMage = getCore().GetRandomMageInGroup()
        if waterMage then
            if MoronBox.Core.Macro.MageWater() < 1 and getUnit().IsManaUser() then
                if getUnit().IsAlive(MBID[waterMage]) and getUnit().InTradeRange(MBID[waterMage]) then
                    TargetByName(waterMage, 1)

                    if not MB_tradeOpen then
                        InitiateTrade("target")
                    end
                end
            end
        end
    end

    if myClass == "Mage" and MB_tradeOpen then
        local count = MoronBox.Core.Macro.MageWater()
        if count > 21 and MoronBox.Core.Macro.PickUpWater() then
            getApi().CdPrint("Trading Water")
            ClickTradeButton(1)
            return
        end
    end

    if getAura().HasBuffOrDebuff("Evocation", "player", "buff") then
        return
    end

    if myClass == "Mage" then
        getGear().MageGear()
    end

    local _, myBest = MoronBox.Core.Macro.MageWater()
    if not getAura().HasBuffNamed("Drink", "player") and myBest then
        if getUnit().IsManaUser() and getUnit().ManaDown() > 0 then
            getBag().UseFromBags(myBest)
        end
    end
end
