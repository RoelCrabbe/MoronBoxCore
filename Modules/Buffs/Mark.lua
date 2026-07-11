-- [[ Mark of the Wild Buffing ]] --

-- The buff key used to look up spell/aura data (BUFF_AURA_NAMES, BUFF_CAST_SPELLS).
local BUFF_KEY = "MarkOfTheWild"

-- The class permitted to cast this buff.
local CLASS_MODULE = "Druid"

-- Unique module/addon-message prefix, derived from BUFF_KEY to avoid drift.
local MODULE_NAME = "MODULE_" .. string.upper(string.gsub(BUFF_KEY, " ", "_"))

-- Frame reference, assigned on module registration.
local MarkOfTheWild

-- Minimum mana required to be considered a valid cast candidate.
local MARK_MANA_COST = 1200 * 0.95

MoronBox:RegisterModule(MODULE_NAME, function()
    local Queue = {}
    local ClaimedQueue = {}

    MarkOfTheWild = MoronBox.Api.Buffs.Register(MODULE_NAME)

    local Handlers = MoronBox.Api.Buffs.CreateHandlers({
        AddonPrefix = MODULE_NAME,
        BuffKey = BUFF_KEY,
        Queue = Queue,
        ClaimedQueue = ClaimedQueue
    })

    MarkOfTheWild:SetScript("OnEvent", function()
        if event ~= "CHAT_MSG_ADDON" then return end
        if not Handlers.IsOwnMessage(arg1) then return end
        MoronBox.Api.Buffs.DispatchMessage(arg2, arg4, Handlers)
    end)

    MoronBox:RegisterExpose({
        -- Broadcasts a request for this buff if not already active.
        Request = function()
            if MoronBox.Api.Buffs.HasActiveBuff(BUFF_KEY) then
                return
            end

            local group = MoronBox.Api.Buffs.GetGroupNumber()
            local member = MoronBox.Api.Buffs.GetClassMemberForGroup(CLASS_MODULE, group, MARK_MANA_COST)

            if not member then
                MoronBox.Debugger:Warn("No " .. CLASS_MODULE .. " found")
                return
            end

            local prio = MoronBox.Api.Buffs.GetPriority(
                {
                    ["Shaman"] = "HIGH",
                    ["Mage"] = "MEDIUM",
                }
            )

            Handlers.SendMessage("NEED_MOTW", string.format("BUFF_INFO:%d:%d:%s", prio, group, member), 9)
        end,

        -- Handles the solo cast, then the queue: casts on the next valid target
        -- or notifies the group if that target is already buffed.
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

                CastSpellByName(spellName, nil)
                SpellTargetUnit(targetUnitId)
                SpellStopTargeting()
                return true
            end

            Handlers.SendMessage("BUFFED_MOTW", string.format("BUFFED:%s:%d", targetUnitId, groupNum), 3)
            return false
        end,
    })
end, function()
    -- Load condition: only active for the required class, or when someone of that class is present.
    return MoronBox.Api.Buffs.UnLoad(CLASS_MODULE)
end, function()
    MoronBox.Api.Buffs.Unregister(MODULE_NAME)
end)

-- FORTITUDE BUFF SYSTEM - COMPLETE FLOW
-- ======================================
-- 0. SOLO PHASE
--    ┌─────────────────────────────────────────────────┐
--    │ Player is not in a group or raid:                │
--    │ ├─ Check: Already have buff? → EXIT              │
--    │ ├─ Cast: SecondaryBuff (Power Word: Fortitude)   │
--    │ │        directly on self, no messaging involved │
--    │ └─ No Request/Queue/Claim logic applies          │
--    └─────────────────────────────────────────────────┘
--
-- 1. REQUEST PHASE
--    ┌─────────────────────────────────────────────────┐
--    │ Player needs Fortitude (in a group/raid):        │
--    │ ├─ Check: Already have buff? → EXIT              │
--    │ ├─ Get: Player group number (1-8)                │
--    │ ├─ Select: Assigned Druid for this group via    │
--    │ │          deterministic round-robin             │
--    │ │          (groupNum mod eligible-druid-count)  │
--    │ │          Eligible = alive, connected, and      │
--    │ │          mana >= FORTITUDE_MANA_COST            │
--    │ ├─ Calculate: Self-priority (10=Shaman,          │
--    │ │             ... , 40=default)                  │
--    │ └─ Send: "BUFF_INFO:Priority:GroupNum:Druid"    │
--    │          (prefixed with this module's AddonPrefix)│
--    └─────────────────────────────────────────────────┘
--                             ↓
-- 2. CLAIM PHASE
--    ┌─────────────────────────────────────────────────┐
--    │ Assigned Druid receives request:                │
--    │ ├─ Filter: Message prefix belongs to this module?│
--    │ │          (IsOwnMessage check) → else IGNORE    │
--    │ ├─ Validate: Am I the assigned druid?           │
--    │ ├─ Check: Target already has buff? → NOTIFY only │
--    │ ├─ Check: Group already claimed? → EXIT          │
--    │ ├─ Create: Group queue if needed                 │
--    │ ├─ Queue: Add to Queue[groupNum][unitId]         │
--    │ ├─ CLAIM: Broadcast "CLAIMING_GROUP:GroupNum"    │
--    │ └─ Record: Mark in ClaimedQueue[groupNum]        │
--    └─────────────────────────────────────────────────┘
--                             ↓
-- 3. PROCESSING PHASE
--    ┌─────────────────────────────────────────────────┐
--    │ Druid processes queue (on each Process() call): │
--    │ ├─ Check: Has permissions to cast? (class,       │
--    │ │         not busy, spell ready)                 │
--    │ ├─ Scan: Find lowest priority number (highest    │
--    │ │        priority) across all queued groups      │
--    │ ├─ Get: GroupNum from queue entry                │
--    │ ├─ Validate: Target is a valid friendly target    │
--    │ │            and not already buffed              │
--    │ ├─ Cast: Prayer of Fortitude on target            │
--    │ └─ Broadcast: "BUFFED:UnitId:GroupNum"           │
--    └─────────────────────────────────────────────────┘
--                             ↓
-- 4. RELEASE PHASE
--    ┌─────────────────────────────────────────────────┐
--    │ All Priests receive buff completion:              │
--    │ ├─ Release: Remove unitId from group queue        │
--    │ │           (only if we were the sender)          │
--    │ └─ Clean: Remove group claim (ClaimedQueue[n]=nil)│
--    └─────────────────────────────────────────────────┘
--
-- KEY DATA STRUCTURES
-- ==================
-- Queue (local, per module instance) = {
--     [1] = {                    -- GroupNum
--         ["raid1"] = 10,        -- unitId → priority
--         ["raid2"] = 20
--     },
--     [2] = {
--         ["raid6"] = 5,
--         ["raid7"] = 15
--     }
--     -- Max 8 groups (raid size limit)
-- }
--
-- ClaimedQueue (local, per module instance) = {
--     [1] = "PriestA",          -- GroupNum → Claiming Druid (SHARED via addon)
--     [2] = "PriestB"
-- }
--
-- COLLISION PREVENTION
-- ===================
-- Group-based claim system → One druid per group, prevents duplicates
-- Claim validation → Only claim if group not already claimed
-- Deterministic assignment → GetClassMemberForGroup maps groupNum to a druid
--                             via round-robin, so all clients independently
--                             agree on who's responsible, without messaging
-- Eligibility filtering → Only alive, connected priests with enough mana
--                          are considered when assigning a group
-- Prefix-based message filtering → IsOwnMessage ensures a module only
--                                   processes its own addon messages,
--                                   isolating it from other buff modules
-- Priority queue → Ensures important class buffs first (Shaman > ... > default)
-- Auto-cleanup → Removes buffed targets from queue via addon messages
-- Group limit enforcement → Max 8 groups enforced by raid structure
--
-- PERFORMANCE OPTIMIZATIONS
-- ========================
-- Nested hash table queue → O(1) lookup/insert/delete per group
-- Single split parse → Fast message parsing via StringSplit + schema mapping
-- Sender from arg4 → No message spoofing possible
-- MBID system → Accurate unit targeting per client
-- Group-level processing → Batch handle groups, not individual players
-- Event-driven cleanup → All state management in event handlers
-- Direct group access → No need to search all groups for targets

-- [[ Macro Entry Points ]] --

-- Called to request the buff for the player's group.
function MOTW_RequestMarkOfTheWild()
    if MoronBox.Registry[MODULE_NAME] and MoronBox.Registry[MODULE_NAME].Request then
        MoronBox.Registry[MODULE_NAME].Request()
    end
end

-- Called to process the buff queue (cast on the next valid target).
function MOTW_ProcessMarkOfTheWildQueue()
    if MoronBox.Registry[MODULE_NAME] and MoronBox.Registry[MODULE_NAME].Process then
        MoronBox.Registry[MODULE_NAME].Process()
    end
end
