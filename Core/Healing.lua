--[####################################################################################################]--
--[##################################### HEALING GLOBAL VARIABLES ######################################]--
--[####################################################################################################]--

--[[
    This file contains all boss encounter healing and player assignments.

    Note: All variables are global and accessible throughout the addon's
--]]

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

-- Adjust the values below to control when Priests and Druids cast HoTs and Shields.
MB_priestRenewLowRandomPercentage           		= 0.66
MB_priestRenewLowRandomRank                 		= "Rank 4"

MB_priestRenewAggroedPlayerPercentage     			= 0.90
MB_priestRenewAggroedPlayerRank            			= "Rank 7"

MB_priestShieldLowRandomPercentage         			= 0.33
MB_priestShieldAggroedPlayerPercentage    			= 0.25

MB_druidRejuvenationLowRandomMovingPercentage 		= 0.75
MB_druidRejuvenationLowRandomMovingRank       		= "Rank 3"

MB_druidRejuvenationLowRandomPercentage    			= 0.45
MB_druidRejuvenationLowRandomRank          			= "Rank 5"

MB_druidRejuvenationAggroedPlayerPercentage 		= 0.9
MB_druidRejuvenationAggroedPlayerRank       		= "Rank 9"

MB_paladinDivineFavorPercentage            			= 0.8
MB_priestInnerFocusPercentage              			= 0.3

-- Swiftmend-specced Druid settings
MB_druidSwiftmendRejuvenationLowRandomPercentage 	= 0.7
MB_druidSwiftmendRejuvenationLowRandomRank       	= "Rank 6"

MB_druidSwiftmendAtPercentage             			= 0.7
MB_druidSwiftmendRegrowthLowRandomPercentage 		= 0.2

MB_druidSwiftmendRegrowthAggroedPlayerPercentage 	= 0.75
MB_druidSwiftmendRegrowthAggroedPlayerRank       	= "Rank 4"

MB_lowestSpellDmgFromGearToScorchToKeepIgnitesUp 	= 565

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

MB_myInnervateHealerList = {
	"Draub",
	"Ayag",
	"Midavellir",
	"Murdrum",
	"Blaidzy"
}

MB_myFlashHealerList = {
	"Draub",
	"Ayag",
	"Midavellir",
	"Murdrum",
	"Blaidzy"
}
	
--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

MB_myInstructorRazuviousAddHealer = {

	-- Horde
	"Mvenna", -- 8T1 Shammy
	"Azøg", -- 8T1 Shammy 
	"Chimando", -- 8T1 Shammy
	--"Purges", -- 8T1 Shammy
	"Superkoe", -- 8T1 Shammy
	"Bogeycrap", -- 8T1 Shammy

	"Laitelaismo", -- 8T3 Shammy
	"Shamuk", -- 8T3 Shammy

	"Corinn", -- 8T2 Priest
	"Healdealz", -- 8T2 Priest
	"Draub", -- 8T2 Priest
	"Ayag", -- T3 Priest

	"Smalheal", -- Druid
	"Drushgor", -- Druid

	-- Alliance
	"Bubblebumm", -- Pala never oom
	"Breachedhull", -- Pala never oom
	"Candylane", -- Pala never oom
	"Fatnun", -- Pala never oom

	"Murdrum", -- 8T3 Priest
	"Wiccana", -- 8T2 Priest
	"Nouveele", -- 8T2 Priest
	"Hms", -- 8T2 Priest

	"Jahetsu", -- Druid
	"Kusch" -- Druid
}

MB_myMainTankOverhealingPercentage = 0.89 --> 11% overheal

MB_myDruidMainTankHealingRank = "Rank 7" -- Healing Touch
MB_myDruidMainTankHealingBossList = {
	-- Default bosses
	"Ossirian the Unscarred",
	"Patchwerk",

	-- Extra bosses
		-- MC
		"Magmadar",
		"Ragnaros",

		-- Naxx
		"Maexxna",
		"Gluth",
		"Heigan the Unclean",
		"Grobbulus",

		-- AQ40
		"Princess Huhuran",
		"Fankriss the Unyielding",

		-- BWL
		"Chromaggus",
		"Firemaw"
}
	
MB_myPriestMainTankHealingRank = "Rank 1" -- Greater Heal
MB_myPriestMainTankHealingBossList = {
	-- Default bosses
	"Ossirian the Unscarred",
	"Patchwerk",

	-- Extra bosses
		-- Naxx
		"Gluth",
}

MB_myShamanMainTankHealingRank = "Rank 7" -- Healing Wave
MB_myShamanMainTankHealingBossList = {
	-- Default bosses
	"Ossirian the Unscarred",
	"Patchwerk",

	-- Extra bosses
		-- Raidheal other bosses
}

MB_myPaladinMainTankHealingRank = "Rank 6" -- Flash of Light
MB_myPaladinMainTankHealingBossList = {
	-- Default bosses
	"Ossirian the Unscarred",
	"Patchwerk",

	-- Extra bosses
		-- Naxx
		"Maexxna",
		"Gluth",
}

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

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
			num = num..char
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

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function mb_assignHealerToName(assignments)
	local _, _, healerName, assignedTarget = string.find(assignments, "(%a+)%s*(%a+)")

	if mb_iamFocus() then
		if (assignedTarget == "Reset" or assignedTarget == "reset") then
			mb_message("Unassigned "..healerName.." from healing a specific player.")
			return
		end
		
		mb_message("Assigned "..healerName.." to heal "..assignedTarget..".")		
	end

	if myName == healerName then
		if (assignedTarget == "Reset" or assignedTarget == "reset") then
			Print("Unassigned myself to focusheal "..MB_myAssignedHealTarget..".")
			MB_myAssignedHealTarget = nil
			return
		end

		MB_myAssignedHealTarget = assignedTarget
		Print("Assigning myself to focusheal "..MB_myAssignedHealTarget..".")
	end
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function mb_getHealSpell()
	if myClass == "Shaman" then
		if mb_equippedSetCount("Earthfury") == 8 then			
			MB_myHealSpell = "Healing Wave"
			return true

		elseif mb_equippedSetCount("The Ten Storms") >= 3 and mb_equippedSetCount("Stormcaller\'s Garb") == 5 then			
			MB_myHealSpell = "Chain Heal"
			return true
		else			
			if MB_raidAssist.Shaman.DefaultToHealingWave then				
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

	elseif myClass == "Druid" and mb_equippedSetCount("Dreamwalker Raiment") >= 2 then
		MB_myHealSpell = "Rejuvenation"
		return true
	end
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function mb_natureSwiftnessLowAggroedPlayer()
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
		for i =  1, GetNumRaidMembers() do
			local NSTarget = "raid"..i

			if NSTarget and aggrox:GetUnitAggroByUnitId(NSTarget) then				
				if mb_isValidFriendlyTarget(NSTarget, instantSpell) 
					and mb_healthPct(NSTarget) <= blastNSatThisPercentage
					and not mb_hasBuffOrDebuff("Feign Death", NSTarget, "buff") then 
				
					if UnitIsFriend("player", NSTarget) then
						ClearTarget()
					end
				
					if not mb_hasBuffOrDebuff("Nature\'s Swiftness", "player", "buff") then						
						SpellStopCasting()
					end

					mb_selfBuff("Nature\'s Swiftness")
				
					if mb_hasBuffOrDebuff("Nature\'s Swiftness", "player", "buff") then		
						CastSpellByName(instantSpell, false)
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

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function mb_castSpellOnRandomRaidMember(spell, rank, percentage)
	if not UnitInRaid("player") then
        return
    end

	if mb_imBusy() then
        return
    end

    if mb_tankTarget("Garr") or mb_tankTarget("Firesworn") then
        return
    end

	local n, r, i, j
	n = mb_GetNumPartyOrRaidMembers()
	r = math.random(n) - 1

	for i = 1, n do
		j = i + r
		if j > n then
			j = j - n
		end	

		if mb_healthPct("raid"..j) < percentage
			and not mb_hasBuffNamed(spell, "raid"..j)
			and mb_isValidFriendlyTarget("raid"..j, spell) then

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

function mb_castShieldOnRandomRaidMember(spell, rank)
	if mb_imBusy() then
		return
	end

	if not UnitInRaid("player") then
		return
	end

	if mb_tankTarget("Garr") or mb_tankTarget("Firesworn") then
		return
	end
	
	local n, r, i, j
	n = mb_GetNumPartyOrRaidMembers()
	r = math.random(n) - 1

	for i = 1, n do
		j = i + r
		if j > n then
			j = j - n
		end	

		if not mb_hasBuffNamed("Power Word: Shield", "raid"..j) 
			and not mb_hasBuffNamed("Weakened Soul", "raid"..j)
			and mb_isValidFriendlyTarget("raid"..j, spell) then

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

function mb_powerShieldTanks()	
	if myClass ~= "Priest" then
		return
	end

	local i = 1
	for _, tank in MB_raidTanks do
		if mb_isAlive(MBID[tank]) then
			if mb_myClassOrder() == i then				
				TargetUnit(MBID[tank])
				CastSpellByName("Power Word: Shield")
				return
			end

			i = i + 1
		end
	end
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function mb_instructorRazAddsHeal()
    if not UnitInRaid("player") then
        return false
    end

    if mb_tankTarget("Instructor Razuvious") and mb_myNameInTable(MB_myInstructorRazuviousAddHealer) then
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
    return false
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function mb_healLieutenantAQ20()
	if not UnitInRaid("player") then
        return false
    end

	if MB_lieutenantAndorovIsNotHealable.Active then
		return false
	end

	if Instance.AQ20 then
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

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function mb_targetMyAssignedTankToHeal()	
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

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function mb_loathebHealing()
   local HealerCounter = 1
   
   if not MB_myLoathebHealer then
       return false
   end
   
   local currentHealer = MB_myLoathebHealer[HealerCounter]
   if not currentHealer then
       return false
   end
   
   local currentHealerId = MBID[currentHealer]
   if not currentHealerId then
       return false
   end
   
   local hasCorruptedMind = mb_hasBuffOrDebuff("Corrupted Mind", currentHealerId, "debuff")
   if hasCorruptedMind then
       local healerTableLength = TableLength(MB_myLoathebHealer)
       if HealerCounter == healerTableLength then
           HealerCounter = 1
       else
           HealerCounter = HealerCounter + 1
       end
   end
   
   local nextHealer = MB_myLoathebHealer[HealerCounter]
   if not nextHealer then
       return false
   end
   
   mb_message("Current healer: "..nextHealer)
   
   if myName ~= nextHealer then
       return false
   end
   
   local mainTank = MB_myLoathebMainTank
   if not mainTank then
       return false
   end
   
   local mainTankId = MBID[mainTank]
   if not mainTankId then
       return false
   end
   
   local myHealSpell = MB_myLoathebHealSpell[myClass]
   if not myHealSpell then
       return false
   end
   
   local myHealRank = MB_myLoathebHealSpellRank[myClass]
   if not myHealRank then
       return false
   end
   
   local healValue = GetHealValueFromRank(myHealSpell, myHealRank)
   if not healValue then
       return false
   end
   
   local overhealPercentage = MB_myMainTankOverhealingPercentage
   if not overhealPercentage then
       return false
   end
   
   local healThreshold = healValue * overhealPercentage
   
   mb_coolDownPrint("My heal will start when "..mainTank.." is below "..healThreshold.." HP")
   mb_coolDownPrint("Without overhealing my heal would heal for "..healValue)
   
   local healthDown = mb_healthDown(mainTankId)
   if not healthDown then
       return false
   end
   
   if healthDown >= healThreshold then
       TargetByName(mainTank)
       CastSpellByName(myHealSpell)
   end
   
   return true
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--
