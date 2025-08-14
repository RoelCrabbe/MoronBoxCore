--[####################################################################################################]--
--[############################################ OnEvent Core ##########################################]--
--[####################################################################################################]--

local MMB_Post_Init = CreateFrame("Button", "MMB", UIParent)
MMB_Post_Init.Timer = GetTime()

local myClass = UnitClass("player")
local myName = UnitName("player")
local myRace = UnitRace("player")

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

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
	if (event == "ADDON_LOADED" and arg1 == "MoronBoxCore") then

		mb_mySpecc()
		mb_initializeClasslists()
		
		MMB_Post_Init:SetScript("OnUpdate", MMB_Post_Init.OnUpdate)
		TakeTaxiNode = mb_takeTaxiNode

	elseif (event == "PLAYER_LOGIN") then

		mb_mySpecc()
		mb_initializeClasslists()

	elseif (event == "ACTIONBAR_SLOT_CHANGED") then

		mb_setAttackButton()
	
	elseif (event == "CHAT_MSG_WHISPER" and arg1 == MB_inviteMessage) then

        InviteByName(arg2)

    elseif (event == "GOSSIP_SHOW") then
        local targetName = UnitName("target")
        local currentTime = GetTime()
        
        if targetName == "Sayge" then
            MB_DMFWeek.Active = true
            MB_DMFWeek.Time = currentTime + 0.2
        elseif targetName == "Lothos Riftwaker" then
            MB_MCEnter.Active = true
            MB_MCEnter.Time = currentTime + 0.2
        elseif mb_reagentVendors() then
            MB_autoBuyReagents.Active = true    
            MB_autoBuyReagents.Time = currentTime + 0.2
        end

    elseif (event == "GOSSIP_CLOSED") then

        MB_DMFWeek.Active = false
        MB_MCEnter.Active = false
        MB_autoBuyReagents.Active = false

	elseif (event == "TAXIMAP_OPENED") then
		
		mb_taxi()

	elseif (event == "CHAT_MSG_ADDON") then
		if arg1 == MB_RAID.."MB_FIND" then
			mb_findItem(arg2)

		elseif arg1 == MB_RAID.."MB_TANKLIST" then
			local inputEncounter = string.upper(arg2)
			mb_tankList(inputEncounter)
		
		elseif arg1 == MB_RAID and arg2 == "MB_REPORTMANAPOTS" then
			mb_reportManapots()

		elseif arg1 == MB_RAID and arg2 == "MB_REPORTSHARDS" then		
			mb_reportShards()

		elseif arg1 == MB_RAID and arg2 == "MB_REPORTRUNES" then		
			mb_reportRunes()
			
		elseif arg1 == MB_RAID and arg2 == "MB_NEFCLOAK" then
			if mb_itemNameOfEquippedSlot(15) == "Onyxia Scale Cloak" then
                return
            end

			if not mb_haveInBags("Onyxia Scale Cloak") then				
				RunLine("/raid I don\'t have a Onyxia Scale Cloak")
				return
			end

			UseItemByName("Onyxia Scale Cloak")

		elseif arg1 == MB_RAID.."MB_HOTS" then
			local hotsValue = string.upper(arg2)
			mb_changeHots(hotsValue)
		
		elseif arg1 == MB_RAID.."MB_GEAR" then
			local gearSet = string.upper(arg2)
			mb_equipSet(gearSet)
		
		elseif arg1 == MB_RAID.."MB_ASSIGNHEALER" then			
			mb_assignHealerToName(arg2)
		
		elseif arg1 == MB_RAID.."MB_USEBAGITEM" then
			if mb_haveInBags(arg2) then
				UseItemByName(arg2)
			else
				Print("Don\'t have "..arg2.." in the bags!")
			end
			
		elseif arg1 == MB_RAID.."MB_REMOVEBLESS" then

            if arg2 == "all" then
                local greaterBlessings = {
                    "Greater Blessing of Salvation",
                    "Greater Blessing of Might", 
                    "Greater Blessing of Kings",
                    "Greater Blessing of Light",
                    "Greater Blessing of Wisdom",
                    "Greater Blessing of Sanctuary"
                }
                
                for _, blessing in ipairs(greaterBlessings) do
                    if mb_hasBuffOrDebuff(blessing, "player", "buff") then
                        CancelBuff(blessing)
                    end
                end
            elseif arg2 and mb_hasBuffOrDebuff(arg2, "player", "buff") then
                CancelBuff(arg2)
            end

		elseif arg1 == MB_RAID.."MB_REMOVEBUFFS" then

            if arg2 == "all" then
                local buffsToCancel = {
                    "Gift of the Wild",
                    "Prayer of Spirit",
                    "Prayer of Fortitude", 
                    "Arcane Brilliance",
                    "Divine Spirit",
                    "Power Word: Fortitude",
                    "Mark of the Wild",
                    "Arcane Intellect",
                    "Prayer of Shadow Protection",
                    "Greater Blessing of Salvation",
                    "Greater Blessing of Might",
                    "Greater Blessing of Kings", 
                    "Greater Blessing of Light",
                    "Greater Blessing of Wisdom",
                    "Greater Blessing of Sanctuary"
                }
                
                if myClass == "Mage" then
                    table.insert(buffsToCancel, "Mage Armor")
                elseif myClass == "Warlock" then
                    table.insert(buffsToCancel, "Demon Armor")
                end
                
                for _, buff in ipairs(buffsToCancel) do
                    if mb_hasBuffOrDebuff(buff, "player", "buff") then
                        CancelBuff(buff)
                    end
                end
            elseif arg2 and mb_hasBuffOrDebuff(arg2, "player", "buff") then
                CancelBuff(arg2)
            end

		elseif arg1 == MB_RAID and arg2 == "MB_FOCUSME" and arg4 ~= myName then			
			MB_raidLeader = arg4
			Print("I\'m Focusing "..MB_raidLeader)
		
		elseif arg1 == MB_RAID and arg2 == "MB_USECOOLDOWNS" then
			if mb_inCombat("player") and not MB_useCooldowns.Active then	
                MB_useCooldowns.Active = true
                MB_useCooldowns.Time = GetTime() + 5
			end

		elseif arg1 == MB_RAID and arg2 == "MB_USERECKLESSNESS" then
			if mb_inCombat("player") and not MB_useBigCooldowns.Active then		
				MB_useBigCooldowns.Active = true
				MB_useBigCooldowns.Time = GetTime() + 5				
			end

		elseif arg1 == MB_RAID and arg2 == "MB_REPORTCOOLDOWNS" then			
			mb_reportMyCooldowns()
			
		elseif arg1 == MB_RAID.."MB_REPORTREP" then
			mb_reputationReport(arg2)
		
		elseif arg1 == MB_RAID and arg2 == "MB_AQBOOKS" then
			mb_missingSpellsReport()

		elseif arg1 == MB_RAID.."_FTAR" then
			local focus = string.gsub(arg2, " .*", "")
			local focus_caller = string.gsub(arg2, "^%S- ", "")

			Print("I\'m Focusing "..focus.." Previous tar: "..focus_caller)
			MB_raidLeader = focus

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

	elseif (event == "RAID_ROSTER_UPDATE" or event == "PARTY_MEMBERS_CHANGED" or event == "PLAYER_ENTERING_WORLD") then

		mb_initializeClasslists()

	elseif (event == "PARTY_INVITE_REQUEST") then

		AcceptGroup()
		StaticPopup_Hide("PARTY_INVITE")
		UIErrorsFrame:AddMessage("Group Auto Accept")
		
	elseif (event == "UNIT_INVENTORY_CHANGED" and mb_imHealer()) then
		
		mb_getHealSpell()

	elseif (event == "SPELLCAST_START") then

		MB_isCasting = true

		if arg1 == MB_myCCSpell[UnitClass("player")] then
			MB_isCastingMyCCSpell = true
		end
						
	elseif (event == "SPELLCAST_INTERRUPTED" or event == "SPELLCAST_STOP" or event == "SPELLCAST_FAILED") then

		MB_isCasting = nil
		MB_isCastingMyCCSpell = nil

	elseif (event == "SPELLCAST_CHANNEL_START") then

		MB_isChanneling = true

	elseif (event == "SPELLCAST_CHANNEL_STOP") then

		MB_isChanneling = nil
	
	elseif (event == "START_LOOT_ROLL") then

		if not mb_iamFocus() then 
			RollOnLoot(arg1, 0) 
		end
	
	elseif (event == "CONFIRM_SUMMON") then

		if not mb_iamFocus() then			
			ConfirmSummon()
			StaticPopup_Hide("CONFIRM_SUMMON")
		end

	elseif (event == "TRADE_SHOW") then
		
		MB_tradeOpen = true
		MB_tradeOpenOnUpdate.Active = true	
		MB_tradeOpenOnUpdate.Time = GetTime() + 1

	elseif (event == "TRADE_CLOSED") then

		MB_tradeOpen = nil
		MB_tradeOpenOnUpdate.Active = false	

	elseif (event == "UI_ERROR_MESSAGE") then

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

		elseif arg1 == "Can\'t do that while moving" then

			if (mb_imHealer() or mb_imRangedDPS()) and not MB_isMoving.Active then				
				MB_isMoving.Active = true
				MB_isMoving.Time = GetTime() + 1
			end

		elseif arg1 == "Target needs to be in front of you" and Instance.BWL then

			if mb_isAtRazorgore() and mb_isAtRazorgorePhase() and MB_myRazorgoreBoxStrategy then
				MB_razorgoreNewTargetBecauseTargetIsBehindOrOutOfRange.Active = true
				MB_razorgoreNewTargetBecauseTargetIsBehindOrOutOfRange.Time = GetTime() + 2

				MB_razorgoreNewTargetBecauseTargetIsBehind.Active = true
				MB_razorgoreNewTargetBecauseTargetIsBehind.Time = GetTime() + 3
			end

		elseif arg1 == "Out of range." then
			
            if Instance.BWL and mb_isAtRazorgore() and mb_isAtRazorgorePhase() and MB_myRazorgoreBoxStrategy then
				if (myClass == "Warrior" or myClass == "Rogue") then
                    return
                end

				MB_razorgoreNewTargetBecauseTargetIsBehindOrOutOfRange.Active = true
				MB_razorgoreNewTargetBecauseTargetIsBehindOrOutOfRange.Time = GetTime() + 2

            elseif Instance.AQ20 and mb_imHealer() and UnitName("target") == "Lieutenant General Andorov" then
				MB_lieutenantAndorovIsNotHealable.Active = true
				MB_lieutenantAndorovIsNotHealable.Time = GetTime() + 6
			end
		
		elseif arg1 == "Target not in line of sight" then

            if Instance.BWL and mb_isAtRazorgore() and mb_isAtRazorgorePhase() and MB_myRazorgoreBoxStrategy then

				MB_razorgoreNewTargetBecauseTargetIsBehindOrOutOfRange.Active = true
				MB_razorgoreNewTargetBecauseTargetIsBehindOrOutOfRange.Time = GetTime() + 2
			
            elseif Instance.AQ20 and mb_imHealer() and UnitName("target") == "Lieutenant General Andorov" then
				MB_lieutenantAndorovIsNotHealable.Active = true
				MB_lieutenantAndorovIsNotHealable.Time = GetTime() + 6
			end

		elseif arg1 == "You are facing the wrong way!" or arg1 == "You are too far away!" then

			if mb_tankTarget("Plague Beast") or mb_tankTarget("Onyxia") then				
				MB_targetWrongWayOrTooFar.Active = true
				MB_targetWrongWayOrTooFar.Time = GetTime() + 1
			end
		end
	
	elseif (event == "PLAYER_REGEN_ENABLED") then

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

        if MB_warriorBinds == "Fury" and mb_imMeleeDPS() then
            if mb_myNameInTable(MB_furysThatCanTank) then				
                mb_furyGear()
            end
        end	

		if myClass == "Mage" then			
			mb_mageGear()
		end

		local x = GetCVar("targetNearestDistance")
		if x == "10" then
			SetCVar("targetNearestDistance", "41")
		end
		

	
	elseif (event == "RESURRECT_REQUEST") then

		if mb_tankTarget("Bloodlord Mandokir") then
            return
        end
		
		AcceptResurrect()
		StaticPopup_Hide("RESURRECT_NO_TIMER")
		StaticPopup_Hide("RESURRECT_NO_SICKNESS")
		StaticPopup_Hide("RESURRECT")
		
	elseif (event == "MERCHANT_SHOW") then
        local targetName = UnitName("target")
        local currentTime = GetTime()

		Print("Opened Merchant")

		if CanMerchantRepair() then 
			if GetRepairAllCost() > GetMoney() then				
				mb_message("I need gold! Can\'t affort repairs!")
			else				
				RepairAllItems()
			end		
		end
        
        if targetName == "Sayge" then
            MB_DMFWeek.Active = true
            MB_DMFWeek.Time = currentTime + 0.2
        elseif targetName == "Lothos Riftwaker" then
            MB_MCEnter.Active = true
            MB_MCEnter.Time = currentTime + 0.2
        elseif mb_reagentVendors() then
            MB_autoBuyReagents.Active = true    
            MB_autoBuyReagents.Time = currentTime + 0.2
        end

	elseif (event == "MERCHANT_CLOSED") then

		MB_autoBuyReagents.Active = false	

	elseif (event == "CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF" or 
			event == "CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE" or 
			event == "CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE" or 
			event == "CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF") then

		local _, _, caster, spell = string.find(arg1, "(.*) begins to cast (.*).")
		
		if caster and UnitName("target") == caster then
			for k, badSpell in MB_spellsToInt do
				if spell == badSpell then
					if UnitName("target") and badSpell and mb_spellReady(MB_myInterruptSpell[myClass]) then
						if myClass == "Priest" and not mb_knowSpell("Silence") then
                            return
                        end

						MB_doInterrupt.Active = true
						MB_doInterrupt.Time = GetTime() + 3
					end
				end
			end
		end	
		
	elseif (event == "CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE" and myClass == "Mage") then

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

	elseif (event == "PLAYER_TARGET_CHANGED") then

		if myClass == "Warlock" then
			MB_cooldowns["Corruption"] = nil
		end

		if myClass == "Mage" then
			MB_ignite.Active = nil
			MB_ignite.Starter = nil
			MB_ignite.Amount = 0
			MB_ignite.Stacks = 0
		end

	elseif (event == "UNIT_AURA" and arg1 == "target" and myClass == "Mage") then

        if (mb_debuffIgniteAmount() == 0) then    

            MB_ignite.Active = nil
            MB_ignite.Starter = nil
            MB_ignite.Amount = 0
            MB_ignite.Stacks = 0

        elseif (mb_debuffIgniteAmount() > MB_ignite.Stacks) then        
            MB_ignite.Active = true;
            MB_ignite.Stacks = mb_debuffIgniteAmount();
        end
	
	elseif (event == "UNIT_HEALTH" and arg1 == "target" and UnitHealth("target") == 0) then
		
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

function MMB_Post_Init:OnUpdate()
	if GetTime() - MMB_Post_Init.Timer < 2.5 then
        return
    end

	mb_mySpecc()
	mb_initializeClasslists()
	mb_setAttackButton()
	mb_getHealSpell()

	DEFAULT_CHAT_FRAME:AddMessage("|cffC71585Welcome to MoronBox! Created by MoroN.",1,1,1)
	DEFAULT_CHAT_FRAME:AddMessage("|cffC71585MoronBox: |r|cff00ff00 Scripts loaded succesfully. Issues? Let me know!",1,1,1)

	if MB_raidAssist.AutoEquipSet.Active then
		mb_equipSet(MB_raidAssist.AutoEquipSet.Set)
	end

	MMB_Post_Init:SetScript("OnUpdate", nil)
	MMB_Post_Init.Timer = nil
	MMB_Post_Init.onUpdate = nil
end