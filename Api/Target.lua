--[####################################################################################################]--
--[####################################### AUTO TARGET HANDLER ########################################]--
--[####################################################################################################]--

function mb_getTarget()
		
	if (mb_isAtRazorgore() and myName == mb_returnPlayerInRaidFromTable(MB_myRazorgoreORBtank)) and not mb_tankTarget("Razorgore the Untamed") then
        mb_orbControlling()
        return
    end

	if MB_myOTTarget then
        return
    end

	if Instance.BWL and mb_isAtRazorgore() and MB_myRazorgoreBoxStrategy

		if myName == mb_returnPlayerInRaidFromTable(MB_myRazorgoreORBtank) then
            return
        end

        if not mb_isAtRazorgorePhase() then
            return
        end
            
        if (myName == mb_returnPlayerInRaidFromTable(MB_myRazorgoreLeftTank) 
            or myName == mb_returnPlayerInRaidFromTable(MB_myRazorgoreRightTank)) and MB_raidLeader ~= myName then
            MB_raidLeader = myName
        end

        if not mb_iamFocus() then
            return
        end

        if (myName == mb_returnPlayerInRaidFromTable(MB_myRazorgoreLeftTank) or myName == mb_returnPlayerInRaidFromTable(MB_myRazorgoreRightTank)) then            
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

	elseif Instance.AQ40 and mb_isAtSkeram() and MB_mySkeramBoxStrategyFollow then
	
        if not mb_imTank() then
            return
        end

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

	if mb_iamFocus() then
		if not UnitName("target") or UnitIsDead("target") or not UnitIsEnemy("player", "target") and not (mb_isAtSartura() or mb_isAtTwinsEmps()) then 
			
			TargetNearestEnemy()
		end
		return
	end

	if Instance.Naxx then
		if mb_isAtGrobbulus() and MB_myGrobbulusBoxStrategy then
			if mb_imTank() then						
				if myName == MB_myGrobbulusMainTank then
					if mb_lockOnTarget("Grobbulus") then
                        return
                    end

					if not UnitName("target") or mb_dead("target") then
                        mb_assistFocus()
                    end
					return
				end
				
				mb_getTargetNotOnTank()
				return

			elseif mb_imMeleeDPS() or mb_imRangedDPS() then
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

                if mb_lockOnTarget("Grobbulus") then
                    return
                end

                if not UnitName("target") or mb_dead("target") then
                    mb_assistFocus()
                end
                return
			end

        elseif (mb_tankTarget("Instructor Razuvious") and mb_myNameInTable(MB_myRazuviousPriest) and MB_myRazuviousBoxStrategy) or
            (mb_tankTarget("Grand Widow Faerlina") and mb_myNameInTable(MB_myFaerlinaPriest) and MB_myFaerlinaBoxStrategy) then
            return

		elseif mb_tankTarget("Anub\'Rekhan") then
			if mb_imTank() then
				mb_getTargetNotOnTank()
				return

			elseif mb_imMeleeDPS() or mb_imRangedDPS() then
				for i = 1, 2 do
					if UnitName("target") == "Crypt Guard" and not mb_dead("target") then
                        return
                    end

					TargetNearestEnemy()
				end

				if not UnitName("target") or mb_dead("target") then
                    mb_assistFocus()
                end
				return
			end

		elseif mb_isAtMonstrosity() then
			if mb_imTank() then				
				mb_getTargetNotOnTank()
				return

			elseif mb_imMeleeDPS() or mb_imRangedDPS() then
				if mb_lockOnTarget("Lightning Totem") then
                    return
                end
	
				if not UnitName("target") or mb_dead("target") then
                    mb_assistFocus()
                end
				return
			end

		elseif mb_tankTarget("Plague Beast") then
			if mb_imTank() then				
				mb_getTargetNotOnTank()
				return

			elseif mb_imMeleeDPS() then
				if MB_targetWrongWayOrTooFar.Active then					
					TargetNearestEnemy()
					MB_targetWrongWayOrTooFar.Active = false
					return
				end

				for i = 1, 3 do
					if UnitName("target") == "Mutated Grub" and not mb_dead("target") then
                        return
                    end

					if UnitName("target") == "Plagued Bat" and not mb_dead("target") then
                        return
                    end

					TargetNearestEnemy()
				end

				if not UnitName("target") or mb_dead("target") then
                    mb_assistFocus()
                end
				return

			elseif mb_imRangedDPS() then
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
		
		if mb_isAtRazorgore() and MB_myRazorgoreBoxStrategy then -- Razorgore room
			
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