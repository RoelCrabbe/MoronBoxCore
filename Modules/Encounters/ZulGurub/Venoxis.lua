-- [[ Venoxis Bossing Logic ]] --

-- Bossname
local BOSS_KEY = "Venoxis"

-- Values for internal begind the scene logic. Like addon messages and table lookups
local ENCOUNTER_KEY = string.upper(string.gsub(BOSS_KEY, " ", "_"))
local MODULE_NAME = "MODULE_" .. ENCOUNTER_KEY

-- Initalize
MoronBox.Core.Bosses.Venoxis = MoronBox.Core.Bosses.Venoxis or {}

MoronBox:RegisterModule(MODULE_NAME, function()
    local BoxStrategy = true
    local NaturePotsStrategy = false

    getBosses().Register(ENCOUNTER_KEY, {
        boss        = { "High Priest Venoxis" },
        guardians   = { "Razzashi Cobra" },
        onEngage    = function() getApi().CdRaidWarning(">> Fighting Venoxis <<") end,
        onDisengage = function() getApi().CdRaidWarning(">> Venoxis Defeated <<") end,
        onBossYell  = function(arg1)
            if string.find(arg1, "Ssserenity..at lassst!") then
                getBosses().EndEncounter(ENCOUNTER_KEY)
            end
        end,
        onActive    = function()
            if NaturePotsStrategy then
                getCons().PotionsWhenPossible("Greater Nature Protection Potion")
            end
        end
    })

    local TargetNearestDistanceChanged = false

    MoronBox:RegisterExpose({
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
                for _ = 1, 3 do
                    if UnitName("target") == "Razzashi Cobra" and not getUnit().IsDead("target")
                        and not GetRaidTargetIndex("target") then
                        return true
                    end

                    TargetNearestEnemy()
                end

                getRaid().AssistFocus()
                return true
            end
            return false
        end
    })
end, function()
    return Instance.ZG()
end)

function MoronBox.Core.Bosses.Venoxis.TargetingPostFocus()
    if MoronBox.Registry[MODULE_NAME] and MoronBox.Registry[MODULE_NAME].TargetingPostFocus then
        return MoronBox.Registry[MODULE_NAME].TargetingPostFocus()
    end
end
