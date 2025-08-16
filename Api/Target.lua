--[####################################################################################################]--
--[####################################### AUTO TARGET HANDLER ########################################]--
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

local MB_targetNearestDistanceChanged = nil

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function mb_iamFocus()
	if MB_raidLeader == myName then
		return true
	end
end

function mb_assistFocus()
    if not MB_raidLeader then
		AssistByName(MB_raidInviter, 1)
		RunLine("/w "..MB_raidInviter.." Press setFOCUS!")
        return
    end

    if MB_raidLeader == myName then
        return true
    end

    local assistUnit = mb_getUnitForPlayerName(MB_raidLeader)
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
end

function mb_getTarget()
		
	if (mb_isAtRazorgore() and myName == mb_returnPlayerInRaidFromTable(MB_myRazorgoreORBtank)) and not mb_tankTarget("Razorgore the Untamed") then
        mb_orbControlling()
        return
    end

	if MB_myOTTarget then
        return
    end

	if Instance.BWL and mb_isAtRazorgore() and MB_myRazorgoreBoxStrategy then
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

	if Instance.NAXX then
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

	elseif Instance.AQ40 then
		if mb_isAtSkeram() and MB_mySkeramBoxStrategyFollow then			
			if (mb_myNameInTable(MB_mySkeramLeftTank) or mb_myNameInTable(MB_mySkeramMiddleTank) or mb_myNameInTable(MB_mySkeramRightTank)) then		
				mb_getTargetNotOnTank()
				return

			elseif mb_imTank() then				
				mb_getTargetNotOnTank()
				return

			elseif mb_imMeleeDPS() then
				if mb_hasBuffOrDebuff("True Fulfillment", "target", "debuff") then
					ClearTarget()
				end

				mb_assistFocus()
				return

			elseif mb_imRangedDPS() then
				if mb_hasBuffOrDebuff("True Fulfillment", "target", "debuff") then
					ClearTarget()
				end

				mb_assistFocus()
				return
			end
			return

		elseif mb_tankTarget("Fankriss the Unyielding") and MB_myFankrissBoxStrategy then
			if mb_imTank() then				
				if mb_myNameInTable(MB_myFankrissOFFTANKS) then
					if mb_lockOnTarget("Fankriss the Unyielding") then
						return
					end

					if not UnitName("target") or mb_dead("target") then
						mb_assistFocus()
					end
					return
				end
				
				mb_getTargetNotOnTank()
				return

			elseif mb_imMeleeDPS() and myClass == "Warrior" then
				if mb_lockOnTarget("Fankriss the Unyielding") then
					return
				end
	
				if not UnitName("target") or mb_dead("target") then
					mb_assistFocus()
				end
				return

			elseif mb_imMeleeDPS() and myClass == "Rogue" then
				if mb_assistSpecificTargetFromPlayerInMeleeRange("Spawn of Fankriss", mb_returnPlayerInRaidFromTable(MB_myFankrissSnakeTankOne)) then 
					mb_debugger(MB_raidAssist.Debugger.Rogue, "Rogues assisting "..mb_returnPlayerInRaidFromTable(MB_myFankrissSnakeTankOne).." on Spawn of Fankriss!") 
					return 
				end

				if mb_assistSpecificTargetFromPlayerInMeleeRange("Spawn of Fankriss", mb_returnPlayerInRaidFromTable(MB_myFankrissSnakeTankTwo)) then 
					mb_debugger(MB_raidAssist.Debugger.Rogue, "Rogues assisting "..mb_returnPlayerInRaidFromTable(MB_myFankrissSnakeTankTwo).." on Spawn of Fankriss!") 
					return 
				end

				if mb_lockOnTarget("Fankriss the Unyielding") then
					return
				end
	
				if not UnitName("target") or mb_dead("target") then
					mb_assistFocus()
				end
				return

			elseif mb_imRangedDPS() then
				if mb_assistSpecificTargetFromPlayer("Spawn of Fankriss", mb_returnPlayerInRaidFromTable(MB_myFankrissSnakeTankOne)) then 
					mb_debugger(MB_raidAssist.Debugger.Mage, "Casters assisting "..mb_returnPlayerInRaidFromTable(MB_myFankrissSnakeTankOne).." on Spawn of Fankriss!") 
					return 
				end

				if mb_assistSpecificTargetFromPlayer("Spawn of Fankriss", mb_returnPlayerInRaidFromTable(MB_myFankrissSnakeTankTwo)) then 
					mb_debugger(MB_raidAssist.Debugger.Mage, "Casters assisting "..mb_returnPlayerInRaidFromTable(MB_myFankrissSnakeTankTwo).." on Spawn of Fankriss!") 
					return 
				end

				if mb_lockOnTarget("Fankriss the Unyielding") then
					return
				end

				if not UnitName("target") or mb_dead("target") then
					mb_assistFocus()
				end
				return

			elseif mb_imHealer() then
				if mb_assistSpecificTargetFromPlayer("Spawn of Fankriss", mb_returnPlayerInRaidFromTable(MB_myFankrissSnakeTankOne)) then 
					mb_debugger(MB_raidAssist.Debugger.Mage, "Casters assisting "..mb_returnPlayerInRaidFromTable(MB_myFankrissSnakeTankOne).." on Spawn of Fankriss!") 
					return 
				end

				if mb_assistSpecificTargetFromPlayer("Spawn of Fankriss", mb_returnPlayerInRaidFromTable(MB_myFankrissSnakeTankTwo)) then 
					mb_debugger(MB_raidAssist.Debugger.Mage, "Casters assisting "..mb_returnPlayerInRaidFromTable(MB_myFankrissSnakeTankTwo).." on Spawn of Fankriss!") 
					return 
				end

				if mb_lockOnTarget("Fankriss the Unyielding") then
					return
				end

				if not UnitName("target") or mb_dead("target") then
					mb_assistFocus()
				end
				return
			end
			return
				
		elseif mb_tankTarget("Anubisath Defender") then
			if mb_imTank() then
				
				mb_getTargetNotOnTank()
				return

			elseif (mb_imMeleeDPS() or mb_imRangedDPS() or mb_imHealer()) then

				for i = 1, 4 do
					if UnitName("target") == "Anubisath Swarmguard" and not mb_dead("target") then
						return
					end

					if UnitName("target") == "Anubisath Warrior" and not mb_dead("target") then
						return
					end

					TargetNearestEnemy()
				end

				if not UnitName("target") or mb_dead("target") then
					mb_assistFocus()
				end
				return
			end
		end

	elseif Instance.BWL then		
		if mb_isAtRazorgore() and MB_myRazorgoreBoxStrategy then			
			if myName == mb_returnPlayerInRaidFromTable(MB_myRazorgoreORBtank) then
				return
			end

			if mb_isAtRazorgorePhase() then
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
					return

				elseif mb_imTank() then					
					if not MB_targetNearestDistanceChanged then						
						SetCVar("targetNearestDistance", "10")
						MB_targetNearestDistanceChanged = true
					end

					if MB_razorgoreNewTargetBecauseTargetIsBehind.Active then					
						TargetNearestEnemy()
						MB_razorgoreNewTargetBecauseTargetIsBehind.Active = false
						return
					end
					
					mb_getTargetNotOnTank()
					return

				elseif mb_imMeleeDPS() then
					if mb_myNameInTable(MB_myRazorgoreLeftDPSERS) then
						AssistByName(mb_returnPlayerInRaidFromTable(MB_myRazorgoreLeftTank))
						return
					end

					if mb_myNameInTable(MB_myRazorgoreRightDPSERS) then
						AssistByName(mb_returnPlayerInRaidFromTable(MB_myRazorgoreRightTank))
						return
					end
					return

				elseif mb_imRangedDPS() then
					if MB_razorgoreNewTargetBecauseTargetIsBehindOrOutOfRange.Active then						
						TargetNearestEnemy()
						MB_razorgoreNewTargetBecauseTargetIsBehindOrOutOfRange.Active = false
						return
					end

					if not mb_dead("target") then
						return
					end

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

					if not UnitName("target") or mb_dead("target") then
						mb_assistFocus()
					end
					return
				end
				return true				
			end

		elseif GetSubZoneText() == "Shadow Wing Lair" then

			if MB_raidLeader and mb_dead(MBID[MB_raidLeader]) then
				mb_lockOnTarget("Vaelastrasz the Corrupt")
				return
			end
		end

	elseif Instance.ONY and mb_tankTarget("Onyxia") and MB_myOnyxiaBoxStrategy then

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
				if UnitName("target") == "Onyxian Whelp" and not mb_dead("target") then
					return
				end

				TargetNearestEnemy()
			end

			if not UnitName("target") or mb_dead("target") then
				mb_assistFocus()
			end
			return

		elseif mb_imRangedDPS() then
			if mb_assistSpecificTargetFromPlayer("Onyxia", MB_myOnyxiaMainTank) then
				return
			end

			if not UnitName("target") or mb_dead("target") then
				mb_assistFocus()
			end
			return
		end

	elseif Instance.ZG then
		if mb_isAtJindo() then
			if mb_imTank() then				
				mb_getTargetNotOnTank() -- Get Targets not on tanks
				return

			elseif mb_imMeleeDPS() then				
				for i = 1, 4 do
					if UnitName("target") == "Shade of Jin\'do" and not mb_dead("target") then
						return
					end

					TargetNearestEnemy()
				end

				if not UnitName("target") or mb_dead("target") then
					mb_assistFocus()
				end
				return
				
			elseif mb_imRangedDPS() then
				for i = 1, 4 do
					if UnitName("target") == "Shade of Jin\'do" and not mb_dead("target") then
						return
					end

					if UnitName("target") == "Powerful Healing Ward" and not mb_dead("target") then
						return
					end

					if UnitName("target") == "Brain Wash Totem" and not mb_dead("target") then
						return
					end

					TargetNearestEnemy()
				end

				if not UnitName("target") or mb_dead("target") then
					mb_assistFocus()
				end
				return
			end

		elseif mb_tankTarget("High Priestess Mar\'li") then
			if mb_imTank() then				
				mb_getTargetNotOnTank()
				return

			elseif mb_imMeleeDPS() then				
				mb_assistFocus()
				return

			elseif mb_imRangedDPS() then
				for i = 1,5 do
					if UnitName("target") == "Spawn of Mar\'li" and not mb_dead("target") then
						return
					end

					if UnitName("target") == "Witherbark Speaker" and not mb_dead("target") then
						return
					end

					TargetNearestEnemy()
				end

				if not UnitName("target") or mb_dead("target") then
					mb_assistFocus()
				end
				return
			end

		elseif mb_tankTarget("High Priestess Jeklik") then
			if mb_imTank() then				
				mb_getTargetNotOnTank()
				return

			elseif mb_imRangedDPS() then
				for i = 1,5 do
					if UnitName("target") == "Bloodseeker Bat" and mb_inCombat("target") and not mb_dead("target") then
						return
					end

					TargetNearestEnemy()
				end

				if not UnitName("target") or mb_dead("target") then
					mb_assistFocus()
				end
				return
			end

		elseif mb_tankTarget("High Priest Venoxis") then
			if mb_imTank() then				
				mb_getTargetNotOnTank()
				return

			elseif mb_imMeleeDPS() or mb_imRangedDPS() then
				for i = 1,5 do
					if UnitName("target") == "Razzashi Cobra" and not mb_dead("target") and not GetRaidTargetIndex("target") then
						return
					end

					TargetNearestEnemy()
				end

				if not UnitName("target") or mb_dead("target") then
					mb_assistFocus()
				end
				return
			end
		end
					
	elseif Instance.AQ20 and mb_tankTarget("Ayamiss the Hunter") and not mb_dead("target") then

		if mb_imTank() then			
			mb_getTargetNotOnTank()
			return

		elseif mb_imMeleeDPS() or mb_imRangedDPS() then
			for i = 1,5 do
				if UnitName("target") == "Hive\'Zara Larva" and not mb_dead("target") then
					return
				end

				TargetNearestEnemy()
			end

			if not UnitName("target") or mb_dead("target") then
				mb_assistFocus()
			end
			return
		end
		
	elseif GetRealZoneText() == "Blackrock Spire" and mb_tankTarget("Lord Valthalak") and not mb_dead("target") then
		if mb_imTank() then			
			mb_getTargetNotOnTank()
			return

		elseif mb_imMeleeDPS() or mb_imRangedDPS() then

			for i = 1,5 do
				if UnitName("target") == "Spectral Assassin" and not mb_dead("target") then
					return
				end

				TargetNearestEnemy()
			end

			if not UnitName("target") or mb_dead("target") then
				mb_assistFocus()
			end
			return
		end
	end

	local focId = MBID[MB_raidLeader]
	if not focId then
		mb_assistFocus()

	elseif UnitName(focId.."target") then		
		TargetUnit(focId.."target")
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

--[####################################################################################################]--
--[####################################### AUTO TARGET HELPERS ########################################]--
--[####################################################################################################]--

function mb_tankTarget(mobName)
    local focusId = MBID[MB_raidLeader]
    if not focusId then
        return false
    end
    
    local targetOfFocus = UnitName(focusId.."target")
    if not targetOfFocus then
        return false
    end
    
    return targetOfFocus == mobName
end

function mb_tankTargetInSet(mobSet)
    local focusId = MBID[MB_raidLeader]
    if not focusId then
        return false
    end
    
    local tankTargetName = UnitName(focusId.."target")
    if not tankTargetName then
        return false
    end
    
    return mobSet[tankTargetName] == true
end

function mb_playerWithAgroFromSpecificTarget(target, player)
    local playerId = MBID[player]
    if not playerId then
        return false
    end
    
    local playerTargetTarget = UnitName(playerId.."targettarget")
    if not playerTargetTarget then
        return false
    end
    
    local playerTarget = UnitName(playerId.."target")
    if not playerTarget then
        return false
    end
    
    local targetFound = string.find(playerTarget, target)
    if targetFound then
        return true
    end
    
    return false
end

function mb_targetHealthFromRaidleader(mobName, percentage)
    local raidLeaderId = MBID[MB_raidLeader]
    if not raidLeaderId then
        return false
    end
    
    local isTargetingMob = mb_tankTarget(mobName)
    if not isTargetingMob then
        return false
    end
    
    local targetHealthPercentage = mb_healthPct(raidLeaderId.."target")
    return (targetHealthPercentage <= percentage)
end

function mb_targetHealthFromSpecificPlayer(mobName, percentage, player)
    local isPlayerTargetingMob = mb_targetFromSpecificPlayer(mobName, player)
    if not isPlayerTargetingMob then
        return false
    end
    
    local playerId = MBID[player]
    if not playerId then
        return false
    end
    
    local targetHealthPercentage = mb_healthPct(playerId.."target")
    return (targetHealthPercentage <= percentage)
end

function mb_targetFromSpecificPlayer(target, player)
    local playerId = MBID[player]
    if not playerId then
        return false
    end
    
    local playerTarget = UnitName(playerId.."target")
    if not playerTarget then
        return false
    end
    
    local targetFound = string.find(playerTarget, target)
    if targetFound then
        return true
    end
    
    return false
end

function mb_assistSpecificTargetFromPlayer(target, player)
    if not mb_targetFromSpecificPlayer(target, player) then
        return false
    end
    
    AssistByName(player)
    return true
end

function mb_assistSpecificTargetFromPlayers(target, playerOne, playerTwo)
    if mb_targetFromSpecificPlayer(target, playerOne) then
        AssistByName(playerOne)
        return true
    end
    
    if mb_targetFromSpecificPlayer(target, playerTwo) then
        AssistByName(playerTwo)
        return true
    end
    
    return false
end

function mb_assistSpecificTargetFromPlayerInMeleeRange(target, player)
    if not mb_targetFromSpecificPlayer(target, player) then
        return false
    end
    
    local playerId = MBID[player]
    if not playerId then
        return false
    end
    
    if not CheckInteractDistance(playerId.."target", 3) then
        return false
    end
    
    AssistByName(player)
    return true
end

function mb_focusAggro()
    local raidLeaderId = MBID[MB_raidLeader]
    if not raidLeaderId then
        return false
    end
    
    local raidLeaderTargetTarget = UnitName(raidLeaderId.."targettarget")
    if not raidLeaderTargetTarget then
        return false
    end
    
    local isTargetingMe = string.find(raidLeaderTargetTarget, myName)
    if isTargetingMe then
        return true
    end
    
    return false
end

function mb_tankTargetHealth()
    if not MB_raidLeader then
        return nil
    end
    
    local raidLeaderId = MBID[MB_raidLeader]
    if not raidLeaderId then
        return nil
    end
    
    local targetId = raidLeaderId.."target"
    if not targetId then
        return nil
    end
    
    local isDead = mb_dead(targetId)
    if isDead then
        return 0
    end
    
    return mb_healthPct(targetId)
end

function mb_debugger(who, msg)
    if not MB_raidAssist.Debugger.Active then
        return
    end

	if myName == who then
		mb_message(msg, 20)
	end
end

function mb_lockOnTarget(target)
	for i = 1,3 do
		if UnitName("target") == target and not mb_dead("target") then
            return true
        end

		TargetByName(target)
	end
	return false
end

function mb_isAtJindo()
    local targetName = UnitName("target")
    
    if mb_tankTarget("Powerful Healing Ward") then
        return true
    end
    
    if mb_tankTarget("Shade of Jin'do") then
        return true
    end
    
    if mb_tankTarget("Jin'do the Hexxer") then
        return true
    end
    
    if tankTmb_tankTarget("Brain Wash Totem") then
        return true
    end
    
    if not targetName then
        return false
    end
    
    if targetName == "Powerful Healing Ward" then
        return true
    end
    
    if targetName == "Shade of Jin'do" then
        return true
    end
    
    if targetName == "Jin'do the Hexxer" then
        return true
    end
    
    if targetName == "Brain Wash Totem" then
        return true
    end
    
    return false
end

function mb_isAtNoth()
    local targetName = UnitName("target")
    
    if mb_tankTarget("Noth the Plaguebringer") then
        return true
    end
    
    if mb_tankTarget("Plagued Warrior") then
        return true
    end
    
    if mb_tankTarget("Plagued Champion") then
        return true
    end
    
    if mb_tankTarget("Plagued Guardian") then
        return true
    end
    
    if mb_tankTarget("Plagued Skeletons") then
        return true
    end
    
    if not targetName then
        return false
    end
    
    if targetName == "Noth the Plaguebringer" then
        return true
    end
    
    if targetName == "Plagued Warrior" then
        return true
    end
    
    if targetName == "Plagued Champion" then
        return true
    end
    
    if targetName == "Plagued Guardian" then
        return true
    end
    
    if targetName == "Plagued Skeletons" then
        return true
    end
    
    return false
end

function mb_isAtMonstrosity()
    local targetName = UnitName("target")
    
    if mb_tankTarget("Living Monstrosity") then
        return true
    end
    
    if mb_tankTarget("Mad Scientist") then
        return true
    end
    
    if mb_tankTarget("Surgical Assistant") then
        return true
    end
    
    if not targetName then
        return false
    end
    
    if targetName == "Living Monstrosity" then
        return true
    end
    
    if targetName == "Mad Scientist" then
        return true
    end
    
    if targetName == "Surgical Assistant" then
        return true
    end
    
    return false
end

function mb_isAtGrobbulus()
   local targetName = UnitName("target")
   
   if mb_targetFromSpecificPlayer("Grobbulus", MB_myGrobbulusMainTank) then
       return true
   end
   
   if mb_targetFromSpecificPlayer("Fallout Slime", MB_myGrobbulusSlimeTankOne) then
       return true
   end
   
   if mb_targetFromSpecificPlayer("Fallout Slime", MB_myGrobbulusSlimeTankTwo) then
       return true
   end
   
   if mb_tankTarget("Grobbulus") then
       return true
   end
   
   if mb_tankTarget("Fallout Slime") then
       return true
   end
   
   if not targetName then
       return false
   end
   
   if targetName == "Grobbulus" then
       return true
   end
   
   if targetName == "Fallout Slime" then
       return true
   end
   
   return false
end

function mb_isAtLoatheb()
   local targetName = UnitName("target")
   
   if mb_targetFromSpecificPlayer("Loatheb", MB_myLoathebMainTank) then
       return true
   end
   
   if mb_targetFromSpecificPlayer("Spore", MB_myLoathebMainTank) then
       return true
   end
   
   if mb_tankTarget("Loatheb") then
       return true
   end
   
   if mb_tankTarget("Spore") then
       return true
   end
   
   if not targetName then
       return false
   end
   
   if targetName == "Loatheb" then
       return true
   end
   
   if targetName == "Spore" then
       return true
   end
   
   return false
end

local function IsOrbControlled()
	for i = 1, GetNumRaidMembers() do
		if mb_hasBuffOrDebuff("Mind Exhaustion", "raid"..i, "debuff") then
			return true
		end
	end
	return false
end

function mb_isAtRazorgorePhase()
   local targetName = UnitName("target")
   
   if IsOrbControlled() then
       return true
   end
   
   if mb_tankTarget("Blackwing Mage") then
       return true
   end
   
   if mb_tankTarget("Blackwing Legionnaire") then
       return true
   end
   
   if mb_tankTarget("Death Talon Dragonspawn") then
       return true
   end
   
   local leftTank = mb_returnPlayerInRaidFromTable(MB_myRazorgoreLeftTank)
   if mb_targetFromSpecificPlayer("Blackwing Mage", leftTank) then
       return true
   end
   
   if mb_targetFromSpecificPlayer("Blackwing Legionnaire", leftTank) then
       return true
   end
   
   if mb_targetFromSpecificPlayer("Death Talon Dragonspawn", leftTank) then
       return true
   end
   
   local rightTank = mb_returnPlayerInRaidFromTable(MB_myRazorgoreRightTank)
   if mb_targetFromSpecificPlayer("Blackwing Mage", rightTank) then
       return true
   end
   
   if mb_targetFromSpecificPlayer("Blackwing Legionnaire", rightTank) then
       return true
   end
   
   if mb_targetFromSpecificPlayer("Death Talon Dragonspawn", rightTank) then
       return true
   end
   
   if not targetName then
       return false
   end
   
   if targetName == "Blackwing Mage" then
       return true
   end
   
   if targetName == "Blackwing Legionnaire" then
       return true
   end
   
   if targetName == "Death Talon Dragonspawn" then
       return true
   end
   
   return false
end

function mb_isAtInstructorRazuvious()
   local targetName = UnitName("target")
   
   if mb_tankTarget("Instructor Razuvious") then
       return true
   end
   
   if mb_tankTarget("Deathknight Understudy") then
       return true
   end
   
   if not targetName then
       return false
   end
   
   if targetName == "Instructor Razuvious" then
       return true
   end
   
   if targetName == "Deathknight Understudy" then
       return true
   end
   
   return false
end

function mb_isAtSartura()
   local targetName = UnitName("target")
   
   if mb_tankTarget("Battleguard Sartura") then
       return true
   end
   
   if mb_tankTarget("Sartura's Royal Guard") then
       return true
   end
   
   if not targetName then
       return false
   end
   
   if targetName == "Battleguard Sartura" then
       return true
   end
   
   if targetName == "Sartura's Royal Guard" then
       return true
   end
   
   return false
end

function mb_isAtNefarianPhase()
   local targetName = UnitName("target")
   
   if mb_tankTarget("Red Drakonid") then
       return true
   end
   
   if mb_tankTarget("Blue Drakonid") then
       return true
   end
   
   if mb_tankTarget("Green Drakonid") then
       return true
   end
   
   if mb_tankTarget("Black Drakonid") then
       return true
   end
   
   if mb_tankTarget("Bronze Drakonid") then
       return true
   end
   
   if mb_tankTarget("Chromatic Drakonid") then
       return true
   end
   
   if mb_tankTarget("Lord Victor Nefarius") then
       return true
   end
   
   if not targetName then
       return false
   end
   
   if targetName == "Red Drakonid" then
       return true
   end
   
   if targetName == "Blue Drakonid" then
       return true
   end
   
   if targetName == "Green Drakonid" then
       return true
   end
   
   if targetName == "Black Drakonid" then
       return true
   end
   
   if targetName == "Bronze Drakonid" then
       return true
   end
   
   if targetName == "Chromatic Drakonid" then
       return true
   end
   
   if targetName == "Lord Victor Nefarius" then
       return true
   end
   
   return false
end

function mb_isAtSkeram()
   local targetName = UnitName("target")
   
   if mb_tankTarget("The Prophet Skeram") then
       return true
   end
   
   local leftTank = mb_returnPlayerInRaidFromTable(MB_mySkeramLeftTank)
   if mb_targetFromSpecificPlayer("The Prophet Skeram", leftTank) then
       return true
   end
   
   local middleTank = mb_returnPlayerInRaidFromTable(MB_mySkeramMiddleTank)
   if mb_targetFromSpecificPlayer("The Prophet Skeram", middleTank) then
       return true
   end
   
   local rightTank = mb_returnPlayerInRaidFromTable(MB_mySkeramRightTank)
   if mb_targetFromSpecificPlayer("The Prophet Skeram", rightTank) then
       return true
   end
   
   if not targetName then
       return false
   end
   
   if targetName == "The Prophet Skeram" then
       return true
   end
   
   return false
end

function mb_isAtTwinsEmps()
   local targetName = UnitName("target")
   
   if mb_tankTarget("Qiraji Scarab") then
       return true
   end
   
   if mb_tankTarget("Qiraji Scorpion") then
       return true
   end
   
   if mb_tankTarget("Emperor Vek'lor") then
       return true
   end
   
   if mb_tankTarget("Emperor Vek'nilash") then
       return true
   end
   
   if not targetName then
       return false
   end
   
   if targetName == "Qiraji Scarab" then
       return true
   end
   
   if targetName == "Qiraji Scorpion" then
       return true
   end
   
   if targetName == "Emperor Vek'lor" then
       return true
   end
   
   if targetName == "Emperor Vek'nilash" then
       return true
   end
   
   return false
end

function mb_offTank()
	if not MB_myOTTarget then
		return
	end

	if UnitExists("target") and GetRaidTargetIndex("target") and GetRaidTargetIndex("target") == MB_myOTTarget then		
		if mb_dead("target") then
			MB_myOTTarget = nil
			TargetUnit("playertarget")
			return
		end

		mb_coolDownPrint("Locked On Target")
		return
	end

	for i = 1, 6 do
		if UnitExists("target") and GetRaidTargetIndex("target") and GetRaidTargetIndex("target") == MB_myOTTarget and not UnitIsDead("target") and not mb_inCombat("target") then
			return
		end

		TargetNearestEnemy()
	end
end

function mb_getTargetNotOnTank()
	if mb_dead("player") then
        return
    end

	if (UnitName("target") == "Deathknight Understudy" or UnitName("target") == "Hakkar"
        or UnitName("target") == "Fallout Slime" or UnitName("target") == "Spawn of Fankriss") then
        return
    end

	if mb_isNotValidTankableTarget() then
		TargetNearestEnemy()
	end

	if UnitIsEnemy("target", "player") and mb_inCombat("target")
        and not FindInTable(MB_raidTanks, UnitName("targettarget")) then
        return
    end

	for i = 0, 8 do
		if not UnitName("target") then 			
			TargetNearestEnemy() 
		end

		if UnitIsEnemy("target", "player") and mb_inCombat("target")
            and not FindInTable(MB_raidTanks, UnitName("targettarget")) then
            return
        end

		TargetNearestEnemy()
	end
end

function mb_getMyInterruptTarget()
	if not MB_myInterruptTarget then
		mb_assistFocus()
		return
	end

	for i = 1, 6 do
		if GetRaidTargetIndex("target") == MB_myInterruptTarget and not mb_dead("target") then
			return
		end

		if GetRaidTargetIndex("target") == MB_myInterruptTarget and mb_dead("target") then			
			TargetNearestEnemy()
		end

		TargetNearestEnemy()
	end
end

function mb_crowdControlMCedRaidMemberHakkar()
	if mb_dead("player") then
		return
	end

	for i = 1, GetNumRaidMembers() do				
		if UnitName("raid"..i) and mb_isAlive("raid"..i) and mb_in28yardRange("raid"..i) then
			if mb_hasBuffOrDebuff("Mind Control", "raid"..i, "debuff")
				and not mb_hasBuffOrDebuff("Polymorph", "raid"..i, "debuff") then				
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

function mb_crowdControlMCedRaidMemberSkeram()
	if mb_dead("player") then
		return
	end

	for i = 1, GetNumRaidMembers() do				
		if UnitName("raid"..i) and mb_isAlive("raid"..i) and mb_in28yardRange("raid"..i) then			
			if mb_hasBuffOrDebuff("True Fulfillment", "raid"..i, "debuff")
				and not mb_hasBuffOrDebuff("Polymorph", "raid"..i, "debuff") then				
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

function mb_crowdControlMCedRaidMemberSkeramFear()
	if mb_dead("player") then
		return
	end

	for i = 1, GetNumRaidMembers() do				
		if UnitName("raid"..i) and mb_isAlive("raid"..i) and mb_in28yardRange("raid"..i) then		
			if mb_hasBuffOrDebuff("True Fulfillment", "raid"..i, "debuff") 
				and not mb_hasBuffOrDebuff("Polymorph", "raid"..i, "debuff") 
				and not mb_hasBuffOrDebuff("Fear", "raid"..i, "debuff") then				
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

function mb_crowdControlMCedRaidMemberSkeramAOE()
	if mb_dead("player") then 
		return
	end

	if not mb_spellReady("Psychic Scream") then
		return
	end

	for i = 1, GetNumRaidMembers() do				
		if UnitName("raid"..i) and mb_isAlive("raid"..i) then			
			if mb_hasBuffOrDebuff("True Fulfillment", "raid"..i, "debuff") 
				and not mb_hasBuffOrDebuff("Polymorph", "raid"..i, "debuff") 
				and not mb_hasBuffOrDebuff("Psychic Scream", "raid"..i, "debuff") 
				and not mb_hasBuffOrDebuff("Fear", "raid"..i, "debuff") and CheckInteractDistance("raid"..i, 3 ) then

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

function mb_crowdControlMCedRaidMemberNefarian()
	if mb_dead("player") then
		return
	end

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

function mb_autoAssignBanishOnMoam()
	if not mb_iamFocus() then
		return
	end

	if not (UnitName("target") == "Moam" or UnitName("target") == "Mana Fiend") then
		return
	end

	for i = 1, 5 do
		if UnitName("target") == "Mana Fiend" and not GetRaidTargetIndex("target") and not UnitIsDead("target") then 
			mb_assignCrowdControl() 
			return 
		end

		TargetNearestEnemy()
	end

	if not moamDead then
		TargetByName("Moam")
	end

	if UnitIsDead("target") and UnitName("target") == "Moam" then 
		moamDead = true
	end
end

function mb_healerJindoRotation(spellName)
	if Instance.ZG and mb_hasBuffOrDebuff("Delusions of Jin\'do", "player", "debuff") then
        if UnitName("target") == "Shade of Jin\'do" and not mb_dead("target") then
            CastSpellByName(spellName)
        end
        return true
    end
	return false
end