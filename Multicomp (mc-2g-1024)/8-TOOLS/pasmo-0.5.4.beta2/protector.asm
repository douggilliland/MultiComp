;	protector.asm
;	Rutinas RSX para un juego de Amstrad CPC.
;	Revista "El Ordenador Personal" num. 52, octubre 1986

	org #0A000

extcom	equ #0BCD1
askcur	equ #0BBC6
linrel	equ #0BBF9
linabs	equ #0BBF6
movrel	equ #0BBC3
movabs	equ #0BBC0
setpen	equ #0BBDE
tstrel	equ #0BBF3

	ld bc, rsx
	ld hl, kernal
	jp extcom
rsx	defw table
	jp boum
	jp vise
	jp choc
table	defm 'BOU', 'M' + 80H
	defm 'VIS', 'E' + 80H
	defm 'CHO', 'C' + 80H, 0

; Cambiado esto para que coincida con las DATA de la revista
; y asi poder comprobar el checksum.
;kernal	defs 4
kernal	defb #FC, #A6, #09, #A0

boum	cp 1
	ret nz

	call askcur
	push hl
	push de

	ld a, 1
	call setpen

	ld a, (ix + 0)
;	and #0Fh	; Debe ser par - ERRATA
	and #FE	; Debe ser par
	push af	; Memoriza este valor
	ld d, 0
	ld e, a
	ld h, 0
	ld l, a
	call movrel
	pop af
	add a, a	; Longitud de un lado
	ld h, 0
	ld l, a
	push hl	; Memoriza la longitud

	call invers
	push hl	; Memoriza -L

	ld de, 0	; 0, -L
	call linrel

	pop de	; -L, 0
	ld hl, 0
	call linrel

	ld de, 0	; 0, L
	pop hl
	push hl
	call linrel

	pop de	; L, 0
	ld hl, 0
	call linrel

	jp centre

vise	cp 2
	ret nz

	ld d, (ix + 3)
	ld e, (ix + 2)
	ld h, (ix + 1)
	ld l, (ix + 0)
	push hl
	push de
	call movabs

	ld a, 3	; Pen 3
	call setpen

	ld de, 0	; mover 0, 6
	ld hl, 6
	push hl
	push de
	call movrel

	pop de	; drawr 0, 6
	pop hl
	push de
	call linrel

	pop de	; mover 0, 24
	ld hl, 24
	call invers
	call movrel

	ld de, 0	; draw 0, 6
	ld hl, 6
	push hl
	call linrel

	pop de	; mover -12, 6
	ld hl, 12
	call invers
	ex de, hl
	call movrel

	ld de, 6	; draw 6, 0
	ld hl, 0
	push hl
	call linrel

	ld de, 12	; mover 12, 0
	pop hl
	push hl
	call movrel

	ld de, 6	; draw 6, 0
	pop hl
	call linrel

	jp centre

choc	cp 2
	ret nz

	ld d, (ix + 3)
	ld e, (ix + 2)
	ld h, (ix + 1)
	ld l, (ix + 0)
	push hl
	push de
	call movabs

	ld a, 0
	ld (result), a

	ld de, 0	; testr (0, 0)
	push de
	pop hl
	call tstrel
	call ajout

	ld de, 12	; testr (12, 0)
	ld hl, 0
	call tstrel
	call ajout

	ld hl, 6	; testr (-6, -8)
	call invers
	push hl
	pop de
	dec hl
	dec hl
	call tstrel
	call ajout

	ld de, 0	; testr (0, 2)
	ld hl, 2
	call tstrel
	call ajout

	jp centre

ajout	cp 1
	jr z, suite1
	cp 2
	ret nz	; Si rojo
	ld a, 10

suite1	ld hl, result
	add a, (hl)
	ld (hl), a
	ret

centre	pop de
	pop hl
	jp movabs

invers	xor a
	sub l
	ld l, a
	sbc a, h
	sub l
	cp h
	ld h, a
	scf
	ret nz
	cp 1
	ret

result	defb 0

	end #0A000
