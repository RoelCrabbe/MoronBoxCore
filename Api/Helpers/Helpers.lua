--[####################################################################################################]--
--[####################################### Helper Locals! #############################################]--
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

function mb_tankName()
	if not MB_raidLeader then
		return
	end

	local focusId = MBID[MB_raidLeader]
	if focusId then
		return UnitName(focusId)
	else
		TargetByName(MB_raidLeader, 1)
		return "target"
	end
end

function mb_promoteEveryone()
	for toon, id in MBID do
        PromoteToAssistant(toon)
    end
end

function mb_clearTargetIfNotAggroed()
	if not mb_inCombat("target") then
        ClearTarget()
    end
end

function mb_crowdControlledMob()
    if (mb_hasBuffOrDebuff("Shackle Undead", "target", "debuff")
        or mb_hasBuffOrDebuff("Polymorph", "target", "debuff")
        or mb_hasBuffOrDebuff("Banish", "target", "debuff")) then
        return true
	end
	return false
end

function mb_inCombat(unit)
	local unit = unit or "player"
	return UnitAffectingCombat(unit)
end

function mb_healthPct(unit)
	local unit = unit or "player"
	return UnitHealth(unit) / UnitHealthMax(unit)
end

function mb_healthDown(unit)
	local unit = unit or "player"
	return UnitHealthMax(unit) - UnitHealth(unit)
end

function mb_manaPct(unit)
	local unit = unit or "player"
	return UnitMana(unit) / UnitManaMax(unit)
end

function mb_manaUser(unit)
	local unit = unit or "player"
	return UnitPowerType(unit) == 0
end

function mb_manaDown(unit)
	local unit = unit or "player"
	if mb_manaUser(unit) then
		return UnitManaMax(unit)-UnitMana(unit)
	else
		return 0
	end
end

function mb_dead(unit)
	local unit = unit or "player"
	return UnitIsDeadOrGhost(unit) or not (UnitHealth(unit) > 1)
end

function mb_manaOfUnit(name)
	if not MBID[name] then return 0 end
	return UnitMana(MBID[name])
end

function mb_haveAggro()
	return UnitName("targettarget") == myName
end

function mb_isAlive(id)
    if not id then
        return false
    end
    
    if not UnitName(id) then
        return false
    end
    
    if UnitIsDead(id) then
        return false
    end
    
    if UnitHealth(id) <= 1 then
        return false
    end
    
    if UnitIsGhost(id) then
        return false
    end
    
    if not UnitIsConnected(id) then
        return false
    end    
    return true
end

function mb_isInGroup(unit)
	for i = 1, GetNumPartyMembers() do
		if unit == UnitName("party"..i) then
			return true
		end
	end
	return false
end

function mb_isInRaid(unit)
	for i = 1, GetNumRaidMembers() do
		if unit == UnitName("raid"..i) then
			return true
		end
	end
	return false
end

function mb_unitInRaidOrParty(unit)
	local unitID = MBID[unit]
	
	if UnitInRaid(unitID) then		
		return true
	elseif UnitInParty(unitID) then		
		return true
	end
	return false
end

function mb_unitInRange(unit)
	if CheckInteractDistance(unit, 4) then
		return true
	end
	return nil
end

function mb_partyMana()
    MB_partyMana = 0
    MB_partyMaxMana = 0
    MB_partyManaPCT = 0
    MB_partyManaDown = 0
    
    local myId = MBID[myName]
    if not myId then
        return MB_partyManaPCT, MB_partyManaDown, MB_partyMana, MB_partyMaxMana
    end
    
    if not UnitInParty(myId) then
        return MB_partyManaPCT, MB_partyManaDown, MB_partyMana, MB_partyMaxMana
    end
    
    local myGroup = MB_groupID[myName]
    if not myGroup then
        return MB_partyManaPCT, MB_partyManaDown, MB_partyMana, MB_partyMaxMana
    end
    
    local groupMembers = MB_toonsInGroup[myGroup]
    if not groupMembers then
        return MB_partyManaPCT, MB_partyManaDown, MB_partyMana, MB_partyMaxMana
    end
    
    for k, name in pairs(groupMembers) do
        local memberId = MBID[name]
        if not memberId then
        else
            local isAlive = mb_isAlive(memberId)
            local canUseMana = mb_manaUser(memberId)
            
            if isAlive and canUseMana then
                local currentMana = UnitMana(memberId)
                local maxMana = UnitManaMax(memberId)
                
                MB_partyMana = MB_partyMana + currentMana
                MB_partyMaxMana = MB_partyMaxMana + maxMana
            end
        end
    end
    
    if MB_partyMaxMana > 0 then
        MB_partyManaPCT = (MB_partyMana / MB_partyMaxMana)
        MB_partyManaDown = (MB_partyMaxMana - MB_partyMana)
    end
    
    return MB_partyManaPCT, MB_partyManaDown, MB_partyMana, MB_partyMaxMana
end

function mb_raidHealth()
    if not UnitInRaid("player") then
        return mb_partyHealth()
    end
    
    MB_raidHealth = 0
    MB_raidMaxHealth = 0
    MB_raidHealthPCT = 0
    MB_raidHealthDown = 0
    
    if not MBID then
        return MB_raidHealthPCT, MB_raidHealthDown
    end
    
    for name, id in pairs(MBID) do
        if not id then
        else
            local isAlive = mb_isAlive(id)
            if isAlive then
                local currentHealth = UnitHealth(id)
                local maxHealth = UnitHealthMax(id)
                
                MB_raidHealth = MB_raidHealth + currentHealth
                MB_raidMaxHealth = MB_raidMaxHealth + maxHealth
            end
        end
    end
    
    if MB_raidMaxHealth > 0 then
        MB_raidHealthPCT = (MB_raidHealth / MB_raidMaxHealth)
        MB_raidHealthDown = (MB_raidMaxHealth - MB_raidHealth)
    end
    
    return MB_raidHealthPCT, MB_raidHealthDown
end

function mb_partyHealth()
    MB_partyHealth = 0
    MB_partyMaxHealth = 0
    MB_partyHealthPCT = 0
    MB_partyHealthDown = 0
    
    local myId = MBID[myName]
    if not myId then
        return MB_partyHealthPCT, MB_partyHealthDown
    end
    
    if not UnitInParty(myId) then
        return MB_partyHealthPCT, MB_partyHealthDown
    end
    
    local myGroup = MB_groupID[myName]
    if not myGroup then
        return MB_partyHealthPCT, MB_partyHealthDown
    end
    
    local groupMembers = MB_toonsInGroup[myGroup]
    if not groupMembers then
        return MB_partyHealthPCT, MB_partyHealthDown
    end
    
    for _, name in pairs(groupMembers) do
        local memberId = MBID[name]
        if not memberId then
        else
            local isAlive = mb_isAlive(memberId)
            if isAlive then
                local currentHealth = UnitHealth(memberId)
                local maxHealth = UnitHealthMax(memberId)
                
                MB_partyHealth = MB_partyHealth + currentHealth
                MB_partyMaxHealth = MB_partyMaxHealth + maxHealth
            end
        end
    end
    
    if MB_partyMaxHealth > 0 then
        MB_partyHealthPCT = (MB_partyHealth / MB_partyMaxHealth)
        MB_partyHealthDown = (MB_partyMaxHealth - MB_partyHealth)
    end
    
    return MB_partyHealthPCT, MB_partyHealthDown
end

function mb_warriorHealth()
    MB_raidWarriorHealth = 0
    MB_raidWarriorMaxHealth = 0
    MB_raidWarriorHealthPCT = 0
    MB_raidWarriorHealthDown = 0
    
    local warriorList = MB_classList["Warrior"]
    if not warriorList then
        return MB_raidWarriorHealthPCT, MB_raidWarriorHealthDown
    end
    
    for id, name in pairs(warriorList) do
        local warriorId = MBID[name]
        if not warriorId then
        else
            local isAlive = mb_isAlive(warriorId)
            if isAlive then
                local currentHealth = UnitHealth(warriorId)
                local maxHealth = UnitHealthMax(warriorId)
                
                MB_raidWarriorHealth = MB_raidWarriorHealth + currentHealth
                MB_raidWarriorMaxHealth = MB_raidWarriorMaxHealth + maxHealth
            end
        end
    end
    
    if MB_raidWarriorMaxHealth > 0 then
        MB_raidWarriorHealthPCT = (MB_raidWarriorHealth / MB_raidWarriorMaxHealth)
        MB_raidWarriorHealthDown = (MB_raidWarriorMaxHealth - MB_raidWarriorHealth)
    end
    
    return MB_raidWarriorHealthPCT, MB_raidWarriorHealthDown
end

function mb_inMeleeRange()
	return CheckInteractDistance("target", 3)
end

function mb_inTradeRange(id)
	if not id then return end
	return CheckInteractDistance(id, 2)
end

function mb_in28yardRange(id)
	if not id then return end
	return CheckInteractDistance(id, 4)
end

function mb_isValidFriendlyTargetWithin28YardRange(unit)
	if UnitExists(unit) and 
		mb_isAlive(unit) and
		UnitIsVisible(unit) and
		mb_in28yardRange(unit) then
		return true
	end
	return false
end

function mb_isValidEnemyTargetWithin28YardRange(unit)
	if UnitExists(unit) and 
		mb_inCombat(unit) and
		mb_in28yardRange(unit) then
		return true
	end
	return false
end

function mb_GetNumPartyOrRaidMembers()
	if UnitInRaid("player") then
		return GetNumRaidMembers()
	else
		return GetNumPartyMembers()
	end
	return 0
end

function mb_isValidFriendlyTarget(unit, spell)
	if UnitExists(unit) and 
		mb_isAlive(unit) and
		UnitIsVisible(unit) and
		mb_canHelpfulSpellBeCastOn(spell, unit) then
		return true
	end
	return false
end

function mb_isValidMeleeTarget(unit)
	if UnitExists(unit) and 
		mb_isAlive(unit) and
		mb_inCombat(unit) and
		mb_inMeleeRange(unit) then
		return true
	end
	return false
end

function mb_isNotValidTankableTarget()
	if not UnitName("target") then		
		return true
	elseif not UnitAffectingCombat("target") then
		return true
	elseif not CheckInteractDistance("target", 3) then
		return true
	elseif not mb_dead("target") then
		return true
	elseif mb_crowdControlledMob() then		
		return true
	end
end

function mb_canHelpfulSpellBeCastOn(spell, unit)
	if MB_raidAssist.Use40yardHealingRangeOnInstants then 

		local oldTarget
		if UnitName("target") then
			oldTarget = UnitName("target")
			ClearTarget()
		end

		local can = false
		CastSpellByName(spell, false)
		if SpellCanTargetUnit(unit) then
			can = true
		end
		
		SpellStopTargeting()
		
		if oldTarget then
			TargetByName(oldTarget)
		end
		return can
		
	else
		return mb_in28yardRange(unit)
	end
end

function mb_getUnitForPlayerName(playerName)
	local members = mb_GetNumPartyOrRaidMembers()

	for i = 1, members do
		local unit = mb_getUnitFromPartyOrRaidIndex(i)
		if UnitName(unit) == playerName then
			return unit
		end
	end

	if myName == playerName then
		return "player"
	end
	return nil
end

function mb_getLink(item)
	for bag = 0, 4 do 
		for slot = 1, GetContainerNumSlots(bag) do 
			local texture, _, _, _, _, _, link = GetContainerItemInfo(bag, slot) 

			if texture then
				link = GetContainerItemLink(bag, slot) 
				if string.find(link, item) then 
					return link 
				end
			end
		end 
	end
end

function mb_getRaidIndexForPlayerName(playerName)
	local members = GetNumRaidMembers()

	for i = 1, members do
		local unit = mb_getUnitFromPartyOrRaidIndex(i)
		if UnitName(unit) == playerName then
			return i
		end
	end
	return nil
end

function mb_getUnitFromPartyOrRaidIndex(index)
	if index ~= 0 then
		if UnitInRaid("player") then
			return "raid"..index
		else			
			return "party"..index
		end
	end
	return "player"
end

function mb_myNameInTable(table)
   if not table then
       return false
   end
   
   if not myName then
       return false
   end
   
   for k, name in pairs(table) do
       if myName == name then
           return true
       end
   end
   
   return false
end

function mb_returnPlayerInRaidFromTable(table)
   if not table then
       return nil
   end
   
   for k, name in pairs(table) do
       if not name then
       else
           local isInRaid = mb_isInRaid(name)
           if isInRaid then
               return name
           end
       end
   end
   
   return nil
end

function RaidIdx(qName)
	return string.gsub(MBID[qName], "raid", "")
end

function mb_isItemInBagCoolDown(itemName)
	local bag, slot = nil
	for bag = 0, 4 do
		for slot = 1, mb_bagSize(bag) do
			local link = GetContainerItemLink(bag, slot)
			if link and strfind(link, itemName) then
				return mb_returnItemInBagCooldown(bag, slot)
			end
		end
	end
end

function mb_returnItemInBagCooldown(bag, slot) --returns true if on CD, false if not on CD
	local start, duration, enable = GetContainerItemCooldown(bag, slot)
	if enable == 1 and duration == 0 then
		return false
	elseif enable == 1 and duration >= 1 then
		return true
	end
	return nil
end

function mb_bagSize(i)
	return GetContainerNumSlots(i)
end

function mb_bagSlotOf(itemName)
	local bag, slot = nil
	for bag = 0, 4 do
		for slot = 1, mb_bagSize(bag) do
			local link = GetContainerItemLink(bag, slot)
			if link and string.find(link, itemName) then
				return bag, slot
			end
		end
	end
	return false
end

function mb_haveInBags(itemName)
	if mb_bagSlotOf(itemName) then
		return true
	end
	return false
end

function mb_useFromBags(itemName)
	if mb_haveInBags(itemName) then
		UseContainerItem(mb_bagSlotOf(itemName))
		return true
	else
		return false
	end
end

function mb_getAllContainerFreeSlots()
	local sum = 0
	for i = 0, 4 do
		sum = sum + mb_getContainerNumFreeSlots(i)
	end
	return sum
end

function mb_getContainerNumFreeSlots(slotNum)
	local totalSlots = GetContainerNumSlots(slotNum)
	local count = 0
	
	for i = 1, totalSlots do
		if not GetContainerItemLink(slotNum, i) then count = count + 1 end
	end
	return count
end

function mb_hasQuiver()
	for bag = 0, 4 do
		if GetBagName(bag) and string.find(GetBagName(bag), "Quiver") then return true end
	end
end

function mb_hasPouch()
	for bag = 0, 4 do
		if GetBagName(bag) and string.find(GetBagName(bag), "Ammo Pouch") then return true end
	end
end

function mb_isBearForm()
	return mb_warriorIsStance(1)
end

function mb_isSwimForm()
	return mb_warriorIsStance(2)
end

function mb_isCatForm()
	return mb_warriorIsStance(3)
end

function mb_isTravelForm()
	return mb_warriorIsStance(4)
end

function mb_isBoomForm()
	return mb_warriorIsStance(5)
end

function mb_isDruidShapeShifted()
	if myClass ~= "Druid" then
		return false
	end

	if mb_isBearForm() then 
		return true
	end

	if mb_isSwimForm() then 
		return true
	end

	if mb_isCatForm() then 
		return true
	end

	if mb_isTravelForm() then 
		return true
	end

	if mb_isBoomForm() then 
		return true
	end
end

function mb_cancelDruidShapeShift()
	if mb_isBearForm() then
		mb_warriorSetStance(1)
		return
	end

	if mb_isSwimForm() then
		mb_warriorSetStance(2)
		return
	end

	if mb_isCatForm() then
		mb_warriorSetStance(3)
		return
	end

	if mb_isTravelForm() then
		mb_warriorSetStance(4)
		return
	end
	
	if mb_isBoomForm() then 
		b_warriorSetStance(5)
		return
	end
end

function mb_warriorIsStance(id)
	local x0, x1, st, x3 = GetShapeshiftFormInfo(id)
	return st
end

function mb_warriorIsBattle()
	return mb_warriorIsStance(1)
end

function mb_warriorIsDefensive()
	return mb_warriorIsStance(2)
end

function mb_warriorIsBerserker()
	return mb_warriorIsStance(3)
end

function mb_warriorSetStance(id)
	CastShapeshiftForm(id)
end

function mb_warriorSetBattle()
	if not mb_warriorIsBattle() then
		mb_warriorSetStance(1)
	end
end

function mb_warriorSetDefensive()
	if not mb_warriorIsDefensive() then
		mb_warriorSetStance(2)
	end
end

function mb_warriorSetBerserker()
	if not mb_warriorIsBerserker() then
		mb_warriorSetStance(3)
	end
end

function mb_numShards()
	local shards = 0
	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			local link = GetContainerItemLink(bag, slot)
			if link == nil then
				link = ""
			end
			if string.find(link, "Soul Shard") then
				shards = shards + 1
			end
		end
	end
	return shards
end

function mb_reportShards()
	if myClass ~= "Warlock" then
		return
	end

	local count = mb_numShards() or 0
	mb_message("I\'ve got "..count.." shards!")
end

function mb_reportRunes()
	if not mb_imHealer() then
		return
	end

	local count = mb_hasItem("Demonic Rune") or 0
	mb_message("I\'ve got "..count.." runes!")
end

function mb_reportManapots()
	if not mb_imHealer() then
		return
	end

	local count = mb_hasItem("Major Mana Potion") or 0
	mb_message("I\'ve got "..count.." pots!")
end

function mb_partyIsPoisoned()	
	if mb_tankTarget("Princess Huhuran") or mb_isAtGrobbulus() then
		return false
	end	

	local i, x
	for i = 1, GetNumPartyMembers() do
		for x = 1, 16 do
			local name, count, debuffType = UnitDebuff("party"..i, x, 1)
			if debuffType == "Poison" then 
				return true 
			end
		end
	end

	for x = 1, 16 do
		local name, count, debuffType = UnitDebuff("player", x, 1)
		if debuffType == "Poison" then 
			return true 
		end
	end
end

function mb_raidIsPoisoned()
	if mb_tankTarget("Princess Huhuran") or mb_isAtGrobbulus() then
		return false
	end	

	local i, x
	for i = 1, GetNumRaidMembers() do
		for x = 1, 16 do
			local name, count, debuffType = UnitDebuff("raid"..i, x, 1)
			if debuffType == "Poison" then 
				return true 
			end
		end
	end
end

function mb_playerIsPoisoned()
	if mb_tankTarget("Princess Huhuran") or mb_isAtGrobbulus() then
		return false
	end	

	for x = 1, 16 do
		local name, count, debuffType = UnitDebuff("player", x, 1)
		if debuffType == "Poison" then 
			return true 
		end
	end
end

function mb_partyIsDiseased()	
	local i, x
	for i = 1, GetNumPartyMembers() do
		for x = 1, 16 do
			local name, count, debuffType = UnitDebuff("party"..i, x, 1)
			if debuffType == "Disease" then 
				return true 
			end
		end
	end

	for x = 1, 16 do
		local name, count, debuffType = UnitDebuff("player", x, 1)
		if debuffType == "Disease" then 
			return true 
		end
	end
end

function mb_hasItem(item)
    local count = 0

    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do 
            local texture, itemCount, locked, quality, readable, lootable, link = GetContainerItemInfo(bag, slot) 
            if texture then
                link = GetContainerItemLink(bag, slot)
                if string.find(link, item) then
                    count = count + itemCount
                end
            end
        end
    end
    
    if count == 0 then 
        mb_message("I'm out of "..item)
    end
    return count
end

local MB_hasAnAtieshEquipped = nil
function mb_reEquipAtieshIfNoAtieshBuff()
	if (myClass == "Warrior" or myClass == "Rogue" or (myClass == "Druid" and MB_raidAssist.Druid.PrioritizePriestsAtieshBuff))  then
		return
	end

	local atiesh = "Atiesh\, Greatstaff of the Guardian"
	if mb_itemNameOfEquippedSlot(16) == atiesh then 
		MB_hasAnAtieshEquipped = true
	end

	if mb_itemNameOfEquippedSlot(16) == atiesh and not mb_hasBuffOrDebuff("Atiesh", "player", "buff") and mb_isAlive("player") then
		if mb_getAllContainerFreeSlots() >= 1 then
			PickupInventoryItem(16)
			PutItemInBackpack()
			ClearCursor()
		else
			mb_message("I don\'t have bagspace to requip Atiesh, sort it!")
		end
	end

	if MB_hasAnAtieshEquipped and mb_itemNameOfEquippedSlot(16) == nil and mb_isAlive("player") then
		UseItemByName(atiesh)
	end
end

function mb_numManapots()
	local pots = 0
	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			local link = GetContainerItemLink(bag, slot)
			if link == nil then
				link = ""
			end
			if string.find(link, "Major Mana Potion") then
				pots = pots + 1
			end
		end
	end
	return pots
end

function mb_numSands()
	local sands = 0
	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			local link = GetContainerItemLink(bag, slot)
			if link == nil then
				link = ""
			end
			if string.find(link, "Hourglass Sand") then
				sands = sands + 1
			end
		end
	end
	return sands
end

local MB_anubAlertCD = GetTime()
function mb_anubisathAlert()
    if mb_iamFocus() then
		return
	end

    if UnitName("target") ~= "Anubisath Sentinel" then
		return
	end

    local timeout = 5
    local now = GetTime()

    if MB_anubAlertCD + timeout > now then
		return
	end

    MB_anubAlertCD = now

    local alerts = {
        ["Shadow Storm"]              = "/yell SHADOW STORM, BACK ME UP",
        ["Mana Burn"]                  = "/yell MANA BURN, BACK ME UP",
        ["Thunderclap"]                = "/yell THUNDERCLAP, BACK ME UP",
        ["Thorns"]                     = "/say This guy has Thorns",
        ["Mortal Strike"]              = "/say This guy has Mortal Strike",
        ["Shadow and Frost Reflect"]   = "/say This guy has Shadow and Frost Reflect",
        ["Fire and Arcane Reflect"]    = "/say This guy has Fire and Arcane Reflect",
        ["Mending"]                    = "/say This guy has Mending",
        ["Periodic Knock Away"]        = "/say This guy has Knockaway"
    }

    for buff, message in pairs(alerts) do
        if mb_hasBuffOrDebuff(buff, "target", "buff") then
            RunLine(message)
        end
    end
end

function GetColors(note)
    local classColors = {
        ["Warrior"] = "|cffC79C6E",
        ["Hunter"] = "|cffABD473",
        ["Mage"] = "|cff69CCF0",
        ["Rogue"] = "|cffFFF569",
        ["Warlock"] = "|cff9482C9",
        ["Druid"] = "|cffFF7D0A",
        ["Shaman"] = "|cff0070DE",
        ["Priest"] = "|cffFFFFFF",
        ["Paladin"] = "|cffF58CBA"
    }
    
    local function getColoredText(color, text)
        return color .. text .. "|r"
    end
    
    local function getUnitClassColor(unit)
        local unitClass = UnitClass(unit)
        if unitClass and classColors[unitClass] then
            return getColoredText(classColors[unitClass], note)
        end
        return nil
    end
    
    if note == myName then
        return getUnitClassColor("player")
    end
    
    if UnitInRaid("player") then
        for i = 1, GetNumRaidMembers() do
            local raidUnit = "raid" .. i
            local raidMemberName = UnitName(raidUnit)
            if raidMemberName == note then
                return getUnitClassColor(raidUnit)
            end
        end
    end

    if UnitInParty("player") then
        for i = 1, GetNumPartyMembers() do
            local partyUnit = "party" .. i
            local partyMemberName = UnitName(partyUnit)
            if partyMemberName == note then
                return getUnitClassColor(partyUnit)
            end
        end
    end
    
    local targetName = UnitName("target")
    if targetName == note then
        return getUnitClassColor("target")
    end
    
    local raidMarkers = {
        ["Skull"] = "|cffFFFFFF",
        ["Cross"] = "|cffFF0000",
        ["Square"] = "|cff00B4FF",
        ["Moon"] = "|cffCEECF5",
        ["Triangle"] = "|cff66FF00",
        ["Diamond"] = "|cffCC00FF",
        ["Circle"] = "|cffFF9900",
        ["Star"] = "|cffFFFF00"
    }
    
    local missingItems = {
        ["Missing Arcane Crystal"] = "|cffFFFF00",
        ["Missing Thorium Bar"] = "|cff00B4FF",
        ["Missing Thorium Bar and Arcane Crystal"] = "|cffFF0000",
        ["Missing Essence of Earth"] = "|cff66FF00",
        ["Missing Essence of Undeath"] = "|cffCC00FF",
        ["Missing Deeprock Salt"] = "|cffC79C6E",
        ["Missing Salt Shaker"] = "|cffFFFFFF",
        ["Missing Deeprock Salt and Salt Shaker"] = "|cffFF0000",
        ["Missing Felcloth"] = "|cff9482C9"
    }
    
    local cooldownMessages = {
        ["Recklessness on CD"] = "|cffC79C6E",
        ["Death Wish on CD"] = "|cffC79C6E",
        ["Recklessness and Death Wish on CD"] = "|cffC79C6E",
        ["Last Stand on CD"] = "|cffC79C6E",
        ["Shield Wall on CD"] = "|cffC79C6E",
        ["Shield Wall and Last Stand on CD"] = "|cffC79C6E",
        ["Adrenaline Rush on CD"] = "|cffFFF569",
        ["Evocation on CD"] = "|cff69CCF0",
        ["Soulstone on CD"] = "|cff9482C9",
        ["Incarnation on CD"] = "|cff0070DE",
        ["Innervate on CD"] = "|cffFF7D0A"
    }
    
    local statusMessages = {
        ["We're recking!"] = "|cff66FF00",
        ["Target out of range or behind me, targetting my nearest enemy!"] = "|cff66FF00"
    }
    
    local allMappings = {raidMarkers, missingItems, cooldownMessages, statusMessages}
    for _, mapping in ipairs(allMappings) do
        if mapping[note] then
            return getColoredText(mapping[note], note)
        end
    end
    return note
end

function mb_makeALine()
	if not UnitInRaid("player") then
		Print("MakeALine only works in raid")
		return
	end

	if mb_iamFocus() then
		headOfLine = myName
	else
		headOfLine = mb_tankName()
	end

	MB_followList = {}
	MB_groups = {}

	for g = 1, 8 do
		MB_groups[g] = {}
	end

	for i = 1, GetNumRaidMembers() do
		local name, _, group = GetRaidRosterInfo(i)
		table.insert(MB_groups[group], name)
	end

	for g = 1, 8 do
		table.sort(MB_groups[g])
	end

	for g = 1, 8 do 
		for i = 1, 5 do
			if g == 1 and i == 1 then
				table.insert(MB_followList, headOfLine)
				table.insert(MB_followList, MB_groups[g][i])
			elseif MB_groups[g][i] and MB_groups[g][i] ~= headOfLine then
				table.insert(MB_followList, MB_groups[g][i])
			end
		end 
	end

	if not IsShiftKeyDown() then
		local mySpot = FindInTable(MB_followList, myName)
		if mySpot > 1 then
			FollowByName(MB_followList[mySpot-1], 1)
		end
	else
		for g = 1, 8 do for i = 1, 5 do
			if myName == MB_groups[g][i] and i > 1 then FollowByName(MB_groups[g][1], 1) end
		end end
	end
end

function mb_reportMyCooldowns()
   if mb_inCombat("player") then 
       return 
   end

   if myClass == "Warrior" then
       if MB_mySpecc == "BT" or MB_mySpecc == "MS" then
           local recklessnessReady = mb_spellReady("Recklessness")
           local deathWishReady = mb_spellReady("Death Wish")
           
           if not recklessnessReady and deathWishReady then
               mb_message(GetColors("Recklessness on CD", 60))
               return
           end
           
           if recklessnessReady and not deathWishReady then
               mb_message(GetColors("Death Wish on CD", 60))
               return
           end
           
           if not recklessnessReady and not deathWishReady then
               mb_message(GetColors("Recklessness and Death Wish on CD", 60))
               return
           end
           
       elseif MB_mySpecc == "Prottank" or MB_mySpecc == "Furytank" then
           local shieldWallReady = mb_spellReady("Shield Wall")
           local knowsLastStand = mb_knowSpell("Last Stand")
           local lastStandReady = mb_spellReady("Last Stand")
           
           if shieldWallReady and knowsLastStand and not lastStandReady then
               mb_message(GetColors("Last Stand on CD", 60))
               return
           end
           
           if not shieldWallReady and knowsLastStand and lastStandReady then
               mb_message(GetColors("Shield Wall on CD", 60))
               return
           end
           
           if not shieldWallReady and knowsLastStand and not lastStandReady then
               mb_message(GetColors("Shield Wall and Last Stand on CD", 60))
               return
           end
       end
       
   elseif myClass == "Rogue" then
       local knowsAdrenalineRush = mb_knowSpell("Adrenaline Rush")
       local adrenalineRushReady = mb_spellReady("Adrenaline Rush")
       
       if knowsAdrenalineRush and not adrenalineRushReady then
           mb_message(GetColors("Adrenaline Rush on CD", 60))
       end
       
   elseif myClass == "Mage" then
       local evocationReady = mb_spellReady("Evocation")
       
       if not evocationReady then
           mb_message(GetColors("Evocation on CD", 60))
       end
       
   elseif myClass == "Warlock" then
       local soulstoneOnCD = mb_isItemInBagCoolDown("Major Soulstone")
       
       if soulstoneOnCD then
           mb_message(GetColors("Soulstone on CD", 60))
       end
       
   elseif myClass == "Shaman" then
       local incarnationReady = mb_spellReady("Incarnation")
       
       if not incarnationReady then
           mb_message(GetColors("Incarnation on CD", 60))
       end
       
   elseif myClass == "Druid" then
       local innervateReady = mb_spellReady("Innervate")
       
       if not innervateReady then
           mb_message(GetColors("Innervate on CD", 60))
       end
   end
end

function mb_missingSpellsReport()
   if myClass == "Rogue" then
       if not mb_knowSpell("Eviscerate", "Rank 9") then
           mb_message("I dont know Eviscerate rank 9.")
       end
       
       if not mb_knowSpell("Backstab", "Rank 9") then
           mb_message("I dont know Backstab rank 9")
       end
       
       if not mb_knowSpell("Feint", "Rank 5") then
           mb_message("I dont know Feint rank 5")
       end
       return
       
   elseif myClass == "Shaman" then
       if not mb_knowSpell("Healing Wave", "Rank 10") then
           mb_message("I dont know Healing Wave rank 10")
       end
       
       if not mb_knowSpell("Strength of Earth Totem", "Rank 5") then
           mb_message("I dont know Strength of Earth Totem rank 5")
       end
       
       if not mb_knowSpell("Grace of Air Totem", "Rank 3") then
           mb_message("I dont know Grace of Air Totem rank 3")
       end
       return
       
   elseif myClass == "Warrior" then
       if not mb_knowSpell("Heroic Strike", "Rank 9") then
           mb_message("I dont know Heroic Strike rank 9")
       end
       
       if not mb_knowSpell("Battle Shout", "Rank 7") then
           mb_message("I dont know Battle Shout rank 7")
       end
       
       if not mb_knowSpell("Revenge", "Rank 6") then
           mb_message("I dont know Revenge rank 6")
       end
       return
       
   elseif myClass == "Druid" then
       if not mb_knowSpell("Healing Touch", "Rank 11") then
           mb_message("I dont know Healing Touch rank 11")
       end
       
       if not mb_knowSpell("Starfire", "Rank 7") then
           mb_message("I dont know Starfire rank 7")
       end
       
       if not mb_knowSpell("Rejuvenation", "Rank 11") then
           mb_message("I dont know Rejuvenation rank 11")
       end
       
       if not mb_knowSpell("Gift of the Wild", "Rank 2") then
           mb_message("I dont know Gift of the Wild rank 2")
       end
       return
       
   elseif myClass == "Paladin" then
       if not mb_knowSpell("Blessing of Wisdom", "Rank 6") then
           mb_message("I dont know Blessing of Wisdom rank 6")
       end
       
       if not mb_knowSpell("Blessing of Might", "Rank 7") then
           mb_message("I dont know Blessing of Might rank 7")
       end
       
       if not mb_knowSpell("Holy Light", "Rank 9") then
           mb_message("I dont know Holy Light rank 9")
       end
       return
       
   elseif myClass == "Mage" then
       if not mb_knowSpell("Frostbolt", "Rank 11") then
           mb_message("I dont know Frostbolt rank 11")
       end
       
       if not mb_knowSpell("Fireball", "Rank 12") then
           mb_message("I dont know Fireball rank 12")
       end
       
       if not mb_knowSpell("Arcane Missiles", "Rank 8") then
           mb_message("I dont know Arcane Missiles rank 8")
       end
       
       if not mb_knowSpell("Arcane Brilliance", "Rank 1") then
           mb_message("I dont know Arcane Brilliance rank 1")
       end
       return
       
   elseif myClass == "Warlock" then
       if not mb_knowSpell("Shadow Bolt", "Rank 10") then
           mb_message("I dont know Shadow Bolt rank 10")
       end
       
       if not mb_knowSpell("Immolate", "Rank 8") then
           mb_message("I dont know Immolate rank 8")
       end
       
       if not mb_knowSpell("Corruption", "Rank 7") then
           mb_message("I dont know Corruption rank 7")
       end
       
       if not mb_knowSpell("Shadow Ward", "Rank 4") then
           mb_message("I dont know Shadow Ward rank 4")
       end
       return
       
   elseif myClass == "Priest" then
       if not mb_knowSpell("Greater Heal", "Rank 5") then
           mb_message("I dont know Greater Heal rank 5")
       end
       
       if not mb_knowSpell("Renew", "Rank 10") then
           mb_message("I dont know Renew rank 10")
       end
       
       if not mb_knowSpell("Prayer of Healing", "Rank 5") then
           mb_message("I dont know Prayer of Healing rank 5")
       end
       
       if not mb_knowSpell("Prayer of Fortitude", "Rank 2") then
           mb_message("I dont know Prayer of Fortitude rank 2")
       end
       return
       
   elseif myClass == "Hunter" then
       if not mb_knowSpell("Multi-Shot", "Rank 5") then
           mb_message("I dont know Multi-Shot rank 5")
       end
       
       if not mb_knowSpell("Serpent Sting", "Rank 9") then
           mb_message("I dont know Serpent Sting rank 9")
       end
       
       if not mb_knowSpell("Aspect of the Hawk", "Rank 7") then
           mb_message("I dont know Aspect of the Hawk rank 7")
       end
       return
   end
end

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