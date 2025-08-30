--[####################################################################################################]--
--[######################################## START DRUID CODE! #########################################]--
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
if myClass ~= "Druid" then return end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local AnubisathAlert = mb_anubisathAlert
local AutoAttack = mb_autoAttack
local AutoWandAttack = mb_autoWandAttack
local BossNeverInterruptHeal = mb_bossNeverInterruptHeal
local CancelDruidShapeShift = mb_cancelDruidShapeShift
local CasterTrinkets = mb_casterTrinkets
local CastSpellOnRandomRaidMember = mb_castSpellOnRandomRaidMember
local CastSpellOrWand = mb_castSpellOrWand
local CdMessage = mb_cdMessage
local CoolDownCast = mb_coolDownCast
local CrowdControl = mb_crowdControl
local CrowdControlledMob = mb_crowdControlledMob
local Dead = mb_dead
local DebuffSunderAmount = mb_debuffSunderAmount
local Decurse = mb_decurse
local GetNumPartyOrRaidMembers = mb_GetNumPartyOrRaidMembers
local GetTarget = mb_getTarget
local HasBuffNamed = mb_hasBuffNamed
local HasBuffOrDebuff = mb_hasBuffOrDebuff
local HealerJindoRotation = mb_healerJindoRotation
local HealerTrinkets = mb_healerTrinkets
local HealLieutenantAQ20 = mb_healLieutenantAQ20
local HealthDown = mb_healthDown
local HealthPct = mb_healthPct
local ImBusy = mb_imBusy
local ImHealer = mb_imHealer
local InCombat = mb_inCombat
local InMeleeRange = mb_inMeleeRange
local InstructorRazAddsHeal = mb_instructorRazAddsHeal
local IsAlive = mb_isAlive
local IsAtRazorgorePhase = mb_isAtRazorgorePhase
local IsBearForm = mb_isBearForm
local IsBoomForm = mb_isBoomForm
local IsDruidShapeShifted = mb_isDruidShapeShifted
local IsValidFriendlyTarget = mb_isValidFriendlyTarget
local ItemNameOfEquippedSlot = mb_itemNameOfEquippedSlot
local KnowSpell = mb_knowSpell
local LoathebHealing = mb_loathebHealing
local ManaDown = mb_manaDown
local ManaPct = mb_manaPct
local MeleeBuff = mb_meleeBuff
local MeleeTrinkets = mb_meleeTrinkets
local MultiBuff = mb_multiBuff
local MyClassAlphabeticalOrder = mb_myClassAlphabeticalOrder
local MyClassOrder = mb_myClassOrder
local MyGroupClassOrder = mb_myGroupClassOrder
local MyNameInTable = mb_myNameInTable
local NatureSwiftnessLowAggroedPlayer = mb_natureSwiftnessLowAggroedPlayer
local OffTank = mb_offTank
local ReturnPlayerInRaidFromTable = mb_returnPlayerInRaidFromTable
local SelfBuff = mb_selfBuff
local SmartDrink = mb_smartDrink
local SpellReady = mb_spellReady
local StunnableMob = mb_stunnableMob
local TakeManaPotionAndRunes = mb_takeManaPotionAndRunes
local TankBuff = mb_tankBuff
local TankName = mb_tankName
local TankTarget = mb_tankTarget
local TankTargetHealth = mb_tankTargetHealth
local TargetFromSpecificPlayer = mb_targetFromSpecificPlayer
local TargetMyAssignedTankToHeal = mb_targetMyAssignedTankToHeal
local TrinketOnCD = mb_trinketOnCD

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local Druid = CreateFrame("Frame", "Druid")

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

    _, _, _, _, TalentsIn = GetTalentInfo(1, 16)
    if TalentsIn > 0 then
        MB_mySpecc = "Balance"
        return 
    end

    _, _, _, _, TalentsIn = GetTalentInfo(2, 16)
    if TalentsIn > 0 then
        MB_mySpecc = "Feral"
        return 
    end

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

    MB_mySpecc = nil
end

local function ImprovedRegrowthCheck()
	local _, _, _, _, TalentsIn = GetTalentInfo(3, 14)
	if TalentsIn > 2 then
		return true
	end
	return false
end

MB_mySpeccList["Druid"] = DruidSpecc

--[####################################################################################################]--
--[######################################### HEALING Code! ############################################]--
--[####################################################################################################]--

local function DruidHeal()
	
	if NatureSwiftnessLowAggroedPlayer() then
        return
    end

	Decurse()

	if InCombat("player") then
		Druid:HealerDebuffs()
		Druid:Innervate()

		TakeManaPotionAndRunes()

        if ManaDown("player") > 600 then
            Druid:Cooldowns()
        end
	end

	if HasBuffOrDebuff("Curse of Tongues", "player", "debuff") and not TankTarget("Anubisath Defender") then
        return
    end

	if Instance.MC() and TankTarget("Shazzrah") then
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
			Druid:MTHeals(MB_myAssignedHealTarget)
			return
		else
			MB_myAssignedHealTarget = nil
			RunLine("/raid My healtarget died, time to ALT-F4.")
		end
	end

	for k, bossName in pairs(MB_myDruidMainTankHealingBossList) do		
		if TankTarget(bossName) then			
			Druid:MTHeals()
			return
		end
	end

	if MB_isMoving.Active then
        if Instance.ONY() and TankTarget("Onyxia") then
            CoolDownCast("Moonfire", 12)            
        end

        CastSpellOnRandomRaidMember("Rejuvenation", MB_druidRejuvenationLowRandomMovingRank, MB_druidRejuvenationLowRandomMovingPercentage)
    end

	if Instance.AQ40() and TankTarget("Princess Huhuran") then
	
        if MyGroupClassOrder() == 1 and TankTargetHealth() <= 0.32 then
            Druid:MTHeals()
            return
        end

		MBH_CastHeal("Healing Touch")
        return

	elseif Instance.BWL() and TankTarget("Vaelastrasz the Corrupt") and MB_myVaelastraszBoxStrategy then

        Druid:Cooldowns()

        if MB_myVaelastraszDruidHealing and not HasBuffOrDebuff("Burning Adrenaline", "player", "debuff") then
            local activeDruid = Druid:GetActiveVaelastraszDruid()

            if myName == activeDruid then
                Druid:MaxRejuvAggroedPlayer()
                Druid:MaxRegrowthAggroedPlayer()
            end
        end

        if SpellReady("Swiftmend") and (swiftmendRaidThrottleTimer == nil or GetTime() - swiftmendRaidThrottleTimer > 1.5) then
            swiftmendRaidThrottleTimer = GetTime();	
            Druid:SwiftmendOnRandomRaidMember("Swiftmend", 0.5)
        end		

        SelfBuff("Rejuvenation")			
        MBH_CastHeal("Regrowth", 9, 9)
        return		
	end

	if not ImBusy() then		
		if MB_myHealSpell == "Rejuvenation" and ManaDown("player") > 300 then
			SelfBuff("Rejuvenation(Rank 1)")
		end

		Druid:RejuvAggroedPlayer()

		if KnowSpell("Swiftmend") then		
			if SpellReady("Swiftmend") then
                Druid:SwiftmendOnRandomRaidMember("Swiftmend", MB_druidSwiftmendAtPercentage)
            end
				
			if (rejuvenationRaidThrottleTimer == nil or GetTime() - rejuvenationRaidThrottleTimer > 1.5) then 
				rejuvenationRaidThrottleTimer = GetTime()	
				CastSpellOnRandomRaidMember("Rejuvenation", MB_druidSwiftmendRejuvenationLowRandomRank, MB_druidSwiftmendRejuvenationLowRandomPercentage)
			end
		else
			if (rejuvenationRaidThrottleTimer == nil or GetTime() - rejuvenationRaidThrottleTimer > 1.5) then 
				rejuvenationRaidThrottleTimer = GetTime()	
				CastSpellOnRandomRaidMember("Rejuvenation", MB_druidRejuvenationLowRandomRank, MB_druidRejuvenationLowRandomPercentage)
			end
		end

		Druid:RegrowthAggroedPlayer()
		
		if (regrowthRaidThrottleTimer == nil or GetTime() - regrowthRaidThrottleTimer > 1.5) then 
			regrowthRaidThrottleTimer = GetTime()
			Druid:RegrowthLowRandom()
		end		
	end

	MBH_CastHeal("Healing Touch")
end

local HealTouch = { Time = 0, Interrupt = false }
function Druid:MTHeals(assignedTarget)

	if assignedTarget then		
		TargetByName(assignedTarget, 1)
	else
		if TankTarget("Patchwerk") and MB_myPatchwerkBoxStrategy then			
			TargetMyAssignedTankToHeal()
		else
			if not UnitName(MBID[TankName()].."targettarget") then				
				MBH_CastHeal("Healing Touch")
			else
				TargetByName(UnitName(MBID[TankName()].."targettarget"), 1) 
			end
		end
	end

	if SpellReady("Nature\'s Swiftness") and HealthPct("target") <= 0.15 then
		if not HasBuffOrDebuff("Nature\'s Swiftness", "player", "buff") then			
			SpellStopCasting()
		end

		SelfBuff("Nature\'s Swiftness")
	end

	if HasBuffOrDebuff("Nature\'s Swiftness", "player", "buff") then			
		CastSpellByName("Healing Touch")
		return
	end

	local HealTouchSpell = "Healing Touch("..MB_myDruidMainTankHealingRank.."\)"
	if TankTarget("Vaelastrasz the Corrupt") then
		HealTouchSpell = "Healing Touch"
	end

    if not BossNeverInterruptHeal() and HealthDown("target") <= (GetHealValueFromRank("Healing Touch", MB_myDruidMainTankHealingRank) * MB_myMainTankOverhealingPercentage) then
		if GetTime() > HealTouch.Time and GetTime() < HealTouch.Time + 0.5 and HealTouch.Interrupt then
			SpellStopCasting()			
			HealTouch.Interrupt = false
			SpellStopCasting()
		end
	end

	if not ImBusy() then
		CastSpellByName(HealTouchSpell)
		HealTouch.Time = GetTime() + 1
		HealTouch.Interrupt = true
	end
end

function Druid:HealerDebuffs()
	if Instance.BWL() then		
		if UnitName("target") == "Death Talon Wyrmkin" or UnitName("target") == "Death Talon Flamescale" then
            return
        end

        if GetSubZoneText() ~= "Dragonmaw Garrison" or not IsAtRazorgorePhase() or not MB_myRazorgoreBoxStrategy then
            return
        end

        local tanks = {
            Right = ReturnPlayerInRaidFromTable(MB_myRazorgoreRightTank),
            Left  = ReturnPlayerInRaidFromTable(MB_myRazorgoreLeftTank)
        }

        for _, tank in pairs(tanks) do
            local targetUnit = MBID[tank].."target"
            if TargetFromSpecificPlayer("Death Talon Dragonspawn", tank) 
                and UnitCanAttack("player", targetUnit)
                and not (HasBuffOrDebuff("Faerie Fire", targetUnit, "debuff")
                or HasBuffOrDebuff("Faerie Fire (Feral)", targetUnit, "debuff")) then

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
        and (not HasBuffOrDebuff("Faerie Fire", targetUnit, "debuff")
        or not HasBuffOrDebuff("Faerie Fire (Feral)", targetUnit, "debuff")) then

        AssistUnit(focusTarget)
        CastSpellByName("Faerie Fire")
        TargetLastTarget()
    end
end

function Druid:Innervate()
    if ImBusy() then
        return
    end

    if Instance.MC() and (TankTarget("Garr") or TankTarget("Firesworn")) then
        return
    end

    if not SpellReady("Innervate") then
        return
    end

    for k, innerTarget in ipairs(MB_myInnervateHealerList) do
        local unitID = MBID[innerTarget]

        if IsValidFriendlyTarget(unitID, "Innervate")
            and HealthPct(unitID) <= 0.5
            and not HasBuffNamed("Innervate", unitID)
            and SpellReady("Innervate") then

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

    if ImBusy() then
        return
    end

    if Instance.MC() and (TankTarget("Garr") or TankTarget("Firesworn")) then
        return
    end

    local rejuvTarget = MBID[MB_raidLeader].."targettarget"
    if not IsValidFriendlyTarget(rejuvTarget, "Rejuvenation") then
        return
    end

    if HealthPct(rejuvTarget) > 0.95 then
        return
    end

    if HasBuffNamed("Rejuvenation", rejuvTarget) then
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

    if ImBusy() then
        return
    end

    if Instance.MC() and (TankTarget("Garr") or TankTarget("Firesworn")) then
        return
    end

    local regroTarget = MBID[MB_raidLeader].."targettarget"
    if not IsValidFriendlyTarget(regroTarget, "Regrowth") then
        return
    end

    if HealthPct(regroTarget) > 0.95 then
        return
    end

    if HasBuffNamed("Regrowth", regroTarget) then
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

    if ImBusy() then
        return
    end

    if Instance.MC() and (TankTarget("Garr") or TankTarget("Firesworn")) then
        return
    end

    local n = GetNumPartyOrRaidMembers()
    local offset = math.random(n) - 1

    for i = 1, n do
        local j = i + offset
        if j > n then j = j - n end

        local raidUnit = "raid"..j
        local hasRejuv = HasBuffNamed("Rejuvenation", raidUnit)
        local hasRegrowth = HasBuffNamed("Regrowth", raidUnit)

        if HealthPct(raidUnit) < percentage 
           and InCombat(raidUnit) 
           and IsValidFriendlyTarget(raidUnit, spell) 
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
    if ImBusy() then
        return
    end

    if Instance.MC() and (TankTarget("Garr") or TankTarget("Firesworn")) then
        return
    end

	local aggrox = AceLibrary("Banzai-1.0")

	for i =  1, GetNumRaidMembers() do		
        local rejuvTarget = "raid"..i

        if aggrox:GetUnitAggroByUnitId(rejuvTarget)
           and IsValidFriendlyTarget(rejuvTarget, "Rejuvenation")
           and HealthPct(rejuvTarget) <= MB_druidRejuvenationAggroedPlayerPercentage
           and not HasBuffNamed("Rejuvenation", rejuvTarget) then

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
    if ImBusy() then
        return
    end

    if Instance.MC() and (TankTarget("Garr") or TankTarget("Firesworn")) then
        return
    end

    if not ImprovedRegrowthCheck() or UnitMana("player") < 880 or MyClassOrder() ~= 1 then
        return
    end
    
    local aggrox = AceLibrary("Banzai-1.0")

	for i =  1, GetNumRaidMembers() do		
        local regroTarget = "raid"..i

        if aggrox:GetUnitAggroByUnitId(regroTarget)
           and IsValidFriendlyTarget(regroTarget, "Regrowth")
           and HealthPct(regroTarget) <= MB_druidSwiftmendRegrowthAggroedPlayerPercentage
           and not HasBuffNamed("Regrowth", regroTarget) then

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
    if ImBusy() then
        return
    end

    if Instance.MC() and (TankTarget("Garr") or TankTarget("Firesworn")) then
        return
    end

    if not ImprovedRegrowthCheck() or UnitMana("player") < 880 then
        return
    end

    if GetRaidRosterInfo(1) then

        for i = 1, GetNumRaidMembers() do
            if HealthPct("raid"..i) < MB_druidSwiftmendRegrowthLowRandomPercentage and IsValidFriendlyTarget("raid"..i, "Regrowth") then
                
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
            if HealthPct("party"..i) < MB_druidSwiftmendRegrowthLowRandomPercentage and IsValidFriendlyTarget("party"..i, "Regrowth") then

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

    if ImBusy() then
        return
    end

    if Instance.MC() and (TankTarget("Garr") or TankTarget("Firesworn")) then
        return
    end

    local rejuvTarget = MBID[MB_raidLeader].."targettarget"
    if not IsValidFriendlyTarget(rejuvTarget, "Abolish Poison") then
        return
    end

    if HealthPct(rejuvTarget) > 0.95 then
        return
    end

    if HasBuffNamed("Abolish Poison", rejuvTarget) then
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
	
    GetTarget()

	if not MB_mySpecc then		
		CdMessage("My specc is fucked. Defaulting to Resto.")
		MB_mySpecc = "Resto"
	end

	if MB_mySpecc == "Feral" then
		if Instance.AQ40() then			
			if HasBuffOrDebuff("True Fulfillment", "target", "debuff") then
                TargetByName("The Prophet Skeram")
            end

			AnubisathAlert()
		end

		Druid:TankSingle()
		return
    end

    if UnitName("target") == "Death Talon Wyrmkin" and GetRaidTargetIndex("target") == MB_myCCTarget then
        CastSpellByName("Hibernate(Rank 1)")
        return 
    end

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

    if MB_mySpecc == "Balance" then
        Druid:Balance()
        return
    end
	
    if Instance.Naxx() and UnitFactionGroup("player") == "Alliance" then
        if TankTarget("Venom Stalker") or TankTarget("Necro Stalker") then
            if ImBusy() then
                SpellStopCasting()
            end

            MeleeBuff("Abolish Poison")
            return
        end
    end

    HealerJindoRotation("Wrath")
    DruidHeal()
end

MB_mySingleList["Druid"] = DruidSingle

--[####################################################################################################]--
--[########################################## BALANCE Code! ############################################]--
--[####################################################################################################]--

function Druid:Balance()

    if not IsBoomForm() then
		SelfBuff("Moonkin Form") 
		CancelDruidShapeShift()
	end

    Decurse()

	if not InCombat("target") then
        return
    end

	if InCombat("player") then
		Druid:HealerDebuffs()
		Druid:Innervate()

		TakeManaPotionAndRunes()

        if ManaDown("player") > 600 then
            Druid:Cooldowns()
        end
	end

    if Druid:BossSpecificDPS() then
        return
    end

    if ImBusy() then
        return
    end

	CastSpellOrWand("Starfire") 
end

function Druid:BossSpecificDPS()

	if UnitName("target") == "Emperor Vek\'nilash" then
        return true
    end

	if HasBuffOrDebuff("Magic Reflection", "target", "buff") then

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

	if Instance.AQ40() and TankTarget("Battleguard Sartura") then			
		CoolDownCast("Moonfire", 24)
	
    elseif Instance.ZG() then	

        if HasBuffOrDebuff("Delusions of Jin\'do", "player", "debuff") then
			if UnitName("target") == "Shade of Jin\'do" and not Dead("target") then
				CastSpellOrWand("Wrath") 
				return true
			end
		end

		if (UnitName("target") == "Powerful Healing Ward" or UnitName("target") == "Brain Wash Totem") and not Dead("target") then
			CastSpellOrWand("Wrath") 
			return true
		end

    elseif Instance.AQ20() and TankTarget("Ossirian the Unscarred") then

        if HasBuffOrDebuff("Nature Weakness", "target", "debuff") then        
            CastSpellOrWand("Wrath")
            return true
        end
	end

	return false
end

--[####################################################################################################]--
--[######################################## Single Tank Code! #########################################]--
--[####################################################################################################]--

local function DruidTankSingleRotation()
    if not HasBuffOrDebuff("Faerie Fire (Feral)", "target", "debuff") 
        and not HasBuffOrDebuff("Faerie Fire", "target", "debuff") then
        CastSpellByName("Faerie Fire (Feral)()")
    end

    if SpellReady("Enrage") and UnitMana("player") <= 15 then        
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

	if FindInTable(MB_raidTanks, myName) and HasBuffOrDebuff("Greater Blessing of Salvation", "player", "buff") then		
		CancelBuff("Greater Blessing of Salvation") 
	end

	if not IsBearForm() then
		SelfBuff("Dire Bear Form") 
		CancelDruidShapeShift()
        return
	end

    if not InCombat("target") then
        return
    end

	if InCombat("player") then
		if HealthPct("player") < 0.3 and SpellReady("Frenzied Regeneration") then			
			CastSpellByName("Frenzied Regeneration") 
		end

		if InMeleeRange() then
			if DebuffSunderAmount() == 5 or HasBuffOrDebuff("Expose Armor", "target", "debuff") then
				Druid:Cooldowns()
			end

			if SpellReady("Bash") and StunnableMob() then				
				CastSpellByName("Bash")
			end

			if not HasBuffOrDebuff("Demoralizing Shout", "target", "debuff") then 
                if UnitName("target") ~= "Emperor Vek\'nilash" or UnitName("target") ~= "Emperor Vek\'lor" then				
                    if not HasBuffOrDebuff("Demoralizing Roar", "target", "debuff") and UnitMana("player") >= 20 then					
                        CastSpellByName("Demoralizing Roar")
                    end
                end
			end
		end
	end

	OffTank()

    local tOfTarget = UnitName("targettarget") or ""
    local tName = UnitName("target") or ""

    local shouldTaunt = tName ~= "" 
        and tOfTarget ~= "" and tOfTarget ~= "Unknown" 
        and UnitIsEnemy("player", "target") 
        and not FindInTable(MB_raidTanks, tOfTarget)

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

	AutoAttack()
    DruidTankSingleRotation()
end

--[####################################################################################################]--
--[########################################## Multi Code! #############################################]--
--[####################################################################################################]--

local function DruidMulti()
	
    GetTarget()

	if not MB_mySpecc then		
		CdMessage("My specc is fucked. Defaulting to Resto.")
		MB_mySpecc = "Resto"
	end

	if MB_mySpecc == "Feral" then
		if Instance.AQ40() then			
			if HasBuffOrDebuff("True Fulfillment", "target", "debuff") then
                TargetByName("The Prophet Skeram")
            end

			AnubisathAlert()
		end

		Druid:TankMulti()
		return
    end

    if UnitName("target") == "Death Talon Wyrmkin" and GetRaidTargetIndex("target") == MB_myCCTarget then
        CastSpellByName("Hibernate(Rank 1)")
        return 
    end

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
		
    if MB_mySpecc == "Balance" then
        Druid:Balance()
        return
    end

    if Instance.Naxx() and UnitFactionGroup("player") == "Alliance" then
        if TankTarget("Venom Stalker") or TankTarget("Necro Stalker") then
            if ImBusy() then
                SpellStopCasting()
            end

            MeleeBuff("Abolish Poison")
            return
        end
    end

    HealerJindoRotation("Wrath")
    DruidHeal()	
end

MB_myMultiList["Druid"] = DruidMulti

--[####################################################################################################]--
--[######################################### Multi Tank Code! #########################################]--
--[####################################################################################################]--

function Druid:TankMulti()

	if FindInTable(MB_raidTanks, myName) and HasBuffOrDebuff("Greater Blessing of Salvation", "player", "buff") then		
		CancelBuff("Greater Blessing of Salvation") 
	end

	if not IsBearForm() then
		SelfBuff("Dire Bear Form") 
		CancelDruidShapeShift()
        return
	end

    if not InCombat("target") then
        return
    end

	if InCombat("player") then
		if HealthPct("player") < 0.3 and SpellReady("Frenzied Regeneration") then			
			CastSpellByName("Frenzied Regeneration") 
		end

		if InMeleeRange() then
			if DebuffSunderAmount() == 5 or HasBuffOrDebuff("Expose Armor", "target", "debuff") then
				Druid:Cooldowns()
			end

			if SpellReady("Bash") and StunnableMob() then				
				CastSpellByName("Bash")
			end

			if not HasBuffOrDebuff("Demoralizing Shout", "target", "debuff") then 
                if UnitName("target") ~= "Emperor Vek\'nilash" or UnitName("target") ~= "Emperor Vek\'lor" then				
                    if not HasBuffOrDebuff("Demoralizing Roar", "target", "debuff") and UnitMana("player") >= 20 then					
                        CastSpellByName("Demoralizing Roar")
                    end
                end
			end
		end
	end

	OffTank()

    local tOfTarget = UnitName("targettarget") or ""
    local tName = UnitName("target") or ""

    local shouldTaunt = tName ~= "" 
        and tOfTarget ~= "" and tOfTarget ~= "Unknown" 
        and UnitIsEnemy("player", "target") 
        and not FindInTable(MB_raidTanks, tOfTarget)

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

	AutoAttack()

    if not HasBuffOrDebuff("Faerie Fire (Feral)", "target", "debuff") 
        and not HasBuffOrDebuff("Faerie Fire", "target", "debuff") then
        CastSpellByName("Faerie Fire (Feral)()")
    end

    if SpellReady("Enrage") and UnitMana("player") <= 15 then        
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

	if TankTarget("Maexxna") and MB_myMaexxnaBoxStrategy and ImHealer() then		
        if MB_myAssignedHealTarget then
            if IsAlive(MBID[MB_myAssignedHealTarget]) then			
                Druid:MTHeals(MB_myAssignedHealTarget)
                return
            else
                MB_myAssignedHealTarget = nil
                RunLine("/raid My healtarget died, time to ALT-F4.")
            end
        end

		if MyNameInTable(MB_myMaexxnaDruidHealer) then
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

	if IsDruidShapeShifted() and not InCombat("player") then		
		CancelDruidShapeShift()
	end
	
	if UnitMana("player") < 3060 and HasBuffNamed("Drink", "player") then
		return
	end

    if not MB_autoBuff.Active then
        MB_autoBuff.Active = true
        MB_autoBuff.Time = GetTime() + 0.25
        DruidCounter.Cycle()
    end

	SelfBuff("Omen of Clarity")

	if MyClassAlphabeticalOrder() == MB_buffingCounterDruid then				
		MultiBuff("Gift of the Wild")
	end

	if MB_raidAssist.Druid.BuffTanksWithThorns then		
		TankBuff("Thorns")
	end

	if not InCombat("player") and ManaPct("player") < 0.20 and not HasBuffNamed("Drink", "player") then
		SmartDrink()
	end
end

MB_mySetupList["Druid"] = DruidSetup

--[####################################################################################################]--
--[######################################### PRECAST Code! ############################################]--
--[####################################################################################################]--

local function DruidPreCast()
    if MB_mySpecc == "Feral" then
        SelfBuff("Dire Bear Form")
        CancelDruidShapeShift()
        return
    end
    
	for k, trinket in pairs(MB_casterTrinkets) do
		if ItemNameOfEquippedSlot(13) == trinket and not TrinketOnCD(13) then 
			use(13) 
		end

		if ItemNameOfEquippedSlot(14) == trinket and not TrinketOnCD(14) then 
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
        if not Dead(MBID[druidName]) then
            return druidName
        end
    end
    return nil
end

function Druid:Cooldowns()
	if ImBusy() or not InCombat("player") then
		return
	end

    if MB_mySpecc == "Feral" then        
        MeleeTrinkets()
        return
    end

    HealerTrinkets()
    CasterTrinkets()    
end

function Druid:Taunt()
    if Instance.MC() and TankTarget("Magmadar") then
        return
    end

	if SpellReady("Growl") then		
		CastSpellByName("Growl")
		return
	end

	if UnitName("target") and InCombat("target") then
		if SpellReady("Faerie Fire (Feral)()") then			
			CastSpellByName("Faerie Fire (Feral)()")
		end
	end
end

--[####################################################################################################]--
--[######################################### LOATHEB Code! ############################################]--
--[####################################################################################################]--

local function DruidLoathebHeal()

	if LoathebHealing() then
		return
	end
	
	if InCombat("player") then
		Druid:HealerDebuffs()
		Druid:Innervate()

		TakeManaPotionAndRunes()

        if ManaDown("player") > 600 then
            Druid:Cooldowns()
        end
	end

	CoolDownCast("Starfire", 8)
end

MB_myLoathebList["Druid"] = DruidLoathebHeal
