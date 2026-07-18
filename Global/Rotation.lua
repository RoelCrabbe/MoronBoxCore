--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

MB_myLoathebList = {}

Instance         = {
    NAXX        = function() return GetRealZoneText() == "Naxxramas" end,
    AQ40        = function() return GetRealZoneText() == "Ahn\'Qiraj" end,
    AQ20        = function() return GetRealZoneText() == "Ruins of Ahn\'Qiraj" end,
    MC          = function() return GetRealZoneText() == "Molten Core" end,
    BWL         = function() return GetRealZoneText() == "Blackwing Lair" end,
    ONY         = function() return GetRealZoneText() == "Onyxia\'s Lair" end,
    ZG          = function() return GetRealZoneText() == "Zul\'Gurub" end,
    IsWorldBoss = function()
        return UnitClassification("target") == "worldboss"
    end,
    IsInRaid    = function(self)
        return self.NAXX() or self.AQ40() or self.AQ20() or self.MC() or self.BWL() or self.ONY() or self.ZG()
    end
}

Faction          = {
    IsHorde = function() return UnitFactionGroup("player") == "Horde" end
}

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--


MB_buffingCounterMage    = 1
MB_buffingCounterPriest  = 1
MB_buffingCounterPaladin = 1
