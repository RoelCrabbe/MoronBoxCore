--[####################################################################################################]--
--[########################################### LOATHEB CODE ###########################################]--
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

local AssistFocus = mb_assistFocus
local AssistSpecificTargetFromPlayer = mb_assistSpecificTargetFromPlayer
local Dead = mb_dead
local GetTargetNotOnTank = mb_getTargetNotOnTank
local HasBuffOrDebuff = mb_hasBuffOrDebuff
local ImBusy = mb_imBusy
local ImHealer = mb_imHealer
local ImMeleeDPS = mb_imMeleeDPS
local ImRangedDPS = mb_imRangedDPS
local ImTank = mb_imTank
local InCombat = mb_inCombat
local IsAtGrobbulus = mb_isAtGrobbulus
local LockOnTarget = mb_lockOnTarget
local TakePotionsWhenPossible = mb_takePotionsWhenPossible
local TankTargetHealth = mb_tankTargetHealth
local UnitInRange = mb_unitInRange

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local GROB = CreateFrame("Button", "GROB", UIParent)

do
	for _, event in {
		"CHAT_MSG_ADDON",
        "ZONE_CHANGED_NEW_AREA",
        "PLAYER_ENTERING_WORLD"
		}
		do GROB:RegisterEvent(event)
	end
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

-- Strategy Configuration
MB_myGrobbulusBoxStrategy = true 
MB_myGrobbulusNaturePotStrategy = true

MB_myGrobbulusDecurseFollow = "Liket"

-- Tank Assignments (REQUIRED)
MB_myGrobbulusMainTank = "Moron"
MB_myGrobbulusSlimeTanks = {
	"Kungen",
	"Likalottapus"
}

-- Follow Targets (REQUIRED)
MB_myGrobbulusRaidFollowers = {
	"Kungen",
	"Likalottapus"
}

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local function UseNaturePotsOnGrobbulus()
    if not MB_myGrobbulusNaturePotStrategy then
        return
    end

    if ImBusy() or not InCombat("player") then
		return
	end

    TakePotionsWhenPossible("Greater Nature Protection Potion")
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function GROB:OnEvent()

end

GROB:SetScript("OnEvent", GROB.OnEvent) 

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

local CurrentMainFollowIndex = 1

local function GetRaidFollow(firstId, secondId, decurseId)
    local firstHasDebuff = HasBuffOrDebuff("Mutating Injection", firstId, "debuff")
    local secondHasDebuff = HasBuffOrDebuff("Mutating Injection", secondId, "debuff")
    
    if firstHasDebuff and secondHasDebuff then
        return decurseId
    elseif CurrentMainFollowIndex == 1 and firstHasDebuff then
        CurrentMainFollowIndex = 2
        return secondId
    elseif CurrentMainFollowIndex == 2 and secondHasDebuff then
        CurrentMainFollowIndex = 1
        return firstId
    else
        return (CurrentMainFollowIndex == 1) and firstId or secondId
    end
end

function GROB_GetOUT()
	if IsAtGrobbulus() and MB_myGrobbulusBoxStrategy then
		UseNaturePotsOnGrobbulus()

		local firstFollow, secondFollow = MB_myGrobbulusRaidFollowers[1], MB_myGrobbulusRaidFollowers[2]
		local firstFollowId, secondFollowId = MBID[firstFollow], MBID[secondFollow]

		if not firstFollowId or not secondFollowId then
			CdRaidWarning(">> You Don't Have Enough Follow Targets! <<")
			return false
		end

		local decurseId = MBID[MB_myGrobbulusDecurseFollow]
		if not decurseId then
			CdRaidWarning(">> You Don't Have Decurse Follow! <<")
			return false
		end

		if myName == MB_myGrobbulusMainTank then
			return false
		end

        local mainFollowId = GetRaidFollow(firstFollowId, secondFollowId, decurseId)
		local mainFollow = UnitName(mainFollowId)

		if myName == mainFollow then
			return false
		end
	
		if HasBuffOrDebuff("Mutating Injection", "player", "debuff") then
			if IsAlive(decurseId) then
				FollowUnit(decurseId, 1)
			end
		else
			if UnitInRange(mainFollowId) then
				if not CheckInteractDistance(mainFollowId, 3) then
					FollowUnit(mainFollowId, 1)
				end
			else
				if IsAlive(decurseId) then
					FollowUnit(decurseId, 1)
				end
			end			
		end
		return true
	end
	return false
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function GROB_Targeting()
	if IsAtGrobbulus() and MB_myGrobbulusBoxStrategy then
		if myName == MB_myGrobbulusMainTank then
            if LockOnTarget("Grobbulus") then
                return true
            end

            if not tName or Dead("target") then
                AssistFocus()
            end
            return true
        
        elseif ImTank() then				
			GetTargetNotOnTank()
			return true

		elseif ImRangedDPS() then
			if TankTargetHealth() < 0.12 then
				AssistFocus()
				return true
			end

			if MB_mySpecc ~= "Fire" then
				for _, tankName in ipairs(MB_myGrobbulusSlimeTanks) do
					if AssistSpecificTargetFromPlayer("Fallout Slime", tankName) then
						return true
					end
				end
			end

			if LockOnTarget("Grobbulus") then
				return true
			end

			if not tName or Dead("target") then
				AssistFocus()
			end
			return true
		end
    end

    return false
end

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

-- if IsAtGrobbulus() and (myName ~= MB_myGrobbulusMainTank or myName ~= MB_myGrobbulusFollowTarget) then
--     if HasBuffOrDebuff("Mutating Injection", "player", "debuff") then                    
--         if MBID[ReturnPlayerInRaidFromTable(MB_raidAssist.GTFO.Grobbulus)] and IsAlive(MBID[ReturnPlayerInRaidFromTable(MB_raidAssist.GTFO.Grobbulus)]) then
--             FollowByName(ReturnPlayerInRaidFromTable(MB_raidAssist.GTFO.Grobbulus), 1)
--         end
--     else
--         if MBID[MB_myGrobbulusFollowTarget] and UnitInRange(MBID[MB_myGrobbulusFollowTarget]) then                        
--             if not CheckInteractDistance(MBID[MB_myGrobbulusFollowTarget], 3) then
--                 FollowByName(MB_myGrobbulusFollowTarget, 1)
--             end
--         else
--             if MBID[ReturnPlayerInRaidFromTable(MB_raidAssist.GTFO.Grobbulus)] and IsAlive(MBID[ReturnPlayerInRaidFromTable(MB_raidAssist.GTFO.Grobbulus)]) then
--                 FollowByName(ReturnPlayerInRaidFromTable(MB_raidAssist.GTFO.Grobbulus), 1)
--             end
--         end
--     end
-- end
