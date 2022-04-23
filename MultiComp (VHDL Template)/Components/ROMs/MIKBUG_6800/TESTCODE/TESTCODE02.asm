; TESTCODE02.ASM
; Douglas Gilliland 2022
;
; Read a char from VDU/ACIA, write a char to VDU/ACIA
; Uses MIKBUG routines INEEE and OUTEEE serial read routines
; Load program in MIKBUG (SmithBug) using & command
;
; Run toolchain in DOS window - assembler
;	..\a68.exe TESTCODE02.ASM -l TESTCODE02.LST -s TESTCODE02.s
; To make a hex file that can be loaded
;	..\srec_cat TESTCODE02.s -offset - -minimum-addr TESTCODE02.s -o TESTCODE02.hex -Intel

INEEE	EQU $f1f3
OUTEEE	EQU $f20a
ECHO	EQU $f47d

START	
			ORG	$0000
		LDA A	ECHO
		PSH	A
		LDA A	#0
		STA A 	ECHO
LBACK
		JSR		INEEE
		JSR		OUTEEE
		JMP		LBACK
