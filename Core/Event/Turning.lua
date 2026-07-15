if not MB_raidAssist.AutoTurnToTarget then
    return
end

local SavedBinding = { Active = false, Time = 0, Binding2 = "SM_MACRO2", Binding3 = "SM_MACRO3" }

local MAT = CreateFrame("Button", "XFTF", UIParent)

do
    for _, event in {
        "UI_ERROR_MESSAGE",
        "AUTOFOLLOW_END"
    }
    do
        MAT:RegisterEvent(event)
    end
end

local function HandleFollow(delay)
    local now = GetTime()

    if not MB_raidLeader then
        return
    end

    if ImFocus() then
        return
    end

    if ImRangedDPS() and UnitInRange(MBID[MB_raidLeader]) then
        FollowByName(MB_raidLeader, 1)
        SavedBinding.Time = now + delay
        SetBinding("2", "MOVEBACKWARD")
        SetBinding("3", "MOVEBACKWARD")
        SavedBinding.Active = true
    end
end

MAT:SetScript("OnEvent", function()
    local now = GetTime()

    if (event == "UI_ERROR_MESSAGE") then
        if (arg1 == "Target needs to be in front of you") then
            HandleFollow(1.5)
        elseif (arg1 == "Can't do that while moving" and UnitInRange(MBID[MB_raidLeader])) then
            if not SavedBinding.Active and (now > SavedBinding.Time) and (now < SavedBinding.Time + 0.5) then
                HandleFollow(0.75)
            end
        end
    elseif (event == "AUTOFOLLOW_END") then
        SavedBinding.Time = now + 0.25
        SavedBinding.Active = true
    end
end)

MAT:SetScript("OnUpdate", function()
    local now = GetTime()

    if (now > SavedBinding.Time) then
        SetBinding("2", SavedBinding.Binding2)
        SetBinding("3", SavedBinding.Binding3)
        SavedBinding.Active = false
    end
end)
