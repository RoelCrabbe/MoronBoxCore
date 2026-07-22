-- [[ Jeklik Bossing Logic ]] --

-- Bossname
local BOSS_KEY = "Jeklik"

-- Values for internal begind the scene logic. Like addon messages and table lookups
local ENCOUNTER_KEY = string.upper(string.gsub(BOSS_KEY, " ", "_"))
local MODULE_NAME = "MODULE_" .. ENCOUNTER_KEY

-- Initalize
MoronBox.Core.Bosses.Jeklik = MoronBox.Core.Bosses.Jeklik or {}

MoronBox:RegisterModule(MODULE_NAME, function()
    local BoxStrategy = true
    local FirePotsStrategy = true

    getBosses().Register(ENCOUNTER_KEY, {
        boss                = { "High Priestess Jeklik" },
        guardians           = { "Bloodseeker Bat" },
        onEngage            = function() getApi().CdRaidWarning(">> Fighting Jeklik <<") end,
        onDisengage         = function() getApi().CdRaidWarning(">> Jeklik Defeated <<") end,
        disableHitDetection = true,
        onBossYell          = function(arg1)
            if string.find(arg1, "Lord Hir'eek, grant me wings of vengance!") then
                getBosses().StartEncounter(ENCOUNTER_KEY)
            elseif string.find(arg1, "Finally ...death. Curse you Hakkar! Curse you!") then
                getBosses().EndEncounter(ENCOUNTER_KEY)
            end
        end,
        onActive            = function()
            getBuffs().RequestFearWard()
            getBuffs().ProcessFearWard()

            if FirePotsStrategy then
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
        end,
        TargetingPostFocus = function()
            if not BoxStrategy then
                return false
            end

            if not getBosses().IsActive(ENCOUNTER_KEY) then
                return false
            end

            getBosses().ExecuteActive(ENCOUNTER_KEY)

            local targetName = UnitName("target")

            if getCore().ImTank() then
                if not TargetNearestDistanceChanged then
                    SetCVar("targetNearestDistance", "10")
                    TargetNearestDistanceChanged = true
                end

                getRaid().GetTargetNotOnTank()
                return true
            elseif getCore().ImMeleeDPS() then
                getRaid().AssistFocus()
                return true
            elseif getCore().ImRangedDPS() or getCore().ImHealer() then
                for _ = 1, 3 do
                    if targetName == "Bloodseeker Bat" and getUnit().InCombat("target")
                        and not getUnit().IsDead("target") then
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

function MoronBox.Core.Bosses.Jeklik.TargetingPreFocus()
    if MoronBox.Registry[MODULE_NAME] and MoronBox.Registry[MODULE_NAME].TargetingPreFocus then
        return MoronBox.Registry[MODULE_NAME].TargetingPreFocus()
    end
end

function MoronBox.Core.Bosses.Jeklik.TargetingPostFocus()
    if MoronBox.Registry[MODULE_NAME] and MoronBox.Registry[MODULE_NAME].TargetingPostFocus then
        return MoronBox.Registry[MODULE_NAME].TargetingPostFocus()
    end
end
