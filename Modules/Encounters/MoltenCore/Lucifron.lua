-- [[ Lucifron Bossing Logic ]] --

-- Bossname
local BOSS_KEY = "Lucifron"

-- Values for internal begind the scene logic. Like addon messages and table lookups
local ENCOUNTER_KEY = string.upper(string.gsub(BOSS_KEY, " ", "_"))
local MODULE_NAME = "MODULE_" .. ENCOUNTER_KEY

MoronBox:RegisterModule(MODULE_NAME, function()
    local BoxStrategy = true
    local ShadowPotsStrategy = false

    getBosses().Register(ENCOUNTER_KEY, {
        boss        = { "Lucifron" },
        guardians   = { "Flamewaker Protector" },
        onEngage    = function() getApi().CdRaidWarning(">> Fighting Lucifron <<") end,
        onDisengage = function() getApi().CdRaidWarning(">> Lucifron Defeated <<") end,
        onActive    = function()
            getBuffs().RequestFearWard()
            getBuffs().ProcessFearWard()

            if ShadowPotsStrategy then
                getCons().PotionsWhenPossible("Greater Shadow Protection Potion")
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

function MoronBox.Core.Bosses.Lucifron.TargetingPreFocus()
    if MoronBox.Registry[MODULE_NAME] and MoronBox.Registry[MODULE_NAME].TargetingPreFocus then
        return MoronBox.Registry[MODULE_NAME].TargetingPreFocus()
    end
end

function MoronBox.Core.Bosses.Lucifron.TargetingPostFocus()
    if MoronBox.Registry[MODULE_NAME] and MoronBox.Registry[MODULE_NAME].TargetingPostFocus then
        return MoronBox.Registry[MODULE_NAME].TargetingPostFocus()
    end
end
