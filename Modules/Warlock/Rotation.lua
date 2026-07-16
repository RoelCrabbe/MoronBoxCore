-- [[ Warlock Rotation ]] --
---@diagnostic disable: undefined-global

local NAME = "Warlock Rotation"
local MODULE_NAME = "MODULE_" .. string.upper(string.gsub(NAME, " ", "_"))

local myClass = UnitClass("player")

MoronBox:RegisterModule(MODULE_NAME, function()
    local WarlockCounter = {
        Cycle = function()
            ConfigState.SheepingWarlockNr = (ConfigState.SheepingWarlockNr >= TableLength(GeneralState.ClassList["Warlock"]))
                and 1 or (ConfigState.SheepingWarlockNr + 1)
        end
    }

    local RemoveBuffs = {
        ["Battle Shout"]     = "Battle Shout",
        ["Fengus' Ferocity"] = "Fengus' Ferocity",
        ["Polished Armor"]   = "Polished Armor",
        ["R.O.I.D.S."]       = "Rage of Ages",
        ["Very Berry Cream"] = "Very Berry Cream",
    }

    local function WarlockCancelAuras()
        for itemName, buffName in pairs(RemoveBuffs) do
            if HasBuffOrDebuff(itemName, "player", "buff") then
                CancelBuff(buffName)
            end
        end
    end

    local function HavePet()
        return UnitHealth("pet") > 0
    end

    local function ShadowBoltWhoring()
        if ImBusy() or not UnitExists("target") then
            return
        end

        local sb = DebuffImpShadowBoltAmount()
        local sw = DebuffShadowWeavingAmount()
        local isBuffed = (sw == 5 and sb >= 4)

        if isBuffed then
            CasterTrinkets()
        end

        if isBuffed and NumShards() > 12 and IsSpellReady("Shadowburn") then
            CastSpellByName("Shadowburn")
        end

        CastOrWand("Shadow Bolt")
    end

    local function SaveShardShadowburn(shardsToSave)
        local minShards = shardsToSave or 0

        if not IsSpellReady("Shadowburn") or NumShards() <= minShards then
            return
        end

        CastSpellByName("Shadowburn")
    end

    local function Cooldowns()
        if ImBusy() or not InCombat() then
            return
        end

        SelfBuff("Berserking")
        HealerTrinkets()
        CasterTrinkets()
    end

    local function HealthStone()
        if ImBusy() or not InCombat() then
            return
        end

        if HealthPct() > 0.15 then
            return
        end

        if not HaveInBags("Major Healthstone") then
            return
        end

        if IsItemInBagCoolDown("Major Healthstone") then
            return
        end

        SpellStopCasting()
        UseItemByName("Major Healthstone")
    end

    local function SumPetAndSac()
        if HasBuffOrDebuff("Touch of Shadow", "player", "buff") then
            return
        end

        if UnitCreatureFamily("pet") == "Succubus" and IsSpellKnown("Demonic Sacrifice") then
            CastSpellByName("Demonic Sacrifice")
            return
        end

        if NumShards() == 0 then
            return
        end

        if IsSpellKnown("Summon Succubus") and IsSpellKnown("Fel Domination") and IsSpellReady("Fel Domination") then
            CastSpellByName("Fel Domination")
            return
        end

        if IsSpellKnown("Summon Succubus") then
            CastSpellByName("Summon Succubus")
        end
    end

    local function TapWhileMoving()
        if HealthPct() < 0.40 or UnitMana("player") == UnitManaMax("player") then
            return
        end

        if ManaPct() < 0.80 and HealthPct() > 0.55 then
            CastSpellByName("Life Tap")
        end
    end

    local function CreateHealthStone()
        if NumShards() < 2
            or GetAllContainerFreeSlots() < 1
            or InCombat()
            or HaveInBags("Major Healthstone") then
            return
        end

        CastSpellByName("Create Healthstone (Major)")
    end

    local function CreateSoulStone()
        local spellId = GetSpellNumber("Create Soulstone.*Major")

        if not spellId
            or NumShards() < 1
            or HaveInBags("Major Soulstone") then
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

    local function WarlockCurses()
        if Instance.NAXX() and THAD_IsAtThaddiusP1() and MB_myThaddiusBoxStrategy then
            return THAD_WarlockDebuffP1()
        end

        if Instance.AQ40() and SKERAM_InFight() and SKERAM_BoxStrategyEnabled() then
            return SKERAM_WarlockDebuff()
        end

        if Instance.BWL() and IsAtRazorgore() and IsAtRazorgorePhase() and MB_myRazorgoreBoxStrategy then
            local myOrder = MyClassAlphabeticalOrder()
            local tankMap = { MB_myRazorgoreRightTank, MB_myRazorgoreLeftTank }
            local tankName = tankMap[myOrder] and ReturnPlayerInRaidFromTable(tankMap[myOrder])

            if tankName and TargetFromSpecificPlayer("Death Talon Dragonspawn", tankName) then
                local tankId = GeneralState.MBID[tankName]
                local tankTargetID = tankId .. "target"

                if not HasBuffOrDebuff("Curse of Recklessness", tankTargetID, "debuff") then
                    AssistUnit(tankId)
                    CastSpellByName("Curse of Recklessness")
                    TargetLastTarget()
                    return true
                end
            end
            return false
        end

        local casters = NumberOfClassInRaid("Mage") + NumberOfClassInRaid("Warlock")
        local melees = NumberOfClassInRaid("Warrior") + NumberOfClassInRaid("Rogue") + NumberOfClassInRaid("Hunter")

        local curseList = (casters > melees) and CURSE_PRIO_CASTER or CURSE_PRIO_MELEE
        local myOrder = MyClassAlphabeticalOrder()
        local assignedCurse = curseList[myOrder]

        if assignedCurse and not HasBuffOrDebuff(assignedCurse, "target", "debuff") then
            CastSpellByName(assignedCurse)
            return true
        end

        return false
    end

    local function SoulStone()
        if HasBuffNamed("Drink", "player") or ImBusy() then
            return
        end

        CreateSoulStone()

        if IsItemInBagCoolDown("Major Soulstone") then
            return
        end

        if not ConfigState.AutoSoulStone.Active then
            ConfigState.AutoSoulStone.Active = true
            ConfigState.AutoSoulStone.Time = GetTime() + 6
            WarlockCounter.Cycle()
        end

        if SomeoneInRaidBuffedWith("Soulstone") or MyClassAlphabeticalOrder() ~= ConfigState.SheepingWarlockNr then
            return
        end

        local targetClasses = { "Priest", "Shaman" }
        for _, class in ipairs(targetClasses) do
            local classList = GeneralState.ClassList[class]

            if classList then
                for i = 1, TableLength(classList) do
                    local name = classList[i]
                    local id = GeneralState.MBID[name]

                    if id and not HasBuffOrDebuff("Soulstone", id, "buff") then
                        CdMessage("Soulstoning " .. GetColors(name))
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

        if not HasBuffNamed("Shadow and Frost Reflect", "target") and WarlockCurses() then
            return true
        end

        if not HasBuffOrDebuff("Shadow Ward", "player", "buff") and IsSpellReady("Shadow Ward") then
            if MobsToShadowWard() or DebuffsToShadowWard() then
                SelfBuff("Shadow Ward")
                return true
            end
        end

        if HasBuffNamed("Shadow and Frost Reflect", "target") then
            if IsSpellReady("Soul Fire") and NumShards() > 10 then
                CastOrWand("Soul Fire")
            end

            CastOrWand("Immolate")
            return true
        elseif HasBuffOrDebuff("Magic Reflection", "target", "buff") then
            if ImBusy() then
                SpellStopCasting()
            end

            AutoWandAttack()
            return true
        end

        if TankTarget("Azuregos") and HasBuffNamed("Magic Shield", "target") then
            if ImBusy() then
                SpellStopCasting()
            end

            SelfBuff("Frost Ward")
            return true
        end

        if Instance.AQ40() then
            if tName == "Emperor Vek'lor" and FindMyNameInTable(MB_myTwinsWarlockTank) then
                SelfBuff("Shadow Ward")
                SaveShardShadowburn(3)

                if HealthPct() < 0.25 and IsSpellReady("Death Coil") then
                    CastSpellByName("Death Coil")
                end

                CastSpellByName("Searing Pain")
                return true
            elseif tName == "Obsidian Eradicator" and ManaPct("target") > 0.7 and not ImBusy() then
                CastSpellByName("Drain Mana")
                return true
            end

            if FANKRISS_WarlockDPS() then
                return true
            end
        end

        if Instance.BWL() and CorruptedTotems() and not Dead("target") then
            SaveShardShadowburn(12)
            CastOrWand("Searing Pain")
            return true
        end

        if Instance.MC() and TankTarget("Shazzrah") then
            if not IsSpellReady("Shadow Bolt") then
                CastOrWand("Immolate")
                return true
            end
        end

        if Instance.ONY() and TankTarget("Onyxia") and ConfigState.IsMoving.Active then
            CoolDownCast("Corruption", 18)

            if TankTargetHealth() <= 0.65 and TankTargetHealth() >= 0.4 then
                SaveShardShadowburn(12)
            end
        end

        if Instance.ZG() then
            if HasBuffOrDebuff("Delusions of Jin'do", "player", "debuff") and tName == "Shade of Jin'do" and not Dead("target") then
                SaveShardShadowburn(12)
                CastOrWand("Searing Pain")
                return true
            end

            if (tName == "Powerful Healing Ward" or tName == "Brain Wash Totem") and not Dead("target") then
                SaveShardShadowburn(12)
                CastOrWand("Searing Pain")
                return true
            end
        end

        if Instance.AQ20() then
            if TankTarget("Moam") and ManaPct("target") > 0.75 and not ImBusy() then
                CastSpellByName("Drain Mana")
            end

            if TankTarget("Ossirian the Unscarred") then
                if HasBuffOrDebuff("Fire Weakness", "target", "debuff") then
                    if IsSpellReady("Soul Fire") and NumShards() > 10 then
                        CastOrWand("Soul Fire")
                    end

                    CastOrWand("Immolate")
                    return true
                elseif HasBuffOrDebuff("Shadow Weakness", "target", "debuff") then
                    CastOrWand("Shadow Bolt")
                    return true
                end
            end
        end

        return false
    end

    MoronBox:RegisterExpose({
        Specc = function()
            local _, _, _, _, shadowBurn = GetTalentInfo(2, 13)
            local _, _, _, _, ruin = GetTalentInfo(3, 8)
            local _, _, _, _, corruption = GetTalentInfo(1, 11)

            if shadowBurn > 0 and ruin > 0 then
                ConfigState.PlayerSpecc = "Shadowburn"
            elseif corruption > 0 then
                ConfigState.PlayerSpecc = "Corruption"
            else
                ConfigState.PlayerSpecc = nil
            end
        end,
        Setup = function()
            if UnitMana("player") < 3060 and HasBuffNamed("Drink", "player") then
                return
            end

            if IsAltKeyDown() then
                if not ConfigState.AutoSoulStone.Active then
                    ConfigState.AutoSoulStone.Active = true
                    ConfigState.AutoSoulStone.Time = GetTime() + 3
                    WarlockCounter.Cycle()
                end

                if MyClassAlphabeticalOrder() == ConfigState.SheepingWarlockNr then
                    SoulStone()
                end
            end

            SelfBuff("Demon Armor")

            if IsSpellKnown("Demonic Sacrifice") then
                if not HasBuffOrDebuff("Touch of Shadow", "player", "buff") then
                    SumPetAndSac()
                end
            else
                if not HavePet() then
                    CastSpellByName("Summon Imp")
                end
            end

            CreateHealthStone()

            if not InCombat() and ManaPct() < 0.20 and not HasBuffNamed("Drink", "player") then
                SmartDrink()
            end
        end,
        Single = function()
            GetTarget()
            WarlockCancelAuras()

            if not ConfigState.PlayerSpecc then
                CdMessage("My specc is fucked. Defaulting to Corruption.")
                ConfigState.PlayerSpecc = "Corruption"
            end

            if CastCrowdControl() then
                return
            end

            if ManaPct() < 0.40 and HealthPct() > 0.75 then
                CastSpellByName("Life Tap")
                return
            end

            if HasBuffOrDebuff("Hellfire", "player", "buff") then
                CastSpellByName("Life Tap(Rank 1)")
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

            if Instance.AQ40() then
                if HasBuffOrDebuff("True Fulfillment", "target", "debuff") then
                    ClearTarget()
                    return
                end
            end

            if not InCombat("target") then
                return
            end

            if InCombat() then
                HealthStone()
                TakeManaPotionAndRunes()

                if IsSpellKnown("Demonic Sacrifice") and not HasBuffOrDebuff("Touch of Shadow", "player", "buff") then
                    SumPetAndSac()
                end

                if ConfigState.IsMoving.Active then
                    TapWhileMoving()
                end

                if ManaDown() > 600 then
                    Cooldowns()
                end
            end

            if BossSpecificDPS() then
                return
            end

            if not Instance.IsWorldBoss() and HealthPct("target") < 0.2 and NumShards() < 60
                and GetAllContainerFreeSlots() >= 10 and not ImBusy() then
                CastSpellByName("Drain Soul(Rank 1)")
                return
            end

            if ConfigState.PlayerSpecc == "Shadowburn" and SettingsState.Warlock.ShouldBeWhores then
                ShadowBoltWhoring()
            else
                CastOrWand("Shadow Bolt")

                if not IsSpellReady("Shadow Bolt") then
                    CastOrWand("Searing Pain")
                end
            end
        end,
        Multi = function()
            GetTarget()
            WarlockCancelAuras()

            if not ConfigState.PlayerSpecc then
                CdMessage("My specc is fucked. Defaulting to Corruption.")
                ConfigState.PlayerSpecc = "Corruption"
            end

            if CastCrowdControl() then
                return
            end

            if ManaPct() < 0.40 and HealthPct() > 0.75 then
                CastSpellByName("Life Tap")
                return
            end

            if HasBuffOrDebuff("Hellfire", "player", "buff") then
                CastSpellByName("Life Tap(Rank 1)")
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

            if Instance.AQ40() then
                if HasBuffOrDebuff("True Fulfillment", "target", "debuff") then
                    ClearTarget()
                    return
                end
            end

            if not InCombat("target") then
                return
            end

            if InCombat() then
                HealthStone()
                TakeManaPotionAndRunes()

                if IsSpellKnown("Demonic Sacrifice") and not HasBuffOrDebuff("Touch of Shadow", "player", "buff") then
                    SumPetAndSac()
                end

                if ConfigState.IsMoving.Active then
                    TapWhileMoving()
                end

                if ManaDown() > 600 then
                    Cooldowns()
                end
            end

            if BossSpecificDPS() then
                return
            end

            if not Instance.IsWorldBoss() and HealthPct("target") < 0.2 and NumShards() < 60
                and GetAllContainerFreeSlots() >= 10 and not ImBusy() then
                CastSpellByName("Drain Soul(Rank 1)")
                return
            end

            if ConfigState.PlayerSpecc == "Shadowburn" and SettingsState.Warlock.ShouldBeWhores then
                ShadowBoltWhoring()
            else
                CastOrWand("Shadow Bolt")

                if not IsSpellReady("Shadow Bolt") then
                    CastOrWand("Searing Pain")
                end
            end
        end,
        AOE = function()
            GetTarget()
            WarlockCancelAuras()

            if not ConfigState.PlayerSpecc then
                CdMessage("My specc is fucked. Defaulting to Corruption.")
                ConfigState.PlayerSpecc = "Corruption"
            end

            if UnitMana("player") < 1250 and not ImBusy() then
                CastSpellByName("Life Tap")
                return
            end

            if InCombat() then
                HealthStone()
                TakeManaPotionAndRunes()

                if ManaDown() > 600 then
                    Cooldowns()
                end
            end

            if not HasBuffOrDebuff("Hellfire", "player", "buff") then
                CastSpellByName("Hellfire")
            end
        end,
        PreCast = function()
            PreCastTrinkets()
            CastSpellByName("Shadow Bolt")
        end
    })
end, function()
    return myClass == "Warlock"
end)
