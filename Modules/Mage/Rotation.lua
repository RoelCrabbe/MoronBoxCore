-- [[ Mage Rotation ]] --
---@diagnostic disable: undefined-global

local NAME = "Mage Rotation"
local MODULE_NAME = "MODULE_" .. string.upper(string.gsub(NAME, " ", "_"))

local myClass = UnitClass("player")

MoronBox:RegisterModule(MODULE_NAME, function()
    local MageCounter = {
        Cycle = function()
            ConfigState.SheepingMageNr = (ConfigState.SheepingMageNr >= getApi().TableLength(MB_classList["Mage"]))
                and 1 or (ConfigState.SheepingMageNr + 1)
        end
    }

    local RemovedBuffs = {
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
        if ImBusy() or InCombat() then
            return
        end

        if GetAllContainerFreeSlots() == 0 then
            CdMessage("My bags are full, can\'t conjure more stuff", 60)
            return
        end

        if not HaveInBags("Mana Ruby") then
            CastSpellByName("Conjure Mana Ruby")
        end

        if not HaveInBags("Mana Citrine") then
            CastSpellByName("Conjure Mana Citrine")
        end

        if not HaveInBags("Mana Jade") then
            CastSpellByName("Conjure Mana Jade")
        end

        if not HaveInBags("Mana Agate") then
            CastSpellByName("Conjure Mana Agate")
        end
    end

    local function Cooldowns()
        if ImBusy() or not InCombat() then
            return
        end

        SelfBuff("Presence of Mind")
        SelfBuff("Berserking")

        if not HasBuffOrDebuff("Power Infusion", "player", "buff") then
            SelfBuff("Arcane Power")
        end

        RequestPowerInfusion()

        HealerTrinkets()
        CasterTrinkets()
    end

    local CooldownScenarios = {
        ["ONY"] = {
            Encounter = function() return TankTarget("Onyxia") end,
            Conditions = function() return TankTargetHealth() <= 0.65 and ManaDown() > 600 end
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

        if GetScorchAmount() == 5 then
            Cooldowns()
        end
    end

    local function UseFrostCooldowns()
        if CooldownConditions() then
            return
        end

        if ManaDown() > 600 then
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
        if ImBusy() or not InCombat() then
            return
        end

        local isBossOrHighLvl = Instance.IsWorldBoss() or UnitLevel("target") >= 63
        local isLowMana = ManaPct("player") < 0.3

        if not (isBossOrHighLvl or isLowMana) then
            return
        end

        for _, gem in ipairs(ManaGems) do
            if HaveInBags(gem.name) and ManaDown() >= gem.threshold then
                UseItemByName(gem.name)
                return true
            end
        end

        return false
    end

    local function Fire()
        local igTick = tonumber(ConfigState.Ignite.Amount)

        -- No active Ignite: starter just starts it
        if not ConfigState.Ignite.Active then
            UseFireCooldowns()
            CastOrWand("Fireball")
            return
        end

        -- Starter logic
        if ConfigState.Ignite.Starter == myName then
            -- Good Ignite tick
            if igTick > SettingsState.Mage.StarterIgniteTick then
                SelfBuff("Combustion") -- pop Combustion once at start

                -- Fire Blast if allowed, in melee, and ready
                if SettingsState.Mage.AllowFireBlastDuringIgnite and InMeleeRange() and IsSpellReady("Fire Blast") then
                    CastSpellByName("Fire Blast")
                end

                -- Main spell to keep Ignite rolling
                CastOrWand("Fireball")
            else
                -- Bad tick handling
                if SettingsState.Mage.AllowIgniteToDropWhenBadTick then
                    CastOrWand("Frostbolt")
                else
                    CastOrWand("Fireball")
                end
            end

            -- Non-starter logic
        else
            -- Starter has good Ignite tick
            if igTick > SettingsState.Mage.StarterIgniteTick then
                if HasBuffOrDebuff("Ignite", "target", "debuff") then
                    CastOrWand(SettingsState.Mage.SpellToKeepIgniteUp) -- usually Scorch
                end
            else
                -- Starter tick is bad â†’ non-starters cast Fireball to start next strong Ignite
                CastOrWand("Fireball")
            end
        end
    end

    local function Frost()
        local winterChill = GetWintersChillAmount()

        -- Combat cooldowns
        if InCombat() then
            UseFrostCooldowns()

            -- Ice Block if low health (except Grobbulus)
            if IsSpellReady("Ice Block") and HealthPct() <= 0.22 and not GROB_IsAtGrobbulus() then
                SelfBuff("Ice Block")
                return
            end

            -- Cancel Ice Block safely
            if HasBuffOrDebuff("Ice Block", "player", "buff") and HealthPct() >= 0.70 then
                CancelBuff("Ice Block")
                return
            end

            -- Ice Barrier
            if IsSpellReady("Ice Barrier") and HealthPct() >= 0.65 and not HasBuffOrDebuff("Ice Barrier", "player", "buff") then
                SelfBuff("Ice Barrier")
                return
            end
        end

        -- Winter's Chill opener
        if Instance.IsWorldBoss() and WinterChill() and winterChill < 2 then
            CastSpellByName(SettingsState.Mage.SpellToKeepWintersChillUp)
            return
        end

        -- Frostbolt rotation (Fireball as backup if GCD)
        if IsSpellReady("Frostbolt") then
            CastOrWand("Frostbolt")
        else
            CastOrWand("Fireball")
        end
    end

    local function BossSpecificDPS()
        local tName = UnitName("target")

        if tName == "Emperor Vek\'nilash" then
            return true
        end

        if MobsToDetectMagic() and not HasBuffOrDebuff("Detect Magic", "target", "debuff") then
            if not HasBuffOrDebuff("Detect Magic", "player", "debuff") then
                CastSpellByName("Detect Magic")
                return true
            end
        end

        if MobsToFireWard() and not HasBuffOrDebuff("Fire Ward", "player", "buff") then
            SelfBuff("Fire Ward")
            return true
        end

        if (Instance.AQ40() or Instance.AQ20()) and MobsToDetectMagic() then
            if not HasBuffOrDebuff("Detect Magic", "target", "debuff") then
                Frost()
                return true
            elseif HasBuffNamed("Fire and Arcane Reflect", "target") and not HasBuffOrDebuff("Immolate", "target", "debuff") then
                Frost()
                return true
            elseif HasBuffNamed("Shadow and Frost Reflect", "target") and HasBuffOrDebuff("Immolate", "target", "debuff") then
                Fire()
                return true
            end
        end

        if HasBuffOrDebuff("Magic Reflection", "target", "buff") then
            if ImBusy() then SpellStopCasting() end
            AutoWandAttack()
            return true
        end

        if TankTarget("Azuregos") and HasBuffNamed("Magic Shield", "target") then
            if ImBusy() then SpellStopCasting() end
            SelfBuff("Frost Ward")
            return true
        end

        if Instance.AQ40() then
            if TankTarget("Viscidus") then
                if HealthPct("target") <= 0.35 then
                    CastSpellByName("Frostbolt(Rank 1)")
                else
                    MageFire()
                end
                return true
            end

            if FANKRISS_MageDPS(Mage) then
                return true
            end
        end

        if Instance.BWL() and CorruptedTotems() and not Dead("target") then
            if IsSpellReady("Fireblast") then CastSpellByName("Fire Blast") end
            CastOrWand("Scorch")
            return true
        end

        if Instance.MC() then
            if TankTarget("Shazzrah") then
                if ConfigState.PlayerSpecc == "Fire" and not IsSpellReady("Fireball") then
                    MageFrost()
                elseif ConfigState.PlayerSpecc == "Frost" and not IsSpellReady("Frostbolt") then
                    MageFire()
                else
                    return false
                end
                return true
            end
            if tName == "Lava Spawn" and InMeleeRange() then
                if IsSpellReady("Cone of Cold") then
                    CastOrWand("Cone of Cold")
                    return true
                end
            end
        end

        if Instance.ZG() then
            if HasBuffOrDebuff("Delusions of Jin'do", "player", "debuff") and tName == "Shade of Jin'do"
                and not Dead("target") then
                if IsSpellReady("Fire Blast") then
                    CastSpellByName("Fire Blast")
                end

                CastOrWand("Scorch")
                return true
            end

            if (tName == "Powerful Healing Ward" or tName == "Brain Wash Totem") and not Dead("target") then
                if IsSpellReady("Fire Blast") then
                    CastSpellByName("Fire Blast")
                end

                CastOrWand("Scorch")
                return true
            end
        end

        if Instance.AQ20() and TankTarget("Ossirian the Unscarred") then
            if HasBuffOrDebuff("Fire Weakness", "target", "debuff") then
                Fire()
                return true
            elseif HasBuffOrDebuff("Frost Weakness", "target", "debuff") then
                Frost()
                return true
            elseif HasBuffOrDebuff("Arcane Weakness", "target", "debuff") then
                CastOrWand("Arcane Missiles")
                return true
            end
        end

        return false
    end

    MoronBox:RegisterExpose({
        Specc = function()
            local _, _, _, _, frostCap = GetTalentInfo(3, 16)
            local _, _, _, _, fireCap = GetTalentInfo(2, 16)
            local _, _, _, _, arcaneCap = GetTalentInfo(1, 16)
            local _, _, _, _, pyroBlast = GetTalentInfo(2, 8)
            local _, _, _, _, iceBarrier = GetTalentInfo(3, 8)

            if frostCap > 0 or (arcaneCap > 0 and iceBarrier > 1) then
                ConfigState.PlayerSpecc = "Frost"
            elseif fireCap > 0 or (arcaneCap > 0 and pyroBlast > 0) then
                ConfigState.PlayerSpecc = "Fire"
            else
                ConfigState.PlayerSpecc = nil
            end
        end,
        Setup = function()
            if HasBuffOrDebuff("Evocation", "player", "buff") then
                return
            end

            if UnitMana("player") < 3060 and HasBuffNamed("Drink", "player") then
                return
            end

            if IsAltKeyDown() then
                ConjureManaGems()
                return
            end

            if MageWater() > 60 or ConfigState.IsMoving.Active then
                ProcessIntellect()
                ProcessAmplifyMagic()
                RequestDampenMagic()
            else
                MakeWater()
            end

            SelfBuff("Mage Armor")
            ConjureManaGems()

            if not InCombat() and ManaPct("player") < 0.20 and not HasBuffNamed("Drink", "player") then
                SmartDrink()
            end
        end,
        Single = function()
            GetTarget()
            CancelAuraSet(RemoveBuffs)

            if not ConfigState.PlayerSpecc then
                CdMessage("My specc is fucked. Defaulting to Frost.")
                ConfigState.PlayerSpecc = "Frost"
            end

            if CastCrowdControl() or HasBuffOrDebuff("Evocation", "player", "buff") then
                return
            end

            Decurse()

            if TankTarget("Ossirian the Unscarred") then
                return
            end

            if UnitName("target") then
                if ConfigState.CrowdControlTarget and GetRaidTargetIndex("target") == ConfigState.CrowdControlTarget
                    and not HasBuffOrDebuff(ConfigState.CrowdControlSpell[myClass], "target", "debuff") then
                    if CastCrowdControl() then
                        return
                    end
                end

                if CrowdControlledMob() then
                    GetTarget()
                end
            end

            if Instance.AQ40() and SKERAM_InFight() and SKERAM_BoxStrategyEnabled() then
                if SKERAM_CastCrowdControl() then
                    return
                end
            elseif Instance.BWL() and string.find(GetSubZoneText(), "Nefarian.*Lair") and IsAtNefarianPhase() then
                if HasBuffOrDebuff("Shadow Command", "target", "debuff") then
                    ClearTarget()
                    return
                end

                if not ConfigState.AutoToggleCC.Active then
                    ConfigState.AutoToggleCC.Active = true
                    ConfigState.AutoToggleCC.Time = GetTime() + 3
                    MageCounter.Cycle()
                end

                if MyClassAlphabeticalOrder() == ConfigState.SheepingMageNr then
                    CrowdControlMCedRaidMemberNefarian()
                end
            elseif Instance.ZG() and TankTarget("Hakkar") then
                if HasBuffOrDebuff("Mind Control", "target", "debuff") then
                    ClearTarget()
                    return
                end

                if not ConfigState.AutoToggleCC.Active then
                    ConfigState.AutoToggleCC.Active = true
                    ConfigState.AutoToggleCC.Time = GetTime() + 10
                    MageCounter.Cycle()
                end

                if MyClassAlphabeticalOrder() == ConfigState.SheepingMageNr then
                    CrowdControlMCedRaidMemberHakkar()
                end
            end

            if not InCombat("target") then
                return
            end

            if InCombat() then
                UseManaGems()
                TakeManaPotionAndRunes()

                if ManaPct() <= 0.1 and IsSpellReady("Evocation") then
                    CastSpellByName("Evocation")
                    return
                end
            end

            if ConfigState.DoInterrupt.Active and IsSpellReady(ConfigState.InterruptSpell[myClass]) then
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

            if BossSpecificDPS() then
                return
            end

            if ConfigState.PlayerSpecc == "Fire" then
                if IsFireImmune() then
                    CastOrWand("Frostbolt")
                    return
                end

                Fire()
            elseif ConfigState.PlayerSpecc == "Frost" then
                if IsFrostImmune() then
                    CastOrWand("Fireball")
                    return
                end

                Frost()
            end
        end,
        Multi = function()

        end,
        AOE = function()
            GetTarget()
            CancelAuraSet(RemoveBuffs)

            if not ConfigState.PlayerSpecc then
                CdMessage("My specc is fucked. Defaulting to Frost.")
                ConfigState.PlayerSpecc = "Frost"
            end

            if HasBuffOrDebuff("Evocation", "player", "buff") then
                return
            end

            Decurse()

            if TankTarget("Ossirian the Unscarred") then
                return
            end

            if InCombat() then
                UseManaGems()

                TakeManaPotionAndRunes()

                if ManaDown() > 600 then
                    Cooldowns()
                end
            end

            if ManaPct("player") < 0.2 and not HasBuffOrDebuff("Clearcasting", "player", "buff") then
                CastSpellByName("Arcane Explosion(Rank 1)")
                return
            end

            if Instance.BWL() and GetSubZoneText() == "Halls of Strife" then
                CastSpellByName("Arcane Explosion(Rank 3)")
                return
            elseif Instance.NAXX() and TankTarget("Maexxna") then
                CastSpellByName("Arcane Explosion(Rank 3)")
                return
            end

            if InMeleeRange() then
                if ConfigState.PlayerSpecc == "Fire" then
                    if IsFireImmune() then
                        return
                    end

                    if IsSpellReady("Blast Wave") then
                        CastSpellByName("Blast Wave")
                    end
                elseif ConfigState.PlayerSpecc == "Frost" then
                    if IsFrostImmune() then
                        return
                    end

                    if IsSpellReady("Ice Block") and HealthPct() <= 0.22 and not GROB_IsAtGrobbulus() then
                        SelfBuff("Ice Block")
                        return
                    end

                    if HasBuffOrDebuff("Ice Block", "player", "buff") and HealthPct() >= 0.70 then
                        CancelBuff("Ice Block")
                        return
                    end

                    if IsSpellReady("Ice Barrier") and HealthPct() >= 0.65 then
                        SelfBuff("Ice Barrier")
                        return
                    end
                end
            end

            CastSpellByName("Arcane Explosion")
        end,
        PreCast = function()
            PreCastTrinkets()

            if ConfigState.PlayerSpecc == "Fire" then
                if IsFireImmune() then
                    CastSpellByName("Frostbolt")
                else
                    CastSpellByName("Fireball")
                end
            elseif ConfigState.PlayerSpecc == "Frost" then
                if IsFrostImmune() then
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
