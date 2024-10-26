------------------------------------------------------------------------------------------------------
----------------------------------------------- FRAME! -----------------------------------------------
------------------------------------------------------------------------------------------------------

function MBC:InterfaceOptionsFrame()

    local AddonGUI = self:CreateOptionsWindow(self:SL("MoronBoxCore"))
    local Description = AddonGUI:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    Description:SetPoint("TOPLEFT", AddonGUI.Title, "BOTTOMLEFT", 0, -10)
    Description:SetWidth(AddonGUI:GetParent():GetWidth() - 30)
    Description:SetJustifyH("LEFT")
    Description:SetHeight(0)
    Description:SetText(self:SL("Intro"))    
    
    local Button = self:CreateButton(AddonGUI, MBC.Button.Fit, MBC.Button.XXLarge, "Open General Menu")
    Button:SetPoint("CENTER", AddonGUI, "CENTER", 0, 0)
    Button:SetScript("OnClick", function()  
        self:HideFrameIfShown(InterfaceOptionsFrame)
        self:HideFrameIfShown(GameMenuFrame)   
        self:CreateSettingsWindow()
    end)

    self:ApplyCustomFont(Description, MBC.Font.InformationSize)

    AddonGUI.Description = Description
    AddonGUI.Button = Button
end

function MBC:CreateSettingsWindow()

    local SettingsFrame = self:CreateGeneralWindow(UIParent, self:SL("Moron Box Menu"), 500, 600)
    local Description = SettingsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    Description:SetPoint("TOPLEFT", SettingsFrame, "TOPLEFT", 20, -60)
    Description:SetWidth(SettingsFrame:GetWidth())
    Description:SetJustifyH("LEFT")
    Description:SetHeight(0)
    Description:SetText(self:SL("Depending"))

    local Addons = self:GetDependingAddons()
    local OffsetY = -100
    
    for _, Addon in ipairs(Addons) do

        local AddonButton = self:CreateButton(SettingsFrame, MBC.Button.Fit, MBC.Button.Large, Addon)
        AddonButton:SetPoint("TOPLEFT", SettingsFrame, "TOPLEFT", 20, OffsetY)

        AddonButton:SetScript("OnClick", function()
            self:OpenAddonGeneralWindow(Addon)
            SettingsFrame:Hide()
        end)
    
        OffsetY = OffsetY - 40
    end

    SettingsFrame.ReturnButton:SetScript("OnClick", function()
        SettingsFrame:Hide()
        InterfaceOptionsFrame:Show()
    end)

    SettingsFrame.CloseButton:SetScript("OnClick", function()
        SettingsFrame:Hide()
    end)
    
    SettingsFrame:SetHeight(self:CalcRespHeight(#Addons, 100, MBC.Button.Large, 15))
    self:ApplyCustomFont(Description, MBC.Font.InformationSize)

    SettingsFrame.Description = Description
    SettingsFrame.Line:Hide()
    SettingsFrame.GroupText:Hide()

    return SettingsFrame
end