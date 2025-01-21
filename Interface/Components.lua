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

    local ButtonText = Button:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
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

    local WaveDots = Button:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    WaveDots:SetPoint("LEFT", ButtonText, "RIGHT", 1, 0)
    WaveDots:SetTextColor(unpack(MBC.Colors.TextLight))
    WaveDots:SetFont(self:GetFont(MBC.Font.DefaultFont), FontSize)
    Button.WaveDots = WaveDots

    WaveDots:Hide()
    Button.DotStep = 0

    function Button:EnableDots()
        self.WaveDots:Show()
        self.DotStep = (self.DotStep or 0) + 1
        local Step = self.DotStep % 4 
        local Dots = string.rep('.', Step)
        self.WaveDots:SetText(Dots)
    end

    function Button:DisableDots()
        self.WaveDots:Hide()
        self.DotStep = 0
        self.WaveDots:SetText("")
    end

    function Button:Disable()
        self:EnableMouse(false)
        self:SetAlpha(0.75)
    end

    function Button:Enable()
        self:EnableMouse(true)
        self:SetAlpha(1)
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

function MBC:CreateCustomCheckboxWithLabel(Parent, Name, Width, Height)
    if not Parent then return end 

    Name = Name or nil
    Width = Width or 32
    Height = Height or 32

    local Checkbox = CreateFrame("CheckButton", Name, Parent)
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
    Checkbox:SetChecked(false)

    local Label = Checkbox:CreateFontString(Name.."Text", "BACKGROUND", "GameFontHighlight")
    Label:SetPoint("BOTTOM", Checkbox, "TOP", 0, 2)
    MBC:ApplyCustomFont(Label, MBC.Font.DefaultSize)

    Checkbox.Label = Label
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

    local GroupText = Parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
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

-------------------------------------------------------------------------------
-- Mail Entry {{{
-------------------------------------------------------------------------------

function MBC:CreateMailEntry(Parent, Height, Amount, Count, MyIcon, MyLink, Title, Sender, MsgMoney, Quantity)
    if not Parent then return end

    Height = Height or 45

    local MailEntry = CreateFrame("Frame", "MBPMailEntry"..Count, Parent)
    MailEntry:SetBackdrop(MBC.BackDrops.Basic)
    MailEntry:SetBackdropColor(unpack(MBC.Colors.FrameBackground))
    MailEntry:SetSize(Parent:GetWidth(), Height)
    MailEntry:SetPoint("TOP", Parent, "TOP", 0, -((Amount - 1) * (Height + 6)))

    -- Mail Icon
    local MailIcon = MBC:CreateItemIcon(MailEntry, { Icon = MyIcon }, 40, 40)
    MailEntry.MailIcon = MailIcon

    MailIcon:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        if MyLink and MyLink ~= "" then
            GameTooltip:SetHyperlink(MyLink)
        elseif MsgMoney and MsgMoney > 0 then
            GameTooltip:AddLine("Gold: ["..GetCoinTextureString(MsgMoney).."]", 1, 1, 1) 
        else
            GameTooltip:AddLine("Sender: "..(Sender or "Unknown Sender"), 1, 1, 1)
        end
        GameTooltip:Show()
    end)

    MailIcon:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    -- Quantity
    if Quantity and Quantity > 0 then
        local QuantityText = MailIcon:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        QuantityText:SetPoint("TOPLEFT", MailIcon, "TOPLEFT", 2, 0)
        QuantityText:SetText(Quantity)
        MBC:ApplyCustomFont(QuantityText, MBC.Font.DefaultSize)
        MailEntry.QuantityText = QuantityText
    end

    -- Mail Title
    local MailTitle = MailEntry:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    MailTitle:SetPoint("LEFT", MailIcon, "RIGHT", 10, 0)
    MailTitle:SetText(Title)
    MBC:ApplyCustomFont(MailTitle, MBC.Font.Title)
    MailEntry.MailTitle = MailTitle

    -- Checkbox
    local CheckBox = MBC:CreateCustomCheckboxWithLabel(MailEntry, "MBPInboxCB"..Count, 20, 20)
    CheckBox:SetPoint("RIGHT", -5, -5)
    CheckBox:SetID(Count)
    CheckBox.Label:SetText(Count)
    CheckBox:SetScript("OnClick", OnCheckboxClick)
    MailEntry.CheckBox = CheckBox

    return MailEntry
end

function MBC:PaginationButton(Parent, Version, Width, Height)
    if not Parent then return end

    Width = Width or 16
    Height = Height or 16

    local Button = CreateFrame("Button", nil, Parent)
    Button:SetSize(Width, Height)
    Button:SetBackdrop(MBC.BackDrops.Basic)
    Button:SetBackdropColor(unpack(MBC.Colors.Background))
    self:ApplyHoverEffect(Button, MBC.Colors.Background, MBC.Colors.HoverBackground)

    -- Create a texture for the button
    local Texture = Button:CreateTexture(nil, "BACKGROUND")
    Texture:SetPoint("CENTER", Button, "CENTER", 0, 0)
    Texture:SetSize(Height * 0.5, Height * 0.5)

    if Version == 1 then
        Texture:SetTexture("Interface\\AddOns\\MoronBoxCore\\Media\\Icons\\Left.tga")
    elseif Version == 2 then
        Texture:SetTexture("Interface\\AddOns\\MoronBoxCore\\Media\\Icons\\Right.tga")
    end

    Button:SetNormalTexture(Texture)
    Button:SetPushedTexture(Texture)

    Texture:SetVertexColor(unpack(MBC.Colors.TextLight))
    Texture:Show()

    return Button
end

function MBC:PageIndicator(Parent, CurrentPage, MaxPages)
    if not Parent then return end

    CurrentPage = CurrentPage or 1
    MaxPages = MaxPages == 0 and 1 or MaxPages
    local Text = CurrentPage.." of "..MaxPages
    
    local PageIndicator = Parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    PageIndicator:SetText(self:ApplyTextColor(Text, MBC.Colors.Text))

    self:ApplyCustomFont(PageIndicator, MBC.Font.InformationSize)

    function PageIndicator:Update(CurrentPage, MaxPages)
        MaxPages = MaxPages == 0 and 1 or MaxPages
        local Text = CurrentPage.." of "..MaxPages
        self:SetText(MBC:ApplyTextColor(Text, MBC.Colors.Text))
    end

    return PageIndicator
end