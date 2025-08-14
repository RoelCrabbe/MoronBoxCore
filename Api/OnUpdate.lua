--[####################################################################################################]--
--[########################################### OnUpdate Core ##########################################]--
--[####################################################################################################]--

local myClass = UnitClass("player")
local myName = UnitName("player")
local myRace = UnitRace("player")

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function MMB:OnUpdate()
    local currentTime = GetTime()
    
    if MB_tradeOpenOnUpdate.Active and currentTime > MB_tradeOpenOnUpdate.Time then
        for i = 0, 6 do
            for k, item in pairs(MB_itemToAutoTrade) do
                if MB_tradeOpen then
                    local targetLink = GetTradeTargetItemLink(i)
                    local playerLink = GetTradePlayerItemLink(i)
                    
                    if (targetLink and targetLink:find(item)) or (playerLink and playerLink:find(item)) then
                        AcceptTrade()
                        return
                    end
                end
            end
        end
    end
    
    if MB_DMFWeek and MB_DMFWeek.Active and currentTime > MB_DMFWeek.Time then
        MB_DMFWeek.Active = false
        local option1, _, option2 = GetGossipOptions()
       
        if mb_imHealer() then
            if option1 == "Yes" then
                SelectGossipOption(1)
            elseif option2 == "Turn him over to liege" or option2 == "Show not so quiet defiance" then
                SelectGossipOption(2)
            end
        elseif option1 == "Yes" or option1 == "Slay the Man" or option1 == "Execute your friend" then
            SelectGossipOption(1)
        end
    end
    
    if MB_MCEnter.Active and currentTime > MB_MCEnter.Time then
        MB_MCEnter.Active = false
        if GetGossipOptions() == "Teleport me to the Molten Core" then              
            SelectGossipOption(1)
        end
    end
    
    local TimersToCheck = {
        MB_razorgoreNewTargetBecauseTargetIsBehindOrOutOfRange,
        MB_lieutenantAndorovIsNotHealable,
        MB_razorgoreNewTargetBecauseTargetIsBehind,
        MB_targetWrongWayOrTooFar,
        MB_autoToggleSheeps,
        MB_autoBuff,
        MB_useCooldowns,
        MB_useBigCooldowns,
        MB_doInterrupt,
        MB_isMoving
    }
    
    for _, action in ipairs(TimersToCheck) do
        if action.Active and currentTime > action.Time then
            action.Active = false
        end
    end
    
    if MB_autoBuyReagents.Active and currentTime > MB_autoBuyReagents.Time then
        mb_buyReagentsAndArrows()
    end
    
    if MB_hunterFeign.Active and currentTime > MB_hunterFeign.Time then
        mb_removeFeignDeath()
    end
end

MMB:SetScript("OnUpdate", MMB.OnUpdate)
