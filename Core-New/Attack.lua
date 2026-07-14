-- [[ Config & Constants ]] --

MoronBox.Core.Attack = MoronBox.Core.Attack or {}

MoronBox.Core.Attack.AttackState = {
    AttackSlot = nil,
    RangedSlot = nil,
    WandSlot = nil
}

local myClass = UnitClass("player")

local Attack = MoronBox.Core.Attack
local AttackState = Attack.AttackState

---@diagnostic disable: undefined-global
setfenv(1, MoronBox:GetEnvironment())

-- [[ Attacking ]] --

local function FindActionSlot(spellName)
    for i = 1, 132 do
        MMBTooltip:SetOwner(UIParent, "ANCHOR_NONE")
        MMBTooltip:SetAction(i)

        local textObject = getglobal("MMBTooltipTextLeft1")
        if textObject and textObject:GetText() == spellName then
            return i
        end
    end

    return nil
end

function MoronBox.Core.Attack.AutoAttack()
    local atkSlot = tonumber(AttackState.AttackSlot)
    if atkSlot and not IsCurrentAction(atkSlot) then
        CastSpellByName("Attack")
    end
end

function MoronBox.Core.Attack.AutoRangedAttack()
    local atkSlot = tonumber(AttackState.RangedSlot)
    if atkSlot and not IsAutoRepeatAction(atkSlot) then
        CastSpellByName("Auto Shot")
    end
end

function MoronBox.Core.Attack.AutoWandAttack()
    local wndSlot = tonumber(AttackState.WandSlot)
    if wndSlot and not IsAutoRepeatAction(wndSlot) then
        CastSpellByName("Shoot")
    end
end

function MoronBox.Core.Attack.SetAttackButton()
    AttackState.AttackSlot = FindActionSlot("Attack")
    if not AttackState.AttackSlot then
        CdMessage("No Auto-Attack on my bars.")
    end

    if myClass == "Mage" or myClass == "Warlock" or myClass == "Priest" then
        AttackState.WandSlot = FindActionSlot("Shoot")
        if not AttackState.WandSlot then
            CdMessage("No Shoot on my bars.")
        end
    elseif myClass == "Hunter" then
        AttackState.RangedSlot = FindActionSlot("Auto Shot")
        if not AttackState.RangedSlot then
            CdMessage("No Ranged Auto-Attack on my bars.")
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
        Attack.SetAttackButton()
    end
end)
