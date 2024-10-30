-------------------------------------------------------------------------------
-- Colors and Backdrop Helpers {{{
-------------------------------------------------------------------------------

function MBC:GetFont(FontFile)
    return "Interface\\AddOns\\MoronBoxCore\\Media\\Fonts\\"..FontFile..".ttf"
end

function MBC:ApplyCustomFont(FontString, Size, Flags)
    if not FontString then return end

    Size = Size or 14
    Flags = Flags or nil

    FontString:SetFont(MBC:GetFont(MBC.Font.DefaultFont), Size, Flags)
end

function MBC:Print(Text)
    return Print(MBC:ApplyTextColor("MoronBox", MBC.Colors.Highlight)..": "..Text)
end

-------------------------------------------------------------------------------
-- Interface Helpers {{{
-------------------------------------------------------------------------------

function MBC:HideFrameIfShown(Frame)
    if Frame:IsShown() then
        HideUIPanel(Frame)
    end
end

function MBC:ShowFrameIfHidden(Frame)
    if not Frame:IsShown() then
        ShowUIPanel(Frame)
    end
end

function MBC:ToggleFrame(Frame)
    if Frame:IsShown() then
        HideUIPanel(Frame)  -- Hide the frame if it's currently shown
    else
        ShowUIPanel(Frame)  -- Show the frame if it's currently hidden
    end
end

MBC.OpenAddonWindows = {}

function MBC:OpenAddonGeneralWindow(Name)
    if MBC.OpenAddonWindows[Name] and MBC.OpenAddonWindows[Name]:IsShown() then
        MBC.OpenAddonWindows[Name] = nil
        return
    end

    if _G[Name] and type(_G[Name].GeneralSettingWindow) == "function" then
        local Frame = _G[Name]:GeneralSettingWindow()
        MBC:ShowFrameIfHidden(Frame)
        MBC.OpenAddonWindows[Name] = Frame
    else
        MBC:Print("No settings menu found for addon: " .. Name)
    end
end

function MBC:CalcRespHeight(NumAddons, BaseHeight, ButtonHeight, ButtonSpacing)
    return BaseHeight + (NumAddons * (ButtonHeight + ButtonSpacing))
end

function MBC:Contains(table, value)
    for _, v in ipairs(table) do
        if v == value then
            return true
        end
    end
    return false
end

function MBC:IsEmptyList(...)
    for _, list in ipairs({...}) do
        if #list > 0 then
            return false
        end
    end
    return true
end
