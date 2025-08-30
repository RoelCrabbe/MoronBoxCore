--[####################################################################################################]--
--[################################### SLASH COMMAND DEFINITIONS ######################################]--
--[####################################################################################################]--

-- Slash command definitions
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
	mb_changeSpecc(specc)
end

SlashCmdList["LOGOUT"] = function()	
	Logout()
end

SlashCmdList["TANKLIST"] = function(list)
	if UnitInRaid("player") then
		SendAddonMessage(MB_RAID.."MB_TANKLIST", list, "RAID")
	else
		SendAddonMessage(MB_RAID.."MB_TANKLIST", list)
	end
end

SlashCmdList["REPORTMANAPOTS"] = function()
	if UnitInRaid("player") then
		SendAddonMessage(MB_RAID, "MB_REPORTMANAPOTS", "RAID")
	else
		SendAddonMessage(MB_RAID, "MB_REPORTMANAPOTS")
	end
end

SlashCmdList["REPORTSHARDS"] = function()
	if UnitInRaid("player") then
		SendAddonMessage(MB_RAID, "MB_REPORTSHARDS", "RAID")
	else
		SendAddonMessage(MB_RAID, "MB_REPORTSHARDS")
	end
end

SlashCmdList["REPORTRUNES"] = function()
	if UnitInRaid("player") then
		SendAddonMessage(MB_RAID, "MB_REPORTRUNES", "RAID")
	else
		SendAddonMessage(MB_RAID, "MB_REPORTRUNES")
	end
end

SlashCmdList["NEFCLOAK"] = function(item)
	if UnitInRaid("player") then
		SendAddonMessage(MB_RAID, "MB_NEFCLOAK", "RAID")
	else
		SendAddonMessage(MB_RAID, "MB_NEFCLOAK")
	end
end
	
SlashCmdList["REMOVEBUFFS"] = function(buff)
	if UnitInRaid("player") then
		SendAddonMessage(MB_RAID.."MB_REMOVEBUFFS", buff, "RAID")
	else
		SendAddonMessage(MB_RAID.."MB_REMOVEBUFFS", buff)
	end
end

SlashCmdList["REMOVEBLESS"] = function(buff)
	if UnitInRaid("player") then
		SendAddonMessage(MB_RAID.."MB_REMOVEBLESS", buff, "RAID")
	else
		SendAddonMessage(MB_RAID.."MB_REMOVEBLESS", buff)
	end
end

SlashCmdList["AQBOOKS"] = function()
	if UnitInRaid("player") then
		SendAddonMessage(MB_RAID, "MB_AQBOOKS", "RAID")
	else
		SendAddonMessage(MB_RAID, "MB_AQBOOKS")
	end
end

SlashCmdList["INIT"] = function()
	mb_createMacros()
end

SlashCmdList["DISBAND"] = function()
	mb_disbandRaid()
end

SlashCmdList["USEBAGITEM"] = function(item)
	if UnitInRaid("player") then
		SendAddonMessage(MB_RAID.."MB_USEBAGITEM", item, "RAID")
	else
		SendAddonMessage(MB_RAID.."MB_USEBAGITEM", item)
	end
end

SlashCmdList["GEAR"] = function(itemSet)
	if UnitInRaid("player") then
		SendAddonMessage(MB_RAID.."MB_GEAR", itemSet, "RAID")
	else
		SendAddonMessage(MB_RAID.."MB_GEAR", itemSet)
	end
end
	
SlashCmdList["ASSIGNHEALER"] = function(names)
	if UnitInRaid("player") then
		SendAddonMessage(MB_RAID.."MB_ASSIGNHEALER", names, "RAID")
	else
		SendAddonMessage(MB_RAID.."MB_ASSIGNHEALER", names)
	end
end
