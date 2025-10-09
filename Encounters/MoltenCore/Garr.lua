--[####################################################################################################]--
--[############################################# GARR CODE ############################################]--
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
local MyNameInTable = mb_myNameInTable
local TakePotionsWhenPossible = mb_takePotionsWhenPossible
local TankTarget = mb_tankTarget
local TankTargetHealth = mb_tankTargetHealth
local TargetFromSpecificPlayer = mb_targetFromSpecificPlayer
local UnitInRange = mb_unitInRange

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local GARR = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0")

function GARR:OnInitialize()
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
local MB_myGarrBoxStrategy = true 
local MB_myGarrHealers = {}

local MB_myGarrTankAssignment = { -- [Tank Number] = [Number of Players Assigned]
    [1] = 2,  -- Main Tank
    [2] = 2,  -- Off Tank
    [3] = 1,  -- Extra Tank
    [4] = 1   -- Extra Tank
}

-- Strategy Configuration -- No changes below this line
local GarrEncounter = {
    Active = false
}

function GARR:OnEnable()
    GarrEncounter.Active = true
end

function GARR:OnReset()
    GarrEncounter.Active = false
    MB_myGarrHealers = {}
    MB_myAssignedHealTarget = nil

    self:CancelScheduledEvent("GetGarrHealers")
    self:CancelScheduledEvent("GarrHealerAssignments")
end

function GARR:OnCleanUp()
    self:OnReset()
    self:UnregisterAllEvents()
    CdPrint(">> GARR - CLEANUP <<")
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local function GetHealersOnGarr()
    if not ImHealer() then
        return false
    end

    if MyNameInTable(MB_myGarrHealers) then
        return true
    end
    
    CdAddonMessage(MB_RAID.."GARR", "HEALERS", 30)
    return true
end

local function HandleHealersOnGarr()
    if not ImHealer() then
        return false
    end

    if MyNameInTable(MB_myGarrHealers) then
        return true
    end
    
    table.insert(MB_myGarrHealers, myName)
    CdPrint(">> You are now registered as a Garr Healer! <<")
    return true
end

local function AssignHealersToTanks()
    if not ImHealer() then
        return false
    end

    if not MyNameInTable(MB_myGarrHealers) then
        return false
    end

    MB_myAssignedHealTarget = nil

    local myPosition = nil
    for i = 1, TableLength(MB_myGarrHealers) do
        if MB_myGarrHealers[i] == myName then
            myPosition = i
            break
        end
    end
    
    if not myPosition then
        return false
    end
    
    local healerIndex = 0
    for tankNum = 1, TableLength(MB_raidTanks) do
        local tankName = MB_raidTanks[tankNum]
        local healersNeeded = MB_myGarrTankAssignment[tankNum] or 0
        
        for h = 1, healersNeeded do
            healerIndex = healerIndex + 1
            if healerIndex == myPosition then
                MB_myAssignedHealTarget = tankName
                CdPrint(">> Assigned to heal: "..tankName.." <<")
                return true
            end
        end
    end

    return false
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local function GARR_CheckEncounter()
	if GarrEncounter.Active then
        return true
    end

	local inF = false
    local tName = UnitName("target")

    if (TankTarget("Garr") or TankTarget("Firesworn")) then
        inF = true
    else
        if tName and (tName == "Garr" or tName == "Firesworn") then
            inF = true
        end
    end

    if inF then
        CdAddonMessage(MB_RAID.."GARR", "ENGAGE", 30)
        GarrEncounter.Active = true
        return true
    end

	return false
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function GARR:CHAT_MSG_ADDON()
    if arg1 == MB_RAID.."GARR" then
        if arg2 == "ENGAGE" then
            CdRaidWarning(">> Fighting Garr! <<")
            self:OnEnable()

            GetHealersOnGarr()
            self:ScheduleEvent("GetGarrHealers", GetHealersOnGarr, 3)
            self:ScheduleEvent("GarrHealerAssignments", AssignHealersToTanks, 5)
        elseif arg2 == "DISENGAGE" then
            CdRaidWarning(">> Garr has died! <<")
            self:ScheduleEvent("GARR_CLEANUP", self.OnCleanUp, 15, self)
        elseif (arg2 == "HEALERS") then
            HandleHealersOnGarr()
        end
    end
end

function GARR:CHAT_MSG_COMBAT_HOSTILE_DEATH()
    if string.find(arg1, "Garr dies") and GarrEncounter.Active then
        CdAddonMessage(MB_RAID.."GARR", "DISENGAGE", 30)
    end
end

function GARR:ZONE_CHANGED_NEW_AREA()
    self:OnReset()
end

function GARR:PLAYER_ENTERING_WORLD()
    self:OnReset()
end

function GARR:PLAYER_REGEN_ENABLED()
    self:OnReset()
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function GARR_TargetingPostFocus()
	if GARR_CheckEncounter() and MB_myGarrBoxStrategy then
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

GARR:OnInitialize()
