********************************************************************
* I/O SPACE DEFINES FOR MULTICOMP
*
* 16 locations $FFD0-$FFDF
*
* For programming information, refer to:
* https://github.com/nealcrook/multicomp6809/wiki/Programming-guide
*
********************************************************************


********************************************************************
* VDU/KBD
UARTSTA        EQU $FFD0
UARTDAT        EQU $FFD1

UART2STA       EQU $FFD2
UART2DAT       EQU $FFD3

UART3STA       EQU $FFD4
UART3DAT       EQU $FFD5


********************************************************************
* GPIO CONTROL REGISTERS
GPIOADR        EQU $FFD6
GPIODAT        EQU $FFD7

* values supported by GPIOADR register
GPDAT0         EQU 0
GPDDR1         EQU 1
GPDAT2         EQU 2
GPDDR3         EQU 3


********************************************************************
* SDCARD CONTROL REGISTERS
SDDATA         EQU $FFD8
SDCTL          EQU $FFD9
SDLBA0         EQU $FFDA
SDLBA1         EQU $FFDB
SDLBA2         EQU $FFDC


********************************************************************
* 50Hz TIMER INTERRUPT
* TIMER (READ/WRITE)
*
* AT RESET, THE TIMER IS DISABLED AND THE INTERRUPT IS DEASSERTED. TIMER READS AS 0.
* BIT[1] IS READ/WRITE, TIMER ENABLE.
* BIT[7] IS READ/WRITE-1-TO-CLEAR, INTERRUPT.
*
* IN AN ISR THE TIMER CAN BE SERVICED BY PERFORMING AN INC ON ITS ADDRESS
*
* READ  WRITE  COMMENT
*  N/A   $02   ENABLE TIMER
*  $00   $01   TIMER WAS/REMAINS DISABLED. N=0.
*  $02   $03   TIMER WAS/REMAINS ENABLED, NO INTERRUPT. N=0.
*  $80   $81   TIMER WAS/REMAINS DISABLED, OLD PENDING INTERRUPT CLEARED. N=1.
*  $82   $83   TIMER WAS/REMAINS DISABLED, OLD PENDING INTERRUPT CLEARED. N=1.
*
TIMER          EQU $FFDD


********************************************************************
* MEM_MAPPER2 CONTROL REGISTERS
* MMUADR (WRITE-ONLY)
* 7   - ROMDIS (RESET TO 0)
* 6   - TR
* 5   - MMUEN
* 4   - RESERVED
* 3:0 - MAPSEL
* MMUDAT (WRITE-ONLY)
* 7   - WRPROT
* 6:0 - PHYSICAL BLOCK FOR CURRENT MAPSEL

MMUADR         EQU $FFDE
MMUDAT         EQU $FFDF



