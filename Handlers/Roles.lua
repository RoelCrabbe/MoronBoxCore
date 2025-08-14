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