--[####################################################################################################]--
--[####################################### START MAGE CODE! #########################################]--
--[####################################################################################################]--

local Mage = CreateFrame("Frame", "Mage")

local myClass = UnitClass("player")
local myName = UnitName("player")

local MageCounter = {
    Cycle = function()
        MB_buffingCounterMage = (MB_buffingCounterMage >= TableLength(MB_classList["Mage"]))
                                  and 1 or (MB_buffingCounterMage + 1)
    end
}

--[####################################################################################################]--
--[########################################## SETUP Code! #############################################]--
--[####################################################################################################]--

local function MageSpecc()
    local TalentsIn, TalentsInA

    _, _, _, _, TalentsIn = GetTalentInfo(3, 16)
    if TalentsIn > 0 then
        MB_mySpecc = "Frost"
        return 
    end

    _, _, _, _, TalentsIn = GetTalentInfo(2, 16)
    if TalentsIn > 0 then
        MB_mySpecc = "Fire"
        return 
    end

    _, _, _, _, TalentsIn = GetTalentInfo(1, 16)
    _, _, _, _, TalentsInA = GetTalentInfo(2, 8)
    if TalentsIn > 0 and TalentsInA > 0 then
        MB_mySpecc = "Fire"
        return 
    end	

    _, _, _, _, TalentsIn = GetTalentInfo(1, 16)
    _, _, _, _, TalentsInA = GetTalentInfo(3, 8)
    if TalentsIn > 0 and TalentsInA > 1 then
        MB_mySpecc = "Frost"
        return 
    end

    MB_mySpecc = nil
end

MB_mySpeccList["Mage"] = MageSpecc

--[####################################################################################################]--
--[########################################## Single Code! ############################################]--
--[####################################################################################################]--

local function MageSingle()

    mb_getTarget()

	if not MB_mySpecc then		
		mb_message("My specc is fucked. Defaulting to frost.")
		MB_mySpecc = "Frost"
	end

	if mb_crowdControl() then 
        return
    end

	if mb_hasBuffOrDebuff("Evocation", "player", "buff") then
		return
	end

	mb_decurse()

	if mb_tankTarget("Ossirian the Unscarred") then
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

	if Instance.AQ40 then
		
		if mb_hasBuffOrDebuff("True Fulfillment", "target", "debuff") then
            ClearTarget()
            return
        end

		if mb_isAtSkeram() then
            if not MB_autoToggleSheeps.Active then
                MB_autoToggleSheeps.Active = true
                MB_autoToggleSheeps.Time = GetTime() + 2
                MageCounter.Cycle()
            end

			if mb_myClassAlphabeticalOrder() == MB_buffingCounterMage then					
				mb_crowdControlMCedRaidMemberSkeram()
			end
		end

	elseif Instance.BWL and string.find(GetSubZoneText(), "Nefarian.*Lair") and mb_isAtNefarianPhase() then 

        if mb_hasBuffOrDebuff("Shadow Command", "target", "debuff") then
            ClearTarget()
            return
        end

        if not MB_autoToggleSheeps.Active then
            MB_autoToggleSheeps.Active = true
            MB_autoToggleSheeps.Time = GetTime() + 3
            MageCounter.Cycle()
        end

        if mb_myClassAlphabeticalOrder() == MB_buffingCounterMage then                
            mb_crowdControlMCedRaidMemberNefarian()
        end

	elseif Instance.ZG and mb_tankTarget("Hakkar") then

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
	end

	if not mb_inCombat("target") then
        return
    end

	if mb_inCombat("player") then
		Mage:UseManaGems()

		mb_takeManaPotionAndRune()
		mb_takeManaPotionIfBelowManaPotMana()
		mb_takeManaPotionIfBelowManaPotManaInRazorgoreRoom()

		if MB_isMoving.Active then			
			mb_selfBuff("Presence of Mind")			
		end

		if mb_manaPct() <= 0.1 and mb_spellReady("Evocation") then
			CastSpellByName("Evocation")
			return
		end
	end

    if MB_doInterrupt.Active and mb_spellReady(MB_myInterruptSpell[myClass]) then
        if MB_myInterruptTarget then
            mb_getMyInterruptTarget()
        end

        if mb_imBusy() then			
            SpellStopCasting() 
        end

        CastSpellByName(MB_myInterruptSpell[myClass])
        mb_coolDownPrint("Interrupting!")
        MB_doInterrupt.Active = false
        return        
    end

	if Mage:BossSpecificDPS() then
        return
    end

	if MB_mySpecc == "Fire" then

		if mb_isFireImmune() then			
			mb_castSpellOrWand("Frostbolt")
			return
		end

		Mage:Fire()

	elseif MB_mySpecc == "Frost" then

        if mb_isFrostImmune() then
            mb_castSpellOrWand("Fireball")
            return
        end

        Mage:Frost()
	end
end

function Mage:BossSpecificDPS()

	if UnitName("target") == "Emperor Vek\'nilash" then
        return true
    end

	if mb_mobsToDetectMagic() and not mb_hasBuffOrDebuff("Detect Magic", "target", "debuff") then		
		if not mb_hasBuffOrDebuff("Detect Magic", "player", "debuff") then
			CastSpellByName("Detect Magic")
			return true
		end
	end

	if mb_mobsToFireWard() and not mb_hasBuffOrDebuff("Fire Ward", "player", "buff")  then
		mb_selfBuff("Fire Ward")
		return true		
	end

    if (mb_mobsToDetectMagic() and mb_hasBuffOrDebuff("Detect Magic", "player", "debuff"))
        and (not mb_hasBuffOrDebuff("Shadow and Frost Reflect", "target", "buff")
            or not mb_hasBuffOrDebuff("Fire and Arcane Reflect", "target", "buff")) then

        Mage:Fire()
        return true

    elseif mb_hasBuffOrDebuff("Fire and Arcane Reflect", "target", "buff") then

        mb_castSpellOrWand("Frostbolt")
        return true

    elseif mb_hasBuffOrDebuff("Shadow and Frost Reflect", "target", "buff") then

        Mage:Fire()
        return true

    elseif mb_mobsToDetectMagic() or mb_hasBuffOrDebuff("Magic Reflection", "target", "buff") then

        if mb_imBusy() then
            SpellStopCasting()
        end

        mb_autoWandAttack()
        return true
    end

	if mb_tankTarget("Azuregos") and mb_hasBuffNamed("Magic Shield", "target") then		
		if mb_imBusy() then 			
			SpellStopCasting()
		end
		
		mb_selfBuff("Frost Ward")
		return true
	end

	if Instance.AQ40 then
		
		if mb_tankTarget("Viscidus") then			
			if mb_healthPct("target") <= 0.35 then				
				CastSpellByName("Frostbolt(Rank 1)")
				return true
			end

			Mage:Fire()
			return true			
		end

		if UnitName("target") == "Spawn of Fankriss" then			
			if mb_spellReady("Fireblast") and mb_inMeleeRange() then
				CastSpellByName("Fire Blast")
			end

            if MB_mySpecc == "Fire" then    
                Mage:Fire()

            elseif MB_mySpecc == "Frost" then
                Mage:Frost()
            end
			return true
		end

	elseif Instance.BWL and mb_corruptedTotems() and not mb_dead("target") then
	
        if mb_spellReady("Fireblast") then
            CastSpellByName("Fire Blast")
        end

        mb_castSpellOrWand("Scorch")
        return true

	elseif Instance.MC then

		if mb_tankTarget("Shazzrah") then
			if MB_mySpecc == "Fire" and not mb_spellReady("Fireball") then
				
                Mage:Frost()
				return true
			elseif MB_mySpecc == "Frost" and not mb_spellReady("Frostbolt") then
							
				Mage:Fire()
				return true				
			end
		end

		if UnitName("target") == "Lava Spawn" and mb_inMeleeRange() then
            if mb_spellReady("Cone of Cold") then				
                mb_castSpellOrWand("Cone of Cold")
                return true
            end
		end

	elseif Instance.ZG then

		if mb_hasBuffOrDebuff("Delusions of Jin\'do", "player", "debuff") then
			if UnitName("target") == "Shade of Jin\'do" and not mb_dead("target") then
				if mb_spellReady("Fire Blast") then
					CastSpellByName("Fire Blast") 
				end 
					
				mb_castSpellOrWand("Scorch") 
				return true
			end
		end

		if (UnitName("target") == "Powerful Healing Ward" or UnitName("target") == "Brain Wash Totem") and not mb_dead("target") then
			if mb_spellReady("Fire Blast") then				
				CastSpellByName("Fire Blast")
			end

			mb_castSpellOrWand("Scorch")
			return true
		end

	elseif Instance.AQ20 and mb_tankTarget("Ossirian the Unscarred") then

        if mb_hasBuffOrDebuff("Fire Weakness", "target", "debuff") then
        
            Mage:Fire()
            return true
        elseif mb_hasBuffOrDebuff("Frost Weakness", "target", "debuff") then

            Mage:Frost()
            return true
        elseif mb_hasBuffOrDebuff("Arcane Weakness", "target", "debuff") then
        
            mb_castSpellOrWand("Arcane Missiles")
            return true
        end
	end

	return false
end

function Mage:Fire()
	local igTick = tonumber(MB_ignite.Amount)

    if not MB_ignite.Active then
		if mb_debuffScorchAmount() == 5 then			
			Mage:Cooldowns()
		end

		mb_castSpellOrWand("Fireball")
        return
    end

    if mb_inMeleeRange() and mb_spellReady("Fire Blast") and MB_raidAssist.Mage.AllowInstantCast then        
        CastSpellByName("Fire Blast")
    end

    if MB_ignite.Starter == myName then
    
        if igTick > MB_raidAssist.Mage.StarterIgniteTick then
            mb_castSpellOrWand("Fireball")
        else

            if MB_raidAssist.Mage.AllowIgniteToDropWhenBadTick then
                mb_castSpellOrWand("Frostbolt")
            else
                mb_castSpellOrWand("Fireball")
            end
        end
    else
        if mb_hasBuffOrDebuff("Ignite", "target", "debuff") then
            mb_castSpellOrWand(MB_raidAssist.Mage.SpellToKeepIgniteUp)
        end
    end		
end

function Mage:Frost()
    if mb_inCombat("player") then        
        if mb_manaDown("player") > 600 then
            Priest:Cooldowns()
        end

        if mb_spellReady("Ice Block") and mb_healthPct("player") <= 0.22 and not mb_isAtGrobbulus() then			
            mb_selfBuff("Ice Block")
            return
        end

        if mb_hasBuffOrDebuff("Ice Block", "player", "buff") and mb_healthPct("player") >= 0.70 then 
            CancelBuff("Ice Block") 
            return 
        end

        if mb_spellReady("Ice Barrier") and mb_healthPct("player") >= 0.65 then				
            mb_selfBuff("Ice Barrier")
            return
        end
    end

    if not mb_spellReady("Frostbolt") then			
        mb_castSpellOrWand("Fireball")
    else
        mb_castSpellOrWand("Frostbolt")
    end
end

MB_mySingleList["Mage"] = MageSingle

--[####################################################################################################]--
--[########################################## Multi Code! #############################################]--
--[####################################################################################################]--

MB_myMultiList["Mage"] = MageSingle

--[####################################################################################################]--
--[########################################### AOE Code! ##############################################]--
--[####################################################################################################]--

local function MageAOE()

    mb_getTarget()

	if not MB_mySpecc then		
		mb_message("My specc is fucked. Defaulting to frost.")
		MB_mySpecc = "Frost"
	end

	if mb_hasBuffOrDebuff("Evocation", "player", "buff") then
		return
	end

	mb_decurse()

	if mb_tankTarget("Ossirian the Unscarred") then
        return
    end

    if mb_inCombat("player") then
		Mage:UseManaGems()

		mb_takeManaPotionAndRune()
		mb_takeManaPotionIfBelowManaPotMana()
		mb_takeManaPotionIfBelowManaPotManaInRazorgoreRoom()

        if mb_manaDown("player") > 600 then
            Priest:Cooldowns()
        end
	end

	if mb_manaPct("player") < 0.2 and not mb_hasBuffOrDebuff("Clearcasting", "player", "buff") then
		CastSpellByName("Arcane Explosion(Rank 1)")
		return
	end

    if Instance.BWL and GetSubZoneText() == "Halls of Strife" then
        
        CastSpellByName("Arcane Explosion(Rank 3)") 
        return
    elseif Instance.Naxx and mb_tankTarget("Maexxna") then
        
        CastSpellByName("Arcane Explosion(Rank 3)") 
        return
    end

    if Instance.Naxx and mb_tankTarget("Plague Beast") then
        if MB_mySpecc == "Fire" then

            if mb_knowSpell("Blast Wave") and mb_spellReady("Blast Wave") then                
                CastSpellByName("Blast Wave")
            end
        elseif MB_mySpecc == "Frost" then

            if mb_spellReady("Cone of Cold") then                
                CastSpellByName("Cone of Cold") 
            end	
        end
    end

    if mb_inMeleeRange() then
        if MB_mySpecc == "Fire" then
            if mb_isFireImmune() then
                return
            end

            if mb_knowSpell("Blast Wave") and mb_spellReady("Blast Wave") then                
                CastSpellByName("Blast Wave")
            end

        elseif MB_mySpecc == "Frost" then
            if mb_isFrostImmune() then
                return
            end

            if mb_spellReady("Cone of Cold") then                
                CastSpellByName("Cone of Cold") 
            end	

            if mb_spellReady("Ice Block") and mb_healthPct("player") <= 0.22 and not mb_isAtGrobbulus() then			
                mb_selfBuff("Ice Block")
                return
            end

            if mb_hasBuffOrDebuff("Ice Block", "player", "buff") and mb_healthPct("player") >= 0.70 then 
                CancelBuff("Ice Block") 
                return 
            end

            if mb_spellReady("Ice Barrier") and mb_healthPct("player") >= 0.65 then				
                mb_selfBuff("Ice Barrier")
                return
            end
        end
    end

	CastSpellByName("Arcane Explosion") 
end

MB_myAOEList["Mage"] = MageAOE

--[####################################################################################################]--
--[########################################## SETUP Code! #############################################]--
--[####################################################################################################]--

local function MageSetup()
	
	if mb_hasBuffOrDebuff("Evocation", "player", "buff") then
        return
    end

	if UnitMana("player") < 3060 and mb_hasBuffNamed("Drink", "player") then
		return
	end

	if IsAltKeyDown() then		
		Mage:ConjureManaGems()
		return
	end

	if mb_mageWater() > 100 or MB_isMoving.Active then		
        if not MB_autoBuff.Active then
            MB_autoBuff.Active = true
            MB_autoBuff.Time = GetTime() + 0.25
            MageCounter.Cycle()
        end

		if mb_myClassAlphabeticalOrder() == MB_buffingCounterMage then			
			mb_multiBuff("Arcane Brilliance")

			if mb_mobsToDampenMagic() then	
				mb_multiBuff("Dampen Magic")			
			
            elseif mb_mobsToAmplifyMagic() then				
				if mb_tankTarget("Gluth") then	
					mb_multiBuff("Amplify Magic")
				end
	
				mb_tankBuff("Amplify Magic")
			end
		end
	else
		mb_makeWater()
	end

	mb_selfBuff("Mage Armor")
	Mage:ConjureManaGems()
			
	if not mb_inCombat("player") and mb_manaPct("player") < 0.20 and not mb_hasBuffNamed("Drink", "player") then
		mb_smartDrink()
	end
end

MB_mySetupList["Mage"] = MageSetup

--[####################################################################################################]--
--[######################################### PRECAST Code! ############################################]--
--[####################################################################################################]--

local function MagePreCast()
	for k, trinket in pairs(MB_casterTrinkets) do
		if mb_itemNameOfEquippedSlot(13) == trinket and not mb_trinketOnCD(13) then 
			use(13) 
		end

		if mb_itemNameOfEquippedSlot(14) == trinket and not mb_trinketOnCD(14) then 
			use(14) 
		end
	end

	if mb_spellReady("Arcane Power") and not mb_hasBuffOrDebuff("Power Infusion", "player", "buff") then
		CastSpellByName("Arcane Power")
	end

	if MB_mySpecc == "Fire" then

		if mb_isFireImmune() then			
			CastSpellByName("Frostbolt")
		else
			CastSpellByName("Fireball")
		end
	elseif MB_mySpecc == "Frost" then

        if mb_isFrostImmune() then
            CastSpellByName("Fireball")
        else
            CastSpellByName("Frostbolt")
        end
	end
end

MB_myPreCastList["Mage"] = MagePreCast

--[####################################################################################################]--
--[########################################## Helper Code! ############################################]--
--[####################################################################################################]--

function Mage:Cooldowns()
	if mb_imBusy() or not mb_inCombat("player") then
		return
	end

    mb_selfBuff("Berserking") 
		
    if not mb_hasBuffOrDebuff("Power Infusion", "player", "buff") then
        mb_selfBuff("Arcane Power")			
    end

    mb_selfBuff("Combustion")
    mb_selfBuff("Presence of Mind")
    
    mb_healerTrinkets()
	mb_casterTrinkets()
end

function Mage:UseManaGems()
	if mb_imBusy() then
		return
	end

	-- Use em
	if (UnitClassification("target") == "worldboss" or UnitLevel("target") >= 63) then

		if mb_haveInBags("Mana Ruby") and mb_manaDown("player") >= 1200  then
			
			UseItemByName("Mana Ruby")
		end

		if mb_haveInBags("Mana Citrine") and mb_manaDown("player") >= 925 and not mb_haveInBags("Mana Ruby") then
			
			UseItemByName("Mana Citrine")
		end

		if mb_haveInBags("Mana Jade") and mb_manaDown("player") >= 650 and not mb_haveInBags("Mana Citrine") then
			if not mb_haveInBags("Mana Ruby") then
				
				UseItemByName("Mana Jade")
			end
		end

		if mb_haveInBags("Mana Agate") and mb_manaDown("player") >= 425 and not mb_haveInBags("Mana Jade") then
			if not mb_haveInBags("Mana Ruby") and not mb_haveInBags("Mana Citrine") then
				
				UseItemByName("Mana Agate")
			end
		end
	end 

	if UnitLevel("target") <= 63 and mb_manaPct("player") < 0.3 then

		if mb_haveInBags("Mana Ruby") and mb_manaDown("player") >= 1200  then
			
			UseItemByName("Mana Ruby")
		end

		if mb_haveInBags("Mana Citrine") and mb_manaDown("player") >= 925 and not mb_haveInBags("Mana Ruby") then
			
			UseItemByName("Mana Citrine")
		end

		if mb_haveInBags("Mana Jade") and mb_manaDown("player") >= 650 and not mb_haveInBags("Mana Citrine") then
			if not mb_haveInBags("Mana Ruby") then
				
				UseItemByName("Mana Jade")
			end
		end

		if mb_haveInBags("Mana Agate") and mb_manaDown("player") >= 425 and not mb_haveInBags("Mana Jade") then
			if not mb_haveInBags("Mana Ruby") and not mb_haveInBags("Mana Citrine") then
				
				UseItemByName("Mana Agate")
			end
		end
	end
	return false
end

function Mage:ConjureManaGems()
    if mb_imBusy() then
		return
	end

	if mb_getAllContainerFreeSlots() == 0 then		
		mb_message("My bags are full, can\'t conjure more stuff", 60)
		return
	end

	if not mb_haveInBags("Mana Ruby") then		
		CastSpellByName("Conjure Mana Ruby")
	end

	if not mb_haveInBags("Mana Citrine") then		
		CastSpellByName("Conjure Mana Citrine")
	end

	if not mb_haveInBags("Mana Jade") then		
		CastSpellByName("Conjure Mana Jade")
	end

	if not mb_haveInBags("Mana Agate") then		
		CastSpellByName("Conjure Mana Agate")
	end
end