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