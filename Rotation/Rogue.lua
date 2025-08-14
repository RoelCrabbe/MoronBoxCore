--[####################################################################################################]--
--[######################################## START ROGUE CODE! #########################################]--
--[####################################################################################################]--

local Rogue = CreateFrame("Frame", "Rogue")

local myClass = UnitClass("player")
local myName = UnitName("player")
local myFaction = UnitFactionGroup("player")

if myClass ~= "Rogue" then
    return
end

--[####################################################################################################]--
--[########################################## SETUP Code! #############################################]--
--[####################################################################################################]--

local function RogueSpecc()
    local TalentsIn, TalentsInA

    _, _, _, _, TalentsIn = GetTalentInfo(3, 15)
    if TalentsIn > 0 then
        MB_mySpecc = "Hemo"
        return 
    end

    _, _, _, _, TalentsIn = GetTalentInfo(2, 19)
    if TalentsIn > 0 then
        MB_mySpecc = "AR"
        return 
    end

    MB_mySpecc = nil
end

local function ImprovedExposeCheck()
    local _, _, _, _, TalentsIn = GetTalentInfo(1, 8)
    if TalentsIn == 2 then
		return true
	end
	return false
end

MB_mySpeccList["Rogue"] = WarriorSpecc

--[####################################################################################################]--
--[########################################## Single Code! ############################################]--
--[####################################################################################################]--

local function RogueSingle()

	mb_getTarget()

	if not mb_inCombat("target") then
        return
    end

	if MB_useCooldowns.Active then		
		Rogue:Cooldowns()
	end

	mb_autoAttack()

	if mb_inCombat("player") and UnitMana("player") <= 40 then		
		if mb_itemNameOfEquippedSlot(13) == "Renataki\'s Charm of Trickery" and not mb_trinketOnCD(13) then 
			use(13)

		elseif mb_itemNameOfEquippedSlot(14) == "Renataki\'s Charm of Trickery" and not mb_trinketOnCD(14) then 
			use(14)
		end
	end

    if MB_doInterrupt.Active and mb_spellReady(MB_myInterruptSpell[myClass]) then
        if UnitMana("player") >= 25 then
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
    end

    local aggrox = AceLibrary("Banzai-1.0")
	if aggrox:GetUnitAggroByUnitId("player") then
        if mb_healthPct("player") < 0.8 and mb_spellReady("Evasion") then 		
            
            CastSpellByName("Evasion") 
            return
        
        elseif mb_healthPct("player") < 0.45 and mb_spellReady("Vanish") then 
		
            CastSpellByName("Vanish") 
            return
        end
	end

	if not mb_inMeleeRange() then
		return
    end

    local cp = GetComboPoints("target")
    if mb_spellReady("Kidney Shot") and cp >= 3 and mb_stunnableMob() then			
        CastSpellByName("Kidney Shot")
    end

    if mb_spellReady("Blade Flurry") and mb_hasBuffOrDebuff("Slice and Dice", "player", "buff") then			
        CastSpellByName("Blade Flurry") 
    end

    if (mb_debuffSunderAmount() == 5 or mb_hasBuffOrDebuff("Expose Armor", "target", "debuff")) 
        and (mb_inMeleeRange() or mb_tankTarget("Ragnaros")) then

        if Instance.IsWorldBoss() then
            Rogue:Cooldowns()
        end

        mb_meleeTrinkets()
    end

    local hasImprovedEA = ImprovedExposeCheck()
    if not mb_hasBuffOrDebuff("Slice and Dice", "player", "buff") then
        if hasImprovedEA then
            if cp == 2 and mb_hasBuffOrDebuff("Expose Armor", "target", "debuff") then                
                CastSpellByName("Slice and Dice")
            end
        else
            if cp >= 1 then                
                CastSpellByName("Slice and Dice")
            end
        end
    end

    if cp > 4 then
        if hasImprovedEA and Instance.IsWorldBoss() then
            CastSpellByName("Expose Armor")
        else
            CastSpellByName("Eviscerate")
        end
    end

	if MB_mySpecc == "Hemo" then		
		CastSpellByName("Hemorrhage")
        return
    end

	CastSpellByName("Sinister Strike")
end

MB_mySingleList["Rogue"] = RogueSingle

--[####################################################################################################]--
--[########################################## Multi Code! #############################################]--
--[####################################################################################################]--

MB_myMultiList["Rogue"] = RogueSingle

--[####################################################################################################]--
--[########################################### AOE Code! ##############################################]--
--[####################################################################################################]--

MB_myAOEList["Rogue"] = RogueSingle

--[####################################################################################################]--
--[########################################## SETUP Code! #############################################]--
--[####################################################################################################]--

local function RogueSetup()
	if myFaction == "Alliance" then
		mb_roguePoisonMainHand()
	end

	mb_roguePoisonOffhand()
end

MB_mySetupList["Rogue"] = RogueSetup

--[####################################################################################################]--
--[########################################## Helper Code! ############################################]--
--[####################################################################################################]--

function Rogue:Cooldowns()
	if mb_imBusy() or not mb_inCombat("player") then
		return
	end

    if mb_spellReady("Blade Flurry") and mb_hasBuffOrDebuff("Slice and Dice", "player", "buff") then 
        CastSpellByName("Blade Flurry") 
    end

    mb_selfBuff("Berserking")
    mb_selfBuff("Blood Fury") 

    if mb_spellReady("Adrenaline Rush") then			
        CastSpellByName("Adrenaline Rush")
    end
end

function mb_roguePoisonOffhand() -- Poisen OT
	if mb_haveInBags("Instant Poison VI") then
		has_enchant_main, mx, mc, has_enchant_off = GetWeaponEnchantInfo()
	
		if not has_enchant_off then
			
			UseItemByName("Instant Poison VI")
			PickupInventoryItem(17)	
			ClearCursor()
		end
	end
end

function mb_roguePoisonMainHand() -- Poisen MH
	if mb_haveInBags("Instant Poison VI") then
		has_enchant_main, mx, mc, has_enchant_off = GetWeaponEnchantInfo()
		
		if not has_enchant_main then
			
			UseItemByName("Instant Poison VI")
			PickupInventoryItem(16)	
			ClearCursor()
		end
	end
end