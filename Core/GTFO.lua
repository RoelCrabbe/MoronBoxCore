--[####################################################################################################]--
--[############################################ GTFO CODE! ############################################]--
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

function mb_GTFO()
    if not MB_raidAssist.GTFO.Active then
        return
    end

    mb_useSandsOnChromaggus()

    if mb_imFocus() then
        return
    end

    if Instance.ONY() and MB_myOnyxiaBoxStrategy then
        if mb_tankTarget("Onyxia") and (mb_tankTargetHealth() <= 0.65 and mb_tankTargetHealth() >= 0.4) and myName ~= MB_myOnyxiaMainTank then
            if mb_focusAggro() then
                if myClass == "Paladin" and mb_spellReady("Divine Shield") then
                    CastSpellByName("Divine Shield")
                    return
                end

                local ozTank = mb_returnPlayerInRaidFromTable(MB_raidAssist.GTFO.Onyxia)
                if ozTank and MBID[ozTank] and mb_isAlive(MBID[ozTank]) then
                    FollowByName(ozTank, 1)
                end
            else
                if MBID[MB_myOnyxiaFollowTarget] and mb_unitInRange(MBID[MB_myOnyxiaFollowTarget]) then
                    if not CheckInteractDistance(MBID[MB_myOnyxiaFollowTarget], 3) then
                        FollowByName(MB_myOnyxiaFollowTarget, 1)
                    end
                end
            end
        end
    end

    if not mb_haveAggro() then
        if Instance.NAXX() then
            GLUTH_GetOUT()
            GROB_GetOUT()
            mb_useFirePotsOnFaerlina()
        elseif Instance.BWL() and mb_hasBuffOrDebuff("Burning Adrenaline", "player", "debuff") then
            if myClass == "Paladin" and mb_spellReady("Divine Shield") then
                CastSpellByName("Divine Shield")
                return
            end

            local vaelTank = mb_returnPlayerInRaidFromTable(MB_raidAssist.GTFO.Vaelastrasz)
            if vaelTank and MBID[vaelTank] and mb_isAlive(MBID[vaelTank]) then
                FollowByName(vaelTank, 1)
            end
        elseif Instance.MC() and mb_hasBuffOrDebuff("Living Bomb", "player", "debuff") then
            if myClass == "Paladin" and mb_spellReady("Divine Shield") then
                CastSpellByName("Divine Shield")
                return
            end

            local baronTank = mb_returnPlayerInRaidFromTable(MB_raidAssist.GTFO.Baron)
            if baronTank and MBID[baronTank] and mb_isAlive(MBID[baronTank]) then
                FollowByName(baronTank, 1)
            end
        end
    end
end
