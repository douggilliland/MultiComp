	org 30000

tv_flag	equ 5C3Ch

start
	; Directs rst 10h output to main screen.
	xor a
	ld (tv_flag),a

	ld b, 50

another

	push bc

	ld hl,hello
again	ld a,(hl)
	cp 0
	jr z, exit
	push hl
	rst 10h
	pop hl
	inc hl
	jr again

exit
	pop bc
	djnz another
	ret

hello	db "Hello, world.", 0Dh, 0

	end start
