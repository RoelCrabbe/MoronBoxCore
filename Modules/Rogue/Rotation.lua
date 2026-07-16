-- [[ Warrior Rotation ]] --
---@diagnostic disable: undefined-global

local NAME = "Warrior Rotation"
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

    local function CancelAuras()
        for itemName, buffName in pairs(RemoveBuffs) do
            if HasBuffOrDebuff(itemName, "player", "buff") then
                CancelBuff(buffName)
            end
        end
    end

    local function ImprovedExpose()
        local _, _, _, _, TalentsIn = GetTalentInfo(1, 8)
        return TalentsIn == 2
    end

    local function PoisonMainHand()
        if not HaveInBags("Instant Poison VI") then
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
        if ImBusy() or not InCombat() then
            return
        end

        if IsSpellReady("Blade Flurry") and HasBuffOrDebuff("Slice and Dice", "player", "buff") then
            CastSpellByName("Blade Flurry")
        end

        SelfBuff("Berserking")
        SelfBuff("Blood Fury")

        if IsSpellReady("Adrenaline Rush") then
            CastSpellByName("Adrenaline Rush")
        end
    end

    local function Single()
        GetTarget()
        CancelAuras()

        if not InCombat("target") then
            return
        end

        if ConfigState.UseCooldowns.Active then
            Cooldowns()
        end

        AutoAttack()

        if InCombat() and UnitMana("player") <= 40 then
            if ItemNameOfEquippedSlot(13) == "Renataki\'s Charm of Trickery" and not TrinketOnCD(13) then
                use(13)
            elseif ItemNameOfEquippedSlot(14) == "Renataki\'s Charm of Trickery" and not TrinketOnCD(14) then
                use(14)
            end
        end

        if ConfigState.DoInterrupt.Active and IsSpellReady(ConfigState.InterruptSpell[myClass]) then
            if UnitMana("player") >= 25 then
                if ConfigState.InterruptTarget then
                    GetMyInterruptTarget()
                end

                if ImBusy() then
                    SpellStopCasting()
                end

                CastSpellByName(ConfigState.InterruptSpell[myClass])
                CdPrint("Interrupting!")
                ConfigState.DoInterrupt.Active = false
                return
            end
        end

        local aggrox = AceLibrary("Banzai-1.0")
        if aggrox:GetUnitAggroByUnitId("player") then
            if HealthPct() < 0.8 and IsSpellReady("Evasion") then
                CastSpellByName("Evasion")
                return
            elseif HealthPct() < 0.45 and IsSpellReady("Vanish") then
                CastSpellByName("Vanish")
                return
            end
        end

        if not InMeleeRange() then
            return
        end

        local cp = GetComboPoints("target")
        if IsSpellReady("Kidney Shot") and cp >= 3 and StunnableMob() then
            CastSpellByName("Kidney Shot")
        end

        if IsSpellReady("Blade Flurry") and HasBuffOrDebuff("Slice and Dice", "player", "buff") then
            CastSpellByName("Blade Flurry")
        end

        if (DebuffSunderAmount() == 5 or HasBuffOrDebuff("Expose Armor", "target", "debuff"))
            and (InMeleeRange() or TankTarget("Ragnaros")) then
            if Instance.IsWorldBoss() then
                Cooldowns()
            end

            MeleeTrinkets()
        end

        local hasImprovedEA = ImprovedExpose()
        if not HasBuffOrDebuff("Slice and Dice", "player", "buff") then
            if hasImprovedEA then
                if cp == 2 and HasBuffOrDebuff("Expose Armor", "target", "debuff") then
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

        if ConfigState.PlayerSpecc == "Hemo" then
            CastSpellByName("Hemorrhage")
            return
        end

        CastSpellByName("Sinister Strike")
    end

    MoronBox:RegisterExpose({
        Specc = function()
            local _, _, _, _, fury = GetTalentInfo(2, 17)
            local _, _, _, _, prot = GetTalentInfo(3, 9)
            local _, _, _, _, deepProt = GetTalentInfo(3, 17)

            if fury > 0 and prot > 4 then
                ConfigState.PlayerSpecc = "Furytank"
            elseif fury > 0 then
                ConfigState.PlayerSpecc = "BT"
            elseif deepProt > 0 then
                ConfigState.PlayerSpecc = "Prottank"
            else
                ConfigState.PlayerSpecc = nil
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
