-- [[ Jindo Bossing Logic ]] --

-- Bossname
local BOSS_KEY = "Jindo"

-- Values for internal begind the scene logic. Like addon messages and table lookups
local ENCOUNTER_KEY = string.upper(string.gsub(BOSS_KEY, " ", "_"))
local MODULE_NAME = "MODULE_" .. ENCOUNTER_KEY

-- Initalize
MoronBox.Core.Bosses.Jindo = MoronBox.Core.Bosses.Jindo or {}

MoronBox:RegisterModule(MODULE_NAME, function()
    local BoxStrategy = true

    getBosses().Register(ENCOUNTER_KEY, {
        boss                = { "Jin'do the Hexxer" },
        guardians           = { "Shade of Jin'do", "Powerful Healing Ward", "Brain Wash Totem" },
        onEngage            = function() getApi().CdRaidWarning(">> Fighting Mandokir <<") end,
        onDisengage         = function() getApi().CdRaidWarning(">> Mandokir Defeated <<") end,
        disableHitDetection = true,
        overrideDetectDeath = true,
        onBossYell          = function(arg1)
            if string.find(arg1, "Welcome to the great show, friends. Step right up to die!") then
                getBosses().StartEncounter(ENCOUNTER_KEY)
            end
        end
    })

    local TargetNearestDistanceChanged = false

    MoronBox:RegisterExpose({
        IsAtJindo = function()
            if not BoxStrategy then
                return false
            end

            return getBosses().IsActive(ENCOUNTER_KEY)
        end,
        TargetingPostFocus = function()
            if not getBosses().Jindo.IsAtJindo() then
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
                for _ = 1, 3 do
                    if UnitName("target") == "Shade of Jin\'do" and not getUnit().IsDead("target") then
                        return true
                    end

                    TargetNearestEnemy()
                end

                getRaid().AssistFocus()
                return true
            elseif getCore().ImRangedDPS() or getCore().ImHealer() then
                for _ = 1, 6 do
                    local targetName = UnitName("target")

                    if targetName == "Shade of Jin\'do" and not getUnit().IsDead("target") then
                        return true
                    end

                    if targetName == "Powerful Healing Ward" and not getUnit().IsDead("target") then
                        return true
                    end

                    if targetName == "Brain Wash Totem" and not getUnit().IsDead("target") then
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

function MoronBox.Core.Bosses.Jindo.IsAtJindo()
    if MoronBox.Registry[MODULE_NAME] and MoronBox.Registry[MODULE_NAME].IsAtJindo then
        return MoronBox.Registry[MODULE_NAME].IsAtJindo()
    end
end

function MoronBox.Core.Bosses.Jindo.TargetingPostFocus()
    if MoronBox.Registry[MODULE_NAME] and MoronBox.Registry[MODULE_NAME].TargetingPostFocus then
        return MoronBox.Registry[MODULE_NAME].TargetingPostFocus()
    end
end
