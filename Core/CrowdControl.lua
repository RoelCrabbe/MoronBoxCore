-- [[ Config & Constants ]] --

MoronBox.Core.CrowdControl = MoronBox.Core.CrowdControl or {}

local myClass = UnitClass("player")

function getCrowdControl()
    return MoronBox.Core.CrowdControl
end

-- [[ CrowdControl ]] --

function MoronBox.Core.CrowdControl.CrowdControlAsPull()
    if IsAltKeyDown() then
        getHealing().PowerShieldTanks()
        return
    end

    if IsShiftKeyDown() then
        if getSpells().IsSpellReady("Power Word: Shield") then
            getHealing().CastShieldOnRandomRaidMember("Weakened Soul", "rank 10")
        end
        return
    end

    getCrowdControl().CastCrowdControl()
end

function MoronBox.Core.CrowdControl.CastCrowdControl()
    if not getConfigState().CrowdControlTarget then
        getCrowdControl().CrowdControlFear()
        return false
    end

    if myClass == "Druid" and GetRaidTargetIndex("target") == getConfigState().CrowdControlTarget then
        if UnitName("target") == "Death Talon Wyrmkin" then
            CastSpellByName("Hibernate(Rank 1)")
            return true
        end
    end

    for _ = 1, 10 do
        if GetRaidTargetIndex("target") == getConfigState().CrowdControlTarget and not UnitIsDead("target") and not getAura().HasBuffOrDebuff(getConfigState().CrowdControlSpell[myClass], "target", "debuff") then
            getApi().CdPrint("CC spell is: " .. getConfigState().CrowdControlSpell[myClass])
            getApi().CdMessage(getConfigState().CrowdControlSpell[myClass] .. "ing " .. UnitName("target"))
            CastSpellByName(getConfigState().CrowdControlSpell[myClass])
            return true
        end

        if GetRaidTargetIndex("target") == getConfigState().CrowdControlTarget and not UnitIsDead("target") and getAura().HasBuffOrDebuff(getConfigState().CrowdControlSpell[myClass], "target", "debuff") then
            return false
        end

        if GetRaidTargetIndex("target") == getConfigState().CrowdControlTarget and UnitIsDead("target") then
            getConfigState().CrowdControlTarget = nil
            return false
        end

        TargetNearestEnemy()
    end
    return false
end

function MoronBox.Core.CrowdControl.AssignCrowdControl()
    if not getRaid().ImFocus() then
        return
    end

    if IsShiftKeyDown() then
        getCrowdControl().AssignFear()
        return
    end

    local function AssignCC(className)
        local state = getConfigState()

        if not GetRaidTargetIndex("target") or GetRaidTargetIndex("target") == 0 then
            state:TargetMarkCycle()
            SetRaidTarget("target", state.CurrentRaidTarget)
        end

        local list = getCoreState().ClassList[className]
        local num = getApi().TableLength(list)

        if num > 0 then
            getApi().SendAddonMessage(MB_RAID .. "_CC", list[state.CurrentCC[className]])

            if state:CycleCC(className, num) then
                getApi().CdMessage("ALL " .. string.upper(className) .. "S ASSIGNED, STOP ASSIGNING MORE.")
            end
        end
    end

    local cType = UnitCreatureType("target")

    if IsAltKeyDown() and cType == "Beast" then
        AssignCC("Druid")
    elseif cType == "Demon" or cType == "Elemental" then
        AssignCC("Warlock")
    elseif cType == "Undead" then
        AssignCC("Priest")
    elseif cType == "Dragonkin" then
        AssignCC("Druid")
    elseif cType == "Beast" or cType == "Humanoid" or cType == "Critter" or not cType then
        AssignCC("Mage")
    end
end

function MoronBox.Core.CrowdControl.CrowdControlFear()
    if not getConfigState().FearTarget then
        return
    end

    for i = 1, 10 do
        if GetRaidTargetIndex("target") == getConfigState().FearTarget then
            if UnitIsDead("target") then
                getConfigState().FearTarget = nil
                TargetUnit("playertarget")
                return
            end

            local fearSpell = getConfigState().FearSpell[myClass]
            if UnitName("target") and not getAura().HasBuffOrDebuff(fearSpell, "target", "debuff") then
                print("CC spell is : " .. fearSpell)
                getApi().CdMessage("Fearing " .. UnitName("target"))
                CastSpellByName(fearSpell)
                TargetUnit("playertarget")
                return
            end
        end

        TargetNearestEnemy()
    end
end

function MoronBox.Core.CrowdControl.AssignFear()
    if not getRaid().ImFocus() then
        return
    end

    if not GetRaidTargetIndex("target") or GetRaidTargetIndex("target") == 0 then
        getConfigState():TargetMarkCycle()
        SetRaidTarget("target", getConfigState().CurrentRaidTarget)
    end

    local className = "Warlock"
    local locks = getCoreState().ClassList[className]
    local num_locks = getApi().TableLength(locks)

    if num_locks > 0 then
        getApi().SendAddonMessage(MB_RAID .. "_FEAR", locks[getConfigState().CurrentFear[className]])

        if getConfigState():CycleFear(className, num_locks) then
            getApi().CdMessage("ALL " .. string.upper(className) .. "S ASSIGNED, STOP ASSIGNING MORE.")
        end
    end
end

function MoronBox.Core.CrowdControl.AssignOffTank()
    if IsShiftKeyDown() then
        getCrowdControl().AssignInterrupt()
        return
    end

    local tanks = getCoreState().AssignableTanks
    local num_tanks = getApi().TableLength(tanks)

    if not getRaid().ImFocus() or num_tanks == 0 then
        return
    end

    if not GetRaidTargetIndex("target") or GetRaidTargetIndex("target") == 0 then
        getConfigState():TargetMarkCycle()
        SetRaidTarget("target", getConfigState().CurrentRaidTarget)
    end

    local thisOffTank
    if IsShiftKeyDown() then
        local temp = getApi().DecrementIndex(MB_Ot_Index, num_tanks)
        thisOffTank = tanks[temp]
    else
        thisOffTank = tanks[MB_Ot_Index]
    end

    getApi().SendAddonMessage(MB_RAID .. "_OT", thisOffTank)

    if not IsShiftKeyDown() then
        MB_Ot_Index = getApi().IncrementIndex(MB_Ot_Index, num_tanks)
    end
end

function MoronBox.Core.CrowdControl.AssignInterrupt()
    if not getRaid().ImFocus() then
        return
    end

    if not GetRaidTargetIndex("target") or GetRaidTargetIndex("target") == 0 then
        getConfigState():TargetMarkCycle()
        SetRaidTarget("target", getConfigState().CurrentRaidTarget)
    end

    local function AssignInt(className)
        local list = getCoreState().ClassList[className]
        local num = getApi().TableLength(list)

        if num > 0 then
            getApi().SendAddonMessage(MB_RAID .. "_INT", list[getConfigState().CurrentInterrupt[className]])
            getConfigState():CycleInterrupt(className, num)
        end
    end

    local hasRogue = getApi().TableLength(getCoreState().ClassList["Rogue"]) > 0
    local hasShaman = getApi().TableLength(getCoreState().ClassList["Shaman"]) > 0

    if hasRogue then
        AssignInt("Rogue")
    end

    if hasShaman then
        AssignInt("Shaman")
    end

    if not hasRogue and not hasShaman then
        AssignInt("Mage")
    end

    if (getApi().TableLength(getCoreState().ClassList["Rogue"]) +
            getApi().TableLength(getCoreState().ClassList["Shaman"]) +
            getApi().TableLength(getCoreState().ClassList["Mage"])) == 0 then
        getApi().CdPrint("No interrupters available")
    end
end
