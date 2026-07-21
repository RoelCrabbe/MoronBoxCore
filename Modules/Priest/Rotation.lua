-- [[ Priest Rotation ]] --

local NAME = "Priest Rotation"
local MODULE_NAME = "MODULE_" .. string.upper(string.gsub(NAME, " ", "_"))

local myName = UnitName("player")
local myClass = UnitClass("player")

MoronBox:RegisterModule(MODULE_NAME, function()
    local PrayerManaCost = {
        [1] = 451,
        [2] = 616,
        [3] = 847,
        [4] = 1133,
        [5] = 1177
    }

    local PrayerFocusRanks = {
        [4] = true,
        [5] = true,
    }

    local RemoveBuffs = {
        ["Battle Shout"]     = "Battle Shout",
        ["Fengus' Ferocity"] = "Fengus' Ferocity",
        ["Polished Armor"]   = "Polished Armor",
        ["R.O.I.D.S."]       = "Rage of Ages"
    }

    local function Fade()
        local aggrox = AceLibrary("Banzai-1.0")

        if aggrox and aggrox:GetUnitAggroByUnitId("player") then
            getSpells().SelfBuff("Fade")
        end
    end

    local function GetActiveVaelastraszHealer()
        for _, name in ipairs(getEncountersState().Vaelastrasz.PriestHealers) do
            local id = getCoreState().MBID[name]
            if id and not getUnit().IsDead(id) then
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

        if getUnit().ManaPct() <= getHealingState().Priest.InnerFocusPercentage then
            getSpells().SelfBuff("Inner Focus")
        end

        getBag().HealerTrinkets()
        getBag().CasterTrinkets()
    end

    local function PowerInfusion()
        if not getUnit().InCombat() then
            return false
        end

        if Instance.MC() and (getRaid().TankTarget("Garr") or getRaid().TankTarget("Firesworn")) then
            return false
        end

        getBuffs().ProcessPowerInfusion()
        return false
    end

    local function ManaDrain()
        if getSpells().ImBusy() then
            return false
        end

        local isAQ40Eradicator = Instance.AQ40() and getRaid().TankTarget("Obsidian Eradicator")
        local isAQ20Moam = Instance.AQ20() and getRaid().TankTarget("Moam")

        if (isAQ40Eradicator or isAQ20Moam) and getUnit().ManaPct("target") > 0.25 then
            getSpells().CastOrWand("Mana Burn")
            return true
        end

        return false
    end

    local function UseWand()
        if getSpells().ImBusy() or not getUnit().InCombat() then
            return
        end

        getRaid().GetTarget()

        if getSettingsState().SpeedRunEnabled and getSpells().IsSpellReady("Mind Blast") then
            getSpells().CastOrWand("Mind Blast")
            return
        end

        getAttack().AutoWandAttack()
    end

    local function PartyHurt(hurt, num_party_hurt)
        local numHurt = 0

        if getUnit().HealthDown() > hurt then
            numHurt = numHurt + 1
        end

        for i = 1, GetNumPartyMembers() do
            local unit = "party" .. i
            if not getUnit().IsDead(unit) and getUnit().In28YardRange(unit) then
                local guysHurt = UnitHealthMax(unit) - UnitHealth(unit)
                if guysHurt > hurt then
                    numHurt = numHurt + 1
                end
            end
        end

        return (numHurt >= num_party_hurt) and numHurt or nil
    end

    local function PrayerOfHealingCheck(manaRank, checkRank, minTargets, focus)
        local cost = PrayerManaCost[manaRank]
        if not cost or UnitMana("player") < cost then
            return false
        end

        local rank = checkRank or manaRank
        local healValue = getHealing().GetHealValueFromRank("Prayer of Healing", "Rank " .. rank)

        if PartyHurt(healValue, minTargets) then
            if focus then
                getSpells().SelfBuff("Inner Focus")
            end

            CastSpellByName("Prayer of Healing(Rank " .. manaRank .. ")")
            return true
        end

        return false
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

            getAttack().AutoWandAttack()
            return true
        end

        if Instance.IsWorldBoss() and target ~= "Nefarian" then
            if not getAura().HasBuffOrDebuff("Vampiric Embrace", "target", "debuff") then
                CastSpellByName("Vampiric Embrace")
            end
        end

        ManaDrain()

        if Instance.AQ40() then
            SARTURA_PriestDPS()
        elseif Instance.MC() then
            getSpells().CastSpellWithCooldown("Shadow Word: Pain(Rank 1)", 24)
        elseif Instance.ONY() and getRaid().TankTarget("Onyxia") then
            getSpells().CastSpellWithCooldown("Shadow Word: Pain", 24)
        elseif not UnitInRaid("player") and getAura().GetShadowWeavingAmount() > 5 then
            getSpells().CastSpellWithCooldown("Shadow Word: Pain", 24)
        end

        return false
    end

    local function ShadowWeaving()
        local leader = getConfigState().RaidLeader or getSettingsState().RaidInviter
        if not leader then
            return false
        end

        local leaderId = getCoreState().MBID[leader]
        local targetUnit = leaderId .. "target"

        local needsStacking = getAura().GetShadowWeavingAmount() < 5
        local isValidTarget = UnitCanAttack("player", targetUnit) and
            getUnit().IsValidEnemyTargetWithin28YardRange(targetUnit)

        AssistUnit(leaderId)

        if needsStacking and isValidTarget then
            CastSpellByName("Shadow Word: Pain(Rank 1)")
            return true
        end

        getSpells().CastSpellWithCooldown("Shadow Word: Pain(Rank 1)", 24)
        return false
    end

    local function Shadow()
        getSpells().SelfBuff("Shadowform")

        if not getUnit().InCombat("target") then
            return
        end

        if getUnit().InCombat() then
            getCons().TakeManaPotionAndRunes()

            if getUnit().ManaDown() > 600 then
                Cooldowns()
            end

            if getSpells().IsSpellReady("Desperate Prayer") and getUnit().HealthPct() < 0.2 then
                CastSpellByName("Desperate Prayer")
                return
            end
        end

        if BossSpecificDPS() then
            return
        end

        if getSpells().ImBusy() then
            return
        end

        if getSpells().IsSpellReady("Mind Blast") then
            getSpells().CastOrWand("Mind Blast")
        else
            getSpells().CastOrWand("Mind Flay")
        end
    end

    local GreaterHeal = { Time = 0, Interrupt = false }

    local function MTHeals(assignedTarget)
        if assignedTarget then
            TargetByName(assignedTarget, 1)
        else
            if getRaid().TankTarget("Patchwerk") and getEncountersState().Patchwerk.Active then
                getHealing().TargetMyAssignedTankToHeal()
            else
                local tankTarget = UnitName(getCoreState().MBID[getUnit().GetTankName()] .. "targettarget")
                if not tankTarget then
                    MBH_CastHeal("Greater Heal", 1, 1)
                else
                    TargetByName(tankTarget, 1)
                end
            end
        end

        if Instance.BWL() and getRaid().TankTarget("Nefarian") and getAura().HasBuffOrDebuff("Corrupted Healing", "player", "debuff") then
            if getSpells().ImBusy() then
                SpellStopCasting()
            end

            if getSpells().IsSpellReady("Power Word: Shield") then
                getHealing().CastSpellOnRandomRaidMember("Weakened Soul", "rank 10", 0.9)
            end

            getHealing().CastSpellOnRandomRaidMember("Renew", "rank 10", 0.95)
            return
        end

        if getUnit().HealthPct("target") < 0.5 and getSpells().IsSpellReady("Power Word: Shield") and not getAura().HasBuffOrDebuff("Weakened Soul", "target", "debuff") then
            CastSpellByName("Power Word: Shield")
        end

        local GreatHealSpell = getRaid().TankTarget("Vaelastrasz the Corrupt") and "Greater Heal" or
            ("Greater Heal(" .. getHealingState().Priest.MainTankHealingRank .. ")")

        if not getTables().BossNeverInterruptHeal() and getUnit().HealthDown("target") <= (getHealing().GetHealValueFromRank("Greater Heal", getHealingState().Priest.MainTankHealingRank) * getHealingState().MainTankOverhealingPercentage) then
            if GetTime() > GreaterHeal.Time and GetTime() < GreaterHeal.Time + 0.5 and GreaterHeal.Interrupt then
                SpellStopCasting()
                GreaterHeal.Interrupt = false
                SpellStopCasting()
            end
        end

        if not getSpells().ImBusy() then
            CastSpellByName(GreatHealSpell)
            GreaterHeal.Time = GetTime() + 1
            GreaterHeal.Interrupt = true
        end
    end

    local function MaxShieldAggroedPlayer()
        local leaderId = getCoreState().MBID[getConfigState().RaidLeader]
        if not leaderId or getSpells().ImBusy() then
            return
        end

        if Instance.MC() and (getRaid().TankTarget("Garr") or getRaid().TankTarget("Firesworn")) then
            return
        end

        local shieldTarget = leaderId .. "targettarget"
        if not getUnit().IsValidFriendlyTarget(shieldTarget, "Power Word: Shield") or
            getUnit().HealthPct(shieldTarget) > 0.95 or
            getAura().HasBuffOrDebuff("Weakened Soul", shieldTarget, "debuff") or
            not getSpells().IsSpellReady("Power Word: Shield") then
            return
        end

        if UnitIsFriend("player", shieldTarget) then
            ClearTarget()
        end

        CastSpellByName("Power Word: Shield", nil)
        SpellTargetUnit(shieldTarget)
        SpellStopTargeting()
    end

    local function MaxRenewAggroedPlayer()
        local leaderId = getCoreState().MBID[getConfigState().RaidLeader]
        if not leaderId or getSpells().ImBusy() then
            return
        end

        if Instance.MC() and (getRaid().TankTarget("Garr") or getRaid().TankTarget("Firesworn")) then
            return
        end

        local renewTarget = leaderId .. "targettarget"
        if not getUnit().IsValidFriendlyTarget(renewTarget, "Renew") or
            getUnit().HealthPct(renewTarget) > 0.95 or
            getAura().HasBuffNamed("Renew", renewTarget) then
            return
        end

        if UnitIsFriend("player", renewTarget) then
            ClearTarget()
        end

        CastSpellByName("Renew")
        SpellTargetUnit(renewTarget)
        SpellStopTargeting()
    end

    local function ShieldAggroedPlayer()
        if getSpells().ImBusy() or (Instance.MC() and (getRaid().TankTarget("Garr") or getRaid().TankTarget("Firesworn"))) then
            return
        end

        local aggrox = AceLibrary("Banzai-1.0")

        for i = 1, GetNumRaidMembers() do
            local shieldTarget = "raid" .. i

            if aggrox and aggrox:GetUnitAggroByUnitId(shieldTarget) and
                getUnit().IsValidFriendlyTarget(shieldTarget, "Power Word: Shield") and
                getUnit().HealthPct(shieldTarget) <= getHealingState().Priest.ShieldAggroedPlayerPercentage and
                not getAura().HasBuffOrDebuff("Weakened Soul", shieldTarget, "debuff") and
                getSpells().IsSpellReady("Power Word: Shield") then
                if UnitIsFriend("player", shieldTarget) then
                    ClearTarget()
                end

                CastSpellByName("Power Word: Shield", nil)
                SpellTargetUnit(shieldTarget)
                SpellStopTargeting()
                return
            end
        end
    end

    local function RenewAggroedPlayer()
        if getSpells().ImBusy() or (Instance.MC() and (getRaid().TankTarget("Garr") or getRaid().TankTarget("Firesworn"))) then
            return
        end

        local aggrox = AceLibrary("Banzai-1.0")

        for i = 1, GetNumRaidMembers() do
            local renewTarget = "raid" .. i

            if aggrox and aggrox:GetUnitAggroByUnitId(renewTarget) and
                getUnit().IsValidFriendlyTarget(renewTarget, "Renew") and
                getUnit().HealthPct(renewTarget) <= getHealingState().Priest.RenewAggroedPlayerPercentage and
                not getAura().HasBuffNamed("Renew", renewTarget) then
                if UnitIsFriend("player", renewTarget) then
                    ClearTarget()
                end

                CastSpellByName("Renew(" .. getHealingState().Priest.RenewAggroedPlayerRank .. ")")
                SpellTargetUnit(renewTarget)
                SpellStopTargeting()
                return
            end
        end
    end

    local function ShieldToBombFollowTarget()
        if getSpells().ImBusy() or getRaid().TankTarget("Vaelastrasz the Corrupt") then
            return
        end

        local targetName = getApi().ReturnPlayerInRaidFromTable(getSettingsState().GTFO.Vaelastrasz)
        local targetID = getCoreState().MBID[targetName]

        if not targetID or not getUnit().IsAlive(targetID) or
            getAura().HasBuffOrDebuff("Weakened Soul", targetID, "debuff") or
            not getSpells().IsSpellReady("Power Word: Shield") then
            return
        end

        TargetUnit(targetID)
        CastSpellByName("Power Word: Shield")
        TargetLastTarget()
    end

    local function Heal()
        if getUnit().InCombat() then
            if Instance.MC() and (getRaid().TankTarget("Garr") or getRaid().TankTarget("Firesworn")) and getConfigState().RaidLeader and getCore().MyClassOrder() == 1 then
                local leaderId = getCoreState().MBID[getConfigState().RaidLeader]

                if getAura().HasBuffOrDebuff("Magma Shackles", leaderId, "debuff") then
                    TargetUnit(leaderId)
                    CastSpellByName("Dispel Magic")
                    TargetLastTarget()
                end
            end

            getCons().TakeManaPotionAndRunes()

            if getUnit().ManaDown() > 600 then
                Cooldowns()
            end

            if PowerInfusion() then
                return
            end

            if ManaDrain() then
                return
            end

            if getSpells().IsSpellReady("Desperate Prayer") and getUnit().HealthPct() < 0.2 then
                CastSpellByName("Desperate Prayer")
                return
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

        for _, bossName in pairs(getHealingState().Priest.MainTankHealingBossList) do
            if getRaid().TankTarget(bossName) then
                MTHeals()
                return
            end
        end

        if getConfigState().IsMoving.Active then
            getHealing().CastSpellOnRandomRaidMember("Renew", getHealingState().Priest.RenewLowRandomRank,
                getHealingState().Priest.RenewLowRandomPercentage)
        end

        if Instance.AQ40() and getRaid().TankTarget("Princess Huhuran") then
            if getRaid().TankTargetHealth() <= 0.32 then
                if PrayerOfHealingCheck(4, 1, 3, true) and getCore().MyGroupClassOrder() == 1 then
                    return
                end

                MBH_CastHeal("Flash Heal", 4, 6)
                return
            end

            MBH_CastHeal("Heal")
        elseif Instance.BWL() then
            if getRaid().TankTarget("Vaelastrasz the Corrupt") and getEncountersState().Vaelastrasz.Active then
                Cooldowns()

                if getEncountersState().Vaelastrasz.PriestHealing and not getAura().HasBuffOrDebuff("Burning Adrenaline", "player", "debuff") then
                    local activePriest = GetActiveVaelastraszHealer()
                    if myName == activePriest then
                        MaxRenewAggroedPlayer()
                        ShieldAggroedPlayer()
                    else
                        ShieldToBombFollowTarget()
                    end
                end

                if PrayerOfHealingCheck(5, 1, 3, true) and getCore().MyGroupClassOrder() == 1 then
                    return
                end

                MBH_CastHeal("Flash Heal", 7, 7)
                return
            elseif getRaid().TankTarget("Nefarian") and getAura().HasBuffOrDebuff("Corrupted Healing", "player", "debuff") then
                if getSpells().ImBusy() then
                    SpellStopCasting()
                end

                if getSpells().IsSpellReady("Power Word: Shield") then
                    getHealing().CastSpellOnRandomRaidMember("Weakened Soul", "rank 10", 0.9)
                end

                getHealing().CastSpellOnRandomRaidMember("Renew", "rank 10", 0.95)
                return
            elseif getRaid().TankTarget("Chromaggus") and getConfigState().HealSpell ~= "Flash Heal" then
                getConfigState().HealSpell = "Flash Heal"
            end
        end

        if not getSpells().ImBusy() then
            if getCore().MyGroupClassOrder() == 1 then
                for rank = 5, 1, -1 do
                    if PrayerOfHealingCheck(rank, rank, 4, PrayerFocusRanks[rank] or false) then
                        return
                    end
                end
            end

            if getUnit().InCombat() then
                if getSpells().IsSpellReady("Power Word: Shield") then
                    ShieldAggroedPlayer()
                    getHealing().CastSpellOnRandomRaidMember("Weakened Soul", "rank 10", getHealingState().Priest
                        .ShieldLowRandomPercentage)
                end

                RenewAggroedPlayer()
                getHealing().CastSpellOnRandomRaidMember("Renew", getHealingState().Priest.RenewLowRandomRank,
                    getHealingState().Priest.RenewLowRandomPercentage)
            end
        end

        if getAura().HasBuffOrDebuff("Inner Focus", "player", "buff") then
            MBH_CastHeal("Flash Heal", 6, 7)
        elseif getConfigState().HealSpell == "Greater Heal" or getAura().HasBuffOrDebuff("Hazza'rah's Charm of Healing", "player", "buff") then
            MBH_CastHeal("Greater Heal", 1, 1)
        elseif getConfigState().HealSpell == "Flash Heal" then
            MBH_CastHeal("Flash Heal")
        else
            MBH_CastHeal("Heal")
        end

        UseWand()
    end

    local function Single()
        getRaid().GetTarget()
        getAura().CancelAuraSet(RemoveBuffs)

        if getCrowdControl().CastCrowdControl() then
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

        if Instance.NAXX() then
            if (getRaid().TankTarget("Instructor Razuvious") and getApi().FindMyNameInTable(getEncountersState().Razuvious.MindControlPriests) and getEncountersState().Razuvious.Active) or
                (getRaid().TankTarget("Grand Widow Faerlina") and getApi().FindMyNameInTable(getEncountersState().Faerlina.MindControlPriests) and getEncountersState().Faerlina.Active) then
                getSpells().GetMCActions()
                return
            end
        elseif Instance.AQ40() and SKERAM_InFight() and SKERAM_BoxStrategyEnabled() then
            if SKERAM_CrowdControl() then
                return
            end
        end

        Fade()
        getDispel().Decurse()

        if getConfigState().PlayerSpecc == "Bitch" then
            ShadowWeaving()
        elseif getConfigState().PlayerSpecc == "Shadow" then
            Shadow()
            return
        end

        getRotation().HealerJindo("Smite")
        Heal()
    end

    local function LOA_Attack()
        if getSpells().ImBusy() or not getUnit().InCombat() then
            return
        end

        getRaid().GetTarget()

        if getUnit().ManaPct() < 0.11 then
            return
        end

        if getSpells().IsSpellReady("Mind Blast") then
            getSpells().CastOrWand("Mind Blast")
            return
        end

        if getSpells().IsSpellReady("Smite") then
            getSpells().CastSpellWithCooldown("Smite", 8)
        end

        getAttack().AutoWandAttack()
    end

    MoronBox:RegisterExpose({
        Specc = function()
            local _, _, _, _, disciplineCap = GetTalentInfo(1, 15)
            local _, _, _, _, holyCap = GetTalentInfo(2, 10)
            local _, _, _, _, shadowCap = GetTalentInfo(3, 16)
            local _, _, _, _, shadowFocus = GetTalentInfo(3, 11)

            if (holyCap > 0 and shadowFocus > 3) or (disciplineCap > 0 and shadowFocus == 5) then
                getConfigState().PlayerSpecc = "Bitch"
            elseif shadowCap > 0 then
                getConfigState().PlayerSpecc = "Shadow"
            else
                getConfigState().PlayerSpecc = nil
            end
        end,
        Setup = function()
            if UnitMana("player") < 3060 and getAura().HasBuffNamed("Drink", "player") then
                return
            end

            getBuffs().ProcessFortitude()
            -- getBuffs().ProcessFearWard()
            -- getBuffs().ProcessSpirit()
            -- getBuffs().ProcessShadowProtection()

            getSpells().SelfBuff("Inner Fire")
            getSpells().SelfBuff("Shadowform")

            if not getUnit().InCombat() and getUnit().ManaPct() < 0.20 and not getAura().HasBuffNamed("Drink", "player") then
                getWater().SmartDrink()
            end
        end,
        Single = Single,
        Multi = Single,
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

                if getApi().FindMyNameInTable(getEncountersState().Maexxna.PriestHealers) then
                    MaxRenewAggroedPlayer()
                    MaxShieldAggroedPlayer()
                    return
                end
            end

            Single()
        end,
        PreCast = function()
            getBag().PreCastTrinkets()
            CastSpellByName("Holy Fire")
        end,
        LoaHeal = function()
            getRaid().GetTarget()
            getAura().CancelAuraSet(RemoveBuffs)
            Fade()

            if getUnit().InCombat() then
                getCons().TakeManaPotionAndRunes()

                if getUnit().ManaDown() > 600 then
                    Cooldowns()
                end

                if PowerInfusion() then
                    return
                end
            end

            if LOA_Healing() then
                return
            end

            LOA_Attack()
        end
    })
end, function()
    return myClass == "Priest"
end)
