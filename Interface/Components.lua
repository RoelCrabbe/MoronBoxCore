-------------------------------------------------------------------------------
-- Interface Addon GUI Window {{{
-------------------------------------------------------------------------------

function MBC:CreateOptionsWindow(aName)
    if not aName then return end

    local OptionsFrame = CreateFrame("Frame", nil, InterfaceOptionsFramePanelContainer)
    OptionsFrame.name = aName
    InterfaceOptions_AddCategory(OptionsFrame)

    local Title = OptionsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    Title:SetText(self:ApplyTextColor(aName, MBC.Colors.Title))
    Title:SetPoint("TOPLEFT", 15, -15)

    self:ApplyCustomFont(Title, MBC.Font.Title)

    OptionsFrame.Title = Title

    return OptionsFrame
end

-------------------------------------------------------------------------------
-- Buttons {{{
-------------------------------------------------------------------------------

function MBC:CreateButton(Parent, Width, Height, Label)
    if not Parent or not Label then return end

    local Button = CreateFrame("Button", nil, Parent)
    Button:SetHeight(Height)
    Button:SetBackdrop(MBC.BackDrops.Basic)
    Button:SetBackdropColor(unpack(MBC.Colors.Background))
    self:ApplyHoverEffect(Button, MBC.Colors.Background, MBC.Colors.HoverBackground)

    local FontSize = Height * MBC.Math.OneThirds
    if FontSize < MBC.Font.DefaultSize then
        FontSize = Height / 2
    end

    local ButtonText = Button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    ButtonText:SetPoint("CENTER", Button, "CENTER", 0, 0)
    ButtonText:SetTextColor(unpack(MBC.Colors.TextLight))
    ButtonText:SetFont(self:GetFont(MBC.Font.DefaultFont), FontSize)
    ButtonText:SetText(Label)
    Button.Text = ButtonText

    if not Width or Width == MBC.Button.Fit then
        local CalcWidth = ButtonText:GetStringWidth() + (Height * MBC.Math.FourThirds)
        Button:SetWidth(CalcWidth)
    else
        Button:SetWidth(Width)
    end

    return Button
end

function MBC:ApplyHoverEffect(Parent, NormalColor, HoverColor)
    if not Parent then return end

    NormalColor = NormalColor or MBC.Colors.Background
    HoverColor = HoverColor or MBC.Colors.HoverBackground
    
    local HighlightOverlay = Parent:CreateTexture(nil, "OVERLAY")
    HighlightOverlay:SetAllPoints(Parent)
    HighlightOverlay:SetTexture("Interface\\AddOns\\MoronBoxCore\\Textures\\Highlight.tga")
    HighlightOverlay:SetVertexColor(1, 1, 1, 0.1)
    HighlightOverlay:Hide()

    Parent:SetScript("OnEnter", function(self)
        self:SetBackdropColor(unpack(HoverColor))
        HighlightOverlay:Show()
    end)

    Parent:SetScript("OnLeave", function(self)
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

    CloseButton:GetNormalTexture():SetVertexColor(unpack(MBC.Colors.CloseButtonNormal))
    CloseButton:GetPushedTexture():SetVertexColor(unpack(MBC.Colors.CloseButtonHover))

    CloseButton:SetScript("OnEnter", function(self)
        self:GetNormalTexture():SetVertexColor(unpack(MBC.Colors.CloseButtonHover))
    end)

    CloseButton:SetScript("OnLeave", function(self)
        self:GetNormalTexture():SetVertexColor(unpack(MBC.Colors.CloseButtonNormal))
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

    ReturnButton:GetNormalTexture():SetVertexColor(unpack(MBC.Colors.ReturnButtonNormal))
    ReturnButton:GetPushedTexture():SetVertexColor(unpack(MBC.Colors.ReturnButtonHover))

    ReturnButton:SetScript("OnEnter", function(self)
        self:GetNormalTexture():SetVertexColor(unpack(MBC.Colors.ReturnButtonHover))
    end)

    ReturnButton:SetScript("OnLeave", function(self)
        self:GetNormalTexture():SetVertexColor(unpack(MBC.Colors.ReturnButtonNormal))
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

    ToggleButton:GetNormalTexture():SetVertexColor(unpack(MBC.Colors.CloseButtonNormal))
    ToggleButton:GetPushedTexture():SetVertexColor(unpack(MBC.Colors.CloseButtonHover))

    ToggleButton:SetScript("OnEnter", function(self)
        self:GetNormalTexture():SetVertexColor(unpack(MBC.Colors.CloseButtonHover))
        end)
        
    ToggleButton:SetScript("OnLeave", function(self)
        self:GetNormalTexture():SetVertexColor(unpack(MBC.Colors.CloseButtonNormal))
    end)

    function UpdateButtonIcon(Item)
        if MBR:ItemExistsInPossibleVendorItems(Item) then
            ToggleButton:SetNormalTexture("Interface\\AddOns\\MoronBoxCore\\Media\\Icons\\Minus.tga")
            ToggleButton:SetPushedTexture("Interface\\AddOns\\MoronBoxCore\\Media\\Icons\\Minus.tga")
            ToggleButton:GetNormalTexture():SetVertexColor(unpack(MBC.Colors.ReturnButtonNormal))
            ToggleButton:GetPushedTexture():SetVertexColor(unpack(MBC.Colors.ReturnButtonHover))

            ToggleButton:SetScript("OnEnter", function(self)
                self:GetNormalTexture():SetVertexColor(unpack(MBC.Colors.CloseButtonHover))
            end)

            ToggleButton:SetScript("OnLeave", function(self)
                self:GetNormalTexture():SetVertexColor(unpack(MBC.Colors.CloseButtonNormal))
            end)
        else
            ToggleButton:SetNormalTexture("Interface\\AddOns\\MoronBoxCore\\Media\\Icons\\Plus.tga")
            ToggleButton:SetPushedTexture("Interface\\AddOns\\MoronBoxCore\\Media\\Icons\\Plus.tga")
            ToggleButton:GetNormalTexture():SetVertexColor(unpack(MBC.Colors.CloseButtonNormal))
            ToggleButton:GetPushedTexture():SetVertexColor(unpack(MBC.Colors.CloseButtonHover))

            ToggleButton:SetScript("OnEnter", function(self)
                self:GetNormalTexture():SetVertexColor(unpack(MBC.Colors.ReturnButtonHover))
            end)

            ToggleButton:SetScript("OnLeave", function(self)
                self:GetNormalTexture():SetVertexColor(unpack(MBC.Colors.ReturnButtonNormal))
            end)
        end
    end

    ToggleButton.UpdateButtonIcon = UpdateButtonIcon

    return ToggleButton
end


-------------------------------------------------------------------------------
-- CheckBox {{{
-------------------------------------------------------------------------------

function MBC:CreateCheckButton(Parent, Title, Value, XOffset)
    if not Parent or not Title then return end

    Value = Value or false
    XOffset = XOffset or -45

    local CheckButton = CreateFrame("CheckButton", nil, Parent, "OptionsCheckButtonTemplate")
    CheckButton:SetChecked(Value)

    local Label = CheckButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    Label:SetText(Title)
    Label:SetPoint("RIGHT", CheckButton, "LEFT", XOffset, 0)

    CheckButton.Label = Label

    return CheckButton
end

function MBC:CreateCustomCheckbox(Parent, Value, Width, Height)
    if not Parent then return end 

    Value = Value or false
    Width = Width or 32
    Height = Height or 32

    local Checkbox = CreateFrame("CheckButton", nil, Parent)
    Checkbox:SetSize(Width, Height)
    Checkbox:SetBackdrop(MBC.BackDrops.Basic)
    Checkbox:SetBackdropColor(unpack(MBC.Colors.Charcoal))

    local CalcWidth = Checkbox:GetWidth() * MBC.Math.TwoThirds
    local CalcHeight = Checkbox:GetHeight() * MBC.Math.TwoThirds

    local CheckedTexture = Checkbox:CreateTexture(nil, "ARTWORK")
    CheckedTexture:SetTexture("Interface\\AddOns\\MoronBoxCore\\Media\\Icons\\Close.tga")
    CheckedTexture:SetSize(CalcWidth, CalcHeight)
    CheckedTexture:SetVertexColor(unpack(MBC.Colors.LightBlue))
    CheckedTexture:SetPoint("CENTER", Checkbox, "CENTER")
    
    Checkbox:SetCheckedTexture(CheckedTexture)
    Checkbox:SetChecked(Value)

    Checkbox.CheckedTexture = CheckedTexture

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

    local Texture = ItemIcon:CreateTexture()
    Texture:SetAllPoints()
    Texture:SetTexture(Item.Icon)

    local CalcWidth = (Width / 2) + 2
    ItemIcon:SetNormalTexture(Texture)
    ItemIcon:SetPoint("CENTER", Parent, "LEFT", CalcWidth, 0)

    Parent.Texture = Texture

    return ItemIcon
end

-------------------------------------------------------------------------------
-- Line {{{
-------------------------------------------------------------------------------

function MBC:CreateLine(Parent, Width, Height, OffsetX, OffsetY, Color)
    if not Parent then return end

    Width = Width or Parent:GetWidth()
    Height = Height or 1
    OffsetX = OffsetX or 0
    OffsetY = OffsetY or 0
    Color = Color or MBC.Colors.LineColor

    local Line = Parent:CreateTexture(nil, "ARTWORK")
    Line:SetTexture(1, 1, 1, 1)
    Line:SetSize(Width, Height)
    Line:SetVertexColor(unpack(Color))
    Line:SetPoint("CENTER", Parent, "CENTER", OffsetX, OffsetY)
    
    Parent.Line = Line

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
    NewFrame:SetBackdrop(Backdrop)
    NewFrame:SetSize(Width, Height)
    NewFrame:SetBackdropColor(unpack(MBC.Colors.FrameBackground))
    NewFrame:SetPoint("CENTER", Parent, "CENTER")

    return NewFrame
end

function MBC:CreateGeneralWindow(Parent, TitleText, Width, Height)
    if not Parent or not TitleText then return end

    Width = Width or 500
    Height = Height or 600

    local SettingsFrame = self:CreateFrame(Parent, MBC.BackDrops.Basic, Width, Height)
    local ReturnButton = self:ReturnButton(SettingsFrame, 20, 20)
    local CloseButton = self:CloseButton(SettingsFrame, 20, 20)
    local OffsetY = (SettingsFrame:GetHeight() / 2) - 35

    local Title = SettingsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    Title:SetText(self:ApplyTextColor(TitleText, MBC.Colors.Title))
    Title:SetPoint("TOP", SettingsFrame, "TOP", 0, -5)

    self:ApplyCustomFont(Title, MBC.Font.BigTitle)
    self:CreateLine(SettingsFrame, (SettingsFrame:GetWidth() - 60), 1, 0, -OffsetY, MBC.Colors.LineColor)
    self:CreateAddonGroupText(SettingsFrame)
    self:MakeMoveable(SettingsFrame)

    SettingsFrame.Title = Title
    SettingsFrame.ReturnButton = ReturnButton
    SettingsFrame.CloseButton = CloseButton

    return SettingsFrame
end

function MBC:CreateAddonGroupText(Parent)
    if not Parent then return end

    local GroupText = Parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    GroupText:SetPoint("CENTER", Parent, "BOTTOM", 0, 20)
    GroupText:SetJustifyH("CENTER")
    GroupText:SetText(self:SL("Addon Group"))

    self:ApplyCustomFont(GroupText, MBC.Font.SmallSize)

    Parent.GroupText = GroupText

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

function MBC:CustomPopup(Message, OnConfirm, OnCancel)
    if not Message then return end

    local BackGround = CreateFrame("Frame", nil, UIParent)
    BackGround:SetFrameStrata("FULLSCREEN_DIALOG")
    BackGround:SetAllPoints(UIParent)
    BackGround:EnableMouse(true)
    BackGround:SetBackdrop(MBC.BackDrops.No_Border)
    BackGround:SetBackdropColor(unpack(MBC.Colors.FadeFrame))

    local PopupDialog = MBC:CreateFrame(BackGround, MBC.BackDrops.Basic, 300, 150)
    local MessageText = PopupDialog:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    MessageText:SetPoint("TOP", PopupDialog, "TOP", 0, -25)
    MessageText:SetJustifyH("CENTER")
    MessageText:SetText(Message)

    local CancelButton = MBC:CreateButton(PopupDialog, 100, MBC.Button.Large, "Cancel")
    CancelButton:SetPoint("BOTTOMLEFT", PopupDialog, "BOTTOMLEFT", 50, 20)

    local ConfirmButton = MBC:CreateButton(PopupDialog, 100, MBC.Button.Large, "Confirm")
    ConfirmButton:SetPoint("BOTTOMRIGHT", PopupDialog, "BOTTOMRIGHT", -50, 20)

    local CalcWidth = MessageText:GetStringWidth() * MBC.Math.ThreeSeconds
    PopupDialog:SetWidth(CalcWidth)

    ConfirmButton:SetScript("OnClick", function()
        if OnConfirm then OnConfirm() end
        BackGround:Hide()
    end)

    CancelButton:SetScript("OnClick", function()
        if OnCancel then OnCancel() end
        BackGround:Hide()
    end)

    MBC:ApplyCustomFont(MessageText, MBC.Font.Title)

    BackGround.PopupDialog = PopupDialog
    BackGround.MessageText = MessageText
    BackGround.ConfirmButton = ConfirmButton
    BackGround.CancelButton = CancelButton

    BackGround:Show()
end