--[####################################################################################################]--
--[####################################### Auto Attacking Utils #######################################]--
--[####################################################################################################]--

local function FindActionSlot(spellName)
    for i = 1, 132 do
        MMBTooltip:SetOwner(UIParent, "ANCHOR_NONE")
        MMBTooltip:SetAction(i)
        if MMBTooltipTextLeft1:GetText() == spellName then
            return i
        end
    end
    return nil
end

function mb_autoAttack()
    local atkSlot = tonumber(MB_attackSlot)
    if atkSlot and not IsCurrentAction(atkSlot) then
        CastSpellByName("Attack")
    end
end

function mb_autoRangedAttack()
    local atkSlot = tonumber(MB_attackRangedSlot)
    if atkSlot and not IsAutoRepeatAction(atkSlot) then
        CastSpellByName("Auto Shot")
    end
end

function mb_autoWandAttack()
    local wndSlot = tonumber(MB_attackWandSlot)
    if wndSlot and not IsAutoRepeatAction(wndSlot) then
        CastSpellByName("Shoot")
    end
end

function mb_healerWand()
	if mb_imBusy() or not mb_inCombat("player") then
		return
	end

	mb_assistFocus()
	mb_autoWandAttack()
end

function mb_setAttackButton()
    MB_attackSlot = FindActionSlot("Attack")
    if not MB_attackSlot then
        mb_message("No Auto-Attack on my bars.")
    end

    if myClass == "Mage" or myClass == "Warlock" or myClass == "Priest" then
        MB_attackWandSlot = FindActionSlot("Shoot")

        if not MB_attackWandSlot then
            mb_message("No Shoot on my bars.")
        end
    elseif myClass == "Hunter" then
        MB_attackRangedSlot = FindActionSlot("Auto Shot")

        if not MB_attackRangedSlot then
            mb_message("No Ranged Auto-Attack on my bars.")
        end
    end
end