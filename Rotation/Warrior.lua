--[####################################################################################################]--
--[###################################### START WARRIOR CODE! #########################################]--
--[####################################################################################################]--

local Warrior = CreateFrame("Frame", "Warrior")

local myClass = UnitClass("player")
local myName = UnitName("player")

--[####################################################################################################]--
--[########################################## SETUP Code! #############################################]--
--[####################################################################################################]--

local function WarriorSpecc()
    local TalentsIn, TalentsInA

    _, _, _, _, TalentsIn = GetTalentInfo(2, 17)
    _, _, _, _, TalentsInA = GetTalentInfo(3, 9)
    if TalentsIn > 0 and TalentsInA > 4 then
        MB_mySpecc = "Furytank"
        return 
    end	

    _, _, _, _, TalentsIn = GetTalentInfo(1, 18)
    if TalentsIn > 0 then
        MB_mySpecc = "MS"
        return 
    end

    _, _, _, _, TalentsIn = GetTalentInfo(2, 17)
    if TalentsIn > 0 then
        MB_mySpecc = "BT"
        return 
    end

    _, _, _, _, TalentsIn = GetTalentInfo(3, 17)
    if TalentsIn > 0 then
        MB_mySpecc = "Prottank"
        return 
    end

    MB_mySpecc = nil
end

MB_mySpeccList["Warrior"] = WarriorSpecc

--[####################################################################################################]--
--[########################################## Single Code! ############################################]--
--[####################################################################################################]--

local function WarriorSingle()
	
	mb_getTarget()
	
    if MB_warriorBinds == "Fury" and not mb_inCombat("player") then
        if mb_myNameInTable(MB_furysThatCanTank) then				
            mb_furyGear()
            MB_warriorBinds = nil
        end
    end	

	if not mb_inCombat("target") then
        return
    end

	if mb_mobsToAutoBreakFear() and mb_inMeleeRange() then
		mb_selfBuff("Death Wish") 
	end
	
    if Instance.AQ40 then
        if mb_tankTarget("Princess Huhuran") and mb_healthPct("target") <= 0.3 and MB_myHuhuranBoxStrategy then        
            if mb_haveInBags("Greater Nature Protection Potion") and not mb_isItemInBagCoolDown("Greater Nature Protection Potion") then				
                UseItemByName("Greater Nature Protection Potion")
            end       
        elseif mb_isAtSkeram() and mb_spellReady("Intimidating Shout") then
            CastSpellByName("Intimidating Shout")
        end
    end

	if (MB_mySpecc == "BT" or MB_mySpecc == "MS") then
		
        if MB_useBigCooldowns.Active then			
			mb_warriorReck()
		end

		if MB_useCooldowns.Active then			
			mb_warriorCooldowns()
		end

		Warrior:DPSSingle()
		return

	elseif (MB_mySpecc == "Prottank" or MB_mySpecc == "Furytank") then

		if Instance.AQ40 then			
			if mb_hasBuffOrDebuff("True Fulfillment", "target", "debuff") then
                TargetByName("The Prophet Skeram")
            end

			mb_anubisathAlert()
		end

		Warrior:TankSingle()
		return
	end
end

MB_mySingleList["Warrior"] = WarriorSingle

--[####################################################################################################]--
--[####################################### Single Damage Code! ########################################]--
--[####################################################################################################]--

function Warrior:DPSSingle()

    if not mb_warriorIsBerserker() then
        mb_warriorSetBerserker()
        return
    end

    if not UnitName("target") then
        return
    end

    mb_autoAttack()
    mb_annihilatorWeaving()

    if mb_spellReady("Bloodrage") and UnitMana("player") < 20 then        
        CastSpellByName("Bloodrage")
    end

    if MB_doInterrupt.Active and mb_spellReady(MB_myInterruptSpell[myClass]) then
        if UnitMana("player") >= 10 then
            if mb_imBusy() then		
                SpellStopCasting()
            end

            CastSpellByName(MB_myInterruptSpell[myClass])
            mb_coolDownPrint("Interrupting!")
            MB_doInterrupt.Active = false
            return
        end
    end

    mb_selfBuff("Battle Shout")

    if not mb_mobsNoSunders() and UnitInRaid("player") and GetNumRaidMembers() > 5 then
        if not mb_hasBuffOrDebuff("Expose Armor", "target", "debuff") and mb_debuffSunderAmount() < 5 then
            CastSpellByName("Sunder Armor")
        end
    end

    if (mb_debuffSunderAmount() == 5 or mb_hasBuffOrDebuff("Expose Armor", "target", "debuff")) 
        and (mb_inMeleeRange() or mb_tankTarget("Ragnaros")) then

        if mb_spellReady("Recklessness") and mb_bossIShouldUseRecklessnessOn() then
            mb_warriorReck()
        end

        if Instance.IsWorldBoss() then
            mb_warriorCooldowns()
        end

        mb_meleeTrinkets()
    end

    mb_warriorExecute()

    if MB_mySpecc == "BT" then

        if UnitMana("player") > 30 and mb_spellReady("Bloodthirst") then            
            CastSpellByName("Bloodthirst")
        end

        if not mb_isExcludedWW() then
            if UnitMana("player") > 25 and mb_spellReady("Whirlwind") and mb_inMeleeRange() then
                if not mb_spellReady("Bloodthirst") then
                    CastSpellByName("Whirlwind")
                end
            end
        end

        if UnitMana("player") > 55 then            
            CastSpellByName("Heroic Strike")
        end

    elseif MB_mySpecc == "MS" then

        if UnitMana("player") > 30 and mb_spellReady("Mortal Strike") then            
            CastSpellByName("Mortal Strike")
        end

        if not mb_isExcludedWW() then
            if UnitMana("player") > 25 and mb_spellReady("Whirlwind") and mb_inMeleeRange() then
                if not mb_spellReady("Mortal Strike") then
                    CastSpellByName("Whirlwind")
                end
            end
        end

        if UnitMana("player") > 85 then            
            CastSpellByName("Heroic Strike")
        end
    end

    if UnitFactionGroup("player") ~= "Alliance" then	
        if UnitMana("player") > 85 then            
            CastSpellByName("Hamstring")
        end
    end
end

--[####################################################################################################]--
--[######################################## Single Tank Code! #########################################]--
--[####################################################################################################]--

function Warrior:TankSingle()

	if mb_findInTable(MB_raidTanks, myName) and mb_hasBuffOrDebuff("Greater Blessing of Salvation", "player", "buff") then		
		CancelBuff("Greater Blessing of Salvation") 
	end

	if mb_inCombat("player") then
        if Instance.Naxx then

            if mb_tankTarget("Patchwerk") and MB_myPatchwerkBoxStrategy then

                if mb_healthPct("target") <= 0.05 then
                    mb_selfBuff("Last Stand")

                    if mb_hasShield() then                     
                        mb_selfBuff("Shield Wall")
                    end
                end

                if mb_haveInBags("Juju Escape") and not mb_isItemInBagCoolDown("Juju Escape") then                    
                    TargetUnit("player")
                    UseItemByName("Juju Escape")
                    TargetLastTarget()
                end

                if mb_haveInBags("Greater Stoneshield Potion") and not mb_isItemInBagCoolDown("Greater Stoneshield Potion") then                    
                    UseItemByName("Greater Stoneshield Potion")
                end

            elseif mb_tankTarget("Maexxna") and MB_myMaexxnaBoxStrategy then
                if mb_myNameInTable(MB_myMaexxnaMainTank) then
                    for _, buff in ipairs({"Prayer of Spirit", "Arcane Brilliance", "Divine Spirit", "Prayer of Shadow Protection"}) do
                        if mb_hasBuffOrDebuff(buff, "player", "buff") then
                            CancelBuff(buff)
                        end
                    end
                end
            end

        elseif Instance.AQ40 and mb_tankTarget("Princess Huhuran") then
            
            if mb_healthPct("target") <= MB_myHuhuranTankDefensivePercentage and MB_myHuhuranBoxStrategy then
                mb_selfBuff("Last Stand")

                if mb_hasShield() then                     
                    mb_selfBuff("Shield Wall")
                end
            end

        elseif Instance.BWL then

            if mb_tankTarget("Vaelastrasz the Corrupt") and mb_inMeleeRange() then         
                mb_selfBuff("Death Wish") 	
                
                if mb_hasBuffOrDebuff("Burning Adrenaline", "player", "debuff") then

                    mb_selfBuff("Last Stand")

                    if mb_hasShield() then                     
                        mb_selfBuff("Shield Wall")
                    end
                end

            elseif mb_tankTarget("Firemaw") then

                if mb_haveInBags("Juju Ember") and not mb_isItemInBagCoolDown("Juju Ember") and not mb_hasBuffOrDebuff("Juju Ember", "player", "buff") then 
                    TargetUnit("player")
                    UseItemByName("Juju Ember")
                    TargetLastTarget()
                end

                if mb_healthPct("target") <= 0.15 and mb_healthPct("player") <= 0.3 then
                    mb_selfBuff("Last Stand")

                    if mb_hasShield() then                     
                        mb_selfBuff("Shield Wall")
                    end                    
                end

            elseif mb_tankTarget("Chromaggus") and mb_healthPct("target") <= 0.07 and  mb_healthPct("player") <= 0.3 then

                mb_selfBuff("Last Stand")

                if mb_hasShield() then                     
                    mb_selfBuff("Shield Wall")
                end
            end
        
        elseif Instance.AQ20 and mb_tankTarget("Ossirian the Unscarred") then
            if mb_healthPct("target") <= MB_myOssirianTankDefensivePercentage and MB_myOssirianBoxStrategy then
                if mb_healthPct("player") <= 0.3 then
                    
                    mb_selfBuff("Last Stand")

                    if mb_hasShield() then                     
                        mb_selfBuff("Shield Wall")
                    end
                end
            end
        end

		if mb_healthPct("player") <= 0.25 then			
			if mb_itemNameOfEquippedSlot(13) == "Lifegiving Gem" and not mb_trinketOnCD(13) then 
				use(13)

			elseif mb_itemNameOfEquippedSlot(14) == "Lifegiving Gem" and not mb_trinketOnCD(14) then 
				use(14)
			end
		end

		if not (mb_tankTarget("Patchwerk") or mb_tankTarget("Maexxna")) then			
			if mb_healthPct("player") <= 0.2 then				
				mb_selfBuff("Last Stand") 
			end
		end

		if mb_inMeleeRange() then
			if (mb_debuffSunderAmount() == 5 or mb_hasBuffOrDebuff("Expose Armor", "target", "debuff")) then			
				mb_meleeTrinkets()
			end

			if mb_knowSpell("Concussion Blow") and mb_spellReady("Concussion Blow") and mb_stunnableMob() then	
				CastSpellByName("Concussion Blow")
			end

            if mb_spellReady("Disarm") and not mb_hasBuffOrDebuff("Disarm", "target", "debuff") then
                local name = UnitName("target")
                local hp = mb_healthPct("target")

                if name == "Gurubashi Axe Thrower"
                or (hp < 0.5 and (name == "Infectious Ghoul" or name == "Plagued Ghoul"))
                or (hp <= 0.21 and (name == "Anubisath Sentinel" or name == "Anubisath Defender")) then
                    CastSpellByName("Disarm")
                end
            end

			if mb_healthPct("player") < 0.85 and UnitMana("player") >= 20 and mb_hasShield() then				
				CastSpellByName("Shield Block") 
			end

			if UnitName("target") ~= "Emperor Vek\'nilash" or UnitName("target") ~= "Emperor Vek\'lor" then				
				if not mb_hasBuffOrDebuff("Demoralizing Shout", "target", "debuff") and UnitMana("player") >= 20 then					
					CastSpellByName("Demoralizing Shout")
				end
			end
		end
	end

	mb_offTank()

	if UnitName("target") and mb_crowdControlledMob() and not myName == MB_raidLeader then
        ClearTarget()
        return
    end

    local tOfTarget = UnitName("targettarget") or ""
    local tName = UnitName("target") or ""

    local shouldTaunt = tName ~= "" 
        and tOfTarget ~= "" and tOfTarget ~= "Unknown" 
        and UnitIsEnemy("player", "target") 
        and not mb_findInTable(MB_raidTanks, tOfTarget)

    if shouldTaunt then
        if MB_myOTTarget then
            if tOfTarget ~= myName then
                mb_warriorTaunt()
            end
        else
            mb_warriorTaunt()
        end
    end

	if MB_myOTTarget then
		if UnitExists("target") and GetRaidTargetIndex("target") and GetRaidTargetIndex("target") == MB_myOTTarget and UnitIsDead("target") then
			MB_myOTTarget = nil
			ClearTarget()
		end
	end

    if not mb_warriorIsDefensive() then
        mb_warriorSetDefensive()
        return
    end
	
    mb_autoAttack()

    if mb_spellReady("Bloodrage") and UnitMana("player") < 15 then        
        CastSpellByName("Bloodrage")
    end

    if MB_doInterrupt.Active and mb_spellReady("Shield Bash") then
        if UnitMana("player") >= 10 then
            if mb_imBusy() then		
                SpellStopCasting()
            end

			CastSpellByName("Shield Bash")
            mb_coolDownPrint("Interrupting!")
            MB_doInterrupt.Active = false
		end
	end
    
    mb_selfBuff("Battle Shout")
    
    if UnitMana("player") >= 5 and mb_spellReady("Revenge") then        
        CastSpellByName("Revenge")
    end
    
    if MB_mySpecc == "Prottank" then
        if mb_spellReady("Shield Slam") and UnitMana("player") >= 20 and mb_hasShield() then        
            CastSpellByName("Shield Slam")
        end

    elseif MB_mySpecc == "Furytank" then
        if mb_spellReady("Bloodthirst") and UnitMana("player") >= 30 then            
            CastSpellByName("Bloodthirst")
        end	
    end
    
    if UnitName("target") ~= "Deathknight Understudy" and not mb_hasBuffOrDebuff("Expose Armor", "target", "debuff") then        
        CastSpellByName("Sunder Armor")
    end

    if mb_hasBuffOrDebuff("Expose Armor", "target", "debuff") then
        if (not mb_spellReady("Bloodthirst") and UnitMana("player") >= 23) or UnitMana("player") >= 43 then
            CastSpellByName("Heroic Strike")
        end
    else
        if UnitMana("player") >= 43 then
            CastSpellByName("Heroic Strike")
        end
    end
end

--[####################################################################################################]--
--[########################################## Multi Code! #############################################]--
--[####################################################################################################]--

MB_myMultiList["Priest"] = PriestSingle

--[####################################################################################################]--
--[########################################### AOE Code! ##############################################]--
--[####################################################################################################]--

local function PriestAOE()

	if mb_tankTarget("Maexxna") and MB_myMaexxnaBoxStrategy then
		if MB_myAssignedHealTarget then		
			if mb_isAlive(MBID[MB_myAssignedHealTarget]) then			
				Priest:MTHeals(MB_myAssignedHealTarget)
				return
			else			
				MB_myAssignedHealTarget = nil
				RunLine("/raid My healtarget died, time to ALT-F4.")
			end
		end

		if mb_myNameInTable(MB_myMaexxnaPriestHealer) then			
			Priest:MaxRenewAggroedPlayer()
			Priest:MaxShieldAggroedPlayer()
			return
		end
	end

	PriestSingle()
end

MB_myAOEList["Priest"] = PriestAOE

--[####################################################################################################]--
--[########################################## SETUP Code! #############################################]--
--[####################################################################################################]--

local function PriestSetup()

	if UnitMana("player") < 3060 and mb_hasBuffNamed("Drink", "player") then
		return
	end

	if not MB_autoBuff.Active then
		MB_autoBuff.Active = true
		MB_autoBuff.Time = GetTime() + 0.25
		PriestCounter.Cycle()
	end

	if mb_myClassAlphabeticalOrder() == MB_buffingCounterPriest then
		mb_selfBuff("Inner Focus")
		mb_multiBuff("Prayer of Fortitude")

		if Instance.Naxx or Instance.AQ40 then
			if mb_knowSpell("Prayer of Spirit") then				
				mb_multiBuff("Prayer of Spirit")
			end
		end

		if Instance.Naxx and not mb_isAtInstructorRazuvious() then										
			mb_multiBuff("Prayer of Shadow Protection")
		end

		if mb_spellReady("Fear Ward") and mb_mobsToFearWard() then
			mb_multiBuff("Fear Ward")
		end
	end

	mb_selfBuff("Inner Fire")
	mb_selfBuff("Shadowform")

	if not mb_inCombat("player") and mb_manaPct("player") < 0.20 and not mb_hasBuffNamed("Drink", "player") then
		mb_smartDrink()
	end
end

MB_mySetupList["Priest"] = PriestSetup

--[####################################################################################################]--
--[######################################### PRECAST Code! ############################################]--
--[####################################################################################################]--

local function PriestPreCast()
	for k, trinket in pairs(MB_casterTrinkets) do
		if mb_itemNameOfEquippedSlot(13) == trinket and not mb_trinketOnCD(13) then 
			use(13) 
		end

		if mb_itemNameOfEquippedSlot(14) == trinket and not mb_trinketOnCD(14) then 
			use(14) 
		end
	end

	CastSpellByName("Holy Fire")
end

MB_myPreCastList["Priest"] = PriestPreCast

--[####################################################################################################]--
--[########################################## Helper Code! ############################################]--
--[####################################################################################################]--

function Priest:Fade()
	local aggrox = AceLibrary("Banzai-1.0")

	if aggrox and aggrox:GetUnitAggroByUnitId("player") then
		mb_selfBuff("Fade")
	end
end

function Priest:Cooldowns()
	if mb_imBusy() or not mb_inCombat("player") then
		return
	end

	mb_selfBuff("Berserking")

	if mb_manaPct("player") <= MB_priestInnerFocusPercentage then
		mb_selfBuff("Inner Focus")
	end

	mb_healerTrinkets()
	mb_casterTrinkets()
end

function Priest:PrayerOfHealingCheck(manaRank, checkRank, minTargets, focus)
    local cost = PrayerManaCost[manaRank]
    if not cost then return false end

	if not checkRank then
		checkRank = manaRank
	end

    if UnitMana("player") >= cost then
        if mb_partyHurt(GetHealValueFromRank("Prayer of Healing", "Rank "..checkRank), minTargets) then
            if focus then
                mb_selfBuff("Inner Focus")
            end

            CastSpellByName("Prayer of Healing (Rank "..manaRank..")")
            return true
        end
    end
    return false
end

function Priest:GetActiveVaelastraszPriest()
    for _, priestName in ipairs(MB_myVaelastraszPriests) do
        if not mb_dead(MBID[priestName]) then
            return priestName
        end
    end
    return nil
end

function Priest:ManaDrain()
	if mb_imBusy() then
		return false
	end

	if (Instance.AQ40 and mb_tankTarget("Obsidian Eradicator")) or
		(Instance.AQ20 and mb_tankTarget("Moam")) then
		if mb_manaPct("target") > 0.25 then
			mb_castSpellOrWand("Mana Burn")
			return true
		end
	end
	return false
end

function Priest:PowerInfusion()
	if mb_imBusy() then
		return false
	end

	if not (mb_inCombat("player") and mb_spellReady("Power Infusion")) then
		return
	end

	if not MB_autoBuff.Active then
		MB_autoBuff.Active = true
		MB_autoBuff.Time = GetTime() + 2.5
		PriestCounter.Cycle()
	end

	if mb_myClassAlphabeticalOrder() == MB_buffingCounterPriest then
		for k, caster in pairs(MB_raidAssist.Priest.PowerInfusionList) do
			if MBID[caster] then
				if mb_isValidFriendlyTargetWithin28YardRange(MBID[caster]) 
					and not mb_hasBuffOrDebuff("Power Infusion", MBID[caster], "buff") 
					and mb_inCombat(MBID[caster]) 
					and mb_manaPct(MBID[caster]) < 0.9 
					and mb_manaPct(MBID[caster]) > 0.1 then

					TargetByName(caster)
					CastSpellByName("Power Infusion")
					mb_message("Power Infusion on "..GetColors(UnitName(MBID[caster])).."!")
					return
				end
			end
		end
	end
end

--[####################################################################################################]--
--[######################################### LOATHEB Code! ############################################]--
--[####################################################################################################]--

local function PriestLoathebHeal()

	if mb_loathebHealing() then
		return
	end
	
	if mb_inCombat("player") then
		Priest:PowerInfusion()

		mb_takeManaPotionAndRune()
		mb_takeManaPotionIfBelowManaPotMana()
		mb_takeManaPotionIfBelowManaPotManaInRazorgoreRoom()

		if mb_manaDown("player") > 600 then
            Priest:Cooldowns()
        end

		if Priest:ManaDrain() then
            return
        end

		if mb_spellReady("Desperate Prayer") and mb_healthPct("player") < 0.2 then			
			CastSpellByName("Desperate Prayer")
			return
		end
	end

	mb_coolDownCast("Smite", 8)
	mb_healerWand()
end

MB_myLoathebList["Priest"] = PriestLoathebHeal