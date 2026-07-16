-- [[ Warrior Rotation ]] --
---@diagnostic disable: undefined-global

local NAME = "Warrior Rotation"
local MODULE_NAME = "MODULE_" .. string.upper(string.gsub(NAME, " ", "_"))

local myClass = UnitClass("player")

MoronBox:RegisterModule(MODULE_NAME, function()
    local RemovedBuffs = {
        ["Arcane Intellect"]  = "Arcane Intellect",
        ["Arcane Brilliance"] = "Arcane Brilliance",
        ["Divine Spirit"]     = "Divine Spirit",
        ["Prayer of Spirit"]  = "Prayer of Spirit",
        ["Slip'kik's Savvy"]  = "Slip'kik's Savvy",
        ["Fury of Ragnaros"]  = "Fury of Ragnaros",
        ["Very Berry Cream"]  = "Very Berry Cream",
        ["Sweet Surprise"]    = "Sweet Surprise",
    }

    local function WarriorCancelAuras()
        for itemName, buffName in pairs(RemovedBuffs) do
            if HasBuffOrDebuff(itemName, "player", "buff") then
                CancelBuff(buffName)
            end
        end
    end

    local textLeft1 = getglobal(MoronBoxTooltip:GetName() .. "TextLeft1")
    local textLeft2 = getglobal(MoronBoxTooltip:GetName() .. "TextLeft2")
    local buffTexture = "Interface\\Icons\\Ability_Warrior_BattleShout"
    local buffNameLower = "battle shout"

    local function HasBattleShout()
        local unit = "player"

        for i = 1, 32 do
            local texture = UnitBuff(unit, i)
            if not texture then break end

            if texture == buffTexture then
                MoronBoxTooltip:SetOwner(UIParent, "ANCHOR_NONE")
                MoronBoxTooltip:SetUnitBuff(unit, i)

                local line1 = textLeft1:GetText()
                if line1 and strfind(strlower(line1), buffNameLower) then
                    local line2 = textLeft2 and textLeft2:GetText() or ""
                    MoronBoxTooltip:Hide() -- Hide as soon as we have the text

                    -- Only return true if it is NOT the lower rank (doesn't contain "400")
                    if not strfind(line2, "400") then
                        return true
                    end
                end
                MoronBoxTooltip:Hide()
            end
        end
        return false
    end

    local function HasShield()
        local offhandLink = GetInventoryItemLink("player", GetInventorySlotInfo("SecondaryHandSlot"))
        if not offhandLink then
            return false
        end

        local _, _, itemId = string.find(offhandLink, "|Hitem:(.-):(.-):(.-):(.-)|h%[(.-)%]|h")
        local _, _, _, _, _, itemType = GetItemInfo(itemId)
        return itemType == "Shields"
    end


    local function ImpExecute()
        local _, _, _, _, TalentsIn = GetTalentInfo(2, 10)
        return TalentsIn > 1
    end

    local function ImpDemo()
        local _, _, _, _, TalentsIn = GetTalentInfo(2, 3)
        return TalentsIn > 3
    end

    local function UseSpeedRunPotsWhenPossible(potion)
        if not SettingsState.SpeedRunEnabled then
            return
        end

        PotionsWhenPossible(potion)
    end

    local function UseSpeedRunJujusWhenPossible(potion)
        if not SettingsState.SpeedRunEnabled then
            return
        end

        JujuWhenPossible(potion)
    end

    local lastAnnihilatorTime = 0
    local EQUIP_THROTTLE = 1.5

    local function Annihilator()
        if not SettingsState.Warrior.AnnihilatorActive or TableLength(SettingsState.Warrior.AnnihilatorWeavers) == 0 then
            return
        end

        local currentTime = GetTime()
        if currentTime - lastAnnihilatorTime < EQUIP_THROTTLE then
            return
        end

        local weaverData = nil
        for _, name in pairs(SettingsState.Warrior.AnnihilatorWeavers) do
            if myName == name then
                weaverData = name
                break
            end
        end

        if not weaverData then
            return
        end

        local mh, oh
        if Instance.IsWorldBoss() and GetArmorShatterAmount() < 3 then
            mh, oh = GetWeaverWeapon(weaverData, "BMH"), GetWeaverWeapon(weaverData, "BOH")
        else
            mh, oh = GetWeaverWeapon(weaverData, "NMH"), GetWeaverWeapon(weaverData, "NOH")
        end

        local function performSwap(slot, targetName)
            if not targetName then return end
            local currentName = GetItemNameOfEquippedSlot(slot)
            if currentName ~= targetName then
                RunLine("/equip " .. string.gsub(targetName, ",", "%%,"))
            end
        end

        performSwap(16, mh)
        performSwap(17, oh)

        lastAnnihilatorTime = currentTime
    end

    local function WarriorDPSInfo()
        local btCD = SpellCooldown("Bloodthirst")
        local wwCD = SpellCooldown("Whirlwind")
        local gcdThreshold = 1.35
        local canUseHam = (btCD > gcdThreshold) and (wwCD > gcdThreshold)
        return btCD, wwCD, canUseHam
    end

    local function CanUseCooldowns()
        if not InCombat() or ImBusy() then
            return false
        end

        return InMeleeRange() or TankTarget("Ragnaros")
    end

    local function BattleShout(myRage)
        if HasBattleShout() then
            return
        end

        if myRage >= 10 then
            CastSpellByName("Battle Shout")
        end
    end

    local function Sunder(myRage)
        if MobsNoSunders() then
            return
        end

        if not UnitInRaid("player") or GetNumRaidMembers() <= 5 then
            return
        end

        if HasBuffOrDebuff("Expose Armor", "target", "debuff") or GetSunderAmount() >= 5 then
            return
        end

        if myRage >= 15 then
            CastSpellByName("Sunder Armor")
        end
    end

    local markOfTheChampion = "Mark of the Champion"
    local sealOfTheDawn = "Seal of the Dawn"

    local function Execute(myRage)
        if HealthPct("target") >= 0.20 then
            return
        end

        local base, pos, neg = UnitAttackPower("player")
        local apTotal = base + pos + neg

        local slot13 = GetItemNameOfEquippedSlot(13)
        local slot14 = GetItemNameOfEquippedSlot(14)

        local targetType = UnitCreatureType("target")
        if targetType == "Undead" or targetType == "Demon" then
            if slot13 == markOfTheChampion or slot14 == markOfTheChampion then
                apTotal = apTotal + 150
            end
            if slot13 == sealOfTheDawn or slot14 == sealOfTheDawn then
                apTotal = apTotal + 81
            end
        end

        local btDamage = apTotal * 0.45
        local isImp = ImpExecute()
        local impExeValue = isImp and 900 or 820
        local impExeCost = isImp and 10 or 15

        if myRage >= impExeCost and (impExeValue >= btDamage or myRage >= 30) then
            CastSpellByName("Execute")
        elseif IsSpellReady("Bloodthirst") and myRage >= 30 and btDamage > impExeValue then
            CastSpellByName("Bloodthirst")
        end
    end

    local function DPSCooldowns(myRage)
        if not CanUseCooldowns() then
            return
        end

        if IsSpellReady("Death Wish") and myRage >= 10 then
            SelfBuff("Death Wish")
        end

        if Instance.MC() and TankTarget("Baron Geddon") then
            UseSpeedRunPotsWhenPossible("Frozen Rune")
        end

        if HasBuffOrDebuff("Death Wish", "player", "debuff") then
            local raceSpell = myRace == "Orc" and "Blood Fury" or "Berserking"
            SelfBuff(raceSpell)
            UseSpeedRunPotsWhenPossible("Mighty Rage Potion")
        end

        MeleeTrinkets()
    end

    local function BigDPSCooldowns(myRage)
        if not CanUseCooldowns() then
            return
        end

        SelfBuff("Recklessness")
        DPSCooldowns(myRage)
    end

    function UseDPSCooldowns(myRage)
        if not CanUseCooldowns() then
            return
        end

        if IsSpellReady("Recklessness") and BossIShouldUseRecklessnessOn() then
            BigDPSCooldowns(myRage)
        end

        if UnitInRaid("player") and GetNumRaidMembers() > 5 then
            local hpThreshold = (GetNumRaidMembers() <= 20) and 25000 or 100000

            if GetSunderAmount() == 5 or HasBuffOrDebuff("Expose Armor", "target", "debuff") then
                if Instance.IsWorldBoss() then
                    DPSCooldowns(myRage)
                elseif UnitHealth("target") > hpThreshold then
                    DPSCooldowns(myRage)
                end
            end
        else
            DPSCooldowns(myRage)
        end
    end

    local function DPSSingleRotation(myRage)
        local btSpellCD, wwSpellCD, canUseHam = WarriorDPSInfo()

        if InMeleeRange() then
            if IsSpellReady("Bloodthirst") and myRage >= 30 then
                CastSpellByName("Bloodthirst")
            end

            if IsSpellReady("Whirlwind") and myRage >= 25 then
                if btSpellCD > 0.33 and not IsExcludedWW() then
                    CastSpellByName("Whirlwind")
                end
            end

            if Faction.IsHorde() and canUseHam and myRage >= 84 then
                CastSpellByName("Hamstring")
            end
        end

        if myRage >= 54 then
            CastSpellByName("Heroic Strike")
        end
    end

    local function DPSSingle(myRage)
        if not WarriorIsBerserker() then
            WarriorSetBerserker()
            return
        end

        if not UnitName("target") then
            return
        end

        AutoAttack()
        Annihilator()

        if IsSpellReady("Bloodrage") and myRage < 20 then
            CastSpellByName("Bloodrage")
        end

        if ConfigState.DoInterrupt.Active and IsSpellReady(ConfigState.InterruptSpell[myClass]) then
            if myRage >= 10 then
                if ImBusy() then
                    SpellStopCasting()
                end

                CastSpellByName(ConfigState.InterruptSpell[myClass])
                CdPrint("Interrupting!")
                ConfigState.DoInterrupt.Active = false
                return
            end
        end

        BattleShout(myRage)
        Sunder(myRage)
        UseDPSCooldowns(myRage)
        Execute(myRage)
        DPSSingleRotation(myRage)
    end

    local function DPSMultiRotation(myRage)
        local btSpellCD, _, canUseHam = WarriorDPSInfo()

        if IsExcludedWW() then
            DPSSingleRotation(myRage)
            return
        end

        if InMeleeRange() and IsSpellReady("Whirlwind") and myRage >= 25 then
            CastSpellByName("Whirlwind")
        end

        if Faction.IsHorde() and canUseHam and myRage >= 89 then
            CastSpellByName("Hamstring")
        end

        if myRage >= 25 then
            CastSpellByName("Cleave")
        end

        if InMeleeRange() and IsSpellReady("Bloodthirst") and myRage >= 30 then
            if btSpellCD > 0.33 then
                CastSpellByName("Bloodthirst")
            end
        end
    end

    local function DPSMulti(myRage)
        if not WarriorIsBerserker() then
            WarriorSetBerserker()
            return
        end

        if not UnitName("target") then
            return
        end

        AutoAttack()
        Annihilator()

        if IsSpellReady("Bloodrage") and myRage < 20 then
            CastSpellByName("Bloodrage")
        end

        if ConfigState.DoInterrupt.Active and IsSpellReady(ConfigState.InterruptSpell[myClass]) then
            if myRage >= 10 then
                if ImBusy() then
                    SpellStopCasting()
                end

                CastSpellByName(ConfigState.InterruptSpell[myClass])
                CdPrint("Interrupting!")
                ConfigState.DoInterrupt.Active = false
                return
            end
        end

        BattleShout(myRage)
        Sunder(myRage)
        UseDPSCooldowns(myRage)
        Execute(myRage)
        DPSMultiRotation(myRage)
    end

    local function Taunt()
        local myRage = UnitMana("player")

        if Instance.MC() and TankTarget("Magmadar") then
            return
        end

        if IsSpellReady("Taunt") then
            WarriorSetDefensive()
            CastSpellByName("Taunt")
            return
        end

        if ImFocus() then
            return
        end

        if ConfigState.PlayerSpecc ~= "Prottank" then
            return
        end

        if IsSpellReady("Mocking Blow") and myRage >= 10 then
            if WarriorIsBattle() then
                CastSpellByName("Mocking Blow")
            else
                WarriorSetBattle()
            end
        end
    end

    local function Disarm(myRage)
        local tName = UnitName("target")
        local tHealthPct = HealthPct("target")

        if not IsSpellReady("Disarm") then
            return
        end

        if HasBuffOrDebuff("Disarm", "target", "debuff") then
            return
        end

        if not (tName == "Gurubashi Axe Thrower"
                or (tHealthPct < 0.5 and (tName == "Infectious Ghoul" or tName == "Plagued Ghoul"))
                or (tHealthPct <= 0.21 and (tName == "Anubisath Sentinel" or tName == "Anubisath Defender"))) then
            return
        end

        if myRage >= 20 then
            CastSpellByName("Disarm")
        end
    end

    local function DemoShout(myRage)
        local tName = UnitName("target")

        if (tName == "Emperor Vek\'nilash" or tName == "Emperor Vek\'lor") then
            return
        end

        if ImFocus() and not ImpDemo() then
            return
        end

        if not HasBuffOrDebuff("Demoralizing Shout", "target", "debuff") and myRage >= 20 then
            CastSpellByName("Demoralizing Shout")
        end
    end

    local function BigTANKCooldowns()
        if HasShield() then
            SelfBuff("Shield Wall")
        end

        SelfBuff("Last Stand")
    end

    local function TANKSurvival()
        if not CanUseCooldowns() then
            return
        end

        local playerHP = HealthPct("player")
        local targetHP = HealthPct("target")

        if Instance.NAXX() then
            if LOA_IsAtLoatheb() and MB_myLoathebBoxStrategy then
                if targetHP <= 0.08 then
                    BigTANKCooldowns()
                elseif targetHP <= 0.12 then
                    SelfBuff("Last Stand")
                end
                TakeJujuWhenPossible("Juju Escape")
            elseif TankTarget("Patchwerk") and MB_myPatchwerkBoxStrategy then
                if targetHP <= 0.05 then BigTANKCooldowns() end
                TakeJujuWhenPossible("Juju Escape")
                PotionsWhenPossible("Greater Stoneshield Potion")
            end
        elseif Instance.BWL() then
            if TankTarget("Vaelastrasz the Corrupt") and HasBuffOrDebuff("Burning Adrenaline", "player", "debuff") then
                BigTANKCooldowns()
            elseif TankTarget("Firemaw") then
                if targetHP <= 0.15 and playerHP <= 0.3 then BigTANKCooldowns() end
                TakeJujuWhenPossible("Juju Ember")
            elseif TankTarget("Chromaggus") and targetHP <= 0.07 and playerHP <= 0.3 then
                BigTANKCooldowns()
            end
        elseif Instance.AQ40() and TankTarget("Princess Huhuran") and MB_myHuhuranBoxStrategy then
            if targetHP <= MB_myHuhuranTankDefensivePercentage then BigTANKCooldowns() end
        elseif Instance.AQ20() and TankTarget("Ossirian the Unscarred") and MB_myOssirianBoxStrategy then
            if targetHP <= MB_myOssirianTankDefensivePercentage and playerHP <= 0.3 then
                BigTANKCooldowns()
            end
        elseif playerHP <= 0.2 then
            SelfBuff("Last Stand")
        end

        if playerHP <= 0.25 then
            if not TrinketOnCD(13) and GetItemNameOfEquippedSlot(13) == "Lifegiving Gem" then
                use(13)
            elseif not TrinketOnCD(14) and GetItemNameOfEquippedSlot(14) == "Lifegiving Gem" then
                use(14)
            end
        end
    end

    local function TANKCooldowns(myRage)
        if not CanUseCooldowns() then
            return
        end

        if IsSpellReady("Death Wish") and myRage >= 10 and SettingsState.SpeedRunEnabled then
            SelfBuff("Death Wish")
        end

        if Instance.MC() and TankTarget("Baron Geddon") then
            UseSpeedRunPotsWhenPossible("Frozen Rune")
        end

        if HasBuffOrDebuff("Death Wish", "player", "debuff") then
            SelfBuff("Berserking")
            UseSpeedRunPotsWhenPossible("Greater Stoneshield Potion")
        end

        MeleeTrinkets()
    end

    local function UseTANKCooldowns(myRage)
        if not CanUseCooldowns() then
            return
        end

        if UnitInRaid("player") and GetNumRaidMembers() > 5 then
            local hpThreshold = (GetNumRaidMembers() <= 20) and 25000 or 100000

            if GetSunderAmount() == 5 or HasBuffOrDebuff("Expose Armor", "target", "debuff") then
                if Instance.IsWorldBoss() then
                    TANKCooldowns(myRage)
                elseif UnitHealth("target") > hpThreshold then
                    TANKCooldowns(myRage)
                end
            end
        else
            TANKCooldowns(myRage)
        end
    end

    local function TANKSingleRotation(myRage)
        local tName = UnitName("target")
        local sRage = ImFocus() and 54 or 46

        if InMeleeRange() then
            if IsSpellReady("Revenge") and myRage >= 5 then
                CastSpellByName("Revenge")
            end

            if IsSpellReady("Concussion Blow") and StunnableMob() and myRage >= 15 then
                CastSpellByName("Concussion Blow")
            end

            if HealthPct("player") < 0.7 and HasShield() and myRage >= 20 then
                CastSpellByName("Shield Block")
            end

            if ConfigState.PlayerSpecc == "Prottank" then
                if IsSpellReady("Shield Slam") and myRage >= 20 and HasShield() then
                    CastSpellByName("Shield Slam")
                end
            elseif ConfigState.PlayerSpecc == "Furytank" then
                if IsSpellReady("Bloodthirst") and myRage >= 30 then
                    CastSpellByName("Bloodthirst")
                end
            end

            Disarm(myRage)
            DemoShout(myRage)
        end

        if HasBuffOrDebuff("Expose Armor", "target", "debuff") then
            if not IsSpellReady("Bloodthirst") and myRage >= 24 then
                CastSpellByName("Heroic Strike")
            elseif myRage >= 42 then
                CastSpellByName("Heroic Strike")
            end
        else
            if tName ~= "Deathknight Understudy" and myRage >= sRage and GetSunderAmount() == 5 then
                CastSpellByName("Sunder Armor")
            elseif myRage >= 42 then
                CastSpellByName("Heroic Strike")
            end
        end
    end

    local function TankSingle(myRage)
        if FindInTable(GeneralState.RaidTanks, myName) then
            if HasBuffOrDebuff("Greater Blessing of Salvation", "player", "buff") then
                CancelBuff("Greater Blessing of Salvation")
            elseif HasBuffOrDebuff("Dampen Magic", "player", "buff") then
                CancelBuff("Dampen Magic")
            end
        end

        TANKSurvival()
        OffTank()

        if UnitName("target") and CrowdControlledMob() and not myName == ConfigState.RaidLeader then
            ClearTarget()
            return
        end

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

        if not WarriorIsDefensive() then
            WarriorSetDefensive()
            return
        end

        AutoAttack()

        if IsSpellReady("Bloodrage") and myRage < 15 then
            CastSpellByName("Bloodrage")
        end

        if ConfigState.DoInterrupt.Active and IsSpellReady("Shield Bash") and HasShield() then
            if myRage >= 10 then
                if ImBusy() then
                    SpellStopCasting()
                end

                CastSpellByName("Shield Bash")
                CdPrint("Interrupting!")
                ConfigState.DoInterrupt.Active = false
            end
        end

        BattleShout(myRage)
        UseTANKCooldowns(myRage)
        TANKSingleRotation(myRage)
    end

    local function TANKMultiRotation(myRage)
        local tName = UnitName("target")
        local sRage = ImFocus() and 54 or 46

        if InMeleeRange() then
            if IsSpellReady("Revenge") and myRage >= 5 then
                CastSpellByName("Revenge")
            end

            if IsSpellReady("Concussion Blow") and StunnableMob() and myRage >= 15 then
                CastSpellByName("Concussion Blow")
            end

            if HealthPct("player") < 0.7 and HasShield() and myRage >= 20 then
                CastSpellByName("Shield Block")
            end

            if ConfigState.PlayerSpecc == "Prottank" then
                if IsSpellReady("Shield Slam") and myRage >= 20 and HasShield() then
                    CastSpellByName("Shield Slam")
                end
            elseif ConfigState.PlayerSpecc == "Furytank" then
                if IsSpellReady("Bloodthirst") and myRage >= 30 then
                    CastSpellByName("Bloodthirst")
                end
            end

            Disarm(myRage)
            DemoShout(myRage)
        end

        if HasBuffOrDebuff("Expose Armor", "target", "debuff") then
            if not IsSpellReady("Bloodthirst") and myRage >= 28 then
                CastSpellByName("Cleave")
            elseif myRage >= 45 then
                CastSpellByName("Cleave")
            end
        else
            if tName ~= "Deathknight Understudy" and myRage >= sRage and GetSunderAmount() == 5 then
                CastSpellByName("Sunder Armor")
            elseif myRage >= 25 then
                CastSpellByName("Cleave")
            end
        end
    end

    local function TankMulti(myRage)
        if FindInTable(GeneralState.RaidTanks, myName) then
            if HasBuffOrDebuff("Greater Blessing of Salvation", "player", "buff") then
                CancelBuff("Greater Blessing of Salvation")
            elseif HasBuffOrDebuff("Dampen Magic", "player", "buff") then
                CancelBuff("Dampen Magic")
            end
        end

        TANKSurvival()
        OffTank()

        if UnitName("target") and CrowdControlledMob() and not myName == ConfigState.RaidLeader then
            ClearTarget()
            return
        end

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

        if not WarriorIsDefensive() then
            WarriorSetDefensive()
            return
        end

        AutoAttack()

        if IsSpellReady("Bloodrage") and myRage < 15 then
            CastSpellByName("Bloodrage")
        end

        if ConfigState.DoInterrupt.Active and IsSpellReady("Shield Bash") and HasShield() then
            if myRage >= 10 then
                if ImBusy() then
                    SpellStopCasting()
                end

                CastSpellByName("Shield Bash")
                CdPrint("Interrupting!")
                ConfigState.DoInterrupt.Active = false
            end
        end

        BattleShout(myRage)
        UseTANKCooldowns(myRage)

        if Instance.NAXX() and IsAtNoth() then
            TANKSingleRotation(myRage)
            return
        elseif Instance.BWL() and TankTarget("Vaelastrasz the Corrupt") and MB_myVaelastraszBoxStrategy then
            TANKSingleRotation(myRage)
            return
        elseif Instance.ONY() and TankTarget("Onyxia") and MB_myOnyxiaBoxStrategy then
            TANKSingleRotation(myRage)
            return
        end

        TANKMultiRotation(myRage)
    end

    MoronBox:RegisterExpose({
        Specc = function()
            local _, _, _, _, fury = GetTalentInfo(2, 17)
            local _, _, _, _, prot = GetTalentInfo(3, 9)
            local _, _, _, _, deepProt = GetTalentInfo(3, 17)

            if fury > 0 and prot > 4 then
                ConfigState.PlayerSpecc = "Furytank"
            elseif fury > 0 then
                ConfigState.PlayerSpecc = "BT"
            elseif deepProt > 0 then
                ConfigState.PlayerSpecc = "Prottank"
            else
                ConfigState.PlayerSpecc = nil
            end
        end,
        Single = function()
            local myRage = UnitMana("player")

            GetTarget()
            WarriorCancelAuras()

            if ConfigState.WarriorBinds == "Fury" and not InCombat() then
                if FindMyNameInTable(SettingsState.FurysThatCanTank) then
                    FuryGear()
                    ConfigState.WarriorBinds = nil
                end
            end

            if not InCombat("target") then
                return
            end

            if InMeleeRange() then
                if Instance.AQ40() then
                    NaturePotsOnHuhuran()
                end

                if MobsToAutoBreakFear() then
                    if IsSpellReady("Death Wish") and myRage >= 10 then
                        SelfBuff("Death Wish")
                    end
                end
            end

            if (ConfigState.PlayerSpecc == "Prottank" or ConfigState.PlayerSpecc == "Furytank") then
                if ConfigState.UseCooldowns.Active then
                    TANKCooldowns(myRage)
                end

                if Instance.AQ40() then
                    AnubisathAlert()
                end

                TankSingle(myRage)
                return
            end

            if ConfigState.UseBigCooldowns.Active then
                BigDPSCooldowns(myRage)
            elseif ConfigState.UseCooldowns.Active then
                DPSCooldowns(myRage)
            end

            DPSSingle(myRage)
        end,
        Multi = function()
            local myRage = UnitMana("player")

            GetTarget()
            WarriorCancelAuras()

            if ConfigState.WarriorBinds == "Fury" and not InCombat() then
                if FindMyNameInTable(SettingsState.FurysThatCanTank) then
                    FuryGear()
                    ConfigState.WarriorBinds = nil
                end
            end

            if not InCombat("target") then
                return
            end

            if InMeleeRange() then
                if Instance.AQ40() then
                    NaturePotsOnHuhuran()
                end

                if MobsToAutoBreakFear() then
                    if IsSpellReady("Death Wish") and myRage >= 10 then
                        SelfBuff("Death Wish")
                    end
                end
            end

            if (ConfigState.PlayerSpecc == "Prottank" or ConfigState.PlayerSpecc == "Furytank") then
                if ConfigState.UseCooldowns.Active then
                    TANKCooldowns(myRage)
                end

                if Instance.AQ40() then
                    AnubisathAlert()
                end

                TankMulti(myRage)
                return
            end

            if ConfigState.UseBigCooldowns.Active then
                BigDPSCooldowns(myRage)
            elseif ConfigState.UseCooldowns.Active then
                DPSCooldowns(myRage)
            end

            DPSMulti(myRage)
        end,
        AOE = function()
            local myRage = UnitMana("player")

            GetTarget()
            WarriorCancelAuras()

            if ConfigState.WarriorBinds == "Fury" and not InCombat() then
                if FindMyNameInTable(SettingsState.FurysThatCanTank) then
                    FuryGear()
                    ConfigState.WarriorBinds = nil
                end
            end

            if not InCombat("target") then
                return
            end

            if InMeleeRange() then
                if Instance.AQ40() then
                    NaturePotsOnHuhuran()
                end

                if MobsToAutoBreakFear() then
                    if IsSpellReady("Death Wish") and myRage >= 10 then
                        SelfBuff("Death Wish")
                    end
                end
            end

            if (ConfigState.PlayerSpecc == "Prottank" or ConfigState.PlayerSpecc == "Furytank") then
                if ConfigState.UseCooldowns.Active then
                    TANKCooldowns(myRage)
                end

                if Instance.AQ40() then
                    AnubisathAlert()
                end

                TankSingle(myRage)
                return
            end

            if ConfigState.UseBigCooldowns.Active then
                BigDPSCooldowns(myRage)
            elseif ConfigState.UseCooldowns.Active then
                DPSCooldowns(myRage)
            end

            DPSMulti(myRage)
        end
    })
end, function()
    return myClass == "Warrior"
end)
