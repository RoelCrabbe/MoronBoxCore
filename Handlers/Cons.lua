--[####################################################################################################]--
--[######################################## Raid Consumables ##########################################]--
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

local UniversalReagents = {
    "Cache of Mau'ari",
    "Drakefire Amulet", 
    "Eternal Quintessence"
}

local OptionalUniversalReagents = {
    "Swiftness of Zanza",
    "Greater Shadow Protection Potion",
}

local ClassSpecificReagents = {
    ["Druid"] = {
        "Demonic Rune",
        "Flask of Distilled Wisdom",
        "Ironwood Seed",
        "Major Mana Potion",
        "Wild Thornroot"
    },
    ["Hunter"] = {
        "Demonic Rune",
        "Doomshot",
        "Flask of the Titans",
        "Greater Nature Protection Potion",
        "Major Mana Potion",
        "Elixir of the Mongoose",
        "Juju Might",
        "Juju Power"
    },
    ["Mage"] = {
        "Arcane Powder",
        "Demonic Rune",
        "Flask of Supreme Power",
        "Major Mana Potion",
        "Rune of Portals",
        "Mageblood Potion",
        "Greater Arcane Elixir",
        "Elixir of Frost Power",
        "Elixir of Greater Firepower"
    },
    ["Paladin"] = {
        "Demonic Rune",
        "Flask of Distilled Wisdom",
        "Major Mana Potion",
        "Symbol of Divinity",
        "Symbol of Kings"
    },
    ["Priest"] = {
        "Demonic Rune",
        "Flask of Distilled Wisdom",
        "Major Mana Potion",
        "Sacred Candle",
        "Mageblood Potion",
        "Flask of Supreme Power",
        "Greater Arcane Elixir",
        "Elixir of Shadow Power"
    },
    ["Rogue"] = {
        "Flash Powder",
        "Flask of the Titans",
        "Greater Nature Protection Potion",
        "Elixir of the Mongoose",
        "Juju Might",
        "Juju Power"
    },
    ["Shaman"] = {
        "Ankh",
        "Demonic Rune",
        "Flask of Distilled Wisdom",
        "Major Mana Potion",
        "Mageblood Potion"
    },
    ["Warlock"] = {
        "Demonic Rune",
        "Flask of Supreme Power",
        "Major Mana Potion",
        "Mageblood Potion",
        "Greater Arcane Elixir",
        "Elixir of Shadow Power"
    },
    ["Warrior"] = {
        "Dirge's Kickin' Chimaerok Chops",
        "Doomshot",
        "Elixir of the Mongoose",
        "Flask of the Titans",
        "Gift of Arthas",
        "Greater Nature Protection Potion",
        "Greater Stoneshield Potion",
        "Juju Might",
        "Juju Power",
        "Miniature Cannon Balls",
        "Rumsey Rum Black Label"
    }
}

local ReagentsLimit = {
    -- ========================================
    -- UNIVERSAL ITEMS (All Characters Need)
    -- ========================================
    ["Cache of Mau'ari"] = { 1, 1 },
    ["Drakefire Amulet"] = { 1, 1 },
    ["Eternal Quintessence"] = { 1, 1 },
    ["Swiftness of Zanza"] = { 1, 1 },

    -- ========================================
    -- CLASS-SPECIFIC REAGENTS
    -- ========================================
    
    -- Druid Reagents
    ["Ironwood Seed"] = { 20, 1 },
    ["Wild Thornroot"] = { 160, 1 },
    
    -- Mage Reagents
    ["Arcane Powder"] = { 160, 1 },
    ["Rune of Portals"] = { 20, 1 },
    
    -- Paladin Reagents
    ["Symbol of Divinity"] = { 10, 1 },
    ["Symbol of Kings"] = { 400, 1 },
    
    -- Priest Reagents
    ["Sacred Candle"] = { 160, 1 },
    
    -- Rogue Reagents
    ["Flash Powder"] = { 100, 1 },
    
    -- Shaman Reagents
    ["Ankh"] = { 20, 1 },

    -- ========================================
    -- CONSUMABLES BY TYPE
    -- ========================================
    
    -- Protection Potions
    ["Greater Nature Protection Potion"] = { 20, 1 },
    ["Greater Shadow Protection Potion"] = { 50, 1 },
    
    -- Mana Restoration
    ["Demonic Rune"] = { 20, 1 },
    ["Major Mana Potion"] = { 40, 1 },
    
    -- Flasks (High-End Consumables)
    ["Flask of Distilled Wisdom"] = { 5, 1 },
    ["Flask of Supreme Power"] = { 5, 1 },
    ["Flask of the Titans"] = { 5, 1 },
    
    -- Damage/Power Elixirs
    ["Elixir of Frost Power"] = { 20, 1 },
    ["Elixir of Greater Firepower"] = { 20, 1 },
    ["Elixir of Shadow Power"] = { 20, 1 },
    ["Greater Arcane Elixir"] = { 20, 1 },
    
    -- Utility Potions
    ["Mageblood Potion"] = { 20, 1 },
    
    -- ========================================
    -- PHYSICAL DPS CONSUMABLES
    -- ========================================
    
    -- Melee Enhancement
    ["Elixir of the Mongoose"] = { 40, 1 },
    ["Juju Might"] = { 40, 1 },
    ["Juju Power"] = { 40, 1 },
    
    -- Food & Drink Buffs
    ["Dirge's Kickin' Chimaerok Chops"] = { 8, 1 },
    ["Rumsey Rum Black Label"] = { 20, 1 },
    
    -- Tank/Survivability
    ["Gift of Arthas"] = { 10, 1 },
    ["Greater Stoneshield Potion"] = { 40, 1 },
    
    -- Ammunition/Projectiles (Special Stack Size)
    ["Doomshot"] = { 1, 2 },
    ["Miniature Cannon Balls"] = { 1, 2 },
}

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local function GetCompleteReagentList(className)
    local classItems = ClassSpecificReagents[className]
    local completeList = {}

    for _, item in ipairs(UniversalReagents) do
        table.insert(completeList, item)
    end

    for _, item in ipairs(OptionalUniversalReagents) do
        table.insert(completeList, item)
    end

    if classItems then
        for _, item in ipairs(classItems) do
            table.insert(completeList, item)
        end
    end
    
    return completeList
end

function mb_buyReagentsAndConsumables()
    local classItems = GetCompleteReagentList(myClass)
    
    if classItems then
        for _, item in ipairs(classItems) do
            local myCurrentItems = mb_hasItem(item) / ReagentsLimit[item][2]
            local myNeededItems
            
            if (item == "Doomshot" or item == "Miniature Cannon Balls") and myClass == "Hunter" then
                myNeededItems = (32 - myCurrentItems) / ReagentsLimit[item][2]
            else
                myNeededItems = (ReagentsLimit[item][1] - myCurrentItems) / ReagentsLimit[item][2]
            end
            
            if myNeededItems > 0 then
                if item == "Symbol of Kings" then
                    myNeededItems = math.floor(myNeededItems / 20)
                end
                
                for itemID = 1, GetMerchantNumItems() do
                    local merchantItemLink = GetMerchantItemLink(itemID)
                    if merchantItemLink then
                        if string.find(merchantItemLink, item) then
                            mb_cdPrint("Buying "..myNeededItems.." "..merchantItemLink)
                            BuyMerchantItem(itemID, myNeededItems)
                        end
                    end
                end
            end
        end
    end
    
    MB_autoBuyReagents.Active = false
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local ManaPotsThreshold = {
    { name = "Major Mana Potion", threshold = 2250 },
    { name = "Demonic Rune", threshold = 1500 },
    { name = "Dark Rune", threshold = 1500 },
}

local function UseManaPotsThresholdPots()
    local manaDown = mb_manaDown()
    for _, item in ipairs(ManaPotsThreshold) do
        if manaDown > item.threshold and mb_haveInBags(item.name) and not mb_isItemInBagCoolDown(item.name) then
            UseItemByName(item.name)
            return
        end
    end
end

local function TakeManaPotionIfBelowManaPotMana()
    if mb_imBusy() or not mb_inCombat("player") then
		return
	end

    if not mb_bossIShouldUseRunesAndManapotsOn() and not mb_bossIShouldUseManapotsOn() then
        return
    end

    UseManaPotsThresholdPots()
end

local function TakeManaPotionIfBelowManaPotManaInRazorgoreRoom()
    if not MB_myRazorgoreBoxHealerStrategy then 
        return
    end

    if mb_imBusy() or not mb_inCombat("player") then
		return
	end

    if Instance.BWL and not mb_isAtRazorgore() and MB_myRazorgoreBoxStrategy then
        return
    end

    UseManaPotsThresholdPots()
end

function mb_takeManaPotionAndRunes()
    TakeManaPotionIfBelowManaPotMana()
    TakeManaPotionIfBelowManaPotManaInRazorgoreRoom()
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function mb_useSandsOnChromaggus()
    if mb_imBusy() or not mb_inCombat("player") then
		return
	end

	if Instance.BWL and not mb_tankTarget("Chromaggus") then
        return
    end

	if not mb_imTank() then
        return
    end

    if not mb_iamFocus() then
        return
    end

	if not mb_hasBuffOrDebuff("Brood Affliction: Bronze", "player", "debuff") then
        return
    end

	if mb_hasBuffNamed("Time Stop", "player") then
        return
    end

    if mb_isDruidShapeShifted() then
        return
    end

    if mb_checkCooldown(sandTime, 3) then
        sandTime = GetTime()
        mb_useFromBags("Hourglass Sand")
    end
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local function UsePotionsWhenPossible(potion)
    if not mb_haveInBags(potion) and not mb_isItemInBagCoolDown(potion) then
        return
    end

    if mb_hasBuffOrDebuff(potion, "player", "buff") then
        return
    end

    if mb_isDruidShapeShifted() then
        return
    end

    if mb_checkCooldown(cooldown, 3) then
        cooldown = GetTime()
        mb_useFromBags(potion)
    end
end

function mb_useFrozenRuneOnFaerlina()
    if not MB_myFaerlinaFirePotStrategy then
        return
    end

    if mb_imBusy() or not mb_inCombat("player") then
		return
	end

    if Instance.NAXX and not (mb_tankTarget("Grand Widow Faerlina") or UnitName("target") == "Grand Widow Faerlina") then
        return
    end

    UsePotionsWhenPossible("Greater Fire Protection Potion")
end

function mb_useShadowPotsOnLoatheb()
    if not MB_myLoathebShadowPotStrategy then
        return
    end

    if mb_imBusy() or not mb_inCombat("player") then
		return
	end

    if Instance.NAXX and not (mb_tankTarget("Loatheb") or UnitName("target") == "Loatheb") then
        return
    end

    UsePotionsWhenPossible("Greater Shadow Protection Potion")
end

function mb_useFirePotsOnVaelastrasz()
    if not MB_myVaelastraszFirePotStrategy then
        return
    end

    if mb_imBusy() or not mb_inCombat("player") then
		return
	end

    if Instance.BWL and not (mb_tankTarget("Vaelastrasz the Corrupt") or UnitName("target") == "Vaelastrasz the Corrupt") then
        return
    end

    UsePotionsWhenPossible("Greater Fire Protection Potion")
end

function mb_useNaturePotsOnHuhuran()
    if not MB_myHuhuranNaturePotStrategy then
        return
    end

    if mb_imBusy() or not mb_inCombat("player") then
		return
	end

    if Instance.AQ40 and not (mb_tankTarget("Princess Huhuran") or UnitName("target") == "Princess Huhuran") then
        return
    end

    if mb_healthPct("target") > 0.3 then
        return
    end

    UsePotionsWhenPossible("Greater Nature Protection Potion")
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local function UseJujuWhenPossible(juju)
    if not mb_haveInBags(juju) and not mb_isItemInBagCoolDown(juju) then
        return
    end

    if mb_hasBuffOrDebuff(juju, "player", "buff") then
        return
    end

    if mb_isDruidShapeShifted() then
        return
    end

    TargetUnit("player")

    if mb_checkCooldown(cooldown, 3) then
        cooldown = GetTime()
        mb_useFromBags(juju)
    end

    TargetLastTarget()
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local function MeleeSpeedRunPots() -- Warrior, Hunter, Rogue
    UsePotionsWhenPossible("Swiftness of Zanza")
    UsePotionsWhenPossible("Flask of the Titans")
    UsePotionsWhenPossible("Elixir of the Mongoose")
    UseJujuWhenPossible("Juju Might")
    UseJujuWhenPossible("Juju Power")
end

local function CasterSpeedRunPots() -- Priest Should get Ranged & Healer Pots; Mage, Warlock;
    UsePotionsWhenPossible("Swiftness of Zanza")
    UsePotionsWhenPossible("Flask of Supereme Power")
    UsePotionsWhenPossible("Mageblood Potion")
    UsePotionsWhenPossible("Greater Arcane Elixir")

    if myClass == "Mage" then
        if MB_mySpecc == "Frost" then
            UsePotionsWhenPossible("Elixir of Frost Power")
            return
        end

        UsePotionsWhenPossible("Elixir of Greater Firepower")
        return
    end

    UsePotionsWhenPossible("Elixir of Shadow Power")
end

local function HealerSpeedRunPots() -- Priest Should get Ranged & Healer Pots; Shaman, Priest, Druid
    UsePotionsWhenPossible("Swiftness of Zanza")
    UsePotionsWhenPossible("Flask of Distilled Wisdom")
    UsePotionsWhenPossible("Mageblood Potion")
end

function mb_useSpeedRunPots()
    if not MB_mySpeedRunStrategy then
        return
    end

    if mb_imBusy() or mb_inCombat("player") then
		return
	end

    if mb_imHealer() then
        HealerSpeedRunPots()
    elseif mb_imRangedDPS() then
        CasterSpeedRunPots()
    else
        MeleeSpeedRunPots()
    end
end