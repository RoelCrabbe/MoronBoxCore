------------------------------------------------------------------------------------------------------
------------------------------------------------ FRAME! ----------------------------------------------
------------------------------------------------------------------------------------------------------

MMB = CreateFrame("Button", "MMB", UIParent)
MMBTooltip = CreateFrame("GAMETOOLTIP", "MMBTooltip", UIParent, "GameTooltipTemplate")

MBx = CreateFrame("Frame")
	MBx.ACE = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0")
	Print(MBx.ACE)
	MBx.ACE.ItemBonus = AceLibrary("ItemBonusLib-1.0")
	Print(MBx.ACE.ItemBonus)
	MBx.ACE.Banzai = AceLibrary("Banzai-1.0")
	Print(MBx.ACE.Banzai)
	MBx.ACE.HealComm = AceLibrary("HealComm-1.0")
	Print(MBx.ACE.HealComm)

------------------------------------------------------------------------------------------------------
----------------------------------------------- Locals! ----------------------------------------------
------------------------------------------------------------------------------------------------------

	-- Init globals / locals --

	MBID = {}
	MB_classList = { Warrior = {}, Mage = {}, Shaman = {}, Paladin = {}, Priest = {}, Rogue = {}, Druid = {}, Hunter = {}, Warlock = {} }
	MB_toonsInGroup = {}
	MB_offTanks = {}
	MB_raidTanks = {}
	MB_noneDruidTanks = {}
	MB_fireMages = {}
	MB_frostMages = {}
	MB_groupID = {}
	for i = 1, 8 do MB_toonsInGroup[i] = {} end

	local MB_druidTankInParty = nil
	local MB_warriorTankInParty = nil

	-- Assign globals / locals --

	MB_myCCTarget = nil
	MB_myInterruptTarget = nil
	MB_myOTTarget = nil
	
	MB_doInterrupt = { Active = false, Time = 0 }

	local MB_myAssignedHealTarget = nil

	MB_currentCC = { Mage = 1, Warlock = 1, Priest = 1, Druid = 1 }
	MB_currentInterrupt  = { Rogue = 1, Mage = 1, Shaman = 1 }
	MB_currentFear = { Warlock = 1 }

	MB_currentRaidTarget = 1
	MB_Ot_Index = 1

	MB_myCCSpell = {
		Priest = "Shackle Undead", 
		Mage = "Polymorph", 
		Warlock = "Banish", 
		Druid = "Hibernate" -- "Entangling Roots"
	}

	MB_myInterruptSpell = {
		Rogue = "Kick", 
		Shaman = "Earth Shock", 
		Mage = "Counterspell", 
		Warrior = "Pummel", 
		Priest = "Silence",
		Paladin = "Hammer of Justice"
	}

	MB_myFearSpell = {
		Warlock = "Fear"
		--Warlock = "Howl of Terror" ??? MAYBE FOR SKERAM
	}

	-- Used for wanding
	MB_classSpellManaCost = {
		-- Fire Magus
		["Fireball"] = 410,
		["Pyroblast"] = 440,
		["Scorch"] = 150,
		["Blast Wave"] = 545,

		-- Frost Magus
		["Frostbolt"] = 290,
		["Frostbolt(Rank 1)"] = 25,
		["Cone of Cold"] = 555,

		-- Arcane Magus
		["Arcane Explosion"] = 390,
		["Arcane Explosion(Rank 1)"] = 75,
		["Arcane Missiles"] = 655,

		-- Warlock
		["Searing Pain"] = 168,
		["Shadow Bolt"] = 380,
		["Soul Fire"] = 335,
		["Immolate"] = 380,
		["Corruption"] = 340,
		["Drain Mana"] = 225,

		-- Priest
		["Smite"] = 280,
		["Mind Flay"] = 205,
		["Mind Blast"] = 250,
		["Mana Burn"] = 270,

		-- Druid
		["Starfire"] = 309,
		["Wrath"] = 163,

		-- Shaman
		["Chain Lightning"] = 544,
		["Lightning Bolt"] = 238
	}

	-- Raid Targets
	MB_raidTargetNames = {
		[8] = "Skull", 
		[7] = "Cross", 
		[6] = "Square", 
		[5] = "Moon", 
		[4] = "Triangle", 
		[3] = "Diamond", 
		[2] = "Circle", 
		[1] = "Star"
	}

	-- Casting globals / locals --

	local MB_soulstone_ressurecters = true -- >  U can change this to false if u dont want SS on AltKeyDown buff

	-- Edit MB_savedBinding to you're liking, binding Binding2 should be single, Binding3 should be Multi
	MB_savedBinding = { Active = false, Time = 0, Binding2 = "SM_MACRO2", Binding3 = "SM_MACRO3" }

	MB_isCasting = nil
	MB_isChanneling = nil
	
	MB_isCastingMyCCSpell = nil
	
	MB_isMoving = { Active = false, Time = 0 }

	-- Ignite

	MB_ignite = { Active = nil, Starter = nil, Amount = 0, Stacks = 0 }

	MB_buffingCounterWarlock = 1
	MB_buffingCounterDruid = 1
	MB_buffingCounterMage = 1
	MB_buffingCounterPriest = 1
	MB_buffingCounterPaladin = 1
	MB_powerInfusionCounter = 1

	-- NPC and Trade globals / locals --

	MB_DMFWeek = { Active = false, Time = 0 }
	MB_MCEnter = { Active = false, Time = 0 }

	MB_tradeOpen = nil
	MB_tradeOpenOnUpdate = { Active = false, Time = 0 }

	-- BossEvents --

	local MB_targetNearestDistanceChanged = nil
	MB_razorgoreNewTargetBecauseTargetIsBehindOrOutOfRange = { Active = false, Time = 0 }
	MB_razorgoreNewTargetBecauseTargetIsBehind = { Active = false, Time = 0 }
	MB_lieutenantAndorovIsNotHealable = { Active = false, Time = 0 }
	MB_targetWrongWayOrTooFar = { Active = false, Time = 0 }
	MB_autoToggleSheeps = { Active = false, Time = 0 }
	MB_autoBuff = { Active = false, Time = 0 }
	MB_useCooldowns = { Active = false, Time = 0 }
	MB_useBigCooldowns = { Active = false, Time = 0 }

	-- Taxi --

	local original_TakeTaxiNode = TakeTaxiNode;
	local MB_taxi = {
		Time = 0, 
		Node = ""
	}

	-- Extra's --

	MB_raidLeader = nil
	MB_mySpecc = nil
	MB_hasTacMastery = nil
	MB_hasImprovedEA = nil
	MB_myHealSpell = nil
	MB_attackSlot = nil
	MB_attackRangedSlot = nil
	MB_attackWandSlot = nil

	MB_warriorBinds = "Fury"
	MB_evoGear = nil

	MB_hunterFeign = { Active = false, Time = 0 }

	MB_autoBuyReagents = { Active = false, Time = 0 }
	MB_autoBuySunfruit = { Active = false, Time = 0 }
	MB_autoTurnInQiraji = { Active = false, Time = 0 }
	
	-- Setup stuff --

	local myClass = UnitClass("player")
	local myName = UnitName("player")
	local myRace = UnitRace("player")

	MB_anubAlertCD = GetTime()

	MB_cooldowns = {}

	MB_myWater = {
		[60] = "Conjured Crystal Water",
		[50] = "Conjured Sparkling Water"
	}
	
	MB_playerMounts = {
		-- "Black Qiraji Resonating Crystal",
		"Reins of the Winterspring Frostsaber",
		"Deathcharger\'s Reins", 
		"Black War Tiger", 
		"Swift Zulian Tiger", 
		"Swift Razzashi Raptor", 
		"Swift Blue Raptor", 
		"Black War Kodo", 
		"Horn of the ", 
		"Reins of the Swift ", 
		"Swift White Steed", 
		"Swift Brown Steed",
		"Black Battlestrider",
		"Warhorse", 
		" Mare", 
		"Horse", 
		"Timber Wolf", 
		"Kodo", 
		"Raptor", 
		" Ram", 
		" Mechanostrider", 
		" Bridle", 
		"Charger", 
		" Frostsaber", 
		" Nightsaber", 
		"Swift Palomino"
	}

function mb_makeALine() -- Make a line, works best if u don't have any *life* players in your group

	if not UnitInRaid("player") then Print("MakeALine only works in raid") return end
	local name, realm =  UnitName("player")

	if mb_iamFocus() then
		headofline = name
	else
		headofline = mb_tankName()
	end

	MB_followlist = {}
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
				table.insert(MB_followlist, headofline)
				table.insert(MB_followlist, MB_groups[g][i])
			elseif MB_groups[g][i] and MB_groups[g][i] ~= headofline then
				table.insert(MB_followlist, MB_groups[g][i])
			end
		end 
	end

	if not IsShiftKeyDown() then
		local myspot = FindInTable(MB_followlist, name)
		if myspot > 1 then
			FollowByName(MB_followlist[myspot-1], 1)
		end
	else
		for g = 1, 8 do for i = 1, 5 do
			if name == MB_groups[g][i] and i > 1 then FollowByName(MB_groups[g][1], 1) end
		end end
	end
end

function mb_reportMyCooldowns() -- Reporting cooldowns

	if mb_inCombat("player") then return end

	-- Melee
	if myClass == "Warrior" then
		if (MB_mySpecc == "BT" or MB_mySpecc == "MS") then 

			if not mb_spellReady("Recklessness") and mb_spellReady("Death Wish") then

				mb_message(GetColors("Recklessness on CD", 60))
			elseif mb_spellReady("Recklessness") and not mb_spellReady("Death Wish") then

				mb_message(GetColors("Death Wish on CD", 60))
			elseif not mb_spellReady("Recklessness") and not mb_spellReady("Death Wish") then

				mb_message(GetColors("Recklessness and Death Wish on CD", 60))
			end

		elseif (MB_mySpecc == "Prottank" or MB_mySpecc == "Furytank") then

			if mb_spellReady("Shield Wall") and (mb_knowSpell("Last Stand") and not mb_spellReady("Last Stand"))then

				mb_message(GetColors("Last Stand on CD", 60))
			elseif not mb_spellReady("Shield Wall") and (mb_knowSpell("Last Stand") and mb_spellReady("Last Stand"))then

				mb_message(GetColors("Shield Wall on CD", 60))
			elseif not mb_spellReady("Shield Wall") and (mb_knowSpell("Last Stand") and not mb_spellReady("Last Stand"))then

				mb_message(GetColors("Shield Wall and Last Stand on CD", 60))
			end
		end

	elseif myClass == "Rogue" then

		if mb_knowSpell("Adrenaline Rush") and not mb_spellReady("Adrenaline Rush") then

			mb_message(GetColors("Adrenaline Rush on CD", 60))
		end

	--Casters
	elseif myClass == "Mage" then

		if not mb_spellReady("Evocation") then

			mb_message(GetColors("Evocation on CD", 60))
		end

	elseif myClass == "Warlock" then

		if mb_isItemInBagCoolDown("Major Soulstone") then

			mb_message(GetColors("Soulstone on CD", 60))
		end

	--Healers
	elseif myClass == "Shaman" then

		if mb_spellReady("Incarnation") then

			mb_message(GetColors("Incarnation on CD", 60))
		end

	elseif myClass == "Druid" then

		if not mb_spellReady("Innervate") then

			mb_message(GetColors("Innervate on CD", 60))
		end
	end
end

function mb_missingSpellsReport() -- Missing spell report

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
			mb_message("I dont know Grace of Air Totem rank rank 3")
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

------------------------------------------------------------------------------------------------------
---------------------------------------- Potions / Runes Code! ---------------------------------------
------------------------------------------------------------------------------------------------------

function mb_changeSpecc(specc)
	if not (myClass == "Warrior" or myClass == "Druid") then Print("Usage /specc only works for druids and warriors") return end
	if specc == "" then Print("Usage /specc < classname >   < dps or tank >") return end

	local _, _, firstWord, restOfString = string.find(specc, "(%w+)[%s%p]*(.*)");
	local inputClass = string.lower(firstWord)
	local myClass = string.lower(UnitClass("player"))
	local inputSpecc = string.lower(restOfString)

	Print("Your current specc is: "..MB_mySpecc)

	if inputClass == myClass then

		if myClass == "warrior" then
			if inputSpecc == "tank" then
				
				mb_tankGear()
				return
			end

			if inputSpecc == "dps" then
				
				mb_furyGear()
				return
			end
		end

		if myClass == "druid" then
			if inputSpecc == "tank" then
				
				MB_mySpecc = "Feral"
				return
			end
		end

		if myClass == "druid" then
			if inputSpecc == "dps" then
				
				MB_mySpecc = "Kitty"
				return
			end
		end

	else

		Print("You had the wrong class given.") 
		Print("Usage /specc < classname >   < dps or tank >") 
	end
end

------------------------------------------------------------------------------------------------------
------------------------------------------ Slash Commands! -------------------------------------------
------------------------------------------------------------------------------------------------------

SLASH_INIT1 = "/init"
SLASH_DEEPINIT1 = "/deepinit"

SLASH_FIND1 = "/Find"
SLASH_FIND2 = "/find"

SLASH_HOTS1 = "/Hots"
SLASH_HOTS2 = "/hots"

SLASH_GEAR1 = "/Gear"
SLASH_GEAR2 = "/gear"

SLASH_REPORTMANAPOTS1 = "/reportmanapots"
SLASH_REPORTSHARDS1 = "/reportshards"
SLASH_REPORTRUNES1 = "/reportrunes"

SLASH_ASSIGNHEALER1 = "/healer"
SLASH_ASSIGNHEALER2 = "/Healer"

SLASH_USEBAGITEM1 = "/usebagitem"

SLASH_REMOVEBUFFS1 = "/removebuffs"
SLASH_REMOVEBUFFS2 = "/Removebuffs"

SLASH_REMOVEBLESS1 = "/removebles"
SLASH_REMOVEBLESS2 = "/Removebles"

SLASH_NEFCLOAK1 = "/nefcloak"
SLASH_NEFCLOAK2 = "/Nefcloak"

SLASH_REPORTREP1 = "/reportrep"
SLASH_AQBOOKS1 = "/reportspells"
SLASH_SOULSTONE1 = "/CreateSoulStones"

SLASH_DISBAND1 = "/disband"
SLASH_DISBAND2 = "/db"

SLASH_LOGOUT1 = "/lo"

SLASH_CHANGESPECC1 = "/specc"
SLASH_CHANGESPECC2 = "/Specc"

SLASH_TANKLIST1 = "/Tanklist"
SLASH_TANKLIST2 = "/tanklist"

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

SlashCmdList["FIND"] = function(item)
	if UnitInRaid("player") then
		SendAddonMessage(MB_RAID.."MB_FIND", item, "RAID")
	else
		SendAddonMessage(MB_RAID.."MB_FIND", item)
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

SlashCmdList["DEEPINIT"] = function()
	mb_createSpecialMacro()
end


SlashCmdList["SOULSTONE"] = function()
	mb_createSoulStone()
end

SlashCmdList["DISBAND"] = function()
	mb_disbandRaid()
end

SlashCmdList["HOTS"] = function(value)
	if UnitInRaid("player") then
		SendAddonMessage(MB_RAID.."MB_HOTS", value, "RAID")
	else
		SendAddonMessage(MB_RAID.."MB_HOTS", value)
	end
end

SlashCmdList["USEBAGITEM"] = function(item)
	if UnitInRaid("player") then
		SendAddonMessage(MB_RAID.."MB_USEBAGITEM", item, "RAID")
	else
		SendAddonMessage(MB_RAID.."MB_USEBAGITEM", item)
	end
end

SlashCmdList["GEAR"] = function(itemset)
	if UnitInRaid("player") then
		SendAddonMessage(MB_RAID.."MB_GEAR", itemset, "RAID")
	else
		SendAddonMessage(MB_RAID.."MB_GEAR", itemset)
	end
end
	
SlashCmdList["ASSIGNHEALER"] = function(names)
	if UnitInRaid("player") then
		SendAddonMessage(MB_RAID.."MB_ASSIGNHEALER", names, "RAID")
	else
		SendAddonMessage(MB_RAID.."MB_ASSIGNHEALER", names)
	end
end

function mb_assignHealerToName(assignments) -- Assign a healer to a target
	local _, _, healername, assignedtarget = string.find(assignments, "(%a+)%s*(%a+)")

	if mb_iamFocus() then
		if (assignedtarget == "Reset" or assignedtarget == "reset") then

			mb_message("Unassigned "..healername.." from healing a specific player.")
			return
		end
		
		mb_message("Assigned "..healername.." to heal "..assignedtarget..".")		
	end

	if myName == healername then
		if (assignedtarget == "Reset" or assignedtarget == "reset") then

			Print("Unassigned myself to focusheal "..MB_myAssignedHealTarget..".")
			MB_myAssignedHealTarget = nil
			return
		end

		MB_myAssignedHealTarget = assignedtarget
		Print("Assigning myself to focusheal "..MB_myAssignedHealTarget..".")
	end
end

function GetHealBonus()
	local value = MBx.ACE.ItemBonus:GetBonus("HEAL")
	return value	
end

function ExtractRank(str)
	local num = ""
	local foundDigit = false
	for i = 1, string.len(str) do
		local char = string.sub(str, i, i)
		if tonumber(char) then
			num = num .. char
			foundDigit = true
		elseif foundDigit then
			break
		end
	end
	return tonumber(num)
end

function GetHealValueFromRank(spell, rank)
	return math.floor(MBx.ACE.HealComm.Spells[spell][ExtractRank(rank)](GetHealBonus()))
end

function GetAverageChainHealValueFromRank(spell, rank, amountOfBounce, multiplier)
    local multiplier = multiplier and (1 + multiplier / 100) or 1
    local baseHeal = MBx.ACE.HealComm.Spells[spell][ExtractRank(rank)](GetHealBonus())
    local lowestHeal = baseHeal / (2 ^ amountOfBounce)
    return math.floor(lowestHeal * multiplier)
end

function mb_loathebHealing()
	HealerCounter = HealerCounter or 1

	if MBID[MB_myLoathebHealer[HealerCounter]] and mb_hasBuffOrDebuff("Corrupted Mind", MBID[MB_myLoathebHealer[HealerCounter]], "debuff") then

		if HealerCounter == TableLength(MB_myLoathebHealer) then
			
			HealerCounter = 1
		else

			HealerCounter = HealerCounter + 1
		end
	end

	mb_message("Current healer: "..MB_myLoathebHealer[HealerCounter])
	
	if myName == MB_myLoathebHealer[HealerCounter] and MBID[MB_myLoathebMainTank] then

		Print("My heal will start when "..MB_myLoathebMainTank.." is below "..(GetHealValueFromRank(MB_myLoathebHealSpell[myClass], MB_myLoathebHealSpellRank[myClass]) * MB_myMainTankOverhealingPercentage).." HP")
		Print("Without overhealing my heal would heal for "..GetHealValueFromRank(MB_myLoathebHealSpell[myClass], MB_myLoathebHealSpellRank[myClass]))
		
		if (mb_healthDown(MBID[MB_myLoathebMainTank]) >= (GetHealValueFromRank(MB_myLoathebHealSpell[myClass], MB_myLoathebHealSpellRank[myClass]) * MB_myMainTankOverhealingPercentage)) then
			
			TargetByName(MB_myLoathebMainTank)
			CastSpellByName(MB_myLoathebHealSpell[myClass])
		end
		return true
	end
	return false
end