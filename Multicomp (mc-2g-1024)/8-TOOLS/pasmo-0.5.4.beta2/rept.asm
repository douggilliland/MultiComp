;	rept.asm
; Test of rept and irp directives.

; Macro with rept and irp inside.
hola	macro
	local unused, unused2

unused	rept 2
	db 'Rept inside macro', 0
	endm

unused2	irp ?reg, af,bc, de, hl
	push ?reg
	endm

	endm	; hola

;-------------------------------------

	rept 10
	db 'Hello, reptworld'
	endm

	rept 3

; Rept with calculated end condition.
n	defl 1
	rept 0FFFFh

n	defl n + 2

	if n gt 10
	exitm
	endif

	rept 4
	db n
	endm

	endm

	endm

; Macro call inside rept.
	rept 2
	hola
	endm

;	New syntax.

counter	equ 1234h

	; With counter (initial value 0 and step 1 assumed):
	rept 3, counter
	db counter
	endm

	; With counter and initial value (step 1 assumed):
	rept 3, counter, 5
	db counter
	endm

	; With counter, initial value and step:
	rept 3, counter, 7, -1
	db counter
	endm

	; Testing that counter was local:
	defw counter

	end
