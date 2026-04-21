; New-game menu option descriptions.
; Called via farcall from Crystal Features 1 (bank $12).
; Resides in "New Game Descs" (bank $21) to avoid overflowing CF1.

ShowNewGameOptionDescription:
; Draws a description overlay box at the bottom of the screen for the
; currently highlighted option. Waits for A or B to close it.
	call GetNewGameOptionDescString ; loads de with description string pointer
	push de

	; Draw description overlay textbox (rows 11–17, full width)
	hlcoord 0, 11
	ld b, 5   ; 4 content lines (rows 12–16)
	ld c, 18  ; inner width
	call Textbox

	; Place description text
	pop de
	hlcoord 1, 12
	call PlaceString

	; Trigger BG map update
	ld a, 1
	ldh [hBGMapMode], a
	call WaitBGMap

.wait_input:
	call JoyTextDelay
	ldh a, [hJoyPressed]
	and PAD_A | PAD_B
	jr z, .wait_input
	ret

GetNewGameOptionDescString:
; Loads de with the description string pointer for the currently
; highlighted option on the current page.
	ld a, [wNewGameOptionsPage]
	and a
	jr z, .page1
	cp 1
	jr z, .page2
	cp 2
	jr z, .page3
	cp 3
	jr z, .page4
	ld hl, .DescPage5
	jr .lookup
.page1:
	ld hl, .DescPage1
	jr .lookup
.page2:
	ld hl, .DescPage2
	jr .lookup
.page3:
	ld hl, .DescPage3
	jr .lookup
.page4:
	ld hl, .DescPage4
.lookup:
	ld a, [wJumptableIndex]
	ld e, a
	ld d, 0
	add hl, de
	add hl, de
	ld a, [hli]
	ld d, [hl]
	ld e, a
	ret

.DescPage1:
	dw .desc_wild_enc
	dw .desc_starter
	dw .desc_trainer
	dw .desc_boss
	dw .desc_berry
	dw .desc_item
.DescPage2:
	dw .desc_gift
	dw .desc_type_rand
	dw .desc_nickname
	dw .desc_wild_held_rand
	dw .desc_static_rand
.DescPage3:
	dw .desc_tm_mode
	dw .desc_exp_mult
	dw .desc_money_mult
	dw .desc_rare_candy
	dw .desc_poison
	dw .desc_wild_drop
.DescPage4:
	dw .desc_tm_vendor
	dw .desc_more_held
	dw .desc_held_rate
.DescPage5:
	dw .desc_permadeath
	dw .desc_reset_wipe
	dw .desc_party_limit
	dw .desc_first_enc
	dw .desc_hm_req
	dw .desc_ow_move

; ---- Description strings (max 18 chars per line, with 5 lines) ----

.desc_wild_enc:
	db "Randomizes wild<LF>"
	db "#MON species in<LF>"
	db "grass, water,<LF>"
	db "rocks and caves.@"

.desc_starter:
	db "Randomizes starter<LF>"
	db "#MON at PROF.<LF>"
	db "ELM's lab.@"

.desc_trainer:
	db "Randomizes regular<LF>"
	db "trainer #MON<LF>"
	db "parties.@"

.desc_boss:
	db "Randomizes gym<LF>"
	db "leader, Elite 4,<LF>"
	db "rival, and<LF>"
	db "RED's parties.@"

.desc_berry:
	db "Randomizes BERRIES<LF>"
	db "found growing on<LF>"
	db "trees throughout<LF>"
	db "the world.@"

.desc_item:
	db "Randomizes items<LF>"
	db "found in item<LF>"
	db "balls on the<LF>"
	db "ground.@"

.desc_gift:
	db "Randomizes or<LF>"
	db "disables gift<LF>"
	db "#MON. No effect<LF>"
	db "on starters.@"

.desc_type_rand:
	db "Randomizes type<LF>"
	db "matchup chart.<LF>"
	db "BALANCED: at most<LF>"
	db "2 immunities.@"

.desc_nickname:
	db "Assigns random<LF>"
	db "nicknames whenever<LF>"
	db "you catch or<LF>"
	db "hatch a #MON.@"

.desc_wild_held_rand:
	db "Randomizes the<LF>"
	db "held items carried<LF>"
	db "by wild #MON.@"

.desc_static_rand:
	db "Randomizes static<LF>"
	db "#MON encounters<LF>"
	db "(legends, Snorlax,<LF>"
	db "etc.). Level kept.@"

.desc_tm_mode:
	db "UNLIMITED: TMs are<LF>"
	db "reused. STANDARD:<LF>"
	db "each TM is<LF>"
	db "consumed on use.@"

.desc_exp_mult:
	db "Multiplies EXP.<LF>"
	db "gained in battle.<LF>"
	db "From x0.50<LF>"
	db "to x1.50.@"

.desc_money_mult:
	db "Multiplies ¥<LF>"
	db "earned.<LF>"
	db "From x0.50<LF>"
	db "to x1.50.@"

.desc_rare_candy:
	db "Adds RARE CANDY to<LF>"
	db "shops. Modes:<LF>"
	db "Cheap, Pricey,<LF>"
	db "or Free.@"

.desc_poison:
	db "Poison stops at<LF>"
	db "1 HP; your #MON<LF>"
	db "won't faint if<LF>"
	db "walking.@"

.desc_wild_drop:
	db "Wild #MON drop<LF>"
	db "their held item<LF>"
	db "when knocked out<LF>"
	db "in battle.@"

.desc_tm_vendor:
	db "Adds a vendor NPC<LF>"
	db "in BLACKTHORN MART<LF>"
	db "who sells all<LF>"
	db "TMs.@"

.desc_more_held:
	db "Wild #MON can<LF>"
	db "hold new items.<LF>"
	db "Most #MON<LF>"
	db "drop something.@"

.desc_held_rate:
	db "Base chance for<LF>"
	db "wild #MON to<LF>"
	db "hold an item when<LF>"
	db "encountered.@"

.desc_permadeath:
	db "Fainted #MON<LF>"
	db "are permanently<LF>"
	db "lost. Held items<LF>"
	db "are recovered.@"

.desc_reset_wipe:
	db "When your last<LF>"
	db "#MON faints,<LF>"
	db "the saved game<LF>"
	db "is auto-deleted.@"

.desc_party_limit:
	db "Maximum #MON<LF>"
	db "you can have in<LF>"
	db "your party at once<LF>"
	db "(1 to 6).@"

.desc_first_enc:
	db "Only the first<LF>"
	db "#MON met in<LF>"
	db "each area can be<LF>"
	db "caught.@"

.desc_hm_req:
	db "DISABLED: Only<LF>"
	db "badge required.<LF>"
	db "LEARNABLE: Must be<LF>"
	db "able to learn.@"

.desc_ow_move:
	db "HEADBUTT and ROCK<LF>"
    db "SMASH. DISABLED: <LF>"
	db "no TM needed.<LF>"
	db "LEARNABLE: Must be<LF>"
	db "able to learn.@"
