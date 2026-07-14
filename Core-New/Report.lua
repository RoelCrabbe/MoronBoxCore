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
        mb_cdMessage("I've got " .. count .. " shards!")
    end
end

function Report.Runes()
    if mb_imHealer() then
        local count = NumDemonicRunes()
        mb_cdMessage("I've got " .. count .. " runes!")
    end
end

function Report.Manapots()
    if mb_imHealer() then
        local count = NumManapots()
        mb_cdMessage("I've got " .. count .. " pots!")
    end
end

function Report.Sands()
    local count = NumSands()
    mb_cdMessage("I've got " .. count .. " sands!")
end
