q	equ 1
qq	equ 1
qqq	equ 1
qqqq	equ 1
qqqqq	equ 1
qqqqqq	equ 1
qqqqqqq	equ 1
qqqqqqqq	equ 1
qqqqqqqqq	equ 1
qqqqqqqqqq	equ 1
qqqqqqqqqqq	equ 1
qqqqqqqqqqqq	equ 1
qqqqqqqqqqqqq	equ 1
qqqqqqqqqqqqqq	equ 1
qqqqqqqqqqqqqqq	equ 1
qqqqqqqqqqqqqqqq	equ 1
qqqqqqqqqqqqqqqqq	equ 1

	db 1
	db 1, 2
	db 1, 2, 3
	db 1, 2, 3, 4
	db 1, 2, 3, 4, 5
	db 1, 2, 3, 4, 5, 6
	db 1, 2, 3, 4, 5, 6, 7
	db 1, 2, 3, 4, 5, 6, 7, 8
	db 1, 2, 3, 4, 5, 6, 7, 8, 9

	dw 1
	dw 1, 2
	dw 1, 2, 3
	dw 1, 2, 3, 4
	dw 1, 2, 3, 4, 5
	dw 1, 2, 3, 4, 5, 6
	dw 1, 2, 3, 4, 5, 6, 7
	dw 1, 2, 3, 4, 5, 6, 7, 8
	dw 1, 2, 3, 4, 5, 6, 7, 8, 9

	proc

	local n
n	defl 0

	rept 20
	ds n
n	defl n + 1
	endm

	endp
