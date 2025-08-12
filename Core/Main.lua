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

	local MB_myCCTarget = nil
	local MB_myInterruptTarget = nil
	local MB_myOTTarget = nil
	
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

		-- Priest
		["Smite"] = 280,
		["Mind Flay"] = 205,
		["Mind Blast"] = 250,
		["Mana Burn"] = 270
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
	local MB_savedBinding = { Active = false, Time = 0, Binding2 = "SM_MACRO2", Binding3 = "SM_MACRO3" }

	MB_isCasting = nil
	MB_isChanneling = nil
	
	MB_isCastingMyCCSpell = nil
	
	MB_isMoving = { Active = false, Time = 0 }

	-- Ignite

	MB_ignite = { Active = nil, Starter = nil, Amount = 0, Stacks = 0 }

	MB_buffingCounterWarlock = 1
	MB_ssCounterWarlock = 1
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
	local MB_useCooldowns = { Active = false, Time = 0 }
	local MB_useBigCooldowns = { Active = false, Time = 0 }

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

	MB_warriorbinds = "Fury"
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
			if MB_warriorbinds == "Fury" and mb_imMeleeDPS() then
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

	if MB_autoBuySunfruit.Active then
        if GetTime() > MB_autoBuySunfruit.Time then

			mb_buyBlessedSunfruits()
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

function mb_imRangedDPS() -- Who is ranged
	if (myClass == "Hunter" or myClass == "Warlock" or myClass == "Mage") then
		return true
	end
end

function mb_imMeleeDPS() -- Melee dps
	if myClass == "Rogue" then
		return true

	elseif myClass == "Warrior" and (MB_mySpecc == "MS" or MB_mySpecc == "BT") then
		return true

	elseif myClass == "Druid" and MB_mySpecc == "Kitty" then
		return true
	end
end

function mb_imTank() -- Tanks
	if myClass == "Warrior" and (MB_mySpecc == "Prottank" or MB_mySpecc == "Furytank") then
		return true

	elseif myClass == "Druid" and MB_mySpecc == "Feral" then
		return true
	end
end

function mb_imHealer() -- Healers
	if myClass == "Paladin" then
		return true

	elseif myClass == "Druid" and (MB_mySpecc == "Swiftmend" or MB_mySpecc == "Resto") then
		return true

	elseif myClass == "Shaman" then
		return true

	elseif myClass == "Priest" then
		return true
	end
end

function mb_iamFocus() -- Focus
	if MB_raidLeader == myName then return true end
end

function mb_autoAttack()
	local atkslot = tonumber(MB_attackSlot)

	if not IsCurrentAction(atkslot) then 
		CastSpellByName("Attack")
	end
end

function mb_autoRangedAttack()
	local atkslot = tonumber(MB_attackRangedSlot)

	if not IsAutoRepeatAction(atkslot) then 
		CastSpellByName("Auto Shot") 
	end
end

function mb_autoWandAttack()
	local wndslot = tonumber(MB_attackWandSlot)

	if not IsAutoRepeatAction(wndslot) then
		CastSpellByName("Shoot")
	end
end

function mb_healerWand()

	if not mb_inCombat("target") then return end

	if not mb_imBusy() and mb_debuffSunderAmount() > 3 then

		mb_assistFocus()
		mb_autoWandAttack()
	end
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

function mb_hasShield()
	local offhandLink = GetInventoryItemLink("player", GetInventorySlotInfo("SecondaryHandSlot"))
	if offhandLink then
		local itemId, permEnchant, tempEnchant, suffix, itemName = string.gfind(offhandLink, "|Hitem:(.-):(.-):(.-):(.-)|h%[(.-)%]|h")()
		local _, _, _, _, _, itemType = GetItemInfo(itemId)
		return itemType == "Shields"
	else
		return false
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

function mb_anubAlert() -- Kinda useless but it yells out who has what on the anub encounter

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

		if mb_isItemInBagCooldown("Major Soulstone") then

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

function mb_spellReady(spellName)
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

function mb_isItemInBagCooldown(itemName)
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

function mb_useBandage()

	if mb_imBusy() then return false end

	if mb_hasBuffOrDebuff("Recently Bandaged", "player", "debuff") then return false end

	if mb_bossIShouldUseBandageOn() then
		if mb_healthDown("player") > 2000 and mb_haveInBags("Heavy Runecloth Bandage") then

			TargetUnit("player")
			UseItemByName("Heavy Runecloth Bandage")
			TargetLastTarget()
			return true
		end
	end
	return false
end

function mb_takeManaPotionAndRune()

	if mb_bossIShouldUseRunesAndManapotsOn() then
		if mb_inCombat("player") then

			if mb_manaDown() > 2250 and mb_haveInBags("Major Mana Potion") and not mb_isItemInBagCooldown("Major Mana Potion") then
				
				UseItemByName("Major Mana Potion")
				return
			end

			if mb_manaDown() > 1500 and mb_haveInBags("Superior Mana Potion") and not mb_isItemInBagCooldown("Superior Mana Potion") then
				
				UseItemByName("Superior Mana Potion")
				return
			end
			
			if mb_manaDown() > 1500 and mb_haveInBags("Demonic Rune") and not mb_isItemInBagCooldown("Demonic Rune") then
				
				UseItemByName("Demonic Rune")
				return
			end

			if mb_manaDown() > 1500 and mb_haveInBags("Dark Rune") and not mb_isItemInBagCooldown("Dark Rune") then
				
				UseItemByName("Dark Rune")
				return
			end
		end
	end
end

function mb_takeManaPotionIfBelowManaPotMana()

	if mb_bossIShouldUseManapotsOn() then
		if mb_inCombat("player") then

			if mb_manaDown() > 2250 and mb_haveInBags("Major Mana Potion") and not mb_isItemInBagCooldown("Major Mana Potion") then
				
				UseItemByName("Major Mana Potion")
				return
			end

			if mb_manaDown() > 1500 and mb_haveInBags("Superior Mana Potion") and not mb_isItemInBagCooldown("Superior Mana Potion") then
				
				UseItemByName("Superior Mana Potion")
				return
			end
		end
	end
end

function mb_takeManaPotionIfBelowManaPotManaInRazorgoreRoom()

	if not MB_myRazorgoreBoxHealerStrategy then return end
	
	if (GetRealZoneText() == "Blackwing Lair" and (GetSubZoneText() == "Dragonmaw Garrison" and mb_isAtRazorgorePhase())) and MB_myRazorgoreBoxStrategy then

		if mb_inCombat("player") then
			
			if mb_manaDown() > 2250 and mb_haveInBags("Major Mana Potion") and not mb_isItemInBagCooldown("Major Mana Potion") then
					
				UseItemByName("Major Mana Potion")
				return
			end

			if mb_manaDown() > 1500 and mb_haveInBags("Superior Mana Potion") and not mb_isItemInBagCooldown("Superior Mana Potion") then
				
				UseItemByName("Superior Mana Potion")
				return
			end
		end
	end
end

function mb_takeHealthPotion()

	if mb_imBusy() then return end

	if mb_isDruidShapeShifted() then return end

	if UnitClassification("target") == "worldboss" then

		if mb_healthPct("player") < 0.15  and mb_haveInBags("Major Healing Potion") and not mb_isItemInBagCooldown("Major Healing Potion") then
			
			UseItemByName("Major Healing Potion")
			return
		end
	end
end

function mb_useSandsOnChromaggus()

	if mb_tankTarget("Chromaggus") then 
	
		if (mb_iamFocus() or mb_imTank()) then
			
			if mb_hasBuffOrDebuff("Brood Affliction: Bronze", "player", "debuff") and not mb_hasBuffNamed("Time Stop", "player") then

				if (mb_sandtime == nil or GetTime() - mb_sandtime > 3) then
					mb_sandtime = GetTime()
					mb_useFromBags("Hourglass Sand")
				end
			end
		end
	end
end

function mb_useFrozenRuneOnFaerlina()
	
	if not MB_myFaerlinaRuneStrategy then return end

	if mb_isDruidShapeShifted() then return end

	if mb_tankTarget("Grand Widow Faerlina") and not mb_hasBuffNamed("Frozen Rune", "player") and not mb_isItemInBagCooldown("Frozen Rune") then
		
		mb_useFromBags("Frozen Rune")
	end
end

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
---------------------------------------------- Speak Code! -------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_message(msg, timer)
	--this is a raid message function with a 10 second cooldown to kind-of avoid some spamming.
	local cooldown
	local time = GetTime()

	if not timer then cooldown = 10 else cooldown = timer end

	if MB_prev_msg == msg and MB_msgCD + cooldown > time then return end
	MB_prev_msg = msg
	MB_msgCD = time

	if UnitInRaid("player") then
		SendChatMessage(msg, "RAID") return
	else
		SendChatMessage(msg, "PARTY") return
	end
end

function mb_cooldownRaidWarning(msg, timer)

	local cooldown
	local time = GetTime()

	if not timer then cooldown = 10 else cooldown = timer end

	if MB_prev_RW == msg and MB_RWCD + cooldown > time then return end
	MB_prev_RW = msg
	MB_RWCD = time

    SendChatMessage(msg,"RAID_WARNING")
end

function mb_coolDownPrint(msg, timer)

	local cooldown
	local time = GetTime()

	if not timer then cooldown = 10 else cooldown = timer end

	if MB_prev_print == msg and MB_printCD + cooldown > time then return end
	MB_prev_print = msg
	MB_printCD = time

    Print(msg)
end

function mb_cooldownSecondPrint(msg, timer)

	local cooldown
	local time = GetTime()

	if not timer then cooldown = 10 else cooldown = timer end

	if MB_printSecndCD == msg and MB_prev_sendPrint + cooldown > time then return end
	MB_printSecndCD = msg
	MB_prev_sendPrint = time

    Print(msg)
end

function Print(msg)
	if msg then return DEFAULT_CHAT_FRAME:AddMessage(msg) end
end

function Print(msg)
	if msg then return DEFAULT_CHAT_FRAME:AddMessage(msg) end
end

------------------------------------------------------------------------------------------------------
----------------------------------------- Trade Cooldown Code! ---------------------------------------
------------------------------------------------------------------------------------------------------

function mb_getGoldFromLeader(amount)
	if not MB_raidLeader then return end

	if myName ~= MB_raidInviter then
		local myGold = GetMoney()

		if myGold >= amount*10000 then return end

		if not MB_tradeOpen then
			InitiateTrade(MBID[MB_raidLeader]) 
		end

		if MB_tradeOpen and GetTargetTradeMoney() > 0 then
			AcceptTrade()
			return
		end

	elseif myName == MB_raidInviter then
		local myGold = GetMoney()

		if myGold <= amount*10000 then
			Print("I don\'t have "..amount.." gold.")
			return
		end

		local myTrade = amount*10000
		
		if MB_tradeOpen then
			if GetPlayerTradeMoney() == 0 then
				SetTradeMoney(myTrade)
			else
				AcceptTrade()
			end
		end
	end
end

function mb_tradeGoldToLeader(amount)
	if not MB_raidLeader then return end

	if myName == MB_raidInviter then

		if MB_tradeOpen and GetTargetTradeMoney() > 0 then
			AcceptTrade()
			return
		end

	elseif myName ~= MB_raidInviter then
		local myGold = GetMoney()

		if myGold <= amount*10000 then return end

		local myTrade = myGold-amount*10000

		TargetUnit(MBID[MB_raidLeader])
		InitiateTrade("target")

		if GetPlayerTradeMoney() == 0 then
			SetTradeMoney(myTrade)
		else
			AcceptTrade()
		end
	end
end

function mb_getTradeSkillCooldown(skillName)
	for i = 1, GetNumTradeSkills() do
		if GetTradeSkillInfo(i) == skillName then
			local isOnCd = GetTradeSkillCooldown(i)
			if isOnCd then
				if isOnCd > 0 then
					return true
				end
			end
			return false
		end
	end
end

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
--------------------------------------------- Buffs Code! --------------------------------------------
------------------------------------------------------------------------------------------------------

mb_buffData = {}
--start of priestbuffs/debuffs
mb_buffData["Prayer of Fortitude"] 			 =  "Interface\\Icons\\Spell_Holy_PrayerOfFortitude"
mb_buffData["Power Word: Fortitude"] 		 =  "Interface\\Icons\\Spell_Holy_WordFortitude"
mb_buffData["Prayer of Spirit"] 			 =  "Interface\\Icons\\Spell_Holy_PrayerofSpirit"
mb_buffData["Divine Spirit"] 				 =  "Interface\\Icons\\Spell_Holy_DivineSpirit"
mb_buffData["Prayer of Shadow Protection"]  = "Interface\\Icons\\Spell_Holy_PrayerofShadowProtection"
mb_buffData["Shadow Protection"] 			 =  "Interface\\Icons\\Spell_Shadow_AntiShadow"
mb_buffData["Weakened Soul"] 				 =  "Interface\\Icons\\Spell_Holy_AshesToAshes"
mb_buffData["Power Word: Shield"] 			 =  "Interface\\Icons\\Spell_Holy_PowerWordShield"
mb_buffData["Shadowform"] 					 =  "Interface\\Icons\\Spell_Shadow_Shadowform"
mb_buffData["Renew"] 						 =  "Interface\\Icons\\Spell_Holy_Renew"
mb_buffData["Mind Control"]					 =  "Interface\\Icons\\Spell_Shadow_ShadowWordDominate"
mb_buffData["Inner Fire"] 					 =  "Interface\\Icons\\Spell_Holy_InnerFire"
mb_buffData["Inner Focus"] 					 =  "Interface\\Icons\\Spell_Frost_WindWalkOn"
mb_buffData["Spirit Tap"] 					 =  "Interface\\Icons\\Spell_Shadow_Requiem"
mb_buffData["Vampiric Embrace"] 			 =  "Interface\\Icons\\Spell_Shadow_UnsummonBuilding"
mb_buffData["Fade"] 						 =  "Interface\\Icons\\Spell_Magic_LesserInvisibilty"
mb_buffData["Power Infusion"] 				 =  "Interface\\Icons\\Spell_Holy_PowerInfusion"
mb_buffData["Spirit of Redemption"] 		 =  "Interface\\Icons\\Spell_Holy_GreaterHeal"
mb_buffData["Fear Ward"] 					 =  "Interface\\Icons\\Spell_Holy_Excorcism"
mb_buffData["Shadowguard"] 					 =  "Interface\\Icons\\Spell_Nature_LightningShield"
mb_buffData["Devouring Plague"] 			 =  "Interface\\Icons\\Spell_Shadow_BlackPlague"
mb_buffData["Hex of Weakness"] 				 =  "Interface\\Icons\\Spell_Shadow_FingerOfDeath"
mb_buffData["Holy Fire"] 					 =  "Interface\\Icons\\Spell_Holy_SearingLight"
mb_buffData["Shadow Weaving"] 				 =  "Interface\\Icons\\Spell_Shadow_BlackPlague"
mb_buffData["Inspiration"] 					 =  "Interface\\Icons\\INV_Shield_06"
mb_buffData["Psychic Scream"] 				 =  "Interface\\Icons\\Spell_Shadow_PsychicScream"
mb_buffData["Shackle Undead"] 				 =  "Interface\\Icons\\Spell_Nature_Slow"
mb_buffData["Shadow Word: Pain"] 			 =  "Interface\\Icons\\Spell_Shadow_ShadowWordPain"
mb_buffData["Mind Soothe"] 					 =  "Interface\\Icons\\Spell_Holy_MindSooth"
mb_buffData["Silence"]						 =  "Interface\\Icons\\Spell_Shadow_ImpPhaseShift"
mb_buffData["Blackout"] 					 =  "Interface\\Icons\\Spell_Shadow_GatherShadows"
--end of prieststuffs
--start of druidbuffs/debuffs
mb_buffData["Gift of the Wild"] 			 =  "Interface\\Icons\\Spell_Nature_Regeneration"
mb_buffData["Mark of the Wild"] 			 =  "Interface\\Icons\\Spell_Nature_Regeneration"
mb_buffData["Rejuvenation"] 				 =  "Interface\\Icons\\Spell_Nature_Rejuvenation"
mb_buffData["Regrowth"] 					 =  "Interface\\Icons\\Spell_Nature_ResistNature"
mb_buffData["Nature\'s Grace"] 				 =  "Interface\\Icons\\Spell_Nature_NaturesBlessing"
mb_buffData["Nature\'s Swiftness"]			 =  "Interface\\Icons\\Spell_Nature_RavenForm"
mb_buffData["Abolish Poison"] 				 =  "Interface\\Icons\\Spell_Nature_NullifyPoison_02"
mb_buffData["Innervate"] 					 =  "Interface\\Icons\\Spell_Nature_Lightning"
mb_buffData["Tranquility"] 					 =  "Interface\\Icons\\Spell_Nature_Tranquility"
mb_buffData["Barkskin"] 					 =  "Interface\\Icons\\Spell_Nature_StoneclawTotem"
mb_buffData["Thorns"] 						 =  "Interface\\Icons\\Spell_Nature_Thorns"
mb_buffData["Leader of the Pack"] 			 =  "Interface\\Icons\\Spell_Nature_UnyeildingStamina"
mb_buffData["Moonkin Aura"] 				 =  "Interface\\Icons\\Spell_Nature_MoonGlow"
mb_buffData["Moonkin Form"] 				 =  "Interface\\Icons\\Spell_Nature_ForceOfNature"
mb_buffData["Cat Form"]						 =  "Interface\\Icons\\Ability_Druid_CatForm"
mb_buffData["Bear Form"] 					 =  "Interface\\Icons\\Ability_Racial_BearForm"
mb_buffData["Dire Bear Form"] 				 =  "Interface\\Icons\\Ability_Racial_BearForm"
mb_buffData["Travel Form"] 					 =  "Interface\\Icons\\Ability_Druid_TravelForm"
mb_buffData["Aquatic Form"] 				 =  "Interface\\Icons\\Ability_Druid_AquaticForm"
mb_buffData["Prowl"] 						 =  "Interface\\Icons\\Ability_Ambush"
mb_buffData["Tiger\'s Fury"] 				 =  "Interface\\Icons\\Ability_Mount_JungleTiger"
mb_buffData["Dash"] 						 =  "Interface\\Icons\\Ability_Druid_Dash"
mb_buffData["Blessing of the Claw"] 		 =  "Interface\\Icons\\Spell_Holy_BlessingOfAgility"
mb_buffData["Nature\'s Grasp"] 				 =  "Interface\\Icons\\Spell_Nature_NaturesWrath"
mb_buffData["Omen of Clarity"] 				 =  "Interface\\Icons\\Spell_Nature_CrystalBall"
mb_buffData["Clearcasting"] 				 =  "Interface\\Icons\\Spell_Shadow_ManaBurn"
mb_buffData["Enrage"] 						 =  "Interface\\Icons\\Ability_Druid_Enrage"
mb_buffData["Frenzied Regeneration"]		 =  "Interface\\Icons\\Ability_BullRush"
mb_buffData["Growl"] 						 =  "Interface\\Icons\\Ability_Druid_Physical_Taunt"
mb_buffData["Pounce"] 						 =  "Interface\\Icons\\Ability_Druid_SupriseAttack"
mb_buffData["Rake"] 						 =  "Interface\\Icons\\Ability_Druid_Disembowel"
mb_buffData["Rip"] 							 =  "Interface\\Icons\\Ability_GhoulFrenzy"
mb_buffData["Moonfire"]						 =  "Interface\\Icons\\Spell_Nature_StarFall"
mb_buffData["Faerie Fire"] 					 =  "Interface\\Icons\\Spell_Nature_FaerieFire" 
mb_buffData["Faerie Fire (Feral)"]			 =  "Interface\\Icons\\Spell_Nature_FaerieFire"
mb_buffData["Hibernate"] 					 =  "Interface\\Icons\\Spell_Nature_Sleep"
mb_buffData["Insect Swarm"]					 =  "Interface\\Icons\\Spell_Nature_InsectSwarm"
mb_buffData["Entangling Roots"] 			 =  "Interface\\Icons\\Spell_Nature_StrangleVines"
mb_buffData["Starfire Stun"] 				 =  "Interface\\Icons\\Spell_Arcane_Starfire"
mb_buffData["Hurricane"] 					 =  "Interface\\Icons\\Spell_Nature_Cyclone"
mb_buffData["Soothe Animal"] 				 =  "Interface\\Icons\\Spell_Hunter_BeastSoothe"
mb_buffData["Bash"] 						 =  "Interface\\Icons\\Ability_Druid_Bash"
mb_buffData["Challenging Roar"] 			 =  "Interface\\Icons\\Ability_Druid_ChallangingRoar"
mb_buffData["Demoralizing Roar"] 			 =  "Interface\\Icons\\Ability_Druid_DemoralizingRoar"
--end of druidbuffs/debuffs
--start of magebuffs/debuffs
mb_buffData["Arcane Brilliance"] 			 =  "Interface\\Icons\\Spell_Holy_ArcaneIntellect"
mb_buffData["Arcane Intellect"] 			 =  "Interface\\Icons\\Spell_Holy_MagicalSentry"
mb_buffData["Dampen Magic"] 				 =  "Interface\\Icons\\Spell_Nature_AbolishMagic"
mb_buffData["Amplify Magic"]				 =  "Interface\\Icons\\Spell_Holy_FlashHeal"
mb_buffData["Ice Armor"] 					 =  "Interface\\Icons\\Spell_Frost_FrostArmor02"
mb_buffData["Mana Shield"] 					 =  "Interface\\Icons\\Spell_Shadow_DetectLesserInvisibility"
mb_buffData["Fire Ward"] 					 =  "Interface\\Icons\\Spell_Fire_FireArmor"
mb_buffData["Ice Block"] 					 =  "Interface\\Icons\\Spell_Frost_Frost"
mb_buffData["Ice Barrier"] 					 =  "Interface\\Icons\\Spell_Ice_Lament"
mb_buffData["Evocation"] 					 =  "Interface\\Icons\\Spell_Nature_Purge"
mb_buffData["Frost Ward"] 					 =  "Interface\\Icons\\Spell_Frost_FrostWard"
mb_buffData["Mage Armor"] 					 =  "Interface\\Icons\\Spell_MageArmor"
mb_buffData["Clearcasting"] 				 =  "Interface\\Icons\\Spell_Shadow_ManaBurn"
mb_buffData["Presence of Mind"] 			 =  "Interface\\Icons\\Spell_Nature_EnchantArmor"
mb_buffData["Combustion"] 					 =  "Interface\\Icons\\Spell_Fire_SealOfFire"
mb_buffData["Netherwind Focus"] 			 =  "Interface\\Icons\\Spell_Shadow_Teleport"
mb_buffData["Detect Magic"] 				 =  "Interface\\Icons\\Spell_Holy_Dizzy"
mb_buffData["Polymorph"] 					 =  "Interface\\Icons\\Spell_Nature_Polymorph"
mb_buffData["Frostbolt"] 					 =  "Interface\\Icons\\Spell_Frost_FrostBolt02"
mb_buffData["Frost Nova"] 					 =  "Interface\\Icons\\Spell_Frost_FrostNova"
mb_buffData["Frostbite"] 					 =  "Interface\\Icons\\Spell_Frost_FrostArmor"
mb_buffData["Scorch"] 						 =  "Interface\\Icons\\Spell_Fire_SoulBurn"
mb_buffData["Ignite"] 						 =  "Interface\\Icons\\Spell_Fire_Incinerate"
mb_buffData["Winter\'s Chill"] 				 =  "Interface\\Icons\\Spell_Frost_ChillingBlast"
mb_buffData["Arcane Power"] 				 =  "Interface\\Icons\\Spell_Nature_Lightning"
--end of magebuffs/debuffs
--start of warlockbuffs/debuffs
mb_buffData["Demon Skin"] 					 =  "Interface\\Icons\\Spell_Shadow_RagingScream"
mb_buffData["Demon Armor"] 					 =  "Interface\\Icons\\Spell_Shadow_RagingScream"
mb_buffData["Fire Shield"] 					 =  "Interface\\Icons\\Spell_Fire_FireArmor"
mb_buffData["Sacrifice"] 					 =  "Interface\\Icons\\Spell_Shadow_SacrificialShield"
mb_buffData["Underwater Breathing"] 		 =  "Interface\\Icons\\Spell_Shadow_DemonBreath"
mb_buffData["Eye of Kilrogg"]				 =  "Interface\\Icons\\Spell_Shadow_EvilEye"
mb_buffData["Nightfall"] 					 =  "Interface\\Icons\\Spell_Shadow_Twilight"
mb_buffData["Touch of Shadow"] 				 =  "Interface\\Icons\\Spell_Shadow_PsychicScream"
mb_buffData["Burning Wish"] 				 =  "Interface\\Icons\\Spell_Shadow_PsychicScream"
mb_buffData["Fel Stamina"] 					 =  "Interface\\Icons\\Spell_Shadow_PsychicScream"
mb_buffData["Fel Energy"] 					 =  "Interface\\Icons\\Spell_Shadow_PsychicScream"
mb_buffData["Shadow Ward"] 					 =  "Interface\\Icons\\Spell_Shadow_AntiShadow"
mb_buffData["Master Demonologist"] 			 =  "Interface\\Icons\\Spell_Shadow_ShadowPact"
mb_buffData["Soul Link"] 					 =  "Interface\\Icons\\Spell_Shadow_GatherShadows"
mb_buffData["Detect Lesser Invisibility"]	 =  "Interface\\Icons\\Spell_Shadow_DetectLesserInvisibility"
mb_buffData["Detect Invisibility"] 			 =  "Interface\\Icons\\Spell_Shadow_DetectInvisibility"
mb_buffData["Detect Greater Invisibility"] 	 =  "Interface\\Icons\\Spell_Shadow_DetectInvisibility"
mb_buffData["Soulstone"] 					 =  "Interface\\Icons\\Spell_Shadow_SoulGem"
mb_buffData["Blood Pact"] 					 =  "Interface\\Icons\\Spell_Shadow_BloodBoil"
mb_buffData["Paranoia"] 					 =  "Interface\\Icons\\Spell_Shadow_AuraOfDarkness"
mb_buffData["Phase Shift"] 					 =  "Interface\\Icons\\Spell_Shadow_ImpPhaseShift"
mb_buffData["Health Funnel"] 				 =  "Interface\\Icons\\Spell_Shadow_LifeDrain"
mb_buffData["Consume Shadows"] 				 =  "Interface\\Icons\\Spell_Shadow_AntiShadow"
mb_buffData["Lesser Invisibility"] 			 =  "Interface\\Icons\\Spell_Magic_LesserInvisibility"
mb_buffData["Corruption"] 					 =  "Interface\\Icons\\Spell_Shadow_AbominationExplosion"
mb_buffData["Immolate"] 					 =  "Interface\\Icons\\Spell_Fire_Immolation"
mb_buffData["Siphon Life"] 					 =  "Interface\\Icons\\Spell_Shadow_Requiem"
mb_buffData["Drain Life"] 					 =  "Interface\\Icons\\Spell_Shadow_LifeDrain02"
mb_buffData["Drain Soul"] 					 =  "Interface\\Icons\\Spell_Shadow_Haunting"
mb_buffData["Drain Mana"] 					 =  "Interface\\Icons\\Spell_Shadow_SiphonMana"
mb_buffData["Improved Shadow Bolt"] 		 =  "Interface\\Icons\\Spell_Shadow_ShadowBolt"
mb_buffData["Curse of Agony"] 				 =  "Interface\\Icons\\Spell_Shadow_CurseOfSargeras"
mb_buffData["Curse of Weakness"] 			 =  "Interface\\Icons\\Spell_Shadow_CurseOfMannoroth"
mb_buffData["Curse of Shadow"] 				 =  "Interface\\Icons\\Spell_Shadow_CurseOfAchimonde"
mb_buffData["Curse of the Elements"] 		 =  "Interface\\Icons\\Spell_Shadow_ChillTouch"
mb_buffData["Curse of Doom"] 				 =  "Interface\\Icons\\Spell_Shadow_AuraOfDarkness"
mb_buffData["Curse of Tongues"] 			 =  "Interface\\Icons\\Spell_Shadow_CurseOfTounges"
mb_buffData["Curse of Recklessness"] 		 =  "Interface\\Icons\\Spell_Shadow_UnholyStrength"
mb_buffData["Curse of Exhaustion"] 			 =  "Interface\\Icons\\Spell_Shadow_GrimWard"
mb_buffData["Enslave Demon"] 				 =  "Interface\\Icons\\Spell_Shadow_EnslaveDemon"
mb_buffData["Hellfire"] 					 =  "Interface\\Icons\\Spell_Fire_Incinerate"
mb_buffData["Fear"] 						 =  "Interface\\Icons\\Spell_Shadow_Possession"
mb_buffData["Banish"] 						 =  "Interface\\Icons\\Spell_Shadow_Cripple"
mb_buffData["Seduction"] 					 =  "Interface\\Icons\\Spell_Shadow_MindSteal"
mb_buffData["Tainted Blood"] 				 =  "Interface\\Icons\\Spell_Shadow_LifeDrain"
mb_buffData["Spell Lock"] 					 =  "Interface\\Icons\\Spell_Shadow_MindRot"
mb_buffData["Howl of Terror"] 				 =  "Interface\\Icons\\Spell_Shadow_DeathScream"
mb_buffData["Death Coil"] 					 =  "Interface\\Icons\\Spell_Shadow_DeathCoil"
--end of warlockbuffs/debuffs
--start of shamanbuffs/debuffs
mb_buffData["Frost Shock"] 					 =  "Interface\\Icons\\Spell_Frost_FrostShock"
mb_buffData["Flame Shock"] 					 =  "Interface\\Icons\\Spell_Fire_FlameShock"
mb_buffData["Stormstrike"] 					 =  "Interface\\Icons\\Spell_Holy_SealOfMight"
mb_buffData["Earthbind Totem"] 				 =  "Interface\\Icons\\Spell_Nature_StrengthhOfEarthTotem02"
mb_buffData["Strength of Earth Totem"] 		 =  "Interface\\Icons\\Spell_Nature_EarthBindTotem"
mb_buffData["Grace of Air Totem"] 			 =  "Interface\\Icons\\Spell_Nature_InvisibilityTotem"
mb_buffData["Mana Spring Totem"] 			 =  "Interface\\Icons\\Spell_Nature_ManaRegenTotem"
mb_buffData["Healing Stream Totem"] 		 =  "Interface\\Icons\\INV_Spear_04"
mb_buffData["Grounding Totem"] 				 =  "Interface\\Icons\\Spell_Nature_GroundingTotem"
mb_buffData["Mana Tide Totem"] 				 =  "Interface\\Icons\\Spell_Frost_SummonWaterElemental"
mb_buffData["Tranquil Air Totem"] 			 =  "Interface\\Icons\\Spell_Nature_Brilliance"
mb_buffData["Stoneskin Totem"] 				 =  "Interface\\Icons\\Spell_Nature_StoneSkinTotem"
mb_buffData["Frost Resistance Totem"] 		 =  "Interface\\Icons\\Spell_FrostResistanceTotem_01"
mb_buffData["Fire Resistance Totem"] 		 =  "Interface\\Icons\\Spell_FireResistanceTotem_01"
mb_buffData["Nature Resistance Totem"] 		 =  "Interface\\Icons\\Spell_Nature_NatureResistanceTotem"
mb_buffData["Windwall Totem"] 				 =  "Interface\\Icons\\Spell_Nature_EarthBind"
mb_buffData["Lightning Shield"] 			 =  "Interface\\Icons\\Spell_Nature_LightningShield"
mb_buffData["Healing Way"] 					 =  "Interface\\Icons\\Spell_Nature_HealingWay"
mb_buffData["Ancestral Fortitude"] 			 =  "Interface\\Icons\\Spell_Nature_UndyingStrength"
mb_buffData["Totemic Power"] 				 =  "Interface\\Icons\\Spell_Magic_MageArmor"
mb_buffData["Ghost Wolf"] 					 =  "Interface\\Icons\\Spell_Nature_SpiritWolf"
--end of shamanbuffs/debuffs
--start of hunterbuffs/debuffs
mb_buffData["Aspect of the Hawk"] 			 =  "Interface\\Icons\\Spell_Nature_RavenForm"
mb_buffData["Aspect of the Monkey"] 		 =  "Interface\\Icons\\Ability_Hunter_AspectOfTheMonkey"
mb_buffData["Aspect of the Cheetah"] 		 =  "Interface\\Icons\\Ability_Mount_JungleTiger"
mb_buffData["Aspect of the Pack"] 			 =  "Interface\\Icons\\Ability_Mount_WhiteTiger"
mb_buffData["Aspect of the Beast"] 			 =  "Interface\\Icons\\Ability_Mount_PinkTiger"
mb_buffData["Aspect of the Wild"] 			 =  "Interface\\Icons\\Spell_Nature_ProtectionformNature"
mb_buffData["Rapid Fire"] 					 =  "Interface\\Icons\\Ability_Hunter_RunningShot"
mb_buffData["Eyes of the Beast"] 			 =  "Interface\\Icons\\Ability_EyesOfTheOwl"
mb_buffData["Deterrence"] 					 =  "Interface\\Icons\\Ability_Whirlwind"
mb_buffData["Feed Pet"] 					 =  "Interface\\Icons\\Ability_Hunter_BeastTraining"
mb_buffData["Mend Pet"] 					 =  "Interface\\Icons\\Ability_Hunter_MendPet"
mb_buffData["Concussive Shot"] 				 =  "Interface\\Icons\\Spell_Frost_Stun"
mb_buffData["Hunter\'s Mark"] 				 =  "Interface\\Icons\\Ability_Hunter_SniperShot"
mb_buffData["Wing Clip"] 					 =  "Interface\\Icons\\Ability_Rogue_Trip"
mb_buffData["Serpent Sting"] 				 =  "Interface\\Icons\\Ability_Hunter_Quickshot"
mb_buffData["Scorpid Sting"] 				 =  "Interface\\Icons\\Ability_Hunter_CriticalShot"
mb_buffData["Viper Sting"] 					 =  "Interface\\Icons\\Ability_Hunter_AimedShot"
mb_buffData["Scatter Shot"] 				 =  "Interface\\Icons\\Ability_GolemStormBolt"
mb_buffData["Freezing Trap"] 				 =  "Interface\\Icons\\Spell_Frost_ChainsOfIce"
mb_buffData["Frost Trap"] 					 =  "Interface\\Icons\\Spell_Frost_FreezingBreath"
mb_buffData["Immolation Trap"] 				 =  "Interface\\Icons\\Spell_Fire_FlameShock"
mb_buffData["Explosive Trap"] 				 =  "Interface\\Icons\\Spell_Fire_SelfDestruct"
mb_buffData["Trueshot Aura"] 				 =  "Interface\\Icons\\Ability_TrueShot"
mb_buffData["Feign Death"] 					 =  "Interface\\Icons\\Ability_Rogue_FeignDeath"
mb_buffData["Screech"] 					 	 =  "Interface\\Icons\\Ability_Hunter_Pet_Bat"
--end of hunterbuffs/debuffs
--start of roguebuffs/debuffs
mb_buffData["Stealth"] 						 =  "Interface\\Icons\\Ability_Stealth"
mb_buffData["Vanish"] 						 =  "Interface\\Icons\\Ability_Vanish"
mb_buffData["Blade Flurry"] 				 =  "Interface\\Icons\\Ability_Warrior_PunishingBlow"
mb_buffData["Adrenaline Rush"] 				 =  "Interface\\Icons\\Spell_Shadow_ShadowWordDominate"
mb_buffData["SPrint"] 						 =  "Interface\\Icons\\Ability_Rogue_SPrint"
mb_buffData["Hemorrhage"] 					 =  "Interface\\Icons\\Spell_Shadow_Lifedrain"
mb_buffData["Gouge"] 						 =  "Interface\\Icons\\Ability_Gouge"
mb_buffData["Garrote"] 						 =  "Interface\\Icons\\Ability_Rogue_Garrote"
mb_buffData["Blind"] 						 =  "Interface\\Icons\\Spell_Shadow_MindSteal"
mb_buffData["Rupture"] 						 =  "Interface\\Icons\\Ability_Rogue_Rupture"
mb_buffData["Cheap Shot"] 					 =  "Interface\\Icons\\Ability_CheapShot"
mb_buffData["Kidney Shot"]					 =  "Interface\\Icons\\Ability_Rogue_KidneyShot"
mb_buffData["Sap"] 							 =  "Interface\\Icons\\Ability_Sap"
mb_buffData["Expose Armor"] 				 =  "Interface\\Icons\\Ability_Warrior_Riposte"
mb_buffData["Slice and Dice"] 				 =  "Interface\\Icons\\Ability_Rogue_SliceDice"
mb_buffData["Mace Stun"]					 =  "Interface\\Icons\\Spell_Frost_Stun"
--end of roguebuffs/debuffs
--start of warriorbuffs/debuffs
mb_buffData["Battle Shout"] 				 =  "Interface\\Icons\\Ability_Warrior_BattleShout"
mb_buffData["Taunt"] 						 =  "Interface\\Icons\\Spell_Nature_Reincarnation"
mb_buffData["Bloodrage"] 					 =  "Interface\\Icons\\Ability_Racial_BloodRage"
mb_buffData["Death Wish"] 					 =  "Interface\\Icons\\Spell_Shadow_DeathPact"
mb_buffData["Enraged"] 						 =  "Interface\\Icons\\Spell_Shadow_UnholyFrenzy"
mb_buffData["Flurry"] 						 =  "Interface\\Icons\\Ability_GhoulFrenzy"
mb_buffData["Recklessness"] 				 =  "Interface\\Icons\\Ability_CriticalStrike"
mb_buffData["Berserker Rage"] 				 =  "Interface\\Icons\\Spell_Nature_AncestralGuardian"
mb_buffData["Mocking Blow"] 				 =  "Interface\\Icons\\Ability_Warrior_PunishingBlow"
mb_buffData["Mortal Strike"] 				 =  "Interface\\Icons\\Ability_Warrior_SavageBlow"
mb_buffData["Thunder Clap"] 				 =  "Interface\\Icons\\Spell_Nature_ThunderClap"
mb_buffData["Piercing Howl"] 				 =  "Interface\\Icons\\Spell_Shadow_DeathScream"
mb_buffData["Hamstring"] 					 =  "Interface\\Icons\\Ability_ShockWave"
mb_buffData["Concussion Blow"] 				 =  "Interface\\Icons\\Ability_ThunderBolt"
mb_buffData["Demoralizing Shout"] 			 =  "Interface\\Icons\\Ability_Warrior_WarCry"
mb_buffData["Intimidating Shout"] 			 =  "Interface\\Icons\\Ability_GolemThunderClap"
mb_buffData["Sunder Armor"] 				 =  "Interface\\Icons\\Ability_Warrior_Sunder"
mb_buffData["Disarm"]						 =  "Interface\\Icons\\Ability_Warrior_Disarm"
mb_buffData["Sweeping Strikes"]				 =  "Interface\\Icons\\Ability_Rogue_SliceDice"
--end of warriorbuffs/debuffs
--start of paladinsbuffs/debuffs
mb_buffData["Devotion Aura"]   				 =  "Interface\\Icons\\Spell_Holy_DevotionAura" 
mb_buffData["Concentration Aura"] 			 =  "Interface\\Icons\\Spell_Holy_MindSooth"
mb_buffData["Fire Resistance Aura"]			 =  "Interface\\Icons\\Spell_Fire_SealOfFire"
mb_buffData["Frost Resistance Aura"]		 =  "Interface\\Icons\\Spell_Frost_WizardMark"
mb_buffData["Retribution Aura"]				 =  "Interface\\Icons\\Spell_Holy_AuraOfLight"
mb_buffData["Greater Blessing of Wisdom"]   = "Interface\\Icons\\Spell_Holy_GreaterBlessingofWisdom" 
mb_buffData["Greater Blessing of Kings"]	 =  "Interface\\Icons\\Spell_Magic_GreaterBlessingofKings" 
mb_buffData["Greater Blessing of Salvation"] =  "Interface\\Icons\\Spell_Holy_GreaterBlessingofSalvation" 
mb_buffData["Greater Blessing of Might"]    = "Interface\\Icons\\Spell_Holy_GreaterBlessingofKings" 
mb_buffData["Greater Blessing of Light"]    = "Interface\\Icons\\Spell_Holy_GreaterBlessingofLight" 
mb_buffData["Greater Blessing of Sanctuary"] =  "Interface\\Icons\\Spell_Holy_GreaterBlessingofSanctuary" 
mb_buffData["Hammer of Justice"] 			 =  "Interface\\Icons\\Spell_Holy_SealOfMight"
mb_buffData["Seal of Light"] 				 =  "Interface\\Icons\\Spell_Holy_HealingAura"
mb_buffData["Seal of Wisdom"]				 =  "Interface\\Icons\\Spell_Holy_RighteousnessAura"
mb_buffData["Judgement of Light"] 			 =  "Interface\\Icons\\Spell_Holy_HealingAura"
mb_buffData["Judgement of Wisdom"]			 =  "Interface\\Icons\\Spell_Holy_RighteousnessAura"
mb_buffData["Blessing of Protection"] 		 =  "Interface\\Icons\\Spell_Holy_SealOfProtection"
mb_buffData["Forbearance"] 					 =  "Interface\\Icons\\Spell_Holy_RemoveCurse"
mb_buffData["Divine Favor"]					 =  "Interface\\Icons\\Spell_Holy_Heal"
mb_buffData["Blinding Light"]				 =  "Interface\\Icons\\Spell_Holy_SearingLight"
mb_buffData["Seal of Righteousness"]		 =  "Interface\\Icons\\Ability_ThunderBolt"
--end of paladins
--start of racials
mb_buffData["Berserking"] 					 =  "Interface\\Icons\\Racial_Troll_Berserk"
mb_buffData["Blood Fury Debuff"] 			 =  "Interface\\Icons\\Ability_Rogue_FeignDeath"
mb_buffData["Blood Fury"] 					 =  "Interface\\Icons\\Racial_Orc_BerserkerStrength"
mb_buffData["War Stomp"] 					 =  "Interface\\Icons\\Ability_WarStomp"
mb_buffData["Cannibalize"] 					 =  "Interface\\Icons\\Ability_Racial_Cannibalize"
mb_buffData["Will of the Forsaken"] 		 =  "Interface\\Icons\\Spell_Shadow_RaiseDead"
--end of racials
--start of worldbuffs
mb_buffData["Warchief\'s Blessing"] 					 =  "Interface\\Icons\\Spell_Arcane_TeleportOrgrimmar"
mb_buffData["Rallying Cry of the Dragonslayer"] 	 =  "Interface\\Icons\\INV_Misc_Head_Dragon_01"
mb_buffData["Spirit of Zandalar"] 					 =  "Interface\\Icons\\Ability_Creature_Poison_05"
mb_buffData["Songflower Serenade"] 					 =  "Interface\\Icons\\Spell_Holy_MindVision"
mb_buffData["Sayge\'s Dark Fortune of Strength"] 	 =  "Interface\\Icons\\INV_Misc_Orb_02"
mb_buffData["Sayge\'s Dark Fortune of Damage"] 		 =  "Interface\\Icons\\INV_Misc_Orb_02"
mb_buffData["Sayge\'s Dark Fortune of Intelligence"] = "Interface\\Icons\\INV_Misc_Orb_02"
mb_buffData["Sayge\'s Dark Fortune of Agility"] 		 =  "Interface\\Icons\\INV_Misc_Orb_02"
mb_buffData["Sayge\'s Dark Fortune of Resistance"] 	 =  "Interface\\Icons\\INV_Misc_Orb_02"
mb_buffData["Sayge\'s Dark Fortune of Stamina"] 		 =  "Interface\\Icons\\INV_Misc_Orb_02"
mb_buffData["Sayge\'s Dark Fortune of Spirit"] 		 =  "Interface\\Icons\\INV_Misc_Orb_02"
mb_buffData["Sayge\'s Dark Fortune of Armor"] 		 =  "Interface\\Icons\\INV_Misc_Orb_02"
mb_buffData["Fengus\' Ferocity"] 					 =  "Interface\\Icons\\Spell_Nature_UndyingStrength"
mb_buffData["Mol\'dar\'s Moxie"] 						 =  "Interface\\Icons\\Spell_Nature_MassTeleport"
mb_buffData["Slip\'kik\'s Savvy"] 					 =  "Interface\\Icons\\Spell_Holy_LesserHeal02"
mb_buffData["Swiftness of Zanza"] 					 =  "Interface\\Icons\\INV_Potion_31"
mb_buffData["Spirit of Zanza"] 						 =  "Interface\\Icons\\INV_Potion_30"
mb_buffData["Recently Bandaged"] 					 =  "Interface\\Icons\\INV_Misc_Bandage_08"
mb_buffData["First Aid"] 							 =  "Interface\\Icons\\Spell_Holy_Heal"
mb_buffData["Frozen Rune"]							 =  "Interface\\Icons\\Spell_Fire_MasterOfElements"
mb_buffData["Shadow Protection Potion"]				 =  "Interface\\Icons\\Spell_Shadow_RagingScream"
--end of worldbuffs
--start of Random bosses stuff/buffs.
mb_buffData["Shadow Storm"] 				 =  "Interface\\Icons\\Spell_Shadow_ShadowBolt" --aq40 anubisaths BUFF
mb_buffData["Mana Burn"]					 =  "Interface\\Icons\\Spell_Shadow_ManaBurn" --aq40 anubisaths BUFF
mb_buffData["Fire and Arcane Reflect"] 		 =  "Interface\\Icons\\Spell_Arcane_Blink" --same icon, 
mb_buffData["Shadow and Frost Reflect"]		 =  "Interface\\Icons\\Spell_Arcane_Blink" --same icon, 
mb_buffData["Mending"] 						 =  "Interface\\Icons\\Spell_Nature_ResistNature" --aq40 anubisaths BUFF
mb_buffData["Periodic Knock Away"] 			 =  "Interface\\Icons\\Ability_UpgradeMoonglaive" --aq40 anubisaths BUFF
mb_buffData["Living Bomb"] 					 =  "Interface\\Icons\\INV_Enchant_EssenceAstralSmall" --Baron Bomb
mb_buffData["Burning Adrenaline"] 			 =  "Interface\\Icons\\INV_Gauntlets_03" --Vaelastrasz Bomb
mb_buffData["Brood Affliction: Bronze"] 	 =  "Interface\\Icons\\INV_Misc_Head_Dragon_Bronze" --Chromaggus bronze debuff
mb_buffData["Plague"] 						 =  "Interface\\Icons\\Spell_Shadow_CurseOfTounges" --aq20/40 anubisath plague debuff
mb_buffData["Drink"] 						 =  "Interface\\Icons\\INV_Drink_18" --LVL 55 water ONLY, not lvl 45 or below.
mb_buffData["Shadow Weakness"] 				 =  "Interface\\Icons\\INV_Misc_QirajiCrystal_05" --Ossirian Weakness
mb_buffData["Fire Weakness"] 				 =  "Interface\\Icons\\INV_Misc_QirajiCrystal_02" --Ossirian Weakness
mb_buffData["Nature Weakness"] 				 =  "Interface\\Icons\\INV_Misc_QirajiCrystal_03" --Ossirian Weakness
mb_buffData["Arcane Weakness"] 				 =  "Interface\\Icons\\INV_Misc_QirajiCrystal_01" --Ossirian Weakness
mb_buffData["Frost Weakness"] 				 =  "Interface\\Icons\\INV_Misc_QirajiCrystal_04" --Ossirian Weakness
mb_buffData["Magic Reflection"] 			 =  "Interface\\Icons\\Spell_Frost_FrostShock" --Magic Reflection on Major Domo adds
mb_buffData["Deaden Magic"] 				 =  "Interface\\Icons\\Spell_Holy_SealOfSalvation" --Shazzrah Deaden Magicc BUFF, can be dispelled.
mb_buffData["Corrupted Healing"] 			 =  "Interface\\Icons\\Spell_Shadow_Charm" --Nefarian Priestcall debuff, stop heal if have this debuff as priest.
mb_buffData["Delusions of Jin\'do"] 			 =  "Interface\\Icons\\Spell_Shadow_UnholyFrenzy" --Jindo shade debuff, do not decurse.
mb_buffData["Threatening Gaze"] 			 =  "Interface\\Icons\\Spell_Shadow_Charm" --Broodlord's Threatening gaze.
mb_buffData["True Fulfillment"] 			 =  "Interface\\Icons\\Spell_Shadow_Charm" --Skerams mindcontrol.
mb_buffData["Nature Protection Potion"] 	 =  "Interface\\Icons\\Spell_Nature_SpiritArmor"
mb_buffData["Fire Protection Potion"] 		 =  "Interface\\Icons\\Spell_Fire_FireArmor"
mb_buffData["Aura of Agony"]				 =  "Interface\\Icons\\Spell_Shadow_CurseOfSargeras"
mb_buffData["Corruption of the Earth"]		 =  "Interface\\Icons\\Ability_Creature_Cursed_03"
mb_buffData["Atiesh"] 						 =  "Interface\\Icons\\Spell_Nature_MoonGlow"
mb_buffData["Hazza\'rah\'s Charm of Healing"] = "Interface\\Icons\\Spell_Holy_HealingAura"
mb_buffData["Magma Shackles"] 				 =  "Interface\\Icons\\Spell_Nature_EarthBind" --Garr's Slowing effect
mb_buffData["Corrupted Mind"]				 =	"Interface\\Icons\\Spell_Shadow_AuraOfDarkness" -- Loatheb
mb_buffData["Fungal Bloom"]					 =  "Interface\\Icons\\Spell_Nature_UnyeildingStamina" -- Buff Loatheb
mb_buffData["Impending Doom"]				 =  "Interface\\Icons\\Spell_Shadow_NightOfTheDead"
mb_buffData["Inevitable Doom"]				 =  "Interface\\Icons\\Spell_Shadow_NightOfTheDead"
--mb_buffData[""] = "Interface\\Icons\\"
--Consumables
mb_buffData["Greater Stoneshield Potion"] 	 = "Interface\\Icons\\INV_Potion_69" 
mb_buffData["Mind Exhaustion"] 				 = "Interface\\Icons\\Spell_Shadow_Teleport" 
mb_buffData["Blessed Sunfruit Juice"] 		 = "Interface\\Icons\\Spell_Holy_Layonhands"
mb_buffData["Blessed Sunfruit"] 			 = "Interface\\Icons\\Spell_Holy_Devotion"
mb_buffData["Spell Vulnerability"]			 = "Interface\\Icons\\Spell_Holy_Elunesgrace"
mb_buffData["Shadow Protection"]			 = "Interface\\Icons\\Spell_Shadow_RagingScream"
mb_buffData["Mutating Injection"]			 = "Interface\\Icons\\Spell_Shadow_CallofBone"
mb_buffData["Juju Ember"]			 		 = "Interface\\Icons\\INV_Misc_MonsterScales_15"
mb_buffData["Shadow Command"] 				 =  "Interface\\Icons\\Spell_Shadow_UnholyFrenzy"

mb_buffData["Elixir of Greater Firepower"] 			 =  "Interface\\Icons\\INV_Potion_60"
mb_buffData["Greater Arcane Elixir"] 				 =  "Interface\\Icons\\INV_Potion_25"
mb_buffData["Elixir of Shadow Power"] 				 =  "Interface\\Icons\\INV_Potion_46"
mb_buffData["Brilliant Wizard Oil"] 				 =  "Interface\\Icons\\INV_Potion_105"
mb_buffData["Brilliant Mana Oil"] 				 =  "Interface\\Icons\\INV_Potion_100"
mb_buffData["Juju Power"] 				 =  "Interface\\Icons\\INV_Misc_MonsterScales_11"
mb_buffData["Juju Might"] 				 =  "Interface\\Icons\\INV_Misc_MonsterScales_07"
mb_buffData["Elemental Sharpening Stone"] 				 =  "Interface\\Icons\\INV_Stone_02"
mb_buffData["Increased Stamina"] 				 =  "Interface\\Icons\\INV_Boots_Plate_03"
mb_buffData["Well Fed"] 				 =  "Interface\\Icons\\INV_Misc_Food"
mb_buffData["Increased Intellect"] 				 =  "Interface\\Icons\\INV_Misc_Organ_03"
mb_buffData["Evil Twin"] 				 =  "Interface\\Icons\\Spell_Shadow_Charm"

function mb_hasWeaponBuff(obuff, unit)
	local buff = strlower(obuff);
	local tooltip = MMBTooltip;
	local textleft1 = getglobal(tooltip:GetName().."TextLeft1");
	if not unit then
		unit  = "player";
	end
	local my, me, mc, oy, oe, oc = GetWeaponEnchantInfo();
	if my then
		tooltip:SetOwner(UIParent, "ANCHOR_NONE");
		tooltip:SetInventoryItem( unit, 16);
		for i = 1, 23 do
			local text = getglobal("MMBTooltipTextLeft"..i):GetText();
			if not text then
				break;
			elseif strfind(strlower(text), buff) then
				tooltip:Hide();
				local metime = me/1000
				return text, metime, mc
			end
		end
		tooltip:Hide();
	elseif oy then
		tooltip:SetOwner(UIParent, "ANCHOR_NONE");
		tooltip:SetInventoryItem( unit, 17);
		for i = 1, 23 do
			local text = getglobal("MMBTooltipTextLeft"..i):GetText();
			if not text then
				break;
			elseif strfind(strlower(text), buff) then
				tooltip:Hide();
				local oetime = oe/1000
				return text, oetime, oc;
			end
		end
		tooltip:Hide();
	end
	tooltip:Hide();
end

function mb_hasBuffNamed(obuff, unit) --buffed stolen from Supermacro and "fixed" so it scans 32 buffs and not only 16. slower than iconpath, but nessesary when theres buffs with multiple icons (like renew)
	local buff = strlower(obuff);
	local tooltip = MMBTooltip;
	local textleft1 = getglobal(tooltip:GetName().."TextLeft1");
	if not unit then
		unit  = "player";
	end
	local c = nil;
	for i = 1, 32 do
		tooltip:SetOwner(UIParent, "ANCHOR_NONE");
		tooltip:SetUnitBuff(unit, i);
		b = textleft1:GetText();
		tooltip:Hide();
		if ( b and strfind(strlower(b), buff) ) then
			return "buff", i, b;
		elseif ( c == b ) then
			break;
		end
	end
	c = nil;
	for i = 1, 16 do
		tooltip:SetOwner(UIParent, "ANCHOR_NONE");
		tooltip:SetUnitDebuff(unit, i);
		b = textleft1:GetText();
		tooltip:Hide();
		if ( b and strfind(strlower(b), buff) ) then
			return "debuff", i, b;
		elseif ( c == b) then
			break;
		end
	end
	tooltip:Hide();
end

function mb_hasBuffOrDebuff(spell, target, buffordebuff)
	if (spell == "Windfury" or spell == "Windfury Totem 3" or spell == "Windfury Weapon" or spell == "Windfury Totem") then
		return mb_hasWeaponBuff(spell, target)
	end
	if buffordebuff == "buff" then
		for k, v in pairs(mb_buffData) do
			if k == spell then 
				return mb_buffCheck(v, target) 
			end
		end
	elseif buffordebuff == "debuff" then
		for k, v in pairs(mb_buffData) do
			if k == spell then 
				return mb_debuffCheck(v, target) 
			end
		end
	end
end

function mb_hasDebuff(spell, target)
	for k, v in pairs(mb_buffData) do
		if spell == k then 
			return mb_debuffCheck(v, target) 
		end
	end
end

function mb_buffCheck(text, target)
	local i = 1
	local buff = UnitBuff(target, i)

	while buff do
		if buff == text then
			return true
		end
		i = i + 1
		buff = UnitBuff(target, i)
	end
	return false
end

function mb_returnBuffIcon()
	local i = 1
	local buff = UnitBuff("player", i)

	while buff do
		Print(buff)
		i = i + 1
		buff = UnitBuff("player", i)
	end
end

function mb_returnDebuffIcon()
	local i = 1
	local buff = UnitDebuff("player", i)

	while buff do
		Print(buff)
		i = i + 1
		buff = UnitDebuff("player", i)
	end
end

function mb_debuffCheck(text, target)
	local i = 1
	local buff = UnitDebuff(target, i)

	while buff do
		if buff == text then
			return true
		end
		i = i + 1
		buff = UnitDebuff(target, i)
	end
	return false
end

function mb_mandokirGaze()
	if mb_hasBuffOrDebuff("Threatening Gaze", "player", "debuff") then
		
		if mb_imBusy() then
				
			SpellStopCasting()
			return
		end

		TargetUnit("player")
		return true
	end
	return false
end

function mb_razorgoreOrb()
	if mb_hasBuffOrDebuff("Mind Exhaustion", "player", "debuff") then
		return true
	end
	return false
end

function mb_isAtRazorgore()
	if GetSubZoneText() == "Dragonmaw Garrison" then 
		return true 
	end
end

function mb_someoneInRaidBuffedWith(spell)
	if UnitIsDead("player") or UnitIsGhost("player") then return end
	local n = GetNumRaidMembers() 

	for i = 1, n do				
		if UnitName("raid"..i) and mb_isAlive("raid"..i) and mb_hasBuffOrDebuff(spell, "raid"..i, "buff") then
			return true
		end
	end
end

function mb_multiBuff(spell)
	local n, r

	if UnitInRaid("player") then

		if spell == "Gift of the Wild" then mb_multiBuffMotw(spell) return end
		if spell == "Arcane Brilliance" then mb_multiBuffAI(spell) return end

		if (spell == "Prayer of Spirit" or spell == "Prayer of Fortitude" or spell == "Prayer of Shadow Protection" or spell == "Fear Ward") then mb_multiBuffPriest(spell) return end
		
		n = GetNumRaidMembers()
		r = math.random(n)-1

		for i = 1, n do
			j = i + r
			if j > n then j = j - n end	
			if mb_isValidFriendlyTarget("raid"..j, spell) and not mb_hasBuffOrDebuff(spell, "raid"..j, "buff") then

				ClearTarget()
				CastSpellByName(spell, false)
				SpellTargetUnit("raid"..j)
				SpellStopTargeting()
				return
			end
		end

	elseif UnitInParty("player") then
		n = GetNumPartyMembers()

		for i = 1, n do
			if mb_isValidFriendlyTarget("party"..i, spell) and not mb_hasBuffOrDebuff(spell, "party"..i, "buff") then
				
				TargetUnit("party"..i)
				CastSpellByName(spell)
				ClearTarget();
				return
			end
		end

		if not mb_dead("player") and not mb_hasBuffOrDebuff(spell, "player", "buff") then
			
			TargetUnit("player")
			CastSpellByName(spell)
			ClearTarget();
			return
		end
	end
end

function mb_multiBuffMotw(spell)
	local n, r
	n = GetNumRaidMembers()
	r = math.random(n)-1

	for i = 1, n do
		j = i + r
		if j > n then j = j - n end	
		if mb_isValidFriendlyTarget("raid"..j, spell) and not (mb_hasBuffOrDebuff(spell, "raid"..j, "buff") or mb_hasBuffOrDebuff("Mark of the Wild", "raid"..j, "buff")) then
				
			ClearTarget()
			CastSpellByName(spell, false)
			SpellTargetUnit("raid"..j)
			SpellStopTargeting()
			return
		end
	end
end

function mb_multiBuffAI(spell)
	local n, r
	n = GetNumRaidMembers()
	r = math.random(n)-1

	for i = 1, n do
		j = i + r
		if j > n then j = j - n end	
		if mb_isValidFriendlyTarget("raid"..j, spell) and not (UnitClass("raid"..j) == "Warrior" or UnitClass("raid"..j) == "Rogue") and not (mb_hasBuffOrDebuff(spell, "raid"..j, "buff") or mb_hasBuffOrDebuff("Arcane Intellect", "raid"..j, "buff")) then
			
			ClearTarget()
			CastSpellByName(spell, false)
			SpellTargetUnit("raid"..j)
			SpellStopTargeting()
			return
		end
	end
end

function mb_multiBuffPriest(spell)
	local n, r
	n = GetNumRaidMembers()
	r = math.random(n)-1

	if spell == "Prayer of Fortitude" then

		for i = 1, n do
			j = i + r
			if j > n then j = j - n end	
			if mb_isValidFriendlyTarget("raid"..j, spell) and not (mb_hasBuffOrDebuff(spell, "raid"..j, "buff") or mb_hasBuffOrDebuff("Power Word: Fortitude", "raid"..j, "buff")) then
				
				ClearTarget()
				CastSpellByName(spell, false)
				SpellTargetUnit("raid"..j)
				SpellStopTargeting()
				return
			end
		end

	elseif spell == "Prayer of Shadow Protection" then

		for i = 1, n do
			j = i + r
			if j > n then j = j - n end	
			if mb_isValidFriendlyTarget("raid"..j, spell) and not (mb_hasBuffOrDebuff(spell, "raid"..j, "buff") or mb_hasBuffOrDebuff("Shadow Protection", "raid"..j, "buff")) then
				
				ClearTarget()
				CastSpellByName(spell, false)
				SpellTargetUnit("raid"..j)
				SpellStopTargeting()
				return
			end
		end

	elseif spell == "Prayer of Spirit" then

		for i = 1, n do
			j = i + r
			if j > n then j = j - n end	
			if mb_isValidFriendlyTarget("raid"..j, spell) and not (UnitClass("raid"..j) == "Warrior" or UnitClass("raid"..j) == "Rogue") and not (mb_hasBuffOrDebuff(spell, "raid"..j, "buff") or mb_hasBuffOrDebuff("Divine Spirit", "raid"..j, "buff")) then
				
				ClearTarget()
				CastSpellByName(spell, false)
				SpellTargetUnit("raid"..j)
				SpellStopTargeting()
				return
			end
		end

	elseif spell == "Fear Ward" then

		for i = 1, n do
			j = i + r
			if j > n then j = j - n end	
			if mb_isValidFriendlyTarget("raid"..j, spell) and not mb_hasBuffOrDebuff(spell, "raid"..j, "buff") then
				
				ClearTarget()
				CastSpellByName(spell, false)
				SpellTargetUnit("raid"..j)
				SpellStopTargeting()
				return
			end
		end
	end
end

function mb_multiBuffBlessing(spell)

	local n, r

	if UnitInRaid("player") then
		n = GetNumRaidMembers()
		r = math.random(n)-1

		for i = 1, n do
			j = i + r
			if j > n then j = j - n end	

			if (spell == "Greater Blessing of Wisdom" or spell == "Greater Blessing of Might") then
				
				if UnitPowerType("raid"..j) == 0 then -- Mana User
					
					spell = "Greater Blessing of Wisdom" 
				end

				if (UnitPowerType("raid"..j) == 1 or UnitPowerType("raid"..j) == 3) then -- Rage / Energy users

					spell = "Greater Blessing of Might"					
				end
			end

			if (spell == "Greater Blessing of Salvation") then

				if mb_isValidFriendlyTarget("raid"..j) and not mb_hasBuffOrDebuff(spell, "raid"..j, "buff") and not mb_findInTable(MB_raidTanks, UnitName("raid"..j)) then
				
					ClearTarget()
					CastSpellByName(spell, false)
					SpellTargetUnit("raid"..j)
					SpellStopTargeting()
					return
				end
				return
			end

			if mb_isValidFriendlyTarget("raid"..j) and not mb_hasBuffOrDebuff(spell, "raid"..j, "buff") then
				
				ClearTarget()
				CastSpellByName(spell, false)
				SpellTargetUnit("raid"..j)
				SpellStopTargeting()
				return
			end
		end
		
	elseif UnitInParty("player") then
		n = GetNumPartyMembers()

		for i = 1, n do

			if (spell == "Greater Blessing of Wisdom" or spell == "Greater Blessing of Might") then
				
				if UnitPowerType("party"..i) == 0 then  -- Mana User
					
					spell = "Greater Blessing of Wisdom" 
				end

				if UnitPowerType("party"..i) == 1 or UnitPowerType("party"..i) == 3 then -- Rage / Energy users
					
					spell = "Greater Blessing of Might" 
				end
			end
			
			if mb_isValidFriendlyTarget("party"..i) and not mb_hasBuffOrDebuff(spell, "party"..i, "buff") then
				
				TargetUnit("party"..i)
				CastSpellByName(spell)
				ClearTarget()
				return
			end
		end

		if not mb_dead("player") and not mb_hasBuffOrDebuff(spell, "player", "buff") then
			TargetUnit("player")
			CastSpellByName(spell)
			ClearTarget()
			return
		end
	end
end

function mb_selfBuff(spell)
	if mb_knowSpell(spell) and mb_spellReady(spell) and not mb_hasBuffOrDebuff(spell, "player", "buff") then
		CastSpellByName(spell, 1)
	end
end

function mb_tankBuff(spell)
	
	for k, tank in pairs(MB_raidTanks) do
		if mb_isValidFriendlyTarget(MBID[tank], spell) and not mb_hasBuffOrDebuff(spell, MBID[tank], "buff") then
			
			--mb_message("Buffing "..UnitName(MBID[tank]).." with "..spell)

			CastSpellByName(spell, false)
			SpellTargetUnit(MBID[tank])
			SpellStopTargeting()
		end
	end
end

function mb_meleeBuff(spell)

	for k, rogue in pairs(MB_classList["Rogue"]) do
		if mb_isValidFriendlyTarget(MBID[rogue], spell) and not mb_hasBuffOrDebuff(spell, MBID[rogue], "buff") then
			
			--mb_message("Buffing "..UnitName(MBID[rogue]).." with "..spell)

			CastSpellByName(spell, false)
			SpellTargetUnit(MBID[rogue])
			SpellStopTargeting()
			return true
		end		
	end

	for k, tank in pairs(MB_raidTanks) do
		if mb_isValidFriendlyTarget(MBID[tank], spell) and not mb_hasBuffOrDebuff(spell, MBID[tank], "buff") then
			
			--mb_message("Buffing "..UnitName(MBID[tank]).." with "..spell)

			CastSpellByName(spell, false)
			SpellTargetUnit(MBID[tank])
			SpellStopTargeting()
			return true
		end
	end

	if spell == "Abolish Poison" then

		for k, warr in pairs(MB_classList["Warrior"]) do
			if mb_isValidFriendlyTarget(MBID[warr], spell) and not mb_hasBuffOrDebuff(spell, MBID[warr], "buff") then
				
				--mb_message("Buffing "..UnitName(MBID[warr]).." with "..spell)
	
				CastSpellByName(spell, false)
				SpellTargetUnit(MBID[warr])
				SpellStopTargeting()
				return true
			end		
		end
	end
end

function mb_debuffShadowWeavingAmount()
	for debuffIndex = 1, 16 do
		local debuffTexture, debuffApplications, debuffDispelType = UnitDebuff("target", debuffIndex)
		if debuffTexture == "Interface\\Icons\\Spell_Shadow_BlackPlague" and debuffDispelType == "Magic" then
			return debuffApplications
		end
	end
	return 0
end

function mb_debuffSunderAmount()
	for debuffIndex = 1, 16 do
		local debuffTexture, debuffApplications, debuffDispelType = UnitDebuff("target", debuffIndex)
		if debuffTexture == "Interface\\Icons\\Ability_Warrior_Sunder" then
			return debuffApplications
		end
	end
	return 0
end

function mb_debuffAmountShatter()
	for debuffIndex = 1, 16 do
		local debuffTexture, debuffApplications, debuffDispelType = UnitDebuff("target", debuffIndex)
		if debuffTexture == "Interface\\Icons\\INV_Axe_12" then
			return debuffApplications
		end
	end
	return 0
end

function mb_debuffWintersChillAmount()
	for debuffIndex = 1, 16 do
		local debuffTexture, debuffApplications, debuffDispelType = UnitDebuff("target", debuffIndex)
		if debuffTexture == "Interface\\Icons\\Spell_Frost_ChillingBlast" and debuffDispelType == "Magic" then
			return debuffApplications
		end
	end
	return 0
end

function mb_debuffShadowBoltAmount()
	for debuffIndex = 1, 16 do
		local debuffTexture, debuffApplications, debuffDispelType = UnitDebuff("target", debuffIndex)
		if (debuffTexture == "Interface\\Icons\\Spell_Shadow_ShadowBolt") and debuffDispelType == "Magic" then
			return debuffApplications
		end
	end
	return 0
end

function mb_debuffScorchAmount()
	for debuffIndex = 1, 16 do
		local debuffTexture, debuffApplications, debuffDispelType = UnitDebuff("target", debuffIndex)
		if debuffTexture == "Interface\\Icons\\Spell_Fire_SoulBurn" and debuffDispelType == "Magic" then
			return debuffApplications
		end
	end
	return 0
end

function mb_debuffIgniteAmount() 
	local DebuffID = 1;
	while (UnitDebuff("target", DebuffID)) do
		if (string.find(UnitDebuff("target", DebuffID), "Spell_Fire_Incinerate")) then
			_, IgniteStacks = UnitDebuff("target", DebuffID);
			return IgniteStacks;
		end
		DebuffID = DebuffID + 1;
	end
	return 0
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
	MB_warriorbinds = nil
end

function mb_furyGear() --/script mb_furyGear()
	mb_equipSet("DPS")
	MB_mySpecc = "BT"
	MB_warriorbinds = "Fury"
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

function mb_setAttackButton() -- Set Melee, Ranged and Wand attack slots

	if myClass == "Rogue" or myClass == "Warrior" or (myClass == "Druid" and MB_mySpecc == "Feral") or myClass == "Hunter" or myClass == "Paladin" then

		MB_attackSlot = nil

		for i = 1, 132 do
			MMBTooltip:SetOwner(UIParent, "ANCHOR_NONE")
			MMBTooltip:SetAction(i)

			if MMBTooltipTextLeft1:GetText() == "Attack" then
				MB_attackSlot = i
				break 
			end
		end

		if not MB_attackSlot then mb_message("No Auto-Attack on my bars.") end
	end

	if myClass == "Mage" or myClass == "Warlock" or myClass == "Priest" then

		MB_attackWandSlot = nil

		for i = 1, 132 do
			MMBTooltip:SetOwner(UIParent, "ANCHOR_NONE")
			MMBTooltip:SetAction(i)

			if MMBTooltipTextLeft1:GetText() == "Shoot" then
				MB_attackWandSlot = i
				break 
			end
		end

		if not MB_attackWandSlot then mb_message("No Shoot on my bars.") end
	end

	if myClass == "Hunter" then

		MB_attackRangedSlot = nil

		for i = 1, 132 do
			MMBTooltip:SetOwner(UIParent, "ANCHOR_NONE")
			MMBTooltip:SetAction(i)

			if MMBTooltipTextLeft1:GetText() == "Auto Shot" then
				MB_attackRangedSlot = i
				break 
			end
		end

		if not MB_attackRangedSlot then mb_message("No Ranged Auto-Attack on my bars.") end
	end
end

function mb_mySpecc() -- Speccs
	local TalentsIn
	local TalentsInA

	if myClass == "Rogue" then

		_, _, _, _, TalentsIn = GetTalentInfo(1, 8)
		if TalentsIn == 2 then

			MB_hasImprovedEA = true
		end

		_, _, _, _, TalentsIn = GetTalentInfo(3, 15)
		if TalentsIn > 0 then 

			MB_mySpecc = "Hemo"
			return 
		end

		_, _, _, _, TalentsIn = GetTalentInfo(2, 4)
		if TalentsIn > 2 then 

			MB_mySpecc = "Dagger"
			return 
		end

		_, _, _, _, TalentsIn = GetTalentInfo(2, 19)
		if TalentsIn > 0 then 

			MB_mySpecc = "AR"
			return 
		end
	end

	if myClass == "Mage" then

		_, _, _, _, TalentsIn = GetTalentInfo(3, 16)
		if TalentsIn > 0 then 

			MB_mySpecc = "Frost"
			return 
		end

		_, _, _, _, TalentsIn = GetTalentInfo(2, 16)
		if TalentsIn > 0 then

			MB_mySpecc = "Fire"
			return 
		end

		_, _, _, _, TalentsIn = GetTalentInfo(1, 16)
		_, _, _, _, TalentsInA = GetTalentInfo(2, 8)
		if TalentsIn > 0 and TalentsInA > 0 then 

			MB_mySpecc = "Fire"
			return 
		end	

		_, _, _, _, TalentsIn = GetTalentInfo(1, 16)
		_, _, _, _, TalentsInA = GetTalentInfo(3, 8)
		if TalentsIn > 0 and TalentsInA > 1 then 

			MB_mySpecc = "Frost"
			return 
		end	
	end

	if myClass == "Warlock" then

		_, _, _, _, TalentsIn = GetTalentInfo(2, 13)
		_, _, _, _, TalentsInA = GetTalentInfo(3, 8)
		if TalentsIn > 0 and TalentsInA > 0 then 

			MB_mySpecc = "Shadowburn"
			return 
		end

		_, _, _, _, TalentsIn = GetTalentInfo(1, 11)
		if TalentsIn > 0 then 

			MB_mySpecc = "Corruption"
			return 
		end	
	end

	if myClass == "Priest" then

		_, _, _, _, TalentsIn = GetTalentInfo(2, 10)
		_, _, _, _, TalentsInA = GetTalentInfo(3, 11)
		if TalentsIn > 0 and TalentsInA > 3 then 

			MB_mySpecc = "Bitch"
			return 
		end

		_, _, _, _, TalentsIn = GetTalentInfo(1, 15)
		_, _, _, _, TalentsInA = GetTalentInfo(3, 11)
		if TalentsIn > 0 and TalentsInA == 5 then 

			MB_mySpecc = "Bitch"
			return 
		end

		_, _, _, _, TalentsIn = GetTalentInfo(3, 16)
		if TalentsIn > 0 then

			MB_mySpecc = "Shadow"
			return 
		end	
	end

	if myClass == "Warrior" then

		_, _, _, _, TalentsIn = GetTalentInfo(1, 5)
		if TalentsIn >= 3 then

			MB_hasTacMastery = true
		end

		_, _, _, _, TalentsIn = GetTalentInfo(2, 17)
		_, _, _, _, TalentsInA = GetTalentInfo(3, 9)
		if TalentsIn > 0 and TalentsInA > 4 then 

			MB_mySpecc = "Furytank"
			return 
		end	

		_, _, _, _, TalentsIn = GetTalentInfo(1, 18)
		if TalentsIn > 0 then 

			MB_mySpecc = "MS"
			return 
		end

		_, _, _, _, TalentsIn = GetTalentInfo(2, 17)
		if TalentsIn > 0 then

			MB_mySpecc = "BT"
			return 
		end

		_, _, _, _, TalentsIn = GetTalentInfo(3, 17)
		if TalentsIn > 0 then

			MB_mySpecc = "Prottank"
			return 
		end

	end

	if myClass == "Druid" then

		_, _, _, _, TalentsIn = GetTalentInfo(3, 15)
		if TalentsIn > 0 then

			MB_mySpecc = "Swiftmend"
			return 
		end

		_, _, _, _, TalentsIn = GetTalentInfo(2, 16)
		if TalentsIn > 0 then 

			MB_mySpecc = "Feral"
			return 
		end

		_, _, _, _, TalentsIn = GetTalentInfo(3, 3)
		if TalentsIn > 4 then

			MB_mySpecc = "Resto"
			return 
		end
	end

	if myClass == "Shaman" then
		
		_, _, _, _, TalentsIn = GetTalentInfo(3, 13)
		_, _, _, _, TalentsInA = GetTalentInfo(3, 15)
		if TalentsIn > 0 and TalentsInA > 0 then 
			
			MB_mySpecc = "Deep Resto"
			return 
		end

		_, _, _, _, TalentsIn = GetTalentInfo(3, 13)
		_, _, _, _, TalentsInA = GetTalentInfo(2, 12)
		if TalentsIn > 0 and TalentsInA > 1 then 
			
			MB_mySpecc = "Totem Resto"
			return 
		end	
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
----------------------------------------------- Single! ----------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_single() -- Single Code

	if not MB_raidLeader and (TableLength(MBID) > 1) then Print("WARNING: You have not chosen a raid leader") end -- No RaidLeader Alert

	if mb_dead("player") then return end -- Stop when ur dead

	if mb_hasBuffNamed("Mind Control", "player") then  -- Stop all when ur MC'ing
	
		if (mb_tankTarget("Instructor Razuvious") and mb_myNameInTable(MB_myRazuviousPriest)) and MB_myRazuviousBoxStrategy then

			mb_doRazuviousActions()
		
		elseif (mb_tankTarget("Grand Widow Faerlina") and mb_myNameInTable(MB_myFaerlinaPriest)) and MB_myFaerlinaBoxStrategy then	
			
			mb_doFaerlinaActions()
		end
		return
	end
	
	if (mb_hasBuffOrDebuff("First Aid", "player", "buff") and mb_hasBuffOrDebuff("Recently Bandaged", "player", "debuff")) then return end -- Stop all when you are using a bandage

	if (mb_isAtRazorgore() and (myName == mb_returnPlayerInRaidFromTable(MB_myRazorgoreORBtank))) and not mb_tankTarget("Razorgore the Untamed") then mb_orbControlling() return end -- Stop when your controlling the ORB

	if GetRealZoneText() == "Zul\'Gurub" then 

		if mb_mandokirGaze() then return end -- Stop ALL when Gaze

	elseif GetRealZoneText() == "Ruins of Ahn\'Qiraj" then 

		mb_autoAssignBanishOnMoam() -- Auto assign adds on Moam
	end

	if not (myClass == "Warrior" or myClass == "Rogue") then -- Reequip ur staff
		
		mb_reEquipAtieshIfNoAtieshBuff()
	end

	if mb_itemNameOfEquippedSlot(16) == nil then -- No weps equip, notify it
		
		mb_message("I don\'t have a weapon equipped.", 500)
	end

	mb_GTFO() -- GTFO

	-- mb_takeHealthPotion() -- Health pots

	if mb_inCombat("player") and mb_stunnableMob() and mb_inMeleeRange() then -- Warstomps
		if mb_knowSpell("War Stomp") and mb_spellReady("War Stomp") then
			
			if not mb_isDruidShapeShifted() then
				
				CastSpellByName("War Stomp")
			end
		end
	end

	if GetRealZoneText() == "Onyxia\'s Lair" and MB_myOnyxiaBoxStrategy then

		if mb_tankTarget("Onyxia") then
			
			if myName == MB_myOnyxiaMainTank then

				if myClass == "Shaman" then mb_shamanSingle() return end
				if myClass == "Rogue" then mb_rogueSingle() return end
				if myClass == "Warrior" then mb_warriorSingle() return end
				if myClass == "Warlock" then mb_warlockSingle() return end
				if myClass == "Druid" then mb_druidSingle() return end
				if myClass == "Hunter" then mb_hunterSingle() return end
				if myClass == "Paladin" then mb_paladinSingle() return end
				MB_mySingleList[myClass]()
				return
			end
			
			if myClass == "Shaman" then mb_shamanSingle() return end
			if myClass == "Rogue" then mb_rogueMulti() return end
			if myClass == "Warrior" then mb_warriorMulti() return end
			if myClass == "Warlock" then mb_warlockSingle() return end
			if myClass == "Druid" then mb_druidSingle() return end
			if myClass == "Hunter" then mb_hunterSingle() return end
			if myClass == "Paladin" then mb_paladinSingle() return end
			MB_mySingleList[myClass]()
		end
						
	elseif GetRealZoneText() == "Ahn\'Qiraj" then -- AQ40 Mode

		if mb_isAtSartura() then -- When @ Sarturna

			if IsAltKeyDown() and mb_imHealer() then return end -- Stop healers when ALT down

			if myClass == "Shaman" then mb_shamanSingle() return end
			if myClass == "Rogue" then mb_rogueSingle() return end
			if myClass == "Warrior" then mb_warriorSingle() return end
			if myClass == "Warlock" then mb_warlockSingle() return end
			if myClass == "Druid" then mb_druidSingle() return end
			if myClass == "Hunter" then mb_hunterSingle() return end
			if myClass == "Paladin" then mb_paladinSingle() return end
			MB_mySingleList[myClass]()
		end

	elseif GetRealZoneText() == "Naxxramas" then -- Naxx Mode

		if mb_isAtLoatheb() then

			--if myClass == "Shaman" then mb_shamanSingle() return end
			if myClass == "Rogue" then mb_rogueSingle() return end
			if myClass == "Warrior" then mb_warriorSingle() return end
			if myClass == "Warlock" then mb_warlockSingle() return end
			if myClass == "Druid" then mb_druidLoatheb() return end
			if myClass == "Hunter" then mb_hunterSingle() return end
			if myClass == "Paladin" then mb_paladinLoatheb() return end
			MB_mySingleList[myClass]()
		end 
	end

	-- Normal Single
	if myClass == "Shaman" then mb_shamanSingle() return end
	if myClass == "Rogue" then mb_rogueSingle() return end
	if myClass == "Warrior" then mb_warriorSingle() return end
	if myClass == "Warlock" then mb_warlockSingle() return end
	if myClass == "Druid" then mb_druidSingle() return end
	if myClass == "Hunter" then mb_hunterSingle() return end
	if myClass == "Paladin" then mb_paladinSingle() return end
	MB_mySingleList[myClass]()
end

------------------------------------------------------------------------------------------------------
------------------------------------------------ Multi! ----------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_multi() -- Multi Code

	if not MB_raidLeader and (TableLength(MBID) > 1) then Print("WARNING: You have not chosen a raid leader") end -- No RaidLeader Alert

	if mb_dead("player") then return end -- Stop when ur dead

	if mb_hasBuffNamed("Mind Control", "player") then  -- Stop all when ur MC'ing
	
		if (mb_tankTarget("Instructor Razuvious") and mb_myNameInTable(MB_myRazuviousPriest)) and MB_myRazuviousBoxStrategy then

			mb_doRazuviousActions()

		elseif (mb_tankTarget("Grand Widow Faerlina") and mb_myNameInTable(MB_myFaerlinaPriest)) and MB_myFaerlinaBoxStrategy then	
			
			mb_doFaerlinaActions()
		end	
		return
	end

	if (mb_hasBuffOrDebuff("First Aid", "player", "buff") and mb_hasBuffOrDebuff("Recently Bandaged", "player", "debuff")) then return end -- Stop all when you are using a bandage

	if (mb_isAtRazorgore() and (myName == mb_returnPlayerInRaidFromTable(MB_myRazorgoreORBtank))) and not mb_tankTarget("Razorgore the Untamed") then mb_orbControlling() return end -- Stop when your controlling the ORB

	if GetRealZoneText() == "Zul\'Gurub" then 

		if mb_mandokirGaze() then return end -- Stop ALL when Gaze

	elseif GetRealZoneText() == "Ruins of Ahn\'Qiraj" then 

		mb_autoAssignBanishOnMoam() -- Auto assign adds on Moam
	end

	if not (myClass == "Warrior" or myClass == "Rogue") then -- Reequip ur staff
		
		mb_reEquipAtieshIfNoAtieshBuff()
	end

	if mb_itemNameOfEquippedSlot(16) == nil then -- No weps equip, notify it
		
		mb_message("I don\'t have a weapon equipped.", 500)
	end

	mb_GTFO() -- GTFO

	-- mb_takeHealthPotion() -- Health pots

	if mb_inCombat("player") and mb_stunnableMob() and mb_inMeleeRange() then -- Warstomps
		if mb_knowSpell("War Stomp") and mb_spellReady("War Stomp") then
			
			if not mb_isDruidShapeShifted() then
				
				CastSpellByName("War Stomp")
			end
		end
	end

	if GetRealZoneText() == "Onyxia\'s Lair" and MB_myOnyxiaBoxStrategy then

		if mb_tankTarget("Onyxia") and myName == MB_myOnyxiaMainTank then 

			if myClass == "Shaman" then mb_shamanSingle() return end
			if myClass == "Rogue" then mb_rogueSingle() return end
			if myClass == "Warrior" then mb_warriorSingle() return end
			if myClass == "Warlock" then mb_warlockSingle() return end
			if myClass == "Druid" then mb_druidSingle() return end
			if myClass == "Hunter" then mb_hunterSingle() return end
			if myClass == "Paladin" then mb_paladinSingle() return end
			MB_myMultiList[myClass]()
			return
		end	

	elseif GetRealZoneText() == "Naxxramas" then -- Naxx Mode

		if mb_isAtNoth() then -- When @ Noth

			if mb_iamFocus() then mb_warriorSingle() return end -- Tank keep doing single, rest do multi

			if myClass == "Shaman" then mb_shamanMulti() return end
			if myClass == "Rogue" then mb_rogueMulti() return end
			if myClass == "Warrior" then mb_warriorMulti() return end
			if myClass == "Warlock" then mb_warlockMulti() return end
			if myClass == "Druid" then mb_druidMulti() return end
			if myClass == "Hunter" then mb_hunterMulti() return end
			if myClass == "Paladin" then mb_paladinMulti() return end
			MB_myMultiList[myClass]()

		elseif mb_isAtLoatheb() then

			--if myClass == "Shaman" then mb_shamanSingle() return end
			if myClass == "Rogue" then mb_rogueSingle() return end
			if myClass == "Warrior" then mb_warriorSingle() return end
			if myClass == "Warlock" then mb_warlockSingle() return end
			if myClass == "Druid" then mb_druidLoatheb() return end
			if myClass == "Hunter" then mb_hunterSingle() return end
			if myClass == "Paladin" then mb_paladinLoatheb() return end
			MB_myMultiList[myClass]()
		end 

	elseif GetRealZoneText() == "Ahn\'Qiraj" then -- AQ40 Mode

		if mb_isAtSartura() then -- When @ Sarturna

			if IsAltKeyDown() and mb_imHealer() then return end -- Stop healers when ALT down

			if myClass == "Shaman" then mb_shamanMulti() return end
			if myClass == "Rogue" then mb_rogueMulti() return end
			if myClass == "Warrior" then mb_warriorMulti() return end
			if myClass == "Warlock" then mb_warlockMulti() return end
			if myClass == "Druid" then mb_druidMulti() return end
			if myClass == "Hunter" then mb_hunterMulti() return end
			if myClass == "Paladin" then mb_paladinMulti() return end
			MB_myMultiList[myClass]()
		end

	elseif GetRealZoneText() == "Blackwing Lair" then

		if mb_tankTarget("Vaelastrasz the Corrupt") then

			if mb_imTank() then mb_warriorSingle() return end
			
			if myClass == "Shaman" then mb_shamanMulti() return end
			if myClass == "Rogue" then mb_rogueMulti() return end
			if myClass == "Warrior" then mb_warriorMulti() return end
			if myClass == "Warlock" then mb_warlockMulti() return end
			if myClass == "Druid" then mb_druidMulti() return end
			if myClass == "Hunter" then mb_hunterMulti() return end
			if myClass == "Paladin" then mb_paladinMulti() return end
			MB_myMultiList[myClass]()
		end
	end

	-- Normal Multi
	if myClass == "Shaman" then mb_shamanMulti() return end
	if myClass == "Rogue" then mb_rogueMulti() return end
	if myClass == "Warrior" then mb_warriorMulti() return end
	if myClass == "Warlock" then mb_warlockMulti() return end
	if myClass == "Druid" then mb_druidMulti() return end
	if myClass == "Hunter" then mb_hunterMulti() return end
	if myClass == "Paladin" then mb_paladinMulti() return end
	MB_myMultiList[myClass]()
end

------------------------------------------------------------------------------------------------------
------------------------------------------------- AOE! -----------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_AOE() -- AOE Code

	if not MB_raidLeader and (TableLength(MBID) > 1) then Print("WARNING: You have not chosen a raid leader") end -- No RaidLeader Alert

	if mb_dead("player") then return end -- Stop when ur dead

	if mb_hasBuffNamed("Mind Control", "player") then  -- Stop all when ur MC'ing
	
		if (mb_tankTarget("Instructor Razuvious") and mb_myNameInTable(MB_myRazuviousPriest)) and MB_myRazuviousBoxStrategy then

			mb_doRazuviousActions()
		
		elseif (mb_tankTarget("Grand Widow Faerlina") and mb_myNameInTable(MB_myFaerlinaPriest)) and MB_myFaerlinaBoxStrategy then	
			
			mb_doFaerlinaActions()
		end	
		return
	end

	if (mb_hasBuffOrDebuff("First Aid", "player", "buff") and mb_hasBuffOrDebuff("Recently Bandaged", "player", "debuff")) then return end -- Stop all when you are using a bandage

	if (mb_isAtRazorgore() and (myName == mb_returnPlayerInRaidFromTable(MB_myRazorgoreORBtank))) and not mb_tankTarget("Razorgore the Untamed") then mb_orbControlling() return end -- Stop when your controlling the ORB

	if GetRealZoneText() == "Zul\'Gurub" then 

		if mb_mandokirGaze() then return end -- Stop ALL when Gaze

	elseif GetRealZoneText() == "Ruins of Ahn\'Qiraj" then 

		mb_autoAssignBanishOnMoam() -- Auto assign adds on Moam
	end

	if not (myClass == "Warrior" or myClass == "Rogue") then -- Reequip ur staff
		
		mb_reEquipAtieshIfNoAtieshBuff()
	end

	if mb_itemNameOfEquippedSlot(16) == nil then -- No weps equip, notify it
		
		mb_message("I don\'t have a weapon equipped.", 500)
	end

	mb_GTFO() -- GTFO

	-- mb_takeHealthPotion() -- Health pots

	if mb_inCombat("player") and mb_stunnableMob() and mb_inMeleeRange() then -- Warstomps
		if mb_knowSpell("War Stomp") and mb_spellReady("War Stomp") then
			
			if not mb_isDruidShapeShifted() then
				
				CastSpellByName("War Stomp")
			end
		end
	end

	if GetRealZoneText() == "Naxxramas" then -- Naxx Mode

		if mb_isAtNoth() then -- When @ Noth

			if mb_iamFocus() then mb_warriorSingle() return end -- Tank keep doing single, rest do multi or AOE

			if myClass == "Shaman" then mb_shamanMulti() return end
			if myClass == "Rogue" then mb_rogueSingle() return end
			if myClass == "Warrior" then mb_warriorMulti() return end
			if myClass == "Warlock" then mb_warlockAOE() return end
			if myClass == "Druid" then mb_druidMulti() return end
			if myClass == "Hunter" then mb_hunterMulti() return end
			if myClass == "Paladin" then mb_paladinMulti() return end
			MB_myAOEList[myClass]()
		end

	elseif GetRealZoneText() == "Ahn\'Qiraj" then -- AQ40 Mode

		if mb_isAtSartura() then -- When @ Sarturna

			if IsAltKeyDown() and mb_imHealer() then return end -- Stop healers when ALT down

			if myClass == "Shaman" then mb_shamanAOE() return end
			if myClass == "Rogue" then mb_rogueAOE() return end
			if myClass == "Warrior" then mb_warriorAOE() return end
			if myClass == "Warlock" then mb_warlockAOE() return end
			if myClass == "Druid" then mb_druidAOE() return end
			if myClass == "Hunter" then mb_hunterAOE() return end
			if myClass == "Paladin" then mb_paladinAOE() return end
			MB_myAOEList[myClass]()
		end

	elseif GetRealZoneText() == "Zul\'Gurub" then -- ZG Mode

		if mb_isAtJindo() then -- When @ Jindo

			if myClass == "Shaman" then mb_shamanSingle() return end
			if myClass == "Rogue" then mb_rogueSingle() return end
			if myClass == "Warrior" then mb_warriorSingle() return end
			if myClass == "Warlock" then mb_warlockSingle() return end
			if myClass == "Druid" then mb_druidSingle() return end
			if myClass == "Hunter" then mb_hunterSingle() return end
			if myClass == "Paladin" then mb_paladinSingle() return end
			MB_myAOEList[myClass]()
		end
	end

	-- Normal AOE
	if myClass == "Shaman" then mb_shamanAOE() return end
	if myClass == "Rogue" then mb_rogueAOE() return end
	if myClass == "Warrior" then mb_warriorAOE() return end
	if myClass == "Warlock" then mb_warlockAOE() return end
	if myClass == "Druid" then mb_druidAOE() return end
	if myClass == "Hunter" then mb_hunterAOE() return end
	if myClass == "Paladin" then mb_paladinAOE() return end
	MB_myAOEList[myClass]()
end

------------------------------------------------------------------------------------------------------
---------------------------------------------- Precast! ----------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_preCast() -- Precasting

	if not MB_raidLeader and (TableLength(MBID) > 1) then Print("WARNING: You have not chosen a raid leader") end -- No RaidLeader Alert

	if mb_dead("player") then return end -- Stop when ur dead

	if myClass == "Rogue" or myClass == "Warrior" or myClass == "Paladin" then return end -- There is no precast for meleeclasses

	if MB_myCCTarget or MB_myOTTarget then return end -- Stop when you are assigned as CC or OT

	mb_assistFocus() -- Assist focus

	if not UnitName("target") then return end -- If not target don't do anything

	-- Normal Precast
	if myClass == "Shaman" then mb_shamanPreCast() return end
	if myClass == "Warlock" then mb_warlockPreCast() return end
	if myClass == "Druid" then mb_druidPreCast() return end
	if myClass == "Hunter" then mb_hunterPreCast() return end
	MB_myPreCastList[myClass]()
end

------------------------------------------------------------------------------------------------------
------------------------------------------- Heal and Tank! -------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_healAndTank()

	if not MB_raidLeader and (TableLength(MBID) > 1) then Print("WARNING: You have not chosen a raid leader") end -- No RaidLeader Alert

	if mb_dead("player") then return end -- Stop when ur dead

	mb_getTarget() -- GetTarget

	if (mb_hasBuffOrDebuff("First Aid", "player", "buff") and mb_hasBuffOrDebuff("Recently Bandaged", "player", "debuff")) then return end -- Stop all when you are using a bandage

	if mb_hasBuffNamed("Mind Control", "player") then  -- Stop all when ur MC'ing
	
		if (mb_tankTarget("Instructor Razuvious") and mb_myNameInTable(MB_myRazuviousPriest)) and MB_myRazuviousBoxStrategy then

			mb_doRazuviousActions()
		
		elseif (mb_tankTarget("Grand Widow Faerlina") and mb_myNameInTable(MB_myFaerlinaPriest)) and MB_myFaerlinaBoxStrategy then	
			
			mb_doFaerlinaActions()
		end
		return
	end

	if (mb_isAtRazorgore() and (myName == mb_returnPlayerInRaidFromTable(MB_myRazorgoreORBtank))) and not mb_tankTarget("Razorgore the Untamed") then mb_orbControlling() return end -- Stop when your controlling the ORB

	mb_reEquipAtieshIfNoAtieshBuff() -- Reequip ur staff

	if GetRealZoneText() == "Naxxramas" then -- Naxx Mode

		if mb_isAtLoatheb() then

			if (mb_imHealer() or mb_imTank()) then

				if myClass == "Warrior" then mb_warriorSingle() return end

				if myClass == "Druid" then mb_druidLoatheb() return end
				if myClass == "Paladin" then mb_paladinLoatheb() return end
				MB_myLoathebList[myClass]()

			elseif mb_hasBuffOrDebuff("Fungal Bloom", "player", "debuff") then

				if myClass == "Rogue" then mb_rogueSingle() return end
				if myClass == "Warrior" then mb_warriorSingle() return end
				if myClass == "Warlock" then mb_warlockSingle() return end
				MB_mySingleList[myClass]()
			end
			return
		end
	end
	
	mb_GTFO() -- GTFO

	if mb_inCombat("player") and mb_stunnableMob() and mb_inMeleeRange() then -- Warstomps
		if mb_knowSpell("War Stomp") and mb_spellReady("War Stomp") then
			
			if not mb_isDruidShapeShifted() then
				
				CastSpellByName("War Stomp")
			end
		end
	end

	mb_interruptingHealAndTank() -- Innterupts

	if myClass == "Hunter" then -- Hunters set pet to passive

		mb_hunterPetPassive()

		if (mb_tankTarget("Gluth") or mb_tankTarget("Princess Huhuran") or mb_tankTarget("Flamegor") or mb_tankTarget("Chromaggus") or mb_tankTarget("Magmadar")) and mb_spellReady("Tranquilizing Shot") then
		
			CastSpellByName("Tranquilizing Shot")
		end

		if mb_tankTarget("Gluth") then
			mb_freezingTrap()
		end

	elseif myClass == "Mage" then -- Mages decurse

		mb_decurse() -- Decurse

		if mb_mobsToDetectMagic() then -- Mage detect magic	

			if not (mb_hasBuffOrDebuff("Detect Magic", "player", "debuff") and mb_hasBuffOrDebuff("Detect Magic", "target", "debuff")) then

				CastSpellByName("Detect Magic")
				return
			end
		end

	elseif myClass == "Warlock" then -- Warlocks
	
		if mb_hasBuffOrDebuff("Hellfire", "player", "buff") then -- Stop Hellfire
			
			CastSpellByName("Life Tap(Rank 1)")
			return
		end

		if MB_raidAssist.Warlock.FarmSoulStones then -- Farm Shards
			
			if mb_numShards() < 60 and mb_getAllContainerFreeSlots() >= 10 and not mb_imBusy() then
	
				CastSpellByName("Drain Soul(Rank 1)")
				return
			end
		end
	end

	if MB_raidAssist.Warlock.FarmSoulStones and mb_imMeleeDPS() then

		MB_mySpecc = "Furytank"
	end

	if GetRealZoneText() == "Zul\'Gurub" then -- ZG

		if mb_mandokirGaze() then return end -- Stop ALL when Gaze

		if myClass == "Mage" and mb_tankTarget("Hakkar") then -- Hakkar MC			
				
			if mb_hasBuffOrDebuff("Mind Control", "target", "debuff") then ClearTarget() return end -- If your target is still a MC'd target here, clear target

			if not MB_autoToggleSheeps.Active then

				MB_autoToggleSheeps.Active = true
				MB_autoToggleSheeps.Time = GetTime() + 10

				if MB_buffingCounterMage == TableLength(MB_classList["Mage"]) + 1 then
					
					MB_buffingCounterMage = 1
				else

					MB_buffingCounterMage = MB_buffingCounterMage + 1
				end
			end

			if MB_buffingCounterMage == mb_myClassAlphabeticalOrder() then
					
				mb_crowdControlMCedRaidMemberHakkar()
			end
		end

	elseif GetRealZoneText() == "Ruins of Ahn\'Qiraj" then -- AQ20

		mb_autoAssignBanishOnMoam() -- Auto assign adds on Moam

	elseif GetRealZoneText() == "Ahn\'Qiraj" then -- AQ40 Mode

		if mb_hasBuffOrDebuff("True Fulfillment", "target", "debuff") then ClearTarget() return end -- Clear target if YOU have a MC'd target
		
		if mb_isAtSkeram() then

			if myClass == "Mage" then -- Mage sheep AQ40

				if not MB_autoToggleSheeps.Active then

					MB_autoToggleSheeps.Active = true
					MB_autoToggleSheeps.Time = GetTime() + 2

					if MB_buffingCounterMage == TableLength(MB_classList["Mage"]) + 1 then
						
						MB_buffingCounterMage = 1
					else

						MB_buffingCounterMage = MB_buffingCounterMage + 1
					end
				end

				if MB_buffingCounterMage == mb_myClassAlphabeticalOrder() then
						
					mb_crowdControlMCedRaidMemberSkeram()
				end
				
			elseif myClass == "Priest" then -- Priest AOE fear Skeram

				if not MB_autoToggleSheeps.Active then

					MB_autoToggleSheeps.Active = true
					MB_autoToggleSheeps.Time = GetTime() + 3

					if MB_buffingCounterPriest == TableLength(MB_classList["Priest"]) + 1 then
						
						MB_buffingCounterPriest = 1
					else

						MB_buffingCounterPriest = MB_buffingCounterPriest + 1
					end
				end

				if MB_buffingCounterPriest == mb_myClassAlphabeticalOrder() then
						
					mb_crowdControlMCedRaidMemberSkeramAOE()
				end
				
			elseif myClass == "Warlock" and MB_mySkeramBoxStrategyWarlock then -- Warlock fear AQ40

				if not MB_autoToggleSheeps.Active then

					MB_autoToggleSheeps.Active = true
					MB_autoToggleSheeps.Time = GetTime() + 6

					if MB_ssCounterWarlock == TableLength(MB_classList["Warlock"]) + 1 then
						
						MB_ssCounterWarlock = 1
					else

						MB_ssCounterWarlock = MB_ssCounterWarlock + 1
					end
				end

				if MB_ssCounterWarlock == mb_myClassAlphabeticalOrder() then
					
					mb_crowdControlMCedRaidMemberSkeramFear()
				end	
			end
		
		elseif mb_isAtTwinsEmps() and MB_myTwinsBoxStrategy then

			if myClass == "Warlock" then			

				if mb_myNameInTable(MB_myTwinsWarlockTank) then

					mb_warlockSingle()
				end
			end
		end

	elseif GetRealZoneText() == "Blackwing Lair" and string.find(GetSubZoneText(), "Nefarian.*Lair") then 

		if myClass == "Mage" then

			if mb_isAtNefarianPhase() then -- Sheep Nefarain Phase

				if mb_hasBuffOrDebuff("Shadow Command", "target", "debuff") then ClearTarget() return end -- If your target is still a MC'd target here, clear target

				if not MB_autoToggleSheeps.Active then

					MB_autoToggleSheeps.Active = true
					MB_autoToggleSheeps.Time = GetTime() + 2

					if MB_buffingCounterMage == TableLength(MB_classList["Mage"]) + 1 then
						
						MB_buffingCounterMage = 1
					else

						MB_buffingCounterMage = MB_buffingCounterMage + 1
					end
				end

				if MB_buffingCounterMage == mb_myClassAlphabeticalOrder() then
						
					mb_crowdControlMCedRaidMemberNefarian()
				end
			end
		end

	elseif GetRealZoneText() == "Naxxramas" then -- Naxx

		-- Mind Control
		if (mb_tankTarget("Instructor Razuvious") and mb_myNameInTable(MB_myRazuviousPriest)) and MB_myRazuviousBoxStrategy then

			mb_getMCActions()
			return

		elseif (mb_tankTarget("Grand Widow Faerlina") and mb_myNameInTable(MB_myFaerlinaPriest)) and MB_myFaerlinaBoxStrategy then

			mb_getMCActions()
			return
		end
	end

	mb_crowdControl() -- CC

	if mb_imTank() then -- Tanks

		if myClass == "Warrior" then -- Tanks for warriors
			
			mb_warriorTank()

		elseif myClass == "Druid" then -- Tanks for ferals
			
			mb_druidTank()
		end

	elseif mb_imHealer() then -- Healers

		if myClass == "Druid" then -- Druid heal

			if UnitName("target") == "Death Talon Wyrmkin" and GetRaidTargetIndex("target") == MB_myCCTarget then -- CC drakes in BWL
			
				CastSpellByName("Hibernate(rank 1)")
				return true
			end

			mb_druidHeal()
		
		elseif myClass == "Priest" then -- Priest heal

			MB_myHealList[myClass]()

		elseif myClass == "Shaman" then -- Shaman heal
		
			mb_shamanSingle()

		elseif myClass == "Paladin" then -- Pala heal
			
			mb_paladinSingle()
		end
	end
end

------------------------------------------------------------------------------------------------------
------------------------------------------------ Setup! ----------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_setup()

	if not MB_raidLeader and (TableLength(MBID) > 1) then Print("WARNING: You have not chosen a raid leader") end -- No RaidLeader Alert
	
	if mb_dead("player") then return end -- Stop when ur dead

	if (mb_hasBuffOrDebuff("First Aid", "player", "buff") and mb_hasBuffOrDebuff("Recently Bandaged", "player", "debuff")) then return end -- Stop all when you are using a bandage

	if (mb_isAtRazorgore() and (myName == mb_returnPlayerInRaidFromTable(MB_myRazorgoreORBtank))) and not mb_tankTarget("Razorgore the Untamed") then mb_orbControlling() return end -- Stop when your controlling the ORB

	if not (myClass == "Warrior" or myClass == "Rogue") then -- Reequip ur staff
		
		mb_reEquipAtieshIfNoAtieshBuff()
	end

	if mb_itemNameOfEquippedSlot(16) == nil then -- No weps equip, notify it
		
		mb_message("I don\'t have a weapon equipped.", 500)
	end

	if IsControlKeyDown() then -- Ctrl Down => make a line
		
		mb_makeALine()
		return
	end

	-- Normal Setup
	if myClass == "Shaman" then mb_shamanSetup() return end
	if myClass == "Rogue" then mb_rogueSetup() return end
	if myClass == "Warrior" then return end
	if myClass == "Warlock" then mb_warlockSetup() return end
	if myClass == "Druid" then mb_druidSetup() return end
	if myClass == "Hunter" then mb_hunterSetup() return end
	if myClass == "Paladin" then mb_paladinSetup() return end
	MB_mySetupList[myClass]()
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

					mb_cooldownSecondPrint("Sending out request to use Cooldowns.")
				else
					mb_cooldownSecondPrint("Stop Cooldown Requesting, still "..math.round(MB_useCooldowns.Time - GetTime()).."s remaining")
				end
			end

			SendAddonMessage(MB_RAID, "MB_USECOOLDOWNS", "RAID")
		else
			SendAddonMessage(MB_RAID, "MB_USECOOLDOWNS")
		end
	end
end

function mb_craftCooldowns()
	
	if not MB_raidLeader and (TableLength(MBID) > 1) then Print("WARNING: You have not chosen a raid leader") end -- No RaidLeader Alert

	if mb_dead("player") then return end -- Stop when ur dead

	mb_tradeCooldownMaterialsToLeader()
	mb_useTradeCooldowns()
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

					mb_cooldownSecondPrint("Sending out request to use Recklessness.")
				else
					mb_cooldownSecondPrint("Stop Recklessness Requesting, still "..math.round(MB_useBigCooldowns.Time - GetTime()).."s remaining")
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

function mb_giveShieldToBombFollowTarget() -- Shield the Vael tanks from explotions
	if mb_tankTarget("Vaelastrasz the Corrupt") and not mb_imBusy() then

		if mb_spellReady("Power Word: Shield") then 
			
			if MBID[mb_returnPlayerInRaidFromTable(MB_raidAssist.GTFO.Vaelastrasz)] and mb_isAlive(MBID[mb_returnPlayerInRaidFromTable(MB_raidAssist.GTFO.Vaelastrasz)]) and not mb_hasBuffOrDebuff("Weakened Soul", MBID[mb_returnPlayerInRaidFromTable(MB_raidAssist.GTFO.Vaelastrasz)], "debuff") then
			
				TargetByName(mb_returnPlayerInRaidFromTable(MB_raidAssist.GTFO.Vaelastrasz))
				CastSpellByName("Power Word: Shield")
			end
		end

		TargetLastTarget()
	end
end

function mb_druidMaxRejuvAggroedPlayer() -- Max ranks Vael Reju on agroed player

	local rejuvTarget
	if MBID[MB_raidLeader] then
		rejuvTarget = MBID[MB_raidLeader].."targettarget"
	end

	if rejuvTarget then

		if mb_isValidFriendlyTarget(rejuvTarget, "Rejuvenation") and mb_healthPct(rejuvTarget) <= 0.95 and not mb_hasBuffNamed("Rejuvenation", rejuvTarget) then 
			
			if UnitIsFriend("player", rejuvTarget) then
				ClearTarget()
			end	
			
			--mb_message("Rejuvenation on "..UnitName(rejuvTarget), 30)

			CastSpellByName("Rejuvenation")
			SpellTargetUnit(rejuvTarget)
			SpellStopTargeting()
		end
	end
end

function mb_druidMaxRegrowthAggroedPlayer() -- Max rank Veal regrowth on agroed player

	local regroTarget
	if MBID[MB_raidLeader] then
		regroTarget = MBID[MB_raidLeader].."targettarget"
	end

	if regroTarget then

		if mb_isValidFriendlyTarget(regroTarget, "Regrowth") and mb_healthPct(regroTarget) <= 0.95 and not mb_hasBuffNamed("Regrowth", regroTarget) then 
			
			if UnitIsFriend("player", regroTarget) then
				ClearTarget()
			end	
			
			--mb_message("Regrowth on "..UnitName(regroTarget), 30)

			CastSpellByName("Regrowth")
			SpellTargetUnit(regroTarget)
			SpellStopTargeting()
		end
	end
end

function mb_druidMaxAbolishAggroedPlayer() -- Max rank Veal Abolish Poison on agroed player

	local abolishTarget
	if MBID[MB_raidLeader] then
		abolishTarget = MBID[MB_raidLeader].."targettarget"
	end

	if abolishTarget then

		if mb_isValidFriendlyTarget(abolishTarget, "Abolish Poison") and mb_healthPct(abolishTarget) <= 0.95 and not mb_hasBuffNamed("Abolish Poison", abolishTarget) then 
			
			if UnitIsFriend("player", abolishTarget) then
				ClearTarget()
			end	
			
			--mb_message("Abolish Poison on "..UnitName(abolishTarget), 30)

			CastSpellByName("Abolish Poison")
			SpellTargetUnit(abolishTarget)
			SpellStopTargeting()
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
-------------------------------------------- Flash Handler! ------------------------------------------
------------------------------------------------------------------------------------------------------

local mb_indicatorFrame = CreateFrame("Frame", nil, UIParent)
	mb_indicatorFrame.FlashTime = GetTime()
	mb_indicatorFrame.FlashColor = {red = 0, green = 0, blue = 0, alpha = 0}
	mb_indicatorFrame.PulseAlphaValue = 0
	mb_indicatorFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	mb_indicatorFrame:RegisterEvent("UI_ERROR_MESSAGE")

local t1 = mb_indicatorFrame:CreateTexture(nil, "BACKGROUND")
	t1:SetTexture(1.0, 0.0, 0.0, 0.4)
	t1:SetHeight(GetScreenHeight()/20/ UIParent:GetEffectiveScale())
	t1:SetPoint("TOP", 0, 0)

local t2 = mb_indicatorFrame:CreateTexture(nil, "BACKGROUND")
	t2:SetTexture(1.0, 0.0, 0.0, 0.4)
	t2:SetHeight(GetScreenHeight()/20/ UIParent:GetEffectiveScale())
	t2:SetPoint("BOTTOM", 0, 0)

local t3 = mb_indicatorFrame:CreateTexture(nil, "BACKGROUND")
	t3:SetTexture(1.0, 0.0, 0.0, 0.4)
	t3:SetWidth(GetScreenHeight()/20/ UIParent:GetEffectiveScale())
	t3:SetPoint("LEFT", 0, 0)

local t4 = mb_indicatorFrame:CreateTexture(nil, "BACKGROUND")
	t4:SetTexture(1.0, 0.0, 0.0, 0.4)
	t4:SetWidth(GetScreenHeight()/20/ UIParent:GetEffectiveScale())
	t4:SetPoint("RIGHT", 0, 0)
	mb_indicatorFrame:SetPoint("CENTER", 0, 0)

function mb_flashFrameFlashHandler()
	--Special indicator active
	if mb_indicatorFrame.FlashTime > GetTime() then
		t1:SetTexture(mb_indicatorFrame.FlashColor.red, mb_indicatorFrame.FlashColor.green, mb_indicatorFrame.FlashColor.blue, mb_indicatorFrame.FlashColor.alpha)
		t2:SetTexture(mb_indicatorFrame.FlashColor.red, mb_indicatorFrame.FlashColor.green, mb_indicatorFrame.FlashColor.blue, mb_indicatorFrame.FlashColor.alpha)
		t3:SetTexture(mb_indicatorFrame.FlashColor.red, mb_indicatorFrame.FlashColor.green, mb_indicatorFrame.FlashColor.blue, mb_indicatorFrame.FlashColor.alpha)
		t4:SetTexture(mb_indicatorFrame.FlashColor.red, mb_indicatorFrame.FlashColor.green, mb_indicatorFrame.FlashColor.blue, mb_indicatorFrame.FlashColor.alpha)
		return
	else
		--Highlight MainTankTargetstarget
		if MBID[MB_raidLeader] and UnitName(MBID[MB_raidLeader].."targettarget") == myName and UnitIsEnemy("target", "player") then
			
			if mb_findInTable(MB_tankList, myName) then
				--Highlight Tank
				t1:SetTexture(1.0, 1.0, 1.0, 0.4)
				t2:SetTexture(1.0, 1.0, 1.0, 0.4)
				t3:SetTexture(1.0, 1.0, 1.0, 0.4)
				t4:SetTexture(1.0, 1.0, 1.0, 0.4)
				return
			else
				--Highlight Toon not in tanklist
				t1:SetTexture(1.0, 0.0, 0.0, mb_indicatorFrame.PulseAlphaValue )
				t2:SetTexture(1.0, 0.0, 0.0, mb_indicatorFrame.PulseAlphaValue )
				t3:SetTexture(1.0, 0.0, 0.0, mb_indicatorFrame.PulseAlphaValue )
				t4:SetTexture(1.0, 0.0, 0.0, mb_indicatorFrame.PulseAlphaValue )
				mb_indicatorFrame.PulseAlphaValue  = mb_indicatorFrame.PulseAlphaValue  + 0.005
				if mb_indicatorFrame.PulseAlphaValue  > 1 then
					mb_indicatorFrame.PulseAlphaValue  = 0
				end
				return
			end
		end
	end
	--Hide it!
	t1:SetTexture(1.0, 0.0, 0.0, 0.0)
	t2:SetTexture(1.0, 0.0, 0.0, 0.0)
	t3:SetTexture(1.0, 0.0, 0.0, 0.0)
	t4:SetTexture(1.0, 0.0, 0.0, 0.0)
end

local function mb_flashFrameEventHandler()
	if not MB_raidAssist.Frameflash then return end

	if (event == "PLAYER_ENTERING_WORLD") then
		mb_indicatorFrame:SetWidth(GetScreenWidth())
		mb_indicatorFrame:SetHeight(GetScreenHeight())
		t1:SetWidth(GetScreenWidth())
		t2:SetWidth(GetScreenWidth())
		t3:SetHeight(GetScreenHeight()-t1:GetHeight() - t2:GetHeight())
		t4:SetHeight(GetScreenHeight()-t1:GetHeight() - t2:GetHeight())
	elseif (event == "UI_ERROR_MESSAGE") then
		if ((arg1  == "Target needs to be in front of you") or (arg1  == "Out of range.") or (arg1 == "Target not in line of sight") or (arg1 == "Target too close")) and MB_raidLeader and MB_raidLeader ~= myName then
			mb_indicatorFrame.FlashTime = GetTime() + 1
			mb_indicatorFrame.FlashColor = {red = 1, green = 1, blue = 0, alpha = .4}
		end
	end
end

mb_indicatorFrame:SetScript("OnEvent", mb_flashFrameEventHandler)
mb_indicatorFrame:SetScript("OnUpdate", mb_flashFrameFlashHandler)

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

function mb_shamanSingle()

	mb_getTarget() -- Gettarget

	if mb_partyIsPoisoned() then -- When poisened party, stop casting
		
		if mb_imBusy() then
			
			SpellStopCasting()
			return
		end
		
		CastSpellByName("Poison Cleansing Totem")
		mb_coolDownCast("Poison Cleansing Totem", 6)
		return
	end	

	if mb_partyIsDiseased() and mb_tankTarget("Heigan the Unclean") then -- Heigan only, decurse disease
		
		if mb_meleeDPSInParty() then
			
			if mb_imBusy() then
			
				SpellStopCasting()
				return
			end

			CastSpellByName("Disease Cleansing Totem")
			mb_coolDownCast("Disease Cleansing Totem", 6)
			return
		end
	end

	mb_decurse() -- Decurse

	if MB_myInterruptTarget and MB_doInterrupt.Active and mb_spellReady(MB_myInterruptSpell[myClass]) then -- Auto intterupt when assigned
		
		mb_getMyInterruptTarget()

		if mb_imBusy() then
			
			SpellStopCasting() 
		end

		CastSpellByName(MB_myInterruptSpell[myClass].."(rank 1)")
		mb_coolDownPrint("Interrupting!")
		MB_doInterrupt.Active = false
		return
	end

	if MB_doInterrupt.Active and mb_spellReady(MB_myInterruptSpell[myClass]) then -- Auto intterupt when not assigned
		
		mb_getMyInterruptTarget()

		if mb_imBusy() then
			
			SpellStopCasting() 
		end

		CastSpellByName(MB_myInterruptSpell[myClass].."(rank 1)")
		mb_coolDownPrint("Interrupting!")
		MB_doInterrupt.Active = false
		return
	end

	mb_dropTotems() -- Dropping totems

	-- Jindo damage rotation
	mb_healerJindoRotation("Chain Lightning")
	mb_healerJindoRotation("Lightning Bolt")

	if mb_tankTarget("Gothik the Harvester") and not IsAltKeyDown() then return end

	mb_shamanHeal() -- Healing
end

function mb_shamanHeal()
	
	if mb_natureSwiftnessLowAggroedPlayer() then return end -- Insta heal
	
	if mb_inCombat("player") then

		-- Mana Tide
		if mb_spellReady("Mana Tide Totem") and not mb_hasBuffOrDebuff("Mana Tide Totem", "player", "buff") then
			
			local MB_partyManaPCT, MB_partyManaDown, MB_partyMana, MB_partyMaxMana = mb_partyMana()

			if (MB_partyManaDown / mb_numOfCasterHealerInParty()) > 1500 and mb_manaDown() > 1050 then
				
				CastSpellByName("Mana Tide Totem") 
				mb_coolDownCast("Mana Tide Totem", 13)
				
			elseif mb_manaDown() > 1500 then 

				CastSpellByName("Mana Tide Totem") 
				mb_coolDownCast("Mana Tide Totem", 13) 		 
			end
		end
		
		-- Potions
		mb_takeManaPotionAndRune()
		mb_takeManaPotionIfBelowManaPotMana()
		mb_takeManaPotionIfBelowManaPotManaInRazorgoreRoom()

		-- Cooldowns
		if mb_manaDown("player") > 600 then mb_shamanCooldowns() end
	end

	if (mb_hasBuffOrDebuff("Curse of Tongues", "player", "debuff") and not mb_tankTarget("Anubisath Defender")) then return end -- Don't need to start heals w COT, wait for dispells

	if mb_healLieutenantAQ20() then return end -- Healing for the Rajaxx Fight (Untested 22/05)

	if mb_instructorRazAddsHeal() then return end -- Healers heal adds in Razuvious fight
	
	if MB_myAssignedHealTarget then -- Assigned Target healing

		if mb_isAlive(MBID[MB_myAssignedHealTarget]) then
			
			mb_shamanMTHeals(MB_myAssignedHealTarget)
			return
		else

			MB_myAssignedHealTarget = nil
			RunLine("/raid My healtarget died, time to ALT-F4.")
		end
	end

	for k, BossName in pairs(MB_myShamanMainTankHealingBossList) do -- Specific encounter heals
		
		if mb_tankTarget(BossName) then
			
			mb_shamanMTHeals()
			return
		end
	end

	if GetRealZoneText() == "Blackwing Lair" then -- BWL specific healing

		if mb_tankTarget("Vaelastrasz the Corrupt") and MB_myVaelastraszBoxStrategy then -- Vael, use max ranks

			if mb_hasBuffOrDebuff("Burning Adrenaline", "player", "debuff") then -- When we have the DEBUFF cast MAX CHAINS
	
				MBH_CastHeal("Chain Heal", 3, 3)
				return
			end

			mb_shamanCooldowns() -- CD's
	
			if MB_myHealSpell == "Healing Wave" then -- 8T1 Healers
				
				if MB_myVaelastraszShamanHealing then -- Heal MT

					if myName == MB_myVaelastraszShamanOne then
						
						mb_message("MT Healing!", 300)
						mb_shamanMTHeals()
						return			

					elseif myName == MB_myVaelastraszShamanTwo and mb_dead(MBID[MB_myVaelastraszShamanOne]) then

						mb_message("MT Healing!", 300)
						mb_shamanMTHeals()
						return

					elseif myName == MB_myVaelastraszShamanThree and mb_dead(MBID[MB_myVaelastraszShamanOne]) and mb_dead(MBID[MB_myVaelastraszShamanTwo]) then

						mb_message("MT Healing!", 300)
						mb_shamanMTHeals()
						return	
					end
				end

				MBH_CastHeal("Lesser Healing Wave", 6, 6) -- Lesser Heals
				return
			end
	
			MBH_CastHeal("Chain Heal", 3, 3) -- Chains if not 8T1
			return
		end

	elseif GetRealZoneText() == "Ahn\'Qiraj" then -- AQ40 sepcific healing

		if mb_tankTarget("Princess Huhuran") then
			
			if mb_healthPct("target") <= 0.32 then -- Huhuran is nasty when she goes below 30%
			
				MBH_CastHeal("Chain Heal", 2, 3)
			else
				MBH_CastHeal("Healing Wave", 3, 5) -- HW
			end
		end
	end

	if MB_myHealSpell == "Healing Wave" then

		if (UnitMana("player") > 780) and mb_shamanPartyHurt(GetAverageChainHealValueFromRank("Chain Heal", "Rank 1", 2, 75), 3) and (GetRealZoneText() == "Blackwing Lair" and (GetSubZoneText() == "Dragonmaw Garrison" and mb_isAtRazorgorePhase())) and MB_myRazorgoreBoxStrategy and MB_raidAssist.Shaman.Razorgore then 
				
			mb_message("Chain brr")
			MBH_CastHeal("Chain Heal", 1, 1)
			return 

		elseif (UnitMana("player") > 780) and mb_shamanPartyHurt(GetAverageChainHealValueFromRank("Chain Heal", "Rank 1", 2, 50), 3) and (GetRealZoneText() == "Naxxramas" and (mb_tankTarget("Naxxramas Acolyte") or mb_tankTarget("Naxxramas Cultist"))) and MB_raidAssist.Shaman.FaerlinaTrash then 
				
			mb_message("Chain brr")
			MBH_CastHeal("Chain Heal", 2, 3)
			return 

		elseif (UnitMana("player") > 780) and mb_shamanPartyHurt(GetAverageChainHealValueFromRank("Chain Heal", "Rank 1", 2, 50), 3) and (GetRealZoneText() == "Blackwing Lair" and (GetSubZoneText() == "Halls of Strife" and not mb_tankTarget("Broodlord Lashlayer"))) and MB_raidAssist.Shaman.SuppressionRoom then 
			
			mb_message("Chain brr")
			MBH_CastHeal("Chain Heal", 1, 3)
			return 

		elseif (UnitMana("player") > 780) and mb_shamanPartyHurt(GetAverageChainHealValueFromRank("Chain Heal", "Rank 1", 2, 75), 3) and MB_raidAssist.Shaman.Normal then 
			
			mb_message("Chain brr")
			MBH_CastHeal("Chain Heal", 1, 1)
			return 
		end
	end

	-- Healing selector
	if MB_myHealSpell == "Healing Wave" then
		
		MBH_CastHeal("Healing Wave", 3) -- HW

	elseif MB_myHealSpell == "Chain Heal" then
		
		MBH_CastHeal("Chain Heal", 1, 1) -- CH1
	end
end

------------------------------------------------------------------------------------------------------
--------------------------------------------- Multi Code! --------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_shamanMulti() -- Multi 
	mb_shamanSingle()
end

------------------------------------------------------------------------------------------------------
---------------------------------------------- AOE Code! ---------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_shamanAOE() -- AOE
		
	if mb_mobsToAoeTotem() and mb_spellReady("Fire Nova Totem") and not mb_imBusy() then

		CastSpellByName("Fire Nova Totem")
		return		
	end

	mb_shamanSingle()
end

------------------------------------------------------------------------------------------------------
-------------------------------------------- Precast Code! -------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_shamanPreCast() -- Precast
	mb_dropTotems()
end

------------------------------------------------------------------------------------------------------
------------------------------------------- Cooldowns Code! ------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_shamanCooldowns() -- Sham cooldowns
	
	if mb_imBusy() then return end

	if mb_inCombat("player") then 

		mb_selfBuff("Berserking")
		
		mb_healerTrinkets()
		mb_casterTrinkets()

		if mb_equippedSetCount("The Earthshatter") >= 8 then

			mb_selfBuff("Lightning Shield")
		end
	end
end

------------------------------------------------------------------------------------------------------
-------------------------------------------- Healing Code! -------------------------------------------
------------------------------------------------------------------------------------------------------

local HealWave = { Time = 0, Interrupt = false }

-- /run mb_shamanMTHeals("Angerissues")
function mb_shamanMTHeals(assignedtarget) -- Shaman MT healing
	
	if assignedtarget then
		
		TargetByName(assignedtarget, 1)
	else

		if mb_tankTarget("Patchwerk") and MB_myPatchwerkBoxStrategy then
			
			mb_targetMyAssignedTankToHeal()
		else

			if not UnitName(MBID[mb_tankName()].."targettarget") then 
				
				MBH_CastHeal("Healing Wave", 3)
			else
				TargetByName(UnitName(MBID[mb_tankName()].."targettarget"), 1) 
			end
		end
	end

	-- NS if needed
	if mb_knowSpell("Nature\'s Swiftness") and mb_spellReady("Nature\'s Swiftness") and mb_healthPct("target") <= 0.2 then

		if not mb_hasBuffOrDebuff("Nature\'s Swiftness", "player", "buff") then			
			
			SpellStopCasting()
		end

		mb_selfBuff("Nature\'s Swiftness") 
	end

	if mb_hasBuffOrDebuff("Nature\'s Swiftness", "player", "buff") then 
			
		CastSpellByName("Healing Wave")
		return
	end
	
	local HealWaveSpell = "Healing Wave("..MB_myShamanMainTankHealingRank.."\)"

	if mb_tankTarget("Vaelastrasz the Corrupt") then -- Max Ranks for Vael :)

		HealWaveSpell = "Healing Wave"
	end

	--[[	
		-- Info
		local HealWaveCastTime = 2.5
		local HealWaveTime = GetTime()
		local HealWaveCooldown = mb_spellCooldown("Healing Wave")

		-- Setup
		HealWaveStop = HealWaveStop or false
		HealWaveFinishTime = HealWaveFinishTime or 0
		HealWaveCastAt = HealWaveCastAt or 0
		
		if HealWaveCooldown > 0 then

			HealWaveFinishTime = (HealWaveCooldown + HealWaveCastTime)  -- Finish Timer = SpellCooldown + CastTime
			HealWaveStop = true
		end

		if not mb_tankTarget("Vaelastrasz the Corrupt") then

			-- Stop when target is not below HP and is not far into the cast
			if mb_healthDown("target") < 1400 and (HealWaveTime > HealWaveFinishTime) and HealWaveStop then
				
				HealWaveCastAt = HealWaveFinishTime + 0.1
				HealWaveStop = false
				SpellStopCasting()
			end
		end

		if HealWaveCooldown <= 0 and HealWaveTime > HealWaveCastAt then

			CastSpellByName(HealWaveSpell)
		end
	]]

	if not (mb_tankTarget("Vaelastrasz the Corrupt") or mb_tankTarget("Maexxna") or mb_tankTarget("Ossirian the Unscarred")) then

		-- Stop when target is not below HP and is not far into the cast
		if (mb_healthDown("target") <= (GetHealValueFromRank("Healing Wave", MB_myShamanMainTankHealingRank) * MB_myMainTankOverhealingPercentage)) and (GetTime() > HealWave.Time) and (GetTime() < HealWave.Time + 0.5) and HealWave.Interrupt then
			
			SpellStopCasting()
			HealWave.Interrupt = false
			SpellStopCasting()
		end
	end

	if not MB_isCasting then

		CastSpellByName(HealWaveSpell)
		HealWave.Time = GetTime() + 1
		HealWave.Interrupt = true
	end
end

------------------------------------------------------------------------------------------------------
------------------------------------------ Drop Totem Code! ------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_chooseAirTotem()

	if mb_tankTarget("Gluth") then

		if mb_isInGroup("Bloodclaw") then

			if mb_myGroupClassOrder() == 1 then return "Grace of Air Totem" end
			if mb_myGroupClassOrder() == 2 then return "Tranquil Air Totem" end
			return

		elseif (MB_druidTankInParty or MB_warriorTankInParty) then

			if mb_myGroupClassOrder() == 1 then return "Windfury Totem" end
			if mb_myGroupClassOrder() == 2 then return "Grace of Air Totem" end

		elseif mb_numberOfClassInParty("Warrior") > 0 or mb_numberOfClassInParty("Rogue") > 0 then

			if mb_myGroupClassOrder() == 1 then return "Windfury Totem" end
			if mb_myGroupClassOrder() == 2 then return "Grace of Air Totem" end

		elseif mb_numberOfClassInParty("Mage") > 0 or mb_numberOfClassInParty("Warlock") > 0 then

			if mb_myGroupClassOrder() == 1 then return "Tranquil Air Totem" end
			if mb_myGroupClassOrder() == 2 then return "Grace of Air Totem" end
		end

	elseif mb_tankTarget("Patchwerk") and MB_myPatchwerkBoxStrategy then

		-- Soaker tanks want extra Dodge?
		if mb_isInGroup(MB_myFirstPWSoaker) or mb_isInGroup(MB_mySecondPWSoaker) or mb_isInGroup(MB_myThirdPWSoaker) then
			
			if mb_myGroupClassOrder() == 1 then return "Grace of Air Totem" end
			if mb_myGroupClassOrder() == 2 then return "Windfury Totem" end
		end

	elseif mb_isGroundingBoss() then -- Special, hakkar can be here too ig
		
		-- Only MainTank needs special totems
		if mb_tankTarget("Ossirian the Unscarred") and MB_myOssirianBoxStrategy then

			if mb_isInGroup(MB_myOssirianMainTank) then

				if mb_myGroupClassOrder() == 1 then return "Grounding Totem" end
				if mb_myGroupClassOrder() == 2 then return "Grounding Totem" end
				if mb_myGroupClassOrder() == 3 then return "Grace of Air Totem" end
				if mb_myGroupClassOrder() == 4 then return "Windfury Totem" end
			end

		-- If enabled drops Grounding as totems
		elseif mb_isAtSkeram() and MB_mySkeramBoxStrategyTotem then
			
			if mb_myGroupClassOrder() == 1 then return "Grounding Totem" end
			
			if (MB_druidTankInParty or MB_warriorTankInParty) then

				if mb_myGroupClassOrder() == 2 then return "Grounding Totem" end
				if mb_myGroupClassOrder() == 3 then return "Windfury Totem" end
			
			elseif mb_numberOfClassInParty("Warrior") > 0 or mb_numberOfClassInParty("Rogue") > 0 then

				if mb_myGroupClassOrder() == 2 then return "Windfury Totem" end
				if mb_myGroupClassOrder() == 3 then return "Grounding Totem" end

			elseif mb_numberOfClassInParty("Mage") > 0 or mb_numberOfClassInParty("Warlock") > 0 then

				if mb_myGroupClassOrder() == 2 then return "Tranquil Air Totem" end
				if mb_myGroupClassOrder() == 3 then return "Grounding Totem" end
			end
		end

	elseif mb_isAtGrobbulus() and MB_myGrobbulusBoxStrategy then

		if (MB_druidTankInParty or MB_warriorTankInParty) then

			if mb_myGroupClassOrder() == 1 then return "Windfury Totem" end
			if mb_myGroupClassOrder() == 2 then return "Grace of Air Totem" end
			
		elseif mb_numberOfClassInParty("Warrior") > 0 or mb_numberOfClassInParty("Rogue") > 0 then

			if mb_myGroupClassOrder() == 1 then return "Windfury Totem" end
			if mb_myGroupClassOrder() == 2 then return "Grace of Air Totem" end
			
		elseif mb_numberOfClassInParty("Mage") > 0 or mb_numberOfClassInParty("Warlock") > 0 then

			if mb_myGroupClassOrder() == 1 then return "Nature Resistance Totem" end
			if mb_myGroupClassOrder() == 2 then return "Grace of Air Totem" end
		end

	elseif mb_isNatureBoss() then -- Nature Bosses

		if GetRealZoneText() == "Ahn\'Qiraj" then -- AQ, want always to have NR totem on these bosses

			if mb_tankTarget("Princess Huhuran") and mb_tankTargetHealth() >= 0.4 then

				if (MB_druidTankInParty or MB_warriorTankInParty) then

					if mb_myGroupClassOrder() == 1 then return "Windfury Totem" end
					if mb_myGroupClassOrder() == 2 then return "Grace of Air Totem" end
					
				elseif mb_numberOfClassInParty("Warrior") > 0 or mb_numberOfClassInParty("Rogue") > 0 then

					if mb_myGroupClassOrder() == 1 then return "Windfury Totem" end
					if mb_myGroupClassOrder() == 2 then return "Grace of Air Totem" end
					
				elseif mb_numberOfClassInParty("Mage") > 0 or mb_numberOfClassInParty("Warlock") > 0 then
	
					if mb_myGroupClassOrder() == 1 then return "Tranquil Air Totem" end
					if mb_myGroupClassOrder() == 2 then return "Grace of Air Totem" end
				end
				return
			end
			
			-- AQ4 NR totem drops
			if mb_myGroupClassOrder() == 1 then return "Nature Resistance Totem" end

			if (MB_druidTankInParty or MB_warriorTankInParty) then

				if mb_myGroupClassOrder() == 2 then return "Windfury Totem" end
				if mb_myGroupClassOrder() == 3 then return "Grace of Air Totem" end
			
			elseif mb_numberOfClassInParty("Warrior") > 0 or mb_numberOfClassInParty("Rogue") > 0 then

				if mb_myGroupClassOrder() == 2 then return "Windfury Totem" end
				if mb_myGroupClassOrder() == 3 then return "Grace of Air Totem" end

			elseif mb_numberOfClassInParty("Mage") > 0 or mb_numberOfClassInParty("Warlock") > 0 then

				if mb_myGroupClassOrder() == 2 then return "Tranquil Air Totem" end
				if mb_myGroupClassOrder() == 3 then return "Grace of Air Totem" end
			end

		else
		
			-- Normal NR dropping
			if mb_myGroupClassOrder() == 2 then return "Nature Resistance Totem" end

			if (MB_druidTankInParty or MB_warriorTankInParty) then

				if mb_myGroupClassOrder() == 1 then return "Windfury Totem" end
				if mb_myGroupClassOrder() == 3 then return "Grace of Air Totem" end
			
			elseif mb_numberOfClassInParty("Warrior") > 0 or mb_numberOfClassInParty("Rogue") > 0 then

				if mb_myGroupClassOrder() == 1 then return "Windfury Totem" end
				if mb_myGroupClassOrder() == 3 then return "Grace of Air Totem" end

			elseif mb_numberOfClassInParty("Mage") > 0 or mb_numberOfClassInParty("Warlock") > 0 then

				if mb_myGroupClassOrder() == 1 then return "Tranquil Air Totem" end
				if mb_myGroupClassOrder() == 3 then return "Grace of Air Totem" end
			end
		end
	end

	-- Normal totem select
	if (MB_druidTankInParty or MB_warriorTankInParty) then

		if mb_myGroupClassOrder() == 1 then return "Windfury Totem" end
		if mb_myGroupClassOrder() == 2 then return "Grace of Air Totem" end

	elseif mb_numberOfClassInParty("Warrior") > 0 or mb_numberOfClassInParty("Rogue") > 0 then
		
		if mb_myGroupClassOrder() == 1 then return "Windfury Totem" end
		if mb_myGroupClassOrder() == 2 then return "Grace of Air Totem" end
			
	elseif mb_numberOfClassInParty("Mage") > 0 or mb_numberOfClassInParty("Warlock") > 0 then
		
		if mb_myGroupClassOrder() == 1 then return "Tranquil Air Totem" end
		if mb_myGroupClassOrder() == 2 then return "Grace of Air Totem" end
	end

	if mb_myGroupClassOrder() == 1 then return "Tranquil Air Totem" end
	if mb_myGroupClassOrder() == 2 then return "Grace of Air Totem" end
end

function mb_chooseEarthTotem()

	if mb_tankTarget("Gluth") then

		if (MB_druidTankInParty or MB_warriorTankInParty) then

			if mb_myGroupClassOrder() == 1 then return "Strength of Earth Totem" end
			if mb_myGroupClassOrder() == 2 then return "Stoneskin Totem" end
		
		elseif mb_numberOfClassInParty("Warrior") > 0 or mb_numberOfClassInParty("Rogue") > 0 then

			if mb_myGroupClassOrder() == 1 then return "Strength of Earth Totem" end
			if mb_myGroupClassOrder() == 2 then return "Stoneskin Totem" end

		elseif mb_numberOfClassInParty("Mage") > 0 or mb_numberOfClassInParty("Warlock") > 0 then

			if mb_myGroupClassOrder() == 1 then return "Earthbind Totem" end
			if mb_myGroupClassOrder() == 2 then return "Stoneskin Totem" end
		end
		
	elseif mb_isTremorBoss() then -- Fear bosses

		if mb_tankTarget("Onyxia") and mb_tankTargetHealth() >= 0.4 then -- Ony doesn't fear untill 40%, drop normal totems

			if (MB_druidTankInParty or MB_warriorTankInParty) then 

				if mb_myGroupClassOrder() == 1 then return "Strength of Earth Totem" end
				if mb_myGroupClassOrder() == 2 then return "Stoneskin Totem" end
			
			elseif mb_numberOfClassInParty("Warrior") > 0 or mb_numberOfClassInParty("Rogue") > 0 then
		
				if mb_myGroupClassOrder() == 1 then return "Strength of Earth Totem" end
				if mb_myGroupClassOrder() == 2 then return "Stoneskin Totem" end
			
			elseif mb_numberOfClassInParty("Mage") > 0 or mb_numberOfClassInParty("Warlock") > 0 then
		
				if mb_myGroupClassOrder() == 1 then return "Stoneskin Totem" end
				if mb_myGroupClassOrder() == 2 then return "Strength of Earth Totem" end
			end
			return
		end

		if mb_myGroupClassOrder() == 1 then return "Tremor Totem" end

		if (MB_druidTankInParty or MB_warriorTankInParty) then

			if mb_myGroupClassOrder() == 2 then return "Strength of Earth Totem" end
			if mb_myGroupClassOrder() == 3 then return "Stoneskin Totem" end
		
		elseif mb_numberOfClassInParty("Warrior") > 0 or mb_numberOfClassInParty("Rogue") > 0 then

			if mb_myGroupClassOrder() == 2 then return "Strength of Earth Totem" end
			if mb_myGroupClassOrder() == 3 then return "Stoneskin Totem" end

		elseif mb_numberOfClassInParty("Mage") > 0 or mb_numberOfClassInParty("Warlock") > 0 then

			if mb_myGroupClassOrder() == 2 then return "Stoneskin Totem" end
			if mb_myGroupClassOrder() == 3 then return "Strength of Earth Totem" end
		end
	end

	-- Normal totem select
	if (MB_druidTankInParty or MB_warriorTankInParty) then 

		if mb_myGroupClassOrder() == 1 then return "Strength of Earth Totem" end
		if mb_myGroupClassOrder() == 2 then return "Stoneskin Totem" end
	
	elseif mb_numberOfClassInParty("Warrior") > 0 or mb_numberOfClassInParty("Rogue") > 0 then

		if mb_myGroupClassOrder() == 1 then return "Strength of Earth Totem" end
		if mb_myGroupClassOrder() == 2 then return "Stoneskin Totem" end
	
	elseif mb_numberOfClassInParty("Mage") > 0 or mb_numberOfClassInParty("Warlock") > 0 then

		if mb_myGroupClassOrder() == 1 then return "Stoneskin Totem" end
		if mb_myGroupClassOrder() == 2 then return "Strength of Earth Totem" end
	end

	if mb_myGroupClassOrder() == 1 then return "Stoneskin Totem" end
	if mb_myGroupClassOrder() == 2 then return "Strength of Earth Totem" end
end

function mb_chooseWaterTotem()

	if mb_isPoisonBoss() then
		
		if GetRealZoneText() == "Ahn\'Qiraj" then -- I want the extra healing on Visc and Huhuran (Not needed for Trio but its whatever)

			if mb_myGroupClassOrder() == 1 then return "Healing Stream Totem" end
			if mb_myGroupClassOrder() == 2 then return "Mana Spring Totem" end

		elseif mb_tankTarget("Chromaggus") then

			if mb_myGroupClassOrder() == 1 then return "Poison Cleansing Totem" end
			if mb_myGroupClassOrder() == 2 then return "Mana Spring Totem" end
		end	
		
	elseif mb_isFireBoss() then -- Bosses that do Firedamage
		
		if mb_myGroupClassOrder() == 1 then return "Fire Resistance Totem" end
		if mb_myGroupClassOrder() == 2 then return "Mana Spring Totem" end
	end

	-- Normal totem select
	if mb_myGroupClassOrder() == 1 then return "Mana Spring Totem" end
	if mb_myGroupClassOrder() == 2 then return "Healing Stream Totem" end
end

function mb_chooseFireTotem()
	
	-- Normal totem select
	if mb_myGroupClassOrder() == 1 then return "Frost Resistance Totem" end
end

function mb_dropTotems()
	
	if IsShiftKeyDown() then --To force reset of totems.
		if not mb_hasBuffOrDebuff("Grounding Totem", "player", "buff") then
			CastSpellByName("Grounding Totem")
		end
		if not mb_hasBuffOrDebuff("Stoneskin Totem", "player", "buff") then
			CastSpellByName("Stoneskin Totem")
		end
		if not mb_hasBuffOrDebuff("Healing Stream Totem", "player", "buff") then
			CastSpellByName("Healing Stream Totem")
		end	
		return
	end

	if GetSubZoneText() == "The Lyceum" then
		return
	end

	if GetSubZoneText() == "Halls of Strife" and not (mb_tankTarget("Broodlord Lashlayer") or mb_tankTarget("Firemaw")) then
		return
	end

	if MBID[MB_raidLeader] and not UnitName(MBID[MB_raidLeader].."target") then 
		return 
	end

	mb_castTotem(mb_chooseAirTotem())

	if not MB_cooldowns["Tremor Totem"] then
		mb_castTotem(mb_chooseEarthTotem())
	end

	if not MB_cooldowns["Poison Cleansing Totem"] then
		mb_castTotem(mb_chooseWaterTotem())
	end

	if mb_tankTarget("Sapphiron") or mb_tankTarget("Azuregos") then
		mb_castTotem(mb_chooseFireTotem())
	end
end

function mb_castTotem(totem)

	if mb_mobsNoTotems() then return end

	if mb_hasBuffOrDebuff("Mana Tide Totem", "player", "buff") then 
		return 
	end

	if (totem == "Fire Nova Totem" or totem == "Magma Totem") and not (mb_inMeleeRange() or mb_inCombat("player")) then 
		return 
	end

	local duration = 15
	if totem and string.find(totem, "Searing Totem") and not mb_inCombat("player") then 
		return
	end

	MB_totemtypes  = { 
		buff = {
				"Grounding Totem", 
				"Windfury Totem", 
				"Grace of Air Totem", 
				"Nature Resistance Totem", 
				"Tranquil Air Totem", 
				"Stoneskin Totem", 
				"Strength of Earth Totem", 
				"Frost Resistance Totem", 
				"Fire Resistance Totem", 
				"Mana Spring Totem", 
				"Healing Stream Totem", 
				"Mana Tide Totem"
				}, 
		nobuff = {
				"Sentry Totem", 
				"Earthbind Totem", 
				"Stoneclaw Totem", 
				"Fire Nova Totem", 
				"Magma Totem", 
				"Searing Totem", 
				"Flametongue Totem", 
				"Tremor Totem", 
				"Poison Cleansing Totem", 
				"Disease Cleansing Totem"
				}
	}
	if mb_findInTable(MB_totemtypes.nobuff, totem) then
		mb_coolDownCast(totem, duration)
	else
		if totem and not mb_hasBuffOrDebuff(totem, "player", "buff") then 
			CastSpellByName(totem) 
		end
	end
end

------------------------------------------------------------------------------------------------------
------------------------------------------- Boss Info Code! ------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_isNatureBoss()
	return mb_tankTarget("The Nature Boss") or
	
	-- AQ40
	-- mb_tankTarget("The Prophet Skeram") or

	mb_tankTarget("Princess Yauj") or
	mb_tankTarget("Lord Kri") or
	mb_tankTarget("Vem") or

	-- mb_tankTarget("Viscidus") or
	mb_tankTarget("Princess Huhuran") or

	-- AQ20
	mb_tankTarget("Buru the Gorger") or 
	
	-- ZG
	mb_tankTarget("High Priestess Mar\'li") or 
	mb_tankTarget("Spawn of Mar\'li") or 
	mb_tankTarget("Witherbark Speaker") or --> Add of spider boss

	mb_tankTarget("High Priest Venoxis") or 
	mb_tankTarget("Razzashi Cobra") or --> Add from Venoxis

	mb_tankTarget("Razzashi Serpent") or 
	mb_tankTarget("Razzashi Adder")
end

function mb_isTremorBoss()
	return mb_tankTarget("The Termor Boss") or
	
	-- MC
	mb_tankTarget("Magmadar") or
	
	-- WorldBoss
	mb_tankTarget("Emeriss") or
	mb_tankTarget("Taerar") or
	mb_tankTarget("Lethon") or
	mb_tankTarget("Ysondre") or
	
	-- BWL
	mb_tankTarget("Nefarian") or

	-- AQ40
	mb_tankTarget("Princess Yauj") or
	mb_tankTarget("Lord Kri") or
	mb_tankTarget("Vem") or 

	-- Ony
	mb_tankTarget("Onyxia")
end

function mb_isGroundingBoss()
	return mb_tankTarget("The Grounding Boss") or
	
	mb_tankTarget("Ossirian the Unscarred")
end

function mb_isPoisonBoss()
	return mb_tankTarget("The Poison Boss") or
	
	-- AQ40
	mb_tankTarget("Princess Yauj") or
	mb_tankTarget("Lord Kri") or
	mb_tankTarget("Vem") or

	mb_tankTarget("Viscidus") or
	mb_tankTarget("Princess Huhuran") or

	mb_tankTarget("Chromaggus") or

	-- ZG
	mb_tankTarget("High Priestess Mar\'li") or 
	mb_tankTarget("Spawn of Mar\'li") or 
	mb_tankTarget("Witherbark Speaker") or --> Add of spider boss

	mb_tankTarget("High Priest Venoxis") or 
	mb_tankTarget("Razzashi Cobra") or --> Add from Venoxis

	mb_tankTarget("Razzashi Serpent") or 
	mb_tankTarget("Razzashi Adder")
end

function mb_isFireBoss()
	return mb_tankTarget("The Fire Boss") or
	
	-- BWL trash
	mb_tankTarget("Death Talon Overseer") or 
	mb_tankTarget("Blackwing Spellbinder") or 
	mb_tankTarget("Blackwing Technician") or 
	mb_tankTarget("Blackwing Warlock") or 
	
	-- BWL boss
	mb_tankTarget("Razorgore the Untamed") or
	mb_tankTarget("Vaelastrasz the Corrupt") or
	mb_tankTarget("Firemaw") or 
	mb_tankTarget("Flamegor") or 
	mb_tankTarget("Ebonroc") or
	
	-- MC trash
	mb_tankTarget("Ancient Core Hound") or
	mb_tankTarget("Firelord") or 
	mb_tankTarget("Lava Spawn") or
	mb_tankTarget("Lava Elemental") or --> Stunning elemental
	mb_tankTarget("Firewalker") or 
	mb_tankTarget("Flame Imp") or 

	-- MB boss
	mb_tankTarget("Magmadar") or 
	mb_tankTarget("Gehennas") or
	mb_tankTarget("Baron Geddon") or
	mb_tankTarget("Sulfuron Harbinger") or
	mb_tankTarget("Golemagg the Incinerator") or
	mb_tankTarget("Majordomo Executus") or
	mb_tankTarget("Ragnaros") or 

	-- ZG
	mb_tankTarget("High Priestess Jeklik") or
	
	-- Naxx
	mb_tankTarget("Grand Widow Faerlina") or
	mb_tankTarget("Naxxramas Follower") or
	mb_tankTarget("Naxxramas Worshipper") or

	-- Other
	mb_tankTarget("Chromatic Dragonspawn") or 
	mb_tankTarget("Chromatic Drakonid") or
	mb_tankTarget("Chromatic Elite Guard") or
	mb_tankTarget("Chromatic Whelp") or
	mb_tankTarget("Rage Talon Dragon Guard") or 
	mb_tankTarget("Rage Talon Dragonspawn") or
	mb_tankTarget("Death Talon Dragonspawn") or
	mb_tankTarget("Anubisath Warder") or 
	mb_tankTarget("Onyxia")
end

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

function mb_shamanSetup() -- Shaman setup

	if not mb_hasBuffNamed("Drink", "player") then

		if mb_equippedSetCount("The Earthshatter") >= 8 then

			mb_selfBuff("Lightning Shield")
		end
	
		MBH_CastHeal("Chain Heal", 1, 1)
	else

		if not mb_inCombat("player") and (mb_manaPct("player") < 0.30) then 
			
			mb_smartDrink() 
		end
	end
end

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
------------------------------------------ START ROGUE CODE! -----------------------------------------
------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------
-------------------------------------------- Single Code! --------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_rogueSingle()
	local aggrox = AceLibrary("Banzai-1.0")

	mb_getTarget() -- Gettarget

	if not mb_inCombat("target") then return end -- Stop when target is not incombat

	if MB_useCooldowns.Active then -- Cooldowns
		
		mb_rogueCooldowns()
	end

	mb_autoAttack() --> Attack

	-- Energy Trinket
	if mb_inCombat("player") and UnitMana("player") <= 40 then
		
		if mb_itemNameOfEquippedSlot(13) == "Renataki\'s Charm of Trickery" and not mb_trinketOnCD(13) then 
			
			use(13)
		elseif mb_itemNameOfEquippedSlot(14) == "Renataki\'s Charm of Trickery" and not mb_trinketOnCD(14) then 
			
			use(14)
		end
	end

	if MB_myInterruptTarget and MB_doInterrupt.Active and mb_spellReady(MB_myInterruptSpell[myClass]) then -- Auto innterupt when assigned
		if UnitMana("player") >= 25 then
			
			mb_getMyInterruptTarget()

			CastSpellByName(MB_myInterruptSpell[myClass])
			mb_coolDownPrint("Interrupting!")
			MB_doInterrupt.Active = false
		end
		return
	end

	if MB_doInterrupt.Active and mb_spellReady(MB_myInterruptSpell[myClass]) then -- Auto innterupt when not assigned
		if UnitMana("player") >= 25 then
			
			CastSpellByName(MB_myInterruptSpell[myClass])
			mb_coolDownPrint("Interrupting!")
			MB_doInterrupt.Active = false
		end
		return
	end

	-- Evasion
	if aggrox:GetUnitAggroByUnitId("player") and mb_healthPct("player") < 0.8 and mb_spellReady("Evasion") then 
		
		CastSpellByName("Evasion") 
		return 
	end

	-- Vanish
	if aggrox:GetUnitAggroByUnitId("player") and mb_healthPct("player") < 0.45 and mb_spellReady("Vanish") then 
		
		CastSpellByName("Vanish") 
		return 
	end

	if mb_inMeleeRange() then
		
		-- Stun
		if mb_knowSpell("Kidney Shot") and mb_spellReady("Kidney Shot") and GetComboPoints("target") >= 3 and mb_stunnableMob() then
			
			CastSpellByName("Kidney Shot")
		end

		-- Bladefury
		if mb_spellReady("Blade Flurry") and mb_hasBuffOrDebuff("Slice and Dice", "player", "buff") then 
			
			CastSpellByName("Blade Flurry") 
		end
	end

	-- Auto Cooldowns
	if (mb_debuffSunderAmount() == 5 or mb_hasBuffOrDebuff("Expose Armor", "target", "debuff")) and mb_hasBuffOrDebuff("Slice and Dice", "player", "buff") then
		
		if UnitClassification("target") == "worldboss" then
			
			mb_rogueCooldowns()
		end

		mb_meleeTrinkets()
	end

	-- Slice and Dice
	if not MB_hasImprovedEA then
		if not mb_hasBuffOrDebuff("Slice and Dice", "player", "buff") and GetComboPoints("target") >= 1 then
			
			CastSpellByName("Slice and Dice")
		end
	end

	if MB_hasImprovedEA then
		if not mb_hasBuffOrDebuff("Slice and Dice", "player", "buff") and GetComboPoints("target") == 2 and mb_hasBuffOrDebuff("Expose Armor", "target", "debuff") then
			
			CastSpellByName("Slice and Dice")
		end
	end

	-- EA pr Evis
	if MB_hasImprovedEA then
		if GetComboPoints("target") > 4 then
			if UnitClassification("target") == "worldboss" then
			
				--mb_message("Expose Armor UP!", 40)
				CastSpellByName("Expose Armor")
			else
				CastSpellByName("Eviscerate")
			end
		end
	else
		if GetComboPoints("target") > 4 then
			
			CastSpellByName("Eviscerate")
		end
	end

	-- Save energy if active
	if MB_raidAssist.Rogue.SaveEnergyForInterrupt and not mb_hasBuffOrDebuff("Adrenaline Rush", "player", "buff") then
		if UnitMana("player") <= 65 then
			return
		end
	end

	-- Attacks
	if MB_mySpecc == "Hemo" then
		
		CastSpellByName("Hemorrhage")
	elseif MB_mySpecc == "Dagger" then
		
		CastSpellByName("Backstab")
	else
		CastSpellByName("Sinister Strike")
	end
end

------------------------------------------------------------------------------------------------------
--------------------------------------------- Multi Code! --------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_rogueMulti() -- Multi
	mb_rogueSingle()
end

------------------------------------------------------------------------------------------------------
---------------------------------------------- AOE Code! ---------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_rogueAOE() -- Aoe
	mb_rogueSingle()
end

------------------------------------------------------------------------------------------------------
------------------------------------------- Cooldowns Code! ------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_rogueCooldowns()

	if mb_imBusy() then return end

	if mb_inCombat("player") and mb_inMeleeRange() then

		if mb_spellReady("Blade Flurry") and mb_hasBuffOrDebuff("Slice and Dice", "player", "buff") then 
			
			CastSpellByName("Blade Flurry") 
		end

		if mb_useBloodFury() then
				
			mb_selfBuff("Blood Fury")
		end

		mb_selfBuff("Berserking")

		if UnitMana("player") == 0 then
			
			mb_useFromBags("Thistle Tea")
		end

		if mb_knowSpell("Adrenaline Rush") and mb_spellReady("Adrenaline Rush") then
			
			CastSpellByName("Adrenaline Rush")
		end
	end
end

------------------------------------------------------------------------------------------------------
-------------------------------------------- Setup Code! ---------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_rogueSetup() -- Rogue setup
	local faction = UnitFactionGroup("player")

	if faction == "Alliance" then
		mb_roguePoisonMainhand()
	end

	mb_roguePoisonOffhand()
end

function mb_roguePoisonOffhand() -- Poisen OT
	if mb_haveInBags("Instant Poison VI") then
		has_enchant_main, mx, mc, has_enchant_off = GetWeaponEnchantInfo()
	
		if not has_enchant_off then
			
			UseItemByName("Instant Poison VI")
			PickupInventoryItem(17)	
			ClearCursor()
		end
	end
end

function mb_roguePoisonMainhand() -- Poisen MH
	if mb_haveInBags("Instant Poison VI") then
		has_enchant_main, mx, mc, has_enchant_off = GetWeaponEnchantInfo()
		
		if not has_enchant_main then
			
			UseItemByName("Instant Poison VI")
			PickupInventoryItem(16)	
			ClearCursor()
		end
	end
end

------------------------------------------------------------------------------------------------------
----------------------------------------- START WARRIOR CODE! ----------------------------------------
------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------
-------------------------------------------- Single Code! --------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_warriorSingle() -- Warrior sinlge
	
	mb_getTarget() -- Gettarget
	
	if not mb_inCombat("target") then return end -- Target not in combat then stop
	
	if MB_warriorbinds == "Fury" then -- Equip fury gear
		if mb_myNameInTable(MB_furysThatCanTank) then
				
			mb_furyGear()
			MB_warriorbinds = nil			
		end
	end

	-- Auto break fear for DK's
	if mb_mobsToAutoBreakFear() and mb_inMeleeRange() then

		if mb_knowSpell("Death Wish") and mb_spellReady("Death Wish") then 
			
			CastSpellByName("Death Wish") 
		end
	end
	
	-- Nature Pot for Huhuran
	if mb_tankTarget("Princess Huhuran") and mb_healthPct("target") <= 0.3 and MB_myHuhuranBoxStrategy then

		if mb_haveInBags("Greater Nature Protection Potion") and not mb_isItemInBagCooldown("Greater Nature Protection Potion") then 
				
			UseItemByName("Greater Nature Protection Potion")
		end
	end

	if mb_playerIsPoisoned() and mb_spellReady("Stoneform") then -- Stoneforms
		
		mb_selfBuff("Stoneform")
	end

	if (MB_mySpecc == "BT" or MB_mySpecc == "MS") then

		if MB_useBigCooldowns.Active then -- Reck
			
			mb_warriorReck()
		end

		if MB_useCooldowns.Active then -- Cooldowns
			
			mb_warriorCooldowns()
		end

		if GetRealZoneText() == "Ahn\'Qiraj" then
			
			if mb_spellReady("Intimidating Shout") and mb_isAtSkeram() then -- Use fear on skeram
				
				CastSpellByName("Intimidating Shout")
			end
		end

		if mb_tankTarget("Princess Huhuran") and mb_healthPct("target") <= 0.3 and mb_isReadyToStaceSwitch() and MB_myHuhuranBoxStrategy then

			mb_warriorBattleDPSSingle()
			return
		end

		mb_warriorDPSSingle() -- DPS
		return

	elseif (MB_mySpecc == "Prottank" or MB_mySpecc == "Furytank") then

		if GetRealZoneText() == "Ahn'Qiraj" then
			
			if mb_hasBuffOrDebuff("True Fulfillment", "target", "debuff") then TargetByName("The Prophet Skeram") end -- If you are mindcontrolled then target the boss 

			mb_anubAlert() -- Alert Different things

			if mb_spellReady("Intimidating Shout") and mb_isAtSkeram() then -- Use fear on skeram
				
				CastSpellByName("Intimidating Shout")
			end
		end

		mb_warriorTank() -- Tank
		return
	end
end

function mb_annihilatorWeaving()

	if MB_raidAssist.Warrior.Active and not (UnitName("target") == "The Prophet Skeram" or UnitName("target") == "Emperor Vek\'nilash" or UnitName("target") == "Emperor Vek\'lor") then 
		
		for k, name in MB_raidAssist.Warrior.AnnihilatorWeavers do if myName == name then

			if UnitClassification("target") == "worldboss" then 
			
				if mb_debuffAmountShatter() == 3 then

					if mb_itemNameOfEquippedSlot(17) ~= mb_getWeaverWeapon(name ,"NOH") then 

						if mb_itemNameOfEquippedSlot(17) then

							RunLine("/unequip "..mb_itemNameOfEquippedSlot(17))
						end
					end 

					if mb_itemNameOfEquippedSlot(16) ~= mb_getWeaverWeapon(name ,"NMH") then 

						if mb_itemNameOfEquippedSlot(16) then
							
							RunLine("/unequip "..mb_itemNameOfEquippedSlot(16))
						end
					end

					RunLine("/equip "..mb_getWeaverWeapon(name ,"NMH"))
					RunLine("/equip "..mb_getWeaverWeapon(name ,"NOH"))

				else


					if mb_itemNameOfEquippedSlot(17) ~= mb_getWeaverWeapon(name ,"BOH") then 

						if mb_itemNameOfEquippedSlot(17) then

							RunLine("/unequip "..mb_itemNameOfEquippedSlot(17))
						end
					end 

					if mb_itemNameOfEquippedSlot(16) ~= mb_getWeaverWeapon(name ,"BMH") then 

						if mb_itemNameOfEquippedSlot(16) then
							
							RunLine("/unequip "..mb_itemNameOfEquippedSlot(16))
						end
					end

					RunLine("/equip "..mb_getWeaverWeapon(name ,"BMH"))
					RunLine("/equip "..mb_getWeaverWeapon(name ,"BOH"))
				end	
			else

				if mb_itemNameOfEquippedSlot(17) ~= mb_getWeaverWeapon(name ,"NOH") then 

					if mb_itemNameOfEquippedSlot(17) then

						RunLine("/unequip "..mb_itemNameOfEquippedSlot(17))
					end
				end 

				if mb_itemNameOfEquippedSlot(16) ~= mb_getWeaverWeapon(name ,"NMH") then 

					if mb_itemNameOfEquippedSlot(16) then
						
						RunLine("/unequip "..mb_itemNameOfEquippedSlot(16))
					end
				end

				RunLine("/equip "..mb_getWeaverWeapon(name ,"NMH"))
				RunLine("/equip "..mb_getWeaverWeapon(name ,"NOH"))
			end end
		end 
	end
end

function mb_warriorBattleDPSSingle() -- Single dps

	if mb_warriorIsBattle() and UnitName("target") then

		mb_autoAttack() --> Attack

		mb_annihilatorWeaving()

		if mb_spellReady("Bloodrage") and UnitMana("player") < 20 then -- Bloodrage
			
			CastSpellByName("Bloodrage")
		end

		mb_selfBuff("Battle Shout") -- Buffs

		if not mb_mobsNoSunders() then -- Sunders

			if UnitInRaid("player") and GetNumRaidMembers() > 5 and not mb_hasBuffOrDebuff("Expose Armor", "target", "debuff") then

				if mb_debuffSunderAmount() < 5 then
				
					CastSpellByName("Sunder Armor")
				end
			end
		end

		if (mb_debuffSunderAmount() == 5 or mb_hasBuffOrDebuff("Expose Armor", "target", "debuff")) then -- Cooldowns

			if mb_inMeleeRange() or mb_tankTarget("Ragnaros") then

				if UnitClassification("target") == "worldboss" then

					mb_warriorCooldowns()
				end
				
				mb_meleeTrinkets()
			end
		end

		mb_warriorExecute() -- Execute

		if MB_mySpecc == "BT" then -- Fury warr

			if UnitMana("player") > 30 and mb_spellReady("Bloodthirst") then
				
				CastSpellByName("Bloodthirst")
			end

			if UnitMana("player") > 55 then
				
				CastSpellByName("Heroic Strike")
			end
		end
		
		if MB_mySpecc == "MS" then -- Arms warr

			if UnitMana("player") > 30 and mb_spellReady("Mortal Strike") then
				
				CastSpellByName("Mortal Strike")
			end

			if UnitMana("player") > 85 then
				
				CastSpellByName("Heroic Strike")
			end
		end

		if UnitFactionGroup("player") ~= "Alliance" then	
			if UnitMana("player") > 85 then
				
				CastSpellByName("Hamstring")
			end
		end
	else 

		mb_warriorSetBattle()
	end
end

function mb_warriorDPSSingle() -- Single dps

	if mb_warriorIsBerserker() and UnitName("target") then

		mb_autoAttack() --> Attack

		mb_annihilatorWeaving()

		if mb_spellReady("Bloodrage") and UnitMana("player") < 20 then -- Bloodrage
			
			CastSpellByName("Bloodrage")
		end

		if MB_doInterrupt.Active and mb_spellReady(MB_myInterruptSpell[myClass]) then -- Auto innterupt

			if UnitMana("player") >= 10 then
				
				CastSpellByName(MB_myInterruptSpell[myClass])
				mb_coolDownPrint("Interrupting!")
				MB_doInterrupt.Active = false
			end
			return
		end

		mb_selfBuff("Battle Shout") -- Buffs

		if not mb_mobsNoSunders() then -- Sunders

			if UnitInRaid("player") and GetNumRaidMembers() > 5 and not mb_hasBuffOrDebuff("Expose Armor", "target", "debuff") then

				if mb_debuffSunderAmount() < 5 then
				
					CastSpellByName("Sunder Armor")
				end
			end
		end

		if (mb_debuffSunderAmount() == 5 or mb_hasBuffOrDebuff("Expose Armor", "target", "debuff")) then -- Cooldowns

			if mb_inMeleeRange() or mb_tankTarget("Ragnaros") then
				if mb_spellReady("Recklessness") and mb_bossIShouldUseRecklessnessOn() then
					
					mb_warriorReck()
				end

				if UnitClassification("target") == "worldboss" then

					mb_warriorCooldowns()
				end
				
				mb_meleeTrinkets()
			end
		end

		mb_warriorExecute() -- Execute

		if MB_mySpecc == "BT" then -- Fury warr

			if UnitMana("player") > 30 and mb_spellReady("Bloodthirst") then
				
				CastSpellByName("Bloodthirst")
			end

			if (UnitName("target") ~=  "Emperor Vek\'lor" or UnitName("target") ~=  "Emperor Vek\'nilash" or UnitName("target") ~=  "The Prophet Skeram") then

				if UnitMana("player") > 25 and mb_spellReady("Whirlwind") and mb_inMeleeRange() then

					if not mb_spellReady("Bloodthirst") then
						
						CastSpellByName("Whirlwind")
					end
				end	
			end

			if UnitMana("player") > 55 then --and not mb_spellReady("Whirlwind") and not mb_spellReady("Bloodthirst") then
				
				CastSpellByName("Heroic Strike")
			end
		end
		
		if MB_mySpecc == "MS" then -- Arms warr

			if UnitMana("player") > 30 and mb_spellReady("Mortal Strike") then
				
				CastSpellByName("Mortal Strike")
			end

			if (UnitName("target") ~=  "Emperor Vek\'lor" or UnitName("target") ~=  "Emperor Vek\'nilash" or UnitName("target") ~=  "The Prophet Skeram") then

				if UnitMana("player") > 25 and mb_spellReady("Whirlwind") and mb_inMeleeRange() then

					if not mb_spellReady("Mortal Strike") then
						
						CastSpellByName("Whirlwind")
					end
				end	
			end

			if UnitMana("player") > 85 then --and not mb_spellReady("Whirlwind") and not mb_spellReady("Bloodthirst") then
				
				CastSpellByName("Heroic Strike")
			end
		end

		if UnitFactionGroup("player") ~= "Alliance" then	
			if UnitMana("player") > 85 then --and not mb_spellReady("Whirlwind") and not mb_spellReady("Bloodthirst") then
				
				CastSpellByName("Hamstring")
			end
		end
	else 

		mb_warriorSetBerserker()
	end
end

function mb_warriorTank()

	if mb_findInTable(MB_raidTanks, myName) and mb_hasBuffOrDebuff("Greater Blessing of Salvation", "player", "buff") then -- Remove salv
		
		CancelBuff("Greater Blessing of Salvation") 
	end

	if mb_inCombat("player") then -- Boss Specific (incombat)

		if mb_tankTarget("Patchwerk") and MB_myPatchwerkBoxStrategy then

			if mb_healthPct("target") <= 0.05 then
				
				if mb_spellReady("Last Stand") then
					
					CastSpellByName("Last Stand")
				end
				
				if mb_spellReady("Shield Wall") and mb_hasShield() then 
				
					CastSpellByName("Shield Wall")
				end
			end

			if mb_haveInBags("Juju Escape") and not mb_isItemInBagCooldown("Juju Escape") then 
				
				TargetUnit("player")
				UseItemByName("Juju Escape")
				TargetLastTarget()
			end

			if mb_haveInBags("Greater Stoneshield Potion") and not mb_isItemInBagCooldown("Greater Stoneshield Potion") then 
				
				UseItemByName("Greater Stoneshield Potion")
			end

		elseif mb_tankTarget("Princess Huhuran") and mb_healthPct("target") <= MB_myHuhuranTankDefensivePercentage and MB_myHuhuranBoxStrategy then

			if mb_spellReady("Last Stand") then
					
				CastSpellByName("Last Stand")
			end
			
			if mb_spellReady("Shield Wall") and mb_hasShield() then 
			
				CastSpellByName("Shield Wall")
			end

		elseif mb_tankTarget("Ossirian the Unscarred") and mb_healthPct("target") <= MB_myOssirianTankDefensivePercentage and MB_myOssirianBoxStrategy then

			if mb_healthPct("player") <= 0.3 then
				
				if mb_spellReady("Last Stand") then
					
					CastSpellByName("Last Stand")
				end
				
				if mb_spellReady("Shield Wall") and mb_hasShield() then 
				
					CastSpellByName("Shield Wall")
				end
			end

		elseif mb_tankTarget("Chromaggus") then

				if mb_healthPct("target") <= 0.07 then
					
					if mb_spellReady("Last Stand") then
						
						CastSpellByName("Last Stand")
					end
					
					if mb_spellReady("Shield Wall") and mb_hasShield() then 
					
						CastSpellByName("Shield Wall")
					end
				end

		elseif mb_tankTarget("Maexxna") and MB_myMaexxnaBoxStrategy then

			if mb_myNameInTable(MB_myMaexxnaMainTank) then

				if mb_hasBuffOrDebuff("Prayer of Spirit", "player", "buff") then
					CancelBuff("Prayer of Spirit")
				end

				if mb_hasBuffOrDebuff("Arcane Brilliance", "player", "buff") then
					CancelBuff("Arcane Brilliance")
				end

				if mb_hasBuffOrDebuff("Divine Spirit", "player", "buff") then
					CancelBuff("Divine Spirit")
				end
				
				if mb_hasBuffOrDebuff("Prayer of Shadow Protection", "player", "buff") then
					CancelBuff("Prayer of Shadow Protection")
				end
			end

		elseif mb_tankTarget("Vaelastrasz the Corrupt") then
			
			if mb_knowSpell("Death Wish") and mb_spellReady("Death Wish") then 
			
				CastSpellByName("Death Wish") 	
			end

			if mb_hasBuffOrDebuff("Burning Adrenaline", "player", "debuff") then

				if mb_spellReady("Shield Wall") and mb_hasShield() then 
				
					CastSpellByName("Shield Wall")
				end

				if mb_spellReady("Last Stand") then
					
					CastSpellByName("Last Stand")
				end
			end

		elseif mb_tankTarget("Firemaw") then

			if mb_haveInBags("Juju Ember") and not mb_isItemInBagCooldown("Juju Ember") and not mb_hasBuffOrDebuff("Juju Ember", "player", "buff") then 
				
				TargetUnit("player")
				UseItemByName("Juju Ember")
				TargetLastTarget()
			end

			if mb_healthPct("target") <= 0.15 then

				if mb_healthPct("player") <= 0.3 then
					
					if mb_spellReady("Last Stand") then
						
						CastSpellByName("Last Stand")
					end
					
					if mb_spellReady("Shield Wall") and mb_hasShield() then 
					
						CastSpellByName("Shield Wall")
					end
				end
			end
		end

		-- Tank survive
		if mb_healthPct("player") <= 0.25 then
			
			if mb_itemNameOfEquippedSlot(13) == "Lifegiving Gem" and not mb_trinketOnCD(13) then 
				use(13)

			elseif mb_itemNameOfEquippedSlot(14) == "Lifegiving Gem" and not mb_trinketOnCD(14) then 
				use(14)
			end
		end

		if not (mb_tankTarget("Patchwerk") or mb_tankTarget("Maexxna")) then
			
			if mb_healthPct("player") <= 0.2 and mb_spellReady("Last Stand") then 
				
				CastSpellByName("Last Stand") 
			end
		end

		if mb_inMeleeRange() then

			if (mb_debuffSunderAmount() == 5 or mb_hasBuffOrDebuff("Expose Armor", "target", "debuff")) then
			
				mb_meleeTrinkets()
			end

			-- Stun
			if mb_knowSpell("Concussion Blow") and mb_spellReady("Concussion Blow") and mb_stunnableMob() then
				
				CastSpellByName("Concussion Blow")
			end

			-- Disarm
			if mb_spellReady("Disarm") and UnitName("target") == "Gurubashi Axe Thrower" and not mb_hasBuffOrDebuff("Disarm", "target", "debuff") then
				
				CastSpellByName("Disarm")
			end

			if mb_spellReady("Disarm") and mb_healthPct("target") < 0.5 and not mb_hasBuffOrDebuff("Disarm", "target", "debuff") and (UnitName("target") == "Infectious Ghoul" or UnitName("target") == "Plagued Ghoul") then
				
				CastSpellByName("Disarm")
			end

			if mb_spellReady("Disarm") and mb_healthPct("target") <= 0.21 and not mb_hasBuffOrDebuff("Disarm", "target", "debuff") and (UnitName("target") == "Anubisath Sentinel" or UnitName("target") == "Anubisath Defender") then
				
				CastSpellByName("Disarm")
			end

			-- Block
			if mb_healthPct("player") < 0.85 and UnitMana("player") >= 20 and mb_hasShield() then 
				
				CastSpellByName("Shield Block") 
			end

			-- Demo
			if UnitName("target") ~= "Emperor Vek\'nilash" or UnitName("target") ~= "Emperor Vek\'lor" then -- Check online player, and if that one has imp demo make him do demo first (boss only maybe?)
				
				if not mb_hasBuffOrDebuff("Demoralizing Shout", "target", "debuff") and UnitMana("player") >= 20 then 
					
					CastSpellByName("Demoralizing Shout")
				end
			end
		end
	end

	mb_offTank()

	if UnitName("target") and mb_crowdControlledMob() and not myName == MB_raidLeader then return end

	local ttname =  UnitName("targettarget")
	local tname =  UnitName("target")
	if not tname then tname = "" end

	if MB_myOTTarget then -- Taunting
		if tname and ttname and ttname ~= "Unknown" and UnitIsEnemy("player", "target") and ttname ~= myName and not mb_findInTable(MB_raidTanks, ttname) then
			
			mb_warriorTaunt()
		end
	else
		if tname and ttname and ttname ~= "Unknown" and UnitIsEnemy("player", "target") and not mb_findInTable(MB_raidTanks, ttname) then
			
			mb_warriorTaunt()
		end
	end

	if MB_doInterrupt.Active and mb_spellReady("Shield Bash") then -- Auto interrupt
		
		if UnitMana("player") >= 10 then
			
			CastSpellByName("Shield Bash")
			mb_coolDownPrint("Interrupting!")
			MB_doInterrupt.Active = false
		end
	end

	if MB_myOTTarget then -- Try to clear Tank target when its dead
		if UnitExists("target") and GetRaidTargetIndex("target") and GetRaidTargetIndex("target") == MB_myOTTarget and UnitIsDead("target") then
			MB_myOTTarget = nil
			ClearTarget()
		end
	end

	if mb_warriorIsDefensive() then
		
		mb_autoAttack() --> Attack

		if mb_spellReady("Bloodrage") and UnitMana("player") <= 15 then --> Blood Rage
			
			CastSpellByName("Bloodrage")
		end
		
		mb_selfBuff("Battle Shout") -- Buffs
		
		if UnitMana("player") >= 5 and mb_spellReady("Revenge") then 
			
			CastSpellByName("Revenge")
		end
		
		if MB_mySpecc == "Prottank" then

			if mb_spellReady("Shield Slam") and UnitMana("player") >= 20 and mb_hasShield() then
			
				CastSpellByName("Shield Slam")
			end

		elseif MB_mySpecc == "Furytank" then

			if mb_spellReady("Bloodthirst") and UnitMana("player") >= 30 then
				
				CastSpellByName("Bloodthirst")
			end	
		end
		
		-- Sunder
		if UnitName("target") ~= "Deathknight Understudy" and not mb_hasBuffOrDebuff("Expose Armor", "target", "debuff") then
			
			CastSpellByName("Sunder Armor")
		end

		-- Rotation
		if mb_hasBuffOrDebuff("Expose Armor", "target", "debuff") then
			
			if not mb_spellReady("Bloodthirst") and UnitMana("player") >= 23 then
				
				CastSpellByName("Heroic Strike")

			elseif UnitMana("player") >= 43 then
				
				CastSpellByName("Heroic Strike") 
			end

		else 
			
			if UnitMana("player") >= 43 then
				
				CastSpellByName("Heroic Strike") 
			end
		end

	else
		mb_warriorSetDefensive() -- Set zerker
	end
end


------------------------------------------------------------------------------------------------------
--------------------------------------------- Multi Code! --------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_warriorMulti() -- Warrior multi

	mb_getTarget() -- Gettarget
	
	if not mb_inCombat("target") then return end -- Target not in combat then stop
	
	if MB_warriorbinds == "Fury" then -- Equip fury gear
		if mb_myNameInTable(MB_furysThatCanTank) then
				
			mb_furyGear()
			MB_warriorbinds = nil			
		end
	end

	-- Auto break fear for DK's
	if mb_mobsToAutoBreakFear() and mb_inMeleeRange() then

		if mb_knowSpell("Death Wish") and mb_spellReady("Death Wish") then 
			
			CastSpellByName("Death Wish") 
		end
	end

	-- Nature Pot for Huhuran
	if mb_tankTarget("Princess Huhuran") and mb_healthPct("target") <= 0.3 and MB_myHuhuranBoxStrategy then

		if mb_haveInBags("Greater Nature Protection Potion") and not mb_isItemInBagCooldown("Greater Nature Protection Potion") then 
				
			UseItemByName("Greater Nature Protection Potion")
		end
	end

	if mb_playerIsPoisoned() and mb_spellReady("Stoneform") then -- Stoneforms
		
		mb_selfBuff("Stoneform")
	end

	if (MB_mySpecc == "BT" or MB_mySpecc == "MS") then

		if MB_useBigCooldowns.Active then -- Reck
			
			mb_warriorReck()
		end

		if MB_useCooldowns.Active then -- Cooldowns
			
			mb_warriorCooldowns()
		end

		if GetRealZoneText() == "Ahn\'Qiraj" then
			
			if mb_spellReady("Intimidating Shout") and mb_isAtSkeram() then -- Use fear on skeram
				
				CastSpellByName("Intimidating Shout")
			end
		end

		if mb_tankTarget("Princess Huhuran") and mb_healthPct("target") <= 0.3 and MB_myHuhuranBoxStrategy then

			mb_warriorBattleDPSSingle()
			return
		end
		
		mb_warriorDPSMulti() -- DPS Multi
		return

	elseif (MB_mySpecc == "Prottank" or MB_mySpecc == "Furytank") then

		if GetRealZoneText() == "Ahn'Qiraj" then
			
			if mb_hasBuffOrDebuff("True Fulfillment", "target", "debuff") then TargetByName("The Prophet Skeram") end -- If you are mindcontrolled then target the boss 

			mb_anubAlert() -- Alert Different things

			if mb_spellReady("Intimidating Shout") and mb_isAtSkeram() then -- Use fear on skeram
				
				CastSpellByName("Intimidating Shout")
			end
		end

		mb_warriorTankMulti() -- Tank multi
		return
	end
end

function mb_warriorDPSMulti() -- Multi dps

	-- Sweeping strikes
	if MB_mySpecc == "MS" and not mb_hasBuffOrDebuff("Sweeping Strikes", "player", "buff") and mb_spellReady("Sweeping Strikes") then
		if UnitName("target") then
			
			mb_warriorSetBattle()

			mb_autoAttack()
		
			if mb_spellReady("Bloodrage") then 
				
				CastSpellByName("Bloodrage")
			end
			
			CastSpellByName("Sweeping Strikes")
			return
		end
	end

	if mb_warriorIsBerserker() and UnitName("target") then

		mb_autoAttack() --> Attack

		mb_annihilatorWeaving()

		if mb_spellReady("Bloodrage") and UnitMana("player") < 20 then -- Bloodrage
			
			CastSpellByName("Bloodrage")
		end
		
		if MB_doInterrupt.Active and mb_spellReady(MB_myInterruptSpell[myClass]) then -- Auto innterupt

			if UnitMana("player") >= 10 then
				
				CastSpellByName(MB_myInterruptSpell[myClass])
				mb_coolDownPrint("Interrupting!")
				MB_doInterrupt.Active = false
			end
			return
		end

		mb_selfBuff("Battle Shout") -- Buffs

		if not mb_mobsNoSunders() then -- Sunders

			if UnitInRaid("player") and GetNumRaidMembers() > 5 and not mb_hasBuffOrDebuff("Expose Armor", "target", "debuff") then

				if mb_debuffSunderAmount() < 5 then
				
					CastSpellByName("Sunder Armor")
				end
			end
		end

		if (mb_debuffSunderAmount() == 5 or mb_hasBuffOrDebuff("Expose Armor", "target", "debuff")) then -- Cooldowns

			if mb_inMeleeRange() or mb_tankTarget("Ragnaros") then
				if mb_spellReady("Recklessness") and mb_bossIShouldUseRecklessnessOn() then
					
					mb_warriorReck()
				end

				if UnitClassification("target") == "worldboss" then

					mb_warriorCooldowns()
				end
				
				mb_meleeTrinkets()
			end
		end

		mb_warriorExecute() -- Execute
		
		if MB_mySpecc == "BT" then -- Fury warr

			if mb_inMeleeRange() then

				if mb_spellReady("Whirlwind") and UnitMana("player") >= 25 then

					CastSpellByName("Whirlwind") 
				end
			
				if not mb_spellReady("Whirlwind") and UnitMana("player") >= 25 then

					if mb_spellReady("Bloodthirst") and UnitMana("player") >= 30 then
				
						CastSpellByName("Bloodthirst")
					end

					if not mb_spellReady("Bloodthirst") then
						
						CastSpellByName("Cleave")
					end
				end
			end
			
		elseif MB_mySpecc == "MS" then -- Arms

			if mb_inMeleeRange() then

				if mb_spellReady("Whirlwind") and UnitMana("player") >= 25 then

					CastSpellByName("Whirlwind") 
				end	
			
				if not mb_spellReady("Whirlwind") and UnitMana("player") >= 25 then

					if mb_spellReady("Mortal Strike") and UnitMana("player") >= 30 then
				
						CastSpellByName("Mortal Strike")
					end

					if not mb_spellReady("Mortal Strike") then
						
						CastSpellByName("Cleave")
					end
				end
			end
		end
	else 
		mb_warriorSetBerserker() -- Set zerker
	end
end

function mb_warriorTankMulti() -- Tank multi

	if mb_findInTable(MB_raidTanks, myName) and mb_hasBuffOrDebuff("Greater Blessing of Salvation", "player", "buff") then -- Remove salv
		
		CancelBuff("Greater Blessing of Salvation") 
	end

	if mb_inCombat("player") then -- Boss Specific (incombat)

		if mb_tankTarget("Patchwerk") and MB_myPatchwerkBoxStrategy then

			if mb_healthPct("target") < 0.05 then
				
				if mb_spellReady("Last Stand") then
					
					CastSpellByName("Last Stand")
				end
				
				if mb_spellReady("Shield Wall") and mb_hasShield() then 
				
					CastSpellByName("Shield Wall")
				end
			end

			if mb_haveInBags("Juju Escape") and not mb_isItemInBagCooldown("Juju Escape") then 
				
				TargetUnit("player")
				UseItemByName("Juju Escape")
				TargetLastTarget()
			end

			if mb_haveInBags("Greater Stoneshield Potion") and not mb_isItemInBagCooldown("Greater Stoneshield Potion") then 
				
				UseItemByName("Greater Stoneshield Potion")
			end

		elseif mb_tankTarget("Princess Huhuran") and mb_healthPct("target") <= MB_myHuhuranTankDefensivePercentage and MB_myHuhuranBoxStrategy then

			if mb_spellReady("Last Stand") then
					
				CastSpellByName("Last Stand")
			end

			if mb_spellReady("Shield Wall") then 
			
				CastSpellByName("Shield Wall")
			end

		elseif mb_tankTarget("Maexxna") and MB_myMaexxnaBoxStrategy then

			if mb_myNameInTable(MB_myMaexxnaMainTank) then

				if mb_hasBuffOrDebuff("Prayer of Spirit", "player", "buff") then
					CancelBuff("Prayer of Spirit")
				end

				if mb_hasBuffOrDebuff("Arcane Brilliance", "player", "buff") then
					CancelBuff("Arcane Brilliance")
				end

				if mb_hasBuffOrDebuff("Divine Spirit", "player", "buff") then
					CancelBuff("Divine Spirit")
				end
				
				if mb_hasBuffOrDebuff("Prayer of Shadow Protection", "player", "buff") then
					CancelBuff("Prayer of Shadow Protection")
				end
			end

		elseif mb_tankTarget("Ossirian the Unscarred") and mb_healthPct("target") <= MB_myOssirianTankDefensivePercentage and MB_myOssirianBoxStrategy then

			if mb_healthPct("player") <= 0.3 then 
				
				if mb_spellReady("Shield Wall") then 
			
					CastSpellByName("Shield Wall")
				end
			end

		elseif mb_tankTarget("Chromaggus") then

			if mb_healthPct("target") <= 0.07 then
				
				if mb_spellReady("Last Stand") then
					
					CastSpellByName("Last Stand")
				end
				
				if mb_spellReady("Shield Wall") and mb_hasShield() then 
				
					CastSpellByName("Shield Wall")
				end
			end

		elseif mb_tankTarget("Vaelastrasz the Corrupt") and mb_hasBuffOrDebuff("Burning Adrenaline", "player", "debuff") then

			if mb_spellReady("Last Stand") then
					
				CastSpellByName("Last Stand")
			end

			if mb_spellReady("Shield Wall") then 
			
				CastSpellByName("Shield Wall")
			end
		end

		-- Tank survive
		if mb_healthPct("player") < 0.25 then
			
			if mb_itemNameOfEquippedSlot(13) == "Lifegiving Gem" and not mb_trinketOnCD(13) then 
				use(13)

			elseif mb_itemNameOfEquippedSlot(14) == "Lifegiving Gem" and not mb_trinketOnCD(14) then 
				use(14)
			end
		end

		if not (mb_tankTarget("Patchwerk") or mb_tankTarget("Maexxna")) then
			
			if mb_healthPct("player") < 0.2 and mb_spellReady("Last Stand") then 
				
				CastSpellByName("Last Stand") 
			end
		end

		if mb_inMeleeRange() then

			if (mb_debuffSunderAmount() == 5 or mb_hasBuffOrDebuff("Expose Armor", "target", "debuff")) then
			
				mb_meleeTrinkets()
			end

			-- Stun
			if mb_knowSpell("Concussion Blow") and mb_spellReady("Concussion Blow") and mb_stunnableMob() then
				
				CastSpellByName("Concussion Blow")
			end

			-- Disarm
			if mb_spellReady("Disarm") and UnitName("target") == "Gurubashi Axe Thrower" and not mb_hasBuffOrDebuff("Disarm", "target", "debuff") then
				
				CastSpellByName("Disarm")
			end

			if mb_spellReady("Disarm") and mb_healthPct("target") < 0.5 and not mb_hasBuffOrDebuff("Disarm", "target", "debuff") and (UnitName("target") == "Infectious Ghoul" or UnitName("target") == "Plagued Ghoul") then
				
				CastSpellByName("Disarm")
			end

			if mb_spellReady("Disarm") and mb_healthPct("target") <= 0.21 and not mb_hasBuffOrDebuff("Disarm", "target", "debuff") and (UnitName("target") == "Anubisath Sentinel" or UnitName("target") == "Anubisath Defender") then
				
				CastSpellByName("Disarm")
			end

			-- Block
			if mb_healthPct("player") < 0.85 and UnitMana("player") >= 20 and mb_hasShield() then 
				
				CastSpellByName("Shield Block") 
			end

			-- Demo
			if UnitName("target") ~= "Emperor Vek\'nilash" or UnitName("target") ~= "Emperor Vek\'lor" then -- Check online player, and if that one has imp demo make him do demo first (boss only maybe?)
				
				if not mb_hasBuffOrDebuff("Demoralizing Shout", "target", "debuff") and UnitMana("player") >= 20 then 
					
					CastSpellByName("Demoralizing Shout")
				end
			end
		end
	end

	mb_offTank()

	if UnitName("target") and mb_crowdControlledMob() and not myName == MB_raidLeader then return end

	local ttname =  UnitName("targettarget")
	local tname =  UnitName("target")
	if not tname then tname = "" end

	if MB_myOTTarget then -- Taunting
		if tname and ttname and ttname ~= "Unknown" and UnitIsEnemy("player", "target") and ttname ~= myName and not mb_findInTable(MB_raidTanks, ttname) then
			
			mb_warriorTaunt()
		end
	else
		if tname and ttname and ttname ~= "Unknown" and UnitIsEnemy("player", "target") and not mb_findInTable(MB_raidTanks, ttname) then
			
			mb_warriorTaunt()
		end
	end

	if MB_doInterrupt.Active and mb_spellReady("Shield Bash") then -- Auto interrupt
		
		if UnitMana("player") >= 10 then
			
			CastSpellByName("Shield Bash")
			mb_coolDownPrint("Interrupting!")
			MB_doInterrupt.Active = false
		end
	end

	if MB_myOTTarget then -- Try to clear Tank target when its dead
		if UnitExists("target") and GetRaidTargetIndex("target") and GetRaidTargetIndex("target") == MB_myOTTarget and UnitIsDead("target") then
			MB_myOTTarget = nil
			ClearTarget()
		end
	end

	if mb_warriorIsDefensive() then

		mb_autoAttack() --> Attack

		if mb_spellReady("Bloodrage") and UnitMana("player") <= 15 then --> Blood Rage
			
			CastSpellByName("Bloodrage")
		end
		
		mb_selfBuff("Battle Shout") -- Buffs
		
		-- Rotation
		if UnitMana("player") >= 5 and mb_spellReady("Revenge") then 
			
			CastSpellByName("Revenge")
		end

		if UnitMana("player") >= 20 then
			
			CastSpellByName("Cleave") 
		end
		
		if MB_mySpecc == "Prottank" then
			
			if mb_spellReady("Shield Slam") and UnitMana("player") >= 20 and mb_hasShield() then
				
				CastSpellByName("Shield Slam")
			end

		elseif MB_mySpecc == "Furytank" then
			
			if mb_spellReady("Bloodthirst") and UnitMana("player") >= 30 then
				
				CastSpellByName("Bloodthirst")
			end	
		end

		-- Sunder
		if UnitName("target") ~= "Deathknight Understudy" and not mb_hasBuffOrDebuff("Expose Armor", "target", "debuff") then
			
			CastSpellByName("Sunder Armor")
		end

	else
		mb_warriorSetDefensive()
	end
end

------------------------------------------------------------------------------------------------------
---------------------------------------------- AOE Code! ---------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_warriorAOE() -- Warr AOE
	mb_warriorMulti()
end

------------------------------------------------------------------------------------------------------
------------------------------------------- Cooldowns Code! ------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_warriorCooldowns() -- Warrior cooldowns

	if mb_imBusy() then return end

	if mb_inCombat("player") then

		if mb_knowSpell("Death Wish") and mb_spellReady("Death Wish") and UnitMana("player") >= 10 then 
			
			CastSpellByName("Death Wish") 
		end

		if mb_knowSpell("Blood Fury") and mb_spellReady("Blood Fury") then 
			
			CastSpellByName("Blood Fury") 
		end

		if mb_knowSpell("Berserking") and mb_spellReady("Berserking") then 
			
			CastSpellByName("Berserking") 
		end

		mb_meleeTrinkets()
	end
end

function mb_warriorReck() -- Warrior Reck

	if mb_imBusy() then return end

	if mb_inCombat("player") then

		if mb_knowSpell("Recklessness") and mb_spellReady("Recklessness") then 
			
			CastSpellByName("Recklessness") 
		end

		mb_warriorCooldowns()
	end
end

function mb_warriorTaunt() -- Warrior taunt

	if mb_spellReady("Taunt") then

		mb_warriorSetDefensive()
		CastSpellByName("Taunt")
		return
	end

	if mb_iamFocus() then return end
	
	if not MB_hasTacMastery then return end -- Only stance switch if you have tac mastety
	
	if mb_spellReady("Mocking Blow") and UnitMana("player") >= 10 then
		if mb_warriorIsBattle() then
			CastSpellByName("Mocking Blow")
			return
		else
			mb_warriorSetBattle()
		end
	end
end

function mb_warriorExecute() -- EXecute and BT function, according to AP
	local UDbonus = 0

	if UnitName("target") and (UnitCreatureType("target") == "Undead" or UnitCreatureType("target") == "Demon") then
		if (mb_itemNameOfEquippedSlot(13) == "Mark of the Champion" or mb_itemNameOfEquippedSlot(14) == "Mark of the Champion") then
			UDbonus = 150
		end
	end

	if UnitName("target") and UnitCreatureType("target") == "Undead" then
		if (mb_itemNameOfEquippedSlot(13) == "Seal of the Dawn" or mb_itemNameOfEquippedSlot(14) == "Seal of the Dawn") then
			UDbonus = UDbonus + 81
		end
	end

	local a, b, c = UnitAttackPower("player")
	local AP = a + b + c + UDbonus
	local BTDmg = AP*0.45

	local impExe = 820
	if mb_warriorImpExecute() then
		impExe = 900
	end

	if (mb_healthPct("target") < 0.20) then	
		if impExe >= BTDmg then
			CastSpellByName("Execute")
			return
		end
		
		if BTDmg >= impExe and mb_spellReady("Bloodthirst") then 
			CastSpellByName("Bloodthirst")
			return
		end
		
		CastSpellByName("Execute")
	end
end

function mb_warriorImpExecute()
	local _, icon, _, _, amounttalentsin = GetTalentInfo(2, 10)
	if amounttalentsin > 1 then
		return true
	else
		return nil
	end
end

------------------------------------------------------------------------------------------------------
-------------------------------------------- Stance Code! --------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_isReadyToStaceSwitch()
	return UnitMana("player") < 25
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

------------------------------------------------------------------------------------------------------
----------------------------------------- START WARLOCK CODE! ----------------------------------------
------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------
-------------------------------------------- Single Code! --------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_warlockSingle()	-- Single Code

	if not MB_mySpecc then --> Specc Defaults
		
		mb_message("My specc is fucked. Defaulting to Corruption.")
		MB_mySpecc = "Corruption"
	end

	mb_getTarget() -- Gettarget

	if mb_crowdControl() then return end -- No need to do anything when CCing

	if (mb_manaPct("player") < 0.40 and mb_healthPct("player") > 0.75) then -- Lifetap if needed

		CastSpellByName("Life Tap")
		return
	end

	if mb_hasBuffOrDebuff("Hellfire", "player", "buff") then  -- Lifetab if you are hellfire'ing
		
		CastSpellByName("Life Tap(Rank 1)")
		return
	end

	if GetRealZoneText() == "Ahn\'Qiraj" and MB_mySkeramBoxStrategyWarlock then --> Fear skeram
		
		if mb_hasBuffOrDebuff("True Fulfillment", "target", "debuff") then ClearTarget() return end -- If your target is still a MC'd target here, clear target

		if mb_isAtSkeram() then

			if not MB_autoToggleSheeps.Active then

				MB_autoToggleSheeps.Active = true
				MB_autoToggleSheeps.Time = GetTime() + 6

				if MB_ssCounterWarlock == TableLength(MB_classList["Warlock"]) + 1 then
					
					MB_ssCounterWarlock = 1
				else

					MB_ssCounterWarlock = MB_ssCounterWarlock + 1
				end
			end

			if MB_ssCounterWarlock == mb_myClassAlphabeticalOrder() then

				mb_crowdControlMCedRaidMemberSkeramFear()
			end
		end
	end

	if not mb_inCombat("target") then return end -- If target is not in combat then stop

	if mb_inCombat("player") then -- Incombat player

		mb_warlockHealthStone() -- Healthstone if low

		if MB_isMoving.Active then -- Bandage adn tap if walking

			mb_warlockTapWhileMoving()
		end
	
		-- Get pet
		if mb_knowSpell("Demonic Sacrifice") then

			if not mb_hasBuffOrDebuff("Touch of Shadow", "player", "buff") then
				
				mb_warlockSumPetAndSac()
			end
		end		

		-- Cooldowns
		if mb_manaDown("player") > 600 then mb_warlockCooldowns() end
	end

	if UnitClassification("target") ~= "worldboss" then -- Suck soul if needed
		if mb_healthPct("target") < 0.2 and mb_numShards() < 60 and mb_getAllContainerFreeSlots() >= 10 and not mb_imBusy() then

			CastSpellByName("Drain Soul(Rank 1)")
			return
		end
	end

	if mb_warlockBossSpecificDPS() then return end -- Boss specific dps

	if UnitClassification("target") == "worldboss" then
		local wndslot = tonumber(MB_attackWandSlot)

		if MB_mySpecc == "Corruption" and UnitMana("player") > MB_classSpellManaCost["Corruption"] and not IsAutoRepeatAction(wndslot) then
			
			mb_coolDownCast("Corruption", 18)
		end
	end

	-- Rotation
	if MB_mySpecc == "Shadowburn" and MB_raidAssist.Warlock.ShouldBeWhores then
		
		mb_warlockShadowBoltWhoring()
	else
	
		mb_castSpellOrWand("Shadow Bolt")

		if not mb_spellReady("Shadow Bolt") then
			
			mb_castSpellOrWand("Searing Pain")
		end
	end
end

------------------------------------------------------------------------------------------------------
--------------------------------------------- Multi Code! --------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_warlockMulti() -- Multi Warlock
	mb_warlockSingle()
end

------------------------------------------------------------------------------------------------------
---------------------------------------------- AOE Code! ---------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_warlockAOE() -- Aoe Warlock
	
	mb_getTarget() -- Gettarget

	mb_warlockHealthStone() -- Healthstone if low

	if (UnitMana("player") < 1250) and not mb_imBusy() then -- Lifetap if needed

		CastSpellByName("Life Tap")
		return		
	end

	if not mb_hasBuffOrDebuff("Hellfire", "player", "buff") then -- Go hellfire

		mb_casterTrinkets()
		CastSpellByName("Hellfire") 
	end
end

------------------------------------------------------------------------------------------------------
--------------------------------------------- Burst Code! --------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_warlockBossSpecificDPS()

	if UnitName("target") == "Emperor Vek\'nilash" then return true end

	if UnitName("target") == "Chromaggus" then CastSpellByName("Curse of Recklessness") return true end

	-- Curses 
	if not mb_hasBuffNamed("Shadow and Frost Reflect", "target") then
		if mb_isAtSkeram() and MB_mySkeramBoxStrategyFollow then
			
			if mb_myClassAlphabeticalOrder() == 1 then

				if mb_targetFromSpecificPlayer("The Prophet Skeram", mb_returnPlayerInRaidFromTable(MB_mySkeramLeftTank)) and not mb_hasBuffOrDebuff("Curse of Tongues", MBID[mb_returnPlayerInRaidFromTable(MB_mySkeramLeftTank)].."target", "debuff") then

					AssistUnit(MBID[mb_returnPlayerInRaidFromTable(MB_mySkeramLeftTank)])

					if mb_imBusy() then
				
						SpellStopCasting()
					end

					CastSpellByName("Curse of Tongues")
					TargetLastTarget()
					return true
				end

			elseif mb_myClassAlphabeticalOrder() == 2 then 

				if mb_targetFromSpecificPlayer("The Prophet Skeram", mb_returnPlayerInRaidFromTable(MB_mySkeramMiddleTank)) and not mb_hasBuffOrDebuff("Curse of Tongues", MBID[mb_returnPlayerInRaidFromTable(MB_mySkeramMiddleTank)].."target", "debuff") then

					AssistUnit(MBID[mb_returnPlayerInRaidFromTable(MB_mySkeramMiddleTank)])

					if mb_imBusy() then
						
						SpellStopCasting()
					end

					CastSpellByName("Curse of Tongues")
					TargetLastTarget()
					return true
				end

			elseif mb_myClassAlphabeticalOrder() == 3 then 

				if mb_targetFromSpecificPlayer("The Prophet Skeram", mb_returnPlayerInRaidFromTable(MB_mySkeramRightTank)) and not mb_hasBuffOrDebuff("Curse of Tongues", MBID[mb_returnPlayerInRaidFromTable(MB_mySkeramRightTank)].."target", "debuff") then

					AssistUnit(MBID[mb_returnPlayerInRaidFromTable(MB_mySkeramRightTank)])

					if mb_imBusy() then
				
						SpellStopCasting()
					end

					CastSpellByName("Curse of Tongues")
					TargetLastTarget()
					return true
				end

			elseif mb_myClassAlphabeticalOrder() == 4 then 

				if mb_targetFromSpecificPlayer("The Prophet Skeram", mb_returnPlayerInRaidFromTable(MB_mySkeramLeftTank)) and not mb_hasBuffOrDebuff("Curse of Tongues", MBID[mb_returnPlayerInRaidFromTable(MB_mySkeramLeftTank)].."target", "debuff") then

					AssistUnit(MBID[mb_returnPlayerInRaidFromTable(MB_mySkeramLeftTank)])

					if mb_imBusy() then
				
						SpellStopCasting()
					end

					CastSpellByName("Curse of Tongues")
					TargetLastTarget()
					return true
				end

			elseif mb_myClassAlphabeticalOrder() == 5 then 

				if mb_targetFromSpecificPlayer("The Prophet Skeram", mb_returnPlayerInRaidFromTable(MB_mySkeramMiddleTank)) and not mb_hasBuffOrDebuff("Curse of Tongues", MBID[mb_returnPlayerInRaidFromTable(MB_mySkeramMiddleTank)].."target", "debuff") then

					AssistUnit(MBID[mb_returnPlayerInRaidFromTable(MB_mySkeramMiddleTank)])

					if mb_imBusy() then
						
						SpellStopCasting()
					end

					CastSpellByName("Curse of Tongues")
					TargetLastTarget()
					return true
				end

			elseif mb_myClassAlphabeticalOrder() == 6 then 

				if mb_targetFromSpecificPlayer("The Prophet Skeram", mb_returnPlayerInRaidFromTable(MB_mySkeramRightTank)) and not mb_hasBuffOrDebuff("Curse of Tongues", MBID[mb_returnPlayerInRaidFromTable(MB_mySkeramRightTank)].."target", "debuff") then

					AssistUnit(MBID[mb_returnPlayerInRaidFromTable(MB_mySkeramRightTank)])

					if mb_imBusy() then
				
						SpellStopCasting()
					end

					CastSpellByName("Curse of Tongues")
					TargetLastTarget()
					return true
				end
			end
			return

		elseif GetRealZoneText() == "Blackwing Lair" then
			
			if (GetSubZoneText() == "Dragonmaw Garrison" and mb_isAtRazorgorePhase()) and MB_myRazorgoreBoxStrategy then

				if mb_myClassAlphabeticalOrder() == 1 then

					if mb_targetFromSpecificPlayer("Death Talon Dragonspawn", mb_returnPlayerInRaidFromTable(MB_myRazorgoreRightTank)) and not mb_hasBuffOrDebuff("Curse of Recklessness", MBID[mb_returnPlayerInRaidFromTable(MB_myRazorgoreRightTank)].."target", "debuff") then

						AssistUnit(MBID[mb_returnPlayerInRaidFromTable(MB_myRazorgoreRightTank)])

						CastSpellByName("Curse of Recklessness")
						TargetLastTarget()
						return true
					end

				elseif mb_myClassAlphabeticalOrder() == 2 then 

					if mb_targetFromSpecificPlayer("Death Talon Dragonspawn", mb_returnPlayerInRaidFromTable(MB_myRazorgoreLeftTank)) and not mb_hasBuffOrDebuff("Curse of Recklessness", MBID[mb_returnPlayerInRaidFromTable(MB_myRazorgoreLeftTank)].."target", "debuff") then

						AssistUnit(MBID[mb_returnPlayerInRaidFromTable(MB_myRazorgoreLeftTank)])

						CastSpellByName("Curse of Recklessness")
						TargetLastTarget()
						return true
					end
				end
				return
			end
		else

			if UnitName("target") == "Naxxramas Acolyte" then

				if mb_myClassAlphabeticalOrder() == 1 then
					
					if not mb_hasBuffOrDebuff("Curse of Tongues", "target", "debuff") then
						
						CastSpellByName("Curse of Tongues")
						return true
					end

				elseif mb_myClassAlphabeticalOrder() == 2 then
					
					if not mb_hasBuffOrDebuff("Curse of Recklessness", "target", "debuff") then
						
						CastSpellByName("Curse of Recklessness")
						return true
					end

				elseif mb_myClassAlphabeticalOrder() == 3 then 
					
					if not mb_hasBuffOrDebuff("Curse of the Elements", "target", "debuff") then
						
						CastSpellByName("Curse of the Elements")
						return true
					end
					
				elseif mb_myClassAlphabeticalOrder() == 4 then 
					
					if not mb_hasBuffOrDebuff("Curse of Shadow", "target", "debuff") then
						
						CastSpellByName("Curse of Shadow")
						return true
					end

				elseif mb_myClassAlphabeticalOrder() == 5 then 
					
					if not mb_hasBuffOrDebuff("Curse of the Elements", "target", "debuff") then
						
						CastSpellByName("Curse of the Elements")
						return true
					end

				elseif mb_myClassAlphabeticalOrder() == 6 then
					
					if not mb_hasBuffOrDebuff("Curse of Recklessness", "target", "debuff") then
						
						CastSpellByName("Curse of Recklessness")
						return true
					end
				end
			else

				if mb_myClassAlphabeticalOrder() == 1 then
					
					if not mb_hasBuffOrDebuff("Curse of Recklessness", "target", "debuff") then
						
						CastSpellByName("Curse of Recklessness")
						return true
					end

				elseif mb_myClassAlphabeticalOrder() == 2 then 
					
					if not mb_hasBuffOrDebuff("Curse of the Elements", "target", "debuff") then
						
						CastSpellByName("Curse of the Elements")
						return true
					end
					
				elseif mb_myClassAlphabeticalOrder() == 3 then 
					
					if not mb_hasBuffOrDebuff("Curse of Shadow", "target", "debuff") then
						
						CastSpellByName("Curse of Shadow")
						return true
					end

				elseif mb_myClassAlphabeticalOrder() == 4 then 
					
					if not mb_hasBuffOrDebuff("Curse of the Elements", "target", "debuff") then
						
						CastSpellByName("Curse of the Elements")
						return true
					end

				elseif mb_myClassAlphabeticalOrder() == 5 then
					
					if not mb_hasBuffOrDebuff("Curse of Recklessness", "target", "debuff") then
						
						CastSpellByName("Curse of Recklessness")
						return true
					end

				elseif mb_myClassAlphabeticalOrder() == 6 then
					
					if not mb_hasBuffOrDebuff("Curse of Shadow", "target", "debuff") then
						
						CastSpellByName("Curse of Shadow")
						return true
					end
				end
			end
		end
	end

	if not mb_hasBuffOrDebuff("Shadow Ward", "player", "buff") and mb_spellReady("Shadow Ward") then
		if mb_mobsToShadowWard() or mb_debuffsToShadowWard() then

			mb_selfBuff("Shadow Ward")
			return true
		end
	end

	if mb_hasBuffNamed("Shadow and Frost Reflect", "target") then

		if mb_spellReady("Soul Fire") and mb_numShards() > 10 then 
			
			mb_castSpellOrWand("Soul Fire") 
		end

		mb_castSpellOrWand("Immolate")
		return true
	
	elseif mb_hasBuffOrDebuff("Magic Reflection", "target", "buff") then 
		
		if mb_imBusy() then
				
			SpellStopCasting()
		end

		mb_autoWandAttack() 
		return true
	end

	if mb_tankTarget("Azuregos") and mb_hasBuffNamed("Magic Shield", "target") then

		if mb_imBusy() then
				
			SpellStopCasting()
		end

		mb_autoWandAttack() 
		return true
	end

	if GetRealZoneText() == "Naxxramas" then -- Naxx

		--

	elseif GetRealZoneText() == "Ahn\'Qiraj" then -- AQ40
		
		-- Twins tanking

		if UnitName("target") == "Emperor Vek\'lor" and mb_myNameInTable(MB_myTwinsWarlockTank) then

			mb_selfBuff("Shadow Ward")

			mb_saveShardShadowBurn(3)
			
			if mb_healthPct("player") < 0.25 and mb_spellReady("Death Coil") then
				
				CastSpellByName("Death Coil")
			end
			
			CastSpellByName("Searing Pain")
			return true
		end

		if UnitName("target") == "Battleguard Sartura" then

			mb_coolDownCast("Corruption", 18)
		end

		if UnitName("target") == "Obsidian Eradicator" and mb_manaPct("target") > 0.7 then

			if not mb_imBusy() then
				
				CastSpellByName("Drain Mana") 
			end
			return true
		end

		if UnitName("target") == "Spawn of Fankriss" then -- Fankriss
			
			mb_saveShardShadowBurn(9)

			mb_castSpellOrWand("Shadow Bolt")
			return true
		end

	elseif GetRealZoneText() == "Blackwing Lair" then -- BWL

		if (UnitName("target") == "Corrupted Healing Stream Totem" or UnitName("target") == "Corrupted Windfury Totem" or UnitName("target") == "Corrupted Stoneskin Totem" or UnitName("target") == "Corrupted Fire Nova Totem") and not mb_dead("target") then
			
			mb_saveShardShadowBurn(12)

			mb_castSpellOrWand("Searing Pain")
			return true
		end

	elseif GetRealZoneText() == "Molten Core" then -- MC

		if UnitName("target") == "Shazzrah" then
			
			if not mb_spellReady("Shadow Bolt") then

				mb_castSpellOrWand("Immolate")
				return true
			end
		end

	elseif GetRealZoneText() == "Onyxia\'s Lair" then

		if UnitName("target") == "Onyxia" then

			mb_coolDownCast("Corruption", 18)
		end

	elseif GetRealZoneText() == "Zul\'Gurub" then -- ZG

		--Jindo

		if mb_hasBuffOrDebuff("Delusions of Jin\'do", "player", "debuff") then

			if UnitName("target") == "Shade of Jin\'do" and not mb_dead("target") then

				mb_saveShardShadowBurn(12)

				mb_castSpellOrWand("Searing Pain") 
				return true
			end
		end

		if UnitName("target") == "Powerful Healing Ward" and not mb_dead("target") then

			mb_saveShardShadowBurn(12)

			mb_castSpellOrWand("Searing Pain") 
			return true
		end

		if UnitName("target") == "Brain Wash Totem" and not mb_dead("target") then
			
			mb_saveShardShadowBurn(12)

			mb_castSpellOrWand("Searing Pain") 
			return true
		end

	elseif GetRealZoneText() == "Ruins of Ahn\'Qiraj" then -- AQ20

		-- Moam

		if UnitName("target") == "Moam" and mb_manaPct("target") > 0.75 then
			
			if not mb_imBusy() then
				
				CastSpellByName("Drain Mana") 
			end
		end

		-- Ossirian

		if UnitName("target") == "Ossirian the Unscarred" then
			
			if mb_hasBuffOrDebuff("Shadow Weakness", "target", "debuff") then

				mb_castSpellOrWand("Shadow Bolt")
				return true

			elseif mb_hasBuffOrDebuff("Fire Weakness", "target", "debuff") then

				if mb_spellReady("Soul Fire") and mb_numShards() > 10 then 

					mb_castSpellOrWand("Soul Fire")
				end

				mb_castSpellOrWand("Immolate")
				return true
			end
		end
	end
	return false
end

function mb_warlockShadowBoltWhoring()
	local SBstacks = 0;
	local SWstacks = 0;
	local gonnaWhore = nil;

	if UnitExists("target") then
		SBstacks = mb_debuffShadowBoltAmount()
		SWstacks = mb_debuffShadowWeavingAmount()
		
		if (SWstacks == 5 and SBstacks >= 4) then
			gonnaWhore = true;
			mb_casterTrinkets();
		else
			gonnaWhore = nil;
		end
		
	if mb_imBusy() then return end

		if gonnaWhore and mb_spellReady("Shadowburn") and mb_numShards() > 12 then
			CastSpellByName("Shadowburn")
			mb_castSpellOrWand("Shadow Bolt")
		else
			mb_castSpellOrWand("Shadow Bolt")
		end
	end
end

function mb_saveShardShadowBurn(shardsToSave)
	local shardsAmount = shardsToSave or 0

	if mb_knowSpell("Shadowburn") and mb_spellReady("Shadowburn") and mb_numShards() > shardsToSave then 

		CastSpellByName("Shadowburn") 
	end 
end

------------------------------------------------------------------------------------------------------
-------------------------------------------- Precast Code! -------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_warlockPreCast() -- Warlock precast

	-- Pop Cooldowns
	for k, trinket in pairs(MB_casterTrinkets) do
		if mb_itemNameOfEquippedSlot(13) == trinket and not mb_trinketOnCD(13) then 
			use(13) 
		end

		if mb_itemNameOfEquippedSlot(14) == trinket and not mb_trinketOnCD(14) then 
			use(14) 
		end
	end

	CastSpellByName("Shadow Bolt")
end

------------------------------------------------------------------------------------------------------
------------------------------------------- Cooldowns Code! ------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_warlockCooldowns() -- Warlock cooldowns

	if mb_imBusy() then return end

	if mb_inCombat("player") then

		mb_casterTrinkets()
	end
end

function mb_warlockTapWhileMoving() -- Tap it when need and is moving

	if mb_healthPct("player") < 0.4 then return end

	if UnitManaMax("player") == UnitMana("player") then
		return 
	end
	
	if mb_manaPct("player") < 0.80 and mb_healthPct("player") > 0.55 then

		CastSpellByName("Life Tap")
		return		
	end
end

------------------------------------------------------------------------------------------------------
--------------------------------------------- Pet Code! ----------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_warlockSumPetAndSac() -- Summon and sac pet

	if not mb_hasBuffOrDebuff("Touch of Shadow", "player", "buff") and UnitCreatureFamily("pet") == "Succubus" and mb_knowSpell("Demonic Sacrifice") then
	
		CastSpellByName("Demonic Sacrifice")
	end

	if mb_numShards() == 0 then return end

	if not mb_hasBuffOrDebuff("Touch of Shadow", "player", "buff") and mb_knowSpell("Summon Succubus") and mb_knowSpell("Fel Domination") and mb_spellReady("Fel Domination") then 
		
		CastSpellByName("Fel Domination")
	end

	if not mb_hasBuffOrDebuff("Touch of Shadow", "player", "buff") and UnitCreatureFamily("pet") == "Succubus" and mb_knowSpell("Demonic Sacrifice") then

		CastSpellByName("Demonic Sacrifice")
	else 
		CastSpellByName("Summon Succubus")
	end
end

function mb_havePet()
	return UnitHealth("pet") > 0
end

------------------------------------------------------------------------------------------------------
-------------------------------------------- Stone Code! ---------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_createSoulStone() -- Make SS
	if mb_spellNumber("Create Soulstone.*Major") and mb_numShards() > 0 and not mb_haveInBags("Major Soulstone") then 
		CastSpell(mb_spellNumber("Create Soulstone.*Major"), BOOKTYPE_SPELL) 
	end
end

function mb_createHealthStone() -- Make HS
	if mb_numShards() >= 2 and mb_getAllContainerFreeSlots() >= 1 and not mb_inCombat("player") and not mb_haveInBags("Major Healthstone") then
		CastSpellByName("Create Healthstone (Major)()")
		return
	end
end

function mb_warlockHealthStone() -- Use HS
	if mb_healthPct("player") <= 0.15 and mb_inCombat("player") and mb_haveInBags("Major Healthstone") and not mb_isItemInBagCooldown("Major Healthstone") then
		SpellStopCasting();
		UseItemByName("Major Healthstone")
	end
end

function mb_soulStoneResser() -- SS a ressing 
	
	if mb_hasBuffNamed("Drink", "player") then return end
	if mb_imBusy() then return end

	mb_createSoulStone()
	if mb_isItemInBagCooldown("Major Soulstone") then return end

	if MB_soulstone_ressurecters then 
		
		if MB_buffingCounterWarlock == TableLength(MB_classList["Warlock"]) + 1 then
			
			MB_buffingCounterWarlock = 1 
		else
				
			MB_buffingCounterWarlock = MB_buffingCounterWarlock + 1
		end
		
		if not mb_someoneInRaidBuffedWith("Soulstone") then
			if MB_buffingCounterWarlock == mb_myClassAlphabeticalOrder() then 
				for i = 1, TableLength(MB_classList["Priest"]) do

					id = MBID[MB_classList["Priest"][i]]
					name = MB_classList["Priest"][i]

					if not mb_hasBuffOrDebuff("Soulstone", id, "buff") and mb_haveInBags("Major Soulstone") then
						mb_message("Soulstoning "..GetColors(name))
						TargetUnit(id)
						UseItemByName("Major Soulstone")
						ClearCursor()
						return
					end
				end

				for i = 1, TableLength(MB_classList["Shaman"]) do

					id = MBID[MB_classList["Shaman"][i]]
					name = MB_classList["Shaman"][i]

					if not mb_hasBuffOrDebuff("Soulstone", id, "buff") and mb_haveInBags("Major Soulstone") then
						mb_message("Soulstoning "..GetColors(name))
						TargetUnit(id)
						UseItemByName("Major Soulstone")
						ClearCursor()
						return
					end
				end
			end
		end
	end
end

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

function mb_warlockSetup() -- Warlock buff

	if UnitMana("player") < 3400 and mb_hasBuffNamed("Drink", "player") then return end

	if IsAltKeyDown() then -- Alt key to make SS

		if MB_ssCounterWarlock == TableLength(MB_classList["Warlock"]) + 1 then
			
			MB_ssCounterWarlock = 1
		else
			
			MB_ssCounterWarlock = MB_ssCounterWarlock + 1
		end

		if MB_ssCounterWarlock == mb_myClassAlphabeticalOrder() then
			mb_soulStoneResser()
		end
	end

	-- Do warlock stuff
	mb_selfBuff("Demon Armor")
	
	if mb_knowSpell("Demonic Sacrifice") then

		if not mb_hasBuffOrDebuff("Touch of Shadow", "player", "buff") then
			
			mb_warlockSumPetAndSac()
		end

	elseif not mb_knowSpell("Demonic Sacrifice") then

		if not mb_havePet() then
			
			CastSpellByName("Summon Imp")
		end
	end
	

	mb_createHealthStone()

	-- Drink
	if not mb_inCombat("player") and (mb_manaPct("player") < 0.30) and not mb_hasBuffNamed("Drink", "player") then 
		
		mb_smartDrink() 
	end
end

------------------------------------------------------------------------------------------------------
------------------------------------------ START DRUID CODE! -----------------------------------------
------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------
-------------------------------------------- Single Code! --------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_druidSingle() -- Druid single
	
	if not MB_mySpecc then --> Specc Defaults
		
		mb_message("My specc is fucked. Defaulting to Resto.")
		MB_mySpecc = "Resto"
	end

	mb_getTarget() -- Gettarget

	if MB_mySpecc == "Kitty" then -- Cat

		mb_druidCat()
		return

	elseif MB_mySpecc == "Feral" then -- Feral

		if GetRealZoneText() == "Ahn\'Qiraj" then
			
			if mb_hasBuffOrDebuff("True Fulfillment", "target", "debuff") then TargetByName("The Prophet Skeram") end -- If you are mindcontrolled then target the boss 

			mb_anubAlert() -- Alert Different things
		end

		mb_druidTank() -- Druid tank
		return	

	elseif (MB_mySpecc == "Resto" or MB_mySpecc == "Swiftmend") then
		
		if UnitFactionGroup("player") == "Alliance" then
			
			if (mb_tankTarget("Venom Stalker") or mb_tankTarget("Necro Stalker")) then
			
				if mb_imBusy() then -- When poisened party, stop casting
				
					SpellStopCasting()
				end
				
				mb_meleeBuff("Abolish Poison")
				return
			end
		end

		-- Keep casting sleeps
		if myClass == "Druid" and UnitName("target") == "Death Talon Wyrmkin" and GetRaidTargetIndex("target") == MB_myCCTarget then
			
			CastSpellByName("Hibernate(rank 1)")
			return 
		end
	
		if mb_crowdControl() then return end -- No need to do anything when CCing

		-- Jindo damage rotation
		mb_healerJindoRotation("Wrath")

		if mb_tankTarget("Gothik the Harvester") and not IsAltKeyDown() then return end
		
		mb_druidHeal() -- Healing
	end
end

function mb_druidHeal()
	
	if mb_natureSwiftnessLowAggroedPlayer() then return end -- Insta heal

	mb_decurse() -- Decurse

	if mb_inCombat("player") then

		mb_druidHealerDebuffs() -- FF on mobs, and different encounters

		mb_innervateAHealer() -- Innervate

		-- Potions
		mb_takeManaPotionAndRune()
		mb_takeManaPotionIfBelowManaPotMana()
		mb_takeManaPotionIfBelowManaPotManaInRazorgoreRoom()

		-- Cooldowns
		if mb_manaDown("player") > 600 then mb_druidCooldowns() end
	end

	if (mb_hasBuffOrDebuff("Curse of Tongues", "player", "debuff") and not mb_tankTarget("Anubisath Defender")) then return end -- Don't need to start heals w COT, wait for dispells

	if mb_tankTarget("Shazzrah") then return end -- No healing in Shazz only dispells

	if mb_healLieutenantAQ20() then return end -- Healing for the Rajaxx Fight (Untested 22/05)

	if mb_instructorRazAddsHeal() then return end -- Healers heal adds in Razuvious fight

	if MB_myAssignedHealTarget then -- Assigned Target healing

		if mb_isAlive(MBID[MB_myAssignedHealTarget]) then
			
			mb_druidMTHeals(MB_myAssignedHealTarget)
			return
		else

			MB_myAssignedHealTarget = nil
			RunLine("/raid My healtarget died, time to ALT-F4.")
		end
	end

	for k, BossName in pairs(MB_myDruidMainTankHealingBossList) do -- Specific encounter heals
		
		if mb_tankTarget(BossName) then
			
			mb_druidMTHeals()
			return
		end
	end

	if MB_isMoving.Active then mb_castSpellOnRandomRaidMember("Rejuvenation", MB_druidRejuvenationLowRandomMovingRank, MB_druidRejuvenationLowRandomMovingPercentage) end

	if GetRealZoneText() == "Ahn\'Qiraj" then -- AQ40 sepcific healing

		if mb_tankTarget("Princess Huhuran") and MB_myHuhuranBoxStrategy then -- Huhuran is nasty when she goes below 30%
			
			if mb_healthPct("target") <= 0.32 and myName == MB_myHuhuranFirstDruidHealer then -- Huhuran is nasty when she goes below 30%
			
				mb_druidMTHeals()
			else

				MBH_CastHeal("Healing Touch") -- H
			end
			return
		end

	elseif GetRealZoneText() == "Blackwing Lair" then -- BWL specific healing
	
		if mb_tankTarget("Vaelastrasz the Corrupt") and MB_myVaelastraszBoxStrategy then -- Vael, use max ranks
		
			mb_druidCooldowns() -- CD's

			if MB_myVaelastraszDruidHealing and not mb_hasBuffOrDebuff("Burning Adrenaline", "player", "debuff") then -- Heal MT

				if myName == MB_myVaelastraszDruidOne then
					
					mb_druidMaxRejuvAggroedPlayer()
					mb_druidMaxRegrowthAggroedPlayer()						

				elseif myName == MB_myVaelastraszDruidTwo and mb_dead(MBID[MB_myVaelastraszDruidOne]) then

					mb_druidMaxRejuvAggroedPlayer()
					mb_druidMaxRegrowthAggroedPlayer()				

				elseif myName == MB_myVaelastraszDruidThree and mb_dead(MBID[MB_myVaelastraszDruidOne]) and mb_dead(MBID[MB_myVaelastraszDruidTwo]) then

					mb_druidMaxRejuvAggroedPlayer()
					mb_druidMaxRegrowthAggroedPlayer()
				end
			end

			if mb_knowSpell("Swiftmend") and mb_spellReady("Swiftmend") then -- Faster Swiftments
	
				if (swiftmendRaidThrottleTimer == nil or GetTime() - swiftmendRaidThrottleTimer > 1.5) then 
					swiftmendRaidThrottleTimer = GetTime();
	
					mb_swiftmendOnRandomRaidMember("Swiftmend", 0.5)
				end
			end
	
			mb_selfBuff("Rejuvenation") -- Selfbuff MAX rank
			
			MBH_CastHeal("Regrowth", 9, 9) -- Toggle Regrowth
			return
		end
	end

	if not mb_imBusy() then
		
		if MB_myHealSpell == "Rejuvenation" then -- 2T3 Bonus

			if mb_manaDown("player") > 300 then
				
				mb_selfBuff("Rejuvenation(rank 1)")
			end
		end

		mb_druidRejuvAggroedPlayer()

		if mb_knowSpell("Swiftmend") then
		
			if mb_spellReady("Swiftmend") then mb_swiftmendOnRandomRaidMember("Swiftmend", MB_druidSwiftmendAtPercentage) end
				
			if (rejuvenationRaidThrottleTimer == nil or GetTime() - rejuvenationRaidThrottleTimer > 1.5) then 
				rejuvenationRaidThrottleTimer = GetTime()
	
				mb_castSpellOnRandomRaidMember("Rejuvenation", MB_druidSwiftmendRejuvenationLowRandomRank, MB_druidSwiftmendRejuvenationLowRandomPercentage)
			end

		else

			if (rejuvenationRaidThrottleTimer == nil or GetTime() - rejuvenationRaidThrottleTimer > 1.5) then 
				rejuvenationRaidThrottleTimer = GetTime()
	
				mb_castSpellOnRandomRaidMember("Rejuvenation", MB_druidRejuvenationLowRandomRank, MB_druidRejuvenationLowRandomPercentage)
			end
		end

		mb_druidRegrowthAggroedPlayer()
		
		if (regrowthRaidThrottleTimer == nil or GetTime() - regrowthRaidThrottleTimer > 1.5) then 
			regrowthRaidThrottleTimer = GetTime()

			mb_druidRegrowthLowRandom()
		end		
	end

	MBH_CastHeal("Healing Touch")
end

function mb_druidHealerDebuffs() -- Druid debuffs, special and I don't want to explain it

	if GetRealZoneText() == "Blackwing Lair" then
		
		if (UnitName("target") == "Death Talon Wyrmkin" or UnitName("target") == "Death Talon Flamescale") then return end

		if (GetSubZoneText() == "Dragonmaw Garrison" and mb_isAtRazorgorePhase()) and MB_myRazorgoreBoxStrategy then
			
			if mb_targetFromSpecificPlayer("Death Talon Dragonspawn", mb_returnPlayerInRaidFromTable(MB_myRazorgoreRightTank)) and UnitCanAttack("player", MBID[mb_returnPlayerInRaidFromTable(MB_myRazorgoreRightTank)].."target") then -- Right ADDS 
				if not (mb_hasBuffOrDebuff("Faerie Fire", MBID[mb_returnPlayerInRaidFromTable(MB_myRazorgoreRightTank)].."target", "debuff") or mb_hasBuffOrDebuff("Faerie Fire (Feral)", MBID[mb_returnPlayerInRaidFromTable(MB_myRazorgoreRightTank)].."target", "debuff")) then
				
					AssistUnit(MBID[mb_returnPlayerInRaidFromTable(MB_myRazorgoreRightTank)])
					CastSpellByName("Faerie Fire")
					TargetLastTarget()
				end
			end
		
			if mb_targetFromSpecificPlayer("Death Talon Dragonspawn", mb_returnPlayerInRaidFromTable(MB_myRazorgoreLeftTank)) and UnitCanAttack("player", MBID[mb_returnPlayerInRaidFromTable(MB_myRazorgoreLeftTank)].."target") then -- Left ADDS
				if not (mb_hasBuffOrDebuff("Faerie Fire", MBID[mb_returnPlayerInRaidFromTable(MB_myRazorgoreLeftTank)].."target", "debuff") or mb_hasBuffOrDebuff("Faerie Fire (Feral)", MBID[mb_returnPlayerInRaidFromTable(MB_myRazorgoreLeftTank)].."target", "debuff")) then
				
					AssistUnit(MBID[mb_returnPlayerInRaidFromTable(MB_myRazorgoreLeftTank)])
					CastSpellByName("Faerie Fire")
					TargetLastTarget()
				end
			end			
			return
		end
	end

	if MB_raidLeader then
		
		if UnitCanAttack("player", MBID[MB_raidLeader].."target") and (not mb_hasBuffOrDebuff("Faerie Fire", MBID[MB_raidLeader].."target", "debuff") or not mb_hasBuffOrDebuff("Faerie Fire (Feral)", MBID[MB_raidLeader].."target", "debuff")) then
				
			AssistUnit(MBID[MB_raidLeader])
			CastSpellByName("Faerie Fire")
			TargetLastTarget()
		end

	else
		if MB_raidInviter then

			if UnitCanAttack("player", MBID[MB_raidInviter].."target") and (not mb_hasBuffOrDebuff("Faerie Fire", MBID[MB_raidInviter].."target", "debuff") or not mb_hasBuffOrDebuff("Faerie Fire (Feral)", MBID[MB_raidLeader].."target", "debuff")) then
					
				AssistUnit(MBID[MB_raidInviter])
				CastSpellByName("Faerie Fire")
				TargetLastTarget()
			end
		end
	end	
end

function mb_druidCat() -- Siple cat dps fuctions
	
	if not mb_isCatForm() then

		mb_selfBuff("Cat Form") 
		mb_cancelDruidShapeShift()
	end

	if not mb_inCombat("target") then return end

	if mb_isCatForm() then

		if (not mb_hasBuffOrDebuff("Faerie Fire (Feral)", "target", "debuff") or mb_hasBuffOrDebuff("Faerie Fire", "target", "debuff")) then 
			CastSpellByName("Faerie Fire (Feral)()") 
		end
		
		mb_autoAttack()
		
		if GetComboPoints("target") == 5 and UnitMana("player") >= 35 then
			CastSpellByName("Ferocious Bite")
		end
		
		CastSpellByName("Shred")
	end
end

function mb_druidTank() -- Druid tanks

	-- Unbuff Salv
	if mb_findInTable(MB_raidTanks, myName) and mb_hasBuffOrDebuff("Greater Blessing of Salvation", "player", "buff") then -- Remove salv
		
		CancelBuff("Greater Blessing of Salvation") 
	end	

	-- Set bear
	if not mb_isBearForm() then

		mb_selfBuff("Dire Bear Form") 
		mb_cancelDruidShapeShift()
	end

	-- Stop if target not incombat
	if not mb_inCombat("target") then return end

	if mb_inCombat("player") then

		-- Survive
		if mb_healthPct("player") < 0.3 and mb_spellReady("Frenzied Regeneration") then 
			
			CastSpellByName("Frenzied Regeneration") 
		end

		if mb_inMeleeRange() then

			-- Trinkets
			if (mb_debuffSunderAmount() == 5 or mb_hasBuffOrDebuff("Expose Armor", "target", "debuff")) then

				mb_druidCooldowns()
			end

			if mb_knowSpell("Bash") and mb_spellReady("Bash") and mb_stunnableMob() then -- Stun
				
				CastSpellByName("Bash")
			end

			-- Demo
			if not mb_hasBuffOrDebuff("Demoralizing Shout", "target", "debuff") then 
					
				if UnitName("target") ~= "Emperor Vek\'nilash" or UnitName("target") ~= "Emperor Vek\'lor" then
					
					if not mb_hasBuffOrDebuff("Demoralizing Roar", "target", "debuff") and UnitMana("player") >= 20 then 
						
						CastSpellByName("Demoralizing Roar")
					end
				end
			end
		end
	end

	mb_offTank()

	if UnitName("target") and mb_crowdControlledMob() and not myName == MB_raidLeader then return end

	local ttname =  UnitName("targettarget")
	local tname =  UnitName("target")
	if not tname then tname = "" end

	if MB_myOTTarget then
		if tname and ttname and ttname ~= "Unknown" and UnitIsEnemy("player", "target") and ttname ~= myName and not mb_findInTable(MB_raidTanks, ttname) then
			
			mb_druidTaunt()
		end
	else
		if tname and ttname and ttname ~= "Unknown" and UnitIsEnemy("player", "target") and not mb_findInTable(MB_raidTanks, ttname) then
			
			mb_druidTaunt()
		end
	end

	if MB_myOTTarget then
		if UnitExists("target") and GetRaidTargetIndex("target") and GetRaidTargetIndex("target") == MB_myOTTarget and UnitIsDead("target") then
			MB_myOTTarget = nil
			ClearTarget()
		end
	end

	if mb_isBearForm() then

		mb_autoAttack()

		if (not mb_hasBuffOrDebuff("Faerie Fire (Feral)", "target", "debuff") or mb_hasBuffOrDebuff("Faerie Fire", "target", "debuff")) then 
			
			CastSpellByName("Faerie Fire (Feral)()") 
		end

		if mb_spellReady("Enrage") and UnitMana("player") <= 15 then --> BR
			
			CastSpellByName("Enrage")
		end
		
		if UnitMana("player") > 7 then 
			CastSpellByName("Maul") 
		end
		
		if UnitMana("player") > 36 then 
			CastSpellByName("Swipe")
		end		
	end
end

------------------------------------------------------------------------------------------------------
-------------------------------------------- Loatheb Code! -------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_druidLoatheb()

	if mb_loathebHealing() then return end

	if mb_inCombat("player") then

		mb_druidHealerDebuffs() -- FF on mobs, and different encounters

		mb_innervateAHealer() -- Innervate

		-- Potions
		mb_takeManaPotionAndRune()
		mb_takeManaPotionIfBelowManaPotMana()

		-- Cooldowns
		if mb_manaDown("player") > 600 then mb_druidCooldowns() end
	end
end

------------------------------------------------------------------------------------------------------
--------------------------------------------- Multi Code! --------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_druidMulti()
	
	if not MB_mySpecc then --> Specc Defaults
		
		mb_message("My specc is fucked. Defaulting to Resto.")
		MB_mySpecc = "Resto"
	end

	mb_getTarget() -- Gettarget

	if MB_mySpecc == "Kitty" then -- Cat

		mb_druidCat()
		return

	elseif MB_mySpecc == "Feral" then -- Feral

		if GetRealZoneText() == "Ahn\'Qiraj" then
			
			if mb_hasBuffOrDebuff("True Fulfillment", "target", "debuff") then TargetByName("The Prophet Skeram") end -- If you are mindcontrolled then target the boss 

			mb_anubAlert() -- Alert Different things
		end

		mb_druidTankMulti() -- Druid multi tank
		return	
		
	elseif (MB_mySpecc == "Resto" or MB_mySpecc == "Swiftmend") then

		-- Keep casting sleeps
		if myClass == "Druid" and UnitName("target") == "Death Talon Wyrmkin" and GetRaidTargetIndex("target") == MB_myCCTarget then
			
			CastSpellByName("Hibernate(rank 1)")
			return true
		end
		
		if mb_crowdControl() then return end -- No need to do anything when CCing

		-- Jindo damage rotation
		mb_healerJindoRotation("Wrath")

		mb_druidHeal() -- Healing
	end
end

function mb_druidTankMulti() -- Druid tank multi

	-- Unbuff Salv
	if mb_findInTable(MB_raidTanks, myName) and mb_hasBuffOrDebuff("Greater Blessing of Salvation", "player", "buff") then -- Remove salv
		
		CancelBuff("Greater Blessing of Salvation") 
	end	

	-- Set bear
	if not mb_isBearForm() then

		mb_selfBuff("Dire Bear Form") 
		mb_cancelDruidShapeShift()
	end

	-- Stop if target not incombat
	if not mb_inCombat("target") then return end

	if mb_inCombat("player") then

		-- Survive
		if mb_healthPct("player") < 0.3 and mb_spellReady("Frenzied Regeneration") then 
			
			CastSpellByName("Frenzied Regeneration") 
		end

		if mb_inMeleeRange() then

			-- Trinkets
			if (mb_debuffSunderAmount() == 5 or mb_hasBuffOrDebuff("Expose Armor", "target", "debuff")) then
			
				mb_druidCooldowns()
			end

			if mb_knowSpell("Bash") and mb_spellReady("Bash") and mb_stunnableMob() then -- Stun
				
				CastSpellByName("Bash")
			end

			-- Demo
			if not mb_hasBuffOrDebuff("Demoralizing Shout", "target", "debuff") then 
					
				if UnitName("target") ~= "Emperor Vek\'nilash" or UnitName("target") ~= "Emperor Vek\'lor" then
					
					if not mb_hasBuffOrDebuff("Demoralizing Roar", "target", "debuff") and UnitMana("player") >= 20 then 
						
						CastSpellByName("Demoralizing Roar")
					end
				end
			end
		end
	end

	mb_offTank()

	if UnitName("target") and mb_crowdControlledMob() and not myName == MB_raidLeader then return end

	local ttname =  UnitName("targettarget")
	local tname =  UnitName("target")
	if not tname then tname = "" end

	if MB_myOTTarget then
		if tname and ttname and ttname ~= "Unknown" and UnitIsEnemy("player", "target") and ttname ~= myName and not mb_findInTable(MB_raidTanks, ttname) then
			
			mb_druidTaunt()
		end
	else
		if tname and ttname and ttname ~= "Unknown" and UnitIsEnemy("player", "target") and not mb_findInTable(MB_raidTanks, ttname) then
			
			mb_druidTaunt()
		end
	end

	if MB_myOTTarget then
		if UnitExists("target") and GetRaidTargetIndex("target") and GetRaidTargetIndex("target") == MB_myOTTarget and UnitIsDead("target") then
			MB_myOTTarget = nil
			ClearTarget()
		end
	end

	if mb_isBearForm() then

		mb_autoAttack()

		if (not mb_hasBuffOrDebuff("Faerie Fire (Feral)", "target", "debuff") or mb_hasBuffOrDebuff("Faerie Fire", "target", "debuff")) then 
			
			CastSpellByName("Faerie Fire (Feral)()") 
		end

		if mb_spellReady("Enrage") and UnitMana("player") <= 15 then --> BR
			
			CastSpellByName("Enrage")
		end
		
		if UnitMana("player") > 12 then 
			CastSpellByName("Swipe")
		end
		
		if UnitMana("player") > 19 then 
			CastSpellByName("Maul") 
		end
	end
end

------------------------------------------------------------------------------------------------------
---------------------------------------------- AOE Code! ---------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_druidAOE()

	-- Give dots to the Maexxna MT
	if mb_tankTarget("Maexxna") and MB_myMaexxnaBoxStrategy and mb_imHealer() then
		
		if MB_myAssignedHealTarget then

			if mb_isAlive(MBID[MB_myAssignedHealTarget]) then
				
				mb_druidMTHeals(MB_myAssignedHealTarget)
				return
			else
	
				MB_myAssignedHealTarget = nil
				RunLine("/raid My healtarget died, time to ALT-F4.")
			end
		end

		if mb_myNameInTable(MB_myMaexxnaDruidHealer) then

			mb_druidMaxRejuvAggroedPlayer()
			mb_druidMaxAbolishAggroedPlayer()
			mb_druidMaxRegrowthAggroedPlayer()
			return
		end
	end
	

	mb_druidSingle()
end

------------------------------------------------------------------------------------------------------
-------------------------------------------- Precast Code! -------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_druidPreCast() -- Druid precast
	
	-- Pop Cooldowns
	for k, trinket in pairs(MB_casterTrinkets) do
		if mb_itemNameOfEquippedSlot(13) == trinket and not mb_trinketOnCD(13) then 
			use(13) 
		end

		if mb_itemNameOfEquippedSlot(14) == trinket and not mb_trinketOnCD(14) then 
			use(14) 
		end
	end

	CastSpellByName("Starfire")
end

------------------------------------------------------------------------------------------------------
------------------------------------------- Cooldowns Code! ------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_druidCooldowns() -- Druid cooldowns

	if mb_imBusy() then return end

	if mb_inCombat("player") then

		if MB_mySpecc == "Feral" then
			
			mb_meleeTrinkets()

		elseif (MB_mySpecc == "Resto" or MB_mySpecc == "Swiftmend") then

			mb_healerTrinkets()
			mb_casterTrinkets()
		end
	end
end

function mb_druidTaunt() -- Druid taunt
	
	if mb_spellReady("Growl") then
		
		CastSpellByName("Growl")
		return
	end

	if UnitName("target") and mb_inCombat("target") then
		if mb_spellReady("Faerie Fire (Feral)()") then
			
			CastSpellByName("Faerie Fire (Feral)()")
		end
	end
end

------------------------------------------------------------------------------------------------------
-------------------------------------------- Healing Code! -------------------------------------------
------------------------------------------------------------------------------------------------------

local HealTouch = { Time = 0, Interrupt = false }

-- /run mb_druidMTHeals("Angerissues")
function mb_druidMTHeals(assignedtarget)

	if assignedtarget then
		
		TargetByName(assignedtarget, 1)
	else

		if mb_tankTarget("Patchwerk") and MB_myPatchwerkBoxStrategy then
			
			mb_targetMyAssignedTankToHeal()
		else

			if not UnitName(MBID[mb_tankName()].."targettarget") then 
				
				MBH_CastHeal("Healing Touch")
			else
				TargetByName(UnitName(MBID[mb_tankName()].."targettarget"), 1) 
			end
		end
	end

	-- NS if needed
	if mb_knowSpell("Nature\'s Swiftness") and mb_spellReady("Nature\'s Swiftness") and mb_healthPct("target") <= 0.15 then

		if not mb_hasBuffOrDebuff("Nature\'s Swiftness", "player", "buff") then			
			
			SpellStopCasting()
		end

		mb_selfBuff("Nature\'s Swiftness") 
	end

	if mb_hasBuffOrDebuff("Nature\'s Swiftness", "player", "buff") then 
			
		CastSpellByName("Healing Wave")
		return
	end

	local HealTouchSpell = "Healing Touch("..MB_myDruidMainTankHealingRank.."\)"

	if mb_tankTarget("Vaelastrasz the Corrupt") then -- Max Ranks for Vael :)

		HealTouchSpell = "Healing Touch"
	end

	--[[	
		-- Info
		local HealTouchCastTime = 3
		local HealTouchTime = GetTime()
		local HealTouchCooldown = mb_spellCooldown("Healing Touch")

		-- Setup
		HealTouchStop = HealTouchStop or false
		HealTouchFinishTime = HealTouchFinishTime or 0
		HealTouchCastAt = HealTouchCastAt or 0
		
		if HealTouchCooldown > 0 then

			if mb_hasBuffOrDebuff("Nature\'s Grace", "player", "buff") then 
				
				HealTouchFinishTime = (HealTouchCooldown + 2.5)  -- Finish Timer = SpellCooldown + CastTime
			else

				HealTouchFinishTime = (HealTouchCooldown + HealTouchCastTime)  -- Finish Timer = SpellmtCooldown + CastTime
			end

			HealTouchStop = true
		end

		if mb_itemNameOfEquippedSlot(18) == "Idol of Health" then

			HealTouchFinishTime = (HealTouchFinishTime - 0.15)
		end

		if not mb_tankTarget("Vaelastrasz the Corrupt") then

			-- Stop when target is not below HP and is not far into the cast
			if mb_healthDown("target") < 1850 and (HealTouchTime > (HealTouchFinishTime - 0.2)) and HealTouchStop then
				
				SpellStopCasting()
				HealTouchCastAt = HealTouchFinishTime + 0.1
				HealTouchStop = false
			end
		end

		if HealTouchCooldown <= 0 and HealTouchTime > HealTouchCastAt then

			CastSpellByName(HealTouchSpell)
		end
	]]

	if not (mb_tankTarget("Vaelastrasz the Corrupt") or mb_tankTarget("Maexxna") or mb_tankTarget("Ossirian the Unscarred")) then

		-- Stop when target is not below HP and is not far into the cast
		if (mb_healthDown("target") <= (GetHealValueFromRank("Healing Touch", MB_myDruidMainTankHealingRank) * MB_myMainTankOverhealingPercentage)) and (GetTime() > HealTouch.Time) and (GetTime() < HealTouch.Time + 0.5) and HealTouch.Interrupt then
			
			SpellStopCasting()
			HealTouch.Interrupt = false
			SpellStopCasting()
		end
	end

	if not MB_isCasting then

		CastSpellByName(HealTouchSpell)
		HealTouch.Time = GetTime() + 1
		HealTouch.Interrupt = true
	end
end

function mb_improvedRegrowthCheck() -- Imp regro check
	local _, _, _, _, TalentsIn = GetTalentInfo(3, 14)
	if TalentsIn > 2 then
		return true
	end
	return false
end

function mb_druidRegrowthLowRandom() -- Regro random guys

	if mb_imBusy() then return end
	if mb_tankTarget("Garr") or mb_tankTarget("Firesworn") then return end

	if mb_improvedRegrowthCheck() and UnitMana("player") >= 880 then
		if GetRaidRosterInfo(1) then

			for i = 1, GetNumRaidMembers() do

				if mb_healthPct("raid"..i) < MB_druidSwiftmendRegrowthLowRandomPercentage and mb_isValidFriendlyTarget("raid"..i, "Regrowth") then
					
					if UnitIsFriend("player", "raid"..i) then
						ClearTarget()
					end	
					
					CastSpellByName("Regrowth")
					SpellTargetUnit("raid"..i)
					SpellStopTargeting()
					return
				end
			end

		elseif GetNumPartyMembers() > 0 then

			for i = 1, GetNumPartyMembers() do
				if mb_healthPct("party"..i) < MB_druidSwiftmendRegrowthLowRandomPercentage then

					if UnitIsFriend("player", "party"..i) then
						ClearTarget()
					end	
					
					CastSpellByName("Regrowth")
					SpellTargetUnit("party"..i)
					SpellStopTargeting()
					return
				end
			end 
		end
	end
end

function mb_druidRegrowthAggroedPlayer() -- Regro agroed player

	if mb_imBusy() then return end
	if mb_tankTarget("Garr") or mb_tankTarget("Firesworn") then return end

	if mb_improvedRegrowthCheck() and UnitMana("player") >= 880 and mb_myClassOrder() == 1 then

		local regroTarget
		if MBID[MB_raidLeader] then
			regroTarget = MBID[MB_raidLeader].."targettarget"
		end

		if regroTarget then

			if mb_isValidFriendlyTarget(regroTarget, "Regrowth") and mb_healthPct(regroTarget) <= MB_druidSwiftmendRegrowthAggroedPlayerPercentage and not mb_hasBuffNamed("Regrowth", regroTarget) then 
				
				if UnitIsFriend("player", regroTarget) then
					ClearTarget()
				end	
				
				CastSpellByName("Regrowth("..MB_druidSwiftmendRegrowthAggroedPlayerRank.."\)")
				SpellTargetUnit(regroTarget)
				SpellStopTargeting()
			end
		end
	end
end

function mb_druidRejuvAggroedPlayer() -- Reju agroed player
	
	if mb_imBusy() then return end
	if mb_tankTarget("Garr") or mb_tankTarget("Firesworn") then return end

	local aggrox = AceLibrary("Banzai-1.0")
	local rejuvTarget

	for i =  1, GetNumRaidMembers() do
		
		rejuvTarget = "raid"..i

		if rejuvTarget and aggrox:GetUnitAggroByUnitId(rejuvTarget) then

			if mb_isValidFriendlyTarget(rejuvTarget, "Rejuvenation") and mb_healthPct(rejuvTarget) <= MB_druidRejuvenationAggroedPlayerPercentage and not mb_hasBuffNamed("Rejuvenation", rejuvTarget) then 
				
				if UnitIsFriend("player", rejuvTarget) then
					ClearTarget()
				end	
				
				CastSpellByName("Rejuvenation("..MB_druidRejuvenationAggroedPlayerRank.."\)")
				SpellTargetUnit(rejuvTarget)
				SpellStopTargeting()
			end
		end
	end
end

function mb_innervateAHealer() -- Innervate a healer

	if mb_imBusy() then return end
	if mb_tankTarget("Garr") or mb_tankTarget("Firesworn") then return end

	if mb_spellReady("Innervate") then
	
		for k, innerTarget in MB_myInnervateHealerList do

			if mb_isValidFriendlyTarget(MBID[innerTarget], "Innervate") and mb_healthPct(MBID[innerTarget]) <= 0.5 and not mb_hasBuffNamed("Innervate", MBID[innerTarget]) then 
				
				if UnitIsFriend("player", MBID[innerTarget]) then
					ClearTarget()
				end	
				
				
				CastSpellByName("Innervate")
				SpellTargetUnit(MBID[innerTarget])
				SpellStopTargeting()
			end
		end
	end
end

function mb_swiftmendOnRandomRaidMember(spell, percentage) -- Swiftment 

	if mb_imBusy() then return end
	if mb_tankTarget("Garr") or mb_tankTarget("Firesworn") then return end
	
	if UnitInRaid("player") then
		local n, r, i, j
		n = mb_GetNumPartyOrRaidMembers()
		r = math.random(n)-1

		for i = 1, n do
			j = i + r
			if j > n then j = j - n end

			if mb_healthPct("raid"..j) < percentage and mb_inCombat("raid"..j) and mb_isValidFriendlyTarget("raid"..j, spell) and (mb_hasBuffNamed("Rejuvenation", "raid"..j) or mb_hasBuffNamed("Regrowth", "raid"..j)) then

				if UnitIsFriend("player", "raid"..j) then
					ClearTarget()
				end

				CastSpellByName(spell, false)

				SpellTargetUnit("raid"..j)
				SpellStopTargeting()
				break
			end
		end
	end
end

------------------------------------------------------------------------------------------------------
-------------------------------------------- Setup Code! ---------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_druidSetup() -- Druid buff

	if mb_isDruidShapeShifted() and not mb_inCombat("player") then
		
		mb_cancelDruidShapeShift()
	end
	
	if (UnitMana("player") < 1200) and mb_hasBuffNamed("Drink", "player") then return end

	-- Buffs
	if not MB_autoBuff.Active then

		MB_autoBuff.Active = true
		MB_autoBuff.Time = GetTime() + 0.2

		if MB_buffingCounterDruid == TableLength(MB_classList["Druid"]) + 1 then
		
			MB_buffingCounterDruid = 1
		else

			MB_buffingCounterDruid = MB_buffingCounterDruid + 1
		end
	end

	mb_selfBuff("Omen of Clarity") -- Omen

	if MB_buffingCounterDruid == mb_myClassAlphabeticalOrder() then
				
		mb_multiBuff("Gift of the Wild")
	end

	if MB_raidAssist.Druid.BuffTanksWithThorns then
		
		mb_tankBuff("Thorns")
	end

	-- Drink
	if not mb_inCombat("player") and (mb_manaPct("player") < 0.20) and not mb_hasBuffNamed("Drink", "player") then
		
		mb_smartDrink()
	end
end

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
	return mb_warriorIsStance(4)
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

------------------------------------------------------------------------------------------------------
----------------------------------------- START HUNTER CODE! -----------------------------------------
------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------
-------------------------------------------- Single Code! --------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_hunterSingle() -- Hunter single

	mb_getTarget() -- Gettarget

	if IsControlKeyDown() then -- Cheetah
		
		CastSpellByName("Aspect of the Cheetah")
		return
	end

	mb_selfBuff("Trueshot Aura") -- Buff Aura
	
	if mb_tankTarget("Princess Huhuran") then -- Aspects

		mb_selfBuff("Aspect of the Wild")  
	else

		mb_selfBuff("Aspect of the Hawk")  
	end

	if mb_tankTarget("Gluth") then
		mb_freezingTrap()
	end

	if not mb_inCombat("target") then return end

	if mb_inCombat("player") then

		-- Cooldowns
		if mb_manaDown("player") > 600 then mb_hunterCooldowns() end
	end
		
	if mb_tankTarget("Moam") then
		
		mb_coolDownCast("Viper Sting", 8)
	end

	if (mb_tankTarget("Gluth") or mb_tankTarget("Princess Huhuran") or mb_tankTarget("Flamegor") or mb_tankTarget("Chromaggus") or mb_tankTarget("Magmadar")) and mb_spellReady("Tranquilizing Shot") then
		
		CastSpellByName("Tranquilizing Shot")
	end

	if not mb_hasBuffNamed("Hunter\'s Mark", "target", "debuff") then
			
		CastSpellByName("Hunter\'s Mark")
	end	

	mb_hunterPetAttack()

	if mb_inMeleeRange() then

		if not mb_isFireImmune() then
			mb_explosiveTrap()
		end

		CastSpellByName("Raptor Strike")
		CastSpellByName("Mongoose Bite")

		mb_autoAttack()
		return 
	end

	local aggrox = AceLibrary("Banzai-1.0")
	if aggrox:GetUnitAggroByUnitId("player") and mb_spellReady("Feign Death") and not MB_hunterFeign.Active and not mb_imBusy() then
		
		MB_hunterFeign.Active = true
		MB_hunterFeign.Time = GetTime() + 0.2

		CastSpellByName("Feign Death")
	end

	if mb_healthPct("target") > 0.1 then
		if mb_knowSpell("Aimed Shot") and mb_spellReady("Aimed Shot") then 
			
			CastSpellByName("Aimed Shot") 
		end	
	end

	if mb_healthPct("target") < 0.95 then
		if mb_knowSpell("Multi-Shot") and mb_spellReady("Multi-Shot") then 
			
			CastSpellByName("Multi-Shot") 
		end
	end

	mb_autoRangedAttack()
end

------------------------------------------------------------------------------------------------------
--------------------------------------------- Multi Code! --------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_hunterMulti()
	mb_hunterSingle()
end

------------------------------------------------------------------------------------------------------
---------------------------------------------- AOE Code! ---------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_hunterAOE()
	mb_hunterSingle()
end

------------------------------------------------------------------------------------------------------
--------------------------------------------- Burst Code! --------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_explosiveTrap()

	if not mb_spellReady("Explosive Trap") then 
		return 
	end

	PetPassiveMode()
	PetFollow()

	if mb_inCombat("player") and not MB_hunterFeign.Active then

		MB_hunterFeign.Active = true
		MB_hunterFeign.Time = GetTime() + 0.2

		CastSpellByName("Feign Death") 
	else

		CastSpellByName("Explosive Trap")
	end
end

function mb_freezingTrap()

	if not mb_spellReady("Frost Trap") then 
		return 
	end

	PetPassiveMode()
	PetFollow()

	if mb_inCombat("player") and not MB_hunterFeign.Active then

		MB_hunterFeign.Active = true
		MB_hunterFeign.Time = GetTime() + 0.2

		CastSpellByName("Feign Death") 
	else

		CastSpellByName("Frost Trap")
	end
end

------------------------------------------------------------------------------------------------------
-------------------------------------------- Precast Code! -------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_hunterPreCast() -- Hunter precast

	for k, trinket in pairs(MB_meleeTrinkets) do
		if mb_itemNameOfEquippedSlot(13) == trinket and not mb_trinketOnCD(13) then 
			use(13) 
		end

		if mb_itemNameOfEquippedSlot(14) == trinket and not mb_trinketOnCD(14) then 
			use(14) 
		end
	end

	CastSpellByName("Aimed Shot")
end


------------------------------------------------------------------------------------------------------
------------------------------------------- Cooldowns Code! ------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_hunterCooldowns() -- Hunter cooldowns

	if mb_imBusy() then return end

	if mb_inCombat("player") then 

		mb_meleeTrinkets()

		if not mb_inMeleeRange() then
		
			mb_selfBuff("Rapid Fire") 
		end

		mb_selfBuff("Berserking")
	end
end

------------------------------------------------------------------------------------------------------
-------------------------------------------- Setup Code! ---------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_hunterSetup() -- Hunter buff

	mb_selfBuff("Trueshot Aura") -- Aura
	
	mb_selfBuff("Aspect of the Hawk") -- Hawk

	if UnitClassification("target") == "worldboss" then

		mb_getPet() -- Revive pet if needed for the boss
	else
		
		if GetPetHappiness() ~= nil and GetPetHappiness() ~= 3 then
			if not mb_hasBuffNamed("Feed Pet Effect", "pet") then
				
				CastSpellByName("Feed Pet")
				mb_pickupPetFood()
			end

			ResetCursor()
		else
			CastSpellByName("Dismiss Pet") -- Put pet away
		end
	end
end

function mb_hunterPetAttack()

	--if UnitClassification("target") ~= "worldboss" then return end

	if mb_dead("pet") then return end

	PetAttack("target")
end

function mb_hunterPetPassive()

	if mb_dead("pet") then return end

	PetPassiveMode()
	PetFollow()
end

function mb_pickupPetFood() -- Pet food
	-- Used to pick up pet food when feeding pet
	-- Have to pick food type based on hunter name and pet
	local amount = 0

	for bag = 0,4 do 
		for slot = 1, GetContainerNumSlots(bag) do 
		
		local texture, itemCount, locked, quality, readable, lootable, link = GetContainerItemInfo(bag,slot)

			if texture then
				link = GetContainerItemLink(bag,slot) 
				if UnitCreatureFamily("pet") == "Bear" then

					if string.find(link, "Roasted Quail") then PickupContainerItem(bag,slot) return end
				elseif UnitCreatureFamily("pet") == "Cat" then

					if string.find(link, "Roasted Quail") then PickupContainerItem(bag,slot) return end
				elseif UnitCreatureFamily("pet") == "Wolf" then

					if string.find(link, "Roasted Quail") then PickupContainerItem(bag,slot) return end
				elseif UnitCreatureFamily("pet") == "Bat" then

					if string.find(link, "Dried King Bolete") then PickupContainerItem(bag, slot) return end
					if string.find(link, "Deep Fried Plantains") then PickupContainerItem(bag, slot) return end
				elseif UnitCreatureFamily("pet") == "Crocolisk" then

					if string.find(link, "Roasted Quail") then PickupContainerItem(bag,slot) return end
				elseif UnitCreatureFamily("pet") == "Raptor" then

					if string.find(link, "Roasted Quail") then PickupContainerItem(bag,slot) return end
				elseif UnitCreatureFamily("pet") == "Spider" then

					if string.find(link, "Roasted Quail") then PickupContainerItem(bag,slot) return end
				elseif UnitCreatureFamily("pet") == "Carrion Bird" then

					if string.find(link, "Roasted Quail") then PickupContainerItem(bag,slot) return end
				elseif UnitCreatureFamily("pet") == "Gorilla" then

					if string.find(link, "Deep Fried Plantains") then PickupContainerItem(bag,slot) return end
				elseif UnitCreatureFamily("pet") == "Boar" then

					if string.find(link, "Roasted Quail") then PickupContainerItem(bag,slot) return end
				elseif UnitCreatureFamily("pet") == "Turtle" then

					if string.find(link, "Deep Fried Plantains") then PickupContainerItem(bag,slot) return end
				elseif UnitCreatureFamily("pet") == "Scorpid" then

					if string.find(link, "Roasted Quail") then PickupContainerItem(bag,slot) return end
				elseif UnitCreatureFamily("pet") == "Owl" then

					if string.find(link, "Roasted Quail") then PickupContainerItem(bag,slot) return end
				end
			end
		end
	end
end

function mb_feedPet() -- Feed it
	--Hunters:Feed your pet if he's not SUUUUUPER happy.
	if GetPetHappiness() ~= nil and GetPetHappiness() ~= 3 then
		if not mb_hasBuffNamed("Feed Pet Effect", "pet") then
			
			CastSpellByName("Feed Pet")
			mb_pickupPetFood()
		end
	end

	ResetCursor()
end

function mb_getPet() -- Summon and ress it
	
	if UnitExists("pet") and mb_isAlive("pet") then
		
		mb_feedPet()
	else
		
		CastSpellByName("Call Pet")
		CastSpellByName("Revive Pet")
	end
end

function mb_removeFeignDeath()

	CancelBuff("Feign Death")
	DoEmote("Stand")
	MB_hunterFeign.Active = false
end

------------------------------------------------------------------------------------------------------
----------------------------------------- START PALADIN CODE! ----------------------------------------
------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------
-------------------------------------------- Single Code! --------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_paladinSingle()
	
	mb_getTarget() -- Gettarget

	if mb_playerIsPoisoned() and mb_spellReady("Stoneform") then -- Stoneforms
		
		mb_selfBuff("Stoneform")
	end

	if mb_raidIsPoisoned() then

		if (mb_tankTarget("Venom Stalker") or mb_tankTarget("Necro Stalker")) and mb_imBusy() then -- When poisened party, stop casting
		
			SpellStopCasting()
		end
	end

	mb_decurse() -- Decurse

	if mb_stunnableMob() then

		if not MB_autoBuff.Active then

			MB_autoBuff.Active = true
			MB_autoBuff.Time = GetTime() + 0.17

			if MB_buffingCounterPaladin == TableLength(MB_classList["Paladin"]) + 1 then
						
				MB_buffingCounterPaladin = 1
			else
		
				MB_buffingCounterPaladin = MB_buffingCounterPaladin + 1
			end
		end

		if MB_buffingCounterPaladin == mb_myClassAlphabeticalOrder() then

			mb_assistFocus()

			if mb_knowSpell("Hammer of Justice") and mb_spellReady("Hammer of Justice") then
				
				CastSpellByName("Hammer of Justice")
			end		
		end
	end

	-- Healing
	mb_paladinHeal()

	-- Seal
	mb_paladinSealLight()
end

function mb_paladinHeal()

	if mb_paladinBOPLowRandom() then return end -- BOP, Save some niggas

	if mb_inCombat("player") then
	
		mb_paladinSetup() -- Buffs when incombat

		if mb_healthPct("player") < 0.2 then -- BOP
			
			mb_selfBuff("Divine Shield")
			return 
		end

		-- Potions
		mb_takeManaPotionAndRune()
		mb_takeManaPotionIfBelowManaPotMana()
		mb_takeManaPotionIfBelowManaPotManaInRazorgoreRoom()

		-- Cooldowns
		if mb_manaDown("player") > 600 then mb_paladinCooldowns() end
	end

	if (mb_hasBuffOrDebuff("Curse of Tongues", "player", "debuff") and not mb_tankTarget("Anubisath Defender")) then return end -- Don't need to start heals w COT, wait for dispells

	if mb_healLieutenantAQ20() then return end -- Healing for the Rajaxx Fight (Untested 22/05)

	if mb_instructorRazAddsHeal() then return end -- Healers heal adds in Razuvious fight

	if MB_myAssignedHealTarget then -- Assigned Target healing

		if mb_isAlive(MBID[MB_myAssignedHealTarget]) then
			
			mb_paladinMTHeals(MB_myAssignedHealTarget)
			return
		else

			MB_myAssignedHealTarget = nil
			RunLine("/raid My healtarget died, time to ALT-F4.")
		end
	end

	for k, BossName in pairs(MB_myPaladinMainTankHealingBossList) do -- Specific encounter heals
		
		if mb_tankTarget(BossName) then
			
			mb_paladinMTHeals()
			return
		end
	end

	if GetRealZoneText() == "Blackwing Lair" then -- BWL specific healing

		if mb_tankTarget("Vaelastrasz the Corrupt") and MB_myVaelastraszBoxStrategy then -- Vael, use max ranks

			mb_paladinCooldowns() -- CD's
		
			if MB_myVaelastraszPaladinHealing then -- Heal MT

				if myName == MB_myVaelastraszPaladinOne then
					
					mb_message("MT Healing!", 300)
					mb_paladinMTHeals()
					return			

				elseif myName == MB_myVaelastraszPaladinTwo and mb_dead(MBID[MB_myVaelastraszPaladinOne]) then

					mb_message("MT Healing!", 300)
					mb_paladinMTHeals()
					return

				elseif myName == MB_myVaelastraszPaladinThree and mb_dead(MBID[MB_myVaelastraszPaladinOne]) and mb_dead(MBID[MB_myVaelastraszPaladinTwo]) then

					mb_message("MT Healing!", 300)
					mb_paladinMTHeals()
					return	
				end
			end

			MBH_CastHeal("Flash of Light", 5, 6) -- Lesser Heals

			mb_paladinSealLight() -- Seal
			return
		end
	end

	-- Healing selector
	if (mb_hasBuffOrDebuff("Blinding Light", "player", "buff") or mb_hasBuffOrDebuff("Divine Favor", "player", "buff")) then
		
		MBH_CastHeal("Holy Light")
		return
	else

		MBH_CastHeal("Flash of Light", 5, 6)
	end
end

------------------------------------------------------------------------------------------------------
-------------------------------------------- Loatheb Code! -------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_paladinLoatheb()

	if mb_loathebHealing() then return end
	
	AssistByName(MB_myLoathebMainTank)

	if mb_playerIsPoisoned() and mb_spellReady("Stoneform") then -- Stoneforms
		
		mb_selfBuff("Stoneform")
	end

	if mb_inCombat("player") then
	
		mb_paladinSetup() -- Buffs when incombat

		-- Potions
		mb_takeManaPotionAndRune()
		mb_takeManaPotionIfBelowManaPotMana()

		-- Cooldowns
		if mb_manaDown("player") > 600 then mb_paladinCooldowns() end
	end

	mb_autoAttack()

	if myName == MB_myLoathebSealPaladin and not mb_hasBuffOrDebuff("Seal of Light", "target", "debuff") then

		mb_paladinSealLight()
		return
	end

	if not mb_hasBuffOrDebuff("Seal of Righteousness", "player", "buff") then

		CastSpellByName("Seal of Righteousness")
	end
end

------------------------------------------------------------------------------------------------------
--------------------------------------------- Multi Code! --------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_paladinMulti() -- Multi Pala
	mb_paladinSingle()
end

------------------------------------------------------------------------------------------------------
---------------------------------------------- AOE Code! ---------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_paladinAOE() -- AOE Pala
	mb_paladinSingle()
end

------------------------------------------------------------------------------------------------------
-------------------------------------------- Blessing Code! ------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_paladinChooseAura() -- Aura
	
	if mb_tankTarget("Sapphiron") or mb_tankTarget("Azuregos") then
		
		mb_selfBuff("Frost Resistance Aura")
		return
	end

	if mb_myGroupClassOrder() == 1 then
		
		if mb_isFireBoss() then
			
			mb_selfBuff("Fire Resistance Aura")
			return
		end

		if (MB_druidTankInParty or MB_warriorTankInParty) then

			mb_selfBuff("Devotion Aura")

		elseif mb_numberOfClassInParty("Warrior") > 0 or mb_numberOfClassInParty("Rogue") > 0 then

			mb_selfBuff("Devotion Aura")

		elseif mb_numberOfClassInParty("Mage") > 0 or mb_numberOfClassInParty("Warlock") > 0 then
			
			mb_selfBuff("Concentration Aura")
		else

			mb_selfBuff("Concentration Aura")
		end
		
	elseif mb_myGroupClassOrder() == 2 then
		
		mb_selfBuff("Concentration Aura")

	elseif mb_myGroupClassOrder() == 3 then
		
		mb_selfBuff("Retribution Aura")		
	end
end

function mb_paladinBlessMyAssignedBlessing() -- Buffs
	
	if mb_tankTarget("Garr") or mb_tankTarget("Firesworn") or mb_tankTarget("Maexxna") then return end
	
	if mb_haveInBags("Symbol of Kings") then
		
		if mb_myClassAlphabeticalOrder() == 1 then

			mb_multiBuffBlessing("Greater Blessing of Kings")
			return

		elseif mb_myClassAlphabeticalOrder() == 2 then

			mb_multiBuffBlessing("Greater Blessing of Might")
			return

		elseif mb_myClassAlphabeticalOrder() == 3 then

			mb_multiBuffBlessing("Greater Blessing of Salvation")
			return
		
		elseif mb_myClassAlphabeticalOrder() == 4 then

			mb_multiBuffBlessing("Greater Blessing of Light")
			return
		
		elseif mb_myClassAlphabeticalOrder() == 5 then

			mb_multiBuffBlessing("Greater Blessing of Sanctuary")
			return
		
		elseif mb_myClassAlphabeticalOrder() == 6 then

			mb_multiBuffBlessing("Greater Blessing of Wisdom")
			return
		end
	else
		mb_message("Out of Symbol of Kings")
	end
end

function mb_holyShockLowAggroedPlayer() -- Insta Pala Heal

	if not MB_raidAssist.Paladin.HolyShockLowHealthAggroedPlayers then
		return false
	end

	if not UnitInRaid("player") then 
		return false
	end

	if not mb_inCombat("player") then
		return false
	end

	if mb_spellReady("Holy Shock") then
		
		local blastHSatThisPercentage = 0.2
		
		if mb_myClassOrder() == 1 then
			blastHSatThisPercentage = 0.50
		elseif mb_myClassOrder() == 2 then
			blastHSatThisPercentage = 0.45
		elseif mb_myClassOrder() == 3 then
			blastHSatThisPercentage = 0.40
		elseif mb_myClassOrder() == 4 then
			blastHSatThisPercentage = 0.35
		elseif mb_myClassOrder() >= 5 then
			blastHSatThisPercentage = 0.30
		end

		local aggrox = AceLibrary("Banzai-1.0")
		local holyShockTarget
	
		for i =  1, GetNumRaidMembers() do
	
			holyShockTarget = "raid"..i
	
			if holyShockTarget and aggrox:GetUnitAggroByUnitId(holyShockTarget) then
	
				if mb_isValidFriendlyTarget(holyShockTarget, "Holy Shock") and mb_healthPct(holyShockTarget) <= blastHSatThisPercentage and not mb_hasBuffNamed("Holy Shock", holyShockTarget) then 
					
					if UnitIsFriend("player", holyShockTarget) then
						ClearTarget()
					end	
					
					CastSpellByName("Holy Shock")
					SpellTargetUnit(holyShockTarget)
					SpellStopTargeting()
					return true
				end
			end
		end
	end
	return false
end

function mb_paladinSealLight()

	if mb_isValidMeleeTarget("target") then

		mb_assistFocus()

		if mb_hasBuffOrDebuff("Judgement of Light", "target", "debuff") then
			return
		end

		mb_autoAttack()

		if not mb_hasBuffOrDebuff("Seal of Light", "player", "buff") then 
			
			CastSpellByName("Seal of Light") 
			
		else

			CastSpellByName("Judgement")
		end	
	end
end

function mb_paladinSealWisdom()
	if mb_isValidMeleeTarget("target") then

		mb_assistFocus()

		if mb_hasBuffOrDebuff("Judgement of Light", "target", "debuff") then
			return
		end
		
		mb_autoAttack()

		if not mb_hasBuffOrDebuff("Seal of Wisdom", "player", "buff") then 
			
			CastSpellByName("Seal of Wisdom") 
			
		else

			CastSpellByName("Judgement")
		end	
	end
end

function mb_paladinCooldowns() -- Cooldowns

	if mb_imBusy() then return end

	if mb_inCombat("player") then
	
		if not mb_tankTarget("Viscidus") then

			if mb_manaPct("player") <= MB_paladinDivineFavorPercentage then
			
				mb_selfBuff("Divine Favor")
			end
		end

		mb_casterTrinkets()
		mb_healerTrinkets()
	end
end

------------------------------------------------------------------------------------------------------
-------------------------------------------- Healing Code! -------------------------------------------
------------------------------------------------------------------------------------------------------

local FlashOfLight = { Time = 0, Interrupt = false }

function mb_paladinMTHeals(assignedtarget)
	
	if assignedtarget then
		
		TargetByName(assignedtarget, 1)
	else
		if mb_tankTarget("Patchwerk") and MB_myPatchwerkBoxStrategy then
			
			mb_targetMyAssignedTankToHeal()
		else

			if not UnitName(MBID[mb_tankName()].."targettarget") then 
				
				MBH_CastHeal("Flash of Light", 5, 6)
			else
				TargetByName(UnitName(MBID[mb_tankName()].."targettarget"), 1) 
			end
		end
	end

	if mb_inCombat("player") and mb_manaPct("player") < 0.95 then
		
		mb_selfBuff("Divine Favor")
	end

	local FlashOfLightSpell = "Flash of Light("..MB_myPaladinMainTankHealingRank.."\)"

	if mb_tankTarget("Vaelastrasz the Corrupt") then -- Max Ranks for Vael :)

		FlashOfLightSpell = "Holy Light"

	elseif mb_tankTarget("Ossirian the Unscarred") then
		
		FlashOfLightSpell = "Holy Light(rank 5)"
	end

	--[[
		FoL_shouldStop = FoL_shouldStop or false
		FoL_castFinishTime = FoL_castFinishTime or 0
		FoL_nextCastAt = FoL_nextCastAt or 0

		local currentTime = GetTime()
		local FoL_cooldown = GetActionCooldown(6)

		if FoL_cooldown > 0 then
			FoL_castFinishTime = FoL_cooldown + 1.5
			FoL_shouldStop = true
		end

		if UnitHealth("target") > UnitHealthMax("target")-(0.8*950) and currentTime > FoL_castFinishTime-0.1 and FoL_shouldStop then
			SpellStopCasting()
			FoL_nextCastAt = FoL_castFinishTime + 0.1
			FoL_shouldStop = false
		end

		if FoL_cooldown <= 0 and currentTime > FoL_nextCastAt then
			
			CastSpellByName("Flash of Light("..MB_myPaladinMainTankHealingRank.."\)")
		end
	]]

	if not (mb_tankTarget("Vaelastrasz the Corrupt") or mb_tankTarget("Maexxna") or mb_tankTarget("Ossirian the Unscarred")) then

		-- Stop when target is not below HP and is not far into the cast
		if (mb_healthDown("target") <= (GetHealValueFromRank("Flash of Light", MB_myPaladinMainTankHealingRank) * MB_myMainTankOverhealingPercentage)) and (GetTime() > FlashOfLight.Time) and (GetTime() < FlashOfLight.Time + 0.5) and FlashOfLight.Interrupt then
			
			SpellStopCasting()			
			FlashOfLight.Interrupt = false
			SpellStopCasting()
		end
	end

	if not MB_isCasting then

		CastSpellByName(FlashOfLightSpell)
		FlashOfLight.Time = GetTime() + 0.25
		FlashOfLight.Interrupt = true
	end
end

function mb_paladinBOPLowRandom()

	if mb_tankTarget("Gluth") or mb_tankTarget("Zombie Chow") then
		return false
	end
	
	if not UnitInRaid("player") then 
		return false
	end

	if not mb_inCombat("player") then
		return false
	end

	if mb_imBusy() then
		return false
	end

	if mb_spellReady("Blessing of Protection") then

		local blastNSatThisPercentage = 0.3

		if mb_myClassOrder() == 1 then
			blastNSatThisPercentage = 0.45
		elseif mb_myClassOrder() == 2 then
			blastNSatThisPercentage = 0.40
		elseif mb_myClassOrder() == 3 then
			blastNSatThisPercentage = 0.35
		elseif mb_myClassOrder() == 4 then
			blastNSatThisPercentage = 0.30
		elseif mb_myClassOrder() >= 5 then
			blastNSatThisPercentage = 0.25
		end

		local aggrox = AceLibrary("Banzai-1.0")
		local BOPTarget

		for i =  1, GetNumRaidMembers() do

			BOPTarget = "raid"..i

			if BOPTarget and aggrox:GetUnitAggroByUnitId(BOPTarget) and not mb_findInTable(MB_raidTanks, UnitName(BOPTarget)) then

				if mb_isValidFriendlyTarget(BOPTarget, "Blessing of Protection") and mb_healthPct(BOPTarget) <= blastNSatThisPercentage and not mb_hasBuffOrDebuff("Forbearance", BOPTarget, "debuff") then 
					
					if UnitIsFriend("player", BOPTarget) then
						ClearTarget()
					end
					
					CastSpellByName("Blessing of Protection", false)

					mb_message("I BOP\'d "..GetColors(UnitName(BOPTarget)).." at "..string.sub(mb_healthPct(BOPTarget), 3, 4).."% - "..UnitHealth(BOPTarget).."/"..UnitHealthMax(BOPTarget).." HP.")
					SpellTargetUnit(BOPTarget)
					SpellStopTargeting()
					return true
				end
			end
		end
	end
	return false
end

------------------------------------------------------------------------------------------------------
-------------------------------------------- Setup Code! ---------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_paladinSetup()

	-- Buffs
	if MB_buffingCounterPaladin == TableLength(MB_classList["Paladin"]) + 1 then
				
		MB_buffingCounterPaladin = 1
	else

		MB_buffingCounterPaladin = MB_buffingCounterPaladin + 1
	end	

	if MB_buffingCounterPaladin == mb_myClassAlphabeticalOrder() then

		mb_paladinBlessMyAssignedBlessing() -- Blessings
	end

	mb_paladinChooseAura() -- Aura

	-- Drink
	if not mb_inCombat("player") and (mb_manaPct("player") < 0.20) and not mb_hasBuffNamed("Drink", "player") then
		
		mb_smartDrink()
	end
end

------------------------------------------------------------------------------------------------------
-------------------------------------------- MoronAutoTurn! ------------------------------------------
------------------------------------------------------------------------------------------------------

MAT = CreateFrame("Button","XFTF",UIParent)

do
	for _, event in {
		"UI_ERROR_MESSAGE", 
		"AUTOFOLLOW_END",
		} 
		do MAT:RegisterEvent(event)
	end
end

function MAT:OnEvent()
   
	if MB_raidAssist.AutoTurnToTarget then

		if event == "UI_ERROR_MESSAGE" then

			if arg1 == "Target needs to be in front of you" then -- After 10 sec the "2/3" key will be SM_MACRO2/3 again (or earlier if AUTOFOLLOW_END is thrown)
				
				if not mb_iamFocus() and mb_imRangedDPS() and mb_unitInRange(MBID[MB_raidLeader]) then

					FollowByName(MB_raidLeader, 1)

					MB_savedBinding.Time = GetTime() + 3.5
					SetBinding("2", "MOVEBACKWARD")
					SetBinding("3", "MOVEBACKWARD")
					MB_savedBinding.Active = true
				end
			
			elseif arg1 == "Can\'t do that while moving" then -- The key seemed to have been down while rebinding

				if not MB_savedBinding.Active and (GetTime() > MB_savedBinding.Time) and (GetTime() < MB_savedBinding.Time + 1) and mb_unitInRange(MBID[MB_raidLeader]) then

					FollowByName(MB_raidLeader, 1)

					MB_savedBinding.Time = GetTime() + 1.75
					SetBinding("2", "MOVEBACKWARD")
					SetBinding("3", "MOVEBACKWARD")
					MB_savedBinding.Active = true
				end
			end

		elseif event == "AUTOFOLLOW_END" then -- If you reset the key without delay, the character will keep moving backwards

			MB_savedBinding.Time = GetTime() + 0.3
			MB_savedBinding.Active = true
		end
	end
end

function MAT:OnUpdate()
    if MB_savedBinding.Active then		

        if GetTime() > MB_savedBinding.Time then
            
            SetBinding("2", MB_savedBinding.Binding2)
			SetBinding("2", MB_savedBinding.Binding2)

            SetBinding("3", MB_savedBinding.Binding3)
            SetBinding("3", MB_savedBinding.Binding3)	

			MB_savedBinding.Active = false
		end
    end
end

MAT:SetScript("OnEvent", MAT.OnEvent)
MAT:SetScript("OnUpdate", MAT.OnUpdate)

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