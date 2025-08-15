------------------------------------------------------------------------------------------------------
------------------------------------------------ FRAME! ----------------------------------------------
------------------------------------------------------------------------------------------------------

MMB = CreateFrame("Button", "MMB", UIParent)
MMBTooltip = CreateFrame("GAMETOOLTIP", "MMBTooltip", UIParent, "GameTooltipTemplate")

MBx = CreateFrame("Frame")
	MBx.ACE = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0")
	Print(MBx.ACE)
	MBx.ACE.ItemBonus = AceLibrary("ItemBonusLib-1.0")
	Print(MBx.ACE.ItemBonus)
	MBx.ACE.Banzai = AceLibrary("Banzai-1.0")
	Print(MBx.ACE.Banzai)
	MBx.ACE.HealComm = AceLibrary("HealComm-1.0")
	Print(MBx.ACE.HealComm)

------------------------------------------------------------------------------------------------------
----------------------------------------------- Locals! ----------------------------------------------
------------------------------------------------------------------------------------------------------

	-- Init globals / locals --

	MBID = {}
	MB_classList = { Warrior = {}, Mage = {}, Shaman = {}, Paladin = {}, Priest = {}, Rogue = {}, Druid = {}, Hunter = {}, Warlock = {} }
	MB_toonsInGroup = {}
	MB_offTanks = {}
	MB_raidTanks = {}
	MB_noneDruidTanks = {}
	MB_fireMages = {}
	MB_frostMages = {}
	MB_groupID = {}
	for i = 1, 8 do MB_toonsInGroup[i] = {} end

	local MB_druidTankInParty = nil
	local MB_warriorTankInParty = nil

	-- Assign globals / locals --

	MB_myCCTarget = nil
	MB_myInterruptTarget = nil
	MB_myOTTarget = nil
	
	MB_doInterrupt = { Active = false, Time = 0 }

	local MB_myAssignedHealTarget = nil

	MB_currentCC = { Mage = 1, Warlock = 1, Priest = 1, Druid = 1 }
	MB_currentInterrupt  = { Rogue = 1, Mage = 1, Shaman = 1 }
	MB_currentFear = { Warlock = 1 }

	MB_currentRaidTarget = 1
	MB_Ot_Index = 1

	MB_myCCSpell = {
		Priest = "Shackle Undead", 
		Mage = "Polymorph", 
		Warlock = "Banish", 
		Druid = "Hibernate" -- "Entangling Roots"
	}

	MB_myInterruptSpell = {
		Rogue = "Kick", 
		Shaman = "Earth Shock", 
		Mage = "Counterspell", 
		Warrior = "Pummel", 
		Priest = "Silence",
		Paladin = "Hammer of Justice"
	}

	MB_myFearSpell = {
		Warlock = "Fear"
		--Warlock = "Howl of Terror" ??? MAYBE FOR SKERAM
	}

	-- Used for wanding
	MB_classSpellManaCost = {
		-- Fire Magus
		["Fireball"] = 410,
		["Pyroblast"] = 440,
		["Scorch"] = 150,
		["Blast Wave"] = 545,

		-- Frost Magus
		["Frostbolt"] = 290,
		["Frostbolt(Rank 1)"] = 25,
		["Cone of Cold"] = 555,

		-- Arcane Magus
		["Arcane Explosion"] = 390,
		["Arcane Explosion(Rank 1)"] = 75,
		["Arcane Missiles"] = 655,

		-- Warlock
		["Searing Pain"] = 168,
		["Shadow Bolt"] = 380,
		["Soul Fire"] = 335,
		["Immolate"] = 380,
		["Corruption"] = 340,
		["Drain Mana"] = 225,

		-- Priest
		["Smite"] = 280,
		["Mind Flay"] = 205,
		["Mind Blast"] = 250,
		["Mana Burn"] = 270,

		-- Druid
		["Starfire"] = 309,
		["Wrath"] = 163,

		-- Shaman
		["Chain Lightning"] = 544,
		["Lightning Bolt"] = 238
	}

	-- Raid Targets
	MB_raidTargetNames = {
		[8] = "Skull", 
		[7] = "Cross", 
		[6] = "Square", 
		[5] = "Moon", 
		[4] = "Triangle", 
		[3] = "Diamond", 
		[2] = "Circle", 
		[1] = "Star"
	}

	-- Casting globals / locals --

	local MB_soulstone_ressurecters = true -- >  U can change this to false if u dont want SS on AltKeyDown buff

	-- Edit MB_savedBinding to you're liking, binding Binding2 should be single, Binding3 should be Multi
	MB_savedBinding = { Active = false, Time = 0, Binding2 = "SM_MACRO2", Binding3 = "SM_MACRO3" }

	MB_isCasting = nil
	MB_isChanneling = nil
	
	MB_isCastingMyCCSpell = nil
	
	MB_isMoving = { Active = false, Time = 0 }

	-- Ignite

	MB_ignite = { Active = nil, Starter = nil, Amount = 0, Stacks = 0 }

	MB_buffingCounterWarlock = 1
	MB_buffingCounterDruid = 1
	MB_buffingCounterMage = 1
	MB_buffingCounterPriest = 1
	MB_buffingCounterPaladin = 1
	MB_powerInfusionCounter = 1

	-- NPC and Trade globals / locals --

	MB_DMFWeek = { Active = false, Time = 0 }
	MB_MCEnter = { Active = false, Time = 0 }

	MB_tradeOpen = nil
	MB_tradeOpenOnUpdate = { Active = false, Time = 0 }

	-- BossEvents --

	local MB_targetNearestDistanceChanged = nil
	MB_razorgoreNewTargetBecauseTargetIsBehindOrOutOfRange = { Active = false, Time = 0 }
	MB_razorgoreNewTargetBecauseTargetIsBehind = { Active = false, Time = 0 }
	MB_lieutenantAndorovIsNotHealable = { Active = false, Time = 0 }
	MB_targetWrongWayOrTooFar = { Active = false, Time = 0 }
	MB_autoToggleSheeps = { Active = false, Time = 0 }
	MB_autoBuff = { Active = false, Time = 0 }
	MB_useCooldowns = { Active = false, Time = 0 }
	MB_useBigCooldowns = { Active = false, Time = 0 }

	-- Taxi --

	local original_TakeTaxiNode = TakeTaxiNode;
	local MB_taxi = {
		Time = 0, 
		Node = ""
	}

	-- Extra's --

	MB_raidLeader = nil
	MB_mySpecc = nil
	MB_hasTacMastery = nil
	MB_hasImprovedEA = nil
	MB_myHealSpell = nil
	MB_attackSlot = nil
	MB_attackRangedSlot = nil
	MB_attackWandSlot = nil

	MB_warriorBinds = "Fury"
	MB_evoGear = nil

	MB_hunterFeign = { Active = false, Time = 0 }

	MB_autoBuyReagents = { Active = false, Time = 0 }
	MB_autoBuySunfruit = { Active = false, Time = 0 }
	MB_autoTurnInQiraji = { Active = false, Time = 0 }
	
	-- Setup stuff --

	local myClass = UnitClass("player")
	local myName = UnitName("player")
	local myRace = UnitRace("player")

	MB_anubAlertCD = GetTime()

	MB_cooldowns = {}

	MB_myWater = {
		[60] = "Conjured Crystal Water",
		[50] = "Conjured Sparkling Water"
	}
	
	MB_playerMounts = {
		-- "Black Qiraji Resonating Crystal",
		"Reins of the Winterspring Frostsaber",
		"Deathcharger\'s Reins", 
		"Black War Tiger", 
		"Swift Zulian Tiger", 
		"Swift Razzashi Raptor", 
		"Swift Blue Raptor", 
		"Black War Kodo", 
		"Horn of the ", 
		"Reins of the Swift ", 
		"Swift White Steed", 
		"Swift Brown Steed",
		"Black Battlestrider",
		"Warhorse", 
		" Mare", 
		"Horse", 
		"Timber Wolf", 
		"Kodo", 
		"Raptor", 
		" Ram", 
		" Mechanostrider", 
		" Bridle", 
		"Charger", 
		" Frostsaber", 
		" Nightsaber", 
		"Swift Palomino"
	}

------------------------------------------------------------------------------------------------------
------------------------------------------ Slash Commands! -------------------------------------------
------------------------------------------------------------------------------------------------------

SLASH_INIT1 = "/init"
SLASH_DEEPINIT1 = "/deepinit"

SLASH_FIND1 = "/Find"
SLASH_FIND2 = "/find"

SLASH_HOTS1 = "/Hots"
SLASH_HOTS2 = "/hots"

SLASH_GEAR1 = "/Gear"
SLASH_GEAR2 = "/gear"

SLASH_REPORTMANAPOTS1 = "/reportmanapots"
SLASH_REPORTSHARDS1 = "/reportshards"
SLASH_REPORTRUNES1 = "/reportrunes"

SLASH_ASSIGNHEALER1 = "/healer"
SLASH_ASSIGNHEALER2 = "/Healer"

SLASH_USEBAGITEM1 = "/usebagitem"

SLASH_REMOVEBUFFS1 = "/removebuffs"
SLASH_REMOVEBUFFS2 = "/Removebuffs"

SLASH_REMOVEBLESS1 = "/removebles"
SLASH_REMOVEBLESS2 = "/Removebles"

SLASH_NEFCLOAK1 = "/nefcloak"
SLASH_NEFCLOAK2 = "/Nefcloak"

SLASH_REPORTREP1 = "/reportrep"
SLASH_AQBOOKS1 = "/reportspells"
SLASH_SOULSTONE1 = "/CreateSoulStones"

SLASH_DISBAND1 = "/disband"
SLASH_DISBAND2 = "/db"

SLASH_LOGOUT1 = "/lo"

SLASH_CHANGESPECC1 = "/specc"
SLASH_CHANGESPECC2 = "/Specc"

SLASH_TANKLIST1 = "/Tanklist"
SLASH_TANKLIST2 = "/tanklist"

SlashCmdList["CHANGESPECC"] = function(specc)	
	mb_changeSpecc(specc)
end

SlashCmdList["LOGOUT"] = function()	
	Logout()
end

SlashCmdList["TANKLIST"] = function(list)
	if UnitInRaid("player") then
		SendAddonMessage(MB_RAID.."MB_TANKLIST", list, "RAID")
	else
		SendAddonMessage(MB_RAID.."MB_TANKLIST", list)
	end
end

SlashCmdList["FIND"] = function(item)
	if UnitInRaid("player") then
		SendAddonMessage(MB_RAID.."MB_FIND", item, "RAID")
	else
		SendAddonMessage(MB_RAID.."MB_FIND", item)
	end
end

SlashCmdList["REPORTMANAPOTS"] = function()
	if UnitInRaid("player") then
		SendAddonMessage(MB_RAID, "MB_REPORTMANAPOTS", "RAID")
	else
		SendAddonMessage(MB_RAID, "MB_REPORTMANAPOTS")
	end
end

SlashCmdList["REPORTSHARDS"] = function()
	if UnitInRaid("player") then
		SendAddonMessage(MB_RAID, "MB_REPORTSHARDS", "RAID")
	else
		SendAddonMessage(MB_RAID, "MB_REPORTSHARDS")
	end
end

SlashCmdList["REPORTRUNES"] = function()
	if UnitInRaid("player") then
		SendAddonMessage(MB_RAID, "MB_REPORTRUNES", "RAID")
	else
		SendAddonMessage(MB_RAID, "MB_REPORTRUNES")
	end
end

SlashCmdList["NEFCLOAK"] = function(item)
	if UnitInRaid("player") then
		SendAddonMessage(MB_RAID, "MB_NEFCLOAK", "RAID")
	else
		SendAddonMessage(MB_RAID, "MB_NEFCLOAK")
	end
end
	
SlashCmdList["REMOVEBUFFS"] = function(buff)
	if UnitInRaid("player") then
		SendAddonMessage(MB_RAID.."MB_REMOVEBUFFS", buff, "RAID")
	else
		SendAddonMessage(MB_RAID.."MB_REMOVEBUFFS", buff)
	end
end

SlashCmdList["REMOVEBLESS"] = function(buff)
	if UnitInRaid("player") then
		SendAddonMessage(MB_RAID.."MB_REMOVEBLESS", buff, "RAID")
	else
		SendAddonMessage(MB_RAID.."MB_REMOVEBLESS", buff)
	end
end

SlashCmdList["AQBOOKS"] = function()
	if UnitInRaid("player") then
		SendAddonMessage(MB_RAID, "MB_AQBOOKS", "RAID")
	else
		SendAddonMessage(MB_RAID, "MB_AQBOOKS")
	end
end

SlashCmdList["INIT"] = function()
	mb_createMacros()
end

SlashCmdList["DEEPINIT"] = function()
	mb_createSpecialMacro()
end


SlashCmdList["SOULSTONE"] = function()
	mb_createSoulStone()
end

SlashCmdList["DISBAND"] = function()
	mb_disbandRaid()
end

SlashCmdList["HOTS"] = function(value)
	if UnitInRaid("player") then
		SendAddonMessage(MB_RAID.."MB_HOTS", value, "RAID")
	else
		SendAddonMessage(MB_RAID.."MB_HOTS", value)
	end
end

SlashCmdList["USEBAGITEM"] = function(item)
	if UnitInRaid("player") then
		SendAddonMessage(MB_RAID.."MB_USEBAGITEM", item, "RAID")
	else
		SendAddonMessage(MB_RAID.."MB_USEBAGITEM", item)
	end
end

SlashCmdList["GEAR"] = function(itemset)
	if UnitInRaid("player") then
		SendAddonMessage(MB_RAID.."MB_GEAR", itemset, "RAID")
	else
		SendAddonMessage(MB_RAID.."MB_GEAR", itemset)
	end
end
	
SlashCmdList["ASSIGNHEALER"] = function(names)
	if UnitInRaid("player") then
		SendAddonMessage(MB_RAID.."MB_ASSIGNHEALER", names, "RAID")
	else
		SendAddonMessage(MB_RAID.."MB_ASSIGNHEALER", names)
	end
end