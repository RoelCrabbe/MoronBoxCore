--[####################################################################################################]--
--[###################################### START WARRIOR CODE! #########################################]--
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
if myClass ~= "Warrior" then return end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local AnubisathAlert = mb_anubisathAlert
local AutoAttack = mb_autoAttack
local BossIShouldUseRecklessnessOn = mb_bossIShouldUseRecklessnessOn
local CdPrint = mb_cdPrint
local CrowdControlledMob = mb_crowdControlledMob
local DebuffAmountShatter = mb_debuffAmountShatter
local DebuffSunderAmount = mb_debuffSunderAmount
local FuryGear = mb_furyGear
local GetTarget = mb_getTarget
local GetWeaverWeapon = mb_getWeaverWeapon
local HasBuffOrDebuff = mb_hasBuffOrDebuff
local HaveInBags = mb_haveInBags
local HealthPct = mb_healthPct
local IamFocus = mb_iamFocus
local ImBusy = mb_imBusy
local InCombat = mb_inCombat
local InMeleeRange = mb_inMeleeRange
local IsAtNoth = mb_isAtNoth
local IsAtSkeram = mb_isAtSkeram
local IsExcludedWW = mb_isExcludedWW
local IsItemInBagCoolDown = mb_isItemInBagCoolDown
local ItemNameOfEquippedSlot = mb_itemNameOfEquippedSlot
local KnowSpell = mb_knowSpell
local MeleeTrinkets = mb_meleeTrinkets
local MobsNoSunders = mb_mobsNoSunders
local MobsToAutoBreakFear = mb_mobsToAutoBreakFear
local MyNameInTable = mb_myNameInTable
local OffTank = mb_offTank
local SelfBuff = mb_selfBuff
local SpellReady = mb_spellReady
local StunnableMob = mb_stunnableMob
local TankTarget = mb_tankTarget
local TrinketOnCD = mb_trinketOnCD
local WarriorIsBattle = mb_warriorIsBattle
local WarriorIsBerserker = mb_warriorIsBerserker
local WarriorIsDefensive = mb_warriorIsDefensive
local WarriorSetBattle = mb_warriorSetBattle
local WarriorSetBerserker = mb_warriorSetBerserker
local WarriorSetDefensive = mb_warriorSetDefensive

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local Warrior = CreateFrame("Frame", "Warrior")

--[####################################################################################################]--
--[########################################## SETUP Code! #############################################]--
--[####################################################################################################]--

local function WarriorSpecc()
    local TalentsIn, TalentsInA

    _, _, _, _, TalentsIn = GetTalentInfo(2, 17)
    _, _, _, _, TalentsInA = GetTalentInfo(3, 9)
    if TalentsIn > 0 and TalentsInA > 4 then
        MB_mySpecc = "Furytank"
        return 
    end	

    _, _, _, _, TalentsIn = GetTalentInfo(1, 18)
    if TalentsIn > 0 then
        MB_mySpecc = "MS"
        return 
    end

    _, _, _, _, TalentsIn = GetTalentInfo(2, 17)
    if TalentsIn > 0 then
        MB_mySpecc = "BT"
        return 
    end

    _, _, _, _, TalentsIn = GetTalentInfo(3, 17)
    if TalentsIn > 0 then
        MB_mySpecc = "Prottank"
        return 
    end

    MB_mySpecc = nil
end

MB_mySpeccList["Warrior"] = WarriorSpecc

--[####################################################################################################]--
--[########################################## Single Code! ############################################]--
--[####################################################################################################]--

local function WarriorSingle()
	
	GetTarget()
	
    if MB_warriorBinds == "Fury" and not InCombat("player") then
        if MyNameInTable(MB_furysThatCanTank) then				
            FuryGear()
            MB_warriorBinds = nil
        end
    end	

	if not InCombat("target") then
        return
    end

    if Instance.AQ40 then
        if TankTarget("Princess Huhuran") and HealthPct("target") <= 0.3 and MB_myHuhuranBoxStrategy then        
            if HaveInBags("Greater Nature Protection Potion") and not IsItemInBagCoolDown("Greater Nature Protection Potion") then				
                UseItemByName("Greater Nature Protection Potion")
            end       
        elseif IsAtSkeram() and SpellReady("Intimidating Shout") then
            CastSpellByName("Intimidating Shout")
        end
    end

    if MobsToAutoBreakFear() and InMeleeRange() then
		SelfBuff("Death Wish") 
	end

	if (MB_mySpecc == "BT" or MB_mySpecc == "MS") then
		
        if MB_useBigCooldowns.Active then			
            Warrior:BigCooldowns()
        end

        if MB_useCooldowns.Active then			
            Warrior:Cooldowns()
        end        

		Warrior:DPSSingle()
		return

	elseif (MB_mySpecc == "Prottank" or MB_mySpecc == "Furytank") then

		if Instance.AQ40 then			
			if HasBuffOrDebuff("True Fulfillment", "target", "debuff") then
                TargetByName("The Prophet Skeram")
            end

			AnubisathAlert()
		end

		Warrior:TankSingle()
		return
	end
end

MB_mySingleList["Warrior"] = WarriorSingle

--[####################################################################################################]--
--[####################################### Single Damage Code! ########################################]--
--[####################################################################################################]--

function Warrior:DPSSingle()

    if not WarriorIsBerserker() then
        WarriorSetBerserker()
        return
    end

    if not UnitName("target") then
        return
    end

    AutoAttack()
    Warrior:Annihilator()

    if SpellReady("Bloodrage") and UnitMana("player") < 20 then        
        CastSpellByName("Bloodrage")
    end

    if MB_doInterrupt.Active and SpellReady(MB_myInterruptSpell[myClass]) then
        if UnitMana("player") >= 10 then
            if ImBusy() then		
                SpellStopCasting()
            end

            CastSpellByName(MB_myInterruptSpell[myClass])
            CdPrint("Interrupting!")
            MB_doInterrupt.Active = false
            return
        end
    end

    SelfBuff("Battle Shout")

    if not MobsNoSunders() and UnitInRaid("player") and GetNumRaidMembers() > 5 then
        if not HasBuffOrDebuff("Expose Armor", "target", "debuff") and DebuffSunderAmount() < 5 then
            CastSpellByName("Sunder Armor")
        end
    end

    Warrior:UseDPSCooldowns()
    Warrior:Execute()

    if MB_mySpecc == "BT" then
        if UnitMana("player") >= 30 and SpellReady("Bloodthirst") then            
            CastSpellByName("Bloodthirst")
        end

        if not IsExcludedWW() then
            if UnitMana("player") >= 25 and SpellReady("Whirlwind") and InMeleeRange() then
                if not SpellReady("Bloodthirst") then
                    CastSpellByName("Whirlwind")
                end
            end
        end

        if UnitMana("player") > 55 then            
            CastSpellByName("Heroic Strike")
        end

    elseif MB_mySpecc == "MS" then
        if UnitMana("player") >= 30 and SpellReady("Mortal Strike") then            
            CastSpellByName("Mortal Strike")
        end

        if not IsExcludedWW() then
            if UnitMana("player") >= 25 and SpellReady("Whirlwind") and InMeleeRange() then
                if not SpellReady("Mortal Strike") then
                    CastSpellByName("Whirlwind")
                end
            end
        end

        if UnitMana("player") > 85 then            
            CastSpellByName("Heroic Strike")
        end
    end

    if UnitFactionGroup("player") ~= "Alliance" then	
        if UnitMana("player") > 85 then            
            CastSpellByName("Hamstring")
        end
    end
end

--[####################################################################################################]--
--[######################################## Single Tank Code! #########################################]--
--[####################################################################################################]--

local function WarriorTankSingleRotation()
    if MB_mySpecc == "Prottank" then
        if SpellReady("Shield Slam") and UnitMana("player") >= 20 and Warrior:HasShield() then        
            CastSpellByName("Shield Slam")
        end

    elseif MB_mySpecc == "Furytank" then
        if SpellReady("Bloodthirst") and UnitMana("player") >= 30 then            
            CastSpellByName("Bloodthirst")
        end	
    end
    
    if UnitName("target") ~= "Deathknight Understudy" and not HasBuffOrDebuff("Expose Armor", "target", "debuff") then        
        CastSpellByName("Sunder Armor")
    end

    if HasBuffOrDebuff("Expose Armor", "target", "debuff") then
        if (not SpellReady("Bloodthirst") and UnitMana("player") >= 23) or UnitMana("player") >= 43 then
            CastSpellByName("Heroic Strike")
        end
    else
        if UnitMana("player") >= 43 then
            CastSpellByName("Heroic Strike")
        end
    end
end

function Warrior:TankSingle()

	if FindInTable(MB_raidTanks, myName) and HasBuffOrDebuff("Greater Blessing of Salvation", "player", "buff") then		
		CancelBuff("Greater Blessing of Salvation") 
	end

    Warrior:UseTANKCooldowns()
	OffTank()

	if UnitName("target") and CrowdControlledMob() and not myName == MB_raidLeader then
        ClearTarget()
        return
    end

    local tOfTarget = UnitName("targettarget") or ""
    local tName = UnitName("target") or ""

    local shouldTaunt = tName ~= "" 
        and tOfTarget ~= "" and tOfTarget ~= "Unknown" 
        and UnitIsEnemy("player", "target") 
        and not FindInTable(MB_raidTanks, tOfTarget)

    if shouldTaunt then
        if MB_myOTTarget then
            if tOfTarget ~= myName then
                Warrior:Taunt()
            end
        else
            Warrior:Taunt()
        end
    end

	if MB_myOTTarget then
		if UnitExists("target") and GetRaidTargetIndex("target") and GetRaidTargetIndex("target") == MB_myOTTarget and UnitIsDead("target") then
			MB_myOTTarget = nil
			ClearTarget()
		end
	end

    if not WarriorIsDefensive() then
        WarriorSetDefensive()
        return
    end
	
    AutoAttack()

    if SpellReady("Bloodrage") and UnitMana("player") <= 15 then        
        CastSpellByName("Bloodrage")
    end

    if MB_doInterrupt.Active and SpellReady("Shield Bash") and Warrior:HasShield() then
        if UnitMana("player") >= 10 then
            if ImBusy() then		
                SpellStopCasting()
            end

			CastSpellByName("Shield Bash")
            CdPrint("Interrupting!")
            MB_doInterrupt.Active = false
		end
	end
    
    SelfBuff("Battle Shout")
    
    if UnitMana("player") >= 5 and SpellReady("Revenge") then        
        CastSpellByName("Revenge")
    end
    
    WarriorTankSingleRotation()
end

--[####################################################################################################]--
--[########################################## Multi Code! #############################################]--
--[####################################################################################################]--

local function WarriorMulti()

	GetTarget()
	
    if MB_warriorBinds == "Fury" and not InCombat("player") then
        if MyNameInTable(MB_furysThatCanTank) then				
            FuryGear()
            MB_warriorBinds = nil
        end
    end	

	if not InCombat("target") then
        return
    end
	
    if Instance.AQ40 then
        if TankTarget("Princess Huhuran") and HealthPct("target") <= 0.3 and MB_myHuhuranBoxStrategy then        
            if HaveInBags("Greater Nature Protection Potion") and not IsItemInBagCoolDown("Greater Nature Protection Potion") then				
                UseItemByName("Greater Nature Protection Potion")
            end       
        elseif IsAtSkeram() and SpellReady("Intimidating Shout") then
            CastSpellByName("Intimidating Shout")
        end
    end

    if MobsToAutoBreakFear() and InMeleeRange() then
		SelfBuff("Death Wish") 
	end

	if (MB_mySpecc == "BT" or MB_mySpecc == "MS") then
		
        if MB_useBigCooldowns.Active then			
            Warrior:BigCooldowns()
        end

        if MB_useCooldowns.Active then			
            Warrior:Cooldowns()
        end        
		
		Warrior:DPSMulti()
		return

	elseif (MB_mySpecc == "Prottank" or MB_mySpecc == "Furytank") then

		if Instance.AQ40 then			
			if HasBuffOrDebuff("True Fulfillment", "target", "debuff") then
                TargetByName("The Prophet Skeram")
            end

			AnubisathAlert()
		end

		Warrior:TankMulti()
		return
	end
end

MB_myMultiList["Warrior"] = WarriorMulti

--[####################################################################################################]--
--[######################################## Multi Damage Code! ########################################]--
--[####################################################################################################]--

function Warrior:DPSMulti()

    if not UnitName("target") then
        return
    end

    AutoAttack()
    Warrior:Annihilator()

    if SpellReady("Bloodrage") and UnitMana("player") < 20 then        
        CastSpellByName("Bloodrage")
    end

	if MB_mySpecc == "MS" and SpellReady("Sweeping Strikes") then
        if not WarriorIsBattle() then
            WarriorSetBattle()
            return
        end 

        CastSpellByName("Sweeping Strikes")
        return
	end

    if not WarriorIsBerserker() then
        WarriorSetBerserker()
        return
    end

    if MB_doInterrupt.Active and SpellReady(MB_myInterruptSpell[myClass]) then
        if UnitMana("player") >= 10 then
            if ImBusy() then		
                SpellStopCasting()
            end

            CastSpellByName(MB_myInterruptSpell[myClass])
            CdPrint("Interrupting!")
            MB_doInterrupt.Active = false
            return
        end
    end

    SelfBuff("Battle Shout")

    if not MobsNoSunders() and UnitInRaid("player") and GetNumRaidMembers() > 5 then
        if not HasBuffOrDebuff("Expose Armor", "target", "debuff") and DebuffSunderAmount() < 5 then
            CastSpellByName("Sunder Armor")
        end
    end

    Warrior:UseDPSCooldowns()
    Warrior:Execute()
    
    if MB_mySpecc == "BT" then
        if not IsExcludedWW() then
            if UnitMana("player") >= 25 and SpellReady("Whirlwind") and InMeleeRange() then
                if not SpellReady("Bloodthirst") then
                    CastSpellByName("Whirlwind")
                end
            end
        end
        
        if not SpellReady("Whirlwind") and UnitMana("player") >= 25 then
            if SpellReady("Bloodthirst") and UnitMana("player") >= 30 then            
                CastSpellByName("Bloodthirst")
            end

            if not SpellReady("Bloodthirst") then                
                CastSpellByName("Cleave")
            end
        end
        
    elseif MB_mySpecc == "MS" then
        if not IsExcludedWW() then
            if UnitMana("player") >= 25 and SpellReady("Whirlwind") and InMeleeRange() then
                if not SpellReady("Bloodthirst") then
                    CastSpellByName("Whirlwind")
                end
            end
        end
        
        if not SpellReady("Whirlwind") and UnitMana("player") >= 25 then
            if SpellReady("Mortal Strike") and UnitMana("player") >= 30 then        
                CastSpellByName("Mortal Strike")
            end

            if not SpellReady("Mortal Strike") then                
                CastSpellByName("Cleave")
            end
        end
    end
end

--[####################################################################################################]--
--[######################################### Multi Tank Code! #########################################]--
--[####################################################################################################]--

function Warrior:TankMulti()

	if FindInTable(MB_raidTanks, myName) and HasBuffOrDebuff("Greater Blessing of Salvation", "player", "buff") then		
		CancelBuff("Greater Blessing of Salvation") 
	end

    Warrior:UseTANKCooldowns()
	OffTank()

	if UnitName("target") and CrowdControlledMob() and not myName == MB_raidLeader then
        ClearTarget()
        return
    end

    local tOfTarget = UnitName("targettarget") or ""
    local tName = UnitName("target") or ""

    local shouldTaunt = tName ~= "" 
        and tOfTarget ~= "" and tOfTarget ~= "Unknown" 
        and UnitIsEnemy("player", "target") 
        and not FindInTable(MB_raidTanks, tOfTarget)

    if shouldTaunt then
        if MB_myOTTarget then
            if tOfTarget ~= myName then
                Warrior:Taunt()
            end
        else
            Warrior:Taunt()
        end
    end

    if MB_myOTTarget then
		if UnitExists("target") and GetRaidTargetIndex("target") and GetRaidTargetIndex("target") == MB_myOTTarget and UnitIsDead("target") then
			MB_myOTTarget = nil
			ClearTarget()
		end
	end

    if not WarriorIsDefensive() then
        WarriorSetDefensive()
        return
    end

    AutoAttack()

    if SpellReady("Bloodrage") and UnitMana("player") < 15 then        
        CastSpellByName("Bloodrage")
    end

    if MB_doInterrupt.Active and SpellReady("Shield Bash") and Warrior:HasShield() then
        if UnitMana("player") >= 10 then
            if ImBusy() then		
                SpellStopCasting()
            end

			CastSpellByName("Shield Bash")
            CdPrint("Interrupting!")
            MB_doInterrupt.Active = false
		end
	end

    SelfBuff("Battle Shout")
    
    if UnitMana("player") >= 5 and SpellReady("Revenge") then        
        CastSpellByName("Revenge")
    end

    if Instance.NAXX and IsAtNoth() then
        WarriorTankSingleRotation()
        return

    elseif Instance.BWL and TankTarget("Vaelastrasz the Corrupt") and MB_myVaelastraszBoxStrategy then
        WarriorTankSingleRotation()
        return

    elseif Instance.ONY and TankTarget("Onyxia") and MB_myOnyxiaBoxStrategy then
        WarriorTankSingleRotation()
        return
    end 

    if UnitMana("player") >= 20 then        
        CastSpellByName("Cleave") 
    end
    
    if MB_mySpecc == "Prottank" then
        if SpellReady("Shield Slam") and UnitMana("player") >= 20 and Warrior:HasShield() then        
            CastSpellByName("Shield Slam")
        end

    elseif MB_mySpecc == "Furytank" then
        if SpellReady("Bloodthirst") and UnitMana("player") >= 30 then            
            CastSpellByName("Bloodthirst")
        end	
    end

    if UnitName("target") ~= "Deathknight Understudy" and not HasBuffOrDebuff("Expose Armor", "target", "debuff") then        
        CastSpellByName("Sunder Armor")
    end
end

--[####################################################################################################]--
--[########################################### AOE Code! ##############################################]--
--[####################################################################################################]--

MB_myAOEList["Warrior"] = WarriorMulti

--[####################################################################################################]--
--[###################################### Cooldowns Encounters! #######################################]--
--[####################################################################################################]--

function Warrior:BigCooldowns(useBloodFury)
	if ImBusy() or not InCombat("player") then
		return
	end

    SelfBuff("Recklessness")
	Warrior:Cooldowns(useBloodFury)
end

function Warrior:Cooldowns(useBloodFury)
    local useBloodFury = useBloodFury ~= false

	if ImBusy() or not InCombat("player") then
		return
	end

    SelfBuff("Berserking")

    if useBloodFury then
        SelfBuff("Blood Fury")
    end

    if SpellReady("Death Wish") and UnitMana("player") >= 10 then        
        SelfBuff("Death Wish")
    end

    MeleeTrinkets()
end

function Warrior:UseDPSCooldowns()
    if not (InMeleeRange() or TankTarget("Ragnaros")) then
        return
    end

    if UnitInRaid("player") and GetNumRaidMembers() > 5 then
        if DebuffSunderAmount() == 5 or HasBuffOrDebuff("Expose Armor", "target", "debuff") then
            if SpellReady("Recklessness") and BossIShouldUseRecklessnessOn() then
                Warrior:BigCooldowns()
            end

            if Instance.IsWorldBoss() then
                Warrior:Cooldowns()
                return
            end

            local hpThreshold = (GetNumRaidMembers() <= 20) and 25000 or 100000
            if UnitHealth("target") > hpThreshold then
                Warrior:Cooldowns()
            end
        end
        return
    end

    if SpellReady("Recklessness") and BossIShouldUseRecklessnessOn() then
        Warrior:BigCooldowns(false)
    end

    Warrior:Cooldowns(false)
end

function Warrior:UseTANKCooldowns()
    if ImBusy() or not InCombat("player") then
		return
	end

    if not (InMeleeRange() or TankTarget("Ragnaros")) then
        return
    end

    if Instance.NAXX then
        if TankTarget("Patchwerk") and MB_myPatchwerkBoxStrategy then
            if HealthPct("target") <= 0.05 then
                SelfBuff("Last Stand")

                if Warrior:HasShield() then                     
                    SelfBuff("Shield Wall")
                end
            end

            if HaveInBags("Juju Escape") and not IsItemInBagCoolDown("Juju Escape") then                    
                TargetUnit("player")
                UseItemByName("Juju Escape")
                TargetLastTarget()
            end

            if HaveInBags("Greater Stoneshield Potion") and not IsItemInBagCoolDown("Greater Stoneshield Potion") then                    
                UseItemByName("Greater Stoneshield Potion")
            end

        elseif TankTarget("Maexxna") and MB_myMaexxnaBoxStrategy then
            if MyNameInTable(MB_myMaexxnaMainTank) then
                for _, buff in ipairs({"Prayer of Spirit", "Arcane Brilliance", "Divine Spirit", "Prayer of Shadow Protection"}) do
                    if HasBuffOrDebuff(buff, "player", "buff") then
                        CancelBuff(buff)
                    end
                end
            end
        end

    elseif Instance.AQ40 and TankTarget("Princess Huhuran") then            
        if HealthPct("target") <= MB_myHuhuranTankDefensivePercentage and MB_myHuhuranBoxStrategy then
            SelfBuff("Last Stand")

            if Warrior:HasShield() then                     
                SelfBuff("Shield Wall")
            end
        end

    elseif Instance.BWL then
        if TankTarget("Vaelastrasz the Corrupt") and InMeleeRange() then         
            SelfBuff("Death Wish") 	
            
            if HasBuffOrDebuff("Burning Adrenaline", "player", "debuff") then

                SelfBuff("Last Stand")

                if Warrior:HasShield() then                     
                    SelfBuff("Shield Wall")
                end
            end

        elseif TankTarget("Firemaw") then
            if HaveInBags("Juju Ember") and not IsItemInBagCoolDown("Juju Ember") and not HasBuffOrDebuff("Juju Ember", "player", "buff") then 
                TargetUnit("player")
                UseItemByName("Juju Ember")
                TargetLastTarget()
            end

            if HealthPct("target") <= 0.15 and HealthPct("player") <= 0.3 then
                SelfBuff("Last Stand")

                if Warrior:HasShield() then                     
                    SelfBuff("Shield Wall")
                end                    
            end

        elseif TankTarget("Chromaggus") and HealthPct("target") <= 0.07 and HealthPct("player") <= 0.3 then
            SelfBuff("Last Stand")

            if Warrior:HasShield() then                     
                SelfBuff("Shield Wall")
            end
        end
    
    elseif Instance.AQ20 and TankTarget("Ossirian the Unscarred") then
        if HealthPct("target") <= MB_myOssirianTankDefensivePercentage and MB_myOssirianBoxStrategy then
            if HealthPct("player") <= 0.3 then
                
                SelfBuff("Last Stand")

                if Warrior:HasShield() then                     
                    SelfBuff("Shield Wall")
                end
            end
        end
    end

    if HealthPct("player") <= 0.25 then			
        if ItemNameOfEquippedSlot(13) == "Lifegiving Gem" and not TrinketOnCD(13) then 
            use(13)

        elseif ItemNameOfEquippedSlot(14) == "Lifegiving Gem" and not TrinketOnCD(14) then 
            use(14)
        end
    end

    if not (TankTarget("Patchwerk") or TankTarget("Maexxna")) then			
        if HealthPct("player") <= 0.2 then				
            SelfBuff("Last Stand") 
        end
    end

    if KnowSpell("Concussion Blow") and SpellReady("Concussion Blow") and StunnableMob() then	
        CastSpellByName("Concussion Blow")
    end

    if SpellReady("Disarm") and not HasBuffOrDebuff("Disarm", "target", "debuff") then
        local name = UnitName("target")
        local hp = HealthPct("target")

        if name == "Gurubashi Axe Thrower"
            or (hp < 0.5 and (name == "Infectious Ghoul" or name == "Plagued Ghoul"))
            or (hp <= 0.21 and (name == "Anubisath Sentinel" or name == "Anubisath Defender")) then
            CastSpellByName("Disarm")
        end
    end

    if HealthPct("player") < 0.85 and UnitMana("player") >= 20 and Warrior:HasShield() then				
        CastSpellByName("Shield Block") 
    end

    if UnitName("target") ~= "Emperor Vek\'nilash" or UnitName("target") ~= "Emperor Vek\'lor" then				
        if not HasBuffOrDebuff("Demoralizing Shout", "target", "debuff") and UnitMana("player") >= 20 then					
            CastSpellByName("Demoralizing Shout")
        end
    end

    if UnitInRaid("player") and GetNumRaidMembers() > 5 then
        if DebuffSunderAmount() == 5 or HasBuffOrDebuff("Expose Armor", "target", "debuff") then
            SelfBuff("Berserking")
            MeleeTrinkets()
        end
        return
    end

    SelfBuff("Berserking")
    MeleeTrinkets()
end

--[####################################################################################################]--
--[########################################## Helper Code! ############################################]--
--[####################################################################################################]--

local lastAnnihilatorTime = 0

function Warrior:Annihilator()
    if TableLength(MB_raidAssist.Warrior.AnnihilatorWeavers) == 0 or not MB_raidAssist.Warrior.Active or IsAtSkeram() then
        return
    end
    
    local currentTime = GetTime()
    if currentTime - lastAnnihilatorTime < 1.5 then
        return
    end
    
    local function equipWeapon(slot, targetWeapon)
        if ItemNameOfEquippedSlot(slot) ~= targetWeapon then
            if ItemNameOfEquippedSlot(slot) then
                RunLine("/unequip "..ItemNameOfEquippedSlot(slot))
            end

            local escapedWeapon = string.gsub(targetWeapon, ",", "%%,")
            RunLine("/equip "..escapedWeapon)
        end
    end
    
    for _, name in pairs(MB_raidAssist.Warrior.AnnihilatorWeavers) do
        if myName == name then
            local mh, oh
            if Instance.IsWorldBoss() then
                if DebuffAmountShatter() == 3 then
                    mh = GetWeaverWeapon(name, "NMH")
                    oh = GetWeaverWeapon(name, "NOH")
                else
                    mh = GetWeaverWeapon(name, "BMH")
                    oh = GetWeaverWeapon(name, "BOH")
                end
            else
                mh = GetWeaverWeapon(name, "NMH")
                oh = GetWeaverWeapon(name, "NOH")
            end
            
            equipWeapon(16, mh)
            equipWeapon(17, oh)

            lastAnnihilatorTime = currentTime
            break
        end
    end
end

local function ImpExecute()
    local TalentsIn, TalentsInA

    _, _, _, _, TalentsIn = GetTalentInfo(2, 10)
	if TalentsIn > 1 then
		return true
    end
	return nil	
end

function Warrior:Execute()
    local targetName = UnitName("target")
    if not targetName then
        return
    end

    local targetType = UnitCreatureType("target")
    local slot13, slot14 = ItemNameOfEquippedSlot(13), ItemNameOfEquippedSlot(14)

    local undeadBonus = 0

    if (targetType == "Undead" or targetType == "Demon") and 
       (slot13 == "Mark of the Champion" or slot14 == "Mark of the Champion") then
        undeadBonus = undeadBonus + 150
    end

    if (targetType == "Undead" or targetType == "Demon") and 
       (slot13 == "Seal of the Dawn" or slot14 == "Seal of the Dawn") then
        undeadBonus = undeadBonus + 81
    end

    local a, b, c = UnitAttackPower("player")
    local apTotal = a + b + c + undeadBonus
    local btDamage = apTotal * 0.45
    local impExeValue = ImpExecute() and 900 or 820

    if HealthPct("target") < 0.20 then
        if impExeValue >= btDamage then
            CastSpellByName("Execute")
        elseif btDamage >= impExeValue and SpellReady("Bloodthirst") then
            CastSpellByName("Bloodthirst")
        else
            CastSpellByName("Execute")
        end
    end
end

function Warrior:HasShield()
	local offhandLink = GetInventoryItemLink("player", GetInventorySlotInfo("SecondaryHandSlot"))
	if offhandLink then
		local itemId, permEnchant, tempEnchant, suffix, itemName = string.gfind(offhandLink, "|Hitem:(.-):(.-):(.-):(.-)|h%[(.-)%]|h")()
		local _, _, _, _, _, itemType = GetItemInfo(itemId)
		return itemType == "Shields"
	else
		return false
	end
end

function Warrior:Taunt()

	if SpellReady("Taunt") then
		WarriorSetDefensive()
		CastSpellByName("Taunt")
		return
	end

	if IamFocus() then
        return
    end
	
    if MB_mySpecc ~= "Prottank" then
        return
    end

	if SpellReady("Mocking Blow") and UnitMana("player") >= 10 then
		if WarriorIsBattle() then
			CastSpellByName("Mocking Blow")
		else
			WarriorSetBattle()
		end
	end
end