--[####################################################################################################]--
--[####################################### START SINGLE CODE! #########################################]--
--[####################################################################################################]--

local myClass = UnitClass("player")
local myName = UnitName("player")

local PriestCounter = {
    Cycle = function()
        MB_buffingCounterPriest = (MB_buffingCounterPriest >= TableLength(MB_classList["Priest"]))
                                  and 1 or (MB_buffingCounterPriest + 1)
    end
}

local MageCounter = {
    Cycle = function()
        MB_buffingCounterMage = (MB_buffingCounterMage >= TableLength(MB_classList["Mage"]))
                                  and 1 or (MB_buffingCounterMage + 1)
    end
}

local WarlockCounter = {
    Cycle = function()
        MB_buffingCounterWarlock = (MB_buffingCounterWarlock >= TableLength(MB_classList["Warlock"]))
                                  and 1 or (MB_buffingCounterWarlock + 1)
    end
}

--[####################################################################################################]--
--[########################################## Single Code! ############################################]--
--[####################################################################################################]--

function mb_single()

	if not MB_raidLeader and (TableLength(MBID) > 1) then 
        mb_coolDownPrint("WARNING: You have not chosen a raid leader")
    end

	if mb_dead("player") then
        return
    end

	if mb_hasBuffNamed("Mind Control", "player") then
        return
    end

    if Instance.Naxx and mb_hasBuffNamed("Mind Control", "player") then
        if mb_tankTarget("Instructor Razuvious") and mb_myNameInTable(MB_myRazuviousPriest) and MB_myRazuviousBoxStrategy then

            mb_doRazuviousActions()
            return
        elseif mb_tankTarget("Grand Widow Faerlina") and mb_myNameInTable(MB_myFaerlinaPriest) and MB_myFaerlinaBoxStrategy then

            mb_doFaerlinaActions()
            return
        end

    elseif Instance.BWL and not mb_tankTarget("Razorgore the Untamed") then
	    if mb_isAtRazorgore() and myName == mb_returnPlayerInRaidFromTable(MB_myRazorgoreORBtank) then
            mb_orbControlling()
            return
        end
    
    elseif Instance.ZG and mb_tankTarget("Bloodlord Mandokir") then
        if mb_mandokirGaze() then
            return
        end

    elseif Instance.AQ20 and mb_tankTarget("Moam") then
        mb_autoAssignBanishOnMoam()
    end

	if not (myClass == "Warrior" or myClass == "Rogue") then		
		mb_reEquipAtieshIfNoAtieshBuff()
	end

	if mb_itemNameOfEquippedSlot(16) == nil then		
		mb_message("I don\'t have a weapon equipped.", 500)
	end

	mb_GTFO()

    if mb_hasBuffOrDebuff("First Aid", "player", "buff") and mb_hasBuffOrDebuff("Recently Bandaged", "player", "debuff") then
        return
    end

    if mb_inCombat("player") 
        and mb_stunnableMob() 
        and mb_inMeleeRange()
        and mb_spellReady("War Stomp") 
        and not mb_isDruidShapeShifted() then

        CastSpellByName("War Stomp")
    end
					
    local SingleRotation = MB_mySingleList[myClass]
    if SingleRotation and type(SingleRotation) == "function" then
        SingleRotation()
    else
        mb_message("I don\'t know what to do.", 500)
    end
end

--[####################################################################################################]--
--[########################################### Multi Code! ############################################]--
--[####################################################################################################]--

function mb_multi()

	if not MB_raidLeader and (TableLength(MBID) > 1) then 
        mb_coolDownPrint("WARNING: You have not chosen a raid leader")
    end

	if mb_dead("player") then
        return
    end

	if mb_hasBuffNamed("Mind Control", "player") then
        return
    end

    if Instance.Naxx and mb_hasBuffNamed("Mind Control", "player") then
        if mb_tankTarget("Instructor Razuvious") and mb_myNameInTable(MB_myRazuviousPriest) and MB_myRazuviousBoxStrategy then

            mb_doRazuviousActions()
            return
        elseif mb_tankTarget("Grand Widow Faerlina") and mb_myNameInTable(MB_myFaerlinaPriest) and MB_myFaerlinaBoxStrategy then

            mb_doFaerlinaActions()
            return
        end

    elseif Instance.BWL and not mb_tankTarget("Razorgore the Untamed") then
	    if mb_isAtRazorgore() and myName == mb_returnPlayerInRaidFromTable(MB_myRazorgoreORBtank) then
            mb_orbControlling()
            return
        end
    
    elseif Instance.ZG and mb_tankTarget("Bloodlord Mandokir") then
        if mb_mandokirGaze() then
            return
        end

    elseif Instance.AQ20 and mb_tankTarget("Moam") then
        mb_autoAssignBanishOnMoam()
    end

	if not (myClass == "Warrior" or myClass == "Rogue") then		
		mb_reEquipAtieshIfNoAtieshBuff()
	end

	if mb_itemNameOfEquippedSlot(16) == nil then		
		mb_message("I don\'t have a weapon equipped.", 500)
	end

	mb_GTFO()

    if mb_hasBuffOrDebuff("First Aid", "player", "buff") and mb_hasBuffOrDebuff("Recently Bandaged", "player", "debuff") then
        return
    end

    if mb_inCombat("player") 
        and mb_stunnableMob() 
        and mb_inMeleeRange()
        and mb_spellReady("War Stomp") 
        and not mb_isDruidShapeShifted() then

        CastSpellByName("War Stomp")
    end

    local MultiRotation = MB_myMultiList[myClass]
    if MultiRotation and type(MultiRotation) == "function" then
        MultiRotation()
    else
        mb_message("I don\'t know what to do.", 500)
    end
end

--[####################################################################################################]--
--[############################################ AOE Code! #############################################]--
--[####################################################################################################]--

function mb_AOE()

	if not MB_raidLeader and (TableLength(MBID) > 1) then 
        mb_coolDownPrint("WARNING: You have not chosen a raid leader")
    end

	if mb_dead("player") then
        return
    end

	if mb_hasBuffNamed("Mind Control", "player") then
        return
    end

    if Instance.Naxx and mb_hasBuffNamed("Mind Control", "player") then
        if mb_tankTarget("Instructor Razuvious") and mb_myNameInTable(MB_myRazuviousPriest) and MB_myRazuviousBoxStrategy then

            mb_doRazuviousActions()
            return
        elseif mb_tankTarget("Grand Widow Faerlina") and mb_myNameInTable(MB_myFaerlinaPriest) and MB_myFaerlinaBoxStrategy then

            mb_doFaerlinaActions()
            return
        end

    elseif Instance.BWL and not mb_tankTarget("Razorgore the Untamed") then
	    if mb_isAtRazorgore() and myName == mb_returnPlayerInRaidFromTable(MB_myRazorgoreORBtank) then
            mb_orbControlling()
            return
        end
    
    elseif Instance.ZG and mb_tankTarget("Bloodlord Mandokir") then
        if mb_mandokirGaze() then
            return
        end

    elseif Instance.AQ20 and mb_tankTarget("Moam") then
        mb_autoAssignBanishOnMoam()
    end

	if not (myClass == "Warrior" or myClass == "Rogue") then		
		mb_reEquipAtieshIfNoAtieshBuff()
	end

	if mb_itemNameOfEquippedSlot(16) == nil then		
		mb_message("I don\'t have a weapon equipped.", 500)
	end

	mb_GTFO()

    if mb_hasBuffOrDebuff("First Aid", "player", "buff") and mb_hasBuffOrDebuff("Recently Bandaged", "player", "debuff") then
        return
    end

    if mb_inCombat("player") 
        and mb_stunnableMob() 
        and mb_inMeleeRange()
        and mb_spellReady("War Stomp") 
        and not mb_isDruidShapeShifted() then

        CastSpellByName("War Stomp")
    end

    local AOERotation = MB_myAOEList[myClass]
    if AOERotation and type(AOERotation) == "function" then
        AOERotation()
    else
        mb_message("I don\'t know what to do.", 500)
    end
end

--[####################################################################################################]--
--[########################################### Setup Code! ############################################]--
--[####################################################################################################]--

function mb_setup()

	if not MB_raidLeader and (TableLength(MBID) > 1) then 
        mb_coolDownPrint("WARNING: You have not chosen a raid leader")
    end

	if mb_dead("player") then
        return
    end

	if mb_hasBuffNamed("Mind Control", "player") then
        return
    end

    if Instance.Naxx and mb_hasBuffNamed("Mind Control", "player") then
        if mb_tankTarget("Instructor Razuvious") and mb_myNameInTable(MB_myRazuviousPriest) and MB_myRazuviousBoxStrategy then

            mb_doRazuviousActions()
            return
        elseif mb_tankTarget("Grand Widow Faerlina") and mb_myNameInTable(MB_myFaerlinaPriest) and MB_myFaerlinaBoxStrategy then

            mb_doFaerlinaActions()
            return
        end

    elseif Instance.BWL and not mb_tankTarget("Razorgore the Untamed") then
	    if mb_isAtRazorgore() and myName == mb_returnPlayerInRaidFromTable(MB_myRazorgoreORBtank) then
            mb_orbControlling()
            return
        end
    
    elseif Instance.ZG and mb_tankTarget("Bloodlord Mandokir") then
        if mb_mandokirGaze() then
            return
        end

    elseif Instance.AQ20 and mb_tankTarget("Moam") then
        mb_autoAssignBanishOnMoam()
    end

	if not (myClass == "Warrior" or myClass == "Rogue") then		
		mb_reEquipAtieshIfNoAtieshBuff()
	end

	if mb_itemNameOfEquippedSlot(16) == nil then		
		mb_message("I don\'t have a weapon equipped.", 500)
	end

	mb_GTFO()

    if mb_hasBuffOrDebuff("First Aid", "player", "buff") and mb_hasBuffOrDebuff("Recently Bandaged", "player", "debuff") then
        return
    end

	if IsControlKeyDown() then		
		mb_makeALine()
		return
	end

	if myClass == "Warrior" then
        return
    end

    local SetupRotation = MB_mySetupList[myClass]
    if SetupRotation and type(SetupRotation) == "function" then
        SetupRotation()
    else
        mb_message("I don\'t know what to do.", 500)
    end
end

--[####################################################################################################]--
--[########################################## Precast Code! ###########################################]--
--[####################################################################################################]--

function mb_preCast()

	if not MB_raidLeader and (TableLength(MBID) > 1) then 
        mb_coolDownPrint("WARNING: You have not chosen a raid leader")
    end

	if mb_dead("player") then
        return
    end

	if myClass == "Rogue" or myClass == "Warrior" or myClass == "Paladin" then
        return
    end

	if MB_myCCTarget or MB_myOTTarget then
        return
    end

	mb_assistFocus() -- Assist focus

	if not UnitName("target") then
        return
    end

    local PreCastRotation = MB_myPreCastList[myClass]
    if PreCastRotation and type(PreCastRotation) == "function" then
        PreCastRotation()
    else
        mb_message("I don\'t know what to do.", 500)
    end
end

--[####################################################################################################]--
--[####################################### Heal and Tank Code! ########################################]--
--[####################################################################################################]--

function mb_healAndTank()

	if not MB_raidLeader and (TableLength(MBID) > 1) then 
        mb_coolDownPrint("WARNING: You have not chosen a raid leader")
    end

	if mb_dead("player") then
        return
    end

	mb_getTarget()

    if mb_hasBuffNamed("Mind Control", "player") then
        return
    end

    if Instance.Naxx and mb_hasBuffNamed("Mind Control", "player") then
        if mb_tankTarget("Instructor Razuvious") and mb_myNameInTable(MB_myRazuviousPriest) and MB_myRazuviousBoxStrategy then

            mb_doRazuviousActions()
            return
        elseif mb_tankTarget("Grand Widow Faerlina") and mb_myNameInTable(MB_myFaerlinaPriest) and MB_myFaerlinaBoxStrategy then

            mb_doFaerlinaActions()
            return
        end

    elseif Instance.BWL and not mb_tankTarget("Razorgore the Untamed") then
	    if mb_isAtRazorgore() and myName == mb_returnPlayerInRaidFromTable(MB_myRazorgoreORBtank) then
            mb_orbControlling()
            return
        end
    
    elseif Instance.ZG and mb_tankTarget("Bloodlord Mandokir") then
        if mb_mandokirGaze() then
            return
        end

    elseif Instance.AQ20 and mb_tankTarget("Moam") then
        mb_autoAssignBanishOnMoam()
    end

	if not (myClass == "Warrior" or myClass == "Rogue") then		
		mb_reEquipAtieshIfNoAtieshBuff()
	end

	if mb_itemNameOfEquippedSlot(16) == nil then		
		mb_message("I don\'t have a weapon equipped.", 500)
	end

	mb_GTFO()

    if mb_hasBuffOrDebuff("First Aid", "player", "buff") and mb_hasBuffOrDebuff("Recently Bandaged", "player", "debuff") then
        return
    end

    if mb_inCombat("player") 
        and mb_stunnableMob() 
        and mb_inMeleeRange()
        and mb_spellReady("War Stomp") 
        and not mb_isDruidShapeShifted() then

        CastSpellByName("War Stomp")
    end

	mb_interruptingHealAndTank()

	if myClass == "Hunter" then
        if mb_useTranquilizingShot() and mb_spellReady("Tranquilizing Shot") then
            CastSpellByName("Tranquilizing Shot")
        end

		if mb_tankTarget("Gluth") then
			mb_freezingTrap()
		end

	elseif myClass == "Mage" then
		mb_decurse()

        if mb_mobsToDetectMagic() and not mb_hasBuffOrDebuff("Detect Magic", "target", "debuff") then		
            if not mb_hasBuffOrDebuff("Detect Magic", "player", "debuff") then
                CastSpellByName("Detect Magic")
                return
            end
        end

	elseif myClass == "Warlock" then
	
		if mb_hasBuffOrDebuff("Hellfire", "player", "buff") then			
			CastSpellByName("Life Tap(Rank 1)")
			return
		end

		if MB_raidAssist.Warlock.FarmSoulStones and not mb_imBusy() then			
			if mb_numShards() < 60 and mb_getAllContainerFreeSlots() >= 10 then	
				CastSpellByName("Drain Soul(Rank 1)")
				return
			end
		end
	end

	if MB_raidAssist.Warlock.FarmSoulStones and mb_imMeleeDPS() then
		MB_mySpecc = "Furytank"
	end

	if Instance.ZG and myClass == "Mage" and mb_tankTarget("Hakkar") then
		
        if mb_hasBuffOrDebuff("Mind Control", "target", "debuff") then
            ClearTarget()
            return
        end

        if not MB_autoToggleSheeps.Active then
            MB_autoToggleSheeps.Active = true
            MB_autoToggleSheeps.Time = GetTime() + 10
            MageCounter.Cycle()
        end

        if mb_myClassAlphabeticalOrder() == MB_buffingCounterMage then                
            mb_crowdControlMCedRaidMemberHakkar()
        end

	elseif Instance.AQ40 then

		if mb_hasBuffOrDebuff("True Fulfillment", "target", "debuff") then
            ClearTarget()
            return
        end

		if mb_isAtSkeram() then

			if myClass == "Mage" then

                if not MB_autoToggleSheeps.Active then
                    MB_autoToggleSheeps.Active = true
                    MB_autoToggleSheeps.Time = GetTime() + 2
                    MageCounter.Cycle()
                end

                if mb_myClassAlphabeticalOrder() == MB_buffingCounterMage then					
                    mb_crowdControlMCedRaidMemberSkeram()
                end
				
			elseif myClass == "Priest" then

                if not MB_autoToggleSheeps.Active then
                    MB_autoToggleSheeps.Active = true
                    MB_autoToggleSheeps.Time = GetTime() + 3
                    PriestCounter.Cycle()
                end

                if mb_myClassAlphabeticalOrder() == MB_buffingCounterPriest then
                    mb_crowdControlMCedRaidMemberSkeramAOE()
                end
				
			elseif myClass == "Warlock" and MB_mySkeramBoxStrategyWarlock then

                if not MB_autoToggleSheeps.Active then
                    MB_autoToggleSheeps.Active = true
                    MB_autoToggleSheeps.Time = GetTime() + 6
                    WarlockCounter.Cycle()
                end

				if mb_myClassAlphabeticalOrder() == MB_buffingCounterWarlock then
					mb_crowdControlMCedRaidMemberSkeramFear()
				end	
			end
		
		elseif myClass == "Warlock" and mb_isAtTwinsEmps() and MB_myTwinsBoxStrategy then
            if mb_myNameInTable(MB_myTwinsWarlockTank) then
                mb_warlockSingle()
            end
		end

    elseif Instance.BWL and string.find(GetSubZoneText(), "Nefarian.*Lair") and mb_isAtNefarianPhase() then 

        if mb_hasBuffOrDebuff("Shadow Command", "target", "debuff") then
            ClearTarget()
            return
        end

		if myClass == "Mage" then
            if not MB_autoToggleSheeps.Active then
                MB_autoToggleSheeps.Active = true
                MB_autoToggleSheeps.Time = GetTime() + 3
                MageCounter.Cycle()
            end

            if mb_myClassAlphabeticalOrder() == MB_buffingCounterMage then                
                mb_crowdControlMCedRaidMemberNefarian()
            end
		end

	elseif Instance.Naxx then

        if (mb_tankTarget("Instructor Razuvious") and mb_myNameInTable(MB_myRazuviousPriest) and MB_myRazuviousBoxStrategy) or
            (mb_tankTarget("Grand Widow Faerlina") and mb_myNameInTable(MB_myFaerlinaPriest) and MB_myFaerlinaBoxStrategy) then
            mb_getMCActions()
            return
        end
	end

	if mb_crowdControl() then
        return
    end

    if UnitName("target") then
        if MB_myCCTarget and GetRaidTargetIndex("target") == MB_myCCTarget and not mb_hasBuffOrDebuff(MB_myCCSpell[myClass], "target", "debuff") then			
            if mb_crowdControl() then
                return
            end
        end        

        if mb_crowdControlledMob() then
            mb_getTarget()
        end
	end

    local SingleRotation = MB_mySingleList[myClass]
    if not (SingleRotation and type(SingleRotation) == "function") then
        mb_message("I don\'t know what to do.", 500)
        return
    end

	if mb_imTank() then
        SingleRotation()

	elseif mb_imHealer() then
		if myClass == "Druid" then
			if UnitName("target") == "Death Talon Wyrmkin" and GetRaidTargetIndex("target") == MB_myCCTarget then			
				CastSpellByName("Hibernate(Rank 1)")
				return true
			end
        end

        SingleRotation()		
	end
end

--[####################################################################################################]--
--[########################################### Drinking! ##############################################]--
--[####################################################################################################]--

function mb_makeWater()
	if myClass ~= "Mage" then
		return
	end

	if mb_hasBuffOrDebuff("Evocation", "player", "buff") then
		return
	end

	if mb_imBusy() then
		return
	end

	if mb_manaPct("player") > 0.8 and mb_hasBuffNamed("Drink", "player") then		
		DoEmote("Stand")
		return
	end

	if UnitMana("player") < 780 then
		if mb_spellReady("Evocation") then
			mb_evoGear()
			CastSpellByName("Evocation")
			return
		end

		mb_mageGear()
		mb_smartDrink()
	end

	if mb_getAllContainerFreeSlots() > 0 then		
		CastSpellByName("Conjure Water")
	else 
		mb_message("My bags are full, can\'t conjure more stuff", 60)
	end
end

function mb_mageWater()
	local waterranks = TableInvert(MB_myWater)
	local bestrank = 1
	local bestwater = nil
	local count = 0
	local bag, slot, link

	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			local texture, itemCount, locked, quality, readable, lootable, link = GetContainerItemInfo(bag, slot)
			
			if texture then
				link = GetContainerItemLink(bag, slot)
				_, stack = GetContainerItemInfo(bag, slot)
				local bsnum = string.gsub(link, ".-\124H([^\124]*)\124h.*", "%1")
				local itemName, itemNo, itemRarity, itemReqLevel, itemType, itemSubType, itemCount, itemEquipLoc, itemIcon = GetItemInfo(bsnum)
				
				if FindInTable(MB_myWater, itemName) then
					if waterranks[itemName] > bestrank then
						bestwater = itemName
						bestrank = waterranks[itemName]
						count = stack
					elseif waterranks[itemName] == bestrank then
						count = count + stack
					end
				end
			end
		end 
	end
	return count, bestwater
end

function mb_pickUpWater()
	local waterranks = TableInvert(MB_myWater)
	local amount = 0
	local mycarriedwater = { }
	local bestrank = 1
	local bag, slot, link

	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			local texture, itemCount, locked, quality, readable, lootable, link = GetContainerItemInfo(bag, slot)
			
			if texture then
				link = GetContainerItemLink(bag, slot)
				local bsnum = string.gsub(link, ".-\124H([^\124]*)\124h.*", "%1")
				local itemName, itemNo, itemRarity, itemReqLevel, itemType, itemSubType, itemCount, itemEquipLoc, itemIcon = GetItemInfo(bsnum)
				if FindInTable(MB_myWater, itemName) then
					if waterranks[itemName] > bestrank then						
						bestrank=waterranks[itemName]
						bestwater=itemName.." "..bag.." "..slot
					end
				end
			end 
		end 
	end

	if bestrank > 0 then
		local _ , _, water, bag, slot = string.find(bestwater, "(Conjured.*Water) (%d+) (%d+)")		
		mb_coolDownPrint("Found "..water.." in bag "..bag.." in slot "..slot)
		PickupContainerItem(bag, slot)
		return water
	end
end

function mb_smartDrink() 
	if IsControlKeyDown() then		
		mb_sunfruitBuff()
		return
	end

	if IsAltKeyDown() then		
		mb_smartManaPotTrade()
		return
	end

	if mb_manaPct("player") > 0.99 and mb_hasBuffNamed("Drink", "player") then		
		DoEmote("Stand")
		return
	end

	if not mb_manaUser() then
		return
	end

	if myClass == "Mage" and MB_tradeOpen then
		if mb_mageWater() > 20 and GetTradePlayerItemLink(1) and string.find(GetTradePlayerItemLink(1), "Conjured.*Water") then
			return 
		end
		
		if mb_mageWater() < 21 and GetTradePlayerItemLink(1) and string.find(GetTradePlayerItemLink(1), "Conjured.*Water") then 
			mb_coolDownPrint("Not enough water to trade!")
			CancelTrade()
			return
		end
	end

	if myClass ~= "Mage" and not MB_tradeOpen then
		local waterMage = mb_isMageInGroup()
		if waterMage then
			if mb_mageWater() < 1 and mb_manaUser() then				
				if mb_isAlive(MBID[waterMage]) and mb_inTradeRange(MBID[waterMage]) then					
					TargetByName(waterMage, 1)
					
					if not MB_tradeOpen then
						InitiateTrade("target")
					end
				end
			end
		end
	end

	if myClass == "Mage" and MB_tradeOpen then
		if mb_mageWater() > 21 and mb_pickUpWater() then			
			mb_coolDownPrint("Trading Water")
			ClickTradeButton(1)
			return
		end
	end

	if mb_hasBuffOrDebuff("Evocation", "player", "buff") then
		return
	else
		if myClass == "Mage" then			
			mb_mageGear() 
		end
	end

	local _, myBest = mb_mageWater()
	if not mb_hasBuffNamed("Drink", "player") and myBest then
		if mb_manaUser() and mb_manaDown() > 0 then			
			mb_useFromBags(myBest)
		end
	end
end

function mb_smartManaPotTrade()
	if not mb_imHealer() then
		return
	end

	if myName == MB_raidAssist.PotionTraders.MajorMana and MB_tradeOpen then
		if mb_numManapots() > 3 and GetTradePlayerItemLink(1) and string.find(GetTradePlayerItemLink(1), "Major Mana Potion") then
			return 
		end
		
		if mb_numManapots() < 2 and GetTradePlayerItemLink(1) and string.find(GetTradePlayerItemLink(1), "Major Mana Potion") then 
			mb_coolDownPrint("Not enough water to trade!")
			CancelTrade()
			return
		end
	end

	if myName ~= MB_raidAssist.PotionTraders.MajorMana and not MB_tradeOpen then
		if MB_raidAssist.PotionTraders.MajorMana and mb_unitInRaidOrParty(MB_raidAssist.PotionTraders.MajorMana) then
			if mb_numManapots() < 1 then				
				if mb_isAlive(MBID[MB_raidAssist.PotionTraders.MajorMana]) and mb_inTradeRange(MBID[MB_raidAssist.PotionTraders.MajorMana]) then
					if not MB_tradeOpen then
						InitiateTrade(MBID[MB_raidAssist.PotionTraders.MajorMana])
					end
				end
			end
		end
	end

	if myName == MB_raidAssist.PotionTraders.MajorMana and MB_tradeOpen then
		if mb_numManapots() > 2 then
			local i, x = mb_bagSlotOf("Major Mana Potion")
			PickupContainerItem(i, x)
			ClickTradeButton(1)
			return
		end
	end
end

--[####################################################################################################]--
--[########################################### Following! ##############################################]--
--[####################################################################################################]--

function mb_followFocus()
	if Instance.AQ40 then
		if mb_hasBuffOrDebuff("Plague", "player", "debuff") and mb_tankTarget("Anubisath Defender") then
			return
		end
	elseif Instance.MC then
		if mb_tankTarget("Baron Geddon") and mb_myNameInTable(MB_raidAssist.GTFO.Baron) then
			return
		end
	elseif Instance.Ony then
		if mb_tankTarget("Onyxia") and myName == MB_myOnyxiaMainTank then
			return
		end
	end

	if myClass == "Warlock" and mb_hasBuffOrDebuff("Hellfire", "player", "buff") then
		CastSpellByName("Life Tap(Rank 1)")
	end

	if mb_iamFocus() then
		return
	end

	if MB_raidLeader then		
		FollowByName(MB_raidLeader, 1)
		SetView(5) 
	end
end

function mb_casterFollow()
	if Instance.AQ40 then
		if mb_hasBuffOrDebuff("Plague", "player", "debuff") and mb_tankTarget("Anubisath Defender") then
			return
		end
	elseif Instance.MC then
		if mb_tankTarget("Baron Geddon") and mb_myNameInTable(MB_raidAssist.GTFO.Baron) then
			return
		end
	elseif Instance.Ony then
		if mb_tankTarget("Onyxia") and myName == MB_myOnyxiaMainTank then
			return
		end
	end

	if myClass == "Warlock" and mb_hasBuffOrDebuff("Hellfire", "player", "buff") then
		CastSpellByName("Life Tap(Rank 1)")
	end

	if mb_iamFocus() then
		return
	end

	if mb_imRangedDPS() then
		mb_followFocus()
	end
end

function mb_meleeFollow()
	if Instance.AQ40 then
		if mb_hasBuffOrDebuff("Plague", "player", "debuff") and mb_tankTarget("Anubisath Defender") then
			return
		end
	elseif Instance.MC then
		if mb_tankTarget("Baron Geddon") and mb_myNameInTable(MB_raidAssist.GTFO.Baron) then
			return
		end
	elseif Instance.Ony then
		if mb_tankTarget("Onyxia") and myName == MB_myOnyxiaMainTank then
			return
		end
	end

	if mb_iamFocus() then
		return
	end

	if Instance.AQ40 and mb_isAtSkeram() and MB_mySkeramBoxStrategyFollow then	
		if mb_myNameInTable(MB_mySkeramLeftTank) then
			return
		end

		if mb_myNameInTable(MB_mySkeramMiddleTank) then
			return
		end

		if mb_myNameInTable(MB_mySkeramRightTank) then
			return
		end
	
		if mb_myNameInTable(MB_mySkeramLeftOFFTANKS) then
			FollowByName(mb_returnPlayerInRaidFromTable(MB_mySkeramLeftTank), 1)
			return
		end

		if mb_myNameInTable(MB_mySkeramMiddleOFFTANKS) then
			FollowByName(mb_returnPlayerInRaidFromTable(MB_mySkeramMiddleTank), 1)
			return
		end

		if mb_myNameInTable(MB_mySkeramMiddleDPSERS) then
			FollowByName(mb_returnPlayerInRaidFromTable(MB_mySkeramMiddleTank), 1)
			return
		end

		if mb_myNameInTable(MB_mySkeramRightOFFTANKS) then
			FollowByName(mb_returnPlayerInRaidFromTable(MB_mySkeramRightTank), 1)
			return
		end

		return

	elseif Instance.BWL and mb_isAtRazorgore() and mb_isAtRazorgorePhase() and MB_myRazorgoreBoxStrategy then
		if myName == mb_returnPlayerInRaidFromTable(MB_myRazorgoreLeftTank) then
			return
		end

		if myName == mb_returnPlayerInRaidFromTable(MB_myRazorgoreRightTank) then
			return
		end
			
		if mb_myNameInTable(MB_myRazorgoreLeftDPSERS) then
			FollowByName(mb_returnPlayerInRaidFromTable(MB_myRazorgoreLeftTank), 1)
			return
		end

		if mb_myNameInTable(MB_myRazorgoreRightDPSERS) then
			FollowByName(mb_returnPlayerInRaidFromTable(MB_myRazorgoreRightTank), 1)
			return
		end

		return
	end

	if mb_imMeleeDPS() then		
		mb_followFocus()
	end

	if mb_imTank() and not MB_myOTTarget
		and not (mb_tankTarget("Instructor Razuvious") or mb_tankTarget("Razorgore the Untamed") 
		or mb_tankTarget("Chromaggus") or mb_isAtTwinsEmps()) then
		mb_followFocus()
	end
end

function mb_tankFollow()
	if Instance.AQ40 then
		if mb_hasBuffOrDebuff("Plague", "player", "debuff") and mb_tankTarget("Anubisath Defender") then
			return
		end
	elseif Instance.MC then
		if mb_tankTarget("Baron Geddon") and mb_myNameInTable(MB_raidAssist.GTFO.Baron) then
			return
		end
	elseif Instance.Ony then
		if mb_tankTarget("Onyxia") and myName == MB_myOnyxiaMainTank then
			return
		end
	end

	if myClass == "Warlock" and mb_hasBuffOrDebuff("Hellfire", "player", "buff") then
		CastSpellByName("Life Tap(Rank 1)")
	end

	if mb_iamFocus() then
		return
	end

	if mb_imTank() then		
		mb_followFocus()
	end
end

function mb_healerFollow()
	if Instance.AQ40 then
		if mb_hasBuffOrDebuff("Plague", "player", "debuff") and mb_tankTarget("Anubisath Defender") then
			return
		end
	elseif Instance.MC then
		if mb_tankTarget("Baron Geddon") and mb_myNameInTable(MB_raidAssist.GTFO.Baron) then
			return
		end
	elseif Instance.Ony then
		if mb_tankTarget("Onyxia") and myName == MB_myOnyxiaMainTank then
			return
		end
	end

	if myClass == "Warlock" and mb_hasBuffOrDebuff("Hellfire", "player", "buff") then
		CastSpellByName("Life Tap(Rank 1)")
	end

	if mb_iamFocus() then
		return
	end

	if mb_imHealer() then		
		mb_followFocus()
	end
end

--[####################################################################################################]--
--[###################################### Some Tank Macros! ###########################################]--
--[####################################################################################################]--

function mb_tankShoot()
	if not MB_raidLeader and (TableLength(MBID) > 1) then 
        mb_coolDownPrint("WARNING: You have not chosen a raid leader")
    end

	if mb_dead("player") then
		return
	end

	if myClass == "Warrior" and mb_imTank() and MB_myOTTarget then
		local rangedWep = mb_returnEquippedItemType(18)

		if rangedWep and mb_spellExists("Shoot "..rangedWep) then			
			CastSpellByName("Shoot "..rangedWep)
		end
	end
end

function mb_manualTaunt()
	if not MB_raidLeader and (TableLength(MBID) > 1) then 
        mb_coolDownPrint("WARNING: You have not chosen a raid leader")
    end

	if mb_dead("player") then
		return
	end

	if Instance.ZG then
		if mb_mandokirGaze() then
			return
		end
	end
	
	if mb_imTank() then 		
		if myClass == "Warrior" and mb_spellReady("Taunt") then			
			CastSpellByName("Taunt")

		elseif myClass == "Druid" and mb_spellReady("Growl") then
			CastSpellByName("Growl")
		end
	end
end

--[####################################################################################################]--
--[########################################## Ress Macros! ############################################]--
--[####################################################################################################]--

function mb_ress()
	if mb_imHealer() then
		if UnitMana("player") < 1368 and myClass == "Shaman" then 			
			mb_smartDrink()
		end

		if UnitMana("player") < 1090 and myClass == "Priest" then 			
			mb_smartDrink()
		end

		if UnitMana("player") < 1209 and myClass == "Paladin" then			
			mb_smartDrink()
		end

		MBH_Resurrection()
	end

	if mb_imRangedDPS() then		
		mb_smartDrink()
	end
end

--[####################################################################################################]--
--[############################################### GTFO! ##############################################]--
--[####################################################################################################]--

function mb_GTFO()
	if not MB_raidAssist.GTFO.Active then
        return
    end

	mb_useSandsOnChromaggus()

    if mb_iamFocus() then
        return
    end

    if Instance.Ony and MB_myOnyxiaBoxStrategy then
        if mb_tankTarget("Onyxia") and (mb_tankTargetHealth() <= 0.65 and mb_tankTargetHealth() >= 0.4) and myName ~= MB_myOnyxiaMainTank then            
            if mb_focusAggro() then
                if myClass == "Paladin" and mb_spellReady("Divine Shield") then                     
                    CastSpellByName("Divine Shield") 
                    return 
                end

                if MBID[mb_returnPlayerInRaidFromTable(MB_raidAssist.GTFO.Onyxia)] and mb_isAlive(MBID[mb_returnPlayerInRaidFromTable(MB_raidAssist.GTFO.Onyxia)]) then
                    FollowByName(mb_returnPlayerInRaidFromTable(MB_raidAssist.GTFO.Onyxia), 1)
                end
            else
                if MBID[MB_myOnyxiaFollowTarget] and mb_unitInRange(MBID[MB_myOnyxiaFollowTarget]) then                        
                    if not CheckInteractDistance(MBID[MB_myOnyxiaFollowTarget], 3) then
                        FollowByName(MB_myOnyxiaFollowTarget, 1)
                    end
                end
            end
        end	
    end
		
    if not mb_haveAggro() then
        if Instance.Naxx and MB_myGrobbulusBoxStrategy then
            if mb_isAtGrobbulus() and (myName ~= MB_myGrobbulusMainTank or myName ~= MB_myGrobbulusFollowTarget) then
                if mb_hasBuffOrDebuff("Mutating Injection", "player", "debuff") then                    
                    if MBID[mb_returnPlayerInRaidFromTable(MB_raidAssist.GTFO.Grobbulus)] and mb_isAlive(MBID[mb_returnPlayerInRaidFromTable(MB_raidAssist.GTFO.Grobbulus)]) then
                        FollowByName(mb_returnPlayerInRaidFromTable(MB_raidAssist.GTFO.Grobbulus), 1)
                    end
                else
                    if MBID[MB_myGrobbulusFollowTarget] and mb_unitInRange(MBID[MB_myGrobbulusFollowTarget]) then                        
                        if not CheckInteractDistance(MBID[MB_myGrobbulusFollowTarget], 3) then
                            FollowByName(MB_myGrobbulusFollowTarget, 1)
                        end
                    else
                        if MBID[mb_returnPlayerInRaidFromTable(MB_raidAssist.GTFO.Grobbulus)] and mb_isAlive(MBID[mb_returnPlayerInRaidFromTable(MB_raidAssist.GTFO.Grobbulus)]) then
                            FollowByName(mb_returnPlayerInRaidFromTable(MB_raidAssist.GTFO.Grobbulus), 1)
                        end
                    end
                end
            end
            
            mb_useFrozenRuneOnFaerlina()
        
        elseif Instance.BWL and mb_hasBuffOrDebuff("Burning Adrenaline", "player", "debuff") then
        
            if myClass == "Paladin" and mb_spellReady("Divine Shield") then                
                CastSpellByName("Divine Shield") 
                return 
            end

            if MBID[mb_returnPlayerInRaidFromTable(MB_raidAssist.GTFO.Vaelastrasz)] and mb_isAlive(MBID[mb_returnPlayerInRaidFromTable(MB_raidAssist.GTFO.Vaelastrasz)]) then
                FollowByName(mb_returnPlayerInRaidFromTable(MB_raidAssist.GTFO.Vaelastrasz), 1)
            end            

        elseif Instance.MC and mb_hasBuffOrDebuff("Living Bomb", "player", "debuff") then
 
            if myClass == "Paladin" and mb_spellReady("Divine Shield") then                
                CastSpellByName("Divine Shield") 
                return 
            end
        
            if MBID[mb_returnPlayerInRaidFromTable(MB_raidAssist.GTFO.Baron)] and mb_isAlive(MBID[mb_returnPlayerInRaidFromTable(MB_raidAssist.GTFO.Baron)]) then
                FollowByName(mb_returnPlayerInRaidFromTable(MB_raidAssist.GTFO.Baron), 1)
            end
        end
    end
end

--[####################################################################################################]--
--[######################################## Inviting Party! ###########################################]--
--[####################################################################################################]--

function mb_requestInviteSummon()
	if IsAltKeyDown() and not IsShiftKeyDown() and not IsControlKeyDown() then		
		if MB_raidInviter == myName then			
			SetLootMethod("freeforall", myName)
			
			if GetNumPartyMembers() > 0 and not UnitInRaid("player") then 				
				ConvertToRaid()
			end
			return
		end

		if MB_raidInviter then
			if not (mb_isInRaid(MB_raidInviter) or mb_isInGroup(MB_raidInviter)) then			
				mb_disbandRaid()
				SendChatMessage(MB_inviteMessage, "WHISPER", DEFAULT_CHAT_FRAME.editBox.languageID, MB_raidInviter);
			end
		end
		return
	end

	if IsShiftKeyDown() and not IsAltKeyDown() and not IsControlKeyDown() then		
		if MB_raidLeader then
			if UnitInRaid("player") then				
				if not mb_unitInRange("raid"..mb_getRaidIndexForPlayerName(MB_raidLeader)) then					
					mb_message("123", 10)
					return 
				end
			else
				if not mb_unitInRange("party"..mb_getRaidIndexForPlayerName(MB_raidLeader)) then					
					mb_message("123", 10)
					return 
				end
			end
		end
	end

	if IsControlKeyDown() and not IsShiftKeyDown() and not IsAltKeyDown() then		
		mb_promoteEveryone()
		return 
	end
end

function mb_disbandRaid()
	if UnitInRaid("player") then
		for i = 1, 40 do
			local _, rank = GetRaidRosterInfo(i);
			if rank ~= 2 then
				UninviteFromParty("raid"..i)
			end
		end	
	else
		for i = 1, GetNumPartyMembers() do
			UninviteFromParty("party"..i)
		end
	end

	LeaveParty()
end

--[####################################################################################################]--
--[##################################### Interrupt Functions! #########################################]--
--[####################################################################################################]--

function mb_interruptSpell()	
	if mb_imTank() then
        return
    end

	if not mb_spellReady(MB_myInterruptSpell[myClass]) then
        return
    end

    mb_getMyInterruptTarget()

    if myClass == "Warrior" then   
        if UnitMana("player") >= 10 then                
            CastSpellByName(MB_myInterruptSpell[myClass])
        end

    elseif myClass == "Shaman" then
        if mb_imBusy() then            
            SpellStopCasting()
        end

        CastSpellByName(MB_myInterruptSpell[myClass].."(Rank 1)")

    elseif myClass == "Rogue" then
        if UnitMana("player") >= 25 then            
            CastSpellByName(MB_myInterruptSpell[myClass])
        end

    elseif myClass == "Mage" then
        if mb_imBusy() then            
            SpellStopCasting()
        end

        CastSpellByName(MB_myInterruptSpell[myClass])
    end
end

function mb_interruptingHealAndTank()	
	if mb_imTank() then
        return
    end

    if not mb_spellReady(MB_myInterruptSpell[myClass]) then
        return
    end

	if not MB_doInterrupt.Active then
        return
    end

    mb_getMyInterruptTarget()

    if myClass == "Warrior" then		
        if UnitMana("player") >= 10 then					
            CastSpellByName(MB_myInterruptSpell[myClass])
        end

    elseif myClass == "Shaman" then
        if mb_imBusy() then				
            SpellStopCasting()
        end

        CastSpellByName(MB_myInterruptSpell[myClass].."(Rank 1)")

    elseif myClass == "Rogue" then
        if UnitMana("player") >= 25 then				
            CastSpellByName(MB_myInterruptSpell[myClass])
        end

    elseif myClass == "Mage" then
        if not MB_isCastingMyCCSpell then				
            SpellStopCasting()
        end

        CastSpellByName(MB_myInterruptSpell[myClass])
    end

	MB_doInterrupt.Active = false
end

--[####################################################################################################]--
--[######################################## Cleans Totems! ############################################]--
--[####################################################################################################]--

function mb_cleanseTotem()
	if myClass == "Shaman" then
		if mb_partyIsPoisoned() then 			
			if mb_imBusy() then				
				SpellStopCasting()
				return
			end

			CastSpellByName("Poison Cleansing Totem")
		elseif mb_partyIsDiseased() then			
			if mb_imBusy() then				
				SpellStopCasting()
				return
			end

			CastSpellByName("Disease Cleansing Totem")
		end
	end
end

--[####################################################################################################]--
--[######################################### Break Fears! #############################################]--
--[####################################################################################################]--

function mb_fearBreak()	
	if IsShiftKeyDown() then 		
		mb_cleanseTotem()
		return 
	end

	if myClass == "Warrior" then
		if mb_spellReady("Berserker Rage") then		
			mb_selfBuff("Berserker Stance")
			CastSpellByName("Berserker Rage")
		end
	end

	if myClass == "Shaman" then		
		if mb_imBusy() then				
			SpellStopCasting()
			return
		end

		mb_coolDownCast("Tremor Totem", 15)
	end

	if mb_knowSpell("Will of the Forsaken") then
		if myClass == "Warrior" then 
			if mb_spellReady("Will of the Forsaken") and not (mb_hasBuffOrDebuff("Berserker Rage", "player", "buff") and mb_spellReady("Berserker Rage")) then 
				CastSpellByName("Will of the Forsaken") 
				return 
			end
		else
			if mb_spellReady("Will of the Forsaken") then 				
				CastSpellByName("Will of the Forsaken") 
				return 
			end
		end
	end
end

--[####################################################################################################]--
--[########################################## Mount Ups! ##############################################]--
--[####################################################################################################]--

function mb_mountUp()
	if myClass == "Druid" and mb_isDruidShapeShifted() and not mb_inCombat("player") then 
		mb_cancelDruidShapeShift() 
	end

	if mb_imBusy() then
        return
    end

	if Instance.AQ40 then		
		use(mb_getLink("Resonating"))
		return
	end
		
	for _, mount in MB_playerMounts do
		use(mb_getLink(mount))
	end

	if myClass == "Warlock" and mb_knowSpell("Summon Dreadsteed") then		
		CastSpellByName("Summon Dreadsteed")
		return
	end

	if myClass == "Paladin" and mb_knowSpell("Summon Charger") then		
		CastSpellByName("Summon Charger")
		return
	end	

	CastSpellByName("Summon Felsteed")
	CastSpellByName("Summon Warhorse")	
end