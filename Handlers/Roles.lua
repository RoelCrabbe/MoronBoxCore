--[####################################################################################################]--
--[###################################### Raid Role Information #######################################]--
--[####################################################################################################]--

local RANGED_DPS = {
    Hunter = true,
    Warlock = true,
    Mage = true,
    Priest = { Shadow = false, default = true },
    Shaman = { Elemental = true }
}

local MELEE_DPS = {
    Rogue = true,
    Warrior = { MS = true, BT = true }
}

local TANK = {
    Warrior = { Prottank = true, Furytank = true },
    Druid = { Feral = true }
}

local HEALER = {
    Paladin = true,
    Druid = { Swiftmend = true, Resto = true },
    Shaman = true,
    Priest = { Shadow = false, default = true }
}

local function CheckRole(roleTable)
    local val = roleTable[myClass]
    if type(val) == "table" then
        if val[MB_mySpecc] then
            return true
        elseif val.default then
            return true
        end
    elseif val then
        return true
    end
    return false
end

function mb_imRangedDPS() return CheckRole(RANGED_DPS) end
function mb_imMeleeDPS() return CheckRole(MELEE_DPS) end
function mb_imTank() return CheckRole(TANK) end
function mb_imHealer() return CheckRole(HEALER) end