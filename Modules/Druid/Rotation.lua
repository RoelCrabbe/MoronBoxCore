-- [[ Druid Rotation ]] --
---@diagnostic disable: undefined-global

local NAME = "Druid Rotation"
local MODULE_NAME = "MODULE_" .. string.upper(string.gsub(NAME, " ", "_"))

local myClass = UnitClass("player")

MoronBox:RegisterModule(MODULE_NAME, function()
    local RemoveBuffs = {
        ["Battle Shout"]     = "Battle Shout",
        ["Fengus' Ferocity"] = "Fengus' Ferocity",
        ["Polished Armor"]   = "Polished Armor",
        ["R.O.I.D.S."]       = "Rage of Ages"
    }

    local function ImprovedRegrowth()
        local _, _, _, _, TalentsIn = GetTalentInfo(3, 14)
        return TalentsIn > 2
    end

    local function GetActiveVaelastraszHealer()
        for _, name in ipairs(MB_myVaelastraszDruids) do
            local id = MBID[name]
            if id and not Dead(id) then
                return name
            end
        end
        return nil
    end

    local function Taunt()
        if Instance.MC() and TankTarget("Magmadar") then
            return
        end

        if IsSpellReady("Growl") then
            CastSpellByName("Growl")
            return
        end

        if UnitName("target") and InCombat("target") then
            if IsSpellReady("Faerie Fire (Feral)()") then
                CastSpellByName("Faerie Fire (Feral)()")
            end
        end
    end

    local function Cooldowns()
        if ImBusy() or not InCombat() then
            return
        end

        if ConfigState.PlayerSpecc == "Feral" then
            MeleeTrinkets()
            return
        end

        HealerTrinkets()
        CasterTrinkets()
    end

    local function Innervate()
        if ImBusy() or (Instance.MC() and (TankTarget("Garr") or TankTarget("Firesworn"))) or not IsSpellReady("Innervate") then
            return
        end

        for _, innerTarget in ipairs(HealingState.Druid.InnervateHealerList) do
            local unitID = MBID[innerTarget]

            if IsValidFriendlyTarget(unitID, "Innervate") and HealthPct(unitID) <= 0.5 and not HasBuffNamed("Innervate", unitID) and IsSpellReady("Innervate") then
                if UnitIsFriend("player", unitID) then
                    ClearTarget()
                end

                CastSpellByName("Innervate", nil)
                SpellTargetUnit(unitID)
                SpellStopTargeting()
            end
        end
    end

    local function HealerDebuffs()
        if Instance.NAXX() and THAD_IsAtThaddiusP1() and MB_myThaddiusBoxStrategy then
            return THAD_DruidDebuffP1()
        elseif Instance.BWL() then
            if UnitName("target") == "Death Talon Wyrmkin" or UnitName("target") == "Death Talon Flamescale" then
                return
            end

            if GetSubZoneText() ~= "Dragonmaw Garrison" or not IsAtRazorgorePhase() or not MB_myRazorgoreBoxStrategy then
                return
            end

            local tanks = {
                Right = ReturnPlayerInRaidFromTable(MB_myRazorgoreRightTank),
                Left = ReturnPlayerInRaidFromTable(MB_myRazorgoreLeftTank)
            }

            for _, tank in pairs(tanks) do
                local targetUnit = MBID[tank] .. "target"
                if TargetFromSpecificPlayer("Death Talon Dragonspawn", tank) and UnitCanAttack("player", targetUnit) and
                    not (HasBuffOrDebuff("Faerie Fire", targetUnit, "debuff") or HasBuffOrDebuff("Faerie Fire (Feral)", targetUnit, "debuff")) then
                    AssistUnit(MBID[tank])
                    CastSpellByName("Faerie Fire")
                    TargetLastTarget()
                end
            end
        else
            local focusTarget = ConfigState.RaidLeader and MBID[ConfigState.RaidLeader] or
                (MB_raidInviter and MBID[MB_raidInviter] or nil)

            if not focusTarget then
                return
            end

            local targetUnit = focusTarget .. "target"
            if UnitCanAttack("player", targetUnit) and
                not (HasBuffOrDebuff("Faerie Fire", targetUnit, "debuff") or HasBuffOrDebuff("Faerie Fire (Feral)", targetUnit, "debuff")) then
                AssistUnit(focusTarget)
                CastSpellByName("Faerie Fire")
                TargetLastTarget()
            end
        end
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

        if Instance.AQ40() then
            SARTURA_DruidDPS()
        elseif Instance.ZG() then
            if HasBuffOrDebuff("Delusions of Jin'do", "player", "debuff") then
                if target == "Shade of Jin'do" and not Dead("target") then
                    CastOrWand("Wrath")
                    return true
                end
            end

            if (target == "Powerful Healing Ward" or target == "Brain Wash Totem") and not Dead("target") then
                CastOrWand("Wrath")
                return true
            end
        elseif Instance.AQ20() and TankTarget("Ossirian the Unscarred") then
            if HasBuffOrDebuff("Nature Weakness", "target", "debuff") then
                CastOrWand("Wrath")
                return true
            end
        end

        return false
    end

    local function Balance()
        if not IsBoomForm() then
            SelfBuff("Moonkin Form")
            CancelDruidShapeShift()
        end

        Decurse()

        if not InCombat("target") then
            return
        end

        if InCombat() then
            HealerDebuffs()
            Innervate()

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

        CastOrWand("Starfire")
    end

    local HealTouch = { Time = 0, Interrupt = false }

    local function MTHeals(assignedTarget)
        if assignedTarget then
            TargetByName(assignedTarget, 1)
        else
            if TankTarget("Patchwerk") and MB_myPatchwerkBoxStrategy then
                TargetMyAssignedTankToHeal()
            else
                local tankTarget = UnitName(MBID[TankName()] .. "targettarget")
                if not tankTarget then
                    MBH_CastHeal("Healing Touch")
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
            CastSpellByName("Healing Touch")
            return
        end

        local healTouchSpell = TankTarget("Vaelastrasz the Corrupt") and "Healing Touch" or
            ("Healing Touch(" .. HealingState.Druid.MainTankHealingRank .. ")")

        if not BossNeverInterruptHeal() and HealthDown("target") <= (GetHealValueFromRank("Healing Touch", HealingState.Druid.MainTankHealingRank) * HealingState.MainTankOverhealingPercentage) then
            if GetTime() > HealTouch.Time and GetTime() < HealTouch.Time + 0.5 and HealTouch.Interrupt then
                SpellStopCasting()
                HealTouch.Interrupt = false
                SpellStopCasting()
            end
        end

        if not ImBusy() then
            CastSpellByName(healTouchSpell)
            HealTouch.Time = GetTime() + 1
            HealTouch.Interrupt = true
        end
    end

    local function MaxRejuvAggroedPlayer()
        if not MBID[ConfigState.RaidLeader] or ImBusy() or (Instance.MC() and (TankTarget("Garr") or TankTarget("Firesworn"))) then
            return
        end

        local rejuvTarget = MBID[ConfigState.RaidLeader] .. "targettarget"
        if not IsValidFriendlyTarget(rejuvTarget, "Rejuvenation") or HealthPct(rejuvTarget) > 0.95 or HasBuffNamed("Rejuvenation", rejuvTarget) then
            return
        end

        if UnitIsFriend("player", rejuvTarget) then
            ClearTarget()
        end

        CastSpellByName("Rejuvenation", nil)
        SpellTargetUnit(rejuvTarget)
        SpellStopTargeting()
    end

    local function MaxRegrowthAggroedPlayer()
        if not MBID[ConfigState.RaidLeader] or ImBusy() or (Instance.MC() and (TankTarget("Garr") or TankTarget("Firesworn"))) then
            return
        end

        local regroTarget = MBID[ConfigState.RaidLeader] .. "targettarget"
        if not IsValidFriendlyTarget(regroTarget, "Regrowth") or HealthPct(regroTarget) > 0.95 or HasBuffNamed("Regrowth", regroTarget) then
            return
        end

        if UnitIsFriend("player", regroTarget) then
            ClearTarget()
        end

        CastSpellByName("Regrowth", nil)
        SpellTargetUnit(regroTarget)
        SpellStopTargeting()
    end

    local function RejuvAggroedPlayer()
        if ImBusy() or (Instance.MC() and (TankTarget("Garr") or TankTarget("Firesworn"))) then
            return
        end

        local aggrox = AceLibrary("Banzai-1.0")

        for i = 1, GetNumRaidMembers() do
            local rejuvTarget = "raid" .. i

            if aggrox:GetUnitAggroByUnitId(rejuvTarget) and
                IsValidFriendlyTarget(rejuvTarget, "Rejuvenation") and
                HealthPct(rejuvTarget) <= HealingState.Druid.RejuvenationAggroedPlayerPercentage and
                not HasBuffNamed("Rejuvenation", rejuvTarget) then
                if UnitIsFriend("player", rejuvTarget) then
                    ClearTarget()
                end

                CastSpellByName("Rejuvenation(" .. HealingState.Druid.RejuvenationAggroedPlayerRank .. ")")
                SpellTargetUnit(rejuvTarget)
                SpellStopTargeting()
                return
            end
        end
    end

    local function RegrowthAggroedPlayer()
        if ImBusy() or (Instance.MC() and (TankTarget("Garr") or TankTarget("Firesworn"))) or not ImprovedRegrowth() or UnitMana("player") < 880 or MyClassOrder() ~= 1 then
            return
        end

        local aggrox = AceLibrary("Banzai-1.0")

        for i = 1, GetNumRaidMembers() do
            local regroTarget = "raid" .. i

            if aggrox:GetUnitAggroByUnitId(regroTarget) and
                IsValidFriendlyTarget(regroTarget, "Regrowth") and
                HealthPct(regroTarget) <= HealingState.Druid.SwiftmendRegrowthAggroedPlayerPercentage and
                not HasBuffNamed("Regrowth", regroTarget) then
                if UnitIsFriend("player", regroTarget) then
                    ClearTarget()
                end

                CastSpellByName("Regrowth(" .. HealingState.Druid.SwiftmendRegrowthAggroedPlayerRank .. ")")
                SpellTargetUnit(regroTarget)
                SpellStopTargeting()
                return
            end
        end
    end

    local function RegrowthLowRandom()
        if ImBusy() or (Instance.MC() and (TankTarget("Garr") or TankTarget("Firesworn"))) or not ImprovedRegrowth() or UnitMana("player") < 880 then
            return
        end

        local isRaid = GetRaidRosterInfo(1)
        local numMembers = isRaid and GetNumRaidMembers() or GetNumPartyMembers()
        local prefix = isRaid and "raid" or "party"

        for i = 1, numMembers do
            local unitID = prefix .. i
            if HealthPct(unitID) < HealingState.Druid.SwiftmendRegrowthLowRandomPercentage and IsValidFriendlyTarget(unitID, "Regrowth") then
                if UnitIsFriend("player", unitID) then
                    ClearTarget()
                end

                CastSpellByName("Regrowth")
                SpellTargetUnit(unitID)
                SpellStopTargeting()
                return
            end
        end
    end

    local function AbolishAggroedPlayer()
        if not MBID[ConfigState.RaidLeader] or ImBusy() or (Instance.MC() and (TankTarget("Garr") or TankTarget("Firesworn"))) then
            return
        end

        local targetUnit = MBID[ConfigState.RaidLeader] .. "targettarget"
        if not IsValidFriendlyTarget(targetUnit, "Abolish Poison") or HealthPct(targetUnit) > 0.95 or HasBuffNamed("Abolish Poison", targetUnit) then
            return
        end

        if UnitIsFriend("player", targetUnit) then
            ClearTarget()
        end

        CastSpellByName("Abolish Poison", nil)
        SpellTargetUnit(targetUnit)
        SpellStopTargeting()
    end

    local function SwiftmendOnRandomRaidMember(spell, percentage)
        if not UnitInRaid("player") or ImBusy() or (Instance.MC() and (TankTarget("Garr") or TankTarget("Firesworn"))) then
            return
        end

        local n = GetNumPartyOrRaidMembers()
        local offset = math.random(n) - 1

        for i = 1, n do
            local j = i + offset
            if j > n then
                j = j - n
            end

            local raidUnit = "raid" .. j
            if HealthPct(raidUnit) < percentage and
                InCombat(raidUnit) and
                IsValidFriendlyTarget(raidUnit, spell) and
                (HasBuffNamed("Rejuvenation", raidUnit) or HasBuffNamed("Regrowth", raidUnit)) then
                if UnitIsFriend("player", raidUnit) then
                    ClearTarget()
                end

                CastSpellByName(spell, nil)
                SpellTargetUnit(raidUnit)
                SpellStopTargeting()
                break
            end
        end
    end

    local function Heal()
        if NatureSwiftnessLowAggroedPlayer() then
            return
        end

        Decurse()

        if InCombat() then
            HealerDebuffs()
            Innervate()
            TakeManaPotionAndRunes()

            if ManaDown() > 600 then
                Cooldowns()
            end
        end

        if HasBuffOrDebuff("Curse of Tongues", "player", "debuff") and not TankTarget("Anubisath Defender") then
            return
        end

        if Instance.MC() and TankTarget("Shazzrah") then
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

        for _, bossName in pairs(MB_myDruidMainTankHealingBossList) do
            if TankTarget(bossName) then
                MTHeals()
                return
            end
        end

        if ConfigState.IsMoving.Active then
            if Instance.ONY() and TankTarget("Onyxia") then
                CoolDownCast("Moonfire", 12)
            end

            CastSpellOnRandomRaidMember("Rejuvenation", HealingState.Druid.RejuvenationLowRandomMovingRank,
                HealingState.Druid.RejuvenationLowRandomMovingPercentage)
        end

        if Instance.AQ40() and TankTarget("Princess Huhuran") then
            if MyGroupClassOrder() == 1 and TankTargetHealth() <= 0.32 then
                MTHeals()
                return
            end

            MBH_CastHeal("Healing Touch")
            return
        elseif Instance.BWL() and TankTarget("Vaelastrasz the Corrupt") and MB_myVaelastraszBoxStrategy then
            Cooldowns()

            if MB_myVaelastraszDruidHealing and not HasBuffOrDebuff("Burning Adrenaline", "player", "debuff") then
                local activeDruid = GetActiveVaelastraszHealer()

                if myName == activeDruid then
                    MaxRejuvAggroedPlayer()
                    MaxRegrowthAggroedPlayer()
                end
            end

            if IsSpellReady("Swiftmend") and (swiftmendRaidThrottleTimer == nil or GetTime() - swiftmendRaidThrottleTimer > 1.5) then
                swiftmendRaidThrottleTimer = GetTime()
                SwiftmendOnRandomRaidMember("Swiftmend", 0.5)
            end

            SelfBuff("Rejuvenation")
            MBH_CastHeal("Regrowth", 9, 9)
            return
        end

        if not ImBusy() then
            if ConfigState.HealSpell == "Rejuvenation" and ManaDown() > 300 then
                SelfBuff("Rejuvenation(Rank 1)")
            end

            RejuvAggroedPlayer()

            if IsSpellKnown("Swiftmend") then
                if IsSpellReady("Swiftmend") then
                    SwiftmendOnRandomRaidMember("Swiftmend", HealingState.Druid.SwiftmendAtPercentage)
                end

                if (rejuvenationRaidThrottleTimer == nil or GetTime() - rejuvenationRaidThrottleTimer > 1.5) then
                    rejuvenationRaidThrottleTimer = GetTime()
                    CastSpellOnRandomRaidMember("Rejuvenation", HealingState.Druid.SwiftmendRejuvenationLowRandomRank,
                        HealingState.Druid.SwiftmendRejuvenationLowRandomPercentage)
                end
            elseif (rejuvenationRaidThrottleTimer == nil or GetTime() - rejuvenationRaidThrottleTimer > 1.5) then
                rejuvenationRaidThrottleTimer = GetTime()
                CastSpellOnRandomRaidMember("Rejuvenation", HealingState.Druid.RejuvenationLowRandomRank,
                    HealingState.Druid.RejuvenationLowRandomPercentage)
            end

            RegrowthAggroedPlayer()

            if (regrowthRaidThrottleTimer == nil or GetTime() - regrowthRaidThrottleTimer > 1.5) then
                regrowthRaidThrottleTimer = GetTime()
                RegrowthLowRandom()
            end
        end

        MBH_CastHeal("Healing Touch")
    end

    local function TankSingle()
        if FindInTable(GeneralState.RaidTanks, myName) and HasBuffOrDebuff("Greater Blessing of Salvation", "player", "buff") then
            CancelBuff("Greater Blessing of Salvation")
        end

        if not IsBearForm() then
            SelfBuff("Dire Bear Form")
            CancelDruidShapeShift()
            return
        end

        if not InCombat("target") then
            return
        end

        if InCombat() then
            if HealthPct() < 0.3 and IsSpellReady("Frenzied Regeneration") then
                CastSpellByName("Frenzied Regeneration")
            end

            if InMeleeRange() then
                if DebuffSunderAmount() == 5 or HasBuffOrDebuff("Expose Armor", "target", "debuff") then
                    Cooldowns()
                end

                if IsSpellReady("Bash") and StunnableMob() then
                    CastSpellByName("Bash")
                end

                if not HasBuffOrDebuff("Demoralizing Shout", "target", "debuff") then
                    local targetName = UnitName("target")
                    if targetName ~= "Emperor Vek'nilash" and targetName ~= "Emperor Vek'lor" then
                        if not HasBuffOrDebuff("Demoralizing Roar", "target", "debuff") and UnitMana("player") >= 20 then
                            CastSpellByName("Demoralizing Roar")
                        end
                    end
                end
            end
        end

        OffTank()

        local tOfTarget = UnitName("targettarget") or ""
        local tName = UnitName("target") or ""

        local shouldTaunt = tName ~= ""
            and tOfTarget ~= "" and tOfTarget ~= "Unknown"
            and UnitIsEnemy("player", "target")
            and not FindInTable(GeneralState.RaidTanks, tOfTarget)

        if shouldTaunt then
            if ConfigState.OffTankTarget then
                if tOfTarget ~= myName then
                    Taunt()
                end
            else
                Taunt()
            end
        end

        if ConfigState.OffTankTarget then
            if UnitExists("target") and GetRaidTargetIndex("target") and GetRaidTargetIndex("target") == ConfigState.OffTankTarget and UnitIsDead("target") then
                ConfigState.OffTankTarget = nil
                ClearTarget()
            end
        end

        AutoAttack()

        if not HasBuffOrDebuff("Faerie Fire (Feral)", "target", "debuff") and not HasBuffOrDebuff("Faerie Fire", "target", "debuff") then
            CastSpellByName("Faerie Fire (Feral)()")
        end

        if IsSpellReady("Enrage") and UnitMana("player") <= 15 then
            CastSpellByName("Enrage")
        end

        if UnitMana("player") >= 7 then
            CastSpellByName("Maul")
        end

        if UnitMana("player") >= 36 then
            CastSpellByName("Swipe")
        end
    end

    local function TankMulti()
        if FindInTable(GeneralState.RaidTanks, myName) and HasBuffOrDebuff("Greater Blessing of Salvation", "player", "buff") then
            CancelBuff("Greater Blessing of Salvation")
        end

        if not IsBearForm() then
            SelfBuff("Dire Bear Form")
            CancelDruidShapeShift()
            return
        end

        if not InCombat("target") then
            return
        end

        if InCombat() then
            if HealthPct() < 0.3 and IsSpellReady("Frenzied Regeneration") then
                CastSpellByName("Frenzied Regeneration")
            end

            if InMeleeRange() then
                if DebuffSunderAmount() == 5 or HasBuffOrDebuff("Expose Armor", "target", "debuff") then
                    Cooldowns()
                end

                if IsSpellReady("Bash") and StunnableMob() then
                    CastSpellByName("Bash")
                end

                if not HasBuffOrDebuff("Demoralizing Shout", "target", "debuff") then
                    local targetName = UnitName("target")
                    if targetName ~= "Emperor Vek'nilash" and targetName ~= "Emperor Vek'lor" then
                        if not HasBuffOrDebuff("Demoralizing Roar", "target", "debuff") and UnitMana("player") >= 20 then
                            CastSpellByName("Demoralizing Roar")
                        end
                    end
                end
            end
        end

        OffTank()

        local tOfTarget = UnitName("targettarget") or ""
        local tName = UnitName("target") or ""

        local shouldTaunt = tName ~= ""
            and tOfTarget ~= "" and tOfTarget ~= "Unknown"
            and UnitIsEnemy("player", "target")
            and not FindInTable(GeneralState.RaidTanks, tOfTarget)

        if shouldTaunt then
            if ConfigState.OffTankTarget then
                if tOfTarget ~= myName then
                    Taunt()
                end
            else
                Taunt()
            end
        end

        if ConfigState.OffTankTarget then
            if UnitExists("target") and GetRaidTargetIndex("target") and GetRaidTargetIndex("target") == ConfigState.OffTankTarget and UnitIsDead("target") then
                ConfigState.OffTankTarget = nil
                ClearTarget()
            end
        end

        AutoAttack()

        if not HasBuffOrDebuff("Faerie Fire (Feral)", "target", "debuff")
            and not HasBuffOrDebuff("Faerie Fire", "target", "debuff") then
            CastSpellByName("Faerie Fire (Feral)()")
        end

        if IsSpellReady("Enrage") and UnitMana("player") <= 15 then
            CastSpellByName("Enrage")
        end

        if UnitMana("player") > 12 then
            CastSpellByName("Swipe")
        end

        if UnitMana("player") > 19 then
            CastSpellByName("Maul")
        end
    end

    local function Multi()
        GetTarget()
        CancelAuraSet(RemoveBuffs)

        if not ConfigState.PlayerSpecc then
            CdMessage("My specc is fucked. Defaulting to Resto.")
            ConfigState.PlayerSpecc = "Resto"
        end

        if ConfigState.PlayerSpecc == "Feral" then
            if Instance.AQ40() then
                AnubisathAlert()
            end

            TankMulti()
            return
        end

        if UnitName("target") == "Death Talon Wyrmkin" and GetRaidTargetIndex("target") == ConfigState.CrowdControlTarget then
            CastSpellByName("Hibernate(Rank 1)")
            return
        end

        if CastCrowdControl() then
            return
        end

        if UnitName("target") then
            if ConfigState.CrowdControlTarget and GetRaidTargetIndex("target") == ConfigState.CrowdControlTarget and not HasBuffOrDebuff(ConfigState.CrowdControlSpell[myClass], "target", "debuff") then
                if CastCrowdControl() then
                    return
                end
            end

            if CrowdControlledMob() then
                GetTarget()
            end
        end

        if ConfigState.PlayerSpecc == "Balance" then
            Balance()
            return
        end

        if Instance.NAXX() and not Faction.IsHorde() then
            if TankTarget("Venom Stalker") or TankTarget("Necro Stalker") then
                if ImBusy() then
                    SpellStopCasting()
                end

                MeleeBuff("Abolish Poison")
                return
            end
        end

        HealerJindo("Wrath")
        Heal()
    end

    local function LOA_Attack()
        if ImBusy() or not InCombat() then
            return
        end

        GetTarget()

        if ManaPct() < 0.13 then
            return
        end

        if IsSpellReady("Starfire") then
            CoolDownCast("Starfire", 6)
            return
        end

        AutoAttack()
    end

    MoronBox:RegisterExpose({
        Specc = function()
            local _, _, _, _, balance = GetTalentInfo(1, 16)
            local _, _, _, _, feral = GetTalentInfo(2, 16)
            local _, _, _, _, swiftmend = GetTalentInfo(3, 15)
            local _, _, _, _, improvedRejuv = GetTalentInfo(3, 3)

            if balance > 0 then
                ConfigState.PlayerSpecc = "Balance"
            elseif feral > 0 then
                ConfigState.PlayerSpecc = "Feral"
            elseif swiftmend > 0 then
                ConfigState.PlayerSpecc = "Swiftmend"
            elseif improvedRejuv > 4 then
                ConfigState.PlayerSpecc = "Resto"
            else
                ConfigState.PlayerSpecc = nil
            end
        end,
        Setup = function()
            if IsDruidShapeShifted() and not InCombat() then
                CancelDruidShapeShift()
            end

            if UnitMana("player") < 3060 and HasBuffNamed("Drink", "player") then
                return
            end

            ProcessMarkOfTheWild()

            if not SettingsState.SpeedRunEnabled then
                TankBuff("Thorns")
            end

            SelfBuff("Omen of Clarity")

            if not InCombat() and ManaPct() < 0.20 and not HasBuffNamed("Drink", "player") then
                SmartDrink()
            end
        end,
        Single = function()
            GetTarget()
            CancelAuraSet(RemoveBuffs)

            if not ConfigState.PlayerSpecc then
                CdMessage("My specc is fucked. Defaulting to Resto.")
                ConfigState.PlayerSpecc = "Resto"
            end

            if ConfigState.PlayerSpecc == "Feral" then
                if Instance.AQ40() then
                    AnubisathAlert()
                end

                TankSingle()
                return
            end

            if UnitName("target") == "Death Talon Wyrmkin" and GetRaidTargetIndex("target") == ConfigState.CrowdControlTarget then
                CastSpellByName("Hibernate(Rank 1)")
                return
            end

            if CastCrowdControl() then
                return
            end

            if UnitName("target") then
                if ConfigState.CrowdControlTarget and GetRaidTargetIndex("target") == ConfigState.CrowdControlTarget and not HasBuffOrDebuff(ConfigState.CrowdControlSpell[myClass], "target", "debuff") then
                    if CastCrowdControl() then
                        return
                    end
                end

                if CrowdControlledMob() then
                    GetTarget()
                end
            end

            if ConfigState.PlayerSpecc == "Balance" then
                Balance()
                return
            end

            if Instance.NAXX() and not Faction.IsHorde() then
                if TankTarget("Venom Stalker") or TankTarget("Necro Stalker") then
                    if ImBusy() then
                        SpellStopCasting()
                    end

                    MeleeBuff("Abolish Poison")
                    return
                end
            end

            HealerJindo("Wrath")
            Heal()
        end,
        Multi = Multi,
        AOE = function()
            if TankTarget("Maexxna") and MB_myMaexxnaBoxStrategy then
                if ConfigState.AssignedHealTarget then
                    if IsAlive(MBID[ConfigState.AssignedHealTarget]) then
                        MTHeals(ConfigState.AssignedHealTarget)
                        return
                    else
                        ConfigState.AssignedHealTarget = nil
                        RunLine("/raid My healtarget died, time to ALT-F4.")
                    end
                end

                if FindMyNameInTable(MB_myMaexxnaDruidHealer) then
                    MaxRejuvAggroedPlayer()
                    AbolishAggroedPlayer()
                    MaxRegrowthAggroedPlayer()
                    return
                end
            end

            Multi()
        end,
        PreCast = function()
            if ConfigState.PlayerSpecc == "Feral" then
                return
            end

            PreCastTrinkets()
            CastSpellByName("Starfire")
        end,
        LoaHeal = function()
            GetTarget()
            CancelAuraSet(RemoveBuffs)


            if InCombat() then
                HealerDebuffs()
                Innervate()

                TakeManaPotionAndRunes()

                if ManaDown() > 600 then
                    Cooldowns()
                end
            end

            if LOA_Healing() then
                return
            end

            LOA_Attack()
        end
    })
end, function()
    return myClass == "Druid"
end)
