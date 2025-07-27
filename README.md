# MoronBoxCore - Quick Start Guide

---

## Introduction

MoronBoxCore is a custom box-script project developed over the past 3 years.  
**Note:** This addon does **not** support leveling from 1-59.  
Everything is custom and will require changes to work for your setup.  
There are no step-by-step guides; some boxing experience is recommended.  
Once configured and your launch scripts are ready, usage should be straightforward.  
(Macros do not show on your bars.)

_Designed for the Vmangos core (2017-19). I ran boxing operations from 2018-2024. Some features may need updates for newer cores._

---

## Progress & Supported Content

As of 03/01/2024, the following content has been completed:

- **AQ40:** Everything up to Twins (Ouro ~70%) - Horde & Alliance
- **BWL:** Everything up to Chromagus (Nefarian 64%) - Horde & Alliance
- **MC:** Full clear
- **Naxxramas:**
  - Full Spider Wing
  - Noth, Heigan, Loatheb (53%)
  - Razuvious (Solo MC), Gothik, Four Horsemen (I once killed a horse :D)
  - Patchwerk, Grobbulus (World Second, World First 2-man), Gluth (21%)
- **Level 20 Raids:** Everything

> All features have been tested and work as intended.

---

## Simple Setup

1. Assign a raid inviter in `Functions/Config.lua`.
2. Make your `MB_RAID` unique if you want to "DUO" box (`Extra/Keybinds.lua`).
3. Change keybinds to your preference (`Extra/Keybinds.lua`) and set up a custom HKN team launcher.
4. Assign tanks in `MB_tankList` (`Functions/Config.lua`).
5. If you have fire mages, add them to the dedicated list (`Functions/Config.lua`)—they won't DPS otherwise.
6. Run `/init` on your windows; macros/keybinds will be created.
7. To invite your party, use the default keybind: **ALT-F3**.
8. Good luck!

---

## Advanced Setup

1. Complete the steps in the "Simple Setup" section.
2. For advanced features:
   - If `AutoEquipSet` is enabled, create an ItemRack set named **NRML** (auto-equips on login/reload).
   - Use the `GTFO` lists for encounter-specific autofollow (e.g., Baron Bomb).
   - Specify Annihilator users in `AnnihilatorWeavers` and update their weapons in `Database/WarriorData.lua` (bosses only).
   - Assign fire/frost mages for proper raid mixing.
   - Enable `MB_sortingBags` to auto-sort bags when opening a vendor (requires SortBags addon).
   - Use `mb_tankList(encounter)` to switch tank lists in-game with `/tanklist <encounter>`.
   - Add fury warriors with tank sets to `MB_furysThatCanTank` (requires ItemRack sets: DPS & TANK).
3. See `Functions/Encounters.lua` for encounter-specific tactics.
4. Adjust healing values in `Functions/Healing.lua`.
5. Edit tables in `Functions/Tables.lua` for buffs and other features.

**Tips:**

- Ensure ItemRack sets are configured (`/gear <set>`).
- Mages: EVO (spirit), DPS, and NRML sets.
- Warriors: DPS, Tank, and NRML sets.
- Others: NRML set to start.
- Read the Encounters and Config files for more info.
- Keep tank lists in order.

---

## Extra Utilities

- Only one rogue should use Expose Armor.
- Improved Demo is preferred over Unbridled Wrath.
- For more than 3 warlocks, consider a dedicated priest for boss stacks.
- Power Infusion is randomly assigned from the `PowerInfusionList`.
- Use Annihilator on at least one warrior for bosses.
- Assign fire/frost mages for optimal raid composition.

---

## Healing Assignments

**Uses the latest MBH healing addon.**

- Default overheal: ~19% (adjustable with `/MBH`).
- **Shamans:** Chain Heal (15-19% overheal, random target); Heal Wave (19% overheal, targets 1-2).
- **Paladins:** Flash of Light (2 heal target 1, rest random, 25-30% overheal).
- **Priests:** Heal (targets 1-2, 19-25% overheal); Flash Heal (targets 1-3, 5-11% overheal); Greater Heal for T2-equipped priests on MT fights.
- **Druids:** More Rejuvenation with 2T3 equipped (targets 1-2, 11-19% overheal).

See `Functions/Healing.lua` for details.

---

## Recommended Specs

- **Warrior:** [Fury Dual Wield](https://classicdb.ch/?talent#LhhxzhbZVV0VgxoVo) | [Fury 2H](https://classicdb.ch/?talent#LhhxzIbZVVbVMxoVo) | [Fury Tank](https://classicdb.ch/?talent#LhZVV0VLxoVoxfzox) | [Improved Demo Tank](https://classicdb.ch/?talent#LhZVv0V0xoVoxfzox) | [Full Prot1](https://classicdb.ch/?talent#LV0hZVZEizoeMdVo) | [Full Prot2](https://classicdb.ch/?talent#LV0hZVVZxizoeMdVo)
- **Priest:** [Heal](https://classicdb.ch/?talent#bxRhsV0oZrxxccMcx) | [Shadowweaver](https://classicdb.ch/?talent#bxMhsZfbxccZx0gd0L)
- **Mage:** [Fire](https://classicdb.ch/?talent#of0E00MZxg0zfcut0h) | [Deep Frost](https://classicdb.ch/?talent#of0EM0cZZVA0c0fzAo) | [Arcane Frost](https://classicdb.ch/?talent#of0ycocquZVA0c0r)
- **Warlock:** [Sacrifice](https://classicdb.ch/?talent#IV0bZfx0zThoZvx0tM0z) | [Imp](https://classicdb.ch/?talent#IEhbuRboVZZgx0tM0z)
- **Rogue:** [Sword](https://classicdb.ch/?talent#fbecoxZMxqb0Vzxfo) | [Mace](https://classicdb.ch/?talent#fbecoxZMxqb0Vt0fo) | [Expose](https://classicdb.ch/?talent#f0ecRxZMhqbbVzxfo) | [Expose Hemorrhage](https://classicdb.ch/?talent#f0ecRxZ0xVZxMe0Mhoo)
- **Hunter:** [Hunter](https://classicdb.ch/?talent#ce0MZVEohthtf0b)
- **Druid:** [Feral](https://classicdb.ch/?talent#0x0V0oZxxxscMdtx0b) | [Healing](https://classicdb.ch/?talent#0x0bIMVsZZxtcotq) | [Swiftmend Dot](https://classicdb.ch/?talent#0xM0hMZZxEcoeqVo)
- **Shaman:** [Healer](https://classicdb.ch/?talent#hZxZEfxtVeqo) | [Improved WF](https://classicdb.ch/?talent#hZxdbbxGZtcxt0eo)

---

## Extra Resources

- [WarriorSim](https://guybrushgit.github.io/WarriorSim/)
