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

    getCrowdControl().CrowdControl()
end

function MoronBox.Core.CrowdControl.CrowdControl()
    if not MB_myCCTarget then
        getCrowdControl().CrowdControlFear()
        return false
    end

    if myClass == "Druid" and GetRaidTargetIndex("target") == MB_myCCTarget then
        if UnitName("target") == "Death Talon Wyrmkin" then
            CastSpellByName("Hibernate(Rank 1)")
            return true
        end
    end

    for _ = 1, 10 do
        if GetRaidTargetIndex("target") == MB_myCCTarget and not UnitIsDead("target") and not getAura().HasBuffOrDebuff(MB_myCCSpell[myClass], "target", "debuff") then
            getApi().CdPrint("CC spell is: " .. MB_myCCSpell[myClass])
            getApi().CdMessage(MB_myCCSpell[myClass] .. "ing " .. UnitName("target"))
            CastSpellByName(MB_myCCSpell[myClass])
            return true
        end

        if GetRaidTargetIndex("target") == MB_myCCTarget and not UnitIsDead("target") and getAura().HasBuffOrDebuff(MB_myCCSpell[myClass], "target", "debuff") then
            return false
        end

        if GetRaidTargetIndex("target") == MB_myCCTarget and UnitIsDead("target") then
            MB_myCCTarget = nil
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

    if IsAltKeyDown() and UnitCreatureType("target") == "Beast" then
        if not GetRaidTargetIndex("target") or GetRaidTargetIndex("target") == 0 then
            SetRaidTarget("target", MB_currentRaidTarget)
            if MB_currentRaidTarget == 8 then
                MB_currentRaidTarget = 1
            else
                MB_currentRaidTarget = MB_currentRaidTarget + 1
            end
        end

        local druids = getCoreState().DruidCasters
        local num_druids = getApi().TableLength(druids)

        if num_druids > 0 then
            getApi().SendAddonMessage(MB_RAID .. "_CC", druids[MB_currentCC.Druid])

            if MB_currentCC.Druid == num_druids then
                MB_currentCC.Druid = 1
                getApi().CdMessage("ALL DRUIDS ASSIGNED, STOP ASSIGNING MORE.")
            else
                MB_currentCC.Druid = MB_currentCC.Druid + 1
            end
        end
        return
    end

    if UnitCreatureType("target") == "Demon" or UnitCreatureType("target") == "Elemental" then
        if not GetRaidTargetIndex("target") or GetRaidTargetIndex("target") == 0 then
            SetRaidTarget("target", MB_currentRaidTarget)
            if MB_currentRaidTarget == 8 then
                MB_currentRaidTarget = 1
            else
                MB_currentRaidTarget = MB_currentRaidTarget + 1
            end
        end

        local locks = getCoreState().ClassList["Warlock"]
        local num_locks = getApi().TableLength(locks)

        if num_locks > 0 then
            getApi().SendAddonMessage(MB_RAID .. "_CC", locks[MB_currentCC.Warlock])

            if MB_currentCC.Warlock == num_locks then
                MB_currentCC.Warlock = 1
                getApi().CdMessage("ALL WARLOCKS ASSIGNED, STOP ASSIGNING MORE.")
            else
                MB_currentCC.Warlock = MB_currentCC.Warlock + 1
            end
        end
    elseif UnitCreatureType("target") == "Undead" then
        if not GetRaidTargetIndex("target") or GetRaidTargetIndex("target") == 0 then
            SetRaidTarget("target", MB_currentRaidTarget)
            if MB_currentRaidTarget == 8 then
                MB_currentRaidTarget = 1
            else
                MB_currentRaidTarget = MB_currentRaidTarget + 1
            end
        end

        local priests = getCoreState().ClassList["Priest"]
        local num_priests = getApi().TableLength(priests)

        if num_priests > 0 then
            getApi().SendAddonMessage(MB_RAID .. "_CC", priests[MB_currentCC.Priest])

            if MB_currentCC.Priest == num_priests then
                MB_currentCC.Priest = 1
                getApi().CdMessage("ALL PRIESTS ASSIGNED, STOP ASSIGNING MORE.")
            else
                MB_currentCC.Priest = MB_currentCC.Priest + 1
            end
        end
    elseif UnitCreatureType("target") == "Dragonkin" then
        if not GetRaidTargetIndex("target") or GetRaidTargetIndex("target") == 0 then
            SetRaidTarget("target", MB_currentRaidTarget)
            if MB_currentRaidTarget == 8 then
                MB_currentRaidTarget = 1
            else
                MB_currentRaidTarget = MB_currentRaidTarget + 1
            end
        end

        local druids = getCoreState().DruidCasters
        local num_druids = getApi().TableLength(druids)

        if num_druids > 0 then
            getApi().SendAddonMessage(MB_RAID .. "_CC", druids[MB_currentCC.Druid])

            if MB_currentCC.Druid == num_druids then
                MB_currentCC.Druid = 1
                getApi().CdMessage("ALL DRUIDS ASSIGNED, STOP ASSIGNING MORE.")
            else
                MB_currentCC.Druid = MB_currentCC.Druid + 1
            end
        end
    elseif nil or UnitCreatureType("target") == "Beast" or UnitCreatureType("target") == "Humanoid" or UnitCreatureType("target") == "Critter" then
        if not GetRaidTargetIndex("target") or GetRaidTargetIndex("target") == 0 then
            SetRaidTarget("target", MB_currentRaidTarget)
            if MB_currentRaidTarget == 8 then
                MB_currentRaidTarget = 1
            else
                MB_currentRaidTarget = MB_currentRaidTarget + 1
            end
        end

        local mages = getCoreState().ClassList["Mage"]
        local num_mages = getApi().TableLength(mages)

        if num_mages > 0 then
            getApi().SendAddonMessage(MB_RAID .. "_CC", mages[MB_currentCC.Mage])

            if MB_currentCC.Mage == num_mages then
                MB_currentCC.Mage = 1
                getApi().CdMessage("ALL MAGES ASSIGNED, STOP ASSIGNING MORE.")
            else
                MB_currentCC.Mage = MB_currentCC.Mage + 1
            end
        end
    end
end

function MoronBox.Core.CrowdControl.CrowdControlFear()
    if not MB_myFearTarget then
        return
    end

    for i = 1, 10 do
        if GetRaidTargetIndex("target") == MB_myFearTarget then
            if UnitIsDead("target") then
                MB_myFearTarget = nil
                TargetUnit("playertarget")
                return
            end

            local fearSpell = MB_myFearSpell[UnitClass("player")]
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
        SetRaidTarget("target", MB_currentRaidTarget)
        if MB_currentRaidTarget == 8 then
            MB_currentRaidTarget = 1
        else
            MB_currentRaidTarget = MB_currentRaidTarget + 1
        end
    end

    local locks = getCoreState().ClassList["Warlock"]
    local num_locks = getApi().TableLength(locks)

    if num_locks > 0 then
        getApi().SendAddonMessage(MB_RAID .. "_FEAR", locks[MB_currentFear.Warlock])

        if MB_currentFear.Warlock == num_locks then
            MB_currentFear.Warlock = 1
            getApi().CdMessage("ALL WARLOCKS ASSIGNED, STOP ASSIGNING MORE.")
        else
            MB_currentFear.Warlock = MB_currentFear.Warlock + 1
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
        SetRaidTarget("target", MB_currentRaidTarget)
        if MB_currentRaidTarget == 8 then
            MB_currentRaidTarget = 1
        else
            MB_currentRaidTarget = MB_currentRaidTarget + 1
        end
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
        SetRaidTarget("target", MB_currentRaidTarget)
        if MB_currentRaidTarget == 8 then
            MB_currentRaidTarget = 1
        else
            MB_currentRaidTarget = MB_currentRaidTarget + 1
        end
    end

    local shamans = getCoreState().ClassList["Shaman"]
    local num_shaman = getApi().TableLength(shamans)

    local rogues = getCoreState().ClassList["Rogue"]
    local num_rogues = getApi().TableLength(rogues)

    local mages = getCoreState().ClassList["Mage"]
    local num_mages = getApi().TableLength(mages)

    if (num_rogues + num_shaman + num_mages) == 0 then
        getApi().CdPrint("No interrupters available")
        return
    end

    if num_rogues > 0 then
        getApi().SendAddonMessage(MB_RAID .. "_INT", rogues[MB_currentInterrupt.Rogue])

        if MB_currentInterrupt.Rogue == num_rogues then
            MB_currentInterrupt.Rogue = 1
        else
            MB_currentInterrupt.Rogue = MB_currentInterrupt.Rogue + 1
        end
    end

    if num_shaman > 0 then
        getApi().SendAddonMessage(MB_RAID .. "_INT", shamans[MB_currentInterrupt.Shaman])

        if MB_currentInterrupt.Shaman == num_shaman then
            MB_currentInterrupt.Shaman = 1
        else
            MB_currentInterrupt.Shaman = MB_currentInterrupt.Shaman + 1
        end
    end

    if num_shaman == 0 and num_rogues == 0 then
        if num_mages > 0 then
            getApi().SendAddonMessage(MB_RAID .. "_INT", mages[MB_currentInterrupt.Mage])

            if MB_currentInterrupt.Mage == num_mages then
                MB_currentInterrupt.Mage = 1
            else
                MB_currentInterrupt.Mage = MB_currentInterrupt.Mage + 1
            end
        end
    end
end
