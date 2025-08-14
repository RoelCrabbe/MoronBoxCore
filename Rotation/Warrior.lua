--[####################################################################################################]--
--[###################################### START WARRIOR CODE! #########################################]--
--[####################################################################################################]--

local Warrior = CreateFrame("Frame", "Warrior")

local myClass = UnitClass("player")
local myName = UnitName("player")

if myClass ~= "Warrior" then
    return
end

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
			Warrior:BigCooldowns()
		end

		if MB_useCooldowns.Active then			
			Warrior:Cooldowns()
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
    Warrior:Annihilator()

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
            Warrior:BigCooldowns()
        end

        if Instance.IsWorldBoss() then
            Warrior:Cooldowns()
        end

        mb_meleeTrinkets()
    end

    Warrior:Execute()

    if MB_mySpecc == "BT" then

        if UnitMana("player") >= 30 and mb_spellReady("Bloodthirst") then            
            CastSpellByName("Bloodthirst")
        end

        if not mb_isExcludedWW() then
            if UnitMana("player") >= 25 and mb_spellReady("Whirlwind") and mb_inMeleeRange() then
                if not mb_spellReady("Bloodthirst") then
                    CastSpellByName("Whirlwind")
                end
            end
        end

        if UnitMana("player") > 55 then            
            CastSpellByName("Heroic Strike")
        end

    elseif MB_mySpecc == "MS" then

        if UnitMana("player") >= 30 and mb_spellReady("Mortal Strike") then            
            CastSpellByName("Mortal Strike")
        end

        if not mb_isExcludedWW() then
            if UnitMana("player") >= 25 and mb_spellReady("Whirlwind") and mb_inMeleeRange() then
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

local function WarriorTankSingleRotation()
    if MB_mySpecc == "Prottank" then
        if mb_spellReady("Shield Slam") and UnitMana("player") >= 20 and Warrior:HasShield() then        
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

function Warrior:TankSingle()

	if mb_findInTable(MB_raidTanks, myName) and mb_hasBuffOrDebuff("Greater Blessing of Salvation", "player", "buff") then		
		CancelBuff("Greater Blessing of Salvation") 
	end

	if mb_inCombat("player") then
        if Instance.Naxx then

            if mb_tankTarget("Patchwerk") and MB_myPatchwerkBoxStrategy then
                if mb_healthPct("target") <= 0.05 then
                    mb_selfBuff("Last Stand")

                    if Warrior:HasShield() then                     
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

                if Warrior:HasShield() then                     
                    mb_selfBuff("Shield Wall")
                end
            end

        elseif Instance.BWL then

            if mb_tankTarget("Vaelastrasz the Corrupt") and mb_inMeleeRange() then         
                mb_selfBuff("Death Wish") 	
                
                if mb_hasBuffOrDebuff("Burning Adrenaline", "player", "debuff") then

                    mb_selfBuff("Last Stand")

                    if Warrior:HasShield() then                     
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

                    if Warrior:HasShield() then                     
                        mb_selfBuff("Shield Wall")
                    end                    
                end

            elseif mb_tankTarget("Chromaggus") and mb_healthPct("target") <= 0.07 and mb_healthPct("player") <= 0.3 then

                mb_selfBuff("Last Stand")

                if Warrior:HasShield() then                     
                    mb_selfBuff("Shield Wall")
                end
            end
        
        elseif Instance.AQ20 and mb_tankTarget("Ossirian the Unscarred") then
            if mb_healthPct("target") <= MB_myOssirianTankDefensivePercentage and MB_myOssirianBoxStrategy then
                if mb_healthPct("player") <= 0.3 then
                    
                    mb_selfBuff("Last Stand")

                    if Warrior:HasShield() then                     
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

			if mb_healthPct("player") < 0.85 and UnitMana("player") >= 20 and Warrior:HasShield() then				
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
                Warrior:Taunt()
            end
        else
            Warrior:Taunt()
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

    if mb_spellReady("Bloodrage") and UnitMana("player") <= 15 then        
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
    
    WarriorTankSingleRotation()
end

--[####################################################################################################]--
--[########################################## Multi Code! #############################################]--
--[####################################################################################################]--

local function WarriorMulti()

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
			Warrior:BigCooldowns()
		end

		if MB_useCooldowns.Active then			
			Warrior:Cooldowns()
		end
		
		Warrior:DPSMulti()
		return

	elseif (MB_mySpecc == "Prottank" or MB_mySpecc == "Furytank") then

		if Instance.AQ40 then			
			if mb_hasBuffOrDebuff("True Fulfillment", "target", "debuff") then
                TargetByName("The Prophet Skeram")
            end

			mb_anubisathAlert()
		end

		Warrior:TankMulti()
		return
	end
end

MB_myMultiList["Warrior"] = WarriorMulti

--[####################################################################################################]--
--[######################################## Multi Damage Code! ########################################]--
--[####################################################################################################]--

function Warrior:DPSMulti()

    if not UnitName("target") then
        return
    end

    mb_autoAttack()
    Warrior:Annihilator()

    if mb_spellReady("Bloodrage") and UnitMana("player") < 20 then        
        CastSpellByName("Bloodrage")
    end

	if MB_mySpecc == "MS" and mb_spellReady("Sweeping Strikes") then
        if not mb_warriorIsBattle() then
            mb_warriorSetBattle()
            return
        end 

        CastSpellByName("Sweeping Strikes")
        return
	end

    if not mb_warriorIsBerserker() then
        mb_warriorSetBerserker()
        return
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
            Warrior:BigCooldowns()
        end

        if Instance.IsWorldBoss() then
            Warrior:Cooldowns()
        end

        mb_meleeTrinkets()
    end

    Warrior:Execute()
    
    if MB_mySpecc == "BT" then

        if not mb_isExcludedWW() then
            if UnitMana("player") >= 25 and mb_spellReady("Whirlwind") and mb_inMeleeRange() then
                if not mb_spellReady("Bloodthirst") then
                    CastSpellByName("Whirlwind")
                end
            end
        end
        
        if not mb_spellReady("Whirlwind") and UnitMana("player") >= 25 then
            if mb_spellReady("Bloodthirst") and UnitMana("player") >= 30 then            
                CastSpellByName("Bloodthirst")
            end

            if not mb_spellReady("Bloodthirst") then                
                CastSpellByName("Cleave")
            end
        end
        
    elseif MB_mySpecc == "MS" then

        if not mb_isExcludedWW() then
            if UnitMana("player") >= 25 and mb_spellReady("Whirlwind") and mb_inMeleeRange() then
                if not mb_spellReady("Bloodthirst") then
                    CastSpellByName("Whirlwind")
                end
            end
        end
        
        if not mb_spellReady("Whirlwind") and UnitMana("player") >= 25 then
            if mb_spellReady("Mortal Strike") and UnitMana("player") >= 30 then        
                CastSpellByName("Mortal Strike")
            end

            if not mb_spellReady("Mortal Strike") then                
                CastSpellByName("Cleave")
            end
        end
    end
end

--[####################################################################################################]--
--[######################################### Multi Tank Code! #########################################]--
--[####################################################################################################]--

function Warrior:TankMulti()

	if mb_findInTable(MB_raidTanks, myName) and mb_hasBuffOrDebuff("Greater Blessing of Salvation", "player", "buff") then		
		CancelBuff("Greater Blessing of Salvation") 
	end

	if mb_inCombat("player") then
        if Instance.Naxx then

            if mb_tankTarget("Patchwerk") and MB_myPatchwerkBoxStrategy then
                if mb_healthPct("target") <= 0.05 then
                    mb_selfBuff("Last Stand")

                    if Warrior:HasShield() then                     
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

                if Warrior:HasShield() then                     
                    mb_selfBuff("Shield Wall")
                end
            end

        elseif Instance.BWL then

            if mb_tankTarget("Vaelastrasz the Corrupt") and mb_inMeleeRange() then         
                mb_selfBuff("Death Wish") 	
                
                if mb_hasBuffOrDebuff("Burning Adrenaline", "player", "debuff") then

                    mb_selfBuff("Last Stand")

                    if Warrior:HasShield() then                     
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

                    if Warrior:HasShield() then                     
                        mb_selfBuff("Shield Wall")
                    end                    
                end

            elseif mb_tankTarget("Chromaggus") and mb_healthPct("target") <= 0.07 and mb_healthPct("player") <= 0.3 then

                mb_selfBuff("Last Stand")

                if Warrior:HasShield() then                     
                    mb_selfBuff("Shield Wall")
                end
            end
        
        elseif Instance.AQ20 and mb_tankTarget("Ossirian the Unscarred") then
            if mb_healthPct("target") <= MB_myOssirianTankDefensivePercentage and MB_myOssirianBoxStrategy then
                if mb_healthPct("player") <= 0.3 then
                    
                    mb_selfBuff("Last Stand")

                    if Warrior:HasShield() then                     
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

			if mb_healthPct("player") < 0.85 and UnitMana("player") >= 20 and Warrior:HasShield() then				
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
                Warrior:Taunt()
            end
        else
            Warrior:Taunt()
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

    if Instance.Naxx and mb_isAtNoth() then

        WarriorTankSingleRotation()
        return
    elseif Instance.BWL and mb_tankTarget("Vaelastrasz the Corrupt") and MB_myVaelastraszBoxStrategy then
        
        WarriorTankSingleRotation()
        return
    elseif Instance.Ony and mb_tankTarget("Onyxia") and MB_myOnyxiaBoxStrategy then

        WarriorTankSingleRotation()
        return
    end 

    if UnitMana("player") >= 20 then        
        CastSpellByName("Cleave") 
    end
    
    if MB_mySpecc == "Prottank" then
        if mb_spellReady("Shield Slam") and UnitMana("player") >= 20 and Warrior:HasShield() then        
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
end

--[####################################################################################################]--
--[########################################### AOE Code! ##############################################]--
--[####################################################################################################]--

MB_myAOEList["Warrior"] = WarriorMulti

--[####################################################################################################]--
--[########################################## Helper Code! ############################################]--
--[####################################################################################################]--

function Warrior:BigCooldowns()
	if mb_imBusy() or not mb_inCombat("player") then
		return
	end

    mb_selfBuff("Recklessness")
	Warrior:Cooldowns()
end

function Warrior:Cooldowns()
	if mb_imBusy() or not mb_inCombat("player") then
		return
	end

    mb_selfBuff("Berserking")
    mb_selfBuff("Blood Fury") 

    if mb_spellReady("Death Wish") and UnitMana("player") >= 10 then        
        mb_selfBuff("Death Wish") 
    end

    mb_meleeTrinkets()
end

function Warrior:Annihilator()
    local weavers = MB_raidAssist.Warrior.AnnihilatorWeavers or {}

    if TableLength(weavers) == 0 or not MB_raidAssist.Warrior.Active or mb_isAtSkeram() then
        return
    end
	
    local function equipWeapon(slot, targetWeapon)
        if mb_itemNameOfEquippedSlot(slot) ~= targetWeapon then
            if mb_itemNameOfEquippedSlot(slot) then
                RunLine("/unequip "..mb_itemNameOfEquippedSlot(slot))
            end
            RunLine("/equip "..targetWeapon)
        end
    end

    for _, name in pairs(weavers) do
        if myName == name then
            local mh, oh
            if Instance.IsWorldBoss() then
                if mb_debuffAmountShatter() == 3 then
                    mh = mb_getWeaverWeapon(name, "NMH")
                    oh = mb_getWeaverWeapon(name, "NOH")
                else
                    mh = mb_getWeaverWeapon(name, "BMH")
                    oh = mb_getWeaverWeapon(name, "BOH")
                end
            else
                mh = mb_getWeaverWeapon(name, "NMH")
                oh = mb_getWeaverWeapon(name, "NOH")
            end

            equipWeapon(16, mh)
            equipWeapon(17, oh)
        end
    end
end

local function ImpExecute()
    local TalentsIn, TalentsInA

    _, _, _, _, TalentsIn = GetTalentInfo(2, 10)
	if TalentsIn > 1 then
		return true
    end
	return nil	
end

function Warrior:Execute()
    local targetName = UnitName("target")
    if not targetName then
        return
    end

    local targetType = UnitCreatureType("target")
    local slot13, slot14 = mb_itemNameOfEquippedSlot(13), mb_itemNameOfEquippedSlot(14)

    local undeadBonus = 0

    if (targetType == "Undead" or targetType == "Demon") and 
       (slot13 == "Mark of the Champion" or slot14 == "Mark of the Champion") then
        undeadBonus = undeadBonus + 150
    end

    if (targetType == "Undead" or targetType == "Demon") and 
       (slot13 == "Seal of the Dawn" or slot14 == "Seal of the Dawn") then
        undeadBonus = undeadBonus + 81
    end

    local a, b, c = UnitAttackPower("player")
    local apTotal = a + b + c + undeadBonus
    local btDamage = apTotal * 0.45
    local impExeValue = ImpExecute() and 900 or 820

    if mb_healthPct("target") < 0.20 then
        if impExeValue >= btDamage then
            CastSpellByName("Execute")
        elseif btDamage >= impExeValue and mb_spellReady("Bloodthirst") then
            CastSpellByName("Bloodthirst")
        else
            CastSpellByName("Execute")
        end
    end
end

function Warrior:HasShield()
	local offhandLink = GetInventoryItemLink("player", GetInventorySlotInfo("SecondaryHandSlot"))
	if offhandLink then
		local itemId, permEnchant, tempEnchant, suffix, itemName = string.gfind(offhandLink, "|Hitem:(.-):(.-):(.-):(.-)|h%[(.-)%]|h")()
		local _, _, _, _, _, itemType = GetItemInfo(itemId)
		return itemType == "Shields"
	else
		return false
	end
end

function Warrior:Taunt()

	if mb_spellReady("Taunt") then
		mb_warriorSetDefensive()
		CastSpellByName("Taunt")
		return
	end

	if mb_iamFocus() then
        return
    end
	
    if MB_mySpecc ~= "Prottank" then
        return
    end

	if mb_spellReady("Mocking Blow") and UnitMana("player") >= 10 then
		if mb_warriorIsBattle() then
			CastSpellByName("Mocking Blow")
		else
			mb_warriorSetBattle()
		end
	end
end