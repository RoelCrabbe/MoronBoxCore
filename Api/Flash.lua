--[####################################################################################################]--
--[######################################## FLASH FRAME EVENTS ########################################]--
--[####################################################################################################]--

local myClass = UnitClass("player")
local myName = UnitName("player")
local myRace = UnitRace("player")

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local IndicatorFrame = CreateFrame("Frame", nil, UIParent)

IndicatorFrame.FlashTime = GetTime()
IndicatorFrame.FlashColor = { red = 0, green = 0, blue = 0, alpha = 0 }
IndicatorFrame.PulseAlphaValue = 0
IndicatorFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
IndicatorFrame:RegisterEvent("UI_ERROR_MESSAGE")

local function LoadTexture(point, width, height)
	local tex = IndicatorFrame:CreateTexture(nil, "BACKGROUND")
	tex:SetTexture(1.0, 0.0, 0.0, 0.4)
	if width then tex:SetWidth(width) end
	if height then tex:SetHeight(height) end
	tex:SetPoint(point, 0, 0)
	return tex
end

local screenW, screenH = GetScreenWidth(), GetScreenHeight()
local scale = UIParent:GetEffectiveScale()
local t1 = LoadTexture("TOP", screenW, screenH / 20 / scale)
local t2 = LoadTexture("BOTTOM", screenW, screenH / 20 / scale)
local t3 = LoadTexture("LEFT", screenH / 20 / scale, nil)
local t4 = LoadTexture("RIGHT", screenH / 20 / scale, nil)

IndicatorFrame:SetPoint("CENTER", 0, 0)

local function FlashFrameFlashHandler()
	if IndicatorFrame.FlashTime > GetTime() then
		for _, tex in ipairs({t1, t2, t3, t4}) do
			tex:SetTexture(IndicatorFrame.FlashColor.red,
				IndicatorFrame.FlashColor.green,
				IndicatorFrame.FlashColor.blue,
				IndicatorFrame.FlashColor.alpha)
		end
		return
	end

	local leaderID = MBID[MB_raidLeader]
	if leaderID and UnitName(leaderID.."targettarget") == myName and UnitIsEnemy("target", "player") then
		if FindInTable(MB_tankList, myName) then
			for _, tex in ipairs({t1, t2, t3, t4}) do
				tex:SetTexture(1.0, 1.0, 1.0, 0.4)
			end
		else
			for _, tex in ipairs({t1, t2, t3, t4}) do
				tex:SetTexture(1.0, 0.0, 0.0, IndicatorFrame.PulseAlphaValue)
			end
			IndicatorFrame.PulseAlphaValue = IndicatorFrame.PulseAlphaValue + 0.005
			if IndicatorFrame.PulseAlphaValue > 1 then IndicatorFrame.PulseAlphaValue = 0 end
		end
		return
	end

	for _, tex in ipairs({t1, t2, t3, t4}) do
		tex:SetTexture(1.0, 0.0, 0.0, 0)
	end
end

local function TableContains(tbl, val)
    for _, v in ipairs(tbl) do
        if v == val then
            return true
        end
    end
    return false
end

local function FlashFrameEventHandler()
	if not MB_raidAssist.Frameflash then return end

	if event == "PLAYER_ENTERING_WORLD" then
		IndicatorFrame:SetWidth(GetScreenWidth())
		IndicatorFrame:SetHeight(GetScreenHeight())
		t1:SetWidth(GetScreenWidth())
		t2:SetWidth(GetScreenWidth())
		t3:SetHeight(GetScreenHeight() - t1:GetHeight() - t2:GetHeight())
		t4:SetHeight(GetScreenHeight() - t1:GetHeight() - t2:GetHeight())
	elseif event == "UI_ERROR_MESSAGE" then
		local msgs = {
			"Target needs to be in front of you",
			"Out of range.",
			"Target not in line of sight",
			"Target too close"
		}
		if MB_raidLeader and MB_raidLeader ~= myName and TableContains(msgs, arg1) then
			IndicatorFrame.FlashTime = GetTime() + 1
			IndicatorFrame.FlashColor = { red = 1, green = 1, blue = 0, alpha = 0.4 }
		end
	end
end

IndicatorFrame:SetScript("OnEvent", FlashFrameEventHandler)
IndicatorFrame:SetScript("OnUpdate", FlashFrameFlashHandler)
