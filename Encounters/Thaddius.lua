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
local HealthPct = mb_healthPct
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
    "Grimpeh",
    "Alionex",
    "Xlimidrizer",
    "Damacon",
    "Rotonic",
    "Salka",
    "Thehatter",
    "Schoffie",
    "Mizea",
    "Merkan",

    -- Warlock
    "Akaaka"
}

local MB_myStalaggHEALERS = {
    -- Shaman
    "Healdazor",
    "Shaitan",
    "Bayo",

    -- Priest
    "Liket",

    -- Druid
    "Pyqmi",
    "Kugal"
}

MB_myFeugenMainTank = "Tyamies"

MB_myFeugenDPSERS = {
    -- Mages
    "Dogles",
    "Kelseran",
    "Oxg",
    "Drogles",
    "Nyktheus",
    "Umek",
    "Trinali",
    "Faithzy",
    "Hypernewb",
    "Ykani",
    "Nofreewater",

    -- Warlock
    "Ayaag"
}

local MB_myFeugenHEALERS = {
    -- Shaman
    "Mvenna",
    "Chimando",

    -- Priest
    "Blaidzy",
    "Draub",

    -- Druid
    "Maxvoldson",
    "Smalheal"
}

-- Tank & DPS Assignments (REQUIRED) PHASE 2
MB_myThaddiusMainTank = "Moron"
MB_myThaddiusMainPriest = "Midavellir"

local MB_myThaddiusHEALERS = {
    -- Shaman
    "Lillifee",

    -- Priest
    MB_myThaddiusMainPriest,
    "Ayag"
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
    local healerList = {}
    table.insert(healerList, MB_myThaddiusMainTank)
    for _, n in ipairs(MB_myThaddiusHEALERS) do table.insert(healerList, n) end

    if MyNameInTable(healerList) then
        if myName == MB_myThaddiusMainPriest and not MB_myAssignedHealTarget then
            MB_myAssignedHealTarget = MB_myThaddiusMainTank
        end

        for i, healerName in pairs(healerList) do
            if not mb_hasBuffOrDebuff("Slow Fall", MBID[healerName], "buff") then
                return false
            end
        end

        CdAddonMessage(MB_RAID.."THADDIUS_HEALERS_SLOWFALL", "ALL_READY", 500)
        return true
    end

    if myName == MB_myStalaggMainTank then
        local tankId = MBID[MB_myStalaggMainTank]
        if not mb_hasBuffOrDebuff("Slow Fall", tankId, "buff") then
            CdPrint("WARNING: MANUAL JUMP NEEDED!")
        end
    elseif myName == MB_myFeugenMainTank then
        local tankId = MBID[MB_myFeugenMainTank]
        if not mb_hasBuffOrDebuff("Slow Fall", tankId, "buff") then
            CdPrint("WARNING: MANUAL JUMP NEEDED!")
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

    if ImTank() then
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

    if (myName == MB_myStalaggMainTank or myName == MB_myFeugenMainTank) 
        and HealthPct("target") > 0.1 then
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

local function CheckClosestHealerDebuff()
    if not ImFocus() then
        return
    end
    
    local mainTankDebuff = "NONE"
    if mb_hasBuffOrDebuff("Negative Charge", MBID[MB_myThaddiusMainTank], "buff") then
        mainTankDebuff = "Negative Charge"
    elseif mb_hasBuffOrDebuff("Positive Charge", MBID[MB_myThaddiusMainTank], "buff") then
        mainTankDebuff = "Positive Charge"
    end
    
    local mainTankHealerDebuff = "NONE"
    if mb_hasBuffOrDebuff("Negative Charge", MBID[MB_myThaddiusMainPriest], "buff") then
        mainTankHealerDebuff = "Negative Charge"
    elseif mb_hasBuffOrDebuff("Positive Charge", MBID[MB_myThaddiusMainPriest], "buff") then
        mainTankHealerDebuff = "Positive Charge"
    end

    if mainTankDebuff == "NONE" and mainTankHealerDebuff == "NONE" then
        return
    end

    if mainTankDebuff == mainTankHealerDebuff then
        SetRaidTarget(MBID[MB_myThaddiusMainPriest], 1)
    else
        SetRaidTarget(MBID[MB_myThaddiusMainPriest], 8)
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
        CheckClosestHealerDebuff()
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

            elseif (arg2 == "AWAIT_NUKE") then
                CdRaidWarning(">> WRONG TANK ON PLATFORM <<") 

            elseif (arg2 == "NUKE_PLATFORM") then
                CdRaidWarning(">> NUKE PLATFORM <<") 
            end

        elseif (arg1 == MB_RAID.."THADDIUS_PHASE2") then
            if (arg2 == "ENGAGE") then
                CdRaidWarning(">> Thaddius Phase 2 - Position Casters <<")
                THAD_PHASE_1_ACTIVE = false
                THAD_PHASE_2_ACTIVE = true
            
            elseif (arg2 == "POLARITY_MOVE") then
                CdRaidWarning(">> MOVE NOW <<")
            end
        end

    elseif (event == "PLAYER_REGEN_ENABLED") then
        THAD_PHASE_1_ACTIVE = false
        THAD_PHASE_2_ACTIVE = false
        THAD_ResetBossSync()
    end
end

THAD:SetScript("OnEvent", THAD.OnEvent) 

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local function GetPlatformBossHealthPct(mobName)
    local members = {}
    if not mobName then
        return
    end
    if mobName == "Feugen" then
        members = MB_myFeugenDPSERS
    elseif mobName == "Stalagg" then
        members = MB_myStalaggDPSERS
    end
    local lowestHp = nil
    for _, playerName in ipairs(members) do
        local playerId = MBID[playerName]
        if playerId and mb_targetFromSpecificPlayer(mobName, playerName) then
            local hp = HealthPct(playerId.."target")
            if not lowestHp or hp < lowestHp then
                lowestHp = hp
            end
        end
    end
    return lowestHp or 1.0
end

-- Global state for synchronization
SyncState = {
    WaitThreshold = 0.25,    -- Start waiting when either hits 25%
    ResumeThreshold = 0.20,  -- Resume when both are at 20%
    FeugenWaiting = false,   -- Track each mob's waiting state separately
    StalaggWaiting = false,
    LastCheck = 0            -- Prevent spam
}

local function CanDPSMob(mobName)
    local feugenHp = GetPlatformBossHealthPct("Feugen")
    local stalaggHp = GetPlatformBossHealthPct("Stalagg")
    
    -- Debug output (limit spam)
    local currentTime = GetTime() or 0
    if currentTime - SyncState.LastCheck > 1 then
        CdPrint("Feugen HP: " .. (feugenHp and string.format("%.1f%%", feugenHp*100) or "nil") .. 
                ", Stalagg HP: " .. (stalaggHp and string.format("%.1f%%", stalaggHp*100) or "nil"))
        SyncState.LastCheck = currentTime
    end
    
    if not feugenHp or not stalaggHp then
        return false
    end
    
    -- Determine if each mob should be waiting
    local feugenShouldWait = feugenHp <= SyncState.WaitThreshold and stalaggHp > SyncState.ResumeThreshold
    local stalaggShouldWait = stalaggHp <= SyncState.WaitThreshold and feugenHp > SyncState.ResumeThreshold
    
    -- Update waiting states
    SyncState.FeugenWaiting = feugenShouldWait
    SyncState.StalaggWaiting = stalaggShouldWait
    
    -- Allow DPS if:
    -- 1. Both mobs are above wait threshold (normal phase)
    -- 2. Both mobs are at or below resume threshold (synchronized kill phase)
    -- 3. This specific mob is not in waiting state
    
    if feugenHp > SyncState.WaitThreshold and stalaggHp > SyncState.WaitThreshold then
        -- Normal DPS phase - both above threshold
        return true
    elseif feugenHp <= SyncState.ResumeThreshold and stalaggHp <= SyncState.ResumeThreshold then
        -- Synchronized kill phase - both ready
        if currentTime - SyncState.LastCheck > 1 then
            CdPrint("SYNCHRONIZED KILL PHASE - Both mobs ready!")
        end
        return true
    else
        -- Waiting phase - check if THIS mob should wait
        if mobName == "Feugen" and SyncState.FeugenWaiting then
            if currentTime - SyncState.LastCheck > 1 then
                CdPrint("Feugen WAITING for Stalagg to catch up")
            end
            return false
        elseif mobName == "Stalagg" and SyncState.StalaggWaiting then
            if currentTime - SyncState.LastCheck > 1 then
                CdPrint("Stalagg WAITING for Feugen to catch up")
            end
            return false
        else
            -- This mob is not waiting, continue DPS
            return true
        end
    end
end

-- Reset function for encounter start
function THAD_ResetBossSync()
    SyncState.FeugenWaiting = false
    SyncState.StalaggWaiting = false
    SyncState.LastCheck = 0
    CdPrint("Boss sync state RESET")
end

function THAD_TargetingPreFocus()
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

            if myName == MB_myFeugenMainTank then
                if tName == "Feugen" then
                    if HealthPct("target") <= 0.1 then
                        CdAddonMessage(MB_RAID.."THADDIUS_PHASE1", "NUKE_PLATFORM", 30)
                    end
                elseif tName == "Stalagg" then
                    if HealthPct("target") <= 0.1 then
                        CdAddonMessage(MB_RAID.."THADDIUS_PHASE1", "AWAIT_NUKE", 30)
                    end
                end
            end

            if myName == MB_myStalaggMainTank then
                if tName == "Stalagg" then
                    if HealthPct("target") <= 0.1 then
                        CdAddonMessage(MB_RAID.."THADDIUS_PHASE1", "NUKE_PLATFORM", 30)
                    end
                elseif tName == "Feugen" then
                    if HealthPct("target") <= 0.1 then
                        CdAddonMessage(MB_RAID.."THADDIUS_PHASE1", "AWAIT_NUKE", 30)
                    end
                end
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
                if CanDPSMob("Feugen") and LockOnTarget("Feugen") then
                    return true
                end
            end

            if MyNameInTable(MB_myStalaggDPSERS) then
                if CanDPSMob("Stalagg") and LockOnTarget("Stalagg") then
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

local THAD_POLARITY = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0")

local NEGATIVE_KEYBINDS = { ["LEFT"] = "STRAFELEFT", ["RIGHT"] = "STRAFERIGHT" }
local POSITIVE_KEYBINDS = { ["LEFT"] = "STRAFERIGHT", ["RIGHT"] = "STRAFELEFT" }

local POSITIVE_TEXTURE = "Interface\\Icons\\Spell_ChargePositive"
local NEGATIVE_TEXTURE = "Interface\\Icons\\Spell_ChargeNegative"

local PolarityState = { Current = "NONE", Position = "HOME", Window = false }

local function GetCurrentPlatform()
    local leftMembers = {}
    table.insert(leftMembers, MB_myStalaggMainTank)

    for _, n in ipairs(MB_myStalaggDPSERS) do
        table.insert(leftMembers, n)
    end

    for _, n in ipairs(MB_myStalaggHEALERS) do
        table.insert(leftMembers, n)
    end

    local rightMembers = {}
    table.insert(rightMembers, MB_myFeugenMainTank)

    for _, n in ipairs(MB_myFeugenDPSERS) do 
        table.insert(rightMembers, n)
    end

    for _, n in ipairs(MB_myFeugenHEALERS) do
        table.insert(rightMembers, n)
    end

    if MyNameInTable(leftMembers) then
        return "LEFT"
    elseif MyNameInTable(rightMembers) then
        return "RIGHT"
    else
        return "CENTER"
    end
end

local function GetPolarityFromAuras()
    local iIterator = 1
    while UnitDebuff("player", iIterator) do
        local texture, applications = UnitDebuff("player", iIterator)
        if texture == POSITIVE_TEXTURE or texture == NEGATIVE_TEXTURE then
            if applications and applications > 1 then
                return nil
            end
            return texture
        end

        iIterator = iIterator + 1
    end
    return nil
end

local function ApplySecondaryBind()
    local platform = GetCurrentPlatform()
    local data = {
        current = PolarityState.Current,
        position = PolarityState.Position
    }

    if data.current == "NEGATIVE" then
        if data.position ~= "AWAY" then
            -- If we're not already AWAY, set position AWAY
            -- Change keybinds, to move away.
            PolarityState.Position = "AWAY"
            SetBinding("SHIFT-W", NEGATIVE_KEYBINDS[platform])
            CdAddonMessage(MB_RAID.."THADDIUS_PHASE2", "POLARITY_MOVE", 10)
        else
            -- Only when we ARE not returning, reset keybinds
            -- ALso includes if we are already away, reset keybinds
            SetBinding("SHIFT-W", nil)
        end

    elseif data.current == "POSITIVE" then
        if data.position == "AWAY" then
            -- If we're already AWAY, set position RETURNING
            -- Change keybinds, to return.
            PolarityState.Position = "RETURNING"
            SetBinding("SHIFT-W", POSITIVE_KEYBINDS[platform])
            CdAddonMessage(MB_RAID.."THADDIUS_PHASE2", "POLARITY_MOVE", 10)
        else
            -- Only when we ARE not away, reset keybinds
            -- ALso includes if we are already returning, reset keybinds
            SetBinding("SHIFT-W", nil)
        end
    end
end

local function CheckPolarityAuras()
    if not PolarityState.Window then
        return
    end
    
    local chargeType = GetPolarityFromAuras()
    if not chargeType then
        return
    end
    
    THAD_POLARITY:UnregisterEvent("PLAYER_AURAS_CHANGED")
    PolarityState.Window = false
    
    local newState = "NONE"
    if chargeType == NEGATIVE_TEXTURE then
        newState = "NEGATIVE"
    elseif chargeType == POSITIVE_TEXTURE then
        newState = "POSITIVE"
    end
    
    if newState ~= PolarityState.Current then
        PolarityState.Current = newState
    end

    ApplySecondaryBind()
end

function THAD_POLARITY:OnInitialize()
    self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
    self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE")
    self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF")
end

function THAD_POLARITY:CloseWindow()
    if PolarityState.Window then
        PolarityState.Window = false
        self:UnregisterEvent("PLAYER_AURAS_CHANGED")
    end
end

function THAD_POLARITY:CHAT_MSG_MONSTER_YELL()
    if string.find(arg1 or "", "Now YOU feel pain") then
        PolarityState.Window = true
        self:RegisterEvent("PLAYER_AURAS_CHANGED")
        self:ScheduleEvent("PolarityWindowClose", self.CloseWindow, 6, self)
    end
end

function THAD_POLARITY:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE()
    if string.find(arg1 or "", "begins to cast Polarity Shift") then
        PolarityState.Window = true
        self:RegisterEvent("PLAYER_AURAS_CHANGED")
        self:ScheduleEvent("PolarityWindowClose", self.CloseWindow, 3, self)
    end
end

function THAD_POLARITY:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF()
    if string.find(arg1 or "", "begins to cast Polarity Shift") then
        PolarityState.Window = true
        self:RegisterEvent("PLAYER_AURAS_CHANGED")
        self:ScheduleEvent("PolarityWindowClose", self.CloseWindow, 3, self)
    end
end

function THAD_POLARITY:PLAYER_AURAS_CHANGED()
    CheckPolarityAuras()
end

THAD_POLARITY:OnInitialize()
