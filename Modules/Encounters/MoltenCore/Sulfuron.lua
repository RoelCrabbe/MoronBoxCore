-- [[ Sulfuron Bossing Logic ]] --

-- Bossname
local BOSS_KEY = "Sulfuron Harbinger"

-- Values for internal begind the scene logic. Like addon messages and table lookups
local ENCOUNTER_KEY = string.upper(string.gsub(BOSS_KEY, " ", "_"))
local MODULE_NAME = "MODULE_" .. ENCOUNTER_KEY

-- Initalize
MoronBox.Core.Bosses.Sulfuron = MoronBox.Core.Bosses.Sulfuron or {}

MoronBox:RegisterModule(MODULE_NAME, function()
    local BoxStrategy = true
    local ShadowPotsStrategy = false

    getBosses().Register(ENCOUNTER_KEY, {
        boss        = { "Sulfuron Harbinger" },
        guardians   = { "Flamewaker Priest" },
        onEngage    = function() getApi().CdRaidWarning(">> Fighting Sulfuron Harbinger <<") end,
        onDisengage = function() getApi().CdRaidWarning(">> Sulfuron Harbinger Defeated <<") end,
        onActive    = function()
            if ShadowPotsStrategy then
                getCons().PotionsWhenPossible("Greater Shadow Protection Potion")
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

function MoronBox.Core.Bosses.Sulfuron.TargetingPostFocus()
    if MoronBox.Registry[MODULE_NAME] and MoronBox.Registry[MODULE_NAME].TargetingPostFocus then
        return MoronBox.Registry[MODULE_NAME].TargetingPostFocus()
    end
end
