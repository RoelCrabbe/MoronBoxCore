-- [[ Event Values ]] --

local TradeWindowOpen       = { Active = false, Time = 0 }
local AutoBuyReagents       = { Active = false, Time = 0 }

-- [[ Local Helpers ]] --
local Original_TakeTaxiNode = TakeTaxiNode
local AutoFlyFollow         = { Time = 0, Node = "" }

-- Auto-Trade Items
local ItemToAutoTrade       = {
    -- Crafting Materials
    "Arcanite Bar",
    "Mooncloth",
    "Refined Deeprock Salt",
    "Deeprock Salt",
    "Cured Rugged Hide",
    "Arcane Crystal",
    "Thorium Bar",
    "Hourglass Sand",
    "Felcloth",

    -- Essences
    "Essence of Air",
    "Essence of Undeath",
    "Living Essence",
    "Essence of Water",
    "Essence of Earth",

    -- Consumables
    "Major Mana Potion",
    "Elixir of the Mongoose",
    "Greater Stoneshield Potion",
    "Greater Nature Protection Potion",
    "Greater Shadow Protection Potion",
    "Gift of Arthas",

    -- Food & Drink
    "Conjured.*Water",
    "Rumsey Rum Black Label",
    "Dirge\'s Kickin\' Chimaerok Chops",

    -- ZG Items
    ".*Hakkari Bijou",
}

local myName                = UnitName("player")
local myClass               = UnitClass("player")

-- [[ Core Hooking Logic ]] --
local function Wrapped_TakeTaxiNode(index)
    getApi().SendAddonMessage(getRaidId() .. "_flyTaxi", TaxiNodeName(index))
    Original_TakeTaxiNode(index)
end

-- [[ Auto-Follow Taxi Logic ]] --
local function TaxiUpdate()
    local time = GetTime()

    if getRaid().ImFocus() then
        return
    end

    if AutoFlyFollow.Time > time then
        for i = 1, NumTaxiNodes() do
            if TaxiNodeName(i) == AutoFlyFollow.Node then
                Original_TakeTaxiNode(i)
                break
            end
        end
    end
end

local function RemoveFeignDeath()
    CancelBuff("Feign Death")
    DoEmote("Stand")
    getConfigState().HunterFeign.Active = false
end

local function AssignHealerToName(assignments)
    local _, _, healerName, assignedTarget = string.find(assignments, "(%a+)%s*(%a+)")

    if getRaid().ImFocus() then
        if (assignedTarget == "Reset" or assignedTarget == "reset") then
            getApi().CdMessage("Unassigned " .. healerName .. " from healing a specific player.")
            return
        end

        getApi().CdMessage("Assigned " .. healerName .. " to heal " .. assignedTarget .. ".")
    end

    if myName == healerName then
        if (assignedTarget == "Reset" or assignedTarget == "reset") then
            getDebugger().InfoMsg("Unassigned myself to focusheal " .. getConfigState().AssignedHealTarget .. ".")
            getConfigState().AssignedHealTarget = nil
            return
        end

        getConfigState().AssignedHealTarget = assignedTarget
        getDebugger().InfoMsg("Assigning myself to focusheal " .. getConfigState().AssignedHealTarget .. ".")
    end
end

local function TankList(encounter)
    -- DO NOT PUT OTHER / GUEST TANKS ON HERE, ADD THEM in MB_extraTanks!!
    -- /tanklist <encounter> will trigger this function and run a preset list

    if not encounter or encounter == "" then
        print("Usage: /tanklist <encounter>")
        return
    end

    local faction = UnitFactionGroup("player")
    local presets = {
        Horde = {
            NRML    = { "Moron", "Suecia", "Ajlano", "Almisael", "Rows", "Sabo" },
            NAXX    = { "Moron", "Suecia", "Ajlano", "Almisael", "Rows", "Sabo", "Crymeariver", "Jokamok" },
            HEIGAN  = { "Moron", "Suecia", "Ajlano", "Almisael", "Rows", "Sabo" },
            DEFAULT = { "Moron", "Suecia", "Ajlano", "Almisael", "Rows", "Sabo" }
        },
        Alliance = {
            NRML    = { "Deadgods", "Drudish", "Gupy", "Bellamaya" },
            NAXX    = { "Deadgods", "Drudish", "Gupy", "Bellamaya", "Akileys", "Bestguy" },
            HEIGAN  = { "Deadgods", "Drudish", "Gupy", "Bellamaya" },
            DEFAULT = { "Deadgods", "Drudish", "Gupy", "Bellamaya" }
        }
    }

    local tanks = presets[faction] and presets[faction][encounter] or presets[faction] and presets[faction].DEFAULT or {}
    getSettingsState().TankList = tanks

    if IsRaidLeader() then
        getApi().CdMessage(encounter .. " Tanklist loaded.")
        for i, tank in ipairs(getSettingsState().TankList) do
            getApi().CdMessage(getApi().GetColors(getConfigState().RaidTargetNames[i]) .. " => " .. tank .. ".")
        end
    end

    getCore().InitializeClasslists()
end

-- [[ Main Events ]] --

local EventFrame = CreateFrame("Frame")

local MAIN_EVENTS = {
    "ADDON_LOADED",
    "TAXIMAP_OPENED",
    "CHAT_MSG_WHISPER",
    "PARTY_INVITE_REQUEST",
    "GOSSIP_SHOW",
    "GOSSIP_CLOSED",
    "MERCHANT_SHOW",
    "MERCHANT_CLOSED",
    "TRADE_SHOW",
    "TRADE_CLOSED",
    "START_LOOT_ROLL",
    "CONFIRM_SUMMON",
    "RESURRECT_REQUEST",
    "UI_ERROR_MESSAGE",
    "CHAT_MSG_ADDON",
    "PLAYER_REGEN_ENABLED"
}

do
    for _, evt in ipairs(MAIN_EVENTS) do
        EventFrame:RegisterEvent(evt)
    end
end

EventFrame:SetScript("OnEvent", function()
    if event == "ADDON_LOADED" and arg1 == "MoronBoxCore" then
        if not Faction.IsHorde() then
            getSettingsState().RaidInviter = getSettingsState().AllianceRaidInviter
        end

        TakeTaxiNode = Wrapped_TakeTaxiNode
    elseif event == "TAXIMAP_OPENED" then
        TaxiUpdate()
    elseif event == "CHAT_MSG_WHISPER" and arg1 == getSettingsState().InviteMessage then
        InviteByName(arg2)
    elseif event == "PARTY_INVITE_REQUEST" then
        AcceptGroup()
        StaticPopup_Hide("PARTY_INVITE")
        UIErrorsFrame:AddMessage("Group Auto Accept")
    elseif event == "GOSSIP_SHOW" then
        local tName = UnitName("target")
        local time = GetTime()

        if tName == "Sayge" then
            MoronBox.ExecuteSequenced(function()
                local option1, _, option2 = GetGossipOptions()
                if not option1 then return end

                if getCore().ImHealer() then
                    if option1 == "Yes" then
                        SelectGossipOption(1)
                    elseif option2 == "Turn him over to liege" or option2 == "Show not so quiet defiance" then
                        SelectGossipOption(2)
                    end
                elseif option1 == "Yes" or option1 == "Slay the Man" or option1 == "Execute your friend" then
                    SelectGossipOption(1)
                end
            end)
        elseif tName == "Lothos Riftwaker" then
            MoronBox.ExecuteSequenced(function()
                local option1 = GetGossipOptions()
                if not option1 then return end

                if option1 == "Teleport me to the Molten Core" then
                    SelectGossipOption(1)
                end
            end)
        elseif tName == "Teleportman" then
            MoronBox.ExecuteSequenced(function()
                local _, _, _, _, option3, _, option4 = GetGossipOptions()
                if not option3 then return end

                if option4 == "Raids" then
                    SelectGossipOption(4)
                elseif option3 == "Molten Core" then
                    SelectGossipOption(3)
                end
            end)
        elseif tName == "WorldBuffs" then
            MoronBox.ExecuteSequenced(function()
                local option1, _, option2 = GetGossipOptions()
                if not option1 then return end

                if getSettingsState().SteroidWorlBuffs then
                    if option2 == "Steroid WorldBuffs" then
                        SelectGossipOption(2)
                    end
                else
                    if option1 == "Normal WorldBuffs" then
                        SelectGossipOption(1)
                    end
                end
            end)
        elseif tName == "Majordomo Executus" then
            MoronBox.ExecuteSequenced(function()
                if GetGossipOptions() then
                    SelectGossipOption(1)
                end
            end, 0.5)
        elseif getTables().ReagentVendors() then
            AutoBuyReagents.Active = true
            AutoBuyReagents.Time = time + 0.2
        end
    elseif event == "GOSSIP_CLOSED" then
        AutoBuyReagents.Active = false
    elseif event == "MERCHANT_SHOW" then
        local tName = UnitName("target")
        local time = GetTime()

        print("Opened Merchant")

        if CanMerchantRepair() then
            if GetRepairAllCost() > GetMoney() then
                getApi().CdMessage("I need gold! Can\'t affort repairs!")
            else
                RepairAllItems()
            end
        end

        if getTables().ReagentVendors() then
            AutoBuyReagents.Active = true
            AutoBuyReagents.Time = time + 0.2
        end
    elseif event == "MERCHANT_CLOSED" then
        AutoBuyReagents.Active = false
    elseif event == "TRADE_SHOW" then
        getConfigState().TradeOpen = true
        TradeWindowOpen.Active = true
        TradeWindowOpen.Time = GetTime() + 1
    elseif event == "TRADE_CLOSED" then
        getConfigState().TradeOpen = nil
        TradeWindowOpen.Active = false
    elseif event == "START_LOOT_ROLL" then
        if getRaid().ImFocus() then
            return
        end

        RollOnLoot(arg1, 0)
    elseif event == "CONFIRM_SUMMON" then
        if getRaid().ImFocus() then
            return
        end

        ConfirmSummon()
        StaticPopup_Hide("CONFIRM_SUMMON")
    elseif event == "RESURRECT_REQUEST" then
        if getRaid().TankTarget("Bloodlord Mandokir") then
            return
        end

        AcceptResurrect()
        StaticPopup_Hide("RESURRECT_NO_TIMER")
        StaticPopup_Hide("RESURRECT_NO_SICKNESS")
        StaticPopup_Hide("RESURRECT")
    elseif event == "UI_ERROR_MESSAGE" then
        if arg1 == "You must be standing to do that" then
            if getUnit().ManaPct() > 0.99 or not getAura().HasBuffNamed("Drink", "player") or (getUnit().ManaPct() > 0.8 and getUnit().InCombat()) then
                DoEmote("Stand")
            end
        elseif arg1 == "Can't do that while moving" then
            if (getCore().ImHealer() or getCore().ImRangedDPS()) and not getConfigState().IsMoving.Active then
                getConfigState().IsMoving.Active = true
                getConfigState().IsMoving.Time = GetTime() + 1
            end
        elseif arg1 == "Target needs to be in front of you" then
            if Instance.BWL() and getRaid().IsAtRazorgore() and getRaid().IsAtRazorgorePhase() and getEncountersState().Razorgore.Active then
                getConfigState().RazorgoreNewTargetBecauseTargetIsBehind.Active = true
                getConfigState().RazorgoreNewTargetBecauseTargetIsBehind.Time = GetTime() + 3
            end
        elseif arg1 == "Out of range." or arg1 == "Target not in line of sight" then
            if Instance.AQ20() and getCore().ImHealer() and UnitName("target") == "Lieutenant General Andorov" then
                getConfigState().LieutenantAndorovIsNotHealable.Active = true
                getConfigState().LieutenantAndorovIsNotHealable.Time = GetTime() + 6
            end
        elseif arg1 == "You are facing the wrong way!" or arg1 == "You are too far away!" then
            if getRaid().TankTarget("Plague Beast") or getRaid().TankTarget("Onyxia") then
                getConfigState().TargetWrongWayOrTooFar.Active = true
                getConfigState().TargetWrongWayOrTooFar.Time = GetTime() + 1
            end
        end
    elseif event == "CHAT_MSG_ADDON" then
        local currentTime = GetTime()

        if arg1 == getRaidId() and arg2 == "MB_FOCUSME" and arg4 ~= myName then
            getConfigState().RaidLeader = arg4
            print("I\'m Focusing " .. getConfigState().RaidLeader)
        elseif arg1 == getRaidId() .. "_FTAR" then
            local focus = string.gsub(arg2, " .*", "")
            local focus_caller = string.gsub(arg2, "^%S- ", "")

            print("I\'m Focusing " .. focus .. " Previous tar: " .. focus_caller)
            getConfigState().RaidLeader = focus
        elseif arg1 == getRaidId() .. "_flyTaxi" and arg4 ~= myName then
            AutoFlyFollow.Time = currentTime + 30
            AutoFlyFollow.Node = arg2
            TaxiUpdate()
        elseif arg1 == getRaidId() and arg2 == "MB_USECOOLDOWNS" then
            if getUnit().InCombat() and not getConfigState().UseCooldowns.Active then
                getConfigState().UseCooldowns.Active = true
                getConfigState().UseCooldowns.Time = currentTime + 5
            end
        elseif arg1 == getRaidId() and arg2 == "MB_USERECKLESSNESS" then
            if getUnit().InCombat() and not getConfigState().UseBigCooldowns.Active then
                getConfigState().UseBigCooldowns.Active = true
                getConfigState().UseBigCooldowns.Time = currentTime + 5
            end
        elseif arg1 == getRaidId() .. "MB_REMOVEBUFFS" then
            if arg2 == "all" then
                local textleft1 = getglobal(MoronBoxTooltip:GetName() .. "TextLeft1")
                local text

                for i = 1, 32 do
                    MoronBoxTooltip:SetOwner(UIParent, "ANCHOR_NONE")
                    MoronBoxTooltip:SetUnitBuff("player", i)
                    text = textleft1:GetText()
                    MoronBoxTooltip:Hide()

                    if not text then
                        break
                    end

                    CancelBuff(text)
                end
            elseif arg2 and getAura().HasBuffOrDebuff(arg2, "player", "buff") then
                CancelBuff(arg2)
            end
        elseif arg1 == getRaidId() .. "MB_REMOVEBLESS" then
            if arg2 == "all" then
                local greaterBlessings = {
                    "Greater Blessing of Salvation",
                    "Greater Blessing of Might",
                    "Greater Blessing of Kings",
                    "Greater Blessing of Light",
                    "Greater Blessing of Wisdom",
                    "Greater Blessing of Sanctuary"
                }

                for _, blessing in ipairs(greaterBlessings) do
                    if getAura().HasBuffOrDebuff(blessing, "player", "buff") then
                        CancelBuff(blessing)
                    end
                end
            elseif arg2 and getAura().HasBuffOrDebuff(arg2, "player", "buff") then
                CancelBuff(arg2)
            end
        elseif arg1 == getRaidId() .. "_INT" then
            if arg2 == myName then
                local api = getApi()
                local state = getConfigState()

                AssistUnit(getCoreState().MBID[getConfigState().RaidLeader])

                if not UnitName("target") then
                    api.CdMessage("Im unable to be assigned to this target.")
                    return
                end

                if not state.InterruptTarget then
                    local targetIndex = GetRaidTargetIndex("target")
                    local targetName = state.RaidTargetNames[targetIndex]

                    if targetName then
                        api.SendChatMessage("I, " ..
                            api.GetColors(myName) .. " will be interrupting " .. api.GetColors(targetName))
                        state.InterruptTarget = targetIndex
                    end
                end
            end
        elseif arg1 == getRaidId() .. "_CC" then
            if arg2 == myName then
                local api = getApi()
                local state = getConfigState()

                AssistUnit(getCoreState().MBID[getConfigState().RaidLeader])

                if not UnitName("target") then
                    api.CdMessage("Im unable to be assigned to this target.")
                    return
                end

                if not state.CrowdControlTarget then
                    local targetIndex = GetRaidTargetIndex("target")
                    local targetName = state.RaidTargetNames[targetIndex]

                    if targetName then
                        api.SendChatMessage("I, " ..
                            api.GetColors(myName) .. " will be CCing " .. api.GetColors(targetName))
                        state.CrowdControlTarget = targetIndex
                    end
                end
            end
        elseif arg1 == getRaidId() .. "_FEAR" then
            if arg2 == myName then
                local api = getApi()
                local state = getConfigState()

                AssistUnit(getCoreState().MBID[getConfigState().RaidLeader])

                if not UnitName("target") then
                    api.CdMessage("Im unable to be assigned to this target.")
                    return
                end

                if not state.FearTarget then
                    local targetIndex = GetRaidTargetIndex("target")
                    local targetName = state.RaidTargetNames[targetIndex]

                    if targetName then
                        api.SendChatMessage("I, " ..
                            api.GetColors(myName) .. " will be Fearing " .. api.GetColors(targetName))
                        state.FearTarget = targetIndex
                    end
                end
            end
        elseif arg1 == getRaidId() .. "_OT" then
            if arg2 == myName then
                local api = getApi()
                local state = getConfigState()

                AssistUnit(getCoreState().MBID[getConfigState().RaidLeader])

                if not UnitName("target") then
                    api.CdMessage("Im unable to be assigned to this target.")
                    return
                end

                if not state.OffTankTarget then
                    local targetIndex = GetRaidTargetIndex("target")
                    local targetName = state.RaidTargetNames[targetIndex]

                    if targetName then
                        api.SendChatMessage("I, " ..
                            api.GetColors(myName) .. " will be tanking " .. api.GetColors(targetName))
                        state.OffTankTarget = targetIndex

                        if api.FindMyNameInTable(getSettingsState().FurysThatCanTank) then
                            getGear().TankGear()
                        end
                    end
                end
            end
        elseif arg1 == getRaidId() .. "CLR_TARG" then
            local api = getApi()
            local state = getConfigState()

            AssistUnit(getCoreState().MBID[arg2])

            local targetIndex = GetRaidTargetIndex("target")
            local targetName = state.RaidTargetNames[targetIndex]

            if targetName then
                if state.InterruptTarget and state.InterruptTarget == targetIndex then
                    api.SendChatMessage("I, " ..
                        api.GetColors(myName) .. " stopped interrupting " .. api.GetColors(targetName))
                    state.InterruptTarget = nil
                end

                if state.CrowdControlTarget and state.CrowdControlTarget == targetIndex then
                    api.SendChatMessage("I, " .. api.GetColors(myName) .. " stopped CCing " .. api.GetColors(targetName))
                    state.CrowdControlTarget = nil
                end

                if state.FearTarget and state.FearTarget == targetIndex then
                    api.SendChatMessage("I, " ..
                        api.GetColors(myName) .. " stopped fearing " .. api.GetColors(targetName))
                    state.FearTarget = nil
                end

                if state.OffTankTarget and state.OffTankTarget == targetIndex then
                    api.SendChatMessage("I, " ..
                        api.GetColors(myName) .. " stopped tanking " .. api.GetColors(targetName))
                    state.OffTankTarget = nil
                    if api.FindMyNameInTable(getSettingsState().FurysThatCanTank) then
                        getGear().FuryGear()
                    end
                end
            end
        elseif arg1 == getRaidId() .. "MB_ASSIGNHEALER" then
            AssignHealerToName(arg2)
        elseif arg1 == getRaidId() and arg2 == "MB_NEFCLOAK" then
            if getBag().GetItemNameOfEquippedSlot(15) == "Onyxia Scale Cloak" then
                return
            end

            if not getBag().HaveInBags("Onyxia Scale Cloak") then
                getApi().CdMessage("I don\'t have a Onyxia Scale Cloak")
                return
            end

            UseItemByName("Onyxia Scale Cloak")
        elseif arg1 == getRaidId() .. "MB_TANKLIST" then
            TankList(string.upper(arg2))
        elseif arg1 == getRaidId() .. "MB_GEAR" then
            getGear().EquipRackSet(string.upper(arg2))
        elseif arg1 == getRaidId() and arg2 == "MB_REPORTMANAPOTS" then
            getReport().Manapots()
        elseif arg1 == getRaidId() and arg2 == "MB_REPORTSHARDS" then
            getReport().Shards()
        elseif arg1 == getRaidId() and arg2 == "MB_REPORTRUNES" then
            getReport().Runes()
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        getConfigState().TrackCooldowns         = {}

        getConfigState().OffTankIndex           = 1
        getConfigState().OffTankTarget          = nil

        getConfigState().InterruptTarget        = nil
        getConfigState().CurrentInterrupt       = {
            Rogue = 1,
            Mage = 1,
            Shaman = 1
        }

        getConfigState().CrowdControlTarget     = nil
        getConfigState().CurrentCC              = {
            Mage = 1,
            Warlock = 1,
            Priest = 1,
            Druid = 1
        }

        getConfigState().FearTarget             = nil
        getConfigState().CurrentFear            = {
            Warlock = 1
        }

        getConfigState().CurrentRaidTarget      = 1
        getConfigState().DoInterrupt.Active     = false
        getConfigState().UseCooldowns.Active    = false
        getConfigState().UseBigCooldowns.Active = false

        if not getRaid().ImFocus() then
            getUnit().ClearTargetIfNotAggroed()
        end

        if getConfigState().WarriorBinds == "Fury" and getCore().ImMeleeDPS() then
            if getApi().FindMyNameInTable(getSettingsState().FurysThatCanTank) then
                getGear().FuryGear()
            end
        end

        if myClass == "Mage" then
            getGear().MageGear()
        end

        local x = GetCVar("targetNearestDistance")
        if x == "10" then
            SetCVar("targetNearestDistance", "41")
        end
    end
end)

EventFrame:SetScript("OnUpdate", function()
    local currentTime = GetTime()

    if TradeWindowOpen.Active and currentTime > TradeWindowOpen.Time then
        for i = 0, 6 do
            for _, item in pairs(ItemToAutoTrade) do
                if getConfigState().TradeOpen and GetTradeTargetItemLink(i) and string.find(GetTradeTargetItemLink(i), item) then
                    AcceptTrade()
                    return
                end

                if getConfigState().TradeOpen and GetTradePlayerItemLink(i) and string.find(GetTradePlayerItemLink(i), item) then
                    AcceptTrade()
                    return
                end
            end
        end
    end

    if AutoBuyReagents.Active and currentTime > AutoBuyReagents.Time then
        getCons().BuyReagentsAndConsumables()
        AutoBuyReagents.Active = false
    end

    if getConfigState().HunterFeign.Active and currentTime > getConfigState().HunterFeign.Time then
        RemoveFeignDeath()
    end

    local TimersToCheck = {
        getConfigState().LieutenantAndorovIsNotHealable,
        getConfigState().RazorgoreNewTargetBecauseTargetIsBehind,
        getConfigState().TargetWrongWayOrTooFar,
        getConfigState().AutoToggleCC,
        getConfigState().UseCooldowns,
        getConfigState().UseBigCooldowns,
        getConfigState().DoInterrupt,
        getConfigState().IsMoving
    }

    for _, action in ipairs(TimersToCheck) do
        if action.Active and currentTime > action.Time then
            action.Active = false
        end
    end
end)
