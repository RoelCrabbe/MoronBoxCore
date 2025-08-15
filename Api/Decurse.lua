--[####################################################################################################]--
--[############################################ Decurse ! #############################################]--
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

	if not MBD.Session.Spells.HasSpells then 
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