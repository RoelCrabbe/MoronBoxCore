-------------------------------------------------------------------------------
-- Colors and Backdrop {{{
-------------------------------------------------------------------------------

MBC.Colors = {
    Title = "7B68EE",        -- Medium Slate Blue
    Highlight = "00CCFF",    -- Bright cyan
    Text = "A9A9A9",         -- Dark gray (as in your example)

    Background = {0.1, 0.1, 0.1}, -- Dark gray (RGB tuple)
    HoverBackground = {0.2, 0.2, 0.2}, -- Lighter gray (RGB tuple)
    Charcoal = {0.3, 0.3, 0.3}, -- Lighter gray (RGB tuple)
    LightBlue = {0.482, 0.408, 0.933},
    TextLight = {0.9, 0.9, 0.9}, -- Light gray (RGB tuple)
    FrameBackground = {0.33, 0.33, 0.33, 0.80}, -- Dark Slate Gray (RGBA tuple)
    LineColor = {0.7, 0.7, 0.7, 1}, -- Line color (RGBA tuple)
    CloseButtonNormal = {0.55, 0, 0, 0.8}, -- Close button normal color (RGBA tuple)
    CloseButtonHover = {1, 0, 0, 0.8}, -- Close button hover color (RGBA tuple)
    ReturnButtonNormal = {0, 0.55, 0, 0.8}, -- Return button normal color (RGBA tuple)
    ReturnButtonHover = {0.0, 1, 0.0, 0.8}, -- Darker green for return button hover (RGBA tuple)
    FadeFrame = {0, 0, 0, 0.4} -- Darker green for return button hover (RGBA tuple)
}

MBC.BackDrops = {
    Basic = {
        bgFile = "Interface\\AddOns\\MoronBoxCore\\Media\\Icons\\Smooth.tga",
        edgeFile = "Interface\\AddOns\\MoronBoxCore\\Media\\Icons\\Border.tga",
        tile = false,
        tileSize = 8,
        edgeSize = 14,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    },
    No_Border = {
        bgFile = "Interface\\AddOns\\MoronBoxCore\\Media\\Icons\\Smooth.tga",
        edgeFile = nil,
        tile = false,
        tileSize = 8,
        edgeSize = 14,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    }
}

MBC.Button = {
    Fit = "Auto",
    Small = 16,
    Medium = 24,
    Middle = 28,
    Large = 32,
    XLarge = 40,
    XXLarge = 48
}

MBC.Font = {
    SmallSize = 13,
    DefaultSize = 14,
    InformationSize = 16,
    Title = 20,
    BigTitle = 32,
    DefaultFont = "MoronFont"
}

MBC.Math = {
    OneThirds = 1 / 3,
    TwoThirds = 2 / 3,
    FourThirds = 4 / 3,
    ThreeSeconds = 3 / 2,
}

function MBC:ApplyTextColor(Text, Color)
    return string.format("|cff%s%s|r", Color, Text)
end