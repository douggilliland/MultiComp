;	fill8k.asm
;
; Generate a file of some size, useful for testing.
; Shows the use of some operators and directives.
;

	if 0	; This is for pasmo testing.

	else

fill256	macro

	local n
n	defl 0

	rept 256
	db n
n	defl n + 1
	endm

	endm

	endif

fill1k	macro

	rept 4
	fill256
	endm

	endm

filln	macro n

	local j
j	defl 0
	rept n
	db j
j	defl (j + 1) mod 256
	endm

	endm

init:	rept 8
	fill1k
	endm

	if 1	; This is for pasmo testing.

	if defined SOMEMORE && SOMEMORE != 0
	filln SOMEMORE
	endif

	else

	if defined SOMEMORE && SOMEMORE != 0

	proc

	local j
j	defl 0
	rept SOMEMORE
	db j
j	defl (j + 1) mod 256
	endm

	endp

	endif

	endif

; End of fill8k.asm
