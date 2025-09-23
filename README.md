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

As of 03/01/2024, the following content has been completed (solo):

- **AQ40:** Everything up to Twins (Ouro ~70%) - Horde & Alliance
- **BWL:** Everything up to Chromagus (Nefarian 64%) - Horde & Alliance
- **MC:** Full clear
- **Naxxramas:**
  - Full Spider Wing
  - Noth, Heigan, Loatheb
  - Razuvious, Gothik
  - Patchwerk, Grobbulus, Gluth, Thaddius
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

## Pre Raid Bis Lists

**Mage**

- Spellweaver's Turban: 22267
- Diana's Pearl Necklace: 22403
- Burial Shawl : 18681
- Spritecaster Cape: 11623
- Bloodvine Vest: 19682
- Bloodvine Leggings: 19683
- Bloodvine Boots: 19684
- Manacle Cuffs: 11962
- Gloves of Spell Mastery : 14146
- Ban'thok Sash: 11662
- Rune Band of Wizardry: 22339
- Don Mauricio's Band of Domination: 22433
- Draconic Infused Emblem: 22268
- Eye of the beast: 13968
- Briarwood Reed: 12930
- Scepter of Interminable Focus: 22329
- Sageblade: 22383
- Bonecreeper Stylus: 13938

**Warlock**

- Spellweaver's Turban: 22267
- Diana's Pearl Necklace: 22403
- Burial Shawl : 18681
- Spritecaster Cape: 11623
- Bloodvine Vest: 19682
- Bloodvine Leggings: 19683
- Bloodvine Boots: 19684
- Manacle Cuffs: 11962
- Felcloth Gloves: 18407
- Ban'thok Sash: 11662
- Rune Band of Wizardry: 22339
- Don Mauricio's Band of Domination: 22433
- Draconic Infused Emblem: 22268
- Eye of the beast: 13968
- Briarwood Reed: 12930
- Scepter of Interminable Focus: 22329
- Sageblade: 22383
- Skul's Ghastly Touch: 13396

**Priest**

- Crimson Felt Hat: 18727
- Animated Chain Necklace: 18723
- Mantle of Lost Hope: 22234
- Hide of the Wild: 18510
- Truefaith Vestement: 14154
- Bracers of Mending: 23129
- Hands of the Exalted Herald: 12554
- Whipvine Cord: 18327
- Padre's Trousers: 18386
- Faith Healer's Boots: 22247
- Fordring's Seal: 16058
- Rosewine Circle: 13178
- Draconic Infused Emblem: 22268
- Royal Seal of Eldre'Thalas: 18469
- Briarwood Reed: 12930
- The Hammer of Grace: 11923
- Brightly Glowing Stone: 18523
- Bonecreeper Stylus: 13938

**Druid**

- Insightful Hood: 18490
- Animated Chain Necklace: 18723
- Mantle of Lost Hope: 22234
- Hide of the Wild: 18510
- Robes of the Exalted: 13346
- Bracers of Prosperity: 18525
- Hands of the Exalted Herald: 12554
- Corehound Belt: 19162
- Padre's Trousers: 18386
- Faith Healer's Boots: 22247
- Fordring's Seal: 16058
- Rosewine Circle: 13178
- Draconic Infused Emblem: 22268
- Royal Seal of Eldre'Thalas: 18470
- Briarwood Reed: 12930
- The Hammer of Grace: 11923
- Brightly Glowing Stone: 18523
- Idol of Rejuvination: 22398

**Paladin**

- Insightful Hood: 18490
- Animated Chain Necklace: 18723
- Mantle of Lost Hope: 22234
- Hide of the Wild: 18510
- Robes of the Exalted: 13346
- Loomguard Armbraces: 13969
- Harmonious Gauntlets: 18527
- Corehound Belt: 19162
- Padre's Trousers: 18386
- Faith Healer's Boots: 22247
- Fordring's Seal: 16058
- Rosewine Circle: 13178
- Draconic Infused Emblem: 22268
- Royal Seal of Eldre'Thalas: 18472
- Briarwood Reed: 12930
- The Hammer of Grace: 11923
- Brightly Glowing Stone: 18523
- Libram of Divinity: 23201

**Rogue**

- Mask of the Unforgiven: 13404
- Mark of Fordring: 15411
- Truestrike Shoulders: 12927
- Cape of the Black Baron: 13340
- Cadaverous Armor: 14637
- Shadowcraft Bracers: 16710
- Devilsaur Gauntlets: 15063
- Shadowcraft Belt: 16713
- Devilsaur Leggings: 15062
- Shadowcraft Boots: 16711
- Tarnished Elven Ring: 18500 x2
- Hand of Justice: 11815
- Royal Seal of Eldre'Thalas: 18465
- Dal'Rend's Sacred Charge: 12940
- Dal'Rend's Tribal Guardian: 12939
- Blackcrow: 12651

**Warrior**

- Lionheart Helm: 12640
- Mark of Fordring: 15411
- Truestrike Shoulders: 12927
- Cape of the Black Baron: 13340
- Savage Gladiator Chain: 11726
- Battleborn Armbraces: 12936
- Omokk's Girth Restrainer: 13959
- Titanic Leggings: 22385
- Bloodmail Boots: 14616
- Blackstone Ring: 17713
- Painweaver Band: 13098
- Diamond Flask: 20130
- Hand of Justice: 11815
- Blackhand's Breadth: 13965
- Blackcrow: 12651

- Gargoyle Slashers: 13957
- Ebon Hand: 19170
- Dal'Rend's Tribal Guardian: 12939

- Edgemaster's Handguards: 14551
- Dal'Rend's Sacred Charge: 12940
- Dal'Rend's Tribal Guardian: 12939

**Druid Tank**

- Mask of the Unforgiven: 13404
- Mark of Fordring: 15411
- Truestrike Shoulders: 12927
- Phantasmal Cloak: 18689
- Primal Batskin Jerkin: 19685
- Blackmist Armguards: 12966
- Primal Batskin Gloves: 19686
- Molten Belt: 19163
- Devilsaur Leggings: 15062
- Boots of Ferocity: 22472
- Myrmidon's Signet: 2246
- Ring of Protection: 15855
- Hand of Justice: 11815
- Blackhand's Breadth: 13965
- Unyielding Maul: 18531

**Warrior Tank**

- Lionheart Helm: 12640
- Helm of the Executioner: 22411
- Beads of Ogre Might : 22150
- Spaulders of Valor: 16733
- Stoneskin Gargoyle Cape: 13397
- Savage Gladiator Chain: 11726
- Battleborn Armbraces: 12936
- Omokk's Girth Restrainer: 13959
- Brigam Girdle: 13142
- Cloudkeeper Legplates: 14554
- Bloodmail Boots: 14616
- Myrmidon's Signet: 2246
- Blackstone Ring: 17713
- Diamond Flask: 20130
- Hand of Justice: 11815
- Blackhand's Breadth: 13965
- Blackcrow: 12651
- Draconian Deflector: 12602

- Voone's Vice Grips: 13963
- Ebon Hand: 19170
- Dal'Rend's Tribal Guardian: 12939

- Edgemaster's Handguards: 14551
- Dal'Rend's Sacred Charge: 12940
- Dal'Rend's Tribal Guardian: 12939
