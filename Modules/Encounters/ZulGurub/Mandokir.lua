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
        IsAtMandokir = function()
            if not BoxStrategy then
                return false
            end

            return getBosses().IsActive(ENCOUNTER_KEY)
        end,
        TargetingPostFocus = function()
            if not getBosses().Mandokir.IsAtMandokir() then
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
        end,
        ClearGaze = function()
            if not getAura().HasBuffOrDebuff("Threatening Gaze", "player", "debuff") then
                return false
            end

            if getSpells().ImBusy() then
                SpellStopCasting()
            end

            TargetUnit("player")
            return true
        end
    })
end, function()
    return Instance.ZG()
end)

function MoronBox.Core.Bosses.Mandokir.IsAtMandokir()
    if MoronBox.Registry[MODULE_NAME] and MoronBox.Registry[MODULE_NAME].IsAtMandokir then
        return MoronBox.Registry[MODULE_NAME].IsAtMandokir()
    end
end

function MoronBox.Core.Bosses.Mandokir.TargetingPostFocus()
    if MoronBox.Registry[MODULE_NAME] and MoronBox.Registry[MODULE_NAME].TargetingPostFocus then
        return MoronBox.Registry[MODULE_NAME].TargetingPostFocus()
    end
end

function MoronBox.Core.Bosses.Mandokir.ClearGaze()
    if MoronBox.Registry[MODULE_NAME] and MoronBox.Registry[MODULE_NAME].ClearGaze then
        return MoronBox.Registry[MODULE_NAME].ClearGaze()
    end
end
