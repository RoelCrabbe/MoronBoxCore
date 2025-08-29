--[####################################################################################################]--
--[######################################### Spells Functions #########################################]--
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
	if mb_knowSpell(spell) then
		if UnitMana("player") > MB_classSpellManaCost[spell] then
			CastSpellByName(spell) 
			return 
		end
	end

	if MB_attackWandSlot then
		mb_autoWandAttack()
		return
	end
	
	mb_autoAttack()
end

function mb_imBusy()
	if MB_isCasting or MB_isChanneling then return true end
end

function mb_petSpellCooldown(spellName)
	local index = mb_getPetSpellOnBar(spellName)
	local timeLeft, _, _ = GetPetActionCooldown(index)
	return timeLeft
end

function mb_petSpellReady(spellName)
	return mb_petSpellCooldown(spellName) == 0
end

function mb_getPetSpellOnBar(spellName)
	for i = 1, 10 do
		local name, _, _, _, _, _, _ = GetPetActionInfo(i)
		if name == spellName then
			return i
		end
	end
end

function mb_castPetAction(spellName)
	if not UnitExists("pet") then
		return
	end

	local index = mb_getPetSpellOnBar(spellName)	
	CastPetAction(index)
end

function mb_getMCActions()
	if mb_hasBuffNamed("Mind Control", "player") then
		return
	end

	if not UnitExists("pet") then
		return
	end

	if UnitName("target") == "Deathknight Understudy"
		or UnitName("target") == "Naxxramas Worshipper" then		
		CastSpellByName("Mind Control")
	end
end

function mb_doRazuviousActions()
	if not UnitExists("pet") then
		return
	end

	for i = 1, 4 do
		TargetByName("Instructor Razuvious")
		PetAttack()

		if mb_petSpellReady("Shield Wall") then
			mb_castPetAction("Shield Wall")
			mb_cdMessage("Shield Wall!")
		end			
	end
end

function mb_doFaerlinaActions()
	if not UnitExists("pet") then
		return
	end

	for i = 1, 4 do
		TargetByName("Grand Widow Faerlina")
		PetAttack("Grand Widow Faerlina")			
	end
end

function mb_orbControlling()
	if not UnitExists("pet") then
		return
	end

	for i = 1, 8 do		
		mb_castPetAction("Destroy Egg")
		CastPetAction(5)		
	end
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