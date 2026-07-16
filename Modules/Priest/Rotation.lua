-- [[ Priest Rotation ]] --
---@diagnostic disable: undefined-global

local NAME = "Priest Rotation"
local MODULE_NAME = "MODULE_" .. string.upper(string.gsub(NAME, " ", "_"))

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
            SelfBuff("Fade")
        end
    end

    local function GetActiveVaelastraszHealer()
        for _, name in ipairs(MB_myVaelastraszPriests) do
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

        if ManaPct() <= HealingState.Priest.InnerFocusPercentage then
            SelfBuff("Inner Focus")
        end

        HealerTrinkets()
        CasterTrinkets()
    end

    local function PowerInfusion()
        if not InCombat() then
            return false
        end

        if Instance.MC() and (TankTarget("Garr") or TankTarget("Firesworn")) then
            return false
        end

        ProcessPowerInfusion()
        return false
    end

    local function ManaDrain()
        if ImBusy() then
            return false
        end

        local isAQ40Eradicator = Instance.AQ40() and TankTarget("Obsidian Eradicator")
        local isAQ20Moam = Instance.AQ20() and TankTarget("Moam")

        if (isAQ40Eradicator or isAQ20Moam) and ManaPct("target") > 0.25 then
            CastOrWand("Mana Burn")
            return true
        end

        return false
    end

    local function UseWand()
        if ImBusy() or not InCombat() then
            return
        end

        GetTarget()

        if SettingsState.SpeedRunEnabled and IsSpellReady("Mind Blast") then
            CastOrWand("Mind Blast")
            return
        end

        AutoWandAttack()
    end

    local function PartyHurt(hurt, num_party_hurt)
        local numHurt = 0

        if HealthDown() > hurt then
            numHurt = numHurt + 1
        end

        for i = 1, GetNumPartyMembers() do
            local unit = "party" .. i
            if not Dead(unit) and In28yardRange(unit) then
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
        local healValue = GetHealValueFromRank("Prayer of Healing", "Rank " .. rank)

        if PartyHurt(healValue, minTargets) then
            if focus then
                SelfBuff("Inner Focus")
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

        if HasBuffNamed("Shadow and Frost Reflect", "target") or
            HasBuffOrDebuff("Magic Reflection", "target", "buff") or
            (TankTarget("Azuregos") and HasBuffNamed("Magic Shield", "target")) then
            if ImBusy() then
                SpellStopCasting()
            end

            AutoWandAttack()
            return true
        end

        if Instance.IsWorldBoss() and target ~= "Nefarian" then
            if not HasBuffOrDebuff("Vampiric Embrace", "target", "debuff") then
                CastSpellByName("Vampiric Embrace")
            end
        end

        ManaDrain()

        if Instance.AQ40() then
            SARTURA_PriestDPS()
        elseif Instance.MC() then
            CoolDownCast("Shadow Word: Pain(Rank 1)", 24)
        elseif Instance.ONY() and TankTarget("Onyxia") then
            CoolDownCast("Shadow Word: Pain", 24)
        elseif not UnitInRaid("player") and DebuffShadowWeavingAmount() > 5 then
            CoolDownCast("Shadow Word: Pain", 24)
        end

        return false
    end

    local function ShadowWeaving()
        local leader = ConfigState.RaidLeader or MB_raidInviter
        if not leader then
            return false
        end

        local leaderId = MBID[leader]
        local targetUnit = leaderId .. "target"

        local needsStacking = DebuffShadowWeavingAmount() < 5
        local isValidTarget = UnitCanAttack("player", targetUnit) and IsValidEnemyTargetWithin28YardRange(targetUnit)

        AssistUnit(leaderId)

        if needsStacking and isValidTarget then
            CastSpellByName("Shadow Word: Pain(Rank 1)")
            return true
        end

        CoolDownCast("Shadow Word: Pain(Rank 1)", 24)
        return false
    end

    local function Shadow()
        SelfBuff("Shadowform")

        if not InCombat("target") then
            return
        end

        if InCombat() then
            TakeManaPotionAndRunes()

            if ManaDown() > 600 then
                Cooldowns()
            end

            if IsSpellReady("Desperate Prayer") and HealthPct() < 0.2 then
                CastSpellByName("Desperate Prayer")
                return
            end
        end

        if BossSpecificDPS() then
            return
        end

        if ImBusy() then
            return
        end

        if IsSpellReady("Mind Blast") then
            CastOrWand("Mind Blast")
        else
            CastOrWand("Mind Flay")
        end
    end

    local GreaterHeal = { Time = 0, Interrupt = false }

    local function MTHeals(assignedTarget)
        if assignedTarget then
            TargetByName(assignedTarget, 1)
        else
            if TankTarget("Patchwerk") and MB_myPatchwerkBoxStrategy then
                TargetMyAssignedTankToHeal()
            else
                local tankTarget = UnitName(MBID[TankName()] .. "targettarget")
                if not tankTarget then
                    MBH_CastHeal("Greater Heal", 1, 1)
                else
                    TargetByName(tankTarget, 1)
                end
            end
        end

        if Instance.BWL() and TankTarget("Nefarian") and HasBuffOrDebuff("Corrupted Healing", "player", "debuff") then
            if ImBusy() then
                SpellStopCasting()
            end

            if IsSpellReady("Power Word: Shield") then
                CastSpellOnRandomRaidMember("Weakened Soul", "rank 10", 0.9)
            end

            CastSpellOnRandomRaidMember("Renew", "rank 10", 0.95)
            return
        end

        if HealthPct("target") < 0.5 and IsSpellReady("Power Word: Shield") and not HasBuffOrDebuff("Weakened Soul", "target", "debuff") then
            CastSpellByName("Power Word: Shield")
        end

        local GreatHealSpell = TankTarget("Vaelastrasz the Corrupt") and "Greater Heal" or
            ("Greater Heal(" .. HealingState.Priest.MainTankHealingRank .. ")")

        if not BossNeverInterruptHeal() and HealthDown("target") <= (GetHealValueFromRank("Greater Heal", HealingState.Priest.MainTankHealingRank) * HealingState.MainTankOverhealingPercentage) then
            if GetTime() > GreaterHeal.Time and GetTime() < GreaterHeal.Time + 0.5 and GreaterHeal.Interrupt then
                SpellStopCasting()
                GreaterHeal.Interrupt = false
                SpellStopCasting()
            end
        end

        if not ImBusy() then
            CastSpellByName(GreatHealSpell)
            GreaterHeal.Time = GetTime() + 1
            GreaterHeal.Interrupt = true
        end
    end

    local function MaxShieldAggroedPlayer()
        local leader = ConfigState.RaidLeader
        if not leader or not MBID[leader] or ImBusy() then
            return
        end

        if Instance.MC() and (TankTarget("Garr") or TankTarget("Firesworn")) then
            return
        end

        local shieldTarget = MBID[leader] .. "targettarget"

        if not IsValidFriendlyTarget(shieldTarget, "Power Word: Shield") or
            HealthPct(shieldTarget) > 0.95 or
            HasBuffOrDebuff("Weakened Soul", shieldTarget, "debuff") or
            not IsSpellReady("Power Word: Shield") then
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
        local leader = ConfigState.RaidLeader
        if not leader or not MBID[leader] or ImBusy() then
            return
        end

        if Instance.MC() and (TankTarget("Garr") or TankTarget("Firesworn")) then
            return
        end

        local renewTarget = MBID[leader] .. "targettarget"

        if not IsValidFriendlyTarget(renewTarget, "Renew") or
            HealthPct(renewTarget) > 0.95 or
            HasBuffNamed("Renew", renewTarget) then
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
        if ImBusy() or (Instance.MC() and (TankTarget("Garr") or TankTarget("Firesworn"))) then
            return
        end

        local aggrox = AceLibrary("Banzai-1.0")

        for i = 1, GetNumRaidMembers() do
            local shieldTarget = "raid" .. i

            if aggrox:GetUnitAggroByUnitId(shieldTarget) and
                IsValidFriendlyTarget(shieldTarget, "Power Word: Shield") and
                HealthPct(shieldTarget) <= HealingState.Priest.ShieldAggroedPlayerPercentage and
                not HasBuffOrDebuff("Weakened Soul", shieldTarget, "debuff") and
                IsSpellReady("Power Word: Shield") then
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
        if ImBusy() or (Instance.MC() and (TankTarget("Garr") or TankTarget("Firesworn"))) then
            return
        end

        local aggrox = AceLibrary("Banzai-1.0")

        for i = 1, GetNumRaidMembers() do
            local renewTarget = "raid" .. i

            if aggrox:GetUnitAggroByUnitId(renewTarget) and
                IsValidFriendlyTarget(renewTarget, "Renew") and
                HealthPct(renewTarget) <= HealingState.Priest.RenewAggroedPlayerPercentage and
                not HasBuffNamed("Renew", renewTarget) then
                if UnitIsFriend("player", renewTarget) then
                    ClearTarget()
                end

                CastSpellByName("Renew(" .. HealingState.Priest.RenewAggroedPlayerRank .. ")")
                SpellTargetUnit(renewTarget)
                SpellStopTargeting()
                return
            end
        end
    end

    local function ShieldToBombFollowTarget()
        if ImBusy() or TankTarget("Vaelastrasz the Corrupt") then
            return
        end

        local targetName = ReturnPlayerInRaidFromTable(SettingsState.GTFO.Vaelastrasz)
        local targetID = MBID[targetName]

        if not targetID or not IsAlive(targetID) or
            HasBuffOrDebuff("Weakened Soul", targetID, "debuff") or
            not IsSpellReady("Power Word: Shield") then
            return
        end

        TargetUnit(targetID)
        CastSpellByName("Power Word: Shield")
        TargetLastTarget()
    end

    local function Heal()
        if InCombat() then
            if Instance.MC() and (TankTarget("Garr") or TankTarget("Firesworn")) and ConfigState.RaidLeader and MyClassOrder() == 1 then
                if HasBuffOrDebuff("Magma Shackles", MBID[ConfigState.RaidLeader], "debuff") then
                    TargetUnit(MBID[ConfigState.RaidLeader])
                    CastSpellByName("Dispel Magic")
                    TargetLastTarget()
                end
            end

            TakeManaPotionAndRunes()

            if ManaDown() > 600 then
                Cooldowns()
            end

            if PowerInfusion() then
                return
            end

            if ManaDrain() then
                return
            end

            if IsSpellReady("Desperate Prayer") and HealthPct() < 0.2 then
                CastSpellByName("Desperate Prayer")
                return
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

        for _, bossName in pairs(HealingState.Priest.MainTankHealingBossList) do
            if TankTarget(bossName) then
                MTHeals()
                return
            end
        end

        if ConfigState.IsMoving.Active then
            CastSpellOnRandomRaidMember("Renew", HealingState.Priest.RenewLowRandomRank,
                HealingState.Priest.RenewLowRandomPercentage)
        end

        if Instance.AQ40() and TankTarget("Princess Huhuran") then
            if TankTargetHealth() <= 0.32 then
                if PrayerOfHealingCheck(4, 1, 3, true) and MyGroupClassOrder() == 1 then
                    return
                end

                MBH_CastHeal("Flash Heal", 4, 6)
                return
            end

            MBH_CastHeal("Heal")
        elseif Instance.BWL() then
            if TankTarget("Vaelastrasz the Corrupt") and MB_myVaelastraszBoxStrategy then
                Cooldowns()

                if MB_myVaelastraszPriestHealing and not HasBuffOrDebuff("Burning Adrenaline", "player", "debuff") then
                    local activePriest = GetActiveVaelastraszHealer()
                    if myName == activePriest then
                        MaxRenewAggroedPlayer()
                        ShieldAggroedPlayer()
                    else
                        ShieldToBombFollowTarget()
                    end
                end

                if PrayerOfHealingCheck(5, 1, 3, true) and MyGroupClassOrder() == 1 then
                    return
                end

                MBH_CastHeal("Flash Heal", 7, 7)
                return
            elseif TankTarget("Nefarian") and HasBuffOrDebuff("Corrupted Healing", "player", "debuff") then
                if ImBusy() then
                    SpellStopCasting()
                end

                if IsSpellReady("Power Word: Shield") then
                    CastSpellOnRandomRaidMember("Weakened Soul", "rank 10", 0.9)
                end

                CastSpellOnRandomRaidMember("Renew", "rank 10", 0.95)
                return
            elseif TankTarget("Chromaggus") and ConfigState.HealSpell ~= "Flash Heal" then
                ConfigState.HealSpell = "Flash Heal"
            end
        end

        if not ImBusy() then
            if MyGroupClassOrder() == 1 then
                for rank = 5, 1, -1 do
                    if PrayerOfHealingCheck(rank, rank, 4, PrayerFocusRanks[rank] or false) then
                        return
                    end
                end
            end

            if InCombat() then
                if IsSpellReady("Power Word: Shield") then
                    ShieldAggroedPlayer()
                    CastSpellOnRandomRaidMember("Weakened Soul", "rank 10", HealingState.Priest
                        .ShieldLowRandomPercentage)
                end

                RenewAggroedPlayer()
                CastSpellOnRandomRaidMember("Renew", HealingState.Priest.RenewLowRandomRank,
                    HealingState.Priest.RenewLowRandomPercentage)
            end
        end

        if HasBuffOrDebuff("Inner Focus", "player", "buff") then
            MBH_CastHeal("Flash Heal", 6, 7)
        elseif ConfigState.HealSpell == "Greater Heal" or HasBuffOrDebuff("Hazza'rah's Charm of Healing", "player", "buff") then
            MBH_CastHeal("Greater Heal", 1, 1)
        elseif ConfigState.HealSpell == "Flash Heal" then
            MBH_CastHeal("Flash Heal")
        else
            MBH_CastHeal("Heal")
        end

        UseWand()
    end

    local function Single()
        GetTarget()
        CancelAuraSet(RemoveBuffs)

        if CastCrowdControl() then
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

        if Instance.NAXX() then
            if (TankTarget("Instructor Razuvious") and FindMyNameInTable(MB_myRazuviousPriest) and MB_myRazuviousBoxStrategy) or
                (TankTarget("Grand Widow Faerlina") and FindMyNameInTable(MB_myFaerlinaPriest) and MB_myFaerlinaBoxStrategy) then
                GetMCActions()
                return
            end
        elseif Instance.AQ40() and SKERAM_InFight() and SKERAM_BoxStrategyEnabled() then
            if SKERAM_CastCrowdControl() then
                return
            end
        end

        Fade()
        Decurse()

        if ConfigState.PlayerSpecc == "Bitch" then
            ShadowWeaving()
        elseif ConfigState.PlayerSpecc == "Shadow" then
            Shadow()
            return
        end

        HealerJindo("Smite")
        Heal()
    end

    local function LOA_Attack()
        if ImBusy() or not InCombat() then
            return
        end

        GetTarget()

        if ManaPct() < 0.11 then
            return
        end

        if IsSpellReady("Mind Blast") then
            CastOrWand("Mind Blast")
            return
        end

        if IsSpellReady("Smite") then
            CoolDownCast("Smite", 8)
        end

        AutoWandAttack()
    end

    MoronBox:RegisterExpose({
        Specc = function()
            local _, _, _, _, disciplineCap = GetTalentInfo(1, 15)
            local _, _, _, _, holyCap = GetTalentInfo(2, 10)
            local _, _, _, _, shadowCap = GetTalentInfo(3, 16)
            local _, _, _, _, shadowFocus = GetTalentInfo(3, 11)

            if (holyCap > 0 and shadowFocus > 3) or (disciplineCap > 0 and shadowFocus == 5) then
                ConfigState.PlayerSpecc = "Bitch"
            elseif shadowCap > 0 then
                ConfigState.PlayerSpecc = "Shadow"
            else
                ConfigState.PlayerSpecc = nil
            end
        end,
        Setup = function()
            if UnitMana("player") < 3060 and HasBuffNamed("Drink", "player") then
                return
            end

            ProcessFortitude()
            -- ProcessFearWard()
            -- ProcessSpirit()
            -- ProcessShadowProtection()

            SelfBuff("Inner Fire")
            SelfBuff("Shadowform")

            if not InCombat() and ManaPct() < 0.20 and not HasBuffNamed("Drink", "player") then
                SmartDrink()
            end
        end,
        Single = Single,
        Multi = Single,
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

                if FindMyNameInTable(MB_myMaexxnaPriestHealer) then
                    MaxRenewAggroedPlayer()
                    MaxShieldAggroedPlayer()
                    return
                end
            end

            Single()
        end,
        PreCast = function()
            PreCastTrinkets()
            CastSpellByName("Holy Fire")
        end,
        LoaHeal = function()
            GetTarget()
            CancelAuraSet(RemoveBuffs)
            Fade()

            if InCombat() then
                TakeManaPotionAndRunes()

                if ManaDown() > 600 then
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
