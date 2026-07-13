-- [[ Config & Constants ]] --

MoronBox.Unit = MoronBox.Unit or {}
local Unit = MoronBox.Unit

MoronBox.Core.Rotation = MoronBox.Core.Rotation or {}
local Rotation = MoronBox.Core.Rotation

function Rotation.Execute(rotation, context)
    if type(rotation) == "function" then
        rotation()
    else
        MoronBox.Api.CdMessage("I don't know what to do for " .. (context or "this situation") .. ".", 500)
    end
end

function Rotation.HealerJindo(spellName)
    if Instance.ZG() and mb_hasBuffOrDebuff("Delusions of Jin'do", "player", "debuff") then
        if UnitName("target") == "Shade of Jin'do" and not Unit.Dead("target") then
            CastSpellByName(spellName)
        end
        return true
    end
    return false
end
