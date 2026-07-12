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

--- Searches a table for a given value and returns its key if found.
--- @param list table: The table to search within.
--- @param needle string: The value to search for.
--- @return boolean: True if the needle is found, false otherwise (or list is nil).
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
