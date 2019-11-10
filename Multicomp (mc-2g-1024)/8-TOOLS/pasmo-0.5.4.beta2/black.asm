	; black.asm

	; Fills slowly the spectrum screen.
	; This program test some capabilities of Pasmo.

	; Try for example:
	; pasmo --tapbas black.asm black.tap
	; pasmo --tapbas --equ NODELAY black.asm black.tap
	; pasmo --tapbas --equ DELAYVALUE=0F000h black.asm black.tap

	; To run it in fuse, for example:
	; fuse black.tap

;		Testing ? short-circuit operator
	org defined LOADPOS ? LOADPOS : 30000

	if defined FILLVALUE
value	equ FILLVALUE
	else
value	equ 0FFh
	endif

start

	; Point to the screen bitmap.

screen		equ defined CPC ? 0C000h : 04000h
	; High word of end of screen
endscreen	equ defined CPC ? 00h : 58h

	if defined USEHL
	ld hl, screen
	else
	ld ix,screen
	endif

other

	; Fills an octet of the screen with the value specified.

	if defined USEHL
	ld (hl), value
	inc hl
	else
	ld (ix), value
	inc ix
	endif

	; Delay

	;if not defined NODELAY
	;if ~ defined NODELAY
	;if ! defined NODELAY
	; Testing short-circuit evaluation.
	if ! defined NODELAY && (! defined DELAYVALUE || DELAYVALUE != 0)
	;if ! defined NODELAY || ! defined DELAYVALUE || DELAYVALUE != 0

;	if defined DELAYVALUE
;loops	equ DELAYVALUE
;	else
;loops	equ 100h
;	endif
;		Testing ? short-circuit operator
loops	equ defined DELAYVALUE ? DELAYVALUE : 100h

;	ld bc, loops
;		Testing high and low operators
	ld b, high loops
	ld c, low loops

delay	dec bc
	ld a,b
	or c
	if defined USEJP
	jp nz, delay
	else
	jr nz, delay
	endif

	endif

	; Test if reached end of screen.

	ld a, 0

	if defined USEHL
	cp l
	else
	cp ixl
	endif

	if defined USEJP
	jp nz, other
	else
	jr nz, other
	endif
	ld a, endscreen

	if defined USEHL
	cp h
	else
	cp ixh
	endif

	if defined USEJP
	jp nz, other
	else
	jr nz, other
	endif

	; And return to Basic.

	ret

	; Set the entry point, needed with the --tapbas option to autorun.
	end start
