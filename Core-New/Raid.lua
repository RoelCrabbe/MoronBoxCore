-- [[ Config & Constants ]] --

MoronBox.Unit = MoronBox.Unit or {}
local Unit = MoronBox.Unit

MoronBox.Core.Raid = MoronBox.Core.Raid or {}
local Raid = MoronBox.Core.Raid

local myClass = UnitClass("player") --[[@as string]]
local myName = UnitName("player") --[[@as string]]
local myRace = UnitRace("player") --[[@as string]]

-- [[ GTFO ]] --

function Raid.GTFO()
    if not MB_raidAssist.GTFO.Active then
        return
    end

    mb_useSandsOnChromaggus()

    if mb_imFocus() then
        return
    end

    if Instance.ONY() and MB_myOnyxiaBoxStrategy then
        if mb_tankTarget("Onyxia") and (mb_tankTargetHealth() <= 0.65 and mb_tankTargetHealth() >= 0.4) and myName ~= MB_myOnyxiaMainTank then
            if mb_focusAggro() then
                if myClass == "Paladin" and mb_spellReady("Divine Shield") then
                    CastSpellByName("Divine Shield")
                    return
                end

                local runTank = Unit.ReturnPlayerInRaidFromTable(MB_raidAssist.GTFO.Onyxia)
                local runTankId = MoronBox.Core.State.MBID[runTank]

                if runTankId and Unit.IsAlive(runTankId) then
                    FollowByName(runTank, 1)
                end
            else
                local mainTankId = MoronBox.Core.State.MBID[MB_myOnyxiaFollowTarget]

                if mainTankId and Unit.InRange(mainTankId) then
                    if not Unit.InMeleeRange(mainTankId) then
                        FollowByName(MB_myOnyxiaFollowTarget, 1)
                    end
                end
            end
        end
    end

    if not Unit.AggroOnPlayer() then
        if Instance.NAXX() then
            GLUTH_GetOUT()
            GROB_GetOUT()
            mb_useFirePotsOnFaerlina()
        elseif Instance.BWL() and mb_hasBuffOrDebuff("Burning Adrenaline", "player", "debuff") then
            if myClass == "Paladin" and mb_spellReady("Divine Shield") then
                CastSpellByName("Divine Shield")
                return
            end

            local vaelTank = Unit.ReturnPlayerInRaidFromTable(MB_raidAssist.GTFO.Vaelastrasz)
            local vaelTankId = MoronBox.Core.State.MBID[vaelTank]

            if vaelTankId and Unit.IsAlive(vaelTankId) then
                FollowByName(vaelTank, 1)
            end
        elseif Instance.MC() and mb_hasBuffOrDebuff("Living Bomb", "player", "debuff") then
            if myClass == "Paladin" and mb_spellReady("Divine Shield") then
                CastSpellByName("Divine Shield")
                return
            end

            local baronTank = Unit.ReturnPlayerInRaidFromTable(MB_raidAssist.GTFO.Baron)
            local baronTankId = MoronBox.Core.State.MBID[baronTank]

            if baronTankId and Unit.IsAlive(baronTankId) then
                FollowByName(baronTank, 1)
            end
        end
    end
end

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
