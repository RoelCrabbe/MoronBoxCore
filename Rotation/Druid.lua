--[####################################################################################################]--
--[######################################## START DRUID CODE! #########################################]--
--[####################################################################################################]--

local Druid = CreateFrame("Frame", "Druid")

local myClass = UnitClass("player")
local myName = UnitName("player")

local DruidCounter = {
    Cycle = function()
        MB_buffingCounterDruid = (MB_buffingCounterDruid >= TableLength(MB_classList["Druid"]))
                                  and 1 or (MB_buffingCounterDruid + 1)
    end
}

--[####################################################################################################]--
--[########################################## SETUP Code! #############################################]--
--[####################################################################################################]--

local function DruidSpecc()
    local TalentsIn, TalentsInA

    _, _, _, _, TalentsIn = GetTalentInfo(3, 15)
    if TalentsIn > 0 then
        MB_mySpecc = "Swiftmend"
        return 
    end

    _, _, _, _, TalentsIn = GetTalentInfo(3, 3)
    if TalentsIn > 4 then
        MB_mySpecc = "Resto"
        return 
    end

    _, _, _, _, TalentsIn = GetTalentInfo(2, 16)
    if TalentsIn > 0 then
        MB_mySpecc = "Feral"
        return 
    end

    _, _, _, _, TalentsIn = GetTalentInfo(1, 16)
    if TalentsIn > 0 then
        MB_mySpecc = "Balance"
        return 
    end

    MB_mySpecc = nil
end

MB_mySpeccList["Druid"] = DruidSpecc

--[####################################################################################################]--
--[######################################### HEALING Code! ############################################]--
--[####################################################################################################]--

local function DruidHeal()
	
	if mb_natureSwiftnessLowAggroedPlayer() then
        return
    end

	mb_decurse()

	if mb_inCombat("player") then
		Druid:HealerDebuffs()
		Druid:Innervate()

		mb_takeManaPotionAndRune()
		mb_takeManaPotionIfBelowManaPotMana()
		mb_takeManaPotionIfBelowManaPotManaInRazorgoreRoom()

        if mb_manaDown("player") > 600 then
            Druid:Cooldowns()
        end
	end

	if mb_hasBuffOrDebuff("Curse of Tongues", "player", "debuff") and not mb_tankTarget("Anubisath Defender") then
        return
    end

	if Instance.MC and mb_tankTarget("Shazzrah") then
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
			Druid:MTHeals(MB_myAssignedHealTarget)
			return
		else
			MB_myAssignedHealTarget = nil
			RunLine("/raid My healtarget died, time to ALT-F4.")
		end
	end

	for k, bossName in pairs(MB_myDruidMainTankHealingBossList) do		
		if mb_tankTarget(bossName) then			
			Druid:MTHeals()
			return
		end
	end

	if MB_isMoving.Active then
        mb_castSpellOnRandomRaidMember("Rejuvenation", MB_druidRejuvenationLowRandomMovingRank, MB_druidRejuvenationLowRandomMovingPercentage)
    end

	if Instance.AQ40 and mb_tankTarget("Princess Huhuran") then
	
        if mb_myGroupClassOrder() == 1 and mb_tankTargetHealth() <= 0.32 then
            Druid:MTHeals()
            return
        end

		MBH_CastHeal("Healing Touch")
        return

	elseif Instance.BWL and mb_tankTarget("Vaelastrasz the Corrupt") and MB_myVaelastraszBoxStrategy then

        Druid:Cooldowns()

        if MB_myVaelastraszDruidHealing and not mb_hasBuffOrDebuff("Burning Adrenaline", "player", "debuff") then
            local activeDruid = Druid:GetActiveVaelastraszDruid()

            if myName == activeDruid then
                Druid:MaxRejuvAggroedPlayer()
                Druid:MaxRegrowthAggroedPlayer()
            end
        end

        if mb_spellReady("Swiftmend") and (swiftmendRaidThrottleTimer == nil or GetTime() - swiftmendRaidThrottleTimer > 1.5) then
            swiftmendRaidThrottleTimer = GetTime();	
            Druid:SwiftmendOnRandomRaidMember("Swiftmend", 0.5)
        end		

        mb_selfBuff("Rejuvenation")			
        MBH_CastHeal("Regrowth", 9, 9)
        return		
	end

	if not mb_imBusy() then		
		if MB_myHealSpell == "Rejuvenation" and mb_manaDown("player") > 300 then
			mb_selfBuff("Rejuvenation(Rank 1)")
		end

		Druid:RejuvAggroedPlayer()

		if mb_knowSpell("Swiftmend") then		
			if mb_spellReady("Swiftmend") then
                Druid:SwiftmendOnRandomRaidMember("Swiftmend", MB_druidSwiftmendAtPercentage)
            end
				
			if (rejuvenationRaidThrottleTimer == nil or GetTime() - rejuvenationRaidThrottleTimer > 1.5) then 
				rejuvenationRaidThrottleTimer = GetTime()	
				mb_castSpellOnRandomRaidMember("Rejuvenation", MB_druidSwiftmendRejuvenationLowRandomRank, MB_druidSwiftmendRejuvenationLowRandomPercentage)
			end
		else
			if (rejuvenationRaidThrottleTimer == nil or GetTime() - rejuvenationRaidThrottleTimer > 1.5) then 
				rejuvenationRaidThrottleTimer = GetTime()	
				mb_castSpellOnRandomRaidMember("Rejuvenation", MB_druidRejuvenationLowRandomRank, MB_druidRejuvenationLowRandomPercentage)
			end
		end

		Druid:RegrowthAggroedPlayer()
		
		if (regrowthRaidThrottleTimer == nil or GetTime() - regrowthRaidThrottleTimer > 1.5) then 
			regrowthRaidThrottleTimer = GetTime()
			Druid:RegrowthLowRandom()()
		end		
	end

	MBH_CastHeal("Healing Touch")
end

MB_myHealList["Druid"] = DruidHeal

local HealTouch = { Time = 0, Interrupt = false }
function Druid:MTHeals(assignedTarget)

	if assignedTarget then		
		TargetByName(assignedTarget, 1)
	else
		if mb_tankTarget("Patchwerk") and MB_myPatchwerkBoxStrategy then			
			mb_targetMyAssignedTankToHeal()
		else
			if not UnitName(MBID[mb_tankName()].."targettarget") then				
				MBH_CastHeal("Healing Touch")
			else
				TargetByName(UnitName(MBID[mb_tankName()].."targettarget"), 1) 
			end
		end
	end

	if mb_spellReady("Nature\'s Swiftness") and mb_healthPct("target") <= 0.15 then
		if not mb_hasBuffOrDebuff("Nature\'s Swiftness", "player", "buff") then			
			SpellStopCasting()
		end

		mb_selfBuff("Nature\'s Swiftness")
	end

	if mb_hasBuffOrDebuff("Nature\'s Swiftness", "player", "buff") then			
		CastSpellByName("Healing Wave")
		return
	end

	local HealTouchSpell = "Healing Touch("..MB_myDruidMainTankHealingRank.."\)"
	if mb_tankTarget("Vaelastrasz the Corrupt") then
		HealTouchSpell = "Healing Touch"
	end

    if not mb_bossNeverInterruptHeal() and mb_healthDown("target") <= (GetHealValueFromRank("Healing Touch", MB_myDruidMainTankHealingRank) * MB_myMainTankOverhealingPercentage) then
		if GetTime() > HealTouch.Time and GetTime() < HealTouch.Time + 0.5 and HealTouch.Interrupt then
			SpellStopCasting()			
			HealTouch.Interrupt = false
			SpellStopCasting()
		end
	end

	if not mb_imBusy() then
		CastSpellByName(HealTouchSpell)
		HealTouch.Time = GetTime() + 1
		HealTouch.Interrupt = true
	end
end

function Druid:HealerDebuffs()

	if Instance.BWL then
		
		if UnitName("target") == "Death Talon Wyrmkin" or UnitName("target") == "Death Talon Flamescale" then
            return
        end

        if GetSubZoneText() ~= "Dragonmaw Garrison" or not mb_isAtRazorgorePhase() or not MB_myRazorgoreBoxStrategy then
            return
        end

        local tanks = {
            Right = mb_returnPlayerInRaidFromTable(MB_myRazorgoreRightTank),
            Left  = mb_returnPlayerInRaidFromTable(MB_myRazorgoreLeftTank)
        }

        for _, tank in pairs(tanks) do
            local targetUnit = MBID[tank].."target"
            if mb_targetFromSpecificPlayer("Death Talon Dragonspawn", tank) 
                and UnitCanAttack("player", targetUnit)
                and not (mb_hasBuffOrDebuff("Faerie Fire", targetUnit, "debuff")
                or mb_hasBuffOrDebuff("Faerie Fire (Feral)", targetUnit, "debuff")) then

                AssistUnit(MBID[tank])
                CastSpellByName("Faerie Fire")
                TargetLastTarget()
            end
        end
        return		
	end

    local focusTarget = nil
    if MB_raidLeader then
        focusTarget = MBID[MB_raidLeader]    
    elseif MB_raidInviter then
        focusTarget = MBID[MB_raidInviter]
    end

    if not focusTarget then
        return
    end

    local targetUnit = focusTarget.."target"
    if UnitCanAttack("player", targetUnit)
        and (not mb_hasBuffOrDebuff("Faerie Fire", targetUnit, "debuff")
        or not mb_hasBuffOrDebuff("Faerie Fire (Feral)", targetUnit, "debuff")) then

        AssistUnit(focusTarget)
        CastSpellByName("Faerie Fire")
        TargetLastTarget()
    end
end

local function ImprovedRegrowthCheck()
	local _, _, _, _, TalentsIn = GetTalentInfo(3, 14)
	if TalentsIn > 2 then
		return true
	end
	return false
end

function Druid:Innervate()
    if mb_imBusy() then
        return
    end

    if mb_tankTarget("Garr") or mb_tankTarget("Firesworn") then
        return
    end

    if not mb_spellReady("Innervate") then
        return
    end

    for k, innerTarget in ipairs(MB_myInnervateHealerList) do
        local unitID = MBID[innerTarget]

        if mb_isValidFriendlyTarget(unitID, "Innervate")
            and mb_healthPct(unitID) <= 0.5
            and not mb_hasBuffNamed("Innervate", unitID)
            and mb_spellReady("Innervate") then

            if UnitIsFriend("player", unitID) then
                ClearTarget()
            end

            CastSpellByName("Innervate", false)
            SpellTargetUnit(unitID)
            SpellStopTargeting()
        end
    end	
end

function Druid:MaxRejuvAggroedPlayer()
    if not MBID[MB_raidLeader] then
        return
    end

    if mb_imBusy() then
        return
    end

    if mb_tankTarget("Garr") or mb_tankTarget("Firesworn") then
        return
    end

    local rejuvTarget = MBID[MB_raidLeader].."targettarget"
    if not mb_isValidFriendlyTarget(rejuvTarget, "Rejuvenation") then
        return
    end

    if mb_healthPct(rejuvTarget) > 0.95 then
        return
    end

    if mb_hasBuffNamed("Rejuvenation", rejuvTarget) then
        return
    end

    if UnitIsFriend("player", rejuvTarget) then
        ClearTarget()
    end

    CastSpellByName("Rejuvenation", false)
    SpellTargetUnit(rejuvTarget)
    SpellStopTargeting()
end

function Druid:MaxRegrowthAggroedPlayer()
    if not MBID[MB_raidLeader] then
        return
    end

    if mb_imBusy() then
        return
    end

    if mb_tankTarget("Garr") or mb_tankTarget("Firesworn") then
        return
    end

    local regroTarget = MBID[MB_raidLeader].."targettarget"
    if not mb_isValidFriendlyTarget(regroTarget, "Regrowth") then
        return
    end

    if mb_healthPct(regroTarget) > 0.95 then
        return
    end

    if mb_hasBuffNamed("Regrowth", regroTarget) then
        return
    end

    if UnitIsFriend("player", regroTarget) then
        ClearTarget()
    end

    CastSpellByName("Regrowth", false)
    SpellTargetUnit(regroTarget)
    SpellStopTargeting()
end

function Druid:SwiftmendOnRandomRaidMember(spell, percentage)
    if not UnitInRaid("player") then
        return
    end

    if mb_imBusy() then
        return
    end

    if mb_tankTarget("Garr") or mb_tankTarget("Firesworn") then
        return
    end

    local n = mb_GetNumPartyOrRaidMembers()
    local offset = math.random(n) - 1

    for i = 1, n do
        local j = i + offset
        if j > n then j = j - n end

        local raidUnit = "raid"..j
        local hasRejuv = mb_hasBuffNamed("Rejuvenation", raidUnit)
        local hasRegrowth = mb_hasBuffNamed("Regrowth", raidUnit)

        if mb_healthPct(raidUnit) < percentage 
           and mb_inCombat(raidUnit) 
           and mb_isValidFriendlyTarget(raidUnit, spell) 
           and (hasRejuv or hasRegrowth) then

            if UnitIsFriend("player", raidUnit) then
                ClearTarget()
            end

            CastSpellByName(spell, false)
            SpellTargetUnit(raidUnit)
            SpellStopTargeting()
            break
        end
    end
end

function Druid:RejuvAggroedPlayer()
    if mb_imBusy() then
        return
    end

    if mb_tankTarget("Garr") or mb_tankTarget("Firesworn") then
        return
    end

	local aggrox = AceLibrary("Banzai-1.0")

	for i =  1, GetNumRaidMembers() do		
        local rejuvTarget = "raid"..i

        if aggrox:GetUnitAggroByUnitId(rejuvTarget)
           and mb_isValidFriendlyTarget(rejuvTarget, "Rejuvenation")
           and mb_healthPct(rejuvTarget) <= MB_druidRejuvenationAggroedPlayerPercentage
           and not mb_hasBuffNamed("Rejuvenation", rejuvTarget) then

            if UnitIsFriend("player", rejuvTarget) then
                ClearTarget()
            end	
            
            CastSpellByName("Rejuvenation("..MB_druidRejuvenationAggroedPlayerRank.."\)")
            SpellTargetUnit(rejuvTarget)
            SpellStopTargeting()
        end
	end
end

function Druid:RegrowthAggroedPlayer()
    if mb_imBusy() then
        return
    end

    if mb_tankTarget("Garr") or mb_tankTarget("Firesworn") then
        return
    end

    if not ImprovedRegrowthCheck() or UnitMana("player") < 880 or mb_myClassOrder() ~= 1 then
        return
    end
    
    local aggrox = AceLibrary("Banzai-1.0")

	for i =  1, GetNumRaidMembers() do		
        local regroTarget = "raid"..i

        if aggrox:GetUnitAggroByUnitId(regroTarget)
           and mb_isValidFriendlyTarget(regroTarget, "Regrowth")
           and mb_healthPct(regroTarget) <= MB_druidSwiftmendRegrowthAggroedPlayerPercentage
           and not mb_hasBuffNamed("Regrowth", regroTarget) then

            if UnitIsFriend("player", regroTarget) then
                ClearTarget()
            end	
            
            CastSpellByName("Regrowth("..MB_druidSwiftmendRegrowthAggroedPlayerRank.."\)")
            SpellTargetUnit(regroTarget)
            SpellStopTargeting()
        end
	end
end

function Druid:RegrowthLowRandom()
    if mb_imBusy() then
        return
    end

    if mb_tankTarget("Garr") or mb_tankTarget("Firesworn") then
        return
    end

    if not ImprovedRegrowthCheck() or UnitMana("player") < 880 then
        return
    end

    if GetRaidRosterInfo(1) then

        for i = 1, GetNumRaidMembers() do
            if mb_healthPct("raid"..i) < MB_druidSwiftmendRegrowthLowRandomPercentage and mb_isValidFriendlyTarget("raid"..i, "Regrowth") then
                
                if UnitIsFriend("player", "raid"..i) then
                    ClearTarget()
                end	
                
                CastSpellByName("Regrowth")
                SpellTargetUnit("raid"..i)
                SpellStopTargeting()
                return
            end
        end

    elseif GetNumPartyMembers() > 0 then

        for i = 1, GetNumPartyMembers() do
            if mb_healthPct("party"..i) < MB_druidSwiftmendRegrowthLowRandomPercentage and mb_isValidFriendlyTarget("party"..i, "Regrowth") then

                if UnitIsFriend("player", "party"..i) then
                    ClearTarget()
                end	
                
                CastSpellByName("Regrowth")
                SpellTargetUnit("party"..i)
                SpellStopTargeting()
                return
            end
        end 
    end
end

function Druid:MaxAbolishAggroedPlayer()

    if not MBID[MB_raidLeader] then
        return
    end

    if mb_imBusy() then
        return
    end

    if mb_tankTarget("Garr") or mb_tankTarget("Firesworn") then
        return
    end

    local rejuvTarget = MBID[MB_raidLeader].."targettarget"
    if not mb_isValidFriendlyTarget(rejuvTarget, "Abolish Poison") then
        return
    end

    if mb_healthPct(rejuvTarget) > 0.95 then
        return
    end

    if mb_hasBuffNamed("Abolish Poison", rejuvTarget) then
        return
    end

    if UnitIsFriend("player", rejuvTarget) then
        ClearTarget()
    end

    CastSpellByName("Abolish Poison", false)
    SpellTargetUnit(rejuvTarget)
    SpellStopTargeting()
end

--[####################################################################################################]--
--[########################################## Single Code! ############################################]--
--[####################################################################################################]--

local function DruidSingle()
	
    mb_getTarget()

	if not MB_mySpecc then		
		mb_message("My specc is fucked. Defaulting to Resto.")
		MB_mySpecc = "Resto"
	end

	if MB_mySpecc == "Feral" then
		if Instance.AQ40 then			
			if mb_hasBuffOrDebuff("True Fulfillment", "target", "debuff") then
                TargetByName("The Prophet Skeram")
            end

			mb_anubisathAlert()
		end

		Druid:TankSingle()
		return
    end

    if UnitName("target") == "Death Talon Wyrmkin" and GetRaidTargetIndex("target") == MB_myCCTarget then
        CastSpellByName("Hibernate(Rank 1)")
        return 
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

    if MB_mySpecc == "Balance" then

        Druid:Balance()
        return

	elseif (MB_mySpecc == "Resto" or MB_mySpecc == "Swiftmend") then
        if Instance.Naxx and UnitFactionGroup("player") == "Alliance" then
            if mb_tankTarget("Venom Stalker") or mb_tankTarget("Necro Stalker") then
                if mb_imBusy() then
                    SpellStopCasting()
                end

                mb_meleeBuff("Abolish Poison")
                return
            end
        end

		mb_healerJindoRotation("Wrath")
		DruidHeal()
	end
end

MB_mySingleList["Druid"] = DruidSingle

--[####################################################################################################]--
--[########################################## BALANCE Code! ############################################]--
--[####################################################################################################]--

function Druid:Balance()

    if not mb_isBoomForm() then
		mb_selfBuff("Moonkin Form") 
		mb_cancelDruidShapeShift()
	end

	if not mb_inCombat("target") then
        return
    end

	if mb_inCombat("player") then
		Druid:HealerDebuffs()
		Druid:Innervate()

		mb_takeManaPotionAndRune()
		mb_takeManaPotionIfBelowManaPotMana()
		mb_takeManaPotionIfBelowManaPotManaInRazorgoreRoom()

        if mb_manaDown("player") > 600 then
            Druid:Cooldowns()
        end
	end

    if Druid:BossSpecificDPS() then
        return
    end

    if mb_imBusy() then
        return
    end

	mb_castSpellOrWand("Starfire") 
end

function Druid:BossSpecificDPS()

	if UnitName("target") == "Emperor Vek\'nilash" then
        return true
    end

	if mb_hasBuffOrDebuff("Magic Reflection", "target", "buff") then

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

	if Instance.AQ40 and mb_tankTarget("Battleguard Sartura") then			
		mb_coolDownCast("Moonfire", 24)
	
    elseif Instance.ZG then	

        if mb_hasBuffOrDebuff("Delusions of Jin\'do", "player", "debuff") then
			if UnitName("target") == "Shade of Jin\'do" and not mb_dead("target") then
				mb_castSpellOrWand("Wrath") 
				return true
			end
		end

		if (UnitName("target") == "Powerful Healing Ward" or UnitName("target") == "Brain Wash Totem") and not mb_dead("target") then
			mb_castSpellOrWand("Wrath") 
			return true
		end

    elseif Instance.AQ20 and mb_tankTarget("Ossirian the Unscarred") then

        if mb_hasBuffOrDebuff("Nature Weakness", "target", "debuff") then        
            mb_castSpellOrWand("Wrath")
            return true
        end
	end

	return false
end

--[####################################################################################################]--
--[######################################## Single Tank Code! #########################################]--
--[####################################################################################################]--

local function DruidTankSingleRotation()
    if not mb_hasBuffOrDebuff("Faerie Fire (Feral)", "target", "debuff") 
        and not mb_hasBuffOrDebuff("Faerie Fire", "target", "debuff") then
        CastSpellByName("Faerie Fire (Feral)()")
    end

    if mb_spellReady("Enrage") and UnitMana("player") <= 15 then        
        CastSpellByName("Enrage")
    end
    
    if UnitMana("player") >= 7 then 
        CastSpellByName("Maul") 
    end
    
    if UnitMana("player") >= 36 then 
        CastSpellByName("Swipe")
    end
end

function Druid:TankSingle()

	if mb_findInTable(MB_raidTanks, myName) and mb_hasBuffOrDebuff("Greater Blessing of Salvation", "player", "buff") then		
		CancelBuff("Greater Blessing of Salvation") 
	end

	if not mb_isBearForm() then
		mb_selfBuff("Dire Bear Form") 
		mb_cancelDruidShapeShift()
        return
	end

	if mb_inCombat("player") then
		if mb_healthPct("player") < 0.3 and mb_spellReady("Frenzied Regeneration") then			
			CastSpellByName("Frenzied Regeneration") 
		end

		if mb_inMeleeRange() then
			if mb_debuffSunderAmount() == 5 or mb_hasBuffOrDebuff("Expose Armor", "target", "debuff") then
				Druid:Cooldowns()
			end

			if mb_spellReady("Bash") and mb_stunnableMob() then				
				CastSpellByName("Bash")
			end

			if not mb_hasBuffOrDebuff("Demoralizing Shout", "target", "debuff") then 
                if UnitName("target") ~= "Emperor Vek\'nilash" or UnitName("target") ~= "Emperor Vek\'lor" then				
                    if not mb_hasBuffOrDebuff("Demoralizing Roar", "target", "debuff") and UnitMana("player") >= 20 then					
                        CastSpellByName("Demoralizing Roar")
                    end
                end
			end
		end
	end

	mb_offTank()

    local tOfTarget = UnitName("targettarget") or ""
    local tName = UnitName("target") or ""

    local shouldTaunt = tName ~= "" 
        and tOfTarget ~= "" and tOfTarget ~= "Unknown" 
        and UnitIsEnemy("player", "target") 
        and not mb_findInTable(MB_raidTanks, tOfTarget)

    if shouldTaunt then
        if MB_myOTTarget then
            if tOfTarget ~= myName then
                Druid:Taunt()
            end
        else
            Druid:Taunt()
        end
    end

	if MB_myOTTarget then
		if UnitExists("target") and GetRaidTargetIndex("target") and GetRaidTargetIndex("target") == MB_myOTTarget and UnitIsDead("target") then
			MB_myOTTarget = nil
			ClearTarget()
		end
	end

	mb_autoAttack()
    DruidTankSingleRotation()
end

--[####################################################################################################]--
--[########################################## Multi Code! #############################################]--
--[####################################################################################################]--

local function DruidMulti()
	
    mb_getTarget()

	if not MB_mySpecc then		
		mb_message("My specc is fucked. Defaulting to Resto.")
		MB_mySpecc = "Resto"
	end

	if MB_mySpecc == "Feral" then
		if Instance.AQ40 then			
			if mb_hasBuffOrDebuff("True Fulfillment", "target", "debuff") then
                TargetByName("The Prophet Skeram")
            end

			mb_anubisathAlert()
		end

		Druid:TankMulti()
		return
    end

    if UnitName("target") == "Death Talon Wyrmkin" and GetRaidTargetIndex("target") == MB_myCCTarget then
        CastSpellByName("Hibernate(Rank 1)")
        return 
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
		
    if MB_mySpecc == "Balance" then

        Druid:Balance()
        return

	elseif (MB_mySpecc == "Resto" or MB_mySpecc == "Swiftmend") then
        if Instance.Naxx and UnitFactionGroup("player") == "Alliance" then
            if mb_tankTarget("Venom Stalker") or mb_tankTarget("Necro Stalker") then
                if mb_imBusy() then
                    SpellStopCasting()
                end

                mb_meleeBuff("Abolish Poison")
                return
            end
        end

		mb_healerJindoRotation("Wrath")
		DruidHeal()
	end
end

MB_myMultiList["Druid"] = DruidMulti

--[####################################################################################################]--
--[######################################### Multi Tank Code! #########################################]--
--[####################################################################################################]--

function Druid:TankMulti()

	if mb_findInTable(MB_raidTanks, myName) and mb_hasBuffOrDebuff("Greater Blessing of Salvation", "player", "buff") then		
		CancelBuff("Greater Blessing of Salvation") 
	end

	if not mb_isBearForm() then
		mb_selfBuff("Dire Bear Form") 
		mb_cancelDruidShapeShift()
        return
	end

	if mb_inCombat("player") then
		if mb_healthPct("player") < 0.3 and mb_spellReady("Frenzied Regeneration") then			
			CastSpellByName("Frenzied Regeneration") 
		end

		if mb_inMeleeRange() then
			if mb_debuffSunderAmount() == 5 or mb_hasBuffOrDebuff("Expose Armor", "target", "debuff") then
				Druid:Cooldowns()
			end

			if mb_spellReady("Bash") and mb_stunnableMob() then				
				CastSpellByName("Bash")
			end

			if not mb_hasBuffOrDebuff("Demoralizing Shout", "target", "debuff") then 
                if UnitName("target") ~= "Emperor Vek\'nilash" or UnitName("target") ~= "Emperor Vek\'lor" then				
                    if not mb_hasBuffOrDebuff("Demoralizing Roar", "target", "debuff") and UnitMana("player") >= 20 then					
                        CastSpellByName("Demoralizing Roar")
                    end
                end
			end
		end
	end

	mb_offTank()

    local tOfTarget = UnitName("targettarget") or ""
    local tName = UnitName("target") or ""

    local shouldTaunt = tName ~= "" 
        and tOfTarget ~= "" and tOfTarget ~= "Unknown" 
        and UnitIsEnemy("player", "target") 
        and not mb_findInTable(MB_raidTanks, tOfTarget)

    if shouldTaunt then
        if MB_myOTTarget then
            if tOfTarget ~= myName then
                Druid:Taunt()
            end
        else
            Druid:Taunt()
        end
    end

	if MB_myOTTarget then
		if UnitExists("target") and GetRaidTargetIndex("target") and GetRaidTargetIndex("target") == MB_myOTTarget and UnitIsDead("target") then
			MB_myOTTarget = nil
			ClearTarget()
		end
	end

	mb_autoAttack()

    if not mb_hasBuffOrDebuff("Faerie Fire (Feral)", "target", "debuff") 
        and not mb_hasBuffOrDebuff("Faerie Fire", "target", "debuff") then
        CastSpellByName("Faerie Fire (Feral)()")
    end

    if mb_spellReady("Enrage") and UnitMana("player") <= 15 then        
        CastSpellByName("Enrage")
    end
		
    if UnitMana("player") > 12 then 
        CastSpellByName("Swipe")
    end
		
    if UnitMana("player") > 19 then 
        CastSpellByName("Maul") 
    end
end

--[####################################################################################################]--
--[########################################### AOE Code! ##############################################]--
--[####################################################################################################]--

local function DruidAOE()

	if mb_tankTarget("Maexxna") and MB_myMaexxnaBoxStrategy and mb_imHealer() then		
        if MB_myAssignedHealTarget then
            if mb_isAlive(MBID[MB_myAssignedHealTarget]) then			
                Druid:MTHeals(MB_myAssignedHealTarget)
                return
            else
                MB_myAssignedHealTarget = nil
                RunLine("/raid My healtarget died, time to ALT-F4.")
            end
        end

		if mb_myNameInTable(MB_myMaexxnaDruidHealer) then
			Druid:MaxRejuvAggroedPlayer()
			Druid:MaxAbolishAggroedPlayer()
			Druid:MaxRegrowthAggroedPlayer()
			return
		end
	end	

	DruidMulti()
end

MB_myAOEList["Druid"] = DruidAOE

--[####################################################################################################]--
--[########################################## SETUP Code! #############################################]--
--[####################################################################################################]--

local function DruidSetup()

	if mb_isDruidShapeShifted() and not mb_inCombat("player") then		
		mb_cancelDruidShapeShift()
	end
	
	if UnitMana("player") < 3060 and mb_hasBuffNamed("Drink", "player") then
		return
	end

    if not MB_autoBuff.Active then
        MB_autoBuff.Active = true
        MB_autoBuff.Time = GetTime() + 0.25
        DruidCounter.Cycle()
    end

	mb_selfBuff("Omen of Clarity")

	if mb_myClassAlphabeticalOrder() == MB_buffingCounterDruid then				
		mb_multiBuff("Gift of the Wild")
	end

	if MB_raidAssist.Druid.BuffTanksWithThorns then		
		mb_tankBuff("Thorns")
	end

	if not mb_inCombat("player") and mb_manaPct("player") < 0.20 and not mb_hasBuffNamed("Drink", "player") then
		mb_smartDrink()
	end
end

MB_mySetupList["Druid"] = DruidSetup

--[####################################################################################################]--
--[######################################### PRECAST Code! ############################################]--
--[####################################################################################################]--

local function DruidPreCast()
	for k, trinket in pairs(MB_casterTrinkets) do
		if mb_itemNameOfEquippedSlot(13) == trinket and not mb_trinketOnCD(13) then 
			use(13) 
		end

		if mb_itemNameOfEquippedSlot(14) == trinket and not mb_trinketOnCD(14) then 
			use(14) 
		end
	end

    CastSpellByName("Starfire")
end

MB_myPreCastList["Druid"] = DruidPreCast

--[####################################################################################################]--
--[########################################## Helper Code! ############################################]--
--[####################################################################################################]--

function Druid:GetActiveVaelastraszDruid()
    for _, druidName in ipairs(MB_myVaelastraszDruids) do
        if not mb_dead(MBID[druidName]) then
            return druidName
        end
    end
    return nil
end

function Druid:Cooldowns()
	if mb_imBusy() or not mb_inCombat("player") then
		return
	end

    if MB_mySpecc == "Feral" then        
        mb_meleeTrinkets()
        return
    end

    mb_healerTrinkets()
    mb_casterTrinkets()    
end

function Druid:Taunt()
	if mb_spellReady("Growl") then		
		CastSpellByName("Growl")
		return
	end

	if UnitName("target") and mb_inCombat("target") then
		if mb_spellReady("Faerie Fire (Feral)()") then			
			CastSpellByName("Faerie Fire (Feral)()")
		end
	end
end

--[####################################################################################################]--
--[######################################### LOATHEB Code! ############################################]--
--[####################################################################################################]--

local function DruidLoathebHeal()

	if mb_loathebHealing() then
		return
	end
	
	if mb_inCombat("player") then
		Druid:HealerDebuffs()
		Druid:Innervate()

		mb_takeManaPotionAndRune()
		mb_takeManaPotionIfBelowManaPotMana()
		mb_takeManaPotionIfBelowManaPotManaInRazorgoreRoom()

        if mb_manaDown("player") > 600 then
            Druid:Cooldowns()
        end
	end

	mb_coolDownCast("Starfire", 8)
end

MB_myLoathebList["Druid"] = DruidLoathebHeal