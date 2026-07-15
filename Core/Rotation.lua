-- [[ Config & Constants ]] --

MoronBox.Core.Rotation = MoronBox.Core.Rotation or {}

local myClass = UnitClass("player")
local myName = UnitName("player")
local myRace = UnitRace("player")

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

-- [[ Simple Rotations ]] --

function MoronBox.Core.Rotation.Execute(rotation, context)
    if type(rotation) == "function" then
        rotation()
    else
        getApi().CdMessage("I don't know what to do for " .. (context or "this situation") .. ".", 500)
    end
end

function MoronBox.Core.Rotation.HealerJindo(spellName)
    if Instance.ZG() and getAura().HasBuffOrDebuff("Delusions of Jin'do", "player", "debuff") then
        if UnitName("target") == "Shade of Jin'do" and not getUnit().IsDead("target") then
            CastSpellByName(spellName)
        end
        return true
    end
    return false
end

function MoronBox.Core.Rotation.MountUp()
    if myClass == "Druid" and getUnit().IsDruidShapeShifted() and not getUnit().InCombat() then
        getUnit().CancelDruidShapeShift()
    end

    if getSpells().ImBusy() then
        return
    end

    if Instance.AQ40() then
        use(getBag().GetItemLink("Resonating"))
        return
    end

    for _, mount in PlayerMounts do
        use(getBag().GetItemLink(mount))
    end

    if myClass == "Warlock" and getSpells().IsSpellKnown("Summon Dreadsteed") then
        CastSpellByName("Summon Dreadsteed")
        return
    end

    if myClass == "Paladin" and getSpells().IsSpellKnown("Summon Charger") then
        CastSpellByName("Summon Charger")
        return
    end

    CastSpellByName("Summon Felsteed")
    CastSpellByName("Summon Warhorse")
end

-- [[ Set Focus ]] --

function MoronBox.Core.Rotation.SetFocus()
    if IsShiftKeyDown() then
        local targetLeader = UnitName("target")
        MB_raidLeader = targetLeader
        getApi().SendAddonMessage(MB_RAID .. "_FTAR", MB_raidLeader .. " " .. myName)
    else
        MB_raidLeader = myName
        getApi().SendAddonMessage(MB_RAID, "MB_FOCUSME")
    end
end

-- [[ Clear Marks ]] --

function MoronBox.Core.Rotation.ClearRaidTarget()
    if not getRaid().ImFocus() then
        return
    end

    getApi().SendAddonMessage(MB_RAID .. "CLR_TARG", myName)
    SetRaidTarget("target", 0)
end

-- [[ COOLDOWNS ]] --

function MoronBox.Core.Rotation.Cooldowns()
    if not MB_raidLeader and (getApi().TableLength(MBID) > 1) then
        getApi().CdPrint("WARNING: You have not chosen a raid leader")
    end

    if getUnit().IsDead() then
        return
    end

    if Instance.ZG() then
        if getAura().MandokirGaze() then
            return
        end
    end

    if not getRaid().ImFocus() then
        return
    end

    if UnitInRaid("player") then
        if getUnit().InCombat("player") then
            if not MB_useCooldowns.Active then
                getApi().CdPrint("Sending out request to use Cooldowns.")
            else
                getApi().CdPrint("Stop Cooldown Requesting, still " ..
                    math.round(MB_useCooldowns.Time - GetTime()) .. "s remaining")
            end
        end

        getApi().SendAddonMessage(MB_RAID, "MB_USECOOLDOWNS")
    else
        getApi().SendAddonMessage(MB_RAID, "MB_USECOOLDOWNS")
    end
end

function MoronBox.Core.Rotation.UseManualRecklessness()
    if not MB_raidLeader and (getApi().TableLength(MBID) > 1) then
        getApi().CdPrint("WARNING: You have not chosen a raid leader")
    end

    if getUnit().IsDead() then
        return
    end

    if Instance.ZG() then
        if getAura().MandokirGaze() then
            return
        end
    end

    if mb_mobsNoTotems() then
        return
    end

    if not getRaid().ImFocus() then
        return
    end

    if UnitInRaid("player") then
        if getUnit().InCombat("player") then
            if not MB_useBigCooldowns.Active then
                getApi().CdPrint("Sending out request to use Recklessness.")
            else
                getApi().CdPrint("Stop Recklessness Requesting, still " ..
                    math.round(MB_useBigCooldowns.Time - GetTime()) .. "s remaining")
            end
        end

        getApi().SendAddonMessage(MB_RAID, "MB_USERECKLESSNESS")
    else
        getApi().SendAddonMessage(MB_RAID, "MB_USERECKLESSNESS")
    end
end
