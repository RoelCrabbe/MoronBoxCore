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
local Dead = mb_dead
local GetTargetNotOnTank = mb_getTargetNotOnTank
local ImHealer = mb_imHealer
local ImMeleeDPS = mb_imMeleeDPS
local ImRangedDPS = mb_imRangedDPS
local ImTank = mb_imTank
local LockOnTarget = mb_lockOnTarget

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

    if mb_imBusy() or not mb_inCombat("player") then
		return
	end

    mb_takePotionsWhenPossible("Greater Nature Protection Potion")
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
function GROB_GetOUT()
	if mb_isAtGrobbulus() and MB_myGrobbulusBoxStrategy then
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

        local mainFollowId
        local firstHasDebuff = mb_hasBuffOrDebuff("Mutating Injection", firstFollowId, "debuff")
        local secondHasDebuff = mb_hasBuffOrDebuff("Mutating Injection", secondFollowId, "debuff")

        if firstHasDebuff and secondHasDebuff then
            mainFollowId = decurseId
        elseif CurrentMainFollowIndex == 1 and firstHasDebuff then
            CurrentMainFollowIndex = 2
            mainFollowId = secondFollowId
        elseif CurrentMainFollowIndex == 2 and secondHasDebuff then
            CurrentMainFollowIndex = 1
            mainFollowId = firstFollowId
        else
            mainFollowId = (CurrentMainFollowIndex == 1) and firstFollowId or secondFollowId
        end

		local mainFollow = UnitName(mainFollowId)
		if myName == mainFollow then
			return false
		end
	
		if mb_hasBuffOrDebuff("Mutating Injection", "player", "debuff") then
			if IsAlive(decurseId) then
				FollowUnit(decurseId, 1)
			end
		else
			if mb_unitInRange(mainFollowId) then
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

--[####################################################################################################]--
--[####################################################################################################]--
--[####################################################################################################]--

function GROB_Targeting()
	if mb_isAtGrobbulus() and MB_myGrobbulusBoxStrategy then
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
			if mb_tankTargetHealth() < 0.12 then
				AssistFocus()
				return true
			end

			if MB_mySpecc ~= "Fire" then
				for _, tankName in ipairs(MB_myGrobbulusSlimeTanks) do
					if mb_assistSpecificTargetFromPlayer("Fallout Slime", tankName) then
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

