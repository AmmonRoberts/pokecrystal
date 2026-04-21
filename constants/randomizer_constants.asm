; See data\items\randomizable_items.asm for the list of items.
DEF NUM_RANDOMIZABLE_ITEMS EQU 176

; Bit index constants for wRandoFlags (see ram/wram.asm)
; These are plain bit indices (0-7) for use with the BIT/SET/RES instructions
; and with `xor 1 << RANDFLAG_*_F` for toggling.
DEF RANDFLAG_WILD_ENCOUNTERS_F EQU 0 ; set = randomized wild encounters
DEF RANDFLAG_STARTER_RAND_F    EQU 1 ; set = randomized starters
DEF RANDFLAG_BOSS_RAND_F       EQU 2 ; set = randomized boss trainer parties (gym leaders, E4, rival, Red)
DEF RANDFLAG_TRAINER_RAND_F    EQU 3 ; set = randomized regular trainer parties
DEF RANDFLAG_TYPE_RAND_F       EQU 4 ; set = type matchups are randomized (any non-standard mode)
DEF RANDFLAG_TYPE_BALANCED_F   EQU 5 ; set = balanced mode: at most 2 immunities per attacker (requires TYPE_RAND_F)
DEF RANDFLAG_BERRY_RAND_F      EQU 6 ; set = randomized berry trees
DEF RANDFLAG_ITEM_RAND_F       EQU 7 ; set = randomized item balls

; Number of rows/columns in wTypeMatchupTable.
; Physical types 0-9 map to indices 0-9; special types 20-27 map to indices 10-17.
; BIRD (index 6) is unused and excluded from the Pokégear type chart display.
DEF TYPE_MATCHUP_TABLE_STRIDE EQU 18
DEF TYPE_MATCHUP_TABLE_DISPLAY_COUNT EQU 17 ; all types except BIRD

; Gift Pokémon randomizer mode (stored in wGiftRandMode, see ram/wram.asm)
DEF GIFT_RAND_STANDARD   EQU 0 ; standard species, normal gift behaviour
DEF GIFT_RAND_RANDOMIZED EQU 1 ; random species substituted for the gift
DEF GIFT_RAND_DISABLED   EQU 2 ; gift Pokémon are not given at all
DEF NUM_GIFT_RAND_MODES  EQU 3

; Static encounter randomizer mode (stored in wStaticRandMode, see ram/wram.asm)
DEF STATIC_RAND_STANDARD   EQU 0 ; standard species (default)
DEF STATIC_RAND_RANDOMIZED EQU 1 ; random species substituted, level preserved
DEF NUM_STATIC_RAND_MODES  EQU 2

; Return codes for GiveXxxGift specials (wScriptVar)
DEF GIFT_RESULT_DISABLED EQU 0 ; gift is disabled — nothing given
DEF GIFT_RESULT_PARTY    EQU 1 ; Pokémon (or egg) added to the party
DEF GIFT_RESULT_BOX      EQU 2 ; Pokémon sent to PC box
DEF GIFT_RESULT_FULL     EQU 3 ; party and box both full — nothing given

; Bit index constants for wModFlags (see ram/wram.asm)
; Modernization / quality-of-life options — not randomization.
DEF MODFLAG_TM_UNLIMITED_F           EQU 0 ; set = TMs are unlimited use
DEF MODFLAG_POISON_SURVIVAL_F        EQU 1 ; set = poison stops at 1 HP
DEF MODFLAG_AUTO_NICKNAME_F          EQU 2 ; set = random nicknames on catch/hatch
DEF MODFLAG_WILD_ITEM_DROP_F         EQU 4 ; set = wild #MON drop held items on KO
DEF MODFLAG_TM_VENDOR_F              EQU 5 ; set = TM vendor NPC enabled in Blackthorn Mart
DEF MODFLAG_WILD_HELD_ITEM_RAND_F    EQU 6 ; set = wild #MON held items are randomized
DEF MODFLAG_WILD_HELD_ITEM_MOD_F     EQU 7 ; set = wild #MON held items use Item3/Item4 (rate set by wWildHeldItemRate)

; Wild held item base rate (stored in wWildHeldItemRate, see ram/wram.asm)
DEF WILD_HELD_ITEM_RATE_10  EQU 0 ; 10% chance to hold an item
DEF WILD_HELD_ITEM_RATE_25  EQU 1 ; 25% chance (default, matches standard Item1/Item2 rate)
DEF WILD_HELD_ITEM_RATE_35  EQU 2 ; 35% chance
DEF WILD_HELD_ITEM_RATE_50  EQU 3 ; 50% chance
DEF WILD_HELD_ITEM_RATE_65  EQU 4 ; 65% chance
DEF WILD_HELD_ITEM_RATE_75  EQU 5 ; 75% chance
DEF WILD_HELD_ITEM_RATE_100 EQU 6 ; 100% chance (always holds an item)
DEF NUM_WILD_HELD_ITEM_RATES EQU 7

; HM requirement mode (stored in wHMMode)
DEF HM_MODE_REQUIRED  EQU 0 ; default: party mon must KNOW the HM move
DEF HM_MODE_LEARNABLE EQU 1 ; party mon only needs to be ABLE to learn the HM
DEF HM_MODE_FREE      EQU 2 ; no Pokémon check — badge alone is sufficient
DEF NUM_HM_MODES      EQU 3

; TODO: REMOVE BEFORE FULL RELEASE!
DEF MODFLAG_BOSS_RAND_INITIALIZED_F  EQU 3 ; internal: set once BOSS_RAND_F has been explicitly initialized
                                           ; (0 on old saves — triggers one-time migration from TRAINER_RAND_F)
