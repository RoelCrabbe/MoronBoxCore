-- [[ Config & Constants ]] --

MoronBox.Unit = MoronBox.Unit or {}

local myClass = UnitClass("player")
local myName = UnitName("player")

function getUnit()
    return MoronBox.Unit
end

-- [[ Unit ]] --

function MoronBox.Unit.GetTankName()
    if not getConfigState().RaidLeader then
        return nil
    end

    local focusId = getCoreState().MBID[getConfigState().RaidLeader]

    if focusId then
        return UnitName(focusId)
    else
        TargetByName(getConfigState().RaidLeader, 1)
        return "target"
    end
end

function MoronBox.Unit.PromoteEveryone()
    for toon in pairs(getCoreState().MBID) do
        PromoteToAssistant(toon)
    end
end

function MoronBox.Unit.DisbandRaid()
    if UnitInRaid("player") then
        for i = 1, 40 do
            local _, rank = GetRaidRosterInfo(i);
            if rank ~= 2 then
                UninviteFromParty("raid" .. i)
            end
        end
    else
        for i = 1, GetNumPartyMembers() do
            UninviteFromParty("party" .. i)
        end
    end

    LeaveParty()
end

function MoronBox.Unit.CrowdControlledMob()
    if (getAura().HasBuffOrDebuff("Shackle Undead", "target", "debuff")
            or getAura().HasBuffOrDebuff("Polymorph", "target", "debuff")
            or getAura().HasBuffOrDebuff("Banish", "target", "debuff")) then
        return true
    end
    return false
end

function MoronBox.Unit.InCombat(unitId)
    unitId = unitId or "player"
    return UnitAffectingCombat(unitId)
end

function MoronBox.Unit.HealthPct(unitId)
    unitId = unitId or "player"
    return UnitHealth(unitId) / UnitHealthMax(unitId)
end

function MoronBox.Unit.HealthDown(unitId)
    unitId = unitId or "player"
    return UnitHealthMax(unitId) - UnitHealth(unitId)
end

function MoronBox.Unit.IsManaUser(unitId)
    unitId = unitId or "player"
    return UnitPowerType(unitId) == 0
end

function MoronBox.Unit.ManaPct(unitId)
    unitId = unitId or "player"
    return UnitMana(unitId) / UnitManaMax(unitId)
end

function MoronBox.Unit.ManaDown(unitId)
    unitId = unitId or "player"
    if not getUnit().IsManaUser(unitId) then
        return 0
    end
    return UnitManaMax(unitId) - UnitMana(unitId)
end

function MoronBox.Unit.ManaOfUnit(unitId)
    unitId = unitId or "player"
    return UnitMana(unitId)
end

function MoronBox.Unit.IsDead(unitId)
    unitId = unitId or "player"
    return UnitIsDeadOrGhost(unitId) or not (UnitHealth(unitId) > 1)
end

function MoronBox.Unit.IsAlive(unitId)
    if not unitId then return false end
    if not UnitName(unitId) then return false end
    if UnitIsDead(unitId) then return false end
    if UnitHealth(unitId) <= 1 then return false end
    if UnitIsGhost(unitId) then return false end
    if not UnitIsConnected(unitId) then return false end
    return true
end

function MoronBox.Unit.ClearTargetIfNotAggroed()
    if not getUnit().InCombat("target") then
        ClearTarget()
    end
end

function MoronBox.Unit.IsInGroup(unitName)
    return getCoreState().GroupID[unitName] ~= nil and
        getCoreState().GroupID[unitName] == getCoreState().GroupID[myName]
end

function MoronBox.Unit.IsInRaid(unitName)
    return getCoreState().MBID[unitName] ~= nil
end

function MoronBox.Unit.AggroOnPlayer()
    return UnitName("targettarget") == myName
end

function MoronBox.Unit.InRaidOrParty(unitId)
    return UnitInRaid(unitId) or UnitInParty(unitId)
end

function MoronBox.Unit.InMeleeRange(unitId)
    unitId = unitId or "target"
    return CheckInteractDistance(unitId, 3)
end

function MoronBox.Unit.InRange(unitId)
    return CheckInteractDistance(unitId, 4)
end

function MoronBox.Unit.InTradeRange(unitId)
    if not unitId then return end
    return CheckInteractDistance(unitId, 2)
end

function MoronBox.Unit.In28YardRange(unitId)
    if not unitId then return end
    return getUnit().InRange(unitId)
end

function MoronBox.Unit.GetNumPartyOrRaidMembers()
    if UnitInRaid("player") then
        return GetNumRaidMembers()
    end
    return GetNumPartyMembers()
end

function MoronBox.Unit.IsValidFriendlyTargetWithin28YardRange(unitId)
    return UnitExists(unitId) and
        getUnit().IsAlive(unitId) and
        UnitIsVisible(unitId) and
        getUnit().In28YardRange(unitId)
end

function MoronBox.Unit.IsValidEnemyTargetWithin28YardRange(unitId)
    return UnitExists(unitId) and
        getUnit().InCombat(unitId) and
        getUnit().In28YardRange(unitId)
end

function MoronBox.Unit.IsValidFriendlyTarget(unitId, spellName)
    return UnitExists(unitId) and
        getUnit().IsAlive(unitId) and
        UnitIsVisible(unitId) and
        getUnit().CanHelpfulSpellBeCastOn(spellName, unitId)
end

function MoronBox.Unit.IsValidMeleeTarget(unitId)
    return UnitExists(unitId) and
        getUnit().IsAlive(unitId) and
        getUnit().InCombat(unitId) and
        getUnit().InMeleeRange()
end

function MoronBox.Unit.IsNotValidTankableTarget()
    return not UnitName("target") or
        not UnitAffectingCombat("target") or
        not CheckInteractDistance("target", 3) or
        not getUnit().IsDead("target") or
        getUnit().CrowdControlledMob()
end

function MoronBox.Unit.CanHelpfulSpellBeCastOn(spell, unitId)
    if getSettingsState().Use40yardHealingRangeOnInstants then
        local oldTarget = UnitName("target")
        if oldTarget then
            ClearTarget()
        end

        local can = false
        CastSpellByName(spell, nil)
        if SpellCanTargetUnit(unitId) then
            can = true
        end

        SpellStopTargeting()

        if oldTarget then
            TargetByName(oldTarget)
        end
        return can
    else
        return getUnit().In28YardRange(unitId)
    end
end

function MoronBox.Unit.GetUnitForPlayerName(playerName)
    local members = getUnit().GetNumPartyOrRaidMembers()

    for i = 1, members do
        local unitId = getUnit().GetUnitFromPartyOrRaidIndex(i)
        if UnitName(unitId) == playerName then
            return unitId
        end
    end

    if myName == playerName then
        return "player"
    end
    return nil
end

function MoronBox.Unit.GetRaidIndexForPlayerName(playerName)
    local members = GetNumRaidMembers()

    for i = 1, members do
        local unitId = getUnit().GetUnitFromPartyOrRaidIndex(i)
        if UnitName(unitId) == playerName then
            return i
        end
    end
    return nil
end

function MoronBox.Unit.GetUnitFromPartyOrRaidIndex(index)
    if index ~= 0 then
        if UnitInRaid("player") then
            return "raid" .. index
        else
            return "party" .. index
        end
    end
    return "player"
end

function MoronBox.Unit.ReturnPlayerInRaidFromTable(list)
    if not list then
        return nil
    end

    for _, name in ipairs(list) do
        if name and getCoreState().MBID[name] then
            return name
        end
    end

    return nil
end

function MoronBox.Unit.PartyMana()
    local mana = 0
    local maxMana = 0
    local manaPCT = 0
    local manaDown = 0

    local myGroup = getCoreState().GroupID[myName]
    if not myGroup then
        return manaPCT, manaDown, mana, maxMana
    end

    local groupMembers = getCoreState().ToonsInGroup[myGroup]
    if not groupMembers then
        return manaPCT, manaDown, mana, maxMana
    end

    for _, name in ipairs(groupMembers) do
        local memberId = getCoreState().MBID[name]
        if memberId and getUnit().IsAlive(memberId) and getUnit().ManaUser(memberId) then
            mana = mana + UnitMana(memberId)
            maxMana = maxMana + UnitManaMax(memberId)
        end
    end

    if maxMana > 0 then
        manaPCT = (mana / maxMana)
        manaDown = (maxMana - mana)
    end

    return manaPCT, manaDown, mana, maxMana
end

function MoronBox.Unit.PartyHealth()
    local health = 0
    local maxHealth = 0

    local myGroup = getCoreState().GroupID[myName]
    if not myGroup then
        return 0, 0
    end

    local groupMembers = getCoreState().ToonsInGroup[myGroup]
    if not groupMembers then
        return 0, 0
    end

    for _, name in ipairs(groupMembers) do
        local memberId = getCoreState().MBID[name]
        if memberId and getUnit().IsAlive(memberId) then
            health = health + UnitHealth(memberId)
            maxHealth = maxHealth + UnitHealthMax(memberId)
        end
    end

    if maxHealth > 0 then
        return (health / maxHealth), (maxHealth - health)
    end

    return 0, 0
end

function MoronBox.Unit.RaidHealth()
    if not UnitInRaid("player") then
        return getUnit().PartyHealth()
    end

    local health = 0
    local maxHealth = 0

    for _, id in pairs(getCoreState().MBID) do
        if id and getUnit().IsAlive(id) then
            health = health + UnitHealth(id)
            maxHealth = maxHealth + UnitHealthMax(id)
        end
    end

    if maxHealth > 0 then
        return (health / maxHealth), (maxHealth - health)
    end

    return 0, 0
end

function MoronBox.Unit.WarriorHealth()
    local health = 0
    local maxHealth = 0

    local warriorList = getCoreState().ClassList["Warrior"]
    if not warriorList then
        return 0, 0
    end

    for _, name in ipairs(warriorList) do
        local warriorId = getCoreState().MBID[name]

        if warriorId and getUnit().IsAlive(warriorId) then
            health = health + UnitHealth(warriorId)
            maxHealth = maxHealth + UnitHealthMax(warriorId)
        end
    end

    if maxHealth > 0 then
        return (health / maxHealth), (maxHealth - health)
    end

    return 0, 0
end

function MoronBox.Unit.IsBearForm()
    return getUnit().WarriorIsStance(1)
end

function MoronBox.Unit.IsSwimForm()
    return getUnit().WarriorIsStance(2)
end

function MoronBox.Unit.IsCatForm()
    return getUnit().WarriorIsStance(3)
end

function MoronBox.Unit.IsTravelForm()
    return getUnit().WarriorIsStance(4)
end

function MoronBox.Unit.IsBoomForm()
    return getUnit().WarriorIsStance(5)
end

function MoronBox.Unit.IsDruidShapeShifted()
    if myClass ~= "Druid" then
        return false
    end

    return getUnit().IsBearForm() or
        getUnit().IsSwimForm() or
        getUnit().IsCatForm() or
        getUnit().IsTravelForm() or
        getUnit().IsBoomForm()
end

function MoronBox.Unit.CancelDruidShapeShift()
    if getUnit().IsBearForm() then
        getUnit().WarriorSetStance(1)
    elseif getUnit().IsSwimForm() then
        getUnit().WarriorSetStance(2)
    elseif getUnit().IsCatForm() then
        getUnit().WarriorSetStance(3)
    elseif getUnit().IsTravelForm() then
        getUnit().WarriorSetStance(4)
    elseif getUnit().IsBoomForm() then
        getUnit().WarriorSetStance(5)
    end
end

function MoronBox.Unit.WarriorIsStance(id)
    local _, _, st, _ = GetShapeshiftFormInfo(id)
    return st
end

function MoronBox.Unit.WarriorIsBattle()
    return getUnit().WarriorIsStance(1)
end

function MoronBox.Unit.WarriorIsDefensive()
    return getUnit().WarriorIsStance(2)
end

function MoronBox.Unit.WarriorIsBerserker()
    return getUnit().WarriorIsStance(3)
end

function MoronBox.Unit.WarriorSetStance(id)
    CastShapeshiftForm(id)
end

function MoronBox.Unit.WarriorSetBattle()
    if not getUnit().WarriorIsBattle() then
        getUnit().WarriorSetStance(1)
    end
end

function MoronBox.Unit.WarriorSetDefensive()
    if not getUnit().WarriorIsDefensive() then
        getUnit().WarriorSetStance(2)
    end
end

function MoronBox.Unit.WarriorSetBerserker()
    if not getUnit().WarriorIsBerserker() then
        getUnit().WarriorSetStance(3)
    end
end
