--[####################################################################################################]--
--[############################################# GLUTH CODE ###########################################]--
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
local ImBusy = mb_imBusy
local ImHealer = mb_imHealer
local ImMeleeDPS = mb_imMeleeDPS
local ImRangedDPS = mb_imRangedDPS
local ImTank = mb_imTank
local InCombat = mb_inCombat
local IsAlive = mb_isAlive
local LockOnTarget = mb_lockOnTarget
local TakePotionsWhenPossible = mb_takePotionsWhenPossible
local TankTarget = mb_tankTarget
local TankTargetHealth = mb_tankTargetHealth
local TargetFromSpecificPlayer = mb_targetFromSpecificPlayer
local UnitInRange = mb_unitInRange

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local GLUTH = CreateFrame("Button", "GLUTH", UIParent)

do
    for _, event in {
        "CHAT_MSG_ADDON",
        "ZONE_CHANGED_NEW_AREA",
        "PLAYER_ENTERING_WORLD"
    }
    do
        GLUTH:RegisterEvent(event)
    end
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

-- Strategy Configuration
local MB_myGluthBoxStrategy = true
local MB_myGluthNaturePotStrategy = true

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local function UseNaturePotsOnGluth()
    if not MB_myGluthNaturePotStrategy then
        return
    end

    if ImBusy() or not InCombat("player") then
        return
    end

    if ImMeleeDPS() or ImTank() then
        return
    end

    TakePotionsWhenPossible("Greater Nature Protection Potion")
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function GLUTH_IsAtGluth()
    if (TankTarget("Gluth") or TankTarget("Zombie Chow")) then
        return true
    end

    local tName = UnitName("target")
    if not tName then
        return false
    end

    if (tName == "Gluth" or tName == "Zombie Chow") then
        return true
    end

    return false
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function GLUTH:OnEvent()
    if (event == "CHAT_MSG_ADDON") then

    end
end

GLUTH:SetScript("OnEvent", GLUTH.OnEvent)

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function GLUTH_GetOUT()
    if GLUTH_IsAtGluth() and MB_myGluthBoxStrategy then
        if TankTarget("Gluth") and TankTargetHealth() < 0.4 then
            UseNaturePotsOnGluth()
        end
        return true
    end
    return false
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--
