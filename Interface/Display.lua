------------------------------------------------------------------------------------------------------
----------------------------------------------- FRAME! -----------------------------------------------
------------------------------------------------------------------------------------------------------

function MBC:InterfaceOptionsFrame()

    local AddonGUI = MBC:CreateOptionsWindow("MoronBoxCore")
    local Description = AddonGUI:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    Description:SetPoint("TOPLEFT", AddonGUI.Title, "BOTTOMLEFT", 0, -10)
    Description:SetWidth(AddonGUI:GetParent():GetWidth() - 30)
    Description:SetJustifyH("LEFT")
    Description:SetHeight(0)
    Description:SetText(
        MBC:ApplyTextColor("MoronBoxCore", MBC.COLORS.Highlight) ..
        MBC:ApplyTextColor(" is the essential foundation of the Moron Multi Box collection. It delivers crucial mathematical functions and indispensable tools that all associated add-ons rely on. This core component fundamentally empowers the ", MBC.COLORS.Text) ..
        MBC:ApplyTextColor("MoronBox", MBC.COLORS.Highlight) ..
        MBC:ApplyTextColor(" ecosystem, guaranteeing efficient multiboxing and ensuring seamless gameplay, ultimately elevating the user experience.", MBC.COLORS.Text)
    )    
    
    local Button = MBC:CreateButton(AddonGUI, MBC.Button.Fit, MBC.Button.XXLarge, "Open General Menu")
    Button:SetPoint("CENTER", AddonGUI, "CENTER", 0, 0)
    Button:SetScript("OnClick", function()  
        MBC:HideFrameIfShown(InterfaceOptionsFrame)
        MBC:HideFrameIfShown(GameMenuFrame)   
        MBC:CreateSettingsWindow()
    end)

    MBC:ApplyCustomFont(Description, 15)

    AddonGUI.Description = Description
    AddonGUI.Button = Button
end

function MBC:CreateSettingsWindow()

    local SettingsFrame = MBC:CreateGeneralWindow(UIParent, "Moron Box Menu", 500, 600)
    local Description = SettingsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    Description:SetPoint("TOPLEFT", SettingsFrame, "TOPLEFT", 20, -60)
    Description:SetWidth(SettingsFrame:GetWidth())
    Description:SetJustifyH("LEFT")
    Description:SetHeight(0)
    Description:SetText(
        MBC:ApplyTextColor("Your addons that depend on ", MBC.COLORS.Text) ..
        MBC:ApplyTextColor("MoronBoxCore", MBC.COLORS.Highlight) .. 
        MBC:ApplyTextColor(":\n\n", MBC.COLORS.Text)
    )

    local Addons = MBC:GetDependingAddons()
    local OffsetY = -100
    
    for _, Addon in InTable(Addons) do

        local AddonButton = MBC:CreateButton(SettingsFrame, MBC.Button.Fit, MBC.Button.Large, Addon)
        AddonButton:SetPoint("TOPLEFT", SettingsFrame, "TOPLEFT", 20, OffsetY)

        AddonButton:SetScript("OnClick", function()
            MBC:OpenAddonGeneralWindow(Addon)
            SettingsFrame:Hide()
        end)
    
        OffsetY = OffsetY - 40
    end

    SettingsFrame:SetHeight(MBC:CalcRespHeight(#Addons, 100, MBC.Button.Large, 15))

    SettingsFrame.ReturnButton:SetScript("OnClick", function()
        SettingsFrame:Hide()
        InterfaceOptionsFrame:Show()
    end)

    SettingsFrame.CloseButton:SetScript("OnClick", function()
        SettingsFrame:Hide()
    end)

    SettingsFrame.Line:Hide()
    SettingsFrame.GroupText:Hide()
    MBC:ApplyCustomFont(Description, 15)

    SettingsFrame.Description = Description

    return SettingsFrame
end