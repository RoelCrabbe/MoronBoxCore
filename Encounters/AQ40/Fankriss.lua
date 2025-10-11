--[####################################################################################################]--
--[########################################## BUG TRIO CODE ###########################################]--
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
local AssistSpecificTargetFromPlayerInMeleeRange =  mb_assistSpecificTargetFromPlayerInMeleeRange
local CdAddonMessage = mb_cdAddonMessage
local CdMessage = mb_cdMessage
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
local TakePotionsWhenPossible = mb_takePotionsWhenPossible
local TankTarget = mb_tankTarget
local TankTargetHealth = mb_tankTargetHealth
local TargetFromSpecificPlayer = mb_targetFromSpecificPlayer
local UnitInRange = mb_unitInRange
local UseFromBags = mb_useFromBags

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local FANKRISS = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0")

function FANKRISS:OnInitialize()
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
local MB_myFankrissBoxStrategy = true

-- Tank Assignments (REQUIRED)
local MB_myFankrissOFFTANKS = {
    "Suecia",               -- Horde (Targets boss, manual taunt)
    "Droodood"              -- Alliance
}

local MB_myFankrissSpawnTANKone = {
    "Ajlano",               -- Horde (Targets snakes, caster assist)
    "Laty"                  -- Alliance
}

local MB_myFankrissSpawnTANKtwo = {
    "Almisael",             -- Horde (Targets snakes, caster assist)  
    "Myosin"                -- Alliance
}

-- Strategy Configuration -- No changes below this line
local FankrissEncounter = {
    Active = false
}

function FANKRISS:OnEnable()
    FankrissEncounter.Active = true
end

function FANKRISS:OnReset()
    FankrissEncounter.Active = false
end

function FANKRISS:OnCleanUp()
    self:OnReset()
    self:UnregisterAllEvents()
    CdPrint(">> FANKRISS - CLEANUP <<")
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local function TankHasMortalWound(targetId)
    local mortalWound = "Interface\\Icons\\Ability_CriticalStrike"

    if not targetId then
        return false
    end

    for x = 1, 16 do
        local name, count = UnitDebuff(targetId, x)
        if name == mortalWound and count and count >= 4 then
            return true
        end
    end
    return false
end

local function AnnounceMortalWound()
    local focId = MBID[MB_raidLeader]
    if not focId then
        return
    end
    
    local targetName = UnitName(focId.."target")
    if targetName == "Fankriss the Unyielding" and TankHasMortalWound(focId) then
        CdAddonMessage(MB_RAID.."FANKRISS", "TAUNT_BOSS", 30)
    end
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local function FANKRISS_CheckEncounter()
    if FankrissEncounter.Active then
        return true
    end

    local inF = false
    local tName = UnitName("target")

    if (TankTarget("Fankriss the Unyielding") or TankTarget("Spawn of Fankriss")) then
        inF = true
    else
        if tName and (tName == "Fankriss the Unyielding" or tName == "Spawn of Fankriss") then
            inF = true
        end
    end

    if inF then
        CdAddonMessage(MB_RAID.."FANKRISS", "ENGAGE", 30)
        FankrissEncounter.Active = true
        return true
    end

	return false
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function FANKRISS:CHAT_MSG_ADDON()
    if arg1 == MB_RAID.."FANKRISS" then
        if arg2 == "ENGAGE" then
            CdRaidWarning(">> Fighting Fankriss! <<")
            self:OnEnable()
        elseif arg2 == "DISENGAGE" then
            CdRaidWarning(">> Fankriss has died! <<")
            self:ScheduleEvent("FANKRISS_CLEANUP", self.OnCleanUp, 15, self)
        elseif arg2 == "TAUNT_BOSS" then
            CdRaidWarning(">> TANK: Taunt Boss NOW! <<")
        end
    end
end

function FANKRISS:CHAT_MSG_COMBAT_HOSTILE_DEATH()
    if string.find(arg1, "Fankriss the Unyielding dies") and FankrissEncounter.Active then
        CdAddonMessage(MB_RAID.."FANKRISS", "DISENGAGE", 30)
    end
end

function FANKRISS:ZONE_CHANGED_NEW_AREA()
    self:OnReset()
end

function FANKRISS:PLAYER_ENTERING_WORLD()
    self:OnReset()
end

function FANKRISS:PLAYER_REGEN_ENABLED()
    self:OnReset()
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function FANKRISS_MageDPS(Mage)
    local tName = UnitName("target")

    if tName ~= "Spawn of Fankriss" then
        return false
    end

    if SpellReady("Fireblast") and InMeleeRange() then
        CastSpellByName("Fire Blast")
    end

    if Mage[MB_mySpecc] then
        Mage[MB_mySpecc](Mage)
    end

    return true
end

function FANKRISS_WarlockDPS(Warlock)
    local tName = UnitName("target")

    if tName ~= "Spawn of Fankriss" then
        return false
    end

    Warlock:SaveShardShadowBurn(9)
    return true
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function FANKRISS_TargetingPreFocus()
    local tName = UnitName("target")

	if FANKRISS_CheckEncounter() and MB_myFankrissBoxStrategy then
        local myFankrissOFFTANK = ReturnPlayerInRaidFromTable(MB_myFankrissOFFTANKS)

        if (myName == myFankrissOFFTANK) and MB_raidLeader ~= myName then
            MB_raidLeader = myName
        end

        if not ImFocus() then
            return false
        end

        if myName == myFankrissOFFTANK then
            if not MB_targetNearestDistanceChanged then                
                SetCVar("targetNearestDistance", "15")
                MB_targetNearestDistanceChanged = true
            end

            if LockOnTarget("Fankriss the Unyielding") then
                AnnounceMortalWound()
                return true
            end

            if tName == nil or Dead("target") or not InMeleeRange() then
                TargetNearestEnemy()
            end
            return true
        end
    end

    return false
end

local function TankSurviveSnake()
    if HealthPct("player") <= 0.4 then				
        SelfBuff("Last Stand") 
    end

    if HealthPct("player") <= 0.3 then				
        SelfBuff("Shield Wall") 
    end
end

function FANKRISS_TargetingPostFocus()
    local tName = UnitName("target")

	if FANKRISS_CheckEncounter() and MB_myFankrissBoxStrategy then
        local myFankrissOFFTANK = ReturnPlayerInRaidFromTable(MB_myFankrissOFFTANKS)
        local mySnakeTANKone = ReturnPlayerInRaidFromTable(MB_myFankrissSpawnTANKone)
        local mySnakeTANKtwo = ReturnPlayerInRaidFromTable(MB_myFankrissSpawnTANKtwo)

        if (myName == myFankrissOFFTANK) then
            if not MB_targetNearestDistanceChanged then             
                SetCVar("targetNearestDistance", "15")
                MB_targetNearestDistanceChanged = true
            end

            if LockOnTarget("Fankriss the Unyielding") then
                return true
            end

            if tName == nil or Dead("target") or not InMeleeRange() then
                TargetNearestEnemy()
            end
            return true

        elseif (myName == mySnakeTANKone or myName == mySnakeTANKtwo) then				
            if not MB_targetNearestDistanceChanged then				
				SetCVar("targetNearestDistance", "25")
				MB_targetNearestDistanceChanged = true
			end

            if FixateOnTarget("Spawn of Fankriss") then
                TankSurviveSnake()
                return true
            end

			GetTargetNotOnTank()
			return true

        elseif ImTank() then
            if not MB_targetNearestDistanceChanged then				
				SetCVar("targetNearestDistance", "10")
				MB_targetNearestDistanceChanged = true
			end

			GetTargetNotOnTank()
			return true

        elseif ImMeleeDPS() and myClass == "Warrior" then
            if LockOnTarget("Fankriss the Unyielding") then
                return true
            end

            AssistFocus()
            return true

        elseif (ImMeleeDPS() and myClass == "Rogue") or ImHealer() then
            if AssistSpecificTargetFromPlayerInMeleeRange("Spawn of Fankriss", mySnakeTANKone) then
                return true
            end

            if AssistSpecificTargetFromPlayerInMeleeRange("Spawn of Fankriss", mySnakeTANKtwo) then
                return true
            end

            if LockOnTarget("Fankriss the Unyielding") then
                return true
            end

            AssistFocus()
            return true

        elseif ImRangedDPS() then
            if AssistSpecificTargetFromPlayer("Spawn of Fankriss", mySnakeTANKone) then
                return true
            end

            if AssistSpecificTargetFromPlayer("Spawn of Fankriss", mySnakeTANKtwo) then
                return true
            end

            if LockOnTarget("Fankriss the Unyielding") then
                return true
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

FANKRISS:OnInitialize()
