--[####################################################################################################]--
--[############################################ Decurse ! #############################################]--
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

function mb_decurse()
	if Instance.ZG then		
		if mb_isAtJindo() and (myClass == "Mage" or myClass == "Druid") then
			return false
		end

	elseif Instance.BWL then
		if mb_tankTarget("Chromaggus") and MB_myAssignedHealTarget then
			return false
		end
	end

	if (mb_isAtSkeram() or mb_tankTarget("Loatheb") or mb_tankTarget("Spore")
        or mb_tankTarget("Vaelastrasz the Corrupt") or mb_tankTarget("Princess Huhuran")
        or mb_isAtGrobbulus() or mb_tankTarget("Garr") or mb_tankTarget("Firesworn")
        or mb_tankTarget("Spore") or mb_tankTarget("Fungal Spore") or mb_tankTarget("Anubisath Guardian")) then
		return false
	end

	if not (MBD or MBD.Session.Spells.HasSpells) then 
		return false 
	end

	if UnitMana("player") < 320 then
		return false
	end

	if mb_imBusy() then
		return false
	end
	
	if (Decurse_wait == nil or GetTime() - Decurse_wait > 0.15) then
		Decurse_wait = GetTime()

		local y, x
		if UnitInRaid("player") then
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