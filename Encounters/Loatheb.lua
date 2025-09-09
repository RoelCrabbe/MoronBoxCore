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
local myClass = UnitClass("player")
local myName = UnitName("player")
local myRace = UnitRace("player")

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local LOA = CreateFrame("Button", "LOA", UIParent)

do
	for _, event in {
		"CHAT_MSG_ADDON"
		}
		do LOA:RegisterEvent(event)
	end
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

-- Strategy Configuration
MB_myLoathebBoxStrategy = true
MB_myLoathebShadowPotStrategy = true

-- Tank and Paladin Assignments (REQUIRED)
MB_myLoathebMainTank = "Kungen"
MB_myLoathebHealerIndex = 1
MB_myLoathebHealerOverheal = 0.85

-- Healer Assignments (REQUIRED)
MB_myLoathebHealer = {
    -- Priests
    "Liket", "Blaidzy", "Cyal", "Bonita",
    -- Shaman
    "Shamuk", "Hurtek", "Rockon", "Slaver", "Mvenna", "Chimando", "Shaitan", "Lillifee",
    -- Druids
    "Pyqmi"
}

-- Healing Spell Configuration
MB_myLoathebHealSpell = {
    Shaman = "Healing Wave", 
    Priest = "Greater Heal",
    Paladin = "Holy Light",
    Druid = "Healing Touch"
}

MB_myLoathebHealSpellRank = {
    Shaman = "Rank 10", 
    Priest = "Rank 5",
    Paladin = "Rank 9",
    Druid = "Rank 11"
}

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local function CurrentActiveHealer()
    if not MB_myLoathebHealer then
        return nil
    end
    
    if not MB_myLoathebHealerIndex or MB_myLoathebHealerIndex < 1 then
        return nil
    end
    
    local totalHealers = TableLength(MB_myLoathebHealer)
    if totalHealers == 0 then
        return nil
    end
    
    if MB_myLoathebHealerIndex > totalHealers then
        return nil
    end
    
    return MB_myLoathebHealer[MB_myLoathebHealerIndex]
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

    local myId = MBID[myName]
    if not myId then
        return false
    end
    
    return mb_hasBuffOrDebuff("Corrupted Mind", myId, "debuff")
end

local function BroadcastHealer()
    local currentIndex = MB_myLoathebHealerIndex
    local nextIndex, nextHealerName = mb_findNextCleanHealer(currentIndex)

    if nextIndex and nextHealerName then
        local message = "NEXT:"..nextIndex..":"..nextHealerName
        SendAddonMessage(MB_RAID.."LOATHEB_HEAL", message, "RAID")

        MB_myLoathebHealerIndex = nextIndex
    else
        SendAddonMessage(MB_RAID.."LOATHEB_EMERGENCY", "ALL_DEBUFFED", "RAID")
    end
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function mb_findNextCleanHealer(startingIndex)
    if not MB_myLoathebHealer then
        return nil, nil
    end

    if not startingIndex or startingIndex < 1 then
        return nil, nil
    end

    local totalHealers = TableLength(MB_myLoathebHealer)
    if totalHealers == 0 then
        return nil, nil
    end

    for i = 1, totalHealers do
        local testIndex = startingIndex + i

        if testIndex > totalHealers then
            testIndex = testIndex - totalHealers
        end

        local healerName = MB_myLoathebHealer[testIndex]

        if healerName then
            local healerId = MBID[healerName]
            if healerId and mb_isAlive(healerId) then
                local hasCorruptedMind = mb_hasBuffOrDebuff("Corrupted Mind", healerId, "debuff")
                if not hasCorruptedMind then
                    return testIndex, healerName
                end
            else
                mb_cdPrint("Warning: Cannot find ID for healer "..healerName)
            end
        end
    end

    return nil, nil
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function LOA:OnEvent()
	if (event == "CHAT_MSG_ADDON") then
        if (arg1 == MB_RAID.."LOATHEB_HEAL") then
            local _, _, newIndex, healerName = string.find(arg2, "NEXT:(%d+):(.+)")

            if myName == healerName then
                mb_cdMessage(">> "..healerName.." is now active healer <<")
            end

            MB_myLoathebHealerIndex = tonumber(newIndex)

        elseif (arg1 == MB_RAID.."LOATHEB_EMERGENCY") then
            if (arg2 == "ALL_DEBUFFED") then
                if IsRaidLeader() then
                    SendChatMessage("<< All Healers Debuffed! Use Cooldowns on TANK! >>", "RAID_WARNING")
                elseif mb_imFocus() then
                    mb_cdMessage("<< All Healers Debuffed! Use Cooldowns on TANK! >>", 20)
                end
            end
        end
    end
end

LOA:SetScript("OnEvent", LOA.OnEvent) 

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function mb_loathebHealing()

    if ShouldBroadcast() then
        BroadcastHealer()
        return false
    end

    if not ImCurrentHealer() then
        return false
    end

    local mainTankId = MBID[MB_myLoathebMainTank]
    if not mainTankId then
        return false
    end

    local myHealSpell = MB_myLoathebHealSpell[myClass]
    local myHealRank = MB_myLoathebHealSpellRank[myClass]
    if not myHealSpell or not myHealRank then
        return false
    end

    local healValue = GetHealValueFromRank(myHealSpell, myHealRank)
    if not healValue or healValue <= 0 then
        return false
    end

    local effectiveFraction = MB_myLoathebHealerOverheal or 1.0
    local effectiveOverheal = math.min(math.max(effectiveFraction, 0.0), 1.0)
    local requiredMissing = math.floor(healValue * effectiveOverheal + 0.5)
    local allowedOverhealPct = (1 - effectiveOverheal) * 100

    local printMessage = string.format(
        "Heal value=%d, allowed overheal=%.0f%% → will start when missing ≥ %d HP",
        healValue, allowedOverhealPct, requiredMissing
    )

    mb_cdPrint(printMessage, 30)

    local healthDown = mb_healthDown(mainTankId)
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

local function ExecuteRotation(rotation, context)
    if rotation and type(rotation) == "function" then
        rotation()
    else
        CdMessage("I don't know what to do for "..(context or "this situation")..".", 500)
    end
end

function mb_loathebRotation()
    if Instance.NAXX() and mb_isAtLoatheb() and MB_myLoathebBoxStrategy then
        local SingleRotation = MB_mySingleList[myClass]

        mb_useShadowPotsOnLoatheb()

        if mb_imHealer() then
            local SingleLoathebRotation = MB_myLoathebList[myClass]
            ExecuteRotation(SingleLoathebRotation, "Loatheb Healing SINGLE")
        elseif mb_hasBuffOrDebuff("Fungal Bloom", "player", "debuff") then
            ExecuteRotation(SingleRotation, "Fungal Bloom SINGLE")
        elseif mb_imTank() then
            ExecuteRotation(SingleRotation, "Loatheb Tank SINGLE")
        elseif mb_tankTargetHealth() <= 0.63 then
            ExecuteRotation(SingleRotation, "Loatheb Emergency SINGLE")
        end
        return true
    end
    return false
end