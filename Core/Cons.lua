-- [[ Config & Constants ]] --

MoronBox.Core.Cons = MoronBox.Core.Cons or {}

local myClass = UnitClass("player")
local myName = UnitName("player")
local myRace = UnitRace("player")

function getCons()
    return MoronBox.Core.Cons
end

-- [[ Cons ]] --

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

local ManaPotsThreshold = {
    { name = "Major Mana Potion", threshold = 2250 },
    { name = "Tea with Sugar",    threshold = 1750 },
    { name = "Demonic Rune",      threshold = 1500 },
    { name = "Dark Rune",         threshold = 1500 },
}

local ManaRunesThreshold = {
    { name = "Tea with Sugar", threshold = 1750 }
}

-- [[ Cons Functions ]] --

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

function MoronBox.Core.Cons.BuyReagentsAndConsumables()
    local freeSlots = getBag().GetAllContainerFreeSlots()
    if freeSlots <= 5 then
        getApi().CdMessage("I don't have enough bagspace to buy consumables, sort it!")
        return
    end

    local classItems = GetCompleteReagentList(myClass)

    if classItems then
        for _, item in ipairs(classItems) do
            -- TODO CHECK: myCurrentItems en myNeededItems delen hier allebei door
            -- ReagentsLimit[item][2]. Voor items met [2] == 1 (de meeste) maakt dit
            -- niks uit. Voor Doomshot/Miniature Cannon Balls ([2] == 2) leidt dit
            -- tot een dubbele deling die mogelijk een te laag aankoopaantal geeft.
            -- Bevestig in-game of BuyMerchantItem hier stuks of stacks verwacht
            -- voor deze twee items voor je hierop vertrouwt.
            local myCurrentItems = getBag().HasItem(item) / ReagentsLimit[item][2]
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
                            getApi().CdPrint("Buying " .. myNeededItems .. " " .. merchantItemLink)
                            BuyMerchantItem(itemID, myNeededItems)
                        end
                    end
                end
            end
        end
    end
end

-- [[ Mana Potions ]] --

local function UseThresholdItem(thresholdList)
    local manaDown = getUnit().ManaDown()
    for _, item in ipairs(thresholdList) do
        if manaDown > item.threshold and getBag().HaveInBags(item.name) and not getBag().IsItemInBagCoolDown(item.name) then
            UseItemByName(item.name)
            return
        end
    end
end

function MoronBox.Core.Cons.TakeManaPotionAndRunes()
    if getSpells().ImBusy() or not getUnit().InCombat() then
        return
    end

    if Instance.NAXX() and LOA_IsAtLoatheb() then
        UseThresholdItem(ManaRunesThreshold)
        return
    end

    UseThresholdItem(ManaPotsThreshold)
end

-- [[ Chrom Sand ]] --

local lastSandTime

function MoronBox.Core.Cons.SandsOnChromaggus()
    if getSpells().ImBusy() or not getUnit().InCombat() then
        return
    end

    if Instance.BWL() and not getRaid().TankTarget("Chromaggus") then
        return
    end

    if not getCore().ImTank() then
        return
    end

    if not getRaid().ImFocus() then
        return
    end

    if not getAura().HasBuffOrDebuff("Brood Affliction: Bronze", "player", "debuff") then
        return
    end

    if getAura().HasBuffNamed("Time Stop", "player") then
        return
    end

    if getUnit().IsDruidShapeShifted() then
        return
    end

    if not lastSandTime or GetTime() - lastSandTime > 3 then
        lastSandTime = GetTime()
        getBag().UseFromBags("Hourglass Sand")
    end
end

-- [[ Combat Potions ]] --

local lastPotionTime

function MoronBox.Core.Cons.PotionsWhenPossible(potion)
    if not getBag().HaveInBags(potion) or getBag().IsItemInBagCoolDown(potion) then
        return
    end

    if getAura().HasBuffOrDebuff(potion, "player", "buff") then
        return
    end

    if getUnit().IsDruidShapeShifted() then
        return
    end

    if not lastPotionTime or GetTime() - lastPotionTime > 3 then
        lastPotionTime = GetTime()
        getBag().UseFromBags(potion)
    end
end

function MoronBox.Core.Cons.FirePotsOnFaerlina()
    if not getEncountersState().Faerlina.FirePots then
        return
    end

    if getSpells().ImBusy() or not getUnit().InCombat() then
        return
    end

    if Instance.NAXX() and not (getRaid().TankTarget("Grand Widow Faerlina") or UnitName("target") == "Grand Widow Faerlina") then
        return
    end

    getCons().PotionsWhenPossible("Greater Fire Protection Potion")
end

function MoronBox.Core.Cons.FirePotsOnVaelastrasz()
    if not getEncountersState().Vaelastrasz.FirePots then
        return
    end

    if getSpells().ImBusy() or not getUnit().InCombat() then
        return
    end

    if Instance.BWL() and not (getRaid().TankTarget("Vaelastrasz the Corrupt") or UnitName("target") == "Vaelastrasz the Corrupt") then
        return
    end

    getCons().PotionsWhenPossible("Greater Fire Protection Potion")
end

function MoronBox.Core.Cons.NaturePotsOnHuhuran()
    if not getEncountersState().Huhuran.NaturePots then
        return
    end

    if getSpells().ImBusy() or not getUnit().InCombat() then
        return
    end

    if Instance.AQ40() and not (getRaid().TankTarget("Princess Huhuran") or UnitName("target") == "Princess Huhuran") then
        return
    end

    if getUnit().HealthPct("target") > 0.3 then
        return
    end

    getCons().PotionsWhenPossible("Greater Nature Protection Potion")
end

-- [[ Jujus ]] --

local lastJujuTime

function MoronBox.Core.Cons.JujuWhenPossible(juju)
    if not getBag().HaveInBags(juju) or getBag().IsItemInBagCoolDown(juju) then
        return
    end

    if getAura().HasBuffOrDebuff(juju, "player", "buff") then
        return
    end

    if getUnit().IsDruidShapeShifted() then
        return
    end

    TargetUnit("player")

    if not lastJujuTime or GetTime() - lastJujuTime > 3 then
        lastJujuTime = GetTime()
        getBag().UseFromBags(juju)
    end

    TargetLastTarget()
end

-- [[ SpeedRun Potions ]] --

local function ZanzaPotions()
    if Instance.NAXX() then
        getCons().PotionsWhenPossible("Spirit of Zanza")
    else
        getCons().PotionsWhenPossible("Swiftness of Zanza")
    end
end

local function ProtectionPotions()
    if Instance.NAXX() and LOA_IsAtLoatheb() then
        getCons().PotionsWhenPossible("Greater Shadow Protection Potion")
    end
end

local function MeleeSpeedRunPots()
    ZanzaPotions()
    ProtectionPotions()

    getCons().PotionsWhenPossible("Flask of the Titans")
    getCons().PotionsWhenPossible("Elixir of the Mongoose")

    getCons().JujuWhenPossible("Juju Might")
    getCons().JujuWhenPossible("Juju Power")
end

local function CasterSpeedRunPots()
    ZanzaPotions()
    ProtectionPotions()

    getCons().PotionsWhenPossible("Flask of Supreme Power")
    getCons().PotionsWhenPossible("Mageblood Potion")
    getCons().PotionsWhenPossible("Greater Arcane Elixir")

    if myClass == "Mage" then
        if getConfigState().PlayerSpecc == "Frost" then
            getCons().PotionsWhenPossible("Elixir of Frost Power")
        else
            getCons().PotionsWhenPossible("Elixir of Greater Firepower")
        end
    elseif myClass == "Warlock" then
        getCons().PotionsWhenPossible("Elixir of Shadow Power")
    end
end

local function HealerSpeedRunPots()
    ZanzaPotions()
    ProtectionPotions()

    getCons().PotionsWhenPossible("Flask of Distilled Wisdom")
    getCons().PotionsWhenPossible("Mageblood Potion")
end

function MoronBox.Core.Cons.SpeedRunPots()
    if not getSettingsState().SpeedRunEnabled then
        return
    end

    if not Instance:IsInRaid() then
        return
    end

    if getSpells().ImBusy() or getUnit().InCombat() then
        return
    end

    if getCore().ImHealer() then
        HealerSpeedRunPots()
    elseif getCore().ImRangedDPS() then
        CasterSpeedRunPots()
    else
        MeleeSpeedRunPots()
    end
end

-- [[ Lip & Fap ]] --

function MoronBox.Core.Cons.UseLIP()
    if not getSettingsState().SpeedRunEnabled then
        return
    end

    if not Instance:IsInRaid() then
        return
    end

    if getSpells().ImBusy() then
        return
    end

    if getCore().ImTank() then
        return
    end

    local aggrox = AceLibrary("Banzai-1.0")
    if aggrox:GetUnitAggroByUnitId("player") and getUnit().HealthPct() <= 0.25 then
        getCons().PotionsWhenPossible("Limited Invulnerability Potion")
    end
end

function MoronBox.Core.Cons.UseFAP()
    if not getSettingsState().SpeedRunEnabled then
        return
    end

    if not Instance:IsInRaid() then
        return
    end

    if getSpells().ImBusy() then
        return
    end

    if not getCore().ImMeleeDPS() then
        return
    end

    if not getTables().BossUseFAPon() then
        return
    end

    getCons().PotionsWhenPossible("Free Action Potion")
end
