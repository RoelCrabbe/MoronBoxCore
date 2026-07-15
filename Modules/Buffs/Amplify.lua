-- [[ Amplify Magic Buffing ]] --
---@diagnostic disable: undefined-global

-- The buff key used to look up spell/aura data (BUFF_AURA_NAMES, BUFF_CAST_SPELLS).
local BUFF_KEY = "AmplifyMagic"

-- The class permitted to cast this buff.
local CLASS_MODULE = "Mage"
local RACE_MODULE = nil

-- Unique module/addon-message prefix, derived from BUFF_KEY to avoid drift.
local MODULE_NAME = "MODULE_" .. string.upper(string.gsub(BUFF_KEY, " ", "_"))

-- Frame reference, assigned on module registration.
local AmplifyMagic

-- Minimum mana required to be considered a valid cast candidate.
local FORTITUDE_MANA_COST = 500 * 0.95

MoronBox:RegisterModule(MODULE_NAME, function()
    local Queue = {}
    local ClaimedQueue = {}

    AmplifyMagic = Register(MODULE_NAME)

    local Handlers = CreateHandlers({
        AddonPrefix = MODULE_NAME,
        BuffKey = BUFF_KEY,
        Queue = Queue,
        ClaimedQueue = ClaimedQueue
    })

    AmplifyMagic:SetScript("OnEvent", function()
        if event ~= "CHAT_MSG_ADDON" then return end
        if not Handlers.IsOwnMessage(arg1) then return end
        DispatchMessage(arg2, arg4, Handlers)
    end)

    MoronBox:RegisterExpose({
        -- Broadcasts a request for this buff if not already active.
        Request = function()
            if HasActiveBuff(BUFF_KEY) then
                return
            end

            local group = GetGroupNumber()
            local member = GetClassMemberForGroup(CLASS_MODULE, group, RACE_MODULE,
                FORTITUDE_MANA_COST)

            if not member then
                WarnMsg("No " .. CLASS_MODULE .. " found")
                return
            end

            local prio = GetPriority(
                {
                    ["Shaman"] = "HIGH",
                    ["Mage"] = "MEDIUM",
                }
            )

            Handlers.SendMessage("NEED_DAMPEN", string.format("BUFF_INFO:%d:%d:%s", prio, group, member), 9)
        end,

        -- Handles the solo cast, then the queue: casts on the next valid target
        -- or notifies the group if that target is already buffed.
        Process = function()
            if not HasBuffPremissions(BUFF_KEY, CLASS_MODULE) then
                return false
            end

            local spellName = GetBuffSpell(BUFF_KEY)
            local soloResult = SoloBuff(BUFF_KEY, spellName)

            if soloResult ~= nil then
                return soloResult
            end

            local targetUnitId, groupNum = GetNextTarget(Queue)

            if not targetUnitId then
                return false
            end

            if IsValidFriendlyTarget(targetUnitId, spellName) and not HasBuffOrDebuff(spellName, targetUnitId, "buff") then
                if UnitIsFriend("player", targetUnitId) then
                    ClearTarget()
                end

                CastSpellByName(spellName, nil)
                SpellTargetUnit(targetUnitId)
                SpellStopTargeting()
                return true
            end

            Handlers.SendMessage("BUFFED_DAMPEN", string.format("BUFFED:%s:%d", targetUnitId, groupNum), 3)
            return false
        end,
    })
end, function()
    -- Load condition: only active for the required class, or when someone of that class is present.
    return UnLoad(CLASS_MODULE, RACE_MODULE)
end, function()
    Unregister(MODULE_NAME)
end)

-- [[ Macro Entry Points ]] --
---@diagnostic enable: undefined-global

-- Called to request the buff for the player's group.
function MoronBox.Core.Buffs.RequestAmplifyMagic()
    if getApi().FindMyNameInTable(MoronBox.Core.State.RaidTanks) then
        return
    end

    if not getTables().MobsToAmplifyMagic() then
        return
    end

    if MoronBox.Registry[MODULE_NAME] and MoronBox.Registry[MODULE_NAME].Request then
        MoronBox.Registry[MODULE_NAME].Request()
    end
end

-- Called to process the buff queue (cast on the next valid target).
function MoronBox.Core.Buffs.ProcessAmplifyMagic()
    if MoronBox.Registry[MODULE_NAME] and MoronBox.Registry[MODULE_NAME].Process then
        MoronBox.Registry[MODULE_NAME].Process()
    end
end
