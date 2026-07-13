-- [[ Config & Constants ]] --

MoronBox.Unit = MoronBox.Unit or {}
local Unit = MoronBox.Unit

-- Unit Functions
local UnitName = UnitName
local UnitClass = UnitClass
local UnitRace = UnitRace
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
local UnitIsVisible = UnitIsVisible
local UnitAffectingCombat = UnitAffectingCombat

-- Spell Functions
local CastSpellByName = CastSpellByName

-- Target Functions
local TargetByName = TargetByName
local ClearTarget = ClearTarget

-- Party/Raid Functions
local GetNumRaidMembers = GetNumRaidMembers

-- Common Names
local myClass = UnitClass("player") --[[@as string]]
local myName = UnitName("player") --[[@as string]]
local myRace = UnitRace("player") --[[@as string]]

-- [[ Unit ]] --

function Unit.GetTankName()
    if not MB_raidLeader then
        return nil
    end

    local focusId = MoronBox.Core.State.MBID[MB_raidLeader]

    if focusId then
        return UnitName(focusId)
    else
        TargetByName(MB_raidLeader, 1)
        return "target"
    end
end

function Unit.PromoteEveryone()
    for toon in pairs(MoronBox.Core.State.MBID) do
        PromoteToAssistant(toon)
    end
end

function Unit.CrowdControlledMob()
    if (mb_hasBuffOrDebuff("Shackle Undead", "target", "debuff")
            or mb_hasBuffOrDebuff("Polymorph", "target", "debuff")
            or mb_hasBuffOrDebuff("Banish", "target", "debuff")) then
        return true
    end
    return false
end

function Unit.InCombat(unitId)
    unitId = unitId or "player"
    return UnitAffectingCombat(unitId)
end

function Unit.HealthPct(unitId)
    unitId = unitId or "player"
    return UnitHealth(unitId) / UnitHealthMax(unitId)
end

function Unit.HealthDown(unitId)
    unitId = unitId or "player"
    return UnitHealthMax(unitId) - UnitHealth(unitId)
end

function Unit.IsManaUser(unitId)
    unitId = unitId or "player"
    return UnitPowerType(unitId) == 0
end

function Unit.ManaPct(unitId)
    unitId = unitId or "player"
    return UnitMana(unitId) / UnitManaMax(unitId)
end

function Unit.ManaDown(unitId)
    unitId = unitId or "player"
    if not Unit.IsManaUser(unitId) then
        return 0
    end
    return UnitManaMax(unitId) - UnitMana(unitId)
end

function Unit.ManaOfUnit(unitId)
    unitId = unitId or "player"
    return UnitMana(unitId)
end

function Unit.IsDead(unitId)
    unitId = unitId or "player"
    return UnitIsDeadOrGhost(unitId) or not (UnitHealth(unitId) > 1)
end

function Unit.IsAlive(unitId)
    if not unitId then return false end
    if not UnitName(unitId) then return false end
    if UnitIsDead(unitId) then return false end
    if UnitHealth(unitId) <= 1 then return false end
    if UnitIsGhost(unitId) then return false end
    if not UnitIsConnected(unitId) then return false end
    return true
end

function Unit.ClearTargetIfNotAggroed()
    if not Unit.InCombat("target") then
        ClearTarget()
    end
end

function Unit.IsInGroup(unitName)
    return MoronBox.Core.State.GroupID[unitName] ~= nil and
        MoronBox.Core.State.GroupID[unitName] == MoronBox.Core.State.GroupID[myName]
end

function Unit.IsInRaid(unitName)
    return MoronBox.Core.State.MBID[unitName] ~= nil
end

function Unit.AggroOnPlayer()
    return UnitName("targettarget") == myName
end

function Unit.InRaidOrParty(unitId)
    return UnitInRaid(unitId) or UnitInParty(unitId)
end

function Unit.InMeleeRange(unitId)
    unitId = unitId or "target"
    return CheckInteractDistance(unitId, 3)
end

function Unit.InRange(unitId)
    return CheckInteractDistance(unitId, 4)
end

function Unit.InTradeRange(unitId)
    if not unitId then return end
    return CheckInteractDistance(unitId, 2)
end

function Unit.In28YardRange(unitId)
    if not unitId then return end
    return Unit.InRange(unitId)
end

function Unit.IsValidFriendlyTargetWithin28YardRange(unitId)
    return UnitExists(unitId) and
        Unit.IsAlive(unitId) and
        UnitIsVisible(unitId) and
        Unit.In28YardRange(unitId)
end

function Unit.IsValidEnemyTargetWithin28YardRange(unitId)
    return UnitExists(unitId) and
        Unit.InCombat(unitId) and
        Unit.In28YardRange(unitId)
end

function Unit.IsValidFriendlyTarget(unitId, spellName)
    return UnitExists(unitId) and
        Unit.IsAlive(unitId) and
        UnitIsVisible(unitId) and
        Unit.CanHelpfulSpellBeCastOn(spellName, unitId)
end

function Unit.IsValidMeleeTarget(unitId)
    return UnitExists(unitId) and
        Unit.IsAlive(unitId) and
        Unit.InCombat(unitId) and
        Unit.InMeleeRange()
end

function Unit.IsNotValidTankableTarget()
    return not UnitName("target") or
        not UnitAffectingCombat("target") or
        not CheckInteractDistance("target", 3) or
        not Unit.Dead("target") or
        Unit.CrowdControlledMob()
end

function Unit.CanHelpfulSpellBeCastOn(spell, unitId)
    if MB_raidAssist.Use40yardHealingRangeOnInstants then
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
        return Unit.In28YardRange(unitId)
    end
end

function Unit.GetUnitForPlayerName(playerName)
    local members = Unit.GetNumPartyOrRaidMembers()

    for i = 1, members do
        local unitId = Unit.GetUnitFromPartyOrRaidIndex(i)
        if UnitName(unitId) == playerName then
            return unitId
        end
    end

    if myName == playerName then
        return "player"
    end
    return nil
end

function Unit.GetRaidIndexForPlayerName(playerName)
    local members = GetNumRaidMembers()

    for i = 1, members do
        local unitId = Unit.GetUnitFromPartyOrRaidIndex(i)
        if UnitName(unitId) == playerName then
            return i
        end
    end
    return nil
end

function Unit.GetUnitFromPartyOrRaidIndex(index)
    if index ~= 0 then
        if UnitInRaid("player") then
            return "raid" .. index
        else
            return "party" .. index
        end
    end
    return "player"
end

function Unit.ReturnPlayerInRaidFromTable(list)
    if not list then return nil end

    for _, name in ipairs(list) do
        if name and MoronBox.Core.State.MBID[name] then
            return name
        end
    end

    return nil
end

function Unit.PartyMana()
    local mana = 0
    local maxMana = 0
    local manaPCT = 0
    local manaDown = 0

    local myGroup = MoronBox.Core.State.GroupID[myName]
    if not myGroup then
        return manaPCT, manaDown, mana, maxMana
    end

    local groupMembers = MoronBox.Core.State.ToonsInGroup[myGroup]
    if not groupMembers then
        return manaPCT, manaDown, mana, maxMana
    end

    for _, name in ipairs(groupMembers) do
        local memberId = MoronBox.Core.State.MBID[name]
        if memberId and Unit.IsAlive(memberId) and Unit.ManaUser(memberId) then
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

function Unit.PartyHealth()
    local health = 0
    local maxHealth = 0

    local myGroup = MoronBox.Core.State.GroupID[myName]
    if not myGroup then
        return 0, 0
    end

    local groupMembers = MoronBox.Core.State.ToonsInGroup[myGroup]
    if not groupMembers then
        return 0, 0
    end

    for _, name in ipairs(groupMembers) do
        local memberId = MoronBox.Core.State.MBID[name]
        if memberId and Unit.IsAlive(memberId) then
            health = health + UnitHealth(memberId)
            maxHealth = maxHealth + UnitHealthMax(memberId)
        end
    end

    if maxHealth > 0 then
        return (health / maxHealth), (maxHealth - health)
    end

    return 0, 0
end

function Unit.RaidHealth()
    if not UnitInRaid("player") then
        return Unit.PartyHealth()
    end

    local health = 0
    local maxHealth = 0

    for _, id in pairs(MoronBox.Core.State.MBID) do
        if id and Unit.IsAlive(id) then
            health = health + UnitHealth(id)
            maxHealth = maxHealth + UnitHealthMax(id)
        end
    end

    if maxHealth > 0 then
        return (health / maxHealth), (maxHealth - health)
    end

    return 0, 0
end

function Unit.WarriorHealth()
    local health = 0
    local maxHealth = 0

    local warriorList = MoronBox.Core.State.ClassList["Warrior"]
    if not warriorList then
        return 0, 0
    end

    for _, name in ipairs(warriorList) do
        local warriorId = MoronBox.Core.State.MBID[name]

        if warriorId and Unit.IsAlive(warriorId) then
            health = health + UnitHealth(warriorId)
            maxHealth = maxHealth + UnitHealthMax(warriorId)
        end
    end

    if maxHealth > 0 then
        return (health / maxHealth), (maxHealth - health)
    end

    return 0, 0
end

function Unit.IsBearForm()
    return Unit.WarriorIsStance(1)
end

function Unit.IsSwimForm()
    return Unit.WarriorIsStance(2)
end

function Unit.IsCatForm()
    return Unit.WarriorIsStance(3)
end

function Unit.IsTravelForm()
    return Unit.WarriorIsStance(4)
end

function Unit.IsBoomForm()
    return Unit.WarriorIsStance(5)
end

function Unit.IsDruidShapeShifted()
    if myClass ~= "Druid" then
        return false
    end

    return Unit.IsBearForm() or
        Unit.IsSwimForm() or
        Unit.IsCatForm() or
        Unit.IsTravelForm() or
        Unit.IsBoomForm()
end

function Unit.CancelDruidShapeShift()
    if Unit.IsBearForm() then
        Unit.WarriorSetStance(1)
    elseif Unit.IsSwimForm() then
        Unit.WarriorSetStance(2)
    elseif Unit.IsCatForm() then
        Unit.WarriorSetStance(3)
    elseif Unit.IsTravelForm() then
        Unit.WarriorSetStance(4)
    elseif Unit.IsBoomForm() then
        Unit.WarriorSetStance(5)
    end
end

function Unit.WarriorIsStance(id)
    local _, _, st, _ = GetShapeshiftFormInfo(id)
    return st
end

function Unit.WarriorIsBattle()
    return Unit.WarriorIsStance(1)
end

function Unit.WarriorIsDefensive()
    return Unit.WarriorIsStance(2)
end

function Unit.WarriorIsBerserker()
    return Unit.WarriorIsStance(3)
end

function Unit.WarriorSetStance(id)
    CastShapeshiftForm(id)
end

function Unit.WarriorSetBattle()
    if not Unit.WarriorIsBattle() then
        Unit.WarriorSetStance(1)
    end
end

function Unit.WarriorSetDefensive()
    if not Unit.WarriorIsDefensive() then
        Unit.WarriorSetStance(2)
    end
end

function Unit.WarriorSetBerserker()
    if not Unit.WarriorIsBerserker() then
        Unit.WarriorSetStance(3)
    end
end

function Unit.MakeALine()
    if not UnitInRaid("player") then
        print("MakeALine only works in raid")
        return
    end

    local headOfLine = Unit.ImFocus() and myName or Unit.GetTankName()
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
