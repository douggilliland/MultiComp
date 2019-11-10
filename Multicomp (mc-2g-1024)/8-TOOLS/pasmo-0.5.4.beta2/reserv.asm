	org 100h
nn	equ 1
add$:	nop
	jr add$

	ld b, (1)
	add a,(nn)
	add a,(add$)
	or (nn)
