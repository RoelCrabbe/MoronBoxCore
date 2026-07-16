-- [[ Paladin Rotation ]] --
---@diagnostic disable: undefined-global

local NAME = "Paladin Rotation"
local MODULE_NAME = "MODULE_" .. string.upper(string.gsub(NAME, " ", "_"))

local myClass = UnitClass("player")

MoronBox:RegisterModule(MODULE_NAME, function()
    local PaladinCounter = {
        Cycle = function()
            MB_buffingCounterPaladin = (MB_buffingCounterPaladin >= TableLength(MB_classList["Paladin"]))
                and 1 or (MB_buffingCounterPaladin + 1)
        end
    }

    local RemoveBuffs = {
        ["Battle Shout"]     = "Battle Shout",
        ["Fengus' Ferocity"] = "Fengus' Ferocity",
        ["R.O.I.D.S."]       = "Rage of Ages"
    }

    local function GetActiveVaelastraszHealer()
        for _, name in ipairs(MB_myVaelastraszPaladins) do
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

        if not TankTarget("Viscidus") then
            if ManaPct() <= MB_paladinDivineFavorPercentage then
                SelfBuff("Divine Favor")
            end
        end

        CasterTrinkets()
        HealerTrinkets()
    end

    local function ChooseAura()
        if TankTarget("Lord Kazzak") then
            SelfBuff("Shadow Resistance Aura")
            return
        end

        if TankTarget("Sapphiron") or TankTarget("Azuregos") then
            SelfBuff("Frost Resistance Aura")
            return
        end

        local groupOrder = MyGroupClassOrder()
        if groupOrder == 1 then
            if IsFireBoss() then
                SelfBuff("Fire Resistance Aura")
                return
            end

            if MB_druidTankInParty or MB_warriorTankInParty or NumberOfClassInParty("Warrior") > 0 or NumberOfClassInParty("Rogue") > 0 then
                SelfBuff("Devotion Aura")
                return
            end

            SelfBuff("Concentration Aura")
        elseif groupOrder == 2 then
            SelfBuff("Concentration Aura")
        elseif groupOrder == 3 then
            SelfBuff("Retribution Aura")
        end
    end

    local function BlessMyAssignedBlessing()
        if TankTarget("Garr") or TankTarget("Firesworn") or TankTarget("Maexxna") then
            return
        end

        if not HaveInBags("Symbol of Kings") then
            CdMessage("Out of Symbol of Kings")
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

        local assignedBlessing = blessings[MyClassAlphabeticalOrder()]
        if assignedBlessing then
            MultiBuffBlessing(assignedBlessing)
        end
    end

    local function SealLight()
        if not IsValidMeleeTarget("target") then
            return
        end

        AssistFocus()

        if HasBuffOrDebuff("Judgement of Light", "target", "debuff") then
            return
        end

        AutoAttack()

        if not HasBuffOrDebuff("Seal of Light", "player", "buff") then
            CastSpellByName("Seal of Light")
            return
        end

        CastSpellByName("Judgement")
    end

    local function SealWisdom()
        if not IsValidMeleeTarget("target") then
            return
        end

        AssistFocus()

        if HasBuffOrDebuff("Judgement of Light", "target", "debuff") then
            return
        end

        AutoAttack()

        if not HasBuffOrDebuff("Seal of Wisdom", "player", "buff") then
            CastSpellByName("Seal of Wisdom")
            return
        end

        CastSpellByName("Judgement")
    end

    local FlashOfLight = { Time = 0, Interrupt = false }

    local function MTHeals(assignedTarget)
        if assignedTarget then
            TargetByName(assignedTarget, 1)
        else
            if TankTarget("Patchwerk") and MB_myPatchwerkBoxStrategy then
                TargetMyAssignedTankToHeal()
            else
                local tankTarget = UnitName(MBID[TankName()] .. "targettarget")
                if not tankTarget then
                    MBH_CastHeal("Flash of Light", 5, 6)
                else
                    TargetByName(tankTarget, 1)
                end
            end
        end

        if InCombat() and ManaPct() < 0.95 then
            SelfBuff("Divine Favor")
        end

        local flashOfLightSpell = "Flash of Light(" .. MB_myPaladinMainTankHealingRank .. ")"
        if TankTarget("Vaelastrasz the Corrupt") then
            flashOfLightSpell = "Holy Light"
        elseif TankTarget("Ossirian the Unscarred") then
            flashOfLightSpell = "Holy Light(rank 5)"
        end

        if not BossNeverInterruptHeal() and HealthDown("target") <= (GetHealValueFromRank("Flash of Light", MB_myPaladinMainTankHealingRank) * HealingState.MainTankOverhealingPercentage) then
            if GetTime() > FlashOfLight.Time and GetTime() < FlashOfLight.Time + 0.5 and FlashOfLight.Interrupt then
                SpellStopCasting()
                FlashOfLight.Interrupt = false
                SpellStopCasting()
            end
        end

        if not ImBusy() then
            CastSpellByName(flashOfLightSpell)
            FlashOfLight.Time = GetTime() + 0.25
            FlashOfLight.Interrupt = true
        end
    end

    local function BOPLowRandom()
        if GLUTH_IsAtGluth()
            or not UnitInRaid("player")
            or not InCombat()
            or ImBusy()
            or not IsSpellReady("Blessing of Protection") then
            return false
        end

        local classOrder = MyClassOrder()
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

            if aggrox:GetUnitAggroByUnitId(BOPTarget)
                and not FindInTable(MB_raidTanks, UnitName(BOPTarget))
                and IsValidFriendlyTarget(BOPTarget, "Blessing of Protection")
                and HealthPct(BOPTarget) <= blastNSatThisPercentage
                and not HasBuffOrDebuff("Forbearance", BOPTarget, "debuff") then
                if UnitIsFriend("player", BOPTarget) then
                    ClearTarget()
                end

                CastSpellByName("Blessing of Protection", nil)
                CdMessage("I BOP'd " ..
                    GetColors(UnitName(BOPTarget)) ..
                    " at " ..
                    string.sub(HealthPct(BOPTarget), 3, 4) ..
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

        Decurse()

        if InCombat() then
            --            MB_mySetupList["Paladin"]()

            if HealthPct() < 0.2 then
                SelfBuff("Divine Shield")
                return
            end

            TakeManaPotionAndRunes()

            if ManaDown() > 600 then
                Cooldowns()
            end
        end

        if HasBuffOrDebuff("Curse of Tongues", "player", "debuff") and not TankTarget("Anubisath Defender") then
            return
        end

        if HealLieutenantAQ20() or InstructorRazAddsHeal() then
            return
        end

        if ConfigState.AssignedHealTarget then
            if IsAlive(MBID[ConfigState.AssignedHealTarget]) then
                MTHeals(ConfigState.AssignedHealTarget)
                return
            else
                ConfigState.AssignedHealTarget = nil
                RunLine("/raid My healtarget died, time to ALT-F4.")
            end
        end

        for _, BossName in pairs(MB_myPaladinMainTankHealingBossList) do
            if TankTarget(BossName) then
                MTHeals()
                return
            end
        end

        if Instance.BWL() and TankTarget("Vaelastrasz the Corrupt") and MB_myVaelastraszBoxStrategy then
            if HasBuffOrDebuff("Burning Adrenaline", "player", "debuff") then
                MBH_CastHeal("Flash of Light", 6, 6)
                return
            end

            Cooldowns()

            if MB_myVaelastraszPaladinHealing then
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

        if HasBuffOrDebuff("Blinding Light", "player", "buff") or HasBuffOrDebuff("Divine Favor", "player", "buff") then
            MBH_CastHeal("Holy Light")
            return
        end

        MBH_CastHeal("Flash of Light", 6, 6)
    end

    local function Single()
        GetTarget()
        CancelAuraSet(RemoveBuffs)

        if Instance.NAXX() and RaidIsPoisoned() and ImBusy() then
            if TankTarget("Venom Stalker") or TankTarget("Necro Stalker") then
                SpellStopCasting()
            end
        end

        Decurse()

        if StunnableMob() then
            if not MB_autoBuff.Active then
                MB_autoBuff.Active = true
                MB_autoBuff.Time = GetTime() + 1
                PaladinCounter.Cycle()
            end

            if MyClassAlphabeticalOrder() == MB_buffingCounterPaladin then
                if IsSpellReady("Hammer of Justice") then
                    AssistFocus()
                    CastSpellByName("Hammer of Justice")
                end
            end
        end

        Heal()
        SealLight()
    end

    MoronBox:RegisterExpose({
        Setup = function()
            if UnitMana("player") < 3060 and HasBuffNamed("Drink", "player") then
                return
            end

            BlessMyAssignedBlessing()
            ChooseAura()

            if not InCombat() and ManaPct() < 0.20 and not HasBuffNamed("Drink", "player") then
                SmartDrink()
            end
        end,
        Single = Single,
        Multi = Single,
        AOE = Single
    })
end, function()
    return myClass == "Paladin"
end)
