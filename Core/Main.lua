------------------------------------------------------------------------------------------------------
------------------------------------------------ FRAME! ----------------------------------------------
------------------------------------------------------------------------------------------------------

local MMB = CreateFrame("Button", "MMB", UIParent)
local MMBTooltip = CreateFrame("GAMETOOLTIP", "MMBTooltip", UIParent, "GameTooltipTemplate")

local MBx = CreateFrame("Frame")
	MBx.ACE = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0")
	Print(MBx.ACE)
	MBx.ACE.ItemBonus = AceLibrary("ItemBonusLib-1.0")
	Print(MBx.ACE.ItemBonus)
	MBx.ACE.Banzai = AceLibrary("Banzai-1.0")
	Print(MBx.ACE.Banzai)
	MBx.ACE.HealComm = AceLibrary("HealComm-1.0")
	Print(MBx.ACE.HealComm)
	
local MMB_Post_Init = CreateFrame("Button", "MMB", UIParent)

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

	local MB_DMFWeek = { Active = false, Time = 0 }
	local MB_MCEnter = { Active = false, Time = 0 }

	local MB_tradeOpen = nil
	local MB_tradeOpenOnupdate = { Active = false, Time = 0 }

	-- BossEvents --

	local MB_targetNearestDistanceChanged = nil
	local MB_razorgoreNewTargetBecauseTargetIsBehindOrOutOfRange = { Active = false, Time = 0 }
	local MB_razorgoreNewTargetBecauseTargetIsBehind = { Active = false, Time = 0 }
	local MB_lieutenantAndorovIsNotHealable = { Active = false, Time = 0 }
	local MB_targetWrongWayOrTooFar = { Active = false, Time = 0 }
	local MB_autoToggleSheeps = { Active = false, Time = 0 }
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

	MMB_Post_Init.timer = GetTime()
	MB_anubAlertCD = GetTime()

	MB_msgCD = GetTime()
	MB_prev_msg = ""

	MB_RWCD = GetTime()
	MB_prev_RW = ""

	MB_printCD = GetTime()
	MB_prev_print = ""

	MB_printSecndCD = GetTime()
	MB_prev_sendPrint = ""

	-- Mounts, CD's and Water (Add whatever keep CD's empty)

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
---------------------------------------------- OnEvent! ----------------------------------------------
------------------------------------------------------------------------------------------------------

-- Events to register

do
	for _, event in {
		"ADDON_LOADED", 
		"CHAT_MSG_WHISPER", 
		"ACTIONBAR_SLOT_CHANGED", 
		"RAID_ROSTER_UPDATE", 
		"PARTY_MEMBERS_CHANGED", 
		"PARTY_INVITE_REQUEST", 
		"CHAT_MSG_ADDON", 
		"SPELLCAST_START", 
		"CHAT_MSG_SPELL_SELF_BUFF", 
		"SPELLCAST_INTERRUPTED", 
		"SPELLCAST_FAILED", 
		"TAXIMAP_OPENED", 
		"SPELLCAST_STOP", 
		"SPELLCAST_CHANNEL_START", 
		"SPELLCAST_CHANNEL_UPDATE", 
		"SPELLCAST_CHANNEL_STOP", 
		"PLAYER_REGEN_ENABLED", 
		"PLAYER_REGEN_DISABLED", 
		"TRADE_SHOW", 
		"TRADE_CLOSED", 
		"CONFIRM_SUMMON", 
		"START_LOOT_ROLL", 
		"RESURRECT_REQUEST", 
		"UNIT_INVENTORY_CHANGED", 
		"UNIT_SPELLCAST_CHANNEL_START", 
		"UNIT_SPELLCAST_CHANNEL_STOP", 
		"MERCHANT_UPDATE", 
		"MERCHANT_FILTER_ITEM_UPDATE", 
		"MERCHANT_SHOW", 
		"MERCHANT_CLOSED", 
		"PLAYER_LOGIN", 
		"CURRENT_SPELL_CAST_CHANGED", 
		"START_AUTOREPEAT_SPELL", 
		"STOP_AUTOREPEAT_SPELL", 
		"ITEM_LOCK_CHANGED", 
		"UI_ERROR_MESSAGE", 
		"AUTOFOLLOW_END", 
		"PLAYER_ENTERING_WORLD", 
		"CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF", 
		"CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE", 
		"CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", 
		"CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF", 
		"CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE", 
		"PLAYER_TARGET_CHANGED", 
		"UNIT_AURA", 
		"UNIT_HEALTH", 
		"GOSSIP_SHOW", 
		"GOSSIP_CLOSED",
		"BAG_UPDATE",
		"BANKFRAME_OPENED",
		} 
		do MMB:RegisterEvent(event)
	end
end

function MMB:OnEvent()
	if event == "ADDON_LOADED" and arg1 == "MoronBoxCore" then

		mb_mySpecc()
		mb_initializeClasslists()
		
		MMB_Post_Init:SetScript("OnUpdate", MMB_Post_Init.OnUpdate) -- >  Starts a second INIT after logging in
		TakeTaxiNode = mb_takeTaxiNode

	elseif event == "PLAYER_LOGIN" then

		mb_mySpecc()
		mb_initializeClasslists()

	elseif event == "ACTIONBAR_SLOT_CHANGED" then

		mb_setAttackButton()
	
	elseif event == "CHAT_MSG_WHISPER" then

		if arg1 == MB_inviteMessage then InviteByName(arg2) end

		if myClass == "Mage" then
			if arg1 == MB_waterMessage then

				if mb_inTradeRange(MBID[arg2]) and mb_unitInRaidOrParty(arg2) then
					
					if mb_mageWater() > 21 then 
						
						InitiateTrade(MBID[arg2])
						mb_pickUpWater()
						DropItemOnUnit(MBID[arg2])
						
					else
						
						SendChatMessage(MB_boxTradeWaterOutOfStockReply, "WHISPER", DEFAULT_CHAT_FRAME.editBox.languageID, arg2)
						CancelTrade()
					end
				end
			else
				
				if mb_unitInRaidOrParty(arg2) then
					SendChatMessage(MB_boxTradeWaterReply, "WHISPER", DEFAULT_CHAT_FRAME.editBox.languageID, arg2)
				end
			end
		end

	elseif event == "GOSSIP_SHOW" then -- >  NPC toggle

		if UnitName("target") == "Sayge" then

			MB_DMFWeek.Active = true
			MB_DMFWeek.Time = GetTime() + 0.2

		elseif UnitName("target") == "Lothos Riftwaker" then

			MB_MCEnter.Active = true
			MB_MCEnter.Time = GetTime() + 0.2

		elseif (UnitName("target") == "Khur Hornstriker" or
			UnitName("target") == "Barim Jurgenstaad" or
			UnitName("target") == "Rekkul" or
			UnitName("target") == "Trak\'gen" or
			UnitName("target") == "Horthus" or
			UnitName("target") == "Khur Hornstriker" or
			UnitName("target") == "Hannah Akeley" or
			UnitName("target") == "Alyssa Eva" or
			UnitName("target") == "Thomas Mordan") then -- >  Add more NPC's to buy stuff from!

			MB_autoBuyReagents.Active = true	
			MB_autoBuyReagents.Time = GetTime() + 0.2

		elseif (UnitName("target") == "Quartermaster Miranda Breechlock" or
			UnitName("target") == "Argent Quartermaster Lightspark" or
			UnitName("target") == "Argent Quartermaster Hasana") then

			MB_autoBuySunfruit.Active = true	
			MB_autoBuySunfruit.Time = GetTime() + 0.2

		elseif UnitName("target") == "Andorgos" then

			MB_autoTurnInQiraji.Active = true
			MB_autoTurnInQiraji.Time = GetTime() + 0.2
		end

	elseif event == "GOSSIP_CLOSED" then

		MB_DMFWeek.Active = false
		MB_MCEnter.Active = false
		MB_autoBuyReagents.Active = false
		MB_autoBuySunfruit.Active = false
		MB_autoTurnInQiraji.Active = false

	elseif event == "TAXIMAP_OPENED" then
		
		mb_taxi()

	elseif event == "CHAT_MSG_ADDON" then

		-- Finds x item in raid
		if arg1 == MB_RAID.."MB_FIND" then

			mb_findItem(arg2)

		-- Change tanklist to inputvalue
		elseif arg1 == MB_RAID.."MB_TANKLIST" then

			local inputEncounter = string.upper(arg2)
			mb_tankList(inputEncounter)
		
		-- Reports of below 2 stacks
		elseif arg1 == MB_RAID and arg2 == "MB_REPORTMANAPOTS" then

			mb_reportManapots()

		-- Reports the amount of shards a warlocks has
		elseif arg1 == MB_RAID and arg2 == "MB_REPORTSHARDS" then
		
			mb_reportShards()

		-- Reports the amount of runes a healer has
		elseif arg1 == MB_RAID and arg2 == "MB_REPORTRUNES" then
		
			mb_reportRunes()
			
		-- Equips the ony cloak if not up
		elseif arg1 == MB_RAID and arg2 == "MB_NEFCLOAK" then

			if mb_itemNameOfEquippedSlot(15) == "Onyxia Scale Cloak" then return end

			if not mb_haveInBags("Onyxia Scale Cloak") then
				
				RunLine("/raid I don\'t have a Onyxia Scale Cloak")
				return
			end

			UseItemByName("Onyxia Scale Cloak")
					
		-- Change hots to inputvalue
		elseif arg1 == MB_RAID.."MB_HOTS" then

			local hotsValue = string.upper(arg2)
			mb_changeHots(hotsValue)
		
		-- Change gear to inputvalue
		elseif arg1 == MB_RAID.."MB_GEAR" then

			local gearSet = string.upper(arg2)
			mb_equipSet(gearSet)
		
		-- Assigning healer to target
		elseif arg1 == MB_RAID.."MB_ASSIGNHEALER" then
			
			mb_assignHealerToName(arg2)
		
		-- Uses an item in the bags	
		elseif arg1 == MB_RAID.."MB_USEBAGITEM" then

			if mb_haveInBags(arg2) then

				UseItemByName(arg2)
			else
				Print("Don\'t have "..arg2.." in the bags!")
			end
			
		elseif arg1 == MB_RAID.."MB_REMOVEBLESS" then

			if arg2 == "all" then
				for i = 1, 6 do

					if mb_hasBuffOrDebuff("Greater Blessing of Salvation", "player", "buff") then
						CancelBuff("Greater Blessing of Salvation")
					end

					if mb_hasBuffOrDebuff("Greater Blessing of Might", "player", "buff") then
						CancelBuff("Greater Blessing of Might")
					end

					if mb_hasBuffOrDebuff("Greater Blessing of Kings", "player", "buff") then
						CancelBuff("Greater Blessing of Kings")
					end

					if mb_hasBuffOrDebuff("Greater Blessing of Light", "player", "buff") then
						CancelBuff("Greater Blessing of Light")
					end

					if mb_hasBuffOrDebuff("Greater Blessing of Wisdom", "player", "buff") then
						CancelBuff("Greater Blessing of Wisdom")
					end

					if mb_hasBuffOrDebuff("Greater Blessing of Sanctuary", "player", "buff") then
						CancelBuff("Greater Blessing of Sanctuary")
					end
				end

			else
				if arg2 == nil then return end

				if mb_hasBuffOrDebuff(arg2, "player", "buff") then
					CancelBuff(arg2)
				end
			end

		-- Removes x or all buffs
		elseif arg1 == MB_RAID.."MB_REMOVEBUFFS" then

			if arg2 == "all" then
				for i = 1, 13 do

					if mb_hasBuffOrDebuff("Gift of the Wild", "player", "buff") then
						CancelBuff("Gift of the Wild")
					end

					if mb_hasBuffOrDebuff("Prayer of Spirit", "player", "buff") then
						CancelBuff("Prayer of Spirit")
					end

					if mb_hasBuffOrDebuff("Prayer of Fortitude", "player", "buff") then
						CancelBuff("Prayer of Fortitude")
					end

					if mb_hasBuffOrDebuff("Arcane Brilliance", "player", "buff") then
						CancelBuff("Arcane Brilliance")
					end

					if mb_hasBuffOrDebuff("Divine Spirit", "player", "buff") then
						CancelBuff("Divine Spirit")
					end

					if mb_hasBuffOrDebuff("Power Word: Fortitude", "player", "buff") then
						CancelBuff("Power Word: Fortitude")
					end

					if mb_hasBuffOrDebuff("Mark of the Wild", "player", "buff") then
						CancelBuff("Mark of the Wild")
					end

					if mb_hasBuffOrDebuff("Arcane Intellect", "player", "buff") then
						CancelBuff("Arcane Intellect")
					end

					if mb_hasBuffOrDebuff("Prayer of Shadow Protection", "player", "buff") then
						CancelBuff("Prayer of Shadow Protection")
					end

					if mb_hasBuffOrDebuff("Greater Blessing of Salvation", "player", "buff") then
						CancelBuff("Greater Blessing of Salvation")
					end

					if mb_hasBuffOrDebuff("Greater Blessing of Might", "player", "buff") then
						CancelBuff("Greater Blessing of Might")
					end

					if mb_hasBuffOrDebuff("Greater Blessing of Kings", "player", "buff") then
						CancelBuff("Greater Blessing of Kings")
					end

					if mb_hasBuffOrDebuff("Greater Blessing of Light", "player", "buff") then
						CancelBuff("Greater Blessing of Light")
					end

					if mb_hasBuffOrDebuff("Greater Blessing of Wisdom", "player", "buff") then
						CancelBuff("Greater Blessing of Wisdom")
					end

					if mb_hasBuffOrDebuff("Greater Blessing of Sanctuary", "player", "buff") then
						CancelBuff("Greater Blessing of Sanctuary")
					end

					if myClass == "Mage" then
						if mb_hasBuffOrDebuff("Mage Armor", "player", "buff") then
							CancelBuff("Mage Armor")
						end
					end

					if myClass == "Warlock" then
						if mb_hasBuffOrDebuff("Demon Armor", "player", "buff") then
							CancelBuff("Demon Armor")
						end
					end
				end
			else
				if arg2 == nil then return end

				if mb_hasBuffOrDebuff(arg2, "player", "buff") then
					CancelBuff(arg2)
				end
			end

		-- Focus 
		elseif arg1 == MB_RAID and arg2 == "MB_FOCUSME" and arg4 ~= myName then
			
			MB_raidLeader = arg4
			Print("I\'m Focusing "..MB_raidLeader)
		
		-- Cooldown
		elseif arg1 == MB_RAID and arg2 == "MB_USECOOLDOWNS" then

			if mb_inCombat("player") then
				
				if not MB_useCooldowns.Active then

					MB_useCooldowns.Active = true
					MB_useCooldowns.Time = GetTime() + 5
				end
			end

		-- Recklessness
		elseif arg1 == MB_RAID and arg2 == "MB_USERECKLESSNESS" then

			if mb_inCombat("player") then
				
				if not MB_useBigCooldowns.Active then

					MB_useBigCooldowns.Active = true
					MB_useBigCooldowns.Time = GetTime() + 5
				end
			end

		-- Reports what's on cooldown
		elseif arg1 == MB_RAID and arg2 == "MB_REPORTCOOLDOWNS" then
			
			mb_reportMyCooldowns()
			
		-- Reports rep to x faction
		elseif arg1 == MB_RAID.."MB_REPORTREP" then

			mb_reputationReport(arg2)
		
		-- Reports who is missing spells
		elseif arg1 == MB_RAID and arg2 == "MB_AQBOOKS" then

			mb_missingSpellsReport()

		-- Focus the last focus again
		elseif arg1 == MB_RAID.."_FTAR" then

			local focustar = string.gsub(arg2, " .*", "")
			local focusc_caller = string.gsub(arg2, "^%S- ", "")

			Print("I\'m Focusing "..focustar.." Previous tar: "..focusc_caller)
			MB_raidLeader = focustar
		
		-- Taxi code
		elseif arg1 == MB_RAID.."_flyTaxi" and arg4 ~= myName then
			
			local time = GetTime();
			MB_taxi.Time = time + 30
			MB_taxi.Node = arg2
			mb_taxi()

		elseif arg1 == MB_RAID.."_CC" then

			if arg2 == myName then
				AssistUnit(MBID[MB_raidLeader])

				if not UnitName("target") then
					mb_message("Im unable to be assigned to this target.")
					return
				end

				if not MB_myCCTarget and myName then
					if MB_raidTargetNames[GetRaidTargetIndex("target")] and UnitInRaid("player") then
						RunLine("/raid I, "..GetColors(myName).." will be CCing "..GetColors(MB_raidTargetNames[GetRaidTargetIndex("target")]))
					elseif MB_raidTargetNames[GetRaidTargetIndex("target")] then
						RunLine("/party I, "..GetColors(myName).." will be CCing "..GetColors(MB_raidTargetNames[GetRaidTargetIndex("target")]))
					end

					MB_myCCTarget = GetRaidTargetIndex("target")
				end
			end
		
		elseif arg1 == MB_RAID.."_INT" then

			if arg2 == myName then
				AssistUnit(MBID[MB_raidLeader])

				if not UnitName("target") then
					mb_message("Im unable to be assigned to this target.")
					return
				end

				if not MB_myInterruptTarget and myName then
					if MB_raidTargetNames[GetRaidTargetIndex("target")] and UnitInRaid("player") then
						RunLine("/raid I, "..GetColors(myName).." will be Interrupting "..GetColors(MB_raidTargetNames[GetRaidTargetIndex("target")]))
					elseif MB_raidTargetNames[GetRaidTargetIndex("target")] then
						RunLine("/party I, "..GetColors(myName).." will be Interrupting "..GetColors(MB_raidTargetNames[GetRaidTargetIndex("target")]))
					end

					MB_myInterruptTarget = GetRaidTargetIndex("target")
				end
			end
		
		elseif arg1 == MB_RAID.."_FEAR" then

			if arg2 == myName then
				AssistUnit(MBID[MB_raidLeader])

				if not UnitName("target") then
					mb_message("Im unable to be assigned to this target.")
					return
				end

				if not MB_myFearTarget and myName then
					if MB_raidTargetNames[GetRaidTargetIndex("target")] and UnitInRaid("player") then
						RunLine("/raid I, "..GetColors(myName).." will be Fearing "..GetColors(MB_raidTargetNames[GetRaidTargetIndex("target")]))
					elseif MB_raidTargetNames[GetRaidTargetIndex("target")] then
						RunLine("/party I, "..GetColors(myName).." will be Fearing "..GetColors(MB_raidTargetNames[GetRaidTargetIndex("target")]))
					end

					MB_myFearTarget = GetRaidTargetIndex("target")
				end
			end
		
		elseif arg1 == MB_RAID.."_OT" then

			if arg2 == myName then
				AssistUnit(MBID[MB_raidLeader])

				if not UnitName("target") then
					mb_message("Im unable to be assigned to this target.")
					return
				end

				if not MB_myOTTarget and myName then
					if MB_raidTargetNames[GetRaidTargetIndex("target")] and UnitInRaid("player") then
						RunLine("/raid I, "..GetColors(myName).." will be Tanking "..GetColors(MB_raidTargetNames[GetRaidTargetIndex("target")]))
					elseif MB_raidTargetNames[GetRaidTargetIndex("target")] then
						RunLine("/party I, "..GetColors(myName).." will be Tanking "..GetColors(MB_raidTargetNames[GetRaidTargetIndex("target")]))
					end

					if mb_myNameInTable(MB_furysThatCanTank) then				
						mb_tankGear()			
					end

					MB_myOTTarget = GetRaidTargetIndex("target")
				end
			end
		
		elseif arg1 == MB_RAID.."CLR_TARG" then

			AssistUnit(MBID[arg2])

			if MB_myOTTarget and MB_myOTTarget == GetRaidTargetIndex("target") then
				if MB_raidTargetNames[GetRaidTargetIndex("target")] then
					if UnitInRaid("player") then
						RunLine("/raid I, "..GetColors(myName).." stopped Tanking "..GetColors(MB_raidTargetNames[GetRaidTargetIndex("target")]))
					else
						RunLine("/party I, "..GetColors(myName).." stopped Tanking "..GetColors(MB_raidTargetNames[GetRaidTargetIndex("target")]))
					end

					if mb_myNameInTable(MB_furysThatCanTank) then						
						mb_furyGear()						
					end

					MB_myOTTarget = nil
				end
			end

			if MB_myCCTarget and MB_myCCTarget == GetRaidTargetIndex("target") then
				if MB_raidTargetNames[GetRaidTargetIndex("target")] then
					if UnitInRaid("player") then
						RunLine("/raid I, "..GetColors(myName).." stopped CCing "..GetColors(MB_raidTargetNames[GetRaidTargetIndex("target")]))
					else
						RunLine("/party I, "..GetColors(myName).." stopped CCing "..GetColors(MB_raidTargetNames[GetRaidTargetIndex("target")]))
					end

					MB_myCCTarget = nil
				end
			end

			if MB_myInterruptTarget and MB_myInterruptTarget == GetRaidTargetIndex("target") then
				if MB_raidTargetNames[GetRaidTargetIndex("target")] then
					if UnitInRaid("player") then
						RunLine("/raid I, "..GetColors(myName).." stopped Interrupt "..GetColors(MB_raidTargetNames[GetRaidTargetIndex("target")]))
					else
						RunLine("/party I, "..GetColors(myName).." stopped Interrupt "..GetColors(MB_raidTargetNames[GetRaidTargetIndex("target")]))
					end

					MB_myInterruptTarget = nil
				end
			end
		end

	elseif event == "RAID_ROSTER_UPDATE" then

		mb_initializeClasslists()
	
	elseif event == "PARTY_MEMBERS_CHANGED" then

		mb_initializeClasslists()

	elseif event == "PARTY_INVITE_REQUEST" then

		AcceptGroup()
		StaticPopup_Hide("PARTY_INVITE")
		UIErrorsFrame:AddMessage("Group Auto Accept")
		
	elseif event == "UNIT_INVENTORY_CHANGED" then -- this event fires when your inventory changes, you can add functions to keep track of bagspace/inventory items/soulshards etc here
		
		if (myClass == "Priest" or myClass == "Druid" or myClass == "Shaman" or myClass == "Paladin") then
			
			mb_getHealSpell()
		end

	elseif event == "SPELLCAST_START" then

		MB_isCasting = true

		if arg1 == MB_myCCSpell[UnitClass("player")] then

			MB_isCastingMyCCSpell = true
		end
						
	elseif event == "SPELLCAST_INTERRUPTED" then

		MB_isCasting = nil
		MB_isCastingMyCCSpell = nil

	elseif event == "SPELLCAST_FAILED" then

		MB_isCasting = nil
		MB_isCastingMyCCSpell = nil
		
	elseif event == "SPELLCAST_CHANNEL_START" then

		MB_isChanneling = true

	elseif event == "SPELLCAST_CHANNEL_STOP" then

		MB_isChanneling = nil
	
	elseif event == "START_LOOT_ROLL" then

		if not mb_iamFocus() then 
			RollOnLoot(arg1, 0) 
		end
	
	elseif event == "CONFIRM_SUMMON" then

		if not mb_iamFocus() then 
			
			ConfirmSummon()
			StaticPopup_Hide("CONFIRM_SUMMON")
		end

	elseif event == "BANKFRAME_OPENED" then

	elseif event == "TRADE_SHOW" then
		
		MB_tradeOpen = true
		MB_tradeOpenOnupdate.Active = true	
		MB_tradeOpenOnupdate.Time = GetTime() + 1

	elseif event == "TRADE_CLOSED" then

		MB_tradeOpen = nil
		MB_tradeOpenOnupdate.Active = false	

	elseif event == "UI_ERROR_MESSAGE" then

		if arg1 == "You must be standing to do that" then

			if mb_manaPct("player") > 0.99 and mb_hasBuffNamed("Drink", "player") then 
				DoEmote("Stand") 
			end

			if not mb_hasBuffNamed("Drink", "player") then
				DoEmote("Stand")
			end

			if mb_manaPct("player") > 0.8 and mb_inCombat("player") and mb_hasBuffNamed("Drink", "player") then
				DoEmote("Stand")
			end

		elseif arg1 == "Can\'t do that while moving" then -- MOVING

			if (myClass == "Warlock" or myClass == "Priest" or myClass == "Druid" or myClass == "Mage" or myClass == "Shaman") and not MB_isMoving.Active then
				
				MB_isMoving.Active = true
				MB_isMoving.Time = GetTime() + 1
			end

		elseif arg1 == "Target needs to be in front of you" then -- LOS

			if (GetRealZoneText() == "Blackwing Lair" and (GetSubZoneText() == "Dragonmaw Garrison" and mb_isAtRazorgorePhase())) and MB_myRazorgoreBoxStrategy then

				MB_razorgoreNewTargetBecauseTargetIsBehindOrOutOfRange.Active = true
				MB_razorgoreNewTargetBecauseTargetIsBehindOrOutOfRange.Time = GetTime() + 2

				MB_razorgoreNewTargetBecauseTargetIsBehind.Active = true
				MB_razorgoreNewTargetBecauseTargetIsBehind.Time = GetTime() + 3
			end

		elseif arg1 == "Out of range." then -- OOR
			
			if (GetRealZoneText() == "Blackwing Lair" and (GetSubZoneText() == "Dragonmaw Garrison" and mb_isAtRazorgorePhase())) and MB_myRazorgoreBoxStrategy then

				if (myClass == "Warrior" or myClass == "Rogue") then return end

				MB_razorgoreNewTargetBecauseTargetIsBehindOrOutOfRange.Active = true
				MB_razorgoreNewTargetBecauseTargetIsBehindOrOutOfRange.Time = GetTime() + 2
			end

			if GetRealZoneText() == "The Ruins of Ahn\'Qiraj" and UnitName("target") == "Lieutenant General Andorov" then

				if mb_imHealer() then
					MB_lieutenantAndorovIsNotHealable.Active = true
					MB_lieutenantAndorovIsNotHealable.Time = GetTime() + 6
				end
			end
		
		elseif arg1 == "Target not in line of sight" then -- LOS

			if (GetRealZoneText() == "Blackwing Lair" and (GetSubZoneText() == "Dragonmaw Garrison" and mb_isAtRazorgorePhase())) and MB_myRazorgoreBoxStrategy then

				MB_razorgoreNewTargetBecauseTargetIsBehindOrOutOfRange.Active = true
				MB_razorgoreNewTargetBecauseTargetIsBehindOrOutOfRange.Time = GetTime() + 2
			end

			if GetRealZoneText() == "The Ruins of Ahn\'Qiraj" and UnitName("target") == "Lieutenant General Andorov" then

				if mb_imHealer() then
					MB_lieutenantAndorovIsNotHealable.Active = true
					MB_lieutenantAndorovIsNotHealable.Time = GetTime() + 6
				end
			end

		elseif arg1 == "You are facing the wrong way!" then

			if mb_tankTarget("Plague Beast") or mb_tankTarget("Onyxia") then
				
				MB_targetWrongWayOrTooFar.Active = true
				MB_targetWrongWayOrTooFar.Time = GetTime() + 1
			end

		elseif arg1 == "You are too far away!" then

			if mb_tankTarget("Plague Beast") or mb_tankTarget("Onyxia") then
				
				MB_targetWrongWayOrTooFar.Active = true
				MB_targetWrongWayOrTooFar.Time = GetTime() + 1
			end
		end
	
	elseif event == "PLAYER_REGEN_ENABLED" then

		MB_cooldowns = {}
		MB_myCCTarget = nil
		MB_myInterruptTarget = nil
		MB_myOTTarget = nil
		MB_myFearTarget = nil
		MB_Ot_Index = 1

		MB_currentCC = {
			Mage = 1, 
			Warlock = 1, 
			Priest = 1, 
			Druid = 1
		}

		MB_currentInterrupt  = {
			Rogue = 1, 
			Mage = 1, 
			Shaman = 1
		}

		MB_currentFear = {
			Warlock = 1
		}

		MB_currentRaidTarget = 1
		MB_doInterrupt.Active = false

		MB_useCooldowns.Active = false
		MB_useBigCooldowns.Active = false

		if not mb_iamFocus() then 
			mb_clearTargetIfNotAggroed()
		end

		if myClass == "Warrior" then
			if MB_warriorBinds == "Fury" and mb_imMeleeDPS() then
				if mb_myNameInTable(MB_furysThatCanTank) then

					mb_furyGear()					
				end
			end
		end

		if myClass == "Mage" then
			
			mb_mageGear()
		end

		local x = GetCVar("targetNearestDistance")
		if x == "10" then
			SetCVar("targetNearestDistance", "41")
		end
		
	elseif event == "PLAYER_REGEN_DISABLED" then

	
	elseif event == "RESURRECT_REQUEST" then

		if mb_tankTarget("Bloodlord Mandokir") then return end
		
		AcceptResurrect()
		StaticPopup_Hide("RESURRECT_NO_TIMER")
		StaticPopup_Hide("RESURRECT_NO_SICKNESS")
		StaticPopup_Hide("RESURRECT")
		
	elseif event == "MERCHANT_SHOW" then

		Print("Opened Merchant")

		if CanMerchantRepair() then 
			if GetRepairAllCost() > GetMoney() then
				
				mb_message("I need gold! Can\'t affort repairs!")
			else
				
				RepairAllItems()
			end		
		end

		if (UnitName("target") == "Khur Hornstriker" or
			UnitName("target") == "Barim Jurgenstaad" or
			UnitName("target") == "Rekkul" or
			UnitName("target") == "Trak\'gen" or
			UnitName("target") == "Horthus" or
			UnitName("target") == "Khur Hornstriker" or
			UnitName("target") == "Hannah Akeley" or
			UnitName("target") == "Alyssa Eva" or
			UnitName("target") == "Thomas Mordan") then -- >  Add more NPC's to buy stuff from!

			MB_autoBuyReagents.Active = true	
			MB_autoBuyReagents.Time = GetTime() + 0.2

		elseif (UnitName("target") == "Quartermaster Miranda Breechlock" or
			UnitName("target") == "Argent Quartermaster Lightspark" or
			UnitName("target") == "Argent Quartermaster Hasana") then

			MB_autoBuySunfruit.Active = true	
			MB_autoBuySunfruit.Time = GetTime() + 0.2

		elseif UnitName("target") == "Andorgos" then

			MB_autoTurnInQiraji.Active = true
			MB_autoTurnInQiraji.Time = GetTime() + 1
		end

	elseif event == "MERCHANT_CLOSED" then

		MB_autoBuyReagents.Active = false	
		MB_autoBuySunfruit.Active = false
		MB_autoTurnInQiraji.Active = false

	elseif event == "SPELLCAST_STOP" then

		MB_isCasting = false
		MB_isCastingMyCCSpell = nil
	
	elseif (event == "CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF" or 
			event == "CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE" or 
			event == "CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE" or 
			event == "CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF") then

		local _, _, caster, spell = string.find(arg1, "(.*) begins to cast (.*).")
		
		if caster and UnitName("target") == caster then
			for k, badSpell in MB_spellsToInt do
				if spell == badSpell then
					Print("Found bad spell: "..badSpell.." from: "..caster)
					if UnitName("target") and badSpell and mb_spellReady(MB_myInterruptSpell[myClass]) then
						if myClass == "Priest" and not mb_knowSpell("Silence") then return end

						MB_doInterrupt.Active = true
						MB_doInterrupt.Time = GetTime() + 3
					end
				end
			end
		end	

	elseif event == "PLAYER_ENTERING_WORLD" then

		mb_initializeClasslists()
		
	elseif event == "CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE" then

		if myClass == "Mage" then
			for mob, tick, igniter in string.gfind(arg1, "(.+) suffers (.+) Fire damage from (.+) Ignite.") do
				
				if (mob == UnitName("target")) then

					if (igniter == "your") then
						igniter = UnitName("player")
					end

					MB_ignite.Active = true
					MB_ignite.Starter = igniter
					MB_ignite.Amount = tick
					MB_ignite.Stacks = mb_debuffIgniteAmount()
				end
			end
		end	

	elseif event == "PLAYER_TARGET_CHANGED" then

		if myClass == "Warlock" then
			MB_cooldowns["Corruption"] = nil
		end

		if myClass == "Mage" then

			MB_ignite.Active = nil
			MB_ignite.Starter = nil
			MB_ignite.Amount = 0
			MB_ignite.Stacks = 0
		end

	elseif event == "UNIT_AURA" and arg1 == "target" then

		if myClass == "Mage" then 
			if (mb_debuffIgniteAmount() == 0) then
				
				MB_ignite.Active = nil
				MB_ignite.Starter = nil
				MB_ignite.Amount = 0
				MB_ignite.Stacks = 0

			elseif (mb_debuffIgniteAmount() > MB_ignite.Stacks) then

				MB_ignite.Active = true;
				MB_ignite.Stacks = mb_debuffIgniteAmount();
			end
		end
	
	elseif event == "UNIT_HEALTH" and arg1 == "target" and UnitHealth("target") == 0 then
		
		MB_doInterrupt.Active = false

		if myClass == "Mage" then

			MB_ignite.Active = nil
			MB_ignite.Starter = nil
			MB_ignite.Amount = 0
			MB_ignite.Stacks = 0
		end
	end	
end

MMB:SetScript("OnEvent", MMB.OnEvent) 

------------------------------------------------------------------------------------------------------
--------------------------------------------- OnUpdate! ----------------------------------------------
------------------------------------------------------------------------------------------------------

function MMB:OnUpdate()

	if MB_tradeOpenOnupdate.Active then
		if GetTime() > MB_tradeOpenOnupdate.Time then

			for i = 0, 6 do
				for k, item in pairs(MB_itemToAutoTrade) do

					if MB_tradeOpen and GetTradeTargetItemLink(i) and string.find(GetTradeTargetItemLink(i), item) then
						AcceptTrade() 
						return 
					end
					
					if MB_tradeOpen and GetTradePlayerItemLink(i) and string.find(GetTradePlayerItemLink(i), item) then
						AcceptTrade() 
						return 
					end
				end
			end
		end
	end

	if MB_DMFWeek.Active then
		if GetTime() > MB_DMFWeek.Time then

			MB_DMFWeek.Active = false

			local a, _, b = GetGossipOptions()

			if mb_imHealer() then

				if a == "Yes" then
					SelectGossipOption(1)
				end

				if b == "Turn him over to liege" or b == "Show not so quiet defiance" then
					SelectGossipOption(2)
				end
				return
			end

			if a == "Yes" or a == "Slay the Man" or a == "Execute your friend painfully" then
				SelectGossipOption(1)
			end
		end
	end

	if MB_MCEnter.Active then
        if GetTime() > MB_MCEnter.Time then

			if GetGossipOptions() == "Teleport me to the Molten Core" then
				
				SelectGossipOption(1)
			end

            MB_MCEnter.Active = false
        end
    end

	if MB_autoTurnInQiraji.Active then
        if GetTime() > MB_autoTurnInQiraji.Time then

			if not mb_getQuest("Secrets of the Qiraji") then mb_openClickQiraji() end

			local Q1, _, Q2, _, Q3 = GetGossipActiveQuests()
			if Q1 == "Secrets of the Qiraji"  then SelectGossipActiveQuest(1) end
			if Q2 == "Secrets of the Qiraji" then SelectGossipActiveQuest(2) end
			if Q3 == "Secrets of the Qiraji" then SelectGossipActiveQuest(3) end
        end
    end

	if MB_razorgoreNewTargetBecauseTargetIsBehindOrOutOfRange.Active then
        if GetTime() > MB_razorgoreNewTargetBecauseTargetIsBehindOrOutOfRange.Time then

            MB_razorgoreNewTargetBecauseTargetIsBehindOrOutOfRange.Active = false
        end
    end

	if MB_lieutenantAndorovIsNotHealable.Active then
        if GetTime() > MB_lieutenantAndorovIsNotHealable.Time then

            MB_lieutenantAndorovIsNotHealable.Active = false
        end
    end

	if MB_razorgoreNewTargetBecauseTargetIsBehind.Active then
        if GetTime() > MB_razorgoreNewTargetBecauseTargetIsBehind.Time then

            MB_razorgoreNewTargetBecauseTargetIsBehind.Active = false
        end
    end

	if MB_targetWrongWayOrTooFar.Active then
        if GetTime() > MB_targetWrongWayOrTooFar.Time then

            MB_targetWrongWayOrTooFar.Active = false
        end
    end

	if MB_autoToggleSheeps.Active and GetTime() > MB_autoToggleSheeps.Time then
		MB_autoToggleSheeps.Active = false
	end

	if MB_autoBuff.Active then
        if GetTime() > MB_autoBuff.Time then

            MB_autoBuff.Active = false
        end
    end

	if MB_useCooldowns.Active then
        if GetTime() > MB_useCooldowns.Time then

            MB_useCooldowns.Active = false
        end
    end

	if MB_useBigCooldowns.Active then
        if GetTime() > MB_useBigCooldowns.Time then

            MB_useBigCooldowns.Active = false
        end
    end
	
	if MB_doInterrupt.Active then
        if GetTime() > MB_doInterrupt.Time then

            MB_doInterrupt.Active = false
        end
    end

	if MB_isMoving.Active then
        if GetTime() > MB_isMoving.Time then

            MB_isMoving.Active = false
        end
    end

	if MB_autoBuyReagents.Active then
        if GetTime() > MB_autoBuyReagents.Time then

			mb_buyReagentsAndArrows()
        end
    end

	if MB_hunterFeign.Active then
        if GetTime() > MB_hunterFeign.Time then

			mb_removeFeignDeath()
        end
    end
end

function MMB_Post_Init:OnUpdate()
	if GetTime() - MMB_Post_Init.timer < 2.5 then return end

	mb_mySpecc()
	mb_initializeClasslists()
	mb_setAttackButton()
	mb_getHealSpell()
	
	------------------------------------------- Login Notes ----------------------------------------------
	
	DEFAULT_CHAT_FRAME:AddMessage("|cffC71585Welcome to MoronBox! Created by MoroN.",1,1,1)
	DEFAULT_CHAT_FRAME:AddMessage("|cffC71585MoronBox: |r|cff00ff00 Scripts loaded succesfully. Issues? Let me know!",1,1,1)
	
	if MB_raidAssist.AutoEquipSet.Active then
		mb_equipSet(MB_raidAssist.AutoEquipSet.Set)
	end

	MMB_Post_Init:SetScript("OnUpdate", nil)
	MMB_Post_Init.timer = nil
	MMB_Post_Init.onupdate = nil
end

MMB:SetScript("OnUpdate", MMB.OnUpdate)

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

function mb_findInTable(table, string)
	--only works on 1D tables
	if not table then return end

	for i, v in table do
		if v == string then return i end
	end
	return nil
end

function FindKeyInTable(table, string)

	if not table then return end

	for i, v in table do
		if i == string and v then return true end
	end
	return nil
end

--[[
	function mb_tankTarget(mobname) --Sometimes we have to know if the tank is targeting a certain boss, so we can do things differently as dps.

		if MBID[MB_raidLeader] and UnitName(MBID[MB_raidLeader].."target") then
			if string.find(UnitName(MBID[MB_raidLeader].."target"), mobname) then return true end
		end
		return false
	end
]]

function mb_tankTarget(mobname) -- Sometimes we have to know if the tank is targeting a certain boss, so we can do things differently as dps.
	if MBID[MB_raidLeader] and UnitName(MBID[MB_raidLeader].."target") then
		if UnitName(MBID[MB_raidLeader].."target") == mobname then return true end
	end
	return false
end

function mb_tankTargetInSet(mobSet)
    if MBID[MB_raidLeader] and UnitName(MBID[MB_raidLeader].."target") then
        local tankTargetName = UnitName(MBID[MB_raidLeader].."target")
        return mobSet[tankTargetName] == true
    end
    return false
end

function mb_playerWithAgroFromSpecificTarget(target, player)

	if MBID[player] and UnitName(MBID[player].."targettarget") then
		if string.find(UnitName(MBID[player].."target"), target) then return true end
	end
	return false
end

-- /run if mb_targetHealthFromRaidleader("Tauror", 0.9) then Print("yes") else Print("no") end
function mb_targetHealthFromRaidleader(mobName, percentage)
	
	if MBID[MB_raidLeader] and mb_tankTarget(mobName) then
		if (mb_healthPct(MBID[MB_raidLeader].."target") <= percentage) then
			return true
		end		
	end
	return false
end

function mb_targetHealthFromSpecificPlayer(mobName, percentage, player)
	
	if mb_targetFromSpecificPlayer(mobName, player) then
		if (mb_healthPct(MBID[player].."target") <= percentage) then
			return true
		end
	end
	return false
end

function mb_tankName() --Return tanks's name

	if not MB_raidLeader then return end

	if MBID[MB_raidLeader] then
		return UnitName(MBID[MB_raidLeader])
	else

		TargetByName(MB_raidLeader, 1)
		return "target"
	end
end

function mb_promoteEveryone()
	for toon, id in MBID do PromoteToAssistant(toon) end
end

function mb_iamFocus() -- Focus
	if MB_raidLeader == myName then return true end
end

function mb_clearTargetIfNotAggroed()
	if not mb_inCombat("target") then ClearTarget() end
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

function mb_focusAggro()
	if MBID[MB_raidLeader] and UnitName(MBID[MB_raidLeader].."targettarget") then
		if string.find(UnitName(MBID[MB_raidLeader].."targettarget"), myName) then return true end
	end
	return false
end

function mb_isAlive(id)
	if not id then
		return
	end

	if UnitName(id) and (not UnitIsDead(id) and UnitHealth(id) > 1 and not UnitIsGhost(id) and UnitIsConnected(id)) then
		return true
	end
end

function mb_unitInRange(unit)
	if CheckInteractDistance(unit, 4) then
		return true
	end
	return nil
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

function mb_partyMana() -- Gives the mana party info

	MB_partyMana = MB_partyMana or 0
	MB_partyMaxMana = MB_partyMaxMana or 0

	MB_partyManaPCT = MB_partyManaPCT or 0
	MB_partyManaDown = MB_partyManaDown or 0

	if not UnitInParty(MBID[myName]) then return MB_partyManaPCT, MB_partyManaDown, MB_partyMana, MB_partyMaxMana end

	local myGroup = MB_groupID[myName]	

	for k, name in MB_toonsInGroup[myGroup] do

		if mb_isAlive(MBID[name]) and mb_manaUser(MBID[name]) then

			MB_partyMana = MB_partyMana + UnitMana(MBID[name])
			MB_partyMaxMana = MB_partyMaxMana + UnitManaMax(MBID[name])
		end
	end

	MB_partyManaPCT = (MB_partyMana / MB_partyMaxMana)
	MB_partyManaDown = (MB_partyMaxMana - MB_partyMana)

	return MB_partyManaPCT, MB_partyManaDown, MB_partyMana, MB_partyMaxMana
end

function mb_raidHealth() -- Gives the health group info
	if not UnitInRaid("player") then return mb_partyHealth() end

    MB_raidHealth = MB_raidHealth or 0
    MB_raidMaxHealth = MB_raidMaxHealth or 0

    for name, id in MBID do
        if mb_isAlive(id) then

            MB_raidHealth = MB_raidHealth + UnitHealth(id)
            MB_raidMaxHealth = MB_raidMaxHealth + UnitHealthMax(id)
        end
    end
    
	MB_raidHealthPCT = (MB_raidHealth / MB_raidMaxHealth)
	MB_raidHealthDown = (MB_raidMaxHealth - MB_raidHealth)

    return MB_raidHealthPCT, MB_raidHealthDown
end

function mb_partyHealth() -- Gives the health party info

	MB_partyHealth = MB_partyHealth or 0
    MB_partyMaxHealth = MB_partyMaxHealth or 0

	MB_partyHealthPCT = MB_partyHealthPCT or 0
	MB_partyHealthDown = MB_partyHealthDown or 0

	if not UnitInParty(MBID[myName]) then return MB_partyHealthPCT, MB_partyHealthDown end

    local myGroup = MB_groupID[myName]

    for _, name in MB_toonsInGroup[myGroup] do
        if mb_isAlive(MBID[name]) then

            MB_partyHealth = MB_partyHealth + UnitHealth(MBID[name])
            MB_partyMaxHealth = MB_partyMaxHealth + UnitHealthMax(MBID[name])
        end
    end
    
	MB_partyHealthPCT = (MB_partyHealth / MB_partyMaxHealth)
	MB_partyHealthDown = (MB_partyMaxHealth - MB_partyHealth)

    return MB_partyHealthPCT, MB_partyHealthDown
end

function mb_warriorHealth() -- Gives the warrior health info

    MB_raidWarriorHealth = MB_raidWarriorHealth or 0
    MB_raidWarriorMaxHealth = MB_raidWarriorMaxHealth or 0

	for id, name in MB_classList["Warrior"] do
		
		if mb_isAlive(MBID[name]) then
			
            MB_raidWarriorHealth = MB_raidWarriorHealth + UnitHealth(MBID[name])
            MB_raidWarriorMaxHealth = MB_raidWarriorMaxHealth + UnitHealthMax(MBID[name])
		end
	end
    
	MB_raidWarriorHealthPCT = (MB_raidWarriorHealth / MB_raidWarriorMaxHealth)
	MB_raidWarriorHealthDown = (MB_raidWarriorMaxHealth - MB_raidWarriorHealth)

    return MB_raidWarriorHealthPCT, MB_raidWarriorHealthDown
end

function mb_pickAndDropItemOnTarget(itemName, target)

	if not mb_inTradeRange(target) then return end
	local target = target or "target"
	local i, x = mb_bagSlotOf(itemName)
	PickupContainerItem(i, x)
	DropItemOnUnit(target)
end

function mb_inMeleeRange()
	return CheckInteractDistance("target", 3)
end
-- /run if CheckInteractDistance("target", 3) then Print("ye") else Print("no") end

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
		mb_CanHelpfulSpellBeCastOn(spell, unit) then
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

function mb_CanHelpfulSpellBeCastOn(spell, unit)

	if MB_raidAssist.Use40yardHealingRangeOnInstants then 

		local oldtarget
		if UnitName("target") then
			oldtarget = UnitName("target")
			ClearTarget()
		end

		local can = false
		CastSpellByName(spell, false)
		if SpellCanTargetUnit(unit) then
			can = true
		end
		
		SpellStopTargeting()
		
		if oldtarget then
			TargetByName(oldtarget)
		end
		return can
		
	else
		return mb_in28yardRange(unit)
	end
end

function mb_GetUnitForPlayerName(playerName) -- Turns a playerName into a unit-reference, nil if not found
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

function mb_getLink(item)

	for bag = 0, 4 do 
		for slot = 1, GetContainerNumSlots(bag) do 
			local texture, itemCount, locked, quality, readable, lootable, link = GetContainerItemInfo(bag, slot) 

			if texture then
				link = GetContainerItemLink(bag, slot) 
				if string.find(link, item) then 
					return link 
				end
			end
		end 
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

function mb_healthBetweenHighLowHP(health, pct1, pct2)
	return (health <= pct1 and health >= pct2)
end

function mb_tankTargetHealth() -- Return nil if you have no focus

	if not MB_raidLeader then return end

	local health = 0

	if not mb_dead(MBID[MB_raidLeader].."target") then
		health = mb_healthPct(MBID[MB_raidLeader].."target")
	end
	return health
end

function mb_isAtJindo() -- Mobs that are in the Jindo encounter
	local tname =  UnitName("target")

	if ((mb_tankTarget("Powerful Healing Ward") or mb_tankTarget("Shade of Jin\'do") or mb_tankTarget("Jin\'do the Hexxer") or mb_tankTarget("Brain Wash Totem"))) or tname == "Powerful Healing Ward" or tname == "Shade of Jin\'do" or tname == "Jin\'do the Hexxer" or tname == "Brain Wash Totem" then
		return true 
	end
end

function mb_isAtNoth() -- Mobs that are in the Noth encounter
    local tname =  UnitName("target")

	if ((mb_tankTarget("Noth the Plaguebringer") or mb_tankTarget("Plagued Warrior") or mb_tankTarget("Plagued Champion") or mb_tankTarget("Plagued Guardian") or mb_tankTarget("Plagued Skeletons"))) or tname == "Noth the Plaguebringer" or tname == "Plagued Warrior" or tname == "Plagued Champion" or tname == "Plagued Guardian" or tname == "Plagued Skeletons" then
		return true 
	end
end

function mb_isAtMonstrosity() -- Mobs that are in the Lightning Totem encounter
	local tname = UnitName("target")

	if ((mb_tankTarget("Living Monstrosity") or mb_tankTarget("Mad Scientist") or mb_tankTarget("Surgical Assistant")) or (tname == "Living Monstrosity" or tname == "Mad Scientist" or tname == "Surgical Assistant")) then
		return true 
	end
end

function mb_isAtGrobbulus() -- Mobs that are in the Lightning Totem encounter
	local tname = UnitName("target")

	if ((mb_targetFromSpecificPlayer("Grobbulus", MB_myGrobbulusMainTank) or mb_targetFromSpecificPlayer("Fallout Slime", MB_myGrobbulusSlimeTankOne) or mb_targetFromSpecificPlayer("Fallout Slime", MB_myGrobbulusSlimeTankTwo)) or (mb_tankTarget("Grobbulus") or mb_tankTarget("Fallout Slime")) or (tname == "Grobbulus" or tname == "Fallout Slime")) then
		return true 
	end
end

function mb_isAtLoatheb() -- Mobs that are in the Lightning Totem encounter
	local tname = UnitName("target")

	if ((mb_targetFromSpecificPlayer("Loatheb", MB_myLoathebMainTank) or mb_targetFromSpecificPlayer("Spore", MB_myLoathebMainTank)) or (mb_tankTarget("Loatheb") or mb_tankTarget("Spore")) or (tname == "Loatheb" or tname == "Spore")) then
		return true 
	end
end

function mb_isAtRazorgorePhase() -- You are currently in the Razorgore Platform encounter
	local tname = UnitName("target")

	if (IsOrbControlled() or ((mb_tankTarget("Blackwing Mage") or mb_tankTarget("Blackwing Legionnaire") or mb_tankTarget("Death Talon Dragonspawn")) or tname == "Blackwing Mage" or tname == "Blackwing Legionnaire" or tname == "Death Talon Dragonspawn") or 
		((mb_targetFromSpecificPlayer("Blackwing Mage", mb_returnPlayerInRaidFromTable(MB_myRazorgoreLeftTank)) or mb_targetFromSpecificPlayer("Blackwing Legionnaire", mb_returnPlayerInRaidFromTable(MB_myRazorgoreLeftTank)) or mb_targetFromSpecificPlayer("Death Talon Dragonspawn", mb_returnPlayerInRaidFromTable(MB_myRazorgoreLeftTank))) or (mb_targetFromSpecificPlayer("Blackwing Mage", mb_returnPlayerInRaidFromTable(MB_myRazorgoreRightTank)) or mb_targetFromSpecificPlayer("Blackwing Legionnaire", mb_returnPlayerInRaidFromTable(MB_myRazorgoreRightTank)) or mb_targetFromSpecificPlayer("Death Talon Dragonspawn", mb_returnPlayerInRaidFromTable(MB_myRazorgoreRightTank))))) then
		return true 
	end
end

function IsOrbControlled()
	for i = 1, GetNumRaidMembers() do
		if mb_hasBuffOrDebuff("Mind Exhaustion", "raid"..i, "debuff") then
			return true
		end
	end
	return false
end

function mb_isAtInstructorRazuvious() -- Mobs that are in the Razuvious encounter
	local tname = UnitName("target")

	if ((mb_tankTarget("Instructor Razuvious") or mb_tankTarget("Deathknight Understudy")) or (tname == "Instructor Razuvious" or tname == "Deathknight Understudy")) then
		return true 
	end
end

function mb_isAtSartura() -- Mobs that are in the Sartura encounter
	local tname = UnitName("target")

	if ((mb_tankTarget("Battleguard Sartura") or mb_tankTarget("Sartura\'s Royal Guard")) or (tname == "Battleguard Sartura" or tname == "Sartura\'s Royal Guard")) then
		return true 
	end
end

function mb_isAtNefarianPhase()
	local tname = UnitName("target")

	if ((mb_tankTarget("Red Drakonid") or mb_tankTarget("Blue Drakonid") or mb_tankTarget("Green Drakonid") or mb_tankTarget("Black Drakonid") or mb_tankTarget("Bronze Drakonid") or mb_tankTarget("Chromatic Drakonid") or mb_tankTarget("Lord Victor Nefarius")) or (tname == "Red Drakonid" or tname == "Blue Drakonid" or tname == "Green Drakonid" or tname == "Black Drakonid" or tname == "Bronze Drakonid" or tname == "Chromatic Drakonid" or tname == "Lord Victor Nefarius")) then
		return true
	end	
end

function mb_isAtSkeram() -- Mobs that are in the Sartura encounter
	local tname = UnitName("target")

	if (mb_tankTarget("The Prophet Skeram") or tname == "The Prophet Skeram") or (mb_targetFromSpecificPlayer("The Prophet Skeram", mb_returnPlayerInRaidFromTable(MB_mySkeramLeftTank)) or mb_targetFromSpecificPlayer("The Prophet Skeram", mb_returnPlayerInRaidFromTable(MB_mySkeramMiddleTank)) or mb_targetFromSpecificPlayer("The Prophet Skeram", mb_returnPlayerInRaidFromTable(MB_mySkeramRightTank))) then
		return true 
	end
end

function mb_isAtTwinsEmps()
	local tname = UnitName("target")

	if ((mb_tankTarget("Qiraji Scarab") or mb_tankTarget("Qiraji Scorpion")) or (tname == "Qiraji Scarab" or tname == "Qiraji Scorpion")) or 
		((mb_tankTarget("Emperor Vek\'lor") or mb_tankTarget("Emperor Vek\'nilash")) or (tname == "Emperor Vek\'lor" or tname == "Emperor Vek\'nilash")) then 
			return true
	end	
end

function mb_talentPointsIn(tab)
	points = 0

	for t = 1, GetNumTalents(tab) do
		n, ic, tier, c, EM = GetTalentInfo(tab, t)
		points = points + EM
		end
	return points
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
		local myspot = mb_findInTable(MB_followlist, name)
		if myspot > 1 then
			FollowByName(MB_followlist[myspot-1], 1)
		end
	else
		for g = 1, 8 do for i = 1, 5 do
			if name == MB_groups[g][i] and i > 1 then FollowByName(MB_groups[g][1], 1) end
		end end
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

function spairs(t, order)
	-- collect the keys
	local keys = {}
	local size

	for k in pairs(t) do size = TableLength(keys) keys[size + 1] = k end --if order function given, sort by it by passing the table and keys a, b, otherwise just sort the keys

		if order then
			table.sort(keys, function(a, b) return order(t, a, b) end)
		else
			table.sort(keys)
		end

		local i = 0
		return function() -- return the iterator function

		i = i + 1
		if keys[i] then return keys[i], t[keys[i]] end
	end
end

function TableLength(tab)
    if not tab then return 0 end
    local len = 0
    for _ in pairs(tab) do len = len + 1 end
    return len
end

function IncrementIndex(tab, len)
	if tab == len then return 1 end
	return tab + 1
end

function DecrementIndex(tab, len)
	if tab == 1 then return len end
	return tab-1
end

function table.invert(tbl)
	local rv = {}

	for key, val in pairs( tbl ) do rv[ val ] = key end
	return rv
end

function PrintTable(t)
	for k, v in pairs(t) do Print(k, v) end
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
-------------------------------------------- Group Order! --------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_myNameInTable(table)

	for k, name in pairs(table) do
		if myName == name then
			return true
		end
	end
end

-- /run Print(mb_returnPlayerInRaidFromTable(MB_myFankrissSnakeTankOne))
function mb_returnPlayerInRaidFromTable(table)

	for k, name in pairs(table) do
		if mb_isInRaid(name) then
			return name
		end
	end
end

function mb_myGroupOrder() --This sorts the number of toons in a given party in alphabetical order and returns a number representing which number in that list this toon is.

	local _, _, mygroup = GetRaidRosterInfo(RaidIdx(myName))
	local myparty = {}

	table.insert(myparty, myName)

	for i = 1, GetNumPartyMembers() do
		local name, _ =  UnitName("party"..i)
		table.insert(myparty, name)
	end

	table.sort(myparty)
	local order = 1

	for k, toon in pairs(myparty) do
		if toon == myName then return order end
		order = order + 1
	end
	return order
end

function RaidIdx(qname)
	return string.gsub(MBID[qname], "raid", "")
end

function mb_numberOfClassInParty(checkclass)
	local i = 0
	local MyGroup = MB_groupID[myName]

	if not MyGroup then return 0 end

	for _, name in MB_toonsInGroup[MyGroup] do
		if MBID[name] and UnitClass(MBID[name]) == checkclass then
			i = i + 1 
		end
	end
	return i
end

function mb_getNameFromPlayerClassInParty(checkclass)
	local MyGroup = MB_groupID[myName]

	if not MyGroup then return 0 end

	for _, name in MB_toonsInGroup[MyGroup] do
		if MBID[name] and UnitClass(MBID[name]) == checkclass then
			return name
		end
	end
end

function mb_myClassOrder() --This sorts the number of toons in a given class in MaxMana order (if mana user) or MaxHealth and returns a number representing which number in that list this toon is. CLASS MUST BE ALIVE AND CONNECTED.

	local myClasstoons = {}

	for name, id in MBID do
		class = UnitClass(id)
		if class == myClass and mb_isAlive(id) then
			if UnitPowerType(id) == 0 then myClasstoons[name] = UnitManaMax(id)
			else myClasstoons[name] = UnitHealthMax(id) end
		end
	end

	local order = 1

	for name, power in spairs(myClasstoons, function(t, a, b) return t[b] < t[a] end) do
		if name == myName then return order end
		order = order + 1
	end
	return 0
end

function mb_myInvertedClassOrder()

	local myClasstoons = {}

	for name, id in MBID do
		class = UnitClass(id)
		if class == myClass and mb_isAlive(id) then
			if UnitPowerType(id) == 0 then myClasstoons[name] = UnitManaMax(id)
			else myClasstoons[name] = UnitHealthMax(id) end
		end
	end

	local order = 1

	for name, power in spairs(myClasstoons, function(t, a, b) return t[b] > t[a] end) do
		if name == myName then return order end
		order = order + 1
	end
	return 0
end

function mb_myFireMageOrder()

	local myFiremages = {}

	for k, name in MB_fireMages do
		id = MBID[name]
		if id and mb_isAlive(id) then
			if UnitPowerType(id) == 0 then myFiremages[name] = UnitManaMax(id)
			else myFiremages[name] = UnitHealthMax(id) end
		end
	end

	local order = 1

	for name, power in spairs(myFiremages, function(t, a, b) return t[b] < t[a] end) do
		if name == myName then return order end
		order = order + 1
	end
	return 0
end

function mb_myFrostMageOrder() -- Small Mage 1st (cuz of 10% int talent)

	local myFiremages = {}

	for k, name in MB_fireMages do
		id = MBID[name]
		if id and mb_isAlive(id) then
			if UnitPowerType(id) == 0 then myFiremages[name] = UnitManaMax(id)
			else myFiremages[name] = UnitHealthMax(id) end
		end
	end

	local order = 1

	for name, power in spairs(myFiremages, function(t, a, b) return t[b] > t[a] end) do
		if name == myName then return order end
		order = order + 1
	end
	return 0
end

function mb_myGroupClassOrder()
	--This sorts the number of toons in a given class IN HIS GROUP in MaxMana order (if mana user) or MaxHealth and returns a number
	--representing which number in that list this toon is. CLASS MUST BE ALIVE AND CONNECTED.
	local myClasstoons = {}
	local name, realm =  UnitName("player")

	if UnitPowerType("player") == 0 then 
		myClasstoons[name] = UnitManaMax("player")
	else 
		myClasstoons[name] = UnitHealthMax("player") 
	end

	for i = 1, 4 do
		class = UnitClass("party"..i)
		local name, realm =  UnitName("party"..i)
		if class == myClass and mb_isAlive("party"..i) then
			if UnitPowerType("party"..i) == 0 then myClasstoons[name] = UnitManaMax("party"..i)
			else myClasstoons[name] = UnitHealthMax("party"..i) end
		end
	end

	local order = 1

	for name, power in spairs(myClasstoons, function(t, a, b) return t[b] < t[a] end) do
		if name == myName then return order end
		order = order + 1
	end
	return 0
end

function mb_myInvertedGroupClassOrder()
	--This sorts the number of toons in a given class IN HIS GROUP in MaxMana order (if mana user) or MaxHealth and returns a number
	--representing which number in that list this toon is. CLASS MUST BE ALIVE AND CONNECTED.
	local myClasstoons = {}
	local name, realm =  UnitName("player")

	if UnitPowerType("player") == 0 then 
		myClasstoons[name] = UnitManaMax("player")
	else 
		myClasstoons[name] = UnitHealthMax("player") 
	end

	for i = 1, 4 do
		class = UnitClass("party"..i)
		local name, realm =  UnitName("party"..i)
		if class == myClass and mb_isAlive("party"..i) then
			if UnitPowerType("party"..i) == 0 then myClasstoons[name] = UnitManaMax("party"..i)
			else myClasstoons[name] = UnitHealthMax("party"..i) end
		end
	end

	local order = 1

	for name, power in spairs(myClasstoons, function(t, a, b) return t[b] > t[a] end) do
		if name == myName then return order end
		order = order + 1
	end
	return 0
end

function mb_myClassAlphabeticalOrder()
	local myClasstoons = {}

	for name, id in MBID do
		class = UnitClass(id)
		if class == myClass and mb_isAlive(id) then
			table.insert(myClasstoons, name)
		end
	end

	local order = 1	
	table.sort(myClasstoons)

	for _, name in myClasstoons do
		if name == myName then return order end
		order = order + 1
	end
	return 0
end

function mb_myClassAlphabeticalOrderGivenClass(classTable)
	local myClasstoons = {}

	for name, id in classTable do
		class = UnitClass(id)
		if class == myClass and mb_isAlive(id) then
			table.insert(myClasstoons, name)
		end
	end

	local order = 1	
	table.sort(myClasstoons)

	for _, name in myClasstoons do
		if name == myName then return order end
		order = order + 1
	end
	return 0
end

function mb_partyHurt(hurt, num_party_hurt)
	local numhurt = 0
	local myhurt = mb_healthDown("player")

	if myhurt > hurt then 
		numhurt = numhurt + 1 
	end

    for i = 1, GetNumPartyMembers() do
        local guyshurt = UnitHealthMax("party"..i) - UnitHealth("party"..i)
        if guyshurt > hurt and mb_in28yardRange("party"..i) and not mb_dead("party"..i) then 
            numhurt = numhurt + 1 
        end
    end

	if numhurt >= num_party_hurt then 
		return numhurt 
	end
end

function mb_shamanPartyHurt(hurt, num_party_hurt)
    local numhurt = 0

    for i = 1, GetNumPartyMembers() do
        local guyshurt = UnitHealthMax("party"..i) - UnitHealth("party"..i)
        if guyshurt > hurt and mb_in28yardRange("party"..i) and not mb_dead("party"..i) then 
            numhurt = numhurt + 1 
        end
    end

    if numhurt >= num_party_hurt then 
        return numhurt
    end
end

------------------------------------------------------------------------------------------------------
-------------------------------------------- Spells Code! --------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_spellReady(spellName, rank)
    if not mb_knowSpell(spellName, rank) then
        return false
    end

    return mb_spellCooldown(spellName) == 0
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

function mb_spellCooldown(spellName)
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

function mb_spellExists(findspell)
	if not findspell then return end
		for i = 1, MAX_SKILLLINE_TABS do
			local name, texture, offset, numSpells = GetSpellTabInfo(i)
			if not name then break end
			for s = offset + 1, offset + numSpells do
			local	spell, rank = GetSpellName(s, BOOKTYPE_SPELL)
			if rank then
				local spell = spell.." "..rank
			end
			if string.find(spell, findspell, nil, true) then
				return true
			end
		end
	end
end

function mb_spellNumber(spell)
	--In the wonderful world of 1.12 programming, sometimes just using a spell name isn't enough.
	--SOMETIMES you need to know what spell NUMBER it is, cause otherwise it doesn't work.
	--Healthstones and feral spells are like this.
	local i = 1 ; highestmb_spellNumber = 0
	local spellName
	while true do
		spellName, spellRank = GetSpellName(i, BOOKTYPE_SPELL)
		if not spellName then
			do break end
		end
		if string.find(spellName, spell) then highestmb_spellNumber = i end
		i = i + 1
	end
	--Fs* returned the spellid of the last spell in the spellbook if the spell is not in the spellbook
	if highestmb_spellNumber == 0 then return end
	return highestmb_spellNumber
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

		mb_autoWandAttack() 
	end
end

function mb_imBusy()
	if MB_isCasting or MB_isChanneling then return true end
end

------------------------------------------------------------------------------------------------------
-------------------------------------------- Trinket Code! -------------------------------------------
------------------------------------------------------------------------------------------------------

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

function mb_trinketOnCD(id) --returns true if on CD, false if not on CD
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
	local _, _, itemname = string.find(link, "%[(.*)%]", 27)
	return itemname
end

function mb_returnEquippedItemType(id) --17 shield, 18 ranged mb_returnEquippedItemType(17) == "Shield" then x end
	local itemLink = GetInventoryItemLink("player", id)
	if not itemLink then return "Bow" end
	local bsnum = string.gsub(itemLink, ".-\124H([^\124]*)\124h.*", "%1")
	local itemName, itemNo, itemRarity, itemReqLevel, itemType, itemSubType, itemCount, itemEquipLoc, itemIcon = GetItemInfo(bsnum)
	_, _, itemSubType = string.find(itemSubType, "(.*)s")
	return(itemSubType)
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

------------------------------------------------------------------------------------------------------
---------------------------------------------- Bag Code! ---------------------------------------------
------------------------------------------------------------------------------------------------------

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
----------------------------------------- Trade Cooldown Code! ---------------------------------------
------------------------------------------------------------------------------------------------------

function mb_useTradeSkill(skillName)
	for i = 1, GetNumTradeSkills() do
		if GetTradeSkillInfo(i) == skillName then
			CloseTradeSkill()
			DoTradeSkill(i)
			break
		end
	end
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
		if not mb_findInTable(MB_raidTanks, guest) then
			table.insert(MB_raidTanks, guest)
		end
	end

	for _, dru in pairs(MB_classList["Druid"]) do
		if not mb_findInTable(MB_raidTanks, dru) then
			table.insert(MB_noneDruidTanks, dru)
		end
	end

	for _, mage in pairs(MB_classList["Mage"]) do
		if mb_findInTable(MB_raidAssist.Mage.FireMages, mage) then
			table.insert(MB_fireMages, mage)
		end
	end

	for _, mage in pairs(MB_classList["Mage"]) do
		if mb_findInTable(MB_raidAssist.Mage.FrostMages, mage) then
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

	if not MB_raidLeader and (TableLength(MBID) > 1) then Print("WARNING: You have not chosen a raid leader") end -- No RaidLeader Alert

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

	if not MB_raidLeader and (TableLength(MBID) > 1) then Print("WARNING: You have not chosen a raid leader") end -- No RaidLeader Alert

	if mb_dead("player") then return end -- Stop when ur dead

	if myClass == "Warrior" and mb_imTank() and MB_myOTTarget then -- Shoot when you are a warrior tank

		if mb_returnEquippedItemType(18) and mb_spellExists("Shoot "..mb_returnEquippedItemType(18)) then
			
			CastSpellByName("Shoot "..mb_returnEquippedItemType(18))
		end
	end
end

function mb_manualTaunt() -- Manual Taunt

	if not MB_raidLeader and (TableLength(MBID) > 1) then Print("WARNING: You have not chosen a raid leader") end -- No RaidLeader Alert

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

	if not MB_raidLeader and (TableLength(MBID) > 1) then Print("WARNING: You have not chosen a raid leader") end -- No RaidLeader Alert

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

	if not MB_raidLeader and (TableLength(MBID) > 1) then Print("WARNING: You have not chosen a raid leader") end -- No RaidLeader Alert

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

function mb_clearRaidTarget() -- Clear assings

	if not mb_iamFocus() then return end
	
	local id = GetRaidTargetIndex("target")

	if UnitInRaid("player") then
		SendAddonMessage(MB_RAID.."CLR_TARG", UnitName("player"), "RAID")
	else
		SendAddonMessage(MB_RAID.."CLR_TARG", UnitName("player"))
	end

	SetRaidTarget("target", 0)
end

function mb_setFocus() -- Set Focus
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

SLASH_RAIDSPAWN1 = '/spawn'
SlashCmdList['RAIDSPAWN'] = function(arg)
local xStart = -500
local yStart = -160
local xOffset = 65
local _G = getfenv(0)

	for i = 1, 8 do
		if not _G['RaidPullout'..(i)] then
			RaidPullout_GenerateGroupFrame(i)
		end
		if _G['RaidPullout'..(i)] then
			_G['RaidPullout'..(i)]:ClearAllPoints()
			if i < 5 then
				_G['RaidPullout'..(i)]:SetPoint("TOP", UIParent , "TOP", xStart + (i - 1) * xOffset, yStart)
			else
				_G['RaidPullout'..(i)]:SetPoint("TOP", UIParent , "TOP", xStart + (i - 5) * xOffset, yStart-190)
			end
		end
	end
end

SLASH_CREATEBINDS1 = "/createbinds"
SLASH_CREATEBINDS2 = "/mcb"

SlashCmdList["CREATEBINDS"] = function()
	
	mb_createBinds()
end

SLASH_DELETEMACRO1 = "/deletemacro"
SLASH_DELETEMACRO2 = "/mdm"

SlashCmdList["CREATEBINDS"] = function()
	
	mb_deleteMacros()
	mb_deleteSuperMacros()
end

SLASH_DISABLEADDON1 = "/disableaddon"
SLASH_DISABLEADDON2 = "/mda"

SlashCmdList["DISABLEADDON"] = function()
	
	mb_addonsDisableEnable()
end

------------------------------------------------------------------------------------------------------
------------------------------------------- Tarrgetting! ---------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_assistFocus() -- Assist the focus target

	if MB_raidLeader then
		if MB_raidLeader == myName then
			return true
		end

		local assistUnit = mb_GetUnitForPlayerName(MB_raidLeader)
		if assistUnit == nil then
			return true
		end

		if UnitIsUnit("target", assistUnit.."target") then
			return true
		end

		if UnitExists(assistUnit.."target") then
			TargetUnit(assistUnit.."target")
			return true
		else

			ClearTarget()
			return false
		end
	else

		AssistByName(MB_raidInviter, 1)
		RunLine("/w "..MB_raidInviter.." Press setFOCUS!")
	end
end

--[[ 
	4 Awesome functions I made

	- mb_targetFromSpecificPlayer, returns true if a player is targetting a certain mob
	- mb_assistSpecificTargetFromPlayer, checks who is targetting what then assist that target
	- mb_assistSpecificTargetFromPlayerInMeleeRange, checks who is targetting what and in meleerange then assist that target
	- mb_lockOnTarget, targets a target and never stops targetting it unless its dead
]]

function mb_targetFromSpecificPlayer(target, player) -- Find who is targetting what

	if MBID[player] and UnitName(MBID[player].."target") then
		if string.find(UnitName(MBID[player].."target"), target) then return true end
	end
	return false
end

function mb_assistSpecificTargetFromPlayer(target, player) -- Find who is targetting what and assisting it

	if mb_targetFromSpecificPlayer(target, player) then

		AssistByName(player)
		return true
	end
	return false
end

function mb_assistSpecificTargetFromPlayers(target, playerone, playertwo) -- Find who is targetting what and assisting it

	if mb_targetFromSpecificPlayer(target, playerone) then

		AssistByName(playerone)
		return true
	end
	if mb_targetFromSpecificPlayer(target, playertwo) then

		AssistByName(playertwo)
		return true
	end
	return false
end

function mb_assistSpecificTargetFromPlayerInMeleeRange(target, player) -- Find who is targetting what in melee range and assisting it

	if mb_targetFromSpecificPlayer(target, player) and CheckInteractDistance(MBID[player].."target", 3) then

		AssistByName(player)
		return true
	end
	return false
end

function mb_debugger(who, msg)

	if MB_raidAssist.Debugger.Active and myName == who then

		mb_message(msg, 20)
	end
end

function mb_lockOnTarget(target) -- Locks onto a target until its dead

	for i = 1,3 do
		if UnitName("target") == target and not mb_dead("target") then return true end
		TargetByName(target)
	end
	return false
end

function mb_getTarget() -- GetTarget Magic
		
	if (mb_isAtRazorgore() and (myName == mb_returnPlayerInRaidFromTable(MB_myRazorgoreORBtank))) and not mb_tankTarget("Razorgore the Untamed") then mb_orbControlling() return end -- Stop when your controlling the ORB

	if MB_myOTTarget then return end -- Offtanks do'nt need to get different targets, just focus OT

	if GetRealZoneText() == "Blackwing Lair" then -- BWL targetting 

		if GetSubZoneText() == "Dragonmaw Garrison" and MB_myRazorgoreBoxStrategy then -- Razorgore room

			if myName == mb_returnPlayerInRaidFromTable(MB_myRazorgoreORBtank) then return end -- Don't do shit when you are the fucking ORB tank

			if mb_isAtRazorgorePhase() then -- Tank is Controlling the orb
				
				if (myName == mb_returnPlayerInRaidFromTable(MB_myRazorgoreLeftTank) or myName == mb_returnPlayerInRaidFromTable(MB_myRazorgoreRightTank)) and MB_raidLeader ~= myName then --> Targetting for main tanks Razorgore fight to set focus

					MB_raidLeader = myName
				end

				if mb_iamFocus() and (myName == mb_returnPlayerInRaidFromTable(MB_myRazorgoreLeftTank) or myName == mb_returnPlayerInRaidFromTable(MB_myRazorgoreRightTank)) then --> Targetting for main tanks Razorgore fight

					if not MB_targetNearestDistanceChanged then
						
						SetCVar("targetNearestDistance", "15")
						MB_targetNearestDistanceChanged = true
					end

					if MB_razorgoreNewTargetBecauseTargetIsBehind.Active then
					
						TargetNearestEnemy()
						MB_razorgoreNewTargetBecauseTargetIsBehind.Active = false
						return
					end
					
					if (UnitName("target") == nil or mb_dead("target")) then
						
						TargetNearestEnemy()
						return
					end

					mb_coolDownPrint("Focussing Attacks on "..UnitName("target"), 30)
					return
				end		
			end
		end

	elseif GetRealZoneText() == "Ahn\'Qiraj" then -- Targetting for AQ40

		if mb_isAtSkeram() and MB_mySkeramBoxStrategyFollow then -- Skeram
			
			if mb_imTank() then
				
				-- My noob attempt to mark the clones or adds
				if UnitName("target") == "The Prophet Skeram" then

					if (mb_myNameInTable(MB_mySkeramLeftTank) or mb_myNameInTable(MB_mySkeramLeftOFFTANKS)) then

						if not GetRaidTargetIndex("target") then

							SetRaidTarget("target", 4)							
						end

					elseif (mb_myNameInTable(MB_mySkeramMiddleTank) or mb_myNameInTable(MB_mySkeramMiddleOFFTANKS)) then

						if not GetRaidTargetIndex("target") then

							SetRaidTarget("target", 1)
						end

					elseif (mb_myNameInTable(MB_mySkeramRightTank) or mb_myNameInTable(MB_mySkeramRightOFFTANKS)) then

						if not GetRaidTargetIndex("target") then

							SetRaidTarget("target", 6)							
						end
					end
				end
			end
		end
	end

	if mb_iamFocus() then -- If I'm focus then get a new target as soon as you killed ur current

		if not UnitName("target") or UnitIsDead("target") or not UnitIsEnemy("player", "target") and not (mb_isAtSartura() or mb_isAtTwinsEmps()) then 
			
			TargetNearestEnemy()
		end
		return
	end

	if GetRealZoneText() == "Naxxramas" then -- Targetting for Naxx

		if mb_isAtLoatheb() then

			AssistByName(MB_myLoathebMainTank)
			
		elseif mb_tankTarget("Gluth") and MB_myGluthBoxStrategy then

			if mb_imTank() then --> Tanks that are not focus, do add stuff
				
				if myName == MB_myGluthOTTank then -- My offtank that needs to taunt sometimes loses his target this locks him back on

					if mb_lockOnTarget("Gluth") then return end -- LockonBoss

					if not UnitName("target") or mb_dead("target") then mb_assistFocus() end
					return
				end
				
				mb_getTargetNotOnTank() -- Get target not on tanks
				return
			end
			
		elseif mb_isAtGrobbulus() and MB_myGrobbulusBoxStrategy then

			if mb_imTank() then --> Tanks that are not focus, do add stuff
						
				if myName == MB_myGrobbulusMainTank then -- My offtank that needs to tank boss

					if mb_lockOnTarget("Grobbulus") then return end -- LockonBoss

					if not UnitName("target") or mb_dead("target") then mb_assistFocus() end
					return
				end
				
				mb_getTargetNotOnTank() -- Get target not on tanks
				return

			elseif mb_imMeleeDPS() or mb_imRangedDPS() then -- All dps focus totem or assist

				if mb_tankTargetHealth() < 0.1 or (mb_tankTargetHealth() < 0.9 and mb_myNameInTable(MB_fireMages)) then
					mb_assistFocus()
					return 
				end

				if mb_assistSpecificTargetFromPlayer("Fallout Slime", MB_myGrobbulusSlimeTankOne) then 
					mb_debugger(MB_raidAssist.Debugger.Mage, "Casters assisting "..MB_myGrobbulusSlimeTankOne.." on Fallout Slime!") 
					return 
				end

				if mb_assistSpecificTargetFromPlayer("Fallout Slime", MB_myGrobbulusSlimeTankTwo) then 
					mb_debugger(MB_raidAssist.Debugger.Mage, "Casters assisting "..MB_myGrobbulusSlimeTankTwo.." on Fallout Slime!") 
					return 
				end

				if mb_assistSpecificTargetFromPlayer("Fallout Slime", MB_myGrobbulusFollowTarget) then 
					mb_debugger(MB_raidAssist.Debugger.Mage, "Casters assisting "..MB_myGrobbulusFollowTarget.." on Fallout Slime!") 
					return 
				end

				if mb_lockOnTarget("Grobbulus") then return end -- LockonBoss

				if not UnitName("target") or mb_dead("target") then mb_assistFocus() end
				return
			end

		elseif (mb_tankTarget("Instructor Razuvious") and mb_myNameInTable(MB_myRazuviousPriest)) and MB_myRazuviousBoxStrategy then
			
			return

		elseif (mb_tankTarget("Grand Widow Faerlina") and mb_myNameInTable(MB_myFaerlinaPriest)) and MB_myFaerlinaBoxStrategy then
			
			return

		elseif mb_tankTarget("Anub\'Rekhan") then -- Lighting Totem Code

			if mb_imTank() then -- Tanks

				mb_getTargetNotOnTank() -- Get Targets not on tanks
				return

			elseif mb_imMeleeDPS() or mb_imRangedDPS() then -- All dps focus totem or assist

				for i = 1, 2 do
					if UnitName("target") == "Crypt Guard" and not mb_dead("target") then return end
					TargetNearestEnemy()
				end

				if not UnitName("target") or mb_dead("target") then mb_assistFocus() end
				return
			end

		elseif mb_isAtMonstrosity() then -- Lighting Totem Code

			if mb_imTank() then -- Tanks
				
				mb_getTargetNotOnTank() -- Get Targets not on tanks
				return

			elseif mb_imMeleeDPS() or mb_imRangedDPS() then -- All dps focus totem or assist

				if mb_lockOnTarget("Lightning Totem") then return end -- LockonBoss
	
				if not UnitName("target") or mb_dead("target") then mb_assistFocus() end
				return
			end

		elseif mb_tankTarget("Plague Beast") then -- Plague Beast

			if mb_imTank() then -- Tanks
				
				mb_getTargetNotOnTank() -- Get Targets not on tanks
				return

			elseif mb_imMeleeDPS() then -- Melee dps, focus adds and change if targets if u you're is out of range

				if MB_targetWrongWayOrTooFar.Active then -- Switching
					
					TargetNearestEnemy()
					MB_targetWrongWayOrTooFar.Active = false
					return
				end

				for i = 1, 3 do -- Picking a target
					if UnitName("target") == "Mutated Grub" and not mb_dead("target") then return end
					if UnitName("target") == "Plagued Bat" and not mb_dead("target") then return end
					TargetNearestEnemy()
				end

				if not UnitName("target") or mb_dead("target") then mb_assistFocus() end
				return

			elseif mb_imRangedDPS() then -- Ranged dps focus down the Beast

				mb_assistFocus()
				return
			end
		end

	elseif GetRealZoneText() == "Ahn\'Qiraj" then -- Targetting for AQ40

		if mb_isAtSkeram() and MB_mySkeramBoxStrategyFollow then -- Skeram
			
			if (mb_myNameInTable(MB_mySkeramLeftTank) or mb_myNameInTable(MB_mySkeramMiddleTank) or mb_myNameInTable(MB_mySkeramRightTank)) then --> Targetting for main tanks Razorgore fight
								
				mb_getTargetNotOnTank() -- Get Targets not on tanks
				return

			elseif mb_imTank() then -- Tanks
				
				mb_getTargetNotOnTank() -- Get Targets not on tanks
				return

			elseif mb_imMeleeDPS() then -- Melee's focus down YOUR focus tank

				if mb_hasBuffOrDebuff("True Fulfillment", "target", "debuff") then ClearTarget() end -- Assist focus when MC'd target is still your target

				mb_assistFocus()
				return

			elseif mb_imRangedDPS() then --> Ranged dps assit on focus

				if mb_hasBuffOrDebuff("True Fulfillment", "target", "debuff") then ClearTarget() end -- Assist focus when MC'd target is still your target

				mb_assistFocus()
				return
			end
			return

		elseif mb_tankTarget("Fankriss the Unyielding") and MB_myFankrissBoxStrategy then -- Fankriss

			if mb_imTank() then --> Tanks that are not focus, do add stuff
				
				if mb_myNameInTable(MB_myFankrissOFFTANKS) then -- My offtank that needs to taunt sometimes loses his target this locks him back on

					if mb_lockOnTarget("Fankriss the Unyielding") then return end -- LockonBoss

					if not UnitName("target") or mb_dead("target") then mb_assistFocus() end
					return
				end
				
				mb_getTargetNotOnTank() -- Get target not on tanks
				return

			elseif mb_imMeleeDPS() and myClass == "Warrior" then --> Assist Boss

				if mb_lockOnTarget("Fankriss the Unyielding") then return end -- LockonBoss
	
				if not UnitName("target") or mb_dead("target") then mb_assistFocus() end
				return

			elseif mb_imMeleeDPS() and myClass == "Rogue" then --> Assist Boss, Switch to snakes in meleeRange

				if mb_assistSpecificTargetFromPlayerInMeleeRange("Spawn of Fankriss", mb_returnPlayerInRaidFromTable(MB_myFankrissSnakeTankOne)) then 
					mb_debugger(MB_raidAssist.Debugger.Rogue, "Rogues assisting "..mb_returnPlayerInRaidFromTable(MB_myFankrissSnakeTankOne).." on Spawn of Fankriss!") 
					return 
				end

				if mb_assistSpecificTargetFromPlayerInMeleeRange("Spawn of Fankriss", mb_returnPlayerInRaidFromTable(MB_myFankrissSnakeTankTwo)) then 
					mb_debugger(MB_raidAssist.Debugger.Rogue, "Rogues assisting "..mb_returnPlayerInRaidFromTable(MB_myFankrissSnakeTankTwo).." on Spawn of Fankriss!") 
					return 
				end

				if mb_lockOnTarget("Fankriss the Unyielding") then return end -- LockonBoss
	
				if not UnitName("target") or mb_dead("target") then mb_assistFocus() end
				return

			elseif mb_imRangedDPS() then --> Targetting those worms and assisting the worm tanks

				if mb_assistSpecificTargetFromPlayer("Spawn of Fankriss", mb_returnPlayerInRaidFromTable(MB_myFankrissSnakeTankOne)) then 
					mb_debugger(MB_raidAssist.Debugger.Mage, "Casters assisting "..mb_returnPlayerInRaidFromTable(MB_myFankrissSnakeTankOne).." on Spawn of Fankriss!") 
					return 
				end

				if mb_assistSpecificTargetFromPlayer("Spawn of Fankriss", mb_returnPlayerInRaidFromTable(MB_myFankrissSnakeTankTwo)) then 
					mb_debugger(MB_raidAssist.Debugger.Mage, "Casters assisting "..mb_returnPlayerInRaidFromTable(MB_myFankrissSnakeTankTwo).." on Spawn of Fankriss!") 
					return 
				end

				if mb_lockOnTarget("Fankriss the Unyielding") then return end -- LockonBoss

				if not UnitName("target") or mb_dead("target") then mb_assistFocus() end
				return

			elseif mb_imHealer() then -- Attempt to warstomp snakes if possible

				if mb_assistSpecificTargetFromPlayer("Spawn of Fankriss", mb_returnPlayerInRaidFromTable(MB_myFankrissSnakeTankOne)) then 
					mb_debugger(MB_raidAssist.Debugger.Mage, "Casters assisting "..mb_returnPlayerInRaidFromTable(MB_myFankrissSnakeTankOne).." on Spawn of Fankriss!") 
					return 
				end

				if mb_assistSpecificTargetFromPlayer("Spawn of Fankriss", mb_returnPlayerInRaidFromTable(MB_myFankrissSnakeTankTwo)) then 
					mb_debugger(MB_raidAssist.Debugger.Mage, "Casters assisting "..mb_returnPlayerInRaidFromTable(MB_myFankrissSnakeTankTwo).." on Spawn of Fankriss!") 
					return 
				end

				if mb_lockOnTarget("Fankriss the Unyielding") then return end -- LockonBoss

				if not UnitName("target") or mb_dead("target") then mb_assistFocus() end
				return
			end
			return
				
		elseif mb_tankTarget("Anubisath Defender") then

			if mb_imTank() then -- Tanks
				
				mb_getTargetNotOnTank() -- Get Targets not on tanks
				return

			elseif (mb_imMeleeDPS() or mb_imRangedDPS() or mb_imHealer()) then -- Ranged and Focus focus down the totems and shades

				for i = 1, 4 do
					if UnitName("target") == "Anubisath Swarmguard" and not mb_dead("target") then return end
					if UnitName("target") == "Anubisath Warrior" and not mb_dead("target") then return end
					TargetNearestEnemy()
				end

				if not UnitName("target") or mb_dead("target") then mb_assistFocus() end
				return
			end
		end

	elseif GetRealZoneText() == "Blackwing Lair" then -- BWL targetting 
		
		if GetSubZoneText() == "Dragonmaw Garrison" and MB_myRazorgoreBoxStrategy then -- Razorgore room
			
			if myName == mb_returnPlayerInRaidFromTable(MB_myRazorgoreORBtank) then return end -- Don't do shit when you are the fucking ORB tank

			if mb_isAtRazorgorePhase() then -- Tank is Controlling the orb

				if (myName == mb_returnPlayerInRaidFromTable(MB_myRazorgoreLeftTank) or myName == mb_returnPlayerInRaidFromTable(MB_myRazorgoreRightTank)) then --> Targetting for main tanks Razorgore fight
					
					if not MB_targetNearestDistanceChanged then
						
						SetCVar("targetNearestDistance", "15")
						MB_targetNearestDistanceChanged = true
					end

					if MB_razorgoreNewTargetBecauseTargetIsBehind.Active then
					
						TargetNearestEnemy()
						MB_razorgoreNewTargetBecauseTargetIsBehind.Active = false
						return
					end
					
					if (UnitName("target") == nil or mb_dead("target")) then
						
						TargetNearestEnemy()
						return
					end
					return

				elseif mb_imTank() then --> Targetting for OT tanks Razorgore fight
					
					if not MB_targetNearestDistanceChanged then
						
						SetCVar("targetNearestDistance", "10")
						MB_targetNearestDistanceChanged = true
					end

					if MB_razorgoreNewTargetBecauseTargetIsBehind.Active then
					
						TargetNearestEnemy()
						MB_razorgoreNewTargetBecauseTargetIsBehind.Active = false
						return
					end
					
					mb_getTargetNotOnTank() -- Get target not on tanks
					return

				elseif mb_imMeleeDPS() then -- Melee focus your assist tank

					if mb_myNameInTable(MB_myRazorgoreLeftDPSERS) then

						AssistByName(mb_returnPlayerInRaidFromTable(MB_myRazorgoreLeftTank))
						return
					end

					if mb_myNameInTable(MB_myRazorgoreRightDPSERS) then

						AssistByName(mb_returnPlayerInRaidFromTable(MB_myRazorgoreRightTank))
						return
					end
					return

				elseif mb_imRangedDPS() then --> Ranged dps targetting Razorgore

					if MB_razorgoreNewTargetBecauseTargetIsBehindOrOutOfRange.Active then -- Get a new target
						
						TargetNearestEnemy()
						MB_razorgoreNewTargetBecauseTargetIsBehindOrOutOfRange.Active = false
						return
					end

					if not mb_dead("target") then return end

					if mb_assistSpecificTargetFromPlayer("Blackwing Mage", mb_returnPlayerInRaidFromTable(MB_myRazorgoreRightTank)) then 
						mb_debugger(MB_raidAssist.Debugger.Mage, "All casters assisting "..mb_returnPlayerInRaidFromTable(MB_myRazorgoreRightTank)) 
						return 
					end

					if mb_assistSpecificTargetFromPlayer("Blackwing Mage", mb_returnPlayerInRaidFromTable(MB_myRazorgoreLeftTank)) then 
						mb_debugger(MB_raidAssist.Debugger.Mage, "All casters assisting "..mb_returnPlayerInRaidFromTable(MB_myRazorgoreLeftTank)) 
						return 
					end

					if mb_assistSpecificTargetFromPlayer("Blackwing Legionnaire", mb_returnPlayerInRaidFromTable(MB_myRazorgoreRightTank)) then 
						mb_debugger(MB_raidAssist.Debugger.Mage, "All casters assisting "..mb_returnPlayerInRaidFromTable(MB_myRazorgoreRightTank)) 
						return 
					end

					if mb_assistSpecificTargetFromPlayer("Blackwing Legionnaire", mb_returnPlayerInRaidFromTable(MB_myRazorgoreLeftTank)) then 
						mb_debugger(MB_raidAssist.Debugger.Mage, "All casters assisting "..mb_returnPlayerInRaidFromTable(MB_myRazorgoreLeftTank)) 
						return 
					end

					if mb_assistSpecificTargetFromPlayer("Death Talon Dragonspawn", mb_returnPlayerInRaidFromTable(MB_myRazorgoreRightTank)) then 
						mb_debugger(MB_raidAssist.Debugger.Mage, "All casters assisting "..mb_returnPlayerInRaidFromTable(MB_myRazorgoreRightTank)) 
						return 
					end

					if mb_assistSpecificTargetFromPlayer("Death Talon Dragonspawn", mb_returnPlayerInRaidFromTable(MB_myRazorgoreLeftTank)) then 
						mb_debugger(MB_raidAssist.Debugger.Mage, "All casters assisting "..mb_returnPlayerInRaidFromTable(MB_myRazorgoreLeftTank)) 
						return 
					end

					if not UnitName("target") or mb_dead("target") then mb_assistFocus() end
					return
				end
				return true				
			end

		elseif GetSubZoneText() == "Shadow Wing Lair" then -- Vael

			if MB_raidLeader and mb_dead(MBID[MB_raidLeader]) then mb_lockOnTarget("Vaelastrasz the Corrupt") return end
		end
		
	elseif GetRealZoneText() == "Molten Core" then

	elseif GetRealZoneText() == "Onyxia\'s Lair" then

		if mb_tankTarget("Onyxia") and MB_myOnyxiaBoxStrategy then

			if mb_imTank() then

				mb_getTargetNotOnTank()
				return

			elseif mb_imMeleeDPS() then

				if MB_targetWrongWayOrTooFar.Active then -- Switching
					
					TargetNearestEnemy()
					MB_targetWrongWayOrTooFar.Active = false
					return
				end

				for i = 1, 3 do -- Picking a target
					if UnitName("target") == "Onyxian Whelp" and not mb_dead("target") then return end
					TargetNearestEnemy()
				end

				if not UnitName("target") or mb_dead("target") then mb_assistFocus() end
				return

			elseif mb_imRangedDPS() then

				if mb_assistSpecificTargetFromPlayer("Onyxia", MB_myOnyxiaMainTank) then return end

				if not UnitName("target") or mb_dead("target") then mb_assistFocus() end
				return
			end
		end

	elseif GetRealZoneText() == "Zul\'Gurub" then --> ZG

		if mb_isAtJindo() then --> Jindo

			if mb_imTank() then -- Tanks
				
				mb_getTargetNotOnTank() -- Get Targets not on tanks
				return

			elseif mb_imMeleeDPS() then
				
				for i = 1, 4 do
					if UnitName("target") == "Shade of Jin\'do" and not mb_dead("target") then return end
					TargetNearestEnemy()
				end

				if not UnitName("target") or mb_dead("target") then mb_assistFocus() end
				return
				
			elseif mb_imRangedDPS() then -- Ranged and Focus focus down the totems and shades

				for i = 1, 4 do
					if UnitName("target") == "Shade of Jin\'do" and not mb_dead("target") then return end
					if UnitName("target") == "Powerful Healing Ward" and not mb_dead("target") then return end
					if UnitName("target") == "Brain Wash Totem" and not mb_dead("target") then return end
					TargetNearestEnemy()
				end

				if not UnitName("target") or mb_dead("target") then mb_assistFocus() end
				return
			end

		elseif mb_tankTarget("High Priestess Mar\'li") then -- Spider

			if mb_imTank() then -- Tanks
				
				mb_getTargetNotOnTank() -- Get Targets not on tanks
				return

			elseif mb_imMeleeDPS() then -- Melee focus on boss
				
				mb_assistFocus()
				return

			elseif mb_imRangedDPS() then -- Ranged focus the adds

				for i = 1,5 do
					if UnitName("target") == "Spawn of Mar\'li" and not mb_dead("target") then return end
					if UnitName("target") == "Witherbark Speaker" and not mb_dead("target") then return end
					TargetNearestEnemy()
				end

				if not UnitName("target") or mb_dead("target") then mb_assistFocus() end
				return
			end

		elseif mb_tankTarget("High Priestess Jeklik") then -- Bat

			if mb_imTank() then -- Tanks
				
				mb_getTargetNotOnTank() -- Get Targets not on tanks
				return

			elseif mb_imRangedDPS() then -- Melee and casters nuke bats

				for i = 1,5 do
					if UnitName("target") == "Bloodseeker Bat" and mb_inCombat("target") and not mb_dead("target") then return end
					TargetNearestEnemy()
				end

				if not UnitName("target") or mb_dead("target") then mb_assistFocus() end
				return
			end

		elseif mb_tankTarget("High Priest Venoxis") then -- Snake boss

			if mb_imTank() then -- Tanks
				
				mb_getTargetNotOnTank() -- Get Targets not on tanks
				return

			elseif mb_imMeleeDPS() or mb_imRangedDPS() then  -- Melee and casters nuke snakes

				for i = 1,5 do
					if UnitName("target") == "Razzashi Cobra" and not mb_dead("target") and not GetRaidTargetIndex("target") then return end
					TargetNearestEnemy()
				end

				if not UnitName("target") or mb_dead("target") then mb_assistFocus() end
				return
			end
		end
					
	elseif GetRealZoneText() == "Ruins of Ahn\'Qiraj" then

		if mb_tankTarget("Ayamiss the Hunter") and not mb_dead("target") then -- Ayamiss

			if mb_imTank() then -- Tanks
				
				mb_getTargetNotOnTank() -- Get Targets not on tanks
				return

			elseif mb_imMeleeDPS() or mb_imRangedDPS() then -- Melee and casters nuke the larva

				for i = 1,5 do
					if UnitName("target") == "Hive\'Zara Larva" and not mb_dead("target") then return end
					TargetNearestEnemy()
				end

				if not UnitName("target") or mb_dead("target") then mb_assistFocus() end
				return
			end
		end
		
	elseif GetRealZoneText() == "Blackrock Spire" then

		if mb_tankTarget("Lord Valthalak") and not mb_dead("target") then -- Valthalak

			if mb_imTank() then -- Tanks
				
				mb_getTargetNotOnTank() -- Get Targets not on tanks
				return

			elseif mb_imMeleeDPS() or mb_imRangedDPS() then -- Melee and casters focus the adds

				for i = 1,5 do
					if UnitName("target") == "Spectral Assassin" and not mb_dead("target") then return end
					TargetNearestEnemy()
				end

				if not UnitName("target") or mb_dead("target") then mb_assistFocus() end
				return
			end
		end
	end

	local focid = MBID[MB_raidLeader]
	if not focid then

		mb_assistFocus()

	elseif UnitName(focid.."target") then
		
		TargetUnit(focid.."target")

	else
		if not UnitIsEnemy("player","target") then
			TargetNearestEnemy()
		end
	end

	if mb_imTank() and not MB_myOTTarget then

		mb_getTargetNotOnTank()
		return
	end

	if MB_myInterruptTarget then

		mb_getMyInterruptTarget()
		return
	end

	if not MB_myOTTarget then
		mb_assistFocus()
	end
end

function mb_getTargetNotOnTank()

	if mb_dead("player") then return end

	if (UnitName("target") == "Deathknight Understudy" or UnitName("target") == "Hakkar" or UnitName("target") == "Fallout Slime" or UnitName("target") == "Spawn of Fankriss") then return end

	if mb_isNotValidTankableTarget() then

		TargetNearestEnemy()
	end

	if UnitIsEnemy("target", "player") and mb_inCombat("target") and not mb_findInTable(MB_raidTanks, UnitName("targettarget")) then return end

	for i = 0, 8 do
		if not UnitName("target") then 
			
			TargetNearestEnemy() 
		end

		if UnitIsEnemy("target", "player") and mb_inCombat("target") and not mb_findInTable(MB_raidTanks, UnitName("targettarget")) then return end

		TargetNearestEnemy()
	end
end

function mb_healerJindoRotation(spellName)
	if GetRealZoneText() == "Zul\'Gurub" then
		if mb_hasBuffOrDebuff("Delusions of Jin\'do", "player", "debuff") then

			if UnitName("target") == "Shade of Jin\'do" and not mb_dead("target") then

				CastSpellByName(spellName)
			end
			return true
		end
	end
	return false
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

------------------------------------------------------------------------------------------------------
---------------------------------- Assigning, Fears, Sheeps, Tanks, Int! -----------------------------
------------------------------------------------------------------------------------------------------

function mb_crowdControlAsPull() -- CrowdControl on the pull

	if IsAltKeyDown() then -- Alt key shield main tanks
		
		mb_powerwordShield_tanks()
		return
	end

	if IsShiftKeyDown() then -- Shift key shield random

		if mb_spellReady("Power Word: Shield") then
			
			mb_castShieldOnRandomRaidMember("Weakened Soul", "rank 10")
		end
		return
	end

	mb_crowdControl()
end

function mb_crowdControl() -- CC

	if myClass == "Druid" and UnitName("target") == "Death Talon Wyrmkin" and GetRaidTargetIndex("target") == MB_myCCTarget then -- Druid Lock

		CastSpellByName("Hibernate(rank 1)")
		return true
	end

	if myClass == "Druid" and mb_mobsToRoot() and GetRaidTargetIndex("target") == MB_myCCTarget then -- Druid Root lock

		CastSpellByName("Entangling Roots(rank 1)")
		return true
	end

	if not MB_myCCTarget then -- Fearing

		mb_crowdControlFear() 
		return false
	end

	for i = 1, 10 do
		if GetRaidTargetIndex("target") == MB_myCCTarget and not UnitIsDead("target") and not mb_hasBuffOrDebuff(MB_myCCSpell[myClass], "target", "debuff") then

			mb_coolDownPrint("CC spell is: "..MB_myCCSpell[myClass])

			mb_message(MB_myCCSpell[myClass].."ing "..UnitName("target"))
			CastSpellByName(MB_myCCSpell[myClass])
			return true
		end

		if GetRaidTargetIndex("target") == MB_myCCTarget and not UnitIsDead("target") and mb_hasBuffOrDebuff(MB_myCCSpell[myClass], "target", "debuff") then
			return false
		end

		if GetRaidTargetIndex("target") == MB_myCCTarget and UnitIsDead("target") then
			MB_myCCTarget = nil
			return false
		end

		TargetNearestEnemy()
	end
	return false
end

function mb_assignCrowdControl() -- Assigning code

	if not mb_iamFocus() then return end -- Only focus allowed here

	if IsShiftKeyDown() then mb_assignFear() return end -- Shift key for fears

	if IsAltKeyDown() then -- Alt key for druid CC on beasts

		if UnitCreatureType("target") == "Beast" then

			if not GetRaidTargetIndex("target") or GetRaidTargetIndex("target") == 0 then
				SetRaidTarget("target", MB_currentRaidTarget)
				if MB_currentRaidTarget == 8 then MB_currentRaidTarget = 1 else MB_currentRaidTarget = MB_currentRaidTarget + 1 end
			end

			local num_druids = TableLength(MB_noneDruidTanks)

			if num_druids > 0 then
				if UnitInRaid("player") then
					SendAddonMessage(MB_RAID.."_CC", MB_noneDruidTanks[MB_currentCC.Druid], "RAID")
				else
					SendAddonMessage(MB_RAID.."_CC", MB_noneDruidTanks[MB_currentCC.Druid])
				end
			end

			if MB_currentCC.Druid == num_druids then
				MB_currentCC.Druid = 1
				mb_message("ALL DRUIDS ASSIGNED, STOP ASSIGNING MORE.")
			else
				MB_currentCC.Druid = MB_currentCC.Druid + 1
			end
		end
		return
	end

	if mb_mobsToRoot() then -- Mobs that can be rooted go in here

		if not GetRaidTargetIndex("target") or GetRaidTargetIndex("target") == 0 then
			SetRaidTarget("target", MB_currentRaidTarget)
			if MB_currentRaidTarget == 8 then MB_currentRaidTarget = 1 else MB_currentRaidTarget = MB_currentRaidTarget + 1 end
		end

		local num_druids = TableLength(MB_noneDruidTanks)

		if num_druids > 0 then
			if UnitInRaid("player") then
				SendAddonMessage(MB_RAID.."_CC", MB_noneDruidTanks[MB_currentCC.Druid], "RAID")
			else
				SendAddonMessage(MB_RAID.."_CC", MB_noneDruidTanks[MB_currentCC.Druid])
			end
		end

		if MB_currentCC.Druid == num_druids then
			MB_currentCC.Druid = 1
			mb_message("ALL DRUIDS ASSIGNED, STOP ASSIGNING MORE.")
		else
			MB_currentCC.Druid = MB_currentCC.Druid + 1
		end

	elseif UnitCreatureType("target") == "Demon" or UnitCreatureType("target") == "Elemental" then -- Warlock

		if not GetRaidTargetIndex("target") or GetRaidTargetIndex("target") == 0 then

			SetRaidTarget("target", MB_currentRaidTarget)
			if MB_currentRaidTarget == 8 then MB_currentRaidTarget = 1 else MB_currentRaidTarget = MB_currentRaidTarget + 1 end
		end

		local num_locks = TableLength(MB_classList["Warlock"])

		if num_locks > 0 then

			if UnitInRaid("player") then
				SendAddonMessage(MB_RAID.."_CC", MB_classList["Warlock"][MB_currentCC.Warlock], "RAID")
			else
				SendAddonMessage(MB_RAID.."_CC", MB_classList["Warlock"][MB_currentCC.Warlock])
			end

			if MB_currentCC.Warlock == num_locks then
				MB_currentCC.Warlock = 1
				mb_message("ALL WARLOCKS ASSIGNED, STOP ASSIGNING MORE.")
			else
				MB_currentCC.Warlock = MB_currentCC.Warlock + 1
			end
		end

	elseif UnitCreatureType("target") == "Undead" then -- Priests

		if not GetRaidTargetIndex("target") or GetRaidTargetIndex("target") == 0 then
			SetRaidTarget("target", MB_currentRaidTarget)
			if MB_currentRaidTarget == 8 then MB_currentRaidTarget = 1 else MB_currentRaidTarget = MB_currentRaidTarget + 1 end
		end

		local num_priests = TableLength(MB_classList["Priest"])

		if num_priests > 0 then

			if UnitInRaid("player") then
				SendAddonMessage(MB_RAID.."_CC", MB_classList["Priest"][MB_currentCC.Priest], "RAID")
			else
				SendAddonMessage(MB_RAID.."_CC", MB_classList["Priest"][MB_currentCC.Priest])
			end

			if MB_currentCC.Priest == num_priests then
				MB_currentCC.Priest = 1
				mb_message("ALL PRIESTS ASSIGNED, STOP ASSIGNING MORE.")
			else
				MB_currentCC.Priest = MB_currentCC.Priest + 1
			end
		end

	elseif UnitCreatureType("target") == "Dragonkin" then -- Druids

		if not GetRaidTargetIndex("target") or GetRaidTargetIndex("target") == 0 then
			SetRaidTarget("target", MB_currentRaidTarget)
			if MB_currentRaidTarget == 8 then MB_currentRaidTarget = 1 else MB_currentRaidTarget = MB_currentRaidTarget + 1 end
		end

		local num_druids = TableLength(MB_noneDruidTanks)

		if num_druids > 0 then
			if UnitInRaid("player") then
				SendAddonMessage(MB_RAID.."_CC", MB_noneDruidTanks[MB_currentCC.Druid], "RAID")
			else
				SendAddonMessage(MB_RAID.."_CC", MB_noneDruidTanks[MB_currentCC.Druid])
			end
		end

		if MB_currentCC.Druid == num_druids then
			MB_currentCC.Druid = 1
			mb_message("ALL DRUIDS ASSIGNED, STOP ASSIGNING MORE.")
		else
			MB_currentCC.Druid = MB_currentCC.Druid + 1
		end

	elseif nil or UnitCreatureType("target") == "Beast" or UnitCreatureType("target") == "Humanoid" or UnitCreatureType("target") == "Critter" then -- Mages

		if not GetRaidTargetIndex("target") or GetRaidTargetIndex("target") == 0 then
			SetRaidTarget("target", MB_currentRaidTarget)
			if MB_currentRaidTarget == 8 then MB_currentRaidTarget = 1 else MB_currentRaidTarget = MB_currentRaidTarget + 1 end
		end

		local num_mages = TableLength(MB_classList["Mage"])

		if num_mages > 0 then

			if UnitInRaid("player") then
				SendAddonMessage(MB_RAID.."_CC", MB_classList["Mage"][MB_currentCC.Mage], "RAID")
			else
				SendAddonMessage(MB_RAID.."_CC", MB_classList["Mage"][MB_currentCC.Mage])
			end

			if MB_currentCC.Mage == num_mages then
				MB_currentCC.Mage = 1
				mb_message("ALL MAGES ASSIGNED, STOP ASSIGNING MORE.")
			else
				MB_currentCC.Mage = MB_currentCC.Mage + 1
			end
		end
	end
end

function mb_crowdControlFear() -- Fear CC

	if not MB_myFearTarget then return end

	for i = 1, 10 do
		if GetRaidTargetIndex("target") == MB_myFearTarget and not UnitIsDead("target") then

			if UnitName("target") and not mb_hasBuffOrDebuff(MB_myFearSpell[UnitClass("player")], "target", "debuff") then

				Print("CC spell is : "..MB_myFearSpell[UnitClass("player")])

				mb_message("Fearing "..UnitName("target"))
				CastSpellByName(MB_myFearSpell[UnitClass("player")])

				TargetUnit("playertarget")
				return
			end
		end

		if GetRaidTargetIndex("target") == MB_myFearTarget and UnitIsDead("target") then

			MB_myFearTarget = nil
			TargetUnit("playertarget")
			return
		end

		TargetNearestEnemy()
	end
end

function mb_assignFear() -- Assign Fear

	if not mb_iamFocus() then return end

	if not GetRaidTargetIndex("target") or GetRaidTargetIndex("target") == 0 then
		SetRaidTarget("target", MB_currentRaidTarget)
		if MB_currentRaidTarget == 8 then MB_currentRaidTarget = 1 else MB_currentRaidTarget = MB_currentRaidTarget + 1 end
	end

	num_locks = TableLength(MB_classList["Warlock"])

	if num_locks > 0 then

		if UnitInRaid("player") then 
			SendAddonMessage(MB_RAID.."_FEAR", MB_classList["Warlock"][MB_currentFear.Warlock], "RAID")
		else
			SendAddonMessage(MB_RAID.."_FEAR", MB_classList["Warlock"][MB_currentFear.Warlock])
		end

		if MB_currentFear.Warlock == num_locks then 
			MB_currentFear.Warlock = 1
		else
			MB_currentFear.Warlock = MB_currentFear.Warlock + 1
		end
	end
end

function mb_assignOffTank() -- Assign offtanks

	if IsShiftKeyDown() then 
		
		mb_assignInterrupt() 
		return 
	end

	if not mb_iamFocus() or TableLength(MB_offTanks) == 0 then return end

	if not GetRaidTargetIndex("target") or GetRaidTargetIndex("target") == 0 then

		SetRaidTarget("target", MB_currentRaidTarget)
		local thistargidx = MB_currentRaidTarget
		if MB_currentRaidTarget == 8 then MB_currentRaidTarget = 1 else MB_currentRaidTarget = MB_currentRaidTarget + 1 end
	else

		local thistargidx = GetRaidTargetIndex("target")
	end

	--Hold SHIFT to assign a second ( and third, etc. ) target to the tank!
	local thisot

	if IsShiftKeyDown() then

		local temp = DecrementIndex(MB_Ot_Index, TableLength(MB_offTanks))
		thisot = MB_offTanks[temp]
	else

		thisot = MB_offTanks[MB_Ot_Index]
	end

	if UnitInRaid("player") then
		SendAddonMessage(MB_RAID.."_OT", thisot, "RAID")
	else
		SendAddonMessage(MB_RAID.."_OT", thisot)
	end

	if not IsShiftKeyDown() then 
		MB_Ot_Index = IncrementIndex(MB_Ot_Index, TableLength(MB_offTanks))
	end
end

function mb_assignInterrupt() -- Assign Kicks

	if not mb_iamFocus() then return end

	if not GetRaidTargetIndex("target") or GetRaidTargetIndex("target") == 0 then
		SetRaidTarget("target", MB_currentRaidTarget)
		if MB_currentRaidTarget == 8 then MB_currentRaidTarget = 1 else MB_currentRaidTarget = MB_currentRaidTarget + 1 end
	end

	num_shaman = TableLength(MB_classList["Shaman"])
	num_rogues = TableLength(MB_classList["Rogue"])
	num_mages = TableLength(MB_classList["Mage"])
	num_interrupters = TableLength(MB_classList["Rogue"])
	num_interrupters = num_interrupters + TableLength(MB_classList["Shaman"])
	num_interrupters = num_interrupters + TableLength(MB_classList["Mage"])

	if num_interrupters == 0 then return end
	
	if num_rogues > 0 then

		if UnitInRaid("player") then
			SendAddonMessage(MB_RAID.."_INT", MB_classList["Rogue"][MB_currentInterrupt.Rogue], "RAID")
		else
			SendAddonMessage(MB_RAID.."_INT", MB_classList["Rogue"][MB_currentInterrupt.Rogue])
		end

		if MB_currentInterrupt.Rogue == num_rogues then
			MB_currentInterrupt.Rogue = 1
		else
			MB_currentInterrupt.Rogue = MB_currentInterrupt.Rogue + 1
		end
	end

	if UnitName("target") == "Naxxramas Acolyte" then

		if num_mages > 0 then
			if UnitInRaid("player") then
				SendAddonMessage(MB_RAID.."_INT", MB_classList["Mage"][MB_currentInterrupt.Mage], "RAID")
			else
				SendAddonMessage(MB_RAID.."_INT", MB_classList["Mage"][MB_currentInterrupt.Mage])
			end

			if MB_currentInterrupt.Mage == num_mages then
				MB_currentInterrupt.Mage = 1
			else
				MB_currentInterrupt.Mage = MB_currentInterrupt.Mage + 1
			end
		end
	else

		if num_shaman > 0 then

			if UnitInRaid("player") then
				SendAddonMessage(MB_RAID.."_INT", MB_classList["Shaman"][MB_currentInterrupt.Shaman], "RAID")
			else
				SendAddonMessage(MB_RAID.."_INT", MB_classList["Shaman"][MB_currentInterrupt.Shaman])
			end

			if MB_currentInterrupt.Shaman == num_shaman then
				MB_currentInterrupt.Shaman = 1
			else
				MB_currentInterrupt.Shaman = MB_currentInterrupt.Shaman + 1
			end
		end
	end

	if num_shaman == 0 and num_rogues == 0 then

		if num_mages > 0 then
			if UnitInRaid("player") then
				SendAddonMessage(MB_RAID.."_INT", MB_classList["Mage"][MB_currentInterrupt.Mage], "RAID")
			else
				SendAddonMessage(MB_RAID.."_INT", MB_classList["Mage"][MB_currentInterrupt.Mage])
			end

			if MB_currentInterrupt.Mage == num_mages then
				MB_currentInterrupt.Mage = 1
			else
				MB_currentInterrupt.Mage = MB_currentInterrupt.Mage + 1
			end
		end
	end
end

function mb_autoAssignBanishOnMoam() -- Auto CC Moam

	if mb_iamFocus() and (UnitName("target") == "Moam" or UnitName("target") == "Mana Fiend") then

		for i = 1, 5 do

			if UnitName("target") == "Mana Fiend" and not GetRaidTargetIndex("target") and not UnitIsDead("target") then 
				mb_assignCrowdControl() 
				return 
			end

			TargetNearestEnemy()
		end

		if not MB_moamdead then RunLine("/target Moam") end

		if UnitIsDead("target") and UnitName("target") == "Moam" then 
			MB_moamdead = true
		end
	end
end

function mb_crowdControlMCedRaidMemberHakkar() -- CC Hakker MC'd target
	if mb_dead("player") then return end

	for i = 1, GetNumRaidMembers() do				
		if UnitName("raid"..i) and mb_isAlive("raid"..i) then

			if mb_hasBuffOrDebuff("Mind Control", "raid"..i, "debuff") and not mb_hasBuffOrDebuff("Polymorph", "raid"..i, "debuff") then
				
				TargetUnit("raid"..i)

				if not MB_isCastingMyCCSpell then
					
					SpellStopCasting()
				end

				CastSpellByName("Polymorph")
				return true
			end
		end
	end
	return false
end

function mb_crowdControlMCedRaidMemberSkeram() -- CC Skeram MC'd target
	if mb_dead("player") then return end

	for i = 1, GetNumRaidMembers() do				
		if UnitName("raid"..i) and mb_isAlive("raid"..i) then
			
			if mb_hasBuffOrDebuff("True Fulfillment", "raid"..i, "debuff") and not mb_hasBuffOrDebuff("Polymorph", "raid"..i, "debuff") then
				
				TargetUnit("raid"..i)

				if not MB_isCastingMyCCSpell then
					
					SpellStopCasting()
				end

				CastSpellByName("Polymorph")
				return true
			end
		end
	end
	return false
end

function mb_crowdControlMCedRaidMemberSkeramFear() -- CC Hakker MC'd target
	if mb_dead("player") then return end

	for i = 1, GetNumRaidMembers() do				
		if UnitName("raid"..i) and mb_isAlive("raid"..i) then
			
			if mb_hasBuffOrDebuff("True Fulfillment", "raid"..i, "debuff") and not mb_hasBuffOrDebuff("Polymorph", "raid"..i, "debuff") and not mb_hasBuffOrDebuff("Fear", "raid"..i, "debuff") then
				
				TargetUnit("raid"..i)

				if not MB_isCastingMyCCSpell then
					
					SpellStopCasting()
				end

				CastSpellByName("Fear")
				return true
			end
		end
	end
	return false
end

function mb_crowdControlMCedRaidMemberSkeramAOE() -- Fear Skeram MC'd target
	if mb_dead("player") then return end

	for i = 1, GetNumRaidMembers() do				
		if UnitName("raid"..i) and mb_isAlive("raid"..i) then
			
			if mb_hasBuffOrDebuff("True Fulfillment", "raid"..i, "debuff") and not mb_hasBuffOrDebuff("Polymorph", "raid"..i, "debuff") and not mb_hasBuffOrDebuff("Psychic Scream", "raid"..i, "debuff") and not mb_hasBuffOrDebuff("Fear", "raid"..i, "debuff") and CheckInteractDistance("raid"..i, 3 ) and mb_spellReady("Psychic Scream") then

				if mb_imBusy() then

					SpellStopCasting()
				end
				
				CastSpellByName("Psychic Scream")
				return true
			end
		end
	end
	return false
end

function mb_crowdControlMCedRaidMemberNefarian() -- Nefarian MC'd target
	if mb_dead("player") then return end

	for i = 1, GetNumRaidMembers() do				
		if UnitName("raid"..i) and mb_isAlive("raid"..i) and mb_in28yardRange("raid"..i) then
			
			if mb_hasBuffOrDebuff("Shadow Command", "raid"..i, "debuff") and not mb_hasBuffOrDebuff("Polymorph", "raid"..i, "debuff") then
				
				TargetUnit("raid"..i)

				if not MB_isCastingMyCCSpell then
					
					SpellStopCasting()					
				end

				CastSpellByName("Polymorph")
				mb_message("Sheeping "..UnitName("raid"..i), 30)
				return true
			end
		end
	end
	return false
end

function mb_offTank() -- Offtank

	if not MB_myOTTarget then return end

	if UnitExists("target") and GetRaidTargetIndex("target") and GetRaidTargetIndex("target") == MB_myOTTarget then -- Give it a message
		
		if mb_dead("target") then

			MB_myOTTarget = nil
			TargetUnit("playertarget")
			return
		end

		mb_coolDownPrint("Locked On Target")
		return
	end

	for i = 1, 6 do

		if UnitExists("target") and GetRaidTargetIndex("target") and GetRaidTargetIndex("target") == MB_myOTTarget and not UnitIsDead("target") and not mb_inCombat("target") then return end

		TargetNearestEnemy()
	end
end

function mb_getMyInterruptTarget() -- Get your int target (just tabbing untill match :P)

	if not MB_myInterruptTarget then mb_assistFocus() return end

	for i = 1, 6 do
		if GetRaidTargetIndex("target") == MB_myInterruptTarget and not mb_dead("target") then return end

		if GetRaidTargetIndex("target") == MB_myInterruptTarget and mb_dead("target") then
			
			TargetNearestEnemy()
		end

		TargetNearestEnemy()
	end
end

------------------------------------------------------------------------------------------------------
----------------------------------------------- Follow! ----------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_followFocus() -- Follow focus

	if (mb_hasBuffOrDebuff("Plague", "player", "debuff") and mb_tankTarget("Anubisath Defender")) then return end

	if mb_tankTarget("Baron Geddon") and mb_myNameInTable(MB_raidAssist.GTFO.Baron) then return end

	if mb_tankTarget("Onyxia") and myName == MB_myOnyxiaMainTank then return end

	if myClass == "Warlock" and mb_hasBuffOrDebuff("Hellfire", "player", "buff") then -- Stop warlocks form Hellfire

		CastSpellByName("Life Tap(Rank 1)")
	end

	if mb_iamFocus() then return end

	if MB_raidLeader then
		
		FollowByName(MB_raidLeader, 1)
		SetView(5) 
	end
end

function mb_casterFollow() -- Caster follow
	
	if (mb_hasBuffOrDebuff("Plague", "player", "debuff") and mb_tankTarget("Anubisath Defender")) then return end

	if mb_tankTarget("Baron Geddon") and mb_myNameInTable(MB_raidAssist.GTFO.Baron) then return end

	if myClass == "Warlock" and mb_hasBuffOrDebuff("Hellfire", "player", "buff") then -- Stop warlocks form Hellfire

		CastSpellByName("Life Tap(Rank 1)")
	end

	if mb_iamFocus() then return end

	if mb_imRangedDPS() then

		mb_followFocus()
	end
end

function mb_meleeFollow() -- Melee follow
	
	if (mb_hasBuffOrDebuff("Plague", "player", "debuff") and mb_tankTarget("Anubisath Defender")) then return end

	if mb_hasBuffOrDebuff("Fungal Bloom", "player", "debuff") and MBID[MB_myLoathebMainTank] and CheckInteractDistance(MBID[MB_myLoathebMainTank].."target", 3) then return end

	if mb_tankTarget("Baron Geddon") and mb_myNameInTable(MB_raidAssist.GTFO.Baron) then return end

	if mb_iamFocus() then return end

	if GetRealZoneText() == "Ahn\'Qiraj" then -- Skeram follow

		if mb_isAtSkeram() and MB_mySkeramBoxStrategyFollow then
			
			if mb_myNameInTable(MB_mySkeramLeftTank) then return end
			if mb_myNameInTable(MB_mySkeramMiddleTank) then return end
			if mb_myNameInTable(MB_mySkeramRightTank) then return end
		
			if mb_myNameInTable(MB_mySkeramLeftOFFTANKS) then

				FollowByName(mb_returnPlayerInRaidFromTable(MB_mySkeramLeftTank), 1)
				return
			end

			if mb_myNameInTable(MB_mySkeramMiddleOFFTANKS) then

				FollowByName(mb_returnPlayerInRaidFromTable(MB_mySkeramMiddleTank), 1)
				return
			end

			if mb_myNameInTable(MB_mySkeramMiddleDPSERS) then

				FollowByName(mb_returnPlayerInRaidFromTable(MB_mySkeramMiddleTank), 1)
				return
			end

			if mb_myNameInTable(MB_mySkeramRightOFFTANKS) then

				FollowByName(mb_returnPlayerInRaidFromTable(MB_mySkeramRightTank), 1)
				return
			end
			return
		end

	elseif GetRealZoneText() == "Blackwing Lair" then
		
		if (GetSubZoneText() == "Dragonmaw Garrison" and mb_isAtRazorgorePhase()) and MB_myRazorgoreBoxStrategy then
			
			if myName == mb_returnPlayerInRaidFromTable(MB_myRazorgoreLeftTank) then return end
			if myName == mb_returnPlayerInRaidFromTable(MB_myRazorgoreRightTank) then return end
				
			if mb_myNameInTable(MB_myRazorgoreLeftDPSERS) then

				FollowByName(mb_returnPlayerInRaidFromTable(MB_myRazorgoreLeftTank), 1)
				return
			end
	
			if mb_myNameInTable(MB_myRazorgoreRightDPSERS) then
	
				FollowByName(mb_returnPlayerInRaidFromTable(MB_myRazorgoreRightTank), 1)
				return
			end			
			return
		end
	end

	if mb_imMeleeDPS() then		
		
		mb_followFocus()
	end

	if mb_imTank() and not MB_myOTTarget and not (mb_tankTarget("Instructor Razuvious") or mb_tankTarget("Razorgore the Untamed") or mb_tankTarget("Chromaggus") or mb_isAtTwinsEmps()) then
		
		mb_followFocus()
	end
end

function mb_tankFollow() -- Tanks only follow
	
	if (mb_hasBuffOrDebuff("Plague", "player", "debuff") and mb_tankTarget("Anubisath Defender")) then return end

	if mb_tankTarget("Baron Geddon") and mb_myNameInTable(MB_raidAssist.GTFO.Baron) then return end

	if mb_iamFocus() then return end

	if mb_imTank() then
		
		mb_followFocus()
	end
end

function mb_healerFollow() -- Healer follow
	
	if (mb_hasBuffOrDebuff("Plague", "player", "debuff") and mb_tankTarget("Anubisath Defender")) then return end
	
	if mb_tankTarget("Baron Geddon") and mb_myNameInTable(MB_raidAssist.GTFO.Baron) then return end

	if mb_iamFocus() then return end

	if mb_imHealer() then
		
		mb_followFocus()
	end
end

------------------------------------------------------------------------------------------------------
------------------------------------ Special Extra Healing Code! -------------------------------------
------------------------------------------------------------------------------------------------------

function mb_natureSwiftnessLowAggroedPlayer() -- Nature Swiftness heals

	if not MB_raidAssist.Shaman.NSLowHealthAggroedPlayers then
		return false
	end

	if not UnitInRaid("player") then 
		return false
	end

	if not mb_inCombat("player") then
		return false
	end

	if (mb_spellReady("Nature\'s Swiftness") or mb_hasBuffOrDebuff("Nature\'s Swiftness", "player", "buff")) then
		
		local blastNSatThisPercentage = 0.2
		local instantSpell = "Healing Touch"

		if mb_myClassOrder() == 1 then
			blastNSatThisPercentage = 0.35
		elseif mb_myClassOrder() == 2 then
			blastNSatThisPercentage = 0.30
		elseif mb_myClassOrder() == 3 then
			blastNSatThisPercentage = 0.25
		elseif mb_myClassOrder() == 4 then
			blastNSatThisPercentage = 0.20
		elseif mb_myClassOrder() >= 5 then
			blastNSatThisPercentage = 0.15
		end

		if myClass == "Shaman" then
			
			instantSpell = "Healing Wave"
		end

		local aggrox = AceLibrary("Banzai-1.0")
		local NSTarget

		for i =  1, GetNumRaidMembers() do

			NSTarget = "raid"..i

			if NSTarget and aggrox:GetUnitAggroByUnitId(NSTarget) then
				
				if mb_isValidFriendlyTarget(NSTarget, instantSpell) and mb_healthPct(NSTarget) <= blastNSatThisPercentage and not mb_hasBuffOrDebuff("Feign Death", NSTarget, "buff") then 
				
					if UnitIsFriend("player", NSTarget) then
						ClearTarget()
					end
				
					if not mb_hasBuffOrDebuff("Nature\'s Swiftness", "player", "buff") then
						
						SpellStopCasting()
					end

					mb_selfBuff("Nature\'s Swiftness")
				
					if mb_hasBuffOrDebuff("Nature\'s Swiftness", "player", "buff") then
		
						CastSpellByName(instantSpell, false)

						-- mb_message("I NS'd "..GetColors(UnitName(NSTarget)).." at "..string.sub(mb_healthPct(NSTarget), 3, 4).."% - "..UnitHealth(NSTarget).."/"..UnitHealthMax(NSTarget).." HP.")
						SpellTargetUnit(NSTarget)
						SpellStopTargeting()					
					end
					return true
				end
			end
		end
	end
	return false
end

function mb_targetMyAssignedTankToHeal() -- PW target the correct tank to heal
	
	if mb_myNameInTable(MB_myThreatPWSoakerHealerList) then
	
		TargetByName(MB_myThreatPWSoaker)
		return
	end		

	if mb_myNameInTable(MB_myFirstPWSoakerHealerList) then
	
		TargetByName(MB_myFirstPWSoaker)
		return
	end	
	
	if mb_myNameInTable(MB_mySecondPWSoakerHealerList) then
	
		TargetByName(MB_mySecondPWSoaker)
		return
	end	

	if mb_myNameInTable(MB_myThirdPWSoakerHealerList) then
	
		TargetByName(MB_myThirdPWSoaker)
		return
	end

	if not MB_myAssignedHealTarget then

		MB_myAssignedHealTarget = MB_raidLeader
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

function mb_instructorRazAddsHeal() -- Heal Razovious adds

    if not UnitInRaid("player") then
        return false
    end

    if mb_tankTarget("Instructor Razuvious") then
        
		if mb_myNameInTable(MB_myInstructorRazuviousAddHealer) then

			TargetUnit(MBID[MB_raidLeader].."targettarget")

			if UnitName("target") == "Deathknight Understudy" then
				local allowedOverHeal, spellToCast

				if myClass == "Shaman" then
				
					allowedOverHeal = GetHealValueFromRank("Healing Wave", MB_myShamanMainTankHealingRank) * MB_myMainTankOverhealingPercentage * 4
					spellToCast = "Healing Wave("..MB_myShamanMainTankHealingRank.."\)"

				elseif myClass == "Paladin" then
					
					allowedOverHeal = GetHealValueFromRank("Flash of Light", MB_myPaladinMainTankHealingRank) * MB_myMainTankOverhealingPercentage * 4
					spellToCast = "Flash of Light("..MB_myPaladinMainTankHealingRank.."\)"

				elseif myClass == "Priest" then
				
					allowedOverHeal = GetHealValueFromRank("Greater Heal", MB_myPriestMainTankHealingRank) * MB_myMainTankOverhealingPercentage * 4
					spellToCast = "Greater Heal("..MB_myPriestMainTankHealingRank.."\)"

				elseif myClass == "Druid" then
				
					allowedOverHeal = GetHealValueFromRank("Healing Touch", MB_myDruidMainTankHealingRank) * MB_myMainTankOverhealingPercentage * 4
					spellToCast = "Healing Touch("..MB_myDruidMainTankHealingRank.."\)"
				end

				if mb_isValidFriendlyTarget("target", spellToCast) and mb_healthDown("target") >= allowedOverHeal then
					
					CastSpellByName(spellToCast)
				end
				return true
			end
		end
    end
    return false
end


function mb_healLieutenantAQ20() -- AQ20 healing

	if MB_lieutenantAndorovIsNotHealable.Active then return false end -- NPC can't be healed stop for 6s

	if GetRealZoneText() == "The Ruins of Ahn\'Qiraj" then

        TargetByName("Lieutenant General Andorov")

        if UnitName("target") == "Lieutenant General Andorov" then
            local spellToCast

            if myClass == "Shaman" then

                spellToCast = "Healing Wave(rank 7)"

            elseif myClass == "Priest" then

                spellToCast = "Heal"

            elseif myClass == "Druid" then

                spellToCast = "Healing Touch(rank 3)"

            elseif myClass == "Paladin" then

                spellToCast = "Flash of Light"
            end

            if mb_isValidFriendlyTarget("target", spellToCast) and mb_healthPct("target") <= 0.4 then

                CastSpellByName(spellToCast)
                return true
            end
        else
            TargetLastTarget()
        end
    end
    return false
end

function mb_castSpellOnRandomRaidMember(spell, rank, percentage) -- Casting spells  random player

	if mb_imBusy() then return end
	if mb_tankTarget("Garr") or mb_tankTarget("Firesworn") then return end
	
	if UnitInRaid("player") then
		local n, r, i, j
		n = mb_GetNumPartyOrRaidMembers()
		r = math.random(n)-1

		for i = 1, n do
			j = i + r
			if j > n then j = j - n end	

			if mb_healthPct("raid"..j) < percentage and not mb_hasBuffNamed(spell, "raid"..j) and mb_isValidFriendlyTarget("raid"..j, spell) then

				if UnitIsFriend("player", "raid"..j) then
					ClearTarget()
				end

				if spell == "Weakened Soul" then
					CastSpellByName("Power Word: Shield", false)
				else
					CastSpellByName(spell.."\("..rank.."\)", false)
				end

				SpellTargetUnit("raid"..j)
				SpellStopTargeting()
				break
			end
		end
	end
end

function mb_getHealSpell() -- Get heal spell, according to gear

	if myClass == "Shaman" then

		if mb_equippedSetCount("Earthfury") == 8 then
			
			MB_myHealSpell = "Healing Wave"
			return true

		elseif (mb_equippedSetCount("The Ten Storms") >= 3 and mb_equippedSetCount("Stormcaller\'s Garb") == 5) then
			
			MB_myHealSpell = "Chain Heal"
			return true
		else
			
			if MB_raidAssist.Shaman.DefaultToHealingWave then -- Defaulting to healing when not assigned
				
				MB_myHealSpell = "Healing Wave"
				return true
			else

				MB_myHealSpell = "Chain Heal"
			end
		end

	elseif myClass == "Priest" then

		if mb_myNameInTable(MB_myFlashHealerList) then

			MB_myHealSpell = "Flash Heal"
			return true	

		elseif mb_equippedSetCount("Vestments of Transcendence") == 8 then
			
			MB_myHealSpell = "Greater Heal"
			return true
		else

			MB_myHealSpell = "Heal"
			return true
		end

	elseif myClass == "Druid" then

		if mb_equippedSetCount("Dreamwalker Raiment") >= 2 then
			
			MB_myHealSpell = "Rejuvenation"
			return true
		end
	end
end

function mb_ress() -- Requires Thaliz addon

	if myClass == "Priest" or myClass == "Shaman" or myClass == "Paladin" then
		
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

	if myClass == "Mage" or myClass == "Warlock" or myClass == "Druid" and not mb_inCombat("player") then
		
		mb_smartDrink()
	end
end

------------------------------------------------------------------------------------------------------
---------------------------------------------- Find Item! --------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_findItem(item) -- How to find items  in your raid

	local Rarity = {["poor"] = 0, ["common"] = 1, ["uncommon"] = 2, ["rare"] = 3, ["epic"] = 4, ["legendary"] = 5}
	-- This is the function that determines what happens when you type /find
	if item == "" then Print("Usage /find  < classname or all or nothing >   < wearing >  item slot or string") return end
	local class = "all"
	local _, _, key = string.find(item, "(%a + )%s*")

	local classlist = {}
	for class, name in MB_classList do
		table.insert(classlist, string.lower(class))
	end

	if mb_findInTable(classlist, key) then
		class = key
		_, _, item = string.find(item, "%a + %s(.*)")
		if not item then
			item = key
		else
			Print("Checking class "..key)
			_, _, key = string.find(item, "(%a + )%s*")
		end
	end

	if key == "all" then
		_, _, item = string.find(item, "%a + %s(.*)")
		_, _, key = string.find(item, "(%a + )%s*")
	end

	if key == "wearing" or key == "crapgear" then
		_, _, item = string.find(item, "%a + %s(.*)")
	end

	local myClass = string.lower(UnitClass("player"))
	if key == "crapgear" then
		Print("Finding crappy gear.")
		if class ~= "all" and class ~= myClass then
			return
		end

		for inv = 1, 16 do
			if inv ~= 4 then
				local itemLink = GetInventoryItemLink("player", inv)
				local quality = GetInventoryItemQuality("player", inv)
				if not quality then
					mb_message("MISSING: slot "..MB_slotmap[inv])
				elseif quality < 3 then
					local bsnum = string.gsub(itemLink, ".-\124H([^\124]*)\124h.*", "%1")
					local itemName, itemNo, itemRarity, itemReqLevel, itemType, itemSubType, itemCount, itemEquipLoc, itemIcon = GetItemInfo(bsnum)
					mb_message("CRAP: "..itemEquipLoc.." "..inv.." "..itemLink)
				end
			end
		end
		return
	end

	if key == "boe" then
		Print("Finding boe items in bags")
		if class ~= "all" and class ~= myClass then
			return
		end

		for bag = -1, 11 do
			for slot = 1, GetContainerNumSlots(bag) do
				local texture, itemCount, locked, quality, readable, lootable, link = GetContainerItemInfo(bag, slot)
				if texture then
					local link = GetContainerItemLink(bag, slot)
					local bsnum = string.gsub(link, ".-\124H([^\124]*)\124h.*", "%1")
					local itemName, itemNo, itemRarity, itemReqLevel, itemType, itemSubType, itemCount, itemEquipLoc, itemIcon = GetItemInfo(bsnum)
					_, itemCount = GetContainerItemInfo(bag, slot)
					local match = nil
					link = GetContainerItemLink(bag, slot)
					links = string.lower(link)
					items = string.lower(item)
					match = string.find(links, items)
					if mb_isItemUnboundBOE(bag, slot) then
						mb_message("Found "..link.." in bag "..bag.." slot "..slot)
					end
				end
			end
		end
		return
	end

	if key == "wearing" then
		if not item then Print("You need to name an item or slot")
			return
		end

		Print("Finding "..class.." wearing "..item)

		if class ~= "all" and class ~= myClass then
			return
		end

		for inv = 1, 19 do
			local itemLink = GetInventoryItemLink("player", inv)
			local quality = GetInventoryItemQuality("player", inv)
			if itemLink then
				local bsnum = string.gsub(itemLink, ".-\124H([^\124]*)\124h.*", "%1")
				local itemName, itemNo, itemRarity, itemReqLevel, itemType, itemSubType, itemCount, itemEquipLoc, itemIcon = GetItemInfo(bsnum)
				local match = nil
				links = string.lower(itemLink)
				items = string.lower(item)
				match = string.find(links, items)
				if itemEquipLoc then
					itemEquipLoc = string.lower(itemEquipLoc)
					match =  match or string.find(itemEquipLoc, items)
				end
				if itemRarity then
					match =  match or itemRarity == Rarity[items]
				end
				if itemType then
					itemType = string.lower(itemType)
					match =  match or string.find(itemType, items)
				end
				if itemSubType then
					itemSubType = string.lower(itemSubType)
					match =  match or string.find(itemSubType, items)
				end
				if match then
					mb_message("Found "..itemLink.." in slot "..MB_slotmap[inv])
				end
			end
		end
		return
	else
		if not item then Print("You need to name an item or slot") return end
			Print("Finding item "..item)
			if class ~= "all" and class ~= myClass then return end
			for bag = -2, 11 do
				local maxIndex = GetContainerNumSlots(bag)
				if bag == -2 then maxIndex = 12 end
				for slot = 1, maxIndex do
					local texture, itemCount, locked, quality, readable, lootable, link = GetContainerItemInfo(bag, slot)
					if texture then
						local link = GetContainerItemLink(bag, slot)
						local bsnum = string.gsub(link, ".-\124H([^\124]*)\124h.*", "%1")
						local itemName, itemNo, itemRarity, itemReqLevel, itemType, itemSubType, itemCount, itemEquipLoc, itemIcon = GetItemInfo(bsnum)
						_, itemCount = GetContainerItemInfo(bag, slot)
						local match = nil
						link = GetContainerItemLink(bag, slot)
						links = string.lower(link)
						items = string.lower(item)
						match = string.find(links, items)
					if itemEquipLoc then
						itemEquipLoc = string.lower(itemEquipLoc)
						match =  match or string.find(itemEquipLoc, items)
					end
					if itemRarity then
						match =  match or itemRarity == Rarity[items]
					end
					if itemType then
						itemType = string.lower(itemType)
						match =  match or string.find(itemType, items)
					end
					if itemSubType then
						itemSubType = string.lower(itemSubType)
						match =  match or string.find(itemSubType, items)
					end
					if match then
						if UnitInRaid("player") then
							mb_message("Found "..link.."x"..itemCount.." in bag "..bag.." slot "..slot)
						end
					end
				end
			end
		end
	end
end

MB_slotmap = { [0] = "ammo", [1] = "head", [2] = "neck", [3] = "shoulder", [4] = "shirt", [5] = "chest", [6] = "waist", [7] = "legs", [8] = "feet", [9] = "wrist", [10] = "hands", [11] = "finger 1", [12] = "finger 2", [13] = "trinket 1", [14] = "trinket 2", [15] = "back", [16] = "main hand", [17] = "off hand", [18] = "ranged", [19] = "tabard"}

function mb_isItemUnboundBOE(b, s)
	local soulbound = nil
	local boe = nil
	--local _, _, itemID = string.find(itemlink, "item:(%d + )")
	MMBTooltip:SetOwner(UIParent, "ANCHOR_NONE");
	MMBTooltip:ClearLines()
	MMBTooltip:SetBagItem(b, s);
	MMBTooltip:Show()
	local index = 1
	local ltext = getglobal("MMBTooltipTextLeft"..index):GetText()
	while ltext ~= nil do
		ltext = getglobal("MMBTooltipTextLeft"..index):GetText()
		if ltext ~= nil then
			if string.find(ltext, "Soulbound") then
				soulbound = true
			end
			if string.find(ltext, "Binds when equipped") then
				boe = true
			end
		end
		index = index + 1
	end
	if not soulbound and boe then return true end
end

------------------------------------------------------------------------------------------------------
-------------------------------------------- Setup Code! ---------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_makeWater()

	if myClass ~= "Mage" then return end
	if mb_imBusy() then return end

	if mb_hasBuffOrDebuff("Evocation", "player", "buff") then return end -- Stop when Evocade

	if (mb_manaPct("player") > 0.8) and mb_hasBuffNamed("Drink", "player") then -- Stand up
		
		DoEmote("Stand")
		return
	end

	if UnitMana("player") < 780 then -- Make water and eveade

		if mb_spellReady("Evocation") then

			mb_evoGear()
			CastSpellByName("Evocation")
			return
		end

		mb_mageGear()
		mb_smartDrink()
	end

	if mb_getAllContainerFreeSlots() > 0 then -- Notify stuff
		
		CastSpellByName("Conjure Water")
	else 

		mb_message("My bags are full, can\'t conjure more stuff", 60)
	end
end

function mb_isMageInGroup() -- Return mage names
	local mages = {}

	if UnitInRaid("player") then

		for i = 1, GetNumRaidMembers() do
			local name, rank, subgroup, level, iclass, fileName, zone, online, isdead = GetRaidRosterInfo(i)
			if iclass == "Mage" then table.insert(mages, name) end
		end
	else
		
		if UnitClass("player") == "Mage" then table.insert(mages, myName) end
			
			for i = 1, 4 do
				iclass = UnitClass("party"..i)
				local name =  UnitName("party"..i)
				
				if iclass == "Mage" then
					table.insert(mages, name) 
				end
			end
		end

	if TableLength(mages) == 0 then
		return nil
	else
		return(mages[math.random(TableLength(mages))])
	end
end

function mb_mageWater()
	--How much crappy mage water do you have? This function will tell you--change name below if you have best water
	--pick up a stack of the best water in your bags
	local waterranks = table.invert(MB_myWater)
	local bestrank = 1
	local bestwater = nil
	local count = 0
	local bag, slot, link

	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			local texture, itemCount, locked, quality, readable, lootable, link = GetContainerItemInfo(bag, slot)
			
			if texture then
				link = GetContainerItemLink(bag, slot)
				_, stack = GetContainerItemInfo(bag, slot)
				local bsnum = string.gsub(link, ".-\124H([^\124]*)\124h.*", "%1")
				local itemName, itemNo, itemRarity, itemReqLevel, itemType, itemSubType, itemCount, itemEquipLoc, itemIcon = GetItemInfo(bsnum)
				
				if mb_findInTable(MB_myWater, itemName) then
					if waterranks[itemName] > bestrank then
						bestwater = itemName
						bestrank = waterranks[itemName]
						count = stack
					elseif waterranks[itemName] == bestrank then
						count = count + stack
					end
				end
			end
		end 
	end
	return count, bestwater
end

function mb_pickUpWater()

	-- Picks ur the best possible water
	local waterranks = table.invert(MB_myWater)
	local amount = 0
	local mycarriedwater = { }
	local bestrank = 1
	local bag, slot, link

	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			local texture, itemCount, locked, quality, readable, lootable, link = GetContainerItemInfo(bag, slot)
			
			if texture then
				link = GetContainerItemLink(bag, slot)
				local bsnum = string.gsub(link, ".-\124H([^\124]*)\124h.*", "%1")
				local itemName, itemNo, itemRarity, itemReqLevel, itemType, itemSubType, itemCount, itemEquipLoc, itemIcon = GetItemInfo(bsnum)
				
				mb_findInTable(waterranks, itemName)
				
				if mb_findInTable(MB_myWater, itemName) then
					if waterranks[itemName] > bestrank then
						
						bestrank=waterranks[itemName]
						bestwater=itemName.." "..bag.." "..slot
					end
				end
			end 
		end 
	end

	if bestrank > 0 then

		_,_,water,bag,slot = string.find(bestwater, "(Conjured.*Water) (%d+) (%d+)")
		
		Print("Found "..water.." in bag "..bag.." in slot "..slot)
		PickupContainerItem(bag, slot)
		return water
	end
end

function mb_smartDrink() -- Drink and Trade water

	if IsControlKeyDown() then -- Get sunfruit buff
		
		mb_sunfruitBuff()
		return
	end

	if IsAltKeyDown() then -- Trade for manapots
		
		mb_smartManaPotTrade()
		return
	end

	if (mb_manaPct("player") > 0.99) and mb_hasBuffNamed("Drink", "player") then -- Stand up
		
		DoEmote("Stand")
		return
	end

	if (myClass == "Warrior" or myClass == "Rogue") then return end

	if myClass == "Mage" and MB_tradeOpen then -- Trade or Cancel the trade
		if mb_mageWater() > 20 and GetTradePlayerItemLink(1) and string.find(GetTradePlayerItemLink(1), "Conjured.*Water") then
			return 
		end
		
		if mb_mageWater() < 21 and GetTradePlayerItemLink(1) and string.find(GetTradePlayerItemLink(1), "Conjured.*Water") then 
			
			Print("Not enough water to trade!")
			CancelTrade()
			return
		end
	end

	if myClass ~= "Mage" and not MB_tradeOpen then -- Open a trade with a mage

		waterMage = mb_isMageInGroup()

		if waterMage then
			if mb_mageWater() < 1 and mb_manaUser() then
				
				if mb_isAlive(MBID[waterMage]) and mb_inTradeRange(MBID[waterMage]) then
					
					TargetByName(waterMage, 1)
					
					if not MB_tradeOpen then
						InitiateTrade("target")
					end
				end
			end
		end
	end

	if myClass == "Mage" and MB_tradeOpen then -- Set water in the trade
		if mb_mageWater() > 21 and mb_pickUpWater() then
			
			Print("Trading Water")
			ClickTradeButton(1)
			return
		end
	end

	if mb_hasBuffOrDebuff("Evocation", "player", "buff") then -- Mage gear
		return
	else 

		if myClass == "Mage" then
			
			mb_mageGear() 
		end
	end

	_, mybest = mb_mageWater()

	if not mb_hasBuffNamed("Drink", "player") and mybest then -- Drink water

		if mb_manaUser() and mb_manaDown() > 0 then
			
			mb_useFromBags(mybest)
		end
	end
end

function mb_smartManaPotTrade() -- Mana pot trade

	if not mb_imHealer() then return end

	if myName == MB_raidAssist.PotionTraders.MajorMana and MB_tradeOpen then
		if mb_numManapots() > 3 and GetTradePlayerItemLink(1) and string.find(GetTradePlayerItemLink(1), "Major Mana Potion") then
			return 
		end
		
		if mb_numManapots() < 2 and GetTradePlayerItemLink(1) and string.find(GetTradePlayerItemLink(1), "Major Mana Potion") then 
			Print("Not enough water to trade!")
			CancelTrade()
			return
		end
	end

	if myName ~= MB_raidAssist.PotionTraders.MajorMana and not MB_tradeOpen then

		if MB_raidAssist.PotionTraders.MajorMana and mb_unitInRaidOrParty(MB_raidAssist.PotionTraders.MajorMana) then
			if mb_numManapots() < 1 then
				
				if mb_isAlive(MBID[MB_raidAssist.PotionTraders.MajorMana]) and mb_inTradeRange(MBID[MB_raidAssist.PotionTraders.MajorMana]) then
					
					if not MB_tradeOpen then
						InitiateTrade(MBID[MB_raidAssist.PotionTraders.MajorMana])
					end
				end
			end
		end
	end

	if myName == MB_raidAssist.PotionTraders.MajorMana and MB_tradeOpen then
		if mb_numManapots() > 2 then

			local i, x = mb_bagSlotOf("Major Mana Potion")
			PickupContainerItem(i, x)
			ClickTradeButton(1)
			return
		end
	end
end

function mb_sunfruitBuff() -- Sunfruit

	if mb_hasBuffNamed("Well Fed", "player") then return end
	
	if mb_hasBuffNamed("Blessed Sunfruit Juice", "player") or mb_hasBuffNamed("Blessed Sunfruit", "player") then

		DoEmote("Stand")
		return
	end

	if myClass == "Rogue" or myClass == "Warrior" then

		if not mb_hasBuffNamed("Blessed Sunfruit", "player") then

			UseItemByName("Blessed Sunfruit")
		end
		return
	end

	if not mb_hasBuffNamed("Blessed Sunfruit Juice", "player") then
		
		UseItemByName("Blessed Sunfruit Juice")
	end
end

------------------------------------------------------------------------------------------------------
----------------------------------------- START SHAMAN CODE! -----------------------------------------
------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------
-------------------------------------------- Single Code! --------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_meleeDPSInParty()
	if mb_numberOfClassInParty("Warrior") > 0 or mb_numberOfClassInParty("Rogue") > 0 then return true end
end

function mb_numOfCasterHealerInParty()
	local total = 0

	total = mb_numberOfClassInParty("Mage") + mb_numberOfClassInParty("Priest") + mb_numberOfClassInParty("Druid") + mb_numberOfClassInParty("Shaman")
	return total
end

------------------------------------------------------------------------------------------------------
------------------------------------------- Boss Info Code! ------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_partyIsPoisoned() --Returns true if anyone in your party is poisoned
	
	if MB_raidLeader then
		if (mb_tankTarget("Princess Huhuran") or mb_isAtGrobbulus()) then
			return false
		end	
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

function mb_raidIsPoisoned() --Returns true if anyone in your party is poisoned
	
	if MB_raidLeader then
		if (mb_tankTarget("Princess Huhuran") or mb_isAtGrobbulus()) then
			return false
		end	
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

function mb_playerIsPoisoned() --Returns true if anyone in your party is poisoned

	if MB_raidLeader then
		if (mb_tankTarget("Princess Huhuran") or mb_isAtGrobbulus()) then
			return false
		end	
	end

	for x = 1, 16 do

		local name, count, debuffType = UnitDebuff("player", x, 1)
		if debuffType == "Poison" then 
			return true 
		end
	end
end

function mb_partyIsDiseased() --Returns true if anyone in party is diseased
	
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

------------------------------------------------------------------------------------------------------
-------------------------------------------- Setup Code! ---------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_castShieldOnRandomRaidMember(spell, rank) -- Cast shield on random members

	if mb_imBusy() then return end
	if mb_tankTarget("Garr") or mb_tankTarget("Firesworn") then return end

	if UnitInRaid("player") then
		local n, r, i, j
		n = mb_GetNumPartyOrRaidMembers()
		r = math.random(n)-1

		for i = 1, n do
			j = i + r
			if j > n then j = j - n end	

			if not mb_hasBuffNamed("Power Word: Shield", "raid"..j) and not mb_hasBuffNamed("Weakened Soul", "raid"..j) and mb_isValidFriendlyTarget("raid"..j, spell) then

				if UnitIsFriend("player", "raid"..j) then
					ClearTarget()
				end
					
				CastSpellByName("Power Word: Shield", false)
				
				SpellTargetUnit("raid"..j)
				SpellStopTargeting()
				break
			end
		end
	end
end

function mb_powerwordShield_tanks() -- Shield tanks
	
	if myClass ~= "Priest" then return end

	i = 1

	for _, tank in MB_raidTanks do

		if mb_isAlive(MBID[tank]) then

			if i == mb_myClassOrder() then
				
				TargetUnit(MBID[tank])
				CastSpellByName("Power Word: Shield")
				return
			end

			i = i + 1
		end
	end
end

-- SpellBonus
function GetHealBonus()
	local value = MBx.ACE.ItemBonus:GetBonus("HEAL")
	return value	
end

-- 1105
function GetSpellBonus()
	local value = MBx.ACE.ItemBonus:GetBonus("DMG")
	return value
end

function GetFireSpellBonus()
	local value = (MBx.ACE.ItemBonus:GetBonus("DMG") + MBx.ACE.ItemBonus:GetBonus("FIREDMG"))
	return value
end

function GetSpellCritBonus()
	local value = MBx.ACE.ItemBonus:GetBonus("SPELLCRIT")
	return value
end

function GetSpellHitBonus()
	local value = MBx.ACE.ItemBonus:GetBonus("SPELLTOHIT")
	return value
end

function GetBetterMage()
    local result = ((GetSpellCritBonus() / GetFireSpellBonus()) * 1000) + GetSpellCritBonus()
    local integerPart = math.floor(result)
    local decimalPart = result - integerPart
    local roundedDecimal = math.floor(decimalPart * 10) / 10
    return integerPart + roundedDecimal
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

	multiplier = multiplier and (1 + multiplier / 100) or 1

	local baseHeal = MBx.ACE.HealComm.Spells[spell][ExtractRank(rank)](GetHealBonus())
	local lowestHeal = baseHeal / (2 ^ amountOfBounce)

	return math.floor(lowestHeal * multiplier)
end

------------------------------------------------------------------------------------------------------
-------------------------------------------- Stance Code! --------------------------------------------
------------------------------------------------------------------------------------------------------

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

------------------------------------------------------------------------------------------------------
-------------------------------------------- Stone Code! ---------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_numShards() -- Count shards
	local shardss = 0
	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			local link = GetContainerItemLink(bag, slot)
			if link == nil then
				link = ""
			end
			if string.find(link, "Soul Shard") then
				shardss = shardss + 1
			end
		end
	end
	return shardss
end

function mb_reportShards() -- Report
	if myClass ~= "Warlock" then return end

	if mb_numShards() then

		mb_message("I\'ve got "..mb_numShards().." shards!")
	end
end

function mb_reportRunes() -- Report
	if not mb_imHealer() then return end

	if mb_hasItem("Demonic Rune") then

		mb_message("I\'ve got "..mb_hasItem("Demonic Rune").." runes!")
	end
end

------------------------------------------------------------------------------------------------------
-------------------------------------------- Setup Code! ---------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_isBearForm()
	return mb_warriorIsStance(1)
end

function mb_isCatForm()
	return mb_warriorIsStance(2)
end

function mb_isTravelForm()
	return mb_warriorIsStance(3)
end

function mb_isBoomForm()
	return mb_warriorIsStance(5)
end

function mb_isDruidShapeShifted()

	if myClass ~= "Druid" then return false end

	if mb_isBearForm() then 
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
	if mb_isBearForm() then mb_warriorSetStance(1) return end
	if mb_isCatForm() then mb_warriorSetStance(2) return end
	if mb_isTravelForm() then mb_warriorSetStance(3) return end
	if mb_isBoomForm() then mb_warriorSetStance(4) return end
end

function mb_removeFeignDeath()
	CancelBuff("Feign Death")
	DoEmote("Stand")
	MB_hunterFeign.Active = false
end

------------------------------------------------------------------------------------------------------
---------------------------------------- New Ideas / Codes! ------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_openClickQiraji()

	if mb_haveInBags("Ancient Qiraji Artifact") then
		mb_coolDownPrint("I have an artifact!")
		UseItemByName("Ancient Qiraji Artifact")
		AcceptQuest()
		return
	end
end
		
function mb_getQuest(name)
	for i = 1,GetNumQuestLogEntries() do
		SelectQuestLogEntry(i)
		if GetQuestLogTitle(i) == name then 
			return true
		end
	end
	return nil
end

function mb_petSpellCooldown(spellName)
	local index = mb_getPetSpellOnBar(spellName)
	local timeleft, _, _ = GetPetActionCooldown(index)
	return timeleft
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
	if UnitExists("pet") then
		
		local index = mb_getPetSpellOnBar(spellName)	
		CastPetAction(index)		
	end
end

function mb_getMCActions()

	if mb_hasBuffNamed("Mind Control", "player") then return end -- Stop all when ur MC'ing

	if not UnitExists("pet") and (UnitName("target") == "Deathknight Understudy" or UnitName("target") == "Naxxramas Worshipper") then
		
		CastSpellByName("Mind Control")
	end
end

function mb_doRazuviousActions()

	for i = 1, 4 do
		if UnitExists("pet") then
			
			TargetByName("Instructor Razuvious")

			--mb_castPetAction("Taunt")
			PetAttack()

			if mb_petSpellReady("Shield Wall") then

				mb_castPetAction("Shield Wall")
				mb_message("Shield Wall!")
			end			
		end
	end
end

function mb_doFaerlinaActions()

	for i = 1, 4 do
		if UnitExists("pet") then
			
			TargetByName("Grand Widow Faerlina")
			PetAttack("Grand Widow Faerlina")			
		end
	end
end

function mb_orbControlling()

	if UnitExists("pet") then
		for i = 1, 8 do
		
			mb_castPetAction("Destroy Egg")
			CastPetAction(5)		
		end
	end
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