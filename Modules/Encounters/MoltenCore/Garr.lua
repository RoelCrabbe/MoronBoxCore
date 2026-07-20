-- [[ Garr Bossing Logic ]] --

-- Bossname
local BOSS_KEY = "Garr"

-- Values for internal begind the scene logic. Like addon messages and table lookups
local ENCOUNTER_KEY = string.upper(string.gsub(BOSS_KEY, " ", "_"))
local MODULE_NAME = "MODULE_" .. ENCOUNTER_KEY

-- Helpers
local myName = UnitName("player")

MoronBox:RegisterModule(MODULE_NAME, function()
    local BoxStrategy = true
    local TankAssignment = { -- [Tank Number] = [Number of Players Assigned]
        [1] = 2,             -- Main Tank
        [2] = 2,             -- Off Tank
        [3] = 1,             -- Extra Tank
        [4] = 1              -- Extra Tank
    }

    local function AssignHealersToTanks()
        if not getCore().ImHealer() then
            return
        end

        local healerList = getCoreState().HealerList

        local myPosition = nil
        for i, name in ipairs(healerList) do
            if name == myName then
                myPosition = i
                break
            end
        end

        if not myPosition then
            return
        end

        local healerIndex = 0
        local raidTanks = getCoreState().RaidTanks

        for tankNum, tankName in ipairs(raidTanks) do
            local healersNeeded = TankAssignment[tankNum] or 0

            for h = 1, healersNeeded do
                healerIndex = healerIndex + 1
                if healerIndex == myPosition then
                    getApi().CdMessage("Assigning myself to focusheal " .. tankName .. ".")
                    getConfigState().AssignedHealTarget = tankName
                    return true
                end
            end
        end
    end

    getBosses().Register(ENCOUNTER_KEY, {
        boss        = { "Garr" },
        guardians   = { "Firesworn" },
        onEngage    = function() getApi().CdRaidWarning(">> Fighting Garr <<") end,
        onDisengage = function() getApi().CdRaidWarning(">> Garr Defeated <<") end,
        onActive    = function()
            if not getConfigState().AssignedHealTarget and table.getn(getCoreState().HealerList) > 0 then
                AssignHealersToTanks()
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

function MoronBox.Core.Bosses.Garr.TargetingPostFocus()
    if MoronBox.Registry[MODULE_NAME] and MoronBox.Registry[MODULE_NAME].TargetingPostFocus then
        return MoronBox.Registry[MODULE_NAME].TargetingPostFocus()
    end
end
