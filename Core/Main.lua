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

------------------------------------------------------------------------------------------------------
--------------------------------------- Raid Assistance Tools! ---------------------------------------
------------------------------------------------------------------------------------------------------

local MB_hasAnAtieshEquipped = nil

function mb_reEquipAtieshIfNoAtieshBuff()

	if (myClass == "Warrior" or myClass == "Rogue" or (myClass == "Druid" and MB_raidAssist.Druid.PrioritizePriestsAtieshBuff))  then
		return
	end

	local atiesh = "Atiesh\, Greatstaff of the Guardian";

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

function mb_taxi()
	local time = GetTime()

	if MB_raidAssist.FollowTheLeaderTaxi and MB_taxi.Time > time and not mb_iamFocus() then
		for i = 1, NumTaxiNodes() do
			if(TaxiNodeName(i) == MB_taxi.Node) then
				original_TakeTaxiNode(i)
				break
			end
		end
	end	
end

function mb_takeTaxiNode(index)
	if UnitInRaid("player") then
		SendAddonMessage(MB_RAID.."_flyTaxi", TaxiNodeName(index), "RAID")
		original_TakeTaxiNode(index)
	elseif UnitInParty("player") then
		SendAddonMessage(MB_RAID.."_flyTaxi", TaxiNodeName(index), "PARTY")
		original_TakeTaxiNode(index)		
	end
end

function mb_disbandRaid() -- Disbanding 

	if UnitInRaid("player") then

		for i = 1, 40 do
			local name, rank, subgroup, level, class, fileName, zone, online, isDead = GetRaidRosterInfo(i);
			if (rank ~= 2) then
				UninviteFromParty("raid"..i)
			end
		end	
	else

		for i = 1, GetNumPartyMembers() do
			UninviteFromParty("party"..i)
		end
	end

	LeaveParty()
end	

function mb_mountUp() -- Mount up

	if myClass == "Druid" and mb_isDruidShapeShifted() and not mb_inCombat("player") then 
		mb_cancelDruidShapeShift() 
	end

	if mb_imBusy() then return end

	if GetRealZoneText() == "Ahn\'Qiraj" then
		
		use(mb_getLink("Resonating"))
		return
	end
		
	for _, mount in MB_playerMounts do
		use(mb_getLink(mount))
	end

	if myClass == "Warlock" and mb_knowSpell("Summon Dreadsteed") then 
		
		CastSpellByName("Summon Dreadsteed")
		return
	end

	if myClass == "Paladin" and mb_knowSpell("Summon Charger") then 
		
		CastSpellByName("Summon Charger")
		return
	end	

	CastSpellByName("Summon Felsteed")
	CastSpellByName("Summon Warhorse")	
end

function mb_cleanseTotem() -- Cleansing totems

	if myClass == "Shaman" then
		if mb_partyIsPoisoned() then 
			
			if mb_imBusy() then
				
				SpellStopCasting()
				return
			end

			CastSpellByName("Poison Cleansing Totem")
		elseif mb_partyIsDiseased() then
			
			if mb_imBusy() then
				
				SpellStopCasting()
				return
			end

			CastSpellByName("Disease Cleansing Totem")
		end
	end
end

function mb_fearBreak() -- Fearbreaking
	
	if IsShiftKeyDown() then 
		
		mb_cleanseTotem()
		return 
	end

	if myClass == "Warrior" then
		if mb_spellReady("Berserker Rage") then
		
			mb_selfBuff("Berserker Stance")
			CastSpellByName("Berserker Rage")
		end
	end

	if myClass == "Shaman" then
		
		if mb_imBusy() then
				
			SpellStopCasting()
			return
		end

		mb_coolDownCast("Tremor Totem", 15)
	end

	if mb_knowSpell("Will of the Forsaken") then -- Undeads only

		if myClass == "Warrior" then 
			if mb_spellReady("Will of the Forsaken") and not (mb_hasBuffOrDebuff("Berserker Rage", "player", "buff") and mb_spellReady("Berserker Rage")) then 
				
				CastSpellByName("Will of the Forsaken") 
				return 
			end
		else
			if mb_spellReady("Will of the Forsaken") then 
				
				CastSpellByName("Will of the Forsaken") 
				return 
			end
		end
	end
end

function mb_interruptSpell() -- Manual interupt focustarget
	
	if mb_imTank() then return end

	if mb_spellReady(MB_myInterruptSpell[myClass]) then

		mb_getMyInterruptTarget()

		if myClass == "Warrior" then
		
			if UnitMana("player") >= 10 then
					
				CastSpellByName(MB_myInterruptSpell[myClass])
			end

		elseif myClass == "Shaman" then

			if mb_imBusy() then
				
				SpellStopCasting()
			end

			CastSpellByName(MB_myInterruptSpell[myClass].."(rank 1)")

		elseif myClass == "Rogue" then

			if UnitMana("player") >= 25 then
				
				CastSpellByName(MB_myInterruptSpell[myClass])
			end

		elseif myClass == "Mage" then

			if mb_imBusy() then
				
				SpellStopCasting()
			end

			CastSpellByName(MB_myInterruptSpell[myClass])
		end
	end
end

function mb_interruptingHealAndTank() -- Auto interupt focustarget
	
	if mb_imTank() then return end

	if MB_doInterrupt.Active and mb_spellReady(MB_myInterruptSpell[myClass]) then

		mb_getMyInterruptTarget()

		if myClass == "Warrior" then
		
			if UnitMana("player") >= 10 then
					
				CastSpellByName(MB_myInterruptSpell[myClass])
			end

		elseif myClass == "Shaman" then

			if mb_imBusy() then
				
				SpellStopCasting()
			end

			CastSpellByName(MB_myInterruptSpell[myClass].."(rank 1)")

		elseif myClass == "Rogue" then

			if UnitMana("player") >= 25 then
				
				CastSpellByName(MB_myInterruptSpell[myClass])
			end

		elseif myClass == "Mage" then

			if not MB_isCastingMyCCSpell then
				
				SpellStopCasting()
			end

			CastSpellByName(MB_myInterruptSpell[myClass])
		end

		MB_doInterrupt.Active = false
	end
end

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

function TableInvert(tbl)
	local rv = {}

	for key, val in pairs( tbl ) do rv[ val ] = key end
	return rv
end

function mb_stunnableMob() -- MOBS TO AUTO STUN
	if not UnitName("target") then 
		return false 
	end
	
	if (mb_hasBuffOrDebuff("Kidney Shot", "target", "debuff") or mb_hasBuffOrDebuff("Blackout", "target", "debuff") or mb_hasBuffOrDebuff("Hammer of Justice", "target", "debuff") or mb_hasBuffOrDebuff("Mace Stun", "target", "debuff") or mb_hasBuffOrDebuff("Concussion Blow", "target", "debuff") or mb_hasBuffOrDebuff("Bash", "target", "debuff") or mb_hasBuffOrDebuff("War Stomp", "target", "debuff")) then 
		return false 
	end

	if UnitName("target") == "Gurubashi Blood Drinker" or
		UnitName("target") == "Gurubashi Axe Thrower" or
		UnitName("target") == "Hakkari Priest" or
		UnitName("target") == "Gurubashi Champion" or
		UnitName("target") == "Gurubashi Headhunter" or
		UnitName("target") == "Shade of Naxxramas" or
		UnitName("target") == "Spirit of Naxxramas" or
		UnitName("target") == "Plagued Construct" or
		UnitName("target") == "Deathknight Servant" or
		UnitName("target") == "Sartura\'s Royal Guard" or
		UnitName("target") == "Battleguard Sartura" or
		UnitName("target") == "Deathchill Servant" then
		return true
	end

	if mb_healthPct("target") < 0.6 and
		(UnitName("target") == "Plagued Champion" or
		UnitName("target") == "Plagued Guardian") then
		return true
	end

	if mb_healthPct("target") < 0.4 and 
		(UnitName("target") == "Infectious Ghoul" or
		UnitName("target") == "Spawn of Fankriss" or
		UnitName("target") == "Plagued Ghoul") then
		return true
	end
	return false
end

function mb_reputationReport(faction)
	for i = 0, GetNumFactions() do
		local name, description, standingId, bottomValue, topValue, earnedValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched = GetFactionInfo(i)
		if name == faction then
			local x = topValue-earnedValue
			if (earnedValue >= 0 and earnedValue <= 2999) then
				mb_message("I need "..x.." for Friendly.")
			elseif (earnedValue >= 3000 and earnedValue <= 8999) then
				mb_message("I need "..x.." for Honored.")
			elseif (earnedValue >= 9000 and earnedValue <= 20999) then
				mb_message("I need "..x.." for Revered.")
			elseif (earnedValue >= 21000 and earnedValue <= 41999) then
				mb_message("I need "..x.." for Exalted.")
			elseif earnedValue >= 42000 then
				Print("Im Exalted with "..name)
			end
		end
	end
end

function mb_anubisathAlert() -- Kinda useless but it yells out who has what on the anub encounter

	if mb_iamFocus() then return end

	local timeout = 5
	local time = GetTime()

	if MB_anubAlertCD + timeout > time then return end
	MB_anubAlertCD = time

	if UnitName("target") == "Anubisath Sentinel" and mb_hasBuffOrDebuff("Shadow Storm", "target", "buff") then RunLine("/yell SHADOW STORM, BACK ME UP") end
	if UnitName("target") == "Anubisath Sentinel" and mb_hasBuffOrDebuff("Mana Burn", "target", "buff") then RunLine("/yell MANA BURN, BACK ME UP") end
	if UnitName("target") == "Anubisath Sentinel" and mb_hasBuffOrDebuff("Thunderclap", "target", "buff") then RunLine("/yell THUNDERCLAP, BACK ME UP") end
	if UnitName("target") == "Anubisath Sentinel" and mb_hasBuffOrDebuff("Thorns", "target", "buff") then RunLine("/say This guy has Thorns") end
	if UnitName("target") == "Anubisath Sentinel" and mb_hasBuffOrDebuff("Mortal Strike", "target", "buff") then RunLine("/say This guy has Mortal Strike") end
	if UnitName("target") == "Anubisath Sentinel" and mb_hasBuffOrDebuff("Shadow and Frost Reflect", "target", "buff") then RunLine("/say This guy has Shadow and Frost Reflect") end
	if UnitName("target") == "Anubisath Sentinel" and mb_hasBuffOrDebuff("Fire and Arcane Reflect", "target", "buff") then RunLine("/say This guy has Fire and Arcane Reflect") end
	if UnitName("target") == "Anubisath Sentinel" and mb_hasBuffOrDebuff("Mending", "target", "buff") then RunLine("/say This guy has Mending") end
	if UnitName("target") == "Anubisath Sentinel" and mb_hasBuffOrDebuff("Periodic Knock Away", "target", "buff") then RunLine("/say This guy has Knockaway") end
end

function GetColors(note) -- Getting colors

	if note == myName then

		if UnitClass("player") == "Warrior" then return "|cffC79C6E"..note.."|r"
		elseif UnitClass("player") == "Hunter" then return "|cffABD473"..note.."|r"
		elseif UnitClass("player") == "Mage" then return "|cff69CCF0"..note.."|r"
		elseif UnitClass("player") == "Rogue" then return "|cffFFF569"..note.."|r"
		elseif UnitClass("player") == "Warlock" then return "|cff9482C9"..note.."|r"
		elseif UnitClass("player") == "Druid" then return "|cffFF7D0A"..note.."|r"
		elseif UnitClass("player") == "Shaman" then return "|cff0070DE"..note.."|r"
		elseif UnitClass("player") == "Priest" then return "|cffFFFFFF"..note.."|r"
		elseif UnitClass("player") == "Paladin" then return "|cffF58CBA"..note.."|r"
		end

	elseif UnitInRaid("player") then

		for i = 1, GetNumRaidMembers() do
			if UnitName("raid"..i) == note then
				if UnitClass("raid"..i) == "Warrior" then return "|cffC79C6E"..note.."|r"
				elseif UnitClass("raid"..i) == "Hunter" then return "|cffABD473"..note.."|r"
				elseif UnitClass("raid"..i) == "Mage" then return "|cff69CCF0"..note.."|r"
				elseif UnitClass("raid"..i) == "Rogue" then return "|cffFFF569"..note.."|r"
				elseif UnitClass("raid"..i) == "Warlock" then return "|cff9482C9"..note.."|r"
				elseif UnitClass("raid"..i) == "Druid" then return "|cffFF7D0A"..note.."|r"
				elseif UnitClass("raid"..i) == "Shaman" then return "|cff0070DE"..note.."|r"
				elseif UnitClass("raid"..i) == "Priest" then return "|cffFFFFFF"..note.."|r"
				elseif UnitClass("raid"..i) == "Paladin" then return "|cffF58CBA"..note.."|r"
				end
			end
		end

	elseif UnitInParty("target") then

		for i = 1, GetNumPartyMembers() do
			if UnitName("party"..i) == note then
				if UnitClass("party"..i) == "Warrior" then return "|cffC79C6E"..note.."|r"
				elseif UnitClass("party"..i) == "Hunter" then return "|cffABD473"..note.."|r"
				elseif UnitClass("party"..i) == "Mage" then return "|cff69CCF0"..note.."|r"
				elseif UnitClass("party"..i) == "Rogue" then return "|cffFFF569"..note.."|r"
				elseif UnitClass("party"..i) == "Warlock" then return "|cff9482C9"..note.."|r"
				elseif UnitClass("party"..i) == "Druid" then return "|cffFF7D0A"..note.."|r"
				elseif UnitClass("party"..i) == "Shaman" then return "|cff0070DE"..note.."|r"
				elseif UnitClass("party"..i) == "Priest" then return "|cffFFFFFF"..note.."|r"
				elseif UnitClass("party"..i) == "Paladin" then return "|cffF58CBA"..note.."|r"
				end
			end
		end

	else
		if UnitClass("target") == "Warrior" then return "|cffC79C6E"..note.."|r"
		elseif UnitClass("target") == "Hunter" then return "|cffABD473"..note.."|r"
		elseif UnitClass("target") == "Mage" then return "|cff69CCF0"..note.."|r"
		elseif UnitClass("target") == "Rogue" then return "|cffFFF569"..note.."|r"
		elseif UnitClass("target") == "Warlock" then return "|cff9482C9"..note.."|r"
		elseif UnitClass("target") == "Druid" then return "|cffFF7D0A"..note.."|r"
		elseif UnitClass("target") == "Shaman" then return "|cff0070DE"..note.."|r"
		elseif UnitClass("target") == "Priest" then return "|cffFFFFFF"..note.."|r"
		elseif UnitClass("target") == "Paladin" then return "|cffF58CBA"..note.."|r"
		end
	end
	
	--
	if note == "Skull" then return "|cffFFFFFF"..note.."|r" end
	if note == "Cross" then return "|cffFF0000"..note.."|r" end
	if note == "Square" then return "|cff00B4FF"..note.."|r" end
	if note == "Moon" then return "|cffCEECF5"..note.."|r" end
	if note == "Triangle" then return "|cff66FF00"..note.."|r" end
	if note == "Diamond" then return "|cffCC00FF"..note.."|r" end
	if note == "Circle" then return "|cffFF9900"..note.."|r" end
	if note == "Star" then return "|cffFFFF00"..note.."|r" end
	-- extra's
	if note == "Missing Arcane Crystal" then return "|cffFFFF00"..note.."|r" end
	if note == "Missing Thorium Bar" then return "|cff00B4FF"..note.."|r" end
	if note == "Missing Thorium Bar and Arcane Crystal" then return "|cffFF0000"..note.."|r" end
	if note == "Missing Essence of Earth" then return "|cff66FF00"..note.."|r" end
	if note == "Missing Essence of Undeath" then return "|cffCC00FF"..note.."|r" end
	if note == "Missing Deeprock Salt" then return "|cffC79C6E"..note.."|r" end
	if note == "Missing Salt Shaker" then return "|cffFFFFFF"..note.."|r" end
	if note == "Missing Deeprock Salt and Salt Shaker" then return "|cffFF0000"..note.."|r" end
	if note == "Missing Felcloth" then return "|cff9482C9"..note.."|r" end
	-- cds
	if note == "Recklessness on CD" then return "|cffC79C6E"..note.."|r" end
	if note == "Death Wish on CD" then return "|cffC79C6E"..note.."|r" end
	if note == "Recklessness and Death Wish on CD" then return "|cffC79C6E"..note.."|r" end
	if note == "Last Stand on CD" then return "|cffC79C6E"..note.."|r" end
	if note == "Shield Wall on CD" then return "|cffC79C6E"..note.."|r" end
	if note == "Shield Wall and Last Stand on CD" then return "|cffC79C6E"..note.."|r" end
	if note == "Adrenaline Rush on CD" then return "|cffFFF569"..note.."|r" end
	if note == "Evocation on CD" then return "|cff69CCF0"..note.."|r" end
	if note == "Soulstone on CD" then return "|cff9482C9"..note.."|r" end
	if note == "Incarnation on CD" then return "|cff0070DE"..note.."|r" end
	if note == "Innervate on CD" then return "|cffFF7D0A"..note.."|r" end

	if note == "We\'re recking!" then return "|cff66FF00"..note.."|r" end
	if note == "Target out of range or behind me, targetting my nearest enemy!" then return "|cff66FF00"..note.."|r" end
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

function mb_reportManapots()
	if not mb_imHealer() then return end

	if mb_hasItem("Major Mana Potion") then

		mb_message("I\'ve got "..mb_hasItem("Major Mana Potion").." pots!")
	end	
end

function mb_numShadowpots()
	local pots = 0
	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			local link = GetContainerItemLink(bag, slot)
			if link == nil then
				link = ""
			end
			if string.find(link, "Greater Shadow Protection Potion") then
				pots = pots + 1
			end
		end
	end
	return pots
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
	local sandss = 0
	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			local link = GetContainerItemLink(bag, slot)
			if link == nil then
				link = ""
			end
			if string.find(link, "Hourglass Sand") then
				sandss = sandss + 1
			end
		end
	end
	return sandss
end

------------------------------------------------------------------------------------------------------
------------------------------------------- Gear Set Code! -------------------------------------------
------------------------------------------------------------------------------------------------------

mb_gear_sets = {}
mb_gear_sets["Earthfury"] = {
	"Earthfury Helmet", 
	"Earthfury Epaulets", 
	"Earthfury Vestments", 
	"Earthfury Belt", 
	"Earthfury Legguards", 
	"Earthfury Boots", 
	"Earthfury Bracers", 
	"Earthfury Gauntlets", 
	"Ring Placeholder", 
	"Ring Placeholder"
}

mb_gear_sets["The Ten Storms"] = {
	"Helmet of Ten Storms", 
	"Epaulets of Ten Storms", 
	"Breastplate of Ten Storms", 
	"Belt of Ten Storms", 
	"Legplates of Ten Storms", 
	"Greaves of Ten Storms", 
	"Bracers of Ten Storms", 
	"Gauntlets of Ten Storms", 
	"Ring Placeholder", 
	"Ring Placeholder"
}

mb_gear_sets["Stormcaller's Garb"] = {
	"Stormcaller\'s Diadem", 
	"Stormcaller\'s Pauldrons", 
	"Stormcaller\'s Hauberk", 
	"Belt Placeholder", 
	"Stormcaller\'s Leggings", 
	"Stormcaller\'s Footguards", 
	"Bracer Placeholder", 
	"Gloves Placeholder", 
	"Ring Placeholder", 
	"Ring Placeholder"
}

mb_gear_sets["Vestments of Transcendence"] = {
	"Halo of Transcendence", 
	"Pauldrons of Transcendence", 
	"Robes of Transcendence", 
	"Belt of Transcendence", 
	"Leggings of Transcendence", 
	"Boots of Transcendence", 
	"Bindings of Transcendence", 
	"Handguards of Transcendence", 
	"Ring Placeholder", 
	"Ring Placeholder"
}

mb_gear_sets["Dreamwalker Raiment"] = {
	"Dreamwalker Headpiece", 
	"Dreamwalker Spaulders", 
	"Dreamwalker Tunic", 
	"Dreamwalker Girdle", 
	"Dreamwalker Legguards", 
	"Dreamwalker Boots", 
	"Dreamwalker Wristguards", 
	"Dreamwalker Handguards", 
	"Ring of The Dreamwalker", 
	"Ring of The Dreamwalker"
}

mb_gear_sets["The Earthshatter"] = {
	"Earthshatter Headpiece", 
	"Earthshatter Spaulders", 
	"Earthshatter Tunic",
	"Earthshatter Girdle",
	"Earthshatter Legguards", 
	"Earthshatter Boots",
	"Earthshatter Wristguards", 
	"Earthshatter Handguards", 
	"Ring of The Earthshatterer", 
	"Ring of The Earthshatterer"
}	

function mb_equippedSetCount(set)
	-- head, shoulders, chest, belt, legs, boots, bracer, gloves
	local item_slots = {1, 3, 5, 6, 7, 8, 9, 10, 11, 12}
	local count = 0
		for i = 1, 10 do
		local link = GetInventoryItemLink("player", item_slots[i])
		if link == nil then 
			mb_coolDownPrint("Missing gear in slots, can\'t decide proper healspell based on gear.", 30)
			return 0
		end
		local _, _, item_name = string.find(link, "%[(.*)%]", 27)
			if item_name == mb_gear_sets[set][i] then
			count = count + 1
			end
		end
	return count
end

function mb_tankGear() -- /script mb_tankGear()
	mb_equipSet("TANK")
	MB_mySpecc = "Furytank"
	MB_warriorBinds = nil
end

function mb_furyGear() --/script mb_furyGear()
	mb_equipSet("DPS")
	MB_mySpecc = "BT"
	MB_warriorBinds = "Fury"
end

function mb_evoGear()
	MB_evoGear = true
	mb_equipSet("EVO")
end

function mb_mageGear()
	MB_evoGear = nil
	mb_equipSet("DPS")
end

function mb_equipSet(set) -- If you don't use ItemRack this should make it that you don't get any errors
	local _, _, _, Enabled, _, _, _ = GetAddOnInfo("ItemRack")
	if Enabled then EquipSet(set) return else mb_coolDownPrint("No ItemRack Addon Found") end
end

------------------------------------------------------------------------------------------------------
---------------------------------------------- Raid Init! --------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_initializeClasslists()

	MBID = {}
	MB_classList = {Warrior = {}, Mage = {}, Shaman = {}, Paladin = {}, Priest = {}, Rogue = {}, Druid = {}, Hunter = {}, Warlock = {}}
	MB_toonsInGroup = {}
	MB_offTanks = {}
	MB_raidTanks = {}
	MB_noneDruidTanks = {}
	MB_fireMages = {}
	MB_frostMages = {}
	for i = 1, 8 do MB_toonsInGroup[i] = {} end
	
	--------------------------------------------------------------------------------------------------

	if not UnitInRaid("player") and GetNumPartyMembers() == 0 then return end
	
	--------------------------------------------------------------------------------------------------

	if UnitInRaid("player") then --Raid initialize
		
		for i = 1, GetNumRaidMembers() do --Raid initialize
			local name, rank, subgroup, level, class, fileName, zone, online, isdead = GetRaidRosterInfo(i)

			if not name then return end
			if name and class and UnitIsConnected("raid"..i) and UnitExists("raid"..i) then 

				table.insert(MB_classList[class], name)
				MBID[name] = "raid"..i
				table.insert(MB_toonsInGroup[subgroup], name)
				MB_groupID[name] = subgroup
			end
		end
	else
		
		for i = 1, GetNumPartyMembers() + 1 do --Party initialize
			local id
			if i == GetNumPartyMembers() + 1 then id = "player" else id = "party"..i end

			local name =  UnitName(id)
			local class = UnitClass(id)
			MBID[name] = id

			if not name or not class then break end

			table.insert(MB_classList[class], name)
			table.insert(MB_toonsInGroup[1], name)
			MB_groupID[name] = 1
		end
	end

	--------------------------------------------------------------------------------------------------

	for k, tank in pairs(MB_tankList) do
		if MBID[tank] then

			if UnitInParty(MBID[tank]) then
				if UnitClass(MBID[tank]) == "Druid" then
					
					MB_druidTankInParty = true
				end

				if UnitClass(MBID[tank]) == "Warrior" then
					
					MB_warriorTankInParty = true
				end
			end

			if tank ~= myName then 
				table.insert(MB_offTanks, tank)
			end

			table.insert(MB_raidTanks, tank)
		end
	end

	for _, guest in pairs(MB_extraTanks) do
		if not FindInTable(MB_raidTanks, guest) then
			table.insert(MB_raidTanks, guest)
		end
	end

	for _, dru in pairs(MB_classList["Druid"]) do
		if not FindInTable(MB_raidTanks, dru) then
			table.insert(MB_noneDruidTanks, dru)
		end
	end

	for _, mage in pairs(MB_classList["Mage"]) do
		if FindInTable(MB_raidAssist.Mage.FireMages, mage) then
			table.insert(MB_fireMages, mage)
		end
	end

	for _, mage in pairs(MB_classList["Mage"]) do
		if FindInTable(MB_raidAssist.Mage.FrostMages, mage) then
			table.insert(MB_frostMages, mage)
		end
	end 
end

function mb_mySpecc()
	local GetMySpecc = MB_mySpeccList[myClass]
    if GetMySpecc and type(GetMySpecc) == "function" then
        GetMySpecc()
    else
        mb_message("I don\'t know what to do.", 500)
    end
end

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

function mb_requestInviteSummon() -- Set up raid stuff

	if IsAltKeyDown() and not IsShiftKeyDown() and not IsControlKeyDown() then -- Alt key to inv
		
		if MB_raidInviter == myName then
			
			SetLootMethod("freeforall", myName)
			
			if GetNumPartyMembers() > 0 and not UnitInRaid("player") then 
				
				ConvertToRaid()
			end
			return
		end

		if MB_raidInviter then

			if not (mb_isInRaid(MB_raidInviter) or mb_isInGroup(MB_raidInviter)) then
			
				mb_disbandRaid()
				SendChatMessage(MB_inviteMessage, "WHISPER", DEFAULT_CHAT_FRAME.editBox.languageID, MB_raidInviter);
			end
		end
		return
	end

	if IsShiftKeyDown() and not IsAltKeyDown() and not IsControlKeyDown() then -- Shift key to summ
		
		if MB_raidLeader then
			if UnitInRaid("player") then
				
				if not mb_unitInRange("raid"..mb_getRaidIndexForPlayerName(MB_raidLeader)) then
					
					mb_message("123", 10)
					return 
				end
			else
				if not mb_unitInRange("party"..mb_getRaidIndexForPlayerName(MB_raidLeader)) then
					
					mb_message("123", 10)
					return 
				end
			end
		end
	end

	if IsControlKeyDown() and not IsShiftKeyDown() and not IsAltKeyDown() then  -- Ctrl key to promote
		
		mb_promoteEveryone()
		return 
	end
end

------------------------------------------------------------------------------------------------------
---------------------------------------------- Cooldowns! --------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_cooldowns() -- Cooldowns

	if not MB_raidLeader and (TableLength(MBID) > 1) then mb_coolDownPrint("WARNING: You have not chosen a raid leader") end -- No RaidLeader Alert

	if mb_dead("player") then return end -- Stop when ur dead

	if GetRealZoneText() == "Zul\'Gurub" then 

		if mb_mandokirGaze() then return end -- Stop ALL when Gaze
	end

	if mb_iamFocus() then -- Only raid leader is allowed to

		if UnitInRaid("player") then

			if mb_inCombat("player") then
				
				if not MB_useCooldowns.Active then

					mb_coolDownPrint("Sending out request to use Cooldowns.")
				else
					mb_coolDownPrint("Stop Cooldown Requesting, still "..math.round(MB_useCooldowns.Time - GetTime()).."s remaining")
				end
			end

			SendAddonMessage(MB_RAID, "MB_USECOOLDOWNS", "RAID")
		else
			SendAddonMessage(MB_RAID, "MB_USECOOLDOWNS")
		end
	end
end

function mb_tankShoot() -- Tank Shoot

	if not MB_raidLeader and (TableLength(MBID) > 1) then mb_coolDownPrint("WARNING: You have not chosen a raid leader") end -- No RaidLeader Alert

	if mb_dead("player") then return end -- Stop when ur dead

	if myClass == "Warrior" and mb_imTank() and MB_myOTTarget then -- Shoot when you are a warrior tank

		if mb_returnEquippedItemType(18) and mb_spellExists("Shoot "..mb_returnEquippedItemType(18)) then
			
			CastSpellByName("Shoot "..mb_returnEquippedItemType(18))
		end
	end
end

function mb_manualTaunt() -- Manual Taunt

	if not MB_raidLeader and (TableLength(MBID) > 1) then mb_coolDownPrint("WARNING: You have not chosen a raid leader") end -- No RaidLeader Alert

	if mb_dead("player") then return end -- Stop when ur dead

	if GetRealZoneText() == "Zul\'Gurub" then 

		if mb_mandokirGaze() then return end -- Stop ALL when Gaze
	end
	
	if mb_imTank() then 
		
		if myClass == "Warrior" and mb_spellReady("Taunt") then
			
			CastSpellByName("Taunt")

		elseif myClass == "Druid" and mb_spellReady("Growl") then

			CastSpellByName("Growl")
		end
	end
end

------------------------------------------------------------------------------------------------------
------------------------------------------ SendAddonMessage! -----------------------------------------
------------------------------------------------------------------------------------------------------

function mb_useManualRecklessness() -- Manual Reck

	if not MB_raidLeader and (TableLength(MBID) > 1) then mb_coolDownPrint("WARNING: You have not chosen a raid leader") end -- No RaidLeader Alert

	if mb_dead("player") then return end -- Stop when ur dead

	if mb_mobsNoTotems() then return end

	if GetRealZoneText() == "Zul\'Gurub" then 

		if mb_mandokirGaze() then return end -- Stop ALL when Gaze
	end

	if mb_iamFocus() then -- I'm Focus and in Combat send Reck			

		if UnitInRaid("player") then
			
			if mb_inCombat("player") then
				
				if not MB_useBigCooldowns.Active then

					mb_coolDownPrint("Sending out request to use Recklessness.")
				else
					mb_coolDownPrint("Stop Recklessness Requesting, still "..math.round(MB_useBigCooldowns.Time - GetTime()).."s remaining")
				end
			end

			SendAddonMessage(MB_RAID, "MB_USERECKLESSNESS", "RAID")
		else
			SendAddonMessage(MB_RAID, "MB_USERECKLESSNESS")
		end
	end
end

function mb_reportCooldowns() -- Report CD's

	if not MB_raidLeader and (TableLength(MBID) > 1) then mb_coolDownPrint("WARNING: You have not chosen a raid leader") end -- No RaidLeader Alert

	if mb_dead("player") then return end -- Stop when ur dead

	if GetRealZoneText() == "Zul\'Gurub" then 

		if mb_mandokirGaze() then return end -- Stop ALL when Gaze
	end

	if mb_iamFocus() and not mb_inCombat("player") then -- I'm Focus and not inCombat send report	

		if UnitInRaid("player") then
			
			SendAddonMessage(MB_RAID, "MB_REPORTCOOLDOWNS", "RAID")
			Print("Sending out request to report Cooldowns.")
		else
			SendAddonMessage(MB_RAID, "MB_REPORTCOOLDOWNS")
		end
	end
end

function mb_clearRaidTarget()
	if not mb_iamFocus() then
		return
	end
	
	local id = GetRaidTargetIndex("target")
	if UnitInRaid("player") then
		SendAddonMessage(MB_RAID.."CLR_TARG", UnitName("player"), "RAID")
	else
		SendAddonMessage(MB_RAID.."CLR_TARG", UnitName("player"))
	end

	SetRaidTarget("target", 0)
end

function mb_setFocus()
	if IsShiftKeyDown() then 
		local targetleader = UnitName("target")
		MB_raidMeader = targetleader
		SendAddonMessage(MB_RAID.."_FTAR", MB_raidLeader.." "..myName, "RAID")
	else
		MB_raidLeader = myName
		if UnitInRaid("player") then
			SendAddonMessage(MB_RAID, "MB_FOCUSME", "RAID")
		else
			SendAddonMessage(MB_RAID, "MB_FOCUSME")
		end
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
	
SlashCmdList["REPORTREP"] = function(faction)
	if UnitInRaid("player") then
		SendAddonMessage(MB_RAID.."MB_REPORTREP", faction, "RAID")
	else
		SendAddonMessage(MB_RAID.."MB_REPORTREP", faction)
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

------------------------------------------------------------------------------------------------------
---------------------------------------------- Decurse! ----------------------------------------------
------------------------------------------------------------------------------------------------------

-- /run if mb_decurse() then Print("yes") else Print("no") end
function mb_decurse() -- Decurse

	if GetRealZoneText() == "Zul\'Gurub" then -- ZG
		
		-- No decurse from mages and druids here
		if mb_isAtJindo() and ((myClass == "Mage" or myClass == "Druid")) then
			return false
		end

	elseif GetRealZoneText() == "Blackwing Lair" then -- BWL

		-- No need to decurse when healing MT
		if (mb_tankTarget("Chromaggus") and MB_myAssignedHealTarget) then
			return false
		end
	end

	-- No need to decurse on these fights
	if (mb_isAtSkeram() or mb_tankTarget("Loatheb") or mb_tankTarget("Spore") or mb_tankTarget("Vaelastrasz the Corrupt") or mb_tankTarget("Princess Huhuran") or mb_isAtGrobbulus() or mb_tankTarget("Garr") or mb_tankTarget("Firesworn") or mb_tankTarget("Spore") or mb_tankTarget("Fungal Spore") or mb_tankTarget("Anubisath Guardian")) then
		return false
	end

	-- No Spells to decurse
	if not MBD.Session.Spells.HasSpells then 
		return false 
	end

	-- Not enough mana to decurse
	if UnitMana("player") < 320 then
		return false
	end

	-- Can't decurse when casting, the addon decursive makes you stop casting
	if mb_imBusy() then
		return false
	end
	
	if (Decurse_wait == nil or GetTime() - Decurse_wait > 0.15) then
		Decurse_wait = GetTime()

		local y, x

		if UnitInRaid("player") then -- If not in raid to clean party

			for y = 1, GetNumRaidMembers() do
				for x = 1, 16 do
					local name, count, debuffType = UnitDebuff("raid"..y, x, 1)

					if debuffType == "Curse" and MBD.Session.Spells.Curse.Can_Cure_Curse and mb_in28yardRange("raid"..y) then 
						MBD_Clean()
						return true
					end

					if debuffType == "Magic" and (MBD.Session.Spells.Magic.Can_Cure_Magic or MBD.Session.Spells.Magic.Can_Cure_Enemy_Magic) and mb_in28yardRange("raid"..y) then 
						MBD_Clean()
						return true
					end

					if debuffType == "Poison" and MBD.Session.Spells.Poison.Can_Cure_Poison and mb_in28yardRange("raid"..y) then 
						MBD_Clean()
						return true
					end

					if debuffType == "Disease" and MBD.Session.Spells.Disease.Can_Cure_Disease and mb_in28yardRange("raid"..y) then 
						MBD_Clean()
						return true
					end
				end
			end

		else

			for y = 1, GetNumPartyMembers() do
				for x = 1, 16 do
					local name, count, debuffType = UnitDebuff("party"..y, x, 1)
		
					if debuffType == "Curse" and MBD.Session.Spells.Curse.Can_Cure_Curse and mb_in28yardRange("party"..y) then 
						MBD_Clean()
						return true
					end
		
					if debuffType == "Magic" and (MBD.Session.Spells.Magic.Can_Cure_Magic or MBD.Session.Spells.Magic.Can_Cure_Enemy_Magic) and mb_in28yardRange("party"..y) then  
						MBD_Clean()
						return true
					end
		
					if debuffType == "Poison"  and MBD.Session.Spells.Poison.Can_Cure_Poison and mb_in28yardRange("party"..y) then  
						MBD_Clean()
						return true
					end
					
					if debuffType == "Disease" and MBD.Session.Spells.Disease.Can_Cure_Disease and mb_in28yardRange("party"..y) then  
						MBD_Clean()
						return true
					end
				end
			end
		end
	end
	return false
end

------------------------------------------------------------------------------------------------------
---------------------------------------------- GTFO! -------------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_GTFO() -- GTFO

	if not MB_raidAssist.GTFO.Active then return end -- Active?

	mb_useSandsOnChromaggus()

	if not mb_iamFocus() then
		
		if GetRealZoneText() == "Onyxia\'s Lair" and MB_myOnyxiaBoxStrategy then

			if mb_tankTarget("Onyxia") and (mb_tankTargetHealth() <= 0.65 and mb_tankTargetHealth() >= 0.4) and myName ~= MB_myOnyxiaMainTank then
				
				if mb_focusAggro() then -- Phase 2 follow

					if myClass == "Paladin" and mb_spellReady("Divine Shield") then 
						
						CastSpellByName("Divine Shield") 
						return 
					end

					if MBID[mb_returnPlayerInRaidFromTable(MB_raidAssist.GTFO.Onyxia)] and mb_isAlive(MBID[mb_returnPlayerInRaidFromTable(MB_raidAssist.GTFO.Onyxia)]) then -- Onyxia follow
							
						FollowByName(mb_returnPlayerInRaidFromTable(MB_raidAssist.GTFO.Onyxia), 1)
					end
				else

					if MBID[MB_myOnyxiaFollowTarget] and mb_unitInRange(MBID[MB_myOnyxiaFollowTarget]) then
							
						if not CheckInteractDistance(MBID[MB_myOnyxiaFollowTarget], 3) then

							FollowByName(MB_myOnyxiaFollowTarget, 1)
						end
					end
				end
			end	
		end
		
		if not mb_haveAggro() then

			if GetRealZoneText() == "Naxxramas" and MB_myGrobbulusBoxStrategy then -- Naxx

				if mb_isAtGrobbulus() and (myName ~= MB_myGrobbulusMainTank or myName ~= MB_myGrobbulusFollowTarget) then

					if mb_hasBuffOrDebuff("Mutating Injection", "player", "debuff") then
						
						if MBID[mb_returnPlayerInRaidFromTable(MB_raidAssist.GTFO.Grobbulus)] and mb_isAlive(MBID[mb_returnPlayerInRaidFromTable(MB_raidAssist.GTFO.Grobbulus)]) then -- Grob follow
							
							FollowByName(mb_returnPlayerInRaidFromTable(MB_raidAssist.GTFO.Grobbulus), 1)
						end
					else

						if MBID[MB_myGrobbulusFollowTarget] and mb_unitInRange(MBID[MB_myGrobbulusFollowTarget]) then
							
							if not CheckInteractDistance(MBID[MB_myGrobbulusFollowTarget], 3) then

								FollowByName(MB_myGrobbulusFollowTarget, 1)
							end
						else
							if MBID[mb_returnPlayerInRaidFromTable(MB_raidAssist.GTFO.Grobbulus)] and mb_isAlive(MBID[mb_returnPlayerInRaidFromTable(MB_raidAssist.GTFO.Grobbulus)]) then -- Grob follow
							
								FollowByName(mb_returnPlayerInRaidFromTable(MB_raidAssist.GTFO.Grobbulus), 1)
							end
						end
					end
				end
				
				mb_useFrozenRuneOnFaerlina()
			
			elseif GetRealZoneText() == "Blackwing Lair" then -- BWL
			
				if mb_hasBuffOrDebuff("Burning Adrenaline", "player", "debuff") then
				
					if myClass == "Paladin" and mb_spellReady("Divine Shield") then 
						
						CastSpellByName("Divine Shield") 
						return 
					end
	
					if MBID[mb_returnPlayerInRaidFromTable(MB_raidAssist.GTFO.Vaelastrasz)] and mb_isAlive(MBID[mb_returnPlayerInRaidFromTable(MB_raidAssist.GTFO.Vaelastrasz)]) then -- Vael follow
						
						FollowByName(mb_returnPlayerInRaidFromTable(MB_raidAssist.GTFO.Vaelastrasz), 1)
					end
				end

			elseif GetRealZoneText() == "Molten Core" then -- MC

				if mb_hasBuffOrDebuff("Living Bomb", "player", "debuff") then
				
					if myClass == "Paladin" and mb_spellReady("Divine Shield") then 
						
						CastSpellByName("Divine Shield") 
						return 
					end
				
					if MBID[mb_returnPlayerInRaidFromTable(MB_raidAssist.GTFO.Baron)] and mb_isAlive(MBID[mb_returnPlayerInRaidFromTable(MB_raidAssist.GTFO.Baron)]) then -- Baron follow
						
						FollowByName(mb_returnPlayerInRaidFromTable(MB_raidAssist.GTFO.Baron), 1)
					end
				end
			end
		end
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

function mb_ress()
	if mb_imHealer() then
		if UnitMana("player") < 1368 and myClass == "Shaman" then 			
			mb_smartDrink()
		end

		if UnitMana("player") < 1090 and myClass == "Priest" then 			
			mb_smartDrink()
		end

		if UnitMana("player") < 1209 and myClass == "Paladin" then			
			mb_smartDrink()
		end

		MBH_Resurrection()
	end

	if mb_imRangedDPS() then		
		mb_smartDrink()
	end
end

------------------------------------------------------------------------------------------------------
-------------------------------------------- Setup Code! ---------------------------------------------
------------------------------------------------------------------------------------------------------

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

------------------------------------------------------------------------------------------------------
-------------------------------------------- Setup Code! ---------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_removeFeignDeath()
	CancelBuff("Feign Death")
	DoEmote("Stand")
	MB_hunterFeign.Active = false
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