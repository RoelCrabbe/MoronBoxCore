-- [[ Fortitude Buffing ]] --

-- The buff key used to look up spell/aura data (BUFF_AURA_NAMES, BUFF_CAST_SPELLS).
local BUFF_KEY = "FearWard"

-- The class permitted to cast this buff.
local CLASS_MODULE = "Priest"
local RACE_MODULE = "Dwarf"

-- Unique module/addon-message prefix, derived from BUFF_KEY to avoid drift.
local MODULE_NAME = "MODULE_" .. string.upper(string.gsub(BUFF_KEY, " ", "_"))

-- Frame reference, assigned on module registration.
local FearWard

-- Minimum mana required to be considered a valid cast candidate.
local FEARWARD_MANA_COST = 90 * 0.95

MoronBox:RegisterModule(MODULE_NAME, function()
    local Queue = {}
    local ClaimedQueue = {}
    local PriorityOverrides = {}

    FearWard = MoronBox.Core.Buffs.Register(MODULE_NAME)

    local Handlers = MoronBox.Core.Buffs.CreateHandlers({
        AddonPrefix = MODULE_NAME,
        BuffKey = BUFF_KEY,
        Queue = Queue,
        ClaimedQueue = ClaimedQueue
    })

    FearWard:SetScript("OnEvent", function()
        if event ~= "CHAT_MSG_ADDON" then return end
        if not Handlers.IsOwnMessage(arg1) then return end
        MoronBox.Core.Buffs.DispatchMessage(arg2, arg4, Handlers)
    end)

    MoronBox:RegisterExpose({
        -- Overrides the priority for a specific fight, preventing accidental duplicates.
        OverridePriority = function(fightName, fn)
            if PriorityOverrides[fightName] then
                MoronBox.Debugger:Warn("Priority override already exists for: " .. fightName)
                return
            end

            PriorityOverrides[fightName] = fn
        end,

        -- Broadcasts a request for this buff if not already active.
        Request = function()
            if MoronBox.Core.Buffs.HasActiveBuff(BUFF_KEY) then
                return
            end

            local group = MoronBox.Core.Buffs.GetGroupNumber()
            local member = MoronBox.Core.Buffs.GetClassMemberForGroup(CLASS_MODULE, group, RACE_MODULE,
                FEARWARD_MANA_COST)

            if not member then
                MoronBox.Debugger:Warn("No " .. CLASS_MODULE .. " found")
                return
            end

            local prio = MoronBox.Core.Buffs.GetCustomPriority(PriorityOverrides,
                {
                    ["Rogue"] = "HIGH",
                    ["Mage"] = "MEDIUM",
                }
            )

            Handlers.SendMessage("NEED_FEARWARD", string.format("BUFF_INFO:%d:%d:%s", prio, group, member), 9)
        end,

        -- Handles the solo cast, then the queue: casts on the next valid target
        -- or notifies the group if that target is already buffed.
        Process = function()
            if not MoronBox.Core.Buffs.HasBuffPremissions(BUFF_KEY, CLASS_MODULE) then
                return false
            end

            local spellName = MoronBox.Core.Buffs.GetBuffSpell(BUFF_KEY)
            local soloResult = MoronBox.Core.Buffs.SoloBuff(BUFF_KEY, spellName)

            if soloResult ~= nil then
                return soloResult
            end

            local targetUnitId, groupNum = MoronBox.Core.Buffs.GetNextTarget(Queue)

            if not targetUnitId then
                return false
            end

            if mb_isValidFriendlyTarget(targetUnitId, spellName) and not mb_hasBuffOrDebuff(spellName, targetUnitId, "buff") then
                if UnitIsFriend("player", targetUnitId) then
                    ClearTarget()
                end

                CastSpellByName(spellName, nil)
                SpellTargetUnit(targetUnitId)
                SpellStopTargeting()
                return true
            end

            Handlers.SendMessage("BUFFED_FEARWARD", string.format("BUFFED:%s:%d", targetUnitId, groupNum), 3)
            return false
        end,
    })
end, function()
    -- Load condition: only active for the required class, or when someone of that class is present.
    return MoronBox.Core.Buffs.UnLoad(CLASS_MODULE, RACE_MODULE)
end, function()
    MoronBox.Core.Buffs.Unregister(MODULE_NAME)
end)

-- [[ Macro Entry Points ]] --

-- Called to request the buff for the player's group.
function MoronBox.Core.Buffs.RequestFearWard()
    if Faction.IsHorde() then return end

    if MoronBox.Registry[MODULE_NAME] and MoronBox.Registry[MODULE_NAME].Request then
        MoronBox.Registry[MODULE_NAME].Request()
    end
end

-- Called to process the buff queue (cast on the next valid target).
function MoronBox.Core.Buffs.ProcessFearWard()
    if Faction.IsHorde() then return end

    if MoronBox.Registry[MODULE_NAME] and MoronBox.Registry[MODULE_NAME].Process then
        MoronBox.Registry[MODULE_NAME].Process()
    end
end

-- Called to register a custom priority function for a specific fight.
function FW_RegisterFearWardPriority(fightName, fn)
    if Faction.IsHorde() then return end

    if MoronBox.Registry[MODULE_NAME] and MoronBox.Registry[MODULE_NAME].Process then
        MoronBox.Registry[MODULE_NAME].OverridePriority(fightName, fn)
    end
end
