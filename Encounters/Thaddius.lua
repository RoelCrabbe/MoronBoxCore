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
local LockOnTarget = mb_lockOnTarget
local MyNameInTable = mb_myNameInTable
local TakePotionsWhenPossible = mb_takePotionsWhenPossible
local TankTarget = mb_tankTarget
local TankTargetHealth = mb_tankTargetHealth
local TargetFromSpecificPlayer = mb_targetFromSpecificPlayer
local UnitInRange = mb_unitInRange
local UseFromBags = mb_useFromBags

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

-- Tank & DPS Assignments (REQUIRED) PHASE 1 - Left Side
local MB_myStalaggMainTank = "Kungen"

local MB_myStalaggDPSERS = {
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
    "Lillifee",
    "Shaitan",
    "Bayo",

    -- Priest
    "Liket",

    -- Druid
    "Pyqmi",
    "Kugal"
}

-- Tank & DPS Assignments (REQUIRED) PHASE 1 - Right Side
local MB_myFeugenMainTank = "Tyamies"

local MB_myFeugenDPSERS = {
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
local MB_myThaddiusMainTank = "Moron"
local MB_myThaddiusMainPriest = "Midavellir"

local MB_myThaddiusHEALERS = {
    -- Shaman
    "Shamuk",

    -- Priest
    MB_myThaddiusMainPriest,
    "Ayag"
}

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local function GetClosestMainTankForSide()
    if (myName == MB_myThaddiusMainTank or myName == MB_myFeugenMainTank or myName == MB_myStalaggMainTank) then
        return false
    end

    local data
    if MyNameInTable(MB_myFeugenDPSERS) or MyNameInTable(MB_myFeugenHEALERS) then
        data = { tank = MB_myFeugenMainTank, off = MB_myStalaggMainTank, side = "Feugen" }
    elseif MyNameInTable(MB_myStalaggDPSERS) or MyNameInTable(MB_myStalaggHEALERS) then
        data = { tank = MB_myStalaggMainTank, off = MB_myFeugenMainTank, side = "Stalagg" }
    elseif MyNameInTable(MB_myThaddiusHEALERS) then
        data = { tank = MB_myThaddiusMainTank, off = MB_myThaddiusMainTank, side = "Thaddius" }
    else
        CdMessage(">> Could not determine side! <<")
        return false
    end

    local closestTankId = MBID[data.tank]
    if not closestTankId then
        CdRaidWarning(">> You Don't Have Enough Side Tanks! <<")
        return false
    end

    if UnitInRange(closestTankId) then
        return closestTankId
    end

    local offTankId = MBID[data.off]
    if offTankId and UnitInRange(offTankId) then
        CdAddonMessage(MB_RAID.."THADDIUS_TRANSITION", data.off)
        return offTankId
    end

    CdAddonMessage(MB_RAID.."THADDIUS_EMERGENCY", data.side)
    return false
end

local function CheckThaddiusHealersSlowFall()
    local healerList = {}
    table.insert(healerList, MB_myThaddiusMainTank)

    for _, n in ipairs(MB_myThaddiusHEALERS) do
        table.insert(healerList, n)
    end

    if MyNameInTable(healerList) then
        if myName == MB_myThaddiusMainPriest and not MB_myAssignedHealTarget then
            MB_myAssignedHealTarget = MB_myThaddiusMainTank
        end

        for i, healerName in pairs(healerList) do
            if not HasBuffOrDebuff("Slow Fall", MBID[healerName], "buff") then
                return false
            end
        end

        CdAddonMessage(MB_RAID.."THADDIUS_HEALERS_SLOWFALL", "ALL_READY", 500)
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

    if ImTank() then
        return
    end

    TakePotionsWhenPossible("Greater Nature Protection Potion")
end

local function UseSlowFallPotsOnThaddiusP1()
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

    if not HaveInBags("Noggenfogger Elixir") and not IsItemInBagCoolDown("Noggenfogger Elixir") then
        return
    end

    CheckThaddiusHealersSlowFall()

    if HasBuffOrDebuff("Slow Fall", "player", "buff") then
        return
    end

    if IsDruidShapeShifted() then
        return
    end

    CancelBuff("Noggenfogger Elixir")

    if (potTimer == nil or GetTime() - potTimer > 3) then
        potTimer = GetTime()
        UseFromBags("Noggenfogger Elixir")
    end
end

local function GetChargeDebuff(unitId)
    if HasBuffOrDebuff("Negative Charge", unitId, "debuff") then
        return "Negative Charge"
    elseif HasBuffOrDebuff("Positive Charge", unitId, "debuff") then
        return "Positive Charge"
    end
    return "NONE"
end

local function CheckClosestHealerDebuff()
    if not ImFocus() then
        return
    end

    local mainTankId = MBID[MB_myThaddiusMainTank]
    local mainTankHealerId = MBID[MB_myThaddiusMainPriest]
    if not mainTankId or not mainTankHealerId then
        return
    end

    local mainTankDebuff = GetChargeDebuff(mainTankId)
    local mainTankHealerDebuff = GetChargeDebuff(mainTankHealerId)

    if mainTankDebuff == "NONE" and mainTankHealerDebuff == "NONE" then
        return
    end

    local desiredMark = (mainTankDebuff == mainTankHealerDebuff) and 1 or 8
    if GetRaidTargetIndex(mainTankHealerId) ~= desiredMark then
        SetRaidTarget(mainTankHealerId, desiredMark)
    end
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local THAD_PHASE_1_ACTIVE = false
local THAD_PHASE_2_ACTIVE = false

function THAD_IsAtThaddiusP1()
    if THAD_PHASE_1_ACTIVE then
        UseSlowFallPotsOnThaddiusP1()
        UseNaturePotsOnThaddius()
        return true
    end

    local inP1 = false
    local tName = UnitName("target")

    if TargetFromSpecificPlayer("Stalagg", MB_myStalaggMainTank) then
        inP1 = true
    elseif TargetFromSpecificPlayer("Feugen", MB_myFeugenMainTank) then
        inP1 = true
    elseif (TankTarget("Stalagg") or TankTarget("Feugen")) then
        inP1 = true
    else
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
        THAD_EnablePolaritySystem()
        UseNaturePotsOnThaddius()
        CheckClosestHealerDebuff()
        return true
    end

    local inP2 = false
    local tName = UnitName("target")

    if TargetFromSpecificPlayer("Thaddius", MB_myThaddiusMainTank) then
        inP2 = true
    elseif TargetFromSpecificPlayer("Thaddius", MB_myStalaggMainTank) then
        inP2 = true
    elseif TargetFromSpecificPlayer("Thaddius", MB_myFeugenMainTank) then
        inP2 = true
    elseif TankTarget("Thaddius") then
        inP2 = true
    else
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
                THAD_EnablePolaritySystem()
            end

        elseif (arg1 == MB_RAID.."THADDIUS_PHASE2") then
            if (arg2 == "ENGAGE") then
                CdRaidWarning(">> Thaddius Phase 2 - Position Casters <<")
                THAD_PHASE_1_ACTIVE = false
                THAD_PHASE_2_ACTIVE = true
                THAD_EnablePolaritySystem()

            elseif (arg2 == "POLARITY_MOVE") then
                CdRaidWarning(">> MOVE NOW <<")
                CheckClosestHealerDebuff()
            end
        end

    elseif (event == "PLAYER_REGEN_ENABLED") then
        THAD_PHASE_1_ACTIVE = false
        THAD_PHASE_2_ACTIVE = false
        THAD_DisablePolaritySystem()
    end
end

THAD:SetScript("OnEvent", THAD.OnEvent) 

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local function GetPlatformBossHealthPct(mobName)
    if not mobName then
        return
    end

    local members = {}
    if mobName == "Feugen" then
        members = MB_myFeugenDPSERS
    elseif mobName == "Stalagg" then
        members = MB_myStalaggDPSERS
    end

    local lowestHp = nil
    for _, playerName in ipairs(members) do
        local playerId = MBID[playerName]
        if playerId and TargetFromSpecificPlayer(mobName, playerName) then
            local hp = HealthPct(playerId.."target")
            if not lowestHp or hp < lowestHp then
                lowestHp = hp
            end
        end
    end

    return lowestHp or 1.0
end

local function CheckPlatformPhase(tName)
    local assignments = {
        [MB_myFeugenMainTank] = {
            self = "Feugen",
            other = "Stalagg"
        },
        [MB_myStalaggMainTank] = {
            self = "Stalagg",
            other = "Feugen"
        },
    }

    local assignment = assignments[myName]
    if not assignment then
        return
    end

    if tName == assignment.self and HealthPct("target") <= 0.1 then
        CdAddonMessage(MB_RAID.."THADDIUS_PHASE1", "NUKE_PLATFORM", 30)
    elseif tName == assignment.other and HealthPct("target") <= 0.1 then
        CdAddonMessage(MB_RAID.."THADDIUS_PHASE1", "AWAIT_NUKE", 30)
    end
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

            CheckPlatformPhase(tName)
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

            if tName == nil or Dead("target") or not InMeleeRange() then
                TargetNearestEnemy()
            end

            CheckPlatformPhase(tName)
            return true

        elseif ImTank() then
            if not MB_targetNearestDistanceChanged then						
				SetCVar("targetNearestDistance", "10")
				MB_targetNearestDistanceChanged = true
			end

			GetTargetNotOnTank()
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

local THAD_POLARITY = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0")
local THAD_POLARITY_ENABLED = false

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

function THAD_EnablePolaritySystem()
    if not THAD_POLARITY_ENABLED then
        THAD_POLARITY:OnInitialize()
        THAD_POLARITY_ENABLED = true
    end
end

function THAD_DisablePolaritySystem()
    if THAD_POLARITY_ENABLED then
        THAD_POLARITY:UnregisterAllEvents()
        SetBinding("SHIFT-W", nil)
        PolarityState = { Current = "NONE", Position = "HOME", Window = false }
        THAD_POLARITY_ENABLED = false
    end
end
