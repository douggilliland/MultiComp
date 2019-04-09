* Test program for RTL simulation of multicomp gpio unit
*
*
* assumes no RAM in simulation environment so can never take subroutine
* calls!

* GPIO control registers
GPIOADR   EQU $FFD6
GPIODAT   EQU $FFD7

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

* All GPIO registers default to 0
* which means we select data register 0 and all bits
* are outputs.

        LDA #$7
        STA GPIODAT         All 3 port0 pins go hi
        LDA #$5             Bit 1 goes low
        STA GPIODAT
        CLRA
        STA GPIODAT         All bits low
        LDA #$2
        STA GPIOADR         Select port2 data
        LDA #$FF
        STA GPIODAT         All 8 port2 bits go hi
        LDA #$AA
        STA GPIODAT
        LDA #$55
        STA GPIODAT
        LDA #$00
        STA GPIODAT

        LDA #$3
        STA GPIOADR         DDR for port2
        LDA #$F0
        STA GPIODAT         Top nibble of port2 is now input
        LDA #$2
        STA GPIOADR         Select port2 data
        LDA #$FF
        STA GPIODAT         Should only affect bottom nibble
        LDA #$AA
        STA GPIODAT

        LDA GPIODAT         Should see X on upper nibble, 1010 on lower.
        LDA GPIODAT         Should see X on upper nibble, 1010 on lower.
        LDA GPIODAT         Should see X on upper nibble, 1010 on lower.


HERE    BRA HERE





FOREVER
        BRA FOREVER

IRQVEC
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
