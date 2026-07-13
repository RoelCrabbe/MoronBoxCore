-- [[ Config & Constants ]] --

MoronBox.Core.Rotation = MoronBox.Core.Rotation or {}
local Rotation = MoronBox.Core.Rotation

function Rotation.Execute(rotation, context)
    if type(rotation) == "function" then
        rotation()
    else
        MoronBox.Api.CdMessage("I don't know what to do for " .. (context or "this situation") .. ".", 500)
    end
end
