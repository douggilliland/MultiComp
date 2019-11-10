;	hola.asm

		
   
;bdos:	equ 5

	org 5
bdos:

	org 100H

	if defined CPM86
	; Install a call to bdos in the cp/m bdos call address
	ld a,0CDh
	ld (5),a
	ld a,0E0h
	ld (6),a
	ld a,0C3h
	ld (7),a
	endif

	ld bc,2565
;	scf
	ccf
sigue:	push bc

	call sayhello

;	ld a, 1
;otro:
;	dec a
;	defb 214, 1; SUB 1
;	jp nz, otro

	pop bc
	dec c
;	jr nz, sigue
	jp nz, sigue
;	djnz sigue

	ld c, 0
	call bdos

	halt

sayhello:
	ld c, 9
	ld de, hola
	call bdos

;	ret

	ld c, 2
	dec c
	ret nz

	call 0

hola:	defb 'Hola, mundo.', 13, 10, '$'

	end
