	org 100h
;	include.asm

	nop
	include if.asm
	halt
	include if.asm
	ex de,hl
	exx
	ex af, af'

	end
