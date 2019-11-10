;	alocal.asm
; Test of autolocal mode in CP/M.

bdos	equ 5
conout	equ 2

start	org 100h

	jp _hola

_exit	db "Good morning.\r\n", 0

_hola	ld hl, _exit
	call showtext

	jp hola

showtext

_hola	ld a, (hl)
	cp 0
	jp z, _exit
	push hl
	ld e, a
	ld c, conout
	call bdos
	pop hl
	inc hl
	jp _hola

_exit	ret

hola	ld hl, _exit
	call showtext
	jp 0

_exit	db "Hello, autolocal world\r\n", 0

	end start
