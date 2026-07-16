-- [[ Hunter Rotation ]] --
---@diagnostic disable: undefined-global

local NAME = "Hunter Rotation"
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

    local function Cooldowns()
        if ImBusy() or not InCombat() then
            return
        end

        SelfBuff("Berserking")

        if not InMeleeRange() then
            SelfBuff("Rapid Fire")
        end

        SelfBuff("Combustion")
        SelfBuff("Presence of Mind")

        MeleeTrinkets()
    end

    local function ExplosiveTrap()
        if not IsSpellReady("Explosive Trap") then
            return
        end

        if InCombat() and not ConfigState.HunterFeign.Active then
            ConfigState.HunterFeign.Active = true
            ConfigState.HunterFeign.Time = GetTime() + 0.2
            CastSpellByName("Feign Death")
        else
            CastSpellByName("Explosive Trap")
        end
    end

    local function FreezingTrap()
        if not IsSpellReady("Frost Trap") then
            return
        end

        PetPassiveMode()
        PetFollow()

        if InCombat() and not ConfigState.HunterFeign.Active then
            ConfigState.HunterFeign.Active = true
            ConfigState.HunterFeign.Time = GetTime() + 0.2
            CastSpellByName("Feign Death")
        else
            CastSpellByName("Frost Trap")
        end
    end

    local function BossSpecificDPS()
        if UseTranquilizingShot() and IsSpellReady("Tranquilizing Shot") then
            CastSpellByName("Tranquilizing Shot")
        end

        if not HasBuffOrDebuff("Hunter\'s Mark", "target", "debuff") then
            CastSpellByName("Hunter\'s Mark")
        end

        if Instance.AQ20() then
            if TankTarget("Ossirian the Unscarred") then
                if HasBuffOrDebuff("Nature Weakness", "target", "debuff") then
                    CoolDownCast("Serpent Sting", 15)
                    return true
                elseif HasBuffOrDebuff("Arcane Weakness", "target", "debuff") then
                    CastSpellByName("Arcane Shot")
                    return true
                end
            elseif TankTarget("Moam") then
                CoolDownCast("Viper Sting", 8)
            end
        end

        return false
    end

    local function Single()
        GetTarget()
        CancelAuraSet(RemoveBuffs)

        if not ConfigState.PlayerSpecc then
            CdMessage("My specc is fucked. Defaulting to Marksmanship.")
            ConfigState.PlayerSpecc = "Marksmanship"
        end

        if IsControlKeyDown() then
            CastSpellByName("Aspect of the Cheetah")
            return
        end

        SelfBuff("Trueshot Aura")

        if TankTarget("Princess Huhuran") then
            SelfBuff("Aspect of the Wild")
        else
            SelfBuff("Aspect of the Hawk")
        end

        if Instance.NAXX() and GLUTH_IsAtGluth() then
            Hunter:FreezingTrap()
        elseif Instance.AQ40() and HasBuffOrDebuff("True Fulfillment", "target", "debuff") then
            ClearTarget()
            return
        elseif Instance.BWL() and string.find(GetSubZoneText(), "Nefarian.*Lair") and IsAtNefarianPhase() then
            if HasBuffOrDebuff("Shadow Command", "target", "debuff") then
                ClearTarget()
                return
            end
        elseif Instance.ZG() and TankTarget("Hakkar") then
            if HasBuffOrDebuff("Mind Control", "target", "debuff") then
                ClearTarget()
                return
            end
        end

        if not InCombat("target") then
            return
        end

        if InCombat() then
            TakeManaPotionAndRunes()

            if ManaDown() > 600 then
                Cooldowns()
            end
        end

        if InMeleeRange() then
            if not IsFireImmune() then
                ExplosiveTrap()
            end

            AutoAttack()

            CastSpellByName("Raptor Strike")
            CastSpellByName("Mongoose Bite")
            return
        end

        AutoRangedAttack()

        if BossSpecificDPS() then
            return
        end

        if ImBusy() then
            return
        end

        if not ConfigState.HunterFeign.Active then
            local aggrox = AceLibrary("Banzai-1.0")

            if aggrox:GetUnitAggroByUnitId("player") and IsSpellReady("Feign Death") then
                ConfigState.HunterFeign.Active = true
                ConfigState.HunterFeign.Time = GetTime() + 0.2
                CastSpellByName("Feign Death")
            end
        end

        if HealthPct("target") > 0.1 and IsSpellReady("Aimed Shot") then
            CastSpellByName("Aimed Shot")
        end

        if HealthPct("target") < 0.95 and IsSpellReady("Multi-Shot") then
            CastSpellByName("Multi-Shot")
        end
    end

    MoronBox:RegisterExpose({
        Specc = function()
            local _, _, _, _, mm = GetTalentInfo(1, 14)
            local _, _, _, _, survival = GetTalentInfo(1, 15)
            local _, _, _, _, bm = GetTalentInfo(1, 13)

            if mm > 0 then
                ConfigState.PlayerSpecc = "Marksmanship"
            elseif survival > 0 then
                ConfigState.PlayerSpecc = "Survival"
            elseif bm > 0 then
                ConfigState.PlayerSpecc = "BeastMastery"
            else
                ConfigState.PlayerSpecc = nil
            end
        end,
        Setup = function()
            SelfBuff("Trueshot Aura")
            SelfBuff("Aspect of the Hawk")

            CastSpellByName("Dismiss Pet")
        end,
        Single = Single,
        Multi = Single,
        AOE = Single,
        PreCast = function()
            PreCastMeleeTrinkets()
            CastSpellByName("Aimed Shot")
        end
    })
end, function()
    return myClass == "Hunter"
end)
