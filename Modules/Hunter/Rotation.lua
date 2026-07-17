-- [[ Hunter Rotation ]] --

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
        if getSpells().ImBusy() or not getUnit().InCombat() then
            return
        end

        getSpells().SelfBuff("Berserking")

        if not getUnit().InMeleeRange() then
            getSpells().SelfBuff("Rapid Fire")
        end

        getBag().MeleeTrinkets()
    end

    local function ExplosiveTrap()
        if not getSpells().IsSpellReady("Explosive Trap") then
            return
        end

        if getUnit().InCombat() and not getConfigState().HunterFeign.Active then
            getConfigState().HunterFeign.Active = true
            getConfigState().HunterFeign.Time = GetTime() + 0.2
            CastSpellByName("Feign Death")
        else
            CastSpellByName("Explosive Trap")
        end
    end

    local function FreezingTrap()
        if not getSpells().IsSpellReady("Frost Trap") then
            return
        end

        PetPassiveMode()
        PetFollow()

        if getUnit().InCombat() and not getConfigState().HunterFeign.Active then
            getConfigState().HunterFeign.Active = true
            getConfigState().HunterFeign.Time = GetTime() + 0.2
            CastSpellByName("Feign Death")
        else
            CastSpellByName("Frost Trap")
        end
    end

    local function BossSpecificDPS()
        if getTables().UseTranquilizingShot() and getSpells().IsSpellReady("Tranquilizing Shot") then
            CastSpellByName("Tranquilizing Shot")
        end

        if not getAura().HasBuffOrDebuff("Hunter\'s Mark", "target", "debuff") then
            CastSpellByName("Hunter\'s Mark")
        end

        if Instance.AQ20() then
            if getRaid().TankTarget("Ossirian the Unscarred") then
                if getAura().HasBuffOrDebuff("Nature Weakness", "target", "debuff") then
                    getSpells().CoolDownCast("Serpent Sting", 15)
                    return true
                elseif getAura().HasBuffOrDebuff("Arcane Weakness", "target", "debuff") then
                    CastSpellByName("Arcane Shot")
                    return true
                end
            elseif getRaid().TankTarget("Moam") then
                getSpells().CoolDownCast("Viper Sting", 8)
            end
        end

        return false
    end

    local function Single()
        getRaid().GetTarget()
        getAura().CancelAuraSet(RemoveBuffs)

        if not getConfigState().PlayerSpecc then
            getApi().CdMessage("My specc is fucked. Defaulting to Marksmanship.")
            getConfigState().PlayerSpecc = "Marksmanship"
        end

        if IsControlKeyDown() then
            CastSpellByName("Aspect of the Cheetah")
            return
        end

        getSpells().SelfBuff("Trueshot Aura")

        if getRaid().TankTarget("Princess Huhuran") then
            getSpells().SelfBuff("Aspect of the Wild")
        else
            getSpells().SelfBuff("Aspect of the Hawk")
        end

        if Instance.NAXX() and GLUTH_IsAtGluth() then
            FreezingTrap()
        elseif Instance.AQ40() and getAura().HasBuffOrDebuff("True Fulfillment", "target", "debuff") then
            ClearTarget()
            return
        elseif Instance.BWL() and string.find(GetSubZoneText(), "Nefarian.*Lair") and getRaid().IsAtNefarianPhase() then
            if getAura().HasBuffOrDebuff("Shadow Command", "target", "debuff") then
                ClearTarget()
                return
            end
        elseif Instance.ZG() and getRaid().TankTarget("Hakkar") then
            if getAura().HasBuffOrDebuff("Mind Control", "target", "debuff") then
                ClearTarget()
                return
            end
        end

        if not getUnit().InCombat("target") then
            return
        end

        if getUnit().InCombat() then
            getCons().TakeManaPotionAndRunes()

            if getUnit().ManaDown() > 600 then
                Cooldowns()
            end
        end

        if getUnit().InMeleeRange() then
            if not getTables().IsFireImmune() then
                ExplosiveTrap()
            end

            getAttack().AutoAttack()

            CastSpellByName("Raptor Strike")
            CastSpellByName("Mongoose Bite")
            return
        end

        getAttack().AutoRangedAttack()

        if BossSpecificDPS() then
            return
        end

        if getSpells().ImBusy() then
            return
        end

        if not getConfigState().HunterFeign.Active then
            local aggrox = AceLibrary("Banzai-1.0")

            if aggrox:GetUnitAggroByUnitId("player") and getSpells().IsSpellReady("Feign Death") then
                getConfigState().HunterFeign.Active = true
                getConfigState().HunterFeign.Time = GetTime() + 0.2
                CastSpellByName("Feign Death")
            end
        end

        if getUnit().HealthPct("target") > 0.1 and getSpells().IsSpellReady("Aimed Shot") then
            CastSpellByName("Aimed Shot")
        end

        if getUnit().HealthPct("target") < 0.95 and getSpells().IsSpellReady("Multi-Shot") then
            CastSpellByName("Multi-Shot")
        end
    end

    MoronBox:RegisterExpose({
        Specc = function()
            local _, _, _, _, mm = GetTalentInfo(1, 14)
            local _, _, _, _, survival = GetTalentInfo(1, 15)
            local _, _, _, _, bm = GetTalentInfo(1, 13)

            if mm > 0 then
                getConfigState().PlayerSpecc = "Marksmanship"
            elseif survival > 0 then
                getConfigState().PlayerSpecc = "Survival"
            elseif bm > 0 then
                getConfigState().PlayerSpecc = "BeastMastery"
            else
                getConfigState().PlayerSpecc = nil
            end
        end,
        Setup = function()
            getSpells().SelfBuff("Trueshot Aura")
            getSpells().SelfBuff("Aspect of the Hawk")

            CastSpellByName("Dismiss Pet")
        end,
        Single = Single,
        Multi = Single,
        AOE = Single,
        PreCast = function()
            getBag().PreCastMeleeTrinkets()
            CastSpellByName("Aimed Shot")
        end
    })
end, function()
    return myClass == "Hunter"
end)
