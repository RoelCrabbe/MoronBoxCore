--[####################################################################################################]--
--[####################################### START HUNTER CODE! #########################################]--
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
if myClass ~= "Hunter" then return end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local AutoAttack = mb_autoAttack
local AutoRangedAttack = mb_autoRangedAttack
local CdMessage = mb_cdMessage
local CoolDownCast = mb_coolDownCast
local GetTarget = mb_getTarget
local HasBuffNamed = mb_hasBuffNamed
local HasBuffOrDebuff = mb_hasBuffOrDebuff
local HealthPct = mb_healthPct
local ImBusy = mb_imBusy
local InCombat = mb_inCombat
local InMeleeRange = mb_inMeleeRange
local IsAtNefarianPhase = mb_isAtNefarianPhase
local IsFireImmune = mb_isFireImmune
local ItemNameOfEquippedSlot = mb_itemNameOfEquippedSlot
local ManaDown = mb_manaDown
local MeleeTrinkets = mb_meleeTrinkets
local SelfBuff = mb_selfBuff
local SpellReady = mb_spellReady
local TakeManaPotionAndRune = mb_takeManaPotionAndRune
local TakeManaPotionIfBelowManaPotMana = mb_takeManaPotionIfBelowManaPotMana
local TakeManaPotionIfBelowManaPotManaInRazorgoreRoom = mb_takeManaPotionIfBelowManaPotManaInRazorgoreRoom
local TankTarget = mb_tankTarget
local TrinketOnCD = mb_trinketOnCD
local UseTranquilizingShot = mb_useTranquilizingShot

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local Hunter = CreateFrame("Frame", "Hunter")

--[####################################################################################################]--
--[########################################## SETUP Code! #############################################]--
--[####################################################################################################]--

local function HunterSpecc()
    local TalentsIn, TalentsInA

    _, _, _, _, TalentsIn = GetTalentInfo(1, 14)
    if TalentsIn > 0 then
        MB_mySpecc = "Marksmanship"
        return 
    end

    _, _, _, _, TalentsIn = GetTalentInfo(1, 15)
    if TalentsIn > 0 then
        MB_mySpecc = "Survival"
        return 
    end

    _, _, _, _, TalentsIn = GetTalentInfo(1, 13)
    if TalentsIn > 0 then
        MB_mySpecc = "BeastMastery"
        return 
    end	

    MB_mySpecc = nil
end

MB_mySpeccList["Hunter"] = HunterSpecc

--[####################################################################################################]--
--[########################################## Single Code! ############################################]--
--[####################################################################################################]--

local function HunterSingle()

    GetTarget()

	if not MB_mySpecc then		
		CdMessage("My specc is fucked. Defaulting to Marksmanship.")
		MB_mySpecc = "Marksmanship"
	end

	if IsControlKeyDown() then		
		CastSpellByName("Aspect of the Cheetah")
		return
	end

	SelfBuff("Trueshot Aura")
	
	if TankTarget("Princess Huhuran") then
		SelfBuff("Aspect of the Wild")  
	else
		SelfBuff("Aspect of the Hawk")  
	end

    if Instance.NAXX and TankTarget("Gluth") then

		Hunter:FreezingTrap()
    elseif Instance.AQ40 and HasBuffOrDebuff("True Fulfillment", "target", "debuff") then
		
        ClearTarget()
        return
	elseif Instance.BWL and string.find(GetSubZoneText(), "Nefarian.*Lair") and IsAtNefarianPhase() then 

        if HasBuffOrDebuff("Shadow Command", "target", "debuff") then
            ClearTarget()
            return
        end
	elseif Instance.ZG and TankTarget("Hakkar") then

        if HasBuffOrDebuff("Mind Control", "target", "debuff") then
            ClearTarget()
            return
        end	
	end

	if not InCombat("target") then
        return
    end

    if InCombat("player") then
		TakeManaPotionAndRune()
		TakeManaPotionIfBelowManaPotMana()
		TakeManaPotionIfBelowManaPotManaInRazorgoreRoom()

		if ManaDown("player") > 600 then
            Hunter:Cooldowns()
        end
	end

	if InMeleeRange() then
		if not IsFireImmune() then
			Hunter:ExplosiveTrap()
		end

        AutoAttack()

		CastSpellByName("Raptor Strike")
		CastSpellByName("Mongoose Bite")
		return 
	end

    AutoRangedAttack()

    if Hunter:BossSpecificDPS() then
        return
    end

    if ImBusy() then
        return
    end

    if not MB_hunterFeign.Active then
        local aggrox = AceLibrary("Banzai-1.0")

        if aggrox:GetUnitAggroByUnitId("player") and SpellReady("Feign Death") then		
            MB_hunterFeign.Active = true
            MB_hunterFeign.Time = GetTime() + 0.2
            CastSpellByName("Feign Death")
        end
    end

    if HealthPct("target") > 0.1 and SpellReady("Aimed Shot") then        
        CastSpellByName("Aimed Shot")    
	end

    if HealthPct("target") < 0.95 and SpellReady("Multi-Shot") then			
        CastSpellByName("Multi-Shot") 
    end
end

function Hunter:BossSpecificDPS()
    if UseTranquilizingShot() and SpellReady("Tranquilizing Shot") then
        CastSpellByName("Tranquilizing Shot")
    end

	if not HasBuffNamed("Hunter\'s Mark", "target", "debuff") then			
		CastSpellByName("Hunter\'s Mark")
	end

	if Instance.AQ20 then        
        if TankTarget("Ossirian the Unscarred") then
            if HasBuffOrDebuff("Nature Weakness", "target", "debuff") then

                CoolDownCast("Serpent Sting", 15)
                return true
            elseif HasBuffOrDebuff("Arcane Weakness", "target", "debuff") then
            
                CastSpellByName("Arcane Shot")
                return true
            end

        elseif TankTarget("Moam") then
            CoolDownCast("Viper Sting", 8)
        end
	end

	return false
end

MB_mySingleList["Hunter"] = HunterSingle

--[####################################################################################################]--
--[########################################## Multi Code! #############################################]--
--[####################################################################################################]--

MB_myMultiList["Hunter"] = HunterSingle

--[####################################################################################################]--
--[########################################### AOE Code! ##############################################]--
--[####################################################################################################]--

MB_myAOEList["Hunter"] = HunterSingle

--[####################################################################################################]--
--[########################################## SETUP Code! #############################################]--
--[####################################################################################################]--

local function HunterSetup()

	SelfBuff("Trueshot Aura")	
	SelfBuff("Aspect of the Hawk")

    CastSpellByName("Dismiss Pet")
end

MB_mySetupList["Hunter"] = HunterSetup

--[####################################################################################################]--
--[######################################### PRECAST Code! ############################################]--
--[####################################################################################################]--

local function HunterPreCast()
	for k, trinket in pairs(MB_meleeTrinkets) do
		if ItemNameOfEquippedSlot(13) == trinket and not TrinketOnCD(13) then 
			use(13) 
		end

		if ItemNameOfEquippedSlot(14) == trinket and not TrinketOnCD(14) then 
			use(14) 
		end
	end

    CastSpellByName("Aimed Shot")
end

MB_myPreCastList["Hunter"] = HunterPreCast

--[####################################################################################################]--
--[########################################## Helper Code! ############################################]--
--[####################################################################################################]--

function Hunter:Cooldowns()
	if ImBusy() or not InCombat("player") then
		return
	end

    SelfBuff("Berserking") 
		
    if not InMeleeRange() then    
        SelfBuff("Rapid Fire") 
    end

    SelfBuff("Combustion")
    SelfBuff("Presence of Mind")
    
    MeleeTrinkets()
end

function Hunter:ExplosiveTrap()

	if not SpellReady("Explosive Trap") then 
		return 
	end

	if InCombat("player") and not MB_hunterFeign.Active then

		MB_hunterFeign.Active = true
		MB_hunterFeign.Time = GetTime() + 0.2

		CastSpellByName("Feign Death") 
	else

		CastSpellByName("Explosive Trap")
	end
end

function Hunter:FreezingTrap()

	if not SpellReady("Frost Trap") then 
		return 
	end

	PetPassiveMode()
	PetFollow()

	if InCombat("player") and not MB_hunterFeign.Active then

		MB_hunterFeign.Active = true
		MB_hunterFeign.Time = GetTime() + 0.2

		CastSpellByName("Feign Death") 
	else

		CastSpellByName("Frost Trap")
	end
end
