-- [[ Gehennas Bossing Logic ]] --

-- Bossname
local BOSS_KEY = "Gehennas"

-- Values for internal begind the scene logic. Like addon messages and table lookups
local ENCOUNTER_KEY = string.upper(string.gsub(BOSS_KEY, " ", "_"))
local MODULE_NAME = "MODULE_" .. ENCOUNTER_KEY

-- Initalize
MoronBox.Core.Bosses.Gehennas = MoronBox.Core.Bosses.Gehennas or {}

MoronBox:RegisterModule(MODULE_NAME, function()
    local BoxStrategy = true
    local FreeActionPotsStrategy = true
    local FirePotsStrategy = false

    getBosses().Register(ENCOUNTER_KEY, {
        boss        = { "Gehennas" },
        guardians   = { "Flamewaker" },
        onEngage    = function() getApi().CdRaidWarning(">> Fighting Gehennas <<") end,
        onDisengage = function() getApi().CdRaidWarning(">> Gehennas Defeated <<") end,
        onActive    = function()
            if FreeActionPotsStrategy and (getCore().ImTank() or getCore().ImMeleeDPS()) then
                getCons().PotionsWhenPossible("Free Action Potion")
            end

            if FirePotsStrategy and (getCore().ImHealer() or getCore().ImRangedDPS()) then
                getCons().PotionsWhenPossible("Greater Fire Protection Potion")
            end
        end
    })

    local TargetNearestDistanceChanged = false

    MoronBox:RegisterExpose({
        TargetingPreFocus = function()
            if not BoxStrategy then
                return false
            end

            if not getBosses().IsActive(ENCOUNTER_KEY) then
                return false
            end

            if not getRaid().ImFocus() then
                return false
            end

            getBosses().ExecuteActive(ENCOUNTER_KEY)
            return true
        end,
        TargetingPostFocus = function()
            if not BoxStrategy then
                return false
            end

            if not getBosses().IsActive(ENCOUNTER_KEY) then
                return false
            end

            getBosses().ExecuteActive(ENCOUNTER_KEY)

            if getCore().ImTank() then
                if not TargetNearestDistanceChanged then
                    SetCVar("targetNearestDistance", "10")
                    TargetNearestDistanceChanged = true
                end

                getRaid().GetTargetNotOnTank()
                return true
            elseif getCore().ImRangedDPS() or getCore().ImMeleeDPS() or getCore().ImHealer() then
                getRaid().AssistFocus()
                return true
            end
            return false
        end
    })
end, function()
    return Instance.MC()
end)

function MoronBox.Core.Bosses.Gehennas.TargetingPreFocus()
    if MoronBox.Registry[MODULE_NAME] and MoronBox.Registry[MODULE_NAME].TargetingPreFocus then
        return MoronBox.Registry[MODULE_NAME].TargetingPreFocus()
    end
end

function MoronBox.Core.Bosses.Gehennas.TargetingPostFocus()
    if MoronBox.Registry[MODULE_NAME] and MoronBox.Registry[MODULE_NAME].TargetingPostFocus then
        return MoronBox.Registry[MODULE_NAME].TargetingPostFocus()
    end
end
