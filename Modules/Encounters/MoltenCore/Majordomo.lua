-- [[ Majordomo Executus Bossing Logic ]] --

-- Bossname
local BOSS_KEY = "Majordomo Executus"

-- Values for internal begind the scene logic. Like addon messages and table lookups
local ENCOUNTER_KEY = string.upper(string.gsub(BOSS_KEY, " ", "_"))
local MODULE_NAME = "MODULE_" .. ENCOUNTER_KEY

MoronBox:RegisterModule(MODULE_NAME, function()
    local BoxStrategy = true
    local FirePotsStrategy = true

    getBosses().Register(ENCOUNTER_KEY, {
        boss        = { "Majordomo Executus" },
        guardians   = { "Flamewaker Healer", "Flamewaker Elite" },
        onEngage    = function() getApi().CdRaidWarning(">> Fighting Majordomo <<") end,
        onDisengage = function() getApi().CdRaidWarning(">> Majordomo has fled! <<") end,
        onBossYell  = function(arg1)
            if string.find(arg1, "I go now to summon the lord whose house this is") then
                getBosses().EndEncounter(ENCOUNTER_KEY)
            end
        end,
        onActive    = function()
            if FirePotsStrategy then
                getCons().PotionsWhenPossible("Greater Fire Protection Potion")
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
    return Instance.MC()
end)

function MoronBox.Core.Bosses.Majordomo.TargetingPostFocus()
    if MoronBox.Registry[MODULE_NAME] and MoronBox.Registry[MODULE_NAME].TargetingPostFocus then
        return MoronBox.Registry[MODULE_NAME].TargetingPostFocus()
    end
end
