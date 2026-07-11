local MODULE_NAME = "FORTITUDE"

local BUFF_KEY = "Fortitude"
local CLASS_MODULE = "Priest"

local FORTITUDE_MANA_COST = 3200 * 0.95

local Fortitude

MoronBox:RegisterModule(MODULE_NAME, function()
    local Queue = {}
    local ClaimedQueue = {}

    Fortitude = MoronBox.Api.Buffs.Register(MODULE_NAME)

    local Handlers = MoronBox.Api.Buffs.CreateHandlers({
        AddonPrefix = MODULE_NAME,
        BuffKey = BUFF_KEY,
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
            if MoronBox.Api.Buffs.HasActiveBuff(BUFF_KEY) then
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
            if not MoronBox.Api.Buffs.HasBuffPremissions(BUFF_KEY, CLASS_MODULE) then
                return false
            end

            local spellName = MoronBox.Api.Buffs.GetBuffSpell(BUFF_KEY)
            local soloResult = MoronBox.Api.Buffs.SoloBuff(BUFF_KEY, spellName)

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
    MoronBox.Api.Buffs.Unregister(MODULE_NAME)
end)

function FORT_RequestFortitude()
    if MoronBox.Registry[MODULE_NAME] and MoronBox.Registry[MODULE_NAME].Request then
        MoronBox.Registry[MODULE_NAME].Request()
    end
end

function FORT_ProcessFortitudeQueue()
    if MoronBox.Registry[MODULE_NAME] and MoronBox.Registry[MODULE_NAME].Process then
        MoronBox.Registry[MODULE_NAME].Process()
    end
end
