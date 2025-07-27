------------------------------------------------------------------------------------------------------
----------------------------------- Annihilator Weaver Weapons! --------------------------------------
------------------------------------------------------------------------------------------------------

AnnihilatorWeaverWeapons = {
	-- Horde	
	["Tazmahdingo"] = {
		["BMH"] = "Annihilator", -- HM
		["BOH"] = "Iblis, Blade of the Fallen Seraph", -- OH

		["NMH"] = "Hatchet of Sundered Bone", -- HM
		["NOH"] = "Iblis, Blade of the Fallen Seraph" -- OH
	},
	["Dl"] = {
		["BMH"] = "Annihilator", -- HM
		["BOH"] = "Blessed Qiraji War Axe", -- OH

		["NMH"] = "Hatchet of Sundered Bone", -- HM
		["NOH"] = "Blessed Qiraji War Axe" -- OH
	},
	["Ajlano"] = { -- TANK
		["BMH"] = "Annihilator", -- HM
		["BOH"] = "Widow\'s Remorse", -- OH

		["NMH"] = "The Hungering Cold", -- HM
		["NOH"] = "Widow\'s Remorse" -- OH
	},
	["Rows"] = { -- TANK
		["BMH"] = "Annihilator", -- HM
		["BOH"] = "Iblis, Blade of the Fallen Seraph", -- OH

		["NMH"] = "The Hungering Cold", -- HM
		["NOH"] = "Iblis, Blade of the Fallen Seraph" -- OH
	},
	["Almisael"] = { -- TANK
		["BMH"] = "Annihilator", -- HM
		["BOH"] = "Crul\'shorukh, Edge of Chaos", -- OH

		["NMH"] = "Hatchet of Sundered Bone", -- HM
		["NOH"] = "Crul\'shorukh, Edge of Chaos" -- OH
	},
	["Tauror"] = { -- TANK
		["BMH"] = "Annihilator", -- HM
		["BOH"] = "Iblis, Blade of the Fallen Seraph", -- OH

		["NMH"] = "High Warlord\'s Cleaver", -- HM
		["NOH"] = "Iblis, Blade of the Fallen Seraph" -- OH
	},

	-- Alliance
	["Hutao"] = {
		["BMH"] = "Annihilator", -- HM
		["BOH"] = "Grand Marshal\'s Swiftblade", -- OH

		["NMH"] = "Grand Marshal\'s Longsword", -- HM
		["NOH"] = "Grand Marshal\'s Swiftblade" -- OH
	},
	["Uvu"] = {
		["BMH"] = "Annihilator", -- HM
		["BOH"] = "Harbinger of Doom", -- OH

		["NMH"] = "Hatchet of Sundered Bone", -- HM
		["NOH"] = "Harbinger of Doom" -- OH
	},
	["Drudish"] = { -- TANK
		["BMH"] = "Annihilator", -- HM
		["BOH"] = "Iblis, Blade of the Fallen Seraph", -- OH

		["NMH"] = "Misplaced Servo Arm", -- HM
		["NOH"] = "Iblis, Blade of the Fallen Seraph" -- OH
	}
}

function mb_GetWeaverWeapon(Name, Type)
	return AnnihilatorWeaverWeapons[Name][Type]
end