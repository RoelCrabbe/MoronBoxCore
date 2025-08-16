--[####################################################################################################]--
--[###################################### Raid Role Information #######################################]--
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

function mb_myGroupOrder()
	local myParty = {}

	table.insert(myParty, myName)

	for i = 1, GetNumPartyMembers() do
		local name, _ =  UnitName("party"..i)
		table.insert(myParty, name)
	end

	table.sort(myParty)

	local order = 1
	for k, toon in pairs(myParty) do
		if toon == myName then
            return order
        end

		order = order + 1
	end
	return order
end

function mb_myClassOrder()
	local myClassToons = {}

	for name, id in MBID do
		class = UnitClass(id)
		if class == myClass and mb_isAlive(id) then
			if UnitPowerType(id) == 0 then
                myClassToons[name] = UnitManaMax(id)
			else
                myClassToons[name] = UnitHealthMax(id)
                 end
		end
	end

	local order = 1
	for name, power in sPairs(myClassToons, function(t, a, b) return t[b] < t[a] end) do
		if name == myName then
            return order
        end

		order = order + 1
	end
	return 0
end

function mb_myInvertedClassOrder()
	local myClassToons = {}

	for name, id in MBID do
		class = UnitClass(id)
		if class == myClass and mb_isAlive(id) then
			if UnitPowerType(id) == 0 then
                myClassToons[name] = UnitManaMax(id)
			else
                myClassToons[name] = UnitHealthMax(id)
            end
		end
	end

	local order = 1
	for name, power in sPairs(myClassToons, function(t, a, b) return t[b] > t[a] end) do
		if name == myName then
            return order
        end

		order = order + 1
	end
	return 0
end

function mb_myGroupClassOrder()
	local myClassToons = {}
	local name, realm =  UnitName("player")

	if UnitPowerType("player") == 0 then 
		myClassToons[name] = UnitManaMax("player")
	else 
		myClassToons[name] = UnitHealthMax("player") 
	end

	for i = 1, 4 do
		class = UnitClass("party"..i)
		local name, realm =  UnitName("party"..i)
		if class == myClass and mb_isAlive("party"..i) then
			if UnitPowerType("party"..i) == 0 then
                myClassToons[name] = UnitManaMax("party"..i)
			else
                myClassToons[name] = UnitHealthMax("party"..i)
            end
		end
	end

	local order = 1
	for name, power in sPairs(myClassToons, function(t, a, b) return t[b] < t[a] end) do
		if name == myName then
            return order
        end

		order = order + 1
	end
	return 0
end

function mb_myInvertedGroupClassOrder()
	local myClassToons = {}
	local name, realm =  UnitName("player")

	if UnitPowerType("player") == 0 then 
		myClassToons[name] = UnitManaMax("player")
	else 
		myClassToons[name] = UnitHealthMax("player") 
	end

	for i = 1, 4 do
		class = UnitClass("party"..i)
		local name, realm =  UnitName("party"..i)
		if class == myClass and mb_isAlive("party"..i) then
			if UnitPowerType("party"..i) == 0 then
                myClassToons[name] = UnitManaMax("party"..i)
			else
                myClassToons[name] = UnitHealthMax("party"..i)
            end
		end
	end

	local order = 1
	for name, power in sPairs(myClassToons, function(t, a, b) return t[b] > t[a] end) do
		if name == myName then
            return order
        end

		order = order + 1
	end
	return 0
end

function mb_myClassAlphabeticalOrder()
	local myClassToons = {}

	for name, id in MBID do
		class = UnitClass(id)
		if class == myClass and mb_isAlive(id) then
			table.insert(myClassToons, name)
		end
	end

	local order = 1	
	table.sort(myClassToons)

	for _, name in myClassToons do
		if name == myName then
            return order
        end

		order = order + 1
	end
	return 0
end

function mb_myClassAlphabeticalOrderGivenClass(classTable)
	local myClassToons = {}

	for name, id in classTable do
		class = UnitClass(id)
		if class == myClass and mb_isAlive(id) then
			table.insert(myClassToons, name)
		end
	end

	local order = 1	
	table.sort(myClassToons)

	for _, name in myClassToons do
		if name == myName then
            return order
        end

		order = order + 1
	end
	return 0
end

function mb_numberOfClassInParty(checkClass)
	local i = 0
	local MyGroup = MB_groupID[myName]

	if not MyGroup then
        return 0
    end

	for _, name in MB_toonsInGroup[MyGroup] do
		if MBID[name] and UnitClass(MBID[name]) == checkClass then
			i = i + 1 
		end
	end
	return i
end

function mb_getNameFromPlayerClassInParty(checkClass)
	local MyGroup = MB_groupID[myName]

	if not MyGroup then
        return 0
    end

	for _, name in MB_toonsInGroup[MyGroup] do
		if MBID[name] and UnitClass(MBID[name]) == checkClass then
			return name
		end
	end
end

function mb_isMageInGroup()
    local mages = {}

    if UnitInRaid("player") then
        for i = 1, GetNumRaidMembers() do
            local name, _, _, _, iClass = GetRaidRosterInfo(i)
            if iClass == "Mage" then 
                table.insert(mages, name) 
            end
        end
    else
        if UnitClass("player") == "Mage" then 
            table.insert(mages, UnitName("player")) 
        end
           
        for i = 1, 4 do
            local iClass = UnitClass("party"..i)
            local name = UnitName("party"..i)
           
            if iClass == "Mage" and name then
                table.insert(mages, name)
            end
        end
    end
    
    if TableLength(mages) == 0 then
        return nil
    else
        return mages[math.random(TableLength(mages))]
    end
end

function mb_meleeDPSInParty()
	if mb_numberOfClassInParty("Warrior") > 0 or mb_numberOfClassInParty("Rogue") > 0 then
		return true
	end
end

function mb_numOfCasterHealerInParty()
    local total = 0
    total = mb_numberOfClassInParty("Mage") + mb_numberOfClassInParty("Priest") + mb_numberOfClassInParty("Druid") + mb_numberOfClassInParty("Shaman")
    return total
end