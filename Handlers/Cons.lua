--[####################################################################################################]--
--[######################################## Raid Consumables ##########################################]--
--[####################################################################################################]--

local myClass = UnitClass("player")

function mb_buyReagentsAndArrows()
    local MB_reagentsList = {
        ["Jagged Arrow"] = "Warrior",
        ["Flash Powder"] = "Rogue",
        ["Wild Thornroot"] = "Druid",
        ["Ironwood Seed"] = "Druid",
        ["Sacred Candle"] = "Priest",
        ["Ankh"] = "Shaman",
        ["Arcane Powder"] = "Mage",
        ["Rune of Portals"] = "Mage",
        ["Symbol of Kings"] = "Paladin",
        ["Symbol of Divinity"] = "Paladin"
    }

    local MB_reagentsLimit = {
        ["Jagged Arrow"] = { 1, 2 },
        ["Flash Powder"] = { 80, 1 },
        ["Wild Thornroot"] = { 200, 1 },
        ["Ironwood Seed"] = { 20, 1 },
        ["Sacred Candle"] = { 200, 1 },
        ["Ankh"] = { 10, 1 },
        ["Arcane Powder"] = { 160, 1 },
        ["Rune of Portals"] = { 10, 1 },
        ["Symbol of Kings"] = { 5, 1 },
        ["Symbol of Divinity"] = { 10, 1 }
    }
    
    for item, class in pairs(MB_reagentsList) do
        if myClass == class then 
            local myCurrentItems = mb_hasItem(item) / MB_reagentsLimit[item][2]
            local myNeededItems

            if item == "Symbol of Kings" then
                myNeededItems = ((MB_reagentsLimit[item][1] * 100) - myCurrentItems) / MB_reagentsLimit[item][2]
            else
                myNeededItems = (MB_reagentsLimit[item][1] - myCurrentItems) / MB_reagentsLimit[item][2]
            end

            if myNeededItems > 0 then 
                if item == "Symbol of Kings" then
                    myNeededItems = math.floor(myNeededItems / 20)
                end

                for itemID = 1, 40 do
                    local merchantItemLink = GetMerchantItemLink(itemID)
                    if merchantItemLink then 
                        if string.find(merchantItemLink, item) then 
                            Print("Buying "..myNeededItems.." "..merchantItemLink)
                            BuyMerchantItem(itemID, myNeededItems)
                        end
                    end
                end
            end
        end
    end
    
    MB_autoBuyReagents.Active = false
end

function mb_takeManaPotionAndRune()
    if not mb_bossIShouldUseRunesAndManapotsOn() or not mb_inCombat("player") then
        return
    end

    local manaDown = mb_manaDown()
    local items = {
        {name = "Major Mana Potion", threshold = 2250},
        {name = "Superior Mana Potion", threshold = 1500},
        {name = "Demonic Rune", threshold = 1500},
        {name = "Dark Rune", threshold = 1500},
    }

    for _, item in ipairs(items) do
        if manaDown > item.threshold and mb_haveInBags(item.name) and not mb_isItemInBagCoolDown(item.name) then
            UseItemByName(item.name)
            return
        end
    end
end

function mb_takeManaPotionIfBelowManaPotMana()
    if not mb_bossIShouldUseManapotsOn() or not mb_inCombat("player") then
        return
    end

    local manaDown = mb_manaDown()
    local potions = {
        {name = "Major Mana Potion", threshold = 2250},
        {name = "Superior Mana Potion", threshold = 1500},
    }

    for _, potion in ipairs(potions) do
        if manaDown > potion.threshold and mb_haveInBags(potion.name) and not mb_isItemInBagCoolDown(potion.name) then
            UseItemByName(potion.name)
            return
        end
    end
end

function mb_takeManaPotionIfBelowManaPotManaInRazorgoreRoom()
    if not MB_myRazorgoreBoxHealerStrategy then 
        return
    end

    if Instance.BWL or GetSubZoneText() ~= "Dragonmaw Garrison" or not mb_isAtRazorgorePhase() or not MB_myRazorgoreBoxStrategy then
        return
    end

    if not mb_inCombat("player") then
        return
    end

    local manaDown = mb_manaDown()
    local potions = {
        {name = "Major Mana Potion", threshold = 2250},
        {name = "Superior Mana Potion", threshold = 1500},
    }

    for _, potion in ipairs(potions) do
        if manaDown > potion.threshold and mb_haveInBags(potion.name) and not mb_isItemInBagCoolDown(potion.name) then
            UseItemByName(potion.name)
            return
        end
    end
end

function mb_useSandsOnChromaggus()
	if not mb_tankTarget("Chromaggus") then
        return
    end

	if not (mb_iamFocus() or mb_imTank()) then
        return
    end

	if not mb_hasBuffOrDebuff("Brood Affliction: Bronze", "player", "debuff") then
        return 
    end

	if mb_hasBuffNamed("Time Stop", "player") then
        return
    end

	if not sandTime or GetTime() - sandTime > 3 then
		sandTime = GetTime()
		mb_useFromBags("Hourglass Sand")
	end
end


function mb_useFrozenRuneOnFaerlina()
	if not MB_myFaerlinaRuneStrategy then
        return
    end

	if mb_isDruidShapeShifted() then
        return
    end

	if not mb_tankTarget("Grand Widow Faerlina") then
        return
    end

	if mb_hasBuffNamed("Frozen Rune", "player") then
        return
    end

	if mb_isItemInBagCoolDown("Frozen Rune") then
        return
    end

	mb_useFromBags("Frozen Rune")
end

