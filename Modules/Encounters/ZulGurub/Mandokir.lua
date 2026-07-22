-- [[ Mandokir Bossing Logic ]] --

-- Bossname
local BOSS_KEY = "Mandokir"

-- Values for internal begind the scene logic. Like addon messages and table lookups
local ENCOUNTER_KEY = string.upper(string.gsub(BOSS_KEY, " ", "_"))
local MODULE_NAME = "MODULE_" .. ENCOUNTER_KEY

-- Initalize
MoronBox.Core.Bosses.Mandokir = MoronBox.Core.Bosses.Mandokir or {}

MoronBox:RegisterModule(MODULE_NAME, function()
    local BoxStrategy = true

    getBosses().Register(ENCOUNTER_KEY, {
        boss                = { "Bloodlord Mandokir" },
        guardians           = { "Ohgan" },
        onEngage            = function() getApi().CdRaidWarning(">> Fighting Mandokir <<") end,
        onDisengage         = function() getApi().CdRaidWarning(">> Mandokir Defeated <<") end,
        disableHitDetection = true,
        overrideDetectDeath = true,
        onBossYell          = function(arg1)
            if string.find(arg1, "I'll feed your souls to Hakkar himself!") then
                getBosses().StartEncounter(ENCOUNTER_KEY)
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
                getRaid().AssistFocus()
                return true
            end
            return false
        end
    })
end, function()
    return Instance.ZG()
end)

function MoronBox.Core.Bosses.Mandokir.TargetingPostFocus()
    if MoronBox.Registry[MODULE_NAME] and MoronBox.Registry[MODULE_NAME].TargetingPostFocus then
        return MoronBox.Registry[MODULE_NAME].TargetingPostFocus()
    end
end
