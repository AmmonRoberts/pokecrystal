ReadTrainerParty:
	ld a, [wInBattleTowerBattle]
	bit IN_BATTLE_TOWER_BATTLE_F, a
	ret nz

	ld a, [wLinkMode]
	and a
	ret nz

	ld hl, wOTPartyCount
	xor a
	ld [hli], a
	dec a
	ld [hl], a

	ld hl, wOTPartyMons
	ld bc, PARTYMON_STRUCT_LENGTH * PARTY_LENGTH
	xor a
	call ByteFill

	ld a, [wOtherTrainerClass]
	cp CAL
	jr nz, .not_cal2
	ld a, [wOtherTrainerID]
	cp CAL2
	jr z, .cal2
	ld a, [wOtherTrainerClass]
.not_cal2

	dec a
	ld c, a
	ld b, 0
	ld hl, TrainerGroups
	add hl, bc
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a

	ld a, [wOtherTrainerID]
	ld b, a
.skip_trainer
	dec b
	jr z, .got_trainer
.loop
	ld a, [hli]
	cp -1
	jr nz, .loop
	jr .skip_trainer
.got_trainer

.skip_name
	ld a, [hli]
	cp '@'
	jr nz, .skip_name

	ld a, [hli]
	ld c, a
	ld b, 0
	ld d, h
	ld e, l
	ld hl, TrainerTypes
	add hl, bc
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld bc, .done
	push bc
	jp hl

.done
	jp ComputeTrainerReward

.cal2
	ld a, BANK(sMysteryGiftTrainer)
	call OpenSRAM
	ld de, sMysteryGiftTrainer
	call TrainerType2
	call CloseSRAM
	jr .done

TrainerTypes:
; entries correspond to TRAINERTYPE_* constants
	dw TrainerType1 ; level, species
	dw TrainerType2 ; level, species, moves
	dw TrainerType3 ; level, species, item
	dw TrainerType4 ; level, species, item, moves

TrainerType1:
; normal (level, species)
	ld h, d
	ld l, e
.loop
	ld a, [hli]
	cp $ff
	ret z

	ld [wCurPartyLevel], a
	ld a, [hli]
	ld [wCurPartySpecies], a
	call RandomizeTrainerSpeciesIfEnabled
	ld a, OTPARTYMON
	ld [wMonType], a
	push hl
	predef TryAddMonToParty
	pop hl
	jr .loop

TrainerType2:
; moves
	ld h, d
	ld l, e
.loop
	ld a, [hli]
	cp $ff
	ret z

	ld [wCurPartyLevel], a
	ld a, [hli]
	ld [wCurPartySpecies], a
	call RandomizeTrainerSpeciesIfEnabled
	ld a, OTPARTYMON
	ld [wMonType], a

	push hl
	predef TryAddMonToParty
	; If trainer randomization is enabled, skip hard-coded moves
	call IsTrainerRandomized
	jp nz, .skip_moves
	ld a, [wOTPartyCount]
	dec a
	ld hl, wOTPartyMon1Moves
	ld bc, PARTYMON_STRUCT_LENGTH
	call AddNTimes
	ld d, h
	ld e, l
	pop hl

	ld b, NUM_MOVES
.copy_moves
	ld a, [hli]
	ld [de], a
	inc de
	dec b
	jr nz, .copy_moves

	push hl

	ld a, [wOTPartyCount]
	dec a
	ld hl, wOTPartyMon1Species
	ld bc, PARTYMON_STRUCT_LENGTH
	call AddNTimes
	ld d, h
	ld e, l
	ld hl, MON_PP
	add hl, de
	push hl
	ld hl, MON_MOVES
	add hl, de
	pop de

	ld b, NUM_MOVES
.copy_pp
	ld a, [hli]
	and a
	jr z, .copied_pp

	push hl
	push bc
	dec a
	ld hl, Moves + MOVE_PP
	ld bc, MOVE_LENGTH
	call AddNTimes
	ld a, BANK(Moves)
	call GetFarByte
	pop bc
	pop hl

	ld [de], a
	inc de
	dec b
	jr nz, .copy_pp
.copied_pp

	pop hl
	jr .loop

.skip_moves
	pop hl
	ld bc, NUM_MOVES
	add hl, bc
	jr .loop

TrainerType3:
; item
	ld h, d
	ld l, e
.loop
	ld a, [hli]
	cp $ff
	ret z

	ld [wCurPartyLevel], a
	ld a, [hli]
	ld [wCurPartySpecies], a
	call RandomizeTrainerSpeciesIfEnabled
	ld a, OTPARTYMON
	ld [wMonType], a
	push hl
	predef TryAddMonToParty
	ld a, [wOTPartyCount]
	dec a
	ld hl, wOTPartyMon1Item
	ld bc, PARTYMON_STRUCT_LENGTH
	call AddNTimes
	ld d, h
	ld e, l
	pop hl
	ld a, [hli]
	ld [de], a
	jr .loop

TrainerType4:
; item + moves
	ld h, d
	ld l, e
.loop
	ld a, [hli]
	cp $ff
	ret z

	ld [wCurPartyLevel], a
	ld a, [hli]
	ld [wCurPartySpecies], a
	call RandomizeTrainerSpeciesIfEnabled

	ld a, OTPARTYMON
	ld [wMonType], a

	push hl
	predef TryAddMonToParty
	ld a, [wOTPartyCount]
	dec a
	ld hl, wOTPartyMon1Item
	ld bc, PARTYMON_STRUCT_LENGTH
	call AddNTimes
	ld d, h
	ld e, l
	pop hl

	ld a, [hli]
	ld [de], a

	; If trainer randomization is enabled, skip hard-coded moves
	call IsTrainerRandomized
	jp nz, .skip_moves
	push hl
	ld a, [wOTPartyCount]
	dec a
	ld hl, wOTPartyMon1Moves
	ld bc, PARTYMON_STRUCT_LENGTH
	call AddNTimes
	ld d, h
	ld e, l
	pop hl

	ld b, NUM_MOVES
.copy_moves
	ld a, [hli]
	ld [de], a
	inc de
	dec b
	jr nz, .copy_moves

	push hl

	ld a, [wOTPartyCount]
	dec a
	ld hl, wOTPartyMon1
	ld bc, PARTYMON_STRUCT_LENGTH
	call AddNTimes
	ld d, h
	ld e, l
	ld hl, MON_PP
	add hl, de

	push hl
	ld hl, MON_MOVES
	add hl, de
	pop de

	ld b, NUM_MOVES
.copy_pp
	ld a, [hli]
	and a
	jr z, .copied_pp

	push hl
	push bc
	dec a
	ld hl, Moves + MOVE_PP
	ld bc, MOVE_LENGTH
	call AddNTimes
	ld a, BANK(Moves)
	call GetFarByte
	pop bc
	pop hl

	ld [de], a
	inc de
	dec b
	jr nz, .copy_pp
.copied_pp

	pop hl
	jp .loop

.skip_moves
	ld bc, NUM_MOVES
	add hl, bc
	jp .loop

ComputeTrainerReward:
	ld hl, hProduct
	xor a
	ld [hli], a
	ld [hli], a ; hMultiplicand + 0
	ld [hli], a ; hMultiplicand + 1
	ld a, [wEnemyTrainerBaseReward]
	ld [hli], a ; hMultiplicand + 2
	ld a, [wCurPartyLevel]
	ld [hl], a ; hMultiplier
	call Multiply
	ld hl, wBattleReward
	xor a
	ld [hli], a
	ldh a, [hProduct + 2]
	ld [hli], a
	ldh a, [hProduct + 3]
	ld [hl], a
	call ApplyMoneyMultiplier
	ret

Battle_GetTrainerName::
	ld a, [wInBattleTowerBattle]
	bit IN_BATTLE_TOWER_BATTLE_F, a
	ld hl, wOTPlayerName
	jp nz, CopyTrainerName

	ld a, [wOtherTrainerID]
	ld b, a
	ld a, [wOtherTrainerClass]
	ld c, a

GetTrainerName::
	ld a, c
	cp CAL
	jr nz, .not_cal2

	ld a, BANK(sMysteryGiftTrainerHouseFlag)
	call OpenSRAM
	ld a, [sMysteryGiftTrainerHouseFlag]
	and a
	call CloseSRAM
	jr z, .not_cal2

	ld a, BANK(sMysteryGiftPartnerName)
	call OpenSRAM
	ld hl, sMysteryGiftPartnerName
	call CopyTrainerName
	jp CloseSRAM

.not_cal2
	dec c
	push bc
	ld b, 0
	ld hl, TrainerGroups
	add hl, bc
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a
	pop bc

.loop
	dec b
	jr z, CopyTrainerName

.skip
	ld a, [hli]
	cp $ff
	jr nz, .skip
	jr .loop

CopyTrainerName:
	ld de, wStringBuffer1
	push de
	ld bc, NAME_LENGTH
	call CopyBytes
	pop de
	ret

IncompleteCopyNameFunction: ; unreferenced
; Copy of CopyTrainerName but without "call CopyBytes"
	ld de, wStringBuffer1
	push de
	ld bc, NAME_LENGTH
	pop de
	ret

IsBossTrainerClass:
; Check whether wOtherTrainerClass is a boss trainer class (gym leaders, Elite 4,
; rival, Champion, Red).
; Returns: Z flag clear (nz) = boss, Z flag set (z) = not a boss.
; Clobbers: a, hl, b, c
	ld a, [wOtherTrainerClass]
	ld c, a
	and $07          ; bit index within byte (class % 8)
	ld b, a          ; b = bit index
	ld a, c
	srl a
	srl a
	srl a            ; a = byte index (class >> 3)
	ld hl, BossTrainerClassBitmask
	ld c, 0
	add hl, bc       ; hl = &BossTrainerClassBitmask[byte_index]
	ld a, [hl]       ; a = bitmask byte for this group of 8 classes
	ld c, a          ; c = bitmask byte
	ld a, b          ; test if bit_index == 0; ld does not affect flags
	and a            ; sets Z if b == 0
	ld a, 1          ; starting mask (ld does not affect flags)
	jr z, .done_shift
.shift_loop
	rlca
	dec b
	jr nz, .shift_loop
.done_shift
	and c            ; test the bit
	ret              ; Z set = not boss (bit clear), Z clear = boss (bit set)

BossTrainerClassBitmask:
; One bit per trainer class, indexed by class ID.
; Bit N of byte B is set when class (B*8 + N) is a boss trainer.
; Class IDs in hex; boss classes:
;   $01-$08 (Johto gym leaders: Falkner-Clair)
;   $09     (Rival1 / Silver early)
;   $0b     (Will - E4)
;   $0d-$0f (Bruno, Karen, Koga - E4)
;   $10     (Champion = Lance)
;   $11-$13 (Brock, Misty, Lt. Surge - Kanto gym leaders)
;   $15     (Erika - Kanto gym leader)
;   $1a     (Janine - Kanto gym leader)
;   $23     (Sabrina - Kanto gym leader)
;   $2a     (Rival2 / Silver late)
;   $2e     (Blaine - Kanto gym leader)
;   $3f     (Red)
;   $40     (Blue - Kanto gym leader / former Champion)
;
; Byte 0 ($00-$07): TRAINER_NONE=0,FALKNER=1..CHUCK=7  => bits 1-7 set
	db %11111110 ; $FE
; Byte 1 ($08-$0F): CLAIR,RIVAL1,POKEMON_PROF,WILL,CAL,BRUNO,KAREN,KOGA
;                   boss: CLAIR(0),RIVAL1(1),WILL(3),BRUNO(5),KAREN(6),KOGA(7)
	db %11101011 ; $EB
; Byte 2 ($10-$17): CHAMPION,BROCK,MISTY,LT_SURGE,SCIENTIST,ERIKA,YOUNGSTER,SCHOOLBOY
;                   boss: CHAMPION(0),BROCK(1),MISTY(2),LT_SURGE(3),ERIKA(5)
	db %00101111 ; $2F
; Byte 3 ($18-$1F): BIRD_KEEPER,LASS,JANINE,COOLTRAINERM,COOLTRAINERF,BEAUTY,POKEMANIAC,GRUNTM
;                   boss: JANINE(2)
	db %00000100 ; $04
; Byte 4 ($20-$27): GENTLEMAN,SKIER,TEACHER,SABRINA,BUG_CATCHER,FISHER,SWIMMERM,SWIMMERF
;                   boss: SABRINA(3)
	db %00001000 ; $08
; Byte 5 ($28-$2F): SAILOR,SUPER_NERD,RIVAL2,GUITARIST,HIKER,BIKER,BLAINE,BURGLAR
;                   boss: RIVAL2(2),BLAINE(6)
	db %01000100 ; $44
; Byte 6 ($30-$37): FIREBREATHER..EXECUTIVEF — none are bosses
	db %00000000 ; $00
; Byte 7 ($38-$3F): SAGE..POKEFANF,RED
;                   boss: RED(7)
	db %10000000 ; $80
; Byte 8 ($40-$47): BLUE,OFFICER,GRUNTF,MYSTICALMAN — boss: BLUE(0)
	db %00000001 ; $01

IsTrainerRandomized:
; Check whether the current trainer's party should be / was randomized.
; Uses BOSS_RAND_F for boss trainers and TRAINER_RAND_F for everyone else.
; Returns: Z set = not randomized, Z clear = randomized.
; Clobbers: a, hl, b, c
	call IsBossTrainerClass
	ld a, [wRandoFlags]  ; reload after IsBossTrainerClass clobbers b
	jr nz, .is_boss
	; Not a boss — check TRAINER_RAND_F
	bit RANDFLAG_TRAINER_RAND_F, a
	ret
.is_boss
	; Boss — check BOSS_RAND_F
	bit RANDFLAG_BOSS_RAND_F, a
	ret

RandomizeTrainerSpeciesIfEnabled:
; Check if this trainer's randomization is enabled, then randomize wCurPartySpecies.
; Preserves hl (callers use it as their data-stream pointer).
	push hl
	call IsTrainerRandomized
	pop hl
	ret z ; return if randomization not enabled for this trainer

	; Randomization enabled - get random species
.get_random_species
	call Random
	and a
	jr z, .get_random_species ; avoid species 0
	cp NUM_POKEMON + 1
	jr nc, .get_random_species ; ensure species <= 251

	; Valid random species obtained
	ld [wCurPartySpecies], a
	ret

ApplyMoneyMultiplier::
; Apply the money multiplier option to the reward in wBattleReward.
; wMoneyMultiplier: 0=50%, 1=75%, 2=100%, 3=125%, 4=150%
; wBattleReward layout: [+0]=high byte, [+1]=mid byte, [+2]=low byte
	ld a, [wMoneyMultiplier]
	cp 2
	ret z         ; 100% - no change
	jr c, .small  ; 0 or 1: go to half/three-quarter
	cp 4
	jr z, .one_and_half  ; 4 = 150%
	; fall through: 3 = 125%

.five_quarter:
	; value = value + value / 4
	ld a, [wBattleReward + 2]
	ld c, a
	ld a, [wBattleReward + 1]
	ld b, a
	ld a, [wBattleReward]
	ld d, a
	srl d
	rr b
	rr c
	srl d
	rr b
	rr c
	ld a, [wBattleReward + 2]
	add c
	ld [wBattleReward + 2], a
	ld a, [wBattleReward + 1]
	adc b
	ld [wBattleReward + 1], a
	ld a, [wBattleReward]
	adc d
	ld [wBattleReward], a
	ret

.one_and_half:
	; value = value + value / 2
	ld a, [wBattleReward + 2]
	ld c, a
	ld a, [wBattleReward + 1]
	ld b, a
	ld a, [wBattleReward]
	ld d, a
	srl d
	rr b
	rr c
	ld a, [wBattleReward + 2]
	add c
	ld [wBattleReward + 2], a
	ld a, [wBattleReward + 1]
	adc b
	ld [wBattleReward + 1], a
	ld a, [wBattleReward]
	adc d
	ld [wBattleReward], a
	ret

.small:
	; a = 0 or 1
	and a
	jr z, .half  ; 0 = 50%
	; fall through: 1 = 75%

.three_quarter:
	; value = value - value / 4
	ld a, [wBattleReward + 2]
	ld c, a
	ld a, [wBattleReward + 1]
	ld b, a
	ld a, [wBattleReward]
	ld d, a
	srl d
	rr b
	rr c
	srl d
	rr b
	rr c
	ld a, [wBattleReward + 2]
	sub c
	ld [wBattleReward + 2], a
	ld a, [wBattleReward + 1]
	sbc b
	ld [wBattleReward + 1], a
	ld a, [wBattleReward]
	sbc d
	ld [wBattleReward], a
	ret

.half:
	; value = value / 2
	ld a, [wBattleReward]
	srl a
	ld [wBattleReward], a
	ld a, [wBattleReward + 1]
	rra
	ld [wBattleReward + 1], a
	ld a, [wBattleReward + 2]
	rra
	ld [wBattleReward + 2], a
	; Ensure at least 1
	or a
	jr nz, .half_done
	ld a, [wBattleReward + 1]
	or a
	jr nz, .half_done
	ld a, [wBattleReward]
	or a
	jr nz, .half_done
	ld a, 1
	ld [wBattleReward + 2], a
.half_done:
	ret

ScaleEnemyDamageAndUpdateTracking::
; Scale wCurDamage by wEnemyDamageMultiplier, then record the scaled value into
; wPlayerDamageTaken (for Counter/Mirror Coat/Bide correctness).
; Called from the ROM0 trampoline ApplyEnemyDmgAndDamagePlayer.
	call ApplyEnemyDamageMultiplier
; Check if the player's substitute is active — if so, skip tracking
; (mirrors the BATTLE_VARS_SUBSTATUS4_OPP substitute check in .update_damage_taken).
	ld a, [wPlayerSubStatus4]
	bit SUBSTATUS_SUBSTITUTE, a
	ret nz
; Add scaled wCurDamage to wPlayerDamageTaken (clamped to $ffff).
	ld hl, wPlayerDamageTaken + 1
	ld a, [wCurDamage + 1]
	ld b, a
	ld a, [hl]
	add b
	ld [hl], a
	dec hl
	ld a, [wCurDamage]
	ld b, a
	ld a, [hl]
	adc b
	ld [hl], a
	ret nc
	ld [hl], $ff
	inc hl
	ld [hl], $ff
	ret

ApplyEnemyDamageMultiplier::
; Scale wCurDamage by wEnemyDamageMultiplier.
; Called from Effect Commands (bank $0d) via homecall.
; wEnemyDamageMultiplier: 0=50%, 1=75%, 2=100%, 3=125%, 4=150%
	ld a, [wEnemyDamageMultiplier]
	cp 2
	ret z ; 100% - no change
	push bc
	ld a, [wCurDamage]
	ld b, a
	ld a, [wCurDamage + 1]
	ld c, a
	ld a, b
	or c
	jr z, .done  ; zero damage — nothing to scale
	ld a, [wEnemyDamageMultiplier]
	and a
	jr z, .half           ; 0 = 50%
	cp 1
	jr z, .three_quarter  ; 1 = 75%
	cp 3
	jr z, .five_quarter   ; 3 = 125%
	cp 5
	jr z, .double         ; 5 = 200%
	; 4 = 150%
.one_and_half:
	srl b
	rr c
	ld a, [wCurDamage + 1]
	add c
	ld [wCurDamage + 1], a
	ld a, [wCurDamage]
	adc b
	ld [wCurDamage], a
	jr .done
.five_quarter:
	srl b
	rr c
	srl b
	rr c
	ld a, [wCurDamage + 1]
	add c
	ld [wCurDamage + 1], a
	ld a, [wCurDamage]
	adc b
	ld [wCurDamage], a
	jr .done
.three_quarter:
	srl b
	rr c
	srl b
	rr c
	ld a, [wCurDamage + 1]
	sub c
	ld [wCurDamage + 1], a
	ld a, [wCurDamage]
	sbc b
	ld [wCurDamage], a
	jr .done
.half:
	srl b
	rr c
	ld a, b
	or c
	jr nz, .store_half
	ld c, 1
.store_half:
	ld a, b
	ld [wCurDamage], a
	ld a, c
	ld [wCurDamage + 1], a
	jr .done
.double:
	; value = value * 2 (cap at $ffff)
	sla c
	rl b
	jr nc, .store_double
	ld b, $ff
	ld c, $ff
.store_double:
	ld a, b
	ld [wCurDamage], a
	ld a, c
	ld [wCurDamage + 1], a
.done:
	pop bc
	ret

INCLUDE "data/trainers/parties.asm"