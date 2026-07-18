--[####################################################################################################]--
--[########################################### SARTURA CODE ###########################################]--
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
local myClass = UnitClass("player") --[[@as string]]
local myName = UnitName("player") --[[@as string]]
local myRace = UnitRace("player") --[[@as string]]

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local AssistFocus = mb_assistFocus
local AssistSpecificTargetFromPlayer = mb_assistSpecificTargetFromPlayer
local AssistSpecificTargetFromPlayerInMeleeRange = mb_assistSpecificTargetFromPlayerInMeleeRange
local CdAddonMessage = mb_cdAddonMessage
local CdMessage = mb_cdMessage
local CoolDownCast = mb_coolDownCast
local CdPrint = mb_cdPrint
local CdRaidWarning = mb_cdRaidWarning
local Dead = mb_dead
local FixateOnTarget = mb_fixateOnTarget
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
local PotionsWhenPossible = mb_takePotionsWhenPossible
local TankTarget = mb_tankTarget
local TankTargetHealth = mb_tankTargetHealth
local TargetFromSpecificPlayer = mb_targetFromSpecificPlayer
local UnitInRange = mb_unitInRange
local UseFromBags = mb_useFromBags

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local SARTURA = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0")

function SARTURA:OnInitialize()
    self:RegisterEvent("CHAT_MSG_ADDON")
    self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

-- Strategy Configuration
local MB_mySarturaBoxStrategy = true

-- Strategy Configuration -- No changes below this line
local SarturaEncounter = {
    Active = false
}

function SARTURA:OnEnable()
    SarturaEncounter.Active = true
end

function SARTURA:OnReset()
    SarturaEncounter.Active = false
end

function SARTURA:OnCleanUp()
    self:OnReset()
    self:UnregisterAllEvents()
    CdPrint(">> SARTURA - CLEANUP <<")
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local function SARTURA_CheckEncounter()
    if SarturaEncounter.Active then
        return true
    end

    local inF = false
    local tName = UnitName("target")

    if (TankTarget("Battleguard Sartura") or TankTarget("Sartura\'s Royal Guard")) then
        inF = true
    else
        if tName and (tName == "Battleguard Sartura" or tName == "Sartura\'s Royal Guard") then
            inF = true
        end
    end

    if inF then
        CdAddonMessage(getRaidId() .. "SARTURA", "ENGAGE", 30)
        SarturaEncounter.Active = true
        return true
    end

    return false
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function SARTURA:CHAT_MSG_ADDON()
    if arg1 == getRaidId() .. "SARTURA" then
        if arg2 == "ENGAGE" then
            CdRaidWarning(">> Fighting Sartura! <<")
            self:OnEnable()
        elseif arg2 == "DISENGAGE" then
            CdRaidWarning(">> Sartura has died! <<")
            self:ScheduleEvent("SARTURA_CLEANUP", self.OnCleanUp, 15, self)
        end
    end
end

function SARTURA:CHAT_MSG_COMBAT_HOSTILE_DEATH()
    if string.find(arg1, "Battleguard Sartura dies") and SarturaEncounter.Active then
        CdAddonMessage(getRaidId() .. "SARTURA", "DISENGAGE", 30)
    end
end

function SARTURA:ZONE_CHANGED_NEW_AREA()
    self:OnReset()
end

function SARTURA:PLAYER_ENTERING_WORLD()
    self:OnReset()
end

function SARTURA:PLAYER_REGEN_ENABLED()
    self:OnReset()
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function SARTURA_DruidDPS()
    local tName = UnitName("target")

    if tName ~= "Battleguard Sartura" then
        return false
    end

    CoolDownCast("Moonfire", 24)
end

function SARTURA_PriestDPS()
    local tName = UnitName("target")

    if tName ~= "Battleguard Sartura" then
        return false
    end

    CoolDownCast("Shadow Word: Pain", 24)
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function SARTURA_TargetingPostFocus()
    local tName = UnitName("target")

    if SARTURA_CheckEncounter() and MB_mySarturaBoxStrategy then
        if ImTank() then
            if not MB_targetNearestDistanceChanged then
                SetCVar("targetNearestDistance", "15")
                MB_targetNearestDistanceChanged = true
            end

            GetTargetNotOnTank()
            return true
        elseif ImRangedDPS() or ImMeleeDPS() or ImHealer() then
            AssistFocus()
            return true
        end
    end

    return false
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

SARTURA:OnInitialize()
