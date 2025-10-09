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

local MageWater = {
	[60] = "Conjured Crystal Water",
	[50] = "Conjured Sparkling Water"
}

function mb_mageWater()
	local waterRanks = TableInvert(MageWater)
	local bestRank = 1
	local bestWater = nil
	local count = 0
	local bag, slot, link

	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			local texture, itemCount, _, _, _, _, link = GetContainerItemInfo(bag, slot)
			
			if texture then
				link = GetContainerItemLink(bag, slot)
				_, stack = GetContainerItemInfo(bag, slot)
				local bsNum = string.gsub(link, ".-\124H([^\124]*)\124h.*", "%1")
				local itemName, itemNo, itemRarity, itemReqLevel, itemType, itemSubType, itemCount, itemEquipLoc, itemIcon = GetItemInfo(bsNum)
				
				if FindInTable(MageWater, itemName) then
					if waterRanks[itemName] > bestRank then
						bestWater = itemName
						bestRank = waterRanks[itemName]
						count = stack
					elseif waterRanks[itemName] == bestRank then
						count = count + stack
					end
				end
			end
		end 
	end
	return count, bestWater
end

function mb_pickUpWater()
	local waterRanks = TableInvert(MageWater)
	local amount = 0
	local bestRank = 1
	local bag, slot, link

	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			local texture, _, _, _, _, _, link = GetContainerItemInfo(bag, slot)
			
			if texture then
				link = GetContainerItemLink(bag, slot)
				local bsNum = string.gsub(link, ".-\124H([^\124]*)\124h.*", "%1")
				local itemName, _, _, _, _, _, _, _, _ = GetItemInfo(bsNum)
				
                if FindInTable(MageWater, itemName) then
					if waterRanks[itemName] > bestRank then						
						bestRank = waterRanks[itemName]
						bestWater = itemName.." "..bag.." "..slot
					end
				end
			end 
		end 
	end

	if bestRank > 0 then
		local _ , _, water, bag, slot = string.find(bestWater, "(Conjured.*Water) (%d+) (%d+)")		
		mb_cdPrint("Found "..water.." in bag "..bag.." in slot "..slot)
		PickupContainerItem(bag, slot)
		return water
	end
end

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
    "Greater Arcane Protection Potion",
    "Greater Fire Protection Potion",
    "Greater Nature Protection Potion",
    "Greater Shadow Protection Potion",
    "Limited Invulnerability Potion",
    "Noggenfogger Elixir",
    "Spirit of Zanza",
    "Swiftness of Zanza"
}

local ClassSpecificReagents = {
    ["Druid"] = {
        "Tea with Sugar",
        "Flask of Distilled Wisdom",
        "Ironwood Seed",
        "Major Mana Potion",
        "Mageblood Potion",
        "Wild Thornroot",
        "Conjured Crystal Water",
        "Lung Juice Cocktail",
        "Gizzard Gum",
        "Cerebral Cortex Compound"
    },
    ["Hunter"] = {
        "Tea with Sugar",
        "Doomshot",
        "Flask of the Titans",
        "Major Mana Potion",
        "Elixir of the Mongoose",
        "Juju Might",
        "Juju Power",
        "Conjured Crystal Water",
        "R.O.I.D.S.",
        "Lung Juice Cocktail",
        "Ground Scorpok Assay",
        "Cerebral Cortex Compound"
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
        "Conjured Crystal Water",
        "Lung Juice Cocktail",
        "Gizzard Gum",
        "Cerebral Cortex Compound"
    },
    ["Paladin"] = {
        "Tea with Sugar",
        "Flask of Distilled Wisdom",
        "Major Mana Potion",
        "Mageblood Potion",
        "Symbol of Divinity",
        "Symbol of Kings",
        "Conjured Crystal Water",
        "Lung Juice Cocktail",
        "Gizzard Gum",
        "Cerebral Cortex Compound"
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
        "Conjured Crystal Water",
        "Lung Juice Cocktail",
        "Gizzard Gum",
        "Cerebral Cortex Compound"
    },
    ["Rogue"] = {
        "Flash Powder",
        "Flask of the Titans",
        "Elixir of the Mongoose",
        "Juju Might",
        "Juju Power",
        "Free Action Potion",
        "R.O.I.D.S.",
        "Lung Juice Cocktail",
        "Ground Scorpok Assay",
        "Frozen Rune"
    },
    ["Shaman"] = {
        "Ankh",
        "Tea with Sugar",
        "Flask of Distilled Wisdom",
        "Major Mana Potion",
        "Mageblood Potion",
        "Conjured Crystal Water",
        "Lung Juice Cocktail",
        "Gizzard Gum",
        "Cerebral Cortex Compound"
    },
    ["Warlock"] = {
        "Tea with Sugar",
        "Flask of Supreme Power",
        "Major Mana Potion",
        "Mageblood Potion",
        "Greater Arcane Elixir",
        "Elixir of Shadow Power",
        "Conjured Crystal Water",
        "Lung Juice Cocktail",
        "Gizzard Gum",
        "Cerebral Cortex Compound"
    },
    ["Warrior"] = {
        "Dirge's Kickin' Chimaerok Chops",
        "Doomshot",
        "Elixir of the Mongoose",
        "Flask of the Titans",
        "Gift of Arthas",
        "Greater Stoneshield Potion",
        "Juju Might",
        "Juju Power",
        "Miniature Cannon Balls",
        "Rumsey Rum Black Label",
        "Free Action Potion",
        "Mighty Rage Potion",
        "R.O.I.D.S.",
        "Lung Juice Cocktail",
        "Ground Scorpok Assay",
        "Frozen Rune",
        "Juju Escape"
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
    ["Spirit of Zanza"] = { 1, 1 },
    ["Onyxia Scale Cloak"] = { 1, 1 },

    ["Conjured Crystal Water"] = { 80, 1 },
    ["Noggenfogger Elixir"] = { 200, 1 },

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
    ["Greater Shadow Protection Potion"] = { 40, 1 },
    ["Greater Fire Protection Potion"] = { 10, 1 },
    ["Greater Arcane Protection Potion"] = { 10, 1 },
    ["Frozen Rune"] = { 5, 1 },

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
    ["Juju Escape"] = { 20, 1 },
    
    -- Food & Drink Buffs
    ["Dirge's Kickin' Chimaerok Chops"] = { 8, 1 },
    ["Rumsey Rum Black Label"] = { 20, 1 },
    
    -- Tank/Survivability
    ["Gift of Arthas"] = { 10, 1 },
    ["Greater Stoneshield Potion"] = { 40, 1 },
    
    -- Ammunition/Projectiles (Special Stack Size)
    ["Doomshot"] = { 1, 2 },
    ["Miniature Cannon Balls"] = { 1, 2 },

    -- Other
    ["Free Action Potion"] = { 5, 1 },
    ["Limited Invulnerability Potion"] = { 10, 1 },
    ["Mighty Rage Potion"] = { 20, 1 },

    -- ========================================
    -- SPECIAL CONSUMABLES
    -- ========================================
    ["R.O.I.D.S."] = { 1, 1 },
    ["Lung Juice Cocktail"] = { 1, 1 },
    ["Cerebral Cortex Compound"] = { 1, 1 },
    ["Gizzard Gum"] = { 1, 1 },
    ["Ground Scorpok Assay"] = { 1, 1 }
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
    local freeSlots = mb_getAllContainerFreeSlots()
    if freeSlots <= 5 then
        mb_cdMessage("I don't have enough bagspace to buy consumables, sort it!")
        return
    end

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
                elseif item == "Noggenfogger Elixir" then
                    myNeededItems = math.floor(myNeededItems / 5)
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
    { name = "Tea with Sugar", threshold = 1750 },
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

local ManaRunesThreshold = {
    { name = "Tea with Sugar", threshold = 1750 }
}

local function UseManaRunesThresholdRunes()
    local manaDown = mb_manaDown()
    for _, item in ipairs(ManaRunesThreshold) do
        if manaDown > item.threshold and mb_haveInBags(item.name) and not mb_isItemInBagCoolDown(item.name) then
            UseItemByName(item.name)
            return
        end
    end
end

function mb_takeManaPotionAndRunes()
    if mb_imBusy() or not mb_inCombat("player") then
		return
	end

    if Instance.NAXX() and LOA_IsAtLoatheb() then
        UseManaRunesThresholdRunes()
        return
    end

    UseManaPotsThresholdPots()
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function mb_useSandsOnChromaggus()
	if mb_imBusy() or not mb_inCombat("player") then
		return
	end

	if Instance.BWL() and not mb_tankTarget("Chromaggus") then
        return
    end

	if not mb_imTank() then
        return
    end

    if not mb_imFocus() then
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

    if (sandTime == nil or GetTime() - sandTime > 3) then
        sandTime = GetTime()
        mb_useFromBags("Hourglass Sand")
    end
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function mb_takePotionsWhenPossible(potion)
    if not mb_haveInBags(potion) and not mb_isItemInBagCoolDown(potion) then
        return
    end

    if mb_hasBuffOrDebuff(potion, "player", "buff") then
        return
    end

    if mb_isDruidShapeShifted() then
        return
    end

    if (sandTime == nil or GetTime() - sandTime > 3) then
        sandTime = GetTime()
        mb_useFromBags(potion)
    end
end

function mb_useFirePotsOnFaerlina()
    if not MB_myFaerlinaFirePotStrategy then
        return
    end

    if mb_imBusy() or not mb_inCombat("player") then
		return
	end

    if Instance.NAXX() and not (mb_tankTarget("Grand Widow Faerlina") or UnitName("target") == "Grand Widow Faerlina") then
        return
    end

    mb_takePotionsWhenPossible("Greater Fire Protection Potion")
end

function mb_useFirePotsOnVaelastrasz()
    if not MB_myVaelastraszFirePotStrategy then
        return
    end

    if mb_imBusy() or not mb_inCombat("player") then
		return
	end

    if Instance.BWL() and not (mb_tankTarget("Vaelastrasz the Corrupt") or UnitName("target") == "Vaelastrasz the Corrupt") then
        return
    end

    mb_takePotionsWhenPossible("Greater Fire Protection Potion")
end

function mb_useNaturePotsOnHuhuran()
    if not MB_myHuhuranNaturePotStrategy then
        return
    end

    if mb_imBusy() or not mb_inCombat("player") then
		return
	end

    if Instance.AQ40() and not (mb_tankTarget("Princess Huhuran") or UnitName("target") == "Princess Huhuran") then
        return
    end

    if mb_healthPct("target") > 0.3 then
        return
    end

    mb_takePotionsWhenPossible("Greater Nature Protection Potion")
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function mb_takeJujuWhenPossible(juju)
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

    if (sandTime == nil or GetTime() - sandTime > 3) then
        sandTime = GetTime()
        mb_useFromBags(juju)
    end

    TargetLastTarget()
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local function ZanzaPotions()
    if Instance.NAXX() then
        mb_takePotionsWhenPossible("Spirit of Zanza")
    else
        mb_takePotionsWhenPossible("Swiftness of Zanza")
    end
end

local function ProtectionPotions()
    if Instance.NAXX() and LOA_IsAtLoatheb() then
        mb_takePotionsWhenPossible("Greater Shadow Protection Potion")
    end
end

local function MeleeSpeedRunPots()
    ZanzaPotions()
    ProtectionPotions()

    mb_takePotionsWhenPossible("Flask of the Titans")
    mb_takePotionsWhenPossible("Elixir of the Mongoose")

    mb_takeJujuWhenPossible("Juju Might")
    mb_takeJujuWhenPossible("Juju Power")
end

local function CasterSpeedRunPots()
    ZanzaPotions()
    ProtectionPotions()

    mb_takePotionsWhenPossible("Flask of Supreme Power")
    mb_takePotionsWhenPossible("Mageblood Potion")
    mb_takePotionsWhenPossible("Greater Arcane Elixir")

    if myClass == "Mage" then
        if MB_mySpecc == "Frost" then
            mb_takePotionsWhenPossible("Elixir of Frost Power")            
        else
            mb_takePotionsWhenPossible("Elixir of Greater Firepower")
        end
    elseif myClass == "Warlock" then
        mb_takePotionsWhenPossible("Elixir of Shadow Power")
    end
end

local function HealerSpeedRunPots()
    ZanzaPotions()
    ProtectionPotions()

    mb_takePotionsWhenPossible("Flask of Distilled Wisdom")
    mb_takePotionsWhenPossible("Mageblood Potion")
end

function mb_useSpeedRunPots()
    if not MB_mySpeedRunStrategy then
        return
    end

    if not Instance:IsInRaid() then
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

    if mb_imBusy() or mb_inCombat("player") then
		return
	end

    if mb_imTank() then
        return
    end

    local aggrox = AceLibrary("Banzai-1.0")
	if aggrox:GetUnitAggroByUnitId("player") and mb_healthPct("player") <= 0.25 then
        mb_takePotionsWhenPossible("Limited Invulnerability Potion")
	end
end

function mb_takeFAP()
    if not MB_mySpeedRunStrategy then
        return
    end

    if not Instance:IsInRaid() then
        return
    end

    if mb_imBusy() or mb_inCombat("player") then
		return
	end

    if not mb_imMeleeDPS() then
        return
    end

    if not mb_bossUseFAPon() then
        return
    end

    mb_takePotionsWhenPossible("Free Action Potion")
end