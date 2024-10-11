-------------------------------------------------------------------------------
-- Interface Addon GUI Window {{{
-------------------------------------------------------------------------------

function MBC:CreateOptionsWindow(aName)

    local OptionsFrame = CreateFrame("Frame", nil, InterfaceOptionsFramePanelContainer)
    OptionsFrame.name = aName -- Do not change .name here
    InterfaceOptions_AddCategory(OptionsFrame)

    local Title = OptionsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    Title:SetText(MBC:ApplyTextColor(aName, MBC.COLORS.Title))
    Title:SetPoint("TOPLEFT", 16, -16)
    MBC:ApplyCustomFont(Title, 20)

    OptionsFrame.Title = Title
    return OptionsFrame
end

-------------------------------------------------------------------------------
-- Buttons {{{
-------------------------------------------------------------------------------

function MBC:CreateButton(Parent, Width, Height, Label)
    if not Parent or not Label then return end

    local Button = CreateFrame("Button", nil, Parent)
    Button:SetSize(Width, Height)
    Button:SetBackdrop(MBC.BACKDROPS.Basic)
    Button:SetBackdropColor(unpack(MBC.COLORS.Background))
    MBC:ApplyHoverEffect(Button, MBC.COLORS.Background, MBC.COLORS.HoverBackground)

    local ButtonText = Button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    ButtonText:SetPoint("CENTER", Button, "CENTER", 0, 0)
    ButtonText:SetTextColor(unpack(MBC.COLORS.TextLight))
    ButtonText:SetFont(MBC:GetFont("MoronFont.ttf"), 15)
    ButtonText:SetText(Label)

    Button.Text = ButtonText
    return Button
end

function MBC:ApplyHoverEffect(Frame, NormalColor, HoverColor)

    local HighlightOverlay = Frame:CreateTexture(nil, "OVERLAY")
    HighlightOverlay:SetAllPoints(Frame)
    HighlightOverlay:SetTexture("Interface\\AddOns\\MoronBoxCore\\Textures\\Highlight.tga")
    HighlightOverlay:SetVertexColor(1, 1, 1, 0.1)
    HighlightOverlay:Hide()

    Frame:SetScript("OnEnter", function(self)
        self:SetBackdropColor(unpack(HoverColor))
        HighlightOverlay:Show()
    end)

    Frame:SetScript("OnLeave", function(self)
        self:SetBackdropColor(unpack(NormalColor))
        HighlightOverlay:Hide()
    end)
end

function MBC:CloseButton(Parent, Width, Height)
    if not Parent then return end

    Width = Width or 16
    Height = Height or 16

    local CloseButton = CreateFrame("Button", nil, Parent)
    CloseButton:SetSize(Width, Height)
    CloseButton:SetNormalTexture("Interface\\AddOns\\MoronBoxCore\\Media\\Icons\\Close.tga")
    CloseButton:SetPushedTexture("Interface\\AddOns\\MoronBoxCore\\Media\\Icons\\Close.tga")
    CloseButton:SetPoint("TOPRIGHT", Parent, "TOPRIGHT", -Width / 2, -Height / 2)

    CloseButton:GetNormalTexture():SetVertexColor(unpack(MBC.COLORS.CloseButtonNormal))
    CloseButton:GetPushedTexture():SetVertexColor(unpack(MBC.COLORS.CloseButtonHover))

    CloseButton:SetScript("OnEnter", function(self)
        self:GetNormalTexture():SetVertexColor(unpack(MBC.COLORS.CloseButtonHover))
    end)

    CloseButton:SetScript("OnLeave", function(self)
        self:GetNormalTexture():SetVertexColor(unpack(MBC.COLORS.CloseButtonNormal))
    end)

    return CloseButton
end

function MBC:ReturnButton(Parent, Width, Height)
    if not Parent then return end

    Width = Width or 16
    Height = Height or 16

    local ReturnButton = CreateFrame("Button", nil, Parent)
    ReturnButton:SetSize(Width, Height)
    ReturnButton:SetNormalTexture("Interface\\AddOns\\MoronBoxCore\\Media\\Icons\\Return.tga")
    ReturnButton:SetPushedTexture("Interface\\AddOns\\MoronBoxCore\\Media\\Icons\\Return.tga")
    ReturnButton:SetPoint("TOPLEFT", Parent, "TOPLEFT", Width / 2, -Height / 2)

    ReturnButton:GetNormalTexture():SetVertexColor(unpack(MBC.COLORS.ReturnButtonNormal))
    ReturnButton:GetPushedTexture():SetVertexColor(unpack(MBC.COLORS.ReturnButtonHover))

    ReturnButton:SetScript("OnEnter", function(self)
        self:GetNormalTexture():SetVertexColor(unpack(MBC.COLORS.ReturnButtonHover))
    end)

    ReturnButton:SetScript("OnLeave", function(self)
        self:GetNormalTexture():SetVertexColor(unpack(MBC.COLORS.ReturnButtonNormal))
    end)

    return ReturnButton
end

function MBC:ToggleButton(Parent, Width, Height)
    if not Parent then return end

    Width = Width or 16
    Height = Height or 16

    local ToggleButton = CreateFrame("Button", nil, Parent)
    ToggleButton:SetSize(Width, Height)
    ToggleButton:SetNormalTexture("Interface\\AddOns\\MoronBoxCore\\Media\\Icons\\Minus.tga")
    ToggleButton:SetPushedTexture("Interface\\AddOns\\MoronBoxCore\\Media\\Icons\\Minus.tga")
    ToggleButton:SetPoint("CENTER", Parent, "RIGHT", -Width, 0)

    ToggleButton:GetNormalTexture():SetVertexColor(unpack(MBC.COLORS.CloseButtonNormal))
    ToggleButton:GetPushedTexture():SetVertexColor(unpack(MBC.COLORS.CloseButtonHover))

    ToggleButton:SetScript("OnEnter", function(self)
        self:GetNormalTexture():SetVertexColor(unpack(MBC.COLORS.CloseButtonHover))
        end)
        
    ToggleButton:SetScript("OnLeave", function(self)
        self:GetNormalTexture():SetVertexColor(unpack(MBC.COLORS.CloseButtonNormal))
    end)

    function UpdateButtonIcon(Item)
        if MBR:ItemExistsInPossibleVendorItems(Item) then
            ToggleButton:SetNormalTexture("Interface\\AddOns\\MoronBoxCore\\Media\\Icons\\Minus.tga")
            ToggleButton:SetPushedTexture("Interface\\AddOns\\MoronBoxCore\\Media\\Icons\\Minus.tga")
            ToggleButton:GetNormalTexture():SetVertexColor(unpack(MBC.COLORS.ReturnButtonNormal))
            ToggleButton:GetPushedTexture():SetVertexColor(unpack(MBC.COLORS.ReturnButtonHover))

            ToggleButton:SetScript("OnEnter", function(self)
                self:GetNormalTexture():SetVertexColor(unpack(MBC.COLORS.CloseButtonHover))
            end)

            ToggleButton:SetScript("OnLeave", function(self)
                self:GetNormalTexture():SetVertexColor(unpack(MBC.COLORS.CloseButtonNormal))
            end)
        else
            ToggleButton:SetNormalTexture("Interface\\AddOns\\MoronBoxCore\\Media\\Icons\\Plus.tga")
            ToggleButton:SetPushedTexture("Interface\\AddOns\\MoronBoxCore\\Media\\Icons\\Plus.tga")
            ToggleButton:GetNormalTexture():SetVertexColor(unpack(MBC.COLORS.CloseButtonNormal))
            ToggleButton:GetPushedTexture():SetVertexColor(unpack(MBC.COLORS.CloseButtonHover))

            ToggleButton:SetScript("OnEnter", function(self)
                self:GetNormalTexture():SetVertexColor(unpack(MBC.COLORS.ReturnButtonHover))
            end)

            ToggleButton:SetScript("OnLeave", function(self)
                self:GetNormalTexture():SetVertexColor(unpack(MBC.COLORS.ReturnButtonNormal))
            end)
        end
    end

    ToggleButton.UpdateButtonIcon = UpdateButtonIcon

    return ToggleButton
end


-------------------------------------------------------------------------------
-- CheckBox {{{
-------------------------------------------------------------------------------

function MBC:CreateCheckButton(Parent, Title, Value, XAsis)
    if not Parent or not Title then return end

    Value = Value or false
    XAsis = XAsis or -48.5

    local CheckButton = CreateFrame("CheckButton", nil, Parent, "OptionsCheckButtonTemplate")
    CheckButton:SetChecked(Value)

    local CheckButtonText = CheckButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    CheckButtonText:SetText(Title)
    CheckButtonText:SetPoint("RIGHT", CheckButton, "LEFT", XAsis, 0)

    CheckButton.CheckButtonText = CheckButtonText
    return CheckButton
end

function MBC:CreateCustomCheckbox(Parent, Val, Width, Height)
    if not Parent then return end 

    Val = Val or false
    Width = Width or 32
    Height = Height or 32

    local Checkbox = CreateFrame("CheckButton", nil, Parent)
    Checkbox:SetSize(Width, Height)
    Checkbox:SetBackdrop(MBC.BACKDROPS.Basic)
    Checkbox:SetBackdropColor(unpack(MBC.COLORS.Charcoal))

    local Checked = Checkbox:CreateTexture(nil, "ARTWORK")
    Checked:SetTexture("Interface\\AddOns\\MoronBoxCore\\Media\\Icons\\Close.tga")
    Checked:SetSize(Width * (2 / 3), Height * (2 / 3))
    Checked:SetVertexColor(unpack(MBC.COLORS.LightBlue))
    Checked:SetPoint("CENTER", Checkbox, "CENTER")
    Checkbox:SetCheckedTexture(Checked)
    Checkbox.Checked = Checked

    Checkbox:SetChecked(Val)

    return Checkbox
end

-------------------------------------------------------------------------------
-- Item Icon {{{
-------------------------------------------------------------------------------

function MBC:CreateItemIcon(Parent, Item, Width, Height)
    if not Parent then return end

    Width = Width or 16
    Height = Height or 16

    local ItemIcon = CreateFrame("Button", nil, Parent)
    ItemIcon:SetSize(Width, Height)
    ItemIcon:SetPoint("CENTER", Parent, "LEFT", 23.5, -1)

    local Texture = ItemIcon:CreateTexture()
    Texture:SetAllPoints()
    Texture:SetTexture(Item.Icon)
    ItemIcon:SetNormalTexture(Texture)
    Parent.Texture = Texture

    return ItemIcon
end

-------------------------------------------------------------------------------
-- Line {{{
-------------------------------------------------------------------------------

function MBC:CreateLine(Parent, Width, Height, OffsetX, OffsetY, Color)
    local Line = Parent:CreateTexture(nil, "ARTWORK")
    Line:SetSize(Width, Height)
    Line:SetPoint("CENTER", Parent, "CENTER", OffsetX, OffsetY)
    Line:SetTexture(1, 1, 1, 1)
    Line:SetVertexColor(unpack(Color))    
    return Line
end

-------------------------------------------------------------------------------
-- Frame {{{
-------------------------------------------------------------------------------

function MBC:CreateFrame(Parent, Backdrop, Width, Height)
    if not Parent or not Backdrop then return end

    Width = Width or 500
    Height = Height or 400

    local NewFrame = CreateFrame("Frame", nil, Parent)
    NewFrame:SetPoint("CENTER", UIParent, "CENTER")
    NewFrame:SetSize(Width, Height)
    NewFrame:SetBackdrop(Backdrop)

    return NewFrame
end

function MBC:CreateGeneralWindow(Parent, TitleText, Width, Height)
    if not Parent then return end

    Width = Width or 500
    Height = Height or 600

    local SettingsFrame = MBC:CreateFrame(Parent, MBC.BACKDROPS.Basic, Width, Height)
    SettingsFrame:SetBackdropColor(unpack(MBC.COLORS.FrameBackground))

    local Title = SettingsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    Title:SetText(MBC:ApplyTextColor(TitleText, MBC.COLORS.Title))
    Title:SetPoint("TOP", SettingsFrame, "TOP", 0, -10)
    MBC:ApplyCustomFont(Title, 30)
    SettingsFrame.Title = Title

    local ReturnButton = MBC:ReturnButton(SettingsFrame, 20, 20)
    SettingsFrame.ReturnButton = ReturnButton

    local CloseButton = MBC:CloseButton(SettingsFrame, 20, 20)
    SettingsFrame.CloseButton = CloseButton

    local FrameHeight = SettingsFrame:GetHeight()
    local LineWidth = SettingsFrame:GetWidth() - 60
    local OffsetY = FrameHeight * 0.5 - 35
    
    MBC:CreateLine(SettingsFrame, LineWidth, 1, 0, -OffsetY, MBC.COLORS.LineColor)
    MBC:CreateAddonGroupText(SettingsFrame)
    MBC:MakeMoveable(SettingsFrame)
    
    return SettingsFrame
end

function MBC:CreateAddonGroupText(Parent)

    local GroupText = Parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    GroupText:SetPoint("CENTER", Parent, "BOTTOM", 0, 20)
    GroupText:SetJustifyH("CENTER")
    GroupText:SetText(
        MBC:ApplyTextColor("This addon is part of the ", MBC.COLORS.Text) ..
        MBC:ApplyTextColor("MoronBox", MBC.COLORS.Highlight) ..
        MBC:ApplyTextColor(" addon group!", MBC.COLORS.Text)
    )

    MBC:ApplyCustomFont(GroupText, 12)
    
    return GroupText
end

function MBC:MakeMoveable(Frame)
    if not Frame then return end

    Frame:SetMovable(true)
    Frame:EnableMouse(true)

    Frame:SetScript("OnMouseDown", function(self)
        self:StartMoving()
    end)

    Frame:SetScript("OnMouseUp", function(self)
        self:StopMovingOrSizing()
    end)
end

