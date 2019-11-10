;	showfcb.asm

bdos	equ 5

conout	equ 2
printstring	equ 9

	public fcb1, fcb2
fcb1	equ 005Ch
fcb2	equ 006Ch

	org 100h

	call endline

	ld hl, fcb1
	call showfcb
	call endline

	ld hl, fcb2
	call showfcb
	call endline

	ld hl, fcb1
	ld de, 12

	add hl, de
	ld (hl), 0

	ld de, dma
	ld c, 1Ah
	call bdos

	ld de, fcb1
	ld c, 11h
	call bdos

	cp 0FFh
	jp z, final

	public otro
otro:	ld hl, dma

	; Calculate the position of the result
	; into the dma.
	add a, a
	add a, a
	add a, a
	add a, a
	add a, a
	ld e, a
	ld d, 0
	add hl, de

	call showfcb
	call endline

	ld de, fcb1
	ld c, 12h
	call bdos

	cp 0FFh
	jp z, final

	jp otro

	public final
final:	ld c, 0
	call bdos

	public showfcb
showfcb	ld a, (hl)
	cp 0
	;jr z, nodrive
	jp z, nodrive
	dec a
	add a, 'A'
	ld e, a
	call printchar
	ld e, ':'
	call printchar

nodrive	inc hl
	ld b, 8

	public name
name	ld e, (hl)
	call printchar
	inc hl
	;djnz name
	dec b
	jp nz, name

	ld e, '.'
	call printchar

	ld b, 3
	public ext
ext	ld e, (hl)
	call printchar
	inc hl
	;djnz ext
	dec b
	jp nz, ext
	ret


HERE:
	public HERE

	public printchar	
printchar	push bc
	push de
	push hl
	ld c, conout
	call bdos
	pop hl
	pop de
	pop bc
	ret

	public endline
endline	ld de, crlf
	ld c, printstring
	jp bdos
crlf	db 0Dh, 0Ah, '$'

	public dma
dma	equ $

	public this_is_the_end
this_is_the_end	end
