--[####################################################################################################]--
--[##################################### Crown Controlling ! ##########################################]--
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

function mb_crowdControlAsPull()
	if IsAltKeyDown() then		
		mb_powerShieldTanks()
		return
	end

	if IsShiftKeyDown() then
		if mb_spellReady("Power Word: Shield") then			
			mb_castShieldOnRandomRaidMember("Weakened Soul", "rank 10")
		end
		return
	end

	mb_crowdControl()
end

function mb_crowdControl()
    if not MB_myCCTarget then
		mb_crowdControlFear() 
		return false
	end

    if myClass == "Druid" and GetRaidTargetIndex("target") == MB_myCCTarget then
        if UnitName("target") == "Death Talon Wyrmkin" then
            CastSpellByName("Hibernate(Rank 1)")
            return true
        end
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

function mb_assignCrowdControl()
	if not mb_iamFocus() then
        return
    end

	if IsShiftKeyDown() then
        mb_assignFear()
        return
    end

	if IsAltKeyDown() and UnitCreatureType("target") == "Beast" then
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

            if MB_currentCC.Druid == num_druids then
                MB_currentCC.Druid = 1
                mb_message("ALL DRUIDS ASSIGNED, STOP ASSIGNING MORE.")
            else
                MB_currentCC.Druid = MB_currentCC.Druid + 1
            end
        end
		return
	end

	if UnitCreatureType("target") == "Demon" or UnitCreatureType("target") == "Elemental" then
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

	elseif UnitCreatureType("target") == "Undead" then
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

	elseif UnitCreatureType("target") == "Dragonkin" then
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
		
            if MB_currentCC.Druid == num_druids then
                MB_currentCC.Druid = 1
                mb_message("ALL DRUIDS ASSIGNED, STOP ASSIGNING MORE.")
            else
                MB_currentCC.Druid = MB_currentCC.Druid + 1
            end
        end

	elseif nil or UnitCreatureType("target") == "Beast" or UnitCreatureType("target") == "Humanoid" or UnitCreatureType("target") == "Critter" then
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

function mb_crowdControlFear()
	if not MB_myFearTarget then
        return
    end

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

function mb_assignFear()
	if not mb_iamFocus() then
        return
    end

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
            mb_message("ALL WARLOCKS ASSIGNED, STOP ASSIGNING MORE.")
        else
            MB_currentFear.Warlock = MB_currentFear.Warlock + 1
        end
	end
end

function mb_assignOffTank()
	if IsShiftKeyDown() then		
		mb_assignInterrupt() 
		return 
	end

	if not mb_iamFocus() or TableLength(MB_offTanks) == 0 then
        return
    end

	if not GetRaidTargetIndex("target") or GetRaidTargetIndex("target") == 0 then
		SetRaidTarget("target", MB_currentRaidTarget)
		if MB_currentRaidTarget == 8 then MB_currentRaidTarget = 1 else MB_currentRaidTarget = MB_currentRaidTarget + 1 end
	end

	local thisOffTank
	if IsShiftKeyDown() then
		local temp = DecrementIndex(MB_Ot_Index, TableLength(MB_offTanks))
		thisOffTank = MB_offTanks[temp]
	else
		thisOffTank = MB_offTanks[MB_Ot_Index]
	end

	if UnitInRaid("player") then
		SendAddonMessage(MB_RAID.."_OT", thisOffTank, "RAID")
	else
		SendAddonMessage(MB_RAID.."_OT", thisOffTank)
	end

	if not IsShiftKeyDown() then 
		MB_Ot_Index = IncrementIndex(MB_Ot_Index, TableLength(MB_offTanks))
	end
end

function mb_assignInterrupt()
	if not mb_iamFocus() then
        return
    end

	if not GetRaidTargetIndex("target") or GetRaidTargetIndex("target") == 0 then
		SetRaidTarget("target", MB_currentRaidTarget)
		if MB_currentRaidTarget == 8 then MB_currentRaidTarget = 1 else MB_currentRaidTarget = MB_currentRaidTarget + 1 end
	end

	local num_shaman = TableLength(MB_classList["Shaman"])
	local num_rogues = TableLength(MB_classList["Rogue"])
	local num_mages = TableLength(MB_classList["Mage"])

	local num_interrupters = num_rogues
	local num_interrupters = num_interrupters + num_shaman
	local num_interrupters = num_interrupters + num_mages

	if num_interrupters == 0 then
        return
    end
	
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