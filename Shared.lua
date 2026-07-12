-- [[ Constants ]] --

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
--- @param needle string: The value to search for.
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
    return FindInTable(list, UnitName("player"))
end
