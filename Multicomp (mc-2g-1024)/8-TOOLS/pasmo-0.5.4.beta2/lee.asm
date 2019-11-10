;	lee.asm

fcb1	equ 05Ch

bdos	equ 5

bdosconsoleoutput	equ 02h
bdosprintstring	equ 09h
bdosopenfile	equ 0Fh
bdosclosefile	equ 10h
bdosreadsequential	equ 14h
bdossetdmaaddress	equ 1Ah

	org 100h

	ld de, fcb1
	ld c, bdosopenfile
	call bdos

	cp 0FFh
	jp z, fallo

	ld de, buffer

again	push de
	ld c, bdossetdmaaddress
	call bdos

	ld de, fcb1
	ld c, bdosreadsequential
	call bdos

	cp 0
	jp z, sigue
	cp 1
	jp z, finlee
	jp fallo

sigue	pop de
	ld hl, 128
	add hl, de
	ld d, h
	ld e, l
	jp again

finlee
	ld c, bdosclosefile
	ld de, fcb1
	call bdos

	ld hl, buffer
	ld bc, 512

nextchar
	ld e, (hl)
	push hl
	push bc
	ld c, bdosconsoleoutput
	call bdos
	pop bc
	pop hl
	inc hl
	dec bc
	ld a, c
	or b
	jp nz, nextchar

	ld c, 0
	call bdos

fallo	ld de, mensajeerror
	ld c, bdosprintstring
	call bdos
	ld c, 0
	call bdos

mensajeerror	defb 'Error.', 0Dh, 0Ah, '$'

	public again, fallo

buffer	equ $

	end 100h

;	End of lee.asm
