-- [[ Config & Constants ]] --

MoronBox.Api = MoronBox.Api or {}
local Api = MoronBox.Api

MoronBox.Core.Attack = MoronBox.Core.Attack or {}
local Attack = MoronBox.Core.Attack

Attack.State = {
    AttackSlot = nil,
    RangedSlot = nil,
    WandSlot = nil
}

-- Common Names
local myClass = UnitClass("player")
local myName = UnitName("player")
local myRace = UnitRace("player")

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

function Attack.AutoAttack()
    local atkSlot = tonumber(Attack.State.AttackSlot)
    if atkSlot and not IsCurrentAction(atkSlot) then
        CastSpellByName("Attack")
    end
end

function Attack.AutoRangedAttack()
    local atkSlot = tonumber(Attack.State.RangedSlot)
    if atkSlot and not IsAutoRepeatAction(atkSlot) then
        CastSpellByName("Auto Shot")
    end
end

function Attack.AutoWandAttack()
    local wndSlot = tonumber(Attack.State.WandSlot)
    if wndSlot and not IsAutoRepeatAction(wndSlot) then
        CastSpellByName("Shoot")
    end
end

function Attack.SetAttackButton()
    Attack.State.AttackSlot = FindActionSlot("Attack")
    if not Attack.State.AttackSlot then
        Api.CdMessage("No Auto-Attack on my bars.")
    end

    if myClass == "Mage" or myClass == "Warlock" or myClass == "Priest" then
        Attack.State.WandSlot = FindActionSlot("Shoot")
        if not Attack.State.WandSlot then
            Api.CdMessage("No Shoot on my bars.")
        end
    elseif myClass == "Hunter" then
        Attack.State.RangedSlot = FindActionSlot("Auto Shot")
        if not Attack.State.RangedSlot then
            Api.CdMessage("No Ranged Auto-Attack on my bars.")
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
