--[####################################################################################################]--
--[############################################ SKERAM CODE ###########################################]--
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
local AssistSpecificTargetFromPlayer = mb_assistSpecificTargetFromPlayer
local CdAddonMessage = mb_cdAddonMessage
local CdMessage = mb_cdMessage
local CdPrint = mb_cdPrint
local CdRaidWarning = mb_cdRaidWarning
local Dead = mb_dead
local GetTargetNotOnTank = mb_getTargetNotOnTank
local HasBuffOrDebuff = mb_hasBuffOrDebuff
local HaveInBags = mb_haveInBags
local HealthPct = mb_healthPct
local ImBusy = mb_imBusy
local ImFocus = mb_imFocus
local ImHealer = mb_imHealer
local ImMeleeDPS = mb_imMeleeDPS
local ImRangedDPS = mb_imRangedDPS
local ImTank = mb_imTank
local InCombat = mb_inCombat
local InMeleeRange = mb_inMeleeRange
local IsAlive = mb_isAlive
local IsDruidShapeShifted = mb_isDruidShapeShifted
local IsItemInBagCoolDown = mb_isItemInBagCoolDown
local In28yardRange = mb_in28yardRange
local LockOnTarget = mb_lockOnTarget
local MyNameInTable = mb_myNameInTable
local MyClassAlphabeticalOrder = mb_myClassAlphabeticalOrder
local ReturnPlayerInRaidFromTable = mb_returnPlayerInRaidFromTable
local SpellReady = mb_spellReady
local TakePotionsWhenPossible = mb_takePotionsWhenPossible
local TankTarget = mb_tankTarget
local TankTargetHealth = mb_tankTargetHealth
local TargetFromSpecificPlayer = mb_targetFromSpecificPlayer
local UnitInRange = mb_unitInRange
local UseFromBags = mb_useFromBags

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local SKERAM = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0")

function SKERAM:OnInitialize()
    self:RegisterEvent("CHAT_MSG_ADDON")
    self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

-- Strategy Configuration
local MB_mySkeramBoxStrategy = true
local MB_mySkeramArcanePotStrategy = true

-- Platform Assignments
local MB_mySkeramLeftTanks = {
    "Suecia",           -- Horde
    "Laty"              -- Alliance
}

local MB_mySkeramLeftOFFTANKS = {
    "Rows",             -- Horde
    "Subsmash" -- Alliance
}

local MB_mySkeramMiddleTanks = {
    "Moron",            -- Horde
    "Sceto"             -- Alliance
}

local MB_mySkeramMiddleOFFTANKS = {
    "Almisael",         -- Horde
    "Droodood"          -- Alliance
}

local MB_mySkeramMiddleDPSERS = {
    -- Horde DPS
    "Moonspawn", "Likez", "Angerissues", "Tazmahdingo", 
    "Gogopwranger", "Chabalala", "Weedzy", "Miagi",
    -- Alliance DPS
    "Kazic", "Kankan", "Nharz", "Hotani", 
    "Shieceofpit", "Arent", "Kurayami", "Purplemane"
}

local MB_mySkeramRightTanks = { 
    "Ajlano",           -- Horde
    "Myosin"            -- Alliance
}

local MB_mySkeramRightOFFTANKS = {
    "Sabo",             -- Horde
    "Algoritam" -- Alliance
}

-- Strategy Configuration -- No changes below this line
local SkeramEncounter = {
    Active = false
}

function SKERAM:OnEnable()
    SkeramEncounter.Active = true
end

function SKERAM:OnReset()
    SkeramEncounter.Active = false
end

function SKERAM:OnCleanUp()
    self:OnReset()
    self:UnregisterAllEvents()
    CdPrint(">> SKERAM - CLEANUP <<")
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local function UseArcanePotsOnSkeram()
    if not MB_mySkeramArcanePotStrategy then
        return
    end

    TakePotionsWhenPossible("Greater Arcane Protection Potion")
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function SKERAM_CheckEncounter()
    if SkeramEncounter.Active then
        if SpellReady("Intimidating Shout") then
            CastSpellByName("Intimidating Shout")
        end

        UseArcanePotsOnSkeram()
        return true
    end

    local inF = false
    local tName = UnitName("target")

    local leftTank = ReturnPlayerInRaidFromTable(MB_mySkeramLeftTanks)
    local middleTank = ReturnPlayerInRaidFromTable(MB_mySkeramMiddleTanks)
    local rightTank = ReturnPlayerInRaidFromTable(MB_mySkeramRightTanks)

    if HasBuffOrDebuff("True Fulfillment", "player", "debuff") then
        inF = true
    elseif TargetFromSpecificPlayer("The Prophet Skeram", leftTank) then
        inF = true
    elseif TargetFromSpecificPlayer("The Prophet Skeram", middleTank) then
        inF = true
    elseif TargetFromSpecificPlayer("The Prophet Skeram", rightTank) then
        inF = true
    elseif TankTarget("The Prophet Skeram") then
        inF = true
    else
        if tName and tName == "The Prophet Skeram" then
            inF = true
        end
    end

    if inF then
        CdAddonMessage(MB_RAID.."SKERAM", "ENGAGE", 30)
        SkeramEncounter.Active = true
        return true
    end

	return false
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local function CheckIfRealDeath()
    if SkeramEncounter.Active and not InCombat() then
        CdAddonMessage(MB_RAID.."SKERAM", "DISENGAGE", 30)
    end
end

function SKERAM:CHAT_MSG_ADDON()
    if arg1 == MB_RAID.."SKERAM" then
        if arg2 == "ENGAGE" then
            CdRaidWarning(">> Fighting Skeram! <<")
            self:OnEnable()
        elseif arg2 == "DISENGAGE" then
            CdRaidWarning(">> Skeram has died! <<")
            self:ScheduleEvent("SKERAM_CLEANUP", self.OnCleanUp, 15, self)
        end
    end
end

function SKERAM:CHAT_MSG_COMBAT_HOSTILE_DEATH()
    if string.find(arg1, "Prophet Skeram dies") and SkeramEncounter.Active then
        self:ScheduleEvent("SKERAM_DEATH_CHECK", CheckIfRealDeath, 5)
    end
end

function SKERAM:PLAYER_ENTERING_WORLD()
    self:CancelScheduledEvent("SKERAM_DEATH_CHECK")
    self:CancelScheduledEvent("SKERAM_CLEANUP")
    self:OnReset()
end

function SKERAM:PLAYER_REGEN_ENABLED()
    self:CancelScheduledEvent("SKERAM_DEATH_CHECK")
    self:CancelScheduledEvent("SKERAM_CLEANUP")
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function SKERAM_TargetingPreFocus()
    local tName = UnitName("target")

	if SKERAM_CheckEncounter() and MB_mySkeramBoxStrategy then
        if not tName then
            return false
        end

        if not ImTank() then
            return false
        end

        if HasBuffOrDebuff("True Fulfillment", "target", "debuff") then
            TargetByName("The Prophet Skeram")
            return false
        end
        
        if tName == "The Prophet Skeram" and not GetRaidTargetIndex("target") then
            local icon

            if MyNameInTable(MB_mySkeramLeftTanks) or MyNameInTable(MB_mySkeramLeftOFFTANKS) then
                icon = 4
            elseif MyNameInTable(MB_mySkeramMiddleTanks) or MyNameInTable(MB_mySkeramMiddleOFFTANKS) then
                icon = 1
            elseif MyNameInTable(MB_mySkeramRightTanks) or MyNameInTable(MB_mySkeramRightOFFTANKS) then
                icon = 6
            end

            if icon then
                SetRaidTarget("target", icon)
            end
        end
    end

    return false
end

function SKERAM_TargetingPostFocus()
    local tName = UnitName("target")

	if SKERAM_CheckEncounter() and MB_mySkeramBoxStrategy then
        if MyNameInTable(MB_mySkeramLeftTanks) or MyNameInTable(MB_mySkeramMiddleTanks) or MyNameInTable(MB_mySkeramRightTanks) then     
            if not MB_targetNearestDistanceChanged then            
                SetCVar("targetNearestDistance", "15")
                MB_targetNearestDistanceChanged = true
            end

            if HasBuffOrDebuff("True Fulfillment", "target", "debuff") then
				ClearTarget()
			end

            if tName == nil or Dead("target") or not InMeleeRange() then
                TargetNearestEnemy()
            end
            return true

        elseif ImTank() then
            if not MB_targetNearestDistanceChanged then				
				SetCVar("targetNearestDistance", "10")
				MB_targetNearestDistanceChanged = true
			end

            if HasBuffOrDebuff("True Fulfillment", "target", "debuff") then
				ClearTarget()
			end

            if tName == nil or Dead("target") or not InMeleeRange() then
                TargetNearestEnemy()
            end
			return true

        elseif ImRangedDPS() or ImMeleeDPS() or ImHealer() then
			if HasBuffOrDebuff("True Fulfillment", "target", "debuff") then
				ClearTarget()
			end

            AssistFocus()
			return true
        end
    end

    return false
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

SKERAM:OnInitialize()

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function SKERAM_WarlockDebuff()
    local skeramTankMap = {
        [1] = MB_mySkeramLeftTanks,
        [2] = MB_mySkeramMiddleTanks,
        [3] = MB_mySkeramRightTanks,
        [4] = MB_mySkeramLeftTanks,
        [5] = MB_mySkeramMiddleTanks,
        [6] = MB_mySkeramRightTanks
    }

    local myOrder = MyClassAlphabeticalOrder()
    local tankName = ReturnPlayerInRaidFromTable(skeramTankMap[myOrder])

    if tankName and TargetFromSpecificPlayer("The Prophet Skeram", tankName) then
        local tankId = MBID[tankName]
        local targetID = tankId.."target"

        if tankId and not HasBuffOrDebuff("Curse of Tongues", targetID, "debuff") then
            AssistUnit(tankId)

            if ImBusy() then
                SpellStopCasting()
            end

            CastSpellByName("Curse of Tongues")
            TargetLastTarget()
            return true
        end
    end

    return false
end

function SKERAM_WarlockEnable()
    return MB_mySkeramBoxStrategy
end

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

local function CrowdControlMCedRaidMemberSkeram()
    if Dead("player") then
        return
    end

    for i = 1, GetNumRaidMembers() do
        local unit = "raid"..i
        if unit and IsAlive(unit) and In28yardRange(unit) then
            if HasBuffOrDebuff("True Fulfillment", unit, "debuff") 
               and not HasBuffOrDebuff("Polymorph", unit, "debuff") then

                TargetUnit(unit)

                if not MB_isCastingMyCCSpell then
                    SpellStopCasting()
                end

                CastSpellByName("Polymorph")
                return true
            end
        end
    end

    return false
end

local function CrowdControlMCedRaidMemberSkeramAOE()
    if Dead("player") or not SpellReady("Psychic Scream") then
        return
    end

    for i = 1, GetNumRaidMembers() do
        local unit = "raid"..i
        if unit and IsAlive(unit) and CheckInteractDistance(unit, 3) then
            if HasBuffOrDebuff("True Fulfillment", unit, "debuff")
                and not HasBuffOrDebuff("Polymorph", unit, "debuff")
                and not HasBuffOrDebuff("Psychic Scream", unit, "debuff") then

                if ImBusy() then
                    SpellStopCasting()
                end

                CastSpellByName("Psychic Scream")
                return true
            end
        end
    end

    return false
end

function SKERAM_CrowdControl()
    if not SKERAM_CheckEncounter() or not MB_mySkeramBoxStrategy then
        return false
    end

    if HasBuffOrDebuff("True Fulfillment", "target", "debuff") then
        ClearTarget()
        return true
    end

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
    end
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function SKERAM_IsFollowSkeram()
    if not SKERAM_CheckEncounter() or not MB_mySkeramBoxStrategy then
        return false
    end

    if MyNameInTable(MB_mySkeramLeftTanks) or MyNameInTable(MB_mySkeramMiddleTanks) or MyNameInTable(MB_mySkeramRightTanks) then
        return true
    end

    local leftTank = ReturnPlayerInRaidFromTable(MB_mySkeramLeftTanks)
    local middleTank = ReturnPlayerInRaidFromTable(MB_mySkeramMiddleTanks)
    local rightTank = ReturnPlayerInRaidFromTable(MB_mySkeramRightTanks)

    if MyNameInTable(MB_mySkeramLeftOFFTANKS) then
        FollowByName(leftTank, 1)
        return true
    end

    if MyNameInTable(MB_mySkeramMiddleOFFTANKS) then
        FollowByName(middleTank, 1)
        return true
    end

    if MyNameInTable(MB_mySkeramMiddleDPSERS) then
        FollowByName(middleTank, 1)
        return true
    end

    if MyNameInTable(MB_mySkeramRightOFFTANKS) then
        FollowByName(rightTank, 1)
        return true
    end
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--
