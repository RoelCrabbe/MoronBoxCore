-- [[ Marli Bossing Logic ]] --

-- Bossname
local BOSS_KEY = "Marli"

-- Values for internal begind the scene logic. Like addon messages and table lookups
local ENCOUNTER_KEY = string.upper(string.gsub(BOSS_KEY, " ", "_"))
local MODULE_NAME = "MODULE_" .. ENCOUNTER_KEY

-- Initalize
MoronBox.Core.Bosses.Marli = MoronBox.Core.Bosses.Marli or {}

MoronBox:RegisterModule(MODULE_NAME, function()
    local BoxStrategy = true

    getBosses().Register(ENCOUNTER_KEY, {
        boss                = { "High Priestess Mar\'li" },
        guardians           = { "Witherbark Speaker", "Spawn of Mar\'li" },
        onEngage            = function() getApi().CdRaidWarning(">> Fighting Mar\'li <<") end,
        onDisengage         = function() getApi().CdRaidWarning(">> Mar\'li Defeated <<") end,
        disableHitDetection = true,
        onBossYell          = function(arg1)
            if string.find(arg1, "Draw me to your web mistress Shadra. Unleash your venom!") then
                getBosses().StartEncounter(ENCOUNTER_KEY)
            elseif string.find(arg1, "Bless you mortal for this release. Hakkar controls me no longer...") then
                getBosses().EndEncounter(ENCOUNTER_KEY)
            end
        end,
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
                    if targetName == "Spawn of Mar\'li" and not getUnit().IsDead("target") then
                        return true
                    end

                    if targetName == "Witherbark Speaker" and not getUnit().IsDead("target") then
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

function MoronBox.Core.Bosses.Marli.TargetingPostFocus()
    if MoronBox.Registry[MODULE_NAME] and MoronBox.Registry[MODULE_NAME].TargetingPostFocus then
        return MoronBox.Registry[MODULE_NAME].TargetingPostFocus()
    end
end
