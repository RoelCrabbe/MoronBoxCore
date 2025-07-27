------------------------------------------------------------------------------------------------------
---------------------------------------------- Keybinds ----------------------------------------------
------------------------------------------------------------------------------------------------------

local myClass = UnitClass("player")

function mb_createBinds()

	LoadBindings(1) -- Load binds.
	mb_unbindAllKeys() -- Unbind all keys.

	SetBinding("B", "OPENALLBAGS") -- Open all bags.
	SetBinding("SHIFT-R", "REPLY") -- Reply whisper.
	SetBinding("O", "TOGGLERAIDTAB") -- O, Opens Raidtab instead of friendlist.
	SetBinding("M", "TOGGLEWORLDMAP") -- Toggle minimap.

	-- Movement binds
	SetBinding("Z", "MOVEFORWARD") -- Forward.
	SetBinding("S", "MOVEBACKWARD") -- Backward.
	SetBinding("Q", "STRAFELEFT") -- Left.
	SetBinding("D", "STRAFERIGHT") -- Right.

	-- Extra's
	SetBinding("SHIFT-V", "NAMEPLATES") -- Show all Nameplates.
	SetBinding("MINUS", "SM_MACRO31") -- ReloadUI.

	-- Set Custom Macro Binds
	SetBinding("PAGEDOWN", "SM_MACRO1") -- Setup / Buffs.
	SetBinding("2", "SM_MACRO2") -- Single DPS.
	SetBinding("3", "SM_MACRO3") -- Multi DPS.
	SetBinding("L", "SM_MACRO4") -- Cooldowns.
	SetBinding("4", "SM_MACRO5") -- AOE.
	SetBinding("Y", "SM_MACRO6") -- Mount.
	SetBinding("F3", "SM_MACRO7") -- Request invites / Request summon / Promote.
	SetBinding("T", "SM_MACRO30") -- Precast.

	SetBinding("F2", "SM_MACRO8") -- CC on pull, AltKeyDown => PowerWord: Shield Tanks, ShiftKeyDown => Target Raidleader.
	SetBinding("F4", "SM_MACRO9") -- FocusME (Do not broadcast!), ShiftKeyDown => Focus Previous FocusME.
	SetBinding("F5", "SM_MACRO10") -- Assign Offtanks to target, ShiftKeyDown => Assign interrupt to target.
	SetBinding("F6", "SM_MACRO11") -- Assign CC to target, ShiftKeyDown => assign fear.
	SetBinding("F7", "SM_MACRO12") -- Clear assign to target.
	SetBinding("PAGEUP", "SM_MACRO13") -- Make water on mages.
	SetBinding("A", "SM_MACRO14") -- Drink and Trade for water.
	SetBinding("CTRL-A", "SM_MACRO14") -- Drink and Trade for water.
	SetBinding("F", "SM_MACRO15") -- Breakfear, ShiftKeyDown => Poison/Disease Cleanse Totem.
	SetBinding("SHIFT-X", "SM_MACRO16") -- Follow Focus.
	SetBinding("N", "SM_MACRO17") -- DropTotems.
	
	SetBinding("V", "SM_MACRO19") -- Tanks and Healers ONLY, no dps.
	SetBinding("9", "SM_MACRO20") -- Craftable Cooldowns.	
	SetBinding("SHIFT-T", "SM_MACRO21") -- Interrupt Focus target.

	SetBinding("SHIFT-G", "SM_MACRO22") -- Casters Follow.
	SetBinding("1", "SM_MACRO23") -- Melees Follow.
	SetBinding("SHIFT-H", "SM_MACRO24") -- Healers Follow.
	SetBinding("SHIFT-C", "SM_MACRO25") -- Tank Follow.

	SetBinding("6", "SM_MACRO26") -- Manual Recklessness.
	SetBinding("0", "SM_MACRO27") -- Reports Cooldowns of Certain spells.
	SetBinding("K", "SM_MACRO28") -- Tank Shoot.

	if myClass == "Druid" or myClass == "Shaman" or myClass == "Priest" or myClass == "Paladin" then
		SetBinding("J", "SM_MACRO18") -- Ress with Thaliz. (Add delay in HKN).
	end

	if myClass == "Warrior" or MB_mySpecc == "Feral" then
		SetBinding("R", "SM_MACRO29") -- Warrior / Feral Taunt.
	end

	SaveBindings(1)
end

function mb_unbindAllKeys()
	SetBinding("SHIFT-1")
	SetBinding("SHIFT-2")
	SetBinding("SHIFT-3")
	SetBinding("SHIFT-4")
	SetBinding("SHIFT-5")
	SetBinding("SHIFT-6")
	SetBinding("SHIFT-7")
	SetBinding("SHIFT-8")
	SetBinding("SHIFT-9")
	SetBinding("SHIFT-0")
	SetBinding("SHIFT--")
	SetBinding("SHIFT-=")	
	SetBinding("ALT-1")
	SetBinding("ALT-2")
	SetBinding("ALT-3")
	SetBinding("ALT-4")
	SetBinding("ALT-5")
	SetBinding("ALT-6")
	SetBinding("ALT-7")
	SetBinding("ALT-8")
	SetBinding("ALT-9")
	SetBinding("ALT-0")
	SetBinding("ALT--")
	SetBinding("ALT-=")
	SetBinding("CTRL-S")
	SetBinding("CTRL-A")
	SetBinding("CTRL-1")
	SetBinding("CTRL-2")
	SetBinding("CTRL-3")
	SetBinding("CTRL-4")
	SetBinding("CTRL-5")
	SetBinding("CTRL-6")
	SetBinding("CTRL-7")
	SetBinding("CTRL-8")
	SetBinding("CTRL-9")
	SetBinding("CTRL-0")
	SetBinding("CTRL--")
	SetBinding("CTRL-=")
	SetBinding("SHIFT-V")
	SetBinding("CTRL-V")
	SetBinding("1")
	SetBinding("2")
	SetBinding("V")
	SetBinding("Q")
	SetBinding("W")
	SetBinding("E")
	SetBinding("R")
	SetBinding("T")
	SetBinding("Y")
	SetBinding("I")
	SetBinding("A")
	SetBinding("D")
	SetBinding("F")
	SetBinding("G")
	SetBinding("H")
	SetBinding("O")
	SetBinding("J")
	SetBinding("K")
	SetBinding("L")
	SetBinding("Z")
	SetBinding("X")
	SetBinding("N")
	SetBinding("?")
	SetBinding("?")
	SetBinding("?")
	SetBinding("NUMPAD0")
	SetBinding("NUMPAD1")
	SetBinding("NUMPAD2")
	SetBinding("NUMPAD3")
	SetBinding("NUMPAD4")
	SetBinding("NUMPAD5")
	SetBinding("NUMPAD6")
	SetBinding("NUMPAD7")
	SetBinding("NUMPAD8")
	SetBinding("NUMPAD9")
	SetBinding("F1")
	SetBinding("F2")
	SetBinding("F3")
	SetBinding("F4")
	SetBinding("F5")
	SetBinding("F6")
	SetBinding("F7")
	SetBinding("F8")
	SetBinding("F9")
	SetBinding("F10")
	SetBinding("F11")
	SetBinding("F12")
	SetBinding("SHIFT-F1")
	SetBinding("SHIFT-F2")
	SetBinding("SHIFT-F3")
	SetBinding("SHIFT-F4")
	SetBinding("SHIFT-F5")
	SetBinding("SHIFT-F6")
	SetBinding("SHIFT-F7")
	SetBinding("SHIFT-F8")
	SetBinding("SHIFT-F9")
	SetBinding("SHIFT-F10")
	SetBinding("SHIFT-F11")
	SetBinding("SHIFT-F12")
	SetBinding("ALT-F1")
	SetBinding("ALT-F2")
	SetBinding("ALT-F3")
	SetBinding("ALT-F4")
	SetBinding("ALT-F5")
	SetBinding("ALT-F6")
	SetBinding("ALT-F7")
	SetBinding("ALT-F8")
	SetBinding("ALT-F9")
	SetBinding("ALT-F10")
	SetBinding("ALT-F11")
	SetBinding("ALT-F12")
	SetBinding("CTRL-F1")
	SetBinding("CTRL-F2")
	SetBinding("CTRL-F3")
	SetBinding("CTRL-F4")
	SetBinding("CTRL-F5")
	SetBinding("CTRL-F6")
	SetBinding("CTRL-F7")
	SetBinding("CTRL-F8")
	SetBinding("CTRL-F9")
	SetBinding("ALT-F10")
	SetBinding("CTRL-F11")
	SetBinding("CTRL-F12")
	SetBinding("BUTTON3")
	SetBinding("SHIFT-UP")
	SetBinding("SHIFT-DOWN")
	SetBinding("SHIFT-MOUSEWHEELUP")
	SetBinding("SHIFT-MOUSEWHEELDOWN")
end

------------------------------------------------------------------------------------------------------
------------------------------------------ Create Macro's! -------------------------------------------
------------------------------------------------------------------------------------------------------

function mb_createMacros()

    SetActionBarToggles(1, 1, 1, 1, 1)
    SHOW_MULTI_ACTIONBAR_1 = 1
    SHOW_MULTI_ACTIONBAR_2 = 1
    SHOW_MULTI_ACTIONBAR_3 = 1
    SHOW_MULTI_ACTIONBAR_4 = 1
    ALWAYS_SHOW_MULTI_ACTIONBAR = 1
    MultiActionBar_Update()

    for i = 1, 36 do
        DeleteMacro(i)
    end

    mb_deleteMacros()
    mb_deleteSuperMacros()
    
    CreateMacro("01Setup", 487, "/script mb_setup()", 1, nil)
    CreateMacro("02Single", 121, "/script mb_single()", 1, nil)
    CreateMacro("03Multi", 155, "/script mb_multi()", 1, nil)
    CreateMacro("04Cooldowns", 21, "/script mb_cooldowns()", 1, nil)
    CreateMacro("05AOE", 206, "/script mb_AOE()", 1, nil)
    CreateMacro("06Mount", 90, "/script mb_mountUp()", 1, nil)
    CreateMacro("07InviteSum", 63, "/script mb_requestInviteSummon()", 1, nil)
    CreateMacro("08PWStanksCCPull", 394, "/script mb_crowdControlAsPull()", 1, nil)
    CreateMacro("09FocusME", 471, "/script mb_setFocus()", 1, nil)
    CreateMacro("10AssignOT", 22, "/script mb_assignOffTank()", 1, nil)
    CreateMacro("11AssignCC", 394, "/script mb_assignCrowdControl()", 1, nil)
    CreateMacro("12ClearAssign", 492, "/script mb_clearRaidTarget()", 1, nil)
    CreateMacro("13MakeWater", 339, "/script mb_makeWater()", 1, nil)
    CreateMacro("14DrinkWater", 339, "/script mb_smartDrink()", 1, nil)
    CreateMacro("15BreakFear", 489, "/script mb_fearBreak()", 1, nil)
    CreateMacro("16Follow", 129, "/script mb_followFocus()", 1, nil)
    CreateMacro("17Totems", 432, "/script mb_dropTotems()", 1, nil)
    CreateMacro("18Ress", 303, "/script mb_ress()", 1, nil)
    CreateMacro("19TankNheal", 165, "/script mb_healAndTank()", 1, 1)
    CreateMacro("20CraftCooldowns", 170, "/script mb_craftCooldowns()", 1, 1)
    CreateMacro("21Interrupt", 180, "/script mb_interruptSpell()", 1, 1)
    CreateMacro("22CasterFollow", 180, "/script mb_casterFollow()", 1, 1)
    CreateMacro("23MeleeFollow", 180, "/script mb_meleeFollow()", 1, 1)
    CreateMacro("24HealerFollow", 180, "/script mb_healerFollow()", 1, 1)
    CreateMacro("25TankFollow", 180, "/script mb_tankFollow()", 1, 1)
    CreateMacro("26ManualReck", 21, "/script mb_useManualRecklessness()", 1, 1)
    CreateMacro("27ReportMyCooldowns", 21, "/script mb_reportCooldowns()", 1, 1)
    CreateMacro("28TankShoot", 87, "/script mb_tankShoot()", 1, 1)
    CreateMacro("29ManualTaunt", 402, "/script mb_manualTaunt()", 1, 1)
    CreateMacro("30PreCast", 83, "/script mb_preCast()", 1, 1)
	CreateMacro("31Reload", 8, "/script ReloadUI()", 1, 1)

    mb_createBinds()
    mb_addonsDisableEnable()
	TrinketMenu_MainFrame:Hide()
end

local DeleteMacros = {
    "01Setup", "02Single", "03Multi", "04Cooldowns", "05AOE", "06Mount", "07InviteSum",
    "08PWStanks", "08PWStanksCCPull", "09FocusME", "10AssignOT", "11AssignCC",
    "12ClearAssign", "13MakeWater", "14DrinkWater", "15BreakFear", "16Follow",
    "17Totems", "18Totems", "18Ress", "19TankNheal", "20CraftCooldowns",
    "21Interrupt", "22CasterFollow", "23MeleeFollow", "24HealerFollow",
    "25TankFollow", "26ManualReck", "27ReportMyCooldowns", "28TankShoot",
    "29ManualTaunt", "30PreCast", "31Reload"
}

function mb_deleteMacros()
    for _, m in pairs(DeleteMacros) do
        while (GetMacroIndexByName(m)) > 0 do
            DeleteMacro(GetMacroIndexByName(m))
        end
    end  
end

function mb_deleteSuperMacros()
    for _, m in pairs(DeleteMacros) do
        while (GetSuperMacroInfo(m, "name")) do
            DeleteSuperMacro(GetSuperMacroInfo(m, "name"))
        end
    end
end

------------------------------------------------------------------------------------------------------
-------------------------------------- Diable / Enable Addon's! --------------------------------------
------------------------------------------------------------------------------------------------------

local EnableDisableAddons = {
    ["MoronBoxDecursive"] = {
        ["Priest"]  = true,
        ["Shaman"]  = true,
        ["Paladin"] = true,
        ["Druid"]   = true,
        ["Mage"]    = true,
        ["Warrior"] = false,
        ["Hunter"]  = false,
        ["Rogue"]   = false,
        ["Warlock"]   = false,
    },
    ["MoronBoxHeal"] = {
        ["Priest"]  = true,
        ["Shaman"]  = true,
        ["Paladin"] = true,
        ["Druid"]   = true,
        ["Mage"]    = false,
        ["Warrior"] = false,
        ["Hunter"]  = false,
        ["Rogue"]   = false,
        ["Warlock"]   = false,
    },
	["Thaliz"] = {
        ["Priest"]  = true,
        ["Shaman"]  = true,
        ["Paladin"] = true,
        ["Druid"]   = true,
        ["Mage"]    = false,
        ["Warrior"] = false,
        ["Hunter"]  = false,
        ["Rogue"]   = false,
        ["Warlock"]   = false,
    },
    ["MoronBoxSummon"] = {
        ["Priest"]  = false,
        ["Shaman"]  = false,
        ["Paladin"] = false,
        ["Druid"]   = false,
        ["Mage"]    = false,
        ["Warrior"] = false,
        ["Hunter"]  = false,
        ["Rogue"]   = false,
        ["Warlock"]   = true,
    },
	["MoronBoxGM"] = {
        ["Priest"]  = false,
        ["Shaman"]  = false,
        ["Paladin"] = false,
        ["Druid"]   = false,
        ["Mage"]    = false,
        ["Warrior"] = false,
        ["Hunter"]  = false,
        ["Rogue"]   = false,
        ["Warlock"]   = false,
    }
}

function mb_addonsDisableEnable()

    for Name, Class in EnableDisableAddons do
        if Class[myClass] then
            local _, _, _, Enabled, _, _, _ = GetAddOnInfo(Name)
            if not Enabled then
                EnableAddOn(Name)
            end
        else
            if GetAddOnInfo(Name) then 
                DisableAddOn(Name) 
            end
        end
    end

    ReloadUI()
end