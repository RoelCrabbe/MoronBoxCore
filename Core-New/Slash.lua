function mb_changeSpecc(specc)
    if not (myClass == "Warrior" or myClass == "Druid") then
        Print("Usage /specc only works for druids and warriors")
        return
    end

    if specc == "" then
        Print("Usage /specc < classname >   < dps or tank >")
        return
    end

    local _, _, firstWord, restOfString = string.find(specc, "(%w+)[%s%p]*(.*)")
    if not firstWord then
        Print("Usage /specc < classname >   < dps or tank >")
        return
    end

    local inputClass = string.lower(firstWord)
    local playerClass = string.lower(UnitClass("player"))
    local inputSpecc = string.lower(restOfString or "")

    Print("Your current specc is: " .. MB_mySpecc)

    if inputClass ~= playerClass then
        Print("You had the wrong class given.")
        Print("Usage /specc < classname >   < dps or tank >")
        return
    end

    if playerClass == "warrior" then
        if inputSpecc == "tank" then
            mb_tankGear()
            return
        end

        if inputSpecc == "dps" then
            mb_furyGear()
            return
        end

        Print("Invalid warrior spec. Use 'tank' or 'dps'")
        return
    end

    if playerClass == "druid" then
        if inputSpecc == "tank" then
            MB_mySpecc = "Feral"
            return
        end

        if inputSpecc == "dps" then
            MB_mySpecc = "Kitty"
            return
        end

        Print("Invalid druid spec. Use 'tank' or 'dps'")
        return
    end
end

function mb_assignHealerToName(assignments)
    local _, _, healerName, assignedTarget = string.find(assignments, "(%a+)%s*(%a+)")

    if mb_imFocus() then
        if (assignedTarget == "Reset" or assignedTarget == "reset") then
            mb_cdMessage("Unassigned " .. healerName .. " from healing a specific player.")
            return
        end

        mb_cdMessage("Assigned " .. healerName .. " to heal " .. assignedTarget .. ".")
    end

    if myName == healerName then
        if (assignedTarget == "Reset" or assignedTarget == "reset") then
            Print("Unassigned myself to focusheal " .. MB_myAssignedHealTarget .. ".")
            MB_myAssignedHealTarget = nil
            return
        end

        MB_myAssignedHealTarget = assignedTarget
        Print("Assigning myself to focusheal " .. MB_myAssignedHealTarget .. ".")
    end
end
