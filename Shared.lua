-- [[ Constants ]] --

-- Common Names
local myClass = UnitClass("player") --[[@as string]]
local myName = UnitName("player") --[[@as string]]
local myRace = UnitRace("player") --[[@as string]]

---
--- Rounds `number` to the nearest integer, rounding half away from zero.
---
--- @param x number
--- @return number
--- @nodiscard
function math.round(x)
    return x >= 0 and math.floor(x + 0.5) or math.ceil(x - 0.5)
end

---@param tab table?
---@return integer
function TableLength(tab)
    if not tab then
        return 0
    end
    local n = table.getn(tab)
    local count = 0
    for _ in pairs(tab) do
        count = count + 1
    end
    if count == n then
        MoronBox.Debugger:Warn(
            "Called on a sequential table — could use ArrayLength() instead for better performance.")
    end
    return count
end

---@param tab table?
---@return integer
function ArrayLength(tab)
    if not tab then
        return 0
    end
    local n = table.getn(tab)
    local count = 0
    for _ in pairs(tab) do
        count = count + 1
    end
    if count ~= n then
        MoronBox.Debugger:Error(
            "Called on a non-sequential table — result may be wrong! Should use TableLength() instead.")
    end
    return n
end

--- Searches a table for a given value and returns true if found.
--- Logs an error via the Debugger and returns false if list is not a valid table.
--- @param list table: The table to search within.
--- @param needle? string|nil: The value to search for.
--- @return boolean: True if needle is found anywhere in list, false otherwise (including invalid input).
function FindInTable(list, needle)
    if type(list) ~= "table" then
        MoronBox.Debugger:Error("FindInTable: expected a table, got " .. type(list))
        return false
    end

    for _, value in pairs(list) do
        if value == needle then
            return true
        end
    end

    return false
end

--- Convenience wrapper around FindInTable that checks for the current player's
--- own name specifically, e.g. to check if the player is already in a role/list
--- such as MoronBox.Core.State.RaidTanks.
--- @param list table: The table to search within.
--- @return boolean: True if the player's own name is found in list, false otherwise.
function FindMyNameInTable(list)
    return FindInTable(list, myName)
end

function GetNumPartyOrRaidMembers()
    if UnitInRaid("player") then
        return GetNumRaidMembers()
    end
    return GetNumPartyMembers()
end

function GetTankDefenceStats()
    local dodge, parry, block = GetDodgeChance(), GetParryChance(), GetBlockChance()
    local total = dodge + parry + block
    Print(format("Def-Values: %.2f%% + %.2f%% + %.2f%% = %.2f%%", dodge, parry, block, total))
end

local CLASS_COLORS = {
    ["Warrior"] = "|cffC79C6E",
    ["Hunter"] = "|cffABD473",
    ["Mage"] = "|cff69CCF0",
    ["Rogue"] = "|cffFFF569",
    ["Warlock"] = "|cff9482C9",
    ["Druid"] = "|cffFF7D0A",
    ["Shaman"] = "|cff0070DE",
    ["Priest"] = "|cffFFFFFF",
    ["Paladin"] = "|cffF58CBA"
}

local RAID_MARKERS = {
    ["Skull"] = "|cffFFFFFF",
    ["Cross"] = "|cffFF0000",
    ["Square"] = "|cff00B4FF",
    ["Moon"] = "|cffCEECF5",
    ["Triangle"] = "|cff66FF00",
    ["Diamond"] = "|cffCC00FF",
    ["Circle"] = "|cffFF9900",
    ["Star"] = "|cffFFFF00"
}

local function applyColor(color, text)
    return color .. text .. "|r"
end

local function getUnitClassColor(unit, text)
    local _, unitClass = UnitClass(unit)
    if unitClass and CLASS_COLORS[unitClass] then
        return applyColor(CLASS_COLORS[unitClass], text)
    end
    return nil
end

function GetColors(note)
    if note == myName then
        return getUnitClassColor("player", note)
    end

    if UnitInRaid("player") then
        for i = 1, GetNumRaidMembers() do
            local unit = "raid" .. i
            if UnitName(unit) == note then
                return getUnitClassColor(unit, note)
            end
        end
    end

    if UnitInParty("player") then
        for i = 1, GetNumPartyMembers() do
            local unit = "party" .. i
            if UnitName(unit) == note then
                return getUnitClassColor(unit, note)
            end
        end
    end

    if UnitName("target") == note then
        return getUnitClassColor("target", note)
    end

    if RAID_MARKERS[note] then
        return applyColor(RAID_MARKERS[note], note)
    end

    return note
end
