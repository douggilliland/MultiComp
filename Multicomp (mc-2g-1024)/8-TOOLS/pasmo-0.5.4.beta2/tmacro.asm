;	tmacro.asm
;	Some tests of macro usage.

	org 100h	; To run in cp/m

start:

macro	bdos, function

	ld c, function
	call 5

	endm

lineend	macro
	ld e, 0Dh
	bdos 2
	ld e, 0Ah
	bdos 2

	endm

macro	pushall
	push af
	push bc
	push de
	push hl

	endm

popall	macro
	pop hl
	pop de
	pop bc
	pop af

	endm

;	Another way.

pall	macro operation

	irp reg, af, bc, de, hl
	local i1
	operation reg
	endm

	endm

pushall2	macro

	pall push

	endm

popall2	macro


	irp reg, af, bc, de, hl
	pop reg
	endm

	endm

;	Yet another way

pushmany	macro reg

	rept -1
	if nul reg
	exitm
	endif
	push reg
	.shift
	endm

	endm

pushall3	macro
	pushmany af, bc, de, hl
	endm

;	Main program

;	pushall
;	pushall2
	pushall3

	ld de, hello
i1	bdos 9
i2:	lineend

	;popall
	popall2

	bdos 0

hello	db 'Hello, world.$'

	end start

; End of tmacro.asm
