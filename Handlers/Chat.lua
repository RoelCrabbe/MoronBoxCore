--[####################################################################################################]--
--[######################################### Chat Functions ###########################################]--
--[####################################################################################################]--

local MB_msgHistory = {}
local MB_printHistory = {}
local MB_maxHistory = 5

function mb_message(msg, timer)
	local coolDown = timer or 10
	local time = GetTime()

	for i = 1, TableLength(MB_msgHistory) do
		local entry = MB_msgHistory[i]
		if entry.msg == msg and entry.time + coolDown > time then
			return
		end
	end

	if TableLength(MB_msgHistory) >= MB_maxHistory then
		table.remove(MB_msgHistory, 1)
	end

	table.insert(MB_msgHistory, {msg = msg, time = time})

	if UnitInRaid("player") then
		SendChatMessage(msg, "RAID")
	else
		SendChatMessage(msg, "PARTY")
	end
end

function mb_coolDownPrint(msg, timer)
	local coolDown = timer or 10
	local time = GetTime()

	for i = 1, TableLength(MB_printHistory) do
		local entry = MB_printHistory[i]
		if entry.msg == msg and entry.time + coolDown > time then
			return
		end
	end

	if TableLength(MB_printHistory) >= MB_maxHistory then
		table.remove(MB_printHistory, 1)
	end

	table.insert(MB_printHistory, {msg = msg, time = time})
	Print(msg)
end

function Print(msg)
	if msg then return DEFAULT_CHAT_FRAME:AddMessage(msg) end
end

function print(msg)
	if msg then return DEFAULT_CHAT_FRAME:AddMessage(msg) end
end