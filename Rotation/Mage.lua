--[####################################################################################################]--
--[######################################### START MAGE CODE! #########################################]--
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
if myClass ~= "Mage" then return end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

-- Global Functions become Local
local GetTarget = mb_getTarget
local CdMessage = mb_cdMessage
local CrowdControl = mb_crowdControl
local HasBuffOrDebuff = mb_hasBuffOrDebuff
local Decurse = mb_decurse
local TankTarget = mb_tankTarget
local CrowdControlledMob = mb_crowdControlledMob
local IsAtSkeram = mb_isAtSkeram
local MyClassAlphabeticalOrder = mb_myClassAlphabeticalOrder
local CrowdControlMCedRaidMemberSkeram = mb_crowdControlMCedRaidMemberSkeram
local IsAtNefarianPhase = mb_isAtNefarianPhase
local CrowdControlMCedRaidMemberNefarian = mb_crowdControlMCedRaidMemberNefarian
local CrowdControlMCedRaidMemberHakkar = mb_crowdControlMCedRaidMemberHakkar
local InCombat = mb_inCombat
local TakeManaPotionAndRune = mb_takeManaPotionAndRune
local TakeManaPotionIfBelowManaPotMana = mb_takeManaPotionIfBelowManaPotMana
local TakeManaPotionIfBelowManaPotManaInRazorgoreRoom = mb_takeManaPotionIfBelowManaPotManaInRazorgoreRoom
local ManaPct = mb_manaPct
local SpellReady = mb_spellReady
local GetMyInterruptTarget
local ImBusy = mb_imBusy
local CdPrint = mb_cdPrint
local IsFireImmune = mb_isFireImmune
local CastSpellOrWand = mb_castSpellOrWand
local IsFrostImmune = mb_isFrostImmune
local MobsToDetectMagic = mb_mobsToDetectMagic
local MobsToFireWard = mb_mobsToFireWard
local SelfBuff = mb_selfBuff
local AutoWandAttack = mb_autoWandAttack
local HasBuffNamed = mb_hasBuffNamed
local HealthPct = mb_healthPct
local InMeleeRange = mb_inMeleeRange
local CorruptedTotems = mb_corruptedTotems
local Dead = mb_dead
local IsAtGrobbulus = mb_isAtGrobbulus
local DebuffWintersChillAmount = mb_debuffWintersChillAmount
local ManaDown = mb_manaDown
local MageWater = mb_mageWater
local MultiBuff = mb_multiBuff
local MobsToDampenMagic = mb_mobsToDampenMagic
local MobsToAmplifyMagic = mb_mobsToAmplifyMagic
local TankBuff = mb_tankBuff
local MakeWater = mb_makeWater
local SmartDrink = mb_smartDrink
local ItemNameOfEquippedSlot = mb_itemNameOfEquippedSlot
local TrinketOnCD = mb_trinketOnCD
local HealerTrinkets = mb_healerTrinkets
local CasterTrinkets = mb_casterTrinkets
local DebuffScorchAmount = mb_debuffScorchAmount
local HaveInBags = mb_haveInBags
local GetAllContainerFreeSlots = mb_getAllContainerFreeSlots

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local Mage = CreateFrame("Frame", "Mage")

local MageCounter = {
    Cycle = function()
        MB_buffingCounterMage = (MB_buffingCounterMage >= TableLength(MB_classList["Mage"]))
                                and 1 or (MB_buffingCounterMage + 1)
    end
}

local CooldownScenarios = {
    ["ONY"] = {
        Encounter = function() return TankTarget("Onyxia") end,
        Conditions = function() return TankTargetHealth() <= 0.65 and ManaDown("player") > 600 end
    },
}

--[####################################################################################################]--
--[########################################## SETUP Code! #############################################]--
--[####################################################################################################]--

local function MageSpecc()
    local TalentsIn, TalentsInA

    _, _, _, _, TalentsIn = GetTalentInfo(3, 16)
    if TalentsIn > 0 then
        MB_mySpecc = "Frost"
        return 
    end

    _, _, _, _, TalentsIn = GetTalentInfo(2, 16)
    if TalentsIn > 0 then
        MB_mySpecc = "Fire"
        return 
    end

    _, _, _, _, TalentsIn = GetTalentInfo(1, 16)
    _, _, _, _, TalentsInA = GetTalentInfo(2, 8)
    if TalentsIn > 0 and TalentsInA > 0 then
        MB_mySpecc = "Fire"
        return 
    end	

    _, _, _, _, TalentsIn = GetTalentInfo(1, 16)
    _, _, _, _, TalentsInA = GetTalentInfo(3, 8)
    if TalentsIn > 0 and TalentsInA > 1 then
        MB_mySpecc = "Frost"
        return 
    end

    MB_mySpecc = nil
end

local function WinterChillCheck()
	local _, _, _, _, TalentsIn = GetTalentInfo(3, 16)
	if TalentsIn > 4 then
		return true
	end
	return false
end

MB_mySpeccList["Mage"] = MageSpecc

--[####################################################################################################]--
--[########################################## Single Code! ############################################]--
--[####################################################################################################]--

local function MageSingle()

    GetTarget()

	if not MB_mySpecc then		
		CdMessage("My specc is fucked. Defaulting to Frost.")
		MB_mySpecc = "Frost"
	end

	if CrowdControl() then 
        return
    end

	if HasBuffOrDebuff("Evocation", "player", "buff") then
		return
	end

	Decurse()

	if TankTarget("Ossirian the Unscarred") then
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

	if Instance.AQ40 then		
		if HasBuffOrDebuff("True Fulfillment", "target", "debuff") then
            ClearTarget()
            return
        end

		if IsAtSkeram() then
            if not MB_autoToggleSheeps.Active then
                MB_autoToggleSheeps.Active = true
                MB_autoToggleSheeps.Time = GetTime() + 2
                MageCounter.Cycle()
            end

			if MyClassAlphabeticalOrder() == MB_buffingCounterMage then					
				CrowdControlMCedRaidMemberSkeram()
			end
		end

	elseif Instance.BWL and string.find(GetSubZoneText(), "Nefarian.*Lair") and IsAtNefarianPhase() then 

        if HasBuffOrDebuff("Shadow Command", "target", "debuff") then
            ClearTarget()
            return
        end

        if not MB_autoToggleSheeps.Active then
            MB_autoToggleSheeps.Active = true
            MB_autoToggleSheeps.Time = GetTime() + 3
            MageCounter.Cycle()
        end

        if MyClassAlphabeticalOrder() == MB_buffingCounterMage then                
            CrowdControlMCedRaidMemberNefarian()
        end

	elseif Instance.ZG and TankTarget("Hakkar") then

        if HasBuffOrDebuff("Mind Control", "target", "debuff") then
            ClearTarget()
            return
        end

        if not MB_autoToggleSheeps.Active then
            MB_autoToggleSheeps.Active = true
            MB_autoToggleSheeps.Time = GetTime() + 10
            MageCounter.Cycle()
        end

        if MyClassAlphabeticalOrder() == MB_buffingCounterMage then                
            CrowdControlMCedRaidMemberHakkar()
        end		
	end

	if not InCombat("target") then
        return
    end

	if InCombat("player") then
		Mage:UseManaGems()

		TakeManaPotionAndRune()
		TakeManaPotionIfBelowManaPotMana()
		TakeManaPotionIfBelowManaPotManaInRazorgoreRoom()

		if ManaPct() <= 0.1 and SpellReady("Evocation") then
			CastSpellByName("Evocation")
			return
		end
	end

    if MB_doInterrupt.Active and SpellReady(MB_myInterruptSpell[myClass]) then
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

	if Mage:BossSpecificDPS() then
        return
    end

	if MB_mySpecc == "Fire" then
		if IsFireImmune() then			
			CastSpellOrWand("Frostbolt")
			return
		end

		Mage:Fire()

	elseif MB_mySpecc == "Frost" then
        if IsFrostImmune() then
            CastSpellOrWand("Fireball")
            return
        end

        Mage:Frost()
	end
end

function Mage:BossSpecificDPS()
    local tName = UnitName("target")

	if tName == "Emperor Vek\'nilash" then
        return true
    end

	if MobsToDetectMagic() and not HasBuffOrDebuff("Detect Magic", "target", "debuff") then		
		if not HasBuffOrDebuff("Detect Magic", "player", "debuff") then
			CastSpellByName("Detect Magic")
			return true
		end
	end

	if MobsToFireWard() and not HasBuffOrDebuff("Fire Ward", "player", "buff")  then
		SelfBuff("Fire Ward")
		return true
	end

    if Instance.AQ40 and MobsToDetectMagic() then
        if not HasBuffOrDebuff("Detect Magic", "target", "debuff") then        
            CastSpellOrWand("Frostbolt")
            return true
        elseif HasBuffOrDebuff("Fire and Arcane Reflect", "target", "buff") and not HasBuffOrDebuff("Immolate", "target", "debuff") then
            CastSpellOrWand("Frostbolt")
            return true
        elseif HasBuffOrDebuff("Shadow and Frost Reflect", "target", "buff") and HasBuffOrDebuff("Immolate", "target", "debuff") then
            Mage:Fire()
            return true
        end
    end

    if HasBuffOrDebuff("Magic Reflection", "target", "buff") then
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

	if Instance.AQ40 then		
		if TankTarget("Viscidus") then			
			if HealthPct("target") <= 0.35 then				
				CastSpellByName("Frostbolt(Rank 1)")
				return true
			end

			Mage:Fire()
			return true			
		end

		if tName == "Spawn of Fankriss" then			
			if SpellReady("Fireblast") and InMeleeRange() then
				CastSpellByName("Fire Blast")
			end

            if MB_mySpecc == "Fire" then    
                Mage:Fire()

            elseif MB_mySpecc == "Frost" then
                Mage:Frost()
            end
			return true
		end

	elseif Instance.BWL and CorruptedTotems() and not Dead("target") then	
        if SpellReady("Fireblast") then
            CastSpellByName("Fire Blast")
        end

        CastSpellOrWand("Scorch")
        return true

	elseif Instance.MC then
		if TankTarget("Shazzrah") then
			if MB_mySpecc == "Fire" and not SpellReady("Fireball") then				
                Mage:Frost()
				return true
			elseif MB_mySpecc == "Frost" and not SpellReady("Frostbolt") then							
				Mage:Fire()
				return true				
			end
		end

		if tName == "Lava Spawn" and InMeleeRange() then
            if SpellReady("Cone of Cold") then				
                CastSpellOrWand("Cone of Cold")
                return true
            end
		end

	elseif Instance.ZG then
		if HasBuffOrDebuff("Delusions of Jin\'do", "player", "debuff") then
			if tName == "Shade of Jin\'do" and not Dead("target") then
				if SpellReady("Fire Blast") then
					CastSpellByName("Fire Blast") 
				end 
					
				CastSpellOrWand("Scorch") 
				return true
			end
		end

		if (tName == "Powerful Healing Ward" or tName == "Brain Wash Totem") and not Dead("target") then
			if SpellReady("Fire Blast") then				
				CastSpellByName("Fire Blast")
			end

			CastSpellOrWand("Scorch")
			return true
		end

	elseif Instance.AQ20 and TankTarget("Ossirian the Unscarred") then
        if HasBuffOrDebuff("Fire Weakness", "target", "debuff") then        
            Mage:Fire()
            return true
        elseif HasBuffOrDebuff("Frost Weakness", "target", "debuff") then
            Mage:Frost()
            return true
        elseif HasBuffOrDebuff("Arcane Weakness", "target", "debuff") then        
            CastSpellOrWand("Arcane Missiles")
            return true
        end
	end

	return false
end

function Mage:Fire()
    local igTick = tonumber(MB_ignite.Amount)

    -- No active Ignite: starter just starts it
    if not MB_ignite.Active then
        Mage:UseFireCooldowns()
        CastSpellOrWand("Fireball")
        return
    end

    -- Starter logic
    if MB_ignite.Starter == myName then
        -- Good Ignite tick
        if igTick > MB_raidAssist.Mage.StarterIgniteTick then
            SelfBuff("Combustion") -- pop Combustion once at start

            -- Fire Blast if allowed, in melee, and ready
            if MB_raidAssist.Mage.AllowFireBlastDuringIgnite and InMeleeRange() and SpellReady("Fire Blast") then
                CastSpellByName("Fire Blast")
            end

            -- Main spell to keep Ignite rolling
            CastSpellOrWand("Fireball")
        else
            -- Bad tick handling
            if MB_raidAssist.Mage.AllowIgniteToDropWhenBadTick then
                CastSpellOrWand("Frostbolt")
            else
                CastSpellOrWand("Fireball")
            end
        end

    -- Non-starter logic
    else
        -- Starter has good Ignite tick
        if igTick > MB_raidAssist.Mage.StarterIgniteTick then
            if HasBuffOrDebuff("Ignite", "target", "debuff") then
                CastSpellOrWand(MB_raidAssist.Mage.SpellToKeepIgniteUp) -- usually Scorch
            end
        else
            -- Starter tick is bad → non-starters cast Fireball to start next strong Ignite
            CastSpellOrWand("Fireball")
        end
    end
end

function Mage:Frost()
    -- Combat cooldowns
    if InCombat("player") then
        Mage:UseFrostCooldowns() 

        -- Ice Block if low health (except Grobbulus)
        if SpellReady("Ice Block") and HealthPct("player") <= 0.22 and not IsAtGrobbulus() then
            SelfBuff("Ice Block")
            return
        end

        -- Cancel Ice Block safely
        if HasBuffOrDebuff("Ice Block", "player", "buff") and HealthPct("player") >= 0.70 then
            CancelBuff("Ice Block")
            return
        end

        -- Ice Barrier
        if SpellReady("Ice Barrier") and HealthPct("player") >= 0.65 and not HasBuffOrDebuff("Ice Barrier", "player", "buff") then
            SelfBuff("Ice Barrier")
            return
        end
    end

    -- Winter's Chill opener
    if WinterChillCheck() and DebuffWintersChillAmount() < 3 then
        CastSpellByName(MB_raidAssist.Mage.SpellToKeepWintersChillUp)
        return
    end

    -- Frostbolt rotation (Fireball as backup if GCD)
    if SpellReady("Frostbolt") then
        CastSpellOrWand("Frostbolt")
    else
        CastSpellOrWand("Fireball")
    end
end

MB_mySingleList["Mage"] = MageSingle

--[####################################################################################################]--
--[########################################## Multi Code! #############################################]--
--[####################################################################################################]--

MB_myMultiList["Mage"] = MageSingle

--[####################################################################################################]--
--[########################################### AOE Code! ##############################################]--
--[####################################################################################################]--

local function MageAOE()

    GetTarget()

	if not MB_mySpecc then		
		CdMessage("My specc is fucked. Defaulting to Frost.")
		MB_mySpecc = "Frost"
	end

	if HasBuffOrDebuff("Evocation", "player", "buff") then
		return
	end

	Decurse()

	if TankTarget("Ossirian the Unscarred") then
        return
    end

    if InCombat("player") then
		Mage:UseManaGems()

		TakeManaPotionAndRune()
		TakeManaPotionIfBelowManaPotMana()
		TakeManaPotionIfBelowManaPotManaInRazorgoreRoom()

        if ManaDown("player") > 600 then
            Mage:Cooldowns()
        end
	end

	if ManaPct("player") < 0.2 and not HasBuffOrDebuff("Clearcasting", "player", "buff") then
		CastSpellByName("Arcane Explosion(Rank 1)")
		return
	end

    if Instance.BWL and GetSubZoneText() == "Halls of Strife" then        
        CastSpellByName("Arcane Explosion(Rank 3)") 
        return
    elseif Instance.NAXX and TankTarget("Maexxna") then        
        CastSpellByName("Arcane Explosion(Rank 3)") 
        return
    end

    if InMeleeRange() then
        if MB_mySpecc == "Fire" then
            if IsFireImmune() then
                return
            end

            if SpellReady("Blast Wave") then                
                CastSpellByName("Blast Wave")
            end

        elseif MB_mySpecc == "Frost" then
            if IsFrostImmune() then
                return
            end

            if SpellReady("Ice Block") and HealthPct("player") <= 0.22 and not IsAtGrobbulus() then			
                SelfBuff("Ice Block")
                return
            end

            if HasBuffOrDebuff("Ice Block", "player", "buff") and HealthPct("player") >= 0.70 then 
                CancelBuff("Ice Block") 
                return 
            end

            if SpellReady("Ice Barrier") and HealthPct("player") >= 0.65 then				
                SelfBuff("Ice Barrier")
                return
            end
        end
    end

	CastSpellByName("Arcane Explosion") 
end

MB_myAOEList["Mage"] = MageAOE

--[####################################################################################################]--
--[########################################## SETUP Code! #############################################]--
--[####################################################################################################]--

local function MageSetup()
   
    if HasBuffOrDebuff("Evocation", "player", "buff") then
        return
    end

    if UnitMana("player") < 3060 and HasBuffNamed("Drink", "player") then
        return
    end

    if IsAltKeyDown() then      
        Mage:ConjureManaGems()
        return
    end

    if MageWater() > 60 or MB_isMoving.Active then      
        if not MB_autoBuff.Active then
            MB_autoBuff.Active = true
            MB_autoBuff.Time = GetTime() + 0.25
            MageCounter.Cycle()
        end

        if MyClassAlphabeticalOrder() == MB_buffingCounterMage then        
            MultiBuff("Arcane Brilliance")

            if MobsToDampenMagic() then  
                MultiBuff("Dampen Magic")            
           
            elseif MobsToAmplifyMagic() then            
                if TankTarget("Gluth") then
                    MultiBuff("Amplify Magic")
                end
   
                TankBuff("Amplify Magic")
            end
        end
    else
        MakeWater()
    end

    SelfBuff("Mage Armor")
    Mage:ConjureManaGems()
           
    if not InCombat("player") and ManaPct("player") < 0.20 and not HasBuffNamed("Drink", "player") then
        SmartDrink()
    end
end

MB_mySetupList["Mage"] = MageSetup

--[####################################################################################################]--
--[######################################### PRECAST Code! ############################################]--
--[####################################################################################################]--

local function MagePreCast()
    for k, trinket in pairs(CasterTrinkets) do
        if ItemNameOfEquippedSlot(13) == trinket and not TrinketOnCD(13) then
            use(13)
        end
        if ItemNameOfEquippedSlot(14) == trinket and not TrinketOnCD(14) then
            use(14)
        end
    end

    if MB_mySpecc == "Fire" then
        if IsFireImmune() then          
            CastSpellByName("Frostbolt")
        else
            CastSpellByName("Fireball")
        end
    elseif MB_mySpecc == "Frost" then
        if IsFrostImmune() then
            CastSpellByName("Fireball")
        else
            CastSpellByName("Frostbolt")
        end
    end
end

MB_myPreCastList["Mage"] = MagePreCast

--[####################################################################################################]--
--[###################################### Cooldowns Encounters! #######################################]--
--[####################################################################################################]--

function Mage:Cooldowns()
	if ImBusy() or not InCombat("player") then
		return
	end

    SelfBuff("Presence of Mind")
    SelfBuff("Berserking") 

    if not HasBuffOrDebuff("Power Infusion", "player", "buff") then
        SelfBuff("Arcane Power")			
    end

    HealerTrinkets()
	CasterTrinkets()
end

local function CooldownConditions()
    if Instance.ONY and CooldownScenarios.ONY then
        if CooldownScenarios.ONY.Encounter() then
            if CooldownScenarios.ONY.Conditions() then
                Mage:Cooldowns()
            end
            return true
        end
    end
    return false
end

function Mage:UseFireCooldowns()
    if CooldownConditions() then
        return      
    end

    if DebuffScorchAmount() == 5 then
        Mage:Cooldowns()
    end
end

function Mage:UseFrostCooldowns()
    if CooldownConditions() then
        return
    end

    if ManaDown("player") > 600 then
        Mage:Cooldowns()
    end
end

--[####################################################################################################]--
--[########################################## Helper Code! ############################################]--
--[####################################################################################################]--

function Mage:UseManaGems()
	if ImBusy() or not InCombat("player") then
		return
	end

	if Instance.IsWorldBoss() or UnitLevel("target") >= 63 then
		if HaveInBags("Mana Ruby") and ManaDown("player") >= 1200  then			
			UseItemByName("Mana Ruby")
		end

		if HaveInBags("Mana Citrine") and ManaDown("player") >= 925 and not HaveInBags("Mana Ruby") then			
			UseItemByName("Mana Citrine")
		end

		if HaveInBags("Mana Jade") and ManaDown("player") >= 650 and not HaveInBags("Mana Citrine") then
			if not HaveInBags("Mana Ruby") then				
				UseItemByName("Mana Jade")
			end
		end

		if HaveInBags("Mana Agate") and ManaDown("player") >= 425 and not HaveInBags("Mana Jade") then
			if not HaveInBags("Mana Ruby") and not HaveInBags("Mana Citrine") then				
				UseItemByName("Mana Agate")
			end
		end
	end 

	if UnitLevel("target") <= 63 and ManaPct("player") < 0.3 then
		if HaveInBags("Mana Ruby") and ManaDown("player") >= 1200  then			
			UseItemByName("Mana Ruby")
		end

		if HaveInBags("Mana Citrine") and ManaDown("player") >= 925 and not HaveInBags("Mana Ruby") then			
			UseItemByName("Mana Citrine")
		end

		if HaveInBags("Mana Jade") and ManaDown("player") >= 650 and not HaveInBags("Mana Citrine") then
			if not HaveInBags("Mana Ruby") then				
				UseItemByName("Mana Jade")
			end
		end

		if HaveInBags("Mana Agate") and ManaDown("player") >= 425 and not HaveInBags("Mana Jade") then
			if not HaveInBags("Mana Ruby") and not HaveInBags("Mana Citrine") then				
				UseItemByName("Mana Agate")
			end
		end
	end

	return false
end

function Mage:ConjureManaGems()
	if ImBusy() or not InCombat("player") then
		return
	end

	if GetAllContainerFreeSlots() == 0 then		
		CdMessage("My bags are full, can\'t conjure more stuff", 60)
		return
	end

	if not HaveInBags("Mana Ruby") then		
		CastSpellByName("Conjure Mana Ruby")
	end

	if not HaveInBags("Mana Citrine") then		
		CastSpellByName("Conjure Mana Citrine")
	end

	if not HaveInBags("Mana Jade") then		
		CastSpellByName("Conjure Mana Jade")
	end

	if not HaveInBags("Mana Agate") then		
		CastSpellByName("Conjure Mana Agate")
	end
end