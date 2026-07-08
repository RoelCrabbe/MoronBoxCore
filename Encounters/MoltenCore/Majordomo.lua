--[####################################################################################################]--
--[########################################## MAJORDOMO CODE ##########################################]--
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
local CdAddonMessage = mb_cdAddonMessage
local CdMessage = mb_cdMessage
local CdPrint = mb_cdPrint
local CdRaidWarning = mb_cdRaidWarning
local Dead = mb_dead
local GetTargetNotOnTank = mb_getTargetNotOnTank
local HasBuffOrDebuff = mb_hasBuffOrDebuff
local ImBusy = mb_imBusy
local ImHealer = mb_imHealer
local ImMeleeDPS = mb_imMeleeDPS
local ImRangedDPS = mb_imRangedDPS
local ImTank = mb_imTank
local InCombat = mb_inCombat
local IsAlive = mb_isAlive
local LockOnTarget = mb_lockOnTarget
local MyNameInTable = mb_myNameInTable
local TakePotionsWhenPossible = mb_takePotionsWhenPossible
local TankTarget = mb_tankTarget
local TankTargetHealth = mb_tankTargetHealth
local TargetFromSpecificPlayer = mb_targetFromSpecificPlayer
local UnitInRange = mb_unitInRange

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local MAJORDOMO = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0")

function MAJORDOMO:OnInitialize()
    self:RegisterEvent("CHAT_MSG_ADDON")
    self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

-- Strategy Configuration
local MB_myMajordomoBoxStrategy = true
local MB_myMajordomoFirePotStrategy = true

-- Strategy Configuration -- No changes below this line
local MajordomoEncounter = {
    Active = false,
    HealersDead = 0,
    ElitesDead = 0
}

function MAJORDOMO:OnEnable()
    MajordomoEncounter = {
        Active = true,
        HealersDead = 0,
        ElitesDead = 0
    }
end

function MAJORDOMO:OnReset()
    MajordomoEncounter = {
        Active = false,
        HealersDead = 0,
        ElitesDead = 0
    }
end

function MAJORDOMO:OnCleanUp()
    self:OnReset()
    self:UnregisterAllEvents()
    CdPrint(">> MAJORDOMO - CLEANUP <<")
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local function UseFirePotsOnMajordomo()
    if not MB_myMajordomoFirePotStrategy then
        return
    end

    TakePotionsWhenPossible("Greater Fire Protection Potion")
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local function MAJORDOMO_CheckEncounter()
    if MajordomoEncounter.Active then
        UseFirePotsOnMajordomo()
        return true
    end

    local inF = false
    local tName = UnitName("target")

    if (TankTarget("Majordomo Executus") or TankTarget("Flamewaker Healer") or TankTarget("Flamewaker Elite")) then
        inF = true
    else
        if tName and (tName == "Majordomo Executus" or tName == "Flamewaker Healer" or tName == "Flamewaker Elite") then
            inF = true
        end
    end

    if inF then
        CdAddonMessage(MB_RAID .. "MAJORDOMO", "ENGAGE", 30)
        MajordomoEncounter.Active = true
        return true
    end

    return false
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function MAJORDOMO:CHAT_MSG_ADDON()
    if arg1 == MB_RAID .. "MAJORDOMO" then
        if arg2 == "ENGAGE" then
            CdRaidWarning(">> Fighting Majordomo! <<")
            self:OnEnable()
        elseif arg2 == "DISENGAGE" then
            CdRaidWarning(">> Majordomo has fled! <<")
            self:ScheduleEvent("MAJORDOMO_CLEANUP", self.OnCleanUp, 15, self)
        end
    end
end

function MAJORDOMO:CHAT_MSG_MONSTER_YELL()
    if string.find(arg1, "I go now to summon the lord whose house this is") and MajordomoEncounter.Active then
        CdAddonMessage(MB_RAID .. "MAJORDOMO", "DISENGAGE", 30)
    end
end

function MAJORDOMO:ZONE_CHANGED_NEW_AREA()
    self:OnReset()
end

function MAJORDOMO:PLAYER_ENTERING_WORLD()
    self:OnReset()
end

function MAJORDOMO:PLAYER_REGEN_ENABLED()
    self:OnReset()
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function MAJORDOMO_TargetingPostFocus()
    if MAJORDOMO_CheckEncounter() and MB_myMajordomoBoxStrategy then
        if ImTank() then
            if not MB_targetNearestDistanceChanged then
                SetCVar("targetNearestDistance", "10")
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

MAJORDOMO:OnInitialize()
