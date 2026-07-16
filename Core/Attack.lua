-- [[ Config & Constants ]] --

MoronBox.Core.Attack = MoronBox.Core.Attack or {}

MoronBox.Core.Attack.AttackState = {
    AttackSlot = nil,
    RangedSlot = nil,
    WandSlot = nil
}

local myClass = UnitClass("player")

function getAttack()
    return MoronBox.Core.Attack
end

function getAttackState()
    return MoronBox.Core.Attack.AttackState
end

-- [[ Attacking ]] --

local function FindActionSlot(spellName)
    for i = 1, 132 do
        MoronBoxTooltip:SetOwner(UIParent, "ANCHOR_NONE")
        MoronBoxTooltip:SetAction(i)

        local textObject = getglobal("MoronBoxTooltipTextLeft1")
        if textObject and textObject:GetText() == spellName then
            return i
        end
    end

    return nil
end

function MoronBox.Core.Attack.AutoAttack()
    local atkSlot = tonumber(getAttackState().AttackSlot)
    if atkSlot and not IsCurrentAction(atkSlot) then
        CastSpellByName("Attack")
    end
end

function MoronBox.Core.Attack.AutoRangedAttack()
    local atkSlot = tonumber(getAttackState().RangedSlot)
    if atkSlot and not IsAutoRepeatAction(atkSlot) then
        CastSpellByName("Auto Shot")
    end
end

function MoronBox.Core.Attack.AutoWandAttack()
    local wndSlot = tonumber(getAttackState().WandSlot)
    if wndSlot and not IsAutoRepeatAction(wndSlot) then
        CastSpellByName("Shoot")
    end
end

function MoronBox.Core.Attack.SetAttackButton()
    getAttackState().AttackSlot = FindActionSlot("Attack")
    if not getAttackState().AttackSlot then
        getApi().CdMessage("No Auto-Attack on my bars.")
    end

    if myClass == "Mage" or myClass == "Warlock" or myClass == "Priest" then
        getAttackState().WandSlot = FindActionSlot("Shoot")
        if not getAttackState().WandSlot then
            getApi().CdMessage("No Shoot on my bars.")
        end
    elseif myClass == "Hunter" then
        getAttackState().RangedSlot = FindActionSlot("Auto Shot")
        if not getAttackState().RangedSlot then
            getApi().CdMessage("No Ranged Auto-Attack on my bars.")
        end
    end
end

-- [[ Spell Events ]] --

local AttackFrame = CreateFrame("Frame")

local ATTACK_EVENTS = {
    "ACTIONBAR_SLOT_CHANGED"
}

do
    for _, evt in ipairs(ATTACK_EVENTS) do
        AttackFrame:RegisterEvent(evt)
    end
end

AttackFrame:SetScript("OnEvent", function()
    if event == "ACTIONBAR_SLOT_CHANGED" then
        getAttack().SetAttackButton()
    end
end)
