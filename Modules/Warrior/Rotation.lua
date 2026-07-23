-- [[ Warrior Rotation ]] --

local NAME = "Warrior Rotation"
local MODULE_NAME = "MODULE_" .. string.upper(string.gsub(NAME, " ", "_"))

local myName = UnitName("player")
local myClass = UnitClass("player")
local myRace = UnitRace("player")

MoronBox:RegisterModule(MODULE_NAME, function()
    local RemoveBuffs = {
        ["Arcane Intellect"]  = "Arcane Intellect",
        ["Arcane Brilliance"] = "Arcane Brilliance",
        ["Divine Spirit"]     = "Divine Spirit",
        ["Prayer of Spirit"]  = "Prayer of Spirit",
        ["Slip'kik's Savvy"]  = "Slip'kik's Savvy",
        ["Fury of Ragnaros"]  = "Fury of Ragnaros",
        ["Very Berry Cream"]  = "Very Berry Cream",
        ["Sweet Surprise"]    = "Sweet Surprise",
    }

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
        if not getSettingsState().SpeedRunEnabled then
            return
        end

        getCons().PotionsWhenPossible(potion)
    end

    -- Not used
    local function UseSpeedRunJujusWhenPossible(potion)
        if not getSettingsState().SpeedRunEnabled then
            return
        end

        getCons().JujuWhenPossible(potion)
    end

    local lastAnnihilatorTime = 0
    local EQUIP_THROTTLE = 1.5

    local function Annihilator()
        if not getSettingsState().Warrior.AnnihilatorActive or getApi().ArrayLength(getSettingsState().Warrior.AnnihilatorWeavers) == 0 then
            return
        end

        local currentTime = GetTime()
        if currentTime - lastAnnihilatorTime < EQUIP_THROTTLE then
            return
        end

        local weaverData = nil
        for _, name in pairs(getSettingsState().Warrior.AnnihilatorWeavers) do
            if myName == name then
                weaverData = name
                break
            end
        end

        if not weaverData then
            return
        end

        local mh, oh
        if Instance.IsWorldBoss() and getAura().GetArmorShatterAmount() < 3 then
            mh, oh = getGear().GetWeaverWeapon(weaverData, "BMH"), getGear().GetWeaverWeapon(weaverData, "BOH")
        else
            mh, oh = getGear().GetWeaverWeapon(weaverData, "NMH"), getGear().GetWeaverWeapon(weaverData, "NOH")
        end

        local function performSwap(slot, targetName)
            if not targetName then return end
            local currentName = getBag().GetItemNameOfEquippedSlot(slot)
            if currentName ~= targetName then
                RunLine("/equip " .. string.gsub(targetName, ",", "%%,"))
            end
        end

        performSwap(16, mh)
        performSwap(17, oh)

        lastAnnihilatorTime = currentTime
    end

    local function DPSInfo()
        local btCD = getSpells().SpellCooldown("Bloodthirst")
        local wwCD = getSpells().SpellCooldown("Whirlwind")
        local gcdThreshold = 1.35
        local canUseHam = (btCD > gcdThreshold) and (wwCD > gcdThreshold)
        return btCD, wwCD, canUseHam
    end

    local function CanUseCooldowns()
        if not getUnit().InCombat() or getSpells().ImBusy() then
            return false
        end

        return getUnit().InMeleeRange() or getRaid().TankTarget("Ragnaros")
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
        if getTables().MobsNoSunders() then
            return
        end

        if not UnitInRaid("player") or GetNumRaidMembers() <= 5 then
            return
        end

        if getAura().HasBuffOrDebuff("Expose Armor", "target", "debuff") or getAura().GetSunderAmount() >= 5 then
            return
        end

        if myRage >= 15 then
            CastSpellByName("Sunder Armor")
        end
    end

    local markOfTheChampion = "Mark of the Champion"
    local sealOfTheDawn = "Seal of the Dawn"

    local function Execute(myRage)
        if getUnit().HealthPct("target") >= 0.20 then
            return
        end

        local base, pos, neg = UnitAttackPower("player")
        local apTotal = base + pos + neg

        local slot13 = getBag().GetItemNameOfEquippedSlot(13)
        local slot14 = getBag().GetItemNameOfEquippedSlot(14)

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
        elseif getSpells().IsSpellReady("Bloodthirst") and myRage >= 30 and btDamage > impExeValue then
            CastSpellByName("Bloodthirst")
        end
    end

    local function DPSCooldowns(myRage)
        if not CanUseCooldowns() then
            return
        end

        if getSpells().IsSpellReady("Death Wish") and myRage >= 10 then
            getSpells().SelfBuff("Death Wish")
        end

        if Instance.MC() and getRaid().TankTarget("Baron Geddon") then
            UseSpeedRunPotsWhenPossible("Frozen Rune")
        end

        if getAura().HasBuffOrDebuff("Death Wish", "player", "debuff") then
            local raceSpell = myRace == "Orc" and "Blood Fury" or "Berserking"
            getSpells().SelfBuff(raceSpell)
            UseSpeedRunPotsWhenPossible("Mighty Rage Potion")
        end

        getBag().MeleeTrinkets()
    end

    local function BigDPSCooldowns(myRage)
        if not CanUseCooldowns() then
            return
        end

        getSpells().SelfBuff("Recklessness")
        DPSCooldowns(myRage)
    end

    local function UseDPSCooldowns(myRage)
        if not CanUseCooldowns() then
            return
        end

        if getSpells().IsSpellReady("Recklessness") and getTables().BossesIShouldUseRecklessnessOn() then
            BigDPSCooldowns(myRage)
        end

        if UnitInRaid("player") and GetNumRaidMembers() > 5 then
            local hpThreshold = (GetNumRaidMembers() <= 20) and 25000 or 100000

            if getAura().GetSunderAmount() == 5 or getAura().HasBuffOrDebuff("Expose Armor", "target", "debuff") then
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
        local btSpellCD, _, canUseHam = DPSInfo()

        if getUnit().InMeleeRange() then
            if getSpells().IsSpellReady("Bloodthirst") and myRage >= 30 then
                CastSpellByName("Bloodthirst")
            end

            if getSpells().IsSpellReady("Whirlwind") and myRage >= 25 then
                if btSpellCD > 0.33 and not getTables().IsExcludedWW() then
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
        if not getUnit().WarriorIsBerserker() then
            getUnit().WarriorSetBerserker()
            return
        end

        if not UnitName("target") then
            return
        end

        getAttack().AutoAttack()
        Annihilator()

        if getSpells().IsSpellReady("Bloodrage") and myRage < 20 then
            CastSpellByName("Bloodrage")
        end

        if getConfigState().DoInterrupt.Active and getSpells().IsSpellReady(getConfigState().InterruptSpell[myClass]) then
            if myRage >= 10 then
                if getSpells().ImBusy() then
                    SpellStopCasting()
                end

                CastSpellByName(getConfigState().InterruptSpell[myClass])
                getApi().CdPrint("Interrupting!")
                getConfigState().DoInterrupt.Active = false
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
        local btSpellCD, _, canUseHam = DPSInfo()

        if getTables().IsExcludedWW() then
            DPSSingleRotation(myRage)
            return
        end

        if getUnit().InMeleeRange() and getSpells().IsSpellReady("Whirlwind") and myRage >= 25 then
            CastSpellByName("Whirlwind")
        end

        if Faction.IsHorde() and canUseHam and myRage >= 89 then
            CastSpellByName("Hamstring")
        end

        if myRage >= 25 then
            CastSpellByName("Cleave")
        end

        if getUnit().InMeleeRange() and getSpells().IsSpellReady("Bloodthirst") and myRage >= 30 then
            if btSpellCD > 0.33 then
                CastSpellByName("Bloodthirst")
            end
        end
    end

    local function DPSMulti(myRage)
        if not getUnit().WarriorIsBerserker() then
            getUnit().WarriorSetBerserker()
            return
        end

        if not UnitName("target") then
            return
        end

        getAttack().AutoAttack()
        Annihilator()

        if getSpells().IsSpellReady("Bloodrage") and myRage < 20 then
            CastSpellByName("Bloodrage")
        end

        if getConfigState().DoInterrupt.Active and getSpells().IsSpellReady(getConfigState().InterruptSpell[myClass]) then
            if myRage >= 10 then
                if getSpells().ImBusy() then
                    SpellStopCasting()
                end

                CastSpellByName(getConfigState().InterruptSpell[myClass])
                getApi().CdPrint("Interrupting!")
                getConfigState().DoInterrupt.Active = false
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

        if Instance.MC() and getRaid().TankTarget("Magmadar") then
            return
        end

        if getSpells().IsSpellReady("Taunt") then
            getUnit().WarriorSetDefensive()
            CastSpellByName("Taunt")
            return
        end

        if getRaid().ImFocus() then
            return
        end

        if getConfigState().PlayerSpecc ~= "Prottank" then
            return
        end

        if getSpells().IsSpellReady("Mocking Blow") and myRage >= 10 then
            if getUnit().WarriorIsBattle() then
                CastSpellByName("Mocking Blow")
            else
                getUnit().WarriorSetBattle()
            end
        end
    end

    local function Disarm(myRage)
        local tName = UnitName("target")
        local tHealthPct = getUnit().HealthPct("target")

        if not getSpells().IsSpellReady("Disarm") then
            return
        end

        if getAura().HasBuffOrDebuff("Disarm", "target", "debuff") then
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

        if getRaid().ImFocus() and not ImpDemo() then
            return
        end

        if not getAura().HasBuffOrDebuff("Demoralizing Shout", "target", "debuff") and myRage >= 20 then
            CastSpellByName("Demoralizing Shout")
        end
    end

    local function BigTANKCooldowns()
        if HasShield() then
            getSpells().SelfBuff("Shield Wall")
        end

        getSpells().SelfBuff("Last Stand")
    end

    local function TANKSurvival()
        if not CanUseCooldowns() then
            return
        end

        local playerHP = getUnit().HealthPct()
        local targetHP = getUnit().HealthPct("target")

        if Instance.NAXX() then
            if LOA_IsAtLoatheb() and MB_myLoathebBoxStrategy then
                if targetHP <= 0.08 then
                    BigTANKCooldowns()
                elseif targetHP <= 0.12 then
                    getSpells().SelfBuff("Last Stand")
                end
                getCons().JujuWhenPossible("Juju Escape")
            elseif getRaid().TankTarget("Patchwerk") and getEncountersState().Patchwerk.Active then
                if targetHP <= 0.05 then BigTANKCooldowns() end
                getCons().JujuWhenPossible("Juju Escape")
                getCons().PotionsWhenPossible("Greater Stoneshield Potion")
            end
        elseif Instance.BWL() then
            if getRaid().TankTarget("Vaelastrasz the Corrupt") and getAura().HasBuffOrDebuff("Burning Adrenaline", "player", "debuff") then
                BigTANKCooldowns()
            elseif getRaid().TankTarget("Firemaw") then
                if targetHP <= 0.15 and playerHP <= 0.3 then BigTANKCooldowns() end
                getCons().JujuWhenPossible("Juju Ember")
            elseif getRaid().TankTarget("Chromaggus") and targetHP <= 0.07 and playerHP <= 0.3 then
                BigTANKCooldowns()
            end
        elseif Instance.AQ40() and getRaid().TankTarget("Princess Huhuran") and getEncountersState().Huhuran.Active then
            if targetHP <= getEncountersState().Huhuran.TankDefensivePercentage then BigTANKCooldowns() end
        elseif Instance.AQ20() and getRaid().TankTarget("Ossirian the Unscarred") and getEncountersState().Ossirian.Active then
            if targetHP <= getEncountersState().Ossirian.TankDefensivePercentage and playerHP <= 0.3 then
                BigTANKCooldowns()
            end
        elseif playerHP <= 0.2 then
            getSpells().SelfBuff("Last Stand")
        end

        if playerHP <= 0.25 then
            if not getBag().TrinketOnCD(13) and getBag().GetItemNameOfEquippedSlot(13) == "Lifegiving Gem" then
                use(13)
            elseif not getBag().TrinketOnCD(14) and getBag().GetItemNameOfEquippedSlot(14) == "Lifegiving Gem" then
                use(14)
            end
        end
    end

    local function TANKCooldowns(myRage)
        if not CanUseCooldowns() then
            return
        end

        if getSpells().IsSpellReady("Death Wish") and myRage >= 10 and getSettingsState().SpeedRunEnabled then
            getSpells().SelfBuff("Death Wish")
        end

        if Instance.MC() and getRaid().TankTarget("Baron Geddon") then
            UseSpeedRunPotsWhenPossible("Frozen Rune")
        end

        if getAura().HasBuffOrDebuff("Death Wish", "player", "debuff") then
            getSpells().SelfBuff("Berserking")
            UseSpeedRunPotsWhenPossible("Greater Stoneshield Potion")
        end

        getBag().MeleeTrinkets()
    end

    local function UseTANKCooldowns(myRage)
        if not CanUseCooldowns() then
            return
        end

        if UnitInRaid("player") and GetNumRaidMembers() > 5 then
            local hpThreshold = (GetNumRaidMembers() <= 20) and 25000 or 100000

            if getAura().GetSunderAmount() == 5 or getAura().HasBuffOrDebuff("Expose Armor", "target", "debuff") then
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
        local sRage = getRaid().ImFocus() and 54 or 46

        if getUnit().InMeleeRange() then
            if getSpells().IsSpellReady("Revenge") and myRage >= 5 then
                CastSpellByName("Revenge")
            end

            if getSpells().IsSpellReady("Concussion Blow") and getTables().getTables().StunnableMob() and myRage >= 15 then
                CastSpellByName("Concussion Blow")
            end

            if getUnit().HealthPct() < 0.7 and HasShield() and myRage >= 20 then
                CastSpellByName("Shield Block")
            end

            if getConfigState().PlayerSpecc == "Prottank" then
                if getSpells().IsSpellReady("Shield Slam") and myRage >= 20 and HasShield() then
                    CastSpellByName("Shield Slam")
                end
            elseif getConfigState().PlayerSpecc == "Furytank" then
                if getSpells().IsSpellReady("Bloodthirst") and myRage >= 30 then
                    CastSpellByName("Bloodthirst")
                end
            end

            Disarm(myRage)
            DemoShout(myRage)
        end

        if getAura().HasBuffOrDebuff("Expose Armor", "target", "debuff") then
            if not getSpells().IsSpellReady("Bloodthirst") and myRage >= 24 then
                CastSpellByName("Heroic Strike")
            elseif myRage >= 42 then
                CastSpellByName("Heroic Strike")
            end
        else
            if tName ~= "Deathknight Understudy" and myRage >= sRage and getAura().GetSunderAmount() == 5 then
                CastSpellByName("Sunder Armor")
            elseif myRage >= 42 then
                CastSpellByName("Heroic Strike")
            end
        end
    end

    local function TankSingle(myRage)
        if getApi().FindInTable(getCoreState().RaidTanks, myName) then
            if getAura().HasBuffOrDebuff("Greater Blessing of Salvation", "player", "buff") then
                CancelBuff("Greater Blessing of Salvation")
            elseif getAura().HasBuffOrDebuff("Dampen Magic", "player", "buff") then
                CancelBuff("Dampen Magic")
            end
        end

        TANKSurvival()
        getRaid().OffTank()

        if UnitName("target") and getUnit().CrowdControlledMob() and myName ~= getConfigState().RaidLeader then
            ClearTarget()
            return
        end

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

        if not getUnit().WarriorIsDefensive() then
            getUnit().WarriorSetDefensive()
            return
        end

        getAttack().AutoAttack()

        if getSpells().IsSpellReady("Bloodrage") and myRage < 15 then
            CastSpellByName("Bloodrage")
        end

        if getConfigState().DoInterrupt.Active and getSpells().IsSpellReady("Shield Bash") and HasShield() then
            if myRage >= 10 then
                if getSpells().ImBusy() then
                    SpellStopCasting()
                end

                CastSpellByName("Shield Bash")
                getApi().CdPrint("Interrupting!")
                getConfigState().DoInterrupt.Active = false
            end
        end

        BattleShout(myRage)
        UseTANKCooldowns(myRage)
        TANKSingleRotation(myRage)
    end

    local function TANKMultiRotation(myRage)
        local tName = UnitName("target")
        local sRage = getRaid().ImFocus() and 54 or 46

        if getUnit().InMeleeRange() then
            if getSpells().IsSpellReady("Revenge") and myRage >= 5 then
                CastSpellByName("Revenge")
            end

            if getSpells().IsSpellReady("Concussion Blow") and getTables().getTables().StunnableMob() and myRage >= 15 then
                CastSpellByName("Concussion Blow")
            end

            if getUnit().HealthPct() < 0.7 and HasShield() and myRage >= 20 then
                CastSpellByName("Shield Block")
            end

            if getConfigState().PlayerSpecc == "Prottank" then
                if getSpells().IsSpellReady("Shield Slam") and myRage >= 20 and HasShield() then
                    CastSpellByName("Shield Slam")
                end
            elseif getConfigState().PlayerSpecc == "Furytank" then
                if getSpells().IsSpellReady("Bloodthirst") and myRage >= 30 then
                    CastSpellByName("Bloodthirst")
                end
            end

            Disarm(myRage)
            DemoShout(myRage)
        end

        if getAura().HasBuffOrDebuff("Expose Armor", "target", "debuff") then
            if not getSpells().IsSpellReady("Bloodthirst") and myRage >= 28 then
                CastSpellByName("Cleave")
            elseif myRage >= 45 then
                CastSpellByName("Cleave")
            end
        else
            if tName ~= "Deathknight Understudy" and myRage >= sRage and getAura().GetSunderAmount() == 5 then
                CastSpellByName("Sunder Armor")
            elseif myRage >= 25 then
                CastSpellByName("Cleave")
            end
        end
    end

    local function TankMulti(myRage)
        if getApi().FindInTable(getCoreState().RaidTanks, myName) then
            if getAura().HasBuffOrDebuff("Greater Blessing of Salvation", "player", "buff") then
                CancelBuff("Greater Blessing of Salvation")
            elseif getAura().HasBuffOrDebuff("Dampen Magic", "player", "buff") then
                CancelBuff("Dampen Magic")
            end
        end

        TANKSurvival()
        getRaid().OffTank()

        if UnitName("target") and getUnit().CrowdControlledMob() and myName ~= getConfigState().RaidLeader then
            ClearTarget()
            return
        end

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

        if not getUnit().WarriorIsDefensive() then
            getUnit().WarriorSetDefensive()
            return
        end

        getAttack().AutoAttack()

        if getSpells().IsSpellReady("Bloodrage") and myRage < 15 then
            CastSpellByName("Bloodrage")
        end

        if getConfigState().DoInterrupt.Active and getSpells().IsSpellReady("Shield Bash") and HasShield() then
            if myRage >= 10 then
                if getSpells().ImBusy() then
                    SpellStopCasting()
                end

                CastSpellByName("Shield Bash")
                getApi().CdPrint("Interrupting!")
                getConfigState().DoInterrupt.Active = false
            end
        end

        BattleShout(myRage)
        UseTANKCooldowns(myRage)

        if Instance.NAXX() and getRaid().IsAtNoth() then
            TANKSingleRotation(myRage)
            return
        elseif Instance.BWL() and getRaid().TankTarget("Vaelastrasz the Corrupt") and getEncountersState().Vaelastrasz.Active then
            TANKSingleRotation(myRage)
            return
        elseif Instance.ONY() and getRaid().TankTarget("Onyxia") and getEncountersState().Onyxia.Active then
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
                getConfigState().PlayerSpecc = "Furytank"
            elseif fury > 0 then
                getConfigState().PlayerSpecc = "BT"
            elseif deepProt > 0 then
                getConfigState().PlayerSpecc = "Prottank"
            else
                getConfigState().PlayerSpecc = nil
            end
        end,
        Single = function()
            local myRage = UnitMana("player")

            getAura().CancelAuraSet(RemoveBuffs)
            getRaid().GetTarget()

            if getConfigState().WarriorBinds == "Fury" and not getUnit().InCombat() then
                if getApi().FindMyNameInTable(getSettingsState().FurysThatCanTank) then
                    getGear().FuryGear()
                    getConfigState().WarriorBinds = nil
                end
            end

            if not getUnit().InCombat("target") then
                return
            end

            if getUnit().InMeleeRange() then
                if Instance.AQ40() then
                    getCons().NaturePotsOnHuhuran()
                end

                if getTables().MobsToAutoBreakFear() then
                    if getSpells().IsSpellReady("Death Wish") and myRage >= 10 then
                        getSpells().SelfBuff("Death Wish")
                    end
                end
            end

            if (getConfigState().PlayerSpecc == "Prottank" or getConfigState().PlayerSpecc == "Furytank") then
                if getConfigState().UseCooldowns.Active then
                    TANKCooldowns(myRage)
                end

                if Instance.AQ40() then
                    getRaid().AnubisathAlert()
                end

                TankSingle(myRage)
                return
            end

            if getConfigState().UseBigCooldowns.Active then
                BigDPSCooldowns(myRage)
            elseif getConfigState().UseCooldowns.Active then
                DPSCooldowns(myRage)
            end

            DPSSingle(myRage)
        end,
        Multi = function()
            local myRage = UnitMana("player")

            getRaid().GetTarget()
            getAura().CancelAuraSet(RemoveBuffs)

            if getConfigState().WarriorBinds == "Fury" and not getUnit().InCombat() then
                if getApi().FindMyNameInTable(getSettingsState().FurysThatCanTank) then
                    getGear().FuryGear()
                    getConfigState().WarriorBinds = nil
                end
            end

            if not getUnit().InCombat("target") then
                return
            end

            if getUnit().InMeleeRange() then
                if Instance.AQ40() then
                    getCons().NaturePotsOnHuhuran()
                end

                if getTables().MobsToAutoBreakFear() then
                    if getSpells().IsSpellReady("Death Wish") and myRage >= 10 then
                        getSpells().SelfBuff("Death Wish")
                    end
                end
            end

            if (getConfigState().PlayerSpecc == "Prottank" or getConfigState().PlayerSpecc == "Furytank") then
                if getConfigState().UseCooldowns.Active then
                    TANKCooldowns(myRage)
                end

                if Instance.AQ40() then
                    getRaid().AnubisathAlert()
                end

                TankMulti(myRage)
                return
            end

            if getConfigState().UseBigCooldowns.Active then
                BigDPSCooldowns(myRage)
            elseif getConfigState().UseCooldowns.Active then
                DPSCooldowns(myRage)
            end

            DPSMulti(myRage)
        end,
        AOE = function()
            local myRage = UnitMana("player")

            getRaid().GetTarget()
            getAura().CancelAuraSet(RemoveBuffs)

            if getConfigState().WarriorBinds == "Fury" and not getUnit().InCombat() then
                if getApi().FindMyNameInTable(getSettingsState().FurysThatCanTank) then
                    getGear().FuryGear()
                    getConfigState().WarriorBinds = nil
                end
            end

            if not getUnit().InCombat("target") then
                return
            end

            if getUnit().InMeleeRange() then
                if Instance.AQ40() then
                    getCons().NaturePotsOnHuhuran()
                end

                if getTables().MobsToAutoBreakFear() then
                    if getSpells().IsSpellReady("Death Wish") and myRage >= 10 then
                        getSpells().SelfBuff("Death Wish")
                    end
                end
            end

            if (getConfigState().PlayerSpecc == "Prottank" or getConfigState().PlayerSpecc == "Furytank") then
                if getConfigState().UseCooldowns.Active then
                    TANKCooldowns(myRage)
                end

                if Instance.AQ40() then
                    getRaid().AnubisathAlert()
                end

                TankSingle(myRage)
                return
            end

            if getConfigState().UseBigCooldowns.Active then
                BigDPSCooldowns(myRage)
            elseif getConfigState().UseCooldowns.Active then
                DPSCooldowns(myRage)
            end

            DPSMulti(myRage)
        end
    })
end, function()
    return myClass == "Warrior"
end)
