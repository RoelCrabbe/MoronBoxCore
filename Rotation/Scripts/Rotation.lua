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

local AOE = mb_AOE
local AssistFocus = mb_assistFocus
local AutoAssignBanishOnMoam = mb_autoAssignBanishOnMoam
local CdMessage = mb_cdMessage
local CdPrint = mb_cdPrint
local Dead = mb_dead
local DoFaerlinaActions = mb_doFaerlinaActions
local DoRazuviousActions = mb_doRazuviousActions
local GTFO = mb_GTFO
local HasBuffNamed = mb_hasBuffNamed
local HasBuffOrDebuff = mb_hasBuffOrDebuff
local ImRangedDPS = mb_imRangedDPS
local ImHealer = mb_imHealer
local InCombat = mb_inCombat
local InMeleeRange = mb_inMeleeRange
local IsAtRazorgore = mb_isAtRazorgore
local IsDruidShapeShifted = mb_isDruidShapeShifted
local ItemNameOfEquippedSlot = mb_itemNameOfEquippedSlot
local MakeALine = mb_makeALine
local MandokirGaze = mb_mandokirGaze
local Multi = mb_multi
local MyNameInTable = mb_myNameInTable
local OrbControlling = mb_orbControlling
local PreCast = mb_preCast
local ReEquipAtieshIfNoAtieshBuff = mb_reEquipAtieshIfNoAtieshBuff
local ReturnPlayerInRaidFromTable = mb_returnPlayerInRaidFromTable
local Setup = mb_setup
local Single = mb_single
local SpellReady = mb_spellReady
local StunnableMob = mb_stunnableMob
local TakeFAP = mb_takeFAP
local TakeLIP = mb_takeLIP
local TankTarget = mb_tankTarget
local UseSpeedRunPots = mb_useSpeedRunPots

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local function SpecialRotation()
    if Instance.Naxx() and HasBuffNamed("Mind Control", "player") and myClass == "Priest" then
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

    local SingleRotation = MB_mySingleList[myClass]
    if SingleRotation and type(SingleRotation) == "function" then
        SingleRotation()
    else
        CdMessage("I don\'t know what to do.", 500)
    end
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

    local MultiRotation = MB_myMultiList[myClass]
    if MultiRotation and type(MultiRotation) == "function" then
        MultiRotation()
    else
        CdMessage("I don\'t know what to do.", 500)
    end
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

    local AOERotation = MB_myAOEList[myClass]
    if AOERotation and type(AOERotation) == "function" then
        AOERotation()
    else
        CdMessage("I don\'t know what to do.", 500)
    end
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

    if myClass == "Warrior" then
        return
    end

    local SetupRotation = MB_mySetupList[myClass]
    if SetupRotation and type(SetupRotation) == "function" then
        SetupRotation()
    else
        CdMessage("I don\'t know what to do.", 500)
    end
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
    if PreCastRotation and type(PreCastRotation) == "function" then
        PreCastRotation()
    else
        CdMessage("I don\'t know what to do.", 500)
    end
end
