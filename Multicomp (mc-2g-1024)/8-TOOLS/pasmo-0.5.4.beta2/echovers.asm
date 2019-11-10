;	echovers.asm
;	Sample RSX for CP/M Plus.

;	Adapted from The CP/M Plus programmers guide.
;	Changed the 8080 sintaxis to Z80.

;	Assemble it with:
;	pasmo --prl echovers.asm ECHOVERS.RSX
;	Assemble the callvers program with:
;	pasmo callvers.asm CALLVERS.COM
;	To attach the RSX to the program excute in CP/M Plus:
;	GENCOM CALLVERS ECHOVERS
;	Now CALLVERS.COM has the RSX attached, run it to see the result.

pstring	equ 9
cr	equ 0dh
lf	equ 0ah

;	RSX PREFIX STRUCTURE

	db 0,0,0,0,0,0
	jp ftest
next:	db 0c3h	; Jump
	dw 0	; Next module in line
prev:	dw 0	; Previous module
remov:	db 0FFh	; Remove flag set
nonbnk:	db 0
	db 'ECHOVERS'
	db 0,0,0

ftest:	; Is this function 12?
	ld a, c
	cp 12
	jp z, begin
	jp next
begin:
	ld hl, 0
	add hl, sp
	ld (ret$stack), hl
	ld sp, loc$stack
	ld c, pstring
	ld de, test$msg
	call next
	ld hl, (ret$stack)
	ld sp, hl
	ld hl, 0031h
	ld c, 12
	call next
	ret
test$msg:
	db cr, lf, '***** ECHOVERS *****$'
ret$stack:	dw 0
	ds 32
loc$stack:
	end
