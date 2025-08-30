--[####################################################################################################]--
--[######################################### Chat Functions ###########################################]--
--[####################################################################################################]--

-- Unit Functions
local UnitName = UnitName
local UnitClass = UnitClass
local UnitRace = UnitRace
local UnitLevel = UnitLevel
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitMana = UnitMana
local UnitManaMax = UnitManaMax
local UnitPowerType = UnitPowerType
local UnitExists = UnitExists
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitIsDead = UnitIsDead
local UnitIsGhost = UnitIsGhost
local UnitIsConnected = UnitIsConnected
local UnitInParty = UnitInParty
local UnitInRaid = UnitInRaid
local UnitCanAttack = UnitCanAttack
local UnitIsFriend = UnitIsFriend
local UnitIsEnemy = UnitIsEnemy
local UnitIsVisible = UnitIsVisible
local UnitAffectingCombat = UnitAffectingCombat
local UnitCreatureType = UnitCreatureType
local UnitClassification = UnitClassification

-- Buff/Debuff Functions
local UnitBuff = UnitBuff
local UnitDebuff = UnitDebuff

-- Spell Functions
local CastSpellByName = CastSpellByName
local GetSpellCooldown = GetSpellCooldown
local IsCurrentAction = IsCurrentAction

-- Target Functions
local TargetUnit = TargetUnit
local TargetByName = TargetByName
local ClearTarget = ClearTarget
local AssistUnit = AssistUnit

-- Party/Raid Functions
local GetNumPartyMembers = GetNumPartyMembers
local GetNumRaidMembers = GetNumRaidMembers
local GetRaidRosterInfo = GetRaidRosterInfo
local IsRaidLeader = IsRaidLeader

-- Player Position/Info Functions
local GetRealZoneText = GetRealZoneText
local GetSubZoneText = GetSubZoneText

-- Addon Communication (if supported on your server)
local SendAddonMessage = SendAddonMessage

-- Misc Utility Functions
local IsShiftKeyDown = IsShiftKeyDown
local IsControlKeyDown = IsControlKeyDown
local IsAltKeyDown = IsAltKeyDown

-- Common Names
local myClass = UnitClass("player")
local myName = UnitName("player")
local myRace = UnitRace("player")

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local MB_msgHistory = {}
local MB_printHistory = {}
local MB_maxHistory = 50

function mb_cdMessage(msg, timer)
	local coolDown = timer or 15
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

function mb_cdPrint(msg, timer)
	local coolDown = timer or 15
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