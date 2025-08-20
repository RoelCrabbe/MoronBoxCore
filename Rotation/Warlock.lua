--[####################################################################################################]--
--[####################################### START WARLOCK CODE! ########################################]--
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

local Warlock = CreateFrame("Frame", "Warlock")
if myClass ~= "Warlock" then
    return
end

local WarlockCounter = {
    Cycle = function()
        MB_buffingCounterWarlock = (MB_buffingCounterWarlock >= TableLength(MB_classList["Warlock"]))
                                and 1 or (MB_buffingCounterWarlock + 1)
    end
}

local function HavePet()
	return UnitHealth("pet") > 0
end

--[####################################################################################################]--
--[########################################## SETUP Code! #############################################]--
--[####################################################################################################]--

local function WarlockSpecc()
    local TalentsIn, TalentsInA

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

    MB_mySpecc = nil
end

MB_mySpeccList["Warlock"] = WarlockSpecc

--[####################################################################################################]--
--[########################################## Single Code! ############################################]--
--[####################################################################################################]--

local function WarlockSingle()

    mb_getTarget()

	if not MB_mySpecc then		
		mb_cdMessage("My specc is fucked. Defaulting to Corruption.")
		MB_mySpecc = "Corruption"
	end

	if mb_crowdControl() then 
        return
    end

	if mb_manaPct("player") < 0.40 and mb_healthPct("player") > 0.75 then
		CastSpellByName("Life Tap")
		return
	end

	if mb_hasBuffOrDebuff("Hellfire", "player", "buff") then		
		CastSpellByName("Life Tap(Rank 1)")
		return
	end

    if UnitName("target") then
        if MB_myCCTarget and GetRaidTargetIndex("target") == MB_myCCTarget and not mb_hasBuffOrDebuff(MB_myCCSpell[myClass], "target", "debuff") then			
            if mb_crowdControl() then
                return
            end
        end        

        if mb_crowdControlledMob() then
            mb_getTarget()
        end
	end

	if Instance.AQ40 then
		
		if mb_hasBuffOrDebuff("True Fulfillment", "target", "debuff") then
            ClearTarget()
            return
        end

        if mb_isAtSkeram() and MB_mySkeramBoxStrategyWarlock then
            if not MB_autoToggleSheeps.Active then
                MB_autoToggleSheeps.Active = true
                MB_autoToggleSheeps.Time = GetTime() + 2
                WarlockCounter.Cycle()
            end

			if mb_myClassAlphabeticalOrder() == MB_buffingCounterWarlock then
				mb_crowdControlMCedRaidMemberSkeramFear()
			end
		end
    end

	if not mb_inCombat("target") then
        return
    end

	if mb_inCombat("player") then
		Warlock:HealthStone()

		mb_takeManaPotionAndRune()
		mb_takeManaPotionIfBelowManaPotMana()
		mb_takeManaPotionIfBelowManaPotManaInRazorgoreRoom()

        if mb_knowSpell("Demonic Sacrifice") and not mb_hasBuffOrDebuff("Touch of Shadow", "player", "buff")then
			Warlock:SumPetAndSac()			
		end	

		if MB_isMoving.Active then			
			Warlock:TapWhileMoving()		
		end

        if mb_manaDown("player") > 600 then
            Warlock:Cooldowns()
        end
	end

    if Warlock:BossSpecificDPS() then
        return
    end

    if not Instance.IsWorldBoss() and mb_healthPct("target") < 0.2 and mb_numShards() < 60 
        and mb_getAllContainerFreeSlots() >= 10 and not mb_imBusy() then
        CastSpellByName("Drain Soul(Rank 1)")
        return
    end

    if Instance.IsWorldBoss() then
        local wndSlot = tonumber(MB_attackWandSlot)

        if MB_mySpecc == "Corruption" 
            and UnitMana("player") > MB_classSpellManaCost["Corruption"] 
            and not IsAutoRepeatAction(wndSlot) then
            mb_coolDownCast("Corruption", 18)
        end
    end

	if MB_mySpecc == "Shadowburn" and MB_raidAssist.Warlock.ShouldBeWhores then		
		Warlock:ShadowBoltWhoring()
	else	
		mb_castSpellOrWand("Shadow Bolt")

		if not mb_spellReady("Shadow Bolt") then			
			mb_castSpellOrWand("Searing Pain")
		end
	end
end

function Warlock:ShadowBoltWhoring()
	local SBstacks = 0
	local SWstacks = 0
	local gonnaWhore = nil

    if mb_imBusy() then
        return 
    end

    if not UnitExists("target") then
        return
    end

    SBstacks = mb_debuffShadowBoltAmount()
    SWstacks = mb_debuffShadowWeavingAmount()
    
    if SWstacks == 5 and SBstacks >= 4 then
        gonnaWhore = true
        mb_casterTrinkets()
    else
        gonnaWhore = nil
    end
    
    if gonnaWhore and mb_spellReady("Shadowburn") and mb_numShards() > 12 then
        CastSpellByName("Shadowburn")
        mb_castSpellOrWand("Shadow Bolt")
    else
        mb_castSpellOrWand("Shadow Bolt")
    end
end

function Warlock:BossSpecificDPS()

	if UnitName("target") == "Emperor Vek\'nilash" then
        return true
    end

	if UnitName("target") == "Chromaggus" then
        CastSpellByName("Curse of Recklessness")
        return true 
    end

	if not mb_hasBuffNamed("Shadow and Frost Reflect", "target") then
        if Instance.AQ40 and mb_isAtSkeram() and MB_mySkeramBoxStrategyFollow then

            local skeramTankMap = {
                [1] = MB_mySkeramLeftTank,
                [2] = MB_mySkeramMiddleTank,
                [3] = MB_mySkeramRightTank,
                [4] = MB_mySkeramLeftTank,
                [5] = MB_mySkeramMiddleTank,
                [6] = MB_mySkeramRightTank
            }

            local myOrder = mb_myClassAlphabeticalOrder()
            local tankName = skeramTankMap[myOrder] and mb_returnPlayerInRaidFromTable(skeramTankMap[myOrder])

            if tankName and mb_targetFromSpecificPlayer("The Prophet Skeram", tankName) then
                local targetID = MBID[tankName].."target"

                if not mb_hasBuffOrDebuff("Curse of Tongues", targetID, "debuff") then
                    AssistUnit(MBID[tankName])

                    if mb_imBusy() then
                        SpellStopCasting()
                    end

                    CastSpellByName("Curse of Tongues")
                    TargetLastTarget()
                    return true
                end
            end

        elseif Instance.BWL and mb_isAtRazorgore() and mb_isAtRazorgorePhase() and MB_myRazorgoreBoxStrategy then

            local razorgoreTankMap = {
                [1] = MB_myRazorgoreRightTank,
                [2] = MB_myRazorgoreLeftTank
            }

            local myOrder = mb_myClassAlphabeticalOrder()
            local tankName = razorgoreTankMap[myOrder] and mb_returnPlayerInRaidFromTable(razorgoreTankMap[myOrder])

            if tankName and mb_targetFromSpecificPlayer("Death Talon Dragonspawn", tankName) then
                local targetID = MBID[tankName].."target"

                if not mb_hasBuffOrDebuff("Curse of Recklessness", targetID, "debuff") then
                    AssistUnit(MBID[tankName])
                    CastSpellByName("Curse of Recklessness")
                    TargetLastTarget()
                    return true
                end
            end          
        else
            local curseAssignments = {
                [1] = "Curse of Recklessness",
                [2] = "Curse of the Elements",
                [3] = "Curse of Shadow",
                [4] = "Curse of the Elements",
                [5] = "Curse of Recklessness",
                [6] = "Curse of Shadow"
            }

            local myOrder = mb_myClassAlphabeticalOrder()
            local assignedCurse = curseAssignments[myOrder]

            if assignedCurse and not mb_hasBuffOrDebuff(assignedCurse, "target", "debuff") then
                CastSpellByName(assignedCurse)
                return true
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
		
		mb_selfBuff("Frost Ward")
		return true
	end

	if Instance.AQ40 then		
		if UnitName("target") == "Emperor Vek\'lor" and mb_myNameInTable(MB_myTwinsWarlockTank) then
			
            mb_selfBuff("Shadow Ward")
			Warlock:SaveShardShadowBurn(3)
			
			if mb_healthPct("player") < 0.25 and mb_spellReady("Death Coil") then				
				CastSpellByName("Death Coil")
			end
			
			CastSpellByName("Searing Pain")
			return true
		
        elseif UnitName("target") == "Obsidian Eradicator" and mb_manaPct("target") > 0.7 and not mb_imBusy() then
			
            CastSpellByName("Drain Mana")			
			return true
        
        elseif UnitName("target") == "Spawn of Fankriss" then	

			Warlock:SaveShardShadowBurn(9)
			mb_castSpellOrWand("Shadow Bolt")
			return true
		end

	elseif Instance.BWL and mb_corruptedTotems() and not mb_dead("target") then

		Warlock:SaveShardShadowBurn(12)
		mb_castSpellOrWand("Searing Pain")
		return true

	elseif Instance.MC and mb_tankTarget("Shazzrah") then
			
        if not mb_spellReady("Shadow Bolt") then
            mb_castSpellOrWand("Immolate")
            return true
        end

	elseif Instance.ONY and mb_tankTarget("Onyxia") then

        if MB_isMoving.Active then			
			mb_coolDownCast("Corruption", 18)

            if mb_tankTargetHealth() <= 0.65 and mb_tankTargetHealth() >= 0.4 then
                Warlock:SaveShardShadowBurn(12)
            end
		end

    elseif Instance.ZG then

		if mb_hasBuffOrDebuff("Delusions of Jin\'do", "player", "debuff") then
			if UnitName("target") == "Shade of Jin\'do" and not mb_dead("target") then
                Warlock:SaveShardShadowBurn(12)					
				mb_castSpellOrWand("Searing Pain") 
				return true
			end
		end

		if (UnitName("target") == "Powerful Healing Ward" or UnitName("target") == "Brain Wash Totem") and not mb_dead("target") then
            Warlock:SaveShardShadowBurn(12)
			mb_castSpellOrWand("Searing Pain")
			return true
		end

	elseif Instance.AQ20 then

		if mb_tankTarget("Moam") and mb_manaPct("target") > 0.75 and not mb_imBusy() then
			CastSpellByName("Drain Mana") 			
		end

        if mb_tankTarget("Ossirian the Unscarred") then
            if mb_hasBuffOrDebuff("Fire Weakness", "target", "debuff") then
            
                if mb_spellReady("Soul Fire") and mb_numShards() > 10 then 
					mb_castSpellOrWand("Soul Fire")
				end

				mb_castSpellOrWand("Immolate")
                return true
            elseif mb_hasBuffOrDebuff("Shadow Weakness", "target", "debuff") then

				mb_castSpellOrWand("Shadow Bolt")
                return true
            end
        end
	end

	return false
end

MB_mySingleList["Warlock"] = WarlockSingle

--[####################################################################################################]--
--[########################################## Multi Code! #############################################]--
--[####################################################################################################]--

MB_myMultiList["Warlock"] = WarlockSingle

--[####################################################################################################]--
--[########################################### AOE Code! ##############################################]--
--[####################################################################################################]--

local function WarlockAOE()

    mb_getTarget()

	if not MB_mySpecc then		
		mb_cdMessage("My specc is fucked. Defaulting to Corruption.")
		MB_mySpecc = "Corruption"
	end

	if UnitMana("player") < 1250 and not mb_imBusy() then
		CastSpellByName("Life Tap")
		return
	end

	if mb_inCombat("player") then
		Warlock:HealthStone()

		mb_takeManaPotionAndRune()
		mb_takeManaPotionIfBelowManaPotMana()
		mb_takeManaPotionIfBelowManaPotManaInRazorgoreRoom()

        if mb_manaDown("player") > 600 then
            Warlock:Cooldowns()
        end
	end

    if not mb_hasBuffOrDebuff("Hellfire", "player", "buff") then
		CastSpellByName("Hellfire") 
	end
end

MB_myAOEList["Warlock"] = WarlockAOE

--[####################################################################################################]--
--[########################################## SETUP Code! #############################################]--
--[####################################################################################################]--

local function WarlockSetup()

	if UnitMana("player") < 3060 and mb_hasBuffNamed("Drink", "player") then
		return
	end

	if IsAltKeyDown() then
        if not MB_autoBuff.Active then
            MB_autoBuff.Active = true
            MB_autoBuff.Time = GetTime() + 3
            WarlockCounter.Cycle()
        end

		if mb_myClassAlphabeticalOrder() == MB_buffingCounterWarlock then
			Warlock:SoulStone()
		end
	end

	mb_selfBuff("Demon Armor")
	
	if mb_knowSpell("Demonic Sacrifice") then
		if not mb_hasBuffOrDebuff("Touch of Shadow", "player", "buff") then			
			Warlock:SumPetAndSac()
		end
	else
		if not HavePet() then			
			CastSpellByName("Summon Imp")
		end
	end	

	Warlock:CreateHealthStone()

	if not mb_inCombat("player") and mb_manaPct("player") < 0.20 and not mb_hasBuffNamed("Drink", "player") then
		mb_smartDrink()
	end
end

MB_mySetupList["Warlock"] = WarlockSetup

--[####################################################################################################]--
--[######################################### PRECAST Code! ############################################]--
--[####################################################################################################]--

local function WarlockPreCast()
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

MB_myPreCastList["Warlock"] = WarlockPreCast

--[####################################################################################################]--
--[########################################## Helper Code! ############################################]--
--[####################################################################################################]--

function Warlock:Cooldowns()
	if mb_imBusy() or not mb_inCombat("player") then
		return
	end

    mb_selfBuff("Berserking") 

    mb_healerTrinkets()
	mb_casterTrinkets()
end

function Warlock:HealthStone()
	if mb_imBusy() or not mb_inCombat("player") then
		return
	end

	if mb_healthPct("player") > 0.15 then
		return
	end

    if not mb_haveInBags("Major Healthstone") then
		return
	end

    if mb_isItemInBagCoolDown("Major Healthstone") then
		return
	end

	SpellStopCasting()
	UseItemByName("Major Healthstone")
end

function Warlock:SumPetAndSac()
	if mb_hasBuffOrDebuff("Touch of Shadow", "player", "buff") then
		return
	end

	if UnitCreatureFamily("pet") == "Succubus" and mb_knowSpell("Demonic Sacrifice") then
		CastSpellByName("Demonic Sacrifice")
		return
	end

	if mb_numShards() == 0 then
		return
	end

	if mb_knowSpell("Summon Succubus") and mb_knowSpell("Fel Domination") and mb_spellReady("Fel Domination") then
		CastSpellByName("Fel Domination")
		return
	end

	if mb_knowSpell("Summon Succubus") then
		CastSpellByName("Summon Succubus")
	end
end

function Warlock:TapWhileMoving()
	if mb_healthPct("player") < 0.40 or UnitMana("player") == UnitManaMax("player") then
		return
	end

	if mb_manaPct("player") < 0.80 and mb_healthPct("player") > 0.55 then
		CastSpellByName("Life Tap")
	end
end

function Warlock:SaveShardShadowBurn(shardsToSave)
	shardsToSave = shardsToSave or 0

	if not mb_spellReady("Shadowburn") or mb_numShards() <= shardsToSave then
		return
	end

	CastSpellByName("Shadowburn")
end

function Warlock:SoulStone()
	
    if mb_hasBuffNamed("Drink", "player") or mb_imBusy() then
        return
    end

    Warlock:CreateSoulStone()

    if mb_isItemInBagCoolDown("Major Soulstone") then
        return
    end

    if not MB_autoBuff.Active then
        MB_autoBuff.Active = true
        MB_autoBuff.Time = GetTime() + 6
        WarlockCounter.Cycle()
    end
    
    if not mb_someoneInRaidBuffedWith("Soulstone") then
        if mb_myClassAlphabeticalOrder() == MB_buffingCounterWarlock then 
            for i = 1, TableLength(MB_classList["Priest"]) do
                id = MBID[MB_classList["Priest"][i]]
                name = MB_classList["Priest"][i]

                if not mb_hasBuffOrDebuff("Soulstone", id, "buff") and mb_haveInBags("Major Soulstone") then
                    mb_cdMessage("Soulstoning "..GetColors(name))
                    
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
                    mb_cdMessage("Soulstoning "..GetColors(name))
                    
                    TargetUnit(id)
                    UseItemByName("Major Soulstone")
                    ClearCursor()
                    return
                end
            end
        end
    end
end

function Warlock:CreateHealthStone()
	if mb_numShards() < 2
		or mb_getAllContainerFreeSlots() < 1
		or mb_inCombat("player")
		or mb_haveInBags("Major Healthstone") then
		return
	end

	CastSpellByName("Create Healthstone (Major)")
end

function Warlock:CreateSoulStone()
	local spellId = mb_spellNumber("Create Soulstone.*Major")

	if not spellId
		or mb_numShards() < 1
		or mb_haveInBags("Major Soulstone") then
		return
	end

	CastSpell(spellId, BOOKTYPE_SPELL)
end