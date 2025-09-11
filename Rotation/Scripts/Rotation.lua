--[####################################################################################################]--
--[###################################### START ROTATIONS CODE! #######################################]--
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

local AssistFocus = mb_assistFocus
local AutoAssignBanishOnMoam = mb_autoAssignBanishOnMoam
local CdMessage = mb_cdMessage
local CdPrint = mb_cdPrint
local CrowdControl = mb_crowdControl
local CrowdControlledMob = mb_crowdControlledMob
local CrowdControlMCedRaidMemberHakkar = mb_crowdControlMCedRaidMemberHakkar
local CrowdControlMCedRaidMemberNefarian = mb_crowdControlMCedRaidMemberNefarian
local CrowdControlMCedRaidMemberSkeram = mb_crowdControlMCedRaidMemberSkeram
local CrowdControlMCedRaidMemberSkeramAOE = mb_crowdControlMCedRaidMemberSkeramAOE
local CrowdControlMCedRaidMemberSkeramFear = mb_crowdControlMCedRaidMemberSkeramFear
local Dead = mb_dead
local Decurse = mb_decurse
local DoFaerlinaActions = mb_doFaerlinaActions
local DoRazuviousActions = mb_doRazuviousActions
local ExecuteRotation = mb_executeRotation
local FreezingTrap = mb_freezingTrap
local GetAllContainerFreeSlots = mb_getAllContainerFreeSlots
local GetMCActions = mb_getMCActions
local GetTarget = mb_getTarget
local GTFO = mb_GTFO
local HasBuffNamed = mb_hasBuffNamed
local HasBuffOrDebuff = mb_hasBuffOrDebuff
local HealAndTank = mb_healAndTank
local ImBusy = mb_imBusy
local ImRangedDPS = mb_imRangedDPS
local ImHealer = mb_imHealer
local ImMeleeDPS = mb_imMeleeDPS
local ImTank = mb_imTank
local InCombat = mb_inCombat
local InMeleeRange = mb_inMeleeRange
local IsAtLoatheb = mb_isAtLoatheb
local IsAtNefarianPhase = mb_isAtNefarianPhase
local IsAtRazorgore = mb_isAtRazorgore
local IsAtSkeram = mb_isAtSkeram
local IsAtTwinsEmps = mb_isAtTwinsEmps
local IsDruidShapeShifted = mb_isDruidShapeShifted
local ItemNameOfEquippedSlot = mb_itemNameOfEquippedSlot
local LoathebRotation = mb_loathebRotation
local MandokirGaze = mb_mandokirGaze
local MobsToDetectMagic = mb_mobsToDetectMagic
local MyClassAlphabeticalOrder = mb_myClassAlphabeticalOrder
local MyNameInTable = mb_myNameInTable
local NumShards = mb_numShards
local OrbControlling = mb_orbControlling
local ReEquipAtieshIfNoAtieshBuff = mb_reEquipAtieshIfNoAtieshBuff
local ReturnPlayerInRaidFromTable = mb_returnPlayerInRaidFromTable
local SpellReady = mb_spellReady
local StunnableMob = mb_stunnableMob
local TakeFAP = mb_takeFAP
local TakeLIP = mb_takeLIP
local TankTarget = mb_tankTarget
local UseTranquilizingShot = mb_useTranquilizingShot
local UseSpeedRunPots = mb_useSpeedRunPots

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local PriestCounter = {
    Cycle = function()
        MB_buffingCounterPriest = (MB_buffingCounterPriest >= TableLength(MB_classList["Priest"]))
                                  and 1 or (MB_buffingCounterPriest + 1)
    end
}

local MageCounter = {
    Cycle = function()
        MB_buffingCounterMage = (MB_buffingCounterMage >= TableLength(MB_classList["Mage"]))
                                  and 1 or (MB_buffingCounterMage + 1)
    end
}

local WarlockCounter = {
    Cycle = function()
        MB_buffingCounterWarlock = (MB_buffingCounterWarlock >= TableLength(MB_classList["Warlock"]))
                                  and 1 or (MB_buffingCounterWarlock + 1)
    end
}

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local function SpecialRotation()
    if Instance.NAXX() and HasBuffNamed("Mind Control", "player") and myClass == "Priest" then
        if (TankTarget("Instructor Razuvious") and MyNameInTable(MB_myRazuviousPriest) and MB_myRazuviousBoxStrategy) or
            (TankTarget("Grand Widow Faerlina") and MyNameInTable(MB_myFaerlinaPriest) and MB_myFaerlinaBoxStrategy) then
            GetMCActions()
            return true
        end
    elseif Instance.BWL() and not TankTarget("Razorgore the Untamed") then
	    if IsAtRazorgore() and myName == ReturnPlayerInRaidFromTable(MB_myRazorgoreORBtank) then
            OrbControlling()
            return true
        end
    elseif Instance.ZG() and TankTarget("Bloodlord Mandokir") then
        if MandokirGaze() then
            return true
        end
    elseif Instance.AQ20() and TankTarget("Moam") then
        AutoAssignBanishOnMoam()
    end

    return false
end

local function CheckWeapon()
    if ImRangedDPS() or ImHealer() then		
		ReEquipAtieshIfNoAtieshBuff()
	end

	if ItemNameOfEquippedSlot(16) == nil then		
		CdMessage("I don\'t have a weapon equipped.", 500)
	end
end

local function CheckWarStomp()
    if not InCombat("player") then
        return
    end

    if not StunnableMob() then
        return
    end

    if not InMeleeRange() then
        return
    end

    if not SpellReady("War Stomp") then
        return
    end

    if IsDruidShapeShifted() then
        return
    end

    CastSpellByName("War Stomp")
end

--[####################################################################################################]--
--[########################################## Single Code! ############################################]--
--[####################################################################################################]--

function mb_single()

	if not MB_raidLeader and (TableLength(MBID) > 1) then 
        CdPrint("WARNING: You have not chosen a raid leader")
    end

	if Dead("player") then
        return
    end

	if HasBuffNamed("Mind Control", "player") then
        return
    end

    if SpecialRotation() then
        return
    end

    CheckWeapon()
	TakeLIP()
	TakeFAP()
	GTFO()

    if HasBuffOrDebuff("First Aid", "player", "buff") and HasBuffOrDebuff("Recently Bandaged", "player", "debuff") then
        return
    end

    CheckWarStomp()

    if LoathebRotation() then
        return
    end

    local SingleRotation = MB_mySingleList[myClass]
    ExecuteRotation(SingleRotation, "Default SINGLE")
end

--[####################################################################################################]--
--[########################################### Multi Code! ############################################]--
--[####################################################################################################]--

function mb_multi()

	if not MB_raidLeader and (TableLength(MBID) > 1) then 
        CdPrint("WARNING: You have not chosen a raid leader")
    end

	if Dead("player") then
        return
    end

	if HasBuffNamed("Mind Control", "player") then
        return
    end

    if SpecialRotation() then
        return
    end

    CheckWeapon()
	TakeLIP()
	TakeFAP()

	GTFO()

    if HasBuffOrDebuff("First Aid", "player", "buff") and HasBuffOrDebuff("Recently Bandaged", "player", "debuff") then
        return
    end

    CheckWarStomp()

    if LoathebRotation() then
        return
    end

    local MultiRotation = MB_myMultiList[myClass]
    ExecuteRotation(MultiRotation, "Default MULTI")
end

--[####################################################################################################]--
--[############################################ AOE Code! #############################################]--
--[####################################################################################################]--

function mb_AOE()

	if not MB_raidLeader and (TableLength(MBID) > 1) then 
        CdPrint("WARNING: You have not chosen a raid leader")
    end

	if Dead("player") then
        return
    end

	if HasBuffNamed("Mind Control", "player") then
        return
    end

    if SpecialRotation() then
        return
    end

    CheckWeapon()
	TakeLIP()
	TakeFAP()

	GTFO()

    if HasBuffOrDebuff("First Aid", "player", "buff") and HasBuffOrDebuff("Recently Bandaged", "player", "debuff") then
        return
    end

    CheckWarStomp()

    if LoathebRotation() then
        return
    end

    local AOERotation = MB_myAOEList[myClass]
    ExecuteRotation(AOERotation, "Default AOE")
end

--[####################################################################################################]--
--[########################################### Setup Code! ############################################]--
--[####################################################################################################]--

function mb_setup()

	if not MB_raidLeader and (TableLength(MBID) > 1) then 
        CdPrint("WARNING: You have not chosen a raid leader")
    end

	if Dead("player") then
        return
    end

	if HasBuffNamed("Mind Control", "player") then
        return
    end

    if SpecialRotation() then
        return
    end

    CheckWeapon()
	TakeLIP()
	TakeFAP()

	GTFO()

    if HasBuffOrDebuff("First Aid", "player", "buff") and HasBuffOrDebuff("Recently Bandaged", "player", "debuff") then
        return
    end

	if IsControlKeyDown() then		
		MakeALine()
		return
	end

	UseSpeedRunPots()

    if myClass == "Mage" or myClass == "Warlock" then
        if Instance.NAXX() and IsAtLoatheb() and MB_myLoathebBoxStrategy then
            RunLine("/trinket load top UNDEAD")
            RunLine("/trinket load top UNDEAD")
        else
            RunLine("/trinket load top NRML")
            RunLine("/trinket load top NRML")
        end
    end

    if myClass == "Warrior" then
        return
    end

    local SetupRotation = MB_mySetupList[myClass]
    ExecuteRotation(SetupRotation, "Default SETUP")
end

--[####################################################################################################]--
--[########################################## Precast Code! ###########################################]--
--[####################################################################################################]--

function mb_preCast()

	if not MB_raidLeader and (TableLength(MBID) > 1) then 
        CdPrint("WARNING: You have not chosen a raid leader")
    end

	if Dead("player") then
        return
    end

    if not ImRangedDPS() then
        return
    end

	AssistFocus()

	if not UnitName("target") then
        return
    end

    local PreCastRotation = MB_myPreCastList[myClass]
    ExecuteRotation(PreCastRotation, "Default PRECAST")
end

--[####################################################################################################]--
--[########################################## Heal and Tank! ##########################################]--
--[####################################################################################################]--

local function InterruptingHealAndTank()	
	if ImTank() then
        return
    end

    if not SpellReady(MB_myInterruptSpell[myClass]) then
        return
    end

	if not MB_doInterrupt.Active then
        return
    end

    GetMyInterruptTarget()

    if myClass == "Warrior" then		
        if UnitMana("player") >= 10 then					
            CastSpellByName(MB_myInterruptSpell[myClass])
        end

    elseif myClass == "Shaman" then
        if ImBusy() then				
            SpellStopCasting()
        end

        CastSpellByName(MB_myInterruptSpell[myClass].."(Rank 1)")

    elseif myClass == "Rogue" then
        if UnitMana("player") >= 25 then				
            CastSpellByName(MB_myInterruptSpell[myClass])
        end

    elseif myClass == "Mage" then
        if not MB_isCastingMyCCSpell then				
            SpellStopCasting()
        end

        CastSpellByName(MB_myInterruptSpell[myClass])
    end

	MB_doInterrupt.Active = false
end

local function SpecialHealAndTankClass()
	if myClass == "Hunter" then
        if UseTranquilizingShot() and SpellReady("Tranquilizing Shot") then
            CastSpellByName("Tranquilizing Shot")
        end

		if TankTarget("Gluth") then
			FreezingTrap()
		end
    end

	if myClass == "Mage" then
		Decurse()

        if MobsToDetectMagic() and not HasBuffOrDebuff("Detect Magic", "target", "debuff") then		
            if not HasBuffOrDebuff("Detect Magic", "player", "debuff") then
                CastSpellByName("Detect Magic")
                return true
            end
        end
	end
    
    if myClass == "Warlock" and HasBuffOrDebuff("Hellfire", "player", "buff") then
		CastSpellByName("Life Tap(Rank 1)")
		return true		
	end

    return false
end

local function SpecialHealAndTankSituation()
	if Instance.ZG() and myClass == "Mage" and TankTarget("Hakkar") then		
        if HasBuffOrDebuff("Mind Control", "target", "debuff") then
            ClearTarget()
            return true
        end

        if not MB_autoToggleSheeps.Active then
            MB_autoToggleSheeps.Active = true
            MB_autoToggleSheeps.Time = GetTime() + 10
            MageCounter.Cycle()
        end

        if MyClassAlphabeticalOrder() == MB_buffingCounterMage then                
            CrowdControlMCedRaidMemberHakkar()
        end

	elseif Instance.AQ40() then
		if HasBuffOrDebuff("True Fulfillment", "target", "debuff") then
            ClearTarget()
            return true
        end

		if IsAtSkeram() then
			if myClass == "Mage" then
                if not MB_autoToggleSheeps.Active then
                    MB_autoToggleSheeps.Active = true
                    MB_autoToggleSheeps.Time = GetTime() + 2
                    MageCounter.Cycle()
                end

                if MyClassAlphabeticalOrder() == MB_buffingCounterMage then					
                    CrowdControlMCedRaidMemberSkeram()
                end
				
			elseif myClass == "Priest" then
                if not MB_autoToggleSheeps.Active then
                    MB_autoToggleSheeps.Active = true
                    MB_autoToggleSheeps.Time = GetTime() + 3
                    PriestCounter.Cycle()
                end

                if MyClassAlphabeticalOrder() == MB_buffingCounterPriest then
                    CrowdControlMCedRaidMemberSkeramAOE()
                end
				
			elseif myClass == "Warlock" and MB_mySkeramBoxStrategyWarlock then
                if not MB_autoToggleSheeps.Active then
                    MB_autoToggleSheeps.Active = true
                    MB_autoToggleSheeps.Time = GetTime() + 6
                    WarlockCounter.Cycle()
                end

				if MyClassAlphabeticalOrder() == MB_buffingCounterWarlock then
					CrowdControlMCedRaidMemberSkeramFear()
				end	
			end
		
		elseif myClass == "Warlock" and IsAtTwinsEmps() and MB_myTwinsBoxStrategy then
            if MyNameInTable(MB_myTwinsWarlockTank) then
                local SingleRotation = MB_mySingleList[myClass]
                ExecuteRotation(SingleRotation, "Twins Tank SINGLE")
            end
		end

    elseif Instance.BWL() and string.find(GetSubZoneText(), "Nefarian.*Lair") and IsAtNefarianPhase() then
        if HasBuffOrDebuff("Shadow Command", "target", "debuff") then
            ClearTarget()
            return true
        end

		if myClass == "Mage" then
            if not MB_autoToggleSheeps.Active then
                MB_autoToggleSheeps.Active = true
                MB_autoToggleSheeps.Time = GetTime() + 3
                MageCounter.Cycle()
            end

            if MyClassAlphabeticalOrder() == MB_buffingCounterMage then                
                CrowdControlMCedRaidMemberNefarian()
            end
		end

	elseif Instance.NAXX() and myClass == "Priest" then
        if (TankTarget("Instructor Razuvious") and MyNameInTable(MB_myRazuviousPriest) and MB_myRazuviousBoxStrategy) or
            (TankTarget("Grand Widow Faerlina") and MyNameInTable(MB_myFaerlinaPriest) and MB_myFaerlinaBoxStrategy) then
            GetMCActions()
            return true
        end
	end

    return false
end

function mb_healAndTank()

	if not MB_raidLeader and (TableLength(MBID) > 1) then 
        CdPrint("WARNING: You have not chosen a raid leader")
    end

	if Dead("player") then
        return
    end

	GetTarget()

    if HasBuffNamed("Mind Control", "player") then
        return
    end

    if SpecialRotation() then
        return
    end

    CheckWeapon()
	TakeLIP()
	TakeFAP()

	GTFO()

    if HasBuffOrDebuff("First Aid", "player", "buff") and HasBuffOrDebuff("Recently Bandaged", "player", "debuff") then
        return
    end

    CheckWarStomp()
	InterruptingHealAndTank()

    if SpecialHealAndTankClass() then
        return
    end

    if SpecialHealAndTankSituation() then
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

    if LoathebRotation() then
        return
    end

    local SingleRotation = MB_mySingleList[myClass]
    if ImTank() then
        ExecuteRotation(SingleRotation, "Tank&Heal SINGLE")
    elseif ImHealer() then
        if myClass == "Druid" then
            if UnitName("target") == "Death Talon Wyrmkin" and GetRaidTargetIndex("target") == MB_myCCTarget then			
                CastSpellByName("Hibernate(Rank 1)")
                return
            end
        end

        ExecuteRotation(SingleRotation, "Tank&Heal SINGLE")
    end
end

