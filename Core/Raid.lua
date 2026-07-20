-- [[ Config & Constants ]] --

MoronBox.Core = MoronBox.Core or {}

local myClass = UnitClass("player")
local myName = UnitName("player")

local MB_targetNearestDistanceChanged = nil

function getRaid()
    return MoronBox.Core.Raid
end

-- [[ Focus | Assist ]] --

function MoronBox.Core.Raid.ImFocus()
    return getConfigState().RaidLeader == myName
end

function MoronBox.Core.Raid.AssistFocus()
    local raidInviter = getSettingsState().RaidInviter
    if not getConfigState().RaidLeader and myName ~= raidInviter then
        AssistByName(raidInviter)
        RunLine("/w " .. raidInviter .. " Press setFOCUS!")
        return false
    end

    if getRaid().ImFocus() then
        return true
    end

    local assistUnit = getUnit().GetUnitForPlayerName(getConfigState().RaidLeader)
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
    if not getConfigState().RaidLeader then
        return false
    end

    local raidLeaderId = getCoreState().MBID[getConfigState().RaidLeader]
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
    if not getConfigState().InterruptTarget then
        getRaid().AssistFocus()
        return
    end

    for i = 1, 6 do
        local targetIndex = GetRaidTargetIndex("target")

        if targetIndex == getConfigState().InterruptTarget then
            if not getUnit().IsDead("target") then
                return
            end

            TargetNearestEnemy()
        end

        TargetNearestEnemy()
    end
end

-- [[ Raid Targetting ]] --

function MoronBox.Core.Raid.TankTarget(mobName)
    if not getConfigState().RaidLeader then
        return false
    end

    local focusId = getCoreState().MBID[getConfigState().RaidLeader]
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
    local focusId = getCoreState().MBID[getConfigState().RaidLeader]
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
    if not getConfigState().RaidLeader then
        return nil
    end

    local focusId = getCoreState().MBID[getConfigState().RaidLeader]
    if not focusId then
        return nil
    end

    local targetId = focusId .. "target"
    if not UnitExists(targetId) then
        return nil
    end

    if getUnit().IsDead(targetId) then
        return 0
    end

    return getUnit().HealthPct(targetId)
end

function MoronBox.Core.Raid.TargetHealthFromRaidleader(mobName, percentage)
    local focusId = getCoreState().MBID[getConfigState().RaidLeader]
    if not focusId then
        return false
    end

    local isTargetingMob = getRaid().TankTarget(mobName)
    if not isTargetingMob then
        return false
    end

    local targetHealthPercentage = getUnit().HealthPct(focusId .. "target")
    return (targetHealthPercentage <= percentage)
end

function MoronBox.Core.Raid.TargetFromSpecificPlayer(targetName, playerName)
    local playerId = getCoreState().MBID[playerName]
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
    local playerId = getCoreState().MBID[playerName]
    if not playerId then
        return false
    end

    if not getRaid().TargetFromSpecificPlayer(targetName, playerName) then
        return false
    end

    AssistUnit(playerId)
    return true
end

function MoronBox.Core.Raid.AssistSpecificTargetFromPlayerInMeleeRange(targetName, playerName)
    local playerId = getCoreState().MBID[playerName]
    if not playerId then
        return false
    end

    if not getRaid().TargetFromSpecificPlayer(targetName, playerName) then
        return false
    end

    if not getUnit().InMeleeRange(playerId .. "target") then
        return false
    end

    AssistUnit(playerId)
    return true
end

function MoronBox.Core.Raid.LockOnTarget(target)
    for i = 1, 3 do
        if UnitName("target") == target and not getUnit().IsDead("target") then
            return true
        end

        TargetByName(target)
    end
    return false
end

function MoronBox.Core.Raid.FixateOnTarget(target)
    return UnitName("target") == target and not getUnit().IsDead("target")
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
        if getRaid().TankTarget(name) then
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
        if getRaid().TankTarget(name) then
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
        if getRaid().TankTarget(name) then
            return true
        end
    end

    local targetName = UnitName("target")
    return targetName ~= nil and MonstrosityTargets[targetName] == true
end

local function IsOrbControlled()
    for i = 1, GetNumRaidMembers() do
        if getAura().HasBuffOrDebuff("Mind Exhaustion", "raid" .. i, "debuff") then
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
        if getRaid().TankTarget(name) then
            return true
        end
    end

    local leftTank = getRaid().ReturnPlayerInRaidFromTable(getEncountersState().Razorgore.LeftMainTank)
    local rightTank = getRaid().ReturnPlayerInRaidFromTable(getEncountersState().Razorgore.RightMainTank)

    for name in pairs(RazorgoreTargets) do
        if getRaid().TargetFromSpecificPlayer(name, leftTank) or getRaid().TargetFromSpecificPlayer(name, rightTank) then
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
        if getRaid().TankTarget(name) then
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
        if getRaid().TankTarget(name) then
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
        if getRaid().TankTarget(name) then
            return true
        end
    end

    local targetName = UnitName("target")
    return targetName ~= nil and TwinsEmpsTargets[targetName] == true
end

-- [[ Off Tanking ]] --

function MoronBox.Core.Raid.OffTank()
    if not getConfigState().OffTankTarget then
        return
    end

    if UnitExists("target") and GetRaidTargetIndex("target") == getConfigState().OffTankTarget then
        if getUnit().IsDead("target") then
            getConfigState().OffTankTarget = nil
            TargetUnit("playertarget")
            return
        end

        MoronBox.Api.CdPrint("Locked On Target")
        return
    end

    for i = 1, 6 do
        if UnitExists("target") and GetRaidTargetIndex("target") == getConfigState().OffTankTarget
            and not getUnit().IsDead("target") and not getUnit().InCombat("target") then
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
    if getUnit().IsDead() then
        return
    end

    local targetName = UnitName("target")
    if targetName and IgnoredTargets[targetName] then
        return
    end

    if getUnit().IsNotValidTankableTarget() then
        TargetNearestEnemy()
    end

    local targetTarget = UnitName("targettarget")

    -- Initial validation
    if UnitIsEnemy("target", "player") and getUnit().InCombat("target")
        and not getApi().FindInTable(getCoreState().RaidTanks, targetTarget) then
        return
    end

    -- Scan for targets
    for i = 0, 8 do
        if not UnitName("target") then
            TargetNearestEnemy()
        end

        if UnitIsEnemy("target", "player") and getUnit().InCombat("target")
            and not getApi().FindInTable(getCoreState().RaidTanks, targetTarget) then
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
    if not getRaid().ImFocus() then
        return
    end

    local targetName = UnitName("target")
    if not IsMoamOrManaFiend(targetName) then
        return
    end

    for i = 1, 5 do
        if UnitName("target") == "Mana Fiend" and not GetRaidTargetIndex("target")
            and not getUnit().IsDead("target") then
            getCrowdControl().AssignCrowdControl()
            return
        end

        TargetNearestEnemy()
    end

    if not moamDead then
        TargetByName("Moam")
    end

    if getUnit().IsDead("target") and UnitName("target") == "Moam" then
        moamDead = true
    end
end

-- [[ Make A Line ]] --

function MoronBox.Core.Raid.MakeALine()
    if not UnitInRaid("player") then
        print("MakeALine only works in raid")
        return
    end

    local headOfLine = getRaid().ImFocus() and myName or getUnit().GetTankName()
    local followList = {}
    local groups = {}

    for g = 1, 8 do
        groups[g] = {}
    end

    for i = 1, GetNumRaidMembers() do
        local name, _, group = GetRaidRosterInfo(i)
        if name then
            table.insert(groups[group], name)
        end
    end

    for g = 1, 8 do
        table.sort(groups[g])
    end

    for g = 1, 8 do
        local groupSize = table.getn(groups[g])
        for i = 1, groupSize do
            local member = groups[g][i]
            if g == 1 and i == 1 then
                table.insert(followList, headOfLine)
                if member ~= headOfLine then
                    table.insert(followList, member)
                end
            elseif member ~= headOfLine then
                table.insert(followList, member)
            end
        end
    end

    if not IsShiftKeyDown() then
        local mySpot = 0
        for i = 1, table.getn(followList) do
            if followList[i] == myName then
                mySpot = i
                break
            end
        end

        if mySpot and mySpot > 1 then
            FollowByName(followList[mySpot - 1], 1)
        end
    else
        for g = 1, 8 do
            local groupSize = table.getn(groups[g])
            for i = 1, groupSize do
                if myName == groups[g][i] and i > 1 then
                    FollowByName(groups[g][1], 1)
                end
            end
        end
    end
end

-- [[ Anub Warning ]] --

local AubAlertCD = GetTime()

function MoronBox.Core.Raid.AnubisathAlert()
    if getRaid().ImFocus() or UnitName("target") ~= "Anubisath Sentinel" then
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
        if getAura().HasBuffOrDebuff(buff, "target", "buff") then
            AubAlertCD = now
            MoronBox.Api.CdSay(message)
            break
        end
    end
end

-- [[ Hakker & Nefarian MC ]] --

local function CastPolymorph(unitId)
    TargetUnit(unitId)

    if not getSpellsState().IsCastingMyCCSpell then
        SpellStopCasting()
    end

    CastSpellByName("Polymorph")
end

function MoronBox.Core.Raid.CrowdControlMCedRaidMember(debuffName, message)
    if getUnit().IsDead() then
        return false
    end

    for i = 1, GetNumRaidMembers() do
        local unitId = "raid" .. i
        if UnitName(unitId) and getUnit().IsAlive(unitId) and getUnit().In28YardRange(unitId) then
            if getAura().HasBuffOrDebuff(debuffName, unitId, "debuff")
                and not getAura().HasBuffOrDebuff("Polymorph", unitId, "debuff") then
                CastPolymorph(unitId)

                if message then
                    getApi().CdMessage(message .. " " .. UnitName(unitId), 30)
                end

                return true
            end
        end
    end
    return false
end

function MoronBox.Core.Raid.CrowdControlMCedRaidMemberHakkar()
    return getRaid().CrowdControlMCedRaidMember("Mind Control", "Sheeping")
end

function MoronBox.Core.Raid.CrowdControlMCedRaidMemberNefarian()
    return getRaid().CrowdControlMCedRaidMember("Shadow Command", "Sheeping")
end

-- [[ Locations ]] --

function MoronBox.Core.Raid.IsAtRazorgore()
    return GetSubZoneText() == "Dragonmaw Garrison"
end

-- [[ GTFO ]] --

function MoronBox.Core.Raid.GTFO()
    if not getSettingsState().GTFO.Active then
        return
    end

    getCons().SandsOnChromaggus()

    if getRaid().ImFocus() then
        return
    end

    if Instance.ONY() and getEncountersState().Onyxia.Active then
        if getRaid().TankTarget("Onyxia") and (getRaid().TankTargetHealth() <= 0.65 and getRaid().TankTargetHealth() >= 0.4) and myName ~= getEncountersState().Onyxia.MainTank then
            if getRaid().FocusAggro() then
                if myClass == "Paladin" and getSpells().IsSpellReady("Divine Shield") then
                    CastSpellByName("Divine Shield")
                    return
                end

                local runTank = getUnit().ReturnPlayerInRaidFromTable(getSettingsState().GTFO.Onyxia)
                local runTankId = getCoreState().MBID[runTank]

                if runTank and getUnit().IsAlive(runTankId) then
                    FollowByName(runTank, 1)
                end
            else
                local mainTankId = getCoreState().MBID[getEncountersState().Onyxia.FollowTarget]

                if mainTankId and getUnit().InRange(mainTankId) then
                    if not getUnit().InMeleeRange(mainTankId) then
                        FollowByName(getEncountersState().Onyxia.FollowTarget, 1)
                    end
                end
            end
        end
    end

    if not getUnit().AggroOnPlayer() then
        if Instance.NAXX() then
            GLUTH_GetOUT()
            GROB_GetOUT()
            getCons().FirePotsOnFaerlina()
        elseif Instance.BWL() and getAura().HasBuffOrDebuff("Burning Adrenaline", "player", "debuff") then
            if myClass == "Paladin" and getSpells().IsSpellReady("Divine Shield") then
                CastSpellByName("Divine Shield")
                return
            end

            local vaelTank = getUnit().ReturnPlayerInRaidFromTable(getSettingsState().GTFO.Vaelastrasz)
            local vaelTankId = getCoreState().MBID[vaelTank]

            if vaelTank and getUnit().IsAlive(vaelTankId) then
                FollowByName(vaelTank, 1)
            end
        elseif Instance.MC() and getAura().HasBuffOrDebuff("Living Bomb", "player", "debuff") then
            if myClass == "Paladin" and getSpells().IsSpellReady("Divine Shield") then
                CastSpellByName("Divine Shield")
                return
            end

            local baronTank = getUnit().ReturnPlayerInRaidFromTable(getSettingsState().GTFO.Baron)
            local baronTankId = getCoreState().MBID[baronTank]

            if baronTank and getUnit().IsAlive(baronTankId) then
                FollowByName(baronTank, 1)
            end
        end
    end
end

-- [[ Get Target ]] --

local function GetTargetIfNone()
    if not UnitName("target") or getUnit().IsDead("target") then
        getRaid().AssistFocus()
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

    if myName == getUnit().ReturnPlayerInRaidFromTable(getEncountersState().Razorgore.ORBtank) then
        return true
    end

    if not getRaid().IsAtRazorgorePhase() then
        return false
    end

    if (myName == getUnit().ReturnPlayerInRaidFromTable(getEncountersState().Razorgore.LeftMainTank)
            or myName == getUnit().ReturnPlayerInRaidFromTable(getEncountersState().Razorgore.RightMainTank)) and getConfigState().RaidLeader ~= myName then
        getConfigState().RaidLeader = myName
    end

    if not getRaid().ImFocus() then
        return false
    end

    if (myName == getUnit().ReturnPlayerInRaidFromTable(getEncountersState().Razorgore.LeftMainTank) or myName == getUnit().ReturnPlayerInRaidFromTable(getEncountersState().Razorgore.RightMainTank)) then
        if not MB_targetNearestDistanceChanged then
            SetCVar("targetNearestDistance", "15")
            MB_targetNearestDistanceChanged = true
        end

        if getConfigState().RazorgoreNewTargetBecauseTargetIsBehind.Active then
            TargetNearestEnemy()
            getConfigState().RazorgoreNewTargetBecauseTargetIsBehind.Active = false
            return true
        end

        if (tName == nil or getUnit().IsDead("target")) then
            TargetNearestEnemy()
            return true
        end

        getApi().CdPrint("Focussing Attacks on " .. tName, 30)
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

    if (getRaid().TankTarget("Instructor Razuvious") and getApi().FindMyNameInTable(getEncountersState().Razuvious.MindControlPriests) and getEncountersState().Razuvious.Active) or
        (getRaid().TankTarget("Grand Widow Faerlina") and getApi().FindMyNameInTable(getEncountersState().Faerlina.MindControlPriests) and getEncountersState().Faerlina.Active) then
        return true
    elseif getRaid().TankTarget("Anub\'Rekhan") then
        if getCore().ImTank() then
            getRaid().GetTargetNotOnTank()
            return true
        elseif getCore().ImMeleeDPS() or getCore().ImRangedDPS() then
            for i = 1, 2 do
                if tName == "Crypt Guard" and not getUnit().IsDead("target") then
                    return true
                end

                TargetNearestEnemy()
            end

            GetTargetIfNone()
            return true
        end
    elseif getRaid().IsAtMonstrosity() then
        if getCore().ImTank() then
            getRaid().GetTargetNotOnTank()
            return true
        elseif getCore().ImMeleeDPS() or getCore().ImRangedDPS() then
            if getRaid().LockOnTarget("Lightning Totem") then
                return true
            end

            GetTargetIfNone()
            return true
        end
    elseif getRaid().TankTarget("Plague Beast") then
        if getCore().ImTank() then
            getRaid().GetTargetNotOnTank()
            return true
        elseif getCore().ImMeleeDPS() then
            if getConfigState().TargetWrongWayOrTooFar.Active then
                TargetNearestEnemy()
                getConfigState().TargetWrongWayOrTooFar.Active = false
                return true
            end

            for i = 1, 4 do
                if tName == "Mutated Grub" and not getUnit().IsDead("target") then
                    return true
                end

                if tName == "Plagued Bat" and not getUnit().IsDead("target") then
                    return true
                end

                TargetNearestEnemy()
            end

            GetTargetIfNone()
            return true
        elseif getCore().ImRangedDPS() then
            getRaid().AssistFocus()
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

    if getRaid().TankTarget("Anubisath Defender") then
        if getCore().ImTank() then
            getRaid().GetTargetNotOnTank()
            return true
        end

        for i = 1, 4 do
            if tName == "Anubisath Swarmguard" and not getUnit().IsDead("target") then
                return true
            end

            if tName == "Anubisath Warrior" and not getUnit().IsDead("target") then
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

    if getRaid().IsAtRazorgore() and getEncountersState().Razorgore.Active then
        if myName == getUnit().ReturnPlayerInRaidFromTable(getEncountersState().Razorgore.ORBtank) then
            return true
        end

        if not getRaid().IsAtRazorgorePhase() then
            return false
        end

        if (myName == getUnit().ReturnPlayerInRaidFromTable(getEncountersState().Razorgore.LeftMainTank) or myName == getUnit().ReturnPlayerInRaidFromTable(getEncountersState().Razorgore.RightMainTank)) then
            if not MB_targetNearestDistanceChanged then
                SetCVar("targetNearestDistance", "15")
                MB_targetNearestDistanceChanged = true
            end

            if getConfigState().RazorgoreNewTargetBecauseTargetIsBehind.Active then
                TargetNearestEnemy()
                getConfigState().RazorgoreNewTargetBecauseTargetIsBehind.Active = false
                return true
            end

            if (tName == nil or getUnit().IsDead("target")) then
                TargetNearestEnemy()
                return true
            end

            return true
        elseif getCore().ImTank() then
            if not MB_targetNearestDistanceChanged then
                SetCVar("targetNearestDistance", "10")
                MB_targetNearestDistanceChanged = true
            end

            if getConfigState().RazorgoreNewTargetBecauseTargetIsBehind.Active then
                TargetNearestEnemy()
                getConfigState().RazorgoreNewTargetBecauseTargetIsBehind.Active = false
                return true
            end

            getRaid().GetTargetNotOnTank()
            return true
        elseif getCore().ImMeleeDPS() then
            if getApi().FindMyNameInTable(getEncountersState().Razorgore.LeftSideDPSERS) then
                local leftTank = getUnit().ReturnPlayerInRaidFromTable(getEncountersState().Razorgore.LeftMainTank)
                if leftTank then
                    AssistByName(leftTank)
                end
                return true
            end
            if getApi().FindMyNameInTable(getEncountersState().Razorgore.RightSideDPSERS) then
                local rightTank = getUnit().ReturnPlayerInRaidFromTable(getEncountersState().Razorgore.RightMainTank)
                if rightTank then
                    AssistByName(rightTank)
                end
                return true
            end

            return true
        elseif getCore().ImRangedDPS() then
            if getConfigState().RazorgoreNewTargetBecauseTargetIsBehind.Active then
                TargetNearestEnemy()
                getConfigState().RazorgoreNewTargetBecauseTargetIsBehind.Active = false
                return true
            end

            if not getUnit().IsDead("target") then
                return true
            end

            local tankOno = getUnit().ReturnPlayerInRaidFromTable(getEncountersState().Razorgore.RightMainTank)
            local tankTwo = getUnit().ReturnPlayerInRaidFromTable(getEncountersState().Razorgore.LeftMainTank)

            if getRaid().AssistSpecificTargetFromPlayer("Blackwing Mage", tankOno) then
                return true
            end

            if getRaid().AssistSpecificTargetFromPlayer("Blackwing Mage", tankTwo) then
                return true
            end

            if getRaid().AssistSpecificTargetFromPlayer("Blackwing Legionnaire", tankOno) then
                return true
            end

            if getRaid().AssistSpecificTargetFromPlayer("Blackwing Legionnaire", tankTwo) then
                return true
            end

            if getRaid().AssistSpecificTargetFromPlayer("Death Talon Dragonspawn", tankOno) then
                return true
            end

            if getRaid().AssistSpecificTargetFromPlayer("Death Talon Dragonspawn", tankTwo) then
                return true
            end

            GetTargetIfNone()
            return true
        end

        return true
    elseif GetSubZoneText() == "Shadow Wing Lair" then
        if getConfigState().RaidLeader and getUnit().Dead(getCoreState().MBID[getConfigState().RaidLeader]) then
            getRaid().LockOnTarget("Vaelastrasz the Corrupt")
            return true
        end
    end

    return false
end

local function HandleMCTargetingPostFocus()
    if getBosses().Lucifron.TargetingPostFocus() then
        return true
    end

    if getBosses().Magmadar.TargetingPostFocus()() then
        return true
    end

    if getBosses().Gehennas.TargetingPostFocus()() then
        return true
    end

    if getBosses().Garr.TargetingPostFocus() then
        return true
    end

    if getBosses().Shazzrah.TargetingPostFocus() then
        return true
    end

    if getBosses().Geddon.TargetingPostFocus() then
        return true
    end

    if getBosses().Golemagg.TargetingPostFocus() then
        return true
    end

    if getBosses().Sulfuron.TargetingPostFocus() then
        return true
    end

    if getBosses().Majordomo.TargetingPostFocus() then
        return true
    end

    if getBosses().Ragnaros.TargetingPostFocus() then
        return true
    end

    return false
end

local function HandleONYTargetingPostFocus()
    local tName = UnitName("target")

    if getCore().ImTank() then
        getRaid().GetTargetNotOnTank()
        return true
    elseif getCore().ImMeleeDPS() then
        if getConfigState().TargetWrongWayOrTooFar.Active then
            TargetNearestEnemy()
            getConfigState().TargetWrongWayOrTooFar.Active = false
            return true
        end

        for i = 1, 2 do
            if tName == "Onyxian Whelp" and not getUnit().IsDead("target") then
                return true
            end

            TargetNearestEnemy()
        end

        GetTargetIfNone()
        return true
    elseif getCore().ImRangedDPS() then
        if getRaid().AssistSpecificTargetFromPlayer("Onyxia", getEncountersState().Onyxia.MainTank) then
            return true
        end

        GetTargetIfNone()
        return true
    end

    return false
end

local function HandleZGTargetingPostFocus()
    local tName = UnitName("target")

    if getRaid().IsAtJindo() then
        if getCore().ImTank() then
            getRaid().GetTargetNotOnTank()
            return true
        elseif getCore().ImMeleeDPS() then
            for i = 1, 2 do
                if tName == "Shade of Jin\'do" and not getUnit().IsDead("target") then
                    return true
                end

                TargetNearestEnemy()
            end

            GetTargetIfNone()
            return true
        elseif getCore().ImRangedDPS() then
            for i = 1, 6 do
                if tName == "Shade of Jin\'do" and not getUnit().IsDead("target") then
                    return true
                end

                if tName == "Powerful Healing Ward" and not getUnit().IsDead("target") then
                    return true
                end

                if tName == "Brain Wash Totem" and not getUnit().IsDead("target") then
                    return true
                end

                TargetNearestEnemy()
            end

            GetTargetIfNone()
            return true
        end
    elseif getRaid().TankTarget("High Priestess Mar\'li") then
        if getCore().ImTank() then
            getRaid().GetTargetNotOnTank()
            return true
        elseif getCore().ImMeleeDPS() then
            getRaid().AssistFocus()
            return true
        elseif getCore().ImRangedDPS() then
            for i = 1, 4 do
                if tName == "Spawn of Mar\'li" and not getUnit().IsDead("target") then
                    return true
                end

                if tName == "Witherbark Speaker" and not getUnit().IsDead("target") then
                    return true
                end

                TargetNearestEnemy()
            end

            GetTargetIfNone()
            return true
        end
    elseif getRaid().TankTarget("High Priestess Jeklik") then
        if getCore().ImTank() then
            getRaid().GetTargetNotOnTank()
            return true
        elseif getCore().ImRangedDPS() then
            for i = 1, 2 do
                if tName == "Bloodseeker Bat" and getUnit().InCombat("target") and not getUnit().IsDead("target") then
                    return true
                end

                TargetNearestEnemy()
            end

            GetTargetIfNone()
            return true
        end
    elseif getRaid().TankTarget("High Priest Venoxis") then
        if getCore().ImTank() then
            getRaid().GetTargetNotOnTank()
            return true
        elseif getCore().ImMeleeDPS() or getCore().ImRangedDPS() then
            for i = 1, 2 do
                if tName == "Razzashi Cobra" and not getUnit().IsDead("target")
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

    if getCore().ImTank() then
        getRaid().GetTargetNotOnTank()
        return true
    elseif getCore().ImMeleeDPS() or getCore().ImRangedDPS() then
        for i = 1, 2 do
            if tName == "Hive\'Zara Larva" and not getUnit().IsDead("target") then
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

    if getCore().ImTank() then
        getRaid().GetTargetNotOnTank()
        return true
    elseif getCore().ImMeleeDPS() or getCore().ImRangedDPS() then
        for i = 1, 2 do
            if tName == "Spectral Assassin" and not getUnit().IsDead("target") then
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

    if Instance.BWL() and getRaid().IsAtRazorgore() and getEncountersState().Razorgore.Active then
        if myName == getUnit().ReturnPlayerInRaidFromTable(getEncountersState().Razorgore.ORBtank) and not
            getRaid().TankTarget("Razorgore the Untamed") then
            getSpells().OrbControlling()
            return
        end
    end

    if getConfigState().OffTankTarget then
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
    elseif Instance.MC() then
        if HandleMCTargetingPostFocus() then
            return
        end
    elseif Instance.BWL() and getRaid().IsAtRazorgore() and getEncountersState().Razorgore.Active then
        if HandleBWLTargetingPreFocus() then
            return
        end
    end

    if getRaid().ImFocus() then
        if tName and getUnit().InCombat("target") then
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
    elseif Instance.ONY() and getRaid().TankTarget("Onyxia") and getEncountersState().Onyxia.Active then
        if HandleONYTargetingPostFocus() then
            return
        end
    elseif Instance.ZG() then
        if HandleZGTargetingPostFocus() then
            return
        end
    elseif Instance.AQ20() and getRaid().TankTarget("Ayamiss the Hunter") and not getUnit().IsDead("target") then
        if HandleAQ20TargetingPostFocus() then
            return
        end
    elseif GetRealZoneText() == "Blackrock Spire" and getRaid().TankTarget("Lord Valthalak") and not getUnit().IsDead("target") then
        if HandleUBRSTargetingPostFocus() then
            return
        end
    end

    local focId = getCoreState().MBID[getConfigState().RaidLeader]
    if not focId then
        getRaid().AssistFocus()
    elseif UnitName(focId .. "target") then
        TargetUnit(focId .. "target")
    else
        if not UnitIsEnemy("player", "target") then
            TargetNearestEnemy()
        end
    end

    if getCore().ImTank() and not getConfigState().OffTankTarget then
        getRaid().GetTargetNotOnTank()
        return
    end

    if not getConfigState().OffTankTarget then
        getRaid().AssistFocus()
    end
end
