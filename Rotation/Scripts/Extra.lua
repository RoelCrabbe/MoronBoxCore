--[####################################################################################################]--
--[####################################### START SINGLE CODE! #########################################]--
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

local CancelDruidShapeShift = mb_cancelDruidShapeShift
local CdMessage = mb_cdMessage
local CdPrint = mb_cdPrint
local CleanseTotem = mb_cleanseTotem
local CoolDownCast = mb_coolDownCast
local Dead = mb_dead
local FearBreak = mb_fearBreak
local GetLink = mb_getLink
local GetMyInterruptTarget = mb_getMyInterruptTarget
local GetRaidIndexForPlayerName = mb_getRaidIndexForPlayerName
local HasBuffOrDebuff = mb_hasBuffOrDebuff
local ImBusy = mb_imBusy
local ImFocus = mb_imFocus
local ImHealer = mb_imHealer
local ImRangedDPS = mb_imRangedDPS
local ImTank = mb_imTank
local InCombat = mb_inCombat
local InterruptSpell = mb_interruptSpell
local IsDruidShapeShifted = mb_isDruidShapeShifted
local IsInGroup = mb_isInGroup
local IsInRaid = mb_isInRaid
local KnowSpell = mb_knowSpell
local MandokirGaze = mb_mandokirGaze
local ManualTaunt = mb_manualTaunt
local MountUp = mb_mountUp
local PartyIsDiseased = mb_partyIsDiseased
local PartyIsPoisoned = mb_partyIsPoisoned
local PromoteEveryone = mb_promoteEveryone
local RequestInviteSummon = mb_requestInviteSummon
local Ress = mb_ress
local ReturnEquippedItemType = mb_returnEquippedItemType
local SelfBuff = mb_selfBuff
local SmartDrink = mb_smartDrink
local SpellExists = mb_spellExists
local SpellReady = mb_spellReady
local TankShoot = mb_tankShoot
local TankTarget = mb_tankTarget
local UnitInRange = mb_unitInRange

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local PlayerMounts = {
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

--[####################################################################################################]--
--[###################################### Some Tank Macros! ###########################################]--
--[####################################################################################################]--

function mb_tankShoot()
	if not MB_raidLeader and (TableLength(MBID) > 1) then 
        CdPrint("WARNING: You have not chosen a raid leader")
    end

	if Dead("player") then
		return
	end

	if Instance.ZG() and TankTarget("Bloodlord Mandokir") then
        if MandokirGaze() then
            return
        end
	end

	if not ImTank() then
		if myClass == "Shaman" then
			mb_dropTotems()
		end
		return
	end

	local rangedWep = ReturnEquippedItemType(18)
	if not rangedWep then
		return
	end

	if not SpellExists("Shoot "..rangedWep) then
		return
	end

	if MB_myOTTarget or ImFocus() then		
		CastSpellByName("Shoot "..rangedWep)
	end	
end

function mb_manualTaunt()
	if not MB_raidLeader and (TableLength(MBID) > 1) then 
        CdPrint("WARNING: You have not chosen a raid leader")
    end

	if Dead("player") then
		return
	end

    if Instance.ZG() and TankTarget("Bloodlord Mandokir") then
        if MandokirGaze() then
            return
        end
	end

	if not ImTank() then
		return
	end

	if myClass == "Warrior" and SpellReady("Taunt") then			
		CastSpellByName("Taunt")

	elseif myClass == "Druid" and SpellReady("Growl") then
		CastSpellByName("Growl")
	end
end

--[####################################################################################################]--
--[########################################## Ress Macros! ############################################]--
--[####################################################################################################]--

function mb_ress()
	if ImHealer() then
		if UnitMana("player") < 1368 and myClass == "Shaman" then 			
			SmartDrink()
		end

		if UnitMana("player") < 1090 and myClass == "Priest" then 			
			SmartDrink()
		end

		if UnitMana("player") < 1209 and myClass == "Paladin" then			
			SmartDrink()
		end

		MBH_Resurrection()
	end

	if ImRangedDPS() then		
		SmartDrink()
	end
end

--[####################################################################################################]--
--[######################################## Inviting Party! ###########################################]--
--[####################################################################################################]--

function mb_disbandRaid()
	if UnitInRaid("player") then
		for i = 1, 40 do
			local _, rank = GetRaidRosterInfo(i);
			if rank ~= 2 then
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

function mb_requestInviteSummon()
	if IsAltKeyDown() and not IsShiftKeyDown() and not IsControlKeyDown() then		
		if MB_raidInviter == myName then			
			SetLootMethod("freeforall", myName)
			
			if GetNumPartyMembers() > 0 and not UnitInRaid("player") then 				
				ConvertToRaid()
			end
			return
		end

		if MB_raidInviter then
			if not (IsInRaid(MB_raidInviter) or IsInGroup(MB_raidInviter)) then			
				mb_disbandRaid()
				SendChatMessage(MB_inviteMessage, "WHISPER", DEFAULT_CHAT_FRAME.editBox.languageID, MB_raidInviter);
			end
		end
		return
	end

	if IsShiftKeyDown() and not IsAltKeyDown() and not IsControlKeyDown() then		
		if MB_raidLeader then
			if UnitInRaid("player") then				
				if not UnitInRange("raid"..GetRaidIndexForPlayerName(MB_raidLeader)) then					
					CdMessage("123", 10)
					return 
				end
			else
				if not UnitInRange("party"..GetRaidIndexForPlayerName(MB_raidLeader)) then					
					CdMessage("123", 10)
					return 
				end
			end
		end
	end

	if IsControlKeyDown() and not IsShiftKeyDown() and not IsAltKeyDown() then		
		PromoteEveryone()
		return 
	end
end

--[####################################################################################################]--
--[##################################### Interrupt Functions! #########################################]--
--[####################################################################################################]--

function mb_interruptSpell()	
	if ImTank() then
        return
    end

	if not SpellReady(MB_myInterruptSpell[myClass]) then
        return
    end

    GetMyInterruptTarget()

    if myClass == "Warrior" then   
        if UnitMana("player") >= 10 then                
            CastSpellByName(MB_myInterruptSpell[myClass])
        end

    elseif myClass == "Shaman" then
        if ImBusy() then            
            SpellStopCasting()
        end

        CastSpellByName(MB_myInterruptSpell[myClass].."(Rank 1)")

    elseif myClass == "Rogue" then
        if UnitMana("player") >= 25 then            
            CastSpellByName(MB_myInterruptSpell[myClass])
        end

    elseif myClass == "Mage" then
        if ImBusy() then            
            SpellStopCasting()
        end

        CastSpellByName(MB_myInterruptSpell[myClass])
    end
end

--[####################################################################################################]--
--[######################################## Cleans Totems! ############################################]--
--[####################################################################################################]--

function mb_cleanseTotem()
	if myClass == "Shaman" then
		if PartyIsPoisoned() then 			
			if ImBusy() then				
				SpellStopCasting()
				return
			end

			CastSpellByName("Poison Cleansing Totem")
		elseif PartyIsDiseased() then			
			if ImBusy() then				
				SpellStopCasting()
				return
			end

			CastSpellByName("Disease Cleansing Totem")
		end
	end
end

--[####################################################################################################]--
--[######################################### Break Fears! #############################################]--
--[####################################################################################################]--

function mb_fearBreak()	
	if IsShiftKeyDown() then 		
		CleanseTotem()
		return 
	end

	if myClass == "Warrior" then
		if SpellReady("Berserker Rage") then		
			SelfBuff("Berserker Stance")
			CastSpellByName("Berserker Rage")
			return
		end
	end

	if myClass == "Shaman" then		
		if ImBusy() then				
			SpellStopCasting()
			return
		end

		CoolDownCast("Tremor Totem", 15)
	end

	if KnowSpell("Will of the Forsaken") then
		if myClass == "Warrior" then
			if HasBuffOrDebuff("Berserker Rage", "player", "buff") then
				CdPrint("WARNING: You already have Berserker Rage!", 15)
				return
			end

			if SpellReady("Will of the Forsaken") and not SpellReady("Berserker Rage") then		
				CastSpellByName("Will of the Forsaken")
			end
		else
			if SpellReady("Will of the Forsaken") then		
				CastSpellByName("Will of the Forsaken")
			end
		end
	end
end

--[####################################################################################################]--
--[########################################## Mount Ups! ##############################################]--
--[####################################################################################################]--

function mb_mountUp()
	if myClass == "Druid" and IsDruidShapeShifted() and not InCombat("player") then 
		CancelDruidShapeShift() 
	end

	if ImBusy() then
        return
    end

	if Instance.AQ40() then		
		use(GetLink("Resonating"))
		return
	end
		
	for _, mount in PlayerMounts do
		use(GetLink(mount))
	end

	if myClass == "Warlock" and KnowSpell("Summon Dreadsteed") then		
		CastSpellByName("Summon Dreadsteed")
		return
	end

	if myClass == "Paladin" and KnowSpell("Summon Charger") then		
		CastSpellByName("Summon Charger")
		return
	end	

	CastSpellByName("Summon Felsteed")
	CastSpellByName("Summon Warhorse")	
end
