local BUFFING_MODULE = "Fortitude"
local CLASS_MODULE = "Priest"

local FORTITUDE_MANA_COST = 3200 * 0.95

local Fortitude

MoronBox:RegisterModule(BUFFING_MODULE, function()
    local Queue = {}
    local ClaimedQueue = {}

    Fortitude = MoronBox.Api.Buffs.Register(BUFFING_MODULE)

    local Handlers = MoronBox.Api.Buffs.CreateHandlers({
        BuffName = "Prayer of Fortitude",
        AddonPrefix = BUFFING_MODULE,
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
            if MoronBox.Api.Buffs.HasActiveBuff(BUFFING_MODULE) then
                return
            end

            local group = MoronBox.Api.Buffs.GetGroupNumber()
            local priest = MoronBox.Api.Buffs.GetClassMemberForGroup(CLASS_MODULE, group, FORTITUDE_MANA_COST)

            if not priest then
                MoronBox.Debugger:Warn("No priest found")
                return
            end

            local prio = MoronBox.Api.Buffs.GetPriority(
                { ["Shaman"] = "HIGH", }
            )

            Handlers.SendMessage("NEED_FORTITUDE", string.format("BUFF_INFO:%d:%d:%s", prio, group, priest), 9)
        end,
        Process = function()
            if not MoronBox.Api.Buffs.HasBuffPremissions(BUFFING_MODULE, CLASS_MODULE) then
                return false
            end

            local spellName = MoronBox.Api.Buffs.GetBuffSpell(BUFFING_MODULE)

            local soloResult = MoronBox.Api.Buffs.SoloBuff(BUFFING_MODULE, spellName)
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
    return MoronBox.Api.Buffs.UnLoad(CLASS_MODULE)
end, function()
    MoronBox.Api.Buffs.Unregister(BUFFING_MODULE)
end)

function FORT_RequestFortitude()
    if MoronBox.Registry[BUFFING_MODULE] and MoronBox.Registry[BUFFING_MODULE].Request then
        MoronBox.Registry[BUFFING_MODULE].Request()
    end
end

function FORT_ProcessFortitudeQueue()
    if MoronBox.Registry[BUFFING_MODULE] and MoronBox.Registry[BUFFING_MODULE].Process then
        MoronBox.Registry[BUFFING_MODULE].Process()
    end
end
