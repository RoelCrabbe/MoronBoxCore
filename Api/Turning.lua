--[####################################################################################################]--
--[####################################### AUTO TURN TO TARGET ########################################]--
--[####################################################################################################]--

local myClass = UnitClass("player")
local myName = UnitName("player")
local myRace = UnitRace("player")

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local MAT = CreateFrame("Button", "XFTF", UIParent)

for _, event in ipairs({"UI_ERROR_MESSAGE", "AUTOFOLLOW_END"}) do
    MAT:RegisterEvent(event)
end

local function HandleFollow(delay)
	if not mb_iamFocus() and mb_imRangedDPS() and mb_unitInRange(MBID[MB_raidLeader]) then
		FollowByName(MB_raidLeader, 1)
		local now = GetTime()
		MB_savedBinding.Time = now + delay
		SetBinding("2", "MOVEBACKWARD")
		SetBinding("3", "MOVEBACKWARD")
		MB_savedBinding.Active = true
	end
end

function MAT:OnEvent(event, arg1)
	if not MB_raidAssist.AutoTurnToTarget then return end

	if event == "UI_ERROR_MESSAGE" then
		if arg1 == "Target needs to be in front of you" then
			HandleFollow(1.5)
		elseif arg1 == "Can't do that while moving" then
			local now = GetTime()
			if not MB_savedBinding.Active and (now > MB_savedBinding.Time) and (now < MB_savedBinding.Time + 0.5) and mb_unitInRange(MBID[MB_raidLeader]) then
				HandleFollow(0.75)
			end
		end
	elseif event == "AUTOFOLLOW_END" then
		MB_savedBinding.Time = GetTime() + 0.15
		MB_savedBinding.Active = true
	end
end

function MAT:OnUpdate()
	if not MB_savedBinding.Active then return end

	if GetTime() > MB_savedBinding.Time then
		SetBinding("2", MB_savedBinding.Binding2)
		SetBinding("3", MB_savedBinding.Binding3)
		MB_savedBinding.Active = false
	end
end

MAT:SetScript("OnEvent", MAT.OnEvent)
MAT:SetScript("OnUpdate", MAT.OnUpdate)