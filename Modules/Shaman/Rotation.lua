-- [[ Shaman Rotation ]] --

local NAME = "Shaman Rotation"
local MODULE_NAME = "MODULE_" .. string.upper(string.gsub(NAME, " ", "_"))

local myName = UnitName("player")
local myClass = UnitClass("player")

MoronBox:RegisterModule(MODULE_NAME, function()
    local RemoveBuffs = {
        ["Battle Shout"]     = "Battle Shout",
        ["Fengus' Ferocity"] = "Fengus' Ferocity",
        ["R.O.I.D.S."]       = "Rage of Ages"
    }

    local function GetActiveVaelastraszHealer()
        for _, name in ipairs(getEncountersState().Vaelastrasz.ShamanHealers) do
            local id = getCoreState().MBID[name]
            if id and not getUnit().Dead(id) then
                return name
            end
        end
        return nil
    end

    local function Cooldowns()
        if getSpells().ImBusy() or not getUnit().InCombat() then
            return
        end

        getSpells().SelfBuff("Berserking")
        getSpells().SelfBuff("Elemental Mastery")

        if getGear().EquippedSetCount("The Earthshatter") >= 8 then
            getSpells().SelfBuff("Lightning Shield")
        end

        getBag().HealerTrinkets()
        getBag().CasterTrinkets()
    end

    local function BossSpecificDPS()
        local target = UnitName("target")

        if target == "Emperor Vek'nilash" then
            return true
        end

        if getAura().HasBuffNamed("Shadow and Frost Reflect", "target") or
            getAura().HasBuffOrDebuff("Magic Reflection", "target", "buff") or
            (getRaid().TankTarget("Azuregos") and getAura().HasBuffNamed("Magic Shield", "target")) then
            if getSpells().ImBusy() then
                SpellStopCasting()
            end

            getAttack().AutoAttack()
            return true
        end

        return false
    end

    local function Elemental()
        if not getUnit().InCombat("target") then
            return
        end

        if getUnit().InCombat() then
            getCons().TakeManaPotionAndRunes()

            if getUnit().ManaDown() > 600 then
                Cooldowns()
            end
        end

        if BossSpecificDPS() then
            return
        end

        if getSpells().ImBusy() then
            return
        end

        if getSpells().IsSpellReady("Chain Lightning") then
            getSpells().CastOrWand("Chain Lightning")
        else
            getSpells().CastOrWand("Lightning Bolt")
        end
    end

    local HealWave = { Time = 0, Interrupt = false }

    local function MTHeals(assignedTarget)
        if assignedTarget then
            TargetByName(assignedTarget, 1)
        else
            if getRaid().TankTarget("Patchwerk") and getEncountersState().Patchwerk.Active then
                getHealing().TargetMyAssignedTankToHeal()
            else
                local tankTarget = UnitName(getCoreState().MBID[getUnit().GetTankName()] .. "targettarget")
                if not tankTarget then
                    MBH_CastHeal("Healing Wave", 3)
                else
                    TargetByName(tankTarget, 1)
                end
            end
        end

        if getSpells().IsSpellReady("Nature\'s Swiftness") and getUnit().HealthPct("target") <= 0.15 then
            if not getAura().HasBuffOrDebuff("Nature\'s Swiftness", "player", "buff") then
                SpellStopCasting()
            end

            getSpells().SelfBuff("Nature\'s Swiftness")
        end

        if getAura().HasBuffOrDebuff("Nature\'s Swiftness", "player", "buff") then
            CastSpellByName("Healing Wave")
            return
        end

        local healWaveSpell = getRaid().TankTarget("Vaelastrasz the Corrupt") and "Healing Wave" or
            ("Healing Wave(" .. getHealingState().Shaman.MainTankHealingRank .. ")")

        if not getTables().BossNeverInterruptHeal() and getUnit().HealthDown("target") <= (getHealing().GetHealValueFromRank("Healing Wave", getHealingState().Shaman.MainTankHealingRank) * getHealingState().MainTankOverhealingPercentage) then
            if GetTime() > HealWave.Time and GetTime() < HealWave.Time + 0.5 and HealWave.Interrupt then
                SpellStopCasting()
                HealWave.Interrupt = false
                SpellStopCasting()
            end
        end

        if not getSpells().ImBusy() then
            CastSpellByName(healWaveSpell)
            HealWave.Time = GetTime() + 1
            HealWave.Interrupt = true
        end
    end

    local function Heal()
        if getHealing().NatureSwiftnessLowAggroedPlayer() then
            return
        end

        if getUnit().InCombat() then
            if getSpells().IsSpellReady("Mana Tide Totem")
                and not getAura().HasBuffOrDebuff("Mana Tide Totem", "player", "buff") then
                local _, partyManaDown = getUnit().PartyMana()
                local avgManaDown = partyManaDown / getCore().NumOfCasterHealerInParty()
                local myManaDown = getUnit().ManaDown()

                if (avgManaDown > 1500 and myManaDown > 1050) or (myManaDown > 1500) then
                    CastSpellByName("Mana Tide Totem")
                    getSpells().CastSpellWithCooldown("Mana Tide Totem", 13)
                end
            end

            getCons().TakeManaPotionAndRunes()

            if getUnit().ManaDown() > 600 then
                Cooldowns()
            end
        end

        if getAura().HasBuffOrDebuff("Curse of Tongues", "player", "debuff") and not getRaid().TankTarget("Anubisath Defender") then return end
        if getHealing().HealLieutenantAQ20() or getHealing().InstructorRazAddsHeal() then return end

        if getConfigState().AssignedHealTarget then
            if getUnit().IsAlive(getCoreState().MBID[getConfigState().AssignedHealTarget]) then
                MTHeals(getConfigState().AssignedHealTarget)
                return
            else
                getConfigState().AssignedHealTarget = nil
                getApi().CdMessage("My healtarget died, time to ALT-F4.")
            end
        end

        for _, bossName in pairs(getHealingState().Shaman.MainTankHealingBossList) do
            if getRaid().TankTarget(bossName) then
                MTHeals()
                return
            end
        end

        if Instance.AQ40() and getRaid().TankTarget("Princess Huhuran") then
            if getRaid().TankTargetHealth() <= 0.32 then
                MBH_CastHeal("Chain Heal", 2, 3)
            else
                MBH_CastHeal("Healing Wave", 3, 5)
            end
            return
        elseif Instance.BWL() and getRaid().TankTarget("Vaelastrasz the Corrupt") and getEncountersState().Vaelastrasz.Active then
            if getAura().HasBuffOrDebuff("Burning Adrenaline", "player", "debuff") then
                MBH_CastHeal("Chain Heal", 3, 3)
                return
            end

            Cooldowns()

            if getConfigState().HealSpell == "Healing Wave" then
                if getEncountersState().Vaelastrasz.ShamanHealing then
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
        elseif Instance.MC() and getRaid().TankTarget("Baron Geddon") then
            MBH_CastHeal("Chain Heal", 3, 3)
            return
        end

        if getConfigState().HealSpell == "Chain Heal" then
            MBH_CastHeal("Chain Heal", 1, 1)
        else
            MBH_CastHeal("Healing Wave", 3)
        end
    end

    local function Single()
        getRaid().GetTarget()
        getAura().CancelAuraSet(RemoveBuffs)

        if not getConfigState().PlayerSpecc then
            getApi().CdMessage("My specc is fucked. Defaulting to Elemental.")
            getConfigState().PlayerSpecc = "Elemental"
        end

        if getDispel().PartyIsPoisoned() then
            if getSpells().ImBusy() then
                SpellStopCasting()
                return
            end

            CastSpellByName("Poison Cleansing Totem")
            getSpells().CastSpellWithCooldown("Poison Cleansing Totem", 6)
            return
        end

        if Instance.NAXX() and getRaid().TankTarget("Heigan the Unclean") then
            if getCore().MeleeDPSInParty() and getDispel().PartyIsDiseased() then
                if getSpells().ImBusy() then
                    SpellStopCasting()
                    return
                end

                CastSpellByName("Disease Cleansing Totem")
                getSpells().CastSpellWithCooldown("Disease Cleansing Totem", 6)
                return
            end
        end

        getDispel().Decurse()

        if getConfigState().DoInterrupt.Active and getSpells().IsSpellReady(getConfigState().InterruptSpell[myClass]) then
            if getConfigState().InterruptTarget then
                getRaid().GetMyInterruptTarget()
            end

            if getSpells().ImBusy() then
                SpellStopCasting()
            end

            CastSpellByName(getConfigState().InterruptSpell[myClass] .. "(Rank 1)")
            getApi().CdPrint("Interrupting!")
            getConfigState().DoInterrupt.Active = false
            return
        end

        getBuffs().DropTotems()

        if getConfigState().PlayerSpecc == "Elemental" then
            Elemental()
            return
        end

        getRotation().HealerJindo("Lightning Bolt")
        Heal()
    end

    local function LOA_Attack()
        if getSpells().ImBusy() or not getUnit().InCombat() then
            return
        end

        getRaid().GetTarget()

        if getUnit().ManaPct() < 0.17 then
            return
        end

        if getSpells().IsSpellReady("Lightning Bolt") then
            getSpells().CastSpellWithCooldown("Lightning Bolt", 6)
            return
        end

        getAttack().AutoAttack()
    end

    MoronBox:RegisterExpose({
        Specc = function()
            local _, _, _, _, ns = GetTalentInfo(3, 13)
            local _, _, _, _, manaTide = GetTalentInfo(3, 15)
            local _, _, _, _, enhTotems = GetTalentInfo(2, 12)
            local _, _, _, _, eleMastery = GetTalentInfo(1, 14)

            if ns > 0 and manaTide > 0 then
                getConfigState().PlayerSpecc = "Deep Resto"
            elseif ns > 0 and enhTotems > 1 then
                getConfigState().PlayerSpecc = "Totem Resto"
            elseif eleMastery > 0 then
                getConfigState().PlayerSpecc = "Elemental"
            else
                getConfigState().PlayerSpecc = nil
            end
        end,
        Setup = function()
            if UnitMana("player") < 3060 and getAura().HasBuffNamed("Drink", "player") then
                return
            end

            if getGear().EquippedSetCount("The Earthshatter") >= 8 then
                getSpells().SelfBuff("Lightning Shield")
            end

            if getCore().ImHealer() then
                MBH_CastHeal("Chain Heal", 1, 1)
            end

            if not getUnit().InCombat() and getUnit().ManaPct() < 0.20 and not getAura().HasBuffNamed("Drink", "player") then
                getWater().SmartDrink()
            end
        end,
        Single = Single,
        Multi = Single,
        AOE = function()
            if getTables().MobsToAoeTotem() and getSpells().IsSpellReady("Fire Nova Totem") then
                CastSpellByName("Fire Nova Totem")
                return
            end

            Single()
        end,
        PreCast = function()
            getBuffs().DropTotems()
        end,
        LoaHeal = function()
            getRaid().GetTarget()
            getAura().CancelAuraSet(RemoveBuffs)

            if not getConfigState().PlayerSpecc then
                getApi().CdMessage("My specc is fucked. Defaulting to Elemental.")
                getConfigState().PlayerSpecc = "Elemental"
            end

            if getDispel().PartyIsPoisoned() then
                if getSpells().ImBusy() then
                    SpellStopCasting()
                    return
                end

                CastSpellByName("Poison Cleansing Totem")
                getSpells().CastSpellWithCooldown("Poison Cleansing Totem", 6)
                return
            end

            if getUnit().InCombat() then
                if getSpells().IsSpellReady("Mana Tide Totem")
                    and not getAura().HasBuffOrDebuff("Mana Tide Totem", "player", "buff") then
                    local _, partyManaDown = getUnit().PartyMana()
                    local avgManaDown = partyManaDown / getCore().NumOfCasterHealerInParty()
                    local myManaDown = getUnit().ManaDown()

                    if (avgManaDown > 1500 and myManaDown > 1050) or (myManaDown > 1500) then
                        CastSpellByName("Mana Tide Totem")
                        getSpells().CastSpellWithCooldown("Mana Tide Totem", 13)
                    end
                end

                getCons().TakeManaPotionAndRunes()

                if getUnit().ManaDown() > 600 then
                    Cooldowns()
                end
            end

            getBuffs().DropTotems()

            if LOA_Healing() then
                return
            end

            LOA_Attack()
        end
    })
end, function()
    return myClass == "Shaman"
end)
