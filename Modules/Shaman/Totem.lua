-- [[ Shaman Drop Totem ]] --

local NAME = "Shaman Totems"
local MODULE_NAME = "MODULE_" .. string.upper(string.gsub(NAME, " ", "_"))

local myClass = UnitClass("player")

MoronBox:RegisterModule(MODULE_NAME, function()
    local function ChooseAirTotem()
        if Instance.NAXX() then
            if getRaid().TankTarget("Patchwerk") and getEncountersState().Patchwerk.Active then
                if getUnit().IsInGroup(getEncountersState().Patchwerk.FirstSoaker) or getUnit().IsInGroup(getEncountersState().Patchwerk.SecondSoaker) or getUnit().IsInGroup(getEncountersState().Patchwerk.ThirdSoaker) then
                    if getCore().MyGroupClassOrder() == 1 then return "Grace of Air Totem" end
                    if getCore().MyGroupClassOrder() == 2 then return "Windfury Totem" end
                end
            end
        elseif Instance.AQ40() and getRaid().TankTarget("Princess Huhuran") and getRaid().TankTargetHealth() <= 0.4 then
            if getCore().MyGroupClassOrder() == 1 then return "Nature Resistance Totem" end

            if getCoreState().DruidTankInParty or getCoreState().WarriorTankInParty then
                if getCore().MyGroupClassOrder() == 2 then return "Windfury Totem" end
                if getCore().MyGroupClassOrder() == 3 then return "Grace of Air Totem" end
            elseif getCore().NumberOfClassInParty("Warrior") > 0 or getCore().NumberOfClassInParty("Rogue") > 0 then
                if getCore().MyGroupClassOrder() == 2 then return "Windfury Totem" end
                if getCore().MyGroupClassOrder() == 3 then return "Grace of Air Totem" end
            elseif getCore().NumberOfClassInParty("Mage") > 0 or getCore().NumberOfClassInParty("Warlock") > 0 then
                if getCore().MyGroupClassOrder() == 2 then return "Tranquil Air Totem" end
                if getCore().MyGroupClassOrder() == 3 then return "Grace of Air Totem" end
            end
        elseif Instance.AQ20() and getRaid().TankTarget("Ossirian the Unscarred") and getEncountersState().Ossirian.Active then
            if getUnit().IsInGroup(getEncountersState().Ossirian.MainTank) then
                if getCore().MyGroupClassOrder() == 1 then return "Grounding Totem" end
                if getCore().MyGroupClassOrder() == 2 then return "Grounding Totem" end
                if getCore().MyGroupClassOrder() == 3 then return "Grace of Air Totem" end
                if getCore().MyGroupClassOrder() == 4 then return "Windfury Totem" end
            end
        end

        if getTables().IsNatureBoss() then
            if getCore().MyGroupClassOrder() == 2 then return "Nature Resistance Totem" end
        end

        if getCoreState().DruidTankInParty or getCoreState().WarriorTankInParty then
            if getCore().MyGroupClassOrder() == 1 then return "Windfury Totem" end
            if getCore().MyGroupClassOrder() == 2 then return "Grace of Air Totem" end
        elseif getCore().NumberOfClassInParty("Warrior") > 0 or getCore().NumberOfClassInParty("Rogue") > 0 then
            if getCore().MyGroupClassOrder() == 1 then return "Windfury Totem" end
            if getCore().MyGroupClassOrder() == 2 then return "Grace of Air Totem" end
        elseif getCore().NumberOfClassInParty("Mage") > 0 or getCore().NumberOfClassInParty("Warlock") > 0 then
            if getCore().MyGroupClassOrder() == 1 then return "Tranquil Air Totem" end
            if getCore().MyGroupClassOrder() == 2 then return "Grace of Air Totem" end
        end

        if getCore().MyGroupClassOrder() == 1 then return "Tranquil Air Totem" end
        if getCore().MyGroupClassOrder() == 2 then return "Grace of Air Totem" end
    end

    local function ChooseEarthTotem()
        if Instance.ONY() and getRaid().TankTarget("Onyxia") and getRaid().TankTargetHealth() >= 0.4 then
            if getCoreState().DruidTankInParty or getCoreState().WarriorTankInParty then
                if getCore().MyGroupClassOrder() == 1 then return "Strength of Earth Totem" end
                if getCore().MyGroupClassOrder() == 2 then return "Stoneskin Totem" end
            elseif getCore().NumberOfClassInParty("Warrior") > 0 or getCore().NumberOfClassInParty("Rogue") > 0 then
                if getCore().MyGroupClassOrder() == 1 then return "Strength of Earth Totem" end
                if getCore().MyGroupClassOrder() == 2 then return "Stoneskin Totem" end
            elseif getCore().NumberOfClassInParty("Mage") > 0 or getCore().NumberOfClassInParty("Warlock") > 0 then
                if getCore().MyGroupClassOrder() == 1 then return "Stoneskin Totem" end
                if getCore().MyGroupClassOrder() == 2 then return "Strength of Earth Totem" end
            end
        end

        if getTables().IsTremorBoss() then
            if getCore().MyGroupClassOrder() == 1 then return "Tremor Totem" end
        end

        if getCoreState().DruidTankInParty or getCoreState().WarriorTankInParty then
            if getCore().MyGroupClassOrder() == 1 then return "Strength of Earth Totem" end
            if getCore().MyGroupClassOrder() == 2 then return "Stoneskin Totem" end
        elseif getCore().NumberOfClassInParty("Warrior") > 0 or getCore().NumberOfClassInParty("Rogue") > 0 then
            if getCore().MyGroupClassOrder() == 1 then return "Strength of Earth Totem" end
            if getCore().MyGroupClassOrder() == 2 then return "Stoneskin Totem" end
        elseif getCore().NumberOfClassInParty("Mage") > 0 or getCore().NumberOfClassInParty("Warlock") > 0 then
            if getCore().MyGroupClassOrder() == 1 then return "Stoneskin Totem" end
            if getCore().MyGroupClassOrder() == 2 then return "Strength of Earth Totem" end
        end

        if getCore().MyGroupClassOrder() == 1 then return "Stoneskin Totem" end
        if getCore().MyGroupClassOrder() == 2 then return "Strength of Earth Totem" end
    end

    local function ChooseWaterTotem()
        if getTables().IsPoisonBoss() then
            if Instance.AQ40() then
                if getCore().MyGroupClassOrder() == 1 then return "Healing Stream Totem" end
                if getCore().MyGroupClassOrder() == 2 then return "Mana Spring Totem" end
            elseif Instance.BWL() and getRaid().TankTarget("Chromaggus") then
                if getCore().MyGroupClassOrder() == 1 then return "Poison Cleansing Totem" end
                if getCore().MyGroupClassOrder() == 2 then return "Mana Spring Totem" end
            end
        elseif getTables().IsFireBoss() then
            if getCore().MyGroupClassOrder() == 1 then return "Fire Resistance Totem" end
            if getCore().MyGroupClassOrder() == 2 then return "Mana Spring Totem" end
        elseif Instance.NAXX() and LOA_IsAtLoatheb() then
            if getCore().MyGroupClassOrder() == 1 then return "Healing Stream Totem" end
            if getCore().MyGroupClassOrder() == 2 then return "Mana Spring Totem" end
        end

        if getCore().MyGroupClassOrder() == 1 then return "Mana Spring Totem" end
        if getCore().MyGroupClassOrder() == 2 then return "Healing Stream Totem" end
    end

    local function ChooseFireTotem()
        if getCore().MyGroupClassOrder() == 1 then return "Frost Resistance Totem" end
    end

    local function CastTotem(totem)
        if getTables().MobsNoTotems() then
            return
        end

        if getAura().HasBuffOrDebuff("Mana Tide Totem", "player", "buff") then
            return
        end

        if (totem == "Fire Nova Totem" or totem == "Magma Totem") and not (getUnit().InMeleeRange() or getUnit().InCombat()) then
            return
        end

        if totem and string.find(totem, "Searing Totem") and not getUnit().InCombat() then
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

        if getApi().FindInTable(TotemTypes.noBuff, totem) then
            getSpells().CastSpellWithCooldown(totem, 15)
        else
            if totem and not getAura().HasBuffOrDebuff(totem, "player", "buff") then
                CastSpellByName(totem)
            end
        end
    end

    MoronBox:RegisterExpose({
        DropTotems = function()
            if IsShiftKeyDown() then
                if not getAura().HasBuffOrDebuff("Grounding Totem", "player", "buff") then
                    CastSpellByName("Grounding Totem")
                end
                if not getAura().HasBuffOrDebuff("Stoneskin Totem", "player", "buff") then
                    CastSpellByName("Stoneskin Totem")
                end
                if not getAura().HasBuffOrDebuff("Healing Stream Totem", "player", "buff") then
                    CastSpellByName("Healing Stream Totem")
                end
                return
            end

            if GetSubZoneText() == "The Lyceum" then
                return
            end

            if GetSubZoneText() == "Halls of Strife" and not (getRaid().TankTarget("Broodlord Lashlayer") or getRaid().TankTarget("Firemaw")) then
                return
            end

            if getCoreState().ClassList[getConfigState().RaidLeader] and not UnitName(getCoreState().ClassList[getConfigState().RaidLeader] .. "target") then
                return
            end

            CastTotem(ChooseAirTotem())

            if not getConfigState().TrackCooldowns["Tremor Totem"] then
                CastTotem(ChooseEarthTotem())
            end

            if not getConfigState().TrackCooldowns["Poison Cleansing Totem"] then
                CastTotem(ChooseWaterTotem())
            end

            if getRaid().TankTarget("Sapphiron") or getRaid().TankTarget("Azuregos") then
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
