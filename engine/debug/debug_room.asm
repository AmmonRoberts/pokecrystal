	; _DebugRoom.MenuItems indexes
	const_def
	const DEBUGROOMMENU_PAGE_1 ; 0
	const DEBUGROOMMENU_PAGE_2 ; 1
	const DEBUGROOMMENU_PAGE_3 ; 2
	const DEBUGROOMMENU_PAGE_4 ; 3
	const DEBUGROOMMENU_PAGE_5 ; 4
	const DEBUGROOMMENU_PAGE_6 ; 5
	const DEBUGROOMMENU_PAGE_7 ; 6
DEF DEBUGROOMMENU_NUM_PAGES EQU const_value

	; _DebugRoom.Strings and _DebugRoom.Jumptable indexes
	const_def
	const DEBUGROOMMENUITEM_SP_CLEAR     ; 00
	const DEBUGROOMMENUITEM_WIN_WORK_CLR ; 01
	const DEBUGROOMMENUITEM_POKEMON_GET  ; 02
	const DEBUGROOMMENUITEM_POKEDEX_COMP ; 03
	const DEBUGROOMMENUITEM_TIMER_RESET  ; 04
	const DEBUGROOMMENUITEM_DECORATE_ALL ; 05
	const DEBUGROOMMENUITEM_ITEM_GET     ; 06
	const DEBUGROOMMENUITEM_RTC_EDIT     ; 07
	const DEBUGROOMMENUITEM_NEXT         ; 08
	const DEBUGROOMMENUITEM_GB_ID_SET    ; 09
	const DEBUGROOMMENUITEM_BTL_REC_CLR  ; 0a
	const DEBUGROOMMENUITEM_POKEDEX_CLR  ; 0b
	const DEBUGROOMMENUITEM_HALT_CHK_CLR ; 0c
	const DEBUGROOMMENUITEM_BATTLE_SKIP  ; 0d
	const DEBUGROOMMENUITEM_HOF_CLEAR    ; 0e
	const DEBUGROOMMENUITEM_ROM_CHECKSUM ; 0f
	const DEBUGROOMMENUITEM_TEL_DEBUG    ; 10
	const DEBUGROOMMENUITEM_SUM_RECALC   ; 11
	const DEBUGROOMMENUITEM_RAM_FLAG_CLR ; 12
	const DEBUGROOMMENUITEM_CHANGE_SEX   ; 13
	const DEBUGROOMMENUITEM_BT_BUG_POKE  ; 14
	const DEBUGROOMMENUITEM_ITEM_RANDO   ; 15
	const DEBUGROOMMENUITEM_WARP_TO      ; 16
	const DEBUGROOMMENUITEM_EXP_MULT     ; 17
	const DEBUGROOMMENUITEM_PERMAFAINT   ; 18
	const DEBUGROOMMENUITEM_RESET_ON_WIPE ; 19
	const DEBUGROOMMENUITEM_BADGE_EDIT   ; 1a
	const DEBUGROOMMENUITEM_RARE_CANDY_MART ; 1b
	const DEBUGROOMMENUITEM_WILD_RANDO   ; 1c
	const DEBUGROOMMENUITEM_STRT_RANDO   ; 1d
	const DEBUGROOMMENUITEM_TRNR_RANDO   ; 1e
	const DEBUGROOMMENUITEM_BERY_RANDO   ; 1f
	const DEBUGROOMMENUITEM_TM_FREE      ; 20
	const DEBUGROOMMENUITEM_POIS_SVL     ; 21
	const DEBUGROOMMENUITEM_AUTO_NICK    ; 22
	const DEBUGROOMMENUITEM_PARTY_LIMIT  ; 23
	const DEBUGROOMMENUITEM_GIFT_RANDO   ; 24
	const DEBUGROOMMENUITEM_BOSS_RANDO   ; 25
	const DEBUGROOMMENUITEM_MONEY_MULT   ; 26
	const DEBUGROOMMENUITEM_WILD_ITEM_DROP ; 27
	const DEBUGROOMMENUITEM_HM_MODE           ; 28
	const DEBUGROOMMENUITEM_OW_MOVE_MODE      ; 29
	const DEBUGROOMMENUITEM_WILD_HELD_ITEM_RAND ; 2a
	const DEBUGROOMMENUITEM_WILD_HELD_ITEM_MOD  ; 2b
	const DEBUGROOMMENUITEM_HELD_ITEM_RATE      ; 2c

_DebugRoom::
	ldh a, [hJoyDown]
	and PAD_SELECT | PAD_START
	cp PAD_SELECT | PAD_START
	ret nz
	xor a
	ldh [hSCX], a
	ldh [hSCY], a
	ldh a, [hDebugRoomMenuPage]
	push af
	xor a
	ldh [hDebugRoomMenuPage], a
	ldh [hDebugRoomMenuCursor], a
.loop
	ld hl, wTilemap
	ld bc, wTilemapEnd - wTilemap
	ld a, ' '
	call ByteFill
	ld hl, wAttrmap
	ld bc, wAttrmapEnd - wAttrmap
	ld a, PAL_BG_TEXT
	call ByteFill
	call DebugRoom_PrintStackBottomTop
	call DebugRoom_PrintWindowStackBottomTop
	ldh a, [hDebugRoomMenuPage]
	cp DEBUGROOMMENU_PAGE_1
	jr z, .page1_status
	cp DEBUGROOMMENU_PAGE_3
	jr z, .page3_status
	cp DEBUGROOMMENU_PAGE_4
	jr z, .page4_status
	cp DEBUGROOMMENU_PAGE_5
	jr z, .page5_status
	cp DEBUGROOMMENU_PAGE_6
	jr z, .page6_status
	cp DEBUGROOMMENU_PAGE_7
	jr nz, .status_done
.page7_status
	call DebugRoom_PrintHeldItemRate
	jr .status_done
.page6_status
	call DebugRoom_PrintBossRando
	call DebugRoom_PrintGiftRando
	call DebugRoom_PrintWildItemDrop
	call DebugRoom_PrintWildHeldItemRand
	call DebugRoom_PrintWildHeldItemMod
	call DebugRoom_PrintHMMode
	call DebugRoom_PrintOWMoveMode
	jr .status_done
.page5_status
	call DebugRoom_PrintWildRando
	call DebugRoom_PrintStrtRando
	call DebugRoom_PrintTrnrRando
	call DebugRoom_PrintBeryRando
	call DebugRoom_PrintTMFree
	call DebugRoom_PrintPoisSvl
	call DebugRoom_PrintAutoNick
	jp .status_done
.page4_status
	call DebugRoom_PrintExpMult
	call DebugRoom_PrintMoneyMult
	call DebugRoom_PrintPermafaint
	call DebugRoom_PrintResetOnWipe
	call DebugRoom_PrintRareCandyMart
	call DebugRoom_PrintPartyLimit
	jr .status_done
.page3_status
	call DebugRoom_PrintTelDebug
	call DebugRoom_PrintRAMFlag
	call DebugRoom_PrintGender
	call DebugRoom_PrintItemRando
	jr .status_done
.page1_status
	call DebugRoom_PrintRTCHaltChk
	call DebugRoom_PrintBattleSkip
.status_done
	ldh a, [hDebugRoomMenuPage]
	ld [wWhichIndexSet], a
	ld hl, .MenuHeader
	call LoadMenuHeader
	; Restore the saved cursor position into wMenuCursorPosition so that
	; InitVerticalMenuCursor (called by SetUpMenu) places the cursor correctly.
	; On first entry hDebugRoomMenuCursor = 0, which _InitVerticalMenuCursor
	; treats the same as 1 ("go to top"), so the default behaviour is preserved.
	ldh a, [hDebugRoomMenuCursor]
	ld [wMenuCursorPosition], a
	call SetUpMenu
.wait
	call GetScrollingMenuJoypad
	; GetScrollingMenuJoypad always runs its .done path, which writes the
	; current wMenuCursorY back into wMenuCursorPosition. Save it here,
	; before CloseWindow / ExitMenu pops the window stack and restores
	; wMenuCursorPosition to the push-time default of 1.
	ld a, [wMenuCursorPosition]
	ldh [hDebugRoomMenuCursor], a
	ldh a, [hJoyPressed]
	bit B_PAD_RIGHT, a
	jr nz, .turn_right
	bit B_PAD_LEFT, a
	jr nz, .turn_left
	ld a, [wMenuJoypad]
	and PAD_A | PAD_B
	jr z, .wait
	call CloseWindow
	cp PAD_B
	jr z, .done
	ld a, [wMenuSelection]
	ld hl, .Jumptable
	rst JumpTable
	jp .loop
.turn_right
	call CloseWindow
	ldh a, [hDebugRoomMenuPage]
	inc a
	cp DEBUGROOMMENU_NUM_PAGES
	jr c, .set_page
	xor a
	jr .set_page
.turn_left
	call CloseWindow
	ldh a, [hDebugRoomMenuPage]
	and a
	jr z, .left_wrap
	dec a
	jr .set_page
.left_wrap
	ld a, DEBUGROOMMENU_NUM_PAGES - 1
.set_page
	ldh [hDebugRoomMenuPage], a
	jp .loop
.done
	pop af
	ldh [hDebugRoomMenuPage], a
	ret

.MenuHeader:
	db MENU_BACKUP_TILES ; flags
	menu_coords 0, 0, 15, SCREEN_HEIGHT - 1
	dw .MenuData
	db 1 ; default option

.MenuData:
	db STATICMENU_CURSOR | STATICMENU_WRAP ; flags
	db 0 ; items
	dw .MenuItems
	dw PlaceMenuStrings
	dw .Strings

.Strings:
; entries correspond to DEBUGROOMMENUITEM_* constants
	db "SP CLEAR@"
	db "WIN WORK CLR@"
	db "#MON GET!@"
	db "#DEX COMP.@"
	db "TIMER RESET@"
	db "DECORATE ALL@"
	db "PC ITEM GET!@"
	db "RTC EDIT@"
	db "NEXT@"
	db "GB ID SET@"
	db "BATTLE RECORD@"
	db "#DEX CLEAR@"
	db "HALT CHK CLR@"
	db "BATTLE SKIP@"
	db "HALL OF FAME@"
	db "ROM CHECKSUM@"
	db "PHONE DEBUG@"
	db "CHECKSUM CALC@"
	db "RAM FLAG CLR@"
	db "CHANGE SEX@"
	db "BT BUG POKE@"
	db "ITEM RANDOM@"
	db "WARP TO@"
	db "EXP MULT@"
	db "PERMAFAINT@"
	db "RESET WIPE@"
	db "BADGE EDIT@"
	db "BUY CANDY@"
	db "WILD RANDOM@"
	db "STARTER RANDO@"
	db "TRAINER RANDO@"
	db "BERRY RANDO@"
	db "TM REUSE@"
	db "POISON FADE@"
	db "AUTO NICKNAME@"
	db "PARTY LIMIT@"
	db "GIFT RANDOM@"
	db "BOSS RANDO@"
	db "MONEY MULT@"
	db "ITEM DROP@"
	db "HM REQUIRE@"
	db "FIELD TMS@"
	db "HELD ITEM RND@"
	db "MODERN HELD@"
	db "ITEM RATE@"
.Jumptable:
; entries correspond to DEBUGROOMMENUITEM_* constants
	dw DebugRoomMenu_SpClear
	dw DebugRoomMenu_WinWorkClr
	dw DebugRoomMenu_PokemonGet
	dw DebugRoomMenu_PokedexComp
	dw DebugRoomMenu_TimerReset
	dw DebugRoomMenu_DecorateAll
	dw DebugRoomMenu_ItemGet
	dw DebugRoomMenu_RTCEdit
	dw DebugRoomMenu_Next
	dw DebugRoomMenu_GBIDSet
	dw DebugRoomMenu_BtlRecClr
	dw DebugRoomMenu_PokedexClr
	dw DebugRoomMenu_HaltChkClr
	dw DebugRoomMenu_BattleSkip
	dw DebugRoomMenu_HOFClear
	dw DebugRoomMenu_ROMChecksum
	dw DebugRoomMenu_TelDebug
	dw DebugRoomMenu_SumRecalc
	dw DebugRoomMenu_RAMFlagClr
	dw DebugRoomMenu_ChangeSex
	dw DebugRoomMenu_BTBugPoke
	dw DebugRoomMenu_ItemRando
	dw DebugRoomMenu_WarpTo
	dw DebugRoomMenu_ExpMult
	dw DebugRoomMenu_Permafaint
	dw DebugRoomMenu_ResetOnWipe
	dw DebugRoomMenu_BadgeEdit
	dw DebugRoomMenu_RareCandyMart
	dw DebugRoomMenu_WildRando
	dw DebugRoomMenu_StrtRando
	dw DebugRoomMenu_TrnrRando
	dw DebugRoomMenu_BeryRando
	dw DebugRoomMenu_TMFree
	dw DebugRoomMenu_PoisSvl
	dw DebugRoomMenu_AutoNick
	dw DebugRoomMenu_PartyLimit
	dw DebugRoomMenu_GiftRando
	dw DebugRoomMenu_BossRando
	dw DebugRoomMenu_MoneyMult
	dw DebugRoomMenu_WildItemDrop
	dw DebugRoomMenu_HMMode
	dw DebugRoomMenu_OWMoveMode
	dw DebugRoomMenu_WildHeldItemRand
	dw DebugRoomMenu_WildHeldItemMod
	dw DebugRoomMenu_HeldItemRate

.MenuItems:
; entries correspond to DEBUGROOMMENU_* constants

	; DEBUGROOMMENU_PAGE_1
	db 8
	db DEBUGROOMMENUITEM_SP_CLEAR
	db DEBUGROOMMENUITEM_BATTLE_SKIP
	db DEBUGROOMMENUITEM_RTC_EDIT
	db DEBUGROOMMENUITEM_TIMER_RESET
	db DEBUGROOMMENUITEM_HALT_CHK_CLR
	db DEBUGROOMMENUITEM_GB_ID_SET
	db DEBUGROOMMENUITEM_BTL_REC_CLR
	db DEBUGROOMMENUITEM_NEXT
	db -1

	; DEBUGROOMMENU_PAGE_2
	db 8
	db DEBUGROOMMENUITEM_POKEMON_GET
	db DEBUGROOMMENUITEM_ITEM_GET
	db DEBUGROOMMENUITEM_POKEDEX_COMP
	db DEBUGROOMMENUITEM_POKEDEX_CLR
	db DEBUGROOMMENUITEM_DECORATE_ALL
	db DEBUGROOMMENUITEM_HOF_CLEAR
	db DEBUGROOMMENUITEM_ROM_CHECKSUM
	db DEBUGROOMMENUITEM_NEXT
	db -1

	; DEBUGROOMMENU_PAGE_3
	db 8
	db DEBUGROOMMENUITEM_TEL_DEBUG
	db DEBUGROOMMENUITEM_SUM_RECALC
	db DEBUGROOMMENUITEM_RAM_FLAG_CLR
	db DEBUGROOMMENUITEM_CHANGE_SEX
	db DEBUGROOMMENUITEM_BT_BUG_POKE
	db DEBUGROOMMENUITEM_ITEM_RANDO
	db DEBUGROOMMENUITEM_WARP_TO
	db DEBUGROOMMENUITEM_NEXT
	db -1

	; DEBUGROOMMENU_PAGE_4
	db 8
	db DEBUGROOMMENUITEM_EXP_MULT
	db DEBUGROOMMENUITEM_MONEY_MULT
	db DEBUGROOMMENUITEM_PERMAFAINT
	db DEBUGROOMMENUITEM_RESET_ON_WIPE
	db DEBUGROOMMENUITEM_BADGE_EDIT
	db DEBUGROOMMENUITEM_RARE_CANDY_MART
	db DEBUGROOMMENUITEM_PARTY_LIMIT
	db DEBUGROOMMENUITEM_NEXT
	db -1

	; DEBUGROOMMENU_PAGE_5
	db 8
	db DEBUGROOMMENUITEM_WILD_RANDO
	db DEBUGROOMMENUITEM_STRT_RANDO
	db DEBUGROOMMENUITEM_TRNR_RANDO
	db DEBUGROOMMENUITEM_BERY_RANDO
	db DEBUGROOMMENUITEM_TM_FREE
	db DEBUGROOMMENUITEM_POIS_SVL
	db DEBUGROOMMENUITEM_AUTO_NICK
	db DEBUGROOMMENUITEM_NEXT
	db -1

	; DEBUGROOMMENU_PAGE_6
	db 8
	db DEBUGROOMMENUITEM_BOSS_RANDO
	db DEBUGROOMMENUITEM_GIFT_RANDO
	db DEBUGROOMMENUITEM_WILD_ITEM_DROP
	db DEBUGROOMMENUITEM_WILD_HELD_ITEM_RAND
	db DEBUGROOMMENUITEM_WILD_HELD_ITEM_MOD
	db DEBUGROOMMENUITEM_HM_MODE
	db DEBUGROOMMENUITEM_OW_MOVE_MODE
	db DEBUGROOMMENUITEM_NEXT
	db -1

	; DEBUGROOMMENU_PAGE_7
	db 2
	db DEBUGROOMMENUITEM_HELD_ITEM_RATE
	db DEBUGROOMMENUITEM_NEXT
	db -1

DebugRoomMenu_Next:
	ldh a, [hDebugRoomMenuPage]
	inc a
	cp DEBUGROOMMENU_NUM_PAGES
	jr c, .got_page
	xor a ; DEBUGROOMMENU_PAGE_1
.got_page
	ldh [hDebugRoomMenuPage], a
	ret

DebugRoom_SaveChecksum:
	ld a, BANK(sGameData)
	call OpenSRAM
	ld bc, sGameDataEnd - sGameData
	ld de, 0
	ld hl, sGameData
.loop
	ld a, [hli]
	add e
	ld e, a
	ld a, d
	adc 0
	ld d, a
	dec bc
	ld a, b
	or c
	jr nz, .loop
	ld a, e
	ld [sChecksum + 0], a
	ld a, d
	ld [sChecksum + 1], a
	call CloseSRAM
	ret

DebugRoomMenu_SpClear:
	call YesNoBox
	ret c
	ld a, BANK(sStackTop)
	call OpenSRAM
	xor a
	ld hl, sStackTop
	ld [hli], a
	ld [hl], a
	call CloseSRAM
	call DebugRoom_PrintStackBottomTop
	ret

DebugRoom_PrintStackBottomTop:
	ld a, BANK(sStackTop)
	call OpenSRAM
	hlcoord 16, 14
	ld de, sStackTop + 1
	ld c, 1
	call PrintHexNumber
	ld de, sStackTop + 0
	ld c, 1
	call PrintHexNumber
	call CloseSRAM
	hlcoord 16, 12
	ld de, .SPString
	call PlaceString
	ld d, LOW(wStackBottom)
	ld e, HIGH(wStackBottom)
	push de
	ld hl, sp+0
	ld d, h
	ld e, l
	hlcoord 16, 13
	ld c, 2
	call PrintHexNumber
	pop de
	ret

.SPString:
	db "SP:@"

DebugRoomMenu_WinWorkClr:
	call YesNoBox
	ret c
	ld a, [wWindowStackPointer]
	ld l, a
	ld a, [wWindowStackPointer + 1]
	ld h, a
	inc hl
	ld a, l
	sub LOW(wWindowStack)
	ld a, h
	sbc HIGH(wWindowStack)
	ret c
	ld a, $00
	call OpenSRAM
	ld bc, -wWindowStack + $10000
	add hl, bc
	ld b, h
	ld c, l
	ld hl, wWindowStack
	xor a
	call ByteFill
	call CloseSRAM
	ret

DebugRoom_PrintWindowStackBottomTop:
	ret ; stubbed out

	ld a, $00
	call OpenSRAM
	ld hl, wWindowStack
.loop
	ld a, h
	cp $c0
	jr z, .ok
	ld a, [hl]
	or a
	jr nz, .ok
	inc hl
	jr .loop
.ok
	call CloseSRAM
	ld a, h
	ld h, l
	ld l, a
	push hl
	ld hl, sp+0
	ld d, h
	ld e, l
	hlcoord 16, 17
	ld c, 2
	call PrintHexNumber
	pop hl
	ld d, LOW(wWindowStack)
	ld e, HIGH(wWindowStack)
	push de
	ld hl, sp+0
	ld d, h
	ld e, l
	hlcoord 16, 16
	ld c, 2
	call PrintHexNumber
	pop de
	hlcoord 16, 15
	ld de, .WSPString
	call PlaceString
	ret

.WSPString:
	db "WSP:@"

DebugRoomMenu_PokedexComp:
	call YesNoBox
	ret c
	ld a, BANK(sGameData) ; aka BANK(sPlayerData)
	call OpenSRAM
	ld hl, sPlayerData + (wPokedexCaught - wPlayerData)
	ld b, wEndPokedexSeen - wPokedexCaught
	ld a, %11111111
.loop1
	ld [hli], a
	dec b
	jr nz, .loop1
	ld a, (1 << (NUM_POKEMON % 8)) - 1 ; %00000111
	ld [sPlayerData + (wEndPokedexCaught - 1 - wPlayerData)], a
	ld [sPlayerData + (wEndPokedexSeen - 1 - wPlayerData)], a
	ld hl, sPlayerData + (wStatusFlags - wPlayerData)
	set STATUSFLAGS_UNOWN_DEX_F, [hl]
	ld a, UNOWN_A
	ld [sGameData + (wFirstUnownSeen - wGameData)], a
	ld hl, sGameData + (wUnownDex - wGameData)
	ld b, NUM_UNOWN
.loop2
	ld [hli], a
	inc a
	dec b
	jr nz, .loop2
	call CloseSRAM
	call DebugRoom_SaveChecksum
	ret

DebugRoomMenu_PokedexClr:
	call YesNoBox
	ret c
	ld a, BANK(sPlayerData)
	call OpenSRAM
	ld hl, sPlayerData + (wStatusFlags - wPlayerData)
	res STATUSFLAGS_UNOWN_DEX_F, [hl]
	ld hl, sPlayerData + (wPokedexCaught - wPlayerData)
	ld bc, wEndPokedexSeen - wPokedexCaught
	xor a
	call ByteFill
	ld hl, sGameData + (wUnownDex - wGameData)
	ld bc, NUM_UNOWN
	xor a
	call ByteFill
	call CloseSRAM
	call DebugRoom_SaveChecksum
	ret

DebugRoomMenu_TimerReset:
	call YesNoBox
	ret c
	ld a, BANK(sRTCStatusFlags)
	call OpenSRAM
	ld hl, sRTCStatusFlags
	set RTC_RESET_F, [hl]
	call CloseSRAM
	ret

DebugRoomMenu_ItemRando:
	ld hl, wRandoFlags
	ld a, [hl]
	xor 1 << RANDFLAG_ITEM_RAND_F
	ld [hl], a
	ret

DebugRoom_PrintItemRando:
	hlcoord 16, 9
	ld de, .RandoString
	call PlaceString
	ld a, [wRandoFlags]
	bit RANDFLAG_ITEM_RAND_F, a
	hlcoord 16, 10
	ld de, .OffString
	jr z, .ok
	ld de, .OnString
.ok
	call PlaceString
	ret

.RandoString:
	db "ITR:@"
.OffString:
	db " OFF@"
.OnString:
	db "  ON@"

DebugRoomMenu_WildRando:
	ld hl, wRandoFlags
	ld a, [hl]
	xor 1 << RANDFLAG_WILD_ENCOUNTERS_F
	ld [hl], a
	ret

DebugRoom_PrintWildRando:
	hlcoord 16, 0
	ld de, .Label
	call PlaceString
	ld a, [wRandoFlags]
	bit RANDFLAG_WILD_ENCOUNTERS_F, a
	hlcoord 16, 1
	ld de, .OffString
	jr z, .ok
	ld de, .OnString
.ok
	call PlaceString
	ret

.Label:     db "WIL:@"
.OffString: db " OFF@"
.OnString:  db "  ON@"

DebugRoomMenu_StrtRando:
	ld hl, wRandoFlags
	ld a, [hl]
	xor 1 << RANDFLAG_STARTER_RAND_F
	ld [hl], a
	ret

DebugRoom_PrintStrtRando:
	hlcoord 16, 2
	ld de, .Label
	call PlaceString
	ld a, [wRandoFlags]
	bit RANDFLAG_STARTER_RAND_F, a
	hlcoord 16, 3
	ld de, .OffString
	jr z, .ok
	ld de, .OnString
.ok
	call PlaceString
	ret

.Label:     db "STR:@"
.OffString: db " OFF@"
.OnString:  db "  ON@"

DebugRoomMenu_TrnrRando:
	ld hl, wRandoFlags
	ld a, [hl]
	xor 1 << RANDFLAG_TRAINER_RAND_F
	ld [hl], a
	ret

DebugRoom_PrintTrnrRando:
	hlcoord 16, 4
	ld de, .Label
	call PlaceString
	ld a, [wRandoFlags]
	bit RANDFLAG_TRAINER_RAND_F, a
	hlcoord 16, 5
	ld de, .OffString
	jr z, .ok
	ld de, .OnString
.ok
	call PlaceString
	ret

.Label:     db "TRR:@"
.OffString: db " OFF@"
.OnString:  db "  ON@"

DebugRoomMenu_BeryRando:
	ld hl, wRandoFlags
	ld a, [hl]
	xor 1 << RANDFLAG_BERRY_RAND_F
	ld [hl], a
	ret

DebugRoom_PrintBeryRando:
	hlcoord 16, 6
	ld de, .Label
	call PlaceString
	ld a, [wRandoFlags]
	bit RANDFLAG_BERRY_RAND_F, a
	hlcoord 16, 7
	ld de, .OffString
	jr z, .ok
	ld de, .OnString
.ok
	call PlaceString
	ret

.Label:     db "BER:@"
.OffString: db " OFF@"
.OnString:  db "  ON@"

DebugRoomMenu_TMFree:
	ld hl, wModFlags
	ld a, [hl]
	xor 1 << MODFLAG_TM_UNLIMITED_F
	ld [hl], a
	ret

DebugRoom_PrintTMFree:
	hlcoord 16, 8
	ld de, .Label
	call PlaceString
	ld a, [wModFlags]
	bit MODFLAG_TM_UNLIMITED_F, a
	hlcoord 16, 9
	ld de, .OffString
	jr z, .ok
	ld de, .OnString
.ok
	call PlaceString
	ret

.Label:     db "TM:@"
.OffString: db " OFF@"
.OnString:  db "  ON@"

DebugRoomMenu_PoisSvl:
	ld hl, wModFlags
	ld a, [hl]
	xor 1 << MODFLAG_POISON_SURVIVAL_F
	ld [hl], a
	ret

DebugRoom_PrintPoisSvl:
	hlcoord 16, 10
	ld de, .Label
	call PlaceString
	ld a, [wModFlags]
	bit MODFLAG_POISON_SURVIVAL_F, a
	hlcoord 16, 11
	ld de, .OffString
	jr z, .ok
	ld de, .OnString
.ok
	call PlaceString
	ret

.Label:     db "PSN:@"
.OffString: db " OFF@"
.OnString:  db "  ON@"

DebugRoomMenu_WildItemDrop:
	ld hl, wModFlags
	ld a, [hl]
	xor 1 << MODFLAG_WILD_ITEM_DROP_F
	ld [hl], a
	ret

DebugRoom_PrintWildItemDrop:
	hlcoord 16, 4
	ld de, .Label
	call PlaceString
	ld a, [wModFlags]
	bit MODFLAG_WILD_ITEM_DROP_F, a
	hlcoord 16, 5
	ld de, .OffString
	jr z, .ok
	ld de, .OnString
.ok
	call PlaceString
	ret

.Label:     db "WID:@"
.OffString: db " OFF@"
.OnString:  db "  ON@"

DebugRoomMenu_WildHeldItemRand:
	ld hl, wModFlags
	ld a, [hl]
	xor 1 << MODFLAG_WILD_HELD_ITEM_RAND_F
	ld [hl], a
	ret

DebugRoom_PrintWildHeldItemRand:
	hlcoord 16, 6
	ld de, .Label
	call PlaceString
	ld a, [wModFlags]
	bit MODFLAG_WILD_HELD_ITEM_RAND_F, a
	hlcoord 16, 7
	ld de, .OffString
	jr z, .ok
	ld de, .OnString
.ok
	call PlaceString
	ret

.Label:     db "WHR:@"
.OffString: db " OFF@"
.OnString:  db "  ON@"

DebugRoomMenu_WildHeldItemMod:
	ld hl, wModFlags
	ld a, [hl]
	xor 1 << MODFLAG_WILD_HELD_ITEM_MOD_F
	ld [hl], a
	ret

DebugRoomMenu_HeldItemRate:
	ld a, [wWildHeldItemRate]
	inc a
	cp NUM_WILD_HELD_ITEM_RATES
	jr c, .ok
	xor a
.ok
	ld [wWildHeldItemRate], a
	ret

DebugRoom_PrintHeldItemRate:
	hlcoord 16, 0
	ld de, .Label
	call PlaceString
	ld a, [wWildHeldItemRate]
	ld e, a
	ld d, 0
	ld hl, .Strings
	add hl, de
	add hl, de
	ld a, [hli]
	ld d, [hl]
	ld e, a
	hlcoord 16, 1
	call PlaceString
	ret

.Label:   db "WIR:@"
.Strings:
	dw .str_10
	dw .str_25
	dw .str_35
	dw .str_50
	dw .str_65
	dw .str_75
	dw .str_100
.str_10:  db " 10%@"
.str_25:  db " 25%@"
.str_35:  db " 35%@"
.str_50:  db " 50%@"
.str_65:  db " 65%@"
.str_75:  db " 75%@"
.str_100: db "100%@"

DebugRoom_PrintWildHeldItemMod:
	hlcoord 16, 8
	ld de, .Label
	call PlaceString
	ld a, [wModFlags]
	bit MODFLAG_WILD_HELD_ITEM_MOD_F, a
	hlcoord 16, 9
	ld de, .OffString
	jr z, .ok
	ld de, .OnString
.ok
	call PlaceString
	ret

.Label:     db "WHM:@"
.OffString: db " OFF@"
.OnString:  db "  ON@"

DebugRoomMenu_HMMode:
; Cycles wHMMode through REQUIRED -> LEARNABLE -> FREE.
	ld a, [wHMMode]
	inc a
	cp NUM_HM_MODES
	jr c, .ok
	xor a
.ok
	ld [wHMMode], a
	ret

DebugRoom_PrintHMMode:
	hlcoord 16, 10
	ld de, .Label
	call PlaceString
	ld a, [wHMMode]
	ld e, a
	ld d, 0
	ld hl, .Strings
	add hl, de
	add hl, de
	ld a, [hli]
	ld d, [hl]
	ld e, a
	hlcoord 16, 11
	call PlaceString
	ret

.Label:      db "HMS:@"
.Strings:
	dw .Req
	dw .Lrn
	dw .Free
.Req:  db " REQ@"
.Lrn:  db " LRN@"
.Free: db "FREE@"

DebugRoomMenu_OWMoveMode:
; Cycles wOWMoveMode through REQUIRED -> LEARNABLE -> FREE.
	ld a, [wOWMoveMode]
	inc a
	cp NUM_HM_MODES
	jr c, .ok
	xor a
.ok
	ld [wOWMoveMode], a
	ret

DebugRoom_PrintOWMoveMode:
	hlcoord 16, 15
	ld de, .Label
	call PlaceString
	ld a, [wOWMoveMode]
	ld e, a
	ld d, 0
	ld hl, .Strings
	add hl, de
	add hl, de
	ld a, [hli]
	ld d, [hl]
	ld e, a
	hlcoord 16, 16
	call PlaceString
	ret

.Label:      db "FLD:@"
.Strings:
	dw .Req
	dw .Lrn
	dw .Free
.Req:  db " REQ@"
.Lrn:  db " LRN@"
.Free: db "FREE@"

DebugRoomMenu_AutoNick:
	ld hl, wModFlags
	ld a, [hl]
	xor 1 << MODFLAG_AUTO_NICKNAME_F
	ld [hl], a
	ret

DebugRoom_PrintAutoNick:
	hlcoord 16, 15
	ld de, .Label
	call PlaceString
	ld a, [wModFlags]
	bit MODFLAG_AUTO_NICKNAME_F, a
	hlcoord 16, 16
	ld de, .OffString
	jr z, .ok
	ld de, .OnString
.ok
	call PlaceString
	ret

.Label:     db "NIR:@"
.OffString: db " OFF@"
.OnString:  db "  ON@"

DebugRoomMenu_MoneyMult:
	ld a, [wMoneyMultiplier]
	inc a
	cp 5
	jr c, .ok
	xor a
.ok
	ld [wMoneyMultiplier], a
	ret

DebugRoomMenu_ExpMult:
	ld a, [wExpMultiplier]
	inc a
	cp 5
	jr c, .ok
	xor a
.ok
	ld [wExpMultiplier], a
	ret

DebugRoomMenu_Permafaint:
	ld a, [wPermafaint]
	xor 1   ; toggle bit 0 (permadeath)
	ld [wPermafaint], a
	ret

DebugRoomMenu_ResetOnWipe:
	ld a, [wPermafaint]
	xor 2   ; toggle bit 1 (reset-on-wipe)
	ld [wPermafaint], a
	ret

DebugRoomMenu_RareCandyMart:
	ld a, [wRareCandyMart]
	inc a
	cp NUM_RARE_CANDY_MART_MODES
	jr c, .ok
	xor a
.ok
	ld [wRareCandyMart], a
	ret

DebugRoomMenu_PartyLimit:
	ld a, [wPartyLimit]
	inc a
	cp PARTY_LENGTH + 1
	jr c, .ok
	ld a, 1
.ok
	ld [wPartyLimit], a
	ret

DebugRoom_PrintPartyLimit:
	hlcoord 16, 10
	ld de, .Label
	call PlaceString
	ld a, [wPartyLimit]
	dec a              ; 1-6 → 0-5
	ld e, a
	ld d, 0
	ld hl, .Strings
	add hl, de
	add hl, de
	ld a, [hli]
	ld d, [hl]
	ld e, a
	hlcoord 16, 11
	call PlaceString
	ret

.Label:   db "PTY:@"
.Strings:
	dw .str_1
	dw .str_2
	dw .str_3
	dw .str_4
	dw .str_5
	dw .str_6
.str_1: db "   1@"
.str_2: db "   2@"
.str_3: db "   3@"
.str_4: db "   4@"
.str_5: db "   5@"
.str_6: db "   6@"

DebugRoomMenu_GiftRando:
	ld a, [wGiftRandMode]
	inc a
	cp NUM_GIFT_RAND_MODES
	jr c, .ok
	xor a
.ok
	ld [wGiftRandMode], a
	ret

DebugRoom_PrintGiftRando:
	hlcoord 16, 2
	ld de, .Label
	call PlaceString
	ld a, [wGiftRandMode]
	ld e, a
	ld d, 0
	ld hl, .Strings
	add hl, de
	add hl, de
	ld a, [hli]
	ld d, [hl]
	ld e, a
	hlcoord 16, 3
	call PlaceString
	ret

.Label:      db "GFT:@"
.Strings:
	dw .Standard
	dw .Randomized
	dw .Disabled
.Standard:   db " STD@"
.Randomized: db "RAND@"
.Disabled:   db " DIS@"

DebugRoomMenu_BossRando:
	ld hl, wRandoFlags
	ld a, [hl]
	xor 1 << RANDFLAG_BOSS_RAND_F
	ld [hl], a
	ret

DebugRoom_PrintBossRando:
	hlcoord 16, 0
	ld de, .Label
	call PlaceString
	ld a, [wRandoFlags]
	bit RANDFLAG_BOSS_RAND_F, a
	hlcoord 16, 1
	ld de, .OffString
	jr z, .ok
	ld de, .OnString
.ok
	call PlaceString
	ret

.Label:     db "BSS:@"
.OffString: db " OFF@"
.OnString:  db "  ON@"

DebugRoom_PrintPermafaint:
	hlcoord 16, 4
	ld de, .Label
	call PlaceString
	ld a, [wPermafaint]
	hlcoord 16, 5
	ld de, .OffString
	bit 0, a
	jr z, .ok
	ld de, .OnString
.ok
	call PlaceString
	ret

.Label:     db "PRM:@"
.OffString: db " OFF@"
.OnString:  db "  ON@"

DebugRoom_PrintResetOnWipe:
	hlcoord 16, 6
	ld de, .Label
	call PlaceString
	ld a, [wPermafaint]
	hlcoord 16, 7
	ld de, .OffString
	bit 1, a
	jr z, .ok
	ld de, .OnString
.ok
	call PlaceString
	ret

.Label:     db "RWP:@"
.OffString: db " OFF@"
.OnString:  db "  ON@"

DebugRoom_PrintRareCandyMart:
	hlcoord 16, 8
	ld de, .Label
	call PlaceString
	ld a, [wRareCandyMart]
	ld e, a
	ld d, 0
	ld hl, .Strings
	add hl, de
	add hl, de
	ld a, [hli]
	ld d, [hl]
	ld e, a
	hlcoord 16, 9
	call PlaceString
	ret

.Label:   db "BRC:@"
.Strings:
	dw .Disabled
	dw .Cheap
	dw .Pricey
	dw .Free
.Disabled: db "DSBL@"
.Cheap:    db "CHEP@"
.Pricey:   db "PRCY@"
.Free:     db "FREE@"

DebugRoom_PrintMoneyMult:
	hlcoord 16, 2
	ld de, .MoneyLabel
	call PlaceString
	ld a, [wMoneyMultiplier]
	ld e, a
	ld d, 0
	ld hl, .MoneyStrings
	add hl, de
	add hl, de
	ld a, [hli]
	ld d, [hl]
	ld e, a
	hlcoord 16, 3
	call PlaceString
	ret

.MoneyLabel:
	db "MNY:@"
.MoneyStrings:
	dw .str_050
	dw .str_075
	dw .str_100
	dw .str_125
	dw .str_150
.str_050: db "0.50@"
.str_075: db "0.75@"
.str_100: db "1.00@"
.str_125: db "1.25@"
.str_150: db "1.50@"

DebugRoom_PrintExpMult:
	hlcoord 16, 0
	ld de, .ExpLabel
	call PlaceString
	ld a, [wExpMultiplier]
	ld e, a
	ld d, 0
	ld hl, .ExpStrings
	add hl, de
	add hl, de
	ld a, [hli]
	ld d, [hl]
	ld e, a
	hlcoord 16, 1
	call PlaceString
	ret

.ExpLabel:
	db "EXP:@"
.ExpStrings:
	dw .str_050
	dw .str_075
	dw .str_100
	dw .str_125
	dw .str_150
.str_050: db "0.50@"
.str_075: db "0.75@"
.str_100: db "1.00@"
.str_125: db "1.25@"
.str_150: db "1.50@"

DebugRoomMenu_WarpTo:
	; Initialise the last-group tracker so the auto function doesn't fire a
	; spurious group-change reset on the very first frame, which would clobber
	; the intended default MAP_NEW_BARK_TOWN starting value.
	ld a, MAPGROUP_NEW_BARK
	ld [wDebugRoomLastWarpGroup], a
	ld hl, .PagedValuesHeader
	call DebugRoom_EditPagedValues
	ret

.PagedValuesHeader:
	dw NULL ; A function
	dw NULL ; Select function
	dw DebugRoom_DoWarp ; Start function
	dw DebugRoom_WarpToAuto ; Auto function
	db 1 ; # pages
	dw .Page1Values

.Page1Values:
	db 2
	; paged_value wDebugRoomWarpGroup, 1, NUM_MAP_GROUPS, MAPGROUP_NEW_BARK, .GroupString, DebugRoom_PrintWarpGroupName, TRUE
	dw wDebugRoomWarpGroup  ; value address
	db 1                    ; min value (group 1 = OLIVINE)
	db NUM_MAP_GROUPS       ; max value (group 26 = CHERRYGROVE)
	db MAPGROUP_NEW_BARK    ; initial value
	dw .GroupString         ; label string
	dw DebugRoom_PrintWarpGroupName ; value name function
	db TRUE                 ; is hex value?
	; MAP paged value
	dw wDebugRoomWarpMap    ; value address
	db 1                    ; min value
	db 91                   ; max value (largest group has 91 maps)
	db MAP_NEW_BARK_TOWN    ; initial value
	dw .MapString          ; label string
	dw DebugRoom_PrintWarpMapName ; value name function
	db TRUE                ; is hex value?

.GroupString:
	db "GROUP@"
.MapString:
	db "MAP  @"

WarpGroupMaxMaps:
; Maximum valid map number for each of the 26 map groups (index = group_number - 1).
	db NUM_OLIVINE_MAPS      ;  1 OLIVINE
	db NUM_MAHOGANY_MAPS     ;  2 MAHOGANY
	db NUM_DUNGEONS_MAPS     ;  3 DUNGEONS
	db NUM_ECRUTEAK_MAPS     ;  4 ECRUTEAK
	db NUM_BLACKTHORN_MAPS   ;  5 BLACKTHORN
	db NUM_CINNABAR_MAPS     ;  6 CINNABAR
	db NUM_CERULEAN_MAPS     ;  7 CERULEAN
	db NUM_AZALEA_MAPS       ;  8 AZALEA
	db NUM_LAKE_OF_RAGE_MAPS ;  9 LAKE_OF_RAGE
	db NUM_VIOLET_MAPS       ; 10 VIOLET
	db NUM_GOLDENROD_MAPS    ; 11 GOLDENROD
	db NUM_VERMILION_MAPS    ; 12 VERMILION
	db NUM_PALLET_MAPS       ; 13 PALLET
	db NUM_PEWTER_MAPS       ; 14 PEWTER
	db NUM_FAST_SHIP_MAPS    ; 15 FAST_SHIP
	db NUM_INDIGO_MAPS       ; 16 INDIGO
	db NUM_FUCHSIA_MAPS      ; 17 FUCHSIA
	db NUM_LAVENDER_MAPS     ; 18 LAVENDER
	db NUM_SILVER_MAPS       ; 19 SILVER
	db NUM_CABLE_CLUB_MAPS   ; 20 CABLE_CLUB
	db NUM_CELADON_MAPS      ; 21 CELADON
	db NUM_CIANWOOD_MAPS     ; 22 CIANWOOD
	db NUM_VIRIDIAN_MAPS     ; 23 VIRIDIAN
	db NUM_NEW_BARK_MAPS     ; 24 NEW_BARK
	db NUM_SAFFRON_MAPS      ; 25 SAFFRON
	db NUM_CHERRYGROVE_MAPS  ; 26 CHERRYGROVE

DebugRoom_PrintWarpGroupName:
; Value name function for the GROUP paged value.
; Input: a = group number (1-26), bc = tilemap position for the name row.
	push bc           ; save tilemap position
	dec a             ; 0-index (group 1 -> 0)
	add a             ; multiply by 2 (each pointer is 2 bytes)
	ld c, a
	ld b, 0
	ld hl, .GroupNamePointers
	add hl, bc        ; hl = &.GroupNamePointers[group-1]
	ld a, [hli]
	ld h, [hl]
	ld l, a           ; hl = group name string pointer
	ld d, h
	ld e, l           ; de = group name string (preserved across pop)
	pop hl            ; hl = tilemap position
	push hl
	lb bc, 1, 12
	call ClearBox
	pop hl
	call PlaceString
	ret

.GroupNamePointers:
	dw .Olivine
	dw .Mahogany
	dw .Dungeons
	dw .Ecruteak
	dw .Blackthorn
	dw .Cinnabar
	dw .Cerulean
	dw .Azalea
	dw .LakeOfRage
	dw .Violet
	dw .Goldenrod
	dw .Vermilion
	dw .Pallet
	dw .Pewter
	dw .FastShip
	dw .Indigo
	dw .Fuchsia
	dw .Lavender
	dw .Silver
	dw .CableClub
	dw .Celadon
	dw .Cianwood
	dw .Viridian
	dw .NewBark
	dw .Saffron
	dw .Cherrygrove

.Olivine:     db "OLIVINE@"
.Mahogany:    db "MAHOGANY@"
.Dungeons:    db "DUNGEONS@"
.Ecruteak:    db "ECRUTEAK@"
.Blackthorn:  db "BLACKTHORN@"
.Cinnabar:    db "CINNABAR@"
.Cerulean:    db "CERULEAN@"
.Azalea:      db "AZALEA@"
.LakeOfRage:  db "LAKE OF RAGE@"
.Violet:      db "VIOLET@"
.Goldenrod:   db "GOLDENROD@"
.Vermilion:   db "VERMILION@"
.Pallet:      db "PALLET@"
.Pewter:      db "PEWTER@"
.FastShip:    db "FAST SHIP@"
.Indigo:      db "INDIGO@"
.Fuchsia:     db "FUCHSIA@"
.Lavender:    db "LAVENDER@"
.Silver:      db "SILVER@"
.CableClub:   db "CABLE CLUB@"
.Celadon:     db "CELADON@"
.Cianwood:    db "CIANWOOD@"
.Viridian:    db "VIRIDIAN@"
.NewBark:     db "NEW BARK@"
.Saffron:     db "SAFFRON@"
.Cherrygrove: db "CHERRYGROVE@"

DebugRoom_PrintWarpMapName:
; Value name function for the MAP paged value.
; Input: a = map number (1-91), bc = tilemap position for the name row.
; Uses the map's landmark ID to look up and display the area name.
; If the map number is out of range for the current group, the row is blanked.
	push bc           ; save tilemap position
	push af           ; save map number
	; Bounds-check map number against the max for the current group
	ld hl, WarpGroupMaxMaps
	ld a, [wDebugRoomWarpGroup]
	dec a             ; 0-index
	ld c, a
	ld b, 0
	add hl, bc        ; hl = &WarpGroupMaxMaps[group-1]
	pop af            ; a = map number
	cp [hl]           ; compare with group max
	jr z, .in_range
	jr c, .in_range
	; Map number exceeds the group's max — blank the name row
	pop hl            ; hl = tilemap position
	lb bc, 1, 15
	call ClearBox
	ret
.in_range
	; Look up the landmark ID from the map's group entry
	ld c, a           ; c = map number
	ld a, [wDebugRoomWarpGroup]
	ld b, a           ; b = map group
	ld de, MAP_LOCATION
	call GetAnyMapField ; b=group, c=map, de=offset -> c = landmark ID
	ld e, c           ; e = landmark ID (input for GetLandmarkName)
	; Copy the landmark name into wStringBuffer1
	farcall GetLandmarkName
	; Sanitize the landmark name:
	; - replace <BSP> ($1f, the "breakable space" used on the Town Map) with a
	;   regular space so it renders correctly in a single-line context
	; - cap the string at 15 characters to keep it within the textbox boundary
	;   (name row starts at col 4; last usable inner col is 18; 18-4+1 = 15)
	ld hl, wStringBuffer1
	ld b, 15
.sanitize
	ld a, [hl]
	cp '@'
	jr z, .sanitized  ; string already ends before the cap — leave it alone
	cp $1f            ; <BSP> character?
	jr nz, .not_bsp
	ld [hl], ' '      ; replace with a regular space
.not_bsp
	inc hl
	dec b
	jr nz, .sanitize
	ld [hl], '@'      ; cap at 15 characters
.sanitized
	; Display the name
	pop hl            ; hl = tilemap position
	push hl
	lb bc, 1, 15
	call ClearBox
	pop hl
	ld de, wStringBuffer1
	call PlaceString
	ret

DebugRoom_WarpToAuto:
; Auto function: called every frame while the WARP TO screen is open.
; Resets MAP to 01 when GROUP changes, and clamps MAP to the group's valid max.
	ld a, [wDebugRoomWarpGroup]
	ld b, a
	ld a, [wDebugRoomLastWarpGroup]
	cp b
	jr z, .same_group
	; Group has changed — save new group and reset MAP to 1
	ld a, [wDebugRoomWarpGroup]
	ld [wDebugRoomLastWarpGroup], a
	ld a, 1
	ld [wDebugRoomWarpMap], a
	ld b, 0
	ld c, 1
	call DebugRoom_PrintPagedValue
	ret
.same_group
	; Check whether current MAP exceeds the max for this group
	ld hl, WarpGroupMaxMaps
	ld a, b           ; b = current group (set above)
	dec a             ; 0-index
	ld c, a
	ld b, 0
	add hl, bc        ; hl = &WarpGroupMaxMaps[group-1]
	ld a, [wDebugRoomWarpMap]
	cp [hl]           ; compare MAP with group max
	jr z, .done
	jr c, .done
	; MAP > max — clamp to this group's max
	ld a, [hl]
	ld [wDebugRoomWarpMap], a
	ld b, 0
	ld c, 1
	call DebugRoom_PrintPagedValue
	ret
.done
	ret

DebugRoom_DoWarp:
	; Set up a door warp to the selected map group and map number
	ld a, [wDebugRoomWarpGroup]
	ld [wNextMapGroup], a
	ld a, [wDebugRoomWarpMap]
	ld [wNextMapNumber], a
	ld a, 1 ; warp 1 = first warp exit in the destination map
	ld [wNextWarp], a
	ld a, SPAWN_N_A ; prevent EnterMapSpawnPoint from overriding the destination
	ld [wDefaultSpawnpoint], a
	ld a, MAPSETUP_DOOR
	ldh [hMapEntryMethod], a
	ld a, MAPSTATUS_ENTER
	call LoadMapStatus
	ld hl, .WarpQueuedText
	call MenuTextbox
	call DebugRoom_JoyWaitABSelect
	call CloseWindow
	ret

.WarpQueuedText:
	text "WARP QUEUED!"
	done

DebugRoomMenu_BattleSkip:
	ld a, BANK(sSkipBattle)
	call OpenSRAM
	ld a, [sSkipBattle]
	inc a
	and 1
	ld [sSkipBattle], a
	call CloseSRAM
	ret

DebugRoom_PrintBattleSkip:
	hlcoord 16, 6
	ld de, .BTLString
	call PlaceString
	ld a, BANK(sSkipBattle)
	call OpenSRAM
	ld a, [sSkipBattle]
	call CloseSRAM
	hlcoord 16, 7
	ld de, .DoString
	or a
	jr z, .ok
	ld de, .SkipString
.ok
	call PlaceString
	ret

.BTLString:
	db "BTL:@"
.DoString:
	db "  DO@"
.SkipString:
	db "SKIP@"

DebugRoomMenu_ChangeSex:
	ld a, BANK(sCrystalData)
	call OpenSRAM
	ld a, [sCrystalData + (wPlayerGender - wCrystalData)]
	inc a
	and 1
	ld [sCrystalData + (wPlayerGender - wCrystalData)], a
	call CloseSRAM		; preserves a
	ld [wPlayerGender], a	; sync live WRAM so the change takes effect immediately
	ret

DebugRoom_PrintGender:
	hlcoord 16, 0
	ld de, .SexString
	call PlaceString
	ld a, BANK(sCrystalData)
	call OpenSRAM
	ld a, [sCrystalData + (wPlayerGender - wCrystalData)]
	call CloseSRAM
	or a
	ld a, '♂'
	jr z, .ok
	ld a, '♀'
.ok
	hlcoord 19, 1
	ld [hl], a
	ret

.SexString:
	db "SEX:@"

DebugRoomMenu_TelDebug:
	ld a, BANK(sDebugTimeCyclesSinceLastCall)
	call OpenSRAM
	ld a, [sDebugTimeCyclesSinceLastCall]
	inc a
	cp 3
	jr c, .ok
	xor a
.ok
	ld [sDebugTimeCyclesSinceLastCall], a
	call CloseSRAM
	ret

DebugRoom_PrintTelDebug:
	hlcoord 16, 16
	ld de, .TelString
	call PlaceString
	ld a, BANK(sDebugTimeCyclesSinceLastCall)
	call OpenSRAM
	ld a, [sDebugTimeCyclesSinceLastCall]
	call CloseSRAM
	hlcoord 16, 17
	ld de, .BusyString
	dec a
	jr z, .ok
	ld de, .HardString
	dec a
	jr z, .ok
	ld de, .OffString
.ok
	call PlaceString
	ret

.TelString:
	db "TEL:@"
.OffString:
	db " OFF@"
.BusyString:
	db "BUSY@"
.HardString:
	db "HARD@"

DebugRoomMenu_RAMFlagClr:
	call YesNoBox
	ret c
	ld a, BANK(sOpenedInvalidSRAM)
	call OpenSRAM
	xor a
	ld [sOpenedInvalidSRAM], a
	call CloseSRAM
	ret

DebugRoom_PrintRAMFlag:
	ld a, BANK(sOpenedInvalidSRAM)
	call OpenSRAM
	ld de, sOpenedInvalidSRAM
	hlcoord 18, 4
	ld c, 1
	call PrintHexNumber
	call CloseSRAM
	hlcoord 16, 3
	ld de, .RamString
	call PlaceString
	ret

.RamString:
	db "RAM:@"

DebugRoomMenu_SumRecalc:
	call YesNoBox
	ret c
	call DebugRoom_SaveChecksum
	ret

DebugRoomMenu_DecorateAll:
	call YesNoBox
	ret c
	ld a, BANK(sPlayerData)
	call OpenSRAM
	ld hl, sPlayerData + (wEventFlags - wPlayerData)
	ld de, EVENT_DECO_BED_1 ; the first EVENT_DECO_* constant
	ld b, SET_FLAG
	ld c, EVENT_DECO_BIG_LAPRAS_DOLL - EVENT_DECO_BED_1 + 1
.loop
	push bc
	push de
	push hl
	call FlagAction
	pop hl
	pop de
	pop bc
	inc de
	dec c
	jr nz, .loop
	call CloseSRAM
	call DebugRoom_SaveChecksum
	ret

MACRO paged_value
	dw \1 ; value address
	db \2 ; min value
	db \3 ; max value
	db \4 ; initial value
	dw \5 ; label string
	dw \6 ; value name function
	db \7 ; is hex value?
ENDM

DEF PAGED_VALUE_SIZE EQU 10

DebugRoom_EditPagedValues:
	xor a
	ld [wDebugRoomCurPage], a
	ld [wDebugRoomCurValue], a
	ld a, [hli]
	ld [wDebugRoomAFunction], a
	ld a, [hli]
	ld [wDebugRoomAFunction+1], a
	ld a, [hli]
	ld [wDebugRoomSelectFunction], a
	ld a, [hli]
	ld [wDebugRoomSelectFunction+1], a
	ld a, [hli]
	ld [wDebugRoomStartFunction], a
	ld a, [hli]
	ld [wDebugRoomStartFunction+1], a
	ld a, [hli]
	ld [wDebugRoomAutoFunction], a
	ld a, [hli]
	ld [wDebugRoomAutoFunction+1], a
	ld a, [hli]
	ld [wDebugRoomPageCount], a
	ld a, l
	ld [wDebugRoomPagesPointer], a
	ld a, h
	ld [wDebugRoomPagesPointer+1], a
	ld hl, hInMenu
	ld a, [hl]
	push af
	ld [hl], TRUE
	call ClearBGPalettes
	hlcoord 0, 0
	ld b, SCREEN_HEIGHT - 2
	ld c, SCREEN_WIDTH - 2
	call Textbox
	hlcoord 8, 17
	ld de, DebugRoom_PageString
	call PlaceString
	call DebugRoom_InitializePagedValues
	xor a
	call DebugRoom_PrintPage
	ld a, '▶'
	call DebugRoom_ShowHideCursor
	xor a
	ldh [hJoyLast], a
	xor a
	ld [wDebugRoomCurPage], a
	inc a
	ldh [hBGMapMode], a
	call WaitBGMap
	ld b, SCGB_DIPLOMA
	call GetSGBLayout
	call SetDefaultBGPAndOBP
.resume
	call DelayFrame
	call JoyTextDelay
	ldh a, [hJoyLast]
	bit B_PAD_B, a
	jr nz, .done
	ld hl, .continue
	push hl
	rra ; B_PAD_A?
	jr c, DebugRoom_PagedValuePressedA
	rra ; skip B_PAD_B
	rra ; B_PAD_SELECT?
	jr c, DebugRoom_PagedValuePressedSelect
	rra ; B_PAD_START?
	jr c, DebugRoom_PagedValuePressedStart
	rra ; B_PAD_RIGHT?
	jp c, DebugRoom_IncrementPagedValue
	rra ; B_PAD_LEFT?
	jp c, DebugRoom_DecrementPagedValue
	rra ; B_PAD_UP?
	jp c, DebugRoom_PrevPagedValue
	rra ; B_PAD_DOWN?
	jp c, DebugRoom_NextPagedValue
	pop hl
.continue
; call wDebugRoomAutoFunction if it's not null, then jump to .resume
	ld hl, .resume
	push hl
	ld a, [wDebugRoomAutoFunction]
	ld l, a
	ld a, [wDebugRoomAutoFunction+1]
	ld h, a
	or l
	ret z
	jp hl

.done
	pop af
	ldh [hInMenu], a
	scf
	ret

DebugRoom_PagedValuePressedA:
	ld hl, wDebugRoomAFunction
	jr _CallNonNullPointer

DebugRoom_PagedValuePressedSelect:
	ld hl, wDebugRoomSelectFunction
	jr _CallNonNullPointer

DebugRoom_PagedValuePressedStart:
	ld hl, wDebugRoomStartFunction
	; fallthrough

_CallNonNullPointer:
	ld a, [hli]
	ld h, [hl]
	ld l, a
	or h
	ret z
	jp hl

DebugRoom_PageString:
	db " P  @"

DebugRoom_IncrementPagedValue:
	call DebugRoom_GetCurPagedValuePointer
	ld e, [hl] ; de = value address
	inc hl
	ld d, [hl]
	inc hl
	inc hl
	ld a, [de] ; a = max value
	cp [hl]
	ret z
	inc a
	ld [de], a
	call DebugRoom_PrintPageBValueC
	ret

DebugRoom_DecrementPagedValue:
	call DebugRoom_GetCurPagedValuePointer
	ld e, [hl] ; de = value address
	inc hl
	ld d, [hl]
	inc hl
	ld a, [de] ; a = min value
	cp [hl]
	ret z
	dec a
	ld [de], a
	call DebugRoom_PrintPageBValueC
	ret

DebugRoom_NextPage:
	ld a, [wDebugRoomPageCount]
	ld c, a
	ld a, [wDebugRoomCurPage]
	inc a
	cp c
	jr c, .ok
	xor a
.ok
	ld [wDebugRoomCurPage], a
	call DebugRoom_PrintPage
	ld a, [wDebugRoomCurPage]
	call DebugRoom_GetNthPagePointer
	ld a, [wDebugRoomCurValue]
	cp [hl]
	jr c, .skip
	ld a, [hl]
	dec a
	ld [wDebugRoomCurValue], a
.skip
	ld a, '▶'
	call DebugRoom_ShowHideCursor
	ret

DebugRoom_PrevPage:
	ld a, [wDebugRoomCurPage]
	or a
	jr nz, .ok
	ld a, [wDebugRoomPageCount]
.ok
	dec a
	ld [wDebugRoomCurPage], a
	call DebugRoom_PrintPage
	ld a, [wDebugRoomCurPage]
	call DebugRoom_GetNthPagePointer
	ld a, [wDebugRoomCurValue]
	cp [hl]
	jr c, .skip
	ld a, [hl]
	dec a
	ld [wDebugRoomCurValue], a
.skip
	ld a, '▶'
	call DebugRoom_ShowHideCursor
	ret

DebugRoom_NextPagedValue:
	ld a, ' '
	call DebugRoom_ShowHideCursor
	ld a, [wDebugRoomCurPage]
	call DebugRoom_GetNthPagePointer
	ld a, [wDebugRoomCurValue]
	inc a
	cp [hl] ; incremented value < paged_value count?
	jr c, DebugRoom_UpdateValueCursor
	xor a
	ld [wDebugRoomCurValue], a
	jr DebugRoom_NextPage

DebugRoom_UpdateValueCursor:
	ld [wDebugRoomCurValue], a
	ld a, '▶'
	call DebugRoom_ShowHideCursor
	ret

DebugRoom_PrevPagedValue:
	ld a, ' '
	call DebugRoom_ShowHideCursor
	ld a, [wDebugRoomCurValue]
	or a ; pre-decremented value > 0?
	jr nz, .decrement
	ld a, -1
	ld [wDebugRoomCurValue], a
	jr DebugRoom_PrevPage

.decrement:
	dec a
	jr DebugRoom_UpdateValueCursor

DebugRoom_GetNthPagePointer:
; Input: a = page index
; Output: hl = pointer to paged_data list
	ld h, 0
	ld l, a
	add hl, hl
	ld a, [wDebugRoomPagesPointer]
	ld e, a
	ld a, [wDebugRoomPagesPointer+1]
	ld d, a
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ret

_DebugRoom_GetPageBValueCPointer:
	push bc
	ld a, b
	call DebugRoom_GetNthPagePointer
	pop bc
	inc hl
	ld a, c
	ld bc, PAGED_VALUE_SIZE
	call AddNTimes
	ret

DebugRoom_GetCurPagedValuePointer:
	ld a, [wDebugRoomCurPage]
	ld b, a
	ld a, [wDebugRoomCurValue]
	ld c, a
	jr _DebugRoom_GetPageBValueCPointer

DebugRoom_ShowHideCursor:
	push af
	hlcoord 1, 1
	ld bc, SCREEN_WIDTH * 2
	ld a, [wDebugRoomCurValue]
	call AddNTimes
	pop af
	ld [hl], a
	ret

DebugRoom_InitializePagedValues:
; Load the initial values for all pages of the current paged value header
	ld a, [wDebugRoomPageCount]
.page_loop
	dec a
	push af
	call .InitializePage
	pop af
	jr nz, .page_loop
	ret

.InitializePage:
; Load the initial values for page a
	ld b, a
	ld h, 0
	ld l, a
	add hl, hl
	ld a, [wDebugRoomPagesPointer]
	ld e, a
	ld a, [wDebugRoomPagesPointer+1]
	ld d, a
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld c, [hl] ; c = paged_value count
.value_loop
	push bc
	dec c
	call .InitializeValue
	pop bc
	dec c
	jr nz, .value_loop
	ret

.InitializeValue:
; Load the initial value for page b, value c
	ld h, 0
	ld l, b
	add hl, hl
	ld a, [wDebugRoomPagesPointer]
	ld e, a
	ld a, [wDebugRoomPagesPointer+1]
	ld d, a
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	inc hl ; skip the paged_value count
	ld a, c
	push bc
	ld bc, PAGED_VALUE_SIZE
	call AddNTimes
	pop bc
	ld e, [hl] ; de = value address
	inc hl
	ld d, [hl]
	inc hl
	inc hl
	inc hl
	ld a, [hl] ; a = initial value
	ld [de], a
	ret

DebugRoom_PrintPage:
	push af
	hlcoord 10, 17
	add '1'
	ld [hl], a
	hlcoord 1, 1
	lb bc, SCREEN_HEIGHT - 2, SCREEN_WIDTH - 2
	call ClearBox
	pop af
	ld b, a
	ld h, 0
	ld l, a
	add hl, hl
	ld a, [wDebugRoomPagesPointer]
	ld e, a
	ld a, [wDebugRoomPagesPointer+1]
	ld d, a
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld c, [hl] ; c = paged_value count
.loop
	push bc
	dec c
	call DebugRoom_PrintPagedValue
	pop bc
	dec c
	jr nz, .loop
	ret

DebugRoom_PrintPageBValueC:
	ld a, [wDebugRoomCurPage]
	ld b, a
	ld a, [wDebugRoomCurValue]
	ld c, a
	jr DebugRoom_PrintPagedValue

DebugRoom_PrintPagedValue:
; Print the value for page b, value c
	ld h, 0
	ld l, b
	add hl, hl
	ld a, [wDebugRoomPagesPointer]
	ld e, a
	ld a, [wDebugRoomPagesPointer+1]
	ld d, a
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	inc hl ; skip the paged_value count
	ld a, c
	push bc
	ld bc, PAGED_VALUE_SIZE
	call AddNTimes
	pop bc
	ld e, [hl] ; de = value address
	inc hl
	ld d, [hl]
	inc hl
	push de
	inc hl
	inc hl
	inc hl
	ld e, [hl] ; de = label string
	inc hl
	ld d, [hl]
	inc hl
	push hl
	hlcoord 2, 1
	ld a, c
	ld bc, SCREEN_WIDTH * 2
	call AddNTimes
	push hl
	call PlaceString
	pop hl
	ld bc, SCREEN_WIDTH - 7
	add hl, bc
	pop bc ; pushed hl
	pop de
	push de
	push bc
	inc bc
	inc bc
	ld a, [bc] ; a = is hex value?
	or a
	jr nz, .hex
	lb bc, PRINTNUM_LEADINGZEROS | 1, 3
	call PrintNum
	jr .printed
.hex
	ld c, 1
	call PrintHexNumber
	ld [hl], 'H'
	inc hl
.printed
	ld bc, 6
	add hl, bc
	ld b, h
	ld c, l
	pop hl
	pop de
	ld a, [hli] ; hl = value name function
	ld h, [hl]
	ld l, a
	or h
	ret z
	ld a, [de]
	jp hl

DebugRoom_JoyWaitABSelect:
.loop
	call GetJoypad
	ldh a, [hJoyPressed]
	and PAD_A | PAD_B | PAD_SELECT
	jr z, .loop
	ret

DebugRoomMenu_ItemGet:
	ld hl, .PagedValuesHeader
	call DebugRoom_EditPagedValues
	ret

.PagedValuesHeader:
	dw NULL ; A function
	dw NULL ; Select function
	dw DebugRoom_SaveItem ; Start function
	dw NULL ; Auto function
	db 1 ; # pages
	dw DebugRoomMenu_ItemGet_Page1Values

DebugRoom_SaveItem:
	call YesNoBox
	ret c
	; Search WRAM PC items for an existing stack
	ld hl, wPCItems
	ld a, [wDebugRoomItemID]
	ld c, a
.loop1
	ld a, [hl]
	cp c
	jr z, .found
	cp -1
	jr z, .not_found
	inc hl
	inc hl
	jr .loop1

.found
	; Item already in PC; increase its quantity
	inc hl
	ld a, [wDebugRoomItemQuantity]
	add [hl]
	cp MAX_ITEM_STACK + 1
	jr c, .max
	ld a, MAX_ITEM_STACK
.max
	ld [hl], a
	ld hl, .ItemNumberAddedText
	jr .done

.not_found
	; Item not yet in PC; add a new entry
	ld a, [wNumPCItems]
	cp MAX_PC_ITEMS
	jr nc, .full
	inc a
	ld [wNumPCItems], a
	ld a, [wDebugRoomItemID]
	ld [hli], a
	ld a, [wDebugRoomItemQuantity]
	ld [hli], a
	ld [hl], -1 ; terminator
	ld hl, .CreatedNewItemText
	jr .done

.full
	ld hl, .StockFullText
.done
	call MenuTextbox
	call DebugRoom_JoyWaitABSelect
	call CloseWindow
	ret

.ItemNumberAddedText:
	text "PC qty increased!"
	done

.CreatedNewItemText:
	text "Added to PC!"
	done

.StockFullText:
	text "PC is full!!"
	done

DebugRoom_PrintItemName:
	ld [wNamedObjectIndex], a
	push bc
	call GetItemName
	pop hl
	push hl
	lb bc, 1, 12
	call ClearBox
	pop hl
	ld de, wStringBuffer1
	call PlaceString
	ret

DebugRoomMenu_ItemGet_Page1Values:
	db 2
	paged_value wDebugRoomItemID,       1, HM01 + NUM_HMS - 1, MASTER_BALL, .ItemNameString, DebugRoom_PrintItemName, FALSE
	paged_value wDebugRoomItemQuantity, 1, 99,          1,           .NumberString,   NULL,                    FALSE

.ItemNameString: db "ITEM NAME@"
.NumberString:   db "NUMBER@"

DebugRoomMenu_PokemonGet:
	ld hl, .PagedValuesHeader
	call DebugRoom_EditPagedValues
	ret

.PagedValuesHeader:
	dw NULL ; A function
	dw NULL ; Select function
	dw DebugRoom_SavePokemon ; Start function
	dw NULL ; Auto function
	db 4 ; # pages
	dw DebugRoomMenu_PokemonGet_Page1Values
	dw DebugRoomMenu_PokemonGet_Page2Values
	dw DebugRoomMenu_PokemonGet_Page3Values
	dw DebugRoomMenu_PokemonGet_Page4Values

DebugRoom_SavePokemon:
	call YesNoBox
	ret c
	call DebugRoom_UpdateExpForLevel
	ld a, [wDebugRoomMonBox]
	dec a ; convert to 0-indexed
	ld b, a
	ld a, [wCurBox]
	and $f
	cp b
	jr z, .active_box
	; target is a numbered box - use DebugRoom_BoxAddresses
	ld a, b
	add a
	add b ; multiply by 3 for table_width 3
	ld h, 0
	ld l, a
	ld de, DebugRoom_BoxAddresses
	add hl, de
	ld a, [hli]
	call OpenSRAM
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jr .got_box_pointer
.active_box
	; target is the currently active box - use sBox directly
	ld a, BANK(sBoxCount)
	call OpenSRAM
	ld hl, sBoxCount
.got_box_pointer
	ld a, [hl]
	cp MONS_PER_BOX
	jr nc, .full
	; update count and species list
	push hl
	inc [hl]
	inc hl
	ld d, 0
	ld e, a
	add hl, de
	ld a, [wDebugRoomMonSpecies]
	ld [hli], a
	ld [hl], -1
	pop hl
	; skip count and species list
	ld bc, 2 + MONS_PER_BOX
	add hl, bc
	; update Nth box mon
	push de
	push hl
	ld a, e
	ld bc, BOXMON_STRUCT_LENGTH
	call AddNTimes
	ld d, h
	ld e, l
	ld hl, wDebugRoomMon
	ld bc, BOXMON_STRUCT_LENGTH
	call CopyBytes
	pop hl
	pop de
	; skip box mons
	ld bc, BOXMON_STRUCT_LENGTH * MONS_PER_BOX
	add hl, bc
	; update Nth OT name
	push de
	push hl
	ld a, e
	ld bc, NAME_LENGTH
	call AddNTimes
	ld d, h
	ld e, l
	ld hl, .OTString
	ld bc, NAME_LENGTH
	call CopyBytes
	pop hl
	pop de
	; skip OT names
	ld bc, NAME_LENGTH * MONS_PER_BOX
	add hl, bc
	; update Nth nickname
	push de
	push hl
	ld a, e
	ld bc, MON_NAME_LENGTH
	call AddNTimes
	ld d, h
	ld e, l
	ld hl, .NicknameString
	ld bc, MON_NAME_LENGTH
	call CopyBytes
	pop hl
	pop de
	call CloseSRAM
	ld hl, .CompletedText
	call MenuTextbox
	call DebugRoom_JoyWaitABSelect
	call CloseWindow
	call DebugRoom_SaveChecksum
	ret

.full
	call CloseSRAM
	ld hl, .BoxIsFullText
	call MenuTextbox
	call DebugRoom_JoyWaitABSelect
	call CloseWindow
	ret

.OTString:
	db "DEBUG▶OT@"

.NicknameString:
	db "DEBUG▶<PK><MN>@"

.CompletedText:
	text "COMPLETED!"
	done

.BoxIsFullText:
	text "BOX IS FULL!"
	done

DebugRoom_PrintPokemonName:
	ld [wNamedObjectIndex], a
	push bc
	call GetPokemonName
	jr _DebugRoom_FinishGetName

DebugRoom_PrintItemName2:
	ld [wNamedObjectIndex], a
	push bc
	call GetItemName
	jr _DebugRoom_FinishGetName

DebugRoom_PrintMoveName:
	ld [wNamedObjectIndex], a
	push bc
	call GetMoveName
	jr _DebugRoom_FinishGetName

_DebugRoom_FinishGetName:
	pop hl
	push hl
	lb bc, 1, 12
	call ClearBox
	pop hl
	ld de, wStringBuffer1
	call PlaceString
	ret

DebugRoom_UpdateExpForLevel:
	ld hl, BaseData + BASE_GROWTH_RATE
	ld bc, BASE_DATA_SIZE
	ld a, [wDebugRoomMonSpecies]
	dec a
	call AddNTimes
	ld a, BANK(BaseData)
	call GetFarByte
	ld [wBaseGrowthRate], a
	ld a, [wDebugRoomMonLevel]
	ld d, a
	farcall CalcExpAtLevel
	ld hl, wDebugRoomMonExp
	ldh a, [hProduct + 1]
	ld [hli], a
	ldh a, [hProduct + 2]
	ld [hli], a
	ldh a, [hProduct + 3]
	ld [hl], a
	ret

DebugRoomMenu_PokemonGet_Page1Values:
	db 8
	paged_value wDebugRoomMonSpecies,       1,   NUM_POKEMON, BULBASAUR,      DebugRoom_BoxStructStrings.Pokemon,   DebugRoom_PrintPokemonName, FALSE
	paged_value wDebugRoomMonItem,          1,   $ff,         MASTER_BALL,    DebugRoom_BoxStructStrings.Item,      DebugRoom_PrintItemName2,   FALSE
	paged_value wDebugRoomMonMoves+0,       1,   NUM_ATTACKS, POUND,          DebugRoom_BoxStructStrings.Move1,     DebugRoom_PrintMoveName,    FALSE
	paged_value wDebugRoomMonMoves+1,       1,   NUM_ATTACKS, POUND,          DebugRoom_BoxStructStrings.Move2,     DebugRoom_PrintMoveName,    FALSE
	paged_value wDebugRoomMonMoves+2,       1,   NUM_ATTACKS, POUND,          DebugRoom_BoxStructStrings.Move3,     DebugRoom_PrintMoveName,    FALSE
	paged_value wDebugRoomMonMoves+3,       1,   NUM_ATTACKS, POUND,          DebugRoom_BoxStructStrings.Move4,     DebugRoom_PrintMoveName,    FALSE
	paged_value wDebugRoomMonID+0,          $00, $ff,         HIGH(1234),     DebugRoom_BoxStructStrings.ID0,       NULL,                       FALSE
	paged_value wDebugRoomMonID+1,          $00, $ff,         LOW(1234),      DebugRoom_BoxStructStrings.ID1,       NULL,                       FALSE

DebugRoomMenu_PokemonGet_Page2Values:
	db 8
	paged_value wDebugRoomMonHPExp+0,       $00, $ff,         $00,            DebugRoom_BoxStructStrings.HPExp0,    NULL,                       FALSE
	paged_value wDebugRoomMonHPExp+1,       $00, $ff,         $00,            DebugRoom_BoxStructStrings.HPExp1,    NULL,                       FALSE
	paged_value wDebugRoomMonAtkExp+0,      $00, $ff,         $00,            DebugRoom_BoxStructStrings.AttkExp0,  NULL,                       FALSE
	paged_value wDebugRoomMonAtkExp+1,      $00, $ff,         $00,            DebugRoom_BoxStructStrings.AttkExp1,  NULL,                       FALSE
	paged_value wDebugRoomMonDefExp+0,      $00, $ff,         $00,            DebugRoom_BoxStructStrings.DfnsExp0,  NULL,                       FALSE
	paged_value wDebugRoomMonDefExp+1,      $00, $ff,         $00,            DebugRoom_BoxStructStrings.DfnsExp1,  NULL,                       FALSE
	paged_value wDebugRoomMonSpdExp+0,      $00, $ff,         $00,            DebugRoom_BoxStructStrings.SpeedExp0, NULL,                       FALSE
	paged_value wDebugRoomMonSpdExp+1,      $00, $ff,         $00,            DebugRoom_BoxStructStrings.SpeedExp1, NULL,                       FALSE

DebugRoomMenu_PokemonGet_Page3Values:
	db 8
	paged_value wDebugRoomMonSpcExp+0,      $00, $ff,         $00,            DebugRoom_BoxStructStrings.SpclExp0,  NULL,                       FALSE
	paged_value wDebugRoomMonSpcExp+1,      $00, $ff,         $00,            DebugRoom_BoxStructStrings.SpclExp1,  NULL,                       FALSE
	paged_value wDebugRoomMonDVs+0,         $00, $ff,         $00,            DebugRoom_BoxStructStrings.PowerRnd0, NULL,                       TRUE
	paged_value wDebugRoomMonDVs+1,         $00, $ff,         $00,            DebugRoom_BoxStructStrings.PowerRnd1, NULL,                       TRUE
	paged_value wDebugRoomMonPP+0,          $00, $ff,         $00,            DebugRoom_BoxStructStrings.PP1,       NULL,                       FALSE
	paged_value wDebugRoomMonPP+1,          $00, $ff,         $00,            DebugRoom_BoxStructStrings.PP2,       NULL,                       FALSE
	paged_value wDebugRoomMonPP+2,          $00, $ff,         $00,            DebugRoom_BoxStructStrings.PP3,       NULL,                       FALSE
	paged_value wDebugRoomMonPP+3,          $00, $ff,         $00,            DebugRoom_BoxStructStrings.PP4,       NULL,                       FALSE

DebugRoomMenu_PokemonGet_Page4Values:
	db 6
	paged_value wDebugRoomMonHappiness,     $00, $ff,         BASE_HAPPINESS, DebugRoom_BoxStructStrings.Friend,    NULL,                       FALSE
	paged_value wDebugRoomMonPokerusStatus, $00, $ff,         $00,            DebugRoom_BoxStructStrings.Pokerus,   NULL,                       TRUE
	paged_value wDebugRoomMonCaughtData+0,  $00, $ff,         $00,            DebugRoom_BoxStructStrings.NoUse0,    NULL,                       FALSE
	paged_value wDebugRoomMonCaughtData+1,  $00, $ff,         $00,            DebugRoom_BoxStructStrings.NoUse1,    NULL,                       FALSE
	paged_value wDebugRoomMonLevel,         1,   MAX_LEVEL,   $05,            DebugRoom_BoxStructStrings.Level,     NULL,                       FALSE
	paged_value wDebugRoomMonBox,           1,   NUM_BOXES,   $0e,            DebugRoom_BoxStructStrings.SendBox,   NULL,                       FALSE

DebugRoom_BoxStructStrings:
.Pokemon:   db "#MON@"
.Item:      db "ITEM@"
.Move1:     db "MOVE 1@"
.Move2:     db "MOVE 2@"
.Move3:     db "MOVE 3@"
.Move4:     db "MOVE 4@"
.ID0:       db "ID[0]@"
.ID1:       db "ID[1]@"
.BaseExp0:  db "BASE EXP[0]@" ; unreferenced
.BaseExp1:  db "BASE EXP[1]@" ; unreferenced
.BaseExp2:  db "BASE EXP[2]@" ; unreferenced
.HPExp0:    db "HP EXP[0]@"
.HPExp1:    db "HP EXP[1]@"
.AttkExp0:  db "ATTK EXP[0]@"
.AttkExp1:  db "ATTK EXP[1]@"
.DfnsExp0:  db "DFNS EXP[0]@"
.DfnsExp1:  db "DFNS EXP[1]@"
.SpeedExp0: db "SPEED EXP[0]@"
.SpeedExp1: db "SPEED EXP[1]@"
.SpclExp0:  db "SPCL EXP[0]@"
.SpclExp1:  db "SPCL EXP[1]@"
.PowerRnd0: db "POWER RND[0]<LF>  RARE:--1-1010@"
.PowerRnd1: db "POWER RND[1]<LF>  RARE:10101010@"
.PP1:       db "PP 1@"
.PP2:       db "PP 2@"
.PP3:       db "PP 3@"
.PP4:       db "PP 4@"
.Friend:    db "FRIEND@"
.Pokerus:   db "#RUS@"
.NoUse0:    db "NO USE[0]@"
.NoUse1:    db "NO USE[1]@"
.Level:     db "LEVEL@"
.SendBox:   db "SEND BOX@"

DebugRoom_BoxAddresses:
	table_width 3
for n, 1, NUM_BOXES + 1
	dba sBox{d:n}
endr
	assert_table_length NUM_BOXES

DebugRoomMenu_RTCEdit:
	ld hl, .PagedValuesHeader
	call DebugRoom_EditPagedValues
	ret

.PagedValuesHeader:
	dw NULL ; A function
	dw NULL ; Select function
	dw DebugRoom_SaveRTC ; Start function
	dw DebugRoomMenu_RTCEdit_UpdateClock ; Auto function
	db 1 ; # pages
	dw DebugRoomMenu_RTCEdit_Page1Values

DebugRoom_SaveRTC:
	call YesNoBox
	ret c
	ld hl, wDebugRoomRTCSec
	call DebugRoom_SetClock
	ret

DebugRoomMenu_RTCEdit_UpdateClock:
	ld hl, wDebugRoomRTCCurSec
	call DebugRoom_GetClock
	ld de, DebugRoom_DayHTimeString
	hlcoord 3, 14
	call PlaceString
	ld a, [wDebugRoomRTCCurDay + 0]
	ld h, a
	ld a, [wDebugRoomRTCCurDay + 1]
	ld l, a
	push hl
	ld hl, sp+0
	ld d, h
	ld e, l
	hlcoord 7, 14
	ld c, 2
	call PrintHexNumber
	pop hl
	hlcoord 8, 15
	ld de, wDebugRoomRTCCurHour
	lb bc, PRINTNUM_LEADINGZEROS | 1, 2
	call PrintNum
	ld [hl], ':'
	inc hl
	ld de, wDebugRoomRTCCurMin
	lb bc, PRINTNUM_LEADINGZEROS | 1, 2
	call PrintNum
	ld [hl], ':'
	inc hl
	ld de, wDebugRoomRTCCurSec
	lb bc, PRINTNUM_LEADINGZEROS | 1, 2
	call PrintNum
	ret

DebugRoom_DayHTimeString:
	db "DAY     H<LF>TIME@"

DebugRoom_GetClock:
	ld a, RAMG_SRAM_ENABLE
	ld [rRAMG], a
	xor a
	ld [rRTCLATCH], a
	inc a
	ld [rRTCLATCH], a
	ld b, RAMB_RTC_DH - RAMB_RTC_S + 1
	ld c, RAMB_RTC_S
.loop
	ld a, c
	ld [rRAMB], a
	ld a, [rRTCREG]
	ld [hli], a
	inc c
	dec b
	jr nz, .loop
	call CloseSRAM
	ret

DebugRoom_SetClock:
	ld a, RAMG_SRAM_ENABLE
	ld [rRAMG], a
	ld b, RAMB_RTC_DH - RAMB_RTC_S + 1
	ld c, RAMB_RTC_S
.loop
	ld a, c
	ld [rRAMB], a
	ld a, [hli]
	ld [rRTCREG], a
	inc c
	dec b
	jr nz, .loop
	call CloseSRAM
	ret

DebugRoomMenu_RTCEdit_Page1Values:
	db 5
	paged_value wDebugRoomRTCSec,   0,   60 - 1, 0, .SecondString, NULL, FALSE
	paged_value wDebugRoomRTCMin,   0,   60 - 1, 0, .MinuteString, NULL, FALSE
	paged_value wDebugRoomRTCHour,  0,   24 - 1, 0, .HourString,   NULL, FALSE
	paged_value wDebugRoomRTCDay+0, $00, $ff,    0, .DayLString,   NULL, TRUE
	paged_value wDebugRoomRTCDay+1, $00, $ff,    0, .DayHString,   NULL, TRUE

.SecondString: db "SECOND@"
.MinuteString: db "MINUTE@"
.HourString:   db "HOUR@"
.DayLString:   db "DAY L@"
.DayHString:   db "DAY H<LF> BIT0:DAY MSB<LF> BIT6:HALT<LF> BIT7:DAY CARRY@"

DebugRoomMenu_HaltChkClr:
	call YesNoBox
	ret c
	ld a, BANK(sRTCHaltCheckValue)
	call OpenSRAM
	xor a
	ld hl, sRTCHaltCheckValue
	ld [hli], a
	ld [hl], a
	call CloseSRAM
	call DebugRoom_PrintRTCHaltChk
	ret

DebugRoom_PrintRTCHaltChk:
	hlcoord 16, 9
	ld de, .RTCString
	call PlaceString
	ld a, BANK(sRTCHaltCheckValue)
	ld hl, sRTCHaltCheckValue
	call OpenSRAM
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call CloseSRAM
	ld de, .HaltString
	ld a, h
	cp HIGH(RTC_HALT_VALUE)
	jr nz, .ok
	ld a, l
	cp LOW(RTC_HALT_VALUE)
	jr z, .done
.ok
	ld de, .OKString
.done
	hlcoord 16, 10
	call PlaceString
	ret

.RTCString:
	db "RTC:@"

.OKString:
	db "  OK@"

.HaltString:
	db "HALT@"

DebugRoomMenu_GBIDSet:
	ld hl, .PagedValuesHeader
	call DebugRoom_EditPagedValues
	ret

.PagedValuesHeader:
	dw NULL ; A function
	dw NULL ; Select function
	dw DebugRoom_SaveGBID ; Start function
	dw NULL ; Auto function
	db 1 ; # pages
	dw DebugRoomMenu_GBIDSet_Page1Values

DebugRoom_SaveGBID:
	call YesNoBox
	ret c
	ld a, BANK(sPlayerData)
	call OpenSRAM
	ld hl, sPlayerData + (wPlayerID - wPlayerData)
	ld a, [wDebugRoomGBID + 0]
	ld [hli], a
	ld a, [wDebugRoomGBID + 1]
	ld [hli], a
	call CloseSRAM
	call DebugRoom_SaveChecksum
	ret

DebugRoomMenu_GBIDSet_Page1Values:
	db 2
	paged_value wDebugRoomGBID+0, $00, $ff, $00, .GBID0String, NULL, TRUE
	paged_value wDebugRoomGBID+1, $00, $ff, $00, .GBID1String, NULL, TRUE

.GBID0String: db "GB ID [0]@"
.GBID1String: db "GB ID [1]@"

DebugRoomMenu_BtlRecClr:
	call YesNoBox
	ret c
	ld a, BANK(sLinkBattleStats)
	call OpenSRAM
	xor a
	ld hl, sLinkBattleStats
	ld bc, sLinkBattleStatsEnd - sLinkBattleStats
	call ByteFill
	call CloseSRAM
	ret

DebugRoomMenu_HOFClear:
	call YesNoBox
	ret c
	ld a, BANK(sPlayerData)
	call OpenSRAM
	ld hl, sPlayerData + (wHallOfFameCount - wPlayerData)
	ld [hl], 0
	xor a
	ld hl, sHallOfFame
	ld bc, sHallOfFameEnd - sHallOfFame
	call ByteFill
	call CloseSRAM
	call DebugRoom_SaveChecksum
	ret

ComputeROMChecksum:
	ld de, 0
	call .ComputeROM0Checksum
	ld c, $01 ; first bank
.loop:
	push bc
	push de
	ld a, c
	cpl
	inc a
	add $80
	ld de, wDebugRoomCurChecksumBank
	ld [de], a
	hlcoord 16, 16
	ld c, 1
	call PrintHexNumber
	ld [hl], 'h'
	pop de
	pop bc
	call ComputeROMXChecksum
	inc c
	ld a, c
	cp $80 ; number of banks
	jr c, .loop
	ld a, d
	ld [wDebugRoomROMChecksum + 0], a
	ld a, e
	ld [wDebugRoomROMChecksum + 1], a
	ret

.AddAtoDE:
	add e
	ld e, a
	ld a, d
	adc 0
	ld d, a
	ret

.ComputeROM0Checksum:
	ld hl, $0000 ; ROM0 start
.rom0_loop
	ld a, [hli]
	call .AddAtoDE
	ld a, h
	cp $40 ; HIGH(ROM0 end)
	jr c, .rom0_loop
	ret

.ComputeROMXChecksum: ; unreferenced
	ld hl, $4000 ; ROMX start
.romx_loop
	ld a, c
	call GetFarByte
	inc hl
	call .AddAtoDE
	ld a, h
	cp $80 ; HIGH(ROMX end)
	jr c, .romx_loop
	ret

DebugRoom_PrintROMChecksum: ; unreferenced
	hlcoord 16, 0
	ld de, .SumString
	call PlaceString
	hlcoord 16, 1
	ld de, wDebugRoomROMChecksum
	ld c, 2
	call PrintHexNumber
	ret

.SumString:
	db "SUM:@"

DebugRoomMenu_ROMChecksum:
	ld hl, .WaitText
	call MenuTextbox
	call ComputeROMChecksum
	call CloseWindow
	ld hl, .ROMChecksumText
	call MenuTextbox
	hlcoord 14, 14
	ld de, wDebugRoomROMChecksum
	ld c, 2
	call PrintHexNumber
	ld [hl], 'h'
	call DebugRoom_JoyWaitABSelect
	call CloseWindow
	ret

.WaitText:
	text "Wait..."
	done

.ROMChecksumText:
	text "ROM CHECKSUM:"
	next ""
	done

DebugRoomMenu_BTBugPoke:
	ld a, BANK(sIsBugMon)
	call OpenSRAM
	ld a, [sIsBugMon]
	call CloseSRAM
	or a
	jr nz, .bug_mon
	ld hl, .NoBugMonText
	call MenuTextbox
	call DebugRoom_JoyWaitABSelect
	call CloseWindow
	ret

.NoBugMonText:
	text "No bug #MON."
	done

.bug_mon:
	ld hl, .ItsBugMonText
	call MenuTextbox
	ld a, BANK(sIsBugMon)
	call OpenSRAM
	hlcoord 4, 16
	ld de, sIsBugMon
	ld c, 1
	call PrintHexNumber
	ld [hl], 'h'
	call YesNoBox
	jr c, .done
	xor a
	ld [sIsBugMon], a
.done
	call CloseSRAM
	call CloseWindow
	ret

.ItsBugMonText:
	text "It'", "s bug #MON!"
	next "No.    Clear flag?"
	done

DebugRoomMenu_BadgeEdit:
	xor a
	ld [wDebugRoomBadgesInitialized], a
	ld hl, .PagedValuesHeader
	call DebugRoom_EditPagedValues
	ret

.PagedValuesHeader:
	dw NULL                      ; A function
	dw NULL                      ; Select function
	dw DebugRoom_SaveBadges      ; Start function
	dw DebugRoom_InitBadgesOnce  ; Auto function
	db 2                         ; # pages
	dw DebugRoomMenu_BadgeEdit_Page1Values
	dw DebugRoomMenu_BadgeEdit_Page2Values

DebugRoom_InitBadgesOnce:
; Load current badge state into scratch bytes on the first frame.
	ld a, [wDebugRoomBadgesInitialized]
	or a
	ret nz
	ld a, $ff
	ld [wDebugRoomBadgesInitialized], a
	; Unpack Johto badges (bit 0 = ZEPHYR ... bit 7 = RISING)
	ld a, [wJohtoBadges]
	ld hl, wDebugRoomBadges
	ld c, NUM_JOHTO_BADGES
.unpack_johto
	ld b, a
	and 1
	ld [hli], a
	ld a, b
	rrca
	dec c
	jr nz, .unpack_johto
	; Unpack Kanto badges (bit 0 = BOULDER ... bit 7 = EARTH)
	ld a, [wKantoBadges]
	ld c, NUM_KANTO_BADGES
.unpack_kanto
	ld b, a
	and 1
	ld [hli], a
	ld a, b
	rrca
	dec c
	jr nz, .unpack_kanto
	; Redraw the page with the loaded values
	ld a, [wDebugRoomCurPage]
	call DebugRoom_PrintPage
	ld a, '▶'
	call DebugRoom_ShowHideCursor
	ret

DebugRoom_SaveBadges:
	ld hl, .ConfirmText
	call MenuTextbox
	call YesNoBox
	jr c, .cancel
	call CloseWindow
	; Pack Johto badge scratch bytes back (read RISING..ZEPHYR, shift into byte)
	ld hl, wDebugRoomBadges + NUM_JOHTO_BADGES - 1
	xor a
	ld c, NUM_JOHTO_BADGES
.pack_johto
	ld b, a
	ld a, [hld]
	rra
	ld a, b
	rla
	dec c
	jr nz, .pack_johto
	ld d, a ; d = packed Johto badges
	; Pack Kanto badge scratch bytes back (read EARTH..BOULDER, shift into byte)
	ld hl, wDebugRoomBadges + NUM_JOHTO_BADGES + NUM_KANTO_BADGES - 1
	xor a
	ld c, NUM_KANTO_BADGES
.pack_kanto
	ld b, a
	ld a, [hld]
	rra
	ld a, b
	rla
	dec c
	jr nz, .pack_kanto
	ld e, a ; e = packed Kanto badges
	; Write to WRAM
	ld a, d
	ld [wJohtoBadges], a
	ld a, e
	ld [wKantoBadges], a
	; Write to SRAM
	ld a, BANK(sPlayerData)
	call OpenSRAM
	ld a, d
	ld [sPlayerData + (wJohtoBadges - wPlayerData)], a
	ld a, e
	ld [sPlayerData + (wKantoBadges - wPlayerData)], a
	call CloseSRAM
	call DebugRoom_SaveChecksum
	ld hl, .SavedText
	call MenuTextbox
	call DebugRoom_JoyWaitABSelect
	call CloseWindow
	ret
.cancel
	call CloseWindow
	ret

.ConfirmText:
	text "Save badges?"
	done
.SavedText:
	text "Badges saved!"
	done

DebugRoomMenu_BadgeEdit_Page1Values:
	db 8
	paged_value wDebugRoomBadges + ZEPHYRBADGE,  0, 1, 0, .ZephyrString,  NULL, FALSE
	paged_value wDebugRoomBadges + HIVEBADGE,    0, 1, 0, .HiveString,    NULL, FALSE
	paged_value wDebugRoomBadges + PLAINBADGE,   0, 1, 0, .PlainString,   NULL, FALSE
	paged_value wDebugRoomBadges + FOGBADGE,     0, 1, 0, .FogString,     NULL, FALSE
	paged_value wDebugRoomBadges + MINERALBADGE, 0, 1, 0, .MineralString, NULL, FALSE
	paged_value wDebugRoomBadges + STORMBADGE,   0, 1, 0, .StormString,   NULL, FALSE
	paged_value wDebugRoomBadges + GLACIERBADGE, 0, 1, 0, .GlacierString, NULL, FALSE
	paged_value wDebugRoomBadges + RISINGBADGE,  0, 1, 0, .RisingString,  NULL, FALSE

.ZephyrString:  db "ZEPHYR@"
.HiveString:    db "HIVE@"
.PlainString:   db "PLAIN@"
.FogString:     db "FOG@"
.MineralString: db "MINERAL@"
.StormString:   db "STORM@"
.GlacierString: db "GLACIER@"
.RisingString:  db "RISING@"

DebugRoomMenu_BadgeEdit_Page2Values:
	db 8
	paged_value wDebugRoomBadges + NUM_JOHTO_BADGES + BOULDERBADGE,  0, 1, 0, .BoulderString,  NULL, FALSE
	paged_value wDebugRoomBadges + NUM_JOHTO_BADGES + CASCADEBADGE,  0, 1, 0, .CascadeString,  NULL, FALSE
	paged_value wDebugRoomBadges + NUM_JOHTO_BADGES + THUNDERBADGE,  0, 1, 0, .ThunderString,  NULL, FALSE
	paged_value wDebugRoomBadges + NUM_JOHTO_BADGES + RAINBOWBADGE,  0, 1, 0, .RainbowString,  NULL, FALSE
	paged_value wDebugRoomBadges + NUM_JOHTO_BADGES + SOULBADGE,     0, 1, 0, .SoulString,     NULL, FALSE
	paged_value wDebugRoomBadges + NUM_JOHTO_BADGES + MARSHBADGE,    0, 1, 0, .MarshString,    NULL, FALSE
	paged_value wDebugRoomBadges + NUM_JOHTO_BADGES + VOLCANOBADGE,  0, 1, 0, .VolcanoString,  NULL, FALSE
	paged_value wDebugRoomBadges + NUM_JOHTO_BADGES + EARTHBADGE,    0, 1, 0, .EarthString,    NULL, FALSE

.BoulderString: db "BOULDER@"
.CascadeString: db "CASCADE@"
.ThunderString: db "THUNDER@"
.RainbowString: db "RAINBOW@"
.SoulString:    db "SOUL@"
.MarshString:   db "MARSH@"
.VolcanoString: db "VOLCANO@"
.EarthString:   db "EARTH@"

PrintHexNumber:
; Print the c-byte value from de to hl as hexadecimal digits.
.loop
	push bc
	call .HandleByte
	pop bc
	dec c
	jr nz, .loop
	ret

.HandleByte:
	ld a, [de]
	swap a
	and $f
	call .PrintDigit
	ld [hli], a
	ld a, [de]
	and $f
	call .PrintDigit
	ld [hli], a
	inc de
	ret

.PrintDigit:
	ld bc, .HexDigits
	add c
	ld c, a
	ld a, 0
	adc b
	ld b, a
	ld a, [bc]
	ret

.HexDigits:
	db "0123456789ABCDEF"

MainMenu_ToggleDebugMenu::
	; Show "please wait" message instantly (no button prompt)
	ld hl, .WaitText
	call PrintText

	; Toggle the flag
	ld hl, wDebugFlags
	ld a, [hl]
	xor 1 << DEBUG_MENU_UNLOCKED_F
	ld [hl], a
	push af

	; Write new state to SRAM
	ld a, BANK(sDebugMenuUnlocked)
	call OpenSRAM
	ld a, [wDebugFlags]
	bit DEBUG_MENU_UNLOCKED_F, a
	ld a, 0
	jr z, .write
	inc a
.write
	ld [sDebugMenuUnlocked], a
	call CloseSRAM

	; Play SFX while we prepare the confirmation message
	ld de, SFX_LEVEL_UP
	call PlaySFX
	call WaitSFX

	; Show confirmation (reuse existing textbox, waits for A/B)
	pop af
	bit DEBUG_MENU_UNLOCKED_F, a
	ld hl, .DisabledText
	jr z, .show
	ld hl, .EnabledText
.show
	call PrintText

	; Wait up to ~3 seconds (180 frames) or until A/B is pressed
	ld b, 180
.wait
	call DelayFrame
	call GetJoypad
	ldh a, [hJoyPressed]
	and PAD_A | PAD_B
	jr nz, .dismiss
	dec b
	jr nz, .wait
.dismiss
	; Sync hJoyDown to real hardware state so the next GetJoypad delta is 0,
	; preventing the dismiss button from leaking back into the main menu loop.
	ldh a, [hJoypadDown]
	ldh [hJoyDown], a
	xor a
	ldh [hJoyPressed], a
	ldh [hJoyReleased], a
	ldh [hJoyLast], a
	ldh [hJoypadPressed], a
	ldh [hJoypadReleased], a
	ldh [hJoypadSum], a
	ret

.WaitText:
	text_far .strWait
	text_end
.strWait:
	text "Updating debug"
	line "menu setting..."
	done

.EnabledText:
	text_far .strEnabled
	text_end
.strEnabled:
	text "Debug menu"
	line "enabled."
	done

.DisabledText:
	text_far .strDisabled
	text_end
.strDisabled:
	text "Debug menu"
	line "disabled."
	done
