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
local InMeleeRange = mb_inMeleeRange
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
        "PLAYER_REGEN_ENABLED",
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
MB_myThaddiusBoxStrategy = true 
MB_myThaddiusNaturePotStrategy = true
MB_myThaddiusSlowFallPotStrategy = true

-- Tank & DPS Assignments (REQUIRED) PHASE 1
MB_myStalaggMainTank = "Kungen"

MB_myStalaggDPSERS = {
    -- Mages
    "Nyktheus",
    "Drogles",
    "Kelseran",
    "Oxg",
    "Hypernewb",
    "Schoffie",
    "Mizea",
    "Umek",
    "Bluedabadee",

    -- Fire
    "Faithzy",
    "Trinali",

    -- Warlock
    "Ayaag"
}

local MB_myStalaggHEALERS = {
    -- Shaman
    "Hurtek",
    "Slaver",
    "Chimando",
    "Lillifee",

    -- Priest
    "Blaidzy",

    -- Druid
    "Maxvoldson"
}

MB_myFeugenMainTank = "Tyamies"

MB_myFeugenDPSERS = {
    -- Mages
    "Damacon",
    "Xlimidrizer",
    "Grimpeh",
    "Alionex",
    "Nofreewater",
    "Merkan",
    "Ykani",
    "Salka",
    "Frostoni",

    -- Fire
    "Thehatter",
    "Rotonic",

    -- Warlock
    "Akaaka"
}

local MB_myFeugenHEALERS = {
    -- Shaman
    "Shamuk",
    "Rockon",
    "Mvenna",
    "Shaitan",

    -- Priest
    "Liket",

    -- Druid
    "Pyqmi"
}

-- Tank & DPS Assignments (REQUIRED) PHASE 2
MB_myThaddiusMainTank = "Moron"

local MB_myThaddiusHEALERS = {
    -- Priest
    "Midavellir",
    "Cyal",
    "Bonita"
}

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local function GetClosestMainTankForSide()
    local data = { tank = nil, off = nil, side = nil }

    if MyNameInTable(MB_myFeugenDPSERS) or MyNameInTable(MB_myFeugenHEALERS) then
        data = {
            tank = MB_myFeugenMainTank,
            off = MB_myStalaggMainTank,
            side = "Feugen"
        }
    end

    if MyNameInTable(MB_myStalaggDPSERS) or MyNameInTable(MB_myStalaggHEALERS) then
        data = {
            tank = MB_myStalaggMainTank,
            off = MB_myFeugenMainTank,
            side = "Stalagg"
        }
    end

    if MyNameInTable(MB_myThaddiusHEALERS) then
        data = {
            tank = MB_myThaddiusMainTank,
            off = MB_myThaddiusMainTank,
            side = "Thaddius"
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
            CdAddonMessage(MB_RAID.."THADDIUS_TRANSITION", data.off)
            return offTankId
        else
            CdAddonMessage(MB_RAID.."THADDIUS_EMERGENCY", data.side)
            return false
        end
    end
end

local function CheckThaddiusHealersSlowFall()
    if MyNameInTable(MB_myThaddiusHEALERS) then
        for i, healerName in pairs(MB_myThaddiusHEALERS) do
            if not mb_hasBuffOrDebuff("Slow Fall", MBID[healerName], "buff") then
                return false
            end
        end

        CdAddonMessage(MB_RAID.."THADDIUS_HEALERS_SLOWFALL", "ALL_READY")
        return true
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

local function UseSlowFallPotsOnThaddius()
    if not MB_myThaddiusSlowFallPotStrategy then
        return
    end

    if ImBusy() or not InCombat("player") then
		return
	end

    if not mb_haveInBags("Noggenfogger Elixir") and not mb_isItemInBagCoolDown("Noggenfogger Elixir") then
        return
    end

    CheckThaddiusHealersSlowFall()

    if mb_hasBuffOrDebuff("Slow Fall", "player", "buff") then
        return
    end

    if mb_isDruidShapeShifted() then
        return
    end

    CancelBuff("Noggenfogger Elixir")

    if (potTimer == nil or GetTime() - potTimer > 3) then
        potTimer = GetTime()
        mb_useFromBags("Noggenfogger Elixir")
    end
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local THAD_PHASE_1_ACTIVE = false
local THAD_PHASE_2_ACTIVE = false

function THAD_IsAtThaddiusP1()
    if THAD_PHASE_1_ACTIVE then
        UseSlowFallPotsOnThaddius()
        UseNaturePotsOnThaddius()
        return true
    end

    local inP1 = false    
    if TargetFromSpecificPlayer("Stalagg", MB_myStalaggMainTank) then
        inP1 = true
    elseif TargetFromSpecificPlayer("Feugen", MB_myFeugenMainTank) then
        inP1 = true
    elseif (TankTarget("Stalagg") or TankTarget("Feugen")) then
        inP1 = true
    else
        local tName = UnitName("target")
        if tName and (tName == "Stalagg" or tName == "Feugen") then
            inP1 = true
        end
    end

    if inP1 then
        CdAddonMessage(MB_RAID.."THADDIUS_PHASE1", "ENGAGE", 30)
        THAD_PHASE_1_ACTIVE = true
        return true
    end

	return THAD_PHASE_1_ACTIVE
end

function THAD_IsAtThaddiusP2()
    if THAD_PHASE_2_ACTIVE then
        UseNaturePotsOnThaddius()
        return true
    end

    local inP2 = false    
    if TargetFromSpecificPlayer("Thaddius", MB_myThaddiusMainTank) then
        inP2 = true
    elseif TargetFromSpecificPlayer("Thaddius", MB_myStalaggMainTank) then
        inP2 = true
    elseif TargetFromSpecificPlayer("Thaddius", MB_myFeugenMainTank) then
        inP2 = true
    elseif TankTarget("Thaddius") then
        inP2 = true
    else
        local tName = UnitName("target")
        if tName and tName == "Thaddius" then
            inP2 = true
        end
    end

    if inP2 then
        CdAddonMessage(MB_RAID.."THADDIUS_PHASE2", "ENGAGE", 30)
        THAD_PHASE_2_ACTIVE = true
        return true
    end

	return THAD_PHASE_2_ACTIVE
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function THAD:OnEvent()
	if (event == "CHAT_MSG_ADDON") then
        if (arg1 == MB_RAID.."THADDIUS_EMERGENCY") then     
            CdRaidWarning(">> "..arg2.." Side Tank Emergency! <<")  

        elseif (arg1 == MB_RAID.."THADDIUS_TRANSITION") then    
            CdRaidWarning(">> "..arg2.." Is Follow Tank! <<")  

        elseif (arg1 == MB_RAID.."THADDIUS_HEALERS_SLOWFALL") then
            if (arg2 == "ALL_READY") then
                CdRaidWarning(">> All Thaddius Healers Have Slow Fall! <<")
            end

        elseif (arg1 == MB_RAID.."THADDIUS_PHASE1") then
            if (arg2 == "ENGAGE") then
                CdRaidWarning(">> Thaddius Phase 1 <<")  
                THAD_PHASE_1_ACTIVE = true
                THAD_PHASE_2_ACTIVE = false
            end
        elseif (arg1 == MB_RAID.."THADDIUS_PHASE2") then
            if (arg2 == "ENGAGE") then
                CdRaidWarning(">> Thaddius Phase 2 <<")
                THAD_PHASE_1_ACTIVE = false
                THAD_PHASE_2_ACTIVE = true
            end
        end

    elseif (event == "PLAYER_REGEN_ENABLED") then
        THAD_PHASE_1_ACTIVE = false
        THAD_PHASE_2_ACTIVE = false
    end
end

THAD:SetScript("OnEvent", THAD.OnEvent) 

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function THAD_TargetingPreFocus()
    local tName = UnitName("target")

	if THAD_IsAtThaddiusP1() and MB_myThaddiusBoxStrategy then
        if (myName == MB_myFeugenMainTank or myName == MB_myStalaggMainTank) and MB_raidLeader ~= myName then
            MB_raidLeader = myName
        end

        if not ImFocus() then
            return false
        end

        if (myName == MB_myFeugenMainTank or myName == MB_myStalaggMainTank) then
            if not MB_targetNearestDistanceChanged then                
                SetCVar("targetNearestDistance", "15")
                MB_targetNearestDistanceChanged = true
            end

            if tName == nil or Dead("target") or not InMeleeRange() then
                TargetNearestEnemy()
            end
            return true
        end
    end

    return false
end

function THAD_TargetingPostFocus()
    local tName = UnitName("target")

    if THAD_IsAtThaddiusP2() and MB_myThaddiusBoxStrategy then
        if LockOnTarget("Thaddius") then
            return true
        end

        if not tName or Dead("target") then
            AssistFocus()
        end
        return true

	elseif THAD_IsAtThaddiusP1() and MB_myThaddiusBoxStrategy then
        if (myName == MB_myFeugenMainTank or myName == MB_myStalaggMainTank) then           
            if not MB_targetNearestDistanceChanged then                
                SetCVar("targetNearestDistance", "15")
                MB_targetNearestDistanceChanged = true
            end

            if (tName == nil or Dead("target") or not InMeleeRange()) then                 
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

        elseif ImRangedDPS() or ImMeleeDPS() or ImHealer() then
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
    if THAD_IsAtThaddiusP1() and MB_myThaddiusBoxStrategy then
        local closestTankId = GetClosestMainTankForSide()

        if closestTankId then
            FollowUnit(closestTankId)
        end

        return true
    end
end

function THAD_IsFollowThaddiusHealers()
    if THAD_IsAtThaddiusP1() and MB_myThaddiusBoxStrategy then
        local closestTankId = MBID[MB_myThaddiusMainTank]
        if closestTankId and MyNameInTable(MB_myThaddiusHEALERS) then
            FollowUnit(closestTankId)
            return true
        end
    end
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function THAD_WarlockCurseP1()
    if THAD_IsAtThaddiusP1() and MB_myThaddiusBoxStrategy then
        if MyNameInTable(MB_myFeugenDPSERS) or MyNameInTable(MB_myStalaggDPSERS) then
            if HasBuffOrDebuff("Curse of the Elements", "target", "debuff") then
                CastSpellByName("Curse of the Elements")
                return true
            end
        end
    end
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local PolarityState = { Current = "NONE", Previous = "NONE", Position = "HOME" }
local THAD_POLARITY = CreateFrame("Button", "THAD_POLARITY", UIParent)

do
    for _, event in {
        "UNIT_AURA",
        "PLAYER_AURAS_CHANGED"
    } do
        THAD_POLARITY:RegisterEvent(event)
    end
end

local function GetCurrentPlatform()
    local leftMembers = {}
    table.insert(leftMembers, MB_myStalaggMainTank)
    for _, n in ipairs(MB_myStalaggDPSERS) do table.insert(leftMembers, n) end
    for _, n in ipairs(MB_myStalaggHEALERS) do table.insert(leftMembers, n) end

    local rightMembers = {}
    table.insert(rightMembers, MB_myFeugenMainTank)
    for _, n in ipairs(MB_myFeugenDPSERS) do table.insert(rightMembers, n) end
    for _, n in ipairs(MB_myFeugenHEALERS) do table.insert(rightMembers, n) end

    if MyNameInTable(leftMembers) then
        return "LEFT"
    elseif MyNameInTable(rightMembers) then
        return "RIGHT"
    end
    return "CENTER"
end

local negativeKeybinds = {
    ["LEFT"] = "STRAFELEFT",
    ["RIGHT"] = "STRAFERIGHT",
}

local positiveKeybinds = {
    ["LEFT"] = "STRAFERIGHT",
    ["RIGHT"] = "STRAFELEFT",
}

local function ApplySecondaryBind()
    local platform = GetCurrentPlatform()
    local currentDebuff = PolarityState.Current
    local previousDebuff = PolarityState.Previous
    local currentPosition = PolarityState.Position

    if currentDebuff == "NEGATIVE" then
        SetBinding("SHIFT-H", negativeKeybinds[platform])
        PolarityState.Position = "AWAY"
        
    elseif currentDebuff == "POSITIVE" then
        if previousDebuff == "NEGATIVE" and currentPosition == "AWAY" then
            SetBinding("SHIFT-H", positiveKeybinds[platform])
            PolarityState.Position = "RETURNING"
        else
            SetBinding("SHIFT-H", nil)
            PolarityState.Position = "HOME"
        end
    else
        SetBinding("SHIFT-H", nil)
        PolarityState.Position = "HOME"
    end
end

function THAD_POLARITY:OnEvent()
    if (event == "UNIT_AURA" and arg1 == "player" and not Dead("player")) then
        PolarityState.Previous = PolarityState.Current

        if HasBuffOrDebuff("Negative Charge", "player", "debuff") then
            PolarityState.Current = "NEGATIVE"
            ApplySecondaryBind()
        elseif HasBuffOrDebuff("Positive Charge", "player", "debuff") then
            PolarityState.Current = "POSITIVE"
            ApplySecondaryBind()
        else
            PolarityState.Current = "NONE"
            ApplySecondaryBind()
        end
    end
end

THAD_POLARITY:SetScript("OnEvent", THAD_POLARITY.OnEvent)
