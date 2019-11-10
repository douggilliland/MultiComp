	org 33000

KM_WAIT_CHAR	equ #BB06

TXT_INITIALISE	equ #BB4E
TXT_VDU_ENABLE	equ #BB54
TXT_OUTPUT	equ #BB5A
TXT_CUR_ENABLE	equ #BB7B
TXT_SET_PEN	equ #BB90
TXT_CUR_ON	equ #BB81

MC_START_PROGRAM	equ #BD16

start

	if 0

	ld hl, program
	ld c, 0
	call MC_START_PROGRAM

	endif

program

	if 0

	call TXT_INITIALISE
	call TXT_VDU_ENABLE

	ld a,1
	call TXT_SET_PEN

	endif

	ld bc,1010h
another

	push bc

	ld hl,hello
again	ld a,(hl)
	cp 0
	jr z, exit
	push hl

	call TXT_OUTPUT

	pop hl
	inc hl
	jr again

exit
	pop bc
	djnz another

	;call TXT_CUR_ENABLE
	call TXT_CUR_ON

	call KM_WAIT_CHAR

	ret

hello	db "Hello, Amstrad CPC world.", 0Dh, 0Ah, 0

	end start
