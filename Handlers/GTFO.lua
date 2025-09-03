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

local FocusAggro = mb_focusAggro
local GTFO = mb_GTFO
local HasBuffOrDebuff = mb_hasBuffOrDebuff
local HaveAggro = mb_haveAggro
local ImFocus = mb_imFocus
local IsAlive = mb_isAlive
local IsAtGrobbulus = mb_isAtGrobbulus
local ReturnPlayerInRaidFromTable = mb_returnPlayerInRaidFromTable
local SpellReady = mb_spellReady
local TankTarget = mb_tankTarget
local TankTargetHealth = mb_tankTargetHealth
local UnitInRange = mb_unitInRange
local UseFirePotsOnFaerlina = mb_useFirePotsOnFaerlina
local UseSandsOnChromaggus = mb_useSandsOnChromaggus

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function mb_GTFO()
	if not MB_raidAssist.GTFO.Active then
        return
    end

	UseSandsOnChromaggus()

    if ImFocus() then
        return
    end

    if Instance.ONY() and MB_myOnyxiaBoxStrategy then
        if TankTarget("Onyxia") and (TankTargetHealth() <= 0.65 and TankTargetHealth() >= 0.4) and myName ~= MB_myOnyxiaMainTank then            
            if FocusAggro() then
                if myClass == "Paladin" and SpellReady("Divine Shield") then                     
                    CastSpellByName("Divine Shield") 
                    return 
                end

                if MBID[ReturnPlayerInRaidFromTable(MB_raidAssist.GTFO.Onyxia)] and IsAlive(MBID[ReturnPlayerInRaidFromTable(MB_raidAssist.GTFO.Onyxia)]) then
                    FollowByName(ReturnPlayerInRaidFromTable(MB_raidAssist.GTFO.Onyxia), 1)
                end
            else
                if MBID[MB_myOnyxiaFollowTarget] and UnitInRange(MBID[MB_myOnyxiaFollowTarget]) then                        
                    if not CheckInteractDistance(MBID[MB_myOnyxiaFollowTarget], 3) then
                        FollowByName(MB_myOnyxiaFollowTarget, 1)
                    end
                end
            end
        end	
    end
		
    if not HaveAggro() then
        if Instance.Naxx() and MB_myGrobbulusBoxStrategy then
            if IsAtGrobbulus() and (myName ~= MB_myGrobbulusMainTank or myName ~= MB_myGrobbulusFollowTarget) then
                if HasBuffOrDebuff("Mutating Injection", "player", "debuff") then                    
                    if MBID[ReturnPlayerInRaidFromTable(MB_raidAssist.GTFO.Grobbulus)] and IsAlive(MBID[ReturnPlayerInRaidFromTable(MB_raidAssist.GTFO.Grobbulus)]) then
                        FollowByName(ReturnPlayerInRaidFromTable(MB_raidAssist.GTFO.Grobbulus), 1)
                    end
                else
                    if MBID[MB_myGrobbulusFollowTarget] and UnitInRange(MBID[MB_myGrobbulusFollowTarget]) then                        
                        if not CheckInteractDistance(MBID[MB_myGrobbulusFollowTarget], 3) then
                            FollowByName(MB_myGrobbulusFollowTarget, 1)
                        end
                    else
                        if MBID[ReturnPlayerInRaidFromTable(MB_raidAssist.GTFO.Grobbulus)] and IsAlive(MBID[ReturnPlayerInRaidFromTable(MB_raidAssist.GTFO.Grobbulus)]) then
                            FollowByName(ReturnPlayerInRaidFromTable(MB_raidAssist.GTFO.Grobbulus), 1)
                        end
                    end
                end
            end
            
            UseFirePotsOnFaerlina()
        
        elseif Instance.BWL() and HasBuffOrDebuff("Burning Adrenaline", "player", "debuff") then        
            if myClass == "Paladin" and SpellReady("Divine Shield") then                
                CastSpellByName("Divine Shield") 
                return 
            end

            if MBID[ReturnPlayerInRaidFromTable(MB_raidAssist.GTFO.Vaelastrasz)] and IsAlive(MBID[ReturnPlayerInRaidFromTable(MB_raidAssist.GTFO.Vaelastrasz)]) then
                FollowByName(ReturnPlayerInRaidFromTable(MB_raidAssist.GTFO.Vaelastrasz), 1)
            end            

        elseif Instance.MC() and HasBuffOrDebuff("Living Bomb", "player", "debuff") then 
            if myClass == "Paladin" and SpellReady("Divine Shield") then                
                CastSpellByName("Divine Shield") 
                return 
            end
        
            if MBID[ReturnPlayerInRaidFromTable(MB_raidAssist.GTFO.Baron)] and IsAlive(MBID[ReturnPlayerInRaidFromTable(MB_raidAssist.GTFO.Baron)]) then
                FollowByName(ReturnPlayerInRaidFromTable(MB_raidAssist.GTFO.Baron), 1)
            end
        end
    end
end
