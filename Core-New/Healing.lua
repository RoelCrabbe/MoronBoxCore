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

local HealingState                 = MoronBox.Core.Healing.HealingState

---@diagnostic disable: undefined-global
setfenv(1, MoronBox:GetEnvironment())

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

local function GetHealValueFromRank(spell, rank)
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
        if EquippedSetCount("Earthfury") == 8 then
            MB_myHealSpell = "Healing Wave"
            return true
        elseif EquippedSetCount("The Ten Storms") >= 3 and EquippedSetCount("Stormcaller\'s Garb") == 5 then
            MB_myHealSpell = "Chain Heal"
            return true
        else
            if MB_raidAssist.Shaman.DefaultToHealingWave then
                MB_myHealSpell = "Healing Wave"
                return true
            else
                MB_myHealSpell = "Chain Heal"
            end
        end
    elseif myClass == "Priest" then
        if FindMyNameInTable(HealingState.Priest.FlashHealerList) then
            MB_myHealSpell = "Flash Heal"
            return true
        elseif EquippedSetCount("Vestments of Transcendence") == 8 then
            MB_myHealSpell = "Greater Heal"
            return true
        else
            MB_myHealSpell = "Heal"
            return true
        end
    elseif myClass == "Druid" and EquippedSetCount("Dreamwalker Raiment") >= 2 then
        MB_myHealSpell = "Rejuvenation"
        return true
    end
end

function MoronBox.Core.Healing.CastSpellOnRandomRaidMember(spell, rank, percentage)
    if not UnitInRaid("player") then
        return
    end

    if ImBusy() then
        return
    end

    if TankTarget("Garr") or TankTarget("Firesworn") then
        return
    end

    local n, r, j
    n = GetNumPartyOrRaidMembers()
    r = math.random(n) - 1

    for i = 1, n do
        j = i + r
        if j > n then
            j = j - n
        end

        if HealthPct("raid" .. j) < percentage
            and not HasBuffNamed(spell, "raid" .. j)
            and IsValidFriendlyTarget("raid" .. j, spell) then
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
    if ImBusy() then
        return
    end

    if not UnitInRaid("player") then
        return
    end

    if TankTarget("Garr") or TankTarget("Firesworn") then
        return
    end

    local n, r, j
    n = GetNumPartyOrRaidMembers()
    r = math.random(n) - 1

    for i = 1, n do
        j = i + r
        if j > n then
            j = j - n
        end

        if not HasBuffNamed("Power Word: Shield", "raid" .. j)
            and not HasBuffNamed("Weakened Soul", "raid" .. j)
            and IsValidFriendlyTarget("raid" .. j, spell) then
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
        if IsAlive(MBID[tank]) then
            if MyClassOrder() == i then
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

    if TankTarget("Instructor Razuvious") and FindMyNameInTable(HealingState.InstructorRazuviousAddHealer) then
        TargetUnit(MBID[MB_raidLeader] .. "targettarget")

        if UnitName("target") == "Deathknight Understudy" then
            local allowedOverHeal, spellToCast

            if myClass == "Shaman" then
                allowedOverHeal = GetHealValueFromRank("Healing Wave", HealingState.Shaman.MainTankHealingRank) *
                    HealingState.MainTankOverhealingPercentage * 4
                spellToCast = "Healing Wave(" .. HealingState.Shaman.MainTankHealingRank .. ")"
            elseif myClass == "Paladin" then
                allowedOverHeal = GetHealValueFromRank("Flash of Light", HealingState.Paladin.MainTankHealingRank) *
                    HealingState.MainTankOverhealingPercentage * 4
                spellToCast = "Flash of Light(" .. HealingState.Paladin.MainTankHealingRank .. ")"
            elseif myClass == "Priest" then
                allowedOverHeal = GetHealValueFromRank("Greater Heal", HealingState.Priest.MainTankHealingRank) *
                    HealingState.MainTankOverhealingPercentage * 4
                spellToCast = "Greater Heal(" .. HealingState.Priest.MainTankHealingRank .. ")"
            elseif myClass == "Druid" then
                allowedOverHeal = GetHealValueFromRank("Healing Touch", HealingState.Druid.MainTankHealingRank) *
                    HealingState.MainTankOverhealingPercentage * 4
                spellToCast = "Healing Touch(" .. HealingState.Druid.MainTankHealingRank .. ")"
            end

            if IsValidFriendlyTarget("target", spellToCast) and HealthDown("target") >= allowedOverHeal then
                CastSpellByName(spellToCast)
            end
            return true
        end
    end
    return false
end
