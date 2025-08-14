--[####################################################################################################]--
--[###################################### Raid Role Information #######################################]--
--[####################################################################################################]--

local myClass = UnitClass("player")

function mb_imRangedDPS() 
    if myClass == "Hunter" or myClass == "Warlock" or myClass == "Mage" then
        return true
    elseif myClass == "Shaman" and MB_mySpecc == "Elemental" then
        return true
    elseif myClass == "Priest" and MB_mySpecc == "Shadow" then
        return true
    end
    return false
end

function mb_imMeleeDPS()
    if myClass == "Rogue" then
        return true
    elseif myClass == "Warrior" and (MB_mySpecc == "MS" or MB_mySpecc == "BT") then
        return true
    end
    return false
end

function mb_imTank() 
    if myClass == "Warrior" and (MB_mySpecc == "Prottank" or MB_mySpecc == "Furytank") then
        return true
    elseif myClass == "Druid" and MB_mySpecc == "Feral" then
        return true
    end
    return false
end

function mb_imHealer()
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