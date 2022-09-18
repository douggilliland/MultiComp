* Test program for RTL simulation of multicomp NMI single-step logic


* Paging control registers
TIMER      EQU $FFDD
MMUADR     EQU $FFDE
MMUDAT     EQU $FFDF

****************************************
* Start of ROM. Come here from reset
          ORG  $E000
****************************************
RESVEC


* Initialise stack
        LDS #INITSP
        NOP
        NOP
        NOP
        LDA #$10    * bit 4 set
        STA MMUADR  * trigger the NMI
        RTI         * should execute this and 1 instruction at the stacked PC
*                   * then take the NMI

        NOP         * should come here on return from NMI (but not in this test
*                   * program as we have no RAM stack!)
        NOP
        NOP
        NOP
NEVER   BRA NEVER



*************************************************
*** This is our pretend stack, that is really in ROM
*** on PUL, read value at INITSP first.

INITSP
          FCB $80   * CC -- with ENTIRE bit set <- STACK PTR
          FCB $55   * A
          FCB $AA   * B
          FCB $06   * DP
          FCB $DE   * XH
          FCB $AD   * XL
          FCB $BE   * YH
          FCB $EF   * YL
          FCB $CA   * UH
          FCB $FE   * UL
          FCB $FE   * PCH - where to resume
          FCB $ED   * PCL

*************************************************
*** This is the instruction stream that should get executed
*** ..or rather, the first instruction should.
*** try some different instructions here, particularly
*** some multi-byte and multi-cycle instructions.
*************************************************

          ORG $FEED
          MUL
          INCA
          INCB
LOOP      BRA LOOP


*************************************************
*** Come here on NMI. Should end up having executed 1 instruction
*** at the target address and then pushed the machine state onto
*** the stack. Unfortunately, in this simulation environment we
*** don't actually have any RAM so the "push" writes to ROM
*** and we can't go back.
***
*************************************************
NMIVEC
* Show register values on the data bus
        STA 0
        STB 0
        STU 0
        STS 0
        STX 0
        STY 0
        BRA NMIVEC



FOREVER
        BRA FOREVER

SW3VEC
SW2VEC
FRQVEC
IRQVEC
SWIVEC
        BRA SW3VEC

* Exception vectors
          ORG  $FFF0
LBFF0     FDB  $0000          RESERVED
LBFF2     FDB  SW3VEC         SWI3
LBFF4     FDB  SW2VEC         SWI2
LBFF6     FDB  FRQVEC         FIRQ
LBFF8     FDB  IRQVEC         IRQ
LBFFA     FDB  SWIVEC         SWI
LBFFC     FDB  NMIVEC         NMI
LBFFE     FDB  RESVEC         RESET
