-- [[ Intellect Buffing ]] --

MoronBox.Unit = MoronBox.Unit or {}
local Unit = MoronBox.Unit

MoronBox.Core = MoronBox.Core or {}
MoronBox.Core.Aura = MoronBox.Core.Aura or {}
local Aura = MoronBox.Core.Aura

-- The buff key used to look up spell/aura data (BUFF_AURA_NAMES, BUFF_CAST_SPELLS).
local BUFF_KEY = "Intellect"

-- The class permitted to cast this buff.
local CLASS_MODULE = "Mage"
local RACE_MODULE = nil

-- Unique module/addon-message prefix, derived from BUFF_KEY to avoid drift.
local MODULE_NAME = "MODULE_" .. string.upper(string.gsub(BUFF_KEY, " ", "_"))

-- Frame reference, assigned on module registration.
local Intellect

-- Minimum mana required to be considered a valid cast candidate.
local INTELLECT_MANA_COST = 3400 * 0.95

-- References to frames.
local Debugger = MoronBox.Debugger
local Buffs = MoronBox.Core.Buffs

MoronBox:RegisterModule(MODULE_NAME, function()
    local Queue = {}
    local ClaimedQueue = {}

    Intellect = Buffs.Register(MODULE_NAME)

    local Handlers = Buffs.CreateHandlers({
        AddonPrefix = MODULE_NAME,
        BuffKey = BUFF_KEY,
        Queue = Queue,
        ClaimedQueue = ClaimedQueue
    })

    Intellect:SetScript("OnEvent", function()
        if event ~= "CHAT_MSG_ADDON" then return end
        if not Handlers.IsOwnMessage(arg1) then return end
        Buffs.DispatchMessage(arg2, arg4, Handlers)
    end)

    MoronBox:RegisterExpose({
        -- Broadcasts a request for this buff if not already active.
        Request = function()
            if Buffs.HasActiveBuff(BUFF_KEY) then
                return
            end

            local group = Buffs.GetGroupNumber()
            local member = Buffs.GetClassMemberForGroup(CLASS_MODULE, group, RACE_MODULE,
                INTELLECT_MANA_COST)

            if not member then
                Debugger:Warn("No " .. CLASS_MODULE .. " found")
                return
            end

            local prio = Buffs.GetPriority(
                {
                    ["Shaman"] = "HIGH",
                    ["Mage"] = "MEDIUM",
                }
            )

            Handlers.SendMessage("NEED_INTELLECT", string.format("BUFF_INFO:%d:%d:%s", prio, group, member), 9)
        end,

        -- Handles the solo cast, then the queue: casts on the next valid target
        -- or notifies the group if that target is already buffed.
        Process = function()
            if not Buffs.HasBuffPremissions(BUFF_KEY, CLASS_MODULE) then
                return false
            end

            local spellName = Buffs.GetBuffSpell(BUFF_KEY)
            local soloResult = Buffs.SoloBuff(BUFF_KEY, spellName)

            if soloResult ~= nil then
                return soloResult
            end

            local targetUnitId, groupNum = Buffs.GetNextTarget(Queue)

            if not targetUnitId then
                return false
            end

            if Unit.IsValidFriendlyTarget(targetUnitId, spellName) and not Aura.HasBuffOrDebuff(spellName, targetUnitId, "buff") then
                if UnitIsFriend("player", targetUnitId) then
                    ClearTarget()
                end

                CastSpellByName(spellName, nil)
                SpellTargetUnit(targetUnitId)
                SpellStopTargeting()
                return true
            end

            Handlers.SendMessage("BUFFED_INTELLECT", string.format("BUFFED:%s:%d", targetUnitId, groupNum), 3)
            return false
        end,
    })
end, function()
    -- Load condition: only active for the required class, or when someone of that class is present.
    return Buffs.UnLoad(CLASS_MODULE, RACE_MODULE)
end, function()
    Buffs.Unregister(MODULE_NAME)
end)

-- [[ Macro Entry Points ]] --

-- Called to request the buff for the player's group.
function Buffs.RequestIntellect()
    if not Unit.IsManaUser() then
        return
    end

    if MoronBox.Registry[MODULE_NAME] and MoronBox.Registry[MODULE_NAME].Request then
        MoronBox.Registry[MODULE_NAME].Request()
    end
end

-- Called to process the buff queue (cast on the next valid target).
function Buffs.ProcessIntellect()
    if MoronBox.Registry[MODULE_NAME] and MoronBox.Registry[MODULE_NAME].Process then
        MoronBox.Registry[MODULE_NAME].Process()
    end
end
