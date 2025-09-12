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

local AssistFocus = mb_assistFocus
local CdPrint = mb_cdPrint
local CdRaidWarning = mb_cdRaidWarning
local Dead = mb_dead
local ExecuteRotation = mb_executeRotation
local GetMaxSpellRank = mb_getMaxSpellRank
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
local IsAtLoatheb = mb_isAtLoatheb
local LockOnTarget = mb_lockOnTarget
local MyClassAlphabeticalOrder = mb_myClassAlphabeticalOrder
local NumberOfClassInRaid = mb_numberOfClassInRaid
local TankTargetHealth = mb_tankTargetHealth
local TakePotionsWhenPossible = mb_takePotionsWhenPossible

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local LOA = CreateFrame("Button", "LOA", UIParent)

do
	for _, event in {
		"CHAT_MSG_ADDON",
        "ZONE_CHANGED_NEW_AREA",
        "PLAYER_ENTERING_WORLD"
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

-- Tank Assignments (REQUIRED)
MB_myLoathebMainTank = "Kungen"

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

-- Healer Rotation Configuration
local MB_myLoathebHealerIndex = 1
local MB_myLoathebHealerOverheal = 0.84
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
            local healerId = MBID[healerName]
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
        if UnitClass(MBID[healerList[i]]) == "Priest" 
            and UnitClass(MBID[healerList[i + 1]]) == "Priest" then
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
        if MBID[healer] and not seen[healer] then
            table.insert(sorted, healer)
            seen[healer] = true
        end
    end

    local priests, nonPriests = {}, {}
    table.sort(sorted)

    for _, healer in ipairs(sorted) do
        local healerId = MBID[healer]
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
        local spacing = math.floor(totalHealers / priestCount)
        local remainder = math.mod(totalHealers, priestCount)

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
        CdRaidWarning(">> Loatheb Healer Info: Only "..finalCount.." Healers Found <<")
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

    local myRaidId = MBID[myName]
    if not myRaidId then
        return false
    end
    
    return HasBuffOrDebuff("Corrupted Mind", myRaidId, "debuff")
end

local function BroadcastHealer()
    local currentIndex = MB_myLoathebHealerIndex
    local nextIndex, nextHealerName = FindNextCleanHealer(currentIndex)

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

local function UseShadowPotsOnLoatheb()
    if not MB_myLoathebShadowPotStrategy then
        return
    end

    if ImBusy() or not InCombat("player") then
		return
	end

    TakePotionsWhenPossible("Greater Shadow Protection Potion")
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function LOA:OnEvent()
	if (event == "CHAT_MSG_ADDON") then
        if (arg1 == MB_RAID.."LOATHEB_HEAL") then
            local _, _, newIndex, healerName = string.find(arg2, "NEXT:(%d+):(.+)")
            MB_myLoathebHealerIndex = tonumber(newIndex)
            CdRaidWarning(">> "..healerName.." <<")

        elseif (arg1 == MB_RAID.."LOATHEB_EMERGENCY") then
            if (arg2 == "ALL_DEBUFFED") then
                CdRaidWarning(">> All Healers Debuffed! Use Cooldowns on TANK! <<")
            end

        elseif (arg1 == MB_RAID.."LOATHEB_IGNITE") then
            if (arg2 == "REFRESH") then
                CdRaidWarning(">> Refresh Fungal Bloom on MAGES! <<")
            end 
        end
    elseif (event == "ZONE_CHANGED_NEW_AREA" or event == "PLAYER_ENTERING_WORLD") and Instance.NAXX() then
        InitializeHealerRotation()
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

    local mainTankId = MBID[MB_myLoathebMainTank]
    if not mainTankId then
        return false
    end

    local myHealSpell = MB_myLoathebHealSpell[myClass]
    local myHealRank = GetMaxSpellRank(myHealSpell)

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
    if Instance.NAXX() and IsAtLoatheb() and MB_myLoathebBoxStrategy then
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
            if MyClassAlphabeticalOrder() == 1 and NumberOfClassInRaid("Mage") < 4 then
                if not HasBuffOrDebuff("Fungal Bloom", "player", "debuff") then
                    SendAddonMessage(MB_RAID.."LOATHEB_IGNITE", "REFRESH", "RAID")
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
	if IsAtLoatheb() and MB_myLoathebBoxStrategy then
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