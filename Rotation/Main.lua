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
        Print("WARNING: You have not chosen a raid leader")
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
					
    local singleRotation = MB_mySingleList[myClass]
    if singleRotation and type(singleRotation) == "function" then
        singleRotation()
    else
        mb_message("I don\'t know what to do.", 500)
    end
end

--[####################################################################################################]--
--[########################################### Multi Code! ############################################]--
--[####################################################################################################]--

function mb_multi()

	if not MB_raidLeader and (TableLength(MBID) > 1) then 
        Print("WARNING: You have not chosen a raid leader")
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

    local multiRotation = MB_myMultiList[myClass]
    if multiRotation and type(multiRotation) == "function" then
        multiRotation()
    else
        mb_message("I don\'t know what to do.", 500)
    end
end

--[####################################################################################################]--
--[############################################ AOE Code! #############################################]--
--[####################################################################################################]--

function mb_AOE()

	if not MB_raidLeader and (TableLength(MBID) > 1) then 
        Print("WARNING: You have not chosen a raid leader")
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
        Print("WARNING: You have not chosen a raid leader")
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
        Print("WARNING: You have not chosen a raid leader")
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
        Print("WARNING: You have not chosen a raid leader")
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
		mb_hunterPetPassive()

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

    local singleRotation = MB_mySingleList[myClass]
    if not (singleRotation and type(singleRotation) == "function") then
        mb_message("I don\'t know what to do.", 500)
        return
    end

	if mb_imTank() then
        singleRotation()

	elseif mb_imHealer() then
		if myClass == "Druid" then
			if UnitName("target") == "Death Talon Wyrmkin" and GetRaidTargetIndex("target") == MB_myCCTarget then			
				CastSpellByName("Hibernate(rank 1)")
				return true
			end
        end

        singleRotation()		
	end
end