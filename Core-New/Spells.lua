-- [[ Config & Constants ]] --

MoronBox.Api = MoronBox.Api or {}
local Api = MoronBox.Api

MoronBox.Core.Spells = MoronBox.Core.Spells or {}
local Spells = MoronBox.Core.Spells

Spells.State = {
    IsCastingMyCCSpell = false
}

local IsCasting = false
local IsChanneling = false

-- Common Names
local myClass = UnitClass("player")

-- [[ Spells ]] --

function Spells.Ready(spellName, rank)
    if not Spells.Know(spellName, rank) then
        return false
    end

    return Spells.CoolDown(spellName) == 0
end

function Spells.Know(spellName, rank)
    local ispellIndex = Spells.Index(spellName, rank)
    return ispellIndex ~= nil
end

function Spells.Index(spellName, rank)
    for tabIndex = 1, MAX_SKILLLINE_TABS do
        local tabName, _, tabSpellOffset, tabNumSpells = GetSpellTabInfo(tabIndex)

        if not tabName then
            break
        end

        for ispellIndex = tabSpellOffset + 1, tabSpellOffset + tabNumSpells do
            local ispellName, ispellRank = GetSpellName(ispellIndex, BOOKTYPE_SPELL)
            if ispellName == spellName then
                if not rank or (rank and rank == ispellRank) then
                    return ispellIndex, BOOKTYPE_SPELL
                end
            end
        end
    end

    return nil, BOOKTYPE_SPELL
end

function Spells.CoolDown(spellName)
    if not Spells.Exists(spellName) then
        return true
    end

    local spellIndex = Spells.Index(spellName)

    if not spellIndex then
        return true
    end

    local start, duration, enabled = GetSpellCooldown(spellIndex, BOOKTYPE_SPELL)

    if enabled == 0 then
        return 1
    else
        local remaining = start + duration - GetTime()
        if remaining < 0 then
            remaining = 0
        end
        return remaining
    end
end

function Spells.Exists(findSpell)
    if not findSpell then
        return
    end

    for i = 1, MAX_SKILLLINE_TABS do
        local name, _, offset, numSpells = GetSpellTabInfo(i)
        if not name then
            break
        end

        for s = offset + 1, offset + numSpells do
            local spell, rank = GetSpellName(s, BOOKTYPE_SPELL)

            if spell then
                local currentSpell = spell

                if rank ~= "" then
                    currentSpell = spell .. " " .. rank
                end

                if string.find(currentSpell, findSpell, 1, true) then
                    return true
                end
            end
        end
    end
end

function Spells.Number(spell)
    local i = 1
    local spellNumber = 0
    local spellName

    while true do
        spellName = GetSpellName(i, BOOKTYPE_SPELL)

        if not spellName then
            break
        end

        if string.find(spellName, spell, 1, true) then
            spellNumber = i
        end

        i = i + 1
    end

    if spellNumber == 0 then
        return nil
    end

    return spellNumber
end

local function MaxRankOfSpell(spellName)
    if not spellName then
        return nil
    end

    local maxRank = 0
    local maxRankText = nil

    local i = 1
    while true do
        local spell, rank = GetSpellName(i, BOOKTYPE_SPELL)
        if not spell then
            break
        end

        if spell == spellName then
            if rank and rank ~= "" then
                local rankStart = string.find(rank, "Rank ", 1, true)
                if rankStart then
                    local numberStart = rankStart + 5
                    local rankNumStr = string.sub(rank, numberStart)
                    local rankNum = tonumber(rankNumStr)
                    if rankNum and rankNum > maxRank then
                        maxRank = rankNum
                        maxRankText = rank
                    end
                end
            else
                if maxRank == 0 then
                    maxRankText = nil
                end
            end
        end

        i = i + 1
    end

    return maxRankText
end

local function CostOfSpell(spellName, rankText)
    if not spellName then
        return nil
    end

    local tooltip = MMBTooltip
    tooltip:SetOwner(UIParent, "ANCHOR_NONE")

    local i = 1
    while true do
        local spell, rank = GetSpellName(i, BOOKTYPE_SPELL)
        if not spell then
            break
        end

        if spell == spellName and (not rankText or rank == rankText) then
            tooltip:SetSpell(i, BOOKTYPE_SPELL)

            local lineIndex = 2
            while true do
                local textRegion = getglobal(tooltip:GetName() .. "TextLeft" .. lineIndex)
                if not textRegion then
                    break
                end

                local text = textRegion:GetText()
                if text then
                    local _, _, cost = string.find(text, "(%d+)%s+[Mm]ana")
                    if cost then
                        tooltip:Hide()
                        return tonumber(cost)
                    end
                end

                lineIndex = lineIndex + 1
            end

            tooltip:Hide()
            break
        end

        i = i + 1
    end

    return nil
end

local SpellRankCache = {}

function Spells.GetMaxRank(spellName)
    if not spellName then
        return nil
    end

    if SpellRankCache[spellName] then
        return SpellRankCache[spellName]
    end

    local result = MaxRankOfSpell(spellName)
    SpellRankCache[spellName] = result
    return result
end

local SpellManaCostCache = {}

function Spells.GetManaCost(spellName, rankText)
    if not spellName then
        return nil
    end

    local getRank = rankText or Spells.GetMaxRank(spellName)
    local cacheKey = spellName .. (getRank or "")

    if SpellManaCostCache[cacheKey] then
        return SpellManaCostCache[cacheKey]
    end

    local manaCost = CostOfSpell(spellName, getRank)
    SpellManaCostCache[cacheKey] = manaCost
    return manaCost
end

-- [[ Wand & Cooldown Casting ]] --

function Spells.CastOrWand(spell)
    if Spells.Know(spell) then
        local spellCost = Spells.GetManaCost(spell)
        if spellCost and UnitMana("player") > spellCost then
            CastSpellByName(spell)
            return
        end
    end

    if MB_attackWandSlot then
        mb_autoWandAttack()
    else
        mb_autoAttack()
    end
end

function Spells.CoolDownCast(spell, cooldown)
    local time = GetTime()

    if not MB_cooldowns[spell] then
        CastSpellByName(spell)
        MB_cooldowns[spell] = time
        return
    end

    if MB_cooldowns[spell] + cooldown > time then
        return
    end

    if MB_cooldowns[spell] + cooldown <= time then
        CastSpellByName(spell)
        MB_cooldowns[spell] = nil
    end
end

-- [[ Pet Spells ]] --

function Spells.PetCooldown(spellName)
    local index = Spells.GetPetSpellOnBar(spellName)
    if not index then
        return 0
    end

    local start, duration = GetPetActionCooldown(index)
    local remaining = start + duration - GetTime()

    if remaining < 0 then
        remaining = 0
    end
    return remaining
end

function Spells.PetReady(spellName)
    return Spells.PetCooldown(spellName) == 0
end

function Spells.GetPetSpellOnBar(spellName)
    for i = 1, 10 do
        local name = GetPetActionInfo(i)
        if name == spellName then
            return i
        end
    end
end

function Spells.CastPetAction(spellName)
    if not UnitExists("pet") then
        return
    end

    local index = Spells.GetPetSpellOnBar(spellName)
    if index then
        CastPetAction(index)
    end
end

function Spells.DoRazuviousActions()
    if not UnitExists("pet") then
        return
    end

    for _ = 1, 4 do
        TargetByName("Instructor Razuvious")
        PetAttack()

        if Spells.PetReady("Shield Wall") then
            Spells.CastPetAction("Shield Wall")
            Api.CdMessage("Shield Wall!")
        end
    end
end

function Spells.DoFaerlinaActions()
    if not UnitExists("pet") then
        return
    end

    for _ = 1, 4 do
        TargetByName("Grand Widow Faerlina")
        PetAttack()
    end
end

function Spells.OrbControlling()
    if not UnitExists("pet") then
        return
    end

    for _ = 1, 8 do
        Spells.CastPetAction("Destroy Egg")
        CastPetAction(5)
    end
end

-- [[ Spell Events ]] --

local SpellsFrame = CreateFrame("Frame")

local SPELL_EVENTS = {
    "SPELLCAST_START",
    "SPELLCAST_INTERRUPTED",
    "SPELLCAST_STOP",
    "SPELLCAST_FAILED",
    "SPELLCAST_CHANNEL_START",
    "SPELLCAST_CHANNEL_STOP",
}

do
    for _, evt in ipairs(SPELL_EVENTS) do
        SpellsFrame:RegisterEvent(evt)
    end
end

SpellsFrame:SetScript("OnEvent", function()
    if event == "SPELLCAST_START" then
        IsCasting = true

        if arg1 == MB_myCCSpell[myClass] then
            Spells.State.IsCastingMyCCSpell = true
        end
    elseif event == "SPELLCAST_INTERRUPTED" or event == "SPELLCAST_STOP" or event == "SPELLCAST_FAILED" then
        IsCasting = false
        Spells.State.IsCastingMyCCSpell = false
    elseif event == "SPELLCAST_CHANNEL_START" then
        IsChanneling = true
    elseif event == "SPELLCAST_CHANNEL_STOP" then
        IsChanneling = false
    end
end)

function Spells.IsBusy()
    return IsCasting or IsChanneling
end
