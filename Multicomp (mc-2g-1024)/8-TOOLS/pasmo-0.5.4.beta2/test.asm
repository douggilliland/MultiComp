;	test.asm


	org 100H

;	Instructions without parameters.

	ccf
	cpd
	cpdr
	cpi
	cpir
	cpl
	daa
	di
	ei
	exx
	halt
	ldd
	lddr
	ldi
	ldir
	nop
	neg
	otdr
	otir
	outd
	outi
	reti
	retn
	rla
	rlca
	rld
	rra
	rrca
	rrd
	scf

	ld a, 1
	ld (hl), 2
	ld a, (hl)
	inc hl
	dec hl
	inc (hl)
	dec (hl)

	ld b, b
	ld b, c
	ld b, d
	ld b, e
	ld b, h
	ld b, l
	ld b, (hl)
	ld b, a

	ld c, b
	ld c, c
	ld c, d
	ld c, e
	ld c, h
	ld c, l
	ld c, (hl)
	ld c, a

	ld d, b
	ld d, c
	ld d, d
	ld d, e
	ld d, h
	ld d, l
	ld d, (hl)
	ld d, a

	cp 128
	cp b
	cp c
	cp d
	cp e
	cp h
	cp l
	cp (hl)
	cp a
	cp (ix)
	cp (iy + 10)

	jp (hl)
	jp (ix)
	jp (iy)

	ex af, af'
	ex de,hl
	ex (sp), hl
	ex (sp), ix
	ex (sp), iy

	call 0
