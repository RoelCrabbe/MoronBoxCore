-- [[ Config & Constants ]] --

MoronBox.Unit = MoronBox.Unit or {}
local Unit = MoronBox.Unit

MoronBox.Core.Raid = MoronBox.Core.Raid or {}
local Raid = MoronBox.Core.Raid

MoronBox.Core.Decurse = MoronBox.Core.Decurse or {}
local Decurse = MoronBox.Core.Decurse

local myClass = UnitClass("player") --[[@as string]]
local myName = UnitName("player") --[[@as string]]
local myRace = UnitRace("player") --[[@as string]]

-- [[ Decurse ]] --

function Decurse.Decurse()
    if not MBD then
        return false
    end

    if Instance.ZG() then
        if Raid.IsAtJindo() and (myClass == "Mage" or myClass == "Druid") then
            return false
        end
    elseif Instance.BWL() then
        if Raid.TankTarget("Chromaggus") and MB_myAssignedHealTarget then
            return false
        end
    end

    if (SKERAM_InFight() or LOA_IsAtLoatheb() or GROB_IsAtGrobbulus()
            or Raid.TankTarget("Vaelastrasz the Corrupt") or Raid.TankTarget("Princess Huhuran")
            or Raid.TankTarget("Garr") or Raid.TankTarget("Firesworn") or Raid.TankTarget("Anubisath Guardian")) then
        return false
    end

    if not MBD.Session.Spells.HasSpells or UnitMana("player") < 320 or mb_imBusy() then
        return false
    end

    if (Decurse_wait == nil or GetTime() - Decurse_wait > 0.15) then
        Decurse_wait = GetTime()

        local numMembers = UnitInRaid("player") and GetNumRaidMembers() or GetNumPartyMembers()
        local prefix = UnitInRaid("player") and "raid" or "party"

        for i = 1, numMembers do
            local unit = prefix .. i
            for j = 1, 16 do
                local _, _, debuffType = UnitDebuff(unit, j, 1)

                if debuffType and Unit.In28yardRange(unit) then
                    local canCure = (debuffType == "Curse" and MBD.Session.Spells.Curse.Can_Cure_Curse) or
                        (debuffType == "Magic" and (MBD.Session.Spells.Magic.Can_Cure_Magic or MBD.Session.Spells.Magic.Can_Cure_Enemy_Magic)) or
                        (debuffType == "Poison" and MBD.Session.Spells.Poison.Can_Cure_Poison) or
                        (debuffType == "Disease" and MBD.Session.Spells.Disease.Can_Cure_Disease)

                    if canCure then
                        MBD_Clean()
                        return true
                    end
                end
            end
        end
    end
    return false
end

function Decurse.PartyIsPoisoned()
    if Raid.TankTarget("Princess Huhuran") or GROB_IsAtGrobbulus() then
        return false
    end

    local numMembers = GetNumPartyMembers()
    for i = 1, numMembers do
        for x = 1, 16 do
            local _, _, debuffType = UnitDebuff("party" .. i, x, 1)
            if debuffType == "Poison" then
                return true
            end
        end
    end

    for x = 1, 16 do
        local _, _, debuffType = UnitDebuff("player", x, 1)
        if debuffType == "Poison" then
            return true
        end
    end

    return false
end

function Decurse.RaidIsPoisoned()
    if Raid.TankTarget("Princess Huhuran") or GROB_IsAtGrobbulus() then
        return false
    end

    local numMembers = GetNumRaidMembers()
    for i = 1, numMembers do
        for x = 1, 16 do
            local _, _, debuffType = UnitDebuff("raid" .. i, x, 1)
            if debuffType == "Poison" then
                return true
            end
        end
    end

    return false
end

function Decurse.PlayerIsPoisoned()
    if Raid.TankTarget("Princess Huhuran") or GROB_IsAtGrobbulus() then
        return false
    end

    for i = 1, 16 do
        local _, _, debuffType = UnitDebuff("player", i)
        if debuffType == "Poison" then
            return true
        end
    end

    return false
end

function Decurse.PartyIsDiseased()
    local numMembers = GetNumPartyMembers()
    for i = 1, numMembers do
        for x = 1, 16 do
            local _, _, debuffType = UnitDebuff("party" .. i, x, 1)
            if debuffType == "Disease" then
                return true
            end
        end
    end

    for x = 1, 16 do
        local _, _, debuffType = UnitDebuff("player", x, 1)
        if debuffType == "Disease" then
            return true
        end
    end

    return false
end
