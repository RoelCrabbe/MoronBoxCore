-- [[ Config & Constants ]] --

local myClass = UnitClass("player")
local myName = UnitName("player")
local myRace = UnitRace("player")

local function ChangeSpecc(specc)
    if not (myClass == "Warrior" or myClass == "Druid") then
        getDebugger().InfoMsg("Usage /specc only works for druids and warriors")
        return
    end

    if specc == "" then
        getDebugger().InfoMsg("Usage /specc < classname >   < dps or tank >")
        return
    end

    local _, _, firstWord, restOfString = string.find(specc, "(%w+)[%s%p]*(.*)")
    if not firstWord then
        getDebugger().InfoMsg("Usage /specc < classname >   < dps or tank >")
        return
    end

    local inputClass = string.lower(firstWord)
    local playerClass = string.lower(UnitClass("player"))
    local inputSpecc = string.lower(restOfString or "")

    getDebugger().InfoMsg("Your current specc is: " .. getConfigState().PlayerSpecc)

    if inputClass ~= playerClass then
        getDebugger().InfoMsg("You had the wrong class given.")
        getDebugger().InfoMsg("Usage /specc < classname >   < dps or tank >")
        return
    end

    if playerClass == "warrior" then
        if inputSpecc == "tank" then
            getGear().TankGear()
            return
        end

        if inputSpecc == "dps" then
            getGear().FuryGear()
            return
        end

        getDebugger().InfoMsg("Invalid warrior spec. Use 'tank' or 'dps'")
        return
    end

    if playerClass == "druid" then
        if inputSpecc == "tank" then
            getConfigState().PlayerSpecc = "Feral"
            return
        end

        if inputSpecc == "dps" then
            getConfigState().PlayerSpecc = "Kitty"
            return
        end

        getDebugger().InfoMsg("Invalid druid spec. Use 'tank' or 'dps'")
        return
    end
end

local function AssignHealerToName(assignments)
    local _, _, healerName, assignedTarget = string.find(assignments, "(%a+)%s*(%a+)")

    if getRaid().ImFocus() then
        if (assignedTarget == "Reset" or assignedTarget == "reset") then
            getApi().CdMessage("Unassigned " .. healerName .. " from healing a specific player.")
            return
        end

        getApi().CdMessage("Assigned " .. healerName .. " to heal " .. assignedTarget .. ".")
    end

    if myName == healerName then
        if (assignedTarget == "Reset" or assignedTarget == "reset") then
            getDebugger().InfoMsg("Unassigned myself to focusheal " .. MB_myAssignedHealTarget .. ".")
            MB_myAssignedHealTarget = nil
            return
        end

        MB_myAssignedHealTarget = assignedTarget
        getDebugger().InfoMsg("Assigning myself to focusheal " .. MB_myAssignedHealTarget .. ".")
    end
end

-- [[ Slash Commands ]] --

SLASH_INIT1 = "/init"
SLASH_INIT2 = "/Init"

SLASH_GEAR1 = "/gear"
SLASH_GEAR2 = "/Gear"
SLASH_GEAR3 = "/GEAR"

SLASH_REPORTMANAPOTS1 = "/reportmanapots"
SLASH_REPORTMANAPOTS2 = "/Reportmanapots"
SLASH_REPORTMANAPOTS3 = "/REPORTMANAPOTS"

SLASH_REPORTSHARDS1 = "/reportshards"
SLASH_REPORTSHARDS2 = "/Reportshards"
SLASH_REPORTSHARDS3 = "/REPORTSHARDS"

SLASH_REPORTRUNES1 = "/reportrunes"
SLASH_REPORTRUNES2 = "/Reportrunes"
SLASH_REPORTRUNES3 = "/REPORTRUNES"

SLASH_ASSIGNHEALER1 = "/healer"
SLASH_ASSIGNHEALER2 = "/Healer"
SLASH_ASSIGNHEALER3 = "/HEALER"

SLASH_USEBAGITEM1 = "/usebagitem"
SLASH_USEBAGITEM2 = "/Usebagitem"
SLASH_USEBAGITEM3 = "/USEBAGITEM"

SLASH_REMOVEBUFFS1 = "/removebuffs"
SLASH_REMOVEBUFFS2 = "/Removebuffs"
SLASH_REMOVEBUFFS3 = "/REMOVEBUFFS"

SLASH_REMOVEBLESS1 = "/removebles"
SLASH_REMOVEBLESS2 = "/Removebles"
SLASH_REMOVEBLESS3 = "/REMOVEBLES"

SLASH_NEFCLOAK1 = "/nefcloak"
SLASH_NEFCLOAK2 = "/Nefcloak"
SLASH_NEFCLOAK3 = "/NEFCLOAK"

SLASH_AQBOOKS1 = "/reportspells"
SLASH_AQBOOKS2 = "/Reportspells"
SLASH_AQBOOKS3 = "/REPORTSPELLS"

SLASH_DISBAND1 = "/disband"
SLASH_DISBAND2 = "/Disband"
SLASH_DISBAND3 = "/DISBAND"
SLASH_DISBAND4 = "/db"
SLASH_DISBAND5 = "/Db"
SLASH_DISBAND6 = "/DB"

SLASH_LOGOUT1 = "/lo"
SLASH_LOGOUT2 = "/Lo"
SLASH_LOGOUT3 = "/LO"

SLASH_CHANGESPECC1 = "/specc"
SLASH_CHANGESPECC2 = "/Specc"
SLASH_CHANGESPECC3 = "/SPECC"

SLASH_TANKLIST1 = "/tanklist"
SLASH_TANKLIST2 = "/Tanklist"
SLASH_TANKLIST3 = "/TANKLIST"

-- Slash command handlers
SlashCmdList["CHANGESPECC"] = function(specc)
    ChangeSpecc(specc)
end

SlashCmdList["MBLOGOUT"] = function()
    Logout()
end

SlashCmdList["TANKLIST"] = function(list)
    getApi().SendAddonMessage(MB_RAID .. "MB_TANKLIST", list)
end

SlashCmdList["REPORTMANAPOTS"] = function()
    getApi().SendAddonMessage(MB_RAID, "MB_REPORTMANAPOTS")
end

SlashCmdList["REPORTSHARDS"] = function()
    getApi().SendAddonMessage(MB_RAID, "MB_REPORTSHARDS")
end

SlashCmdList["REPORTRUNES"] = function()
    getApi().SendAddonMessage(MB_RAID, "MB_REPORTRUNES")
end

SlashCmdList["NEFCLOAK"] = function(item)
    getApi().SendAddonMessage(MB_RAID, "MB_NEFCLOAK")
end

SlashCmdList["REMOVEBUFFS"] = function(buff)
    getApi().SendAddonMessage(MB_RAID .. "MB_REMOVEBUFFS", buff)
end

SlashCmdList["REMOVEBLESS"] = function(buff)
    getApi().SendAddonMessage(MB_RAID .. "MB_REMOVEBLESS", buff)
end

SlashCmdList["AQBOOKS"] = function()
    getApi().SendAddonMessage(MB_RAID, "MB_AQBOOKS")
end

SlashCmdList["INIT"] = function()
    getMacro().CreateMacros()
end

SlashCmdList["DISBAND"] = function()
    getUnit().DisbandRaid()
end

SlashCmdList["USEBAGITEM"] = function(item)
    getApi().SendAddonMessage(MB_RAID .. "MB_USEBAGITEM", item)
end

SlashCmdList["GEAR"] = function(itemSet)
    getApi().SendAddonMessage(MB_RAID .. "MB_GEAR", itemSet)
end

SlashCmdList["ASSIGNHEALER"] = function(names)
    getApi().SendAddonMessage(MB_RAID .. "MB_ASSIGNHEALER", names)
end
