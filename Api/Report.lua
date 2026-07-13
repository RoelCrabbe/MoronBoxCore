-- [[ Config & Constants ]] --

MoronBox.Bag = MoronBox.Bag or {}
local Bag = MoronBox.Bag

MoronBox.Report = MoronBox.Report or {}
local Report = MoronBox.Report

-- Common Names
local myClass = UnitClass("player") --[[@as string]]
local myName = UnitName("player") --[[@as string]]
local myRace = UnitRace("player") --[[@as string]]

-- [[ Report ]] --

function Report.Shards()
    if myClass == "Warlock" then
        local count = Bag.NumShards()
        mb_cdMessage("I've got " .. count .. " shards!")
    end
end

function Report.Runes()
    if mb_imHealer() then
        local count = Bag.NumDemonicRunes()
        mb_cdMessage("I've got " .. count .. " runes!")
    end
end

function Report.Manapots()
    if mb_imHealer() then
        local count = Bag.NumManapots()
        mb_cdMessage("I've got " .. count .. " pots!")
    end
end

function Report.Sands()
    local count = Bag.NumSands()
    mb_cdMessage("I've got " .. count .. " sands!")
end
