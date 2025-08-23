--[####################################################################################################]--
--[####################################### START PRIEST CODE! #########################################]--
--[####################################################################################################]--

-- Unit Functions
local UnitName = UnitName
local UnitClass = UnitClass
local UnitRace = UnitRace
local UnitLevel = UnitLevel
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitMana = UnitMana
local UnitManaMax = UnitManaMax
local UnitPowerType = UnitPowerType
local UnitExists = UnitExists
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitIsDead = UnitIsDead
local UnitIsGhost = UnitIsGhost
local UnitIsConnected = UnitIsConnected
local UnitInParty = UnitInParty
local UnitInRaid = UnitInRaid
local UnitCanAttack = UnitCanAttack
local UnitIsFriend = UnitIsFriend
local UnitIsEnemy = UnitIsEnemy
local UnitIsVisible = UnitIsVisible
local UnitAffectingCombat = UnitAffectingCombat
local UnitCreatureType = UnitCreatureType
local UnitClassification = UnitClassification

-- Buff/Debuff Functions
local UnitBuff = UnitBuff
local UnitDebuff = UnitDebuff

-- Spell Functions
local CastSpellByName = CastSpellByName
local GetSpellCooldown = GetSpellCooldown
local IsCurrentAction = IsCurrentAction

-- Target Functions
local TargetUnit = TargetUnit
local TargetByName = TargetByName
local ClearTarget = ClearTarget
local AssistUnit = AssistUnit

-- Party/Raid Functions
local GetNumPartyMembers = GetNumPartyMembers
local GetNumRaidMembers = GetNumRaidMembers
local GetRaidRosterInfo = GetRaidRosterInfo
local IsRaidLeader = IsRaidLeader

-- Player Position/Info Functions
local GetRealZoneText = GetRealZoneText
local GetSubZoneText = GetSubZoneText

-- Addon Communication (if supported on your server)
local SendAddonMessage = SendAddonMessage

-- Misc Utility Functions
local IsShiftKeyDown = IsShiftKeyDown
local IsControlKeyDown = IsControlKeyDown
local IsAltKeyDown = IsAltKeyDown

-- Common Names
local myClass = UnitClass("player")
local myName = UnitName("player")
local myRace = UnitRace("player")

-- Disable File Loading Completely
if myClass ~= "Priest" then return end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local AutoWandAttack = mb_autoWandAttack
local BossNeverInterruptHeal = mb_bossNeverInterruptHeal
local CasterTrinkets = mb_casterTrinkets
local CastSpellOnRandomRaidMember = mb_castSpellOnRandomRaidMember
local CastSpellOrWand = mb_castSpellOrWand
local CdMessage = mb_cdMessage
local CoolDownCast = mb_coolDownCast
local CrowdControl = mb_crowdControl
local CrowdControlledMob = mb_crowdControlledMob
local CrowdControlMCedRaidMemberSkeramAOE = mb_crowdControlMCedRaidMemberSkeramAOE
local Dead = mb_dead
local DebuffShadowWeavingAmount = mb_debuffShadowWeavingAmount
local Decurse = mb_decurse
local GetMCActions = mb_getMCActions
local GetTarget = mb_getTarget
local HasBuffNamed = mb_hasBuffNamed
local HasBuffOrDebuff = mb_hasBuffOrDebuff
local HealerJindoRotation = mb_healerJindoRotation
local HealerTrinkets = mb_healerTrinkets
local HealerWand = mb_healerWand
local HealLieutenantAQ20 = mb_healLieutenantAQ20
local HealthDown = mb_healthDown
local HealthPct = mb_healthPct
local ImBusy = mb_imBusy
local In28yardRange = mb_in28yardRange
local InCombat = mb_inCombat
local InstructorRazAddsHeal = mb_instructorRazAddsHeal
local IsAlive = mb_isAlive
local IsAtInstructorRazuvious = mb_isAtInstructorRazuvious
local IsAtSkeram = mb_isAtSkeram
local IsValidEnemyTargetWithin28YardRange = mb_isValidEnemyTargetWithin28YardRange
local IsValidFriendlyTarget = mb_isValidFriendlyTarget
local IsValidFriendlyTargetWithin28YardRange = mb_isValidFriendlyTargetWithin28YardRange
local ItemNameOfEquippedSlot = mb_itemNameOfEquippedSlot
local KnowSpell = mb_knowSpell
local LoathebHealing = mb_loathebHealing
local ManaDown = mb_manaDown
local ManaPct = mb_manaPct
local MobsToFearWard = mb_mobsToFearWard
local MultiBuff = mb_multiBuff
local MyClassAlphabeticalOrder = mb_myClassAlphabeticalOrder
local MyClassOrder = mb_myClassOrder
local MyGroupClassOrder = mb_myGroupClassOrder
local MyNameInTable = mb_myNameInTable
local ReturnPlayerInRaidFromTable = mb_returnPlayerInRaidFromTable
local SelfBuff = mb_selfBuff
local SmartDrink = mb_smartDrink
local SpellReady = mb_spellReady
local TakeManaPotionAndRune = mb_takeManaPotionAndRune
local TakeManaPotionIfBelowManaPotMana = mb_takeManaPotionIfBelowManaPotMana
local TakeManaPotionIfBelowManaPotManaInRazorgoreRoom = mb_takeManaPotionIfBelowManaPotManaInRazorgoreRoom
local TankName = mb_tankName
local TankTarget = mb_tankTarget
local TankTargetHealth = mb_tankTargetHealth
local TargetMyAssignedTankToHeal = mb_targetMyAssignedTankToHeal
local TrinketOnCD = mb_trinketOnCD

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local Priest = CreateFrame("Frame", "Priest")

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

	if InCombat("player") then
		if MB_raidLeader and MyClassOrder() == 1 and (TankTarget("Garr") or TankTarget("Firesworn")) then
			if HasBuffOrDebuff("Magma Shackles", MBID[MB_raidLeader], "debuff") then
				
				TargetUnit(MBID[MB_raidLeader])
				CastSpellByName("Dispel Magic")
				TargetLastTarget()
			end
		end

		Priest:PowerInfusion()

		TakeManaPotionAndRune()
		TakeManaPotionIfBelowManaPotMana()
		TakeManaPotionIfBelowManaPotManaInRazorgoreRoom()

		if ManaDown("player") > 600 then
            Priest:Cooldowns()
        end

		if Priest:ManaDrain() then
            return
        end

		if SpellReady("Desperate Prayer") and HealthPct("player") < 0.2 then			
			CastSpellByName("Desperate Prayer")
			return
		end
	end

	if HasBuffOrDebuff("Curse of Tongues", "player", "debuff") and not TankTarget("Anubisath Defender") then
        return
    end

	if HealLieutenantAQ20() then
        return
    end

	if InstructorRazAddsHeal() then
        return
    end

	if MB_myAssignedHealTarget then		
		if IsAlive(MBID[MB_myAssignedHealTarget]) then			
			Priest:MTHeals(MB_myAssignedHealTarget)
			return
		else			
			MB_myAssignedHealTarget = nil
			CdMessage("My healtarget died, time to ALT-F4.")
		end
	end

	for k, bossName in pairs(MB_myPriestMainTankHealingBossList) do
		if TankTarget(bossName) then			
			Priest:MTHeals()
			return
		end
	end

	if MB_isMoving.Active then
        CastSpellOnRandomRaidMember("Renew", MB_priestRenewLowRandomRank, MB_priestRenewLowRandomPercentage)
    end	

	if Instance.AQ40 and TankTarget("Princess Huhuran") then
				
		if TankTargetHealth() <= 0.32 then			
			if Priest:PrayerOfHealingCheck(4, 1, 3, true) and MyGroupClassOrder() == 1 then
				return
			end

			MBH_CastHeal("Flash Heal", 4, 6)
			return
		end
		
		MBH_CastHeal("Heal")
		
	elseif Instance.BWL then
		if TankTarget("Vaelastrasz the Corrupt") and MB_myVaelastraszBoxStrategy then

			Priest:Cooldowns()

			if MB_myVaelastraszPriestHealing and not HasBuffOrDebuff("Burning Adrenaline", "player", "debuff") then
				local activePriest = Priest:GetActiveVaelastraszPriest()
				
				if myName == activePriest then
					Priest:MaxRenewAggroedPlayer()
					Priest:ShieldAggroedPlayer()
				else
					Priest:ShieldToBombFollowTarget()
				end
			end

			if Priest:PrayerOfHealingCheck(5, 1, 3, true) and MyGroupClassOrder() == 1 then
				return
			end
	
			MBH_CastHeal("Flash Heal", 7, 7)
			return

		elseif TankTarget("Nefarian") and HasBuffOrDebuff("Corrupted Healing", "player", "debuff") then

			if ImBusy() then					
				SpellStopCasting()
			end

			if SpellReady("Power Word: Shield") then					
				CastSpellOnRandomRaidMember("Weakened Soul", "rank 10", 0.9)
			end	
			
			CastSpellOnRandomRaidMember("Renew", "rank 10", 0.95)		
			return

		elseif TankTarget("Chromaggus") and MB_myHealSpell ~= "Flash Heal" then
			MB_myHealSpell = "Flash Heal"
		end
	end

	if not ImBusy() then
		if MyGroupClassOrder() == 1 then
			for rank = 5, 1, -1 do
				local focus = PrayerFocusRanks[rank] or false
				if Priest:PrayerOfHealingCheck(rank, rank, 4, focus) then
					return
				end
			end
		end

		if InCombat("player") then
			if SpellReady("Power Word: Shield") then 
				Priest:ShieldAggroedPlayer()
				CastSpellOnRandomRaidMember("Weakened Soul", "rank 10", MB_priestShieldLowRandomPercentage)
			end

			Priest:RenewAggroedPlayer()
			CastSpellOnRandomRaidMember("Renew", MB_priestRenewLowRandomRank, MB_priestRenewLowRandomPercentage)
		end
	end

	if HasBuffOrDebuff("Inner Focus", "player", "buff") then
		MBH_CastHeal("Flash Heal", 6, 6)

	elseif MB_myHealSpell == "Greater Heal" or HasBuffOrDebuff("Hazza\'rah\'s Charm of Healing", "player", "buff") then
		MBH_CastHeal("Greater Heal", 1, 1)
		
	elseif MB_myHealSpell == "Heal" then
		MBH_CastHeal("Heal")
		
	elseif MB_myHealSpell == "Flash Heal" then
		MBH_CastHeal("Flash Heal")
	else
		MBH_CastHeal("Heal")
	end

	HealerWand()
end

local GreaterHeal = { Time = 0, Interrupt = false }
function Priest:MTHeals(assignedTarget)
	
	if assignedTarget then		
		TargetByName(assignedTarget, 1)
	else
		if TankTarget("Patchwerk") and MB_myPatchwerkBoxStrategy then			
			TargetMyAssignedTankToHeal()
		else
			if not UnitName(MBID[TankName()].."targettarget") then 				
				MBH_CastHeal("Greater Heal", 1, 1)
			else
				TargetByName(UnitName(MBID[TankName()].."targettarget"), 1) 
			end
		end
	end

	if Instance.BWL and TankTarget("Nefarian") then
		if HasBuffOrDebuff("Corrupted Healing", "player", "debuff") then

			if ImBusy() then					
				SpellStopCasting()
			end

			if SpellReady("Power Word: Shield") then					
				CastSpellOnRandomRaidMember("Weakened Soul", "rank 10", 0.9)
			end	
			
			CastSpellOnRandomRaidMember("Renew", "rank 10", 0.95)		
			return
		end
	end

	if (HealthPct("target") < 0.5) and SpellReady("Power Word: Shield") and not HasBuffOrDebuff("Weakened Soul", "target", "debuff") then		
		CastSpellByName("Power Word: Shield")
	end

	local GreatHealSpell = "Greater Heal("..MB_myPriestMainTankHealingRank.."\)"
	if TankTarget("Vaelastrasz the Corrupt") then
		GreatHealSpell = "Greater Heal"
	end

	if not BossNeverInterruptHeal() and HealthDown("target") <= (GetHealValueFromRank("Greater Heal", MB_myPriestMainTankHealingRank) * MB_myMainTankOverhealingPercentage) then
		if GetTime() > GreaterHeal.Time and GetTime() < GreaterHeal.Time + 0.5 and GreaterHeal.Interrupt then
			SpellStopCasting()			
			GreaterHeal.Interrupt = false
			SpellStopCasting()
		end
	end

	if not ImBusy() then
		CastSpellByName(GreatHealSpell)
		GreaterHeal.Time = GetTime() + 1
		GreaterHeal.Interrupt = true
	end
end

function Priest:MaxShieldAggroedPlayer()
    if not MBID[MB_raidLeader] then
        return
    end

	if ImBusy() then
        return
    end

    if TankTarget("Garr") or TankTarget("Firesworn") then
        return
    end

    local shieldTarget = MBID[MB_raidLeader].."targettarget"
    if not IsValidFriendlyTarget(shieldTarget, "Power Word: Shield") then
        return
    end

    if HealthPct(shieldTarget) > 0.95 then
        return
    end

    if HasBuffOrDebuff("Weakened Soul", shieldTarget, "debuff") then
        return
    end

    if not SpellReady("Power Word: Shield") then
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

	if ImBusy() then
        return
    end

    if TankTarget("Garr") or TankTarget("Firesworn") then
        return
    end

    local renewTarget = MBID[MB_raidLeader].."targettarget"
    if not IsValidFriendlyTarget(renewTarget, "Renew") then
        return
    end

    if HealthPct(renewTarget) > 0.95 then
        return
    end

    if HasBuffNamed("Renew", renewTarget) then
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
    if ImBusy() then
        return
    end

    if TankTarget("Garr") or TankTarget("Firesworn") then
        return
    end

    local aggrox = AceLibrary("Banzai-1.0")

    for i = 1, GetNumRaidMembers() do
        local renewTarget = "raid"..i

        if aggrox:GetUnitAggroByUnitId(renewTarget)
           and IsValidFriendlyTarget(renewTarget, "Renew")
           and HealthPct(renewTarget) <= MB_priestRenewAggroedPlayerPercentage
           and not HasBuffNamed("Renew", renewTarget) then

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
    if ImBusy() then
        return
    end

    if TankTarget("Garr") or TankTarget("Firesworn") then
        return
    end

    local aggrox = AceLibrary("Banzai-1.0")

    for i = 1, GetNumRaidMembers() do
        local shieldTarget = "raid"..i

        if aggrox:GetUnitAggroByUnitId(shieldTarget)
           and IsValidFriendlyTarget(shieldTarget, "Power Word: Shield")
           and HealthPct(shieldTarget) <= MB_priestShieldAggroedPlayerPercentage
           and not HasBuffOrDebuff("Weakened Soul", shieldTarget, "debuff")
           and SpellReady("Power Word: Shield") then

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

	if ImBusy() then
        return
    end

    if TankTarget("Garr") or TankTarget("Firesworn") then
        return
    end

    local fearWardTarget = MBID[MB_raidLeader].."targettarget"
    if not IsValidFriendlyTarget(fearWardTarget, "Fear Ward") then
        return false
    end

    if HasBuffNamed("Fear Ward", fearWardTarget) then
        return false
    end

    if UnitPowerType(fearWardTarget) ~= 1 then
        return false
    end

    if UnitIsFriend("player", fearWardTarget) then
        ClearTarget()
    end

    CdMessage("Focus Fear Ward on "..UnitName(fearWardTarget), 30)

    CastSpellByName("Fear Ward")
    SpellTargetUnit(fearWardTarget)
    SpellStopTargeting()
    return true
end

function Priest:ShieldToBombFollowTarget()
    if ImBusy() or TankTarget("Vaelastrasz the Corrupt") then
        return
    end

    local targetName = ReturnPlayerInRaidFromTable(MB_raidAssist.GTFO.Vaelastrasz)
    local targetID = MBID[targetName]

    if not targetID 
		or not IsAlive(targetID) 
		or HasBuffOrDebuff("Weakened Soul", targetID, "debuff") 
		or not SpellReady("Power Word: Shield") then
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
	
    GetTarget()

	if CrowdControl() then
        return
    end

	if UnitName("target") then
        if MB_myCCTarget and GetRaidTargetIndex("target") == MB_myCCTarget and not HasBuffOrDebuff(MB_myCCSpell[myClass], "target", "debuff") then			
            if CrowdControl() then
                return
            end
        end        

        if CrowdControlledMob() then
            GetTarget()
        end
	end

	if Instance.NAXX then

        if (TankTarget("Instructor Razuvious") and MyNameInTable(MB_myRazuviousPriest) and MB_myRazuviousBoxStrategy) or
            (TankTarget("Grand Widow Faerlina") and MyNameInTable(MB_myFaerlinaPriest) and MB_myFaerlinaBoxStrategy) then
            GetMCActions()
            return
        end

	elseif Instance.AQ40 then
		
		if HasBuffOrDebuff("True Fulfillment", "target", "debuff") then
            ClearTarget()
            return
        end

		if IsAtSkeram() then
            if not MB_autoToggleSheeps.Active then
                MB_autoToggleSheeps.Active = true
                MB_autoToggleSheeps.Time = GetTime() + 3
                PriestCounter.Cycle()
            end

            if MyClassAlphabeticalOrder() == MB_buffingCounterPriest then
                CrowdControlMCedRaidMemberSkeramAOE()
            end
		end
	end

	Priest:Fade()
	Decurse()

	if MB_mySpecc == "Bitch" then
        Priest:ShadowWeaving()

    elseif MB_mySpecc == "Shadow" then

        Priest:Shadow()
        return
    end

	HealerJindoRotation("Smite")
	PriestHeal()
end

MB_mySingleList["Priest"] = PriestSingle

--[####################################################################################################]--
--[########################################## SHADOW Code! ############################################]--
--[####################################################################################################]--

function Priest:Shadow()

    SelfBuff("Shadowform")

	if not InCombat("target") then
        return
    end

    if InCombat("player") then
        if Instance.MC then
            if TankTarget("Shazzrah") and HasBuffOrDebuff("Deaden Magic", "target", "buff") then
                CastSpellByName("Dispel Magic")
            end
        end

		TakeManaPotionAndRune()
		TakeManaPotionIfBelowManaPotMana()
		TakeManaPotionIfBelowManaPotManaInRazorgoreRoom()

		if ManaDown("player") > 600 then
            Priest:Cooldowns()
        end

		if SpellReady("Desperate Prayer") and HealthPct("player") < 0.2 then			
			CastSpellByName("Desperate Prayer")
			return
		end
	end

    if Priest:BossSpecificDPS() then
        return
    end

    if ImBusy() then
        return
    end

	if SpellReady("Mind Blast") then 
		CastSpellOrWand("Mind Blast") 
	end

	CastSpellOrWand("Mind Flay") 
end

function Priest:ShadowWeaving()
    local focusUnit = MB_raidLeader or MB_raidInviter

    if focusUnit then
        local targetUnit = MBID[focusUnit].."target"
        local canCastDirectly = (UnitCanAttack("player", targetUnit) and DebuffShadowWeavingAmount() < 5) 
                            and IsValidEnemyTargetWithin28YardRange(targetUnit)
        
        AssistUnit(MBID[focusUnit])
        
        if canCastDirectly then
            CastSpellByName("Shadow Word: Pain(Rank 1)")
            return true
        else
            CoolDownCast("Shadow Word: Pain(Rank 1)", 24)
        end
    end	
	return false
end

function Priest:BossSpecificDPS()

	if UnitName("target") == "Emperor Vek\'nilash" then
        return true
    end

	if HasBuffNamed("Shadow and Frost Reflect", "target") then

		AutoWandAttack()
		return true

	elseif HasBuffOrDebuff("Magic Reflection", "target", "buff") then

		if ImBusy() then
			SpellStopCasting()
		end

		AutoWandAttack()
		return true

	elseif TankTarget("Azuregos") and HasBuffNamed("Magic Shield", "target") then
		
		if ImBusy() then
			SpellStopCasting()
		end

		AutoWandAttack()
		return true
	end

    if Instance.IsWorldBoss() and UnitName("target") ~= "Nefarian" then
		if not HasBuffOrDebuff("Vampiric Embrace", "target", "debuff") then
			CastSpellByName("Vampiric Embrace")
		end
	end

	Priest:ManaDrain()

	if Instance.AQ40 and TankTarget("Battleguard Sartura") then			
		CoolDownCast("Shadow Word: Pain", 24)
	
	elseif Instance.MC then
        CoolDownCast("Shadow Word: Pain(Rank 1)", 24)

	elseif Instance.ONY and TankTarget("Onyxia") then
		CoolDownCast("Shadow Word: Pain", 24)
	elseif not UnitInRaid("player") and DebuffShadowWeavingAmount() > 5 then
		CoolDownCast("Shadow Word: Pain", 24)
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

	if TankTarget("Maexxna") and MB_myMaexxnaBoxStrategy then
		if MB_myAssignedHealTarget then		
			if IsAlive(MBID[MB_myAssignedHealTarget]) then			
				Priest:MTHeals(MB_myAssignedHealTarget)
				return
			else			
				MB_myAssignedHealTarget = nil
				RunLine("/raid My healtarget died, time to ALT-F4.")
			end
		end

		if MyNameInTable(MB_myMaexxnaPriestHealer) then			
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

	if UnitMana("player") < 3060 and HasBuffNamed("Drink", "player") then
		return
	end

	if not MB_autoBuff.Active then
		MB_autoBuff.Active = true
		MB_autoBuff.Time = GetTime() + 0.25
		PriestCounter.Cycle()
	end

	if MyClassAlphabeticalOrder() == MB_buffingCounterPriest then
		SelfBuff("Inner Focus")
		MultiBuff("Prayer of Fortitude")

		if Instance.NAXX or Instance.AQ40 then
			if KnowSpell("Prayer of Spirit") then				
				MultiBuff("Prayer of Spirit")
			end
		end

		if Instance.NAXX and not IsAtInstructorRazuvious() then										
			MultiBuff("Prayer of Shadow Protection")
		end

		if SpellReady("Fear Ward") and MobsToFearWard() then
			MultiBuff("Fear Ward")
		end
	end

	SelfBuff("Inner Fire")
	SelfBuff("Shadowform")

	if not InCombat("player") and ManaPct("player") < 0.20 and not HasBuffNamed("Drink", "player") then
		SmartDrink()
	end
end

MB_mySetupList["Priest"] = PriestSetup

--[####################################################################################################]--
--[######################################### PRECAST Code! ############################################]--
--[####################################################################################################]--

local function PriestPreCast()
	for k, trinket in pairs(MB_casterTrinkets) do
		if ItemNameOfEquippedSlot(13) == trinket and not TrinketOnCD(13) then 
			use(13) 
		end

		if ItemNameOfEquippedSlot(14) == trinket and not TrinketOnCD(14) then 
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
		SelfBuff("Fade")
	end
end

function Priest:Cooldowns()
	if ImBusy() or not InCombat("player") then
		return
	end

	SelfBuff("Berserking")

	if ManaPct("player") <= MB_priestInnerFocusPercentage then
		SelfBuff("Inner Focus")
	end

	HealerTrinkets()
	CasterTrinkets()
end

function Priest:PrayerOfHealingCheck(manaRank, checkRank, minTargets, focus)
    local cost = PrayerManaCost[manaRank]
    if not cost then return false end

	if not checkRank then
		checkRank = manaRank
	end

    if UnitMana("player") >= cost then
		local healValue = GetHealValueFromRank("Prayer of Healing", "Rank "..checkRank)
        if Priest:PartyHurt(healValue, minTargets) then
            if focus then
                SelfBuff("Inner Focus")
            end
	
            CastSpellByName("Prayer of Healing(Rank "..manaRank..")")
            return true
        end
    end
    return false
end

function Priest:GetActiveVaelastraszPriest()
    for _, priestName in ipairs(MB_myVaelastraszPriests) do
        if not Dead(MBID[priestName]) then
            return priestName
        end
    end
    return nil
end

function Priest:ManaDrain()
	if ImBusy() then
		return false
	end

	if (Instance.AQ40 and TankTarget("Obsidian Eradicator")) or
		(Instance.AQ20 and TankTarget("Moam")) then
		if ManaPct("target") > 0.25 then
			CastSpellOrWand("Mana Burn")
			return true
		end
	end
	return false
end

function Priest:PowerInfusion()
	if ImBusy() then
		return false
	end

	if not (InCombat("player") and SpellReady("Power Infusion")) then
		return
	end

	if not MB_autoBuff.Active then
		MB_autoBuff.Active = true
		MB_autoBuff.Time = GetTime() + 2.5
		PriestCounter.Cycle()
	end

	if MyClassAlphabeticalOrder() == MB_buffingCounterPriest then
		for k, caster in pairs(MB_raidAssist.Priest.PowerInfusionList) do
			if MBID[caster] then
				if IsValidFriendlyTargetWithin28YardRange(MBID[caster]) 
					and not HasBuffOrDebuff("Power Infusion", MBID[caster], "buff") 
					and InCombat(MBID[caster]) 
					and ManaPct(MBID[caster]) < 0.9 
					and ManaPct(MBID[caster]) > 0.1 then

					TargetByName(caster)
					CastSpellByName("Power Infusion")
					CdMessage("Power Infusion on "..GetColors(UnitName(MBID[caster])).."!")
					return
				end
			end
		end
	end
end

function Priest:PartyHurt(hurt, num_party_hurt)
	local numHurt = 0
	local myHurt = HealthDown("player")

	if myHurt > hurt then 
		numHurt = numHurt + 1 
	end

    for i = 1, GetNumPartyMembers() do
        local guysHurt = UnitHealthMax("party"..i) - UnitHealth("party"..i)
        if guysHurt > hurt and In28yardRange("party"..i) and not Dead("party"..i) then 
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

	if LoathebHealing() then
		return
	end
	
	if InCombat("player") then
		Priest:PowerInfusion()

		TakeManaPotionAndRune()
		TakeManaPotionIfBelowManaPotMana()
		TakeManaPotionIfBelowManaPotManaInRazorgoreRoom()

		if ManaDown("player") > 600 then
            Priest:Cooldowns()
        end

		if Priest:ManaDrain() then
            return
        end

		if SpellReady("Desperate Prayer") and HealthPct("player") < 0.2 then			
			CastSpellByName("Desperate Prayer")
			return
		end
	end

	CoolDownCast("Smite", 8)
	HealerWand()
end

MB_myLoathebList["Priest"] = PriestLoathebHeal
