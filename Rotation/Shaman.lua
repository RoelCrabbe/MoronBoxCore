--[####################################################################################################]--
--[####################################### START SHAMAN CODE! #########################################]--
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
if myClass ~= "Shaman" then return end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local BossNeverInterruptHeal = mb_bossNeverInterruptHeal
local CasterTrinkets = mb_casterTrinkets
local CastSpellOrWand = mb_castSpellOrWand
local CdMessage = mb_cdMessage
local CdPrint = mb_cdPrint
local CoolDownCast = mb_coolDownCast
local Dead = mb_dead
local Decurse = mb_decurse
local DropTotems = mb_dropTotems
local EquippedSetCount = mb_equippedSetCount
local GetMyInterruptTarget = mb_getMyInterruptTarget
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
local InstructorRazAddsHeal = mb_instructorRazAddsHeal
local IsAlive = mb_isAlive
local ManaDown = mb_manaDown
local ManaPct = mb_manaPct
local MeleeDPSInParty = mb_meleeDPSInParty
local MobsToAoeTotem = mb_mobsToAoeTotem
local NatureSwiftnessLowAggroedPlayer = mb_natureSwiftnessLowAggroedPlayer
local NumOfCasterHealerInParty = mb_numOfCasterHealerInParty
local PartyIsDiseased = mb_partyIsDiseased
local PartyIsPoisoned = mb_partyIsPoisoned
local PartyMana = mb_partyMana
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

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local Shaman = CreateFrame("Frame", "Shaman")

--[####################################################################################################]--
--[########################################## SETUP Code! #############################################]--
--[####################################################################################################]--

local function ShamanSpecc()
    local TalentsIn, TalentsInA

    _, _, _, _, TalentsIn = GetTalentInfo(3, 13)
    _, _, _, _, TalentsInA = GetTalentInfo(3, 15)
    if TalentsIn > 0 and TalentsInA > 0 then        
        MB_mySpecc = "Deep Resto"
        return 
    end
    _, _, _, _, TalentsIn = GetTalentInfo(3, 13)
    _, _, _, _, TalentsInA = GetTalentInfo(2, 12)
    if TalentsIn > 0 and TalentsInA > 1 then        
        MB_mySpecc = "Totem Resto"
        return 
    end

    _, _, _, _, TalentsIn = GetTalentInfo(1, 14)
    if TalentsIn > 0 then        
        MB_mySpecc = "Elemental"
        return 
    end

    MB_mySpecc = nil
end

MB_mySpeccList["Shaman"] = ShamanSpecc

--[####################################################################################################]--
--[######################################### HEALING Code! ############################################]--
--[####################################################################################################]--

local function ShamanHeal()
	
	if NatureSwiftnessLowAggroedPlayer() then
        return
    end

    if InCombat("player") then
        if SpellReady("Mana Tide Totem") 
            and not HasBuffOrDebuff("Mana Tide Totem", "player", "buff") then
            
            local _, partyManaDown = PartyMana()
            local avgManaDown = partyManaDown / NumOfCasterHealerInParty()
            local myManaDown = ManaDown()

            if (avgManaDown > 1500 and myManaDown > 1050)
                or (myManaDown > 1500) then
                CastSpellByName("Mana Tide Totem")
                CoolDownCast("Mana Tide Totem", 13)
            end
        end

		TakeManaPotionAndRune()
		TakeManaPotionIfBelowManaPotMana()
		TakeManaPotionIfBelowManaPotManaInRazorgoreRoom()

        if ManaDown("player") > 600 then
            Shaman:Cooldowns()
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
			Shaman:MTHeals(MB_myAssignedHealTarget)
			return
		else
			MB_myAssignedHealTarget = nil
			RunLine("/raid My healtarget died, time to ALT-F4.")
		end
	end

	for k, BossName in pairs(MB_myShamanMainTankHealingBossList) do		
		if TankTarget(BossName) then			
			Shaman:MTHeals()
			return
		end
	end

    if Instance.AQ40 and TankTarget("Princess Huhuran") then
        if TankTargetHealth() <= 0.32 then
            MBH_CastHeal("Chain Heal", 2, 3)
            return
        end

        MBH_CastHeal("Healing Wave", 3, 5) 
        return

    elseif Instance.BWL and TankTarget("Vaelastrasz the Corrupt") and MB_myVaelastraszBoxStrategy then
        if HasBuffOrDebuff("Burning Adrenaline", "player", "debuff") then	
            MBH_CastHeal("Chain Heal", 3, 3)
            return
        end

        Shaman:Cooldowns()

        if MB_myHealSpell == "Healing Wave" then
            if MB_myVaelastraszShamanHealing then
                local activeShaman = Shaman:GetActiveVaelastraszShaman()

                if myName == activeShaman then
                    Shaman:MTHeals()
                    return
                end
            end

            MBH_CastHeal("Lesser Healing Wave", 6, 6)
            return
        end

        MBH_CastHeal("Chain Heal", 3, 3)
        return
    end

	if MB_myHealSpell == "Chain Heal" then		
		MBH_CastHeal("Chain Heal", 1, 1)
        return
	end

    MBH_CastHeal("Healing Wave", 3)
end

local HealWave = { Time = 0, Interrupt = false }
function Shaman:MTHeals(assignedTarget)
	
	if assignedTarget then		
		TargetByName(assignedTarget, 1)
	else
		if TankTarget("Patchwerk") and MB_myPatchwerkBoxStrategy then			
			TargetMyAssignedTankToHeal()
		else
			if not UnitName(MBID[TankName()].."targettarget") then 				
				MBH_CastHeal("Healing Wave", 3)
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
		CastSpellByName("Healing Wave")
		return
	end
	
	local HealWaveSpell = "Healing Wave("..MB_myShamanMainTankHealingRank.."\)"
	if TankTarget("Vaelastrasz the Corrupt") then
		HealWaveSpell = "Healing Wave"
	end

    if not BossNeverInterruptHeal() and HealthDown("target") <= (GetHealValueFromRank("Healing Wave", MB_myShamanMainTankHealingRank) * MB_myMainTankOverhealingPercentage) then
		if GetTime() > HealWave.Time and GetTime() < HealWave.Time + 0.5 and HealWave.Interrupt then
			SpellStopCasting()			
			HealWave.Interrupt = false
			SpellStopCasting()
		end
	end

	if not MB_isCasting then
		CastSpellByName(HealWaveSpell)
		HealWave.Time = GetTime() + 1
		HealWave.Interrupt = true
	end
end

--[####################################################################################################]--
--[########################################## Single Code! ############################################]--
--[####################################################################################################]--

local function ShamanSingle()

	GetTarget()

    if not MB_mySpecc then		
		CdMessage("My specc is fucked. Defaulting to Elemental.")
		MB_mySpecc = "Elemental"
	end

	if PartyIsPoisoned() then		
		if ImBusy() then			
			SpellStopCasting()
			return
		end
		
		CastSpellByName("Poison Cleansing Totem")
		CoolDownCast("Poison Cleansing Totem", 6)
		return
	end	

	if Instance.NAXX and TankTarget("Heigan the Unclean") then		 
		if MeleeDPSInParty() and PartyIsDiseased() then			
			if ImBusy() then			
				SpellStopCasting()
				return
			end

			CastSpellByName("Disease Cleansing Totem")
			CoolDownCast("Disease Cleansing Totem", 6)
			return
		end
	end

	Decurse()

    if MB_doInterrupt.Active and SpellReady(MB_myInterruptSpell[myClass]) then
        if MB_myInterruptTarget then
            GetMyInterruptTarget()
        end

        if ImBusy() then			
            SpellStopCasting() 
        end

        CastSpellByName(MB_myInterruptSpell[myClass].."(Rank 1)")
        CdPrint("Interrupting!")
        MB_doInterrupt.Active = false
        return        
    end

	DropTotems()

    if MB_mySpecc == "Elemental" then
        Shaman:Elemental()
        return
    end

	HealerJindoRotation("Lightning Bolt")
	ShamanHeal()
end

MB_mySingleList["Shaman"] = ShamanSingle

--[####################################################################################################]--
--[########################################## SHADOW Code! ############################################]--
--[####################################################################################################]--

function Shaman:Elemental()

	if not InCombat("target") then
        return
    end

    if InCombat("player") then
		TakeManaPotionAndRune()
		TakeManaPotionIfBelowManaPotMana()
		TakeManaPotionIfBelowManaPotManaInRazorgoreRoom()

        if ManaDown("player") > 600 then
            Shaman:Cooldowns()
        end
	end

    if Shaman:BossSpecificDPS() then
        return
    end

    if ImBusy() then
        return
    end

	if SpellReady("Chain Lightning") then 
		CastSpellOrWand("Chain Lightning") 
	end

	CastSpellOrWand("Lightning Bolt") 
end

function Shaman:BossSpecificDPS()

	if UnitName("target") == "Emperor Vek\'nilash" then
        return true
    end

	if HasBuffOrDebuff("Magic Reflection", "target", "buff") then

		if ImBusy() then
			SpellStopCasting()
		end
		return true

	elseif TankTarget("Azuregos") and HasBuffNamed("Magic Shield", "target") then
		
		if ImBusy() then
			SpellStopCasting()
		end
		return true
	end

	return false
end

--[####################################################################################################]--
--[########################################## Multi Code! #############################################]--
--[####################################################################################################]--

MB_myMultiList["Shaman"] = ShamanSingle

--[####################################################################################################]--
--[########################################### AOE Code! ##############################################]--
--[####################################################################################################]--

local function ShamanAOE()

	if MobsToAoeTotem() and SpellReady("Fire Nova Totem") then
		CastSpellByName("Fire Nova Totem")
		return
	end

	ShamanSingle()
end

MB_myAOEList["Shaman"] = ShamanAOE

--[####################################################################################################]--
--[########################################## SETUP Code! #############################################]--
--[####################################################################################################]--

local function ShamanSetup()

    if UnitMana("player") < 3060 and HasBuffNamed("Drink", "player") then
		return
	end

	if EquippedSetCount("The Earthshatter") >= 8 then
		SelfBuff("Lightning Shield")
	end
	
	if ImHealer() then
		MBH_CastHeal("Chain Heal", 1, 1)
	end

    if not InCombat("player") and ManaPct("player") < 0.20 and not HasBuffNamed("Drink", "player") then
		SmartDrink()
	end
end

MB_mySetupList["Shaman"] = ShamanSetup

--[####################################################################################################]--
--[######################################### PRECAST Code! ############################################]--
--[####################################################################################################]--

local function ShamanPreCast()
    DropTotems()
end

MB_myPreCastList["Shaman"] = ShamanPreCast

--[####################################################################################################]--
--[########################################## Helper Code! ############################################]--
--[####################################################################################################]--

function Shaman:GetActiveVaelastraszShaman()
    for _, shamanName in ipairs(MB_myVaelastraszShamans) do
        if not Dead(MBID[shamanName]) then
            return shamanName
        end
    end
    return nil
end

function Shaman:Cooldowns()
	if ImBusy() or not InCombat("player") then
		return
	end

    SelfBuff("Berserking")
    SelfBuff("Elemental Mastery")

    if EquippedSetCount("The Earthshatter") >= 8 then
        SelfBuff("Lightning Shield")
    end

    HealerTrinkets()
    CasterTrinkets()
end
