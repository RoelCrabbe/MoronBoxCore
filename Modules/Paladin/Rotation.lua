-- [[ Paladin Rotation ]] --

local NAME = "Paladin Rotation"
local MODULE_NAME = "MODULE_" .. string.upper(string.gsub(NAME, " ", "_"))

local myName = UnitName("player")
local myClass = UnitClass("player")
local myRace = UnitRace("player")

MoronBox:RegisterModule(MODULE_NAME, function()
    local PaladinStunNr = 1

    local PaladinCounter = {
        Cycle = function()
            PaladinStunNr = (PaladinStunNr >= getApi().TableLength(getCoreState().ClassList["Paladin"]))
                and 1 or (PaladinStunNr + 1)
        end
    }

    local RemoveBuffs = {
        ["Battle Shout"]     = "Battle Shout",
        ["Fengus' Ferocity"] = "Fengus' Ferocity",
        ["R.O.I.D.S."]       = "Rage of Ages"
    }

    local function GetActiveVaelastraszHealer()
        for _, name in ipairs(getEncountersState().Vaelastrasz.PaladinHealers) do
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

        if not getRaid().TankTarget("Viscidus") then
            if getUnit().ManaPct() <= getHealingState().Paladin.DivineFavorPercentage then
                getSpells().SelfBuff("Divine Favor")
            end
        end

        getBag().CasterTrinkets()
        getBag().HealerTrinkets()
    end

    local function ChooseAura()
        if getRaid().TankTarget("Lord Kazzak") then
            getSpells().SelfBuff("Shadow Resistance Aura")
            return
        end

        if getRaid().TankTarget("Sapphiron") or getRaid().TankTarget("Azuregos") then
            getSpells().SelfBuff("Frost Resistance Aura")
            return
        end

        local groupOrder = getCore().MyGroupClassOrder()
        if groupOrder == 1 then
            if getTables().IsFireBoss() then
                getSpells().SelfBuff("Fire Resistance Aura")
                return
            end

            if getCoreState().DruidTankInParty or getCoreState().WarriorTankInParty or getCore().NumberOfClassInParty("Warrior") > 0 or getCore().NumberOfClassInParty("Rogue") > 0 then
                getSpells().SelfBuff("Devotion Aura")
                return
            end

            getSpells().SelfBuff("Concentration Aura")
        elseif groupOrder == 2 then
            getSpells().SelfBuff("Concentration Aura")
        elseif groupOrder == 3 then
            getSpells().SelfBuff("Retribution Aura")
        end
    end

    local function BlessMyAssignedBlessing()
        if getRaid().TankTarget("Garr") or getRaid().TankTarget("Firesworn") or getRaid().TankTarget("Maexxna") then
            return
        end

        if not getBag().HaveInBags("Symbol of Kings") then
            getApi().CdMessage("Out of Symbol of Kings")
            return
        end

        local blessings = {
            [1] = "Greater Blessing of Kings",
            [2] = "Greater Blessing of Might",
            [3] = "Greater Blessing of Salvation",
            [4] = "Greater Blessing of Light",
            [5] = "Greater Blessing of Sanctuary",
            [6] = "Greater Blessing of Wisdom"
        }

        local assignedBlessing = blessings[getCore().MyClassAlphabeticalOrder()]
        if assignedBlessing then
            getAura().MultiBuffBlessing(assignedBlessing)
        end
    end

    local function SealLight()
        if not getUnit().IsValidMeleeTarget("target") then
            return
        end

        getRaid().AssistFocus()

        if getAura().HasBuffOrDebuff("Judgement of Light", "target", "debuff") then
            return
        end

        getAttack().AutoAttack()

        if not getAura().HasBuffOrDebuff("Seal of Light", "player", "buff") then
            CastSpellByName("Seal of Light")
            return
        end

        CastSpellByName("Judgement")
    end

    local FlashOfLight = { Time = 0, Interrupt = false }

    local function MTHeals(assignedTarget)
        if assignedTarget then
            TargetByName(assignedTarget, 1)
        else
            if getRaid().TankTarget("Patchwerk") and getEncountersState().Patchwerk.Active then
                getHealing().TargetMyAssignedTankToHeal()
            else
                local tankTarget = UnitName(getCoreState().MBID[getUnit().GetTankName()] .. "targettarget")
                if not tankTarget then
                    MBH_CastHeal("Flash of Light", 5, 6)
                else
                    TargetByName(tankTarget, 1)
                end
            end
        end

        if getUnit().InCombat() and getUnit().ManaPct() < 0.95 then
            getSpells().SelfBuff("Divine Favor")
        end

        local flashOfLightSpell = "Flash of Light(" .. getHealingState().Paladin.MainTankHealingRank .. ")"
        if getRaid().TankTarget("Vaelastrasz the Corrupt") then
            flashOfLightSpell = "Holy Light"
        elseif getRaid().TankTarget("Ossirian the Unscarred") then
            flashOfLightSpell = "Holy Light(rank 5)"
        end

        if not getTables().BossNeverInterruptHeal() and getUnit().HealthDown("target") <= (getHealing().GetHealValueFromRank("Flash of Light", getHealingState().Paladin.MainTankHealingRank) * getHealingState().MainTankOverhealingPercentage) then
            if GetTime() > FlashOfLight.Time and GetTime() < FlashOfLight.Time + 0.5 and FlashOfLight.Interrupt then
                SpellStopCasting()
                FlashOfLight.Interrupt = false
                SpellStopCasting()
            end
        end

        if not getSpells().ImBusy() then
            CastSpellByName(flashOfLightSpell)
            FlashOfLight.Time = GetTime() + 0.25
            FlashOfLight.Interrupt = true
        end
    end

    local function BOPLowRandom()
        if GLUTH_IsAtGluth()
            or not UnitInRaid("player")
            or not getUnit().InCombat()
            or getSpells().ImBusy()
            or not getSpells().IsSpellReady("Blessing of Protection") then
            return false
        end

        local classOrder = getCore().MyClassOrder()
        local blastNSatThisPercentage = 0.3

        if classOrder == 1 then
            blastNSatThisPercentage = 0.45
        elseif classOrder == 2 then
            blastNSatThisPercentage = 0.40
        elseif classOrder == 3 then
            blastNSatThisPercentage = 0.35
        elseif classOrder == 4 then
            blastNSatThisPercentage = 0.30
        elseif classOrder >= 5 then
            blastNSatThisPercentage = 0.25
        end

        local aggrox = AceLibrary("Banzai-1.0")

        for i = 1, GetNumRaidMembers() do
            local BOPTarget = "raid" .. i

            if aggrox and aggrox:GetUnitAggroByUnitId(BOPTarget)
                and not getApi().FindInTable(getCoreState().RaidTanks, UnitName(BOPTarget))
                and getUnit().IsValidFriendlyTarget(BOPTarget, "Blessing of Protection")
                and getUnit().HealthPct(BOPTarget) <= blastNSatThisPercentage
                and not getAura().HasBuffOrDebuff("Forbearance", BOPTarget, "debuff") then
                if UnitIsFriend("player", BOPTarget) then
                    ClearTarget()
                end

                CastSpellByName("Blessing of Protection", nil)
                getApi().CdMessage("I BOP'd " ..
                    getApi().GetColors(UnitName(BOPTarget)) ..
                    " at " ..
                    string.sub(getUnit().HealthPct(BOPTarget), 3, 4) ..
                    "% - " .. UnitHealth(BOPTarget) .. "/" .. UnitHealthMax(BOPTarget) .. " HP.")

                SpellTargetUnit(BOPTarget)
                SpellStopTargeting()
                return true
            end
        end

        return false
    end

    local function Heal()
        if BOPLowRandom() then
            return
        end

        getDispel().Decurse()

        if getUnit().InCombat() then
            --            MB_mySetupList["Paladin"]()

            if getUnit().HealthPct() < 0.2 then
                getSpells().SelfBuff("Divine Shield")
                return
            end

            getCons().TakeManaPotionAndRunes()

            if getUnit().ManaDown() > 600 then
                Cooldowns()
            end
        end

        if getAura().HasBuffOrDebuff("Curse of Tongues", "player", "debuff") and not getRaid().TankTarget("Anubisath Defender") then
            return
        end

        if getHealing().HealLieutenantAQ20() or getHealing().InstructorRazAddsHeal() then
            return
        end

        if getConfigState().AssignedHealTarget then
            if getUnit().IsAlive(getCoreState().MBID[getConfigState().AssignedHealTarget]) then
                MTHeals(getConfigState().AssignedHealTarget)
                return
            else
                getConfigState().AssignedHealTarget = nil
                getApi().CdMessage("My healtarget died, time to ALT-F4.")
            end
        end

        for _, bossName in pairs(getHealingState().Paladin.MainTankHealingBossList) do
            if getRaid().TankTarget(bossName) then
                MTHeals()
                return
            end
        end

        if Instance.BWL() and getRaid().TankTarget("Vaelastrasz the Corrupt") and getEncountersState().Vaelastrasz.Active then
            if getAura().HasBuffOrDebuff("Burning Adrenaline", "player", "debuff") then
                MBH_CastHeal("Flash of Light", 6, 6)
                return
            end

            Cooldowns()

            if getEncountersState().Vaelastrasz.PaladinHealing then
                local activePaladin = GetActiveVaelastraszHealer()
                if myName == activePaladin then
                    MTHeals()
                    return
                end
            end

            MBH_CastHeal("Flash of Light", 6, 6)
            SealLight()
            return
        end

        if getAura().HasBuffOrDebuff("Blinding Light", "player", "buff") or getAura().HasBuffOrDebuff("Divine Favor", "player", "buff") then
            MBH_CastHeal("Holy Light")
            return
        end

        MBH_CastHeal("Flash of Light", 6, 6)
    end

    local function Single()
        getRaid().GetTarget()
        getAura().CancelAuraSet(RemoveBuffs)

        if Instance.NAXX() and getDispel().RaidIsPoisoned() and getSpells().ImBusy() then
            if getRaid().TankTarget("Venom Stalker") or getRaid().TankTarget("Necro Stalker") then
                SpellStopCasting()
            end
        end

        getDispel().Decurse()

        if getTables().StunnableMob() then
            if not getConfigState().PaladinHOJ.Active then
                getConfigState().PaladinHOJ.Active = true
                getConfigState().PaladinHOJ.Time = GetTime() + 1
                PaladinCounter.Cycle()
            end

            if getCore().MyClassAlphabeticalOrder() == PaladinStunNr then
                if getSpells().IsSpellReady("Hammer of Justice") then
                    getRaid().AssistFocus()
                    CastSpellByName("Hammer of Justice")
                end
            end
        end

        Heal()
        SealLight()
    end

    MoronBox:RegisterExpose({
        Setup = function()
            if UnitMana("player") < 3060 and getAura().HasBuffNamed("Drink", "player") then
                return
            end

            BlessMyAssignedBlessing()
            ChooseAura()

            if not getUnit().InCombat() and getUnit().ManaPct() < 0.20 and not getAura().HasBuffNamed("Drink", "player") then
                getWater().SmartDrink()
            end
        end,
        Single = Single,
        Multi = Single,
        AOE = Single
    })
end, function()
    return myClass == "Paladin"
end)
