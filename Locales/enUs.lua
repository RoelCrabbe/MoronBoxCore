-------------------------------------------------------------------------------
-- Localization English {{{
-------------------------------------------------------------------------------

function MBC:Localization_enUS()

    self.L = {}

    self.L["MoronBoxCore"] = ""
    self.L["Moron Box Menu"] = ""
    self.L["Intro"] =         
        self:ApplyTextColor("MoronBoxCore", MBC.Colors.Highlight)..
        self:ApplyTextColor(" is the essential foundation of the Moron Multi Box collection. It delivers crucial mathematical functions and indispensable tools that all associated add-ons rely on. This core component fundamentally empowers the ", MBC.Colors.Text)..
        self:ApplyTextColor("MoronBox", MBC.Colors.Highlight)..
        self:ApplyTextColor(" ecosystem, guaranteeing efficient multiboxing and ensuring seamless gameplay, ultimately elevating the user experience.", MBC.Colors.Text)

    self.L["Depending"] =  
        self:ApplyTextColor("Your addons that depend on ", MBC.Colors.Text)..
        self:ApplyTextColor("MoronBoxCore", MBC.Colors.Highlight).. 
        self:ApplyTextColor(":\n\n", MBC.Colors.Text)

    self.L["Addon Group"] =  
        MBC:ApplyTextColor("This addon is part of the ", MBC.Colors.Text)..
        MBC:ApplyTextColor("MoronBox", MBC.Colors.Highlight)..
        MBC:ApplyTextColor(" addon group!", MBC.Colors.Text)
end