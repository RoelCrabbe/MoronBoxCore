-- [[ Config & Constants ]] --

MoronBox.Core = MoronBox.Core or {}
MoronBox.Core.Aura = MoronBox.Core.Aura or {}

local BuffData = {}

function getAura()
    return MoronBox.Core.Aura
end

-- [[ Buff & Debuff ]] --

function MoronBox.Core.Aura.HasBuffNamed(oBuff, unit)
    local buff = string.lower(oBuff)
    local targetUnit = unit or "player"
    local tooltip = MoronBoxTooltip
    local textLeft1 = getglobal(tooltip:GetName() .. "TextLeft1")

    for i = 1, 32 do
        tooltip:SetOwner(UIParent, "ANCHOR_NONE")
        tooltip:SetUnitBuff(targetUnit, i)
        local text = textLeft1:GetText()
        tooltip:Hide()

        if not text then
            break
        end

        if string.find(string.lower(text), buff, 1, true) then
            return "buff", i, text
        end
    end

    for i = 1, 16 do
        tooltip:SetOwner(UIParent, "ANCHOR_NONE")
        tooltip:SetUnitDebuff(targetUnit, i)
        local text = textLeft1:GetText()
        tooltip:Hide()

        if not text then
            break
        end

        if string.find(string.lower(text), buff, 1, true) then
            return "debuff", i, text
        end
    end

    tooltip:Hide()
    return nil
end

function MoronBox.Core.Aura.HasBuffOrDebuff(spell, unit, buffOrDebuff)
    local texture = BuffData[spell]

    if not texture then
        return false
    end

    if buffOrDebuff == "buff" then
        return getAura().BuffCheck(texture, unit)
    elseif buffOrDebuff == "debuff" then
        return getAura().DebuffCheck(texture, unit)
    end

    return false
end

function MoronBox.Core.Aura.BuffCheck(texture, unit)
    local targetUnit = unit or "player"

    for i = 1, 32 do
        local buffTexture = UnitBuff(targetUnit, i)
        if not buffTexture then
            break
        end

        if buffTexture == texture then
            return true
        end
    end

    return false
end

function MoronBox.Core.Aura.DebuffCheck(texture, unit)
    local targetUnit = unit or "player"

    for i = 1, 16 do
        local debuffTexture = UnitDebuff(targetUnit, i)
        if not debuffTexture then
            break
        end

        if debuffTexture == texture then
            return true
        end
    end

    return false
end

function MoronBox.Core.Aura.SomeoneInRaidBuffedWith(spell)
    if UnitIsDead("player") or UnitIsGhost("player") then
        return
    end

    for i = 1, GetNumRaidMembers() do
        if UnitName("raid" .. i) and getUnit().IsAlive("raid" .. i)
            and getAura().HasBuffOrDebuff(spell, "raid" .. i, "buff") then
            return true
        end
    end
end

function MoronBox.Core.Aura.CancelAuraSet(list)
    for itemName, buffName in pairs(list) do
        if getAura().HasBuffOrDebuff(itemName, "player", "buff") then
            CancelBuff(buffName)
        end
    end
end

-- [[ Tracking Specific Debuffs ]] --

function MoronBox.Core.Aura.GetShadowWeavingAmount()
    for i = 1, 16 do
        local texture, applications, dispelType = UnitDebuff("target", i)
        if not texture then
            break
        end

        if texture == BuffData["Shadow Weaving"] and dispelType == "Magic" then
            return (applications or 1)
        end
    end

    return 0
end

function MoronBox.Core.Aura.GetSunderAmount()
    for i = 1, 16 do
        local texture, applications = UnitDebuff("target", i)
        if not texture then
            break
        end

        if texture == BuffData["Sunder Armor"] then
            return (applications or 1)
        end
    end

    return 0
end

function MoronBox.Core.Aura.GetArmorShatterAmount()
    for i = 1, 16 do
        local texture, applications = UnitDebuff("target", i)
        if not texture then
            break
        end

        if texture == BuffData["Armor Shatter"] then
            return (applications or 1)
        end
    end

    return 0
end

function MoronBox.Core.Aura.GetWintersChillAmount()
    for i = 1, 16 do
        local texture, applications, dispelType = UnitDebuff("target", i)
        if not texture then
            break
        end

        if texture == BuffData["Winter's Chill"] and dispelType == "Magic" then
            return (applications or 1)
        end
    end

    return 0
end

function MoronBox.Core.Aura.GetImprovedShadowBoltAmount()
    for i = 1, 16 do
        local texture, applications, dispelType = UnitDebuff("target", i)
        if not texture then
            break
        end

        if texture == BuffData["Improved Shadow Bolt"] and dispelType == "Magic" then
            return (applications or 1)
        end
    end

    return 0
end

function MoronBox.Core.Aura.GetScorchAmount()
    for i = 1, 16 do
        local texture, applications, dispelType = UnitDebuff("target", i)
        if not texture then
            break
        end

        if texture == BuffData["Scorch"] and dispelType == "Magic" then
            return (applications or 1)
        end
    end

    return 0
end

function MoronBox.Core.Aura.GetIgniteAmount()
    local i = 1
    local texture, applications = UnitDebuff("target", i)

    while texture do
        if texture == BuffData["Ignite"] then
            return (applications or 0)
        end

        i = i + 1
        texture, applications = UnitDebuff("target", i)
    end

    return 0
end

-- [[ Specific Aura At Fights ]] --

function MoronBox.Core.Aura.MandokirGaze()
    if not getAura().HasBuffOrDebuff("Threatening Gaze", "player", "debuff") then
        return false
    end

    if getSpells().ImBusy() then
        SpellStopCasting()
    end

    TargetUnit("player")
    return true
end

function MoronBox.Core.Aura.PlayerRazorgoreOrb()
    return getAura().HasBuffOrDebuff("Mind Exhaustion", "player", "debuff")
end

-- [[ Paladin Buffs ]] --

function MoronBox.Core.Aura.MultiBuffBlessing(spell)
    local n, r, j

    if UnitInRaid("player") then
        n = GetNumRaidMembers()
        r = math.random(n) - 1

        for i = 1, n do
            j = i + r
            if j > n then
                j = j - n
            end

            local unit = "raid" .. j
            local currentSpell = spell

            if (currentSpell == "Greater Blessing of Wisdom" or currentSpell == "Greater Blessing of Might") then
                if UnitPowerType(unit) == 0 then
                    currentSpell = "Greater Blessing of Wisdom"
                elseif (UnitPowerType(unit) == 1 or UnitPowerType(unit) == 3) then
                    currentSpell = "Greater Blessing of Might"
                end
            end

            if (currentSpell == "Greater Blessing of Salvation") then
                if getUnit().IsValidFriendlyTarget(unit, currentSpell)
                    and not getAura().HasBuffOrDebuff(currentSpell, unit, "buff")
                    and not getApi().FindInTable(getCoreState().RaidTanks, UnitName(unit)) then
                    ClearTarget()
                    CastSpellByName(currentSpell, nil)
                    SpellTargetUnit(unit)
                    SpellStopTargeting()
                    return
                end
            elseif getUnit().IsValidFriendlyTarget(unit, currentSpell)
                and not getAura().HasBuffOrDebuff(currentSpell, unit, "buff") then
                ClearTarget()
                CastSpellByName(currentSpell, nil)
                SpellTargetUnit(unit)
                SpellStopTargeting()
                return
            end
        end
    elseif UnitInParty("player") then
        n = GetNumPartyMembers()

        for i = 1, n do
            local unit = "party" .. i
            local currentSpell = spell

            if (currentSpell == "Greater Blessing of Wisdom" or currentSpell == "Greater Blessing of Might") then
                if UnitPowerType(unit) == 0 then
                    currentSpell = "Greater Blessing of Wisdom"
                elseif UnitPowerType(unit) == 1 or UnitPowerType(unit) == 3 then
                    currentSpell = "Greater Blessing of Might"
                end
            end

            if getUnit().IsValidFriendlyTarget(unit, currentSpell)
                and not getAura().HasBuffOrDebuff(currentSpell, unit, "buff") then
                TargetUnit(unit)
                CastSpellByName(currentSpell)
                ClearTarget()
                return
            end
        end

        if not getUnit().IsDead() and not getAura().HasBuffOrDebuff(spell, "player", "buff") then
            TargetUnit("player")
            CastSpellByName(spell)
            ClearTarget()
            return
        end
    end
end

-- [[ Buff | Debuff Table Data ]] --

BuffData["Prayer of Fortitude"]                   = "Interface\\Icons\\Spell_Holy_PrayerOfFortitude"
BuffData["Power Word: Fortitude"]                 = "Interface\\Icons\\Spell_Holy_WordFortitude"
BuffData["Prayer of Spirit"]                      = "Interface\\Icons\\Spell_Holy_PrayerofSpirit"
BuffData["Divine Spirit"]                         = "Interface\\Icons\\Spell_Holy_DivineSpirit"
BuffData["Prayer of Shadow Protection"]           = "Interface\\Icons\\Spell_Holy_PrayerofShadowProtection"
BuffData["Shadow Protection"]                     = "Interface\\Icons\\Spell_Shadow_AntiShadow"
BuffData["Weakened Soul"]                         = "Interface\\Icons\\Spell_Holy_AshesToAshes"
BuffData["Power Word: Shield"]                    = "Interface\\Icons\\Spell_Holy_PowerWordShield"
BuffData["Shadowform"]                            = "Interface\\Icons\\Spell_Shadow_Shadowform"
BuffData["Renew"]                                 = "Interface\\Icons\\Spell_Holy_Renew"
BuffData["Mind Control"]                          = "Interface\\Icons\\Spell_Shadow_ShadowWordDominate"
BuffData["Inner Fire"]                            = "Interface\\Icons\\Spell_Holy_InnerFire"
BuffData["Inner Focus"]                           = "Interface\\Icons\\Spell_Frost_WindWalkOn"
BuffData["Spirit Tap"]                            = "Interface\\Icons\\Spell_Shadow_Requiem"
BuffData["Vampiric Embrace"]                      = "Interface\\Icons\\Spell_Shadow_UnsummonBuilding"
BuffData["Fade"]                                  = "Interface\\Icons\\Spell_Magic_LesserInvisibilty"
BuffData["Power Infusion"]                        = "Interface\\Icons\\Spell_Holy_PowerInfusion"
BuffData["Spirit of Redemption"]                  = "Interface\\Icons\\Spell_Holy_GreaterHeal"
BuffData["Fear Ward"]                             = "Interface\\Icons\\Spell_Holy_Excorcism"
BuffData["Shadowguard"]                           = "Interface\\Icons\\Spell_Nature_LightningShield"
BuffData["Devouring Plague"]                      = "Interface\\Icons\\Spell_Shadow_BlackPlague"
BuffData["Hex of Weakness"]                       = "Interface\\Icons\\Spell_Shadow_FingerOfDeath"
BuffData["Holy Fire"]                             = "Interface\\Icons\\Spell_Holy_SearingLight"
BuffData["Shadow Weaving"]                        = "Interface\\Icons\\Spell_Shadow_BlackPlague"
BuffData["Inspiration"]                           = "Interface\\Icons\\INV_Shield_06"
BuffData["Psychic Scream"]                        = "Interface\\Icons\\Spell_Shadow_PsychicScream"
BuffData["Shackle Undead"]                        = "Interface\\Icons\\Spell_Nature_Slow"
BuffData["Shadow Word: Pain"]                     = "Interface\\Icons\\Spell_Shadow_ShadowWordPain"
BuffData["Mind Soothe"]                           = "Interface\\Icons\\Spell_Holy_MindSooth"
BuffData["Silence"]                               = "Interface\\Icons\\Spell_Shadow_ImpPhaseShift"
BuffData["Blackout"]                              = "Interface\\Icons\\Spell_Shadow_GatherShadows"
BuffData["Gift of the Wild"]                      = "Interface\\Icons\\Spell_Nature_Regeneration"
BuffData["Mark of the Wild"]                      = "Interface\\Icons\\Spell_Nature_Regeneration"
BuffData["Rejuvenation"]                          = "Interface\\Icons\\Spell_Nature_Rejuvenation"
BuffData["Regrowth"]                              = "Interface\\Icons\\Spell_Nature_ResistNature"
BuffData["Nature\'s Grace"]                       = "Interface\\Icons\\Spell_Nature_NaturesBlessing"
BuffData["Nature\'s Swiftness"]                   = "Interface\\Icons\\Spell_Nature_RavenForm"
BuffData["Abolish Poison"]                        = "Interface\\Icons\\Spell_Nature_NullifyPoison_02"
BuffData["Innervate"]                             = "Interface\\Icons\\Spell_Nature_Lightning"
BuffData["Tranquility"]                           = "Interface\\Icons\\Spell_Nature_Tranquility"
BuffData["Barkskin"]                              = "Interface\\Icons\\Spell_Nature_StoneclawTotem"
BuffData["Thorns"]                                = "Interface\\Icons\\Spell_Nature_Thorns"
BuffData["Leader of the Pack"]                    = "Interface\\Icons\\Spell_Nature_UnyeildingStamina"
BuffData["Moonkin Aura"]                          = "Interface\\Icons\\Spell_Nature_MoonGlow"
BuffData["Moonkin Form"]                          = "Interface\\Icons\\Spell_Nature_ForceOfNature"
BuffData["Cat Form"]                              = "Interface\\Icons\\Ability_Druid_CatForm"
BuffData["Bear Form"]                             = "Interface\\Icons\\Ability_Racial_BearForm"
BuffData["Dire Bear Form"]                        = "Interface\\Icons\\Ability_Racial_BearForm"
BuffData["Travel Form"]                           = "Interface\\Icons\\Ability_Druid_TravelForm"
BuffData["Aquatic Form"]                          = "Interface\\Icons\\Ability_Druid_AquaticForm"
BuffData["Prowl"]                                 = "Interface\\Icons\\Ability_Ambush"
BuffData["Tiger\'s Fury"]                         = "Interface\\Icons\\Ability_Mount_JungleTiger"
BuffData["Dash"]                                  = "Interface\\Icons\\Ability_Druid_Dash"
BuffData["Blessing of the Claw"]                  = "Interface\\Icons\\Spell_Holy_BlessingOfAgility"
BuffData["Nature\'s Grasp"]                       = "Interface\\Icons\\Spell_Nature_NaturesWrath"
BuffData["Omen of Clarity"]                       = "Interface\\Icons\\Spell_Nature_CrystalBall"
BuffData["Clearcasting"]                          = "Interface\\Icons\\Spell_Shadow_ManaBurn"
BuffData["Enrage"]                                = "Interface\\Icons\\Ability_Druid_Enrage"
BuffData["Frenzied Regeneration"]                 = "Interface\\Icons\\Ability_BullRush"
BuffData["Growl"]                                 = "Interface\\Icons\\Ability_Druid_Physical_Taunt"
BuffData["Pounce"]                                = "Interface\\Icons\\Ability_Druid_SupriseAttack"
BuffData["Rake"]                                  = "Interface\\Icons\\Ability_Druid_Disembowel"
BuffData["Rip"]                                   = "Interface\\Icons\\Ability_GhoulFrenzy"
BuffData["Moonfire"]                              = "Interface\\Icons\\Spell_Nature_StarFall"
BuffData["Faerie Fire"]                           = "Interface\\Icons\\Spell_Nature_FaerieFire"
BuffData["Faerie Fire (Feral)"]                   = "Interface\\Icons\\Spell_Nature_FaerieFire"
BuffData["Hibernate"]                             = "Interface\\Icons\\Spell_Nature_Sleep"
BuffData["Insect Swarm"]                          = "Interface\\Icons\\Spell_Nature_InsectSwarm"
BuffData["Entangling Roots"]                      = "Interface\\Icons\\Spell_Nature_StrangleVines"
BuffData["Starfire Stun"]                         = "Interface\\Icons\\Spell_Arcane_Starfire"
BuffData["Hurricane"]                             = "Interface\\Icons\\Spell_Nature_Cyclone"
BuffData["Soothe Animal"]                         = "Interface\\Icons\\Spell_Hunter_BeastSoothe"
BuffData["Bash"]                                  = "Interface\\Icons\\Ability_Druid_Bash"
BuffData["Challenging Roar"]                      = "Interface\\Icons\\Ability_Druid_ChallangingRoar"
BuffData["Demoralizing Roar"]                     = "Interface\\Icons\\Ability_Druid_DemoralizingRoar"
BuffData["Arcane Brilliance"]                     = "Interface\\Icons\\Spell_Holy_ArcaneIntellect"
BuffData["Arcane Intellect"]                      = "Interface\\Icons\\Spell_Holy_MagicalSentry"
BuffData["Dampen Magic"]                          = "Interface\\Icons\\Spell_Nature_AbolishMagic"
BuffData["Amplify Magic"]                         = "Interface\\Icons\\Spell_Holy_FlashHeal"
BuffData["Ice Armor"]                             = "Interface\\Icons\\Spell_Frost_FrostArmor02"
BuffData["Mana Shield"]                           = "Interface\\Icons\\Spell_Shadow_DetectLesserInvisibility"
BuffData["Fire Ward"]                             = "Interface\\Icons\\Spell_Fire_FireArmor"
BuffData["Ice Block"]                             = "Interface\\Icons\\Spell_Frost_Frost"
BuffData["Ice Barrier"]                           = "Interface\\Icons\\Spell_Ice_Lament"
BuffData["Evocation"]                             = "Interface\\Icons\\Spell_Nature_Purge"
BuffData["Frost Ward"]                            = "Interface\\Icons\\Spell_Frost_FrostWard"
BuffData["Mage Armor"]                            = "Interface\\Icons\\Spell_MageArmor"
BuffData["Clearcasting"]                          = "Interface\\Icons\\Spell_Shadow_ManaBurn"
BuffData["Presence of Mind"]                      = "Interface\\Icons\\Spell_Nature_EnchantArmor"
BuffData["Combustion"]                            = "Interface\\Icons\\Spell_Fire_SealOfFire"
BuffData["Netherwind Focus"]                      = "Interface\\Icons\\Spell_Shadow_Teleport"
BuffData["Detect Magic"]                          = "Interface\\Icons\\Spell_Holy_Dizzy"
BuffData["Polymorph"]                             = "Interface\\Icons\\Spell_Nature_Polymorph"
BuffData["Frostbolt"]                             = "Interface\\Icons\\Spell_Frost_FrostBolt02"
BuffData["Frost Nova"]                            = "Interface\\Icons\\Spell_Frost_FrostNova"
BuffData["Frostbite"]                             = "Interface\\Icons\\Spell_Frost_FrostArmor"
BuffData["Scorch"]                                = "Interface\\Icons\\Spell_Fire_SoulBurn"
BuffData["Ignite"]                                = "Interface\\Icons\\Spell_Fire_Incinerate"
BuffData["Winter\'s Chill"]                       = "Interface\\Icons\\Spell_Frost_ChillingBlast"
BuffData["Arcane Power"]                          = "Interface\\Icons\\Spell_Nature_Lightning"
BuffData["Demon Skin"]                            = "Interface\\Icons\\Spell_Shadow_RagingScream"
BuffData["Demon Armor"]                           = "Interface\\Icons\\Spell_Shadow_RagingScream"
BuffData["Fire Shield"]                           = "Interface\\Icons\\Spell_Fire_FireArmor"
BuffData["Sacrifice"]                             = "Interface\\Icons\\Spell_Shadow_SacrificialShield"
BuffData["Underwater Breathing"]                  = "Interface\\Icons\\Spell_Shadow_DemonBreath"
BuffData["Eye of Kilrogg"]                        = "Interface\\Icons\\Spell_Shadow_EvilEye"
BuffData["Nightfall"]                             = "Interface\\Icons\\Spell_Shadow_Twilight"
BuffData["Touch of Shadow"]                       = "Interface\\Icons\\Spell_Shadow_PsychicScream"
BuffData["Burning Wish"]                          = "Interface\\Icons\\Spell_Shadow_PsychicScream"
BuffData["Fel Stamina"]                           = "Interface\\Icons\\Spell_Shadow_PsychicScream"
BuffData["Fel Energy"]                            = "Interface\\Icons\\Spell_Shadow_PsychicScream"
BuffData["Shadow Ward"]                           = "Interface\\Icons\\Spell_Shadow_AntiShadow"
BuffData["Master Demonologist"]                   = "Interface\\Icons\\Spell_Shadow_ShadowPact"
BuffData["Soul Link"]                             = "Interface\\Icons\\Spell_Shadow_GatherShadows"
BuffData["Detect Lesser Invisibility"]            = "Interface\\Icons\\Spell_Shadow_DetectLesserInvisibility"
BuffData["Detect Invisibility"]                   = "Interface\\Icons\\Spell_Shadow_DetectInvisibility"
BuffData["Detect Greater Invisibility"]           = "Interface\\Icons\\Spell_Shadow_DetectInvisibility"
BuffData["Soulstone"]                             = "Interface\\Icons\\Spell_Shadow_SoulGem"
BuffData["Blood Pact"]                            = "Interface\\Icons\\Spell_Shadow_BloodBoil"
BuffData["Paranoia"]                              = "Interface\\Icons\\Spell_Shadow_AuraOfDarkness"
BuffData["Phase Shift"]                           = "Interface\\Icons\\Spell_Shadow_ImpPhaseShift"
BuffData["Health Funnel"]                         = "Interface\\Icons\\Spell_Shadow_LifeDrain"
BuffData["Consume Shadows"]                       = "Interface\\Icons\\Spell_Shadow_AntiShadow"
BuffData["Lesser Invisibility"]                   = "Interface\\Icons\\Spell_Magic_LesserInvisibility"
BuffData["Corruption"]                            = "Interface\\Icons\\Spell_Shadow_AbominationExplosion"
BuffData["Immolate"]                              = "Interface\\Icons\\Spell_Fire_Immolation"
BuffData["Siphon Life"]                           = "Interface\\Icons\\Spell_Shadow_Requiem"
BuffData["Drain Life"]                            = "Interface\\Icons\\Spell_Shadow_LifeDrain02"
BuffData["Drain Soul"]                            = "Interface\\Icons\\Spell_Shadow_Haunting"
BuffData["Drain Mana"]                            = "Interface\\Icons\\Spell_Shadow_SiphonMana"
BuffData["Improved Shadow Bolt"]                  = "Interface\\Icons\\Spell_Shadow_ShadowBolt"
BuffData["Curse of Agony"]                        = "Interface\\Icons\\Spell_Shadow_CurseOfSargeras"
BuffData["Curse of Weakness"]                     = "Interface\\Icons\\Spell_Shadow_CurseOfMannoroth"
BuffData["Curse of Shadow"]                       = "Interface\\Icons\\Spell_Shadow_CurseOfAchimonde"
BuffData["Curse of the Elements"]                 = "Interface\\Icons\\Spell_Shadow_ChillTouch"
BuffData["Curse of Doom"]                         = "Interface\\Icons\\Spell_Shadow_AuraOfDarkness"
BuffData["Curse of Tongues"]                      = "Interface\\Icons\\Spell_Shadow_CurseOfTounges"
BuffData["Curse of Recklessness"]                 = "Interface\\Icons\\Spell_Shadow_UnholyStrength"
BuffData["Curse of Exhaustion"]                   = "Interface\\Icons\\Spell_Shadow_GrimWard"
BuffData["Enslave Demon"]                         = "Interface\\Icons\\Spell_Shadow_EnslaveDemon"
BuffData["Hellfire"]                              = "Interface\\Icons\\Spell_Fire_Incinerate"
BuffData["Fear"]                                  = "Interface\\Icons\\Spell_Shadow_Possession"
BuffData["Banish"]                                = "Interface\\Icons\\Spell_Shadow_Cripple"
BuffData["Seduction"]                             = "Interface\\Icons\\Spell_Shadow_MindSteal"
BuffData["Tainted Blood"]                         = "Interface\\Icons\\Spell_Shadow_LifeDrain"
BuffData["Spell Lock"]                            = "Interface\\Icons\\Spell_Shadow_MindRot"
BuffData["Howl of Terror"]                        = "Interface\\Icons\\Spell_Shadow_DeathScream"
BuffData["Death Coil"]                            = "Interface\\Icons\\Spell_Shadow_DeathCoil"
BuffData["Frost Shock"]                           = "Interface\\Icons\\Spell_Frost_FrostShock"
BuffData["Flame Shock"]                           = "Interface\\Icons\\Spell_Fire_FlameShock"
BuffData["Stormstrike"]                           = "Interface\\Icons\\Spell_Holy_SealOfMight"
BuffData["Earthbind Totem"]                       = "Interface\\Icons\\Spell_Nature_StrengthOfEarthTotem02"
BuffData["Strength of Earth Totem"]               = "Interface\\Icons\\Spell_Nature_EarthBindTotem"
BuffData["Grace of Air Totem"]                    = "Interface\\Icons\\Spell_Nature_InvisibilityTotem"
BuffData["Mana Spring Totem"]                     = "Interface\\Icons\\Spell_Nature_ManaRegenTotem"
BuffData["Healing Stream Totem"]                  = "Interface\\Icons\\INV_Spear_04"
BuffData["Grounding Totem"]                       = "Interface\\Icons\\Spell_Nature_GroundingTotem"
BuffData["Mana Tide Totem"]                       = "Interface\\Icons\\Spell_Frost_SummonWaterElemental"
BuffData["Tranquil Air Totem"]                    = "Interface\\Icons\\Spell_Nature_Brilliance"
BuffData["Stoneskin Totem"]                       = "Interface\\Icons\\Spell_Nature_StoneSkinTotem"
BuffData["Frost Resistance Totem"]                = "Interface\\Icons\\Spell_FrostResistanceTotem_01"
BuffData["Fire Resistance Totem"]                 = "Interface\\Icons\\Spell_FireResistanceTotem_01"
BuffData["Nature Resistance Totem"]               = "Interface\\Icons\\Spell_Nature_NatureResistanceTotem"
BuffData["Windwall Totem"]                        = "Interface\\Icons\\Spell_Nature_EarthBind"
BuffData["Lightning Shield"]                      = "Interface\\Icons\\Spell_Nature_LightningShield"
BuffData["Healing Way"]                           = "Interface\\Icons\\Spell_Nature_HealingWay"
BuffData["Ancestral Fortitude"]                   = "Interface\\Icons\\Spell_Nature_UndyingStrength"
BuffData["Totemic Power"]                         = "Interface\\Icons\\Spell_Magic_MageArmor"
BuffData["Ghost Wolf"]                            = "Interface\\Icons\\Spell_Nature_SpiritWolf"
BuffData["Aspect of the Hawk"]                    = "Interface\\Icons\\Spell_Nature_RavenForm"
BuffData["Aspect of the Monkey"]                  = "Interface\\Icons\\Ability_Hunter_AspectOfTheMonkey"
BuffData["Aspect of the Cheetah"]                 = "Interface\\Icons\\Ability_Mount_JungleTiger"
BuffData["Aspect of the Pack"]                    = "Interface\\Icons\\Ability_Mount_WhiteTiger"
BuffData["Aspect of the Beast"]                   = "Interface\\Icons\\Ability_Mount_PinkTiger"
BuffData["Aspect of the Wild"]                    = "Interface\\Icons\\Spell_Nature_ProtectionformNature"
BuffData["Rapid Fire"]                            = "Interface\\Icons\\Ability_Hunter_RunningShot"
BuffData["Eyes of the Beast"]                     = "Interface\\Icons\\Ability_EyesOfTheOwl"
BuffData["Deterrence"]                            = "Interface\\Icons\\Ability_Whirlwind"
BuffData["Feed Pet"]                              = "Interface\\Icons\\Ability_Hunter_BeastTraining"
BuffData["Mend Pet"]                              = "Interface\\Icons\\Ability_Hunter_MendPet"
BuffData["Concussive Shot"]                       = "Interface\\Icons\\Spell_Frost_Stun"
BuffData["Hunter\'s Mark"]                        = "Interface\\Icons\\Ability_Hunter_SniperShot"
BuffData["Wing Clip"]                             = "Interface\\Icons\\Ability_Rogue_Trip"
BuffData["Serpent Sting"]                         = "Interface\\Icons\\Ability_Hunter_Quickshot"
BuffData["Scorpid Sting"]                         = "Interface\\Icons\\Ability_Hunter_CriticalShot"
BuffData["Viper Sting"]                           = "Interface\\Icons\\Ability_Hunter_AimedShot"
BuffData["Scatter Shot"]                          = "Interface\\Icons\\Ability_GolemStormBolt"
BuffData["Freezing Trap"]                         = "Interface\\Icons\\Spell_Frost_ChainsOfIce"
BuffData["Frost Trap"]                            = "Interface\\Icons\\Spell_Frost_FreezingBreath"
BuffData["Immolation Trap"]                       = "Interface\\Icons\\Spell_Fire_FlameShock"
BuffData["Explosive Trap"]                        = "Interface\\Icons\\Spell_Fire_SelfDestruct"
BuffData["Trueshot Aura"]                         = "Interface\\Icons\\Ability_TrueShot"
BuffData["Feign Death"]                           = "Interface\\Icons\\Ability_Rogue_FeignDeath"
BuffData["Screech"]                               = "Interface\\Icons\\Ability_Hunter_Pet_Bat"
BuffData["Stealth"]                               = "Interface\\Icons\\Ability_Stealth"
BuffData["Vanish"]                                = "Interface\\Icons\\Ability_Vanish"
BuffData["Blade Flurry"]                          = "Interface\\Icons\\Ability_Warrior_PunishingBlow"
BuffData["Adrenaline Rush"]                       = "Interface\\Icons\\Spell_Shadow_ShadowWordDominate"
BuffData["SPrint"]                                = "Interface\\Icons\\Ability_Rogue_SPrint"
BuffData["Hemorrhage"]                            = "Interface\\Icons\\Spell_Shadow_Lifedrain"
BuffData["Gouge"]                                 = "Interface\\Icons\\Ability_Gouge"
BuffData["Garrote"]                               = "Interface\\Icons\\Ability_Rogue_Garrote"
BuffData["Blind"]                                 = "Interface\\Icons\\Spell_Shadow_MindSteal"
BuffData["Rupture"]                               = "Interface\\Icons\\Ability_Rogue_Rupture"
BuffData["Cheap Shot"]                            = "Interface\\Icons\\Ability_CheapShot"
BuffData["Kidney Shot"]                           = "Interface\\Icons\\Ability_Rogue_KidneyShot"
BuffData["Sap"]                                   = "Interface\\Icons\\Ability_Sap"
BuffData["Expose Armor"]                          = "Interface\\Icons\\Ability_Warrior_Riposte"
BuffData["Slice and Dice"]                        = "Interface\\Icons\\Ability_Rogue_SliceDice"
BuffData["Mace Stun"]                             = "Interface\\Icons\\Spell_Frost_Stun"
BuffData["Battle Shout"]                          = "Interface\\Icons\\Ability_Warrior_BattleShout"
BuffData["Taunt"]                                 = "Interface\\Icons\\Spell_Nature_Reincarnation"
BuffData["Bloodrage"]                             = "Interface\\Icons\\Ability_Racial_BloodRage"
BuffData["Death Wish"]                            = "Interface\\Icons\\Spell_Shadow_DeathPact"
BuffData["Enraged"]                               = "Interface\\Icons\\Spell_Shadow_UnholyFrenzy"
BuffData["Flurry"]                                = "Interface\\Icons\\Ability_GhoulFrenzy"
BuffData["Recklessness"]                          = "Interface\\Icons\\Ability_CriticalStrike"
BuffData["Berserker Rage"]                        = "Interface\\Icons\\Spell_Nature_AncestralGuardian"
BuffData["Mocking Blow"]                          = "Interface\\Icons\\Ability_Warrior_PunishingBlow"
BuffData["Mortal Strike"]                         = "Interface\\Icons\\Ability_Warrior_SavageBlow"
BuffData["Thunder Clap"]                          = "Interface\\Icons\\Spell_Nature_ThunderClap"
BuffData["Piercing Howl"]                         = "Interface\\Icons\\Spell_Shadow_DeathScream"
BuffData["Hamstring"]                             = "Interface\\Icons\\Ability_ShockWave"
BuffData["Concussion Blow"]                       = "Interface\\Icons\\Ability_ThunderBolt"
BuffData["Demoralizing Shout"]                    = "Interface\\Icons\\Ability_Warrior_WarCry"
BuffData["Intimidating Shout"]                    = "Interface\\Icons\\Ability_GolemThunderClap"
BuffData["Sunder Armor"]                          = "Interface\\Icons\\Ability_Warrior_Sunder"
BuffData["Disarm"]                                = "Interface\\Icons\\Ability_Warrior_Disarm"
BuffData["Sweeping Strikes"]                      = "Interface\\Icons\\Ability_Rogue_SliceDice"
BuffData["Devotion Aura"]                         = "Interface\\Icons\\Spell_Holy_DevotionAura"
BuffData["Concentration Aura"]                    = "Interface\\Icons\\Spell_Holy_MindSooth"
BuffData["Fire Resistance Aura"]                  = "Interface\\Icons\\Spell_Fire_SealOfFire"
BuffData["Frost Resistance Aura"]                 = "Interface\\Icons\\Spell_Frost_WizardMark"
BuffData["Shadow Resistance Aura"]                = "Interface\\Icons\\Spell_Shadow_SealOfKings"
BuffData["Retribution Aura"]                      = "Interface\\Icons\\Spell_Holy_AuraOfLight"
BuffData["Greater Blessing of Wisdom"]            = "Interface\\Icons\\Spell_Holy_GreaterBlessingofWisdom"
BuffData["Greater Blessing of Kings"]             = "Interface\\Icons\\Spell_Magic_GreaterBlessingofKings"
BuffData["Greater Blessing of Salvation"]         = "Interface\\Icons\\Spell_Holy_GreaterBlessingofSalvation"
BuffData["Greater Blessing of Might"]             = "Interface\\Icons\\Spell_Holy_GreaterBlessingofKings"
BuffData["Greater Blessing of Light"]             = "Interface\\Icons\\Spell_Holy_GreaterBlessingofLight"
BuffData["Greater Blessing of Sanctuary"]         = "Interface\\Icons\\Spell_Holy_GreaterBlessingofSanctuary"
BuffData["Hammer of Justice"]                     = "Interface\\Icons\\Spell_Holy_SealOfMight"
BuffData["Seal of Light"]                         = "Interface\\Icons\\Spell_Holy_HealingAura"
BuffData["Seal of Wisdom"]                        = "Interface\\Icons\\Spell_Holy_RighteousnessAura"
BuffData["Judgement of Light"]                    = "Interface\\Icons\\Spell_Holy_HealingAura"
BuffData["Judgement of Wisdom"]                   = "Interface\\Icons\\Spell_Holy_RighteousnessAura"
BuffData["Blessing of Protection"]                = "Interface\\Icons\\Spell_Holy_SealOfProtection"
BuffData["Forbearance"]                           = "Interface\\Icons\\Spell_Holy_RemoveCurse"
BuffData["Divine Favor"]                          = "Interface\\Icons\\Spell_Holy_Heal"
BuffData["Blinding Light"]                        = "Interface\\Icons\\Spell_Holy_SearingLight"
BuffData["Seal of Righteousness"]                 = "Interface\\Icons\\Ability_ThunderBolt"
BuffData["Berserking"]                            = "Interface\\Icons\\Racial_Troll_Berserk"
BuffData["Blood Fury Debuff"]                     = "Interface\\Icons\\Ability_Rogue_FeignDeath"
BuffData["Blood Fury"]                            = "Interface\\Icons\\Racial_Orc_BerserkerStrength"
BuffData["War Stomp"]                             = "Interface\\Icons\\Ability_WarStomp"
BuffData["Cannibalize"]                           = "Interface\\Icons\\Ability_Racial_Cannibalize"
BuffData["Will of the Forsaken"]                  = "Interface\\Icons\\Spell_Shadow_RaiseDead"
BuffData["Warchief\'s Blessing"]                  = "Interface\\Icons\\Spell_Arcane_TeleportOrgrimmar"
BuffData["Rallying Cry of the Dragonslayer"]      = "Interface\\Icons\\INV_Misc_Head_Dragon_01"
BuffData["Spirit of Zandalar"]                    = "Interface\\Icons\\Ability_Creature_Poison_05"
BuffData["Songflower Serenade"]                   = "Interface\\Icons\\Spell_Holy_MindVision"
BuffData["Sayge\'s Dark Fortune of Strength"]     = "Interface\\Icons\\INV_Misc_Orb_02"
BuffData["Sayge\'s Dark Fortune of Damage"]       = "Interface\\Icons\\INV_Misc_Orb_02"
BuffData["Sayge\'s Dark Fortune of Intelligence"] = "Interface\\Icons\\INV_Misc_Orb_02"
BuffData["Sayge\'s Dark Fortune of Agility"]      = "Interface\\Icons\\INV_Misc_Orb_02"
BuffData["Sayge\'s Dark Fortune of Resistance"]   = "Interface\\Icons\\INV_Misc_Orb_02"
BuffData["Sayge\'s Dark Fortune of Stamina"]      = "Interface\\Icons\\INV_Misc_Orb_02"
BuffData["Sayge\'s Dark Fortune of Spirit"]       = "Interface\\Icons\\INV_Misc_Orb_02"
BuffData["Sayge\'s Dark Fortune of Armor"]        = "Interface\\Icons\\INV_Misc_Orb_02"
BuffData["Recently Bandaged"]                     = "Interface\\Icons\\INV_Misc_Bandage_08"
BuffData["First Aid"]                             = "Interface\\Icons\\Spell_Holy_Heal"
BuffData["Shadow Storm"]                          = "Interface\\Icons\\Spell_Shadow_ShadowBolt"        --aq40 anubisaths BUFF
BuffData["Mana Burn"]                             = "Interface\\Icons\\Spell_Shadow_ManaBurn"          --aq40 anubisaths BUFF
BuffData["Fire and Arcane Reflect"]               = "Interface\\Icons\\Spell_Arcane_Blink"             --same icon,
BuffData["Shadow and Frost Reflect"]              = "Interface\\Icons\\Spell_Arcane_Blink"             --same icon,
BuffData["Mending"]                               = "Interface\\Icons\\Spell_Nature_ResistNature"      --aq40 anubisaths BUFF
BuffData["Periodic Knock Away"]                   = "Interface\\Icons\\Ability_UpgradeMoonglaive"      --aq40 anubisaths BUFF
BuffData["Living Bomb"]                           = "Interface\\Icons\\INV_Enchant_EssenceAstralSmall" --Baron Bomb
BuffData["Burning Adrenaline"]                    = "Interface\\Icons\\INV_Gauntlets_03"               --Vaelastrasz Bomb
BuffData["Brood Affliction: Bronze"]              = "Interface\\Icons\\INV_Misc_Head_Dragon_Bronze"    --Chromaggus bronze debuff
BuffData["Plague"]                                = "Interface\\Icons\\Spell_Shadow_CurseOfTounges"    --aq20/40 anubisath plague debuff
BuffData["Drink"]                                 = "Interface\\Icons\\INV_Drink_18"                   --LVL 55 water ONLY, not lvl 45 or below.
BuffData["Shadow Weakness"]                       = "Interface\\Icons\\INV_Misc_QirajiCrystal_05"      --Ossirian Weakness
BuffData["Fire Weakness"]                         = "Interface\\Icons\\INV_Misc_QirajiCrystal_02"      --Ossirian Weakness
BuffData["Nature Weakness"]                       = "Interface\\Icons\\INV_Misc_QirajiCrystal_03"      --Ossirian Weakness
BuffData["Arcane Weakness"]                       = "Interface\\Icons\\INV_Misc_QirajiCrystal_01"      --Ossirian Weakness
BuffData["Frost Weakness"]                        = "Interface\\Icons\\INV_Misc_QirajiCrystal_04"      --Ossirian Weakness
BuffData["Magic Reflection"]                      = "Interface\\Icons\\Spell_Frost_FrostShock"         --Magic Reflection on Major Domo adds
BuffData["Deaden Magic"]                          =
"Interface\\Icons\\Spell_Holy_SealOfSalvation"                                                         --Shazzrah Deaden Magicc BUFF, can be dispelled.
BuffData["Corrupted Healing"]                     =
"Interface\\Icons\\Spell_Shadow_Charm"                                                                 --Nefarian Priestcall debuff, stop heal if have this debuff as priest.
BuffData["Delusions of Jin\'do"]                  =
"Interface\\Icons\\Spell_Shadow_UnholyFrenzy"                                                          --Jindo shade debuff, do not decurse.
BuffData["Threatening Gaze"]                      = "Interface\\Icons\\Spell_Shadow_Charm"             --Broodlord's Threatening gaze.
BuffData["True Fulfillment"]                      = "Interface\\Icons\\Spell_Shadow_Charm"             --Skerams mindcontrol.
BuffData["Aura of Agony"]                         = "Interface\\Icons\\Spell_Shadow_CurseOfSargeras"
BuffData["Corruption of the Earth"]               = "Interface\\Icons\\Ability_Creature_Cursed_03"
BuffData["Atiesh"]                                = "Interface\\Icons\\Spell_Nature_MoonGlow"
BuffData["Hazza\'rah\'s Charm of Healing"]        = "Interface\\Icons\\Spell_Holy_HealingAura"
BuffData["Magma Shackles"]                        = "Interface\\Icons\\Spell_Nature_EarthBind" --Garr's Slowing effect
BuffData["Impending Doom"]                        = "Interface\\Icons\\Spell_Shadow_NightOfTheDead"
BuffData["Inevitable Doom"]                       = "Interface\\Icons\\Spell_Shadow_NightOfTheDead"
BuffData["Mind Exhaustion"]                       = "Interface\\Icons\\Spell_Shadow_Teleport"
BuffData["Blessed Sunfruit Juice"]                = "Interface\\Icons\\Spell_Holy_Layonhands"
BuffData["Blessed Sunfruit"]                      = "Interface\\Icons\\Spell_Holy_Devotion"
BuffData["Spell Vulnerability"]                   = "Interface\\Icons\\Spell_Holy_Elunesgrace"
BuffData["Mutating Injection"]                    = "Interface\\Icons\\Spell_Shadow_CallofBone"
BuffData["Shadow Command"]                        = "Interface\\Icons\\Spell_Shadow_UnholyFrenzy"
BuffData["Elemental Sharpening Stone"]            = "Interface\\Icons\\INV_Stone_02"
BuffData["Increased Stamina"]                     = "Interface\\Icons\\INV_Boots_Plate_03"
BuffData["Well Fed"]                              = "Interface\\Icons\\INV_Misc_Food"
BuffData["Increased Intellect"]                   = "Interface\\Icons\\INV_Misc_Organ_03"
BuffData["Evil Twin"]                             = "Interface\\Icons\\Spell_Shadow_Charm"

BuffData["Greater Shadow Protection Potion"]      = "Interface\\Icons\\Spell_Shadow_RagingScream"
BuffData["Greater Nature Protection Potion"]      = "Interface\\Icons\\Spell_Nature_SpiritArmor"
BuffData["Greater Fire Protection Potion"]        = "Interface\\Icons\\Spell_Fire_FireArmor"
BuffData["Greater Frost Protection Potion"]       = "Interface\\Icons\\Spell_Frost_FrostArmor02"
BuffData["Greater Arcane Protection Potion"]      = "Interface\\Icons\\Spell_Holy_PrayerOfHealing02"
BuffData["Frozen Rune"]                           = "Interface\\Icons\\Spell_Fire_MasterOfElements"

BuffData["Juju Power"]                            = "Interface\\Icons\\INV_Misc_MonsterScales_11"
BuffData["Juju Might"]                            = "Interface\\Icons\\INV_Misc_MonsterScales_07"
BuffData["Juju Ember"]                            = "Interface\\Icons\\INV_Misc_MonsterScales_15"
BuffData["Juju Escape"]                           = "Interface\\Icons\\INV_Misc_MonsterScales_17"
BuffData["Juju Chill"]                            = "Interface\\Icons\\INV_Misc_MonsterScales_09"
BuffData["Juju Guile"]                            = "Interface\\Icons\\INV_Misc_MonsterScales_13"
BuffData["Juju Flurry"]                           = "Interface\\Icons\\INV_Misc_MonsterScales_17"

BuffData["Swiftness of Zanza"]                    = "Interface\\Icons\\INV_Potion_31"
BuffData["Spirit of Zanza"]                       = "Interface\\Icons\\INV_Potion_30"

BuffData["Flask of the Titans"]                   = "Interface\\Icons\\INV_Potion_62"
BuffData["Flask of Supreme Power"]                = "Interface\\Icons\\INV_Potion_41"
BuffData["Flask of Distilled Wisdom"]             = "Interface\\Icons\\INV_Potion_97"

BuffData["Elixir of the Mongoose"]                = "Interface\\Icons\\INV_Potion_32"
BuffData["Elixir of Frost Power"]                 = "Interface\\Icons\\INV_Potion_03"
BuffData["Elixir of Greater Firepower"]           = "Interface\\Icons\\INV_Potion_60"
BuffData["Elixir of Shadow Power"]                = "Interface\\Icons\\INV_Potion_46"

BuffData["Mageblood Potion"]                      = "Interface\\Icons\\INV_Potion_45"
BuffData["Mighty Rage Potion"]                    = "Interface\\Icons\\Ability_Warrior_InnerRage"

BuffData["Greater Stoneshield Potion"]            = "Interface\\Icons\\INV_Potion_69"
BuffData["Greater Arcane Elixir"]                 = "Interface\\Icons\\INV_Potion_25"

BuffData["Brilliant Wizard Oil"]                  = "Interface\\Icons\\INV_Potion_105"
BuffData["Brilliant Mana Oil"]                    = "Interface\\Icons\\INV_Potion_100"

BuffData["Limited Invulnerability Potion"]        = "Interface\\Icons\\Spell_Holy_DivineIntervention"
BuffData["Free Action Potion"]                    = "Interface\\Icons\\INV_Potion_04"
BuffData["Gift of Arthas"]                        = "Interface\\Icons\\Spell_Shadow_FingerOfDeath"

BuffData["Fury of Ragnaros"]                      = "Interface\\Icons\\Spell_Holy_MindSooth"
BuffData["Fengus\' Ferocity"]                     = "Interface\\Icons\\Spell_Nature_UndyingStrength"
BuffData["Mol\'dar\'s Moxie"]                     = "Interface\\Icons\\Spell_Nature_MassTeleport"
BuffData["Slip\'kik\'s Savvy"]                    = "Interface\\Icons\\Spell_Holy_LesserHeal02"

BuffData["Gizzard Gum"]                           = "Interface\\Icons\\Spell_Fire_Incinerate"
BuffData["Lung Juice Cocktail"]                   = "Interface\\Icons\\Spell_Nature_Purge"
BuffData["Cerebral Cortex Compound"]              = "Interface\\Icons\\Spell_Ice_Lament"
BuffData["R.O.I.D.S."]                            = "Interface\\Icons\\Spell_Nature_Strength"
BuffData["Ground Scorpok Assay"]                  = "Interface\\Icons\\Spell_Nature_ForceOfNature"

BuffData["Very Berry Cream"]                      = "Interface\\Icons\\INV_ValentinesChocolate02"
BuffData["Sweet Surprise"]                        = "Interface\\Icons\\INV_ValentinesChocolate03"
BuffData["Polished Armor"]                        = "Interface\\Icons\\INV_Shield_10"

BuffData["Corrupted Mind"]                        = "Interface\\Icons\\Spell_Shadow_AuraOfDarkness"
BuffData["Fungal Bloom"]                          = "Interface\\Icons\\Spell_Nature_UnyeildingStamina"

BuffData["Positive Charge"]                       = "Interface\\Icons\\Spell_ChargePositive"
BuffData["Negative Charge"]                       = "Interface\\Icons\\Spell_ChargeNegative"

BuffData["Slow Fall"]                             = "Interface\\Icons\\Spell_Magic_FeatherFall"
BuffData["Armor Shatter"]                         = "Interface\\Icons\\INV_Axe_12"
