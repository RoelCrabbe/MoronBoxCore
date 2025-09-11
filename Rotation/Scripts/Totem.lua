--[####################################################################################################]--
--[######################################## START TOTEMS CODE! ########################################]--
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

local CastTotem = mb_castTotem
local CoolDownCast = mb_coolDownCast
local DropTotems = mb_dropTotems
local HasBuffOrDebuff = mb_hasBuffOrDebuff
local InCombat = mb_inCombat
local InMeleeRange = mb_inMeleeRange
local IsAtLoatheb = mb_isAtLoatheb
local IsFireBoss = mb_isFireBoss
local IsInGroup = mb_isInGroup
local IsNatureBoss = mb_isNatureBoss
local IsPoisonBoss = mb_isPoisonBoss
local IsTremorBoss = mb_isTremorBoss
local MobsNoTotems = mb_mobsNoTotems
local MyGroupClassOrder = mb_myGroupClassOrder
local NumberOfClassInParty = mb_numberOfClassInParty
local TankTarget = mb_tankTarget
local TankTargetHealth = mb_tankTargetHealth

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local function ChooseAirTotem()

    if Instance.NAXX() then
        if TankTarget("Patchwerk") and MB_myPatchwerkBoxStrategy then           
            if IsInGroup(MB_myFirstPWSoaker) or IsInGroup(MB_mySecondPWSoaker) or IsInGroup(MB_myThirdPWSoaker) then                
                if MyGroupClassOrder() == 1 then return "Grace of Air Totem" end
                if MyGroupClassOrder() == 2 then return "Windfury Totem" end
            end
		end

    elseif Instance.AQ40() and TankTarget("Princess Huhuran") and TankTargetHealth() <= 0.4 then

        if MyGroupClassOrder() == 1 then return "Nature Resistance Totem" end

        if MB_druidTankInParty or MB_warriorTankInParty then
            if MyGroupClassOrder() == 2 then return "Windfury Totem" end
            if MyGroupClassOrder() == 3 then return "Grace of Air Totem" end
        
        elseif NumberOfClassInParty("Warrior") > 0 or NumberOfClassInParty("Rogue") > 0 then
            if MyGroupClassOrder() == 2 then return "Windfury Totem" end
            if MyGroupClassOrder() == 3 then return "Grace of Air Totem" end

        elseif NumberOfClassInParty("Mage") > 0 or NumberOfClassInParty("Warlock") > 0 then
            if MyGroupClassOrder() == 2 then return "Tranquil Air Totem" end
            if MyGroupClassOrder() == 3 then return "Grace of Air Totem" end
        end

    elseif Instance.AQ20() and TankTarget("Ossirian the Unscarred") and MB_myOssirianBoxStrategy then

        if IsInGroup(MB_myOssirianMainTank) then
            if MyGroupClassOrder() == 1 then return "Grounding Totem" end
            if MyGroupClassOrder() == 2 then return "Grounding Totem" end
            if MyGroupClassOrder() == 3 then return "Grace of Air Totem" end
            if MyGroupClassOrder() == 4 then return "Windfury Totem" end
        end
    end

	if IsNatureBoss() then
        if MyGroupClassOrder() == 2 then return "Nature Resistance Totem" end
	end

	if MB_druidTankInParty or MB_warriorTankInParty then
		if MyGroupClassOrder() == 1 then return "Windfury Totem" end
		if MyGroupClassOrder() == 2 then return "Grace of Air Totem" end

	elseif NumberOfClassInParty("Warrior") > 0 or NumberOfClassInParty("Rogue") > 0 then		
		if MyGroupClassOrder() == 1 then return "Windfury Totem" end
		if MyGroupClassOrder() == 2 then return "Grace of Air Totem" end
			
	elseif NumberOfClassInParty("Mage") > 0 or NumberOfClassInParty("Warlock") > 0 then		
		if MyGroupClassOrder() == 1 then return "Tranquil Air Totem" end
		if MyGroupClassOrder() == 2 then return "Grace of Air Totem" end
	end

	if MyGroupClassOrder() == 1 then return "Tranquil Air Totem" end
	if MyGroupClassOrder() == 2 then return "Grace of Air Totem" end
end

local function ChooseEarthTotem()

    if Instance.ONY() and TankTarget("Onyxia") and TankTargetHealth() >= 0.4 then

        if MB_druidTankInParty or MB_warriorTankInParty then
            if MyGroupClassOrder() == 1 then return "Strength of Earth Totem" end
            if MyGroupClassOrder() == 2 then return "Stoneskin Totem" end
        
        elseif NumberOfClassInParty("Warrior") > 0 or NumberOfClassInParty("Rogue") > 0 then    
            if MyGroupClassOrder() == 1 then return "Strength of Earth Totem" end
            if MyGroupClassOrder() == 2 then return "Stoneskin Totem" end
        
        elseif NumberOfClassInParty("Mage") > 0 or NumberOfClassInParty("Warlock") > 0 then    
            if MyGroupClassOrder() == 1 then return "Stoneskin Totem" end
            if MyGroupClassOrder() == 2 then return "Strength of Earth Totem" end
        end
    end

	if IsTremorBoss() then
		if MyGroupClassOrder() == 1 then return "Tremor Totem" end
	end

	if MB_druidTankInParty or MB_warriorTankInParty then 
		if MyGroupClassOrder() == 1 then return "Strength of Earth Totem" end
		if MyGroupClassOrder() == 2 then return "Stoneskin Totem" end
	
	elseif NumberOfClassInParty("Warrior") > 0 or NumberOfClassInParty("Rogue") > 0 then
		if MyGroupClassOrder() == 1 then return "Strength of Earth Totem" end
		if MyGroupClassOrder() == 2 then return "Stoneskin Totem" end
	
	elseif NumberOfClassInParty("Mage") > 0 or NumberOfClassInParty("Warlock") > 0 then
		if MyGroupClassOrder() == 1 then return "Stoneskin Totem" end
		if MyGroupClassOrder() == 2 then return "Strength of Earth Totem" end
	end

	if MyGroupClassOrder() == 1 then return "Stoneskin Totem" end
	if MyGroupClassOrder() == 2 then return "Strength of Earth Totem" end
end

local function ChooseWaterTotem()

	if IsPoisonBoss() then	
        if Instance.AQ40() then
			if MyGroupClassOrder() == 1 then return "Healing Stream Totem" end
			if MyGroupClassOrder() == 2 then return "Mana Spring Totem" end

		elseif Instance.BWL() and TankTarget("Chromaggus") then
			if MyGroupClassOrder() == 1 then return "Poison Cleansing Totem" end
			if MyGroupClassOrder() == 2 then return "Mana Spring Totem" end
		end		

	elseif IsFireBoss() then		
		if MyGroupClassOrder() == 1 then return "Fire Resistance Totem" end
		if MyGroupClassOrder() == 2 then return "Mana Spring Totem" end

	elseif IsAtLoatheb() then
		if MyGroupClassOrder() == 1 then return "Healing Stream Totem" end
		if MyGroupClassOrder() == 2 then return "Mana Spring Totem" end
	end

	if MyGroupClassOrder() == 1 then return "Mana Spring Totem" end
	if MyGroupClassOrder() == 2 then return "Healing Stream Totem" end
end

local function ChooseFireTotem()
	if MyGroupClassOrder() == 1 then return "Frost Resistance Totem" end
end

function mb_dropTotems()
	
	if IsShiftKeyDown() then
		if not HasBuffOrDebuff("Grounding Totem", "player", "buff") then
			CastSpellByName("Grounding Totem")
		end
		if not HasBuffOrDebuff("Stoneskin Totem", "player", "buff") then
			CastSpellByName("Stoneskin Totem")
		end
		if not HasBuffOrDebuff("Healing Stream Totem", "player", "buff") then
			CastSpellByName("Healing Stream Totem")
		end	
		return
	end

	if GetSubZoneText() == "The Lyceum" then
		return
	end

	if GetSubZoneText() == "Halls of Strife" and not (TankTarget("Broodlord Lashlayer") or TankTarget("Firemaw")) then
		return
	end

	if MBID[MB_raidLeader] and not UnitName(MBID[MB_raidLeader].."target") then 
		return 
	end

	mb_castTotem(ChooseAirTotem())

	if not MB_cooldowns["Tremor Totem"] then
		mb_castTotem(ChooseEarthTotem())
	end

	if not MB_cooldowns["Poison Cleansing Totem"] then
		mb_castTotem(ChooseWaterTotem())
	end

	if TankTarget("Sapphiron") or TankTarget("Azuregos") then
		mb_castTotem(ChooseFireTotem())
	end
end

function mb_castTotem(totem)

	if MobsNoTotems() then
        return
    end

	if HasBuffOrDebuff("Mana Tide Totem", "player", "buff") then 
		return 
	end

	if (totem == "Fire Nova Totem" or totem == "Magma Totem") and not (InMeleeRange() or InCombat("player")) then 
		return 
	end

	local duration = 15
	if totem and string.find(totem, "Searing Totem") and not InCombat("player") then 
		return
	end

	local MB_totemTypes  = { 
        buff = {
            "Grounding Totem", 
            "Windfury Totem", 
            "Grace of Air Totem", 
            "Nature Resistance Totem", 
            "Tranquil Air Totem", 
            "Stoneskin Totem", 
            "Strength of Earth Totem", 
            "Frost Resistance Totem", 
            "Fire Resistance Totem", 
            "Mana Spring Totem", 
            "Healing Stream Totem", 
            "Mana Tide Totem"
        }, 
        noBuff = {
            "Sentry Totem", 
            "Earthbind Totem", 
            "Stoneclaw Totem", 
            "Fire Nova Totem", 
            "Magma Totem", 
            "Searing Totem", 
            "Flametongue Totem", 
            "Tremor Totem", 
            "Poison Cleansing Totem", 
            "Disease Cleansing Totem"
        }
	}

	if FindInTable(MB_totemTypes.noBuff, totem) then
		CoolDownCast(totem, duration)
	else
		if totem and not HasBuffOrDebuff(totem, "player", "buff") then 
			CastSpellByName(totem) 
		end
	end
end
