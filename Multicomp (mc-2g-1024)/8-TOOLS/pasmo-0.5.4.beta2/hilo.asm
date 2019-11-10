;	hilo.asm

;	Test of HIGH and LOW operators.

bdos	equ 5

	org 100h

l1	equ 01234h
l2	equ 0FFFFh
l3	equ 0F07Fh

	ld a, high l1
	call showreg
	call showendline

	ld a, low l1
	call showreg
	call showendline

	ld a, high l1 or l3
	call showreg
	call showendline

	ld a, high (low l1) and l3
	call showreg
	call showendline

	call 0

showendline:	ld de, endline
	ld c, 9
	call bdos
	ret

endline	defb 0Dh, 0Ah, '$'

showreg:
	push bc
	push hl

	push af

	push af

	ld e, 20h
	ld c, 2
	call bdos

	pop af

	; Para ver mejor al trazar.
	and 0F0h

	rept 4
	rrca
	endm

	call shownibble

	pop af

	call shownibble

	pop hl
	pop bc
	ret	

shownibble:
	and 0Fh
	add a, 30h

	cp 3Ah
	jp c, isdigit

	add a, 7
isdigit:	

	ld e, a
	ld c, 2
	call bdos
	ret

;	End of showline.asm
