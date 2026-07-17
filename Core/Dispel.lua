-- [[ Config & Constants ]] --

MoronBox.Core.Dispel = MoronBox.Core.Dispel or {}

local myClass = UnitClass("player")

function getDispel()
    return MoronBox.Core.Dispel
end

-- [[ Decurse ]] --

function MoronBox.Core.Dispel.Decurse()
    if not MBD then
        return false
    end

    if Instance.ZG() then
        if getRaid().IsAtJindo() and (myClass == "Mage" or myClass == "Druid") then
            return false
        end
    elseif Instance.BWL() then
        if getRaid().TankTarget("Chromaggus") and MB_myAssignedHealTarget then
            return false
        end
    end

    if Instance.NAXX() and (LOA_IsAtLoatheb() or GROB_IsAtGrobbulus()) then
        return false
    end

    if Instance.AQ40() and (SKERAM_InFight() or getRaid().TankTarget("Princess Huhuran")) then
        return false
    end

    if Instance.BWL() and getRaid().TankTarget("Vaelastrasz the Corrupt") then
        return false
    end

    if Instance.MC() and (getRaid().TankTarget("Garr") or getRaid().TankTarget("Firesworn")) then
        return false
    end

    if not MBD.Session.Spells.HasSpells or UnitMana("player") < 320 or getSpells().ImBusy() then
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

                if debuffType and getUnit().In28yardRange(unit) then
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

function MoronBox.Core.Dispel.PartyIsPoisoned()
    if Instance.NAXX() and GROB_IsAtGrobbulus() then
        return false
    end

    if Instance.AQ40() and getRaid().TankTarget("Princess Huhuran") then
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

function MoronBox.Core.Dispel.RaidIsPoisoned()
    if Instance.NAXX() and GROB_IsAtGrobbulus() then
        return false
    end

    if Instance.AQ40() and getRaid().TankTarget("Princess Huhuran") then
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

function MoronBox.Core.Dispel.PlayerIsPoisoned()
    if Instance.NAXX() and GROB_IsAtGrobbulus() then
        return false
    end

    if Instance.AQ40() and getRaid().TankTarget("Princess Huhuran") then
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

function MoronBox.Core.Dispel.PartyIsDiseased()
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
