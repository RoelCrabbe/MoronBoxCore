-- [[ Druid Rotation ]] --

local NAME = "Druid Rotation"
local MODULE_NAME = "MODULE_" .. string.upper(string.gsub(NAME, " ", "_"))

local myName = UnitName("player")
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
        for _, name in ipairs(getEncountersState().Vaelastrasz.DruidHealers) do
            local id = getCoreState().MBID[name]
            if id and not getUnit().Dead(id) then
                return name
            end
        end
        return nil
    end

    local function Taunt()
        if Instance.MC() and getRaid().TankTarget("Magmadar") then
            return
        end

        if getSpells().IsSpellReady("Growl") then
            CastSpellByName("Growl")
            return
        end

        if UnitName("target") and getUnit().InCombat("target") then
            if getSpells().IsSpellReady("Faerie Fire (Feral)()") then
                CastSpellByName("Faerie Fire (Feral)()")
            end
        end
    end

    local function Cooldowns()
        if getSpells().ImBusy() or not getUnit().InCombat() then
            return
        end

        if getConfigState().PlayerSpecc == "Feral" then
            getBag().MeleeTrinkets()
            return
        end

        getBag().HealerTrinkets()
        getBag().CasterTrinkets()
    end

    local function Innervate()
        if getSpells().ImBusy() or (Instance.MC() and (getRaid().TankTarget("Garr") or getRaid().TankTarget("Firesworn"))) or not getSpells().IsSpellReady("Innervate") then
            return
        end

        for _, innerTarget in ipairs(getHealingState().Druid.InnervateHealerList) do
            local unitID = getCoreState().MBID[innerTarget]

            if getUnit().IsValidFriendlyTarget(unitID, "Innervate") and getUnit().HealthPct(unitID) <= 0.5 and not getAura().HasBuffNamed("Innervate", unitID) and getSpells().IsSpellReady("Innervate") then
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

            if not getRaid().IsAtRazorgore() or not getRaid().IsAtRazorgorePhase() or not getEncountersState().Razorgore.Active then
                return
            end

            local tanks = {
                Right = getApi().ReturnPlayerInRaidFromTable(getEncountersState().Razorgore.RightMainTank),
                Left = getApi().ReturnPlayerInRaidFromTable(getEncountersState().Razorgore.LeftMainTank)
            }

            for _, tank in pairs(tanks) do
                local tankId = getCoreState().MBID[tank]
                local tankTargetId = tankId .. "target"
                if getRaid().TargetFromSpecificPlayer("Death Talon Dragonspawn", tank) and UnitCanAttack("player", tankTargetId) and
                    not (getAura().HasBuffOrDebuff("Faerie Fire", tankTargetId, "debuff") or getAura().HasBuffOrDebuff("Faerie Fire (Feral)", tankTargetId, "debuff")) then
                    AssistUnit(tankId)
                    CastSpellByName("Faerie Fire")
                    TargetLastTarget()
                end
            end
        else
            local state = getConfigState()
            local core = getCoreState()
            local setting = getSettingsState()

            local leaderName = state.RaidLeader or setting.RaidInviter
            local focusTarget = nil

            if leaderName and core.MBID[leaderName] then
                focusTarget = core.MBID[leaderName]
            end

            if not focusTarget then
                return
            end

            local targetUnit = focusTarget .. "target"
            if UnitCanAttack("player", targetUnit) and
                not (getAura().HasBuffOrDebuff("Faerie Fire", targetUnit, "debuff") or getAura().HasBuffOrDebuff("Faerie Fire (Feral)", targetUnit, "debuff")) then
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

        if getAura().HasBuffNamed("Shadow and Frost Reflect", "target") or
            getAura().HasBuffOrDebuff("Magic Reflection", "target", "buff") or
            (getRaid().TankTarget("Azuregos") and getAura().HasBuffNamed("Magic Shield", "target")) then
            if getSpells().ImBusy() then
                SpellStopCasting()
            end

            getAttack().AutoAttack()
            return true
        end

        if Instance.AQ40() then
            SARTURA_DruidDPS()
        elseif Instance.ZG() then
            if getAura().HasBuffOrDebuff("Delusions of Jin'do", "player", "debuff") then
                if target == "Shade of Jin'do" and not getUnit().Dead("target") then
                    getSpells().CastOrWand("Wrath")
                    return true
                end
            end

            if (target == "Powerful Healing Ward" or target == "Brain Wash Totem") and not getUnit().Dead("target") then
                getSpells().CastOrWand("Wrath")
                return true
            end
        elseif Instance.AQ20() and getRaid().TankTarget("Ossirian the Unscarred") then
            if getAura().HasBuffOrDebuff("Nature Weakness", "target", "debuff") then
                getSpells().CastOrWand("Wrath")
                return true
            end
        end

        return false
    end

    local function Balance()
        if not getUnit().IsBoomForm() then
            getSpells().SelfBuff("Moonkin Form")
            getUnit().CancelDruidShapeShift()
        end

        getDispel().Decurse()

        if not getUnit().InCombat("target") then
            return
        end

        if getUnit().InCombat() then
            HealerDebuffs()
            Innervate()

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

        getSpells().CastOrWand("Starfire")
    end

    local HealTouch = { Time = 0, Interrupt = false }

    local function MTHeals(assignedTarget)
        if assignedTarget then
            TargetByName(assignedTarget, 1)
        else
            if getRaid().TankTarget("Patchwerk") and getEncountersState().Patchwerk.Active then
                getHealing().TargetMyAssignedTankToHeal()
            else
                local tankTarget = UnitName(getCoreState().MBID[getUnit().GetTankName()] .. "targettarget")
                if not tankTarget then
                    MBH_CastHeal("Healing Touch")
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
            CastSpellByName("Healing Touch")
            return
        end

        local healTouchSpell = getRaid().TankTarget("Vaelastrasz the Corrupt") and "Healing Touch" or
            ("Healing Touch(" .. getHealingState().Druid.MainTankHealingRank .. ")")

        if not getTables().BossNeverInterruptHeal() and getUnit().HealthDown("target") <= (getHealing().GetHealValueFromRank("Healing Touch", getHealingState().Druid.MainTankHealingRank) * getHealingState().MainTankOverhealingPercentage) then
            if GetTime() > HealTouch.Time and GetTime() < HealTouch.Time + 0.5 and HealTouch.Interrupt then
                SpellStopCasting()
                HealTouch.Interrupt = false
                SpellStopCasting()
            end
        end

        if not getSpells().ImBusy() then
            CastSpellByName(healTouchSpell)
            HealTouch.Time = GetTime() + 1
            HealTouch.Interrupt = true
        end
    end

    local function MaxRejuvAggroedPlayer()
        local raidLeadId = getCoreState().MBID[getConfigState().RaidLeader]
        if not raidLeadId or getSpells().ImBusy() or (Instance.MC() and (getRaid().TankTarget("Garr") or getRaid().TankTarget("Firesworn"))) then
            return
        end

        local rejuvTarget = raidLeadId .. "targettarget"
        if not getUnit().IsValidFriendlyTarget(rejuvTarget, "Rejuvenation") or getUnit().HealthPct(rejuvTarget) > 0.95 or getAura().HasBuffNamed("Rejuvenation", rejuvTarget) then
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
        local raidLeadId = getCoreState().MBID[getConfigState().RaidLeader]
        if not raidLeadId or getSpells().ImBusy() or (Instance.MC() and (getRaid().TankTarget("Garr") or getRaid().TankTarget("Firesworn"))) then
            return
        end

        local regroTarget = raidLeadId .. "targettarget"
        if not getUnit().IsValidFriendlyTarget(regroTarget, "Regrowth") or getUnit().HealthPct(regroTarget) > 0.95 or getAura().HasBuffNamed("Regrowth", regroTarget) then
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
        if getSpells().ImBusy() or (Instance.MC() and (getRaid().TankTarget("Garr") or getRaid().TankTarget("Firesworn"))) then
            return
        end

        local aggrox = AceLibrary("Banzai-1.0")

        for i = 1, GetNumRaidMembers() do
            local rejuvTarget = "raid" .. i

            if aggrox:GetUnitAggroByUnitId(rejuvTarget) and
                getUnit().IsValidFriendlyTarget(rejuvTarget, "Rejuvenation") and
                getUnit().HealthPct(rejuvTarget) <= getHealingState().Druid.RejuvenationAggroedPlayerPercentage and
                not getAura().HasBuffNamed("Rejuvenation", rejuvTarget) then
                if UnitIsFriend("player", rejuvTarget) then
                    ClearTarget()
                end

                CastSpellByName("Rejuvenation(" .. getHealingState().Druid.RejuvenationAggroedPlayerRank .. ")")
                SpellTargetUnit(rejuvTarget)
                SpellStopTargeting()
                return
            end
        end
    end

    local function RegrowthAggroedPlayer()
        if getSpells().ImBusy() or (Instance.MC() and (getRaid().TankTarget("Garr") or getRaid().TankTarget("Firesworn"))) or not ImprovedRegrowth() or UnitMana("player") < 880 or getCore().MyClassOrder() ~= 1 then
            return
        end

        local aggrox = AceLibrary("Banzai-1.0")

        for i = 1, GetNumRaidMembers() do
            local regroTarget = "raid" .. i

            if aggrox:GetUnitAggroByUnitId(regroTarget) and
                getUnit().IsValidFriendlyTarget(regroTarget, "Regrowth") and
                getUnit().HealthPct(regroTarget) <= getHealingState().Druid.SwiftmendRegrowthAggroedPlayerPercentage and
                not getAura().HasBuffNamed("Regrowth", regroTarget) then
                if UnitIsFriend("player", regroTarget) then
                    ClearTarget()
                end

                CastSpellByName("Regrowth(" .. getHealingState().Druid.SwiftmendRegrowthAggroedPlayerRank .. ")")
                SpellTargetUnit(regroTarget)
                SpellStopTargeting()
                return
            end
        end
    end

    local function RegrowthLowRandom()
        if getSpells().ImBusy() or (Instance.MC() and (getRaid().TankTarget("Garr") or getRaid().TankTarget("Firesworn"))) or not ImprovedRegrowth() or UnitMana("player") < 880 then
            return
        end

        local isRaid = GetRaidRosterInfo(1)
        local numMembers = isRaid and GetNumRaidMembers() or GetNumPartyMembers()
        local prefix = isRaid and "raid" or "party"

        for i = 1, numMembers do
            local unitID = prefix .. i
            if getUnit().HealthPct(unitID) < getHealingState().Druid.SwiftmendRegrowthLowRandomPercentage and getUnit().IsValidFriendlyTarget(unitID, "Regrowth") then
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
        local raidLeadId = getCoreState().MBID[getConfigState().RaidLeader]
        if not raidLeadId or getSpells().ImBusy() or (Instance.MC() and (getRaid().TankTarget("Garr") or getRaid().TankTarget("Firesworn"))) then
            return
        end

        local targetUnit = raidLeadId .. "targettarget"
        if not getUnit().IsValidFriendlyTarget(targetUnit, "Abolish Poison") or getUnit().HealthPct(targetUnit) > 0.95 or getAura().HasBuffNamed("Abolish Poison", targetUnit) then
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
        if not UnitInRaid("player") or getSpells().ImBusy() or (Instance.MC() and (getRaid().TankTarget("Garr") or getRaid().TankTarget("Firesworn"))) then
            return
        end

        local n = getUnit().GetNumPartyOrRaidMembers()
        local offset = math.random(n) - 1

        for i = 1, n do
            local j = i + offset
            if j > n then
                j = j - n
            end

            local raidUnit = "raid" .. j
            if getUnit().HealthPct(raidUnit) < percentage and
                getUnit().InCombat(raidUnit) and
                getUnit().IsValidFriendlyTarget(raidUnit, spell) and
                (getAura().HasBuffNamed("Rejuvenation", raidUnit) or getAura().HasBuffNamed("Regrowth", raidUnit)) then
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
        if getHealing().NatureSwiftnessLowAggroedPlayer() then
            return
        end

        getDispel().Decurse()

        if getUnit().InCombat() then
            HealerDebuffs()
            Innervate()
            getCons().TakeManaPotionAndRunes()

            if getUnit().ManaDown() > 600 then
                Cooldowns()
            end
        end

        if getAura().HasBuffOrDebuff("Curse of Tongues", "player", "debuff") and not getRaid().TankTarget("Anubisath Defender") then
            return
        end

        if Instance.MC() and getRaid().TankTarget("Shazzrah") then
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

        for _, bossName in pairs(getHealingState().Druid.MainTankHealingBossList) do
            if getRaid().TankTarget(bossName) then
                MTHeals()
                return
            end
        end

        if getConfigState().IsMoving.Active then
            if Instance.ONY() and getRaid().TankTarget("Onyxia") then
                getSpells().CastSpellWithCooldown("Moonfire", 12)
            end

            getHealing().CastSpellOnRandomRaidMember("Rejuvenation",
                getHealingState().Druid.RejuvenationLowRandomMovingRank,
                getHealingState().Druid.RejuvenationLowRandomMovingPercentage)
        end

        if Instance.AQ40() and getRaid().TankTarget("Princess Huhuran") then
            if getCore().MyGroupClassOrder() == 1 and getRaid().TankTargetHealth() <= 0.32 then
                MTHeals()
                return
            end

            MBH_CastHeal("Healing Touch")
            return
        elseif Instance.BWL() and getRaid().TankTarget("Vaelastrasz the Corrupt") and getEncountersState().Vaelastrasz.Active then
            Cooldowns()

            if getEncountersState().Vaelastrasz.DruidHealing and not getAura().HasBuffOrDebuff("Burning Adrenaline", "player", "debuff") then
                local activeDruid = GetActiveVaelastraszHealer()

                if myName == activeDruid then
                    MaxRejuvAggroedPlayer()
                    MaxRegrowthAggroedPlayer()
                end
            end

            if getSpells().IsSpellReady("Swiftmend") and (swiftmendRaidThrottleTimer == nil or GetTime() - swiftmendRaidThrottleTimer > 1.5) then
                swiftmendRaidThrottleTimer = GetTime()
                SwiftmendOnRandomRaidMember("Swiftmend", 0.5)
            end

            getSpells().SelfBuff("Rejuvenation")
            MBH_CastHeal("Regrowth", 9, 9)
            return
        end

        if not getSpells().ImBusy() then
            if getConfigState().HealSpell == "Rejuvenation" and getUnit().ManaDown() > 300 then
                getSpells().SelfBuff("Rejuvenation(Rank 1)")
            end

            RejuvAggroedPlayer()

            if getSpells().IsSpellKnown("Swiftmend") then
                if getSpells().IsSpellReady("Swiftmend") then
                    SwiftmendOnRandomRaidMember("Swiftmend", getHealingState().Druid.SwiftmendAtPercentage)
                end

                if (rejuvenationRaidThrottleTimer == nil or GetTime() - rejuvenationRaidThrottleTimer > 1.5) then
                    rejuvenationRaidThrottleTimer = GetTime()
                    getHealing().CastSpellOnRandomRaidMember("Rejuvenation",
                        getHealingState().Druid.SwiftmendRejuvenationLowRandomRank,
                        getHealingState().Druid.SwiftmendRejuvenationLowRandomPercentage)
                end
            elseif (rejuvenationRaidThrottleTimer == nil or GetTime() - rejuvenationRaidThrottleTimer > 1.5) then
                rejuvenationRaidThrottleTimer = GetTime()
                getHealing().CastSpellOnRandomRaidMember("Rejuvenation",
                    getHealingState().Druid.RejuvenationLowRandomRank,
                    getHealingState().Druid.RejuvenationLowRandomPercentage)
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
        if getApi().FindInTable(getCoreState().RaidTanks, myName) and getAura().HasBuffOrDebuff("Greater Blessing of Salvation", "player", "buff") then
            CancelBuff("Greater Blessing of Salvation")
        end

        if not getUnit().IsBearForm() then
            getSpells().SelfBuff("Dire Bear Form")
            getUnit().CancelDruidShapeShift()
            return
        end

        if not getUnit().InCombat("target") then
            return
        end

        if getUnit().InCombat() then
            if getUnit().HealthPct() < 0.3 and getSpells().IsSpellReady("Frenzied Regeneration") then
                CastSpellByName("Frenzied Regeneration")
            end

            if getUnit().InMeleeRange() then
                if getAura().GetSunderAmount() == 5 or getAura().HasBuffOrDebuff("Expose Armor", "target", "debuff") then
                    Cooldowns()
                end

                if getSpells().IsSpellReady("Bash") and getTables().StunnableMob() then
                    CastSpellByName("Bash")
                end

                if not getAura().HasBuffOrDebuff("Demoralizing Shout", "target", "debuff") then
                    local targetName = UnitName("target")
                    if targetName ~= "Emperor Vek'nilash" and targetName ~= "Emperor Vek'lor" then
                        if not getAura().HasBuffOrDebuff("Demoralizing Roar", "target", "debuff") and UnitMana("player") >= 20 then
                            CastSpellByName("Demoralizing Roar")
                        end
                    end
                end
            end
        end

        getRaid().OffTank()

        local tOfTarget = UnitName("targettarget") or ""
        local tName = UnitName("target") or ""

        local shouldTaunt = tName ~= ""
            and tOfTarget ~= "" and tOfTarget ~= "Unknown"
            and UnitIsEnemy("player", "target")
            and not getApi().FindInTable(getCoreState().RaidTanks, tOfTarget)

        if shouldTaunt then
            if getConfigState().OffTankTarget then
                if tOfTarget ~= myName then
                    Taunt()
                end
            else
                Taunt()
            end
        end

        if getConfigState().OffTankTarget then
            if UnitExists("target") and GetRaidTargetIndex("target") and GetRaidTargetIndex("target") == getConfigState().OffTankTarget and UnitIsDead("target") then
                getConfigState().OffTankTarget = nil
                ClearTarget()
            end
        end

        getAttack().AutoAttack()

        if not getAura().HasBuffOrDebuff("Faerie Fire (Feral)", "target", "debuff") and not getAura().HasBuffOrDebuff("Faerie Fire", "target", "debuff") then
            CastSpellByName("Faerie Fire (Feral)()")
        end

        if getSpells().IsSpellReady("Enrage") and UnitMana("player") <= 15 then
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
        if getApi().FindInTable(getCoreState().RaidTanks, myName) and getAura().HasBuffOrDebuff("Greater Blessing of Salvation", "player", "buff") then
            CancelBuff("Greater Blessing of Salvation")
        end

        if not getUnit().IsBearForm() then
            getSpells().SelfBuff("Dire Bear Form")
            getUnit().CancelDruidShapeShift()
            return
        end

        if not getUnit().InCombat("target") then
            return
        end

        if getUnit().InCombat() then
            if getUnit().HealthPct() < 0.3 and getSpells().IsSpellReady("Frenzied Regeneration") then
                CastSpellByName("Frenzied Regeneration")
            end

            if getUnit().InMeleeRange() then
                if getAura().GetSunderAmount() == 5 or getAura().HasBuffOrDebuff("Expose Armor", "target", "debuff") then
                    Cooldowns()
                end

                if getSpells().IsSpellReady("Bash") and getTables().StunnableMob() then
                    CastSpellByName("Bash")
                end

                if not getAura().HasBuffOrDebuff("Demoralizing Shout", "target", "debuff") then
                    local targetName = UnitName("target")
                    if targetName ~= "Emperor Vek'nilash" and targetName ~= "Emperor Vek'lor" then
                        if not getAura().HasBuffOrDebuff("Demoralizing Roar", "target", "debuff") and UnitMana("player") >= 20 then
                            CastSpellByName("Demoralizing Roar")
                        end
                    end
                end
            end
        end

        getRaid().OffTank()

        local tOfTarget = UnitName("targettarget") or ""
        local tName = UnitName("target") or ""

        local shouldTaunt = tName ~= ""
            and tOfTarget ~= "" and tOfTarget ~= "Unknown"
            and UnitIsEnemy("player", "target")
            and not getApi().FindInTable(getCoreState().RaidTanks, tOfTarget)

        if shouldTaunt then
            if getConfigState().OffTankTarget then
                if tOfTarget ~= myName then
                    Taunt()
                end
            else
                Taunt()
            end
        end

        if getConfigState().OffTankTarget then
            if UnitExists("target") and GetRaidTargetIndex("target") and GetRaidTargetIndex("target") == getConfigState().OffTankTarget and UnitIsDead("target") then
                getConfigState().OffTankTarget = nil
                ClearTarget()
            end
        end

        getAttack().AutoAttack()

        if not getAura().HasBuffOrDebuff("Faerie Fire (Feral)", "target", "debuff")
            and not getAura().HasBuffOrDebuff("Faerie Fire", "target", "debuff") then
            CastSpellByName("Faerie Fire (Feral)()")
        end

        if getSpells().IsSpellReady("Enrage") and UnitMana("player") <= 15 then
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
        getRaid().GetTarget()
        getAura().CancelAuraSet(RemoveBuffs)

        if not getConfigState().PlayerSpecc then
            getApi().CdMessage("My specc is fucked. Defaulting to Resto.")
            getConfigState().PlayerSpecc = "Resto"
        end

        if getConfigState().PlayerSpecc == "Feral" then
            if Instance.AQ40() then
                getRaid().AnubisathAlert()
            end

            TankMulti()
            return
        end

        if UnitName("target") == "Death Talon Wyrmkin" and GetRaidTargetIndex("target") == getConfigState().CrowdControlTarget then
            CastSpellByName("Hibernate(Rank 1)")
            return
        end

        if getCrowdControl().CastCrowdControl() then
            return
        end

        if UnitName("target") then
            if getConfigState().CrowdControlTarget and GetRaidTargetIndex("target") == getConfigState().CrowdControlTarget and not getAura().HasBuffOrDebuff(getConfigState().CrowdControlSpell[myClass], "target", "debuff") then
                if getCrowdControl().CastCrowdControl() then
                    return
                end
            end

            if getUnit().CrowdControlledMob() then
                getRaid().GetTarget()
            end
        end

        if getConfigState().PlayerSpecc == "Balance" then
            Balance()
            return
        end

        if Instance.NAXX() and not Faction.IsHorde() then
            if getRaid().TankTarget("Venom Stalker") or getRaid().TankTarget("Necro Stalker") then
                if getSpells().ImBusy() then
                    SpellStopCasting()
                end

                getSpells().MeleeBuff("Abolish Poison")
                return
            end
        end

        getRotation().HealerJindo("Wrath")
        Heal()
    end

    local function LOA_Attack()
        if getSpells().ImBusy() or not getUnit().InCombat() then
            return
        end

        getRaid().GetTarget()

        if getUnit().ManaPct() < 0.13 then
            return
        end

        if getSpells().IsSpellReady("Starfire") then
            getSpells().CastSpellWithCooldown("Starfire", 6)
            return
        end

        getAttack().AutoAttack()
    end

    MoronBox:RegisterExpose({
        Specc = function()
            local _, _, _, _, balance = GetTalentInfo(1, 16)
            local _, _, _, _, feral = GetTalentInfo(2, 16)
            local _, _, _, _, swiftmend = GetTalentInfo(3, 15)
            local _, _, _, _, improvedRejuv = GetTalentInfo(3, 3)

            if balance > 0 then
                getConfigState().PlayerSpecc = "Balance"
            elseif feral > 0 then
                getConfigState().PlayerSpecc = "Feral"
            elseif swiftmend > 0 then
                getConfigState().PlayerSpecc = "Swiftmend"
            elseif improvedRejuv > 4 then
                getConfigState().PlayerSpecc = "Resto"
            else
                getConfigState().PlayerSpecc = nil
            end
        end,
        Setup = function()
            if getUnit().IsDruidShapeShifted() and not getUnit().InCombat() then
                getUnit().CancelDruidShapeShift()
            end

            if UnitMana("player") < 3060 and getAura().HasBuffNamed("Drink", "player") then
                return
            end

            getBuffs().ProcessMarkOfTheWild()

            if not getSettingsState().SpeedRunEnabled then
                getSpells().TankBuff("Thorns")
            end

            getSpells().SelfBuff("Omen of Clarity")

            if not getUnit().InCombat() and getUnit().ManaPct() < 0.20 and not getAura().HasBuffNamed("Drink", "player") then
                getWater().SmartDrink()
            end
        end,
        Single = function()
            getRaid().GetTarget()
            getAura().CancelAuraSet(RemoveBuffs)

            if not getConfigState().PlayerSpecc then
                getApi().CdMessage("My specc is fucked. Defaulting to Resto.")
                getConfigState().PlayerSpecc = "Resto"
            end

            if getConfigState().PlayerSpecc == "Feral" then
                if Instance.AQ40() then
                    getRaid().AnubisathAlert()
                end

                TankSingle()
                return
            end

            if UnitName("target") == "Death Talon Wyrmkin" and GetRaidTargetIndex("target") == getConfigState().CrowdControlTarget then
                CastSpellByName("Hibernate(Rank 1)")
                return
            end

            if getCrowdControl().CastCrowdControl() then
                return
            end

            if UnitName("target") then
                if getConfigState().CrowdControlTarget and GetRaidTargetIndex("target") == getConfigState().CrowdControlTarget and not getAura().HasBuffOrDebuff(getConfigState().CrowdControlSpell[myClass], "target", "debuff") then
                    if getCrowdControl().CastCrowdControl() then
                        return
                    end
                end

                if getUnit().CrowdControlledMob() then
                    getRaid().GetTarget()
                end
            end

            if getConfigState().PlayerSpecc == "Balance" then
                Balance()
                return
            end

            if Instance.NAXX() and not Faction.IsHorde() then
                if getRaid().TankTarget("Venom Stalker") or getRaid().TankTarget("Necro Stalker") then
                    if getSpells().ImBusy() then
                        SpellStopCasting()
                    end

                    getSpells().MeleeBuff("Abolish Poison")
                    return
                end
            end

            getRotation().HealerJindo("Wrath")
            Heal()
        end,
        Multi = Multi,
        AOE = function()
            if getRaid().TankTarget("Maexxna") and getEncountersState().Maexxna.Active then
                if getConfigState().AssignedHealTarget then
                    if getUnit().IsAlive(getCoreState().MBID[getConfigState().AssignedHealTarget]) then
                        MTHeals(getConfigState().AssignedHealTarget)
                        return
                    else
                        getConfigState().AssignedHealTarget = nil
                        getApi().CdMessage("My healtarget died, time to ALT-F4.")
                    end
                end

                if getApi().FindMyNameInTable(getEncountersState().Maexxna.DruidHealers) then
                    MaxRejuvAggroedPlayer()
                    AbolishAggroedPlayer()
                    MaxRegrowthAggroedPlayer()
                    return
                end
            end

            Multi()
        end,
        PreCast = function()
            if getConfigState().PlayerSpecc == "Feral" then
                return
            end

            getBag().PreCastTrinkets()
            CastSpellByName("Starfire")
        end,
        LoaHeal = function()
            getRaid().GetTarget()
            getAura().CancelAuraSet(RemoveBuffs)


            if getUnit().InCombat() then
                HealerDebuffs()
                Innervate()

                getCons().TakeManaPotionAndRunes()

                if getUnit().ManaDown() > 600 then
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
