* Test program for RTL simulation of multicomp timer interrupt
* assumes mem_mapper2
*
* assumes no RAM in simulation environment so can never return
* from interrupt!

* Paging control registers
TIMER     EQU $FFDD
MMUADR    EQU $FFDE
MMUDAT    EQU $FFDF

* SDCARD control registers
SDDATA    EQU $FFD8
SDCTL     EQU $FFD9
SDLBA0    EQU $FFDA
SDLBA1    EQU $FFDB
SDLBA2    EQU $FFDC


* Start address of logical blocks
LBLK01    EQU $0000
LBLK23    EQU $2000
LBLK45    EQU $4000
LBLK67    EQU $6000
LBLK89    EQU $8000
LBLKAB    EQU $A000
LBLKCD    EQU $C000
LBLKEF    EQU $E000


          ORG  $E000
RESVEC


* Wait for SDCARD to initialise
WAITI1
*        LDA SDCTL
*        BITA #$10
*        BNE WAITI1

* Do a store to each region with MMU disabled (reset state)
        LDA #$55
        STA LBLK01
        STA LBLK23
        STA LBLK45
        STA LBLK67
        STA LBLK89
        STA LBLKAB
        STA LBLKCD
        STA LBLKEF      ROM

* INITIALISE THE MEMORY MAPPER
        LDD #$0000
        STD MMUADR
        ADDD #$0101
        STD MMUADR
        ADDD #$0101
        STD MMUADR
        ADDD #$0101
        STD MMUADR
        ADDD #$0101
        STD MMUADR
        ADDD #$0101
        STD MMUADR
        ADDD #$0101
        STD MMUADR
        ADDD #$0101
        STD MMUADR
        ADDD #$0101

* ENABLE MMU
        LDA #$20
        STA MMUADR

* STORES USING MMU
        LDA #$55
        STA LBLK01
        STA LBLK23
        STA LBLK45
        STA LBLK67
        STA LBLK89
        STA LBLKAB
        STA LBLKCD
        STA LBLKEF      ROM

* PROTECT SECTION 45 - AND SHOW THAT THIS CAN BE DONE WITHOUT
* DISABLING MMU
        LDD #$2484      BLK4 ie LBLK89
        STD MMUADR
        LDA #$55
        STA LBLK01
        STA LBLK23
        STA LBLK45
        STA LBLK67
        STA LBLK89      WRITE SHOULD BE INHIBITED
        STA LBLKAB

* ENABLE TIMER INTERRUPT
        LDS #$2000
        ANDCC #%11101111  ENABLE INTERRUPT
        LDA #1
        STA TIMER

* WAIT FOREVER
LOOP    JMP LOOP
        NOP
        NOP

IRQVEC  INC TIMER
* SHOULD SEE NO EFFECT FROM SUBSEQUENT INC UNTIL INTERRYUPT FIRES AGAIN
        INC TIMER
        INC TIMER
        INC TIMER
        RTI     NO RAM SO MISERY WILL ENSUE





FOREVER
        BRA FOREVER

SW3VEC
SW2VEC
FRQVEC
SWIVEC
NMIVEC
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
