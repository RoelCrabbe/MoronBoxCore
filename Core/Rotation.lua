-- [[ Config & Constants ]] --

MoronBox.Core.Rotation = MoronBox.Core.Rotation or {}

local myClass = UnitClass("player")
local myName = UnitName("player")
local myRace = UnitRace("player")

local PlayerMounts = {
    "Reins of the Winterspring Frostsaber",
    "Deathcharger\'s Reins",
    "Black War Tiger",
    "Swift Zulian Tiger",
    "Swift Razzashi Raptor",
    "Swift Blue Raptor",
    "Black War Kodo",
    "Horn of the ",
    "Reins of the Swift ",
    "Swift White Steed",
    "Swift Brown Steed",
    "Black Battlestrider",
    "Warhorse",
    " Mare",
    "Horse",
    "Timber Wolf",
    "Kodo",
    "Raptor",
    " Ram",
    " Mechanostrider",
    " Bridle",
    "Charger",
    " Frostsaber",
    " Nightsaber",
    "Swift Palomino"
}

local MageCounter = {
    Cycle = function()
        getConfigState().SheepingMageNr = (getConfigState().SheepingMageNr >= getApi().TableLength(MB_classList["Mage"]))
            and 1 or (getConfigState().SheepingMageNr + 1)
    end
}

function getRotation()
    return MoronBox.Core.Rotation
end

-- [[ Simple Rotations ]] --

function MoronBox.Core.Rotation.ExecuteRotation(rotationType)
    local moduleName = "MODULE_" .. string.upper(myClass) .. "_ROTATION"
    local rotationModule = MoronBox.Registry[moduleName]

    if rotationModule and rotationModule[rotationType] then
        local status, err = pcall(rotationModule[rotationType])
        if not status then
            getDebugger().ErrorMsg("Rotation error [" .. rotationType .. "] for " .. myClass .. ": " .. tostring(err))
        end
    else
        getDebugger().WarnMsg("No " .. rotationType .. " rotation registered for class: " .. myClass)
    end
end

function MoronBox.Core.Rotation.HealerJindo(spellName)
    if Instance.ZG() and getAura().HasBuffOrDebuff("Delusions of Jin'do", "player", "debuff") then
        if UnitName("target") == "Shade of Jin'do" and not getUnit().IsDead("target") then
            CastSpellByName(spellName)
        end
        return true
    end
    return false
end

-- [[ Invites & Summons ]] --

function MoronBox.Core.Rotation.RequestInviteSummon()
    if IsAltKeyDown() and not IsShiftKeyDown() and not IsControlKeyDown() then
        if MB_raidInviter == myName then
            SetLootMethod("freeforall")

            if GetNumPartyMembers() > 0 and not UnitInRaid("player") then
                ConvertToRaid()
            end
            return
        end

        if MB_raidInviter then
            if not (getUnit().IsInRaid(MB_raidInviter) or getUnit().IsInGroup(MB_raidInviter)) then
                getUnit().DisbandRaid()
                SendChatMessage(MB_inviteMessage, "WHISPER", nil, MB_raidInviter)
            end
        end
        return
    end

    if IsShiftKeyDown() and not IsAltKeyDown() and not IsControlKeyDown() then
        if getConfigState().RaidLeader then
            local unit = UnitInRaid("player") and "raid" or "party"
            local index = getUnit().GetRaidIndexForPlayerName(getConfigState().RaidLeader)
            if index and not getUnit().InRange(unit .. index) then
                getApi().CdMessage("123", 10)
                return
            end
        end
    end

    if IsControlKeyDown() and not IsShiftKeyDown() and not IsAltKeyDown() then
        getUnit().PromoteEveryone()
        return
    end
end

-- [[ Set Focus ]] --

function MoronBox.Core.Rotation.SetFocus()
    if IsShiftKeyDown() then
        local targetLeader = UnitName("target")
        getConfigState().RaidLeader = targetLeader
        getApi().SendAddonMessage(MB_RAID .. "_FTAR", getConfigState().RaidLeader .. " " .. myName)
    else
        getConfigState().RaidLeader = myName
        getApi().SendAddonMessage(MB_RAID, "MB_FOCUSME")
    end
end

-- [[ Rotation Utils ]] --

local function SpecialRotation()
    if Instance.NAXX() and getAura().HasBuffNamed("Mind Control", "player") and myClass == "Priest" then
        if (getRaid().TankTarget("Instructor Razuvious") and getApi().FindMyNameInTable(MB_myRazuviousPriest) and MB_myRazuviousBoxStrategy) or
            (getRaid().TankTarget("Grand Widow Faerlina") and getApi().FindMyNameInTable(MB_myFaerlinaPriest) and MB_myFaerlinaBoxStrategy) then
            getSpells().GetMCActions()
            return true
        end
    elseif Instance.BWL() and not getRaid().TankTarget("Razorgore the Untamed") then
        if getRaid().IsAtRazorgore() and myName == getUnit().ReturnPlayerInRaidFromTable(MB_myRazorgoreORBtank) then
            getSpells().OrbControlling()
            return true
        end
    elseif Instance.ZG() and getRaid().TankTarget("Bloodlord Mandokir") then
        if getAura().MandokirGaze() then
            return true
        end
    elseif Instance.AQ20() and getRaid().TankTarget("Moam") then
        getRaid().AutoAssignBanishOnMoam()
    end

    return false
end

local function CheckWeapon()
    if getCore().ImRangedDPS() or getCore().ImHealer() then
        getBag().ReEquipAtieshIfNoAtieshBuff()
    end

    if getBag().GetItemNameOfEquippedSlot(16) == nil then
        getApi().CdMessage("I don\'t have a weapon equipped.", 500)
    end
end

local function CheckWarStomp()
    if not getUnit().InCombat() then
        return
    end

    if not getTables().StunnableMob() then
        return
    end

    if not getUnit().InMeleeRange() then
        return
    end

    if not getSpells().IsSpellReady("War Stomp") then
        return
    end

    if getUnit().IsDruidShapeShifted() then
        return
    end

    CastSpellByName("War Stomp")
end

local function CheckStoneForm()
    if not getUnit().InCombat() then
        return
    end

    if not getSpells().IsSpellReady("Stoneform") then
        return
    end

    if not getDispel().PlayerIsPoisoned() then
        return
    end

    CastSpellByName("Stoneform", 1)
end

-- [[ Single ]] --

function MoronBox.Core.Rotation.Single()
    if not getConfigState().RaidLeader and getApi().TableLength(MBID) > 1 then
        getApi().CdPrint("WARNING: You have not chosen a raid leader")
    end

    if getUnit().IsDead() or getAura().HasBuffNamed("Mind Control", "player") or SpecialRotation() then
        return
    end

    CheckWeapon()
    getCons().UseLIP()
    getCons().UseFAP()
    getRaid().GTFO()

    if getAura().HasBuffOrDebuff("First Aid", "player", "buff") and getAura().HasBuffOrDebuff("Recently Bandaged", "player", "debuff") then
        return
    end

    CheckWarStomp()
    CheckStoneForm()

    if LOA_Rotation() then
        return
    end

    getRotation().ExecuteRotation("Single")
end

-- [[ Multi ]] --

function MoronBox.Core.Rotation.Multi()
    if not getConfigState().RaidLeader and getApi().TableLength(MBID) > 1 then
        getApi().CdPrint("WARNING: You have not chosen a raid leader")
    end

    if getUnit().IsDead() or getAura().HasBuffNamed("Mind Control", "player") or SpecialRotation() then
        return
    end

    CheckWeapon()
    getCons().UseLIP()
    getCons().UseFAP()
    getRaid().GTFO()

    if getAura().HasBuffOrDebuff("First Aid", "player", "buff") and getAura().HasBuffOrDebuff("Recently Bandaged", "player", "debuff") then
        return
    end

    CheckWarStomp()
    CheckStoneForm()

    if LOA_Rotation() then
        return
    end

    getRotation().ExecuteRotation("Multi")
end

-- [[ AOE ]] --

function MoronBox.Core.Rotation.AOE()
    if not getConfigState().RaidLeader and getApi().TableLength(MBID) > 1 then
        getApi().CdPrint("WARNING: You have not chosen a raid leader")
    end

    if getUnit().IsDead() or getAura().HasBuffNamed("Mind Control", "player") or SpecialRotation() then
        return
    end

    CheckWeapon()
    getCons().UseLIP()
    getCons().UseFAP()
    getRaid().GTFO()

    if getAura().HasBuffOrDebuff("First Aid", "player", "buff") and getAura().HasBuffOrDebuff("Recently Bandaged", "player", "debuff") then
        return
    end

    CheckWarStomp()
    CheckStoneForm()

    if LOA_Rotation() then
        return
    end

    getRotation().ExecuteRotation("AOE")
end

-- [[ Setup ]] --

function MoronBox.Core.Rotation.Setup()
    if not getConfigState().RaidLeader and getApi().TableLength(MBID) > 1 then
        getApi().CdPrint("WARNING: You have not chosen a raid leader")
    end

    if getUnit().IsDead() or getAura().HasBuffNamed("Mind Control", "player") or SpecialRotation() then
        return
    end

    CheckWeapon()
    getCons().UseLIP()
    getCons().UseFAP()
    getRaid().GTFO()

    if getAura().HasBuffOrDebuff("First Aid", "player", "buff") and getAura().HasBuffOrDebuff("Recently Bandaged", "player", "debuff") then
        return
    end

    if IsControlKeyDown() then
        getRaid().MakeALine()
        return
    end

    getCons().SpeedRunPots()

    if myClass == "Mage" or myClass == "Warlock" then
        if Instance.NAXX() and MB_myLoathebBoxStrategy then
            RunLine("/trinket load top UNDEAD")
            RunLine("/trinket load top UNDEAD")
        else
            RunLine("/trinket load top NRML")
            RunLine("/trinket load top NRML")
        end
    end

    getBuffs().RequestMarkOfTheWild()

    getBuffs().RequestFortitude()
    -- getBuffs().RequestShadowProtection()
    -- getBuffs().RequestSpirit()
    -- getBuffs().RequestFearWard()

    getBuffs().RequestIntellect()
    -- getBuffs().RequestAmplifyMagic()
    -- getBuffs().RequestDampenMagic()

    if myClass == "Warrior" then
        return
    end

    getRotation().ExecuteRotation("Setup")
end

-- [[ PreCast ]] --

function MoronBox.Core.Rotation.PreCast()
    if not getConfigState().RaidLeader and getApi().TableLength(MBID) > 1 then
        getApi().CdPrint("WARNING: You have not chosen a raid leader")
    end

    if getUnit().IsDead() then
        return
    end

    if not getCore().ImRangedDPS() then
        return
    end

    getRaid().AssistFocus()

    if not UnitName("target") then
        return
    end

    getRotation().ExecuteRotation("PreCast")
end

-- [[ Heal & Tank ]] --

local function InterruptingHealAndTank()
    if getCore().ImTank() then
        return
    end

    if not getSpells().IsSpellReady(getConfigState().InterruptSpell[myClass]) then
        return
    end

    if not getConfigState().DoInterrupt.Active then
        return
    end

    getRaid().GetMyInterruptTarget()

    if myClass == "Warrior" then
        if UnitMana("player") >= 10 then
            CastSpellByName(getConfigState().InterruptSpell[myClass])
        end
    elseif myClass == "Shaman" then
        if getSpells().ImBusy() then
            SpellStopCasting()
        end

        CastSpellByName(getConfigState().InterruptSpell[myClass] .. "(Rank 1)")
    elseif myClass == "Rogue" then
        if UnitMana("player") >= 25 then
            CastSpellByName(getConfigState().InterruptSpell[myClass])
        end
    elseif myClass == "Mage" then
        if not MB_isCastingMyCCSpell then
            SpellStopCasting()
        end

        CastSpellByName(getConfigState().InterruptSpell[myClass])
    end

    getConfigState().DoInterrupt.Active = false
end

local function SpecialHealAndTankClass()
    if myClass == "Hunter" then
        if getTables().UseTranquilizingShot() and getSpells().IsSpellReady("Tranquilizing Shot") then
            CastSpellByName("Tranquilizing Shot")
        end
    end

    if myClass == "Mage" then
        getDispel().Decurse()

        if getTables().MobsToDetectMagic() and not getAura().HasBuffOrDebuff("Detect Magic", "target", "debuff") then
            if not getAura().HasBuffOrDebuff("Detect Magic", "player", "debuff") then
                CastSpellByName("Detect Magic")
                return true
            end
        end
    end

    if myClass == "Warlock" and getAura().HasBuffOrDebuff("Hellfire", "player", "buff") then
        CastSpellByName("Life Tap(Rank 1)")
        return true
    end

    return false
end

local function SpecialHealAndTankSituation()
    if Instance.ZG() and myClass == "Mage" and getRaid().TankTarget("Hakkar") then
        if getAura().HasBuffOrDebuff("Mind Control", "target", "debuff") then
            ClearTarget()
            return true
        end

        if not getConfigState().AutoToggleCC.Active then
            getConfigState().AutoToggleCC.Active = true
            getConfigState().AutoToggleCC.Time = GetTime() + 10
            MageCounter.Cycle()
        end

        if getCore().MyClassAlphabeticalOrder() == getConfigState().SheepingMageNr then
            getRaid().CrowdControlMCedRaidMemberHakkar()
        end
    elseif Instance.AQ40() and SKERAM_InFight() and SKERAM_BoxStrategyEnabled() then
        if SKERAM_CrowdControl() then
            return true
        end
    elseif Instance.BWL() and string.find(GetSubZoneText(), "Nefarian.*Lair") and getRaid().IsAtNefarianPhase() then
        if getAura().HasBuffOrDebuff("Shadow Command", "target", "debuff") then
            ClearTarget()
            return true
        end

        if myClass == "Mage" then
            if not getConfigState().AutoToggleCC.Active then
                getConfigState().AutoToggleCC.Active = true
                getConfigState().AutoToggleCC.Time = GetTime() + 3
                MageCounter.Cycle()
            end

            if getCore().MyClassAlphabeticalOrder() == getConfigState().SheepingMageNr then
                getRaid().CrowdControlMCedRaidMemberNefarian()
            end
        end
    elseif Instance.NAXX() and myClass == "Priest" then
        if (getRaid().TankTarget("Instructor Razuvious") and getApi().FindMyNameInTable(MB_myRazuviousPriest) and MB_myRazuviousBoxStrategy) or
            (getRaid().TankTarget("Grand Widow Faerlina") and getApi().FindMyNameInTable(MB_myFaerlinaPriest) and MB_myFaerlinaBoxStrategy) then
            getSpells().GetMCActions()
            return true
        end
    end

    return false
end

function MoronBox.Core.Rotation.HealAndTank()
    if not getConfigState().RaidLeader and getApi().TableLength(MBID) > 1 then
        getApi().CdPrint("WARNING: You have not chosen a raid leader")
    end

    if getUnit().IsDead() then
        return
    end

    getRaid().GetTarget()

    if getAura().HasBuffNamed("Mind Control", "player") or SpecialRotation() then
        return
    end

    CheckWeapon()
    getCons().UseLIP()
    getCons().UseFAP()
    getRaid().GTFO()

    if getAura().HasBuffOrDebuff("First Aid", "player", "buff") and getAura().HasBuffOrDebuff("Recently Bandaged", "player", "debuff") then
        return
    end

    CheckWarStomp()
    CheckStoneForm()
    InterruptingHealAndTank()

    if SpecialHealAndTankClass() then
        return
    end

    if SpecialHealAndTankSituation() then
        return
    end

    if getCrowdControl().CastCrowdControl() then
        return
    end

    if UnitName("target") then
        if getConfigState().CrowdControlTarget and GetRaidTargetIndex("target") == getConfigState().CrowdControlTarget and not getAura().HasBuffOrDebuff(getConfigState().CrowdControlSpell[myClass], "target", "debuff") then
            if getCrowdControl().CastCrowdControl() then
                return
            end
        end

        if getUnit().CrowdControlledMob() then
            getRaid().GetTarget()
        end
    end

    if LOA_Rotation() then
        return
    end

    if getCore().ImTank() then
        getRotation().ExecuteRotation("Single")
    elseif getCore().ImHealer() then
        if myClass == "Druid" then
            if UnitName("target") == "Death Talon Wyrmkin" and GetRaidTargetIndex("target") == getConfigState().CrowdControlTarget then
                CastSpellByName("Hibernate(Rank 1)")
                return
            end
        end

        getRotation().ExecuteRotation("Single")
    end
end

-- [[ Mount Up ]] --

function MoronBox.Core.Rotation.MountUp()
    if myClass == "Druid" and getUnit().IsDruidShapeShifted() and not getUnit().InCombat() then
        getUnit().CancelDruidShapeShift()
    end

    if getSpells().ImBusy() then
        return
    end

    if Instance.AQ40() then
        use(getBag().GetItemLink("Resonating"))
        return
    end

    for _, mount in PlayerMounts do
        use(getBag().GetItemLink(mount))
    end

    if myClass == "Warlock" and getSpells().IsSpellKnown("Summon Dreadsteed") then
        CastSpellByName("Summon Dreadsteed")
        return
    end

    if myClass == "Paladin" and getSpells().IsSpellKnown("Summon Charger") then
        CastSpellByName("Summon Charger")
        return
    end

    CastSpellByName("Summon Felsteed")
    CastSpellByName("Summon Warhorse")
end

-- [[ Clear Marks ]] --

function MoronBox.Core.Rotation.ClearRaidTarget()
    if not getRaid().ImFocus() then
        return
    end

    getApi().SendAddonMessage(MB_RAID .. "CLR_TARG", myName)
    SetRaidTarget("target", 0)
end

-- [[ COOLDOWNS ]] --

function MoronBox.Core.Rotation.Cooldowns()
    if not getConfigState().RaidLeader and (getApi().TableLength(MBID) > 1) then
        getApi().CdPrint("WARNING: You have not chosen a raid leader")
    end

    if getUnit().IsDead() then
        return
    end

    if Instance.ZG() then
        if getAura().MandokirGaze() then
            return
        end
    end

    if not getRaid().ImFocus() then
        return
    end

    if UnitInRaid("player") then
        if getUnit().InCombat("player") then
            if not getConfigState().UseCooldowns.Active then
                getApi().CdPrint("Sending out request to use Cooldowns.")
            else
                getApi().CdPrint("Stop Cooldown Requesting, still " ..
                    math.round(getConfigState().UseCooldowns.Time - GetTime()) .. "s remaining")
            end
        end

        getApi().SendAddonMessage(MB_RAID, "MB_USECOOLDOWNS")
    else
        getApi().SendAddonMessage(MB_RAID, "MB_USECOOLDOWNS")
    end
end

function MoronBox.Core.Rotation.UseManualRecklessness()
    if not getConfigState().RaidLeader and (getApi().TableLength(MBID) > 1) then
        getApi().CdPrint("WARNING: You have not chosen a raid leader")
    end

    if getUnit().IsDead() then
        return
    end

    if Instance.ZG() then
        if getAura().MandokirGaze() then
            return
        end
    end

    if getTables().MobsNoTotems() then
        return
    end

    if not getRaid().ImFocus() then
        return
    end

    if UnitInRaid("player") then
        if getUnit().InCombat("player") then
            if not getConfigState().UseBigCooldowns.Active then
                getApi().CdPrint("Sending out request to use Recklessness.")
            else
                getApi().CdPrint("Stop Recklessness Requesting, still " ..
                    math.round(getConfigState().UseBigCooldowns.Time - GetTime()) .. "s remaining")
            end
        end

        getApi().SendAddonMessage(MB_RAID, "MB_USERECKLESSNESS")
    else
        getApi().SendAddonMessage(MB_RAID, "MB_USERECKLESSNESS")
    end
end

-- [[ Follow Raid ]] --

local function SpecialFollowing()
    if Instance.AQ40() and getAura().HasBuffOrDebuff("Plague", "player", "debuff") and getRaid().TankTarget("Anubisath Defender") then
        return true
    elseif Instance.MC() and getRaid().TankTarget("Baron Geddon") and getApi().FindMyNameInTable(MB_raidAssist.GTFO.Baron) then
        return true
    elseif Instance.ONY() and getRaid().TankTarget("Onyxia") and myName == MB_myOnyxiaMainTank then
        return true
    end

    return false
end

local function FollowRaidLeader()
    if getConfigState().RaidLeader then
        FollowByName(getConfigState().RaidLeader, 1)
        SetView(5)
    end
end

function MoronBox.Core.Rotation.FollowFocus()
    if SpecialFollowing() then
        return
    end

    if myClass == "Warlock" and getAura().HasBuffOrDebuff("Hellfire", "player", "buff") then
        CastSpellByName("Life Tap(Rank 1)")
    end

    if getRaid().ImFocus() then
        return
    end

    if not (Instance.NAXX() and THAD_IsFollowThaddius()) then
        FollowRaidLeader()
    end
end

function MoronBox.Core.Rotation.CasterFollow()
    if SpecialFollowing() then
        return
    end

    if myClass == "Warlock" and getAura().HasBuffOrDebuff("Hellfire", "player", "buff") then
        CastSpellByName("Life Tap(Rank 1)")
    end

    if getRaid().ImFocus() then
        return
    end

    if getCore().ImRangedDPS() then
        FollowRaidLeader()
    end
end

function MoronBox.Core.Rotation.MeleeFollow()
    if SpecialFollowing() then
        return
    end

    if getRaid().ImFocus() then
        return
    end

    if Instance.AQ40() and SKERAM_InFight() and SKERAM_BoxStrategyEnabled() then
        if SKERAM_IsFollowSkeram() then
            return
        end
    elseif Instance.BWL() and getRaid().IsAtRazorgore() and getRaid().IsAtRazorgorePhase() and MB_myRazorgoreBoxStrategy then
        if myName == getUnit().ReturnPlayerInRaidFromTable(MB_myRazorgoreLeftTank) or myName == getUnit().ReturnPlayerInRaidFromTable(MB_myRazorgoreRightTank) then
            return
        end

        if getApi().FindMyNameInTable(MB_myRazorgoreLeftDPSERS) then
            local leftTank = getUnit().ReturnPlayerInRaidFromTable(MB_myRazorgoreLeftTank)
            if leftTank then FollowByName(leftTank, 1) end
            return
        end

        if getApi().FindMyNameInTable(MB_myRazorgoreRightDPSERS) then
            local rightTank = getUnit().ReturnPlayerInRaidFromTable(MB_myRazorgoreRightTank)
            if rightTank then FollowByName(rightTank, 1) end
            return
        end
    else
        if getCore().ImMeleeDPS() then
            FollowRaidLeader()
        end

        if getCore().ImTank() and not MB_myOTTarget
            and not (getRaid().TankTarget("Instructor Razuvious") or getRaid().TankTarget("Razorgore the Untamed")
                or getRaid().TankTarget("Chromaggus") or getRaid().IsAtTwinsEmps()) then
            FollowRaidLeader()
        end
    end
end

function MoronBox.Core.Rotation.TankFollow()
    if SpecialFollowing() then
        return
    end

    if getRaid().ImFocus() then
        return
    end

    if getCore().ImTank() then
        FollowRaidLeader()
    end
end

function MoronBox.Core.Rotation.HealerFollow()
    if SpecialFollowing() then
        return
    end

    if getRaid().ImFocus() then
        return
    end

    if not getCore().ImHealer() then
        return
    end

    if Instance.NAXX() and THAD_IsAtThaddiusP1() then
        THAD_IsFollowThaddiusHealers()
    else
        FollowRaidLeader()
    end
end

-- [[ Break Fear ]] --

function MoronBox.Core.Rotation.FearBreak()
    if IsShiftKeyDown() then
        getRotation().CleanseTotem()
        return
    end

    if myClass == "Warrior" then
        if getSpells().IsSpellReady("Berserker Rage") then
            getSpells().SelfBuff("Berserker Stance")
            CastSpellByName("Berserker Rage")
            return
        end
    end

    if myClass == "Shaman" then
        if getSpells().ImBusy() then
            SpellStopCasting()
            return
        end

        getSpells().CastSpellWithCooldown("Tremor Totem", 15)
    end

    if getSpells().IsSpellKnown("Will of the Forsaken") then
        if myClass == "Warrior" then
            if getAura().HasBuffOrDebuff("Berserker Rage", "player", "buff") then
                getApi().CdPrint("WARNING: You already have Berserker Rage!")
                return
            end

            if getSpells().IsSpellReady("Will of the Forsaken") and not getSpells().IsSpellReady("Berserker Rage") then
                CastSpellByName("Will of the Forsaken")
            end
        else
            if getSpells().IsSpellReady("Will of the Forsaken") then
                CastSpellByName("Will of the Forsaken")
            end
        end
    end
end

-- [[ Cleanse Totem ]] --

function MoronBox.Core.Rotation.CleanseTotem()
    if myClass == "Shaman" then
        if getDispel().PartyIsPoisoned() then
            if getSpells().ImBusy() then
                SpellStopCasting()
                return
            end

            CastSpellByName("Poison Cleansing Totem")
        elseif getDispel().PartyIsDiseased() then
            if getSpells().ImBusy() then
                SpellStopCasting()
                return
            end

            CastSpellByName("Disease Cleansing Totem")
        end
    end
end

-- [[ Manual Interrupt ]] --

function MoronBox.Core.Rotation.Interrupt()
    if getCore().ImTank() then
        return
    end

    if not getSpells().IsSpellReady(getConfigState().InterruptSpell[myClass]) then
        return
    end

    getRaid().GetMyInterruptTarget()

    if myClass == "Warrior" then
        if UnitMana("player") >= 10 then
            CastSpellByName(getConfigState().InterruptSpell[myClass])
        end
    elseif myClass == "Shaman" then
        if getSpells().ImBusy() then
            SpellStopCasting()
        end

        CastSpellByName(getConfigState().InterruptSpell[myClass] .. "(Rank 1)")
    elseif myClass == "Rogue" then
        if UnitMana("player") >= 25 then
            CastSpellByName(getConfigState().InterruptSpell[myClass])
        end
    elseif myClass == "Mage" then
        if getSpells().ImBusy() then
            SpellStopCasting()
        end

        CastSpellByName(getConfigState().InterruptSpell[myClass])
    end
end

-- [[ Revive ]] --

function MoronBox.Core.Rotation.Ress()
    if getCore().ImHealer() then
        if (myClass == "Shaman" and UnitMana("player") < 1368) or
            (myClass == "Priest" and UnitMana("player") < 1090) or
            (myClass == "Paladin" and UnitMana("player") < 1209) then
            getWater().SmartDrink()
        end

        MBH_Resurrection()
    end

    if getCore().ImRangedDPS() then
        getWater().SmartDrink()
    end
end

-- [[ Tank Shoot or Taunt ]] --

function MoronBox.Core.Rotation.TankShoot()
    if not getConfigState().RaidLeader and (getApi().TableLength(MBID) > 1) then
        getApi().CdPrint("WARNING: You have not chosen a raid leader")
    end

    if getUnit().IsDead() then
        return
    end

    if Instance.ZG() and getRaid().TankTarget("Bloodlord Mandokir") then
        if getAura().MandokirGaze() then
            return
        end
    end

    if not getCore().ImTank() then
        if myClass == "Shaman" then
            MoronBox.Core.Rotation.DropTotems()
        end
        return
    end

    local rangedWep = getBag().GetEquippedItemSubType(18)
    if not rangedWep then
        return
    end

    if not getSpells().SpellExists("Shoot " .. rangedWep) then
        return
    end

    if MB_myOTTarget or getRaid().ImFocus() then
        CastSpellByName("Shoot " .. rangedWep)
    end
end

function MoronBox.Core.Rotation.ManualTaunt()
    if not getConfigState().RaidLeader and (getApi().TableLength(MBID) > 1) then
        getApi().CdPrint("WARNING: You have not chosen a raid leader")
    end

    if getUnit().IsDead() then
        return
    end

    if Instance.ZG() and getRaid().TankTarget("Bloodlord Mandokir") then
        if getAura().MandokirGaze() then
            return
        end
    end

    if not getCore().ImTank() then
        return
    end

    if myClass == "Warrior" and getSpells().IsSpellReady("Taunt") then
        CastSpellByName("Taunt")
    elseif myClass == "Druid" and getSpells().IsSpellReady("Growl") then
        CastSpellByName("Growl")
    end
end
