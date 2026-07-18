--[####################################################################################################]--
--[########################################### LOATHEB CODE ###########################################]--
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
local CdAddonMessage = mb_cdAddonMessage
local CdMessage = mb_cdMessage
local CdPrint = mb_cdPrint
local CdRaidWarning = mb_cdRaidWarning
local Dead = mb_dead
local ExecuteRotation = mb_executeRotation
local GetSpellManaCost = mb_getSpellManaCost
local GetSpellMaxRank = mb_getSpellMaxRank
local GetTargetNotOnTank = mb_getTargetNotOnTank
local HasBuffOrDebuff = mb_hasBuffOrDebuff
local HealthDown = mb_healthDown
local ImBusy = mb_imBusy
local ImHealer = mb_imHealer
local ImMeleeDPS = mb_imMeleeDPS
local ImRangedDPS = mb_imRangedDPS
local ImTank = mb_imTank
local InCombat = mb_inCombat
local IsAlive = mb_isAlive
local LockOnTarget = mb_lockOnTarget
local MyClassAlphabeticalOrder = mb_myClassAlphabeticalOrder
local NumberOfClassInRaid = mb_numberOfClassInRaid
local PotionsWhenPossible = mb_takePotionsWhenPossible
local TankTarget = mb_tankTarget
local TankTargetHealth = mb_tankTargetHealth
local TargetFromSpecificPlayer = mb_targetFromSpecificPlayer

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

---@class LOA: Frame
local LOA = CreateFrame("Frame", "LOA")

do
    for _, event in {
        "CHAT_MSG_ADDON",
        "CHAT_MSG_COMBAT_HOSTILE_DEATH",
        "ZONE_CHANGED_NEW_AREA",
        "PLAYER_ENTERING_WORLD",
        "PLAYER_REGEN_ENABLED"
    } do
        LOA:RegisterEvent(event)
    end
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

MB_myLoathebList = {}

-- Strategy Configuration
MB_myLoathebBoxStrategy = true

-- Potion Configuration
local MB_myLoathebShadowPotStrategy = true

-- Tank Assignments (REQUIRED)
local MB_myLoathebMainTank = "Kungen"

-- Healer Rotation Configuration
local MB_myLoathebHealerIndex = 1
local MB_myLoathebHealerOverheal = 0.85
local MB_myLoathebDPSThreshold = 0.88

-- Healer Assignments (REQUIRED)
local MB_myLoathebHealers = {
    -- Priests
    "Liket", "Blaidzy", "Cyal", "Bonita",
    -- Shaman
    "Shamuk", "Hurtek", "Rockon", "Slaver", "Mvenna",
    "Chimando", "Shaitan", "Lillifee",
    -- Druids
    "Pyqmi"
}

-- Healing Spell Configuration
local MB_myLoathebHealSpell = {
    Druid = "Healing Touch",
    Shaman = "Healing Wave",
    Priest = "Greater Heal",
    Paladin = "Holy Light"
}

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local function FindNextCleanHealer(startingIndex)
    if not MB_myLoathebHealers then
        return nil, nil
    end

    if not startingIndex or startingIndex < 1 then
        return nil, nil
    end

    local totalHealers = TableLength(MB_myLoathebHealers)
    if totalHealers == 0 then
        return nil, nil
    end

    for i = 1, totalHealers do
        local testIndex = startingIndex + i
        if testIndex > totalHealers then
            testIndex = testIndex - totalHealers
        end

        local healerName = MB_myLoathebHealers[testIndex]
        if healerName then
            local healerId = getCoreState().MBID[healerName]
            if healerId and IsAlive(healerId) then
                local hasCorruptedMind = HasBuffOrDebuff("Corrupted Mind", healerId, "debuff")
                if not hasCorruptedMind then
                    return testIndex, healerName
                end
            end
        end
    end

    return nil, nil
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local function CheckClassOrder(healerList, fallbackList)
    for i = 1, TableLength(healerList) - 1 do
        if UnitClass(getCoreState().MBID[healerList[i]]) == "Priest"
            and UnitClass(getCoreState().MBID[healerList[i + 1]]) == "Priest" then
            return fallbackList, false
        end
    end
    return healerList, true
end

local function InitializeHealerRotation()
    if not MB_myLoathebHealers or TableLength(MB_myLoathebHealers) == 0 then
        return nil
    end

    local sorted, seen = {}, {}
    table.sort(MB_myLoathebHealers)

    for _, healer in ipairs(MB_myLoathebHealers) do
        if getCoreState().MBID[healer] and not seen[healer] then
            table.insert(sorted, healer)
            seen[healer] = true
        end
    end

    local priests, nonPriests = {}, {}
    table.sort(sorted)

    for _, healer in ipairs(sorted) do
        local healerId = getCoreState().MBID[healer]
        if healerId then
            if UnitClass(healerId) == "Priest" then
                table.insert(priests, healer)
            else
                table.insert(nonPriests, healer)
            end
        end
    end

    local result = {}
    local priestIndex, nonPriestIndex, nextPriestPosition = 1, 1, 1
    local totalHealers = TableLength(priests) + TableLength(nonPriests)
    local priestCount = TableLength(priests)

    if priestCount >= totalHealers or priestCount == 0 then
        result = sorted
    else
        local spacing = floor(totalHealers / priestCount)
        local remainder = mod(totalHealers, priestCount)

        for i = 1, totalHealers do
            if i == nextPriestPosition and priestIndex <= priestCount then
                table.insert(result, priests[priestIndex])
                priestIndex = priestIndex + 1

                if priestIndex <= priestCount then
                    local additionalSpacing = 0
                    if priestIndex <= remainder then
                        additionalSpacing = 1
                    end

                    nextPriestPosition = nextPriestPosition + spacing + additionalSpacing
                end
            else
                if nonPriestIndex <= TableLength(nonPriests) then
                    table.insert(result, nonPriests[nonPriestIndex])
                    nonPriestIndex = nonPriestIndex + 1
                end
            end
        end
    end

    local final, isSuccessful = CheckClassOrder(result, sorted)
    local finalCount = TableLength(final)

    if finalCount < 12 then
        CdRaidWarning(">> Loatheb Healer Info: Only " .. finalCount .. " Healers Found <<")
    elseif not isSuccessful then
        CdRaidWarning(">> Loatheb Healer Info: Using Alphabetic Fallback <<")
    else
        CdRaidWarning(">> Loatheb Healer Info: Priest Spacing Successful <<")
    end

    MB_myLoathebHealers = final
    MB_myLoathebHealerIndex = 1
end

local function CurrentActiveHealer()
    if not MB_myLoathebHealers then
        return nil
    end

    if not MB_myLoathebHealerIndex or MB_myLoathebHealerIndex < 1 then
        return nil
    end

    local totalHealers = TableLength(MB_myLoathebHealers)
    if totalHealers == 0 then
        return nil
    end

    if MB_myLoathebHealerIndex > totalHealers then
        return nil
    end

    return MB_myLoathebHealers[MB_myLoathebHealerIndex]
end

local function ImCurrentHealer()
    local currentHealer = CurrentActiveHealer()
    if not currentHealer then
        return false
    end

    return currentHealer == myName
end

local function ShouldBroadcast()
    if not ImCurrentHealer() then
        return false
    end

    local myRaidId = getCoreState().MBID[myName]
    if not myRaidId then
        return false
    end

    return HasBuffOrDebuff("Corrupted Mind", myRaidId, "debuff")
end

local function BroadcastHealer()
    local currentIndex = MB_myLoathebHealerIndex
    local nextIndex, nextHealerName = FindNextCleanHealer(currentIndex)

    if nextIndex and nextHealerName then
        local message = "NEXT:" .. nextIndex .. ":" .. nextHealerName
        CdAddonMessage(getRaidId() .. "LOATHEB_HEAL", message)
    else
        CdAddonMessage(getRaidId() .. "LOATHEB_HEAL", "ALL_DEBUFFED")
    end
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local function UseShadowPotsOnLoatheb()
    if not MB_myLoathebShadowPotStrategy then
        return
    end

    if ImBusy() or not InCombat("player") then
        return
    end

    PotionsWhenPossible("Greater Shadow Protection Potion")
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local LOA_ACTIVE = false

function LOA_IsAtLoatheb()
    if LOA_ACTIVE then
        UseShadowPotsOnLoatheb()
        return true
    end

    local inF = false
    local tName = UnitName("target")

    if TargetFromSpecificPlayer("Loatheb", MB_myLoathebMainTank) then
        inF = true
    elseif (TankTarget("Loatheb") or TankTarget("Spore")) then
        inF = true
    else
        if tName and (tName == "Loatheb" or tName == "Spore") then
            inF = true
        end
    end

    if inF then
        CdAddonMessage(getRaidId() .. "LOATHEB", "ENGAGE", 30)
        LOA_ACTIVE = true
        return true
    end

    return LOA_ACTIVE
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function LOA:OnEvent()
    if (event == "CHAT_MSG_ADDON") then
        if (arg1 == getRaidId() .. "LOATHEB_HEAL") then
            local _, _, newIndex, healerName = string.find(arg2, "NEXT:(%d+):(.+)")
            MB_myLoathebHealerIndex = tonumber(newIndex)
            CdRaidWarning(">> " .. healerName .. " <<")
        elseif (arg1 == getRaidId() .. "LOATHEB_EMERGENCY") then
            if (arg2 == "ALL_DEBUFFED") then
                CdRaidWarning(">> All Healers Debuffed! Use Cooldowns on TANK! <<")
            end
        elseif (arg1 == getRaidId() .. "LOATHEB_IGNITE") then
            if (arg2 == "REFRESH") then
                CdRaidWarning(">> Refresh Fungal Bloom on MAGES! <<")
            end
        elseif (arg1 == getRaidId() .. "LOATHEB") then
            if (arg2 == "ENGAGE") then
                InitializeHealerRotation()
                LOA_ACTIVE = true
            end
        end
    elseif (event == "CHAT_MSG_COMBAT_HOSTILE_DEATH") then
        if string.find(arg1, "Loatheb dies") then
            CdRaidWarning(">> Loatheb Died! <<")
        end
    elseif (event == "ZONE_CHANGED_NEW_AREA" or event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_REGEN_ENABLED") then
        LOA_ACTIVE = false
    end
end

LOA:SetScript("OnEvent", LOA.OnEvent)

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function LOA_Healing()
    if ShouldBroadcast() then
        BroadcastHealer()
        return false
    end

    if not ImCurrentHealer() then
        return false
    end

    local mainTankId = getCoreState().MBID[MB_myLoathebMainTank]
    if not mainTankId then
        return false
    end

    local myHealSpell = MB_myLoathebHealSpell[myClass]
    local myHealRank = GetSpellMaxRank(myHealSpell)

    if not myHealSpell or not myHealRank then
        return false
    end

    local spellCost = GetSpellManaCost(myHealSpell, myHealRank)
    if not spellCost or (spellCost * 1.25) > UnitMana("player") then
        CdMessage("No Mana For << " .. myHealSpell .. " >> Finding Healer!", 30)
        BroadcastHealer()
        return false
    end

    local healValue = GetHealValueFromRank(myHealSpell, myHealRank)
    if not healValue or healValue <= 0 then
        return false
    end

    local effectiveFraction = MB_myLoathebHealerOverheal or 1.0
    local effectiveOverheal = math.min(math.max(effectiveFraction, 0.0), 1.0)
    local requiredMissing = floor(healValue * effectiveOverheal + 0.5)
    local allowedOverhealPct = (1 - effectiveOverheal) * 100

    local printMessage = string.format([[
    Heal Configuration:
    • Heal Value: %d HP
    • Allowed Overheal: %.0f%%
    • Will Heal When Missing ≥ %d HP
    ]], healValue, allowedOverhealPct, requiredMissing)

    CdPrint(printMessage, 30)

    local healthDown = HealthDown(mainTankId)
    if not healthDown then
        return false
    end

    if healthDown >= requiredMissing then
        TargetUnit(mainTankId)
        CastSpellByName(myHealSpell)
    end

    return true
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function LOA_Rotation()
    if Instance.NAXX() and LOA_IsAtLoatheb() and MB_myLoathebBoxStrategy then
        local SingleRotation = MB_mySingleList[myClass]

        UseShadowPotsOnLoatheb()

        if ImHealer() then
            local SingleLoathebRotation = MB_myLoathebList[myClass]
            ExecuteRotation(SingleLoathebRotation, "Loatheb Healing SINGLE")
        elseif HasBuffOrDebuff("Fungal Bloom", "player", "debuff") then
            ExecuteRotation(SingleRotation, "Fungal Bloom SINGLE")
        elseif ImTank() then
            ExecuteRotation(SingleRotation, "Loatheb Tank SINGLE")
        elseif TankTargetHealth() <= MB_myLoathebDPSThreshold then
            if myClass == "Mage" and MyClassAlphabeticalOrder() == 1 then
                if not HasBuffOrDebuff("Fungal Bloom", "player", "debuff") and NumberOfClassInRaid("Mage") < 4 then
                    CdAddonMessage(getRaidId() .. "LOATHEB_IGNITE", "REFRESH")
                end
            end

            ExecuteRotation(SingleRotation, "Loatheb Emergency SINGLE")
        end
        return true
    end
    return false
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function LOA_Targeting()
    local tName = UnitName("target")

    if LOA_IsAtLoatheb() and MB_myLoathebBoxStrategy then
        if myName == MB_myLoathebMainTank then
            if LockOnTarget("Loatheb") then
                return true
            end

            if not tName or Dead("target") then
                AssistFocus()
            end
            return true
        elseif ImTank() then
            GetTargetNotOnTank()
            return true
        elseif ImMeleeDPS() or ImRangedDPS() or ImHealer() then
            if LockOnTarget("Loatheb") then
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
