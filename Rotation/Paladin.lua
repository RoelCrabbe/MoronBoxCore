--[####################################################################################################]--
--[####################################### START PALADIN CODE! ########################################]--
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
if myClass ~= "Paladin" then return end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local AssistFocus = mb_assistFocus
local AutoAttack = mb_autoAttack
local BossNeverInterruptHeal = mb_bossNeverInterruptHeal
local CasterTrinkets = mb_casterTrinkets
local CdMessage = mb_cdMessage
local Dead = mb_dead
local Decurse = mb_decurse
local GetTarget = mb_getTarget
local HasBuffNamed = mb_hasBuffNamed
local HasBuffOrDebuff = mb_hasBuffOrDebuff
local HaveInBags = mb_haveInBags
local HealerTrinkets = mb_healerTrinkets
local HealLieutenantAQ20 = mb_healLieutenantAQ20
local HealthDown = mb_healthDown
local HealthPct = mb_healthPct
local ImBusy = mb_imBusy
local InCombat = mb_inCombat
local InstructorRazAddsHeal = mb_instructorRazAddsHeal
local IsAlive = mb_isAlive
local IsFireBoss = mb_isFireBoss
local IsValidFriendlyTarget = mb_isValidFriendlyTarget
local IsValidMeleeTarget = mb_isValidMeleeTarget
local LoathebHealing = mb_loathebHealing
local ManaDown = mb_manaDown
local ManaPct = mb_manaPct
local MultiBuffBlessing = mb_multiBuffBlessing
local MyClassAlphabeticalOrder = mb_myClassAlphabeticalOrder
local MyClassOrder = mb_myClassOrder
local MyGroupClassOrder = mb_myGroupClassOrder
local NumberOfClassInParty = mb_numberOfClassInParty
local PaladinHeal = mb_paladinHeal
local RaidIsPoisoned = mb_raidIsPoisoned
local SelfBuff = mb_selfBuff
local SmartDrink = mb_smartDrink
local SpellReady = mb_spellReady
local StunnableMob = mb_stunnableMob
local TakeManaPotionAndRune = mb_takeManaPotionAndRune
local TakeManaPotionIfBelowManaPotMana = mb_takeManaPotionIfBelowManaPotMana
local TakeManaPotionIfBelowManaPotManaInRazorgoreRoom = mb_takeManaPotionIfBelowManaPotManaInRazorgoreRoom
local TankName = mb_tankName
local TankTarget = mb_tankTarget
local TargetMyAssignedTankToHeal = mb_targetMyAssignedTankToHeal

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local Paladin = CreateFrame("Frame", "Paladin")

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

    Decurse()

	if InCombat("player") then	
		MB_mySetupList["Paladin"]()

		if HealthPct("player") < 0.2 then			
			SelfBuff("Divine Shield")
			return 
		end

		TakeManaPotionAndRune()
		TakeManaPotionIfBelowManaPotMana()
		TakeManaPotionIfBelowManaPotManaInRazorgoreRoom()

		if ManaDown("player") > 600 then
            Paladin:Cooldowns()
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
			Paladin:MTHeals(MB_myAssignedHealTarget)
			return
		else
			MB_myAssignedHealTarget = nil
			RunLine("/raid My healtarget died, time to ALT-F4.")
		end
	end

	for k, BossName in pairs(MB_myPaladinMainTankHealingBossList) do		
		if TankTarget(BossName) then			
			Paladin:MTHeals()
			return
		end
	end

    if Instance.BWL and TankTarget("Vaelastrasz the Corrupt") and MB_myVaelastraszBoxStrategy then
        if HasBuffOrDebuff("Burning Adrenaline", "player", "debuff") then	
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

	if HasBuffOrDebuff("Blinding Light", "player", "buff") or HasBuffOrDebuff("Divine Favor", "player", "buff") then		
		MBH_CastHeal("Holy Light")
		return
    end

	MBH_CastHeal("Flash of Light", 5, 6)
end

local FlashOfLight = { Time = 0, Interrupt = false }
function Paladin:MTHeals(assignedTarget)
	
	if assignedTarget then		
		TargetByName(assignedTarget, 1)
	else
		if TankTarget("Patchwerk") and MB_myPatchwerkBoxStrategy then			
			TargetMyAssignedTankToHeal()
		else
			if not UnitName(MBID[TankName()].."targettarget") then 				
				MBH_CastHeal("Flash of Light", 5, 6)
			else
				TargetByName(UnitName(MBID[TankName()].."targettarget"), 1) 
			end
		end
	end

	if InCombat("player") and ManaPct("player") < 0.95 then		
		SelfBuff("Divine Favor")
	end

	local FlashOfLightSpell = "Flash of Light("..MB_myPaladinMainTankHealingRank.."\)"
	if TankTarget("Vaelastrasz the Corrupt") then
		FlashOfLightSpell = "Holy Light"

	elseif TankTarget("Ossirian the Unscarred") then		
		FlashOfLightSpell = "Holy Light(rank 5)"
	end

    if not BossNeverInterruptHeal() and HealthDown("target") <= (GetHealValueFromRank("Flash of Light", MB_myPaladinMainTankHealingRank) * MB_myMainTankOverhealingPercentage) then
		if GetTime() > FlashOfLight.Time and GetTime() < FlashOfLight.Time + 0.5 and FlashOfLight.Interrupt then
			SpellStopCasting()			
			FlashOfLight.Interrupt = false
			SpellStopCasting()
		end
	end

	if not ImBusy() then
		CastSpellByName(FlashOfLightSpell)
		FlashOfLight.Time = GetTime() + 0.25
		FlashOfLight.Interrupt = true
	end
end

function Paladin:ShockLowAggroedPlayer()
	if not MB_raidAssist.Paladin.HolyShockLowHealthAggroedPlayers
		or not UnitInRaid("player")
		or not InCombat("player")
		or not SpellReady("Holy Shock") then
		return false
	end

	local blastHSatThisPercentage = 0.2
	local classOrder = MyClassOrder()

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
			if IsValidFriendlyTarget(holyShockTarget, "Holy Shock")
				and HealthPct(holyShockTarget) <= blastHSatThisPercentage
				and not HasBuffNamed("Holy Shock", holyShockTarget) then

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
	if TankTarget("Gluth") or TankTarget("Zombie Chow")
		or not UnitInRaid("player")
		or not InCombat("player")
		or ImBusy()
		or not SpellReady("Blessing of Protection") then
		return false
	end

	local blastNSatThisPercentage = 0.3
	local classOrder = MyClassOrder()

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
			and IsValidFriendlyTarget(BOPTarget, "Blessing of Protection")
			and HealthPct(BOPTarget) <= blastNSatThisPercentage
			and not HasBuffOrDebuff("Forbearance", BOPTarget, "debuff") then

			if UnitIsFriend("player", BOPTarget) then
				ClearTarget()
			end

			CastSpellByName("Blessing of Protection", false)
			CdMessage("I BOP'd "..GetColors(UnitName(BOPTarget)).." at "..string.sub(HealthPct(BOPTarget), 3, 4).."% - "..UnitHealth(BOPTarget).."/"..UnitHealthMax(BOPTarget).." HP.")
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
	
	GetTarget()

    if Instance.NAXX and RaidIsPoisoned() and ImBusy() then
		if TankTarget("Venom Stalker") or TankTarget("Necro Stalker") then
			SpellStopCasting()
		end
    end

	Decurse()

	if StunnableMob() then
        if not MB_autoBuff.Active then
            MB_autoBuff.Active = true
            MB_autoBuff.Time = GetTime() + 1
            PriestCounter.Cycle()
        end

		if MyClassAlphabeticalOrder() == MB_buffingCounterPaladin then
			if SpellReady("Hammer of Justice") then
                AssistFocus()		
				CastSpellByName("Hammer of Justice")
			end		
		end
	end

	PaladinHeal()
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

    if UnitMana("player") < 3060 and HasBuffNamed("Drink", "player") then
		return
	end

    if not MB_autoBuff.Active then
        MB_autoBuff.Active = true
        MB_autoBuff.Time = GetTime() + 1
        PriestCounter.Cycle()
    end

	if MyClassAlphabeticalOrder() == MB_buffingCounterPaladin then
		Paladin:BlessMyAssignedBlessing()
	end

	Paladin:ChooseAura()

	if not InCombat("player") and ManaPct("player") < 0.20 and not HasBuffNamed("Drink", "player") then
		SmartDrink()
	end
end

MB_mySetupList["Paladin"] = PaladinSetup

--[####################################################################################################]--
--[########################################## Helper Code! ############################################]--
--[####################################################################################################]--

function Paladin:GetActiveVaelastraszPaladin()
    for _, paladinName in ipairs(MB_myVaelastraszPaladins) do
        if not Dead(MBID[paladinName]) then
            return paladinName
        end
    end
    return nil
end

function Paladin:Cooldowns()
	if ImBusy() or not InCombat("player") then
		return
	end

    if not TankTarget("Viscidus") then
        if ManaPct("player") <= MB_paladinDivineFavorPercentage then			
            SelfBuff("Divine Favor")
        end
    end

	CasterTrinkets()
	HealerTrinkets()
end

function Paladin:ChooseAura()
	if TankTarget("Sapphiron") or TankTarget("Azuregos") then
		SelfBuff("Frost Resistance Aura")
		return
	end

	if MyGroupClassOrder() == 1 then
		if IsFireBoss() then
			SelfBuff("Fire Resistance Aura")
			return
		end

		if MB_druidTankInParty or MB_warriorTankInParty
			or NumberOfClassInParty("Warrior") > 0
			or NumberOfClassInParty("Rogue") > 0 then
			SelfBuff("Devotion Aura")
			return
		end

		SelfBuff("Concentration Aura")
		return
	end

	if MyGroupClassOrder() == 2 then
		SelfBuff("Concentration Aura")
		return
	end

	if MyGroupClassOrder() == 3 then
		SelfBuff("Retribution Aura")
		return
	end
end

function Paladin:BlessMyAssignedBlessing()
	if TankTarget("Garr") or TankTarget("Firesworn") or TankTarget("Maexxna") then
		return
	end

	if not HaveInBags("Symbol of Kings") then
		CdMessage("Out of Symbol of Kings")
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

	local assignedBlessing = blessings[MyClassAlphabeticalOrder()]
	if assignedBlessing then
		MultiBuffBlessing(assignedBlessing)
	end
end

function Paladin:SealLight()
	if not IsValidMeleeTarget("target") then
		return
	end

	AssistFocus()

	if HasBuffOrDebuff("Judgement of Light", "target", "debuff") then
		return
	end

	AutoAttack()

	if not HasBuffOrDebuff("Seal of Light", "player", "buff") then
		CastSpellByName("Seal of Light")
		return
	end

	CastSpellByName("Judgement")
end

function Paladin:SealWisdom()
	if not IsValidMeleeTarget("target") then
		return
	end

	AssistFocus()

	if HasBuffOrDebuff("Judgement of Light", "target", "debuff") then
		return
	end

	AutoAttack()

	if not HasBuffOrDebuff("Seal of Wisdom", "player", "buff") then
		CastSpellByName("Seal of Wisdom")
		return
	end

	CastSpellByName("Judgement")
end

--[####################################################################################################]--
--[######################################### LOATHEB Code! ############################################]--
--[####################################################################################################]--

local function PriestLoathebHeal()

	if LoathebHealing() then
		return
	end

    AssistByName(MB_myLoathebMainTank)
	
	if InCombat("player") then	
		MB_mySetupList["Paladin"]()

		if HealthPct("player") < 0.2 then			
			SelfBuff("Divine Shield")
			return 
		end

		TakeManaPotionAndRune()
		TakeManaPotionIfBelowManaPotMana()
		TakeManaPotionIfBelowManaPotManaInRazorgoreRoom()

		if ManaDown("player") > 600 then
            Paladin:Cooldowns()
        end
	end

    AutoAttack()

    if myName == MB_myLoathebSealPaladin and not HasBuffOrDebuff("Seal of Light", "target", "debuff") then
		Paladin:SealLight()
		return
	end

    if not HasBuffOrDebuff("Seal of Righteousness", "player", "buff") then
		CastSpellByName("Seal of Righteousness")
	end
end

MB_myLoathebList["Paladin"] = PriestLoathebHeal
