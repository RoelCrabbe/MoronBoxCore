------------------------------------------------------------------------------------------------------
----------------------------------- Annihilator Weaver Weapons! --------------------------------------
------------------------------------------------------------------------------------------------------

AnnihilatorWeaverWeapons = {
	-- Horde	
	["Jokamok"] = {
		["BMH"] = "Annihilator", -- HM
		["BOH"] = "The Hungering Cold", -- OH

		["NMH"] = "Gressil, Dawn of Ruin", -- HM
		["NOH"] = "The Hungering Cold" -- OH
	},

	-- Alliance
	["Alliance Warrior 1"] = {
		["BMH"] = "Annihilator", -- HM
		["BOH"] = "The Hungering Cold", -- OH

		["NMH"] = "Gressil, Dawn of Ruin", -- HM
		["NOH"] = "The Hungering Cold" -- OH
	},
}

function mb_getWeaverWeapon(Name, Type)
	return AnnihilatorWeaverWeapons[Name][Type]
end