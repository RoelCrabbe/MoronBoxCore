-- [[ Venoxis Bossing Logic ]] --

-- Bossname
local BOSS_KEY = "Arlokk"

-- Values for internal begind the scene logic. Like addon messages and table lookups
local ENCOUNTER_KEY = string.upper(string.gsub(BOSS_KEY, " ", "_"))
local MODULE_NAME = "MODULE_" .. ENCOUNTER_KEY

-- Initalize
MoronBox.Core.Bosses.Arlokk = MoronBox.Core.Bosses.Arlokk or {}

MoronBox:RegisterModule(MODULE_NAME, function()
    local BoxStrategy = true

    getBosses().Register(ENCOUNTER_KEY, {
        boss                = { "High Priestess Arlokk" },
        guardians           = { "Zulian Prowler" },
        onEngage            = function() getApi().CdRaidWarning(">> Fighting Arlokk <<") end,
        onDisengage         = function() getApi().CdRaidWarning(">> Arlokk Defeated <<") end,
        disableHitDetection = true,
        onBossYell          = function(arg1)
            if string.find(arg1, "Bethekk, your priestess calls upon your might!") then
                getBosses().StartEncounter(ENCOUNTER_KEY)
            elseif string.find(arg1, "At last, I am free of the Soulflayer!") then
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

function MoronBox.Core.Bosses.Arlokk.TargetingPostFocus()
    if MoronBox.Registry[MODULE_NAME] and MoronBox.Registry[MODULE_NAME].TargetingPostFocus then
        return MoronBox.Registry[MODULE_NAME].TargetingPostFocus()
    end
end
