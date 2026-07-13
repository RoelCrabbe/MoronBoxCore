-- [[ Config & Constants ]] --

MoronBox.Api = MoronBox.Api or {}
local Api = MoronBox.Api

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
