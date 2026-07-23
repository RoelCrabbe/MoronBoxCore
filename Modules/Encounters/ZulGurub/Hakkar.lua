-- [[ Hakkar Bossing Logic ]] --

-- Bossname
local BOSS_KEY = "Hakkar"

-- Values for internal begind the scene logic. Like addon messages and table lookups
local ENCOUNTER_KEY = string.upper(string.gsub(BOSS_KEY, " ", "_"))
local MODULE_NAME = "MODULE_" .. ENCOUNTER_KEY

-- Initalize
MoronBox.Core.Bosses.Hakkar = MoronBox.Core.Bosses.Hakkar or {}

MoronBox:RegisterModule(MODULE_NAME, function()
    local BoxStrategy = true

    getBosses().Register(ENCOUNTER_KEY, {
        boss                = { "Hakkar" },
        onEngage            = function() getApi().CdRaidWarning(">> Fighting Hakkar <<") end,
        onDisengage         = function() getApi().CdRaidWarning(">> Hakkar Defeated <<") end,
        disableHitDetection = true,
        overrideDetectDeath = true,
        onBossYell          = function(arg1)
            if string.find(arg1, "PRIDE HERALDS THE END OF YOUR WORLD. COME, MORTALS! FACE THE WRATH OF THE SOULFLAYER!") then
                getBosses().StartEncounter(ENCOUNTER_KEY)
            end
        end
    })

    local TargetNearestDistanceChanged = false

    MoronBox:RegisterExpose({
        IsAtHakkar = function()
            if not BoxStrategy then
                return false
            end

            return getBosses().IsActive(ENCOUNTER_KEY)
        end,
        TargetingPostFocus = function()
            if not getBosses().Hakkar.IsAtHakkar() then
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
            elseif getCore().ImMeleeDPS() then
                getRaid().AssistFocus()
                return true
            elseif getCore().ImRangedDPS() or getCore().ImHealer() then
                for _ = 1, 3 do
                    if UnitName("target") == "Bloodseeker Bat" and getUnit().InCombat("target")
                        and not getUnit().IsDead("target") then
                        return true
                    end

                    TargetNearestEnemy()
                end

                getRaid().AssistFocus()
                return true
            end
            return false
        end,
        CrowdControlMCedRaidMember = function()
            return getRaid().CrowdControlMCedRaidMember("Mind Control", "Sheeping")
        end
    })
end, function()
    return Instance.ZG()
end)

function MoronBox.Core.Bosses.Hakkar.IsAtHakkar()
    if MoronBox.Registry[MODULE_NAME] and MoronBox.Registry[MODULE_NAME].IsAtHakkar then
        return MoronBox.Registry[MODULE_NAME].IsAtHakkar()
    end
end

function MoronBox.Core.Bosses.Hakkar.TargetingPostFocus()
    if MoronBox.Registry[MODULE_NAME] and MoronBox.Registry[MODULE_NAME].TargetingPostFocus then
        return MoronBox.Registry[MODULE_NAME].TargetingPostFocus()
    end
end

function MoronBox.Core.Bosses.Hakkar.CrowdControlMCedRaidMember()
    if MoronBox.Registry[MODULE_NAME] and MoronBox.Registry[MODULE_NAME].CrowdControlMCedRaidMember then
        return MoronBox.Registry[MODULE_NAME].CrowdControlMCedRaidMember()
    end
end
