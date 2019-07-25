* Test program for RTL simulation of multicomp SDcontroller

* Paging control registers
WPROT     EQU $FFDD
ROMDIS    EQU $FFDE
MAPPER    EQU $FFDF

* SDCARD control registers
SDDATA    EQU $FFD8
SDCTL     EQU $FFD9
SDLBA0    EQU $FFDA
SDLBA1    EQU $FFDB
SDLBA2    EQU $FFDC


* Start address of the two pageable regions
REGCD     EQU $C000
REGEF     EQU $E000


          ORG  $E000
RESVEC


* Wait for SDCARD to initialise
WAITI1
        LDA SDCTL
        BITA #$10
        BNE WAITI1

* Reinitialise as high_capacity card
        LDA #$82
        STA SDCTL      Issue the read

* Wait for SDCARD to initialise
WAITI2
        LDA SDCTL
        BITA #$10
        BNE WAITI2

* Issue SDCARD read
        LDA #$0
        STA SDLBA0     Select block 0
        STA SDLBA0
        STA SDLBA0
        STA SDCTL      Issue the read

* Wait for data available
        LDX #$512               ; count
        LDY #$4000              ; where to put it
WAITD   LDA SDCTL
        BITA #$40
        BEQ WAITD               ; not ready yet
        LDA SDDATA
        STA ,Y+
        LEAX -1,X
        BNE WAITD



* In response should see activity on the interface
* - clocking and chip select.






* Test with reset values
        LDA #$55
        LDB #$11
        STA REGCD
        LDA REGCD
        STA REGEF
        LDA REGEF
        STB MAPPER            Move regions
        STA REGCD
        LDA REGCD
        STA REGEF
        LDA REGEF
        ADDB #$11
        STB MAPPER            Move regions
        STA REGCD
        LDA REGCD
        STA REGEF
        LDA REGEF
        ADDB #$11
        STB MAPPER            Move regions
        STA REGCD
        LDA REGCD
        STA REGEF
        LDA REGEF


* Protect the top 2 8k sections
        LDB #$C0
        STB WPROT

* The write should be inhibited
        STA REGCD
        LDA REGCD
        STA REGEF
        LDA REGEF

* Disable the ROM. Misery should ensue
        LDB #1
        STB ROMDIS



* Relocatable code fragment for bootstrap of boot loader
* copy this to RAM then jump to it in order to NOT be
* executing from ROM when ROM is disabled.
* Disable the ROM. Misery should ensue
        LDA #$A0
        STA ROMDIS
        JMP [$FFFE]

* Relocatable code fragment for bootstrap of boot loader
* copy this to RAM then jump to it in order to NOT be
* executing from ROM when ROM is disabled.
* Disable the ROM. Misery should ensue
        LDA #1
        STA ROMDIS
        JMP $F800


FOREVER
        BRA FOREVER

SW3VEC
SW2VEC
FRQVEC
IRQVEC
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
