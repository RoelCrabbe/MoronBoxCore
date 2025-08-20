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

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local Shaman = CreateFrame("Frame", "Shaman")
if myClass ~= "Shaman" then
    return
end

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
	
	if mb_natureSwiftnessLowAggroedPlayer() then
        return
    end

    if mb_inCombat("player") then
        if mb_spellReady("Mana Tide Totem") 
            and not mb_hasBuffOrDebuff("Mana Tide Totem", "player", "buff") then
            
            local _, partyManaDown = mb_partyMana()
            local avgManaDown = partyManaDown / mb_numOfCasterHealerInParty()
            local myManaDown = mb_manaDown()

            if (avgManaDown > 1500 and myManaDown > 1050)
                or (myManaDown > 1500) then
                CastSpellByName("Mana Tide Totem")
                mb_coolDownCast("Mana Tide Totem", 13)
            end
        end

		mb_takeManaPotionAndRune()
		mb_takeManaPotionIfBelowManaPotMana()
		mb_takeManaPotionIfBelowManaPotManaInRazorgoreRoom()

        if mb_manaDown("player") > 600 then
            Shaman:Cooldowns()
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
			Shaman:MTHeals(MB_myAssignedHealTarget)
			return
		else
			MB_myAssignedHealTarget = nil
			RunLine("/raid My healtarget died, time to ALT-F4.")
		end
	end

	for k, BossName in pairs(MB_myShamanMainTankHealingBossList) do		
		if mb_tankTarget(BossName) then			
			Shaman:MTHeals()
			return
		end
	end

    if Instance.AQ40 and mb_tankTarget("Princess Huhuran") then
        if mb_tankTargetHealth() <= 0.32 then
            MBH_CastHeal("Chain Heal", 2, 3)
            return
        end

        MBH_CastHeal("Healing Wave", 3, 5) 
        return

    elseif Instance.BWL and mb_tankTarget("Vaelastrasz the Corrupt") and MB_myVaelastraszBoxStrategy then
        if mb_hasBuffOrDebuff("Burning Adrenaline", "player", "debuff") then	
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
		if mb_tankTarget("Patchwerk") and MB_myPatchwerkBoxStrategy then			
			mb_targetMyAssignedTankToHeal()
		else
			if not UnitName(MBID[mb_tankName()].."targettarget") then 				
				MBH_CastHeal("Healing Wave", 3)
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
	
	local HealWaveSpell = "Healing Wave("..MB_myShamanMainTankHealingRank.."\)"
	if mb_tankTarget("Vaelastrasz the Corrupt") then
		HealWaveSpell = "Healing Wave"
	end

    if not mb_bossNeverInterruptHeal() and mb_healthDown("target") <= (GetHealValueFromRank("Healing Wave", MB_myShamanMainTankHealingRank) * MB_myMainTankOverhealingPercentage) then
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

	mb_getTarget()

    if not MB_mySpecc then		
		mb_cdMessage("My specc is fucked. Defaulting to Elemental.")
		MB_mySpecc = "Elemental"
	end

	if mb_partyIsPoisoned() then		
		if mb_imBusy() then			
			SpellStopCasting()
			return
		end
		
		CastSpellByName("Poison Cleansing Totem")
		mb_coolDownCast("Poison Cleansing Totem", 6)
		return
	end	

	if Instance.NAXX and mb_tankTarget("Heigan the Unclean") then		 
		if mb_meleeDPSInParty() and mb_partyIsDiseased() then			
			if mb_imBusy() then			
				SpellStopCasting()
				return
			end

			CastSpellByName("Disease Cleansing Totem")
			mb_coolDownCast("Disease Cleansing Totem", 6)
			return
		end
	end

	mb_decurse()

    if MB_doInterrupt.Active and mb_spellReady(MB_myInterruptSpell[myClass]) then
        if MB_myInterruptTarget then
            mb_getMyInterruptTarget()
        end

        if mb_imBusy() then			
            SpellStopCasting() 
        end

        CastSpellByName(MB_myInterruptSpell[myClass].."(Rank 1)")
        mb_cdPrint("Interrupting!")
        MB_doInterrupt.Active = false
        return        
    end

	mb_dropTotems()

    if MB_mySpecc == "Elemental" then
        Shaman:Elemental()
        return
    end

	mb_healerJindoRotation("Lightning Bolt")
	ShamanHeal()
end

MB_mySingleList["Shaman"] = ShamanSingle

--[####################################################################################################]--
--[########################################## SHADOW Code! ############################################]--
--[####################################################################################################]--

function Shaman:Elemental()

	if not mb_inCombat("target") then
        return
    end

    if mb_inCombat("player") then
		mb_takeManaPotionAndRune()
		mb_takeManaPotionIfBelowManaPotMana()
		mb_takeManaPotionIfBelowManaPotManaInRazorgoreRoom()

        if mb_manaDown("player") > 600 then
            Shaman:Cooldowns()
        end
	end

    if Shaman:BossSpecificDPS() then
        return
    end

    if mb_imBusy() then
        return
    end

	if mb_spellReady("Chain Lightning") then 
		mb_castSpellOrWand("Chain Lightning") 
	end

	mb_castSpellOrWand("Lightning Bolt") 
end

function Shaman:BossSpecificDPS()

	if UnitName("target") == "Emperor Vek\'nilash" then
        return true
    end

	if mb_hasBuffOrDebuff("Magic Reflection", "target", "buff") then

		if mb_imBusy() then
			SpellStopCasting()
		end
		return true

	elseif mb_tankTarget("Azuregos") and mb_hasBuffNamed("Magic Shield", "target") then
		
		if mb_imBusy() then
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

	if mb_mobsToAoeTotem() and mb_spellReady("Fire Nova Totem") then
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

    if UnitMana("player") < 3060 and mb_hasBuffNamed("Drink", "player") then
		return
	end

	if mb_equippedSetCount("The Earthshatter") >= 8 then
		mb_selfBuff("Lightning Shield")
	end
	
	if mb_imHealer() then
		MBH_CastHeal("Chain Heal", 1, 1)
	end

    if not mb_inCombat("player") and mb_manaPct("player") < 0.20 and not mb_hasBuffNamed("Drink", "player") then
		mb_smartDrink()
	end
end

MB_mySetupList["Shaman"] = ShamanSetup

--[####################################################################################################]--
--[######################################### PRECAST Code! ############################################]--
--[####################################################################################################]--

local function ShamanPreCast()
    mb_dropTotems()
end

MB_myPreCastList["Shaman"] = ShamanPreCast

--[####################################################################################################]--
--[########################################## Helper Code! ############################################]--
--[####################################################################################################]--

function Shaman:GetActiveVaelastraszShaman()
    for _, shamanName in ipairs(MB_myVaelastraszShamans) do
        if not mb_dead(MBID[shamanName]) then
            return shamanName
        end
    end
    return nil
end

function Shaman:Cooldowns()
	if mb_imBusy() or not mb_inCombat("player") then
		return
	end

    mb_selfBuff("Berserking")
    mb_selfBuff("Elemental Mastery")

    if mb_equippedSetCount("The Earthshatter") >= 8 then
        mb_selfBuff("Lightning Shield")
    end

    mb_healerTrinkets()
    mb_casterTrinkets()
end