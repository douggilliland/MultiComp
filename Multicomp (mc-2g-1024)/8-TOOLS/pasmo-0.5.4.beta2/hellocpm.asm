;	hellocpm.asm

;	(C) 2004 Julian Albo.
;	This code may be freely used.

;	Simple hello world for cp/m, showing the use of some
;	pasmo options to adapt cp/m programs for cp/m 86 or
;	ms-dos.

;	Assembly with:
;	- For cp/m:
;		pasmo hellocpm.asm HELLOCPM.COM
;	- For cp/m 86:
;		pasmo --86 --cmd --equ CPM86 hellocpm.asm HELLOCPM.CMD
;	- For ms-dos:
;		pasmo --86 --equ MSDOS hellocpm.asm HELLOCPM.COM

;	This macro allows to easily adapt the program to run
;	in ms-dos or cp/m 86, using the --86 option and, in
;	the case of cp/m 86, the --cmd option.
;	The MSDOS is really not needed, ms-dos can handle
;	call 5 use, but under dosemu this does not work,
;	I still don't know why. Defining MSDOS it runs in any
;	dos clone.

BDOS_CALL	macro

	if defined CPM86
	db 0CDh, 0E0h	; int 0E0h, bdos call in cp/m 86
	else
	if defined MSDOS
	db 088h, 0CCh	; mov ah, cl
	db 0CDH, 021h	; int 0CDh, ms-dos call.
	else
	call 5
;	endif

;	endif

	endm	; BDOS_CALL

;	Some cp/m values.

CPM_TPA		equ 0100h
SYSTEM_RESET	equ 0
PRINT_STRING	equ 9

;	Main program.

	org CPM_TPA

	ld de, hello
	ld c, PRINT_STRING
	BDOS_CALL
	ld c, SYSTEM_RESET
	BDOS_CALL

;	Variables.

hello	db 'Hello, world.', 0Dh, 0Ah, '$'

	end

; End of hellocpm.asm
