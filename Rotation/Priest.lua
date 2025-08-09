--[####################################################################################################]--
--[####################################### START PRIEST CODE! #########################################]--
--[####################################################################################################]--

local myClass = UnitClass("player")
local myName = UnitName("player")
local tName = UnitName("target")
local myZone = GetRealZoneText()

local PriestCounter = {
    Cycle = function()
        MB_buffingCounterPriest = (MB_buffingCounterPriest >= TableLength(MB_classList["Priest"]))
                                  and 1 or (MB_buffingCounterPriest + 1)
    end
}

--[####################################################################################################]--
--[########################################## SETUP Code! #############################################]--
--[####################################################################################################]--

local function getPriestSpecc()
    local TalentsIn, TalentsInA
    _, _, _, _, TalentsIn = GetTalentInfo(2, 10)
    _, _, _, _, TalentsInA = GetTalentInfo(3, 11)
    if TalentsIn > 0 and TalentsInA > 3 then
        MB_mySpecc = "Bitch"
        return
    end
    _, _, _, _, TalentsIn = GetTalentInfo(1, 15)
    _, _, _, _, TalentsInA = GetTalentInfo(3, 11)
    if TalentsIn > 0 and TalentsInA == 5 then
        MB_mySpecc = "Bitch"
        return
    end
    _, _, _, _, TalentsIn = GetTalentInfo(3, 16)
    if TalentsIn > 0 then
        MB_mySpecc = "Shadow"
        return
    end
    MB_mySpecc = nil
end

MB_mySpeccList["Priest"] = getPriestSpecc

local function PriestFade()
	local aggrox = AceLibrary("Banzai-1.0")
	if aggrox and aggrox:GetUnitAggroByUnitId("player") then
		mb_selfBuff("Fade")
	end
end

--[####################################################################################################]--
--[######################################### HEALING Code! ############################################]--
--[####################################################################################################]--

local function PriestHeal()

	if mb_inCombat("player") then
		if MB_raidLeader and mb_myClassOrder() == 1 and (mb_tankTarget("Garr") or mb_tankTarget("Firesworn")) then
			if mb_hasBuffOrDebuff("Magma Shackles", MBID[MB_raidLeader], "debuff") then
				
				TargetUnit(MBID[MB_raidLeader])
				CastSpellByName("Dispel Magic")
				TargetLastTarget()
			end
		end

		mb_powerInfusionBuff()

		mb_takeManaPotionAndRune()
		mb_takeManaPotionIfBelowManaPotMana()
		mb_takeManaPotionIfBelowManaPotManaInRazorgoreRoom()

		if mb_manaDown("player") > 600 then
            mb_priestCooldowns()
        end

		if mb_priestManaDrain() then
            return
        end

		if mb_spellReady("Desperate Prayer") and mb_healthPct("player") < 0.2 then			
			CastSpellByName("Desperate Prayer")
			return
		end
	end

	if mb_hasBuffOrDebuff("Curse of Tongues", "player", "debuff") and not mb_tankTarget("Anubisath Defender") then
        return
    end

	if mb_healLieutenantAQ20() then
        return
    end

	if mb_instructorRazAddsHeal() then
        return
    end

	if MB_myAssignedHealTarget then		
		if mb_isAlive(MBID[MB_myAssignedHealTarget]) then			
			mb_priestMTHeals(MB_myAssignedHealTarget)
			return
		else			
			MB_myAssignedHealTarget = nil
			RunLine("/raid My healtarget died, time to ALT-F4.")
		end
	end

	for k, BossName in pairs(MB_myPriestMainTankHealingBossList) do
		if mb_tankTarget(BossName) then			
			mb_priestMTHeals()
			return
		end
	end

	if MB_isMoving.Active then
        mb_castSpellOnRandomRaidMember("Renew", MB_priestRenewLowRandomRank, MB_priestRenewLowRandomPercentage)
    end	

	if Instance.AQ40 then
		if mb_tankTarget("Princess Huhuran") then			
			if mb_healthPct("target") <= 0.32 then			
				if (UnitMana("player") > 855) and mb_partyHurt(GetHealValueFromRank("Prayer of Healing", "Rank 1"), 3) then

					mb_selfBuff("Inner Focus") 
					CastSpellByName("Prayer of Healing(rank 4)") 
					return 
				end
	
				MBH_CastHeal("Flash Heal", 4, 6)
			else
				MBH_CastHeal("Heal")
			end
		end

	elseif GetRealZoneText() == "Blackwing Lair" then
		if mb_tankTarget("Vaelastrasz the Corrupt") and MB_myVaelastraszBoxStrategy then

			mb_priestCooldowns()

			if MB_myVaelastraszPriestHealing and not mb_hasBuffOrDebuff("Burning Adrenaline", "player", "debuff") then
				if myName == MB_myVaelastraszPriestOne then
					
					mb_priestMaxRenewAggroedPlayer()
					mb_priestShieldAggroedPlayer()								

				elseif myName == MB_myVaelastraszPriestTwo and mb_dead(MBID[MB_myVaelastraszPriestOne]) then

					mb_priestMaxRenewAggroedPlayer()
					mb_priestShieldAggroedPlayer()					

				elseif myName == MB_myVaelastraszPriestThree and mb_dead(MBID[MB_myVaelastraszPriestOne]) and mb_dead(MBID[MB_myVaelastraszPriestTwo]) then

					mb_priestMaxRenewAggroedPlayer()
					mb_priestShieldAggroedPlayer()						
				else
					mb_giveShieldToBombFollowTarget()
				end
			end

			if (UnitMana("player") > 875) and mb_partyHurt(GetHealValueFromRank("Prayer of Healing", "Rank 1"), 3) then
				
				mb_selfBuff("Inner Focus") 
				CastSpellByName("Prayer of Healing(rank 5)") 
				return
			end
	
			MBH_CastHeal("Flash Heal", 7, 7)
			return

		elseif mb_tankTarget("Nefarian") then

			if mb_hasBuffOrDebuff("Corrupted Healing", "player", "debuff") then

				if mb_imBusy() then
					
					SpellStopCasting()
				end

				if mb_spellReady("Power Word: Shield") then 
					
					mb_castSpellOnRandomRaidMember("Weakened Soul", "rank 10", 0.9)
				end	
				
				mb_castSpellOnRandomRaidMember("Renew", "rank 10", 0.95)
				return 
			end

		elseif mb_tankTarget("Chromaggus") and not MB_myHealSpell == "Flash Heal" then

			MB_myHealSpell = "Flash Heal"
		end
	end

	if not mb_imBusy() then

		if mb_myGroupClassOrder() == 1 then
			if (UnitMana("player") > 875) and mb_partyHurt(GetHealValueFromRank("Prayer of Healing", "Rank 5"), 4) then
				
				mb_selfBuff("Inner Focus") 
				CastSpellByName("Prayer of Healing(rank 5)") 
				return
				
			elseif (UnitMana("player") > 825) and mb_partyHurt(GetHealValueFromRank("Prayer of Healing", "Rank 4"), 4) then
				
				mb_selfBuff("Inner Focus") 
				CastSpellByName("Prayer of Healing(rank 4)") 
				return			

			elseif (UnitMana("player") > 650) and mb_partyHurt(GetHealValueFromRank("Prayer of Healing", "Rank 3"), 4) then 
				
				CastSpellByName("Prayer of Healing(rank 3)") 
				return 

			elseif (UnitMana("player") > 500) and mb_partyHurt(GetHealValueFromRank("Prayer of Healing", "Rank 2"), 4) then 
				
				CastSpellByName("Prayer of Healing(rank 2)") 
				return 

			elseif (UnitMana("player") > 350) and mb_partyHurt(GetHealValueFromRank("Prayer of Healing", "Rank 1"), 4) then 
				
				CastSpellByName("Prayer of Healing(rank 1)") 
				return 
			end
		end

		if mb_inCombat("player") then -- No AOE or Hots when not inCombat		

			if mb_spellReady("Power Word: Shield") then 

				mb_priestShieldAggroedPlayer() -- Shield on agro player
				mb_castSpellOnRandomRaidMember("Weakened Soul", "rank 10", MB_priestShieldLowRandomPercentage) -- Shield on randoom
			end

			mb_priestRenewAggroedPlayer() -- Renew on agro player
			mb_castSpellOnRandomRaidMember("Renew", MB_priestRenewLowRandomRank, MB_priestRenewLowRandomPercentage) -- Renew on random		
		end
	end

	-- Healing selector
	if mb_hasBuffOrDebuff("Inner Focus", "player", "buff") then

		MBH_CastHeal("Flash Heal", 6, 6) -- FH

	elseif MB_myHealSpell == "Greater Heal" or mb_hasBuffOrDebuff("Hazza\'rah\'s Charm of Healing", "player", "buff") then
		
		MBH_CastHeal("Greater Heal", 1, 1) -- GH
		
	elseif MB_myHealSpell == "Heal" then

		MBH_CastHeal("Heal") -- H
		
	elseif MB_myHealSpell == "Flash Heal" then

		MBH_CastHeal("Flash Heal") -- FH
	else

		MBH_CastHeal("Heal") -- H
	end

	mb_healerWand() -- Wanding
end

--[####################################################################################################]--
--[########################################## SHADOW Code! ############################################]--
--[####################################################################################################]--

local function PriestShadowWeaving()
    local focusUnit = MB_raidLeader or MB_raidInviter
    if focusUnit then
        local targetUnit = MBID[focusUnit].."target"
        local canCastDirectly = (UnitCanAttack("player", targetUnit) and mb_debuffShadowWeavingAmount() < 5) 
                            and mb_isValidEnemyTargetWithin28YardRange(targetUnit)
        
        AssistUnit(MBID[focusUnit])
        
        if canCastDirectly then
            CastSpellByName("Shadow Word: Pain(rank 1)")
            return true
        else
            mb_coolDownCast("Shadow Word: Pain(rank 1)", 17)
        end
    end	
	return false
end

local function PriestBossSpecificDPS()

	if tName == "Emperor Vek\'nilash" then
        return true
    end

	if mb_hasBuffNamed("Shadow and Frost Reflect", "target") then

		mb_castSpellOrWand("Smite")
		return true
	
	elseif mb_hasBuffOrDebuff("Magic Reflection", "target", "buff") then 	

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

		mb_autoWandAttack() 
		return true
	end

    if Instance.IsWorldBoss() and tName ~= "Nefarian" then
		if not mb_hasBuffOrDebuff("Vampiric Embrace", "target", "debuff") then
			CastSpellByName("Vampiric Embrace")
		end
	end

	if Instance.AQ40 then		
		if tName == "Obsidian Eradicator" and mb_manaPct("target") > 0.7 then

			if not mb_imBusy() then				
				mb_castSpellOrWand("Mana Burn") 
			end
			return true
		end

        if tName == "Battleguard Sartura" then
			mb_coolDownCast("Shadow Word: Pain", 24)
		end

	elseif Instance.MC then

		if tName == "Shazzrah" then			
			if not mb_spellReady("Mind Flay") then
				mb_castSpellOrWand("Smite")
				return true
			end
		end

        mb_coolDownCast("Shadow Word: Pain(Rank 1)", 24)

	elseif Instance.Ony then

		if tName == "Onyxia" then
			mb_coolDownCast("Shadow Word: Pain", 24)
		end
	end
	return false
end

local function PriestShadow()

    mb_selfBuff("Shadowform")

	if not mb_inCombat("target") then
        return
    end

    if mb_inCombat("player") then
        if Instance.MC then
            if mb_tankTarget("Shazzrah") and mb_hasBuffOrDebuff("Deaden Magic", "target", "buff") then
                CastSpellByName("Dispel Magic")
            end
        end

		mb_takeManaPotionAndRune()
		mb_takeManaPotionIfBelowManaPotMana()
		mb_takeManaPotionIfBelowManaPotManaInRazorgoreRoom()

		if mb_manaDown("player") > 600 then
            mb_priestCooldowns()
        end

		if mb_priestManaDrain() then
            return
        end

		if mb_spellReady("Desperate Prayer") and mb_healthPct("player") < 0.2 then			
			CastSpellByName("Desperate Prayer")
			return
		end
	end

    if PriestBossSpecificDPS() then
        return
    end

    if mb_imBusy() then
        return
    end

	if mb_spellReady("Mind Blast") then 
		mb_castSpellOrWand("Mind Blast") 
	end

	mb_castSpellOrWand("Mind Flay") 
end

--[####################################################################################################]--
--[########################################## Single Code! ############################################]--
--[####################################################################################################]--

local function getPriestSingle()
	
    mb_getTarget()

	if mb_crowdControl() then
        return
    end

	if Instance.Naxx then

        if (mb_tankTarget("Instructor Razuvious") and mb_myNameInTable(MB_myRazuviousPriest) and MB_myRazuviousBoxStrategy) or
            (mb_tankTarget("Grand Widow Faerlina") and mb_myNameInTable(MB_myFaerlinaPriest) and MB_myFaerlinaBoxStrategy) then
            mb_getMCActions()
            return
        end

	elseif Instance.AQ40 then
		
		if mb_hasBuffOrDebuff("True Fulfillment", "target", "debuff") then
            ClearTarget()
            return
        end

		if mb_isAtSkeram() then
            if not MB_autoToggleSheeps.Active then
                MB_autoToggleSheeps.Active = true
                MB_autoToggleSheeps.Time = GetTime() + 3
                PriestCounter.Cycle()
            end

            if MB_buffingCounterPriest == mb_myClassAlphabeticalOrder() then
                mb_crowdControlMCedRaidMemberSkeramAOE()
            end
		end
	end

	PriestFade()
	mb_decurse()

	if MB_mySpecc == "Bitch" then
        PriestShadowWeaving()

    elseif MB_mySpecc == "Shadow" then

        PriestShadow()
        return
    end

	mb_healerJindoRotation("Smite")
	PriestHeal()
end

MB_mySingleList["Priest"] = getPriestSingle