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
        if not Handlers.IsOwnMessage(arg1) then return end
        MoronBox.Api.Buffs.DispatchMessage(arg2, arg4, Handlers)
    end)

    MoronBox:RegisterExpose({
        Request = function()
            if MoronBox.Api.Buffs.HasActiveBuff(Buff) then
                return
            end

            local priest = MoronBox.Api.Buffs.GetRandomClassMember("Priest")

            if not priest then
                MoronBox.Debugger:Warn("No priest found")
                return
            end

            local group = MoronBox.Api.Buffs.GetGroupNumber()
            local prio = MoronBox.Api.Buffs.GetPriority(
                { ["Shaman"] = "HIGH", }
            )

            Handlers.SendMessage("NEED_FORTITUDE", string.format("BUFF_INFO:%d:%d:%s", prio, group, priest), 9)
        end,
        Process = function()
            if not MoronBox.Api.Buffs.HasBuffPremissions(Buff, "Priest") then
                return false
            end

            local spellName = MoronBox.Api.Buffs.GetBuffSpell(Buff)

            local soloResult = MoronBox.Api.Buffs.SoloBuff(Buff, spellName)
            if soloResult ~= nil then
                return soloResult
            end

            local targetUnitId, groupNum = MoronBox.Api.Buffs.GetNextTarget(Queue)

            if not targetUnitId then
                return false
            end

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

            Handlers.SendMessage("BUFFED_FORTITUDE", string.format("BUFFED:%s:%d", targetUnitId, groupNum), 3)
            return false
        end,
    })
end, function()
    return MoronBox.Api.Buffs.UnLoad("Priest")
end, function()
    MoronBox.Api.Buffs.Unregister(Buff)
end)

function FORT_RequestFortitude()
    if MoronBox.Registry[Buff] and MoronBox.Registry[Buff].Request then
        MoronBox.Registry[Buff].Request()
    end
end

function FORT_ProcessFortitudeQueue()
    if MoronBox.Registry[Buff] and MoronBox.Registry[Buff].Process then
        MoronBox.Registry[Buff].Process()
    end
end
