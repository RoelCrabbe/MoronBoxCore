--[####################################################################################################]--
--[############################################ GEDDON CODE ###########################################]--
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
local PotionsWhenPossible = mb_takePotionsWhenPossible
local TankTarget = mb_tankTarget
local TankTargetHealth = mb_tankTargetHealth
local TankName = mb_tankName
local TargetFromSpecificPlayer = mb_targetFromSpecificPlayer
local UnitInRange = mb_unitInRange

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local GEDDON = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0")

function GEDDON:OnInitialize()
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
local MB_myGeddonBoxStrategy = true
local MB_myGeddonHealers = {}

local MB_myGeddonHealerAssignment = { -- [Player Number] = [Number of Players Assigned]
    [1] = 3                           -- Main Tank
}

-- Strategy Configuration -- No changes below this line
local GeddonEncounter = {
    Active = false
}

function GEDDON:OnEnable()
    GeddonEncounter.Active = true
end

function GEDDON:OnReset()
    GeddonEncounter.Active = false
    MB_myGeddonHealers = {}
    MB_myAssignedHealTarget = nil

    self:CancelScheduledEvent("GetGeddonHealers")
    self:CancelScheduledEvent("GeddonHealerAssignments")
end

function GEDDON:OnCleanUp()
    self:OnReset()
    self:UnregisterAllEvents()
    CdPrint(">> GEDDON - CLEANUP <<")
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local function GetHealersOnGeddon()
    if not ImHealer() then
        return false
    end

    if myClass == "Priest" then
        CdPrint(">> Priest healers are not allowed to register as Geddon Healers! <<", 60)
        return false
    end

    if MyNameInTable(MB_myGeddonHealers) then
        return true
    end

    CdAddonMessage(MB_RAID .. "GEDDON", "HEALERS", 30)
    return true
end

local function HandleHealersOnGeddon()
    if not ImHealer() then
        return false
    end

    if myClass == "Priest" then
        return false
    end

    if MyNameInTable(MB_myGeddonHealers) then
        return true
    end

    table.insert(MB_myGeddonHealers, myName)
    CdPrint(">> You are now registered as a Geddon Healer! <<")
    return true
end

local function AssignHealersToTanks()
    if not ImHealer() then
        return false
    end

    if not MyNameInTable(MB_myGeddonHealers) then
        return false
    end

    MB_myAssignedHealTarget = nil

    local myPosition = nil
    for i = 1, TableLength(MB_myGeddonHealers) do
        if MB_myGeddonHealers[i] == myName then
            myPosition = i
            break
        end
    end

    if not myPosition then
        return false
    end

    local tankHealers = MB_myGeddonHealerAssignment[1] or 0
    if myPosition > tankHealers then
        return false
    end

    local tankName = TankName()
    local tankUnit = MBID[tankName]
    local tankToHeal = tankUnit and UnitName(tankUnit .. "targettarget")

    if not tankToHeal then
        return false
    end

    MB_myAssignedHealTarget = tankToHeal
    return false
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local function GEDDON_CheckEncounter()
    if GeddonEncounter.Active then
        return true
    end

    local inF = false
    local tName = UnitName("target")

    if TankTarget("Baron Geddon") then
        inF = true
    else
        if tName and tName == "Baron Geddon" then
            inF = true
        end
    end

    if inF then
        CdAddonMessage(MB_RAID .. "GEDDON", "ENGAGE", 30)
        GeddonEncounter.Active = true
        return true
    end

    return false
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function GEDDON:CHAT_MSG_ADDON()
    if arg1 == MB_RAID .. "GEDDON" then
        if arg2 == "ENGAGE" then
            CdRaidWarning(">> Fighting Geddon! <<")
            self:OnEnable()

            GetHealersOnGeddon()
            self:ScheduleEvent("GetGeddonHealers", GetHealersOnGeddon, 3)
            self:ScheduleEvent("GeddonHealerAssignments", AssignHealersToTanks, 5)
        elseif arg2 == "DISENGAGE" then
            CdRaidWarning(">> Geddon has died! <<")
            self:ScheduleEvent("GEDDON_CLEANUP", self.OnCleanUp, 15, self)
        elseif (arg2 == "HEALERS") then
            HandleHealersOnGeddon()
        end
    end
end

function GEDDON:CHAT_MSG_COMBAT_HOSTILE_DEATH()
    if string.find(arg1, "Baron Geddon dies") and GeddonEncounter.Active then
        CdAddonMessage(MB_RAID .. "GEDDON", "DISENGAGE", 30)
    end
end

function GEDDON:ZONE_CHANGED_NEW_AREA()
    self:OnReset()
end

function GEDDON:PLAYER_ENTERING_WORLD()
    self:OnReset()
end

function GEDDON:PLAYER_REGEN_ENABLED()
    self:OnReset()
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function GEDDON_TargetingPostFocus()
    if GEDDON_CheckEncounter() and MB_myGeddonBoxStrategy then
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

GEDDON:OnInitialize()
