--[####################################################################################################]--
--[########################################### Buff Tracking ##########################################]--
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

local BuffData = {}

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function mb_hasWeaponBuff(oBuff, unit)
    local my, me, mc, oy, oe, oc = GetWeaponEnchantInfo()
    local buff = strlower(oBuff)
    local tooltip = MMBTooltip
    local text

    if not unit then
        unit = "player"
    end

    if my then
        tooltip:SetOwner(UIParent, "ANCHOR_NONE")
        tooltip:SetInventoryItem(unit, 16)

        for i = 1, 32 do
            text = getglobal("MMBTooltipTextLeft"..i):GetText()

            if not text then
                break
            elseif strfind(strlower(text), buff) then
                tooltip:Hide()
                local meTime = (me / 1000)
                return text, meTime, mc
            end
        end

        tooltip:Hide()
    end

    if oy then
        tooltip:SetOwner(UIParent, "ANCHOR_NONE")
        tooltip:SetInventoryItem(unit, 17)

        for i = 1, 32 do
            text = getglobal("MMBTooltipTextLeft"..i):GetText()
            
            if not text then
                break
            elseif strfind(strlower(text), buff) then
                tooltip:Hide()
                local oeTime = (oe / 1000)
                return text, oeTime, oc
            end
        end

        tooltip:Hide()
    end

    tooltip:Hide()
    return nil
end

function mb_hasBuffNamed(oBuff, unit)
    local buff = strlower(oBuff)
    local tooltip = MMBTooltip
    local textleft1 = getglobal(tooltip:GetName().."TextLeft1")
    local text

    if not unit then
        unit = "player"
    end

    for i = 1, 32 do
        tooltip:SetOwner(UIParent, "ANCHOR_NONE")
        tooltip:SetUnitBuff(unit, i)
        text = textleft1:GetText()
        tooltip:Hide()

        if not text then
            break
        end

        if strfind(strlower(text), buff) then
            return "buff", i, text
        end
    end

    for i = 1, 16 do
        tooltip:SetOwner(UIParent, "ANCHOR_NONE")
        tooltip:SetUnitDebuff(unit, i)
        text = textleft1:GetText()
        tooltip:Hide()

        if not text then
            break
        end

        if strfind(strlower(text), buff) then
            return "debuff", i, text
        end
    end

    tooltip:Hide()
    return nil
end

function mb_hasBuffOrDebuff(spell, target, buffOrDebuff)
    local TotemSpells = {
        ["Windfury"] = true,
        ["Windfury Totem 3"] = true,
        ["Windfury Weapon"] = true,
        ["Windfury Totem"] = true
    }

    if TotemSpells[spell] then
        return mb_hasWeaponBuff(spell, target)
    end

    local buffData = BuffData[spell]
    if not buffData then
        return nil
    end

    if buffOrDebuff == "buff" then
        return mb_buffCheck(buffData, target)
    elseif buffOrDebuff == "debuff" then
        return mb_debuffCheck(buffData, target)
    end

    return nil
end

function mb_buffCheck(text, target)
    local i = 1
    local buff = UnitBuff(target, i)

    while buff and i <= 32 do
        if buff == text then
            return true
        end

        i = i + 1
        buff = UnitBuff(target, i)
    end

    return false
end

function mb_debuffCheck(text, target)
    local i = 1
    local debuff = UnitDebuff(target, i)

    while debuff and i <= 16 do
        if debuff == text then
            return true
        end

        i = i + 1
        debuff = UnitDebuff(target, i)
    end

    return false
end

function mb_debuffShadowWeavingAmount()
	for debuffIndex = 1, 16 do
		local debuffTexture, debuffApplications, debuffDispelType = UnitDebuff("target", debuffIndex)
		if debuffTexture == "Interface\\Icons\\Spell_Shadow_BlackPlague" and debuffDispelType == "Magic" then
			return debuffApplications
		end
	end
	return 0
end

function mb_debuffSunderAmount()
	for debuffIndex = 1, 16 do
		local debuffTexture, debuffApplications, debuffDispelType = UnitDebuff("target", debuffIndex)
		if debuffTexture == "Interface\\Icons\\Ability_Warrior_Sunder" then
			return debuffApplications
		end
	end
	return 0
end

function mb_debuffAmountShatter()
	for debuffIndex = 1, 16 do
		local debuffTexture, debuffApplications, debuffDispelType = UnitDebuff("target", debuffIndex)
		if debuffTexture == "Interface\\Icons\\INV_Axe_12" then
			return debuffApplications
		end
	end
	return 0
end

function mb_debuffWintersChillAmount()
	for debuffIndex = 1, 16 do
		local debuffTexture, debuffApplications, debuffDispelType = UnitDebuff("target", debuffIndex)
		if debuffTexture == "Interface\\Icons\\Spell_Frost_ChillingBlast" and debuffDispelType == "Magic" then
			return debuffApplications
		end
	end
	return 0
end

function mb_debuffShadowBoltAmount()
	for debuffIndex = 1, 16 do
		local debuffTexture, debuffApplications, debuffDispelType = UnitDebuff("target", debuffIndex)
		if (debuffTexture == "Interface\\Icons\\Spell_Shadow_ShadowBolt") and debuffDispelType == "Magic" then
			return debuffApplications
		end
	end
	return 0
end

function mb_debuffScorchAmount()
	for debuffIndex = 1, 16 do
		local debuffTexture, debuffApplications, debuffDispelType = UnitDebuff("target", debuffIndex)
		if debuffTexture == "Interface\\Icons\\Spell_Fire_SoulBurn" and debuffDispelType == "Magic" then
			return debuffApplications
		end
	end
	return 0
end

function mb_debuffIgniteAmount() 
	local DebuffID = 1
	while (UnitDebuff("target", DebuffID)) do
		if (string.find(UnitDebuff("target", DebuffID), "Spell_Fire_Incinerate")) then
			_, IgniteStacks = UnitDebuff("target", DebuffID)
			return IgniteStacks
		end
		DebuffID = DebuffID + 1
	end
	return 0
end

function mb_mandokirGaze()
	if not mb_hasBuffOrDebuff("Threatening Gaze", "player", "debuff") then
		return false
	end

	if mb_imBusy() then			
		SpellStopCasting()
		return
	end

	TargetUnit("player")
	return true
end

function mb_razorgoreOrb()
	if mb_hasBuffOrDebuff("Mind Exhaustion", "player", "debuff") then
		return true
	end
	return false
end

function mb_isAtRazorgore()
	if GetSubZoneText() == "Dragonmaw Garrison" then 
		return true 
	end
	return false
end

function mb_selfBuff(spell)
	if mb_spellReady(spell) and not mb_hasBuffOrDebuff(spell, "player", "buff") then
		CastSpellByName(spell, 1)
	end
end

local function TryBuff(unitList, spell)
    for _, unitName in pairs(unitList) do
        local unitID = MBID[unitName]
        if mb_isValidFriendlyTarget(unitID, spell) and not mb_hasBuffOrDebuff(spell, unitID, "buff") then
            CastSpellByName(spell, false)
            SpellTargetUnit(unitID)
            SpellStopTargeting()
            return true
        end
    end
    return false
end

function mb_tankBuff(spell)
    TryBuff(MB_raidTanks, spell)
end

function mb_meleeBuff(spell)
    if TryBuff(MB_classList["Rogue"], spell) then return true end
    if TryBuff(MB_raidTanks, spell) then return true end
    if spell == "Abolish Poison" then
        TryBuff(MB_classList["Warrior"], spell)
    end
end

function mb_someoneInRaidBuffedWith(spell)
	if UnitIsDead("player") or UnitIsGhost("player") then
        return
    end

	for i = 1, GetNumRaidMembers()  do				
		if UnitName("raid"..i) and mb_isAlive("raid"..i) and mb_hasBuffOrDebuff(spell, "raid"..i, "buff") then
			return true
		end
	end
end

local function MultiBuffMOTW(spell)
	local n, r
	n = GetNumRaidMembers()
	r = math.random(n) - 1

	for i = 1, n do
		j = i + r
		if j > n then
            j = j - n
        end	

		if mb_isValidFriendlyTarget("raid"..j, spell) 
            and not (mb_hasBuffOrDebuff(spell, "raid"..j, "buff")
            or mb_hasBuffOrDebuff("Mark of the Wild", "raid"..j, "buff")) then

			ClearTarget()
			CastSpellByName(spell, false)
			SpellTargetUnit("raid"..j)
			SpellStopTargeting()
			return
		end
	end
end

local function MultiBuffAI(spell)
	local n, r
	n = GetNumRaidMembers()
	r = math.random(n) - 1

	for i = 1, n do
		j = i + r
		if j > n then
            j = j - n
        end	

		if mb_isValidFriendlyTarget("raid"..j, spell) 
            and not (UnitClass("raid"..j) == "Warrior" or UnitClass("raid"..j) == "Rogue")
            and not (mb_hasBuffOrDebuff(spell, "raid"..j, "buff")
            or mb_hasBuffOrDebuff("Arcane Intellect", "raid"..j, "buff")) then

			ClearTarget()
			CastSpellByName(spell, false)
			SpellTargetUnit("raid"..j)
			SpellStopTargeting()
			return
		end
	end
end

local function MultiBuffPriest(spell)
	local n, r
	n = GetNumRaidMembers()
	r = math.random(n) - 1

	if spell == "Prayer of Fortitude" then
		for i = 1, n do
			j = i + r
			if j > n then
                j = j - n
            end	

			if mb_isValidFriendlyTarget("raid"..j, spell)
                and not (mb_hasBuffOrDebuff(spell, "raid"..j, "buff")
                or mb_hasBuffOrDebuff("Power Word: Fortitude", "raid"..j, "buff")) then
				
				ClearTarget()
				CastSpellByName(spell, false)
				SpellTargetUnit("raid"..j)
				SpellStopTargeting()
				return
			end
		end

	elseif spell == "Prayer of Shadow Protection" then

		for i = 1, n do
			j = i + r
			if j > n then
                j = j - n
            end	

			if mb_isValidFriendlyTarget("raid"..j, spell)
                and not (mb_hasBuffOrDebuff(spell, "raid"..j, "buff")
                or mb_hasBuffOrDebuff("Shadow Protection", "raid"..j, "buff")) then
				
				ClearTarget()
				CastSpellByName(spell, false)
				SpellTargetUnit("raid"..j)
				SpellStopTargeting()
				return
			end
		end

	elseif spell == "Prayer of Spirit" then

		for i = 1, n do
			j = i + r
			if j > n then
                j = j - n
            end	

			if mb_isValidFriendlyTarget("raid"..j, spell)
                and not (UnitClass("raid"..j) == "Warrior" or UnitClass("raid"..j) == "Rogue")
                and not (mb_hasBuffOrDebuff(spell, "raid"..j, "buff")
                or mb_hasBuffOrDebuff("Divine Spirit", "raid"..j, "buff")) then
				
				ClearTarget()
				CastSpellByName(spell, false)
				SpellTargetUnit("raid"..j)
				SpellStopTargeting()
				return
			end
		end

	elseif spell == "Fear Ward" then

		for i = 1, n do
			j = i + r
			if j > n then 
                j = j - n
            end	

			if mb_isValidFriendlyTarget("raid"..j, spell) 
                and not mb_hasBuffOrDebuff(spell, "raid"..j, "buff") then
				
				ClearTarget()
				CastSpellByName(spell, false)
				SpellTargetUnit("raid"..j)
				SpellStopTargeting()
				return
			end
		end
	end
end

function MultiBuffBlessing(spell)
	local n, r

	if UnitInRaid("player") then
		n = GetNumRaidMembers()
		r = math.random(n) - 1

		for i = 1, n do
			j = i + r
			if j > n then
                j = j - n
            end	

			if (spell == "Greater Blessing of Wisdom" or spell == "Greater Blessing of Might") then				
				if UnitPowerType("raid"..j) == 0 then					
					spell = "Greater Blessing of Wisdom" 
				end

				if (UnitPowerType("raid"..j) == 1 or UnitPowerType("raid"..j) == 3) then
					spell = "Greater Blessing of Might"					
				end
			end

			if (spell == "Greater Blessing of Salvation") then
				if mb_isValidFriendlyTarget("raid"..j)
                    and not mb_hasBuffOrDebuff(spell, "raid"..j, "buff")
                    and not FindInTable(MB_raidTanks, UnitName("raid"..j)) then
				
					ClearTarget()
					CastSpellByName(spell, false)
					SpellTargetUnit("raid"..j)
					SpellStopTargeting()
					return
				end
				return
			end

			if mb_isValidFriendlyTarget("raid"..j)
                and not mb_hasBuffOrDebuff(spell, "raid"..j, "buff") then
				
				ClearTarget()
				CastSpellByName(spell, false)
				SpellTargetUnit("raid"..j)
				SpellStopTargeting()
				return
			end
		end
		
	elseif UnitInParty("player") then
		n = GetNumPartyMembers()

		for i = 1, n do
			if (spell == "Greater Blessing of Wisdom" or spell == "Greater Blessing of Might") then				
				if UnitPowerType("party"..i) == 0 then					
					spell = "Greater Blessing of Wisdom" 
				end

				if UnitPowerType("party"..i) == 1 or UnitPowerType("party"..i) == 3 then					
					spell = "Greater Blessing of Might" 
				end
			end
			
			if mb_isValidFriendlyTarget("party"..i)
                and not mb_hasBuffOrDebuff(spell, "party"..i, "buff") then
				
				TargetUnit("party"..i)
				CastSpellByName(spell)
				ClearTarget()
				return
			end
		end

		if not mb_dead("player") and not mb_hasBuffOrDebuff(spell, "player", "buff") then
			TargetUnit("player")
			CastSpellByName(spell)
			ClearTarget()
			return
		end
	end
end

function mb_multiBuff(spell)
	local n, r

	if UnitInRaid("player") then
		if spell == "Gift of the Wild" then
            MultiBuffMOTW(spell)
            return
        end

		if spell == "Arcane Brilliance" then
            MultiBuffAI(spell)
            return
        end

		if (spell == "Prayer of Spirit" or spell == "Prayer of Fortitude" or spell == "Prayer of Shadow Protection" or spell == "Fear Ward") then
            MultiBuffPriest(spell)
            return
        end
		
		n = GetNumRaidMembers()
		r = math.random(n) - 1

		for i = 1, n do
			j = i + r
			if j > n then
                j = j - n
            end	

			if mb_isValidFriendlyTarget("raid"..j, spell)
                and not mb_hasBuffOrDebuff(spell, "raid"..j, "buff") then
				ClearTarget()
				CastSpellByName(spell, false)
				SpellTargetUnit("raid"..j)
				SpellStopTargeting()
				return
			end
		end

	elseif UnitInParty("player") then
		n = GetNumPartyMembers()

		for i = 1, n do
			if mb_isValidFriendlyTarget("party"..i, spell)
                and not mb_hasBuffOrDebuff(spell, "party"..i, "buff") then				
				TargetUnit("party"..i)
				CastSpellByName(spell)
				ClearTarget();
				return
			end
		end

		if not mb_dead("player") and not mb_hasBuffOrDebuff(spell, "player", "buff") then			
			TargetUnit("player")
			CastSpellByName(spell)
			ClearTarget();
			return
		end
	end
end

--[####################################################################################################]--
--[############################################# Buff Data ############################################]--
--[####################################################################################################]--

BuffData["Prayer of Fortitude"] 			 =  "Interface\\Icons\\Spell_Holy_PrayerOfFortitude"
BuffData["Power Word: Fortitude"] 		 =  "Interface\\Icons\\Spell_Holy_WordFortitude"
BuffData["Prayer of Spirit"] 			 =  "Interface\\Icons\\Spell_Holy_PrayerofSpirit"
BuffData["Divine Spirit"] 				 =  "Interface\\Icons\\Spell_Holy_DivineSpirit"
BuffData["Prayer of Shadow Protection"]  = "Interface\\Icons\\Spell_Holy_PrayerofShadowProtection"
BuffData["Shadow Protection"] 			 =  "Interface\\Icons\\Spell_Shadow_AntiShadow"
BuffData["Weakened Soul"] 				 =  "Interface\\Icons\\Spell_Holy_AshesToAshes"
BuffData["Power Word: Shield"] 			 =  "Interface\\Icons\\Spell_Holy_PowerWordShield"
BuffData["Shadowform"] 					 =  "Interface\\Icons\\Spell_Shadow_Shadowform"
BuffData["Renew"] 						 =  "Interface\\Icons\\Spell_Holy_Renew"
BuffData["Mind Control"]					 =  "Interface\\Icons\\Spell_Shadow_ShadowWordDominate"
BuffData["Inner Fire"] 					 =  "Interface\\Icons\\Spell_Holy_InnerFire"
BuffData["Inner Focus"] 					 =  "Interface\\Icons\\Spell_Frost_WindWalkOn"
BuffData["Spirit Tap"] 					 =  "Interface\\Icons\\Spell_Shadow_Requiem"
BuffData["Vampiric Embrace"] 			 =  "Interface\\Icons\\Spell_Shadow_UnsummonBuilding"
BuffData["Fade"] 						 =  "Interface\\Icons\\Spell_Magic_LesserInvisibilty"
BuffData["Power Infusion"] 				 =  "Interface\\Icons\\Spell_Holy_PowerInfusion"
BuffData["Spirit of Redemption"] 		 =  "Interface\\Icons\\Spell_Holy_GreaterHeal"
BuffData["Fear Ward"] 					 =  "Interface\\Icons\\Spell_Holy_Excorcism"
BuffData["Shadowguard"] 					 =  "Interface\\Icons\\Spell_Nature_LightningShield"
BuffData["Devouring Plague"] 			 =  "Interface\\Icons\\Spell_Shadow_BlackPlague"
BuffData["Hex of Weakness"] 				 =  "Interface\\Icons\\Spell_Shadow_FingerOfDeath"
BuffData["Holy Fire"] 					 =  "Interface\\Icons\\Spell_Holy_SearingLight"
BuffData["Shadow Weaving"] 				 =  "Interface\\Icons\\Spell_Shadow_BlackPlague"
BuffData["Inspiration"] 					 =  "Interface\\Icons\\INV_Shield_06"
BuffData["Psychic Scream"] 				 =  "Interface\\Icons\\Spell_Shadow_PsychicScream"
BuffData["Shackle Undead"] 				 =  "Interface\\Icons\\Spell_Nature_Slow"
BuffData["Shadow Word: Pain"] 			 =  "Interface\\Icons\\Spell_Shadow_ShadowWordPain"
BuffData["Mind Soothe"] 					 =  "Interface\\Icons\\Spell_Holy_MindSooth"
BuffData["Silence"]						 =  "Interface\\Icons\\Spell_Shadow_ImpPhaseShift"
BuffData["Blackout"] 					 =  "Interface\\Icons\\Spell_Shadow_GatherShadows"
BuffData["Gift of the Wild"] 			 =  "Interface\\Icons\\Spell_Nature_Regeneration"
BuffData["Mark of the Wild"] 			 =  "Interface\\Icons\\Spell_Nature_Regeneration"
BuffData["Rejuvenation"] 				 =  "Interface\\Icons\\Spell_Nature_Rejuvenation"
BuffData["Regrowth"] 					 =  "Interface\\Icons\\Spell_Nature_ResistNature"
BuffData["Nature\'s Grace"] 				 =  "Interface\\Icons\\Spell_Nature_NaturesBlessing"
BuffData["Nature\'s Swiftness"]			 =  "Interface\\Icons\\Spell_Nature_RavenForm"
BuffData["Abolish Poison"] 				 =  "Interface\\Icons\\Spell_Nature_NullifyPoison_02"
BuffData["Innervate"] 					 =  "Interface\\Icons\\Spell_Nature_Lightning"
BuffData["Tranquility"] 					 =  "Interface\\Icons\\Spell_Nature_Tranquility"
BuffData["Barkskin"] 					 =  "Interface\\Icons\\Spell_Nature_StoneclawTotem"
BuffData["Thorns"] 						 =  "Interface\\Icons\\Spell_Nature_Thorns"
BuffData["Leader of the Pack"] 			 =  "Interface\\Icons\\Spell_Nature_UnyeildingStamina"
BuffData["Moonkin Aura"] 				 =  "Interface\\Icons\\Spell_Nature_MoonGlow"
BuffData["Moonkin Form"] 				 =  "Interface\\Icons\\Spell_Nature_ForceOfNature"
BuffData["Cat Form"]						 =  "Interface\\Icons\\Ability_Druid_CatForm"
BuffData["Bear Form"] 					 =  "Interface\\Icons\\Ability_Racial_BearForm"
BuffData["Dire Bear Form"] 				 =  "Interface\\Icons\\Ability_Racial_BearForm"
BuffData["Travel Form"] 					 =  "Interface\\Icons\\Ability_Druid_TravelForm"
BuffData["Aquatic Form"] 				 =  "Interface\\Icons\\Ability_Druid_AquaticForm"
BuffData["Prowl"] 						 =  "Interface\\Icons\\Ability_Ambush"
BuffData["Tiger\'s Fury"] 				 =  "Interface\\Icons\\Ability_Mount_JungleTiger"
BuffData["Dash"] 						 =  "Interface\\Icons\\Ability_Druid_Dash"
BuffData["Blessing of the Claw"] 		 =  "Interface\\Icons\\Spell_Holy_BlessingOfAgility"
BuffData["Nature\'s Grasp"] 				 =  "Interface\\Icons\\Spell_Nature_NaturesWrath"
BuffData["Omen of Clarity"] 				 =  "Interface\\Icons\\Spell_Nature_CrystalBall"
BuffData["Clearcasting"] 				 =  "Interface\\Icons\\Spell_Shadow_ManaBurn"
BuffData["Enrage"] 						 =  "Interface\\Icons\\Ability_Druid_Enrage"
BuffData["Frenzied Regeneration"]		 =  "Interface\\Icons\\Ability_BullRush"
BuffData["Growl"] 						 =  "Interface\\Icons\\Ability_Druid_Physical_Taunt"
BuffData["Pounce"] 						 =  "Interface\\Icons\\Ability_Druid_SupriseAttack"
BuffData["Rake"] 						 =  "Interface\\Icons\\Ability_Druid_Disembowel"
BuffData["Rip"] 							 =  "Interface\\Icons\\Ability_GhoulFrenzy"
BuffData["Moonfire"]						 =  "Interface\\Icons\\Spell_Nature_StarFall"
BuffData["Faerie Fire"] 					 =  "Interface\\Icons\\Spell_Nature_FaerieFire" 
BuffData["Faerie Fire (Feral)"]			 =  "Interface\\Icons\\Spell_Nature_FaerieFire"
BuffData["Hibernate"] 					 =  "Interface\\Icons\\Spell_Nature_Sleep"
BuffData["Insect Swarm"]					 =  "Interface\\Icons\\Spell_Nature_InsectSwarm"
BuffData["Entangling Roots"] 			 =  "Interface\\Icons\\Spell_Nature_StrangleVines"
BuffData["Starfire Stun"] 				 =  "Interface\\Icons\\Spell_Arcane_Starfire"
BuffData["Hurricane"] 					 =  "Interface\\Icons\\Spell_Nature_Cyclone"
BuffData["Soothe Animal"] 				 =  "Interface\\Icons\\Spell_Hunter_BeastSoothe"
BuffData["Bash"] 						 =  "Interface\\Icons\\Ability_Druid_Bash"
BuffData["Challenging Roar"] 			 =  "Interface\\Icons\\Ability_Druid_ChallangingRoar"
BuffData["Demoralizing Roar"] 			 =  "Interface\\Icons\\Ability_Druid_DemoralizingRoar"
BuffData["Arcane Brilliance"] 			 =  "Interface\\Icons\\Spell_Holy_ArcaneIntellect"
BuffData["Arcane Intellect"] 			 =  "Interface\\Icons\\Spell_Holy_MagicalSentry"
BuffData["Dampen Magic"] 				 =  "Interface\\Icons\\Spell_Nature_AbolishMagic"
BuffData["Amplify Magic"]				 =  "Interface\\Icons\\Spell_Holy_FlashHeal"
BuffData["Ice Armor"] 					 =  "Interface\\Icons\\Spell_Frost_FrostArmor02"
BuffData["Mana Shield"] 					 =  "Interface\\Icons\\Spell_Shadow_DetectLesserInvisibility"
BuffData["Fire Ward"] 					 =  "Interface\\Icons\\Spell_Fire_FireArmor"
BuffData["Ice Block"] 					 =  "Interface\\Icons\\Spell_Frost_Frost"
BuffData["Ice Barrier"] 					 =  "Interface\\Icons\\Spell_Ice_Lament"
BuffData["Evocation"] 					 =  "Interface\\Icons\\Spell_Nature_Purge"
BuffData["Frost Ward"] 					 =  "Interface\\Icons\\Spell_Frost_FrostWard"
BuffData["Mage Armor"] 					 =  "Interface\\Icons\\Spell_MageArmor"
BuffData["Clearcasting"] 				 =  "Interface\\Icons\\Spell_Shadow_ManaBurn"
BuffData["Presence of Mind"] 			 =  "Interface\\Icons\\Spell_Nature_EnchantArmor"
BuffData["Combustion"] 					 =  "Interface\\Icons\\Spell_Fire_SealOfFire"
BuffData["Netherwind Focus"] 			 =  "Interface\\Icons\\Spell_Shadow_Teleport"
BuffData["Detect Magic"] 				 =  "Interface\\Icons\\Spell_Holy_Dizzy"
BuffData["Polymorph"] 					 =  "Interface\\Icons\\Spell_Nature_Polymorph"
BuffData["Frostbolt"] 					 =  "Interface\\Icons\\Spell_Frost_FrostBolt02"
BuffData["Frost Nova"] 					 =  "Interface\\Icons\\Spell_Frost_FrostNova"
BuffData["Frostbite"] 					 =  "Interface\\Icons\\Spell_Frost_FrostArmor"
BuffData["Scorch"] 						 =  "Interface\\Icons\\Spell_Fire_SoulBurn"
BuffData["Ignite"] 						 =  "Interface\\Icons\\Spell_Fire_Incinerate"
BuffData["Winter\'s Chill"] 				 =  "Interface\\Icons\\Spell_Frost_ChillingBlast"
BuffData["Arcane Power"] 				 =  "Interface\\Icons\\Spell_Nature_Lightning"
BuffData["Demon Skin"] 					 =  "Interface\\Icons\\Spell_Shadow_RagingScream"
BuffData["Demon Armor"] 					 =  "Interface\\Icons\\Spell_Shadow_RagingScream"
BuffData["Fire Shield"] 					 =  "Interface\\Icons\\Spell_Fire_FireArmor"
BuffData["Sacrifice"] 					 =  "Interface\\Icons\\Spell_Shadow_SacrificialShield"
BuffData["Underwater Breathing"] 		 =  "Interface\\Icons\\Spell_Shadow_DemonBreath"
BuffData["Eye of Kilrogg"]				 =  "Interface\\Icons\\Spell_Shadow_EvilEye"
BuffData["Nightfall"] 					 =  "Interface\\Icons\\Spell_Shadow_Twilight"
BuffData["Touch of Shadow"] 				 =  "Interface\\Icons\\Spell_Shadow_PsychicScream"
BuffData["Burning Wish"] 				 =  "Interface\\Icons\\Spell_Shadow_PsychicScream"
BuffData["Fel Stamina"] 					 =  "Interface\\Icons\\Spell_Shadow_PsychicScream"
BuffData["Fel Energy"] 					 =  "Interface\\Icons\\Spell_Shadow_PsychicScream"
BuffData["Shadow Ward"] 					 =  "Interface\\Icons\\Spell_Shadow_AntiShadow"
BuffData["Master Demonologist"] 			 =  "Interface\\Icons\\Spell_Shadow_ShadowPact"
BuffData["Soul Link"] 					 =  "Interface\\Icons\\Spell_Shadow_GatherShadows"
BuffData["Detect Lesser Invisibility"]	 =  "Interface\\Icons\\Spell_Shadow_DetectLesserInvisibility"
BuffData["Detect Invisibility"] 			 =  "Interface\\Icons\\Spell_Shadow_DetectInvisibility"
BuffData["Detect Greater Invisibility"] 	 =  "Interface\\Icons\\Spell_Shadow_DetectInvisibility"
BuffData["Soulstone"] 					 =  "Interface\\Icons\\Spell_Shadow_SoulGem"
BuffData["Blood Pact"] 					 =  "Interface\\Icons\\Spell_Shadow_BloodBoil"
BuffData["Paranoia"] 					 =  "Interface\\Icons\\Spell_Shadow_AuraOfDarkness"
BuffData["Phase Shift"] 					 =  "Interface\\Icons\\Spell_Shadow_ImpPhaseShift"
BuffData["Health Funnel"] 				 =  "Interface\\Icons\\Spell_Shadow_LifeDrain"
BuffData["Consume Shadows"] 				 =  "Interface\\Icons\\Spell_Shadow_AntiShadow"
BuffData["Lesser Invisibility"] 			 =  "Interface\\Icons\\Spell_Magic_LesserInvisibility"
BuffData["Corruption"] 					 =  "Interface\\Icons\\Spell_Shadow_AbominationExplosion"
BuffData["Immolate"] 					 =  "Interface\\Icons\\Spell_Fire_Immolation"
BuffData["Siphon Life"] 					 =  "Interface\\Icons\\Spell_Shadow_Requiem"
BuffData["Drain Life"] 					 =  "Interface\\Icons\\Spell_Shadow_LifeDrain02"
BuffData["Drain Soul"] 					 =  "Interface\\Icons\\Spell_Shadow_Haunting"
BuffData["Drain Mana"] 					 =  "Interface\\Icons\\Spell_Shadow_SiphonMana"
BuffData["Improved Shadow Bolt"] 		 =  "Interface\\Icons\\Spell_Shadow_ShadowBolt"
BuffData["Curse of Agony"] 				 =  "Interface\\Icons\\Spell_Shadow_CurseOfSargeras"
BuffData["Curse of Weakness"] 			 =  "Interface\\Icons\\Spell_Shadow_CurseOfMannoroth"
BuffData["Curse of Shadow"] 				 =  "Interface\\Icons\\Spell_Shadow_CurseOfAchimonde"
BuffData["Curse of the Elements"] 		 =  "Interface\\Icons\\Spell_Shadow_ChillTouch"
BuffData["Curse of Doom"] 				 =  "Interface\\Icons\\Spell_Shadow_AuraOfDarkness"
BuffData["Curse of Tongues"] 			 =  "Interface\\Icons\\Spell_Shadow_CurseOfTounges"
BuffData["Curse of Recklessness"] 		 =  "Interface\\Icons\\Spell_Shadow_UnholyStrength"
BuffData["Curse of Exhaustion"] 			 =  "Interface\\Icons\\Spell_Shadow_GrimWard"
BuffData["Enslave Demon"] 				 =  "Interface\\Icons\\Spell_Shadow_EnslaveDemon"
BuffData["Hellfire"] 					 =  "Interface\\Icons\\Spell_Fire_Incinerate"
BuffData["Fear"] 						 =  "Interface\\Icons\\Spell_Shadow_Possession"
BuffData["Banish"] 						 =  "Interface\\Icons\\Spell_Shadow_Cripple"
BuffData["Seduction"] 					 =  "Interface\\Icons\\Spell_Shadow_MindSteal"
BuffData["Tainted Blood"] 				 =  "Interface\\Icons\\Spell_Shadow_LifeDrain"
BuffData["Spell Lock"] 					 =  "Interface\\Icons\\Spell_Shadow_MindRot"
BuffData["Howl of Terror"] 				 =  "Interface\\Icons\\Spell_Shadow_DeathScream"
BuffData["Death Coil"] 					 =  "Interface\\Icons\\Spell_Shadow_DeathCoil"
BuffData["Frost Shock"] 					 =  "Interface\\Icons\\Spell_Frost_FrostShock"
BuffData["Flame Shock"] 					 =  "Interface\\Icons\\Spell_Fire_FlameShock"
BuffData["Stormstrike"] 					 =  "Interface\\Icons\\Spell_Holy_SealOfMight"
BuffData["Earthbind Totem"] 				 =  "Interface\\Icons\\Spell_Nature_StrengthhOfEarthTotem02"
BuffData["Strength of Earth Totem"] 		 =  "Interface\\Icons\\Spell_Nature_EarthBindTotem"
BuffData["Grace of Air Totem"] 			 =  "Interface\\Icons\\Spell_Nature_InvisibilityTotem"
BuffData["Mana Spring Totem"] 			 =  "Interface\\Icons\\Spell_Nature_ManaRegenTotem"
BuffData["Healing Stream Totem"] 		 =  "Interface\\Icons\\INV_Spear_04"
BuffData["Grounding Totem"] 				 =  "Interface\\Icons\\Spell_Nature_GroundingTotem"
BuffData["Mana Tide Totem"] 				 =  "Interface\\Icons\\Spell_Frost_SummonWaterElemental"
BuffData["Tranquil Air Totem"] 			 =  "Interface\\Icons\\Spell_Nature_Brilliance"
BuffData["Stoneskin Totem"] 				 =  "Interface\\Icons\\Spell_Nature_StoneSkinTotem"
BuffData["Frost Resistance Totem"] 		 =  "Interface\\Icons\\Spell_FrostResistanceTotem_01"
BuffData["Fire Resistance Totem"] 		 =  "Interface\\Icons\\Spell_FireResistanceTotem_01"
BuffData["Nature Resistance Totem"] 		 =  "Interface\\Icons\\Spell_Nature_NatureResistanceTotem"
BuffData["Windwall Totem"] 				 =  "Interface\\Icons\\Spell_Nature_EarthBind"
BuffData["Lightning Shield"] 			 =  "Interface\\Icons\\Spell_Nature_LightningShield"
BuffData["Healing Way"] 					 =  "Interface\\Icons\\Spell_Nature_HealingWay"
BuffData["Ancestral Fortitude"] 			 =  "Interface\\Icons\\Spell_Nature_UndyingStrength"
BuffData["Totemic Power"] 				 =  "Interface\\Icons\\Spell_Magic_MageArmor"
BuffData["Ghost Wolf"] 					 =  "Interface\\Icons\\Spell_Nature_SpiritWolf"
BuffData["Aspect of the Hawk"] 			 =  "Interface\\Icons\\Spell_Nature_RavenForm"
BuffData["Aspect of the Monkey"] 		 =  "Interface\\Icons\\Ability_Hunter_AspectOfTheMonkey"
BuffData["Aspect of the Cheetah"] 		 =  "Interface\\Icons\\Ability_Mount_JungleTiger"
BuffData["Aspect of the Pack"] 			 =  "Interface\\Icons\\Ability_Mount_WhiteTiger"
BuffData["Aspect of the Beast"] 			 =  "Interface\\Icons\\Ability_Mount_PinkTiger"
BuffData["Aspect of the Wild"] 			 =  "Interface\\Icons\\Spell_Nature_ProtectionformNature"
BuffData["Rapid Fire"] 					 =  "Interface\\Icons\\Ability_Hunter_RunningShot"
BuffData["Eyes of the Beast"] 			 =  "Interface\\Icons\\Ability_EyesOfTheOwl"
BuffData["Deterrence"] 					 =  "Interface\\Icons\\Ability_Whirlwind"
BuffData["Feed Pet"] 					 =  "Interface\\Icons\\Ability_Hunter_BeastTraining"
BuffData["Mend Pet"] 					 =  "Interface\\Icons\\Ability_Hunter_MendPet"
BuffData["Concussive Shot"] 				 =  "Interface\\Icons\\Spell_Frost_Stun"
BuffData["Hunter\'s Mark"] 				 =  "Interface\\Icons\\Ability_Hunter_SniperShot"
BuffData["Wing Clip"] 					 =  "Interface\\Icons\\Ability_Rogue_Trip"
BuffData["Serpent Sting"] 				 =  "Interface\\Icons\\Ability_Hunter_Quickshot"
BuffData["Scorpid Sting"] 				 =  "Interface\\Icons\\Ability_Hunter_CriticalShot"
BuffData["Viper Sting"] 					 =  "Interface\\Icons\\Ability_Hunter_AimedShot"
BuffData["Scatter Shot"] 				 =  "Interface\\Icons\\Ability_GolemStormBolt"
BuffData["Freezing Trap"] 				 =  "Interface\\Icons\\Spell_Frost_ChainsOfIce"
BuffData["Frost Trap"] 					 =  "Interface\\Icons\\Spell_Frost_FreezingBreath"
BuffData["Immolation Trap"] 				 =  "Interface\\Icons\\Spell_Fire_FlameShock"
BuffData["Explosive Trap"] 				 =  "Interface\\Icons\\Spell_Fire_SelfDestruct"
BuffData["Trueshot Aura"] 				 =  "Interface\\Icons\\Ability_TrueShot"
BuffData["Feign Death"] 					 =  "Interface\\Icons\\Ability_Rogue_FeignDeath"
BuffData["Screech"] 					 	 =  "Interface\\Icons\\Ability_Hunter_Pet_Bat"
BuffData["Stealth"] 						 =  "Interface\\Icons\\Ability_Stealth"
BuffData["Vanish"] 						 =  "Interface\\Icons\\Ability_Vanish"
BuffData["Blade Flurry"] 				 =  "Interface\\Icons\\Ability_Warrior_PunishingBlow"
BuffData["Adrenaline Rush"] 				 =  "Interface\\Icons\\Spell_Shadow_ShadowWordDominate"
BuffData["SPrint"] 						 =  "Interface\\Icons\\Ability_Rogue_SPrint"
BuffData["Hemorrhage"] 					 =  "Interface\\Icons\\Spell_Shadow_Lifedrain"
BuffData["Gouge"] 						 =  "Interface\\Icons\\Ability_Gouge"
BuffData["Garrote"] 						 =  "Interface\\Icons\\Ability_Rogue_Garrote"
BuffData["Blind"] 						 =  "Interface\\Icons\\Spell_Shadow_MindSteal"
BuffData["Rupture"] 						 =  "Interface\\Icons\\Ability_Rogue_Rupture"
BuffData["Cheap Shot"] 					 =  "Interface\\Icons\\Ability_CheapShot"
BuffData["Kidney Shot"]					 =  "Interface\\Icons\\Ability_Rogue_KidneyShot"
BuffData["Sap"] 							 =  "Interface\\Icons\\Ability_Sap"
BuffData["Expose Armor"] 				 =  "Interface\\Icons\\Ability_Warrior_Riposte"
BuffData["Slice and Dice"] 				 =  "Interface\\Icons\\Ability_Rogue_SliceDice"
BuffData["Mace Stun"]					 =  "Interface\\Icons\\Spell_Frost_Stun"
BuffData["Battle Shout"] 				 =  "Interface\\Icons\\Ability_Warrior_BattleShout"
BuffData["Taunt"] 						 =  "Interface\\Icons\\Spell_Nature_Reincarnation"
BuffData["Bloodrage"] 					 =  "Interface\\Icons\\Ability_Racial_BloodRage"
BuffData["Death Wish"] 					 =  "Interface\\Icons\\Spell_Shadow_DeathPact"
BuffData["Enraged"] 						 =  "Interface\\Icons\\Spell_Shadow_UnholyFrenzy"
BuffData["Flurry"] 						 =  "Interface\\Icons\\Ability_GhoulFrenzy"
BuffData["Recklessness"] 				 =  "Interface\\Icons\\Ability_CriticalStrike"
BuffData["Berserker Rage"] 				 =  "Interface\\Icons\\Spell_Nature_AncestralGuardian"
BuffData["Mocking Blow"] 				 =  "Interface\\Icons\\Ability_Warrior_PunishingBlow"
BuffData["Mortal Strike"] 				 =  "Interface\\Icons\\Ability_Warrior_SavageBlow"
BuffData["Thunder Clap"] 				 =  "Interface\\Icons\\Spell_Nature_ThunderClap"
BuffData["Piercing Howl"] 				 =  "Interface\\Icons\\Spell_Shadow_DeathScream"
BuffData["Hamstring"] 					 =  "Interface\\Icons\\Ability_ShockWave"
BuffData["Concussion Blow"] 				 =  "Interface\\Icons\\Ability_ThunderBolt"
BuffData["Demoralizing Shout"] 			 =  "Interface\\Icons\\Ability_Warrior_WarCry"
BuffData["Intimidating Shout"] 			 =  "Interface\\Icons\\Ability_GolemThunderClap"
BuffData["Sunder Armor"] 				 =  "Interface\\Icons\\Ability_Warrior_Sunder"
BuffData["Disarm"]						 =  "Interface\\Icons\\Ability_Warrior_Disarm"
BuffData["Sweeping Strikes"]				 =  "Interface\\Icons\\Ability_Rogue_SliceDice"
BuffData["Devotion Aura"]   				 =  "Interface\\Icons\\Spell_Holy_DevotionAura" 
BuffData["Concentration Aura"] 			 =  "Interface\\Icons\\Spell_Holy_MindSooth"
BuffData["Fire Resistance Aura"]			 =  "Interface\\Icons\\Spell_Fire_SealOfFire"
BuffData["Frost Resistance Aura"]		 =  "Interface\\Icons\\Spell_Frost_WizardMark"
BuffData["Retribution Aura"]				 =  "Interface\\Icons\\Spell_Holy_AuraOfLight"
BuffData["Greater Blessing of Wisdom"]   = "Interface\\Icons\\Spell_Holy_GreaterBlessingofWisdom" 
BuffData["Greater Blessing of Kings"]	 =  "Interface\\Icons\\Spell_Magic_GreaterBlessingofKings" 
BuffData["Greater Blessing of Salvation"] =  "Interface\\Icons\\Spell_Holy_GreaterBlessingofSalvation" 
BuffData["Greater Blessing of Might"]    = "Interface\\Icons\\Spell_Holy_GreaterBlessingofKings" 
BuffData["Greater Blessing of Light"]    = "Interface\\Icons\\Spell_Holy_GreaterBlessingofLight" 
BuffData["Greater Blessing of Sanctuary"] =  "Interface\\Icons\\Spell_Holy_GreaterBlessingofSanctuary" 
BuffData["Hammer of Justice"] 			 =  "Interface\\Icons\\Spell_Holy_SealOfMight"
BuffData["Seal of Light"] 				 =  "Interface\\Icons\\Spell_Holy_HealingAura"
BuffData["Seal of Wisdom"]				 =  "Interface\\Icons\\Spell_Holy_RighteousnessAura"
BuffData["Judgement of Light"] 			 =  "Interface\\Icons\\Spell_Holy_HealingAura"
BuffData["Judgement of Wisdom"]			 =  "Interface\\Icons\\Spell_Holy_RighteousnessAura"
BuffData["Blessing of Protection"] 		 =  "Interface\\Icons\\Spell_Holy_SealOfProtection"
BuffData["Forbearance"] 					 =  "Interface\\Icons\\Spell_Holy_RemoveCurse"
BuffData["Divine Favor"]					 =  "Interface\\Icons\\Spell_Holy_Heal"
BuffData["Blinding Light"]				 =  "Interface\\Icons\\Spell_Holy_SearingLight"
BuffData["Seal of Righteousness"]		 =  "Interface\\Icons\\Ability_ThunderBolt"
BuffData["Berserking"] 					 =  "Interface\\Icons\\Racial_Troll_Berserk"
BuffData["Blood Fury Debuff"] 			 =  "Interface\\Icons\\Ability_Rogue_FeignDeath"
BuffData["Blood Fury"] 					 =  "Interface\\Icons\\Racial_Orc_BerserkerStrength"
BuffData["War Stomp"] 					 =  "Interface\\Icons\\Ability_WarStomp"
BuffData["Cannibalize"] 					 =  "Interface\\Icons\\Ability_Racial_Cannibalize"
BuffData["Will of the Forsaken"] 		 =  "Interface\\Icons\\Spell_Shadow_RaiseDead"
BuffData["Warchief\'s Blessing"] 					 =  "Interface\\Icons\\Spell_Arcane_TeleportOrgrimmar"
BuffData["Rallying Cry of the Dragonslayer"] 	 =  "Interface\\Icons\\INV_Misc_Head_Dragon_01"
BuffData["Spirit of Zandalar"] 					 =  "Interface\\Icons\\Ability_Creature_Poison_05"
BuffData["Songflower Serenade"] 					 =  "Interface\\Icons\\Spell_Holy_MindVision"
BuffData["Sayge\'s Dark Fortune of Strength"] 	 =  "Interface\\Icons\\INV_Misc_Orb_02"
BuffData["Sayge\'s Dark Fortune of Damage"] 		 =  "Interface\\Icons\\INV_Misc_Orb_02"
BuffData["Sayge\'s Dark Fortune of Intelligence"] = "Interface\\Icons\\INV_Misc_Orb_02"
BuffData["Sayge\'s Dark Fortune of Agility"] 		 =  "Interface\\Icons\\INV_Misc_Orb_02"
BuffData["Sayge\'s Dark Fortune of Resistance"] 	 =  "Interface\\Icons\\INV_Misc_Orb_02"
BuffData["Sayge\'s Dark Fortune of Stamina"] 		 =  "Interface\\Icons\\INV_Misc_Orb_02"
BuffData["Sayge\'s Dark Fortune of Spirit"] 		 =  "Interface\\Icons\\INV_Misc_Orb_02"
BuffData["Sayge\'s Dark Fortune of Armor"] 		 =  "Interface\\Icons\\INV_Misc_Orb_02"
BuffData["Fengus\' Ferocity"] 					 =  "Interface\\Icons\\Spell_Nature_UndyingStrength"
BuffData["Mol\'dar\'s Moxie"] 						 =  "Interface\\Icons\\Spell_Nature_MassTeleport"
BuffData["Slip\'kik\'s Savvy"] 					 =  "Interface\\Icons\\Spell_Holy_LesserHeal02"
BuffData["Recently Bandaged"] 					 =  "Interface\\Icons\\INV_Misc_Bandage_08"
BuffData["First Aid"] 							 =  "Interface\\Icons\\Spell_Holy_Heal"
BuffData["Frozen Rune"]							 =  "Interface\\Icons\\Spell_Fire_MasterOfElements"
BuffData["Shadow Storm"] 				 =  "Interface\\Icons\\Spell_Shadow_ShadowBolt" --aq40 anubisaths BUFF
BuffData["Mana Burn"]					 =  "Interface\\Icons\\Spell_Shadow_ManaBurn" --aq40 anubisaths BUFF
BuffData["Fire and Arcane Reflect"] 		 =  "Interface\\Icons\\Spell_Arcane_Blink" --same icon, 
BuffData["Shadow and Frost Reflect"]		 =  "Interface\\Icons\\Spell_Arcane_Blink" --same icon, 
BuffData["Mending"] 						 =  "Interface\\Icons\\Spell_Nature_ResistNature" --aq40 anubisaths BUFF
BuffData["Periodic Knock Away"] 			 =  "Interface\\Icons\\Ability_UpgradeMoonglaive" --aq40 anubisaths BUFF
BuffData["Living Bomb"] 					 =  "Interface\\Icons\\INV_Enchant_EssenceAstralSmall" --Baron Bomb
BuffData["Burning Adrenaline"] 			 =  "Interface\\Icons\\INV_Gauntlets_03" --Vaelastrasz Bomb
BuffData["Brood Affliction: Bronze"] 	 =  "Interface\\Icons\\INV_Misc_Head_Dragon_Bronze" --Chromaggus bronze debuff
BuffData["Plague"] 						 =  "Interface\\Icons\\Spell_Shadow_CurseOfTounges" --aq20/40 anubisath plague debuff
BuffData["Drink"] 						 =  "Interface\\Icons\\INV_Drink_18" --LVL 55 water ONLY, not lvl 45 or below.
BuffData["Shadow Weakness"] 				 =  "Interface\\Icons\\INV_Misc_QirajiCrystal_05" --Ossirian Weakness
BuffData["Fire Weakness"] 				 =  "Interface\\Icons\\INV_Misc_QirajiCrystal_02" --Ossirian Weakness
BuffData["Nature Weakness"] 				 =  "Interface\\Icons\\INV_Misc_QirajiCrystal_03" --Ossirian Weakness
BuffData["Arcane Weakness"] 				 =  "Interface\\Icons\\INV_Misc_QirajiCrystal_01" --Ossirian Weakness
BuffData["Frost Weakness"] 				 =  "Interface\\Icons\\INV_Misc_QirajiCrystal_04" --Ossirian Weakness
BuffData["Magic Reflection"] 			 =  "Interface\\Icons\\Spell_Frost_FrostShock" --Magic Reflection on Major Domo adds
BuffData["Deaden Magic"] 				 =  "Interface\\Icons\\Spell_Holy_SealOfSalvation" --Shazzrah Deaden Magicc BUFF, can be dispelled.
BuffData["Corrupted Healing"] 			 =  "Interface\\Icons\\Spell_Shadow_Charm" --Nefarian Priestcall debuff, stop heal if have this debuff as priest.
BuffData["Delusions of Jin\'do"] 			 =  "Interface\\Icons\\Spell_Shadow_UnholyFrenzy" --Jindo shade debuff, do not decurse.
BuffData["Threatening Gaze"] 			 =  "Interface\\Icons\\Spell_Shadow_Charm" --Broodlord's Threatening gaze.
BuffData["True Fulfillment"] 			 =  "Interface\\Icons\\Spell_Shadow_Charm" --Skerams mindcontrol.
BuffData["Aura of Agony"]				 =  "Interface\\Icons\\Spell_Shadow_CurseOfSargeras"
BuffData["Corruption of the Earth"]		 =  "Interface\\Icons\\Ability_Creature_Cursed_03"
BuffData["Atiesh"] 						 =  "Interface\\Icons\\Spell_Nature_MoonGlow"
BuffData["Hazza\'rah\'s Charm of Healing"] = "Interface\\Icons\\Spell_Holy_HealingAura"
BuffData["Magma Shackles"] 				 =  "Interface\\Icons\\Spell_Nature_EarthBind" --Garr's Slowing effect
BuffData["Corrupted Mind"]				 =	"Interface\\Icons\\Spell_Shadow_AuraOfDarkness" -- Loatheb
BuffData["Fungal Bloom"]					 =  "Interface\\Icons\\Spell_Nature_UnyeildingStamina" -- Buff Loatheb
BuffData["Impending Doom"]				 =  "Interface\\Icons\\Spell_Shadow_NightOfTheDead"
BuffData["Inevitable Doom"]				 =  "Interface\\Icons\\Spell_Shadow_NightOfTheDead"
BuffData["Mind Exhaustion"] 				 = "Interface\\Icons\\Spell_Shadow_Teleport" 
BuffData["Blessed Sunfruit Juice"] 		 = "Interface\\Icons\\Spell_Holy_Layonhands"
BuffData["Blessed Sunfruit"] 			 = "Interface\\Icons\\Spell_Holy_Devotion"
BuffData["Spell Vulnerability"]			 = "Interface\\Icons\\Spell_Holy_Elunesgrace"
BuffData["Shadow Protection"]			 = "Interface\\Icons\\Spell_Shadow_RagingScream"
BuffData["Mutating Injection"]			 = "Interface\\Icons\\Spell_Shadow_CallofBone"
BuffData["Shadow Command"] 				 =  "Interface\\Icons\\Spell_Shadow_UnholyFrenzy"
BuffData["Elemental Sharpening Stone"] 				 =  "Interface\\Icons\\INV_Stone_02"
BuffData["Increased Stamina"] 				 =  "Interface\\Icons\\INV_Boots_Plate_03"
BuffData["Well Fed"] 				 =  "Interface\\Icons\\INV_Misc_Food"
BuffData["Increased Intellect"] 				 =  "Interface\\Icons\\INV_Misc_Organ_03"
BuffData["Evil Twin"] 				 =  "Interface\\Icons\\Spell_Shadow_Charm"

BuffData["Greater Shadow Protection Potion"]				=	"Interface\\Icons\\Spell_Shadow_RagingScream"
BuffData["Greater Nature Protection Potion"] 	 		=	"Interface\\Icons\\Spell_Nature_SpiritArmor"
BuffData["Greater Fire Protection Potion"] 		 		=	"Interface\\Icons\\Spell_Fire_FireArmor"
BuffData["Greater Frost Protection Potion"] 		 		=	"Interface\\Icons\\Spell_Frost_FrostArmor02"
BuffData["Greater Arcane Protection Potion"] 		 		=	"Interface\\Icons\\Spell_Holy_PrayerOfHealing02"

BuffData["Juju Power"] 				 	=	"Interface\\Icons\\INV_Misc_MonsterScales_11"
BuffData["Juju Might"] 				 	=	"Interface\\Icons\\INV_Misc_MonsterScales_07"
BuffData["Juju Ember"]			 		=	"Interface\\Icons\\INV_Misc_MonsterScales_15"
BuffData["Juju Escape"]			 		=	"Interface\\Icons\\INV_Misc_MonsterScales_17"
BuffData["Juju Chill"]			 		=	"Interface\\Icons\\INV_Misc_MonsterScales_09"
BuffData["Juju Guile"]			 		=	"Interface\\Icons\\INV_Misc_MonsterScales_13"
BuffData["Juju Flurry"]			 		=	"Interface\\Icons\\INV_Misc_MonsterScales_17"

BuffData["Swiftness of Zanza"] 				 	=	"Interface\\Icons\\INV_Potion_31"
BuffData["Spirit of Zanza"] 						=   "Interface\\Icons\\INV_Potion_30"

BuffData["Flask of the Titans"] 				 	=	"Interface\\Icons\\INV_Potion_62"
BuffData["Flask of Supreme Power"] 				=	"Interface\\Icons\\INV_Potion_41"
BuffData["Flask of Distilled Wisdom"] 			=	"Interface\\Icons\\INV_Potion_97"

BuffData["Elixir of the Mongoose"] 				=	"Interface\\Icons\\INV_Potion_32"
BuffData["Elixir of Frost Power"] 				=	"Interface\\Icons\\INV_Potion_03"
BuffData["Elixir of Greater Firepower"] 			=	"Interface\\Icons\\INV_Potion_60"
BuffData["Elixir of Shadow Power"] 				=	"Interface\\Icons\\INV_Potion_46"

BuffData["Mageblood Potion"] 					=	"Interface\\Icons\\INV_Potion_45"

BuffData["Greater Stoneshield Potion"] 			=	"Interface\\Icons\\INV_Potion_69" 
BuffData["Greater Arcane Elixir"] 				=	"Interface\\Icons\\INV_Potion_25"

BuffData["Brilliant Wizard Oil"] 				=	"Interface\\Icons\\INV_Potion_105"
BuffData["Brilliant Mana Oil"] 				 	=	"Interface\\Icons\\INV_Potion_100"