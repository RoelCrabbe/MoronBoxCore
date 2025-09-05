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
local ImFocus = mb_imFocus
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
local SpellCoolDown = mb_spellCoolDown
local StunnableMob = mb_stunnableMob
local TankTarget = mb_tankTarget
local TrinketOnCD = mb_trinketOnCD
local UseFromBags = mb_useFromBags
local UseNaturePotsOnHuhuran = mb_useNaturePotsOnHuhuran
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
--[####################################################################################################]--
--[####################################################################################################]--

local removeBuffs = {
    ["Arcane Intellect"]    =   "Arcane Intellect",
    ["Arcane Brilliance"]   =   "Arcane Brilliance",
    ["Divine Spirit"]       =   "Divine Spirit",
    ["Prayer of Spirit"]    =   "Prayer of Spirit",
    ["Slip'kik's Savvy"]    =   "Slip'kik's Savvy",
    ["Fury of Ragnaros"]    =   "Fury of Ragnaros",
    ["Very Berry Cream"]    =   "Very Berry Cream",
    ["Sweet Surprise"]      =   "Sweet Surprise",
}

local function WarriorCancelAuras()
    for itemName, buffName in pairs(removeBuffs) do
        if HasBuffOrDebuff(itemName, "player", "buff") then
            CancelBuff(buffName)
        end
    end
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local function HasBattleShout()
    local buffName = "Battle Shout"
    local buffTexture = "Interface\\Icons\\Ability_Warrior_BattleShout"
    local tooltip = MMBTooltip
    local textleft1 = getglobal(tooltip:GetName().."TextLeft1")
    local unit = "player"

    for i = 1, 32 do
        local texture = UnitBuff(unit, i)
        if not texture then
            break
        end

        if texture == buffTexture then
            tooltip:SetOwner(UIParent, "ANCHOR_NONE")
            tooltip:SetUnitBuff(unit, i)

            local line1 = textleft1:GetText()
            if strfind(strlower(line1 or ""), strlower(buffName)) then
                local textLeft2 = getglobal(tooltip:GetName().."TextLeft2")
                local line2 = textLeft2 and textLeft2:GetText() or ""
                tooltip:Hide()

                if not strfind(line2, "400") then
                    return true
                end
            end
        end
    end

    tooltip:Hide()
    return false
end

local function ImpExecute()
    local _, _, _, _, TalentsIn = GetTalentInfo(2, 10)
    return TalentsIn > 1
end

local function ImpDemo()
    local _, _, _, _, TalentsIn = GetTalentInfo(2, 3)
    return TalentsIn > 3
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local function UsePotionsWhenPossible(potion)
    if not HaveInBags(potion) and not IsItemInBagCoolDown(potion) then
        return
    end

    if not Instance:IsInRaid() then
        return
    end

    if HasBuffOrDebuff(potion, "player", "buff") then
        return
    end

    if (sandTime == nil or GetTime() - sandTime > 3) then
        sandTime = GetTime()
        UseFromBags(potion)
    end
end

local function UseJujuWhenPossible(juju)
    if not HaveInBags(juju) and not IsItemInBagCoolDown(juju) then
        return
    end

    if not Instance:IsInRaid() then
        return
    end

    if HasBuffOrDebuff(juju, "player", "buff") then
        return
    end

    TargetUnit("player")

    if (sandTime == nil or GetTime() - sandTime > 3) then
        sandTime = GetTime()
        UseFromBags(juju)
    end

    TargetLastTarget()
end

local function UseSpeedRunPotsWhenPossible(potion)
    if not MB_mySpeedRunStrategy then
        return
    end

    UsePotionsWhenPossible(potion)
end

local function UseSpeedRunJujusWhenPossible(potion)
    if not MB_mySpeedRunStrategy then
        return
    end

    UseJujuWhenPossible(potion)
end

--[####################################################################################################]--
--[########################################## Single Code! ############################################]--
--[####################################################################################################]--

local function WarriorSingle()
    local myRage = UnitMana("player")

	GetTarget()
	WarriorCancelAuras()

    if MB_warriorBinds == "Fury" and not InCombat("player") then
        if MyNameInTable(MB_furysThatCanTank) then				
            FuryGear()
            MB_warriorBinds = nil
        end
    end	

	if not InCombat("target") then
        return
    end

    if Instance.AQ40() then
        UseNaturePotsOnHuhuran()

        if IsAtSkeram() and SpellReady("Intimidating Shout") then
            CastSpellByName("Intimidating Shout")
        end
    end

    if MobsToAutoBreakFear() and InMeleeRange() then
		SelfBuff("Death Wish") 
	end

	if (MB_mySpecc == "BT") then		
        if MB_useBigCooldowns.Active then			
            Warrior:BigDPSCooldowns(myRage)
        elseif MB_useCooldowns.Active then			
            Warrior:DPSCooldowns(myRage)
        end

		Warrior:DPSSingle(myRage)
		return

	elseif (MB_mySpecc == "Prottank" or MB_mySpecc == "Furytank") then
		if Instance.AQ40() then			
			if HasBuffOrDebuff("True Fulfillment", "target", "debuff") then
                TargetByName("The Prophet Skeram")
            end

			AnubisathAlert()
		end

		Warrior:TankSingle(myRage)
		return
	end
end

MB_mySingleList["Warrior"] = WarriorSingle

--[####################################################################################################]--
--[####################################### Single Damage Code! ########################################]--
--[####################################################################################################]--

local function WarriorDPSSingleRotation(myRage)
    local mainSpell = MB_mySpecc == "BT" and "Bloodthirst" or "Mortal Strike"
    local mainSpellCD = SpellCoolDown(mainSpell)
    local wwSpellCD = SpellCoolDown("Whirlwind")
    local canUseHam = mainSpellCD > 1.35 and wwSpellCD > 1.35

    if InMeleeRange() then
        if SpellReady(mainSpell) and myRage >= 30 then    
            CastSpellByName(mainSpell)
        end

        if SpellReady("Whirlwind") and myRage >= 25 then
            if mainSpellCD > 0.33 and not IsExcludedWW() then
                CastSpellByName("Whirlwind")
            end
        end
    end

    if Faction.IsHorde() and canUseHam and myRage >= 84 then
        CastSpellByName("Hamstring")
    end

    if myRage >= 54 then
        CastSpellByName("Heroic Strike")
    end
end

function Warrior:DPSSingle(myRage)

    if not WarriorIsBerserker() then
        WarriorSetBerserker()
        return
    end

    if not UnitName("target") then
        return
    end

    AutoAttack()
    Warrior:Annihilator()

    if SpellReady("Bloodrage") and myRage < 20 then        
        CastSpellByName("Bloodrage")
    end

    if MB_doInterrupt.Active and SpellReady(MB_myInterruptSpell[myClass]) then
        if myRage >= 10 then
            if ImBusy() then		
                SpellStopCasting()
            end

            CastSpellByName(MB_myInterruptSpell[myClass])
            CdPrint("Interrupting!")
            MB_doInterrupt.Active = false
            return
        end
    end

    Warrior:BattleShout()
    Warrior:Sunder()
    Warrior:UseDPSCooldowns(myRage)
    Warrior:Execute()

    WarriorDPSSingleRotation(myRage)
end

--[####################################################################################################]--
--[######################################## Single Tank Code! #########################################]--
--[####################################################################################################]--

local function WarriorTankSingleRotation(myRage)
    local tName = UnitName("target")
    local sRage = ImFocus() and 54 or 46

    if InMeleeRange() then
        if SpellReady("Concussion Blow") and StunnableMob() and myRage >= 15 then
            CastSpellByName("Concussion Blow")
        end

        if HealthPct("player") < 0.85 and Warrior:HasShield() and myRage >= 20 then	
            CastSpellByName("Shield Block")
        end

        if MB_mySpecc == "Prottank" then
            if SpellReady("Shield Slam") and myRage >= 20 and Warrior:HasShield() then  
                CastSpellByName("Shield Slam")
            end
        elseif MB_mySpecc == "Furytank" then
            if SpellReady("Bloodthirst") and myRage >= 30 then          
                CastSpellByName("Bloodthirst")
            end
        end

        Warrior:Disarm(myRage)
        Warrior:DemoShout(myRage)
    end

    if HasBuffOrDebuff("Expose Armor", "target", "debuff") then
        if not SpellReady("Bloodthirst") and myRage >= 23 then
            CastSpellByName("Heroic Strike")
        elseif myRage >= 42 then
            CastSpellByName("Heroic Strike")
        end
        return
    end

    if tName ~= "Deathknight Understudy" and myRage >= sRage and DebuffSunderAmount() == 5 then
        CastSpellByName("Sunder Armor")
    elseif myRage >= 42 then
        CastSpellByName("Heroic Strike")
    end
end

function Warrior:TankSingle(myRage)

	if FindInTable(MB_raidTanks, myName) and HasBuffOrDebuff("Greater Blessing of Salvation", "player", "buff") then		
		CancelBuff("Greater Blessing of Salvation") 
	end

    Warrior:TANKSurvival()
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

    if SpellReady("Bloodrage") and myRage < 15 then        
        CastSpellByName("Bloodrage")
    end

    if MB_doInterrupt.Active and SpellReady("Shield Bash") and Warrior:HasShield() then
        if myRage >= 10 then
            if ImBusy() then
                SpellStopCasting()
            end

			CastSpellByName("Shield Bash")
            CdPrint("Interrupting!")
            MB_doInterrupt.Active = false
		end
	end

    Warrior:BattleShout()

    if SpellReady("Revenge") and myRage >= 5 then        
        CastSpellByName("Revenge")
    end

    Warrior:UseTANKCooldowns(myRage)
    WarriorTankSingleRotation(myRage)
end

--[####################################################################################################]--
--[########################################## Multi Code! #############################################]--
--[####################################################################################################]--

local function WarriorMulti()
    local myRage = UnitMana("player")

	GetTarget()
    WarriorCancelAuras()

    if MB_warriorBinds == "Fury" and not InCombat("player") then
        if MyNameInTable(MB_furysThatCanTank) then				
            FuryGear()
            MB_warriorBinds = nil
        end
    end	

	if not InCombat("target") then
        return
    end
	
    if Instance.AQ40() then
        UseNaturePotsOnHuhuran()

        if IsAtSkeram() and SpellReady("Intimidating Shout") then
            CastSpellByName("Intimidating Shout")
        end
    end

    if MobsToAutoBreakFear() and InMeleeRange() then
		SelfBuff("Death Wish") 
	end

	if (MB_mySpecc == "BT") then		
        if MB_useBigCooldowns.Active then			
            Warrior:BigDPSCooldowns(myRage)
        elseif MB_useCooldowns.Active then			
            Warrior:DPSCooldowns(myRage)
        end  
		
		Warrior:DPSMulti(myRage)
		return

	elseif (MB_mySpecc == "Prottank" or MB_mySpecc == "Furytank") then
		if Instance.AQ40() then			
			if HasBuffOrDebuff("True Fulfillment", "target", "debuff") then
                TargetByName("The Prophet Skeram")
            end

			AnubisathAlert()
		end

		Warrior:TankMulti(myRage)
		return
	end
end

MB_myMultiList["Warrior"] = WarriorMulti

--[####################################################################################################]--
--[######################################## Multi Damage Code! ########################################]--
--[####################################################################################################]--

local function WarriorDPSMultiRotation(myRage)
    local mainSpell = MB_mySpecc == "BT" and "Bloodthirst" or "Mortal Strike"
    local mainSpellCD = SpellCoolDown(mainSpell)
    local wwSpellCD = SpellCoolDown("Whirlwind")
    local canUseHam = mainSpellCD > 1.35 and wwSpellCD > 1.35

    if IsExcludedWW() then
        WarriorDPSSingleRotation(myRage)
        return
    end

    if InMeleeRange() and SpellReady("Whirlwind") and myRage >= 25 then        
        CastSpellByName("Whirlwind")
    end

    if Faction.IsHorde() and canUseHam and myRage >= 89 then
        CastSpellByName("Hamstring")
    end

    if myRage >= 25 then
        CastSpellByName("Cleave")
    end

    if InMeleeRange() and SpellReady(mainSpell) and myRage >= 30 then
        if wwSpellCD > 0.33 then
            CastSpellByName(mainSpell)
        end
    end
end

function Warrior:DPSMulti(myRage)

    if not WarriorIsBerserker() then
        WarriorSetBerserker()
        return
    end

    if not UnitName("target") then
        return
    end

    AutoAttack()
    Warrior:Annihilator()

    if SpellReady("Bloodrage") and myRage < 20 then        
        CastSpellByName("Bloodrage")
    end

    if MB_doInterrupt.Active and SpellReady(MB_myInterruptSpell[myClass]) then
        if myRage >= 10 then
            if ImBusy() then		
                SpellStopCasting()
            end

            CastSpellByName(MB_myInterruptSpell[myClass])
            CdPrint("Interrupting!")
            MB_doInterrupt.Active = false
            return
        end
    end

    Warrior:BattleShout()
    Warrior:Sunder()
    Warrior:UseDPSCooldowns(myRage)
    Warrior:Execute()
    
    WarriorDPSMultiRotation(myRage)
end

--[####################################################################################################]--
--[######################################### Multi Tank Code! #########################################]--
--[####################################################################################################]--

local function WarriorTankMultiRotation(myRage)
    local tName = UnitName("target")
    local sRage = ImFocus() and 54 or 46

    if InMeleeRange() then
        if SpellReady("Concussion Blow") and StunnableMob() and myRage >= 15 then
            CastSpellByName("Concussion Blow")
        end

        if HealthPct("player") < 0.85 and Warrior:HasShield() and myRage >= 20 then	
            CastSpellByName("Shield Block")
        end

        if MB_mySpecc == "Prottank" then
            if SpellReady("Shield Slam") and myRage >= 20 and Warrior:HasShield() then  
                CastSpellByName("Shield Slam")
            end
        elseif MB_mySpecc == "Furytank" then
            if SpellReady("Bloodthirst") and myRage >= 30 then          
                CastSpellByName("Bloodthirst")
            end
        end

        Warrior:Disarm(myRage)
        Warrior:DemoShout(myRage)
    end

    if HasBuffOrDebuff("Expose Armor", "target", "debuff") then
        if not SpellReady("Bloodthirst") and myRage >= 28 then
            CastSpellByName("Cleave")
        elseif myRage >= 47 then
            CastSpellByName("Cleave")
        end
        return
    end

    if tName ~= "Deathknight Understudy" and myRage >= sRage and DebuffSunderAmount() == 5 then
        CastSpellByName("Sunder Armor")
    elseif myRage >= 23 then
        CastSpellByName("Cleave")
    end
end

function Warrior:TankMulti(myRage)

	if FindInTable(MB_raidTanks, myName) and HasBuffOrDebuff("Greater Blessing of Salvation", "player", "buff") then		
		CancelBuff("Greater Blessing of Salvation") 
	end

    Warrior:TANKSurvival()
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

    if SpellReady("Bloodrage") and myRage < 15 then        
        CastSpellByName("Bloodrage")
    end

    if MB_doInterrupt.Active and SpellReady("Shield Bash") and Warrior:HasShield() then
        if myRage >= 10 then
            if ImBusy() then		
                SpellStopCasting()
            end

			CastSpellByName("Shield Bash")
            CdPrint("Interrupting!")
            MB_doInterrupt.Active = false
		end
	end

    Warrior:BattleShout()
    
    if SpellReady("Revenge") and myRage >= 5 then        
        CastSpellByName("Revenge")
    end

    Warrior:UseTANKCooldowns(myRage)

    if Instance.Naxx() and IsAtNoth() then
        WarriorTankSingleRotation(myRage)
        return
    elseif Instance.BWL() and TankTarget("Vaelastrasz the Corrupt") and MB_myVaelastraszBoxStrategy then
        WarriorTankSingleRotation(myRage)
        return
    elseif Instance.ONY() and TankTarget("Onyxia") and MB_myOnyxiaBoxStrategy then
        WarriorTankSingleRotation(myRage)
        return
    end 
    
    WarriorTankMultiRotation(myRage)
end

--[####################################################################################################]--
--[########################################### AOE Code! ##############################################]--
--[####################################################################################################]--

MB_myAOEList["Warrior"] = WarriorMulti

--[####################################################################################################]--
--[######################################### DPS Cooldowns! ###########################################]--
--[####################################################################################################]--

local function CanUseCooldowns()
    if ImBusy() or not InCombat("player") then
        return false
    end

    return (TankTarget("Ragnaros") or InMeleeRange())
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function Warrior:BigDPSCooldowns(myRage)
    if not CanUseCooldowns() then
        return
    end

    SelfBuff("Recklessness")
	Warrior:DPSCooldowns(myRage)
end

function Warrior:DPSCooldowns(myRage)
    if not CanUseCooldowns() then
        return
    end

    if SpellReady("Death Wish") and myRage >= 10 then
        SelfBuff("Death Wish")
    end

    if Instance.MC() and TankTarget("Baron Geddon") then
        UseSpeedRunPotsWhenPossible("Frozen Rune")
    end

    if HasBuffOrDebuff("Death Wish", "player", "debuff") then
        SelfBuff("Berserking")
        SelfBuff("Blood Fury")
        UseSpeedRunPotsWhenPossible("Mighty Rage Potion")
    end

    MeleeTrinkets()
end

function Warrior:UseDPSCooldowns(myRage)
    if not CanUseCooldowns() then
        return
    end

    if SpellReady("Recklessness") and BossIShouldUseRecklessnessOn() then
        Warrior:BigDPSCooldowns(myRage)
    end

    if UnitInRaid("player") and GetNumRaidMembers() > 5 then
        local hpThreshold = (GetNumRaidMembers() <= 20) and 25000 or 100000
    
        if DebuffSunderAmount() == 5 or HasBuffOrDebuff("Expose Armor", "target", "debuff") then
            if Instance.IsWorldBoss() then
                Warrior:DPSCooldowns(myRage)
            elseif UnitHealth("target") > hpThreshold then
                Warrior:DPSCooldowns(myRage)
            end
        end
    else
        Warrior:DPSCooldowns(myRage)
    end
end

--[####################################################################################################]--
--[######################################## Tank Cooldowns! ###########################################]--
--[####################################################################################################]--

function Warrior:BigTANKCooldowns()
    if Warrior:HasShield() then
        SelfBuff("Shield Wall")
    end

    SelfBuff("Last Stand")
end

function Warrior:TANKSurvival()
    if not CanUseCooldowns() then
        return
    end

    if Instance.Naxx() and TankTarget("Patchwerk") and MB_myPatchwerkBoxStrategy then
        if HealthPct("target") <= 0.05 then
            Warrior:BigTANKCooldowns()
        end

        UseJujuWhenPossible("Juju Escape")
        UsePotionsWhenPossible("Greater Stoneshield Potion")

    elseif Instance.AQ40() and TankTarget("Princess Huhuran") and MB_myHuhuranBoxStrategy then            
        if HealthPct("target") <= MB_myHuhuranTankDefensivePercentage then
            Warrior:BigTANKCooldowns()
        end

    elseif Instance.BWL() and TankTarget("Vaelastrasz the Corrupt") and HasBuffOrDebuff("Burning Adrenaline", "player", "debuff") then
        Warrior:BigTANKCooldowns()

    elseif Instance.BWL() and TankTarget("Firemaw") then
        if HealthPct("target") <= 0.15 and HealthPct("player") <= 0.3 then
            Warrior:BigTANKCooldowns()                 
        end

        UseJujuWhenPossible("Juju Ember")

    elseif Instance.BWL() and TankTarget("Chromaggus") and HealthPct("target") <= 0.07 and HealthPct("player") <= 0.3 then
        Warrior:BigTANKCooldowns()

    elseif Instance.AQ20() and TankTarget("Ossirian the Unscarred") and MB_myOssirianBoxStrategy then
        if HealthPct("target") <= MB_myOssirianTankDefensivePercentage then
            if HealthPct("player") <= 0.3 then                
                Warrior:BigTANKCooldowns()
            end
        end
    else        
        if HealthPct("player") <= 0.2 then				
            SelfBuff("Last Stand") 
        end
    end

    if HealthPct("player") <= 0.25 then
        if ItemNameOfEquippedSlot(13) == "Lifegiving Gem" and not TrinketOnCD(13) then
            use(13)
        elseif ItemNameOfEquippedSlot(14) == "Lifegiving Gem" and not TrinketOnCD(14) then
            use(14)
        end
    end
end

function Warrior:TANKCooldowns(myRage)
    if not CanUseCooldowns() then
        return
    end

    if SpellReady("Death Wish") and myRage >= 10 and MB_mySpeedRunStrategy then
        SelfBuff("Death Wish")
    end

    if Instance.MC() and TankTarget("Baron Geddon") then
        UseSpeedRunPotsWhenPossible("Frozen Rune")
    end

    if HasBuffOrDebuff("Death Wish", "player", "debuff") then
        SelfBuff("Berserking")
        UseSpeedRunPotsWhenPossible("Greater Stoneshield Potion")
    end

    MeleeTrinkets()
end

function Warrior:UseTANKCooldowns(myRage)
    if not CanUseCooldowns() then
        return
    end

    if UnitInRaid("player") and GetNumRaidMembers() > 5 then
        local hpThreshold = (GetNumRaidMembers() <= 20) and 25000 or 100000

        if DebuffSunderAmount() == 5 or HasBuffOrDebuff("Expose Armor", "target", "debuff") then
            if Instance.IsWorldBoss() then
                Warrior:TANKCooldowns(myRage)
            elseif UnitHealth("target") > hpThreshold then
                Warrior:TANKCooldowns(myRage)
            end
        end
    else
        Warrior:TANKCooldowns(myRage)
    end
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

function Warrior:Execute()
    if HealthPct("target") >= 0.20 then
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

    if impExeValue >= btDamage then
        CastSpellByName("Execute")
    elseif btDamage >= impExeValue and SpellReady("Bloodthirst") then
        CastSpellByName("Bloodthirst")
    else
        CastSpellByName("Execute")
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
    local myRage = UnitMana("player")

    if Instance.MC() and TankTarget("Magmadar") then
        return
    end

	if SpellReady("Taunt") then
		WarriorSetDefensive()
		CastSpellByName("Taunt")
		return
	end

	if ImFocus() then
        return
    end
	
    if MB_mySpecc ~= "Prottank" then
        return
    end

	if SpellReady("Mocking Blow") and myRage >= 10 then
		if WarriorIsBattle() then
			CastSpellByName("Mocking Blow")
		else
			WarriorSetBattle()
		end
	end
end

function Warrior:Disarm(myRage)
    local tName = UnitName("target")
    local tHealthPct = HealthPct("target")

    if not SpellReady("Disarm") then
        return
    end

    if HasBuffOrDebuff("Disarm", "target", "debuff") then
        return
    end

    if not (tName == "Gurubashi Axe Thrower"
        or (tHealthPct < 0.5 and (tName == "Infectious Ghoul" or tName == "Plagued Ghoul"))
        or (tHealthPct <= 0.21 and (tName == "Anubisath Sentinel" or tName == "Anubisath Defender"))) then
        return
    end

    if myRage >= 20 then
        CastSpellByName("Disarm")
    end
end

function Warrior:DemoShout(myRage)
    local tName = UnitName("target")

    if (tName == "Emperor Vek\'nilash" or tName == "Emperor Vek\'lor") then
        return
    end

    if ImFocus() and not ImpDemo() then
        return
    end

    if not HasBuffOrDebuff("Demoralizing Shout", "target", "debuff") and myRage >= 20 then					
        CastSpellByName("Demoralizing Shout")
    end
end

function Warrior:BattleShout()
    if SpellReady("Battle Shout") and not HasBattleShout() then
        CastSpellByName("Battle Shout")
    end
end

function Warrior:Sunder()
    if MobsNoSunders() then
        return
    end

    if not UnitInRaid("player") or GetNumRaidMembers() <= 5 then
        return
    end

    if not HasBuffOrDebuff("Expose Armor", "target", "debuff")
        and DebuffSunderAmount() < 5 then
        CastSpellByName("Sunder Armor")
    end
end