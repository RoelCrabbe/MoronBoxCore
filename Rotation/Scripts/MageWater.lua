--[####################################################################################################]--
--[##################################### START MAGE WATER CODE! #######################################]--
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

function mb_makeWater()
    if myClass ~= "Mage" then
        return
    end

    if mb_hasBuffOrDebuff("Evocation", "player", "buff") then
        return
    end

    if mb_imBusy() then
        return
    end

    if mb_manaPct("player") > 0.8 and mb_hasBuffNamed("Drink", "player") then
        DoEmote("Stand")
        return
    end

    if UnitMana("player") < 780 then
        if mb_spellReady("Evocation") then
            mb_evoGear()
            CastSpellByName("Evocation")
            return
        end

        mb_mageGear()
        mb_smartDrink()
    end

    if mb_getAllContainerFreeSlots() > 0 then
        CastSpellByName("Conjure Water")
    else
        mb_cdMessage("My bags are full, can\'t conjure more stuff", 60)
    end
end

function mb_smartDrink()
    if mb_manaPct("player") > 0.99 and mb_hasBuffNamed("Drink", "player") then
        DoEmote("Stand")
        return
    end

    if not mb_manaUser() then
        return
    end

    if myClass == "Mage" and MB_tradeOpen then
        if mb_mageWater() > 20 and GetTradePlayerItemLink(1) and string.find(GetTradePlayerItemLink(1), "Conjured.*Water") then
            return
        end

        if mb_mageWater() < 21 and GetTradePlayerItemLink(1) and string.find(GetTradePlayerItemLink(1), "Conjured.*Water") then
            mb_cdPrint("Not enough water to trade!")
            CancelTrade()
            return
        end
    end

    if myClass ~= "Mage" and not MB_tradeOpen then
        local waterMage = mb_isMageInGroup()
        if waterMage then
            if mb_mageWater() < 1 and mb_manaUser() then
                if mb_isAlive(MBID[waterMage]) and mb_inTradeRange(MBID[waterMage]) then
                    TargetByName(waterMage, 1)

                    if not MB_tradeOpen then
                        InitiateTrade("target")
                    end
                end
            end
        end
    end

    if myClass == "Mage" and MB_tradeOpen then
        if mb_mageWater() > 21 and mb_pickUpWater() then
            mb_cdPrint("Trading Water")
            ClickTradeButton(1)
            return
        end
    end

    if mb_hasBuffOrDebuff("Evocation", "player", "buff") then
        return
    end

    if myClass == "Mage" then
        mb_mageGear()
    end

    local _, myBest = mb_mageWater()
    if not mb_hasBuffNamed("Drink", "player") and myBest then
        if mb_manaUser() and mb_manaDown() > 0 then
            mb_useFromBags(myBest)
        end
    end
end
