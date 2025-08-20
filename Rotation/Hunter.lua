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

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local Hunter = CreateFrame("Frame", "Hunter")
if myClass ~= "Hunter" then
    return
end

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

    mb_getTarget()

	if not MB_mySpecc then		
		mb_cdMessage("My specc is fucked. Defaulting to Marksmanship.")
		MB_mySpecc = "Marksmanship"
	end

	if IsControlKeyDown() then		
		CastSpellByName("Aspect of the Cheetah")
		return
	end

	mb_selfBuff("Trueshot Aura")
	
	if mb_tankTarget("Princess Huhuran") then
		mb_selfBuff("Aspect of the Wild")  
	else
		mb_selfBuff("Aspect of the Hawk")  
	end

    if Instance.NAXX and mb_tankTarget("Gluth") then

		Hunter:FreezingTrap()
    elseif Instance.AQ40 and mb_hasBuffOrDebuff("True Fulfillment", "target", "debuff") then
		
        ClearTarget()
        return
	elseif Instance.BWL and string.find(GetSubZoneText(), "Nefarian.*Lair") and mb_isAtNefarianPhase() then 

        if mb_hasBuffOrDebuff("Shadow Command", "target", "debuff") then
            ClearTarget()
            return
        end
	elseif Instance.ZG and mb_tankTarget("Hakkar") then

        if mb_hasBuffOrDebuff("Mind Control", "target", "debuff") then
            ClearTarget()
            return
        end	
	end

	if not mb_inCombat("target") then
        return
    end

    if mb_inCombat("player") then
		mb_takeManaPotionAndRune()
		mb_takeManaPotionIfBelowManaPotMana()
		mb_takeManaPotionIfBelowManaPotManaInRazorgoreRoom()

		if mb_manaDown("player") > 600 then
            Hunter:Cooldowns()
        end
	end

	if mb_inMeleeRange() then
		if not mb_isFireImmune() then
			Hunter:ExplosiveTrap()
		end

        mb_autoAttack()

		CastSpellByName("Raptor Strike")
		CastSpellByName("Mongoose Bite")
		return 
	end

    mb_autoRangedAttack()

    if Hunter:BossSpecificDPS() then
        return
    end

    if mb_imBusy() then
        return
    end

    if not MB_hunterFeign.Active then
        local aggrox = AceLibrary("Banzai-1.0")

        if aggrox:GetUnitAggroByUnitId("player") and mb_spellReady("Feign Death") then		
            MB_hunterFeign.Active = true
            MB_hunterFeign.Time = GetTime() + 0.2
            CastSpellByName("Feign Death")
        end
    end

    if mb_healthPct("target") > 0.1 and mb_spellReady("Aimed Shot") then        
        CastSpellByName("Aimed Shot")    
	end

    if mb_healthPct("target") < 0.95 and mb_spellReady("Multi-Shot") then			
        CastSpellByName("Multi-Shot") 
    end
end

function Hunter:BossSpecificDPS()
    if mb_useTranquilizingShot() and mb_spellReady("Tranquilizing Shot") then
        CastSpellByName("Tranquilizing Shot")
    end

	if not mb_hasBuffNamed("Hunter\'s Mark", "target", "debuff") then			
		CastSpellByName("Hunter\'s Mark")
	end

	if Instance.AQ20 then        
        if mb_tankTarget("Ossirian the Unscarred") then
            if mb_hasBuffOrDebuff("Nature Weakness", "target", "debuff") then

                mb_coolDownCast("Serpent Sting", 15)
                return true
            elseif mb_hasBuffOrDebuff("Arcane Weakness", "target", "debuff") then
            
                CastSpellByName("Arcane Shot")
                return true
            end

        elseif mb_tankTarget("Moam") then
            mb_coolDownCast("Viper Sting", 8)
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

	mb_selfBuff("Trueshot Aura")	
	mb_selfBuff("Aspect of the Hawk")

    CastSpellByName("Dismiss Pet")
end

MB_mySetupList["Hunter"] = HunterSetup

--[####################################################################################################]--
--[######################################### PRECAST Code! ############################################]--
--[####################################################################################################]--

local function HunterPreCast()
	for k, trinket in pairs(MB_meleeTrinkets) do
		if mb_itemNameOfEquippedSlot(13) == trinket and not mb_trinketOnCD(13) then 
			use(13) 
		end

		if mb_itemNameOfEquippedSlot(14) == trinket and not mb_trinketOnCD(14) then 
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
	if mb_imBusy() or not mb_inCombat("player") then
		return
	end

    mb_selfBuff("Berserking") 
		
    if not mb_inMeleeRange() then    
        mb_selfBuff("Rapid Fire") 
    end

    mb_selfBuff("Combustion")
    mb_selfBuff("Presence of Mind")
    
    mb_meleeTrinkets()
end

function Hunter:ExplosiveTrap()

	if not mb_spellReady("Explosive Trap") then 
		return 
	end

	if mb_inCombat("player") and not MB_hunterFeign.Active then

		MB_hunterFeign.Active = true
		MB_hunterFeign.Time = GetTime() + 0.2

		CastSpellByName("Feign Death") 
	else

		CastSpellByName("Explosive Trap")
	end
end

function Hunter:FreezingTrap()

	if not mb_spellReady("Frost Trap") then 
		return 
	end

	PetPassiveMode()
	PetFollow()

	if mb_inCombat("player") and not MB_hunterFeign.Active then

		MB_hunterFeign.Active = true
		MB_hunterFeign.Time = GetTime() + 0.2

		CastSpellByName("Feign Death") 
	else

		CastSpellByName("Frost Trap")
	end
end