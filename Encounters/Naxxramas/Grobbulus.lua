--[####################################################################################################]--
--[########################################## GROBBULUS CODE ##########################################]--
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

---@class GROB: Frame
local GROB = CreateFrame("Frame", "GROB")

do
    for _, event in {
        "CHAT_MSG_ADDON",
        "CHAT_MSG_COMBAT_HOSTILE_DEATH",
        "ZONE_CHANGED_NEW_AREA",
        "PLAYER_ENTERING_WORLD",
        "PLAYER_REGEN_ENABLED"
    } do
        GROB:RegisterEvent(event)
    end
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

-- Strategy Configuration
local MB_myGrobbulusBoxStrategy = true
local MB_myGrobbulusNaturePotStrategy = true

-- Healing Assignments (REQUIRED)
local MB_myGrobbulusCleanser = "Midavellir"
local MB_myGrobbulusCleanseHealers = {
    ["Healdazor"] = MB_myGrobbulusCleanser,
    ["Niroxs"] = nil
}

-- Tank Assignments (REQUIRED)
local MB_myGrobbulusMainTank = "Moron"
local MB_myGrobbulusSlimeTanks = {
    "Kungen",
    "Tyamies"
}

-- Follow Targets (REQUIRED)
local MB_myGrobbulusRaidFollowers = {
    "Kungen",
    "Tyamies"
}

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local function UseNaturePotsOnGrobbulus()
    if not MB_myGrobbulusNaturePotStrategy then
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

local GROB_ACTIVE = false

function GROB_IsAtGrobbulus()
    if GROB_ACTIVE then
        UseNaturePotsOnGrobbulus()
        return true
    end

    local inF = false
    local tName = UnitName("target")

    if TargetFromSpecificPlayer("Grobbulus", MB_myGrobbulusMainTank) then
        inF = true
    elseif (TankTarget("Grobbulus") or TankTarget("Fallout Slime")) then
        inF = true
    else
        for _, tankName in ipairs(MB_myGrobbulusSlimeTanks) do
            if TargetFromSpecificPlayer("Fallout Slime", tankName) then
                inF = true
                break
            end
        end

        if tName and (tName == "Grobbulus" or tName == "Fallout Slime") then
            inF = true
        end
    end

    if inF then
        CdAddonMessage(MB_RAID .. "GROBBULUS", "ENGAGE", 30)
        GROB_ACTIVE = true
        return true
    end

    return GROB_ACTIVE
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function GROB:OnEvent()
    if (event == "CHAT_MSG_ADDON") then
        if (arg1 == MB_RAID .. "GROBBULUS_EMERGENCY") then
            if (arg2 == "PRIEST_OOR") then
                CdRaidWarning(">> Priest Out of Range! <<")
            end
        elseif (arg1 == MB_RAID .. "GROBBULUS") then
            if (arg2 == "ENGAGE") then
                GROB_ACTIVE = true
            end
        end
    elseif (event == "CHAT_MSG_COMBAT_HOSTILE_DEATH") then
        if string.find(arg1, "Grobbulus dies") then
            CdRaidWarning(">> Grobbulus Died! <<")
        end
    elseif (event == "ZONE_CHANGED_NEW_AREA" or event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_REGEN_ENABLED") then
        GROB_ACTIVE = false
    end
end

GROB:SetScript("OnEvent", GROB.OnEvent)

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local function GetTargetWithInjection()
    if not UnitInRaid("player") then
        return nil
    end

    for i = 1, GetNumRaidMembers() do
        local memberId = "raid" .. i
        if HasBuffOrDebuff("Mutating Injection", memberId, "debuff") then
            return memberId
        end
    end

    return nil
end

function GROB_Decurse()
    local targetId = GetTargetWithInjection()
    if not targetId then
        return false
    end

    if not UnitInRange(targetId) then
        CdAddonMessage(MB_RAID .. "GROBBULUS_EMERGENCY", "PRIEST_OOR")
        return false
    end

    if CheckInteractDistance(targetId, 3) then
        TargetUnit(targetId)
        CastSpellByName("Cure Disease")
        return true
    end

    return false
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local CurrentMainFollowIndex = 1

local function GetRaidFollow(firstId, secondId, decurseId)
    local firstHasDebuff = HasBuffOrDebuff("Mutating Injection", firstId, "debuff")
    local secondHasDebuff = HasBuffOrDebuff("Mutating Injection", secondId, "debuff")

    if firstHasDebuff and secondHasDebuff then
        return decurseId
    elseif CurrentMainFollowIndex == 1 and firstHasDebuff then
        CurrentMainFollowIndex = 2
        return secondId
    elseif CurrentMainFollowIndex == 2 and secondHasDebuff then
        CurrentMainFollowIndex = 1
        return firstId
    else
        return (CurrentMainFollowIndex == 1) and firstId or secondId
    end
end

function GROB_GetOUT()
    if GROB_IsAtGrobbulus() and MB_myGrobbulusBoxStrategy then
        UseNaturePotsOnGrobbulus()

        local firstFollow, secondFollow = MB_myGrobbulusRaidFollowers[1], MB_myGrobbulusRaidFollowers[2]
        local firstFollowId, secondFollowId = MBID[firstFollow], MBID[secondFollow]

        if not firstFollowId or not secondFollowId then
            CdRaidWarning(">> You Don't Have Enough Follow Targets! <<")
            return false
        end

        local decurseId = MBID[MB_myGrobbulusCleanser]
        if not decurseId then
            CdRaidWarning(">> You Don't Have Decurse Follow! <<")
            return false
        end

        if MyNameInTable(MB_myGrobbulusCleanseHealers) then
            local assigned = MB_myGrobbulusCleanseHealers[myName]

            if assigned ~= nil then
                MB_myAssignedHealTarget = assigned
            else
                local targetId = GetTargetWithInjection()
                if targetId then
                    local name = UnitName(targetId)
                    MB_myAssignedHealTarget = name
                    CdMessage(">> Healing " .. name .. "! <<", 60)
                else
                    MB_myAssignedHealTarget = nil
                end
            end
        end

        if myName == MB_myGrobbulusCleanser then
            GROB_Decurse()
            return false
        end

        if myName == MB_myGrobbulusMainTank then
            return false
        end

        local mainFollowId = GetRaidFollow(firstFollowId, secondFollowId, decurseId)
        local mainFollow = UnitName(mainFollowId)

        if myName == mainFollow then
            return false
        end

        if HasBuffOrDebuff("Mutating Injection", "player", "debuff") then
            if IsAlive(decurseId) then
                FollowUnit(decurseId)
            end
        else
            if UnitInRange(mainFollowId) then
                if not CheckInteractDistance(mainFollowId, 3) then
                    FollowUnit(mainFollowId)
                end
            else
                if IsAlive(decurseId) then
                    FollowUnit(decurseId)
                end
            end
        end
        return true
    end
    return false
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function GROB_Targeting()
    local tName = UnitName("target")

    if GROB_IsAtGrobbulus() and MB_myGrobbulusBoxStrategy then
        if myName == MB_myGrobbulusMainTank then
            if LockOnTarget("Grobbulus") then
                return true
            end

            if not tName or Dead("target") then
                AssistFocus()
            end
            return true
        elseif ImTank() then
            GetTargetNotOnTank()
            return true
        elseif ImRangedDPS() then
            if TankTargetHealth() < 0.12 then
                AssistFocus()
                return true
            end

            if MB_mySpecc ~= "Fire" then
                for _, tankName in ipairs(MB_myGrobbulusSlimeTanks) do
                    if AssistSpecificTargetFromPlayer("Fallout Slime", tankName) then
                        return true
                    end
                end
            end

            if LockOnTarget("Grobbulus") then
                return true
            end

            if not tName or Dead("target") then
                AssistFocus()
            end
            return true
        end
    end

    return false
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--
