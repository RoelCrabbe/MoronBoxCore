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

local BossIShouldUseManapotsOn = mb_bossIShouldUseManapotsOn
local BossIShouldUseRunesAndManapotsOn = mb_bossIShouldUseRunesAndManapotsOn
local BuyReagentsAndConsumables = mb_buyReagentsAndConsumables
local BossUseFAPon = mb_bossUseFAPon
local CdMessage = mb_cdMessage
local CdPrint = mb_cdPrint
local GetAllContainerFreeSlots = mb_getAllContainerFreeSlots
local HasBuffNamed = mb_hasBuffNamed
local HasBuffOrDebuff = mb_hasBuffOrDebuff
local HasItem = mb_hasItem
local HaveInBags = mb_haveInBags
local HealthPct = mb_healthPct
local ImBusy = mb_imBusy
local ImFocus = mb_imFocus
local ImHealer = mb_imHealer
local ImMeleeDPS = mb_imMeleeDPS
local ImRangedDPS = mb_imRangedDPS
local ImTank = mb_imTank
local InCombat = mb_inCombat
local IsAtRazorgore = mb_isAtRazorgore
local IsDruidShapeShifted = mb_isDruidShapeShifted
local IsItemInBagCoolDown = mb_isItemInBagCoolDown
local ManaDown = mb_manaDown
local TakeManaPotionAndRunes = mb_takeManaPotionAndRunes
local TankTarget = mb_tankTarget
local UseFirePotsOnVaelastrasz = mb_useFirePotsOnVaelastrasz
local UseFromBags = mb_useFromBags
local UseFrozenRuneOnFaerlina = mb_useFrozenRuneOnFaerlina
local UseNaturePotsOnHuhuran = mb_useNaturePotsOnHuhuran
local UseSandsOnChromaggus = mb_useSandsOnChromaggus
local UseShadowPotsOnLoatheb = mb_useShadowPotsOnLoatheb
local UseSpeedRunPots = mb_useSpeedRunPots

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local UniversalReagents = {
    "Cache of Mau'ari",
    "Drakefire Amulet", 
    "Eternal Quintessence",
    "Onyxia Scale Cloak"
}

local OptionalUniversalReagents = {
    "Swiftness of Zanza",
    "Greater Shadow Protection Potion",
    "Limited Invulnerability Potion"
}

local ClassSpecificReagents = {
    ["Druid"] = {
        "Tea with Sugar",
        "Flask of Distilled Wisdom",
        "Ironwood Seed",
        "Major Mana Potion",
        "Mageblood Potion",
        "Wild Thornroot",
        "Conjured Crystal Water"
    },
    ["Hunter"] = {
        "Tea with Sugar",
        "Doomshot",
        "Flask of the Titans",
        "Greater Nature Protection Potion",
        "Major Mana Potion",
        "Elixir of the Mongoose",
        "Juju Might",
        "Juju Power",
        "Conjured Crystal Water"
    },
    ["Mage"] = {
        "Arcane Powder",
        "Tea with Sugar",
        "Flask of Supreme Power",
        "Major Mana Potion",
        "Rune of Portals",
        "Mageblood Potion",
        "Greater Arcane Elixir",
        "Elixir of Frost Power",
        "Elixir of Greater Firepower",
        "Conjured Crystal Water"
    },
    ["Paladin"] = {
        "Tea with Sugar",
        "Flask of Distilled Wisdom",
        "Major Mana Potion",
        "Mageblood Potion",
        "Symbol of Divinity",
        "Symbol of Kings",
        "Conjured Crystal Water"
    },
    ["Priest"] = {
        "Tea with Sugar",
        "Flask of Distilled Wisdom",
        "Major Mana Potion",
        "Sacred Candle",
        "Mageblood Potion",
        "Flask of Supreme Power",
        "Greater Arcane Elixir",
        "Elixir of Shadow Power",
        "Conjured Crystal Water"
    },
    ["Rogue"] = {
        "Flash Powder",
        "Flask of the Titans",
        "Greater Nature Protection Potion",
        "Elixir of the Mongoose",
        "Juju Might",
        "Juju Power",
        "Free Action Potion"
    },
    ["Shaman"] = {
        "Ankh",
        "Tea with Sugar",
        "Flask of Distilled Wisdom",
        "Major Mana Potion",
        "Mageblood Potion",
        "Conjured Crystal Water"
    },
    ["Warlock"] = {
        "Tea with Sugar",
        "Flask of Supreme Power",
        "Major Mana Potion",
        "Mageblood Potion",
        "Greater Arcane Elixir",
        "Elixir of Shadow Power",
        "Conjured Crystal Water"
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
        "Rumsey Rum Black Label",
        "Free Action Potion",
        "Mighty Rage Potion"
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
    ["Onyxia Scale Cloak"] = { 1, 1 },

    ["Conjured Crystal Water"] = { 60, 1 },

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
    ["Greater Nature Protection Potion"] = { 15, 1 },
    ["Greater Shadow Protection Potion"] = { 55, 1 },
    
    -- Mana Restoration
    ["Tea with Sugar"] = { 40, 1 },
    ["Major Mana Potion"] = { 60, 1 },
    
    -- Flasks (High-End Consumables)
    ["Flask of Distilled Wisdom"] = { 10, 1 },
    ["Flask of Supreme Power"] = { 10, 1 },
    ["Flask of the Titans"] = { 10, 1 },
    
    -- Damage/Power Elixirs
    ["Elixir of Frost Power"] = { 20, 1 },
    ["Elixir of Greater Firepower"] = { 20, 1 },
    ["Elixir of Shadow Power"] = { 20, 1 },
    ["Greater Arcane Elixir"] = { 40, 1 },
    
    -- Utility Potions
    ["Mageblood Potion"] = { 40, 1 },
    
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
    ["Gift of Arthas"] = { 15, 1 },
    ["Greater Stoneshield Potion"] = { 40, 1 },
    
    -- Ammunition/Projectiles (Special Stack Size)
    ["Doomshot"] = { 1, 2 },
    ["Miniature Cannon Balls"] = { 1, 2 },

    -- Other
    ["Free Action Potion"] = { 5, 1 },
    ["Limited Invulnerability Potion"] = { 10, 1 },
    ["Mighty Rage Potion"] = { 15, 1 }
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
    local freeSlots = GetAllContainerFreeSlots()
    if freeSlots <= 5 then
        CdMessage("I don't have enough bagspace to buy consumables, sort it!")
        return
    end

    local classItems = GetCompleteReagentList(myClass)
    
    if classItems then
        for _, item in ipairs(classItems) do
            local myCurrentItems = HasItem(item) / ReagentsLimit[item][2]
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
                            CdPrint("Buying "..myNeededItems.." "..merchantItemLink)
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
    { name = "Tea with Sugar", threshold = 1750 },
    { name = "Demonic Rune", threshold = 1500 },
    { name = "Dark Rune", threshold = 1500 },
}

local function UseManaPotsThresholdPots()
    local manaDown = ManaDown()
    for _, item in ipairs(ManaPotsThreshold) do
        if manaDown > item.threshold and HaveInBags(item.name) and not IsItemInBagCoolDown(item.name) then
            UseItemByName(item.name)
            return
        end
    end
end

function mb_takeManaPotionAndRunes()
    if ImBusy() or not InCombat("player") then
		return
	end

    UseManaPotsThresholdPots()
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function mb_useSandsOnChromaggus()
	if ImBusy() or not InCombat("player") then
		return
	end

	if Instance.BWL() and not TankTarget("Chromaggus") then
        return
    end

	if not ImTank() then
        return
    end

    if not ImFocus() then
        return
    end

	if not HasBuffOrDebuff("Brood Affliction: Bronze", "player", "debuff") then
        return
    end

	if HasBuffNamed("Time Stop", "player") then
        return
    end

    if IsDruidShapeShifted() then
        return
    end

    if (sandTime == nil or GetTime() - sandTime > 3) then
        sandTime = GetTime()
        UseFromBags("Hourglass Sand")
    end
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local function UsePotionsWhenPossible(potion)
    if not HaveInBags(potion) and not IsItemInBagCoolDown(potion) then
        return
    end

    if HasBuffOrDebuff(potion, "player", "buff") then
        return
    end

    if IsDruidShapeShifted() then
        return
    end

    if (sandTime == nil or GetTime() - sandTime > 3) then
        sandTime = GetTime()
        UseFromBags(potion)
    end
end

function mb_useFrozenRuneOnFaerlina()
    if not MB_myFaerlinaFirePotStrategy then
        return
    end

    if ImBusy() or not InCombat("player") then
		return
	end

    if Instance.Naxx() and not (TankTarget("Grand Widow Faerlina") or UnitName("target") == "Grand Widow Faerlina") then
        return
    end

    UsePotionsWhenPossible("Greater Fire Protection Potion")
end

function mb_useShadowPotsOnLoatheb()
    if not MB_myLoathebShadowPotStrategy then
        return
    end

    if ImBusy() or not InCombat("player") then
		return
	end

    if Instance.Naxx() and not (TankTarget("Loatheb") or UnitName("target") == "Loatheb") then
        return
    end

    UsePotionsWhenPossible("Greater Shadow Protection Potion")
end

function mb_useFirePotsOnVaelastrasz()
    if not MB_myVaelastraszFirePotStrategy then
        return
    end

    if ImBusy() or not InCombat("player") then
		return
	end

    if Instance.BWL() and not (TankTarget("Vaelastrasz the Corrupt") or UnitName("target") == "Vaelastrasz the Corrupt") then
        return
    end

    UsePotionsWhenPossible("Greater Fire Protection Potion")
end

function mb_useNaturePotsOnHuhuran()
    if not MB_myHuhuranNaturePotStrategy then
        return
    end

    if ImBusy() or not InCombat("player") then
		return
	end

    if Instance.AQ40() and not (TankTarget("Princess Huhuran") or UnitName("target") == "Princess Huhuran") then
        return
    end

    if HealthPct("target") > 0.3 then
        return
    end

    UsePotionsWhenPossible("Greater Nature Protection Potion")
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local function UseJujuWhenPossible(juju)
    if not HaveInBags(juju) and not IsItemInBagCoolDown(juju) then
        return
    end

    if HasBuffOrDebuff(juju, "player", "buff") then
        return
    end

    if IsDruidShapeShifted() then
        return
    end

    TargetUnit("player")

    if (sandTime == nil or GetTime() - sandTime > 3) then
        sandTime = GetTime()
        UseFromBags(juju)
    end

    TargetLastTarget()
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local function MeleeSpeedRunPots()
    UsePotionsWhenPossible("Swiftness of Zanza")
    UsePotionsWhenPossible("Flask of the Titans")
    UsePotionsWhenPossible("Elixir of the Mongoose")
    UsePotionsWhenPossible("Gift of Arthas")
    UseJujuWhenPossible("Juju Might")
    UseJujuWhenPossible("Juju Power")
end

local function CasterSpeedRunPots()
    UsePotionsWhenPossible("Swiftness of Zanza")
    UsePotionsWhenPossible("Flask of Supreme Power")
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

local function HealerSpeedRunPots()
    UsePotionsWhenPossible("Swiftness of Zanza")
    UsePotionsWhenPossible("Flask of Distilled Wisdom")
    UsePotionsWhenPossible("Mageblood Potion")
end

function mb_useSpeedRunPots()
    if not MB_mySpeedRunStrategy then
        return
    end

    if not Instance:IsInRaid() then
        return
    end

    if ImBusy() or InCombat("player") then
		return
	end

    if ImHealer() then
        HealerSpeedRunPots()
    elseif ImRangedDPS() then
        CasterSpeedRunPots()
    else
        MeleeSpeedRunPots()
    end
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function mb_takeLIP()
    if not MB_mySpeedRunStrategy then
        return
    end

    if not Instance:IsInRaid() then
        return
    end

    if ImBusy() or InCombat("player") then
		return
	end

    if ImTank() then
        return
    end

    local aggrox = AceLibrary("Banzai-1.0")
	if aggrox:GetUnitAggroByUnitId("player") and HealthPct("player") <= 0.25 then
        UsePotionsWhenPossible("Limited Invulnerability Potion")
	end
end

function mb_takeFAP()
    if not MB_mySpeedRunStrategy then
        return
    end

    if not Instance:IsInRaid() then
        return
    end

    if ImBusy() or InCombat("player") then
		return
	end

    if not ImMeleeDPS() then
        return
    end

    if not BossUseFAPon() then
        return
    end

    UsePotionsWhenPossible("Free Action Potion")
end