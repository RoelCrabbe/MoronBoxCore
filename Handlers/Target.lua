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

function mb_imFocus()
	if MB_raidLeader == myName then
		return true
	end
end

function mb_assistFocus()
    if not MB_raidLeader and myName ~= MB_raidInviter then
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

function mb_playerWithAggroFromSpecificTarget(target, player)
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

function mb_targetHealthFromSpecificPlayer(mobName, percentage, playerName)
	local playerId = MBID[playerName]
    if not playerId then
        return false
    end

    local isPlayerTargetingMob = mb_targetFromSpecificPlayer(mobName, playerName)
    if not isPlayerTargetingMob then
        return false
    end
    
    local targetHealthPercentage = mb_healthPct(playerId.."target")
    return (targetHealthPercentage <= percentage)
end

function mb_targetFromSpecificPlayer(targetName, playerName)
	local playerId = MBID[playerName]
    if not playerId then
        return false
    end

    local playerTarget = UnitName(playerId.."target")
    if not playerTarget then
        return false
    end

    return playerTarget == targetName
end

function mb_assistSpecificTargetFromPlayer(targetName, playerName)
    local playerId = MBID[playerName]
    if not playerId then
        return false
    end

    if not mb_targetFromSpecificPlayer(targetName, playerName) then
        return false
    end

    AssistUnit(playerId)
    return true
end

function mb_assistSpecificTargetFromPlayerInMeleeRange(targetName, playerName)
    local playerId = MBID[playerName]
    if not playerId then
        return false
    end

    if not mb_targetFromSpecificPlayer(targetName, playerName) then
        return false
    end
    
    if not CheckInteractDistance(playerId.."target", 3) then
        return false
    end
    
    AssistUnit(playerId)
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
		mb_cdMessage(msg, 20)
	end
end

function mb_lockOnTarget(target)
	for i = 1, 3 do
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
    
    if mb_tankTarget("Brain Wash Totem") then
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
	
	if targetName and targetName == "The Prophet Skeram" then
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

		mb_cdPrint("Locked On Target")
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
				mb_cdMessage("Sheeping "..UnitName("raid"..i), 30)
				return true
			end
		end
	end
	return false
end

function mb_autoAssignBanishOnMoam()
	if not mb_imFocus() then
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
	if Instance.ZG() and mb_hasBuffOrDebuff("Delusions of Jin\'do", "player", "debuff") then
        if UnitName("target") == "Shade of Jin\'do" and not mb_dead("target") then
            CastSpellByName(spellName)
        end
        return true
    end
	return false
end