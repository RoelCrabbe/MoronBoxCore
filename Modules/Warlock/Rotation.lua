-- [[ Warlock Rotation ]] --

local NAME = "Warlock Rotation"
local MODULE_NAME = "MODULE_" .. string.upper(string.gsub(NAME, " ", "_"))

local myClass = UnitClass("player")

MoronBox:RegisterModule(MODULE_NAME, function()
    local WarlockCounter = {
        Cycle = function()
            getConfigState().SheepingWarlockNr = (getConfigState().SheepingWarlockNr >= getApi().TableLength(getCoreState().ClassList["Warlock"]))
                and 1 or (getConfigState().SheepingWarlockNr + 1)
        end
    }

    local RemoveBuffs = {
        ["Battle Shout"]     = "Battle Shout",
        ["Fengus' Ferocity"] = "Fengus' Ferocity",
        ["Polished Armor"]   = "Polished Armor",
        ["R.O.I.D.S."]       = "Rage of Ages",
        ["Very Berry Cream"] = "Very Berry Cream",
    }

    local function HavePet()
        return UnitHealth("pet") > 0
    end

    local function ShadowBoltWhoring()
        if getSpells().ImBusy() or not UnitExists("target") then
            return
        end

        local sb = getAura().GetImprovedShadowBoltAmount()
        local sw = getAura().GetShadowWeavingAmount()
        local isBuffed = (sw == 5 and sb >= 4)

        if isBuffed then
            getBag().CasterTrinkets()
        end

        if isBuffed and getBag().NumShards() > 12 and getSpells().IsSpellReady("Shadowburn") then
            CastSpellByName("Shadowburn")
        end

        getSpells().CastOrWand("Shadow Bolt")
    end

    local function SaveShardShadowburn(shardsToSave)
        local minShards = shardsToSave or 0

        if not getSpells().IsSpellReady("Shadowburn") or getBag().NumShards() <= minShards then
            return
        end

        CastSpellByName("Shadowburn")
    end

    local function Cooldowns()
        if getSpells().ImBusy() or not getUnit().InCombat() then
            return
        end

        getSpells().SelfBuff("Berserking")
        getBag().HealerTrinkets()
        getBag().CasterTrinkets()
    end

    local function HealthStone()
        if getSpells().ImBusy() or not getUnit().InCombat() then
            return
        end

        if getUnit().HealthPct() > 0.15 then
            return
        end

        if not getBag().HaveInBags("Major Healthstone") then
            return
        end

        if getBag().IsItemInBagCoolDown("Major Healthstone") then
            return
        end

        SpellStopCasting()
        UseItemByName("Major Healthstone")
    end

    local function SumPetAndSac()
        if getAura().HasBuffOrDebuff("Touch of Shadow", "player", "buff") then
            return
        end

        if UnitCreatureFamily("pet") == "Succubus" and getSpells().IsSpellKnown("Demonic Sacrifice") then
            CastSpellByName("Demonic Sacrifice")
            return
        end

        if getBag().NumShards() == 0 then
            return
        end

        if getSpells().IsSpellKnown("Summon Succubus") and getSpells().IsSpellKnown("Fel Domination") and getSpells().IsSpellReady("Fel Domination") then
            CastSpellByName("Fel Domination")
            return
        end

        if getSpells().IsSpellKnown("Summon Succubus") then
            CastSpellByName("Summon Succubus")
        end
    end

    local function TapWhileMoving()
        if getUnit().HealthPct() < 0.40 or UnitMana("player") == UnitManaMax("player") then
            return
        end

        if getUnit().ManaPct() < 0.80 and getUnit().HealthPct() > 0.55 then
            CastSpellByName("Life Tap")
        end
    end

    local function CreateHealthStone()
        if getBag().NumShards() < 2
            or getBag().GetAllContainerFreeSlots() < 1
            or getUnit().InCombat()
            or getBag().HaveInBags("Major Healthstone") then
            return
        end

        CastSpellByName("Create Healthstone (Major)")
    end

    local function CreateSoulStone()
        local spellId = getSpells().GetSpellNumber("Create Soulstone.*Major")

        if not spellId
            or getBag().NumShards() < 1
            or getBag().HaveInBags("Major Soulstone") then
            return
        end

        CastSpell(spellId, BOOKTYPE_SPELL)
    end

    local CURSE_PRIO_CASTER = {
        "Curse of the Elements", "Curse of Shadow", "Curse of Recklessness",
        "Curse of the Elements", "Curse of Shadow", "Curse of Recklessness"
    }

    local CURSE_PRIO_MELEE = {
        "Curse of Recklessness", "Curse of the Elements", "Curse of Shadow",
        "Curse of Recklessness", "Curse of the Elements", "Curse of Shadow"
    }

    local function Curses()
        if Instance.NAXX() and THAD_IsAtThaddiusP1() and MB_myThaddiusBoxStrategy then
            return THAD_WarlockDebuffP1()
        end

        if Instance.AQ40() and SKERAM_InFight() and SKERAM_BoxStrategyEnabled() then
            return SKERAM_WarlockDebuff()
        end

        if Instance.BWL() and getRaid().IsAtRazorgore() and getRaid().IsAtRazorgorePhase() and getEncountersState().Razorgore.Active then
            local myOrder = getCore().MyClassAlphabeticalOrder()
            local tankMap = { getEncountersState().Razorgore.RightMainTank, getEncountersState().Razorgore.LeftMainTank }
            local tankName = tankMap[myOrder] and getApi().ReturnPlayerInRaidFromTable(tankMap[myOrder])

            if tankName and getRaid().TargetFromSpecificPlayer("Death Talon Dragonspawn", tankName) then
                local tankId = getCoreState().MBID[tankName]
                local tankTargetId = tankId .. "target"

                if not getAura().HasBuffOrDebuff("Curse of Recklessness", tankTargetId, "debuff") then
                    AssistUnit(tankId)
                    CastSpellByName("Curse of Recklessness")
                    TargetLastTarget()
                    return true
                end
            end
            return false
        end

        local casters = getCore().NumberOfClassInRaid("Mage") + getCore().NumberOfClassInRaid("Warlock")
        local melees = getCore().NumberOfClassInRaid("Warrior") + getCore().NumberOfClassInRaid("Rogue") +
            getCore().NumberOfClassInRaid("Hunter")

        local curseList = (casters > melees) and CURSE_PRIO_CASTER or CURSE_PRIO_MELEE
        local myOrder = getCore().MyClassAlphabeticalOrder()
        local assignedCurse = curseList[myOrder]

        if assignedCurse and not getAura().HasBuffOrDebuff(assignedCurse, "target", "debuff") then
            CastSpellByName(assignedCurse)
            return true
        end

        return false
    end

    local function SoulStone()
        if getAura().HasBuffNamed("Drink", "player") or getSpells().ImBusy() then
            return
        end

        CreateSoulStone()

        if getBag().IsItemInBagCoolDown("Major Soulstone") then
            return
        end

        if not getConfigState().AutoSoulStone.Active then
            getConfigState().AutoSoulStone.Active = true
            getConfigState().AutoSoulStone.Time = GetTime() + 6
            WarlockCounter.Cycle()
        end

        if getAura().SomeoneInRaidBuffedWith("Soulstone") or getCore().MyClassAlphabeticalOrder() ~= getConfigState().SheepingWarlockNr then
            return
        end

        local targetClasses = { "Priest", "Shaman" }
        for _, class in ipairs(targetClasses) do
            local classList = getCoreState().ClassList[class]

            if classList then
                for i = 1, getApi().TableLength(classList) do
                    local name = classList[i]
                    local id = getCoreState().MBID[name]

                    if id and not getAura().HasBuffOrDebuff("Soulstone", id, "buff") then
                        getApi().getApi().CdMessage("Soulstoning " .. getApi().GetColors(name))
                        TargetUnit(id)
                        UseItemByName("Major Soulstone")
                        ClearCursor()
                        return
                    end
                end
            end
        end
    end

    local function BossSpecificDPS()
        local tName = UnitName("target")

        if tName == "Emperor Vek'nilash" then
            return true
        end

        if tName == "Chromaggus" then
            CastSpellByName("Curse of Recklessness")
            return true
        end

        if not getAura().HasBuffNamed("Shadow and Frost Reflect", "target") and Curses() then
            return true
        end

        if not getAura().HasBuffOrDebuff("Shadow Ward", "player", "buff") and getSpells().IsSpellReady("Shadow Ward") then
            if getTables().MobsToShadowWard() or getTables().DebuffsToShadowWard() then
                getSpells().SelfBuff("Shadow Ward")
                return true
            end
        end

        if getAura().HasBuffNamed("Shadow and Frost Reflect", "target") then
            if getSpells().IsSpellReady("Soul Fire") and getBag().NumShards() > 10 then
                getSpells().CastOrWand("Soul Fire")
            end

            getSpells().CastOrWand("Immolate")
            return true
        elseif getAura().HasBuffOrDebuff("Magic Reflection", "target", "buff") then
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
            if tName == "Emperor Vek'lor" and getEncountersState().TwinEmps.Active and getApi().FindMyNameInTable(getEncountersState().TwinEmps.WarlockTanks) then
                getSpells().SelfBuff("Shadow Ward")
                SaveShardShadowburn(3)

                if getUnit().HealthPct() < 0.25 and getSpells().IsSpellReady("Death Coil") then
                    CastSpellByName("Death Coil")
                end

                CastSpellByName("Searing Pain")
                return true
            elseif tName == "Obsidian Eradicator" and getUnit().ManaPct("target") > 0.7 and not getSpells().ImBusy() then
                CastSpellByName("Drain Mana")
                return true
            end

            if FANKRISS_WarlockDPS() then
                return true
            end
        end

        if Instance.BWL() and getTables().getTables().CorruptedTotems() and not getUnit().Dead("target") then
            SaveShardShadowburn(12)
            getSpells().CastOrWand("Searing Pain")
            return true
        end

        if Instance.MC() and getRaid().TankTarget("Shazzrah") then
            if not getSpells().IsSpellReady("Shadow Bolt") then
                getSpells().CastOrWand("Immolate")
                return true
            end
        end

        if Instance.ONY() and getRaid().TankTarget("Onyxia") and getConfigState().IsMoving.Active then
            getSpells().CoolDownCast("Corruption", 18)

            if getRaid().TankTargetHealth() <= 0.65 and getRaid().TankTargetHealth() >= 0.4 then
                SaveShardShadowburn(12)
            end
        end

        if Instance.ZG() then
            if getAura().HasBuffOrDebuff("Delusions of Jin'do", "player", "debuff") and tName == "Shade of Jin'do" and not getUnit().Dead("target") then
                SaveShardShadowburn(12)
                getSpells().CastOrWand("Searing Pain")
                return true
            end

            if (tName == "Powerful Healing Ward" or tName == "Brain Wash Totem") and not getUnit().Dead("target") then
                SaveShardShadowburn(12)
                getSpells().CastOrWand("Searing Pain")
                return true
            end
        end

        if Instance.AQ20() then
            if getRaid().TankTarget("Moam") and getUnit().ManaPct("target") > 0.75 and not getSpells().ImBusy() then
                CastSpellByName("Drain Mana")
            end

            if getRaid().TankTarget("Ossirian the Unscarred") then
                if getAura().HasBuffOrDebuff("Fire Weakness", "target", "debuff") then
                    if getSpells().IsSpellReady("Soul Fire") and getBag().NumShards() > 10 then
                        getSpells().CastOrWand("Soul Fire")
                    end

                    getSpells().CastOrWand("Immolate")
                    return true
                elseif getAura().HasBuffOrDebuff("Shadow Weakness", "target", "debuff") then
                    getSpells().CastOrWand("Shadow Bolt")
                    return true
                end
            end
        end

        return false
    end

    local function Single()
        getRaid().GetTarget()
        getAura().CancelAuraSet(RemoveBuffs)

        if not getConfigState().PlayerSpecc then
            getApi().getApi().CdMessage("My specc is fucked. Defaulting to Corruption.")
            getConfigState().PlayerSpecc = "Corruption"
        end

        if getCrowdControl().CastCrowdControl() then
            return
        end

        if getUnit().ManaPct() < 0.40 and getUnit().HealthPct() > 0.75 then
            CastSpellByName("Life Tap")
            return
        end

        if getAura().HasBuffOrDebuff("Hellfire", "player", "buff") then
            CastSpellByName("Life Tap(Rank 1)")
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

        if Instance.AQ40() then
            if getAura().HasBuffOrDebuff("True Fulfillment", "target", "debuff") then
                ClearTarget()
                return
            end
        end

        if not getUnit().InCombat("target") then
            return
        end

        if getUnit().InCombat() then
            HealthStone()
            getCons().TakeManaPotionAndRunes()

            if getSpells().IsSpellKnown("Demonic Sacrifice") and not getAura().HasBuffOrDebuff("Touch of Shadow", "player", "buff") then
                SumPetAndSac()
            end

            if getConfigState().IsMoving.Active then
                TapWhileMoving()
            end

            if getUnit().ManaDown() > 600 then
                Cooldowns()
            end
        end

        if BossSpecificDPS() then
            return
        end

        if not Instance.IsWorldBoss() and getUnit().HealthPct("target") < 0.2 and getBag().NumShards() < 60
            and getBag().GetAllContainerFreeSlots() >= 10 and not getSpells().ImBusy() then
            CastSpellByName("Drain Soul(Rank 1)")
            return
        end

        if getConfigState().PlayerSpecc == "Shadowburn" and getSettingsState().Warlock.ShouldBeWhores then
            ShadowBoltWhoring()
        else
            getSpells().CastOrWand("Shadow Bolt")

            if not getSpells().IsSpellReady("Shadow Bolt") then
                getSpells().CastOrWand("Searing Pain")
            end
        end
    end

    MoronBox:RegisterExpose({
        Specc = function()
            local _, _, _, _, shadowBurn = GetTalentInfo(2, 13)
            local _, _, _, _, ruin = GetTalentInfo(3, 8)
            local _, _, _, _, corruption = GetTalentInfo(1, 11)

            if shadowBurn > 0 and ruin > 0 then
                getConfigState().PlayerSpecc = "Shadowburn"
            elseif corruption > 0 then
                getConfigState().PlayerSpecc = "Corruption"
            else
                getConfigState().PlayerSpecc = nil
            end
        end,
        Setup = function()
            if UnitMana("player") < 3060 and getAura().HasBuffNamed("Drink", "player") then
                return
            end

            if IsAltKeyDown() then
                if not getConfigState().AutoSoulStone.Active then
                    getConfigState().AutoSoulStone.Active = true
                    getConfigState().AutoSoulStone.Time = GetTime() + 3
                    WarlockCounter.Cycle()
                end

                if getCore().MyClassAlphabeticalOrder() == getConfigState().SheepingWarlockNr then
                    SoulStone()
                end
            end

            getSpells().SelfBuff("Demon Armor")

            if getSpells().IsSpellKnown("Demonic Sacrifice") then
                if not getAura().HasBuffOrDebuff("Touch of Shadow", "player", "buff") then
                    SumPetAndSac()
                end
            else
                if not HavePet() then
                    CastSpellByName("Summon Imp")
                end
            end

            CreateHealthStone()

            if not getUnit().InCombat() and getUnit().ManaPct() < 0.20 and not getAura().HasBuffNamed("Drink", "player") then
                getWater().SmartDrink()
            end
        end,
        Single = Single,
        Multi = Single,
        AOE = function()
            getRaid().GetTarget()
            getAura().CancelAuraSet(RemoveBuffs)

            if not getConfigState().PlayerSpecc then
                getApi().getApi().CdMessage("My specc is fucked. Defaulting to Corruption.")
                getConfigState().PlayerSpecc = "Corruption"
            end

            if UnitMana("player") < 1250 and not getSpells().ImBusy() then
                CastSpellByName("Life Tap")
                return
            end

            if getUnit().InCombat() then
                HealthStone()
                getCons().TakeManaPotionAndRunes()

                if getUnit().ManaDown() > 600 then
                    Cooldowns()
                end
            end

            if not getAura().HasBuffOrDebuff("Hellfire", "player", "buff") then
                CastSpellByName("Hellfire")
            end
        end,
        PreCast = function()
            getBag().PreCastTrinkets()
            CastSpellByName("Shadow Bolt")
        end
    })
end, function()
    return myClass == "Warlock"
end)
