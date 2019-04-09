* Test program for RTL simulation of multicomp paging register
* Test ROM disable.

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
* The external RAM has 16, 8K regions numbered 0-F.
* at reset, the mapper register holds 0x76 so that cpu address 0xC000-0xDFFF map to
* region 6 and cpu address 0xE000-FFFF map to region 7.
* - Remap the CD address space to region 7
* - Copy the ROM to CD address space
* - Remap the CD address space (back to) region 6
* - Disable the ROM (the region 6 copy should appear and should
*   transparently take over)

        LDA #$77
        STA MAPPER

        LDY #30                 ; byte count to move
        LDX #$E000              ; from
COPY    LDA ,X
        STA -$2000,X            ; -2000 to get to 0xC000

        LEAX 1,X
        LEAY -1,Y
        BNE COPY

        LDA #$76
        STA MAPPER

        LDA #$1
        STA ROMDIS

* Now do something to show we're alive
* (Actually, there is no external RAM in the testbench so
* there is nothing to fetch code from.)
FOREVER
        ADDA #$1
        STA 0
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
LBFF0     FDB  $0000          ; RESERVED
LBFF2     FDB  SW3VEC         ; SWI3
LBFF4     FDB  SW2VEC         ; SWI2
LBFF6     FDB  FRQVEC         ; FIRQ
LBFF8     FDB  IRQVEC         ; IRQ
LBFFA     FDB  SWIVEC         ; SWI
LBFFC     FDB  NMIVEC         ; NMI
LBFFE     FDB  RESVEC         ; RESET
