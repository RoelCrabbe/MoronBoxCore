-- [[ Config & Constants ]] --

MoronBox.Core = MoronBox.Core or {}
MoronBox.Core.Spells = MoronBox.Core.Spells or {}
MoronBox.Core.Raid = MoronBox.Core.Raid or {}

local myClass = UnitClass("player")
local myName = UnitName("player")

local Core = MoronBox.Core
local GeneralState = Core.GeneralState
local Spells = MoronBox.Core.Spells
local Raid = MoronBox.Core.Raid

---@diagnostic disable: undefined-global
setfenv(1, MoronBox:GetEnvironment())

-- [[ Focus | Assist ]] --

function MoronBox.Core.Raid.ImFocus()
    return MB_raidLeader == myName
end

function MoronBox.Core.Raid.AssistFocus()
    if not Raid.ImFocus() and myName ~= MB_raidInviter then
        AssistByName(MB_raidInviter)
        RunLine("/w " .. MB_raidInviter .. " Press setFOCUS!")
        return false
    end

    if Raid.ImFocus() then
        return true
    end

    local assistUnit = GetUnitForPlayerName(MB_raidLeader)
    if not assistUnit then
        return true
    end

    local assistTarget = assistUnit .. "target"
    if UnitIsUnit("target", assistTarget) then
        return true
    end

    if UnitExists(assistTarget) then
        TargetUnit(assistTarget)
        return true
    end

    ClearTarget()
    return false
end

function MoronBox.Core.Raid.FocusAggro()
    if not MB_raidLeader then
        return false
    end

    local raidLeaderId = GeneralState.MBID[MB_raidLeader]
    if not raidLeaderId then
        return false
    end

    local targetTarget = UnitName(raidLeaderId .. "targettarget")
    if not targetTarget then
        return false
    end

    return targetTarget == myName
end

function MoronBox.Core.Raid.GetMyInterruptTarget()
    if not MB_myInterruptTarget then
        Raid.AssistFocus()
        return
    end

    for i = 1, 6 do
        local targetIndex = GetRaidTargetIndex("target")

        if targetIndex == MB_myInterruptTarget then
            if not Dead("target") then
                return
            end

            TargetNearestEnemy()
        end

        TargetNearestEnemy()
    end
end

-- [[ Raid Targetting ]] --

function MoronBox.Core.Raid.TankTarget(mobName)
    if not MB_raidLeader then
        return false
    end

    local focusId = GeneralState.MBID[MB_raidLeader]
    if not focusId then
        return false
    end

    local targetOfFocus = UnitName(focusId .. "target")
    if not targetOfFocus then
        return false
    end

    return targetOfFocus == mobName
end

function MoronBox.Core.Raid.TankTargetInSet(mobSet)
    local focusId = GeneralState.MBID[MB_raidLeader]
    if not focusId then
        return false
    end

    local tankTargetName = UnitName(focusId .. "target")
    if not tankTargetName then
        return false
    end

    return mobSet[tankTargetName] == true
end

function MoronBox.Core.Raid.TankTargetHealth()
    if not MB_raidLeader then
        return nil
    end

    local focusId = GeneralState.MBID[MB_raidLeader]
    if not focusId then
        return nil
    end

    local targetId = focusId .. "target"
    if not UnitExists(targetId) then
        return nil
    end

    if IsDead(targetId) then
        return 0
    end

    return HealthPct(targetId)
end

function MoronBox.Core.Raid.TargetHealthFromRaidleader(mobName, percentage)
    local focusId = GeneralState.MBID[MB_raidLeader]
    if not focusId then
        return false
    end

    local isTargetingMob = Raid.TankTarget(mobName)
    if not isTargetingMob then
        return false
    end

    local targetHealthPercentage = HealthPct(focusId .. "target")
    return (targetHealthPercentage <= percentage)
end

function MoronBox.Core.Raid.TargetFromSpecificPlayer(targetName, playerName)
    local playerId = GeneralState.MBID[playerName]
    if not playerId then
        return false
    end

    local playerTarget = UnitName(playerId .. "target")
    if not playerTarget then
        return false
    end

    return playerTarget == targetName
end

-- [[ Assist | LockOn ]] --

function MoronBox.Core.Raid.AssistSpecificTargetFromPlayer(targetName, playerName)
    local playerId = GeneralState.MBID[playerName]
    if not playerId then
        return false
    end

    if not Raid.TargetFromSpecificPlayer(targetName, playerName) then
        return false
    end

    AssistUnit(playerId)
    return true
end

function MoronBox.Core.Raid.AssistSpecificTargetFromPlayerInMeleeRange(targetName, playerName)
    local playerId = GeneralState.MBID[playerName]
    if not playerId then
        return false
    end

    if not Raid.TargetFromSpecificPlayer(targetName, playerName) then
        return false
    end

    if not InMeleeRange(playerId .. "target") then
        return false
    end

    AssistUnit(playerId)
    return true
end

function MoronBox.Core.Raid.LockOnTarget(target)
    for i = 1, 3 do
        if UnitName("target") == target and not Dead("target") then
            return true
        end

        TargetByName(target)
    end
    return false
end

function MoronBox.Core.Raid.FixateOnTarget(target)
    return UnitName("target") == target and not Dead("target")
end

-- [[ Encounters ]] --

local JindoTargets = {
    ["Powerful Healing Ward"] = true,
    ["Shade of Jin'do"] = true,
    ["Jin'do the Hexxer"] = true,
    ["Brain Wash Totem"] = true
}

function MoronBox.Core.Raid.IsAtJindo()
    for name in pairs(JindoTargets) do
        if Raid.TankTarget(name) then
            return true
        end
    end

    local targetName = UnitName("target")
    return targetName ~= nil and JindoTargets[targetName] == true
end

local NothTargets = {
    ["Noth the Plaguebringer"] = true,
    ["Plagued Warrior"] = true,
    ["Plagued Champion"] = true,
    ["Plagued Guardian"] = true,
    ["Plagued Skeletons"] = true
}

function MoronBox.Core.Raid.IsAtNoth()
    for name in pairs(NothTargets) do
        if Raid.TankTarget(name) then
            return true
        end
    end

    local targetName = UnitName("target")
    return targetName ~= nil and NothTargets[targetName] == true
end

local MonstrosityTargets = {
    ["Living Monstrosity"] = true,
    ["Mad Scientist"] = true,
    ["Surgical Assistant"] = true
}

function MoronBox.Core.Raid.IsAtMonstrosity()
    for name in pairs(MonstrosityTargets) do
        if Raid.TankTarget(name) then
            return true
        end
    end

    local targetName = UnitName("target")
    return targetName ~= nil and MonstrosityTargets[targetName] == true
end

local function IsOrbControlled()
    for i = 1, GetNumRaidMembers() do
        if mb_hasBuffOrDebuff("Mind Exhaustion", "raid" .. i, "debuff") then
            return true
        end
    end
    return false
end

local RazorgoreTargets = {
    ["Blackwing Mage"] = true,
    ["Blackwing Legionnaire"] = true,
    ["Death Talon Dragonspawn"] = true
}

function MoronBox.Core.Raid.IsAtRazorgorePhase()
    if IsOrbControlled() then
        return true
    end

    for name in pairs(RazorgoreTargets) do
        if Raid.TankTarget(name) then
            return true
        end
    end

    local leftTank = Raid.ReturnPlayerInRaidFromTable(MB_myRazorgoreLeftTank)
    local rightTank = Raid.ReturnPlayerInRaidFromTable(MB_myRazorgoreRightTank)

    for name in pairs(RazorgoreTargets) do
        if Raid.TargetFromSpecificPlayer(name, leftTank) or Raid.TargetFromSpecificPlayer(name, rightTank) then
            return true
        end
    end

    local targetName = UnitName("target")
    return targetName ~= nil and RazorgoreTargets[targetName] == true
end

local RazuviousTargets = {
    ["Instructor Razuvious"] = true,
    ["Deathknight Understudy"] = true
}

function MoronBox.Core.Raid.IsAtInstructorRazuvious()
    for name in pairs(RazuviousTargets) do
        if Raid.TankTarget(name) then
            return true
        end
    end

    local targetName = UnitName("target")
    return targetName ~= nil and RazuviousTargets[targetName] == true
end

local NefarianTargets = {
    ["Red Drakonid"] = true,
    ["Blue Drakonid"] = true,
    ["Green Drakonid"] = true,
    ["Black Drakonid"] = true,
    ["Bronze Drakonid"] = true,
    ["Chromatic Drakonid"] = true,
    ["Lord Victor Nefarius"] = true
}

function MoronBox.Core.Raid.IsAtNefarianPhase()
    for name in pairs(NefarianTargets) do
        if Raid.TankTarget(name) then
            return true
        end
    end

    local targetName = UnitName("target")
    return targetName ~= nil and NefarianTargets[targetName] == true
end

local TwinsEmpsTargets = {
    ["Qiraji Scarab"] = true,
    ["Qiraji Scorpion"] = true,
    ["Emperor Vek'lor"] = true,
    ["Emperor Vek'nilash"] = true
}

function MoronBox.Core.Raid.IsAtTwinsEmps()
    for name in pairs(TwinsEmpsTargets) do
        if Raid.TankTarget(name) then
            return true
        end
    end

    local targetName = UnitName("target")
    return targetName ~= nil and TwinsEmpsTargets[targetName] == true
end

-- [[ Off Tanking ]] --

function MoronBox.Core.Raid.OffTank()
    if not MB_myOTTarget then
        return
    end

    if UnitExists("target") and GetRaidTargetIndex("target") == MB_myOTTarget then
        if Dead("target") then
            MB_myOTTarget = nil
            TargetUnit("playertarget")
            return
        end

        MoronBox.Api.CdPrint("Locked On Target")
        return
    end

    for i = 1, 6 do
        if UnitExists("target") and GetRaidTargetIndex("target") == MB_myOTTarget
            and not Dead("target") and not InCombat("target") then
            return
        end

        TargetNearestEnemy()
    end
end

local IgnoredTargets = {
    ["Deathknight Understudy"] = true,
    ["Hakkar"] = true,
    ["Fallout Slime"] = true
}

function MoronBox.Core.Raid.GetTargetNotOnTank()
    if Dead("player") then
        return
    end

    local targetName = UnitName("target")
    if targetName and IgnoredTargets[targetName] then
        return
    end

    if IsNotValidTankableTarget() then
        TargetNearestEnemy()
    end

    local targetTarget = UnitName("targettarget")

    -- Initial validation
    if UnitIsEnemy("target", "player") and InCombat("target")
        and not FindInTable(MB_raidTanks, targetTarget) then
        return
    end

    -- Scan for targets
    for i = 0, 8 do
        if not UnitName("target") then
            TargetNearestEnemy()
        end

        if UnitIsEnemy("target", "player") and InCombat("target")
            and not FindInTable(MB_raidTanks, targetTarget) then
            return
        end

        TargetNearestEnemy()
    end
end

-- [[ Auto Mark Moam ]] --

local function IsMoamOrManaFiend(targetName)
    return targetName == "Moam" or targetName == "Mana Fiend"
end

function MoronBox.Core.Raid.AutoAssignBanishOnMoam()
    if not Raid.ImFocus() then
        return
    end

    local targetName = UnitName("target")
    if not IsMoamOrManaFiend(targetName) then
        return
    end

    for i = 1, 5 do
        if UnitName("target") == "Mana Fiend" and not GetRaidTargetIndex("target")
            and not Dead("target") then
            mb_assignCrowdControl()
            return
        end

        TargetNearestEnemy()
    end

    if not moamDead then
        TargetByName("Moam")
    end

    if Dead("target") and UnitName("target") == "Moam" then
        moamDead = true
    end
end

-- [[ Anub Warning ]] --

local AubAlertCD = GetTime()

function MoronBox.Core.Raid.AnubisathAlert()
    if mb_imFocus() or UnitName("target") ~= "Anubisath Sentinel" then
        return
    end

    local now = GetTime()
    if AubAlertCD + 5 > now then
        return
    end

    local alerts = {
        ["Shadow Storm"]             = "SHADOW STORM, BACK ME UP",
        ["Mana Burn"]                = "MANA BURN, BACK ME UP",
        ["Thunderclap"]              = "THUNDERCLAP, BACK ME UP",
        ["Thorns"]                   = "This guy has Thorns",
        ["Mortal Strike"]            = "This guy has Mortal Strike",
        ["Shadow and Frost Reflect"] = "This guy has Shadow and Frost Reflect",
        ["Fire and Arcane Reflect"]  = "This guy has Fire and Arcane Reflect",
        ["Mending"]                  = "This guy has Mending",
        ["Periodic Knock Away"]      = "This guy has Knockaway"
    }

    for buff, message in pairs(alerts) do
        if mb_hasBuffOrDebuff(buff, "target", "buff") then
            AubAlertCD = now
            MoronBox.Api.CdSay(message)
            break
        end
    end
end

-- [[ Hakker & Nefarian MC ]] --

local function CastPolymorph(unitId)
    TargetUnit(unitId)

    if not MB_isCastingMyCCSpell then
        SpellStopCasting()
    end

    CastSpellByName("Polymorph")
end

function MoronBox.Core.Raid.CrowdControlMCedRaidMember(debuffName, message)
    if Dead("player") then
        return false
    end

    for i = 1, GetNumRaidMembers() do
        local unitId = "raid" .. i
        if UnitName(unitId) and Raid.IsAlive(unitId) and Raid.In28yardRange(unitId) then
            if mb_hasBuffOrDebuff(debuffName, unitId, "debuff")
                and not mb_hasBuffOrDebuff("Polymorph", unitId, "debuff") then
                CastPolymorph(unitId)

                if message then
                    Raid.CdMessage(message .. " " .. UnitName(unitId), 30)
                end

                return true
            end
        end
    end
    return false
end

function MoronBox.Core.Raid.CrowdControlMCedRaidMemberHakkar()
    return Raid.CrowdControlMCedRaidMember("Mind Control", "Sheeping")
end

function MoronBox.Core.Raid.CrowdControlMCedRaidMemberNefarian()
    return Raid.CrowdControlMCedRaidMember("Shadow Command", "Sheeping")
end

-- [[ Locations ]] --

function MoronBox.Core.Raid.IsAtRazorgore()
    return GetSubZoneText() == "Dragonmaw Garrison"
end

-- [[ GTFO ]] --

function MoronBox.Core.Raid.GTFO()
    if not MB_raidAssist.GTFO.Active then
        return
    end

    mb_useSandsOnChromaggus()

    if mb_imFocus() then
        return
    end

    if Instance.ONY() and MB_myOnyxiaBoxStrategy then
        if Raid.TankTarget("Onyxia") and (Raid.TankTargetHealth() <= 0.65 and Raid.TankTargetHealth() >= 0.4) and myName ~= MB_myOnyxiaMainTank then
            if Raid.FocusAggro() then
                if myClass == "Paladin" and mb_spellReady("Divine Shield") then
                    CastSpellByName("Divine Shield")
                    return
                end

                local runTank = ReturnPlayerInRaidFromTable(MB_raidAssist.GTFO.Onyxia)
                local runTankId = GeneralState.MBID[runTank]

                if runTankId and IsAlive(runTankId) then
                    FollowByName(runTank, 1)
                end
            else
                local mainTankId = GeneralState.MBID[MB_myOnyxiaFollowTarget]

                if mainTankId and InRange(mainTankId) then
                    if not InMeleeRange(mainTankId) then
                        FollowByName(MB_myOnyxiaFollowTarget, 1)
                    end
                end
            end
        end
    end

    if not AggroOnPlayer() then
        if Instance.NAXX() then
            GLUTH_GetOUT()
            GROB_GetOUT()
            mb_useFirePotsOnFaerlina()
        elseif Instance.BWL() and mb_hasBuffOrDebuff("Burning Adrenaline", "player", "debuff") then
            if myClass == "Paladin" and mb_spellReady("Divine Shield") then
                CastSpellByName("Divine Shield")
                return
            end

            local vaelTank = ReturnPlayerInRaidFromTable(MB_raidAssist.GTFO.Vaelastrasz)
            local vaelTankId = GeneralState.MBID[vaelTank]

            if vaelTankId and IsAlive(vaelTankId) then
                FollowByName(vaelTank, 1)
            end
        elseif Instance.MC() and mb_hasBuffOrDebuff("Living Bomb", "player", "debuff") then
            if myClass == "Paladin" and mb_spellReady("Divine Shield") then
                CastSpellByName("Divine Shield")
                return
            end

            local baronTank = ReturnPlayerInRaidFromTable(MB_raidAssist.GTFO.Baron)
            local baronTankId = GeneralState.MBID[baronTank]

            if baronTankId and IsAlive(baronTankId) then
                FollowByName(baronTank, 1)
            end
        end
    end
end

-- [[ Get Target ]] --

local function GetTargetIfNone()
    if not UnitName("target") or Dead("target") then
        Raid.AssistFocus()
    end
end

local function HandleNAXXTargetingPreFocus()
    if THAD_TargetingPreFocus() then
        return true
    end

    return false
end

local function HandleAQ40TargetingPreFocus()
    if SKERAM_TargetingPreFocus() then
        return true
    end

    if BUGTRIO_TargetingPreFocus() then
        return true
    end

    if FANKRISS_TargetingPreFocus() then
        return true
    end

    return false
end

local function HandleBWLTargetingPreFocus()
    local tName = UnitName("target")

    for k, v in MB_myRazorgoreORBtank do
        Print(k)
        Print(v)
    end

    if myName == ReturnPlayerInRaidFromTable(MB_myRazorgoreORBtank) then
        return true
    end

    if not Raid.IsAtRazorgorePhase() then
        return false
    end

    if (myName == ReturnPlayerInRaidFromTable(MB_myRazorgoreLeftTank)
            or myName == ReturnPlayerInRaidFromTable(MB_myRazorgoreRightTank)) and MB_raidLeader ~= myName then
        MB_raidLeader = myName
    end

    if not Raid.ImFocus() then
        return false
    end

    if (myName == ReturnPlayerInRaidFromTable(MB_myRazorgoreLeftTank) or myName == ReturnPlayerInRaidFromTable(MB_myRazorgoreRightTank)) then
        if not MB_targetNearestDistanceChanged then
            SetCVar("targetNearestDistance", "15")
            MB_targetNearestDistanceChanged = true
        end

        if MB_razorgoreNewTargetBecauseTargetIsBehind.Active then
            TargetNearestEnemy()
            MB_razorgoreNewTargetBecauseTargetIsBehind.Active = false
            return true
        end

        if (tName == nil or Dead("target")) then
            TargetNearestEnemy()
            return true
        end

        CdPrint("Focussing Attacks on " .. tName, 30)
        return true
    end

    return false
end

local function HandleNAXXTargetingPostFocus()
    local tName = UnitName("target")

    if LOA_Targeting() then
        return true
    end

    if GROB_Targeting() then
        return true
    end

    if THAD_TargetingPostFocus() then
        return true
    end

    if (Raid.TankTarget("Instructor Razuvious") and FindMyNameInTable(MB_myRazuviousPriest) and MB_myRazuviousBoxStrategy) or
        (Raid.TankTarget("Grand Widow Faerlina") and FindMyNameInTable(MB_myFaerlinaPriest) and MB_myFaerlinaBoxStrategy) then
        return true
    elseif Raid.TankTarget("Anub\'Rekhan") then
        if ImTank() then
            Raid.GetTargetNotOnTank()
            return true
        elseif ImMeleeDPS() or ImRangedDPS() then
            for i = 1, 2 do
                if tName == "Crypt Guard" and not Dead("target") then
                    return true
                end

                TargetNearestEnemy()
            end

            GetTargetIfNone()
            return true
        end
    elseif Raid.IsAtMonstrosity() then
        if ImTank() then
            Raid.GetTargetNotOnTank()
            return true
        elseif ImMeleeDPS() or ImRangedDPS() then
            if Raid.LockOnTarget("Lightning Totem") then
                return true
            end

            GetTargetIfNone()
            return true
        end
    elseif Raid.TankTarget("Plague Beast") then
        if ImTank() then
            Raid.GetTargetNotOnTank()
            return true
        elseif ImMeleeDPS() then
            if MB_targetWrongWayOrTooFar.Active then
                TargetNearestEnemy()
                MB_targetWrongWayOrTooFar.Active = false
                return true
            end

            for i = 1, 4 do
                if tName == "Mutated Grub" and not Dead("target") then
                    return true
                end

                if tName == "Plagued Bat" and not Dead("target") then
                    return true
                end

                TargetNearestEnemy()
            end

            GetTargetIfNone()
            return true
        elseif ImRangedDPS() then
            Raid.AssistFocus()
            return true
        end
    end

    return false
end

local function HandleAQ40TargetingPostFocus()
    local tName = UnitName("target")

    if SKERAM_TargetingPostFocus() then
        return true
    end

    if BUGTRIO_TargetingPostFocus() then
        return true
    end

    if SARTURA_TargetingPostFocus() then
        return true
    end

    if FANKRISS_TargetingPostFocus() then
        return true
    end

    if Raid.TankTarget("Anubisath Defender") then
        if ImTank() then
            Raid.GetTargetNotOnTank()
            return true
        end

        for i = 1, 4 do
            if tName == "Anubisath Swarmguard" and not Dead("target") then
                return true
            end

            if tName == "Anubisath Warrior" and not Dead("target") then
                return true
            end

            TargetNearestEnemy()
        end

        GetTargetIfNone()
        return true
    end

    return false
end

local function HandleBWLTargetingPostFocus()
    local tName = UnitName("target")

    if Raid.IsAtRazorgore() and MB_myRazorgoreBoxStrategy then
        if myName == ReturnPlayerInRaidFromTable(MB_myRazorgoreORBtank) then
            return true
        end

        if not Raid.IsAtRazorgorePhase() then
            return false
        end

        if (myName == ReturnPlayerInRaidFromTable(MB_myRazorgoreLeftTank) or myName == ReturnPlayerInRaidFromTable(MB_myRazorgoreRightTank)) then
            if not MB_targetNearestDistanceChanged then
                SetCVar("targetNearestDistance", "15")
                MB_targetNearestDistanceChanged = true
            end

            if MB_razorgoreNewTargetBecauseTargetIsBehind.Active then
                TargetNearestEnemy()
                MB_razorgoreNewTargetBecauseTargetIsBehind.Active = false
                return true
            end

            if (tName == nil or Dead("target")) then
                TargetNearestEnemy()
                return true
            end

            return true
        elseif ImTank() then
            if not MB_targetNearestDistanceChanged then
                SetCVar("targetNearestDistance", "10")
                MB_targetNearestDistanceChanged = true
            end

            if MB_razorgoreNewTargetBecauseTargetIsBehind.Active then
                TargetNearestEnemy()
                MB_razorgoreNewTargetBecauseTargetIsBehind.Active = false
                return true
            end

            Raid.GetTargetNotOnTank()
            return true
        elseif ImMeleeDPS() then
            if FindMyNameInTable(MB_myRazorgoreLeftDPSERS) then
                local leftTank = ReturnPlayerInRaidFromTable(MB_myRazorgoreLeftTank)
                if leftTank then
                    AssistByName(leftTank)
                end
                return true
            end
            if FindMyNameInTable(MB_myRazorgoreRightDPSERS) then
                local rightTank = ReturnPlayerInRaidFromTable(MB_myRazorgoreRightTank)
                if rightTank then
                    AssistByName(rightTank)
                end
                return true
            end

            return true
        elseif ImRangedDPS() then
            if MB_razorgoreNewTargetBecauseTargetIsBehind.Active then
                TargetNearestEnemy()
                MB_razorgoreNewTargetBecauseTargetIsBehind.Active = false
                return true
            end

            if not Dead("target") then
                return true
            end

            local tankOno = ReturnPlayerInRaidFromTable(MB_myRazorgoreRightTank)
            local tankTwo = ReturnPlayerInRaidFromTable(MB_myRazorgoreLeftTank)

            if Raid.AssistSpecificTargetFromPlayer("Blackwing Mage", tankOno) then
                return true
            end

            if Raid.AssistSpecificTargetFromPlayer("Blackwing Mage", tankTwo) then
                return true
            end

            if Raid.AssistSpecificTargetFromPlayer("Blackwing Legionnaire", tankOno) then
                return true
            end

            if Raid.AssistSpecificTargetFromPlayer("Blackwing Legionnaire", tankTwo) then
                return true
            end

            if Raid.AssistSpecificTargetFromPlayer("Death Talon Dragonspawn", tankOno) then
                return true
            end

            if Raid.AssistSpecificTargetFromPlayer("Death Talon Dragonspawn", tankTwo) then
                return true
            end

            GetTargetIfNone()
            return true
        end

        return true
    elseif GetSubZoneText() == "Shadow Wing Lair" then
        if MB_raidLeader and Dead(DefaultState.MBID[MB_raidLeader]) then
            Raid.LockOnTarget("Vaelastrasz the Corrupt")
            return true
        end
    end

    return false
end

local function HandleMCTargetingPostFocus()
    if LUCIFRON_TargetingPostFocus() then
        return true
    end

    if MAGMADAR_TargetingPostFocus() then
        return true
    end

    if GEHENNAS_TargetingPostFocus() then
        return true
    end

    if GARR_TargetingPostFocus() then
        return true
    end

    if SHAZZRAH_TargetingPostFocus() then
        return true
    end

    if GEDDON_TargetingPostFocus() then
        return true
    end

    if GOLEMAGG_TargetingPostFocus() then
        return true
    end

    if SULFURON_TargetingPostFocus() then
        return true
    end

    if MAJORDOMO_TargetingPostFocus() then
        return true
    end

    if RAGNAROS_TargetingPostFocus() then
        return true
    end

    return false
end

local function HandleONYTargetingPostFocus()
    local tName = UnitName("target")

    if ImTank() then
        Raid.GetTargetNotOnTank()
        return true
    elseif ImMeleeDPS() then
        if MB_targetWrongWayOrTooFar.Active then
            TargetNearestEnemy()
            MB_targetWrongWayOrTooFar.Active = false
            return true
        end

        for i = 1, 2 do
            if tName == "Onyxian Whelp" and not Dead("target") then
                return true
            end

            TargetNearestEnemy()
        end

        GetTargetIfNone()
        return true
    elseif ImRangedDPS() then
        if Raid.AssistSpecificTargetFromPlayer("Onyxia", MB_myOnyxiaMainTank) then
            return true
        end

        GetTargetIfNone()
        return true
    end

    return false
end

local function HandleZGTargetingPostFocus()
    local tName = UnitName("target")

    if Raid.IsAtJindo() then
        if ImTank() then
            Raid.GetTargetNotOnTank()
            return true
        elseif ImMeleeDPS() then
            for i = 1, 2 do
                if tName == "Shade of Jin\'do" and not Dead("target") then
                    return true
                end

                TargetNearestEnemy()
            end

            GetTargetIfNone()
            return true
        elseif ImRangedDPS() then
            for i = 1, 6 do
                if tName == "Shade of Jin\'do" and not Dead("target") then
                    return true
                end

                if tName == "Powerful Healing Ward" and not Dead("target") then
                    return true
                end

                if tName == "Brain Wash Totem" and not Dead("target") then
                    return true
                end

                TargetNearestEnemy()
            end

            GetTargetIfNone()
            return true
        end
    elseif Raid.TankTarget("High Priestess Mar\'li") then
        if ImTank() then
            Raid.GetTargetNotOnTank()
            return true
        elseif ImMeleeDPS() then
            Raid.AssistFocus()
            return true
        elseif ImRangedDPS() then
            for i = 1, 4 do
                if tName == "Spawn of Mar\'li" and not Dead("target") then
                    return true
                end

                if tName == "Witherbark Speaker" and not Dead("target") then
                    return true
                end

                TargetNearestEnemy()
            end

            GetTargetIfNone()
            return true
        end
    elseif Raid.TankTarget("High Priestess Jeklik") then
        if ImTank() then
            Raid.GetTargetNotOnTank()
            return true
        elseif ImRangedDPS() then
            for i = 1, 2 do
                if tName == "Bloodseeker Bat" and InCombat("target") and not Dead("target") then
                    return true
                end

                TargetNearestEnemy()
            end

            GetTargetIfNone()
            return true
        end
    elseif Raid.TankTarget("High Priest Venoxis") then
        if ImTank() then
            Raid.GetTargetNotOnTank()
            return true
        elseif ImMeleeDPS() or ImRangedDPS() then
            for i = 1, 2 do
                if tName == "Razzashi Cobra" and not Dead("target")
                    and not GetRaidTargetIndex("target") then
                    return true
                end

                TargetNearestEnemy()
            end

            GetTargetIfNone()
            return true
        end
    end

    return false
end

local function HandleAQ20TargetingPostFocus()
    local tName = UnitName("target")

    if ImTank() then
        Raid.GetTargetNotOnTank()
        return true
    elseif ImMeleeDPS() or ImRangedDPS() then
        for i = 1, 2 do
            if tName == "Hive\'Zara Larva" and not Dead("target") then
                return true
            end

            TargetNearestEnemy()
        end

        GetTargetIfNone()
        return true
    end

    return false
end

local function HandleUBRSTargetingPostFocus()
    local tName = UnitName("target")

    if ImTank() then
        Raid.GetTargetNotOnTank()
        return true
    elseif ImMeleeDPS() or ImRangedDPS() then
        for i = 1, 2 do
            if tName == "Spectral Assassin" and not Dead("target") then
                return true
            end

            TargetNearestEnemy()
        end

        GetTargetIfNone()
        return true
    end

    return false
end

-- [[ MAGIC ]] --

function MoronBox.Core.Raid.GetTarget()
    local tName = UnitName("target")

    if Instance.BWL() and Raid.IsAtRazorgore() and MB_myRazorgoreBoxStrategy then
        if myName == ReturnPlayerInRaidFromTable(MB_myRazorgoreORBtank) and not
            Raid.TankTarget("Razorgore the Untamed") then
            Spells.OrbControlling()
            return
        end
    end

    if MB_myOTTarget then
        return
    end

    if Instance.NAXX() then
        if HandleNAXXTargetingPreFocus() then
            return
        end
    elseif Instance.AQ40() then
        if HandleAQ40TargetingPreFocus() then
            return
        end
    elseif Instance.BWL() and Raid.IsAtRazorgore() and MB_myRazorgoreBoxStrategy then
        if HandleBWLTargetingPreFocus() then
            return
        end
    end

    if ImFocus() then
        if tName and InCombat("target") then
            return
        end

        if not tName or UnitIsDead("target") or not UnitIsEnemy("player", "target") then
            TargetNearestEnemy()
        end
        return
    end

    if Instance.NAXX() then
        if HandleNAXXTargetingPostFocus() then
            return
        end
    elseif Instance.AQ40() then
        if HandleAQ40TargetingPostFocus() then
            return
        end
    elseif Instance.BWL() then
        if HandleBWLTargetingPostFocus() then
            return
        end
    elseif Instance.MC() then
        if HandleMCTargetingPostFocus() then
            return
        end
    elseif Instance.ONY() and Raid.TankTarget("Onyxia") and MB_myOnyxiaBoxStrategy then
        if HandleONYTargetingPostFocus() then
            return
        end
    elseif Instance.ZG() then
        if HandleZGTargetingPostFocus() then
            return
        end
    elseif Instance.AQ20() and Raid.TankTarget("Ayamiss the Hunter") and not Dead("target") then
        if HandleAQ20TargetingPostFocus() then
            return
        end
    elseif GetRealZoneText() == "Blackrock Spire" and Raid.TankTarget("Lord Valthalak") and not Dead("target") then
        if HandleUBRSTargetingPostFocus() then
            return
        end
    end

    local focId = GeneralState.MBID[MB_raidLeader]
    if not focId then
        Raid.AssistFocus()
    elseif UnitName(focId .. "target") then
        TargetUnit(focId .. "target")
    else
        if not UnitIsEnemy("player", "target") then
            TargetNearestEnemy()
        end
    end

    if ImTank() and not MB_myOTTarget then
        Raid.GetTargetNotOnTank()
        return
    end

    if not MB_myOTTarget then
        Raid.AssistFocus()
    end
end
