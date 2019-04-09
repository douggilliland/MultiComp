* Test program for RTL simulation of multicomp VDU line-insert
* bug. If you do a line insert, the bottom part of the screen
* gets corrupted with a single character repeated.

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

* VDU Data
UARTDAT   EQU $FFD1
UARTSTA   EQU $FFD0

          ORG  $E000
RESVEC
          LDX #MSG1
NXTCHR    LDA ,X               ; get char
          BEQ MSGDONE

BIZWAIT   LDB UARTSTA
          BITB #2
          BEQ BIZWAIT

          STA UARTDAT
          LEAX 1,X
          BRA NXTCHR
MSGDONE

FOREVER
          BRA FOREVER


MSG1      FCC '1'               ; identify each line
          FCB $0A,$0D
          FCC '2'
          FCB $0A,$0D
          FCC '3'
          FCB $0A,$0D
          FCC '4'
          FCB $0A,$0D
          FCC '5'
          FCB $0A,$0D
          FCC '6'
          FCB $0A,$0D
          FCC '7'
          FCB $0A,$0D
          FCC '8'
          FCB $0A,$0D
          FCC '9'
          FCB $0A,$0D
          FCC 'A'
          FCB $0A,$0D
          FCC 'B'
          FCB $0A,$0D
          FCC 'C'
          FCB $0A,$0D
          FCC 'D'
          FCB $0A,$0D
          FCC 'E'
          FCB $0A,$0D
          FCC 'F'
          FCB $0A,$0D
          FCC 'G'
          FCB $0A,$0D
          FCC 'H'
          FCB $0A,$0D
          FCC 'I'
          FCB $0A,$0D
          FCC 'J'
          FCB $0A,$0D
          FCC 'K'
          FCB $0A,$0D
          FCC 'L'
          FCB $0A,$0D
          FCC 'M'
          FCB $0A,$0D
          FCC 'N'
          FCB $0A,$0D
          FCC 'O'
          FCB $0A,$0D
          FCC 'P'
        ;; go to 3,1 (row 3 column 1) ESC [ 3 ; 1 H
          FCB $1B,$5B,$33,$3B,$31,$48
        ;; do a line insert ESC [ L
          FCB $1B,$5B,$4C
          FCC 'HELLO'
          FCB 00



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
