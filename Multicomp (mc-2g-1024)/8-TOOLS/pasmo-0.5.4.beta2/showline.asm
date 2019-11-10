;	showline.asm

bdos	equ 5

parambegin	equ 80h
paramlen	equ 128

	org 100h

	call showendline

	ld hl, parambegin
	ld b, paramlen

nextchar:	ld a, (hl)

	call showreg

	inc hl

	;djnz nextchar
	dec b
	jp nz, nextchar

	call showendline

	ld hl, parambegin
	ld a, (hl)

nextchar2:	inc hl
	cp 0
	jp z, nomorechar

	ld e, (hl)
	ld c, 2
	push hl
	push af
	call bdos
	pop af
	pop hl
	dec a
	jp nextchar2

nomorechar:	call showendline

	call 0

showendline:	ld de, endline
	ld c, 9
	call bdos
	ret

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

	rrca
	rrca
	rrca
	rrca

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

endline	defb 0Dh, 0Ah, '$'

this_is_the_end:	end

;	End of showline.asm
