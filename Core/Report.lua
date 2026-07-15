-- [[ Config & Constants ]] --

MoronBox.Core.Report = MoronBox.Core.Report or {}

local myClass = UnitClass("player")

function getReport()
    return MoronBox.Core.Report
end

-- [[ Report ]] --

function MoronBox.Core.Report.Shards()
    if myClass == "Warlock" then
        local count = getBag().NumShards()
        getApi().CdMessage("I've got " .. count .. " shards!")
    end
end

function MoronBox.Core.Report.Runes()
    if getCore().ImHealer() then
        local count = getBag().NumDemonicRunes()
        getApi().CdMessage("I've got " .. count .. " runes!")
    end
end

function MoronBox.Core.Report.Manapots()
    if getCore().ImHealer() then
        local count = getBag().NumManapots()
        getApi().CdMessage("I've got " .. count .. " pots!")
    end
end

function MoronBox.Core.Report.Sands()
    local count = getBag().NumSands()
    getApi().CdMessage("I've got " .. count .. " sands!")
end
