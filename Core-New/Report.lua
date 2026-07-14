-- [[ Config & Constants ]] --

MoronBox.Core.Report = MoronBox.Core.Report or {}

local myClass = UnitClass("player")

local Report = MoronBox.Core.Report

---@diagnostic disable: undefined-global
setfenv(1, MoronBox:GetEnvironment())

-- [[ Report ]] --

function Report.Shards()
    if myClass == "Warlock" then
        local count = NumShards()
        CdMessage("I've got " .. count .. " shards!")
    end
end

function Report.Runes()
    if ImHealer() then
        local count = NumDemonicRunes()
        CdMessage("I've got " .. count .. " runes!")
    end
end

function Report.Manapots()
    if ImHealer() then
        local count = NumManapots()
        CdMessage("I've got " .. count .. " pots!")
    end
end

function Report.Sands()
    local count = NumSands()
    CdMessage("I've got " .. count .. " sands!")
end
