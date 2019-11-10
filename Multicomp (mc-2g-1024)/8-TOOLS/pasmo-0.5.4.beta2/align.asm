;	align.asm
;	(C) 2004 Julian Albo
;	This code may be freely used.

;--------------------------------------------------------------------
; Sample of macro that can be used to align the current position to
; a multiple of some number, like the align and aligndata directives
; of some oher assemblers.
;--------------------------------------------------------------------

align	macro n

	local newpos, oldpos
oldpos	equ $
newpos	equ (oldpos + n - 1) / n * n

	if newpos < oldpos
	.error Align out of memory
	endif

; The second method is faster, the first can be used to align code
; in 8086 generation mode (code of NOP is not 00).
; If align of data and code is needed can be better to define another
; macro called aligndata.

	if defined ALIGN_WITH_NOP

	rept newpos - oldpos
	nop
	endm

	else

	org newpos

	endif

	endm	; align

;--------------------------------------------------------------------
;			Test program.
;--------------------------------------------------------------------

	org 100h	; To view the result with a cp/m debugger.

	ld a, a
	align 8
	ld a, b
	ld a, c
	ld a, d
	align 64
	align 16	; Do nothing, already aligned.
	ld a, e

	if defined TESTERROR

	org 0E000h
	ld a, h
	align 16384	; Must generate an error.
	ld a, l

	endif

	end

;--------------------------------------------------------------------
; End of align.asm
