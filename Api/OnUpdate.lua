--[####################################################################################################]--
--[########################################### OnUpdate Core ##########################################]--
--[####################################################################################################]--

-- Unit Functions
local UnitName = UnitName
local UnitClass = UnitClass
local UnitRace = UnitRace
local UnitLevel = UnitLevel
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitMana = UnitMana
local UnitManaMax = UnitManaMax
local UnitPowerType = UnitPowerType
local UnitExists = UnitExists
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitIsDead = UnitIsDead
local UnitIsGhost = UnitIsGhost
local UnitIsConnected = UnitIsConnected
local UnitInParty = UnitInParty
local UnitInRaid = UnitInRaid
local UnitCanAttack = UnitCanAttack
local UnitIsFriend = UnitIsFriend
local UnitIsEnemy = UnitIsEnemy
local UnitIsVisible = UnitIsVisible
local UnitAffectingCombat = UnitAffectingCombat
local UnitCreatureType = UnitCreatureType
local UnitClassification = UnitClassification

-- Buff/Debuff Functions
local UnitBuff = UnitBuff
local UnitDebuff = UnitDebuff

-- Spell Functions
local CastSpellByName = CastSpellByName
local GetSpellCooldown = GetSpellCooldown
local IsCurrentAction = IsCurrentAction

-- Target Functions
local TargetUnit = TargetUnit
local TargetByName = TargetByName
local ClearTarget = ClearTarget
local AssistUnit = AssistUnit

-- Party/Raid Functions
local GetNumPartyMembers = GetNumPartyMembers
local GetNumRaidMembers = GetNumRaidMembers
local GetRaidRosterInfo = GetRaidRosterInfo
local IsRaidLeader = IsRaidLeader

-- Player Position/Info Functions
local GetRealZoneText = GetRealZoneText
local GetSubZoneText = GetSubZoneText

-- Addon Communication (if supported on your server)
local SendAddonMessage = SendAddonMessage

-- Misc Utility Functions
local IsShiftKeyDown = IsShiftKeyDown
local IsControlKeyDown = IsControlKeyDown
local IsAltKeyDown = IsAltKeyDown

-- Common Names
local myClass = UnitClass("player")
local myName = UnitName("player")
local myRace = UnitRace("player")

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function MMB:OnUpdate()
    local currentTime = GetTime()
    
    if MB_tradeOpenOnUpdate.Active and currentTime > MB_tradeOpenOnUpdate.Time then
        for i = 0, 6 do
            for k, item in pairs(MB_itemToAutoTrade) do
                if MB_tradeOpen then
                    local targetLink = GetTradeTargetItemLink(i)
                    local playerLink = GetTradePlayerItemLink(i)
                    
                    if (targetLink and targetLink:find(item)) or (playerLink and playerLink:find(item)) then
                        AcceptTrade()
                        return
                    end
                end
            end
        end
    end
    
    if MB_DMFWeek and MB_DMFWeek.Active and currentTime > MB_DMFWeek.Time then
        MB_DMFWeek.Active = false
        local option1, _, option2 = GetGossipOptions()
       
        if mb_imHealer() then
            if option1 == "Yes" then
                SelectGossipOption(1)
            elseif option2 == "Turn him over to liege" or option2 == "Show not so quiet defiance" then
                SelectGossipOption(2)
            end
        elseif option1 == "Yes" or option1 == "Slay the Man" or option1 == "Execute your friend" then
            SelectGossipOption(1)
        end
    end
    
    if MB_MCEnter.Active and currentTime > MB_MCEnter.Time then
        MB_MCEnter.Active = false
        if GetGossipOptions() == "Teleport me to the Molten Core" then              
            SelectGossipOption(1)
        end
    end
    
    local TimersToCheck = {
        MB_razorgoreNewTargetBecauseTargetIsBehindOrOutOfRange,
        MB_lieutenantAndorovIsNotHealable,
        MB_razorgoreNewTargetBecauseTargetIsBehind,
        MB_targetWrongWayOrTooFar,
        MB_autoToggleSheeps,
        MB_autoBuff,
        MB_useCooldowns,
        MB_useBigCooldowns,
        MB_doInterrupt,
        MB_isMoving
    }
    
    for _, action in ipairs(TimersToCheck) do
        if action.Active and currentTime > action.Time then
            action.Active = false
        end
    end
    
    if MB_autoBuyReagents.Active and currentTime > MB_autoBuyReagents.Time then
        mb_buyReagentsAndArrows()
    end
    
    if MB_hunterFeign.Active and currentTime > MB_hunterFeign.Time then
        mb_removeFeignDeath()
    end
end

MMB:SetScript("OnUpdate", MMB.OnUpdate)

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function mb_removeFeignDeath()
	CancelBuff("Feign Death")
	DoEmote("Stand")
	MB_hunterFeign.Active = false
end