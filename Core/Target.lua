--[####################################################################################################]--
--[####################################### AUTO TARGET HANDLER ########################################]--
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

local MB_targetNearestDistanceChanged = nil

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local function GetTargetIfNone()
    local tName = UnitName("target")

    if not tName or mb_dead("target") then
        mb_assistFocus()
    end
end

local function HandleNAXXTargetingPreFocus()
    if THAD_TargetingPreFocus() then
        return true
    end

    return false
end

local function HandleAQ40TargetingPreFocus()
    if SKERAM_TargetingPreFocus() then
        return true
    end

    if BUGTRIO_TargetingPreFocus() then
        return true
    end

    if FANKRISS_TargetingPreFocus() then
        return true
    end

    return false
end

local function HandleBWLTargetingPreFocus()
    local tName = UnitName("target")

    if myName == mb_returnPlayerInRaidFromTable(MB_myRazorgoreORBtank) then
        return true
    end

    if not mb_isAtRazorgorePhase() then
        return false
    end

    if (myName == mb_returnPlayerInRaidFromTable(MB_myRazorgoreLeftTank)
            or myName == mb_returnPlayerInRaidFromTable(MB_myRazorgoreRightTank)) and MB_raidLeader ~= myName then
        MB_raidLeader = myName
    end

    if not mb_imFocus() then
        return false
    end

    if (myName == mb_returnPlayerInRaidFromTable(MB_myRazorgoreLeftTank) or myName == mb_returnPlayerInRaidFromTable(MB_myRazorgoreRightTank)) then
        if not MB_targetNearestDistanceChanged then
            SetCVar("targetNearestDistance", "15")
            MB_targetNearestDistanceChanged = true
        end

        if MB_razorgoreNewTargetBecauseTargetIsBehind.Active then
            TargetNearestEnemy()
            MB_razorgoreNewTargetBecauseTargetIsBehind.Active = false
            return true
        end

        if (tName == nil or mb_dead("target")) then
            TargetNearestEnemy()
            return true
        end

        mb_cdPrint("Focussing Attacks on " .. tName, 30)
        return true
    end

    return false
end

local function HandleNAXXTargetingPostFocus()
    local tName = UnitName("target")

    if LOA_Targeting() then
        return true
    end

    if GROB_Targeting() then
        return true
    end

    if THAD_TargetingPostFocus() then
        return true
    end

    if (mb_tankTarget("Instructor Razuvious") and mb_myNameInTable(MB_myRazuviousPriest) and MB_myRazuviousBoxStrategy) or
        (mb_tankTarget("Grand Widow Faerlina") and mb_myNameInTable(MB_myFaerlinaPriest) and MB_myFaerlinaBoxStrategy) then
        return true
    elseif mb_tankTarget("Anub\'Rekhan") then
        if mb_imTank() then
            mb_getTargetNotOnTank()
            return true
        elseif mb_imMeleeDPS() or mb_imRangedDPS() then
            for i = 1, 2 do
                if tName == "Crypt Guard" and not mb_dead("target") then
                    return true
                end

                TargetNearestEnemy()
            end

            GetTargetIfNone()
            return true
        end
    elseif mb_isAtMonstrosity() then
        if mb_imTank() then
            mb_getTargetNotOnTank()
            return true
        elseif mb_imMeleeDPS() or mb_imRangedDPS() then
            if mb_lockOnTarget("Lightning Totem") then
                return true
            end

            GetTargetIfNone()
            return true
        end
    elseif mb_tankTarget("Plague Beast") then
        if mb_imTank() then
            mb_getTargetNotOnTank()
            return true
        elseif mb_imMeleeDPS() then
            if MB_targetWrongWayOrTooFar.Active then
                TargetNearestEnemy()
                MB_targetWrongWayOrTooFar.Active = false
                return true
            end

            for i = 1, 4 do
                if tName == "Mutated Grub" and not mb_dead("target") then
                    return true
                end

                if tName == "Plagued Bat" and not mb_dead("target") then
                    return true
                end

                TargetNearestEnemy()
            end

            GetTargetIfNone()
            return true
        elseif mb_imRangedDPS() then
            mb_assistFocus()
            return true
        end
    end

    return false
end

local function HandleAQ40TargetingPostFocus()
    local tName = UnitName("target")

    if SKERAM_TargetingPostFocus() then
        return true
    end

    if BUGTRIO_TargetingPostFocus() then
        return true
    end

    if SARTURA_TargetingPostFocus() then
        return true
    end

    if FANKRISS_TargetingPostFocus() then
        return true
    end

    if mb_tankTarget("Anubisath Defender") then
        if mb_imTank() then
            mb_getTargetNotOnTank()
            return true
        end

        for i = 1, 4 do
            if tName == "Anubisath Swarmguard" and not mb_dead("target") then
                return true
            end

            if tName == "Anubisath Warrior" and not mb_dead("target") then
                return true
            end

            TargetNearestEnemy()
        end

        GetTargetIfNone()
        return true
    end

    return false
end

local function HandleBWLTargetingPostFocus()
    local tName = UnitName("target")

    if mb_isAtRazorgore() and MB_myRazorgoreBoxStrategy then
        if myName == mb_returnPlayerInRaidFromTable(MB_myRazorgoreORBtank) then
            return true
        end

        if not mb_isAtRazorgorePhase() then
            return false
        end

        if (myName == mb_returnPlayerInRaidFromTable(MB_myRazorgoreLeftTank) or myName == mb_returnPlayerInRaidFromTable(MB_myRazorgoreRightTank)) then
            if not MB_targetNearestDistanceChanged then
                SetCVar("targetNearestDistance", "15")
                MB_targetNearestDistanceChanged = true
            end

            if MB_razorgoreNewTargetBecauseTargetIsBehind.Active then
                TargetNearestEnemy()
                MB_razorgoreNewTargetBecauseTargetIsBehind.Active = false
                return true
            end

            if (tName == nil or mb_dead("target")) then
                TargetNearestEnemy()
                return true
            end

            return true
        elseif mb_imTank() then
            if not MB_targetNearestDistanceChanged then
                SetCVar("targetNearestDistance", "10")
                MB_targetNearestDistanceChanged = true
            end

            if MB_razorgoreNewTargetBecauseTargetIsBehind.Active then
                TargetNearestEnemy()
                MB_razorgoreNewTargetBecauseTargetIsBehind.Active = false
                return true
            end

            mb_getTargetNotOnTank()
            return true
        elseif mb_imMeleeDPS() then
            if mb_myNameInTable(MB_myRazorgoreLeftDPSERS) then
                local leftTank = mb_returnPlayerInRaidFromTable(MB_myRazorgoreLeftTank)
                if leftTank then
                    AssistByName(leftTank)
                end
                return true
            end
            if mb_myNameInTable(MB_myRazorgoreRightDPSERS) then
                local rightTank = mb_returnPlayerInRaidFromTable(MB_myRazorgoreRightTank)
                if rightTank then
                    AssistByName(rightTank)
                end
                return true
            end

            return true
        elseif mb_imRangedDPS() then
            if MB_razorgoreNewTargetBecauseTargetIsBehind.Active then
                TargetNearestEnemy()
                MB_razorgoreNewTargetBecauseTargetIsBehind.Active = false
                return true
            end

            if not mb_dead("target") then
                return true
            end

            local tankOno = mb_returnPlayerInRaidFromTable(MB_myRazorgoreRightTank)
            if mb_assistSpecificTargetFromPlayer("Blackwing Mage", tankOno) then
                mb_debugger(MB_raidAssist.Debugger.Mage, "All casters assisting " .. tankOno)
                return true
            end

            local tankTwo = mb_returnPlayerInRaidFromTable(MB_myRazorgoreLeftTank)
            if mb_assistSpecificTargetFromPlayer("Blackwing Mage", tankTwo) then
                mb_debugger(MB_raidAssist.Debugger.Mage, "All casters assisting " .. tankTwo)
                return true
            end

            if mb_assistSpecificTargetFromPlayer("Blackwing Legionnaire", tankOno) then
                mb_debugger(MB_raidAssist.Debugger.Mage, "All casters assisting " .. tankOno)
                return true
            end

            if mb_assistSpecificTargetFromPlayer("Blackwing Legionnaire", tankTwo) then
                mb_debugger(MB_raidAssist.Debugger.Mage, "All casters assisting " .. tankTwo)
                return true
            end

            if mb_assistSpecificTargetFromPlayer("Death Talon Dragonspawn", tankOno) then
                mb_debugger(MB_raidAssist.Debugger.Mage, "All casters assisting " .. tankOno)
                return true
            end

            if mb_assistSpecificTargetFromPlayer("Death Talon Dragonspawn", tankTwo) then
                mb_debugger(MB_raidAssist.Debugger.Mage, "All casters assisting " .. tankTwo)
                return true
            end

            GetTargetIfNone()
            return true
        end

        return true
    elseif GetSubZoneText() == "Shadow Wing Lair" then
        if MB_raidLeader and mb_dead(MBID[MB_raidLeader]) then
            mb_lockOnTarget("Vaelastrasz the Corrupt")
            return true
        end
    end

    return false
end

local function HandleMCTargetingPostFocus()
    if LUCIFRON_TargetingPostFocus() then
        return true
    end

    if MAGMADAR_TargetingPostFocus() then
        return true
    end

    if GEHENNAS_TargetingPostFocus() then
        return true
    end

    if GARR_TargetingPostFocus() then
        return true
    end

    if SHAZZRAH_TargetingPostFocus() then
        return true
    end

    if GEDDON_TargetingPostFocus() then
        return true
    end

    if GOLEMAGG_TargetingPostFocus() then
        return true
    end

    if SULFURON_TargetingPostFocus() then
        return true
    end

    if MAJORDOMO_TargetingPostFocus() then
        return true
    end

    if RAGNAROS_TargetingPostFocus() then
        return true
    end

    return false
end

local function HandleONYTargetingPostFocus()
    local tName = UnitName("target")

    if mb_imTank() then
        mb_getTargetNotOnTank()
        return true
    elseif mb_imMeleeDPS() then
        if MB_targetWrongWayOrTooFar.Active then
            TargetNearestEnemy()
            MB_targetWrongWayOrTooFar.Active = false
            return true
        end

        for i = 1, 2 do
            if tName == "Onyxian Whelp" and not mb_dead("target") then
                return true
            end

            TargetNearestEnemy()
        end

        GetTargetIfNone()
        return true
    elseif mb_imRangedDPS() then
        if mb_assistSpecificTargetFromPlayer("Onyxia", MB_myOnyxiaMainTank) then
            return true
        end

        GetTargetIfNone()
        return true
    end

    return false
end

local function HandleZGTargetingPostFocus()
    local tName = UnitName("target")

    if mb_isAtJindo() then
        if mb_imTank() then
            mb_getTargetNotOnTank()
            return true
        elseif mb_imMeleeDPS() then
            for i = 1, 2 do
                if tName == "Shade of Jin\'do" and not mb_dead("target") then
                    return true
                end

                TargetNearestEnemy()
            end

            GetTargetIfNone()
            return true
        elseif mb_imRangedDPS() then
            for i = 1, 6 do
                if tName == "Shade of Jin\'do" and not mb_dead("target") then
                    return true
                end

                if tName == "Powerful Healing Ward" and not mb_dead("target") then
                    return true
                end

                if tName == "Brain Wash Totem" and not mb_dead("target") then
                    return true
                end

                TargetNearestEnemy()
            end

            GetTargetIfNone()
            return true
        end
    elseif mb_tankTarget("High Priestess Mar\'li") then
        if mb_imTank() then
            mb_getTargetNotOnTank()
            return true
        elseif mb_imMeleeDPS() then
            mb_assistFocus()
            return true
        elseif mb_imRangedDPS() then
            for i = 1, 4 do
                if tName == "Spawn of Mar\'li" and not mb_dead("target") then
                    return true
                end

                if tName == "Witherbark Speaker" and not mb_dead("target") then
                    return true
                end

                TargetNearestEnemy()
            end

            GetTargetIfNone()
            return true
        end
    elseif mb_tankTarget("High Priestess Jeklik") then
        if mb_imTank() then
            mb_getTargetNotOnTank()
            return true
        elseif mb_imRangedDPS() then
            for i = 1, 2 do
                if tName == "Bloodseeker Bat" and mb_inCombat("target") and not mb_dead("target") then
                    return true
                end

                TargetNearestEnemy()
            end

            GetTargetIfNone()
            return true
        end
    elseif mb_tankTarget("High Priest Venoxis") then
        if mb_imTank() then
            mb_getTargetNotOnTank()
            return true
        elseif mb_imMeleeDPS() or mb_imRangedDPS() then
            for i = 1, 2 do
                if tName == "Razzashi Cobra" and not mb_dead("target") and not GetRaidTargetIndex("target") then
                    return true
                end

                TargetNearestEnemy()
            end

            GetTargetIfNone()
            return true
        end
    end

    return false
end

local function HandleAQ20TargetingPostFocus()
    local tName = UnitName("target")

    if mb_imTank() then
        mb_getTargetNotOnTank()
        return true
    elseif mb_imMeleeDPS() or mb_imRangedDPS() then
        for i = 1, 2 do
            if tName == "Hive\'Zara Larva" and not mb_dead("target") then
                return true
            end

            TargetNearestEnemy()
        end

        GetTargetIfNone()
        return true
    end

    return false
end

local function HandleUBRSTargetingPostFocus()
    local tName = UnitName("target")

    if mb_imTank() then
        mb_getTargetNotOnTank()
        return true
    elseif mb_imMeleeDPS() or mb_imRangedDPS() then
        for i = 1, 2 do
            if tName == "Spectral Assassin" and not mb_dead("target") then
                return true
            end

            TargetNearestEnemy()
        end

        GetTargetIfNone()
        return true
    end

    return false
end

function mb_getTarget()
    local tName = UnitName("target")

    if Instance.BWL() and mb_isAtRazorgore() and MB_myRazorgoreBoxStrategy then
        if myName == mb_returnPlayerInRaidFromTable(MB_myRazorgoreORBtank) and not mb_tankTarget("Razorgore the Untamed") then
            mb_orbControlling()
            return
        end
    end

    if MB_myOTTarget then
        return
    end

    if Instance.NAXX() then
        if HandleNAXXTargetingPreFocus() then
            return
        end
    elseif Instance.AQ40() then
        if HandleAQ40TargetingPreFocus() then
            return
        end
    elseif Instance.BWL() and mb_isAtRazorgore() and MB_myRazorgoreBoxStrategy then
        if HandleBWLTargetingPreFocus() then
            return
        end
    end

    if mb_imFocus() then
        if tName and mb_inCombat("target") then
            return
        end

        if not tName or UnitIsDead("target") or not UnitIsEnemy("player", "target") then
            TargetNearestEnemy()
        end
        return
    end

    if Instance.NAXX() then
        if HandleNAXXTargetingPostFocus() then
            return
        end
    elseif Instance.AQ40() then
        if HandleAQ40TargetingPostFocus() then
            return
        end
    elseif Instance.BWL() then
        if HandleBWLTargetingPostFocus() then
            return
        end
    elseif Instance.MC() then
        if HandleMCTargetingPostFocus() then
            return
        end
    elseif Instance.ONY() and mb_tankTarget("Onyxia") and MB_myOnyxiaBoxStrategy then
        if HandleONYTargetingPostFocus() then
            return
        end
    elseif Instance.ZG() then
        if HandleZGTargetingPostFocus() then
            return
        end
    elseif Instance.AQ20() and mb_tankTarget("Ayamiss the Hunter") and not mb_dead("target") then
        if HandleAQ20TargetingPostFocus() then
            return
        end
    elseif GetRealZoneText() == "Blackrock Spire" and mb_tankTarget("Lord Valthalak") and not mb_dead("target") then
        if HandleUBRSTargetingPostFocus() then
            return
        end
    end

    local focId = MBID[MB_raidLeader]
    if not focId then
        mb_assistFocus()
    elseif UnitName(focId .. "target") then
        TargetUnit(focId .. "target")
    else
        if not UnitIsEnemy("player", "target") then
            TargetNearestEnemy()
        end
    end

    if mb_imTank() and not MB_myOTTarget then
        mb_getTargetNotOnTank()
        return
    end

    if not MB_myOTTarget then
        mb_assistFocus()
    end
end
