-- [[ Power Infusion Buffing ]] --
---@diagnostic disable: undefined-global

-- The buff key used to look up spell/aura data (BUFF_AURA_NAMES, BUFF_CAST_SPELLS).
local BUFF_KEY = "PowerInfusion"

-- The class permitted to cast this buff.
local CLASS_MODULE = "Priest"
local RACE_MODULE = nil

-- Unique module/addon-message prefix, derived from BUFF_KEY to avoid drift.
local MODULE_NAME = "MODULE_" .. string.upper(string.gsub(BUFF_KEY, " ", "_"))

-- Frame reference, assigned on module registration.
local PowerInfusion

-- Minimum mana required to be considered a valid cast candidate.
local POWER_INFUSION_MANA_COST = 250 * 0.95

-- Discovery cooldown: how it works differs from Request/Claim messages.
-- "Who can cast X" answers rarely change within a session (only on respec
-- or roster change), so a long cooldown avoids re-asking a question whose
-- answer almost never changes, unlike buff requests which are always
-- time-sensitive and per-instance.
local DISCOVERY_COOLDOWN = 300 -- 5 minutes

MoronBox:RegisterModule(MODULE_NAME, function()
    local Queue = {}
    local ClaimedQueue = {}
    local PowerInfusionPriests = {}
    local PriorityOverrides = {}

    PowerInfusion = Register(MODULE_NAME)
    PowerInfusion:RegisterEvent("RAID_ROSTER_UPDATE")
    PowerInfusion:RegisterEvent("PARTY_MEMBERS_CHANGED")

    local Handlers = CreateHandlers({
        AddonPrefix = MODULE_NAME,
        BuffKey = BUFF_KEY,
        Queue = Queue,
        ClaimedQueue = ClaimedQueue,
        CapableList = PowerInfusionPriests,
    })

    PowerInfusion:SetScript("OnEvent", function()
        if event == "CHAT_MSG_ADDON" then
            if not Handlers.IsOwnMessage(arg1) then return end
            DispatchMessage(arg2, arg4, Handlers)
        elseif event == "RAID_ROSTER_UPDATE" or event == "PARTY_MEMBERS_CHANGED" then
            ClearTable(PowerInfusionPriests)
        end
    end)

    MoronBox:RegisterExpose({
        -- Overrides the priority for a specific fight, preventing accidental duplicates.
        OverridePriority = function(fightName, fn)
            if PriorityOverrides[fightName] then
                WarnMsg("Priority override already exists for: " .. fightName)
                return
            end

            PriorityOverrides[fightName] = fn
        end,

        -- Broadcasts a request for this buff if not already active.
        Request = function()
            if HasActiveBuff(BUFF_KEY) then
                return
            end

            local spellName = GetBuffSpell(BUFF_KEY)

            if table.getn(PowerInfusionPriests) == 0 then
                Handlers.RequestCapable(spellName, DISCOVERY_COOLDOWN)
                return
            end

            local group = GetGroupNumber()
            local member = GetMemberForGroup(PowerInfusionPriests, group, RACE_MODULE,
                POWER_INFUSION_MANA_COST)

            if not member then
                WarnMsg("No " .. CLASS_MODULE .. " found")
                return
            end

            local prio = GetCustomPriority(PriorityOverrides,
                {
                    ["Mage"] = "HIGH",
                    ["Warlock"] = "MEDIUM",
                }
            )

            Handlers.SendMessage("NEED_POWERINFUSION", string.format("BUFF_INFO:%d:%d:%s", prio, group, member), 9)
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

            Handlers.SendMessage("BUFFED_POWERINFUSION", string.format("BUFFED:%s:%d", targetUnitId, groupNum), 3)
            return false
        end,
    })
end, function()
    -- Load condition: only active for the required class, or when someone of that class is present.
    return UnLoad(CLASS_MODULE, RACE_MODULE)
end, function()
    Unregister(MODULE_NAME)
end)

-- POWER INFUSION BUFF SYSTEM - COMPLETE FLOW
-- ===========================================
-- 0. DISCOVERY PHASE (only if CapableList is empty)
--    ┌─────────────────────────────────────────────────┐
--    │ Player has no known Power Infusion casters yet:  │
--    │ ├─ Check: CapableList empty? → trigger discovery │
--    │ ├─ Resolve: PriorityBuff spell via BUFF_KEY       │
--    │ ├─ Broadcast: "ANYONE_CAPABLE_TO_CAST:SpellName" │
--    │ └─ EXIT — actual request happens on a future     │
--    │           Request() call once someone responds   │
--    └─────────────────────────────────────────────────┘
--                             ↓
--    ┌─────────────────────────────────────────────────┐
--    │ Any client receives the discovery broadcast:     │
--    │ ├─ Filter: Message prefix belongs to this module?│
--    │ │          (IsOwnMessage check) → else IGNORE    │
--    │ ├─ Check: Do I know this spell? (mb_knowSpell)   │
--    │ └─ If yes: Broadcast "CAPABLE_TO_CAST:MyName"    │
--    └─────────────────────────────────────────────────┘
--                             ↓
--    ┌─────────────────────────────────────────────────┐
--    │ All clients receive a capability announcement:   │
--    │ ├─ Check: Name already in CapableList? → SKIP    │
--    │ ├─ Add: Insert name into CapableList              │
--    │ └─ Sort: Keep CapableList alphabetically sorted   │
--    │          (no separate build phase like ClassList, │
--    │          so it's sorted incrementally on insert)  │
--    └─────────────────────────────────────────────────┘
--
-- 1. REQUEST PHASE (only once CapableList is populated)
--    ┌─────────────────────────────────────────────────┐
--    │ Player needs Power Infusion:                     │
--    │ ├─ Check: Already have buff? → EXIT              │
--    │ ├─ Check: CapableList empty? → back to Discovery │
--    │ ├─ Get: Player group number (1-8)                │
--    │ ├─ Select: Assigned caster via deterministic      │
--    │ │          round-robin over CapableList           │
--    │ │          (groupNum mod eligible-caster-count)   │
--    │ │          Eligible = alive, mana >= required,    │
--    │ │          and race match (if RACE_MODULE is set) │
--    │ ├─ Calculate: Priority via overridable fight-      │
--    │ │             specific function, else class-based │
--    │ │             default (Mage=HIGH, Warlock=MEDIUM) │
--    │ └─ Send: "BUFF_INFO:Priority:GroupNum:Caster"    │
--    │          (prefixed with this module's AddonPrefix)│
--    └─────────────────────────────────────────────────┘
--                             ↓
-- 2. CLAIM PHASE
--    ┌─────────────────────────────────────────────────┐
--    │ Assigned caster receives request:                │
--    │ ├─ Filter: Message prefix belongs to this module?│
--    │ │          (IsOwnMessage check) → else IGNORE    │
--    │ ├─ Validate: Am I the assigned caster?           │
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
--    │ Caster processes queue (on each Process() call): │
--    │ ├─ Check: Has permissions to cast? (class,       │
--    │ │         not busy, spell ready)                 │
--    │ ├─ Scan: Find lowest priority number (highest    │
--    │ │        priority) across all queued groups      │
--    │ ├─ Get: GroupNum from queue entry                │
--    │ ├─ Validate: Target is a valid friendly target    │
--    │ │            and not already buffed              │
--    │ ├─ Cast: Power Infusion on target                 │
--    │ └─ Broadcast: "BUFFED:UnitId:GroupNum"           │
--    └─────────────────────────────────────────────────┘
--                             ↓
-- 4. RELEASE PHASE
--    ┌─────────────────────────────────────────────────┐
--    │ All casters receive buff completion:              │
--    │ ├─ Release: Remove unitId from group queue        │
--    │ │           (only if we were the sender)          │
--    │ └─ Clean: Remove group claim (ClaimedQueue[n]=nil)│
--    └─────────────────────────────────────────────────┘
--
-- KEY DATA STRUCTURES
-- ==================
-- CapableList (local, per module instance) = {
--     "PriestNameA",             -- Discovered casters, alphabetically sorted
--     "PriestNameB"              -- Persists per session; not rebuilt on roster
--                                -- changes like ClassList is — a caster who
--                                -- disconnects stays listed until eligibility
--                                -- filtering excludes them at selection time
-- }
--
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
--     [1] = "PriestA",          -- GroupNum → Claiming caster (SHARED via addon)
--     [2] = "PriestB"
-- }
--
-- PriorityOverrides (local, per module instance) = {
--     ["Onyxia"] = function() return 10 end  -- Registered via OverridePriority()
-- }
--
-- WHY DISCOVERY EXISTS (vs. Fortitude's direct ClassList lookup)
-- ================================================================
-- Fortitude's caster pool is any Priest — derivable directly from
-- MoronBox.Core.State.ClassList["Priest"], no runtime discovery needed.
-- Power Infusion's caster pool is a TALENT-gated subset of Priests, which
-- isn't derivable from class/race alone — it's only known once a Priest
-- confirms it via mb_knowSpell. Hence the Discovery phase, and hence
-- GetMemberForGroup (an arbitrary-list variant of GetClassMemberForGroup)
-- instead of a class-name lookup.
--
-- COLLISION PREVENTION
-- ===================
-- Group-based claim system → One caster per group, prevents duplicates
-- Claim validation → Only claim if group not already claimed
-- Deterministic assignment → GetMemberForGroup maps groupNum to a caster
--                             via round-robin over CapableList, so all
--                             clients independently agree on who's
--                             responsible, without additional messaging
-- Eligibility filtering → Only alive casters with enough mana (and matching
--                          race, if configured) are considered at selection
-- Prefix-based message filtering → IsOwnMessage ensures a module only
--                                   processes its own addon messages,
--                                   isolating it from other buff modules
-- Discovery cooldown → RequestCapable is rate-limited (15s) via
--                       CdAddonMessage, so repeated Request() calls while
--                       CapableList is still empty don't spam broadcasts
-- Auto-cleanup → Removes buffed targets from queue via addon messages
-- Group limit enforcement → Max 8 groups enforced by raid structure
--
-- PERFORMANCE OPTIMIZATIONS
-- ========================
-- Nested hash table queue → O(1) lookup/insert/delete per group
-- Single split parse → Fast message parsing via StringSplit + schema mapping
-- Sender from arg4 → No message spoofing possible
-- MBID system → Accurate unit targeting per client
-- Incremental sort on discovery → CapableList stays sorted without a
--                                  separate build phase (small n, negligible cost)
-- Group-level processing → Batch handle groups, not individual players
-- Event-driven cleanup → All state management in event handlers
-- Direct group access → No need to search all groups for targets

-- [[ Macro Entry Points ]] --
---@diagnostic enable: undefined-global

-- Called to request the buff for the player's group.
function MoronBox.Core.Buffs.RequestPowerInfusion()
    if not getUnit().IsManaUser() then
        return
    end

    if MoronBox.Registry[MODULE_NAME] and MoronBox.Registry[MODULE_NAME].Request then
        MoronBox.Registry[MODULE_NAME].Request()
    end
end

-- Called to process the buff queue (cast on the next valid target).
function MoronBox.Core.Buffs.ProcessPowerInfusion()
    if MoronBox.Registry[MODULE_NAME] and MoronBox.Registry[MODULE_NAME].Process then
        MoronBox.Registry[MODULE_NAME].Process()
    end
end

-- Called to register a custom priority function for a specific fight.
function MoronBox.Core.Buffs.PriorityPowerInfusion(fightName, fn)
    if MoronBox.Registry[MODULE_NAME] and MoronBox.Registry[MODULE_NAME].Process then
        MoronBox.Registry[MODULE_NAME].OverridePriority(fightName, fn)
    end
end
