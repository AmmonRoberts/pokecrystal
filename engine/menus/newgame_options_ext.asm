; Overflow handlers for new-game option toggles.
; Resides in "Crystal Features 1 Ext" (bank $21) because "Crystal Features 1"
; (bank $12) is full.  All routines here are called via farcall from CF1.

StaticRandOptionHandler::
; Toggles wStaticRandMode between STATIC_RAND_STANDARD and STATIC_RAND_RANDOMIZED.
	ldh a, [hJoyPressed]
	bit B_PAD_RIGHT, a
	jr nz, .Toggle
	bit B_PAD_LEFT, a
	jr z, .Display
.Toggle
	ld a, [wStaticRandMode]
	xor 1                      ; toggle between 0 (STANDARD) and 1 (RANDOMIZED)
	ld [wStaticRandMode], a
.Display
	ld a, [wStaticRandMode]
	and a
	ld de, .Standard
	jr z, .PlaceStr
	ld de, .Randomized
.PlaceStr
	hlcoord 8, 12
	call PlaceString
	ret
.Standard:   db "STANDARD  @"
.Randomized: db "RANDOMIZED@"
