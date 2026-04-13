_RollWildHeldItem::
; Rolls the item a wild Pokemon carries at the start of battle.
; Result written directly to wEnemyMonItem (farcall doesn't preserve a).
;
; MODFLAG_WILD_HELD_ITEM_MOD_F selects which item group is used:
;
;   Flag OFF — standard roll (Item1 / Item2):
;     75% NO_ITEM  /  ~23% Item1  /  ~2% Item2
;     If MODFLAG_WILD_HELD_ITEM_RAND_F is also set, the item is drawn
;     randomly from RandomizableItems instead of Item1/Item2.
;
;   Flag ON — mod roll (Item3 / Item4):
;     75% NO_ITEM  /  ~15% Item3  /  ~10% Item4
;
; The two groups are mutually exclusive — enabling the flag replaces the
; standard roll entirely; Item1/Item2 are never consulted when it is on.
; The no-item threshold for both rolls is controlled by wWildHeldItemRate.
	ld a, [wModFlags]
	bit MODFLAG_WILD_HELD_ITEM_MOD_F, a
	jr nz, .mod_roll
	; Standard roll
	call .roll_base
	jr c, .no_item
	ld a, [wModFlags]
	bit MODFLAG_WILD_HELD_ITEM_RAND_F, a
	jr nz, .rand_item
	; ~2% Item2, ~23% Item1
	call BattleRandom
	cp 8 percent
	ld a, [wBaseItem1]
	jr nc, .done
	ld a, [wBaseItem2]
	jr .done
.rand_item:
	call BattleRandom
	; Reduce to [0, NUM_RANDOMIZABLE_ITEMS) via subtraction loop
	ld e, a
.clamp:
	ld a, e
	cp NUM_RANDOMIZABLE_ITEMS
	jr c, .index_ok
	sub NUM_RANDOMIZABLE_ITEMS
	ld e, a
	jr .clamp
.index_ok:
	ld d, 0
	ld hl, RandomizableItems
	add hl, de
	ld a, BANK(RandomizableItems)
	call GetFarByte
	jr .done
.mod_roll:
	call .roll_base
	jr c, .no_item
	call BattleRandom
	cp 40 percent      ; < 40% (~10%) → Item4, ≥ 40% (~15%) → Item3
	ld a, [wBaseItem3]
	jr nc, .done
	ld a, [wBaseItem4]
	jr .done
.no_item:
	xor a
.done:
	ld [wEnemyMonItem], a
	ret
.roll_base:
; Calls BattleRandom and compares against the held item rate threshold.
; Returns with C set if the roll indicates no item should be held.
	call BattleRandom
	ld b, a
	ld a, [wWildHeldItemRate]
	ld e, a
	ld d, 0
	ld hl, WildHeldItemRateThresholds
	add hl, de
	ld a, b
	cp [hl]            ; C set if random < threshold (no item)
	ret

WildHeldItemRateThresholds:
; Indexed by wWildHeldItemRate (0–6). The random byte must be >= the threshold
; for an item to be held. Used with: cp [hl]; jr c, .no_item
	db 90 percent + 1  ; 0 = 10% item chance
	db 75 percent + 1  ; 1 = 25% item chance (default)
	db 65 percent + 1  ; 2 = 35% item chance
	db 50 percent + 1  ; 3 = 50% item chance
	db 35 percent + 1  ; 4 = 65% item chance
	db 25 percent + 1  ; 5 = 75% item chance
	db 0               ; 6 = 100% item chance (cp 0 → nc always → always item)

_TryDropWildItemCore::
; If MODFLAG_WILD_ITEM_DROP_F is set and the wild #MON held an item,
; add that item to the player's bag (or PC if the bag is full).
; Called via farcall from TryDropWildItem (home bank).
	ld a, [wModFlags]
	bit MODFLAG_WILD_ITEM_DROP_F, a
	ret z
	ld a, [wEnemyMonItem]
	and a                         ; NO_ITEM = 0
	ret z
	ld [wCurItem], a
	ld [wNamedObjectIndex], a
	call GetItemName              ; puts item name into wStringBuffer1
	ld a, 1
	ld [wItemQuantityChange], a
	ld hl, wNumItems
	call ReceiveItem              ; try bag first
	jr c, .got_bag
	ld hl, wNumPCItems
	call ReceiveItem              ; bag full — try PC
	jr c, .got_pc
	ld hl, BattleText_WildItemDropFull ; bag and PC both full — notify
	jp StdBattleTextbox
.got_bag:
	ld hl, BattleText_WildItemDropBag
	jp StdBattleTextbox
.got_pc:
	ld hl, BattleText_WildItemDropPC
	jp StdBattleTextbox
