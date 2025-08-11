
local myClass = UnitClass("player")
local myName = UnitName("player")
local tName = UnitName("target")
local myZone = GetRealZoneText()

MB_mySpeccList = {}
MB_mySingleList = {}
MB_myMultiList = {}
MB_myAOEList = {}
MB_mySetupList = {}
MB_myPreCastList = {}
MB_myLoathebList = {}
MB_myHealList = {}

Instance = {
    Naxx  = (myZone == "Naxxramas"),
    AQ40  = (myZone == "Ahn'Qiraj"),
    AQ20  = (myZone == "Ruins of Ahn'Qiraj"),
    MC    = (myZone == "Molten Core"),
    BWL   = (myZone == "Blackwing Lair"),
    Ony   = (myZone == "Onyxia's Lair"),
    ZG    = (myZone == "Zul'Gurub");
    IsWorldBoss = function()
        return UnitClassification("target") == "worldboss"
    end
}
