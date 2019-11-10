;	callvers.asm
;	Show the effect of attach the sample RSX echovers
;	Adapted from The CP/M Plus programmers guide.

bdos	equ 5
prtstr	equ 9
vers	equ 12
cr	equ 0dh
lf	equ 0ah

	org 100h
	ld d, 5
loop:	push de
	ld c, prtstr
	ld de, call$msg
	call bdos
	ld c, vers
	call bdos
	ld a, l
	ld (curvers), a
	pop de
	dec d
	jp nz, loop
	ld c, 0
	jp bdos
call$msg:	db cr, lf, '****  CALLVERS  ****$'
curvers	db 0
	end
