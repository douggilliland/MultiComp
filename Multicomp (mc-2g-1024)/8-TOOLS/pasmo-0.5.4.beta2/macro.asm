;	macro.asm
; Test of MACRO and ENDM directives.
; Following a sample of the documentation of Digital Research MAC.
; For use with CP/M.

reboot	equ 0
tpa	equ 100h
bdos	equ 5
type	equ 2
cr	equ 0Dh
lf	equ 0Ah

_hola

chrout	macro
	ld c, type
	call bdos
	endm

typeout	macro ?message
	local pastsub
	jp pastsub
msgout:	ld e, (hl)
	ld a, e
	or a
	ret z
	inc hl
	push hl
	chrout
	pop hl
	jp msgout
pastsub:

; Redefine the typeout macro after the first invocation.
typeout	macro ??message
	local tymsg
	local pastm
	ld hl, tymsg
	call msgout
	jp pastm
tymsg:	db ??message, cr, lf, 0
pastm:
	endm

	typeout ?message

	endm

	org 100h

	typeout "Hello, \"macro\" world"

	typeout "\x30\7"

	typeout 'That''s all folks!'

	jp reboot

	end
