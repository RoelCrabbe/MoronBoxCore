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

-- Disable File Loading Completely
if myClass ~= "Warlock" then return end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local AutoWandAttack = mb_autoWandAttack
local CasterTrinkets = mb_casterTrinkets
local CastSpellOrWand = mb_castSpellOrWand
local CdMessage = mb_cdMessage
local CoolDownCast = mb_coolDownCast
local CorruptedTotems = mb_corruptedTotems
local CrowdControl = mb_crowdControl
local CrowdControlledMob = mb_crowdControlledMob
local CrowdControlMCedRaidMemberSkeramFear = mb_crowdControlMCedRaidMemberSkeramFear
local Dead = mb_dead
local DebuffShadowBoltAmount = mb_debuffShadowBoltAmount
local DebuffShadowWeavingAmount = mb_debuffShadowWeavingAmount
local DebuffsToShadowWard = mb_debuffsToShadowWard
local GetAllContainerFreeSlots = mb_getAllContainerFreeSlots
local GetTarget = mb_getTarget
local HasBuffNamed = mb_hasBuffNamed
local HasBuffOrDebuff = mb_hasBuffOrDebuff
local HaveInBags = mb_haveInBags
local HealerTrinkets = mb_healerTrinkets
local HealthPct = mb_healthPct
local ImBusy = mb_imBusy
local InCombat = mb_inCombat
local IsAtRazorgore = mb_isAtRazorgore
local IsAtRazorgorePhase = mb_isAtRazorgorePhase
local IsAtSkeram = mb_isAtSkeram
local IsItemInBagCoolDown = mb_isItemInBagCoolDown
local ItemNameOfEquippedSlot = mb_itemNameOfEquippedSlot
local KnowSpell = mb_knowSpell
local ManaDown = mb_manaDown
local ManaPct = mb_manaPct
local MobsToShadowWard = mb_mobsToShadowWard
local MyClassAlphabeticalOrder = mb_myClassAlphabeticalOrder
local MyNameInTable = mb_myNameInTable
local NumShards = mb_numShards
local ReturnPlayerInRaidFromTable = mb_returnPlayerInRaidFromTable
local SelfBuff = mb_selfBuff
local SmartDrink = mb_smartDrink
local SomeoneInRaidBuffedWith = mb_someoneInRaidBuffedWith
local SpellNumber = mb_spellNumber
local SpellReady = mb_spellReady
local TakeManaPotionAndRunes = mb_takeManaPotionAndRunes
local TankTarget = mb_tankTarget
local TankTargetHealth = mb_tankTargetHealth
local TargetFromSpecificPlayer = mb_targetFromSpecificPlayer
local TrinketOnCD = mb_trinketOnCD

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local Warlock = CreateFrame("Frame", "Warlock")

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

    GetTarget()

	if not MB_mySpecc then		
		CdMessage("My specc is fucked. Defaulting to Corruption.")
		MB_mySpecc = "Corruption"
	end

	if CrowdControl() then 
        return
    end

	if ManaPct("player") < 0.40 and HealthPct("player") > 0.75 then
		CastSpellByName("Life Tap")
		return
	end

	if HasBuffOrDebuff("Hellfire", "player", "buff") then		
		CastSpellByName("Life Tap(Rank 1)")
		return
	end

    if UnitName("target") then
        if MB_myCCTarget and GetRaidTargetIndex("target") == MB_myCCTarget and not HasBuffOrDebuff(MB_myCCSpell[myClass], "target", "debuff") then			
            if CrowdControl() then
                return
            end
        end        

        if CrowdControlledMob() then
            GetTarget()
        end
	end

	if Instance.AQ40() then
		
		if HasBuffOrDebuff("True Fulfillment", "target", "debuff") then
            ClearTarget()
            return
        end

        if IsAtSkeram() and MB_mySkeramBoxStrategyWarlock then
            if not MB_autoToggleSheeps.Active then
                MB_autoToggleSheeps.Active = true
                MB_autoToggleSheeps.Time = GetTime() + 2
                WarlockCounter.Cycle()
            end

			if MyClassAlphabeticalOrder() == MB_buffingCounterWarlock then
				CrowdControlMCedRaidMemberSkeramFear()
			end
		end
    end

	if not InCombat("target") then
        return
    end

	if InCombat("player") then
		Warlock:HealthStone()

		TakeManaPotionAndRunes()

        if KnowSpell("Demonic Sacrifice") and not HasBuffOrDebuff("Touch of Shadow", "player", "buff")then
			Warlock:SumPetAndSac()			
		end	

		if MB_isMoving.Active then			
			Warlock:TapWhileMoving()		
		end

        if ManaDown("player") > 600 then
            Warlock:Cooldowns()
        end
	end

    if Warlock:BossSpecificDPS() then
        return
    end

    if not Instance.IsWorldBoss() and HealthPct("target") < 0.2 and NumShards() < 60 
        and GetAllContainerFreeSlots() >= 10 and not ImBusy() then
        CastSpellByName("Drain Soul(Rank 1)")
        return
    end

    if Instance.IsWorldBoss() then
        local wndSlot = tonumber(MB_attackWandSlot)

        if MB_mySpecc == "Corruption" 
            and UnitMana("player") > MB_classSpellManaCost["Corruption"] 
            and not IsAutoRepeatAction(wndSlot) then
            CoolDownCast("Corruption", 18)
        end
    end

	if MB_mySpecc == "Shadowburn" and MB_raidAssist.Warlock.ShouldBeWhores then		
		Warlock:ShadowBoltWhoring()
	else	
		CastSpellOrWand("Shadow Bolt")

		if not SpellReady("Shadow Bolt") then			
			CastSpellOrWand("Searing Pain")
		end
	end
end

function Warlock:ShadowBoltWhoring()
	local SBstacks = 0
	local SWstacks = 0
	local gonnaWhore = nil

    if ImBusy() then
        return 
    end

    if not UnitExists("target") then
        return
    end

    SBstacks = DebuffShadowBoltAmount()
    SWstacks = DebuffShadowWeavingAmount()
    
    if SWstacks == 5 and SBstacks >= 4 then
        gonnaWhore = true
        CasterTrinkets()
    else
        gonnaWhore = nil
    end
    
    if gonnaWhore and SpellReady("Shadowburn") and NumShards() > 12 then
        CastSpellByName("Shadowburn")
        CastSpellOrWand("Shadow Bolt")
    else
        CastSpellOrWand("Shadow Bolt")
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

	if not HasBuffNamed("Shadow and Frost Reflect", "target") then
        if Instance.AQ40() and IsAtSkeram() and MB_mySkeramBoxStrategyFollow then

            local skeramTankMap = {
                [1] = MB_mySkeramLeftTank,
                [2] = MB_mySkeramMiddleTank,
                [3] = MB_mySkeramRightTank,
                [4] = MB_mySkeramLeftTank,
                [5] = MB_mySkeramMiddleTank,
                [6] = MB_mySkeramRightTank
            }

            local myOrder = MyClassAlphabeticalOrder()
            local tankName = skeramTankMap[myOrder] and ReturnPlayerInRaidFromTable(skeramTankMap[myOrder])

            if tankName and TargetFromSpecificPlayer("The Prophet Skeram", tankName) then
                local targetID = MBID[tankName].."target"

                if not HasBuffOrDebuff("Curse of Tongues", targetID, "debuff") then
                    AssistUnit(MBID[tankName])

                    if ImBusy() then
                        SpellStopCasting()
                    end

                    CastSpellByName("Curse of Tongues")
                    TargetLastTarget()
                    return true
                end
            end

        elseif Instance.BWL() and IsAtRazorgore() and IsAtRazorgorePhase() and MB_myRazorgoreBoxStrategy then

            local razorgoreTankMap = {
                [1] = MB_myRazorgoreRightTank,
                [2] = MB_myRazorgoreLeftTank
            }

            local myOrder = MyClassAlphabeticalOrder()
            local tankName = razorgoreTankMap[myOrder] and ReturnPlayerInRaidFromTable(razorgoreTankMap[myOrder])

            if tankName and TargetFromSpecificPlayer("Death Talon Dragonspawn", tankName) then
                local targetID = MBID[tankName].."target"

                if not HasBuffOrDebuff("Curse of Recklessness", targetID, "debuff") then
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

            local myOrder = MyClassAlphabeticalOrder()
            local assignedCurse = curseAssignments[myOrder]

            if assignedCurse and not HasBuffOrDebuff(assignedCurse, "target", "debuff") then
                CastSpellByName(assignedCurse)
                return true
            end
		end
	end

	if not HasBuffOrDebuff("Shadow Ward", "player", "buff") and SpellReady("Shadow Ward") then
		if MobsToShadowWard() or DebuffsToShadowWard() then
			SelfBuff("Shadow Ward")
			return true
		end
	end

	if HasBuffNamed("Shadow and Frost Reflect", "target") then
		if SpellReady("Soul Fire") and NumShards() > 10 then			
			CastSpellOrWand("Soul Fire") 
		end

		CastSpellOrWand("Immolate")
		return true
	
    elseif HasBuffOrDebuff("Magic Reflection", "target", "buff") then

        if ImBusy() then
            SpellStopCasting()
        end

        AutoWandAttack()
        return true
    end

	if TankTarget("Azuregos") and HasBuffNamed("Magic Shield", "target") then		
		if ImBusy() then 			
			SpellStopCasting()
		end
		
		SelfBuff("Frost Ward")
		return true
	end

	if Instance.AQ40() then		
		if UnitName("target") == "Emperor Vek\'lor" and MyNameInTable(MB_myTwinsWarlockTank) then
			
            SelfBuff("Shadow Ward")
			Warlock:SaveShardShadowBurn(3)
			
			if HealthPct("player") < 0.25 and SpellReady("Death Coil") then				
				CastSpellByName("Death Coil")
			end
			
			CastSpellByName("Searing Pain")
			return true
		
        elseif UnitName("target") == "Obsidian Eradicator" and ManaPct("target") > 0.7 and not ImBusy() then
			
            CastSpellByName("Drain Mana")			
			return true
        
        elseif UnitName("target") == "Spawn of Fankriss" then	

			Warlock:SaveShardShadowBurn(9)
			CastSpellOrWand("Shadow Bolt")
			return true
		end

	elseif Instance.BWL() and CorruptedTotems() and not Dead("target") then

		Warlock:SaveShardShadowBurn(12)
		CastSpellOrWand("Searing Pain")
		return true

	elseif Instance.MC() and TankTarget("Shazzrah") then
			
        if not SpellReady("Shadow Bolt") then
            CastSpellOrWand("Immolate")
            return true
        end

	elseif Instance.ONY() and TankTarget("Onyxia") then

        if MB_isMoving.Active then			
			CoolDownCast("Corruption", 18)

            if TankTargetHealth() <= 0.65 and TankTargetHealth() >= 0.4 then
                Warlock:SaveShardShadowBurn(12)
            end
		end

    elseif Instance.ZG() then

		if HasBuffOrDebuff("Delusions of Jin\'do", "player", "debuff") then
			if UnitName("target") == "Shade of Jin\'do" and not Dead("target") then
                Warlock:SaveShardShadowBurn(12)					
				CastSpellOrWand("Searing Pain") 
				return true
			end
		end

		if (UnitName("target") == "Powerful Healing Ward" or UnitName("target") == "Brain Wash Totem") and not Dead("target") then
            Warlock:SaveShardShadowBurn(12)
			CastSpellOrWand("Searing Pain")
			return true
		end

	elseif Instance.AQ20() then

		if TankTarget("Moam") and ManaPct("target") > 0.75 and not ImBusy() then
			CastSpellByName("Drain Mana") 			
		end

        if TankTarget("Ossirian the Unscarred") then
            if HasBuffOrDebuff("Fire Weakness", "target", "debuff") then
            
                if SpellReady("Soul Fire") and NumShards() > 10 then 
					CastSpellOrWand("Soul Fire")
				end

				CastSpellOrWand("Immolate")
                return true
            elseif HasBuffOrDebuff("Shadow Weakness", "target", "debuff") then

				CastSpellOrWand("Shadow Bolt")
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

    GetTarget()

	if not MB_mySpecc then		
		CdMessage("My specc is fucked. Defaulting to Corruption.")
		MB_mySpecc = "Corruption"
	end

	if UnitMana("player") < 1250 and not ImBusy() then
		CastSpellByName("Life Tap")
		return
	end

	if InCombat("player") then
		Warlock:HealthStone()

		TakeManaPotionAndRunes()

        if ManaDown("player") > 600 then
            Warlock:Cooldowns()
        end
	end

    if not HasBuffOrDebuff("Hellfire", "player", "buff") then
		CastSpellByName("Hellfire") 
	end
end

MB_myAOEList["Warlock"] = WarlockAOE

--[####################################################################################################]--
--[########################################## SETUP Code! #############################################]--
--[####################################################################################################]--

local function WarlockSetup()

	if UnitMana("player") < 3060 and HasBuffNamed("Drink", "player") then
		return
	end

	if IsAltKeyDown() then
        if not MB_autoBuff.Active then
            MB_autoBuff.Active = true
            MB_autoBuff.Time = GetTime() + 3
            WarlockCounter.Cycle()
        end

		if MyClassAlphabeticalOrder() == MB_buffingCounterWarlock then
			Warlock:SoulStone()
		end
	end

	SelfBuff("Demon Armor")
	
	if KnowSpell("Demonic Sacrifice") then
		if not HasBuffOrDebuff("Touch of Shadow", "player", "buff") then			
			Warlock:SumPetAndSac()
		end
	else
		if not HavePet() then			
			CastSpellByName("Summon Imp")
		end
	end	

	Warlock:CreateHealthStone()

	if not InCombat("player") and ManaPct("player") < 0.20 and not HasBuffNamed("Drink", "player") then
		SmartDrink()
	end
end

MB_mySetupList["Warlock"] = WarlockSetup

--[####################################################################################################]--
--[######################################### PRECAST Code! ############################################]--
--[####################################################################################################]--

local function WarlockPreCast()
	for k, trinket in pairs(MB_casterTrinkets) do
		if ItemNameOfEquippedSlot(13) == trinket and not TrinketOnCD(13) then 
			use(13) 
		end

		if ItemNameOfEquippedSlot(14) == trinket and not TrinketOnCD(14) then 
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
	if ImBusy() or not InCombat("player") then
		return
	end

    SelfBuff("Berserking") 

    HealerTrinkets()
	CasterTrinkets()
end

function Warlock:HealthStone()
	if ImBusy() or not InCombat("player") then
		return
	end

	if HealthPct("player") > 0.15 then
		return
	end

    if not HaveInBags("Major Healthstone") then
		return
	end

    if IsItemInBagCoolDown("Major Healthstone") then
		return
	end

	SpellStopCasting()
	UseItemByName("Major Healthstone")
end

function Warlock:SumPetAndSac()
	if HasBuffOrDebuff("Touch of Shadow", "player", "buff") then
		return
	end

	if UnitCreatureFamily("pet") == "Succubus" and KnowSpell("Demonic Sacrifice") then
		CastSpellByName("Demonic Sacrifice")
		return
	end

	if NumShards() == 0 then
		return
	end

	if KnowSpell("Summon Succubus") and KnowSpell("Fel Domination") and SpellReady("Fel Domination") then
		CastSpellByName("Fel Domination")
		return
	end

	if KnowSpell("Summon Succubus") then
		CastSpellByName("Summon Succubus")
	end
end

function Warlock:TapWhileMoving()
	if HealthPct("player") < 0.40 or UnitMana("player") == UnitManaMax("player") then
		return
	end

	if ManaPct("player") < 0.80 and HealthPct("player") > 0.55 then
		CastSpellByName("Life Tap")
	end
end

function Warlock:SaveShardShadowBurn(shardsToSave)
	shardsToSave = shardsToSave or 0

	if not SpellReady("Shadowburn") or NumShards() <= shardsToSave then
		return
	end

	CastSpellByName("Shadowburn")
end

function Warlock:SoulStone()
	
    if HasBuffNamed("Drink", "player") or ImBusy() then
        return
    end

    Warlock:CreateSoulStone()

    if IsItemInBagCoolDown("Major Soulstone") then
        return
    end

    if not MB_autoBuff.Active then
        MB_autoBuff.Active = true
        MB_autoBuff.Time = GetTime() + 6
        WarlockCounter.Cycle()
    end
    
    if not SomeoneInRaidBuffedWith("Soulstone") then
        if MyClassAlphabeticalOrder() == MB_buffingCounterWarlock then 
            for i = 1, TableLength(MB_classList["Priest"]) do
                id = MBID[MB_classList["Priest"][i]]
                name = MB_classList["Priest"][i]

                if not HasBuffOrDebuff("Soulstone", id, "buff") and HaveInBags("Major Soulstone") then
                    CdMessage("Soulstoning "..GetColors(name))
                    
                    TargetUnit(id)
                    UseItemByName("Major Soulstone")
                    ClearCursor()
                    return
                end
            end

            for i = 1, TableLength(MB_classList["Shaman"]) do
                id = MBID[MB_classList["Shaman"][i]]
                name = MB_classList["Shaman"][i]

                if not HasBuffOrDebuff("Soulstone", id, "buff") and HaveInBags("Major Soulstone") then
                    CdMessage("Soulstoning "..GetColors(name))
                    
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
	if NumShards() < 2
		or GetAllContainerFreeSlots() < 1
		or InCombat("player")
		or HaveInBags("Major Healthstone") then
		return
	end

	CastSpellByName("Create Healthstone (Major)")
end

function Warlock:CreateSoulStone()
	local spellId = SpellNumber("Create Soulstone.*Major")

	if not spellId
		or NumShards() < 1
		or HaveInBags("Major Soulstone") then
		return
	end

	CastSpell(spellId, BOOKTYPE_SPELL)
end
