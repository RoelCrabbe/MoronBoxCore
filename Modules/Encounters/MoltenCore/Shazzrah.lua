-- [[ Shazzrah Bossing Logic ]] --

-- Bossname
local BOSS_KEY = "Shazzrah"

-- Values for internal begind the scene logic. Like addon messages and table lookups
local ENCOUNTER_KEY = string.upper(string.gsub(BOSS_KEY, " ", "_"))
local MODULE_NAME = "MODULE_" .. ENCOUNTER_KEY

-- Helper values
local myClass = UnitClass("player")

MoronBox:RegisterModule(MODULE_NAME, function()
    local BoxStrategy = true
    local ArcanePotsStrategy = true

    getBosses().Register(ENCOUNTER_KEY, {
        boss        = { "Shazzrah" },
        onEngage    = function() getApi().CdRaidWarning(">> Fighting Shazzrah <<") end,
        onDisengage = function() getApi().CdRaidWarning(">> Shazzrah Defeated <<") end,
        onActive    = function()
            if ArcanePotsStrategy then
                getCons().PotionsWhenPossible("Greater Arcane Protection Potion")
            end

            if myClass == "Mage" and getCore().MyClassAlphabeticalOrder() ~= 1 then
                if UnitName("target") == "Shazzrah" and not getAura().HasBuffOrDebuff("Detect Magic", "target", "debuff") then
                    CastSpellByName("Detect Magic")
                end
            end

            if myClass == "Priest" and getCore().MyClassAlphabeticalOrder() ~= 1 then
                local focId = getCoreState().MBID[getConfigState().RaidLeader]
                if focId then
                    local targetId = focId .. "target"
                    if UnitName(targetId) == "Shazzrah" and not getAura().HasBuffOrDebuff("Deaden Magic", targetId, "buff") then
                        TargetUnit(targetId)
                        CastSpellByName("Dispel Magic")
                    end
                end
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

function MoronBox.Core.Bosses.Shazzrah.TargetingPreFocus()
    if MoronBox.Registry[MODULE_NAME] and MoronBox.Registry[MODULE_NAME].TargetingPreFocus then
        return MoronBox.Registry[MODULE_NAME].TargetingPreFocus()
    end
end

function MoronBox.Core.Bosses.Shazzrah.TargetingPostFocus()
    if MoronBox.Registry[MODULE_NAME] and MoronBox.Registry[MODULE_NAME].TargetingPostFocus then
        return MoronBox.Registry[MODULE_NAME].TargetingPostFocus()
    end
end
