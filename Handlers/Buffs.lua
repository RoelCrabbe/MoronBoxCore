--[####################################################################################################]--
--[########################################### Buff Tracking ##########################################]--
--[####################################################################################################]--

mb_buffData = {}

function mb_hasWeaponBuff(oBuff, unit)
    local my, me, mc, oy, oe, oc = GetWeaponEnchantInfo()
	local buff = strlower(oBuff)
	local tooltip = MMBTooltip
	local textleft1 = getglobal(tooltip:GetName().."TextLeft1")
	if not unit then
		unit  = "player"
	end

	if my then
		tooltip:SetOwner(UIParent, "ANCHOR_NONE")
		tooltip:SetInventoryItem( unit, 16)

		for i = 1, 23 do
			local text = getglobal("MMBTooltipTextLeft"..i):GetText()
			if not text then
				break
			elseif strfind(strlower(text), buff) then
				tooltip:Hide()
				local meTime = me/1000
				return text, meTime, mc
			end
		end

		tooltip:Hide()
	elseif oy then
		tooltip:SetOwner(UIParent, "ANCHOR_NONE")
		tooltip:SetInventoryItem( unit, 17)

		for i = 1, 23 do
			local text = getglobal("MMBTooltipTextLeft"..i):GetText()
			if not text then
				break
			elseif strfind(strlower(text), buff) then
				tooltip:Hide()
				local oeTime = oe/1000
				return text, oeTime, oc
			end
		end

		tooltip:Hide()
	end
	tooltip:Hide()
end

function mb_hasBuffNamed(oBuff, unit)
    local c = nil
	local buff = strlower(oBuff)
	local tooltip = MMBTooltip
	local textleft1 = getglobal(tooltip:GetName().."TextLeft1")
	if not unit then
		unit  = "player"
	end

	for i = 1, 32 do
		tooltip:SetOwner(UIParent, "ANCHOR_NONE")
		tooltip:SetUnitBuff(unit, i)
		b = textleft1:GetText()
		tooltip:Hide()

		if ( b and strfind(strlower(b), buff) ) then
			return "buff", i, b
		elseif ( c == b ) then
			break
		end
	end

	c = nil

	for i = 1, 16 do
		tooltip:SetOwner(UIParent, "ANCHOR_NONE")
		tooltip:SetUnitDebuff(unit, i)
		b = textleft1:GetText()
		tooltip:Hide()

		if ( b and strfind(strlower(b), buff) ) then
			return "debuff", i, b
		elseif ( c == b) then
			break
		end
	end

	tooltip:Hide()
end

function mb_hasBuffOrDebuff(spell, target, buffOrDebuff)
	if (spell == "Windfury" or spell == "Windfury Totem 3" or spell == "Windfury Weapon" or spell == "Windfury Totem") then
		return mb_hasWeaponBuff(spell, target)
	end

	if buffOrDebuff == "buff" then
		for k, v in pairs(mb_buffData) do
			if k == spell then 
				return mb_buffCheck(v, target) 
			end
		end
	elseif buffOrDebuff == "debuff" then
		for k, v in pairs(mb_buffData) do
			if k == spell then 
				return mb_debuffCheck(v, target) 
			end
		end
	end
end

function mb_hasDebuff(spell, target)
	for k, v in pairs(mb_buffData) do
		if spell == k then 
			return mb_debuffCheck(v, target) 
		end
	end
end

function mb_buffCheck(text, target)
	local i = 1
	local buff = UnitBuff(target, i)

	while buff do
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
	local buff = UnitDebuff(target, i)

	while buff do
		if buff == text then
			return true
		end
		i = i + 1
		buff = UnitDebuff(target, i)
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
            mb_multiBuffPriest(spell)
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

mb_buffData["Prayer of Fortitude"] 			 =  "Interface\\Icons\\Spell_Holy_PrayerOfFortitude"
mb_buffData["Power Word: Fortitude"] 		 =  "Interface\\Icons\\Spell_Holy_WordFortitude"
mb_buffData["Prayer of Spirit"] 			 =  "Interface\\Icons\\Spell_Holy_PrayerofSpirit"
mb_buffData["Divine Spirit"] 				 =  "Interface\\Icons\\Spell_Holy_DivineSpirit"
mb_buffData["Prayer of Shadow Protection"]  = "Interface\\Icons\\Spell_Holy_PrayerofShadowProtection"
mb_buffData["Shadow Protection"] 			 =  "Interface\\Icons\\Spell_Shadow_AntiShadow"
mb_buffData["Weakened Soul"] 				 =  "Interface\\Icons\\Spell_Holy_AshesToAshes"
mb_buffData["Power Word: Shield"] 			 =  "Interface\\Icons\\Spell_Holy_PowerWordShield"
mb_buffData["Shadowform"] 					 =  "Interface\\Icons\\Spell_Shadow_Shadowform"
mb_buffData["Renew"] 						 =  "Interface\\Icons\\Spell_Holy_Renew"
mb_buffData["Mind Control"]					 =  "Interface\\Icons\\Spell_Shadow_ShadowWordDominate"
mb_buffData["Inner Fire"] 					 =  "Interface\\Icons\\Spell_Holy_InnerFire"
mb_buffData["Inner Focus"] 					 =  "Interface\\Icons\\Spell_Frost_WindWalkOn"
mb_buffData["Spirit Tap"] 					 =  "Interface\\Icons\\Spell_Shadow_Requiem"
mb_buffData["Vampiric Embrace"] 			 =  "Interface\\Icons\\Spell_Shadow_UnsummonBuilding"
mb_buffData["Fade"] 						 =  "Interface\\Icons\\Spell_Magic_LesserInvisibilty"
mb_buffData["Power Infusion"] 				 =  "Interface\\Icons\\Spell_Holy_PowerInfusion"
mb_buffData["Spirit of Redemption"] 		 =  "Interface\\Icons\\Spell_Holy_GreaterHeal"
mb_buffData["Fear Ward"] 					 =  "Interface\\Icons\\Spell_Holy_Excorcism"
mb_buffData["Shadowguard"] 					 =  "Interface\\Icons\\Spell_Nature_LightningShield"
mb_buffData["Devouring Plague"] 			 =  "Interface\\Icons\\Spell_Shadow_BlackPlague"
mb_buffData["Hex of Weakness"] 				 =  "Interface\\Icons\\Spell_Shadow_FingerOfDeath"
mb_buffData["Holy Fire"] 					 =  "Interface\\Icons\\Spell_Holy_SearingLight"
mb_buffData["Shadow Weaving"] 				 =  "Interface\\Icons\\Spell_Shadow_BlackPlague"
mb_buffData["Inspiration"] 					 =  "Interface\\Icons\\INV_Shield_06"
mb_buffData["Psychic Scream"] 				 =  "Interface\\Icons\\Spell_Shadow_PsychicScream"
mb_buffData["Shackle Undead"] 				 =  "Interface\\Icons\\Spell_Nature_Slow"
mb_buffData["Shadow Word: Pain"] 			 =  "Interface\\Icons\\Spell_Shadow_ShadowWordPain"
mb_buffData["Mind Soothe"] 					 =  "Interface\\Icons\\Spell_Holy_MindSooth"
mb_buffData["Silence"]						 =  "Interface\\Icons\\Spell_Shadow_ImpPhaseShift"
mb_buffData["Blackout"] 					 =  "Interface\\Icons\\Spell_Shadow_GatherShadows"
mb_buffData["Gift of the Wild"] 			 =  "Interface\\Icons\\Spell_Nature_Regeneration"
mb_buffData["Mark of the Wild"] 			 =  "Interface\\Icons\\Spell_Nature_Regeneration"
mb_buffData["Rejuvenation"] 				 =  "Interface\\Icons\\Spell_Nature_Rejuvenation"
mb_buffData["Regrowth"] 					 =  "Interface\\Icons\\Spell_Nature_ResistNature"
mb_buffData["Nature\'s Grace"] 				 =  "Interface\\Icons\\Spell_Nature_NaturesBlessing"
mb_buffData["Nature\'s Swiftness"]			 =  "Interface\\Icons\\Spell_Nature_RavenForm"
mb_buffData["Abolish Poison"] 				 =  "Interface\\Icons\\Spell_Nature_NullifyPoison_02"
mb_buffData["Innervate"] 					 =  "Interface\\Icons\\Spell_Nature_Lightning"
mb_buffData["Tranquility"] 					 =  "Interface\\Icons\\Spell_Nature_Tranquility"
mb_buffData["Barkskin"] 					 =  "Interface\\Icons\\Spell_Nature_StoneclawTotem"
mb_buffData["Thorns"] 						 =  "Interface\\Icons\\Spell_Nature_Thorns"
mb_buffData["Leader of the Pack"] 			 =  "Interface\\Icons\\Spell_Nature_UnyeildingStamina"
mb_buffData["Moonkin Aura"] 				 =  "Interface\\Icons\\Spell_Nature_MoonGlow"
mb_buffData["Moonkin Form"] 				 =  "Interface\\Icons\\Spell_Nature_ForceOfNature"
mb_buffData["Cat Form"]						 =  "Interface\\Icons\\Ability_Druid_CatForm"
mb_buffData["Bear Form"] 					 =  "Interface\\Icons\\Ability_Racial_BearForm"
mb_buffData["Dire Bear Form"] 				 =  "Interface\\Icons\\Ability_Racial_BearForm"
mb_buffData["Travel Form"] 					 =  "Interface\\Icons\\Ability_Druid_TravelForm"
mb_buffData["Aquatic Form"] 				 =  "Interface\\Icons\\Ability_Druid_AquaticForm"
mb_buffData["Prowl"] 						 =  "Interface\\Icons\\Ability_Ambush"
mb_buffData["Tiger\'s Fury"] 				 =  "Interface\\Icons\\Ability_Mount_JungleTiger"
mb_buffData["Dash"] 						 =  "Interface\\Icons\\Ability_Druid_Dash"
mb_buffData["Blessing of the Claw"] 		 =  "Interface\\Icons\\Spell_Holy_BlessingOfAgility"
mb_buffData["Nature\'s Grasp"] 				 =  "Interface\\Icons\\Spell_Nature_NaturesWrath"
mb_buffData["Omen of Clarity"] 				 =  "Interface\\Icons\\Spell_Nature_CrystalBall"
mb_buffData["Clearcasting"] 				 =  "Interface\\Icons\\Spell_Shadow_ManaBurn"
mb_buffData["Enrage"] 						 =  "Interface\\Icons\\Ability_Druid_Enrage"
mb_buffData["Frenzied Regeneration"]		 =  "Interface\\Icons\\Ability_BullRush"
mb_buffData["Growl"] 						 =  "Interface\\Icons\\Ability_Druid_Physical_Taunt"
mb_buffData["Pounce"] 						 =  "Interface\\Icons\\Ability_Druid_SupriseAttack"
mb_buffData["Rake"] 						 =  "Interface\\Icons\\Ability_Druid_Disembowel"
mb_buffData["Rip"] 							 =  "Interface\\Icons\\Ability_GhoulFrenzy"
mb_buffData["Moonfire"]						 =  "Interface\\Icons\\Spell_Nature_StarFall"
mb_buffData["Faerie Fire"] 					 =  "Interface\\Icons\\Spell_Nature_FaerieFire" 
mb_buffData["Faerie Fire (Feral)"]			 =  "Interface\\Icons\\Spell_Nature_FaerieFire"
mb_buffData["Hibernate"] 					 =  "Interface\\Icons\\Spell_Nature_Sleep"
mb_buffData["Insect Swarm"]					 =  "Interface\\Icons\\Spell_Nature_InsectSwarm"
mb_buffData["Entangling Roots"] 			 =  "Interface\\Icons\\Spell_Nature_StrangleVines"
mb_buffData["Starfire Stun"] 				 =  "Interface\\Icons\\Spell_Arcane_Starfire"
mb_buffData["Hurricane"] 					 =  "Interface\\Icons\\Spell_Nature_Cyclone"
mb_buffData["Soothe Animal"] 				 =  "Interface\\Icons\\Spell_Hunter_BeastSoothe"
mb_buffData["Bash"] 						 =  "Interface\\Icons\\Ability_Druid_Bash"
mb_buffData["Challenging Roar"] 			 =  "Interface\\Icons\\Ability_Druid_ChallangingRoar"
mb_buffData["Demoralizing Roar"] 			 =  "Interface\\Icons\\Ability_Druid_DemoralizingRoar"
mb_buffData["Arcane Brilliance"] 			 =  "Interface\\Icons\\Spell_Holy_ArcaneIntellect"
mb_buffData["Arcane Intellect"] 			 =  "Interface\\Icons\\Spell_Holy_MagicalSentry"
mb_buffData["Dampen Magic"] 				 =  "Interface\\Icons\\Spell_Nature_AbolishMagic"
mb_buffData["Amplify Magic"]				 =  "Interface\\Icons\\Spell_Holy_FlashHeal"
mb_buffData["Ice Armor"] 					 =  "Interface\\Icons\\Spell_Frost_FrostArmor02"
mb_buffData["Mana Shield"] 					 =  "Interface\\Icons\\Spell_Shadow_DetectLesserInvisibility"
mb_buffData["Fire Ward"] 					 =  "Interface\\Icons\\Spell_Fire_FireArmor"
mb_buffData["Ice Block"] 					 =  "Interface\\Icons\\Spell_Frost_Frost"
mb_buffData["Ice Barrier"] 					 =  "Interface\\Icons\\Spell_Ice_Lament"
mb_buffData["Evocation"] 					 =  "Interface\\Icons\\Spell_Nature_Purge"
mb_buffData["Frost Ward"] 					 =  "Interface\\Icons\\Spell_Frost_FrostWard"
mb_buffData["Mage Armor"] 					 =  "Interface\\Icons\\Spell_MageArmor"
mb_buffData["Clearcasting"] 				 =  "Interface\\Icons\\Spell_Shadow_ManaBurn"
mb_buffData["Presence of Mind"] 			 =  "Interface\\Icons\\Spell_Nature_EnchantArmor"
mb_buffData["Combustion"] 					 =  "Interface\\Icons\\Spell_Fire_SealOfFire"
mb_buffData["Netherwind Focus"] 			 =  "Interface\\Icons\\Spell_Shadow_Teleport"
mb_buffData["Detect Magic"] 				 =  "Interface\\Icons\\Spell_Holy_Dizzy"
mb_buffData["Polymorph"] 					 =  "Interface\\Icons\\Spell_Nature_Polymorph"
mb_buffData["Frostbolt"] 					 =  "Interface\\Icons\\Spell_Frost_FrostBolt02"
mb_buffData["Frost Nova"] 					 =  "Interface\\Icons\\Spell_Frost_FrostNova"
mb_buffData["Frostbite"] 					 =  "Interface\\Icons\\Spell_Frost_FrostArmor"
mb_buffData["Scorch"] 						 =  "Interface\\Icons\\Spell_Fire_SoulBurn"
mb_buffData["Ignite"] 						 =  "Interface\\Icons\\Spell_Fire_Incinerate"
mb_buffData["Winter\'s Chill"] 				 =  "Interface\\Icons\\Spell_Frost_ChillingBlast"
mb_buffData["Arcane Power"] 				 =  "Interface\\Icons\\Spell_Nature_Lightning"
mb_buffData["Demon Skin"] 					 =  "Interface\\Icons\\Spell_Shadow_RagingScream"
mb_buffData["Demon Armor"] 					 =  "Interface\\Icons\\Spell_Shadow_RagingScream"
mb_buffData["Fire Shield"] 					 =  "Interface\\Icons\\Spell_Fire_FireArmor"
mb_buffData["Sacrifice"] 					 =  "Interface\\Icons\\Spell_Shadow_SacrificialShield"
mb_buffData["Underwater Breathing"] 		 =  "Interface\\Icons\\Spell_Shadow_DemonBreath"
mb_buffData["Eye of Kilrogg"]				 =  "Interface\\Icons\\Spell_Shadow_EvilEye"
mb_buffData["Nightfall"] 					 =  "Interface\\Icons\\Spell_Shadow_Twilight"
mb_buffData["Touch of Shadow"] 				 =  "Interface\\Icons\\Spell_Shadow_PsychicScream"
mb_buffData["Burning Wish"] 				 =  "Interface\\Icons\\Spell_Shadow_PsychicScream"
mb_buffData["Fel Stamina"] 					 =  "Interface\\Icons\\Spell_Shadow_PsychicScream"
mb_buffData["Fel Energy"] 					 =  "Interface\\Icons\\Spell_Shadow_PsychicScream"
mb_buffData["Shadow Ward"] 					 =  "Interface\\Icons\\Spell_Shadow_AntiShadow"
mb_buffData["Master Demonologist"] 			 =  "Interface\\Icons\\Spell_Shadow_ShadowPact"
mb_buffData["Soul Link"] 					 =  "Interface\\Icons\\Spell_Shadow_GatherShadows"
mb_buffData["Detect Lesser Invisibility"]	 =  "Interface\\Icons\\Spell_Shadow_DetectLesserInvisibility"
mb_buffData["Detect Invisibility"] 			 =  "Interface\\Icons\\Spell_Shadow_DetectInvisibility"
mb_buffData["Detect Greater Invisibility"] 	 =  "Interface\\Icons\\Spell_Shadow_DetectInvisibility"
mb_buffData["Soulstone"] 					 =  "Interface\\Icons\\Spell_Shadow_SoulGem"
mb_buffData["Blood Pact"] 					 =  "Interface\\Icons\\Spell_Shadow_BloodBoil"
mb_buffData["Paranoia"] 					 =  "Interface\\Icons\\Spell_Shadow_AuraOfDarkness"
mb_buffData["Phase Shift"] 					 =  "Interface\\Icons\\Spell_Shadow_ImpPhaseShift"
mb_buffData["Health Funnel"] 				 =  "Interface\\Icons\\Spell_Shadow_LifeDrain"
mb_buffData["Consume Shadows"] 				 =  "Interface\\Icons\\Spell_Shadow_AntiShadow"
mb_buffData["Lesser Invisibility"] 			 =  "Interface\\Icons\\Spell_Magic_LesserInvisibility"
mb_buffData["Corruption"] 					 =  "Interface\\Icons\\Spell_Shadow_AbominationExplosion"
mb_buffData["Immolate"] 					 =  "Interface\\Icons\\Spell_Fire_Immolation"
mb_buffData["Siphon Life"] 					 =  "Interface\\Icons\\Spell_Shadow_Requiem"
mb_buffData["Drain Life"] 					 =  "Interface\\Icons\\Spell_Shadow_LifeDrain02"
mb_buffData["Drain Soul"] 					 =  "Interface\\Icons\\Spell_Shadow_Haunting"
mb_buffData["Drain Mana"] 					 =  "Interface\\Icons\\Spell_Shadow_SiphonMana"
mb_buffData["Improved Shadow Bolt"] 		 =  "Interface\\Icons\\Spell_Shadow_ShadowBolt"
mb_buffData["Curse of Agony"] 				 =  "Interface\\Icons\\Spell_Shadow_CurseOfSargeras"
mb_buffData["Curse of Weakness"] 			 =  "Interface\\Icons\\Spell_Shadow_CurseOfMannoroth"
mb_buffData["Curse of Shadow"] 				 =  "Interface\\Icons\\Spell_Shadow_CurseOfAchimonde"
mb_buffData["Curse of the Elements"] 		 =  "Interface\\Icons\\Spell_Shadow_ChillTouch"
mb_buffData["Curse of Doom"] 				 =  "Interface\\Icons\\Spell_Shadow_AuraOfDarkness"
mb_buffData["Curse of Tongues"] 			 =  "Interface\\Icons\\Spell_Shadow_CurseOfTounges"
mb_buffData["Curse of Recklessness"] 		 =  "Interface\\Icons\\Spell_Shadow_UnholyStrength"
mb_buffData["Curse of Exhaustion"] 			 =  "Interface\\Icons\\Spell_Shadow_GrimWard"
mb_buffData["Enslave Demon"] 				 =  "Interface\\Icons\\Spell_Shadow_EnslaveDemon"
mb_buffData["Hellfire"] 					 =  "Interface\\Icons\\Spell_Fire_Incinerate"
mb_buffData["Fear"] 						 =  "Interface\\Icons\\Spell_Shadow_Possession"
mb_buffData["Banish"] 						 =  "Interface\\Icons\\Spell_Shadow_Cripple"
mb_buffData["Seduction"] 					 =  "Interface\\Icons\\Spell_Shadow_MindSteal"
mb_buffData["Tainted Blood"] 				 =  "Interface\\Icons\\Spell_Shadow_LifeDrain"
mb_buffData["Spell Lock"] 					 =  "Interface\\Icons\\Spell_Shadow_MindRot"
mb_buffData["Howl of Terror"] 				 =  "Interface\\Icons\\Spell_Shadow_DeathScream"
mb_buffData["Death Coil"] 					 =  "Interface\\Icons\\Spell_Shadow_DeathCoil"
mb_buffData["Frost Shock"] 					 =  "Interface\\Icons\\Spell_Frost_FrostShock"
mb_buffData["Flame Shock"] 					 =  "Interface\\Icons\\Spell_Fire_FlameShock"
mb_buffData["Stormstrike"] 					 =  "Interface\\Icons\\Spell_Holy_SealOfMight"
mb_buffData["Earthbind Totem"] 				 =  "Interface\\Icons\\Spell_Nature_StrengthhOfEarthTotem02"
mb_buffData["Strength of Earth Totem"] 		 =  "Interface\\Icons\\Spell_Nature_EarthBindTotem"
mb_buffData["Grace of Air Totem"] 			 =  "Interface\\Icons\\Spell_Nature_InvisibilityTotem"
mb_buffData["Mana Spring Totem"] 			 =  "Interface\\Icons\\Spell_Nature_ManaRegenTotem"
mb_buffData["Healing Stream Totem"] 		 =  "Interface\\Icons\\INV_Spear_04"
mb_buffData["Grounding Totem"] 				 =  "Interface\\Icons\\Spell_Nature_GroundingTotem"
mb_buffData["Mana Tide Totem"] 				 =  "Interface\\Icons\\Spell_Frost_SummonWaterElemental"
mb_buffData["Tranquil Air Totem"] 			 =  "Interface\\Icons\\Spell_Nature_Brilliance"
mb_buffData["Stoneskin Totem"] 				 =  "Interface\\Icons\\Spell_Nature_StoneSkinTotem"
mb_buffData["Frost Resistance Totem"] 		 =  "Interface\\Icons\\Spell_FrostResistanceTotem_01"
mb_buffData["Fire Resistance Totem"] 		 =  "Interface\\Icons\\Spell_FireResistanceTotem_01"
mb_buffData["Nature Resistance Totem"] 		 =  "Interface\\Icons\\Spell_Nature_NatureResistanceTotem"
mb_buffData["Windwall Totem"] 				 =  "Interface\\Icons\\Spell_Nature_EarthBind"
mb_buffData["Lightning Shield"] 			 =  "Interface\\Icons\\Spell_Nature_LightningShield"
mb_buffData["Healing Way"] 					 =  "Interface\\Icons\\Spell_Nature_HealingWay"
mb_buffData["Ancestral Fortitude"] 			 =  "Interface\\Icons\\Spell_Nature_UndyingStrength"
mb_buffData["Totemic Power"] 				 =  "Interface\\Icons\\Spell_Magic_MageArmor"
mb_buffData["Ghost Wolf"] 					 =  "Interface\\Icons\\Spell_Nature_SpiritWolf"
mb_buffData["Aspect of the Hawk"] 			 =  "Interface\\Icons\\Spell_Nature_RavenForm"
mb_buffData["Aspect of the Monkey"] 		 =  "Interface\\Icons\\Ability_Hunter_AspectOfTheMonkey"
mb_buffData["Aspect of the Cheetah"] 		 =  "Interface\\Icons\\Ability_Mount_JungleTiger"
mb_buffData["Aspect of the Pack"] 			 =  "Interface\\Icons\\Ability_Mount_WhiteTiger"
mb_buffData["Aspect of the Beast"] 			 =  "Interface\\Icons\\Ability_Mount_PinkTiger"
mb_buffData["Aspect of the Wild"] 			 =  "Interface\\Icons\\Spell_Nature_ProtectionformNature"
mb_buffData["Rapid Fire"] 					 =  "Interface\\Icons\\Ability_Hunter_RunningShot"
mb_buffData["Eyes of the Beast"] 			 =  "Interface\\Icons\\Ability_EyesOfTheOwl"
mb_buffData["Deterrence"] 					 =  "Interface\\Icons\\Ability_Whirlwind"
mb_buffData["Feed Pet"] 					 =  "Interface\\Icons\\Ability_Hunter_BeastTraining"
mb_buffData["Mend Pet"] 					 =  "Interface\\Icons\\Ability_Hunter_MendPet"
mb_buffData["Concussive Shot"] 				 =  "Interface\\Icons\\Spell_Frost_Stun"
mb_buffData["Hunter\'s Mark"] 				 =  "Interface\\Icons\\Ability_Hunter_SniperShot"
mb_buffData["Wing Clip"] 					 =  "Interface\\Icons\\Ability_Rogue_Trip"
mb_buffData["Serpent Sting"] 				 =  "Interface\\Icons\\Ability_Hunter_Quickshot"
mb_buffData["Scorpid Sting"] 				 =  "Interface\\Icons\\Ability_Hunter_CriticalShot"
mb_buffData["Viper Sting"] 					 =  "Interface\\Icons\\Ability_Hunter_AimedShot"
mb_buffData["Scatter Shot"] 				 =  "Interface\\Icons\\Ability_GolemStormBolt"
mb_buffData["Freezing Trap"] 				 =  "Interface\\Icons\\Spell_Frost_ChainsOfIce"
mb_buffData["Frost Trap"] 					 =  "Interface\\Icons\\Spell_Frost_FreezingBreath"
mb_buffData["Immolation Trap"] 				 =  "Interface\\Icons\\Spell_Fire_FlameShock"
mb_buffData["Explosive Trap"] 				 =  "Interface\\Icons\\Spell_Fire_SelfDestruct"
mb_buffData["Trueshot Aura"] 				 =  "Interface\\Icons\\Ability_TrueShot"
mb_buffData["Feign Death"] 					 =  "Interface\\Icons\\Ability_Rogue_FeignDeath"
mb_buffData["Screech"] 					 	 =  "Interface\\Icons\\Ability_Hunter_Pet_Bat"
mb_buffData["Stealth"] 						 =  "Interface\\Icons\\Ability_Stealth"
mb_buffData["Vanish"] 						 =  "Interface\\Icons\\Ability_Vanish"
mb_buffData["Blade Flurry"] 				 =  "Interface\\Icons\\Ability_Warrior_PunishingBlow"
mb_buffData["Adrenaline Rush"] 				 =  "Interface\\Icons\\Spell_Shadow_ShadowWordDominate"
mb_buffData["SPrint"] 						 =  "Interface\\Icons\\Ability_Rogue_SPrint"
mb_buffData["Hemorrhage"] 					 =  "Interface\\Icons\\Spell_Shadow_Lifedrain"
mb_buffData["Gouge"] 						 =  "Interface\\Icons\\Ability_Gouge"
mb_buffData["Garrote"] 						 =  "Interface\\Icons\\Ability_Rogue_Garrote"
mb_buffData["Blind"] 						 =  "Interface\\Icons\\Spell_Shadow_MindSteal"
mb_buffData["Rupture"] 						 =  "Interface\\Icons\\Ability_Rogue_Rupture"
mb_buffData["Cheap Shot"] 					 =  "Interface\\Icons\\Ability_CheapShot"
mb_buffData["Kidney Shot"]					 =  "Interface\\Icons\\Ability_Rogue_KidneyShot"
mb_buffData["Sap"] 							 =  "Interface\\Icons\\Ability_Sap"
mb_buffData["Expose Armor"] 				 =  "Interface\\Icons\\Ability_Warrior_Riposte"
mb_buffData["Slice and Dice"] 				 =  "Interface\\Icons\\Ability_Rogue_SliceDice"
mb_buffData["Mace Stun"]					 =  "Interface\\Icons\\Spell_Frost_Stun"
mb_buffData["Battle Shout"] 				 =  "Interface\\Icons\\Ability_Warrior_BattleShout"
mb_buffData["Taunt"] 						 =  "Interface\\Icons\\Spell_Nature_Reincarnation"
mb_buffData["Bloodrage"] 					 =  "Interface\\Icons\\Ability_Racial_BloodRage"
mb_buffData["Death Wish"] 					 =  "Interface\\Icons\\Spell_Shadow_DeathPact"
mb_buffData["Enraged"] 						 =  "Interface\\Icons\\Spell_Shadow_UnholyFrenzy"
mb_buffData["Flurry"] 						 =  "Interface\\Icons\\Ability_GhoulFrenzy"
mb_buffData["Recklessness"] 				 =  "Interface\\Icons\\Ability_CriticalStrike"
mb_buffData["Berserker Rage"] 				 =  "Interface\\Icons\\Spell_Nature_AncestralGuardian"
mb_buffData["Mocking Blow"] 				 =  "Interface\\Icons\\Ability_Warrior_PunishingBlow"
mb_buffData["Mortal Strike"] 				 =  "Interface\\Icons\\Ability_Warrior_SavageBlow"
mb_buffData["Thunder Clap"] 				 =  "Interface\\Icons\\Spell_Nature_ThunderClap"
mb_buffData["Piercing Howl"] 				 =  "Interface\\Icons\\Spell_Shadow_DeathScream"
mb_buffData["Hamstring"] 					 =  "Interface\\Icons\\Ability_ShockWave"
mb_buffData["Concussion Blow"] 				 =  "Interface\\Icons\\Ability_ThunderBolt"
mb_buffData["Demoralizing Shout"] 			 =  "Interface\\Icons\\Ability_Warrior_WarCry"
mb_buffData["Intimidating Shout"] 			 =  "Interface\\Icons\\Ability_GolemThunderClap"
mb_buffData["Sunder Armor"] 				 =  "Interface\\Icons\\Ability_Warrior_Sunder"
mb_buffData["Disarm"]						 =  "Interface\\Icons\\Ability_Warrior_Disarm"
mb_buffData["Sweeping Strikes"]				 =  "Interface\\Icons\\Ability_Rogue_SliceDice"
mb_buffData["Devotion Aura"]   				 =  "Interface\\Icons\\Spell_Holy_DevotionAura" 
mb_buffData["Concentration Aura"] 			 =  "Interface\\Icons\\Spell_Holy_MindSooth"
mb_buffData["Fire Resistance Aura"]			 =  "Interface\\Icons\\Spell_Fire_SealOfFire"
mb_buffData["Frost Resistance Aura"]		 =  "Interface\\Icons\\Spell_Frost_WizardMark"
mb_buffData["Retribution Aura"]				 =  "Interface\\Icons\\Spell_Holy_AuraOfLight"
mb_buffData["Greater Blessing of Wisdom"]   = "Interface\\Icons\\Spell_Holy_GreaterBlessingofWisdom" 
mb_buffData["Greater Blessing of Kings"]	 =  "Interface\\Icons\\Spell_Magic_GreaterBlessingofKings" 
mb_buffData["Greater Blessing of Salvation"] =  "Interface\\Icons\\Spell_Holy_GreaterBlessingofSalvation" 
mb_buffData["Greater Blessing of Might"]    = "Interface\\Icons\\Spell_Holy_GreaterBlessingofKings" 
mb_buffData["Greater Blessing of Light"]    = "Interface\\Icons\\Spell_Holy_GreaterBlessingofLight" 
mb_buffData["Greater Blessing of Sanctuary"] =  "Interface\\Icons\\Spell_Holy_GreaterBlessingofSanctuary" 
mb_buffData["Hammer of Justice"] 			 =  "Interface\\Icons\\Spell_Holy_SealOfMight"
mb_buffData["Seal of Light"] 				 =  "Interface\\Icons\\Spell_Holy_HealingAura"
mb_buffData["Seal of Wisdom"]				 =  "Interface\\Icons\\Spell_Holy_RighteousnessAura"
mb_buffData["Judgement of Light"] 			 =  "Interface\\Icons\\Spell_Holy_HealingAura"
mb_buffData["Judgement of Wisdom"]			 =  "Interface\\Icons\\Spell_Holy_RighteousnessAura"
mb_buffData["Blessing of Protection"] 		 =  "Interface\\Icons\\Spell_Holy_SealOfProtection"
mb_buffData["Forbearance"] 					 =  "Interface\\Icons\\Spell_Holy_RemoveCurse"
mb_buffData["Divine Favor"]					 =  "Interface\\Icons\\Spell_Holy_Heal"
mb_buffData["Blinding Light"]				 =  "Interface\\Icons\\Spell_Holy_SearingLight"
mb_buffData["Seal of Righteousness"]		 =  "Interface\\Icons\\Ability_ThunderBolt"
mb_buffData["Berserking"] 					 =  "Interface\\Icons\\Racial_Troll_Berserk"
mb_buffData["Blood Fury Debuff"] 			 =  "Interface\\Icons\\Ability_Rogue_FeignDeath"
mb_buffData["Blood Fury"] 					 =  "Interface\\Icons\\Racial_Orc_BerserkerStrength"
mb_buffData["War Stomp"] 					 =  "Interface\\Icons\\Ability_WarStomp"
mb_buffData["Cannibalize"] 					 =  "Interface\\Icons\\Ability_Racial_Cannibalize"
mb_buffData["Will of the Forsaken"] 		 =  "Interface\\Icons\\Spell_Shadow_RaiseDead"
mb_buffData["Warchief\'s Blessing"] 					 =  "Interface\\Icons\\Spell_Arcane_TeleportOrgrimmar"
mb_buffData["Rallying Cry of the Dragonslayer"] 	 =  "Interface\\Icons\\INV_Misc_Head_Dragon_01"
mb_buffData["Spirit of Zandalar"] 					 =  "Interface\\Icons\\Ability_Creature_Poison_05"
mb_buffData["Songflower Serenade"] 					 =  "Interface\\Icons\\Spell_Holy_MindVision"
mb_buffData["Sayge\'s Dark Fortune of Strength"] 	 =  "Interface\\Icons\\INV_Misc_Orb_02"
mb_buffData["Sayge\'s Dark Fortune of Damage"] 		 =  "Interface\\Icons\\INV_Misc_Orb_02"
mb_buffData["Sayge\'s Dark Fortune of Intelligence"] = "Interface\\Icons\\INV_Misc_Orb_02"
mb_buffData["Sayge\'s Dark Fortune of Agility"] 		 =  "Interface\\Icons\\INV_Misc_Orb_02"
mb_buffData["Sayge\'s Dark Fortune of Resistance"] 	 =  "Interface\\Icons\\INV_Misc_Orb_02"
mb_buffData["Sayge\'s Dark Fortune of Stamina"] 		 =  "Interface\\Icons\\INV_Misc_Orb_02"
mb_buffData["Sayge\'s Dark Fortune of Spirit"] 		 =  "Interface\\Icons\\INV_Misc_Orb_02"
mb_buffData["Sayge\'s Dark Fortune of Armor"] 		 =  "Interface\\Icons\\INV_Misc_Orb_02"
mb_buffData["Fengus\' Ferocity"] 					 =  "Interface\\Icons\\Spell_Nature_UndyingStrength"
mb_buffData["Mol\'dar\'s Moxie"] 						 =  "Interface\\Icons\\Spell_Nature_MassTeleport"
mb_buffData["Slip\'kik\'s Savvy"] 					 =  "Interface\\Icons\\Spell_Holy_LesserHeal02"
mb_buffData["Swiftness of Zanza"] 					 =  "Interface\\Icons\\INV_Potion_31"
mb_buffData["Spirit of Zanza"] 						 =  "Interface\\Icons\\INV_Potion_30"
mb_buffData["Recently Bandaged"] 					 =  "Interface\\Icons\\INV_Misc_Bandage_08"
mb_buffData["First Aid"] 							 =  "Interface\\Icons\\Spell_Holy_Heal"
mb_buffData["Frozen Rune"]							 =  "Interface\\Icons\\Spell_Fire_MasterOfElements"
mb_buffData["Shadow Protection Potion"]				 =  "Interface\\Icons\\Spell_Shadow_RagingScream"
mb_buffData["Shadow Storm"] 				 =  "Interface\\Icons\\Spell_Shadow_ShadowBolt" --aq40 anubisaths BUFF
mb_buffData["Mana Burn"]					 =  "Interface\\Icons\\Spell_Shadow_ManaBurn" --aq40 anubisaths BUFF
mb_buffData["Fire and Arcane Reflect"] 		 =  "Interface\\Icons\\Spell_Arcane_Blink" --same icon, 
mb_buffData["Shadow and Frost Reflect"]		 =  "Interface\\Icons\\Spell_Arcane_Blink" --same icon, 
mb_buffData["Mending"] 						 =  "Interface\\Icons\\Spell_Nature_ResistNature" --aq40 anubisaths BUFF
mb_buffData["Periodic Knock Away"] 			 =  "Interface\\Icons\\Ability_UpgradeMoonglaive" --aq40 anubisaths BUFF
mb_buffData["Living Bomb"] 					 =  "Interface\\Icons\\INV_Enchant_EssenceAstralSmall" --Baron Bomb
mb_buffData["Burning Adrenaline"] 			 =  "Interface\\Icons\\INV_Gauntlets_03" --Vaelastrasz Bomb
mb_buffData["Brood Affliction: Bronze"] 	 =  "Interface\\Icons\\INV_Misc_Head_Dragon_Bronze" --Chromaggus bronze debuff
mb_buffData["Plague"] 						 =  "Interface\\Icons\\Spell_Shadow_CurseOfTounges" --aq20/40 anubisath plague debuff
mb_buffData["Drink"] 						 =  "Interface\\Icons\\INV_Drink_18" --LVL 55 water ONLY, not lvl 45 or below.
mb_buffData["Shadow Weakness"] 				 =  "Interface\\Icons\\INV_Misc_QirajiCrystal_05" --Ossirian Weakness
mb_buffData["Fire Weakness"] 				 =  "Interface\\Icons\\INV_Misc_QirajiCrystal_02" --Ossirian Weakness
mb_buffData["Nature Weakness"] 				 =  "Interface\\Icons\\INV_Misc_QirajiCrystal_03" --Ossirian Weakness
mb_buffData["Arcane Weakness"] 				 =  "Interface\\Icons\\INV_Misc_QirajiCrystal_01" --Ossirian Weakness
mb_buffData["Frost Weakness"] 				 =  "Interface\\Icons\\INV_Misc_QirajiCrystal_04" --Ossirian Weakness
mb_buffData["Magic Reflection"] 			 =  "Interface\\Icons\\Spell_Frost_FrostShock" --Magic Reflection on Major Domo adds
mb_buffData["Deaden Magic"] 				 =  "Interface\\Icons\\Spell_Holy_SealOfSalvation" --Shazzrah Deaden Magicc BUFF, can be dispelled.
mb_buffData["Corrupted Healing"] 			 =  "Interface\\Icons\\Spell_Shadow_Charm" --Nefarian Priestcall debuff, stop heal if have this debuff as priest.
mb_buffData["Delusions of Jin\'do"] 			 =  "Interface\\Icons\\Spell_Shadow_UnholyFrenzy" --Jindo shade debuff, do not decurse.
mb_buffData["Threatening Gaze"] 			 =  "Interface\\Icons\\Spell_Shadow_Charm" --Broodlord's Threatening gaze.
mb_buffData["True Fulfillment"] 			 =  "Interface\\Icons\\Spell_Shadow_Charm" --Skerams mindcontrol.
mb_buffData["Nature Protection Potion"] 	 =  "Interface\\Icons\\Spell_Nature_SpiritArmor"
mb_buffData["Fire Protection Potion"] 		 =  "Interface\\Icons\\Spell_Fire_FireArmor"
mb_buffData["Aura of Agony"]				 =  "Interface\\Icons\\Spell_Shadow_CurseOfSargeras"
mb_buffData["Corruption of the Earth"]		 =  "Interface\\Icons\\Ability_Creature_Cursed_03"
mb_buffData["Atiesh"] 						 =  "Interface\\Icons\\Spell_Nature_MoonGlow"
mb_buffData["Hazza\'rah\'s Charm of Healing"] = "Interface\\Icons\\Spell_Holy_HealingAura"
mb_buffData["Magma Shackles"] 				 =  "Interface\\Icons\\Spell_Nature_EarthBind" --Garr's Slowing effect
mb_buffData["Corrupted Mind"]				 =	"Interface\\Icons\\Spell_Shadow_AuraOfDarkness" -- Loatheb
mb_buffData["Fungal Bloom"]					 =  "Interface\\Icons\\Spell_Nature_UnyeildingStamina" -- Buff Loatheb
mb_buffData["Impending Doom"]				 =  "Interface\\Icons\\Spell_Shadow_NightOfTheDead"
mb_buffData["Inevitable Doom"]				 =  "Interface\\Icons\\Spell_Shadow_NightOfTheDead"
mb_buffData["Greater Stoneshield Potion"] 	 = "Interface\\Icons\\INV_Potion_69" 
mb_buffData["Mind Exhaustion"] 				 = "Interface\\Icons\\Spell_Shadow_Teleport" 
mb_buffData["Blessed Sunfruit Juice"] 		 = "Interface\\Icons\\Spell_Holy_Layonhands"
mb_buffData["Blessed Sunfruit"] 			 = "Interface\\Icons\\Spell_Holy_Devotion"
mb_buffData["Spell Vulnerability"]			 = "Interface\\Icons\\Spell_Holy_Elunesgrace"
mb_buffData["Shadow Protection"]			 = "Interface\\Icons\\Spell_Shadow_RagingScream"
mb_buffData["Mutating Injection"]			 = "Interface\\Icons\\Spell_Shadow_CallofBone"
mb_buffData["Juju Ember"]			 		 = "Interface\\Icons\\INV_Misc_MonsterScales_15"
mb_buffData["Shadow Command"] 				 =  "Interface\\Icons\\Spell_Shadow_UnholyFrenzy"
mb_buffData["Elixir of Greater Firepower"] 			 =  "Interface\\Icons\\INV_Potion_60"
mb_buffData["Greater Arcane Elixir"] 				 =  "Interface\\Icons\\INV_Potion_25"
mb_buffData["Elixir of Shadow Power"] 				 =  "Interface\\Icons\\INV_Potion_46"
mb_buffData["Brilliant Wizard Oil"] 				 =  "Interface\\Icons\\INV_Potion_105"
mb_buffData["Brilliant Mana Oil"] 				 =  "Interface\\Icons\\INV_Potion_100"
mb_buffData["Juju Power"] 				 =  "Interface\\Icons\\INV_Misc_MonsterScales_11"
mb_buffData["Juju Might"] 				 =  "Interface\\Icons\\INV_Misc_MonsterScales_07"
mb_buffData["Elemental Sharpening Stone"] 				 =  "Interface\\Icons\\INV_Stone_02"
mb_buffData["Increased Stamina"] 				 =  "Interface\\Icons\\INV_Boots_Plate_03"
mb_buffData["Well Fed"] 				 =  "Interface\\Icons\\INV_Misc_Food"
mb_buffData["Increased Intellect"] 				 =  "Interface\\Icons\\INV_Misc_Organ_03"
mb_buffData["Evil Twin"] 				 =  "Interface\\Icons\\Spell_Shadow_Charm"