;	jumptable.asm
;	Test of ## operator.

	org 100h

bdos	equ 5

conin	equ 1
pstring	equ 9

start	jp init

jpfunc	macro nfunc
	jp function_ ## nfunc
	endm

table:
	irp func, mess1, mess2, presskey, endline
	jpfunc func
	endm

print	ld c, pstring
	jp bdos

init
	if 0

	rept 3, nfunc
	ld a, nfunc
	call usefunc
	endm

	else

	rept 3, nfunc, 2, -1
	ld a, nfunc
	call usefunc
	endm

	endif

	ld a, 3
	call usefunc

	ld c, 0
	call bdos

usefunc
	ld b, a
	add a, a
	add a, b
	ld c, a
	ld b, 0
	ld hl, table
	add hl, bc
	push hl
	ret

function_mess1	proc
	local message

	ld de, message
	call print
	ret

message	db "Hello, world\r\n$"

	endp

function_mess2	proc
	local message

	ld c, pstring
	ld de, message
	jp bdos

message	db 'Have a nice day', 0Dh, 0Ah, '$'

	endp

function_presskey	proc
	local message

	ld c, pstring
	ld de, message
	call bdos
	ld c, conin
	call bdos
	ret

message	db 'Press any key...$'

	endp

function_endline	proc
	local message

	ld de, message
	jp print

message	db 0Dh, 0Ah, '$'

	endp

	end start

;	End of jumptable.asm
