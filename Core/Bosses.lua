-- Core/Bosses.lua
MoronBox.Core.Bosses = MoronBox.Core.Bosses or {}
local LoadedBossModules = {}

function getBosses()
    return MoronBox.Core.Bosses
end

function MoronBox.Core.Bosses.Register(name, config)
    if LoadedBossModules[name] then
        return
    end

    local BossDispatch = CreateFrame("Frame")

    local BOSS_EVENTS = {
        "CHAT_MSG_ADDON",
        "CHAT_MSG_COMBAT_HOSTILE_DEATH",
        "CHAT_MSG_MONSTER_YELL",
        "PLAYER_REGEN_ENABLED",
        "CHAT_MSG_COMBAT_SELF_HITS",
        "CHAT_MSG_COMBAT_SELF_MISSES",
        "CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS",
        "CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES",
        "CHAT_MSG_SPELL_SELF_DAMAGE",
        "CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE",
    }

    do
        for _, evt in ipairs(BOSS_EVENTS) do
            if config.onBossYell and evt == "CHAT_MSG_COMBAT_HOSTILE_DEATH" then
                -- Skip
            elseif not config.onBossYell and evt == "CHAT_MSG_MONSTER_YELL" then
                -- Skip
            else
                BossDispatch:RegisterEvent(evt)
            end
        end
    end

    -- doDeath is nog niet defined, pas erna kunnen we het erin steken
    local session = { config = config, Active = false, frame = BossDispatch }

    local function doEngage()
        if session.Active then
            return
        end

        session.Active = true
        if config.onEngage then
            config.onEngage()
        end
    end

    session.doEngage = doEngage

    local function doDisengage()
        if session.Active then
            session.Active = false
            if config.onDisengage then
                config.onDisengage()
            end
        end
    end

    session.doDisengage = doDisengage

    local function doDeath()
        session.Dead = true
        BossDispatch:UnregisterAllEvents()
        doDisengage()
    end

    session.doDeath = doDeath

    local function doReset()
        if session.Dead then
            return
        end

        doDisengage()
    end

    session.doReset = doReset

    local function onYellMsg()
        if session.Active and config.onBossYell then
            config.onBossYell(arg1)
        end
    end

    local function matchesAnyName(nameList)
        if not nameList then
            return false
        end

        for _, n in ipairs(nameList) do
            if string.find(arg1, "^" .. n .. " %l") then
                return true
            end
        end

        return false
    end

    local function detectedByHit()
        return matchesAnyName(config.boss) or matchesAnyName(config.guardians)
    end

    local function detectedByDeath()
        for _, bossName in ipairs(config.boss) do
            if string.find(arg1, bossName, 1, true) then
                return true
            end
        end
        return false
    end

    local function onAddonMsg()
        if arg1 ~= "MB_ENCOUNTER_" .. name then
            return
        end

        if arg2 == "ENGAGE" then
            doEngage()
        elseif arg2 == "DEATH" then
            doDeath()
        end
    end

    local function onDeathMsg()
        if session.Active and detectedByDeath() then
            getApi().CdAddonMessage("MB_ENCOUNTER_" .. name, "DEATH", 30)
            doDeath()
        end
    end

    local function onHit()
        if session.Active or session.Dead then
            return
        end

        if detectedByHit() then
            getApi().CdAddonMessage("MB_ENCOUNTER_" .. name, "ENGAGE", 30)
            doEngage()
        end
    end

    local eventHandlers = {
        CHAT_MSG_ADDON = onAddonMsg,
        CHAT_MSG_COMBAT_HOSTILE_DEATH = onDeathMsg,
        CHAT_MSG_MONSTER_YELL = onYellMsg,
        PLAYER_REGEN_ENABLED = doReset,
        CHAT_MSG_COMBAT_SELF_HITS = onHit,
        CHAT_MSG_COMBAT_SELF_MISSES = onHit,
        CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS = onHit,
        CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES = onHit,
        CHAT_MSG_SPELL_SELF_DAMAGE = onHit,
        CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE = onHit,
    }

    BossDispatch:SetScript("OnEvent", function()
        local handler = eventHandlers[event]
        if handler then handler() end
    end)

    LoadedBossModules[name] = session
end

function MoronBox.Core.Bosses.IsActive(name)
    local session = LoadedBossModules[name]
    return session ~= nil and session.Active
end

function MoronBox.Core.Bosses.ExecuteActive(name)
    local session = LoadedBossModules[name]
    if session ~= nil and session.Active and session.config.onActive then
        session.config.onActive()
    end
end

function MoronBox.Core.Bosses.EndEncounter(name)
    local session = LoadedBossModules[name]
    if session ~= nil and session.Active and session.doDeath then
        getApi().CdAddonMessage("MB_ENCOUNTER_" .. name, "DEATH", 30)
        session.doDeath()
    end
end
