-- [[ Shaman Rotation ]] --
---@diagnostic disable: undefined-global

local NAME = "Shaman Rotation"
local MODULE_NAME = "MODULE_" .. string.upper(string.gsub(NAME, " ", "_"))

local myClass = UnitClass("player")

MoronBox:RegisterModule(MODULE_NAME, function()
    local RemoveBuffs = {
        ["Battle Shout"]     = "Battle Shout",
        ["Fengus' Ferocity"] = "Fengus' Ferocity",
        ["R.O.I.D.S."]       = "Rage of Ages"
    }

    local function GetActiveVaelastraszHealer()
        for _, name in ipairs(MB_myVaelastraszShamans) do
            local id = MBID[name]
            if id and not Dead(id) then
                return name
            end
        end
        return nil
    end

    local function Cooldowns()
        if ImBusy() or not InCombat() then
            return
        end

        SelfBuff("Berserking")
        SelfBuff("Elemental Mastery")

        if EquippedSetCount("The Earthshatter") >= 8 then
            SelfBuff("Lightning Shield")
        end

        HealerTrinkets()
        CasterTrinkets()
    end

    local function BossSpecificDPS()
        local target = UnitName("target")

        if target == "Emperor Vek'nilash" then
            return true
        end

        if HasBuffNamed("Shadow and Frost Reflect", "target") or
            HasBuffOrDebuff("Magic Reflection", "target", "buff") or
            (TankTarget("Azuregos") and HasBuffNamed("Magic Shield", "target")) then
            if ImBusy() then
                SpellStopCasting()
            end

            AutoAttack()
            return true
        end

        return false
    end

    local function Elemental()
        if not InCombat("target") then
            return
        end

        if InCombat() then
            TakeManaPotionAndRunes()

            if ManaDown() > 600 then
                Cooldowns()
            end
        end

        if BossSpecificDPS() then
            return
        end

        if ImBusy() then
            return
        end

        if IsSpellReady("Chain Lightning") then
            CastOrWand("Chain Lightning")
        else
            CastOrWand("Lightning Bolt")
        end
    end

    local HealWave = { Time = 0, Interrupt = false }

    local function MTHeals(assignedTarget)
        if assignedTarget then
            TargetByName(assignedTarget, 1)
        else
            if TankTarget("Patchwerk") and MB_myPatchwerkBoxStrategy then
                TargetMyAssignedTankToHeal()
            else
                local tankTarget = UnitName(MBID[TankName()] .. "targettarget")
                if not tankTarget then
                    MBH_CastHeal("Healing Wave", 3)
                else
                    TargetByName(tankTarget, 1)
                end
            end
        end

        if IsSpellReady("Nature\'s Swiftness") and HealthPct("target") <= 0.15 then
            if not HasBuffOrDebuff("Nature\'s Swiftness", "player", "buff") then
                SpellStopCasting()
            end

            SelfBuff("Nature\'s Swiftness")
        end

        if HasBuffOrDebuff("Nature\'s Swiftness", "player", "buff") then
            CastSpellByName("Healing Wave")
            return
        end

        local healWaveSpell = TankTarget("Vaelastrasz the Corrupt") and "Healing Wave" or
            ("Healing Wave(" .. HealingState.Shaman.MainTankHealingRank .. ")")

        if not BossNeverInterruptHeal() and HealthDown("target") <= (GetHealValueFromRank("Healing Wave", HealingState.Shaman.MainTankHealingRank) * HealingState.MainTankOverhealingPercentage) then
            if GetTime() > HealWave.Time and GetTime() < HealWave.Time + 0.5 and HealWave.Interrupt then
                SpellStopCasting()
                HealWave.Interrupt = false
                SpellStopCasting()
            end
        end

        if not ImBusy() then
            CastSpellByName(healWaveSpell)
            HealWave.Time = GetTime() + 1
            HealWave.Interrupt = true
        end
    end

    local function Heal()
        if NatureSwiftnessLowAggroedPlayer() then
            return
        end

        if InCombat() then
            if IsSpellReady("Mana Tide Totem")
                and not HasBuffOrDebuff("Mana Tide Totem", "player", "buff") then
                local _, partyManaDown = PartyMana()
                local avgManaDown = partyManaDown / NumOfCasterHealerInParty()
                local myManaDown = ManaDown()

                if (avgManaDown > 1500 and myManaDown > 1050) or (myManaDown > 1500) then
                    CastSpellByName("Mana Tide Totem")
                    CoolDownCast("Mana Tide Totem", 13)
                end
            end

            TakeManaPotionAndRunes()

            if ManaDown() > 600 then
                Cooldowns()
            end
        end

        if HasBuffOrDebuff("Curse of Tongues", "player", "debuff") and not TankTarget("Anubisath Defender") then return end
        if HealLieutenantAQ20() or InstructorRazAddsHeal() then return end

        if ConfigState.AssignedHealTarget then
            if IsAlive(MBID[ConfigState.AssignedHealTarget]) then
                MTHeals(ConfigState.AssignedHealTarget)
                return
            else
                ConfigState.AssignedHealTarget = nil
                CdMessage("My healtarget died, time to ALT-F4.")
            end
        end

        for _, bossName in pairs(HealingState.Shaman.MainTankHealingBossList) do
            if TankTarget(bossName) then
                MTHeals()
                return
            end
        end

        if Instance.AQ40() and TankTarget("Princess Huhuran") then
            if TankTargetHealth() <= 0.32 then
                MBH_CastHeal("Chain Heal", 2, 3)
            else
                MBH_CastHeal("Healing Wave", 3, 5)
            end
            return
        elseif Instance.BWL() and TankTarget("Vaelastrasz the Corrupt") and MB_myVaelastraszBoxStrategy then
            if HasBuffOrDebuff("Burning Adrenaline", "player", "debuff") then
                MBH_CastHeal("Chain Heal", 3, 3)
                return
            end

            Cooldowns()

            if ConfigState.HealSpell == "Healing Wave" then
                if MB_myVaelastraszShamanHealing then
                    local activeShaman = GetActiveVaelastraszHealer()

                    if myName == activeShaman then
                        MTHeals()
                        return
                    end
                end

                MBH_CastHeal("Lesser Healing Wave", 6, 6)
                return
            end

            MBH_CastHeal("Chain Heal", 3, 3)
            return
        elseif Instance.MC() and TankTarget("Baron Geddon") then
            MBH_CastHeal("Chain Heal", 3, 3)
            return
        end

        if ConfigState.HealSpell == "Chain Heal" then
            MBH_CastHeal("Chain Heal", 1, 1)
        else
            MBH_CastHeal("Healing Wave", 3)
        end
    end

    local function Single()
        GetTarget()
        CancelAuraSet(RemoveBuffs)

        if not ConfigState.PlayerSpecc then
            CdMessage("My specc is fucked. Defaulting to Elemental.")
            ConfigState.PlayerSpecc = "Elemental"
        end

        if PartyIsPoisoned() then
            if ImBusy() then
                SpellStopCasting()
                return
            end

            CastSpellByName("Poison Cleansing Totem")
            CoolDownCast("Poison Cleansing Totem", 6)
            return
        end

        if Instance.NAXX() and TankTarget("Heigan the Unclean") then
            if MeleeDPSInParty() and PartyIsDiseased() then
                if ImBusy() then
                    SpellStopCasting()
                    return
                end

                CastSpellByName("Disease Cleansing Totem")
                CoolDownCast("Disease Cleansing Totem", 6)
                return
            end
        end

        Decurse()

        if ConfigState.DoInterrupt.Active and IsSpellReady(ConfigState.InterruptSpell[myClass]) then
            if ConfigState.InterruptTarget then
                GetMyInterruptTarget()
            end

            if ImBusy() then
                SpellStopCasting()
            end

            CastSpellByName(ConfigState.InterruptSpell[myClass] .. "(Rank 1)")
            CdPrint("Interrupting!")
            ConfigState.DoInterrupt.Active = false
            return
        end

        DropTotems()

        if ConfigState.PlayerSpecc == "Elemental" then
            Elemental()
            return
        end

        HealerJindo("Lightning Bolt")
        Heal()
    end

    local function LOA_Attack()
        if ImBusy() or not InCombat() then
            return
        end

        GetTarget()

        if ManaPct() < 0.17 then
            return
        end

        if IsSpellReady("Lightning Bolt") then
            CoolDownCast("Lightning Bolt", 6)
            return
        end

        AutoAttack()
    end

    MoronBox:RegisterExpose({
        Specc = function()
            local _, _, _, _, ns = GetTalentInfo(3, 13)
            local _, _, _, _, manaTide = GetTalentInfo(3, 15)
            local _, _, _, _, enhTotems = GetTalentInfo(2, 12)
            local _, _, _, _, eleMastery = GetTalentInfo(1, 14)

            if ns > 0 and manaTide > 0 then
                ConfigState.PlayerSpecc = "Deep Resto"
            elseif ns > 0 and enhTotems > 1 then
                ConfigState.PlayerSpecc = "Totem Resto"
            elseif eleMastery > 0 then
                ConfigState.PlayerSpecc = "Elemental"
            else
                ConfigState.PlayerSpecc = nil
            end
        end,
        Setup = function()
            if UnitMana("player") < 3060 and HasBuffNamed("Drink", "player") then
                return
            end

            if EquippedSetCount("The Earthshatter") >= 8 then
                SelfBuff("Lightning Shield")
            end

            if ImHealer() then
                MBH_CastHeal("Chain Heal", 1, 1)
            end

            if not InCombat() and ManaPct() < 0.20 and not HasBuffNamed("Drink", "player") then
                SmartDrink()
            end
        end,
        Single = Single,
        Multi = Single,
        AOE = function()
            if MobsToAoeTotem() and IsSpellReady("Fire Nova Totem") then
                CastSpellByName("Fire Nova Totem")
                return
            end

            Single()
        end,
        PreCast = function()
            DropTotems()
        end,
        LoaHeal = function()
            GetTarget()
            CancelAuraSet(RemoveBuffs)

            if not ConfigState.PlayerSpecc then
                CdMessage("My specc is fucked. Defaulting to Elemental.")
                ConfigState.PlayerSpecc = "Elemental"
            end

            if PartyIsPoisoned() then
                if ImBusy() then
                    SpellStopCasting()
                    return
                end

                CastSpellByName("Poison Cleansing Totem")
                CoolDownCast("Poison Cleansing Totem", 6)
                return
            end

            if InCombat() then
                if IsSpellReady("Mana Tide Totem")
                    and not HasBuffOrDebuff("Mana Tide Totem", "player", "buff") then
                    local _, partyManaDown = PartyMana()
                    local avgManaDown = partyManaDown / NumOfCasterHealerInParty()
                    local myManaDown = ManaDown()

                    if (avgManaDown > 1500 and myManaDown > 1050) or (myManaDown > 1500) then
                        CastSpellByName("Mana Tide Totem")
                        CoolDownCast("Mana Tide Totem", 13)
                    end
                end

                TakeManaPotionAndRunes()

                if ManaDown() > 600 then
                    Cooldowns()
                end
            end

            DropTotems()

            if LOA_Healing() then
                return
            end

            LOA_Attack()
        end
    })
end, function()
    return myClass == "Shaman"
end)
