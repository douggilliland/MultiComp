* Test program for RTL simulation of multicomp UART
* Remember: NO EXTERNAL RAM OR STACK IS AVAILABLE IN
* RTL simulation!!


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

* UART
UARTDAT   EQU $FFD3
UARTSTA   EQU $FFD2

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


MSG1
          FCB $AA,$55
          FCB $81,$81,$81,$81,$7E,$7E,$7E,$7E
          FCB $00



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
