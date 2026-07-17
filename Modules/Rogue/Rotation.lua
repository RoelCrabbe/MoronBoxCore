-- [[ Rogue Rotation ]] --

local NAME = "Rogue Rotation"
local MODULE_NAME = "MODULE_" .. string.upper(string.gsub(NAME, " ", "_"))

local myClass = UnitClass("player")

MoronBox:RegisterModule(MODULE_NAME, function()
    local RemoveBuffs = {
        ["Arcane Intellect"]  = "Arcane Intellect",
        ["Arcane Brilliance"] = "Arcane Brilliance",
        ["Divine Spirit"]     = "Divine Spirit",
        ["Prayer of Spirit"]  = "Prayer of Spirit",
        ["Slip'kik's Savvy"]  = "Slip'kik's Savvy",
        ["Fury of Ragnaros"]  = "Fury of Ragnaros",
        ["Very Berry Cream"]  = "Very Berry Cream",
        ["Sweet Surprise"]    = "Sweet Surprise",
    }

    local function ImprovedExpose()
        local _, _, _, _, TalentsIn = GetTalentInfo(1, 8)
        return TalentsIn == 2
    end

    local function PoisonMainHand()
        if not getBag().HaveInBags("Instant Poison VI") then
            return
        end

        local _, _, _, hasEnchantOff = GetWeaponEnchantInfo()

        if not hasEnchantOff then
            UseItemByName("Instant Poison VI")
            PickupInventoryItem(17)
            ClearCursor()
        end
    end

    local function PoisonOffhand()
        if not getBag().HaveInBags("Instant Poison VI") then
            return
        end

        local _, _, _, hasEnchantOff = GetWeaponEnchantInfo()

        if not hasEnchantOff then
            UseItemByName("Instant Poison VI")
            PickupInventoryItem(17)
            ClearCursor()
        end
    end

    local function Cooldowns()
        if getSpells().ImBusy() or not getUnit().InCombat() then
            return
        end

        if getSpells().IsSpellReady("Blade Flurry") and getAura().HasBuffOrDebuff("Slice and Dice", "player", "buff") then
            CastSpellByName("Blade Flurry")
        end

        getSpells().SelfBuff("Berserking")
        getSpells().SelfBuff("Blood Fury")

        if getSpells().IsSpellReady("Adrenaline Rush") then
            CastSpellByName("Adrenaline Rush")
        end
    end

    local function Single()
        getRaid().GetTarget()
        getAura().CancelAuraSet(RemoveBuffs)

        if not getUnit().InCombat("target") then
            return
        end

        if getConfigState().UseCooldowns.Active then
            Cooldowns()
        end

        getAttack().AutoAttack()

        if getUnit().InCombat() and UnitMana("player") <= 40 then
            if getBag().ItemNameOfEquippedSlot(13) == "Renataki\'s Charm of Trickery" and not getBag().TrinketOnCD(13) then
                use(13)
            elseif getBag().ItemNameOfEquippedSlot(14) == "Renataki\'s Charm of Trickery" and not getBag().TrinketOnCD(14) then
                use(14)
            end
        end

        if getConfigState().DoInterrupt.Active and getSpells().IsSpellReady(getConfigState().InterruptSpell[myClass]) then
            if UnitMana("player") >= 25 then
                if getConfigState().InterruptTarget then
                    getRaid().GetMyInterruptTarget()
                end

                if getSpells().ImBusy() then
                    SpellStopCasting()
                end

                CastSpellByName(getConfigState().InterruptSpell[myClass])
                getApi().CdPrint("Interrupting!")
                getConfigState().DoInterrupt.Active = false
                return
            end
        end

        local aggrox = AceLibrary("Banzai-1.0")
        if aggrox and aggrox:GetUnitAggroByUnitId("player") then
            if getUnit().HealthPct() < 0.8 and getSpells().IsSpellReady("Evasion") then
                CastSpellByName("Evasion")
                return
            elseif getUnit().HealthPct() < 0.45 and getSpells().IsSpellReady("Vanish") then
                CastSpellByName("Vanish")
                return
            end
        end

        if not getUnit().InMeleeRange() then
            return
        end

        local cp = GetComboPoints("target")
        if getSpells().IsSpellReady("Kidney Shot") and cp >= 3 and getTables().StunnableMob() then
            CastSpellByName("Kidney Shot")
        end

        if getSpells().IsSpellReady("Blade Flurry") and getAura().HasBuffOrDebuff("Slice and Dice", "player", "buff") then
            CastSpellByName("Blade Flurry")
        end

        if (getAura().GetSunderAmount() == 5 or getAura().HasBuffOrDebuff("Expose Armor", "target", "debuff"))
            and (getUnit().InMeleeRange() or getRaid().TankTarget("Ragnaros")) then
            if Instance.IsWorldBoss() then
                Cooldowns()
            end

            getBag().MeleeTrinkets()
        end

        local hasImprovedEA = ImprovedExpose()
        if not getAura().HasBuffOrDebuff("Slice and Dice", "player", "buff") then
            if hasImprovedEA then
                if cp == 2 and getAura().HasBuffOrDebuff("Expose Armor", "target", "debuff") then
                    CastSpellByName("Slice and Dice")
                end
            elseif cp >= 1 then
                CastSpellByName("Slice and Dice")
            end
        end

        if cp > 4 then
            if hasImprovedEA and Instance.IsWorldBoss() then
                CastSpellByName("Expose Armor")
            else
                CastSpellByName("Eviscerate")
            end
        end

        if getConfigState().PlayerSpecc == "Hemo" then
            CastSpellByName("Hemorrhage")
            return
        end

        CastSpellByName("Sinister Strike")
    end

    MoronBox:RegisterExpose({
        Specc = function()
            local _, _, _, _, hemo = GetTalentInfo(3, 15)
            local _, _, _, _, ar = GetTalentInfo(2, 19)

            if hemo > 0 then
                getConfigState().PlayerSpecc = "Hemo"
            elseif ar > 0 then
                getConfigState().PlayerSpecc = "AR"
            else
                getConfigState().PlayerSpecc = nil
            end
        end,
        Setup = function()
            if not Faction.IsHorde() then
                PoisonMainHand()
            end

            PoisonOffhand()
        end,
        Single = Single,
        Multi = Single,
        AOE = Single
    })
end, function()
    return myClass == "Rogue"
end)
