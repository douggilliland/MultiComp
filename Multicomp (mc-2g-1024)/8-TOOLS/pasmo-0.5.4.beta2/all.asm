;	all.asm
;	All instructions of the Z80

	org 100h	; Useful for some tests.

des	equ 05h
n	equ 20h
nn	equ 0584h

;	ADC

	adc a, (hl)

	if ! defined ONLY8080 && ! defined ONLY86
	adc a, (ix + des)
	adc a, (iy + des)
	endif

	adc a, a
	adc a, b
	adc a, c
	adc a, d
	adc a, e
	adc a, h
	adc a, l
	adc a, n

	if ! defined ONLY8080
	adc hl, bc
	adc hl, de
	adc hl, hl
	adc hl, sp
	endif

;	ADD

	add a, (hl)

	if ! defined ONLY8080 && ! defined ONLY86
	add a, (ix + des)
	add a, (iy + des)
	endif

	add a, a
	add a, b
	add a, c
	add a, d
	add a, e
	add a, h
	add a, l
	add a, n

	add hl, bc
	add hl, de
	add hl, hl
	add hl, sp

	if ! defined ONLY8080 && ! defined ONLY86
	add ix, bc
	add ix, de
	add ix, ix
	add ix, sp

	add iy, bc
	add iy, de
	add iy, iy
	add iy, sp
	endif

;	AND

	and (hl)

	if ! defined ONLY8080 && ! defined ONLY86
	and (ix + des)
	and (iy + des)
	endif

	and a
	and b
	and c
	and d
	and e
	and h
	and l
	and n

;	BIT

	if ! defined ONLY8080 && ! defined ONLY86
	bit 0, (hl)
	bit 0, (ix + des)
	bit 0, (iy + des)
	bit 0, a
	bit 0, b
	bit 0, c
	bit 0, d
	bit 0, e
	bit 0, h
	bit 0, l

	bit 1, (hl)
	bit 1, (ix + des)
	bit 1, (iy + des)
	bit 1, a
	bit 1, b
	bit 1, c
	bit 1, d
	bit 1, e
	bit 1, h
	bit 1, l

	bit 2, (hl)
	bit 2, (ix + des)
	bit 2, (iy + des)
	bit 2, a
	bit 2, b
	bit 2, c
	bit 2, d
	bit 2, e
	bit 2, h
	bit 2, l

	bit 3, (hl)
	bit 3, (ix + des)
	bit 3, (iy + des)
	bit 3, a
	bit 3, b
	bit 3, c
	bit 3, d
	bit 3, e
	bit 3, h
	bit 3, l

	bit 4, (hl)
	bit 4, (ix + des)
	bit 4, (iy + des)
	bit 4, a
	bit 4, b
	bit 4, c
	bit 4, d
	bit 4, e
	bit 4, h
	bit 4, l

	bit 5, (hl)
	bit 5, (ix + des)
	bit 5, (iy + des)
	bit 5, a
	bit 5, b
	bit 5, c
	bit 5, d
	bit 5, e
	bit 5, h
	bit 5, l

	bit 6, (hl)
	bit 6, (ix + des)
	bit 6, (iy + des)
	bit 6, a
	bit 6, b
	bit 6, c
	bit 6, d
	bit 6, e
	bit 6, h
	bit 6, l

	bit 7, (hl)
	bit 7, (ix + des)
	bit 7, (iy + des)
	bit 7, a
	bit 7, b
	bit 7, c
	bit 7, d
	bit 7, e
	bit 7, h
	bit 7, l
	endif

;	CALL

	call c, nn
	call m, nn
	call nc, nn
	call nz, nn
	call p, nn
	call pe, nn
	call po, nn
	call z, nn
	call nn

;	CCF

	ccf

;	CP

	cp (hl)

	if ! defined ONLY8080 && ! defined ONLY86
	cp (ix + des)
	cp (iy + des)
	endif

	cp a
	cp b
	cp c
	cp d
	cp e
	cp h
	cp l
	cp n

;	CP..

	if ! defined ONLY8080 && ! defined ONLY86
	cpd
	cpdr
	cpir
	cpi
	endif

	cpl

;	DAA

	daa

;	DEC

	dec (hl)

	if ! defined ONLY8080 && ! defined ONLY86
	dec (ix + des)
	dec (iy + des)
	endif

	dec a
	dec b
	dec bc
	dec c
	dec d
	dec de
	dec e
	dec h
	dec hl

	if ! defined ONLY8080 && ! defined ONLY86
	dec ix
	dec iy
	endif

	dec l
	dec sp

;	DI

	di

;	DJNZ

	if ! defined ONLY8080
l1	djnz l1
	endif

;	EI

	ei

;	EX

	if ! defined ONLY86
	ex (sp), hl
	endif

	if ! defined ONLY8080 && ! defined ONLY86
	ex (sp), ix
	ex (sp), iy
	ex af, af'
	endif

	ex de, hl

	if ! defined ONLY8080 && ! defined ONLY86
	exx
	endif

;	HALT

	halt

;	IM

	if ! defined ONLY8080 && ! defined ONLY86
	im 0
	im 1
	im 2
	endif

;	IN

	if ! defined ONLY8080 && ! defined ONLY86
	in a, (c)
	in b, (c)
	in c, (c)
	in d, (c)
	in e, (c)
	in h, (c)
	in l, (c)
	endif

;	INC

	inc (hl)

	if ! defined ONLY8080 && ! defined ONLY86
	inc (ix + des)
	inc (iy + des)
	endif

	inc a
	inc b
	inc bc
	inc c
	inc d
	inc de
	inc e
	inc h
	inc hl

	if ! defined ONLY8080 && ! defined ONLY86
	inc ix
	inc iy
	endif

	inc l
	inc sp

;	IN...

	in a, (n)

	if ! defined ONLY8080 && ! defined ONLY86
	ind
	indr
	ini
	inir
	endif

;	JP

	jp nn
	jp (hl)

	if ! defined ONLY8080 && ! defined ONLY86
	jp (ix)
	jp (iy)
	endif

	jp c, nn
	jp m, nn
	jp nc, nn
	jp nz, nn
	jp p, nn
	jp pe, nn
	jp po, nn
	jp z, nn

;	JR

	if ! defined ONLY8080
	jr c, $ + 22h
	jr nc, $ + 22h
	jr nz, $ + 22h
	jr z, $ + 22h
	jr $ + 22h
	endif

;	LD

	ld (bc), a
	ld (de), a
	ld (hl), a
	ld (hl), b
	ld (hl), c
	ld (hl), d
	ld (hl), e
	ld (hl), h
	ld (hl), l
	ld (hl), n

	if ! defined ONLY8080 && ! defined ONLY86
	ld (ix + des), a
	ld (ix + des), b
	ld (ix + des), c
	ld (ix + des), d
	ld (ix + des), e
	ld (ix + des), h
	ld (ix + des), l
	ld (ix + des), n

	ld (iy + des), a
	ld (iy + des), b
	ld (iy + des), c
	ld (iy + des), d
	ld (iy + des), e
	ld (iy + des), h
	ld (iy + des), l
	ld (iy + des), n
	endif

	ld (nn), a

	if ! defined ONLY8080
	ld (nn), bc
	ld (nn), de
	endif

	ld (nn), hl

	if ! defined ONLY8080 && ! defined ONLY86
	ld (nn), ix
	ld (nn), iy
	endif

	if ! defined ONLY8080
	ld (nn), sp
	endif

	ld a, (bc)
	ld a, (de)
	ld a, (hl)

	if ! defined ONLY8080 && ! defined ONLY86
	ld a, (ix + des)
	ld a, (iy + des)
	endif

	ld a, (nn)
	ld a, a
	ld a, b
	ld a, c
	ld a, d
	ld a, e
	ld a, h

	if ! defined ONLY8080 && ! defined ONLY86
	ld a, i
	endif

	ld a, l
	ld a, n

	if ! defined ONLY8080 && ! defined ONLY86
	ld a, r
	endif

	ld b, (hl)

	if ! defined ONLY8080 && ! defined ONLY86
	ld b, (ix + des)
	ld b, (iy + des)
	endif

	ld b, a
	ld b, b
	ld b, c
	ld b, d
	ld b, e
	ld b, h
	ld b, l
	ld b, n

	if ! defined ONLY8080
	ld bc, (nn)
	endif

	ld bc, nn

	ld c, (hl)

	if ! defined ONLY8080 && ! defined ONLY86
	ld c, (ix + des)
	ld c, (iy + des)
	endif

	ld c, a
	ld c, b
	ld c, c
	ld c, d
	ld c, e
	ld c, h
	ld c, l
	ld c, n

	ld d, (hl)

	if ! defined ONLY8080 && ! defined ONLY86
	ld d, (ix + des)
	ld d, (iy + des)
	endif

	ld d, a
	ld d, b
	ld d, c
	ld d, d
	ld d, e
	ld d, h
	ld d, l
	ld d, n

	if ! defined ONLY8080
	ld de, (nn)
	endif

	ld de, nn

	ld e, (hl)

	if ! defined ONLY8080 && ! defined ONLY86
	ld e, (ix + des)
	ld e, (iy + des)
	endif

	ld e, a
	ld e, b
	ld e, c
	ld e, d
	ld e, e
	ld e, h
	ld e, l
	ld e, n

	ld h, (hl)

	if ! defined ONLY8080 && ! defined ONLY86
	ld h, (ix + des)
	ld h, (iy + des)
	endif

	ld h, a
	ld h, b
	ld h, c
	ld h, d
	ld h, e
	ld h, h
	ld h, l
	ld h, n

	ld hl, (nn)
	ld hl, nn

	if ! defined ONLY8080 && ! defined ONLY86
	ld i, a
	endif

	if ! defined ONLY8080 && ! defined ONLY86
	ld ix, (nn)
	ld ix, nn
	ld iy, (nn)
	ld iy, nn
	endif

	ld l, (hl)

	if ! defined ONLY8080 && ! defined ONLY86
	ld l, (ix + des)
	ld l, (iy + des)
	endif

	ld l, a
	ld l, b
	ld l, c
	ld l, d
	ld l, e
	ld l, h
	ld l, l
	ld l, n

	if ! defined ONLY8080 && ! defined ONLY86
	ld r, a
	endif

	if ! defined ONLY8080
	ld sp, (nn)
	endif

	ld sp, hl

	if ! defined ONLY8080 && ! defined ONLY86
	ld sp, ix
	ld sp, iy
	endif

	ld sp, nn

	if ! defined ONLY8080 && ! defined ONLY86
	ldd
	lddr
	ldi
	ldir
	endif

;	NEG

	if ! defined ONLY8080 && ! defined ONLY86
	neg
	endif

;	NOP

	nop

;	OR

	or (hl)

	if ! defined ONLY8080 && ! defined ONLY86
	or (ix + des)
	or (iy + des)
	endif

	or a
	or b
	or c
	or d
	or e
	or h
	or l
	or n

;	OT...

	if ! defined ONLY8080 && ! defined ONLY86
	otdr
	otir
	endif

;	OUT

	if ! defined ONLY8080 && ! defined ONLY86
	out (c), a
	out (c), b
	out (c), c
	out (c), d
	out (c), e
	out (c), h
	out (c), l
	out (n), a
	endif

;	OUTD/I

	if ! defined ONLY8080 && ! defined ONLY86
	outd
	outi
	endif

;	POP

	pop af
	pop bc
	pop de
	pop hl

	if ! defined ONLY8080 && ! defined ONLY86
	pop ix
	pop iy
	endif

;	PUSH

	push af
	push bc
	push de
	push hl

	if ! defined ONLY8080 && ! defined ONLY86
	push ix
	push iy
	endif

;	RES

	if ! defined ONLY8080 && ! defined ONLY86
	res 0, (hl)
	res 0, (ix + des)
	res 0, (iy + des)
	res 0, a
	res 0, b
	res 0, c
	res 0, d
	res 0, e
	res 0, h
	res 0, l

	res 1, (hl)
	res 1, (ix + des)
	res 1, (iy + des)
	res 1, a
	res 1, b
	res 1, c
	res 1, d
	res 1, e
	res 1, h
	res 1, l

	res 2, (hl)
	res 2, (ix + des)
	res 2, (iy + des)
	res 2, a
	res 2, b
	res 2, c
	res 2, d
	res 2, e
	res 2, h
	res 2, l

	res 3, (hl)
	res 3, (ix + des)
	res 3, (iy + des)
	res 3, a
	res 3, b
	res 3, c
	res 3, d
	res 3, e
	res 3, h
	res 3, l

	res 4, (hl)
	res 4, (ix + des)
	res 4, (iy + des)
	res 4, a
	res 4, b
	res 4, c
	res 4, d
	res 4, e
	res 4, h
	res 4, l

	res 5, (hl)
	res 5, (ix + des)
	res 5, (iy + des)
	res 5, a
	res 5, b
	res 5, c
	res 5, d
	res 5, e
	res 5, h
	res 5, l

	res 6, (hl)
	res 6, (ix + des)
	res 6, (iy + des)
	res 6, a
	res 6, b
	res 6, c
	res 6, d
	res 6, e
	res 6, h
	res 6, l

	res 7, (hl)
	res 7, (ix + des)
	res 7, (iy + des)
	res 7, a
	res 7, b
	res 7, c
	res 7, d
	res 7, e
	res 7, h
	res 7, l
	endif

;	RET

	ret
	ret c
	ret m
	ret nc
	ret nz
	ret p
	ret pe
	ret po
	ret z

	if ! defined ONLY8080 && ! defined ONLY86
	reti
	retn
	endif

;	RL

	if ! defined ONLY8080 && ! defined ONLY86
	rl (hl)
	rl (ix + des)
	rl (iy + des)
	rl a
	rl b
	rl c
	rl d
	rl e
	rl h
	rl l
	endif

;	RLA

	rla

;	RLC

	if ! defined ONLY8080 && ! defined ONLY86
	rlc (hl)
	rlc (ix + des)
	rlc (iy + des)
	rlc a
	rlc b
	rlc c
	rlc d
	rlc e
	rlc h
	rlc l
	endif

;	RLCA

	rlca

;	RLD

	if ! defined ONLY8080 && ! defined ONLY86
	rld
	endif

;	RR

	if ! defined ONLY8080 && ! defined ONLY86
	rr (hl)
	rr (ix + des)
	rr (iy + des)
	rr a
	rr b
	rr c
	rr d
	rr e
	rr h
	rr l
	endif

;	RRA

	rra

;	RRC

	if ! defined ONLY8080 && ! defined ONLY86
	rrc (hl)
	rrc (ix + des)
	rrc (iy + des)
	rrc a
	rrc b
	rrc c
	rrc d
	rrc e
	rrc h
	rrc l
	endif

;	RRCA

	rrca

;	RRD

	if ! defined ONLY8080 && ! defined ONLY86
	rrd
	endif

;	RST

	if ! defined MODE86 && ! defined ONLY86
	rst 0
	rst 8
	rst 10h
	rst 18h
	rst 20h
	rst 28h
	rst 30h
	rst 38h
	endif

;	SBC

	sbc a, n
	sbc a, (hl)

	if ! defined ONLY8080 && ! defined ONLY86
	sbc a, (ix + des)
	sbc a, (iy + des)
	endif

	sbc a, a
	sbc a, b
	sbc a, c
	sbc a, d
	sbc a, e
	sbc a, h
	sbc a, l

	if ! defined ONLY8080
	sbc hl, bc
	sbc hl, de
	sbc hl, hl
	sbc hl, sp
	endif

;	SCF

	scf

;	SET

	if ! defined ONLY8080 && ! defined ONLY86
	set 0, (hl)
	set 0, (ix + des)
	set 0, (iy + des)
	set 0, a
	set 0, b
	set 0, c
	set 0, d
	set 0, e
	set 0, h
	set 0, l

	set 1, (hl)
	set 1, (ix + des)
	set 1, (iy + des)
	set 1, a
	set 1, b
	set 1, c
	set 1, d
	set 1, e
	set 1, h
	set 1, l

	set 2, (hl)
	set 2, (ix + des)
	set 2, (iy + des)
	set 2, a
	set 2, b
	set 2, c
	set 2, d
	set 2, e
	set 2, h
	set 2, l

	set 3, (hl)
	set 3, (ix + des)
	set 3, (iy + des)
	set 3, a
	set 3, b
	set 3, c
	set 3, d
	set 3, e
	set 3, h
	set 3, l

	set 4, (hl)
	set 4, (ix + des)
	set 4, (iy + des)
	set 4, a
	set 4, b
	set 4, c
	set 4, d
	set 4, e
	set 4, h
	set 4, l

	set 5, (hl)
	set 5, (ix + des)
	set 5, (iy + des)
	set 5, a
	set 5, b
	set 5, c
	set 5, d
	set 5, e
	set 5, h
	set 5, l

	set 6, (hl)
	set 6, (ix + des)
	set 6, (iy + des)
	set 6, a
	set 6, b
	set 6, c
	set 6, d
	set 6, e
	set 6, h
	set 6, l

	set 7, (hl)
	set 7, (ix + des)
	set 7, (iy + des)
	set 7, a
	set 7, b
	set 7, c
	set 7, d
	set 7, e
	set 7, h
	set 7, l
	endif

;	SLA

	if ! defined ONLY8080 && ! defined ONLY86
	sla (hl)
	sla (ix + des)
	sla (iy + des)
	sla a
	sla b
	sla c
	sla d
	sla e
	sla h
	sla l
	endif

;	SRA

	if ! defined ONLY8080 && ! defined ONLY86
	sra (hl)
	sra (ix + des)
	sra (iy + des)
	sra a
	sra b
	sra c
	sra d
	sra e
	sra h
	sra l
	endif

;	SRL

	if ! defined ONLY8080 && ! defined ONLY86
	srl (hl)
	srl (ix + des)
	srl (iy + des)
	srl a
	srl b
	srl c
	srl d
	srl e
	srl h
	srl l
	endif

;	SUB

	sub (hl)

	if ! defined ONLY8080 && ! defined ONLY86
	sub (ix + des)
	sub (iy + des)
	endif

	sub a
	sub b
	sub c
	sub d
	sub e
	sub h
	sub l
	sub n

;	XOR

	xor (hl)

	if ! defined ONLY8080 && ! defined ONLY86
	xor (ix + des)
	xor (iy + des)
	endif

	xor a
	xor b
	xor c
	xor d
	xor e
	xor h
	xor l
	xor n

this_is_the_end:	end

;	End of all.asm
