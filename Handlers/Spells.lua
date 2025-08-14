--[####################################################################################################]--
--[######################################### Spells Functions #########################################]--
--[####################################################################################################]--

function mb_spellReady(spellName, rank)
    if not mb_knowSpell(spellName, rank) then
        return false
    end

    return mb_spellCoolDown(spellName) == 0
end

function mb_knowSpell(spellName, rank)
	local ispellIndex = mb_spellIndex(spellName, rank)
	return ispellIndex ~= nil
end

function mb_spellIndex(spellName, rank)
	for tabIndex = 1, MAX_SKILLLINE_TABS do
		local tabName, tabTexture, tabSpellOffset, tabNumSpells = GetSpellTabInfo(tabIndex)
		if not tabName then
			break
		end
		for ispellIndex = tabSpellOffset + 1, tabSpellOffset + tabNumSpells do
			local ispellName, ispellRank = GetSpellName(ispellIndex, BOOKTYPE_SPELL)
			if ispellName == spellName then
				if not rank or (rank and rank == ispellRank) then
					return ispellIndex, BOOKTYPE_SPELL
				end
			end
		end
	end
	return nil, BOOKTYPE_SPELL
end

function mb_spellCoolDown(spellName)
	if not mb_spellExists(spellName) then return true end
	local start, duration, enabled = GetSpellCooldown(mb_spellIndex(spellName))
	if enabled == 0 then
		return 1
	else
		local remaining = start + duration - GetTime()
		if remaining < 0 then remaining = 0 end
		return remaining
	end
end

function mb_spellExists(findSpell)
	if not findSpell then return end
		for i = 1, MAX_SKILLLINE_TABS do
			local name, texture, offset, numSpells = GetSpellTabInfo(i)
			if not name then break end
			for s = offset + 1, offset + numSpells do
			local	spell, rank = GetSpellName(s, BOOKTYPE_SPELL)
			if rank then
				local spell = spell.." "..rank
			end
			if string.find(spell, findSpell, nil, true) then
				return true
			end
		end
	end
end

function mb_spellNumber(spell)
	local i = 1
    local spellNumber = 0
	local spellName

	while true do
		spellName, spellRank = GetSpellName(i, BOOKTYPE_SPELL)

		if not spellName then
			do break end
		end

		if string.find(spellName, spell) then
            spellNumber = i
        end

		i = i + 1
	end

	if spellNumber == 0 then
        return
    end

	return spellNumber
end

function mb_coolDownCast(spell, cooldown)
	local time = GetTime()

	if not MB_cooldowns[spell] then
		CastSpellByName(spell)
		MB_cooldowns[spell] = time
		return
	end

	if MB_cooldowns[spell] + cooldown > time then
		return
	end

	if MB_cooldowns[spell] + cooldown <= time then
		CastSpellByName(spell)
		MB_cooldowns[spell] = nil
	end
end

function mb_castSpellOrWand(spell)		
	if mb_knowSpell(spell) and UnitMana("player") > MB_classSpellManaCost[spell] then
		CastSpellByName(spell) 
		return 
	else
        if MB_attackWandSlot then
		    mb_autoWandAttack()
        else
            mb_autoAttack()
        end
	end
end

function mb_imBusy()
	if MB_isCasting or MB_isChanneling then return true end
end

--[####################################################################################################]--
--[######################################## Trinket Functions #########################################]--
--[####################################################################################################]--

MB_healerTrinkets = {
	"Eye of the Dead", 
	"Zandalarian Hero Charm", 
	"Talisman of Ephemeral Power", 
	"Hibernation Crystal", 
	"Scarab Brooch", 
	"Warmth of Forgiveness", 
	"Natural Alignment Crystal", 
	"Mar\'li\'s Eye", 
	"Hazza\'rah\'s Charm of Healing", 
	"Wushoolay\'s Charm of Nature", 
	"Draconic Infused Emblem", 
	"Talisman of Ascendance", 
	"Second Wind", 
	"Burst of Knowledge"
}

MB_casterTrinkets = {
	"Zandalarian Hero Charm", 
	"Talisman of Ephemeral Power", 
	"Burst of Knowledge", 
	"Fetish of the Sand Reaver", 
	"Eye of Diminution", 
	"The Restrained Essence of Sapphiron", 
	"Mind Quickening Gem", 
	"Eye of Moam", 
	"Mar\'li\'s Eye", 
	"Draconic Infused Emblem", 
	"Talisman of Ascendance", 
	"Second Wind"
}

MB_meleeTrinkets = {
	"Earthstrike", 
	"Kiss of the Spider", 
	"Badge of the Swarmguard", 
	"Diamond Flask", 
	"Slayer\'s Crest", 
	"Jom Gabbar", 
	"Glyph of Deflection", 
	"Zandalarian Hero Badge", 
	"Zandalarian Hero Medallion", 
	"Gri\'lek\'s Charm of Might", 
	"Renataki\'s Charm of Trickery", 
	"Devilsaur Eye"
}

function mb_trinketOnCD(id)
	local start, duration, enable = GetInventoryItemCooldown("player", id)
	if enable == 1 and duration == 0 then
		return false
	elseif enable == 1 and duration >= 1 then
		return true
	end
	return nil
end

function mb_itemNameOfEquippedSlot(id)
	local link = GetInventoryItemLink("player", id)
	if link == nil then 
		return nil 
	end
	local _, _, itemName = string.find(link, "%[(.*)%]", 27)
	return itemName
end

function mb_returnEquippedItemType(id)
	local itemLink = GetInventoryItemLink("player", id)
	if not itemLink then
		return "Bow"
	end

	local bsNum = string.gsub(itemLink, ".-\124H([^\124]*)\124h.*", "%1")
	local itemName, itemNo, itemRarity, itemReqLevel, itemType, itemSubType, itemCount, itemEquipLoc, itemIcon = GetItemInfo(bsNum)
	_, _, itemSubType = string.find(itemSubType, "(.*)s")
	return itemSubType
end

function mb_healerTrinkets()
	for k, trinket in pairs(MB_healerTrinkets) do
		if mb_inCombat("player") and mb_itemNameOfEquippedSlot(13) == trinket and not mb_trinketOnCD(13) then 
			use(13) 
		end

		if mb_inCombat("player") and mb_itemNameOfEquippedSlot(14) == trinket and not mb_trinketOnCD(14) then 
			use(14) 
		end
	end
end

function mb_casterTrinkets()
	for k, trinket in pairs(MB_casterTrinkets) do
		if mb_inCombat("player") and mb_itemNameOfEquippedSlot(13) == trinket and not mb_trinketOnCD(13) then 
			use(13) 
		end

		if mb_inCombat("player") and mb_itemNameOfEquippedSlot(14) == trinket and not mb_trinketOnCD(14) then 
			use(14) 
		end
	end
end

function mb_meleeTrinkets()
	for k, trinket in pairs(MB_meleeTrinkets) do
		if mb_inCombat("player") and mb_itemNameOfEquippedSlot(13) == trinket and not mb_trinketOnCD(13) then 
			use(13)			
		end

		if mb_inCombat("player") and mb_itemNameOfEquippedSlot(14) == trinket and not mb_trinketOnCD(14) then 
			use(14)
		end
	end
end