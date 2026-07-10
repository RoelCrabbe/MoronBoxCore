local Buff = "Fortitude"
local Fortitude

MoronBox:RegisterModule(Buff, function()
    local Queue = {}
    local ClaimedQueue = {}

    Fortitude = MoronBox.Api.Buffs.Register(Buff)

    local Handlers = MoronBox.Api.Buffs.CreateHandlers({
        BuffName = "Prayer of Fortitude",
        AddonPrefix = Buff,
        Queue = Queue,
        ClaimedQueue = ClaimedQueue
    })

    Fortitude:SetScript("OnEvent", function()
        if event ~= "CHAT_MSG_ADDON" then return end
        MoronBox.Api.Buffs.DispatchMessage(arg2, arg4, Handlers)
    end)

    MoronBox:RegisterExpose({
        Request = function()
            if MoronBox.Api.Buffs.HasActiveBuff(Buff) then
                return
            end

            local group = MoronBox.Api.Buffs.GetGroupNumber()
            local priest = MoronBox.Api.Buffs.GetRandomClassMember("Priest")
            local prio = MoronBox.Api.Buffs.GetPriority(
                { ["Warrior"] = "HIGH", }
            )

            if not priest or not prio or not group then
                MoronBox.Debugger:Warn("No priest, priority or group found")
                return
            end

            Handlers.SendMessage("NEED_FORTITUDE", string.format("BUFF_INFO:%d:%d:%s", prio, group, priest), 15)
        end,
        Process = function()
            if not MoronBox.Api.Buffs.HasBuffPremissions(Buff, "Priest") then
                return false
            end

            local targetUnitId, _, groupNum = MoronBox.Api.Buffs.GetNextTarget(Queue)
            if not targetUnitId or not groupNum then
                return false
            end

            local spellName = "Prayer of Fortitude"
            if mb_isValidFriendlyTarget(targetUnitId, spellName) and not mb_hasBuffOrDebuff(spellName, targetUnitId, "buff") then
                if UnitIsFriend("player", targetUnitId) then
                    ClearTarget()
                end

                mb_selfBuff("Inner Focus")
                CastSpellByName(spellName, nil)
                SpellTargetUnit(targetUnitId)
                SpellStopTargeting()
                return true
            end

            Handlers.SendMessage("BUFFED_FORTITUDE", string.format("BUFFED:%s:%d", targetUnitId, groupNum))
            return false
        end,
    })
end, nil, function()
    MoronBox.Api.Buffs.Unregister(Buff)
end)

function testRequest()
    MoronBox.Registry.Fortitude.Request()
end

function testProcess()
    MoronBox.Registry.Fortitude.Process()
end
