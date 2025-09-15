--[####################################################################################################]--
--[########################################### THADDIUS CODE ##########################################]--
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
local ImFocus = mb_imFocus
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

local THAD = CreateFrame("Button", "THAD", UIParent)

do
	for _, event in {
		"CHAT_MSG_ADDON",
        "ZONE_CHANGED_NEW_AREA",
        "PLAYER_ENTERING_WORLD"
		}
		do THAD:RegisterEvent(event)
	end
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

-- Strategy Configuration
local MB_myThaddiusBoxStrategy = true 
local MB_myThaddiusNaturePotStrategy = true

-- Tank & DPS Assignments (REQUIRED)
local MB_myFeugenMainTank = "Moron"
local MB_myFeugenOffTank = "Almisael"

local MB_myFeugenDPSERS = {
    MB_myFeugenOffTank,

    -- Mages
    "Frostoni",
    "Salka",
    "Alionex",
    "Grimpeh",
    "Xlimidrizer",
    "Damacon",
    "Schoffie",
    "Mizea",
    "Merkan",
    "Thehatter",
    "Rotonic",
    "Trinali",

    -- Warlock
    "Ayaag"
}

local MB_myFeugenHEALERS = {
    -- Shaman
    "Shamuk",
    "Rockon",
    "Mvenna",
    "Shaitan",

    -- Priest
    "Liket",
    "Cyal",

    -- Druid
    "Pyqmi"
}

local MB_myStalaggMainTank = "Suecia"
local MB_myStalaggOffTank = "Ajlano"

local MB_myStalaggDPSERS = {
    MB_myStalaggOffTank,

    -- Mages
    "Bluedabadee",
    "Nofreewater",
    "Oxg",
    "Nyktheus",
    "Drogles",
    "Kelseran",
    "Umek",
    "Ykani",
    "Hypernewb",

    -- Warlock
    "Akaaka"
}

local MB_myStalaggHEALERS = {
    -- Shaman
    "Hurtek",
    "Slaver",
    "Chimando",
    "Lillifee",

    -- Priest
    "Blaidzy",
    "Bonita"
}

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local function GetClosestMainTankForSide()
    local data = { tank = nil, off = nil, side = nil }

    if MyNameInTable(MB_myFeugenDPSERS) or MyNameInTable(MB_myFeugenHEALERS) or myName == MB_myFeugenOffTank then
        data = {
            tank = MB_myFeugenMainTank,
            off = MB_myFeugenOffTank,
            side = "Feugen"
        }
    end

    if MyNameInTable(MB_myStalaggDPSERS) or MyNameInTable(MB_myStalaggHEALERS) or myName == MB_myStalaggOffTank then
        data = {
            tank = MB_myStalaggMainTank,
            off = MB_myStalaggOffTank,
            side = "Stalagg"
        }
    end

    local closestTankId = MBID[data.tank]
    if not closestTankId then
        CdRaidWarning(">> You Don't Have Enough Side Tanks! <<")
        return false
    end

    if UnitInRange(closestTankId) then
        return closestTankId
    else
        local offTankId = MBID[data.off]
        if offTankId and UnitInRange(offTankId) then
            return offTankId
        end

        local oppositeTank
        if data.side == "Feugen" then
            oppositeTank = MB_myStalaggMainTank
        elseif data.side == "Stalagg" then
            oppositeTank = MB_myFeugenMainTank
        end

        local oppositeTankId = MBID[oppositeTank]
        if oppositeTankId and UnitInRange(oppositeTankId) then
            return oppositeTankId
        else
            CdAddonMessage(MB_RAID.."THADDIUS_EMERGENCY", data.side)
            return false
        end
    end
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local function UseNaturePotsOnThaddius()
    if not MB_myThaddiusNaturePotStrategy then
        return
    end

    if ImBusy() or not InCombat("player") then
		return
	end

    TakePotionsWhenPossible("Greater Nature Protection Potion")
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function THAD_IsAtThaddius()
	if TargetFromSpecificPlayer("Stalagg", MB_myStalaggMainTank) then
		return true
	end

    if TargetFromSpecificPlayer("Stalagg", MB_myStalaggOffTank) then
		return true
	end

	if TargetFromSpecificPlayer("Feugen", MB_myFeugenMainTank) then
		return true
	end

    if TargetFromSpecificPlayer("Feugen", MB_myFeugenOffTank) then
		return true
	end

	if (TankTarget("Stalagg") or TankTarget("Feugen")) then
		return true
	end

	local tName = UnitName("target")
	if not tName then
		return false
	end

	if (tName == "Stalagg" or tName == "Feugen") then
		return true
	end

	return false
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function THAD:OnEvent()
	if (event == "CHAT_MSG_ADDON") then
        if (arg1 == MB_RAID.."THADDIUS_EMERGENCY") then     
            CdRaidWarning(">> "..arg2.." Side Tank Emergency! <<")    
        end
    end
end

THAD:SetScript("OnEvent", THAD.OnEvent) 

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function THAD_TargetingPreFocus()
	if THAD_IsAtThaddius() and MB_myThaddiusBoxStrategy then
        if (myName == MB_myFeugenMainTank or myName == MB_myFeugenOffTank) and MB_raidLeader ~= myName then
            MB_raidLeader = myName
        end

        if (myName == MB_myStalaggMainTank or myName == MB_myStalaggOffTank) and MB_raidLeader ~= myName then
            MB_raidLeader = myName
        end

        if not ImFocus() then
            return false
        end

        if (myName == MB_myFeugenMainTank or myName == MB_myFeugenOffTank) then            
            if not MB_targetNearestDistanceChanged then                
                SetCVar("targetNearestDistance", "15")
                MB_targetNearestDistanceChanged = true
            end

            if MB_razorgoreNewTargetBecauseTargetIsBehind.Active then            
                TargetNearestEnemy()
                MB_razorgoreNewTargetBecauseTargetIsBehind.Active = false
                return true
            end

            if (tName == nil or Dead("target")) then                
                TargetNearestEnemy()
                return true
            end
            return true
        end

        if (myName == MB_myStalaggMainTank or myName == MB_myStalaggOffTank) then            
            if not MB_targetNearestDistanceChanged then                
                SetCVar("targetNearestDistance", "15")
                MB_targetNearestDistanceChanged = true
            end

            if MB_razorgoreNewTargetBecauseTargetIsBehind.Active then            
                TargetNearestEnemy()
                MB_razorgoreNewTargetBecauseTargetIsBehind.Active = false
                return true
            end

            if (tName == nil or Dead("target")) then                
                TargetNearestEnemy()
                return true
            end
            return true
        end
    end

    return false
end

function THAD_TargetingPostFocus()
	if THAD_IsAtThaddius() and MB_myThaddiusBoxStrategy then

        if (myName == MB_myFeugenMainTank or myName == MB_myFeugenOffTank) then            
            if not MB_targetNearestDistanceChanged then                
                SetCVar("targetNearestDistance", "15")
                MB_targetNearestDistanceChanged = true
            end

            if MB_razorgoreNewTargetBecauseTargetIsBehind.Active then            
                TargetNearestEnemy()
                MB_razorgoreNewTargetBecauseTargetIsBehind.Active = false
                return true
            end

            if (tName == nil or Dead("target")) then                
                TargetNearestEnemy()
                return true
            end
            return true

        elseif (myName == MB_myStalaggMainTank or myName == MB_myStalaggOffTank) then            
            if not MB_targetNearestDistanceChanged then                
                SetCVar("targetNearestDistance", "15")
                MB_targetNearestDistanceChanged = true
            end

            if MB_razorgoreNewTargetBecauseTargetIsBehind.Active then            
                TargetNearestEnemy()
                MB_razorgoreNewTargetBecauseTargetIsBehind.Active = false
                return true
            end

            if (tName == nil or Dead("target")) then                
                TargetNearestEnemy()
                return true
            end
            return true
        
        elseif ImTank() then
            if not MB_targetNearestDistanceChanged then						
				SetCVar("targetNearestDistance", "10")
				MB_targetNearestDistanceChanged = true
			end

			mb_getTargetNotOnTank()
			return true

        elseif ImRangedDPS() then
            if MyNameInTable(MB_myFeugenDPSERS) then
                if LockOnTarget("Feugen") then
                    return true
                end
			end

			if MyNameInTable(MB_myStalaggDPSERS) then
                if LockOnTarget("Stalagg") then
                    return true
                end
			end
            return true

        elseif ImMeleeDPS() then
            if MyNameInTable(MB_myFeugenDPSERS) then
                if LockOnTarget("Feugen") then
                    return true
                end
			end

			if MyNameInTable(MB_myStalaggDPSERS) then
                if LockOnTarget("Stalagg") then
                    return true
                end
			end
            return true
        end
    end

    return false
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function THAD_IsFollowThaddius()
    if THAD_IsAtThaddius() and MB_myThaddiusBoxStrategy then
        local closestTankId = GetClosestMainTankForSide()

        if closestTankId then
            FollowUnit(closestTankId)
        end

        return true
    end
end