-- [[ Mage Rotation ]] --

local NAME = "Mage Rotation"
local MODULE_NAME = "MODULE_" .. string.upper(string.gsub(NAME, " ", "_"))

local myName = UnitName("player")
local myClass = UnitClass("player")

MoronBox:RegisterModule(MODULE_NAME, function()
    local MageCounter = {
        Cycle = function()
            getConfigState().SheepingMageNr = (getConfigState().SheepingMageNr >= getApi().TableLength(getCoreState().ClassList["Warlock"]))
                and 1 or (getConfigState().SheepingMageNr + 1)
        end
    }

    local RemoveBuffs = {
        ["Battle Shout"]     = "Battle Shout",
        ["Fengus' Ferocity"] = "Fengus' Ferocity",
        ["Polished Armor"]   = "Polished Armor",
        ["R.O.I.D.S."]       = "Rage of Ages"
    }

    local function WinterChill()
        local _, _, _, _, TalentsIn = GetTalentInfo(3, 16)
        return TalentsIn > 4
    end

    local function ConjureManaGems()
        if getSpells().ImBusy() or getUnit().InCombat() then
            return
        end

        if getBag().GetAllContainerFreeSlots() == 0 then
            getApi().CdMessage("My bags are full, can\'t conjure more stuff", 60)
            return
        end

        if not getBag().HaveInBags("Mana Ruby") then
            CastSpellByName("Conjure Mana Ruby")
        end

        if not getBag().HaveInBags("Mana Citrine") then
            CastSpellByName("Conjure Mana Citrine")
        end

        if not getBag().HaveInBags("Mana Jade") then
            CastSpellByName("Conjure Mana Jade")
        end

        if not getBag().HaveInBags("Mana Agate") then
            CastSpellByName("Conjure Mana Agate")
        end
    end

    local function Cooldowns()
        if getSpells().ImBusy() or not getUnit().InCombat() then
            return
        end

        getSpells().SelfBuff("Presence of Mind")
        getSpells().SelfBuff("Berserking")

        if not getAura().HasBuffOrDebuff("Power Infusion", "player", "buff") then
            getSpells().SelfBuff("Arcane Power")
        end

        getBuffs().RequestPowerInfusion()

        getBag().HealerTrinkets()
        getBag().CasterTrinkets()
    end

    local CooldownScenarios = {
        ["ONY"] = {
            Encounter = function() return getRaid().TankTarget("Onyxia") end,
            Conditions = function() return getRaid().TankTargetHealth() <= 0.65 and getUnit().ManaDown() > 600 end
        },
    }

    local function CooldownConditions()
        for name, scenario in pairs(CooldownScenarios) do
            if scenario.Encounter() then
                if scenario.Conditions() then
                    Cooldowns()
                    return true
                end
            end
        end
        return false
    end

    local function UseFireCooldowns()
        if CooldownConditions() then
            return
        end

        if getAura().GetScorchAmount() == 5 then
            Cooldowns()
        end
    end

    local function UseFrostCooldowns()
        if CooldownConditions() then
            return
        end

        if getUnit().ManaDown() > 600 then
            Cooldowns()
        end
    end

    local ManaGems = {
        { name = "Mana Ruby",    threshold = 1200 },
        { name = "Mana Citrine", threshold = 925 },
        { name = "Mana Jade",    threshold = 650 },
        { name = "Mana Agate",   threshold = 425 }
    }

    local function UseManaGems()
        if getSpells().ImBusy() or not getUnit().InCombat() then
            return
        end

        local isBossOrHighLvl = Instance.IsWorldBoss() or UnitLevel("target") >= 63
        local isLowMana = getUnit().ManaPct("player") < 0.3

        if not (isBossOrHighLvl or isLowMana) then
            return
        end

        for _, gem in ipairs(ManaGems) do
            if getBag().HaveInBags(gem.name) and getUnit().ManaDown() >= gem.threshold then
                UseItemByName(gem.name)
                return true
            end
        end

        return false
    end

    local function Fire()
        local igTick = tonumber(getConfigState().Ignite.Amount)

        -- No active Ignite: starter just starts it
        if not getConfigState().Ignite.Active then
            UseFireCooldowns()
            getSpells().CastOrWand("Fireball")
            return
        end

        -- Starter logic
        if getConfigState().Ignite.Starter == myName then
            -- Good Ignite tick
            if igTick > getSettingsState().Mage.StarterIgniteTick then
                getSpells().SelfBuff("Combustion") -- pop Combustion once at start

                -- Fire Blast if allowed, in melee, and ready
                if getSettingsState().Mage.AllowFireBlastDuringIgnite and getUnit().InMeleeRange() and getSpells().IsSpellReady("Fire Blast") then
                    CastSpellByName("Fire Blast")
                end

                -- Main spell to keep Ignite rolling
                getSpells().CastOrWand("Fireball")
            else
                -- Bad tick handling
                if getSettingsState().Mage.AllowIgniteToDropWhenBadTick then
                    getSpells().CastOrWand("Frostbolt")
                else
                    getSpells().CastOrWand("Fireball")
                end
            end

            -- Non-starter logic
        else
            -- Starter has good Ignite tick
            if igTick > getSettingsState().Mage.StarterIgniteTick then
                if getAura().HasBuffOrDebuff("Ignite", "target", "debuff") then
                    getSpells().CastOrWand(getSettingsState().Mage.SpellToKeepIgniteUp) -- usually Scorch
                end
            else
                -- Starter tick is bad non-starters cast Fireball to start next strong Ignite
                getSpells().CastOrWand("Fireball")
            end
        end
    end

    local function Frost()
        local winterChill = getAura().GetWintersChillAmount()

        -- Combat cooldowns
        if getUnit().InCombat() then
            UseFrostCooldowns()

            -- Ice Block if low health (except Grobbulus)
            if getSpells().IsSpellReady("Ice Block") and getUnit().HealthPct() <= 0.22 and not GROB_IsAtGrobbulus() then
                getSpells().SelfBuff("Ice Block")
                return
            end

            -- Cancel Ice Block safely
            if getAura().HasBuffOrDebuff("Ice Block", "player", "buff") and getUnit().HealthPct() >= 0.70 then
                CancelBuff("Ice Block")
                return
            end

            -- Ice Barrier
            if getSpells().IsSpellReady("Ice Barrier") and getUnit().HealthPct() >= 0.65 and not getAura().HasBuffOrDebuff("Ice Barrier", "player", "buff") then
                getSpells().SelfBuff("Ice Barrier")
                return
            end
        end

        -- Winter's Chill opener
        if Instance.IsWorldBoss() and WinterChill() and winterChill < 2 then
            CastSpellByName(getSettingsState().Mage.SpellToKeepWintersChillUp)
            return
        end

        -- Frostbolt rotation (Fireball as backup if GCD)
        if getSpells().IsSpellReady("Frostbolt") then
            getSpells().CastOrWand("Frostbolt")
        else
            getSpells().CastOrWand("Fireball")
        end
    end

    local function BossSpecificDPS()
        local tName = UnitName("target")

        if tName == "Emperor Vek\'nilash" then
            return true
        end

        if getTables().MobsToDetectMagic() and not getAura().HasBuffOrDebuff("Detect Magic", "target", "debuff") then
            if not getAura().HasBuffOrDebuff("Detect Magic", "player", "debuff") then
                CastSpellByName("Detect Magic")
                return true
            end
        end

        if getTables().MobsToFireWard() and not getAura().HasBuffOrDebuff("Fire Ward", "player", "buff") then
            getSpells().SelfBuff("Fire Ward")
            return true
        end

        if (Instance.AQ40() or Instance.AQ20()) and getTables().MobsToDetectMagic() then
            if not getAura().HasBuffOrDebuff("Detect Magic", "target", "debuff") then
                Frost()
                return true
            elseif getAura().HasBuffNamed("Fire and Arcane Reflect", "target") and not getAura().HasBuffOrDebuff("Immolate", "target", "debuff") then
                Frost()
                return true
            elseif getAura().HasBuffNamed("Shadow and Frost Reflect", "target") and getAura().HasBuffOrDebuff("Immolate", "target", "debuff") then
                Fire()
                return true
            end
        end

        if getAura().HasBuffOrDebuff("Magic Reflection", "target", "buff") then
            if getSpells().ImBusy() then
                SpellStopCasting()
            end

            getAttack().AutoWandAttack()
            return true
        end

        if getRaid().TankTarget("Azuregos") and getAura().HasBuffNamed("Magic Shield", "target") then
            if getSpells().ImBusy() then
                SpellStopCasting()
            end

            getSpells().SelfBuff("Frost Ward")
            return true
        end

        if Instance.AQ40() then
            if getRaid().TankTarget("Viscidus") then
                if getUnit().HealthPct("target") <= 0.35 then
                    CastSpellByName("Frostbolt(Rank 1)")
                else
                    Fire()
                end
                return true
            end

            if FANKRISS_MageDPS() then
                return true
            end
        end

        if Instance.BWL() and getTables().CorruptedTotems() and not getUnit().IsDead("target") then
            if getSpells().IsSpellReady("Fireblast") then
                CastSpellByName("Fire Blast")
            end

            getSpells().CastOrWand("Scorch")
            return true
        end

        if Instance.MC() then
            if getRaid().TankTarget("Shazzrah") then
                if getConfigState().PlayerSpecc == "Fire" and not getSpells().IsSpellReady("Fireball") then
                    Frost()
                elseif getConfigState().PlayerSpecc == "Frost" and not getSpells().IsSpellReady("Frostbolt") then
                    Fire()
                else
                    return false
                end
                return true
            end
            if tName == "Lava Spawn" and getUnit().InMeleeRange() then
                if getSpells().IsSpellReady("Cone of Cold") then
                    getSpells().CastOrWand("Cone of Cold")
                    return true
                end
            end
        end

        if Instance.ZG() then
            if getAura().HasBuffOrDebuff("Delusions of Jin'do", "player", "debuff") and tName == "Shade of Jin'do"
                and not getUnit().IsDead("target") then
                if getSpells().IsSpellReady("Fire Blast") then
                    CastSpellByName("Fire Blast")
                end

                getSpells().CastOrWand("Scorch")
                return true
            end

            if (tName == "Powerful Healing Ward" or tName == "Brain Wash Totem") and not getUnit().IsDead("target") then
                if getSpells().IsSpellReady("Fire Blast") then
                    CastSpellByName("Fire Blast")
                end

                getSpells().CastOrWand("Scorch")
                return true
            end
        end

        if Instance.AQ20() and getRaid().TankTarget("Ossirian the Unscarred") then
            if getAura().HasBuffOrDebuff("Fire Weakness", "target", "debuff") then
                Fire()
                return true
            elseif getAura().HasBuffOrDebuff("Frost Weakness", "target", "debuff") then
                Frost()
                return true
            elseif getAura().HasBuffOrDebuff("Arcane Weakness", "target", "debuff") then
                getSpells().CastOrWand("Arcane Missiles")
                return true
            end
        end

        return false
    end

    local function Single()
        getRaid().GetTarget()
        getAura().CancelAuraSet(RemoveBuffs)

        if not getConfigState().PlayerSpecc then
            getApi().CdMessage("My specc is fucked. Defaulting to Frost.")
            getConfigState().PlayerSpecc = "Frost"
        end

        if getCrowdControl().CastCrowdControl() or getAura().HasBuffOrDebuff("Evocation", "player", "buff") then
            return
        end

        getDispel().Decurse()

        if getRaid().TankTarget("Ossirian the Unscarred") then
            return
        end

        if UnitName("target") then
            if getConfigState().CrowdControlTarget and GetRaidTargetIndex("target") == getConfigState().CrowdControlTarget
                and not getAura().HasBuffOrDebuff(getConfigState().CrowdControlSpell[myClass], "target", "debuff") then
                if getCrowdControl().CastCrowdControl() then
                    return
                end
            end

            if getUnit().CrowdControlledMob() then
                getRaid().GetTarget()
            end
        end

        if Instance.AQ40() and SKERAM_InFight() and SKERAM_BoxStrategyEnabled() then
            if SKERAM_CrowdControl() then
                return
            end
        elseif Instance.BWL() and string.find(GetSubZoneText(), "Nefarian.*Lair") and getRaid().IsAtNefarianPhase() then
            if getAura().HasBuffOrDebuff("Shadow Command", "target", "debuff") then
                ClearTarget()
                return
            end

            if not getConfigState().AutoToggleCC.Active then
                getConfigState().AutoToggleCC.Active = true
                getConfigState().AutoToggleCC.Time = GetTime() + 3
                MageCounter.Cycle()
            end

            if getCore().MyClassAlphabeticalOrder() == getConfigState().SheepingMageNr then
                getRaid().CrowdControlMCedRaidMemberNefarian()
            end
        elseif Instance.ZG() and getRaid().TankTarget("Hakkar") then
            if getAura().HasBuffOrDebuff("Mind Control", "target", "debuff") then
                ClearTarget()
                return
            end

            if not getConfigState().AutoToggleCC.Active then
                getConfigState().AutoToggleCC.Active = true
                getConfigState().AutoToggleCC.Time = GetTime() + 10
                MageCounter.Cycle()
            end

            if getCore().MyClassAlphabeticalOrder() == getConfigState().SheepingMageNr then
                getRaid().CrowdControlMCedRaidMemberHakkar()
            end
        end

        if not getUnit().InCombat("target") then
            return
        end

        if getUnit().InCombat() then
            UseManaGems()
            getCons().TakeManaPotionAndRunes()

            if getUnit().ManaPct() <= 0.1 and getSpells().IsSpellReady("Evocation") then
                CastSpellByName("Evocation")
                return
            end
        end

        if getConfigState().DoInterrupt.Active and getSpells().IsSpellReady(getConfigState().InterruptSpell[myClass]) then
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

        if BossSpecificDPS() then
            return
        end

        if getConfigState().PlayerSpecc == "Fire" then
            if getTables().IsFireImmune() then
                getSpells().CastOrWand("Frostbolt")
                return
            end

            Fire()
        elseif getConfigState().PlayerSpecc == "Frost" then
            if getTables().IsFrostImmune() then
                getSpells().CastOrWand("Fireball")
                return
            end

            Frost()
        end
    end

    MoronBox:RegisterExpose({
        Specc = function()
            local _, _, _, _, frostCap = GetTalentInfo(3, 16)
            local _, _, _, _, fireCap = GetTalentInfo(2, 16)
            local _, _, _, _, arcaneCap = GetTalentInfo(1, 16)
            local _, _, _, _, pyroBlast = GetTalentInfo(2, 8)
            local _, _, _, _, iceBarrier = GetTalentInfo(3, 8)

            if frostCap > 0 or (arcaneCap > 0 and iceBarrier > 1) then
                getConfigState().PlayerSpecc = "Frost"
            elseif fireCap > 0 or (arcaneCap > 0 and pyroBlast > 0) then
                getConfigState().PlayerSpecc = "Fire"
            else
                getConfigState().PlayerSpecc = nil
            end
        end,
        Setup = function()
            if getAura().HasBuffOrDebuff("Evocation", "player", "buff") then
                return
            end

            if UnitMana("player") < 3060 and getAura().HasBuffNamed("Drink", "player") then
                return
            end

            if IsAltKeyDown() then
                ConjureManaGems()
                return
            end

            if getWater().MageWater() > 60 or getConfigState().IsMoving.Active then
                getBuffs().ProcessIntellect()
                getBuffs().ProcessAmplifyMagic()
                getBuffs().RequestDampenMagic()
            else
                getWater().MakeWater()
            end

            getSpells().SelfBuff("Mage Armor")
            ConjureManaGems()

            if not getUnit().InCombat() and getUnit().ManaPct("player") < 0.20 and not getAura().HasBuffNamed("Drink", "player") then
                getWater().SmartDrink()
            end
        end,
        Single = Single,
        Multi = Single,
        AOE = function()
            getRaid().GetTarget()
            getAura().CancelAuraSet(RemoveBuffs)

            if not getConfigState().PlayerSpecc then
                getApi().CdMessage("My specc is fucked. Defaulting to Frost.")
                getConfigState().PlayerSpecc = "Frost"
            end

            if getAura().HasBuffOrDebuff("Evocation", "player", "buff") then
                return
            end

            getDispel().Decurse()

            if getRaid().TankTarget("Ossirian the Unscarred") then
                return
            end

            if getUnit().InCombat() then
                UseManaGems()

                getCons().TakeManaPotionAndRunes()

                if getUnit().ManaDown() > 600 then
                    Cooldowns()
                end
            end

            if getUnit().ManaPct("player") < 0.2 and not getAura().HasBuffOrDebuff("Clearcasting", "player", "buff") then
                CastSpellByName("Arcane Explosion(Rank 1)")
                return
            end

            if Instance.BWL() and GetSubZoneText() == "Halls of Strife" then
                CastSpellByName("Arcane Explosion(Rank 3)")
                return
            elseif Instance.NAXX() and getRaid().TankTarget("Maexxna") then
                CastSpellByName("Arcane Explosion(Rank 3)")
                return
            end

            if getUnit().InMeleeRange() then
                if getConfigState().PlayerSpecc == "Fire" then
                    if getTables().IsFireImmune() then
                        return
                    end

                    if getSpells().IsSpellReady("Blast Wave") then
                        CastSpellByName("Blast Wave")
                    end
                elseif getConfigState().PlayerSpecc == "Frost" then
                    if getTables().IsFrostImmune() then
                        return
                    end

                    if getSpells().IsSpellReady("Ice Block") and getUnit().HealthPct() <= 0.22 and not GROB_IsAtGrobbulus() then
                        getSpells().SelfBuff("Ice Block")
                        return
                    end

                    if getAura().HasBuffOrDebuff("Ice Block", "player", "buff") and getUnit().HealthPct() >= 0.70 then
                        CancelBuff("Ice Block")
                        return
                    end

                    if getSpells().IsSpellReady("Ice Barrier") and getUnit().HealthPct() >= 0.65 then
                        getSpells().SelfBuff("Ice Barrier")
                        return
                    end
                end
            end

            CastSpellByName("Arcane Explosion")
        end,
        PreCast = function()
            getBag().PreCastTrinkets()

            if getConfigState().PlayerSpecc == "Fire" then
                if getTables().IsFireImmune() then
                    CastSpellByName("Frostbolt")
                else
                    CastSpellByName("Fireball")
                end
            elseif getConfigState().PlayerSpecc == "Frost" then
                if getTables().IsFrostImmune() then
                    CastSpellByName("Fireball")
                else
                    CastSpellByName("Frostbolt")
                end
            end
        end
    })
end, function()
    return myClass == "Mage"
end)
