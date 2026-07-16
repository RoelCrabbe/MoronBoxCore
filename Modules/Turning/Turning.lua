-- [[ Auto Turn TO Target ]] --
---@diagnostic disable: undefined-global

local NAME = "Moron Auto Turn"
local MODULE_NAME = "MODULE_" .. string.upper(string.gsub(NAME, " ", "_"))

local SavedBinding = { Active = false, Time = 0, Binding2 = "SM_MACRO2", Binding3 = "SM_MACRO3" }

local MoronBoxAutoTurn

MoronBox:RegisterModule(MODULE_NAME, function()
    MoronBoxAutoTurn = Register(MODULE_NAME)

    do
        for _, event in {
            "UI_ERROR_MESSAGE",
            "AUTOFOLLOW_END"
        }
        do
            MoronBoxAutoTurn:RegisterEvent(event)
        end
    end

    local function HandleFollow(delay)
        local now = GetTime()

        if not ConfigState.RaidLeader then
            return
        end

        if ImFocus() then
            return
        end

        if InRange(MBID[ConfigState.RaidLeader]) then
            FollowByName(ConfigState.RaidLeader, 1)
            SavedBinding.Time = now + delay
            SetBinding("2", "MOVEBACKWARD")
            SetBinding("3", "MOVEBACKWARD")
            SavedBinding.Active = true
        end
    end

    MoronBoxAutoTurn:SetScript("OnEvent", function()
        local now = GetTime()

        if (event == "UI_ERROR_MESSAGE") then
            if (arg1 == "Target needs to be in front of you") then
                HandleFollow(1.5)
            elseif (arg1 == "Can't do that while moving" and InRange(MBID[ConfigState.RaidLeader])) then
                if not SavedBinding.Active and (now > SavedBinding.Time) and (now < SavedBinding.Time + 0.5) then
                    HandleFollow(0.75)
                end
            end
        elseif (event == "AUTOFOLLOW_END") then
            SavedBinding.Time = now + 0.25
            SavedBinding.Active = true
        end
    end)

    MoronBoxAutoTurn:SetScript("OnUpdate", function()
        local now = GetTime()

        if (now > SavedBinding.Time) then
            SetBinding("2", SavedBinding.Binding2)
            SetBinding("3", SavedBinding.Binding3)
            SavedBinding.Active = false
        end
    end)
end, function()
    -- Load condition: only active when its enabled and we are a ranged DPS.
    return MB_raidAssist.AutoTurnToTarget and ImRangedDPS()
end, function()
    Unregister(MODULE_NAME)
end)
