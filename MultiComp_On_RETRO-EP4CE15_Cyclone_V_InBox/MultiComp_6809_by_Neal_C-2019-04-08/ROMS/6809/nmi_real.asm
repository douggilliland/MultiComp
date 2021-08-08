* Type-in test program for trying multicomp NMI single-step logic on
* real hardware: type in and execute under the control of BUGGY
*
* Test1: type in as-is. G2000 to execute. It should return to
* the BUGGY prompt. D2069 to see final register state. Expect
* to see A incremented (By first instruction at RESUME) and
* PC incremented.
*
* Test2: A205A and enter LDY 8,S <return> . <return
* G2000 to execute. It should return to
* the BUGGY prompt. D2069 to see final register state. Expect
* to see A still at 55, value of Y changed and PC incremented
* by 3 (address of next instruction after 3-byte "LDY 8,S".

* Control register: bit 4 generates NMI.
MMUADR  EQU $FFDE

* Type in code at this address.
        ORG $2000

* On entry, S is set up as the stack pointer for BUGGY

* Link in to BUGGY NMI vector
        LDX  #NMI
        STX  $E290

* Build processor state on stack
        LDY  #RESUME
        PSHS Y      * PCL, PCH: Return address
        LDX  #INITIAL
        LDY  ,X++
        PSHS Y      * UL,  UH
        LDY  ,X++
        PSHS Y      * YL,  YH
        LDY  ,X++
        PSHS Y      * XL,  XH
        LDY  ,X++
        PSHS Y      * DP,  B
        LDY  ,X++
        PSHS Y      * A,   CC

* Now the stack looks like this:
*
* $80   * CC -- with ENTIRE bit set <-- STACK PTR
* $55   * A
* $AA   * B
* $06   * DP   |
* $DE   * XH   | S increments
* $AD   * XL   v
* $BE   * YH
* $EF   * YL
* $CA   * UH
* $FE   * UL
* $xx   * PCH - high byte of "RESUME" address
* $yy   * PCL - low byte of "RESUME" address

        LDA #$10    * bit 4 set
        STA MMUADR  * trigger the NMI
* should execute RTI and 1 instruction at the stacked PC then
* take the NMI
        RTI

* never come back.. but just in case.
ELOOP1  BRA ELOOP1

* NMI Service routine. Processor state is on the
* stack. If all went well, we will see PC incremented
* and A incremented.
NMI     LDX  #FINAL
        LDY  0,S
        STY  ,X++   * CC A
        LDY  2,S
        STY  ,X++   * B DP
        LDY  4,S
        STY  ,X++   * X
        LDY  6,S
        STY  ,X++   * Y
        LDY  8,S
        STY  ,X++   * U
        LDY  10,S
        STY  ,X++   * PC
* If we did an RTI now it would go back to the instruction
* of the stacked PC ie RESUME+1. Instead, go back to BUGGY
        JMP  $e409

* This is the code sequence to be executed
RESUME  INCA            * Should only execute this instruction
        INCA
        INCA
ELOOP2  BRA ELOOP2    * Should never get here

* Initial processor state.
INITIAL FCB $CA   * UH
        FCB $FE   * UL
        FCB $BE   * YH
        FCB $EF   * YL
        FCB $DE   * XH
        FCB $AD   * XL
        FCB $AA   * B
        FCB $06   * DP
        FCB $80   * CC -- with ENTIRE bit set
        FCB $55   * A

* Final processor state (gets written here)
FINAL   FCB $00   * CC  expect 80
        FCB $00   * A          56 (55 incremented)
        FCB $00   * B          AA
        FCB $00   * DP         06
        FCB $00   * XH         DE
        FCB $00   * XL         AD
        FCB $00   * YH         BE
        FCB $00   * YL         EF
        FCB $00   * UH         CA
        FCB $00   * UL         FE
        FCB $00   * PCH        20
        FCB $00   * PCL        5B (205A incremented)
