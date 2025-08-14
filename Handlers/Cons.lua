--[####################################################################################################]--
--[######################################## Raid Consumables ##########################################]--
--[####################################################################################################]--

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
