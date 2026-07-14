-- [[ Config & Constants ]] --

MoronBox.Core.Rotation = MoronBox.Core.Rotation or {}

local myClass = UnitClass("player")

local PlayerMounts = {
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

---@diagnostic disable: undefined-global
setfenv(1, MoronBox:GetEnvironment())

-- [[ Simple Rotations ]] --

function MoronBox.Core.Rotation.Execute(rotation, context)
    if type(rotation) == "function" then
        rotation()
    else
        CdMessage("I don't know what to do for " .. (context or "this situation") .. ".", 500)
    end
end

function MoronBox.Core.Rotation.HealerJindo(spellName)
    if Instance.ZG() and HasBuffOrDebuff("Delusions of Jin'do", "player", "debuff") then
        if UnitName("target") == "Shade of Jin'do" and not Dead("target") then
            CastSpellByName(spellName)
        end
        return true
    end
    return false
end

function MoronBox.Core.Rotation.MountUp()
    if myClass == "Druid" and IsDruidShapeShifted() and not InCombat() then
        CancelDruidShapeShift()
    end

    if ImBusy() then
        return
    end

    if Instance.AQ40() then
        use(GetItemLink("Resonating"))
        return
    end

    for _, mount in PlayerMounts do
        use(GetItemLink(mount))
    end

    if myClass == "Warlock" and IsSpellKnown("Summon Dreadsteed") then
        CastSpellByName("Summon Dreadsteed")
        return
    end

    if myClass == "Paladin" and IsSpellKnown("Summon Charger") then
        CastSpellByName("Summon Charger")
        return
    end

    CastSpellByName("Summon Felsteed")
    CastSpellByName("Summon Warhorse")
end
