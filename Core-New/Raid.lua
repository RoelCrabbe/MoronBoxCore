-- [[ Config & Constants ]] --

MoronBox.Core.Raid = MoronBox.Core.Raid or {}
local Raid = MoronBox.Core.Raid

local MB_anubAlertCD = GetTime()

function Raid.AnubisathAlert()
    if mb_imFocus() or UnitName("target") ~= "Anubisath Sentinel" then
        return
    end

    local now = GetTime()
    if MB_anubAlertCD + 5 > now then
        return
    end

    local alerts = {
        ["Shadow Storm"]             = "SHADOW STORM, BACK ME UP",
        ["Mana Burn"]                = "MANA BURN, BACK ME UP",
        ["Thunderclap"]              = "THUNDERCLAP, BACK ME UP",
        ["Thorns"]                   = "This guy has Thorns",
        ["Mortal Strike"]            = "This guy has Mortal Strike",
        ["Shadow and Frost Reflect"] = "This guy has Shadow and Frost Reflect",
        ["Fire and Arcane Reflect"]  = "This guy has Fire and Arcane Reflect",
        ["Mending"]                  = "This guy has Mending",
        ["Periodic Knock Away"]      = "This guy has Knockaway"
    }

    for buff, message in pairs(alerts) do
        if mb_hasBuffOrDebuff(buff, "target", "buff") then
            MB_anubAlertCD = now
            MoronBox.Api.CdSay(message)
            break
        end
    end
end
