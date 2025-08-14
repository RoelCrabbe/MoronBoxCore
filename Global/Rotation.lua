--[####################################################################################################]--
--[################################### Global Values for Rotation #####################################]--
--[####################################################################################################]--

local myClass = UnitClass("player")
local myName = UnitName("player")
local tName = UnitName("target")

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

MB_mySpeccList = {}
MB_mySingleList = {}
MB_myMultiList = {}
MB_myAOEList = {}
MB_mySetupList = {}
MB_myPreCastList = {}
MB_myLoathebList = {}
MB_myHealList = {}

Instance = {
    Naxx  = (GetRealZoneText() == "Naxxramas"),
    AQ40  = (GetRealZoneText() == "Ahn'Qiraj"),
    AQ20  = (GetRealZoneText() == "Ruins of Ahn'Qiraj"),
    MC    = (GetRealZoneText() == "Molten Core"),
    BWL   = (GetRealZoneText() == "Blackwing Lair"),
    Ony   = (GetRealZoneText() == "Onyxia's Lair"),
    ZG    = (GetRealZoneText() == "Zul'Gurub");
    IsWorldBoss = function()
        return UnitClassification("target") == "worldboss"
    end
}
