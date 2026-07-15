-- [[ Shaman Drop Totem ]] --
---@diagnostic disable: undefined-global

local NAME = "Shaman Totems"
local MODULE_NAME = "MODULE_" .. string.upper(string.gsub(NAME, " ", "_"))

local myClass = UnitClass("player")

MoronBox:RegisterModule(MODULE_NAME, function()
    local function ChooseAirTotem()
        if Instance.NAXX() then
            if TankTarget("Patchwerk") and MB_myPatchwerkBoxStrategy then
                if IsInGroup(MB_myFirstPWSoaker) or IsInGroup(MB_mySecondPWSoaker) or IsInGroup(MB_myThirdPWSoaker) then
                    if MyGroupClassOrder() == 1 then return "Grace of Air Totem" end
                    if MyGroupClassOrder() == 2 then return "Windfury Totem" end
                end
            end
        elseif Instance.AQ40() and TankTarget("Princess Huhuran") and TankTargetHealth() <= 0.4 then
            if MyGroupClassOrder() == 1 then return "Nature Resistance Totem" end

            if MB_druidTankInParty or MB_warriorTankInParty then
                if MyGroupClassOrder() == 2 then return "Windfury Totem" end
                if MyGroupClassOrder() == 3 then return "Grace of Air Totem" end
            elseif NumberOfClassInParty("Warrior") > 0 or NumberOfClassInParty("Rogue") > 0 then
                if MyGroupClassOrder() == 2 then return "Windfury Totem" end
                if MyGroupClassOrder() == 3 then return "Grace of Air Totem" end
            elseif NumberOfClassInParty("Mage") > 0 or NumberOfClassInParty("Warlock") > 0 then
                if MyGroupClassOrder() == 2 then return "Tranquil Air Totem" end
                if MyGroupClassOrder() == 3 then return "Grace of Air Totem" end
            end
        elseif Instance.AQ20() and TankTarget("Ossirian the Unscarred") and MB_myOssirianBoxStrategy then
            if IsInGroup(MB_myOssirianMainTank) then
                if MyGroupClassOrder() == 1 then return "Grounding Totem" end
                if MyGroupClassOrder() == 2 then return "Grounding Totem" end
                if MyGroupClassOrder() == 3 then return "Grace of Air Totem" end
                if MyGroupClassOrder() == 4 then return "Windfury Totem" end
            end
        end

        if IsNatureBoss() then
            if MyGroupClassOrder() == 2 then return "Nature Resistance Totem" end
        end

        if MB_druidTankInParty or MB_warriorTankInParty then
            if MyGroupClassOrder() == 1 then return "Windfury Totem" end
            if MyGroupClassOrder() == 2 then return "Grace of Air Totem" end
        elseif NumberOfClassInParty("Warrior") > 0 or NumberOfClassInParty("Rogue") > 0 then
            if MyGroupClassOrder() == 1 then return "Windfury Totem" end
            if MyGroupClassOrder() == 2 then return "Grace of Air Totem" end
        elseif NumberOfClassInParty("Mage") > 0 or NumberOfClassInParty("Warlock") > 0 then
            if MyGroupClassOrder() == 1 then return "Tranquil Air Totem" end
            if MyGroupClassOrder() == 2 then return "Grace of Air Totem" end
        end

        if MyGroupClassOrder() == 1 then return "Tranquil Air Totem" end
        if MyGroupClassOrder() == 2 then return "Grace of Air Totem" end
    end

    local function ChooseEarthTotem()
        if Instance.ONY() and TankTarget("Onyxia") and TankTargetHealth() >= 0.4 then
            if MB_druidTankInParty or MB_warriorTankInParty then
                if MyGroupClassOrder() == 1 then return "Strength of Earth Totem" end
                if MyGroupClassOrder() == 2 then return "Stoneskin Totem" end
            elseif NumberOfClassInParty("Warrior") > 0 or NumberOfClassInParty("Rogue") > 0 then
                if MyGroupClassOrder() == 1 then return "Strength of Earth Totem" end
                if MyGroupClassOrder() == 2 then return "Stoneskin Totem" end
            elseif NumberOfClassInParty("Mage") > 0 or NumberOfClassInParty("Warlock") > 0 then
                if MyGroupClassOrder() == 1 then return "Stoneskin Totem" end
                if MyGroupClassOrder() == 2 then return "Strength of Earth Totem" end
            end
        end

        if IsTremorBoss() then
            if MyGroupClassOrder() == 1 then return "Tremor Totem" end
        end

        if MB_druidTankInParty or MB_warriorTankInParty then
            if MyGroupClassOrder() == 1 then return "Strength of Earth Totem" end
            if MyGroupClassOrder() == 2 then return "Stoneskin Totem" end
        elseif NumberOfClassInParty("Warrior") > 0 or NumberOfClassInParty("Rogue") > 0 then
            if MyGroupClassOrder() == 1 then return "Strength of Earth Totem" end
            if MyGroupClassOrder() == 2 then return "Stoneskin Totem" end
        elseif NumberOfClassInParty("Mage") > 0 or NumberOfClassInParty("Warlock") > 0 then
            if MyGroupClassOrder() == 1 then return "Stoneskin Totem" end
            if MyGroupClassOrder() == 2 then return "Strength of Earth Totem" end
        end

        if MyGroupClassOrder() == 1 then return "Stoneskin Totem" end
        if MyGroupClassOrder() == 2 then return "Strength of Earth Totem" end
    end

    local function ChooseWaterTotem()
        if IsPoisonBoss() then
            if Instance.AQ40() then
                if MyGroupClassOrder() == 1 then return "Healing Stream Totem" end
                if MyGroupClassOrder() == 2 then return "Mana Spring Totem" end
            elseif Instance.BWL() and TankTarget("Chromaggus") then
                if MyGroupClassOrder() == 1 then return "Poison Cleansing Totem" end
                if MyGroupClassOrder() == 2 then return "Mana Spring Totem" end
            end
        elseif IsFireBoss() then
            if MyGroupClassOrder() == 1 then return "Fire Resistance Totem" end
            if MyGroupClassOrder() == 2 then return "Mana Spring Totem" end
        elseif LOA_IsAtLoatheb() then
            if MyGroupClassOrder() == 1 then return "Healing Stream Totem" end
            if MyGroupClassOrder() == 2 then return "Mana Spring Totem" end
        end

        if MyGroupClassOrder() == 1 then return "Mana Spring Totem" end
        if MyGroupClassOrder() == 2 then return "Healing Stream Totem" end
    end

    local function ChooseFireTotem()
        if MyGroupClassOrder() == 1 then return "Frost Resistance Totem" end
    end

    local function CastTotem(totem)
        if MobsNoTotems() then
            return
        end

        if HasBuffOrDebuff("Mana Tide Totem", "player", "buff") then
            return
        end

        if (totem == "Fire Nova Totem" or totem == "Magma Totem") and not (InMeleeRange() or InCombat()) then
            return
        end

        if totem and string.find(totem, "Searing Totem") and not InCombat() then
            return
        end

        local TotemTypes = {
            buff = {
                "Grounding Totem",
                "Windfury Totem",
                "Grace of Air Totem",
                "Nature Resistance Totem",
                "Tranquil Air Totem",
                "Stoneskin Totem",
                "Strength of Earth Totem",
                "Frost Resistance Totem",
                "Fire Resistance Totem",
                "Mana Spring Totem",
                "Healing Stream Totem",
                "Mana Tide Totem"
            },
            noBuff = {
                "Sentry Totem",
                "Earthbind Totem",
                "Stoneclaw Totem",
                "Fire Nova Totem",
                "Magma Totem",
                "Searing Totem",
                "Flametongue Totem",
                "Tremor Totem",
                "Poison Cleansing Totem",
                "Disease Cleansing Totem"
            }
        }

        if FindInTable(TotemTypes.noBuff, totem) then
            CastSpellWithCooldown(totem, 15)
        else
            if totem and not HasBuffOrDebuff(totem, "player", "buff") then
                CastSpellByName(totem)
            end
        end
    end

    MoronBox:RegisterExpose({
        DropTotems = function()
            if IsShiftKeyDown() then
                if not HasBuffOrDebuff("Grounding Totem", "player", "buff") then
                    CastSpellByName("Grounding Totem")
                end
                if not HasBuffOrDebuff("Stoneskin Totem", "player", "buff") then
                    CastSpellByName("Stoneskin Totem")
                end
                if not HasBuffOrDebuff("Healing Stream Totem", "player", "buff") then
                    CastSpellByName("Healing Stream Totem")
                end
                return
            end

            if GetSubZoneText() == "The Lyceum" then
                return
            end

            if GetSubZoneText() == "Halls of Strife" and not (TankTarget("Broodlord Lashlayer") or TankTarget("Firemaw")) then
                return
            end

            if MBID[MB_raidLeader] and not UnitName(MBID[MB_raidLeader] .. "target") then
                return
            end

            CastTotem(ChooseAirTotem())

            if not MB_cooldowns["Tremor Totem"] then
                CastTotem(ChooseEarthTotem())
            end

            if not MB_cooldowns["Poison Cleansing Totem"] then
                CastTotem(ChooseWaterTotem())
            end

            if TankTarget("Sapphiron") or TankTarget("Azuregos") then
                CastTotem(ChooseFireTotem())
            end
        end
    })
end, function()
    return myClass == "Shaman"
end)

function MoronBox.Core.Buffs.DropTotems()
    if MoronBox.Registry[MODULE_NAME] and MoronBox.Registry[MODULE_NAME].DropTotems then
        MoronBox.Registry[MODULE_NAME].DropTotems()
    end
end
