# Wild Pokémon Held Item Probabilities

Wild Pokémon held items are resolved at the start of battle by `_RollWildHeldItem`
(`engine/battle/wild_item_drop.asm`). Each species has four item slots in its base
stats: **Item1**, **Item2**, **Item3**, and **Item4**.

The **Mod Held Items** setting (`MODFLAG_WILD_HELD_ITEM_MOD_F`, toggled on page 4 of
the new-game options or in the debug room) selects which item group is used. The two
groups are mutually exclusive — enabling the flag replaces the standard roll entirely.

---

## How the roll works

### Flag OFF — standard roll (Item1 / Item2)

- Roll `BattleRandom`.
- **< 193 (~75%)** → `NO_ITEM`.
- **≥ 193 (~25%)** → roll again:
  - **< 20 (~8% of 25% → ~2% overall)** → hold Item2.
  - **≥ 20 (~92% of 25% → ~23% overall)** → hold Item1.
- If `MODFLAG_WILD_HELD_ITEM_RAND_F` is also set, the item is drawn randomly from
  `RandomizableItems` instead of using Item1/Item2.

### Flag ON — mod roll (Item3 / Item4)

- Roll `BattleRandom`.
- **< 193 (~75%)** → `NO_ITEM`.
- **≥ 193 (~25%)** → roll again:
  - **< 102 (~40% of 25% → ~10% overall)** → hold Item4.
  - **≥ 102 (~60% of 25% → ~15% overall)** → hold Item3.
- Item1/Item2 are never consulted when the flag is on.

---

## Probability tables

### Mod Held Items OFF

| Outcome | Probability |
|---------|-------------|
| NO_ITEM | ~75%        |
| Item1   | ~23%        |
| Item2   | ~2%         |

### Mod Held Items ON

| Outcome | Probability |
|---------|-------------|
| NO_ITEM | ~75%        |
| Item3   | ~15%        |
| Item4   | ~10%        |

**Species with Item1 or Item2 also set**

---

## Special cases

| Situation | Behaviour |
|-----------|-----------|
| `BATTLETYPE_FORCEITEM` | Bypasses `_RollWildHeldItem` entirely. Item1 is always held (used for Ho-Oh, Lugia, Snorlax). |
| `MODFLAG_WILD_HELD_ITEM_RAND_F` ON | Only applies when Mod Held Items is OFF. Replaces Item1/Item2 with a random pick from `RandomizableItems`. Has no effect when Mod Held Items is ON. |

---

## Item slot assignments

Item slots are defined in `data/pokemon/base_stats/<species>.asm`:

```asm
db Item1, Item2, Item3, Item4 ; items
```

- **Item1 / Item2** — the original Crystal held-item system, used when Mod Held Items
  is OFF. ~61 species have at least one non-`NO_ITEM` slot.
- **Item3 / Item4** — used when Mod Held Items is ON, replacing Item1/Item2 entirely.
  Assigned thematically per primary type (e.g. Psychic → `BITTER_BERRY` /
  `TWISTEDSPOON`; Fire → `BURNT_BERRY` / `CHARCOAL`). Item3 is the common drop
  (~15%) and Item4 is the rare drop (~10%).

---

## Species held item reference

| # | Species | Item1 | Item2 | Item3 | Item4 |
|---|---------|-------|-------|-------|-------|
| 1 | Bulbasaur | NO_ITEM | NO_ITEM | PSNCUREBERRY | MIRACLE_SEED |
| 2 | Ivysaur | NO_ITEM | NO_ITEM | PSNCUREBERRY | MIRACLE_SEED |
| 3 | Venusaur | NO_ITEM | NO_ITEM | PSNCUREBERRY | MIRACLE_SEED |
| 4 | Charmander | NO_ITEM | NO_ITEM | BURNT_BERRY | CHARCOAL |
| 5 | Charmeleon | NO_ITEM | NO_ITEM | BURNT_BERRY | CHARCOAL |
| 6 | Charizard | NO_ITEM | NO_ITEM | BURNT_BERRY | CHARCOAL |
| 7 | Squirtle | NO_ITEM | NO_ITEM | BERRY | MYSTIC_WATER |
| 8 | Wartortle | NO_ITEM | NO_ITEM | BERRY | MYSTIC_WATER |
| 9 | Blastoise | NO_ITEM | NO_ITEM | BERRY | MYSTIC_WATER |
| 10 | Caterpie | NO_ITEM | NO_ITEM | PSNCUREBERRY | SILVERPOWDER |
| 11 | Metapod | NO_ITEM | NO_ITEM | PSNCUREBERRY | SILVERPOWDER |
| 12 | Butterfree | NO_ITEM | SILVERPOWDER | PSNCUREBERRY | SILVERPOWDER |
| 13 | Weedle | NO_ITEM | NO_ITEM | PSNCUREBERRY | POISON_BARB |
| 14 | Kakuna | NO_ITEM | NO_ITEM | PSNCUREBERRY | POISON_BARB |
| 15 | Beedrill | NO_ITEM | POISON_BARB | PSNCUREBERRY | POISON_BARB |
| 16 | Pidgey | NO_ITEM | NO_ITEM | BERRY | SHARP_BEAK |
| 17 | Pidgeotto | NO_ITEM | NO_ITEM | BERRY | SHARP_BEAK |
| 18 | Pidgeot | NO_ITEM | NO_ITEM | BERRY | SHARP_BEAK |
| 19 | Rattata | NO_ITEM | NO_ITEM | BERRY | QUICK_CLAW |
| 20 | Raticate | NO_ITEM | NO_ITEM | BERRY | QUICK_CLAW |
| 21 | Spearow | NO_ITEM | NO_ITEM | NO_ITEM | SHARP_BEAK |
| 22 | Fearow | NO_ITEM | SHARP_BEAK | NO_ITEM | SHARP_BEAK |
| 23 | Ekans | NO_ITEM | NO_ITEM | PSNCUREBERRY | POISON_BARB |
| 24 | Arbok | NO_ITEM | NO_ITEM | PSNCUREBERRY | POISON_BARB |
| 25 | Pikachu | NO_ITEM | BERRY | BERRY | LIGHT_BALL |
| 26 | Raichu | NO_ITEM | BERRY | BERRY | LIGHT_BALL |
| 27 | Sandshrew | NO_ITEM | NO_ITEM | YLW_APRICORN | SOFT_SAND |
| 28 | Sandslash | NO_ITEM | NO_ITEM | YLW_APRICORN | SOFT_SAND |
| 29 | Nidoran♀ | NO_ITEM | NO_ITEM | PSNCUREBERRY | POISON_BARB |
| 30 | Nidorina | NO_ITEM | NO_ITEM | PSNCUREBERRY | MOON_STONE |
| 31 | Nidoqueen | NO_ITEM | NO_ITEM | PSNCUREBERRY | POISON_BARB |
| 32 | Nidoran♂ | NO_ITEM | NO_ITEM | PSNCUREBERRY | POISON_BARB |
| 33 | Nidorino | NO_ITEM | NO_ITEM | PSNCUREBERRY | MOON_STONE |
| 34 | Nidoking | NO_ITEM | NO_ITEM | PSNCUREBERRY | POISON_BARB |
| 35 | Clefairy | MYSTERYBERRY | MOON_STONE | MYSTERYBERRY | MOON_STONE |
| 36 | Clefable | MYSTERYBERRY | MOON_STONE | MYSTERYBERRY | MOON_STONE |
| 37 | Vulpix | BURNT_BERRY | BURNT_BERRY | BURNT_BERRY | CHARCOAL |
| 38 | Ninetales | BURNT_BERRY | BURNT_BERRY | BURNT_BERRY | CHARCOAL |
| 39 | Jigglypuff | NO_ITEM | NO_ITEM | NO_ITEM | MOON_STONE |
| 40 | Wigglytuff | NO_ITEM | NO_ITEM | NO_ITEM | MOON_STONE |
| 41 | Zubat | NO_ITEM | NO_ITEM | PSNCUREBERRY | POISON_BARB |
| 42 | Golbat | NO_ITEM | NO_ITEM | PSNCUREBERRY | POISON_BARB |
| 43 | Oddish | NO_ITEM | NO_ITEM | MINT_BERRY | MIRACLE_SEED |
| 44 | Gloom | NO_ITEM | NO_ITEM | MINT_BERRY | MIRACLE_SEED |
| 45 | Vileplume | NO_ITEM | NO_ITEM | MINT_BERRY | MIRACLE_SEED |
| 46 | Paras | TINYMUSHROOM | BIG_MUSHROOM | TINYMUSHROOM | BIG_MUSHROOM |
| 47 | Parasect | TINYMUSHROOM | BIG_MUSHROOM | TINYMUSHROOM | BIG_MUSHROOM |
| 48 | Venonat | NO_ITEM | NO_ITEM | PSNCUREBERRY | SILVERPOWDER |
| 49 | Venomoth | NO_ITEM | NO_ITEM | PSNCUREBERRY | SILVERPOWDER |
| 50 | Diglett | NO_ITEM | NO_ITEM | BERRY | SOFT_SAND |
| 51 | Dugtrio | NO_ITEM | NO_ITEM | BERRY | SOFT_SAND |
| 52 | Meowth | NO_ITEM | NO_ITEM | BERRY | QUICK_CLAW |
| 53 | Persian | NO_ITEM | NO_ITEM | BERRY | QUICK_CLAW |
| 54 | Psyduck | NO_ITEM | NO_ITEM | BERRY | MYSTIC_WATER |
| 55 | Golduck | NO_ITEM | NO_ITEM | BERRY | MYSTIC_WATER |
| 56 | Mankey | NO_ITEM | NO_ITEM | BITTER_BERRY | BLACKBELT_I |
| 57 | Primeape | NO_ITEM | NO_ITEM | BITTER_BERRY | BLACKBELT_I |
| 58 | Growlithe | BURNT_BERRY | BURNT_BERRY | BURNT_BERRY | CHARCOAL |
| 59 | Arcanine | BURNT_BERRY | BURNT_BERRY | BURNT_BERRY | CHARCOAL |
| 60 | Poliwag | NO_ITEM | NO_ITEM | NO_ITEM | KINGS_ROCK |
| 61 | Poliwhirl | NO_ITEM | KINGS_ROCK | NO_ITEM | KINGS_ROCK |
| 62 | Poliwrath | NO_ITEM | KINGS_ROCK | NO_ITEM | KINGS_ROCK |
| 63 | Abra | NO_ITEM | NO_ITEM | BITTER_BERRY | SMOKE_BALL |
| 64 | Kadabra | NO_ITEM | NO_ITEM | BITTER_BERRY | TWISTEDSPOON |
| 65 | Alakazam | NO_ITEM | NO_ITEM | BITTER_BERRY | TWISTEDSPOON |
| 66 | Machop | NO_ITEM | NO_ITEM | DIRE_HIT | BLACKBELT_I |
| 67 | Machoke | NO_ITEM | NO_ITEM | DIRE_HIT | BLACKBELT_I |
| 68 | Machamp | NO_ITEM | NO_ITEM | DIRE_HIT | BLACKBELT_I |
| 69 | Bellsprout | NO_ITEM | NO_ITEM | PSNCUREBERRY | MIRACLE_SEED |
| 70 | Weepinbell | NO_ITEM | NO_ITEM | PSNCUREBERRY | MIRACLE_SEED |
| 71 | Victreebel | NO_ITEM | NO_ITEM | PSNCUREBERRY | MIRACLE_SEED |
| 72 | Tentacool | NO_ITEM | NO_ITEM | NO_ITEM | NO_ITEM |
| 73 | Tentacruel | NO_ITEM | NO_ITEM | NO_ITEM | NO_ITEM |
| 74 | Geodude | NO_ITEM | EVERSTONE | BERRY | HARD_STONE |
| 75 | Graveler | NO_ITEM | EVERSTONE | BERRY | HARD_STONE |
| 76 | Golem | NO_ITEM | EVERSTONE | BERRY | HARD_STONE |
| 77 | Ponyta | NO_ITEM | NO_ITEM | BURNT_BERRY | CHARCOAL |
| 78 | Rapidash | NO_ITEM | NO_ITEM | BURNT_BERRY | CHARCOAL |
| 79 | Slowpoke | NO_ITEM | KINGS_ROCK | PNK_APRICORN | SLOWPOKETAIL |
| 80 | Slowbro | NO_ITEM | KINGS_ROCK | PNK_APRICORN | KINGS_ROCK |
| 81 | Magnemite | NO_ITEM | METAL_COAT | PRZCUREBERRY | METAL_COAT |
| 82 | Magneton | NO_ITEM | METAL_COAT | PRZCUREBERRY | METAL_COAT |
| 83 | Farfetch'd | NO_ITEM | STICK | NO_ITEM | STICK |
| 84 | Doduo | NO_ITEM | NO_ITEM | BERRY | SHARP_BEAK |
| 85 | Dodrio | NO_ITEM | SHARP_BEAK | BERRY | SHARP_BEAK |
| 86 | Seel | NO_ITEM | NO_ITEM | ICE_BERRY | NEVERMELTICE |
| 87 | Dewgong | NO_ITEM | NO_ITEM | ICE_BERRY | NEVERMELTICE |
| 88 | Grimer | NO_ITEM | NUGGET | PSNCUREBERRY | NUGGET |
| 89 | Muk | NO_ITEM | NUGGET | PSNCUREBERRY | NUGGET |
| 90 | Shellder | PEARL | BIG_PEARL | PEARL | BIG_PEARL |
| 91 | Cloyster | PEARL | BIG_PEARL | PEARL | BIG_PEARL |
| 92 | Gastly | NO_ITEM | NO_ITEM | BITTER_BERRY | SPELL_TAG |
| 93 | Haunter | NO_ITEM | NO_ITEM | BITTER_BERRY | SPELL_TAG |
| 94 | Gengar | NO_ITEM | NO_ITEM | BITTER_BERRY | SPELL_TAG |
| 95 | Onix | NO_ITEM | NO_ITEM | BERRY | METAL_COAT |
| 96 | Drowzee | NO_ITEM | NO_ITEM | MINT_BERRY | TWISTEDSPOON |
| 97 | Hypno | NO_ITEM | NO_ITEM | MINT_BERRY | TWISTEDSPOON |
| 98 | Krabby | NO_ITEM | NO_ITEM | NO_ITEM | NO_ITEM |
| 99 | Kingler | NO_ITEM | NO_ITEM | NO_ITEM | NO_ITEM |
| 100 | Voltorb | NO_ITEM | NO_ITEM | NO_ITEM | MAGNET |
| 101 | Electrode | NO_ITEM | NO_ITEM | NO_ITEM | MAGNET |
| 102 | Exeggcute | NO_ITEM | NO_ITEM | PSNCUREBERRY | MIRACLE_SEED |
| 103 | Exeggutor | NO_ITEM | NO_ITEM | PSNCUREBERRY | MIRACLE_SEED |
| 104 | Cubone | NO_ITEM | THICK_CLUB | BERRY | THICK_CLUB |
| 105 | Marowak | NO_ITEM | THICK_CLUB | BERRY | THICK_CLUB |
| 106 | Hitmonlee | NO_ITEM | NO_ITEM | BERRY | BLACKBELT_I |
| 107 | Hitmonchan | NO_ITEM | NO_ITEM | BERRY | BLACKBELT_I |
| 108 | Lickitung | NO_ITEM | NO_ITEM | NO_ITEM | MOOMOO_MILK |
| 109 | Koffing | NO_ITEM | NO_ITEM | PSNCUREBERRY | POISON_BARB |
| 110 | Weezing | NO_ITEM | NO_ITEM | PSNCUREBERRY | POISON_BARB |
| 111 | Rhyhorn | NO_ITEM | NO_ITEM | NO_ITEM | NO_ITEM |
| 112 | Rhydon | NO_ITEM | NO_ITEM | NO_ITEM | NO_ITEM |
| 113 | Chansey | NO_ITEM | LUCKY_EGG | BERRY | LUCKY_EGG |
| 114 | Tangela | NO_ITEM | NO_ITEM | PRZCUREBERRY | MIRACLE_SEED |
| 115 | Kangaskhan | NO_ITEM | NO_ITEM | NO_ITEM | NO_ITEM |
| 116 | Horsea | NO_ITEM | DRAGON_SCALE | BERRY | DRAGON_SCALE |
| 117 | Seadra | NO_ITEM | DRAGON_SCALE | BERRY | DRAGON_SCALE |
| 118 | Goldeen | NO_ITEM | NO_ITEM | BERRY | FRESH_WATER |
| 119 | Seaking | NO_ITEM | NO_ITEM | BERRY | FRESH_WATER |
| 120 | Staryu | STARDUST | STAR_PIECE | STARDUST | STAR_PIECE |
| 121 | Starmie | STARDUST | STAR_PIECE | STARDUST | STAR_PIECE |
| 122 | Mr. Mime | NO_ITEM | MYSTERYBERRY | NO_ITEM | MYSTERYBERRY |
| 123 | Scyther | NO_ITEM | NO_ITEM | NO_ITEM | METAL_COAT |
| 124 | Jynx | ICE_BERRY | ICE_BERRY | ICE_BERRY | NEVERMELTICE |
| 125 | Electabuzz | NO_ITEM | NO_ITEM | PRZCUREBERRY | MAGNET |
| 126 | Magmar | BURNT_BERRY | BURNT_BERRY | BURNT_BERRY | CHARCOAL |
| 127 | Pinsir | NO_ITEM | NO_ITEM | BERRY | SILVERPOWDER |
| 128 | Tauros | NO_ITEM | NO_ITEM | NO_ITEM | NO_ITEM |
| 129 | Magikarp | NO_ITEM | NO_ITEM | NO_ITEM | NO_ITEM |
| 130 | Gyarados | NO_ITEM | NO_ITEM | BERRY | MYSTIC_WATER |
| 131 | Lapras | NO_ITEM | NO_ITEM | ICE_BERRY | NEVERMELTICE |
| 132 | Ditto | NO_ITEM | NO_ITEM | NO_ITEM | NO_ITEM |
| 133 | Eevee | NO_ITEM | NO_ITEM | WHT_APRICORN | EVERSTONE |
| 134 | Vaporeon | NO_ITEM | NO_ITEM | BLU_APRICORN | MYSTIC_WATER |
| 135 | Jolteon | NO_ITEM | NO_ITEM | YLW_APRICORN | MAGNET |
| 136 | Flareon | NO_ITEM | NO_ITEM | RED_APRICORN | CHARCOAL |
| 137 | Porygon | NO_ITEM | NO_ITEM | NO_ITEM | NO_ITEM |
| 138 | Omanyte | NO_ITEM | NO_ITEM | NO_ITEM | HARD_STONE |
| 139 | Omastar | NO_ITEM | NO_ITEM | NO_ITEM | HARD_STONE |
| 140 | Kabuto | NO_ITEM | NO_ITEM | NO_ITEM | HARD_STONE |
| 141 | Kabutops | NO_ITEM | NO_ITEM | NO_ITEM | HARD_STONE |
| 142 | Aerodactyl | NO_ITEM | NO_ITEM | BERRY | HARD_STONE |
| 143 | Snorlax | LEFTOVERS | LEFTOVERS | LEFTOVERS | LEFTOVERS |
| 144 | Articuno | NO_ITEM | NO_ITEM | NEVERMELTICE | NEVERMELTICE |
| 145 | Zapdos | NO_ITEM | NO_ITEM | MAGNET | MAGNET |
| 146 | Moltres | NO_ITEM | NO_ITEM | CHARCOAL | CHARCOAL |
| 147 | Dratini | NO_ITEM | DRAGON_SCALE | BERRY | DRAGON_SCALE |
| 148 | Dragonair | NO_ITEM | DRAGON_SCALE | BERRY | DRAGON_SCALE |
| 149 | Dragonite | NO_ITEM | DRAGON_SCALE | BERRY | DRAGON_SCALE |
| 150 | Mewtwo | NO_ITEM | BERSERK_GENE | NO_ITEM | BERSERK_GENE |
| 151 | Mew | NO_ITEM | MIRACLEBERRY | NO_ITEM | MIRACLEBERRY |
| 152 | Chikorita | NO_ITEM | NO_ITEM | PSNCUREBERRY | MIRACLE_SEED |
| 153 | Bayleef | NO_ITEM | NO_ITEM | PSNCUREBERRY | MIRACLE_SEED |
| 154 | Meganium | NO_ITEM | NO_ITEM | PSNCUREBERRY | MIRACLE_SEED |
| 155 | Cyndaquil | NO_ITEM | NO_ITEM | BURNT_BERRY | CHARCOAL |
| 156 | Quilava | NO_ITEM | NO_ITEM | BURNT_BERRY | CHARCOAL |
| 157 | Typhlosion | NO_ITEM | NO_ITEM | BURNT_BERRY | CHARCOAL |
| 158 | Totodile | NO_ITEM | NO_ITEM | BERRY | MYSTIC_WATER |
| 159 | Croconaw | NO_ITEM | NO_ITEM | BERRY | MYSTIC_WATER |
| 160 | Feraligatr | NO_ITEM | NO_ITEM | BERRY | MYSTIC_WATER |
| 161 | Sentret | NO_ITEM | BERRY | BERRY | GOLD_BERRY |
| 162 | Furret | BERRY | GOLD_BERRY | GOLD_BERRY | PINK_BOW |
| 163 | Hoothoot | NO_ITEM | NO_ITEM | BLACKGLASSES | SHARP_BEAK |
| 164 | Noctowl | NO_ITEM | NO_ITEM | BLACKGLASSES | SHARP_BEAK |
| 165 | Ledyba | NO_ITEM | NO_ITEM | PRZCUREBERRY | SILVERPOWDER |
| 166 | Ledian | NO_ITEM | NO_ITEM | PRZCUREBERRY | SILVERPOWDER |
| 167 | Spinarak | NO_ITEM | NO_ITEM | PSNCUREBERRY | SILVERPOWDER |
| 168 | Ariados | NO_ITEM | NO_ITEM | PSNCUREBERRY | SILVERPOWDER |
| 169 | Crobat | NO_ITEM | NO_ITEM | PSNCUREBERRY | POISON_BARB |
| 170 | Chinchou | NO_ITEM | NO_ITEM | BERRY | MYSTIC_WATER |
| 171 | Lanturn | NO_ITEM | NO_ITEM | BERRY | MAGNET |
| 172 | Pichu | NO_ITEM | BERRY | NO_ITEM | BERRY |
| 173 | Cleffa | MYSTERYBERRY | MOON_STONE | MYSTERYBERRY | MOON_STONE |
| 174 | Igglybuff | NO_ITEM | NO_ITEM | NO_ITEM | MOON_STONE |
| 175 | Togepi | NO_ITEM | NO_ITEM | BERRY | PINK_BOW |
| 176 | Togetic | NO_ITEM | NO_ITEM | BERRY | PINK_BOW |
| 177 | Natu | NO_ITEM | NO_ITEM | GRN_APRICORN | TWISTEDSPOON |
| 178 | Xatu | NO_ITEM | NO_ITEM | GRN_APRICORN | TWISTEDSPOON |
| 179 | Mareep | NO_ITEM | NO_ITEM | PRZCUREBERRY | MAGNET |
| 180 | Flaaffy | NO_ITEM | NO_ITEM | PRZCUREBERRY | MAGNET |
| 181 | Ampharos | NO_ITEM | NO_ITEM | PRZCUREBERRY | MAGNET |
| 182 | Bellossom | NO_ITEM | NO_ITEM | MINT_BERRY | MIRACLE_SEED |
| 183 | Marill | NO_ITEM | NO_ITEM | FRESH_WATER | MYSTIC_WATER |
| 184 | Azumarill | NO_ITEM | NO_ITEM | FRESH_WATER | MYSTIC_WATER |
| 185 | Sudowoodo | NO_ITEM | NO_ITEM | BERRY | HARD_STONE |
| 186 | Politoed | NO_ITEM | KINGS_ROCK | NO_ITEM | KINGS_ROCK |
| 187 | Hoppip | NO_ITEM | NO_ITEM | BERRY | MIRACLE_SEED |
| 188 | Skiploom | NO_ITEM | NO_ITEM | BERRY | MIRACLE_SEED |
| 189 | Jumpluff | NO_ITEM | NO_ITEM | BERRY | MIRACLE_SEED |
| 190 | Aipom | NO_ITEM | NO_ITEM | BERRY | PINK_BOW |
| 191 | Sunkern | NO_ITEM | NO_ITEM | ENERGY_ROOT | MIRACLE_SEED |
| 192 | Sunflora | NO_ITEM | NO_ITEM | ENERGY_ROOT | MIRACLE_SEED |
| 193 | Yanma | NO_ITEM | NO_ITEM | PSNCUREBERRY | SILVERPOWDER |
| 194 | Wooper | NO_ITEM | NO_ITEM | BERRY | SOFT_SAND |
| 195 | Quagsire | NO_ITEM | NO_ITEM | BERRY | SOFT_SAND |
| 196 | Espeon | NO_ITEM | NO_ITEM | PNK_APRICORN | TWISTEDSPOON |
| 197 | Umbreon | NO_ITEM | NO_ITEM | BLK_APRICORN | BLACKGLASSES |
| 198 | Murkrow | NO_ITEM | NO_ITEM | BITTER_BERRY | BLACKGLASSES |
| 199 | Slowking | NO_ITEM | KINGS_ROCK | PNK_APRICORN | KINGS_ROCK |
| 200 | Misdreavus | NO_ITEM | SPELL_TAG | BITTER_BERRY | SPELL_TAG |
| 201 | Unown | NO_ITEM | NO_ITEM | MYSTERYBERRY | MYSTERYBERRY |
| 202 | Wobbuffet | NO_ITEM | NO_ITEM | TWISTEDSPOON | TWISTEDSPOON |
| 203 | Girafarig | NO_ITEM | NO_ITEM | BERRY | TWISTEDSPOON |
| 204 | Pineco | NO_ITEM | NO_ITEM | PSNCUREBERRY | SILVERPOWDER |
| 205 | Forretress | NO_ITEM | NO_ITEM | PSNCUREBERRY | METAL_COAT |
| 206 | Dunsparce | NO_ITEM | NO_ITEM | BLK_APRICORN | PINK_BOW |
| 207 | Gligar | NO_ITEM | NO_ITEM | BERRY | SOFT_SAND |
| 208 | Steelix | NO_ITEM | METAL_COAT | BERRY | METAL_COAT |
| 209 | Snubbull | NO_ITEM | NO_ITEM | TINYMUSHROOM | PINK_BOW |
| 210 | Granbull | NO_ITEM | NO_ITEM | BIG_MUSHROOM | PINK_BOW |
| 211 | Qwilfish | NO_ITEM | NO_ITEM | BERRY | POISON_BARB |
| 212 | Scizor | NO_ITEM | NO_ITEM | NO_ITEM | METAL_COAT |
| 213 | Shuckle | BERRY | BERRY | BERRY | BERRY_JUICE |
| 214 | Heracross | NO_ITEM | NO_ITEM | SILVERPOWDER | BLACKBELT_I |
| 215 | Sneasel | NO_ITEM | QUICK_CLAW | ICE_BERRY | QUICK_CLAW |
| 216 | Teddiursa | NO_ITEM | NO_ITEM | BERRY | PINK_BOW |
| 217 | Ursaring | NO_ITEM | NO_ITEM | BERRY | PINK_BOW |
| 218 | Slugma | NO_ITEM | NO_ITEM | BURNT_BERRY | CHARCOAL |
| 219 | Magcargo | NO_ITEM | NO_ITEM | BURNT_BERRY | CHARCOAL |
| 220 | Swinub | NO_ITEM | NO_ITEM | ICE_BERRY | NEVERMELTICE |
| 221 | Piloswine | NO_ITEM | NO_ITEM | ICE_BERRY | NEVERMELTICE |
| 222 | Corsola | NO_ITEM | NO_ITEM | BERRY | MYSTIC_WATER |
| 223 | Remoraid | NO_ITEM | NO_ITEM | NO_ITEM | FRESH_WATER |
| 224 | Octillery | NO_ITEM | NO_ITEM | NO_ITEM | FRESH_WATER |
| 225 | Delibird | NO_ITEM | NO_ITEM | ICE_BERRY | NEVERMELTICE |
| 226 | Mantine | NO_ITEM | NO_ITEM | FRESH_WATER | MYSTIC_WATER |
| 227 | Skarmory | NO_ITEM | NO_ITEM | BERRY | METAL_COAT |
| 228 | Houndour | NO_ITEM | NO_ITEM | BURNT_BERRY | BLACKGLASSES |
| 229 | Houndoom | NO_ITEM | NO_ITEM | BURNT_BERRY | BLACKGLASSES |
| 230 | Kingdra | NO_ITEM | DRAGON_SCALE | BERRY | DRAGON_SCALE |
| 231 | Phanpy | NO_ITEM | NO_ITEM | BERRY | SOFT_SAND |
| 232 | Donphan | NO_ITEM | NO_ITEM | BERRY | SOFT_SAND |
| 233 | Porygon2 | NO_ITEM | NO_ITEM | NO_ITEM | NO_ITEM |
| 234 | Stantler | NO_ITEM | NO_ITEM | NO_ITEM | NO_ITEM |
| 235 | Smeargle | NO_ITEM | NO_ITEM | NO_ITEM | NO_ITEM |
| 236 | Tyrogue | NO_ITEM | NO_ITEM | BERRY | BLACKBELT_I |
| 237 | Hitmontop | NO_ITEM | NO_ITEM | BERRY | BLACKBELT_I |
| 238 | Smoochum | ICE_BERRY | ICE_BERRY | ICE_BERRY | NEVERMELTICE |
| 239 | Elekid | NO_ITEM | NO_ITEM | PRZCUREBERRY | MAGNET |
| 240 | Magby | BURNT_BERRY | BURNT_BERRY | BURNT_BERRY | CHARCOAL |
| 241 | Miltank | MOOMOO_MILK | MOOMOO_MILK | MOOMOO_MILK | MOOMOO_MILK |
| 242 | Blissey | NO_ITEM | LUCKY_EGG | BERRY | LUCKY_EGG |
| 243 | Raikou | NO_ITEM | NO_ITEM | PRZCUREBERRY | MAGNET |
| 244 | Entei | NO_ITEM | NO_ITEM | CHARCOAL | CHARCOAL |
| 245 | Suicune | NO_ITEM | NO_ITEM | BERRY | MYSTIC_WATER |
| 246 | Larvitar | NO_ITEM | NO_ITEM | BERRY | HARD_STONE |
| 247 | Pupitar | NO_ITEM | NO_ITEM | BERRY | HARD_STONE |
| 248 | Tyranitar | NO_ITEM | NO_ITEM | BERRY | HARD_STONE |
| 249 | Lugia | NO_ITEM | NO_ITEM | NO_ITEM | NO_ITEM |
| 250 | Ho-Oh | SACRED_ASH | SACRED_ASH | SACRED_ASH | SACRED_ASH |
| 251 | Celebi | NO_ITEM | MIRACLEBERRY | MIRACLEBERRY | TWISTEDSPOON |
