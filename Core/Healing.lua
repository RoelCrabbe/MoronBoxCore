-- [[ Config & Constants ]] --

MoronBox.Core.Healing              = MoronBox.Core.Healing or {}

MoronBox.Core.Healing.HealingState = {
    MainTankOverhealingPercentage = 0.89, --> 11% overheal

    Priest                        = {
        InnerFocusPercentage          = 0.3,
        RenewLowRandomPercentage      = 0.66,
        RenewLowRandomRank            = "Rank 4",
        RenewAggroedPlayerPercentage  = 0.90,
        RenewAggroedPlayerRank        = "Rank 7",
        ShieldLowRandomPercentage     = 0.33,
        ShieldAggroedPlayerPercentage = 0.25,
        -- Main Tank Healing
        MainTankHealingRank           = "Rank 1",
        MainTankHealingBossList       = {
            -- Default bosses
            "Ossirian the Unscarred",
            "Patchwerk",

            -- Extra bosses
            -- Naxx
            "Gluth",
        },
        -- Lists
        FlashHealerList               = {
            "Draub",
            "Ayag",
            "Midavellir",
            "Murdrum",

            -- SpeedRunners
            "Liket",
            "Blaidzy",
            "Cyal",
            "Bonita"
        }
    },
    Druid                         = {
        -- Values
        RejuvenationLowRandomMovingPercentage    = 0.75,
        RejuvenationLowRandomMovingRank          = "Rank 3",
        RejuvenationLowRandomPercentage          = 0.45,
        RejuvenationLowRandomRank                = "Rank 5",
        RejuvenationAggroedPlayerPercentage      = 0.9,
        RejuvenationAggroedPlayerRank            = "Rank 9",
        SwiftmendRejuvenationLowRandomPercentage = 0.7,
        SwiftmendRejuvenationLowRandomRank       = "Rank 6",
        SwiftmendAtPercentage                    = 0.7,
        SwiftmendRegrowthLowRandomPercentage     = 0.2,
        SwiftmendRegrowthAggroedPlayerPercentage = 0.75,
        SwiftmendRegrowthAggroedPlayerRank       = "Rank 4",
        -- Main Tank Healing
        MainTankHealingRank                      = "Rank 7",
        MainTankHealingBossList                  = {
            -- Default bosses
            "Ossirian the Unscarred",
            "Patchwerk",

            -- Extra bosses
            -- MC
            "Magmadar",
            "Ragnaros",

            -- Naxx
            "Maexxna",
            "Gluth",
            "Heigan the Unclean",
            "Grobbulus",

            -- AQ40
            "Princess Huhuran",
            "Fankriss the Unyielding",

            -- BWL
            "Chromaggus",
            "Firemaw"
        },
        -- Lists
        InnervateHealerList                      = {
            "Draub",
            "Ayag",
            "Midavellir",
            "Murdrum",

            -- SpeedRunners
            "Liket",
            "Blaidzy",
            "Cyal",
            "Bonita",
            "Drogles"
        }
    },
    Paladin                       = {
        DivineFavorPercentage   = 0.8,
        -- Main Tank Healing
        MainTankHealingRank     = "Rank 6",
        MainTankHealingBossList = {
            -- Default bosses
            "Ossirian the Unscarred",
            "Patchwerk",

            -- Extra bosses
            -- Naxx
            "Maexxna",
            "Gluth",
        }
    },
    Shaman                        = {
        -- Main Tank Healing
        MainTankHealingRank     = "Rank 7",
        MainTankHealingBossList = {
            -- Default bosses
            "Ossirian the Unscarred",
            "Patchwerk",

            -- Extra bosses
            -- Raidheal other bosses
        }
    },
    InstructorRazuviousAddHealer  = {
        -- Horde
        "Mvenna",      -- 8T1 Shammy
        "Azøg",        -- 8T1 Shammy
        "Chimando",    -- 8T1 Shammy
        --"Purges", -- 8T1 Shammy
        "Superkoe",    -- 8T1 Shammy
        "Bogeycrap",   -- 8T1 Shammy

        "Laitelaismo", -- 8T3 Shammy
        "Shamuk",      -- 8T3 Shammy

        "Corinn",      -- 8T2 Priest
        "Healdealz",   -- 8T2 Priest
        "Draub",       -- 8T2 Priest
        "Ayag",        -- T3 Priest

        "Smalheal",    -- Druid
        "Drushgor",    -- Druid

        -- Alliance
        "Bubblebumm",   -- Pala never oom
        "Breachedhull", -- Pala never oom
        "Candylane",    -- Pala never oom
        "Fatnun",       -- Pala never oom

        "Murdrum",      -- 8T3 Priest
        "Wiccana",      -- 8T2 Priest
        "Nouveele",     -- 8T2 Priest
        "Hms",          -- 8T2 Priest

        "Jahetsu",      -- Druid
        "Kusch"         -- Druid
    }
}

local myClass                      = UnitClass("player")

function getHealing()
    return MoronBox.Core.Healing
end

function getHealingState()
    return MoronBox.Core.Healing.HealingState
end

-- [[ Healing Local Functions ]] --

local function GetHealBonus()
    local value = MBx.ACE.ItemBonus:GetBonus("HEAL")
    return value
end

local function ExtractRank(str)
    local num = ""
    local foundDigit = false
    for i = 1, string.len(str) do
        local char = string.sub(str, i, i)
        if tonumber(char) then
            num = num .. char
            foundDigit = true
        elseif foundDigit then
            break
        end
    end
    return tonumber(num)
end

function MoronBox.Core.Healing.GetHealValueFromRank(spell, rank)
    return floor(MBx.ACE.HealComm.Spells[spell][ExtractRank(rank)](GetHealBonus()))
end

local function GetAverageChainHealValueFromRank(spell, rank, amountOfBounce, multiplier)
    local mult = multiplier and (1 + multiplier / 100) or 1
    local baseHeal = MBx.ACE.HealComm.Spells[spell][ExtractRank(rank)](GetHealBonus())
    local lowestHeal = baseHeal / (2 ^ amountOfBounce)
    return floor(lowestHeal * mult)
end

-- [[ Healing ]] --

function MoronBox.Core.Healing.GetHealSpell()
    if myClass == "Shaman" then
        if getGear().EquippedSetCount("Earthfury") == 8 then
            getConfigState().HealSpell = "Healing Wave"
            return true
        elseif getGear().EquippedSetCount("The Ten Storms") >= 3 and getGear().EquippedSetCount("Stormcaller\'s Garb") == 5 then
            getConfigState().HealSpell = "Chain Heal"
            return true
        else
            if MB_raidAssist.Shaman.DefaultToHealingWave then
                getConfigState().HealSpell = "Healing Wave"
                return true
            else
                getConfigState().HealSpell = "Chain Heal"
            end
        end
    elseif myClass == "Priest" then
        if getApi().FindMyNameInTable(getHealingState().Priest.FlashHealerList) then
            getConfigState().HealSpell = "Flash Heal"
            return true
        elseif getGear().EquippedSetCount("Vestments of Transcendence") == 8 then
            getConfigState().HealSpell = "Greater Heal"
            return true
        else
            getConfigState().HealSpell = "Heal"
            return true
        end
    elseif myClass == "Druid" and getGear().EquippedSetCount("Dreamwalker Raiment") >= 2 then
        getConfigState().HealSpell = "Rejuvenation"
        return true
    end
end

function MoronBox.Core.Healing.NatureSwiftnessLowAggroedPlayer()
    if not UnitInRaid("player") then
        return false
    end

    if not getUnit().InCombat() then
        return false
    end

    if (getSpells().IsSpellReady("Nature\'s Swiftness") or getAura().HasBuffOrDebuff("Nature\'s Swiftness", "player", "buff")) then
        local blastNSatThisPercentage = 0.2
        local instantSpell = "Healing Touch"

        if getCore().MyClassOrder() == 1 then
            blastNSatThisPercentage = 0.35
        elseif getCore().MyClassOrder() == 2 then
            blastNSatThisPercentage = 0.30
        elseif getCore().MyClassOrder() == 3 then
            blastNSatThisPercentage = 0.25
        elseif getCore().MyClassOrder() == 4 then
            blastNSatThisPercentage = 0.20
        elseif getCore().MyClassOrder() >= 5 then
            blastNSatThisPercentage = 0.15
        end

        if myClass == "Shaman" then
            instantSpell = "Healing Wave"
        end

        local aggrox = AceLibrary("Banzai-1.0")
        for i = 1, GetNumRaidMembers() do
            local NSTarget = "raid" .. i

            if NSTarget and aggrox:GetUnitAggroByUnitId(NSTarget) then
                if getUnit().IsValidFriendlyTarget(NSTarget, instantSpell)
                    and getUnit().HealthPct(NSTarget) <= blastNSatThisPercentage
                    and not getAura().HasBuffOrDebuff("Feign Death", NSTarget, "buff") then
                    if UnitIsFriend("player", NSTarget) then
                        ClearTarget()
                    end

                    if not getAura().HasBuffOrDebuff("Nature\'s Swiftness", "player", "buff") then
                        SpellStopCasting()
                    end

                    getSpells().SelfBuff("Nature\'s Swiftness")

                    if getAura().HasBuffOrDebuff("Nature\'s Swiftness", "player", "buff") then
                        CastSpellByName(instantSpell, nil)
                        SpellTargetUnit(NSTarget)
                        SpellStopTargeting()
                    end
                    return true
                end
            end
        end
    end
    return false
end

function MoronBox.Core.Healing.CastSpellOnRandomRaidMember(spell, rank, percentage)
    if not UnitInRaid("player") then
        return
    end

    if getSpells().ImBusy() then
        return
    end

    if getRaid().TankTarget("Garr") or getRaid().TankTarget("Firesworn") then
        return
    end

    local n, r, j
    n = getUnit().GetNumPartyOrRaidMembers()
    r = math.random(n) - 1

    for i = 1, n do
        j = i + r
        if j > n then
            j = j - n
        end

        if getUnit().HealthPct("raid" .. j) < percentage
            and not getAura().HasBuffNamed(spell, "raid" .. j)
            and getUnit().IsValidFriendlyTarget("raid" .. j, spell) then
            if UnitIsFriend("player", "raid" .. j) then
                ClearTarget()
            end

            if spell == "Weakened Soul" then
                CastSpellByName("Power Word: Shield", nil)
            else
                CastSpellByName(spell .. "(" .. rank .. ")", nil)
            end

            SpellTargetUnit("raid" .. j)
            SpellStopTargeting()
            break
        end
    end
end

function MoronBox.Core.Healing.CastShieldOnRandomRaidMember(spell, rank)
    if getSpells().ImBusy() then
        return
    end

    if not UnitInRaid("player") then
        return
    end

    if getRaid().TankTarget("Garr") or getRaid().TankTarget("Firesworn") then
        return
    end

    local n, r, j
    n = getUnit().GetNumPartyOrRaidMembers()
    r = math.random(n) - 1

    for i = 1, n do
        j = i + r
        if j > n then
            j = j - n
        end

        if not getAura().HasBuffNamed("Power Word: Shield", "raid" .. j)
            and not getAura().HasBuffNamed("Weakened Soul", "raid" .. j)
            and getUnit().IsValidFriendlyTarget("raid" .. j, spell) then
            if UnitIsFriend("player", "raid" .. j) then
                ClearTarget()
            end

            CastSpellByName("Power Word: Shield", nil)

            SpellTargetUnit("raid" .. j)
            SpellStopTargeting()
            break
        end
    end
end

function MoronBox.Core.Healing.PowerShieldTanks()
    if myClass ~= "Priest" then
        return
    end

    local i = 1
    for _, tank in ipairs(MB_raidTanks) do
        if getUnit().IsAlive(MBID[tank]) then
            if getCore().MyClassOrder() == i then
                TargetUnit(MBID[tank])
                CastSpellByName("Power Word: Shield")
                return
            end

            i = i + 1
        end
    end
end

function MoronBox.Core.Healing.InstructorRazAddsHeal()
    if not UnitInRaid("player") then
        return false
    end

    if getRaid().TankTarget("Instructor Razuvious") and getApi().FindMyNameInTable(getHealingState().InstructorRazuviousAddHealer) then
        TargetUnit(MBID[getConfigState().RaidLeader] .. "targettarget")

        if UnitName("target") == "Deathknight Understudy" then
            local allowedOverHeal, spellToCast

            if myClass == "Shaman" then
                allowedOverHeal = getHealing().GetHealValueFromRank("Healing Wave",
                        getHealingState().Shaman.MainTankHealingRank) *
                    getHealingState().MainTankOverhealingPercentage * 4
                spellToCast = "Healing Wave(" .. getHealingState().Shaman.MainTankHealingRank .. ")"
            elseif myClass == "Paladin" then
                allowedOverHeal = getHealing().GetHealValueFromRank("Flash of Light",
                        getHealingState().Paladin.MainTankHealingRank) *
                    getHealingState().MainTankOverhealingPercentage * 4
                spellToCast = "Flash of Light(" .. getHealingState().Paladin.MainTankHealingRank .. ")"
            elseif myClass == "Priest" then
                allowedOverHeal = getHealing().GetHealValueFromRank("Greater Heal",
                        getHealingState().Priest.MainTankHealingRank) *
                    getHealingState().MainTankOverhealingPercentage * 4
                spellToCast = "Greater Heal(" .. getHealingState().Priest.MainTankHealingRank .. ")"
            elseif myClass == "Druid" then
                allowedOverHeal = getHealing().GetHealValueFromRank("Healing Touch",
                        getHealingState().Druid.MainTankHealingRank) *
                    getHealingState().MainTankOverhealingPercentage * 4
                spellToCast = "Healing Touch(" .. getHealingState().Druid.MainTankHealingRank .. ")"
            end

            if getUnit().IsValidFriendlyTarget("target", spellToCast) and getUnit().HealthDown("target") >= allowedOverHeal then
                CastSpellByName(spellToCast)
            end
            return true
        end
    end
    return false
end

function MoronBox.Core.Healing.HealLieutenantAQ20()
    if not UnitInRaid("player") or MB_lieutenantAndorovIsNotHealable.Active then
        return false
    end

    if Instance.AQ20() then
        TargetByName("Lieutenant General Andorov")

        if UnitName("target") == "Lieutenant General Andorov" then
            local spellToCast

            if myClass == "Shaman" then
                spellToCast = "Healing Wave(rank 7)"
            elseif myClass == "Priest" then
                spellToCast = "Heal"
            elseif myClass == "Druid" then
                spellToCast = "Healing Touch(rank 3)"
            elseif myClass == "Paladin" then
                spellToCast = "Flash of Light"
            end

            if getUnit().IsValidFriendlyTarget("target", spellToCast) and getUnit().HealthPct("target") <= 0.4 then
                CastSpellByName(spellToCast)
                return true
            end
        else
            TargetLastTarget()
        end
    end
    return false
end

function MoronBox.Core.Healing.TargetMyAssignedTankToHeal()
    if getApi().FindMyNameInTable(MB_myThreatPWSoakerHealerList) then
        TargetByName(MB_myThreatPWSoaker)
        return
    end

    if getApi().FindMyNameInTable(MB_myFirstPWSoakerHealerList) then
        TargetByName(MB_myFirstPWSoaker)
        return
    end

    if getApi().FindMyNameInTable(MB_mySecondPWSoakerHealerList) then
        TargetByName(MB_mySecondPWSoaker)
        return
    end

    if getApi().FindMyNameInTable(MB_myThirdPWSoakerHealerList) then
        TargetByName(MB_myThirdPWSoaker)
        return
    end

    if not MB_myAssignedHealTarget then
        MB_myAssignedHealTarget = MB_raidLeader
    end
end
