--[####################################################################################################]--
--[####################################### START PALADIN CODE! ########################################]--
--[####################################################################################################]--

local Paladin = CreateFrame("Frame", "Paladin")

local myClass = UnitClass("player")
local myName = UnitName("player")

if myClass ~= "Paladin" then
    return
end

local PaladinCounter = {
    Cycle = function()
        MB_buffingCounterPaladin = (MB_buffingCounterPaladin >= TableLength(MB_classList["Paladin"]))
                                  and 1 or (MB_buffingCounterPaladin + 1)
    end
}

--[####################################################################################################]--
--[######################################### HEALING Code! ############################################]--
--[####################################################################################################]--

local function PaladinHeal()

	if Paladin:BOPLowRandom() then
        return
    end

    mb_decurse()

	if mb_inCombat("player") then	
		MB_mySetupList["Paladin"]()

		if mb_healthPct("player") < 0.2 then			
			mb_selfBuff("Divine Shield")
			return 
		end

		mb_takeManaPotionAndRune()
		mb_takeManaPotionIfBelowManaPotMana()
		mb_takeManaPotionIfBelowManaPotManaInRazorgoreRoom()

		if mb_manaDown("player") > 600 then
            Paladin:Cooldowns()
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
			Paladin:MTHeals(MB_myAssignedHealTarget)
			return
		else
			MB_myAssignedHealTarget = nil
			RunLine("/raid My healtarget died, time to ALT-F4.")
		end
	end

	for k, BossName in pairs(MB_myPaladinMainTankHealingBossList) do		
		if mb_tankTarget(BossName) then			
			Paladin:MTHeals()
			return
		end
	end

    if Instance.BWL and mb_tankTarget("Vaelastrasz the Corrupt") and MB_myVaelastraszBoxStrategy then
        if mb_hasBuffOrDebuff("Burning Adrenaline", "player", "debuff") then	
            MBH_CastHeal("Flash of Light", 6, 6)
            return
        end

		Paladin:Cooldowns()
		
        if MB_myVaelastraszPaladinHealing then
            local activePaladin = Paladin:GetActiveVaelastraszPaladin()

            if myName == activePaladin then
                Paladin:MTHeals()
                return
            end
        end

		MBH_CastHeal("Flash of Light", 6, 6)
		Paladin:SealLight()
		return		
	end

	if mb_hasBuffOrDebuff("Blinding Light", "player", "buff") or mb_hasBuffOrDebuff("Divine Favor", "player", "buff") then		
		MBH_CastHeal("Holy Light")
		return
    end

	MBH_CastHeal("Flash of Light", 5, 6)
end
MB_myHealList["Paladin"] = PriestHeal

local FlashOfLight = { Time = 0, Interrupt = false }
function Paladin:MTHeals(assignedTarget)
	
	if assignedTarget then		
		TargetByName(assignedTarget, 1)
	else
		if mb_tankTarget("Patchwerk") and MB_myPatchwerkBoxStrategy then			
			mb_targetMyAssignedTankToHeal()
		else
			if not UnitName(MBID[mb_tankName()].."targettarget") then 				
				MBH_CastHeal("Flash of Light", 5, 6)
			else
				TargetByName(UnitName(MBID[mb_tankName()].."targettarget"), 1) 
			end
		end
	end

	if mb_inCombat("player") and mb_manaPct("player") < 0.95 then		
		mb_selfBuff("Divine Favor")
	end

	local FlashOfLightSpell = "Flash of Light("..MB_myPaladinMainTankHealingRank.."\)"
	if mb_tankTarget("Vaelastrasz the Corrupt") then
		FlashOfLightSpell = "Holy Light"

	elseif mb_tankTarget("Ossirian the Unscarred") then		
		FlashOfLightSpell = "Holy Light(rank 5)"
	end

    if not mb_bossNeverInterruptHeal() and mb_healthDown("target") <= (GetHealValueFromRank("Flash of Light", MB_myPaladinMainTankHealingRank) * MB_myMainTankOverhealingPercentage) then
		if GetTime() > FlashOfLight.Time and GetTime() < FlashOfLight.Time + 0.5 and FlashOfLight.Interrupt then
			SpellStopCasting()			
			FlashOfLight.Interrupt = false
			SpellStopCasting()
		end
	end

	if not mb_imBusy() then
		CastSpellByName(FlashOfLightSpell)
		FlashOfLight.Time = GetTime() + 0.25
		FlashOfLight.Interrupt = true
	end
end

function Paladin:ShockLowAggroedPlayer()
	if not MB_raidAssist.Paladin.HolyShockLowHealthAggroedPlayers
		or not UnitInRaid("player")
		or not mb_inCombat("player")
		or not mb_spellReady("Holy Shock") then
		return false
	end

	local blastHSatThisPercentage = 0.2
	local classOrder = mb_myClassOrder()

	if classOrder == 1 then
		blastHSatThisPercentage = 0.50
	elseif classOrder == 2 then
		blastHSatThisPercentage = 0.45
	elseif classOrder == 3 then
		blastHSatThisPercentage = 0.40
	elseif classOrder == 4 then
		blastHSatThisPercentage = 0.35
	elseif classOrder >= 5 then
		blastHSatThisPercentage = 0.30
	end

	local aggrox = AceLibrary("Banzai-1.0")

	for i = 1, GetNumRaidMembers() do
		local holyShockTarget = "raid"..i
		if holyShockTarget and aggrox:GetUnitAggroByUnitId(holyShockTarget) then
			if mb_isValidFriendlyTarget(holyShockTarget, "Holy Shock")
				and mb_healthPct(holyShockTarget) <= blastHSatThisPercentage
				and not mb_hasBuffNamed("Holy Shock", holyShockTarget) then

				if UnitIsFriend("player", holyShockTarget) then
					ClearTarget()
				end

				SpellTargetUnit(holyShockTarget)
				CastSpellByName("Holy Shock")
				SpellStopTargeting()
				return true
			end
		end
	end

	return false
end

function Paladin:BOPLowRandom()
	if mb_tankTarget("Gluth") or mb_tankTarget("Zombie Chow")
		or not UnitInRaid("player")
		or not mb_inCombat("player")
		or mb_imBusy()
		or not mb_spellReady("Blessing of Protection") then
		return false
	end

	local blastNSatThisPercentage = 0.3
	local classOrder = mb_myClassOrder()

	if classOrder == 1 then
		blastNSatThisPercentage = 0.45
	elseif classOrder == 2 then
		blastNSatThisPercentage = 0.40
	elseif classOrder == 3 then
		blastNSatThisPercentage = 0.35
	elseif classOrder == 4 then
		blastNSatThisPercentage = 0.30
	elseif classOrder >= 5 then
		blastNSatThisPercentage = 0.25
	end

	local aggrox = AceLibrary("Banzai-1.0")

	for i = 1, GetNumRaidMembers() do
		local BOPTarget = "raid"..i

		if BOPTarget
			and aggrox:GetUnitAggroByUnitId(BOPTarget)
			and not FindInTable(MB_raidTanks, UnitName(BOPTarget))
			and mb_isValidFriendlyTarget(BOPTarget, "Blessing of Protection")
			and mb_healthPct(BOPTarget) <= blastNSatThisPercentage
			and not mb_hasBuffOrDebuff("Forbearance", BOPTarget, "debuff") then

			if UnitIsFriend("player", BOPTarget) then
				ClearTarget()
			end

			CastSpellByName("Blessing of Protection", false)
			mb_message("I BOP'd "..GetColors(UnitName(BOPTarget)).." at "..string.sub(mb_healthPct(BOPTarget), 3, 4).."% - "..UnitHealth(BOPTarget).."/"..UnitHealthMax(BOPTarget).." HP.")
			SpellTargetUnit(BOPTarget)
			SpellStopTargeting()
			return true
		end
	end

	return false
end


--[####################################################################################################]--
--[########################################## Single Code! ############################################]--
--[####################################################################################################]--

local function PaladinSingle()
	
	mb_getTarget()

    if Instance.Naxx and mb_raidIsPoisoned() and mb_imBusy() then
		if mb_tankTarget("Venom Stalker") or mb_tankTarget("Necro Stalker") then
			SpellStopCasting()
		end
    end

	mb_decurse()

	if mb_stunnableMob() then
        if not MB_autoBuff.Active then
            MB_autoBuff.Active = true
            MB_autoBuff.Time = GetTime() + 1
            PriestCounter.Cycle()
        end

		if mb_myClassAlphabeticalOrder() == MB_buffingCounterPaladin then
			if mb_spellReady("Hammer of Justice") then
                mb_assistFocus()		
				CastSpellByName("Hammer of Justice")
			end		
		end
	end

	mb_paladinHeal()
	Paladin:SealLight()
end

MB_mySingleList["Paladin"] = PaladinSingle

--[####################################################################################################]--
--[########################################## Multi Code! #############################################]--
--[####################################################################################################]--

MB_myMultiList["Paladin"] = PaladinSingle

--[####################################################################################################]--
--[########################################### AOE Code! ##############################################]--
--[####################################################################################################]--

MB_myAOEList["Paladin"] = PaladinSingle

--[####################################################################################################]--
--[########################################## SETUP Code! #############################################]--
--[####################################################################################################]--

local function PaladinSetup()

    if UnitMana("player") < 3060 and mb_hasBuffNamed("Drink", "player") then
		return
	end

    if not MB_autoBuff.Active then
        MB_autoBuff.Active = true
        MB_autoBuff.Time = GetTime() + 1
        PriestCounter.Cycle()
    end

	if mb_myClassAlphabeticalOrder() == MB_buffingCounterPaladin then
		Paladin:BlessMyAssignedBlessing()
	end

	Paladin:ChooseAura()

	if not mb_inCombat("player") and mb_manaPct("player") < 0.20 and not mb_hasBuffNamed("Drink", "player") then
		mb_smartDrink()
	end
end

MB_mySetupList["Paladin"] = PaladinSetup

--[####################################################################################################]--
--[########################################## Helper Code! ############################################]--
--[####################################################################################################]--

function Paladin:GetActiveVaelastraszPaladin()
    for _, paladinName in ipairs(MB_myVaelastraszPaladins) do
        if not mb_dead(MBID[paladinName]) then
            return paladinName
        end
    end
    return nil
end

function Paladin:Cooldowns()
	if mb_imBusy() or not mb_inCombat("player") then
		return
	end

    if not mb_tankTarget("Viscidus") then
        if mb_manaPct("player") <= MB_paladinDivineFavorPercentage then			
            mb_selfBuff("Divine Favor")
        end
    end

	mb_casterTrinkets()
	mb_healerTrinkets()
end

function Paladin:ChooseAura()
	if mb_tankTarget("Sapphiron") or mb_tankTarget("Azuregos") then
		mb_selfBuff("Frost Resistance Aura")
		return
	end

	if mb_myGroupClassOrder() == 1 then
		if mb_isFireBoss() then
			mb_selfBuff("Fire Resistance Aura")
			return
		end

		if MB_druidTankInParty or MB_warriorTankInParty
			or mb_numberOfClassInParty("Warrior") > 0
			or mb_numberOfClassInParty("Rogue") > 0 then
			mb_selfBuff("Devotion Aura")
			return
		end

		mb_selfBuff("Concentration Aura")
		return
	end

	if mb_myGroupClassOrder() == 2 then
		mb_selfBuff("Concentration Aura")
		return
	end

	if mb_myGroupClassOrder() == 3 then
		mb_selfBuff("Retribution Aura")
		return
	end
end

function Paladin:BlessMyAssignedBlessing()
	if mb_tankTarget("Garr") or mb_tankTarget("Firesworn") or mb_tankTarget("Maexxna") then
		return
	end

	if not mb_haveInBags("Symbol of Kings") then
		mb_message("Out of Symbol of Kings")
		return
	end

	local blessings = {
		[1] = "Greater Blessing of Kings",
		[2] = "Greater Blessing of Might",
		[3] = "Greater Blessing of Salvation",
		[4] = "Greater Blessing of Light",
		[5] = "Greater Blessing of Sanctuary",
		[6] = "Greater Blessing of Wisdom"
	}

	local assignedBlessing = blessings[mb_myClassAlphabeticalOrder()]
	if assignedBlessing then
		mb_multiBuffBlessing(assignedBlessing)
	end
end

function Paladin:SealLight()
	if not mb_isValidMeleeTarget("target") then
		return
	end

	mb_assistFocus()

	if mb_hasBuffOrDebuff("Judgement of Light", "target", "debuff") then
		return
	end

	mb_autoAttack()

	if not mb_hasBuffOrDebuff("Seal of Light", "player", "buff") then
		CastSpellByName("Seal of Light")
		return
	end

	CastSpellByName("Judgement")
end

function Paladin:SealWisdom()
	if not mb_isValidMeleeTarget("target") then
		return
	end

	mb_assistFocus()

	if mb_hasBuffOrDebuff("Judgement of Light", "target", "debuff") then
		return
	end

	mb_autoAttack()

	if not mb_hasBuffOrDebuff("Seal of Wisdom", "player", "buff") then
		CastSpellByName("Seal of Wisdom")
		return
	end

	CastSpellByName("Judgement")
end

--[####################################################################################################]--
--[######################################### LOATHEB Code! ############################################]--
--[####################################################################################################]--

local function PriestLoathebHeal()

	if mb_loathebHealing() then
		return
	end

    AssistByName(MB_myLoathebMainTank)
	
	if mb_inCombat("player") then	
		MB_mySetupList["Paladin"]()

		if mb_healthPct("player") < 0.2 then			
			mb_selfBuff("Divine Shield")
			return 
		end

		mb_takeManaPotionAndRune()
		mb_takeManaPotionIfBelowManaPotMana()
		mb_takeManaPotionIfBelowManaPotManaInRazorgoreRoom()

		if mb_manaDown("player") > 600 then
            Paladin:Cooldowns()
        end
	end

    mb_autoAttack()

    if myName == MB_myLoathebSealPaladin and not mb_hasBuffOrDebuff("Seal of Light", "target", "debuff") then
		Paladin:SealLight()
		return
	end

    if not mb_hasBuffOrDebuff("Seal of Righteousness", "player", "buff") then
		CastSpellByName("Seal of Righteousness")
	end
end

MB_myLoathebList["Paladin"] = PriestLoathebHeal