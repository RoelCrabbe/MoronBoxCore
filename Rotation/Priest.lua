--[####################################################################################################]--
--[####################################### START PRIEST CODE! #########################################]--
--[####################################################################################################]--

local Priest = CreateFrame("Frame", "Priest")

local myClass = UnitClass("player")
local myName = UnitName("player")

if myClass ~= "Priest" then
    return
end

local PriestCounter = {
    Cycle = function()
        MB_buffingCounterPriest = (MB_buffingCounterPriest >= TableLength(MB_classList["Priest"]))
                                  and 1 or (MB_buffingCounterPriest + 1)
    end
}

local PrayerManaCost = {
    [1] = 451,
	[2] = 616,
	[3] = 847,
	[4] = 1133,
	[5] = 1177
}

local PrayerFocusRanks = {
    [4] = true,
    [5] = true,
}

--[####################################################################################################]--
--[########################################## SETUP Code! #############################################]--
--[####################################################################################################]--

local function PriestSpecc()
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

MB_mySpeccList["Priest"] = PriestSpecc

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
			Priest:MTHeals(MB_myAssignedHealTarget)
			return
		else			
			MB_myAssignedHealTarget = nil
			mb_message("My healtarget died, time to ALT-F4.")
		end
	end

	for k, bossName in pairs(MB_myPriestMainTankHealingBossList) do
		if mb_tankTarget(bossName) then			
			Priest:MTHeals()
			return
		end
	end

	if MB_isMoving.Active then
        mb_castSpellOnRandomRaidMember("Renew", MB_priestRenewLowRandomRank, MB_priestRenewLowRandomPercentage)
    end	

	if Instance.AQ40 and mb_tankTarget("Princess Huhuran") then
				
		if mb_tankTargetHealth() <= 0.32 then			
			if Priest:PrayerOfHealingCheck(4, 1, 3, true) and mb_myGroupClassOrder() == 1 then
				return
			end

			MBH_CastHeal("Flash Heal", 4, 6)
			return
		end
		
		MBH_CastHeal("Heal")
		
	elseif Instance.BWL then
		if mb_tankTarget("Vaelastrasz the Corrupt") and MB_myVaelastraszBoxStrategy then

			Priest:Cooldowns()

			if MB_myVaelastraszPriestHealing and not mb_hasBuffOrDebuff("Burning Adrenaline", "player", "debuff") then
				local activePriest = Priest:GetActiveVaelastraszPriest()
				
				if myName == activePriest then
					Priest:MaxRenewAggroedPlayer()
					Priest:ShieldAggroedPlayer()
				else
					Priest:ShieldToBombFollowTarget()
				end
			end

			if Priest:PrayerOfHealingCheck(5, 1, 3, true) and mb_myGroupClassOrder() == 1 then
				return
			end
	
			MBH_CastHeal("Flash Heal", 7, 7)
			return

		elseif mb_tankTarget("Nefarian") and mb_hasBuffOrDebuff("Corrupted Healing", "player", "debuff") then

			if mb_imBusy() then					
				SpellStopCasting()
			end

			if mb_spellReady("Power Word: Shield") then					
				mb_castSpellOnRandomRaidMember("Weakened Soul", "rank 10", 0.9)
			end	
			
			mb_castSpellOnRandomRaidMember("Renew", "rank 10", 0.95)		
			return

		elseif mb_tankTarget("Chromaggus") and MB_myHealSpell ~= "Flash Heal" then
			MB_myHealSpell = "Flash Heal"
		end
	end

	if not mb_imBusy() then
		if mb_myGroupClassOrder() == 1 then
			for rank = 5, 1, -1 do
				local focus = PrayerFocusRanks[rank] or false
				if Priest:PrayerOfHealingCheck(rank, rank, 4, focus) then
					return
				end
			end
		end

		if mb_inCombat("player") then
			if mb_spellReady("Power Word: Shield") then 
				Priest:ShieldAggroedPlayer()
				mb_castSpellOnRandomRaidMember("Weakened Soul", "rank 10", MB_priestShieldLowRandomPercentage)
			end

			Priest:RenewAggroedPlayer()
			mb_castSpellOnRandomRaidMember("Renew", MB_priestRenewLowRandomRank, MB_priestRenewLowRandomPercentage)
		end
	end

	if mb_hasBuffOrDebuff("Inner Focus", "player", "buff") then
		MBH_CastHeal("Flash Heal", 6, 6)

	elseif MB_myHealSpell == "Greater Heal" or mb_hasBuffOrDebuff("Hazza\'rah\'s Charm of Healing", "player", "buff") then
		MBH_CastHeal("Greater Heal", 1, 1)
		
	elseif MB_myHealSpell == "Heal" then
		MBH_CastHeal("Heal")
		
	elseif MB_myHealSpell == "Flash Heal" then
		MBH_CastHeal("Flash Heal")
	else
		MBH_CastHeal("Heal")
	end

	mb_healerWand()
end

MB_myHealList["Priest"] = PriestHeal

local GreaterHeal = { Time = 0, Interrupt = false }
function Priest:MTHeals(assignedTarget)
	
	if assignedTarget then		
		TargetByName(assignedTarget, 1)
	else
		if mb_tankTarget("Patchwerk") and MB_myPatchwerkBoxStrategy then			
			mb_targetMyAssignedTankToHeal()
		else
			if not UnitName(MBID[mb_tankName()].."targettarget") then 				
				MBH_CastHeal("Greater Heal", 1, 1)
			else
				TargetByName(UnitName(MBID[mb_tankName()].."targettarget"), 1) 
			end
		end
	end

	if Instance.BWL and mb_tankTarget("Nefarian") then
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
	end

	if (mb_healthPct("target") < 0.5) and mb_spellReady("Power Word: Shield") and not mb_hasBuffOrDebuff("Weakened Soul", "target", "debuff") then		
		CastSpellByName("Power Word: Shield")
	end

	local GreatHealSpell = "Greater Heal("..MB_myPriestMainTankHealingRank.."\)"
	if mb_tankTarget("Vaelastrasz the Corrupt") then
		GreatHealSpell = "Greater Heal"
	end

	if not mb_bossNeverInterruptHeal() and mb_healthDown("target") <= (GetHealValueFromRank("Greater Heal", MB_myPriestMainTankHealingRank) * MB_myMainTankOverhealingPercentage) then
		if GetTime() > GreaterHeal.Time and GetTime() < GreaterHeal.Time + 0.5 and GreaterHeal.Interrupt then
			SpellStopCasting()			
			GreaterHeal.Interrupt = false
			SpellStopCasting()
		end
	end

	if not mb_imBusy() then
		CastSpellByName(GreatHealSpell)
		GreaterHeal.Time = GetTime() + 1
		GreaterHeal.Interrupt = true
	end
end

function Priest:MaxShieldAggroedPlayer()
    if not MBID[MB_raidLeader] then
        return
    end

	if mb_imBusy() then
        return
    end

    if mb_tankTarget("Garr") or mb_tankTarget("Firesworn") then
        return
    end

    local shieldTarget = MBID[MB_raidLeader].."targettarget"
    if not mb_isValidFriendlyTarget(shieldTarget, "Power Word: Shield") then
        return
    end

    if mb_healthPct(shieldTarget) > 0.95 then
        return
    end

    if mb_hasBuffOrDebuff("Weakened Soul", shieldTarget, "debuff") then
        return
    end

    if not mb_spellReady("Power Word: Shield") then
        return
    end

    if UnitIsFriend("player", shieldTarget) then
        ClearTarget()
    end

    CastSpellByName("Power Word: Shield", false)
    SpellTargetUnit(shieldTarget)
    SpellStopTargeting()
end

function Priest:MaxRenewAggroedPlayer()
    if not MBID[MB_raidLeader] then
        return
    end

	if mb_imBusy() then
        return
    end

    if mb_tankTarget("Garr") or mb_tankTarget("Firesworn") then
        return
    end

    local renewTarget = MBID[MB_raidLeader].."targettarget"
    if not mb_isValidFriendlyTarget(renewTarget, "Renew") then
        return
    end

    if mb_healthPct(renewTarget) > 0.95 then
        return
    end

    if mb_hasBuffNamed("Renew", renewTarget) then
        return
    end

    if UnitIsFriend("player", renewTarget) then
        ClearTarget()
    end

    CastSpellByName("Renew")
    SpellTargetUnit(renewTarget)
    SpellStopTargeting()
end

function Priest:RenewAggroedPlayer()
    if mb_imBusy() then
        return
    end

    if mb_tankTarget("Garr") or mb_tankTarget("Firesworn") then
        return
    end

    local aggrox = AceLibrary("Banzai-1.0")

    for i = 1, GetNumRaidMembers() do
        local renewTarget = "raid"..i

        if aggrox:GetUnitAggroByUnitId(renewTarget)
           and mb_isValidFriendlyTarget(renewTarget, "Renew")
           and mb_healthPct(renewTarget) <= MB_priestRenewAggroedPlayerPercentage
           and not mb_hasBuffNamed("Renew", renewTarget) then

            if UnitIsFriend("player", renewTarget) then
                ClearTarget()
            end

            CastSpellByName("Renew("..MB_priestRenewAggroedPlayerRank..")")
            SpellTargetUnit(renewTarget)
            SpellStopTargeting()
        end
    end
end

function Priest:ShieldAggroedPlayer()
    if mb_imBusy() then
        return
    end

    if mb_tankTarget("Garr") or mb_tankTarget("Firesworn") then
        return
    end

    local aggrox = AceLibrary("Banzai-1.0")

    for i = 1, GetNumRaidMembers() do
        local shieldTarget = "raid"..i

        if aggrox:GetUnitAggroByUnitId(shieldTarget)
           and mb_isValidFriendlyTarget(shieldTarget, "Power Word: Shield")
           and mb_healthPct(shieldTarget) <= MB_priestShieldAggroedPlayerPercentage
           and not mb_hasBuffOrDebuff("Weakened Soul", shieldTarget, "debuff")
           and mb_spellReady("Power Word: Shield") then

            if UnitIsFriend("player", shieldTarget) then
                ClearTarget()
            end

            CastSpellByName("Power Word: Shield", false)
            SpellTargetUnit(shieldTarget)
            SpellStopTargeting()
		end
	end
end

function Priest:FearWardAggroedPlayer()
    if not MBID[MB_raidLeader] then
        return false
    end

	if mb_imBusy() then
        return
    end

    if mb_tankTarget("Garr") or mb_tankTarget("Firesworn") then
        return
    end

    local fearWardTarget = MBID[MB_raidLeader].."targettarget"
    if not mb_isValidFriendlyTarget(fearWardTarget, "Fear Ward") then
        return false
    end

    if mb_hasBuffNamed("Fear Ward", fearWardTarget) then
        return false
    end

    if UnitPowerType(fearWardTarget) ~= 1 then
        return false
    end

    if UnitIsFriend("player", fearWardTarget) then
        ClearTarget()
    end

    mb_message("Focus Fear Ward on "..UnitName(fearWardTarget), 30)

    CastSpellByName("Fear Ward")
    SpellTargetUnit(fearWardTarget)
    SpellStopTargeting()
    return true
end

function Priest:ShieldToBombFollowTarget()
    if mb_imBusy() or mb_tankTarget("Vaelastrasz the Corrupt") then
        return
    end

    local targetName = mb_returnPlayerInRaidFromTable(MB_raidAssist.GTFO.Vaelastrasz)
    local targetID = MBID[targetName]

    if not targetID 
		or not mb_isAlive(targetID) 
		or mb_hasBuffOrDebuff("Weakened Soul", targetID, "debuff") 
		or not mb_spellReady("Power Word: Shield") then
        return
    end

    TargetByName(targetName)
    CastSpellByName("Power Word: Shield")
    TargetLastTarget()
end

--[####################################################################################################]--
--[########################################## Single Code! ############################################]--
--[####################################################################################################]--

local function PriestSingle()
	
    mb_getTarget()

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

            if mb_myClassAlphabeticalOrder() == MB_buffingCounterPriest then
                mb_crowdControlMCedRaidMemberSkeramAOE()
            end
		end
	end

	Priest:Fade()
	mb_decurse()

	if MB_mySpecc == "Bitch" then
        Priest:ShadowWeaving()

    elseif MB_mySpecc == "Shadow" then

        Priest:Shadow()
        return
    end

	mb_healerJindoRotation("Smite")
	PriestHeal()
end

MB_mySingleList["Priest"] = PriestSingle

--[####################################################################################################]--
--[########################################## SHADOW Code! ############################################]--
--[####################################################################################################]--

function Priest:Shadow()

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
            Priest:Cooldowns()
        end

		if mb_spellReady("Desperate Prayer") and mb_healthPct("player") < 0.2 then			
			CastSpellByName("Desperate Prayer")
			return
		end
	end

    if Priest:BossSpecificDPS() then
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

function Priest:ShadowWeaving()
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
            mb_coolDownCast("Shadow Word: Pain(rank 1)", 24)
        end
    end	
	return false
end

function Priest:BossSpecificDPS()

	if UnitName("target") == "Emperor Vek\'nilash" then
        return true
    end

	if mb_hasBuffNamed("Shadow and Frost Reflect", "target") then

		mb_autoWandAttack()
		return true

	elseif mb_hasBuffOrDebuff("Magic Reflection", "target", "buff") then

		if mb_imBusy() then
			SpellStopCasting()
		end

		mb_autoWandAttack()
		return true

	elseif mb_tankTarget("Azuregos") and mb_hasBuffNamed("Magic Shield", "target") then
		
		if mb_imBusy() then
			SpellStopCasting()
		end

		mb_autoWandAttack()
		return true
	end

    if Instance.IsWorldBoss() and UnitName("target") ~= "Nefarian" then
		if not mb_hasBuffOrDebuff("Vampiric Embrace", "target", "debuff") then
			CastSpellByName("Vampiric Embrace")
		end
	end

	Priest:ManaDrain()

	if Instance.AQ40 and mb_tankTarget("Battleguard Sartura") then			
		mb_coolDownCast("Shadow Word: Pain", 24)
	
	elseif Instance.MC then
        mb_coolDownCast("Shadow Word: Pain(Rank 1)", 24)

	elseif Instance.Ony and mb_tankTarget("Onyxia") then
		mb_coolDownCast("Shadow Word: Pain", 24)
	elseif not UnitInRaid("player") and mb_debuffShadowWeavingAmount() > 5 then
		mb_coolDownCast("Shadow Word: Pain", 24)
	end
	
	return false
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
        if Priest:PartyHurt(GetHealValueFromRank("Prayer of Healing", "Rank "..checkRank), minTargets) then
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

function Priest:PartyHurt(hurt, num_party_hurt)
	local numHurt = 0
	local myHurt = mb_healthDown("player")

	if myHurt > hurt then 
		numHurt = numHurt + 1 
	end

    for i = 1, GetNumPartyMembers() do
        local guysHurt = UnitHealthMax("party"..i) - UnitHealth("party"..i)
        if guysHurt > hurt and mb_in28yardRange("party"..i) and not mb_dead("party"..i) then 
            numHurt = numHurt + 1 
        end
    end

	if numHurt >= num_party_hurt then 
		return numHurt 
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