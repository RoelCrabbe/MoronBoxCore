--[####################################################################################################]--
--[####################################### START MAGE CODE! #########################################]--
--[####################################################################################################]--

local Mage = CreateFrame("Frame", "Mage")

local myClass = UnitClass("player")
local myName = UnitName("player")
local tName = UnitName("target")
local myMana = UnitMana("player")

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

	if tName and MB_myCCTarget then
		if GetRaidTargetIndex("target") == MB_myCCTarget and not mb_hasBuffOrDebuff(MB_myCCSpell[myClass], "target", "debuff") then			
			mb_crowdControl()
			return 
		end
	elseif tName and mb_crowdControlledMob() then		
		mb_getTarget()
		return
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
            MB_autoToggleSheeps.Time = GetTime() + 2
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
		mb_mageUseManaGems()

		mb_takeManaPotionAndRune()
		mb_takeManaPotionIfBelowManaPotMana()
		mb_takeManaPotionIfBelowManaPotManaInRazorgoreRoom()

        if mb_manaDown("player") > 750 then
            Priest:Cooldowns()
        end

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

		if mb_isFireImmune() or not mb_spellReady("Scorch") then			
			mb_castSpellOrWand("Frostbolt")
			return
		end

		Mage:RollIgnite()

	elseif MB_mySpecc == "Frost" then

		if mb_inCombat("player") then			
			if mb_focusAggro() and mb_healthPct("player") <= 0.20 and not mb_isAtGrobbulus() then			
				mb_selfBuff("Ice Block")
				return
			end

			if mb_healthPct("player") >= 0.70 then				
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
end

MB_mySingleList["Mage"] = MageSingle

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

function Mage:BossSpecificDPS()

	if tName == "Emperor Vek\'nilash" then
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

        Mage:RollIgnite()
        return true

    elseif mb_hasBuffOrDebuff("Fire and Arcane Reflect", "target", "buff") then

        mb_castSpellOrWand("Frostbolt")
        return true

    elseif mb_hasBuffOrDebuff("Shadow and Frost Reflect", "target", "buff") then

        Mage:RollIgnite()
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

			Mage:RollIgnite()
			return true			
		end

		if tName == "Spawn of Fankriss" then			
			if mb_spellReady("Fireblast") and mb_inMeleeRange() then
				CastSpellByName("Fire Blast")
			end

			Mage:RollIgnite()
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
			if MB_mySpecc == "Fire" and not (mb_spellReady("Scorch") or mb_spellReady("Fireball")) then
				
                mb_castSpellOrWand("Frostbolt")
				return true
			elseif MB_mySpecc == "Frost" and not mb_spellReady("Frostbolt") then
							
				mb_castSpellOrWand("Scorch")
				return true				
			end
		end

		if tName == "Lava Spawn" and mb_inMeleeRange() then
            if mb_spellReady("Cone of Cold") then				
                mb_castSpellOrWand("Cone of Cold")
                return true
            end
		end

	elseif Instance.ZG then

		if mb_hasBuffOrDebuff("Delusions of Jin\'do", "player", "debuff") then
			if tName == "Shade of Jin\'do" and not mb_dead("target") then
				if mb_spellReady("Fire Blast") then
					CastSpellByName("Fire Blast") 
				end 
					
				mb_castSpellOrWand("Scorch") 
				return true
			end
		end

		if (tName == "Powerful Healing Ward" or tName == "Brain Wash Totem") and not mb_dead("target") then
			if mb_spellReady("Fire Blast") then				
				CastSpellByName("Fire Blast")
			end

			mb_castSpellOrWand("Scorch")
			return true
		end

	elseif Instance.AQ20 and mb_tankTarget("Ossirian the Unscarred") then

        if mb_hasBuffOrDebuff("Fire Weakness", "target", "debuff") then
        
            Mage:RollIgnite()
            return true
        elseif mb_hasBuffOrDebuff("Frost Weakness", "target", "debuff") then

            mb_castSpellOrWand("Frostbolt")
            return true
        elseif mb_hasBuffOrDebuff("Arcane Weakness", "target", "debuff") then
        
            mb_castSpellOrWand("Arcane Missiles")
            return true
        end
	end

	return false
end

function Mage:RollIgnite()
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