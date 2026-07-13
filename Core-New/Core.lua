-- [[ Config & Constants ]] --

MoronBox.Api = MoronBox.Api or {}
local Api = MoronBox.Api

MoronBox.Unit = MoronBox.Unit or {}
local Unit = MoronBox.Unit

MoronBox.Core = MoronBox.Core or {}
local Core = MoronBox.Core

--- @type MoronBoxState
Core.State = {
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
    WarriorTankInParty = false,
    DruidTankInParty = false,
}

for i = 1, 8 do
    Core.State.ToonsInGroup[i] = {}
end

--- @type MoronBoxState
local ResetState = Api.CopyTable(Core.State)

local myClass = UnitClass("player") --[[@as string]]
local myName = UnitName("player") --[[@as string]]

-- [[ InitializeClasslists ]]

--- Rebuilds all raid/party roster-derived caches under Core.State,
--- isolated from the legacy mb_initializeClasslists() globals while both run
--- side by side. Called primarily on roster changes (RAID_ROSTER_UPDATE,
--- PARTY_MEMBERS_CHANGED).
function Core.InitializeClasslists()
    -- [[ Reset ]] --
    -- ResetState is a fixed template captured once at load time; CopyTable
    -- gives us a fresh, independent copy so we never mutate the template itself.

    Core.State = Api.CopyTable(ResetState)
    local State = Core.State

    -- Solo (or in an inconsistent transitional state): nothing to build, caches stay empty.
    if not Api.GetGroupStatus() then
        return
    end

    -- [[ Roster Scan ]] --
    if UnitInRaid("player") then
        for i = 1, GetNumRaidMembers() do
            local name, _, subGroup, _, class = GetRaidRosterInfo(i)

            -- A gap in the roster index shouldn't wipe out everything already
            -- collected — skip this slot and keep processing the rest.
            if name and class and UnitIsConnected("raid" .. i) and UnitExists("raid" .. i) then
                State.MBID[name] = "raid" .. i
                table.insert(State.ClassList[class], name)
                table.insert(State.ToonsInGroup[subGroup], name)
                State.GroupID[name] = subGroup
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

            State.MBID[name] = unitId
            table.insert(State.ClassList[class], name)
            table.insert(State.ToonsInGroup[1], name)
            State.GroupID[name] = 1
        end
    end

    -- [[ Tank Lists ]] --
    for _, tank in ipairs(MB_tankList) do
        local tankId = State.MBID[tank]
        if tankId then
            local tankClass = UnitClass(tankId)

            if UnitInParty(tankId) then
                if tankClass == "Druid" then
                    State.DruidTankInParty = true
                end
                if tankClass == "Warrior" then
                    State.WarriorTankInParty = true
                end
            end

            if tank ~= myName then
                table.insert(State.AssignableTanks, tank)
            end

            table.insert(State.RaidTanks, tank)
        end
    end

    for _, name in pairs(State.ClassList["Druid"]) do
        if not FindInTable(State.RaidTanks, name) then
            table.insert(State.DruidCasters, name)
        end
    end

    -- [[ Sort ]] --
    ---- Keeping them in order instead of sorting is better for assigning tanks
    -- Api.SortAlphabetically(State.AssignableTanks)

    Api.SortAlphabetically(State.RaidTanks)
    Api.SortAlphabetically(State.DruidCasters)

    for _, list in pairs(State.ClassList) do
        Api.SortAlphabetically(list)
    end
end

-- [[ Roles Checking ]] --

function Core.ImRangedDPS()
    if myClass == "Hunter" or myClass == "Warlock" or myClass == "Mage" then
        return true
    elseif myClass == "Shaman" and MB_mySpecc == "Elemental" then
        return true
    elseif myClass == "Priest" and MB_mySpecc == "Shadow" then
        return true
    elseif myClass == "Druid" and MB_mySpecc == "Balance" then
        return true
    end
    return false
end

function Core.ImMeleeDPS()
    if myClass == "Rogue" then
        return true
    elseif myClass == "Warrior" and MB_mySpecc == "BT" then
        return true
    end
    return false
end

function Core.ImTank()
    if myClass == "Warrior" and (MB_mySpecc == "Prottank" or MB_mySpecc == "Furytank") then
        return true
    elseif myClass == "Druid" and MB_mySpecc == "Feral" then
        return true
    end
    return false
end

function Core.ImHealer()
    if myClass == "Druid" and (MB_mySpecc == "Resto" or MB_mySpecc == "Swiftmend") then
        return true
    elseif myClass == "Shaman" and MB_mySpecc ~= "Elemental" then
        return true
    elseif myClass == "Priest" and MB_mySpecc ~= "Shadow" then
        return true
    elseif myClass == "Paladin" then
        return true
    end
    return false
end

-- [[ Group ]] --

function Core.MyGroupOrder()
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

function Core.MyClassOrder()
    local myClassToons = {}

    for name, id in MBID do
        local class = UnitClass(id)
        if class == myClass and Unit.IsAlive(id) then
            if UnitPowerType(id) == 0 then
                myClassToons[name] = UnitManaMax(id)
            else
                myClassToons[name] = UnitHealthMax(id)
            end
        end
    end

    local order = 1
    for name, _ in sPairs(myClassToons,
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

function Core.MyInvertedClassOrder()
    local myClassToons = {}

    for name, id in MBID do
        local class = UnitClass(id)
        if class == myClass and Unit.IsAlive(id) then
            if UnitPowerType(id) == 0 then
                myClassToons[name] = UnitManaMax(id)
            else
                myClassToons[name] = UnitHealthMax(id)
            end
        end
    end

    local order = 1
    for name, _ in sPairs(myClassToons,
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

function Core.MyGroupClassOrder()
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

        if class == myClass and partyName and Unit.IsAlive(unit) then
            if UnitPowerType(unit) == 0 then
                myClassToons[partyName] = UnitManaMax(unit)
            else
                myClassToons[partyName] = UnitHealthMax(unit)
            end
        end
    end

    local order = 1
    for name, _ in sPairs(myClassToons,
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

function Core.MyInvertedGroupClassOrder()
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

        if class == myClass and partyName and Unit.IsAlive(unit) then
            if UnitPowerType(unit) == 0 then
                myClassToons[partyName] = UnitManaMax(unit)
            else
                myClassToons[partyName] = UnitHealthMax(unit)
            end
        end
    end

    local order = 1
    for name, _ in sPairs(myClassToons,
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

function Core.MyClassAlphabeticalOrder()
    local myClassToons = {}

    for name, id in MBID do
        local class = UnitClass(id)

        if class == myClass and Unit.IsAlive(id) then
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

function Core.NumberOfClassInParty(checkClass)
    local i = 0
    local myGroup = Core.State.GroupID[myName]

    if not myGroup then
        return 0
    end

    for _, name in ipairs(MB_toonsInGroup[myGroup]) do
        if MBID[name] and UnitClass(MBID[name]) == checkClass then
            i = i + 1
        end
    end
    return i
end

function Core.NumberOfClassInRaid(checkClass)
    local i = 0

    for _, id in pairs(MBID) do
        if UnitClass(id) == checkClass then
            i = i + 1
        end
    end

    return i
end

function Core.GetRandomMageInGroup()
    local mages = MoronBox.Core.State.ClassList["Mage"]

    if not mages or table.getn(mages) == 0 then
        return nil
    end

    return mages[math.random(table.getn(mages))]
end

function Core.MeleeDPSInParty()
    return Core.NumberOfClassInParty("Warrior") > 0 or Core.NumberOfClassInParty("Rogue") > 0
end

function Core.NumOfCasterHealerInParty()
    return Core.NumberOfClassInParty("Mage")
        + Core.NumberOfClassInParty("Priest")
        + Core.NumberOfClassInParty("Druid")
        + Core.NumberOfClassInParty("Shaman")
end
