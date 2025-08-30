--[####################################################################################################]--
--[######################################## START ROGUE CODE! #########################################]--
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
if myClass ~= "Rogue" then return end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local AutoAttack = mb_autoAttack
local CdPrint = mb_cdPrint
local DebuffSunderAmount = mb_debuffSunderAmount
local GetMyInterruptTarget = mb_getMyInterruptTarget
local GetTarget = mb_getTarget
local HasBuffOrDebuff = mb_hasBuffOrDebuff
local HaveInBags = mb_haveInBags
local HealthPct = mb_healthPct
local ImBusy = mb_imBusy
local InCombat = mb_inCombat
local InMeleeRange = mb_inMeleeRange
local ItemNameOfEquippedSlot = mb_itemNameOfEquippedSlot
local MeleeTrinkets = mb_meleeTrinkets
local SelfBuff = mb_selfBuff
local SpellReady = mb_spellReady
local StunnableMob = mb_stunnableMob
local TankTarget = mb_tankTarget
local TrinketOnCD = mb_trinketOnCD

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local Rogue = CreateFrame("Frame", "Rogue")

--[####################################################################################################]--
--[########################################## SETUP Code! #############################################]--
--[####################################################################################################]--

local function RogueSpecc()
    local TalentsIn, TalentsInA

    _, _, _, _, TalentsIn = GetTalentInfo(3, 15)
    if TalentsIn > 0 then
        MB_mySpecc = "Hemo"
        return 
    end

    _, _, _, _, TalentsIn = GetTalentInfo(2, 19)
    if TalentsIn > 0 then
        MB_mySpecc = "AR"
        return 
    end

    MB_mySpecc = nil
end

local function ImprovedExposeCheck()
    local _, _, _, _, TalentsIn = GetTalentInfo(1, 8)
    if TalentsIn == 2 then
		return true
	end
	return false
end

MB_mySpeccList["Rogue"] = RogueSpecc

--[####################################################################################################]--
--[########################################## Single Code! ############################################]--
--[####################################################################################################]--

local function RogueSingle()

	GetTarget()

	if not InCombat("target") then
        return
    end

	if MB_useCooldowns.Active then		
		Rogue:Cooldowns()
	end

	AutoAttack()

	if InCombat("player") and UnitMana("player") <= 40 then		
		if ItemNameOfEquippedSlot(13) == "Renataki\'s Charm of Trickery" and not TrinketOnCD(13) then 
			use(13)

		elseif ItemNameOfEquippedSlot(14) == "Renataki\'s Charm of Trickery" and not TrinketOnCD(14) then 
			use(14)
		end
	end

    if MB_doInterrupt.Active and SpellReady(MB_myInterruptSpell[myClass]) then
        if UnitMana("player") >= 25 then
            if MB_myInterruptTarget then
                GetMyInterruptTarget()
            end

            if ImBusy() then			
                SpellStopCasting() 
            end

            CastSpellByName(MB_myInterruptSpell[myClass])
            CdPrint("Interrupting!")
            MB_doInterrupt.Active = false
            return
        end     
    end

    local aggrox = AceLibrary("Banzai-1.0")
	if aggrox:GetUnitAggroByUnitId("player") then
        if HealthPct("player") < 0.8 and SpellReady("Evasion") then 		
            
            CastSpellByName("Evasion") 
            return
        
        elseif HealthPct("player") < 0.45 and SpellReady("Vanish") then 
		
            CastSpellByName("Vanish") 
            return
        end
	end

	if not InMeleeRange() then
		return
    end

    local cp = GetComboPoints("target")
    if SpellReady("Kidney Shot") and cp >= 3 and StunnableMob() then			
        CastSpellByName("Kidney Shot")
    end

    if SpellReady("Blade Flurry") and HasBuffOrDebuff("Slice and Dice", "player", "buff") then			
        CastSpellByName("Blade Flurry") 
    end

    if (DebuffSunderAmount() == 5 or HasBuffOrDebuff("Expose Armor", "target", "debuff")) 
        and (InMeleeRange() or TankTarget("Ragnaros")) then

        if Instance.IsWorldBoss() then
            Rogue:Cooldowns()
        end

        MeleeTrinkets()
    end

    local hasImprovedEA = ImprovedExposeCheck()
    if not HasBuffOrDebuff("Slice and Dice", "player", "buff") then
        if hasImprovedEA then
            if cp == 2 and HasBuffOrDebuff("Expose Armor", "target", "debuff") then                
                CastSpellByName("Slice and Dice")
            end
        else
            if cp >= 1 then                
                CastSpellByName("Slice and Dice")
            end
        end
    end

    if cp > 4 then
        if hasImprovedEA and Instance.IsWorldBoss() then
            CastSpellByName("Expose Armor")
        else
            CastSpellByName("Eviscerate")
        end
    end

	if MB_mySpecc == "Hemo" then		
		CastSpellByName("Hemorrhage")
        return
    end

	CastSpellByName("Sinister Strike")
end

MB_mySingleList["Rogue"] = RogueSingle

--[####################################################################################################]--
--[########################################## Multi Code! #############################################]--
--[####################################################################################################]--

MB_myMultiList["Rogue"] = RogueSingle

--[####################################################################################################]--
--[########################################### AOE Code! ##############################################]--
--[####################################################################################################]--

MB_myAOEList["Rogue"] = RogueSingle

--[####################################################################################################]--
--[########################################## SETUP Code! #############################################]--
--[####################################################################################################]--

local function RogueSetup()
	if UnitFactionGroup("player") == "Alliance" then
		Rogue:PoisonMainHand()
	end

	Rogue:PoisonOffhand()
end

MB_mySetupList["Rogue"] = RogueSetup

--[####################################################################################################]--
--[########################################## Helper Code! ############################################]--
--[####################################################################################################]--

function Rogue:Cooldowns()
	if ImBusy() or not InCombat("player") then
		return
	end

    if SpellReady("Blade Flurry") and HasBuffOrDebuff("Slice and Dice", "player", "buff") then 
        CastSpellByName("Blade Flurry") 
    end

    SelfBuff("Berserking")
    SelfBuff("Blood Fury") 

    if SpellReady("Adrenaline Rush") then			
        CastSpellByName("Adrenaline Rush")
    end
end

function Rogue:PoisonOffhand()
	if HaveInBags("Instant Poison VI") then
		local has_enchant_main, mx, mc, has_enchant_off = GetWeaponEnchantInfo()
	
		if not has_enchant_off then			
			UseItemByName("Instant Poison VI")
			PickupInventoryItem(17)	
			ClearCursor()
		end
	end
end

function Rogue:PoisonMainHand()
	if HaveInBags("Instant Poison VI") then
		local has_enchant_main, mx, mc, has_enchant_off = GetWeaponEnchantInfo()
		
		if not has_enchant_main then			
			UseItemByName("Instant Poison VI")
			PickupInventoryItem(16)	
			ClearCursor()
		end
	end
end
