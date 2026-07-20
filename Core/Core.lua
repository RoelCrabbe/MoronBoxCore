-- [[ Config & Constants ]] --

MoronBox.Core = MoronBox.Core or {}

--- @type MoronBoxState
MoronBox.Core.GeneralState = {
    MBID = {},
    ToonsInGroup = {},
    RaidTanks = {},
    AssignableTanks = {},
    DruidCasters = {},
    GroupID = {},
    ClassList = {
        Warrior = {},
        Mage = {},
        Shaman = {},
        Paladin = {},
        Priest = {},
        Rogue = {},
        Druid = {},
        Hunter = {},
        Warlock = {}
    },
    HealerList = {},
    WarriorTankInParty = false,
    DruidTankInParty = false,
}

for i = 1, 8 do
    MoronBox.Core.GeneralState.ToonsInGroup[i] = {}
end

local myClass = UnitClass("player")
local myName = UnitName("player")
local myRace = UnitRace("player")

--- @type MoronBoxState
local ResetState = getApi().CopyTable(MoronBox.Core.GeneralState)

function getCore()
    return MoronBox.Core
end

function getCoreState()
    return MoronBox.Core.GeneralState
end

-- [[ InitializeClasslists ]]

--- Rebuilds all raid/party roster-derived caches under GeneralState,
--- isolated from the legacy mb_initializeClasslists() globals while both run
--- side by side. Called primarily on roster changes (RAID_ROSTER_UPDATE,
--- PARTY_MEMBERS_CHANGED).
function MoronBox.Core.InitializeClasslists()
    -- [[ Reset ]] --
    -- ResetState is a fixed template captured once at load time; CopyTable
    -- gives us a fresh, independent copy so we never mutate the template itself.

    MoronBox.Core.GeneralState = getApi().CopyTable(ResetState)

    -- Solo (or in an inconsistent transitional state): nothing to build, caches stay empty.
    if not getApi().GetGroupStatus() then
        return
    end

    -- [[ Find Healers ]] --
    getCore().InitializeHealerList()

    -- [[ Roster Scan ]] --
    if UnitInRaid("player") then
        for i = 1, GetNumRaidMembers() do
            local name, _, subGroup, _, class = GetRaidRosterInfo(i)

            -- A gap in the roster index shouldn't wipe out everything already
            -- collected — skip this slot and keep processing the rest.
            if name and class and UnitIsConnected("raid" .. i) and UnitExists("raid" .. i) then
                getCoreState().MBID[name] = "raid" .. i
                table.insert(getCoreState().ClassList[class], name)
                table.insert(getCoreState().ToonsInGroup[subGroup], name)
                getCoreState().GroupID[name] = subGroup
            end
        end
    else
        for i = 1, GetNumPartyMembers() + 1 do
            local unitId
            if i == GetNumPartyMembers() + 1 then
                unitId = "player"
            else
                unitId = "party" .. i
            end

            local name = UnitName(unitId)
            local class = UnitClass(unitId)

            -- Party members are contiguous (party1..N + player), so a missing
            -- entry here does mean "no more members" — break is correct.
            if not name or not class then
                break
            end

            getCoreState().MBID[name] = unitId
            table.insert(getCoreState().ClassList[class], name)
            table.insert(getCoreState().ToonsInGroup[1], name)
            getCoreState().GroupID[name] = 1
        end
    end

    -- [[ Tank Lists ]] --
    for _, tank in ipairs(getSettingsState().TankList) do
        local tankId = getCoreState().MBID[tank]
        if tankId then
            local tankClass = UnitClass(tankId)

            if UnitInParty(tankId) then
                if tankClass == "Druid" then
                    getCoreState().DruidTankInParty = true
                end
                if tankClass == "Warrior" then
                    getCoreState().WarriorTankInParty = true
                end
            end

            if tank ~= myName then
                table.insert(getCoreState().AssignableTanks, tank)
            end

            table.insert(getCoreState().RaidTanks, tank)
        end
    end

    for _, name in pairs(getCoreState().ClassList["Druid"]) do
        if not getApi().FindInTable(getCoreState().RaidTanks, name) then
            table.insert(getCoreState().DruidCasters, name)
        end
    end

    -- [[ Sort ]] --
    ---- Keeping them in order instead of sorting is better for assigning tanks
    -- SortAlphabetically(State.AssignableTanks)

    getApi().SortAlphabetically(getCoreState().RaidTanks)
    getApi().SortAlphabetically(getCoreState().DruidCasters)

    for _, list in pairs(getCoreState().ClassList) do
        getApi().SortAlphabetically(list)
    end

    getApi().SortAlphabetically(getCoreState().HealerList)
end

function MoronBox.Core.InitializeHealerList()
    if not getCore().ImHealer() then
        return
    end

    getApi().SendAddonMessage(getRaidId() .. "MB_ROLE_HEALER", myName)
end

function MoronBox.Core.HandleHealerList(msg)
    if msg and getCoreState().MBID[msg] then
        for _, name in ipairs(getCoreState().HealerList) do
            if name == msg then return end
        end

        table.insert(getCoreState().HealerList, msg)
    end
end

-- [[ Roles Checking ]] --

function MoronBox.Core.GetMySpecc()
    local moduleName = "MODULE_" .. string.upper(myClass) .. "_ROTATION"
    local rotationModule = MoronBox.Registry[moduleName]

    if rotationModule and type(rotationModule["Specc"]) == "function" then
        local status, err = pcall(rotationModule["Specc"])
        if not status then
            getDebugger().ErrorMsg("Specc error for " .. myClass .. ": " .. tostring(err))
        end
    end
end

function MoronBox.Core.ImRangedDPS()
    if myClass == "Hunter" or myClass == "Warlock" or myClass == "Mage" then
        return true
    elseif myClass == "Shaman" and getConfigState().PlayerSpecc == "Elemental" then
        return true
    elseif myClass == "Priest" and getConfigState().PlayerSpecc == "Shadow" then
        return true
    elseif myClass == "Druid" and getConfigState().PlayerSpecc == "Balance" then
        return true
    end
    return false
end

function MoronBox.Core.ImMeleeDPS()
    if myClass == "Rogue" then
        return true
    elseif myClass == "Warrior" and getConfigState().PlayerSpecc == "BT" then
        return true
    end
    return false
end

function MoronBox.Core.ImTank()
    if myClass == "Warrior" and (getConfigState().PlayerSpecc == "Prottank" or getConfigState().PlayerSpecc == "Furytank") then
        return true
    elseif myClass == "Druid" and getConfigState().PlayerSpecc == "Feral" then
        return true
    end
    return false
end

function MoronBox.Core.ImHealer()
    if myClass == "Druid" and (getConfigState().PlayerSpecc == "Resto" or getConfigState().PlayerSpecc == "Swiftmend") then
        return true
    elseif myClass == "Shaman" and getConfigState().PlayerSpecc ~= "Elemental" then
        return true
    elseif myClass == "Priest" and getConfigState().PlayerSpecc ~= "Shadow" then
        return true
    elseif myClass == "Paladin" then
        return true
    end
    return false
end

-- [[ Group ]] --

function MoronBox.Core.MyGroupOrder()
    local myParty = {}

    table.insert(myParty, myName)

    for i = 1, GetNumPartyMembers() do
        local name = UnitName("party" .. i)
        table.insert(myParty, name)
    end

    table.sort(myParty)

    local order = 1
    for _, toon in pairs(myParty) do
        if toon == myName then
            return order
        end

        order = order + 1
    end

    return order
end

function MoronBox.Core.MyClassOrder()
    local myClassToons = {}

    for name, id in getCoreState().MBID do
        local class = UnitClass(id)
        if class == myClass and getUnit().IsAlive(id) then
            if UnitPowerType(id) == 0 then
                myClassToons[name] = UnitManaMax(id)
            else
                myClassToons[name] = UnitHealthMax(id)
            end
        end
    end

    local order = 1
    for name, _ in getApi().sPairs(myClassToons,
        function(t, a, b)
            return t[b] < t[a]
        end)
    do
        if name == myName then
            return order
        end

        order = order + 1
    end
    return 0
end

function MoronBox.Core.MyInvertedClassOrder()
    local myClassToons = {}

    for name, id in getCoreState().MBID do
        local class = UnitClass(id)
        if class == myClass and getUnit().IsAlive(id) then
            if UnitPowerType(id) == 0 then
                myClassToons[name] = UnitManaMax(id)
            else
                myClassToons[name] = UnitHealthMax(id)
            end
        end
    end

    local order = 1
    for name, _ in getApi().sPairs(myClassToons,
        function(t, a, b)
            return t[b] > t[a]
        end)
    do
        if name == myName then
            return order
        end

        order = order + 1
    end
    return 0
end

function MoronBox.Core.MyGroupClassOrder()
    local myClassToons = {}

    if UnitPowerType("player") == 0 then
        myClassToons[myName] = UnitManaMax("player")
    else
        myClassToons[myName] = UnitHealthMax("player")
    end

    for i = 1, 4 do
        local unit = "party" .. i
        local class = UnitClass(unit)
        local partyName = UnitName(unit)

        if class == myClass and partyName and getUnit().IsAlive(unit) then
            if UnitPowerType(unit) == 0 then
                myClassToons[partyName] = UnitManaMax(unit)
            else
                myClassToons[partyName] = UnitHealthMax(unit)
            end
        end
    end

    local order = 1
    for name, _ in getApi().sPairs(myClassToons,
        function(t, a, b)
            return t[b] < t[a]
        end)
    do
        if name == myName then
            return order
        end

        order = order + 1
    end
    return 0
end

function MoronBox.Core.MyInvertedGroupClassOrder()
    local myClassToons = {}

    if UnitPowerType("player") == 0 then
        myClassToons[myName] = UnitManaMax("player")
    else
        myClassToons[myName] = UnitHealthMax("player")
    end

    for i = 1, 4 do
        local unit = "party" .. i
        local class = UnitClass(unit)
        local partyName = UnitName(unit)

        if class == myClass and partyName and getUnit().IsAlive(unit) then
            if UnitPowerType(unit) == 0 then
                myClassToons[partyName] = UnitManaMax(unit)
            else
                myClassToons[partyName] = UnitHealthMax(unit)
            end
        end
    end

    local order = 1
    for name, _ in getApi().sPairs(myClassToons,
        function(t, a, b)
            return t[b] > t[a]
        end)
    do
        if name == myName then
            return order
        end

        order = order + 1
    end
    return 0
end

function MoronBox.Core.MyClassAlphabeticalOrder()
    local myClassToons = {}

    for name, id in getCoreState().MBID do
        local class = UnitClass(id)

        if class == myClass and getUnit().IsAlive(id) then
            table.insert(myClassToons, name)
        end
    end

    table.sort(myClassToons)

    local order = 1
    for _, name in ipairs(myClassToons) do
        if name == myName then
            return order
        end

        order = order + 1
    end
    return 0
end

function MoronBox.Core.NumberOfClassInParty(checkClass)
    local i = 0
    local myGroup = getCoreState().GroupID[myName]

    if not myGroup then
        return 0
    end

    for _, name in ipairs(getCoreState().ToonsInGroup[myGroup]) do
        local MBID = getCoreState().MBID
        if MBID[name] and UnitClass(MBID[name]) == checkClass then
            i = i + 1
        end
    end
    return i
end

function MoronBox.Core.NumberOfClassInRaid(checkClass)
    local i = 0

    for _, id in pairs(getCoreState().MBID) do
        if UnitClass(id) == checkClass then
            i = i + 1
        end
    end

    return i
end

function MoronBox.Core.GetRandomMageInGroup()
    local mages = getCoreState().ClassList["Mage"]

    if not mages or table.getn(mages) == 0 then
        return nil
    end

    return mages[math.random(table.getn(mages))]
end

function MoronBox.Core.MeleeDPSInParty()
    return getCore().NumberOfClassInParty("Warrior") > 0 or getCore().NumberOfClassInParty("Rogue") > 0
end

function MoronBox.Core.NumOfCasterHealerInParty()
    return getCore().NumberOfClassInParty("Mage")
        + getCore().NumberOfClassInParty("Priest")
        + getCore().NumberOfClassInParty("Druid")
        + getCore().NumberOfClassInParty("Shaman")
end
