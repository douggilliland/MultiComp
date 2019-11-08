*******************************************************************
* FLEX DRIVERS FOR MULTICOMP6809 SYSTEM
*
* CONSOLE I/O DRIVER PACKAGE FOR MULTICOMP VDU
*
* Neal Crook May2015. Based on Appendix G of 6809 FLEX Adaption Guide
*
* MOVED THE JUMP TABLE FROM THE START OF THE SOURCE TO THE END
* SO THAT THE ADDRESSES WERE SEQUENTIAL (REMOVED ONE WARNING FROM
* THE FLOW TO BINARY)
*******************************************************************

* MULTICOMP I/O REGISTERS FOR VDU TERMINAL
UARTDAT        EQU $FFD1
UARTSTA        EQU $FFD0

* FLEX ENTRY POINT FOR WARM START
FLEXWRM        EQU $CD03

               ORG $D370

*******************************************************************
* SUBROUTINE INIT
*
* INITIALIZE HARDWARE
* FOR MULTICOMP, THERE IS NOTHING TO DO. BESIDES, THE TERMINAL
* WAS ALREADY INITIALIZED BY THE BOOT LOADER
INIT           RTS


*******************************************************************
* SUBROUTINE INNECH
*
* WAIT FOR CHARACTER, NO ECHO
* ALLOWED TO DESTROY A, CC
INNECH         LDA  UARTSTA     VDU/UART STATUS
               BITA #1          CHARACTER AVAILABLE?
               BEQ  INNECH      NOT YET..
               LDA  UARTDAT     CHARACTER
               ANDA #$7F        STRIP PARITY
               RTS


*******************************************************************
* SUBROUTINE INPUT
*
* WAIT FOR CHARACTER, ECHO. CALLS INNECH THEN FALLS THROUGH TO
* SUBROUTINE OUTPUT.
* ALLOWED TO DESTROY A, CC
INPUT          BSR   INNECH

* PUT NO CODE HERE!! ROUTINE ABOVE FALLING THROUGH!!


*******************************************************************
* SUBROUTINE OUTPUT
*
* OUTPUT CHARACTER IN A
* ALLOWED TO DESTROY CC
OUTPUT         PSHS  A          SAVE CHARACTER
OUTPU2         LDA  UARTSTA     VDU/UART STATUS
               BITA #2
               BEQ OUTPU2       BUSY
               PULS  A          GET CHARACTER BACK
               STA  UARTDAT     OUTPUT IT
               RTS

*******************************************************************
* SUBROUTINE STATUS
*
* CHECK FOR INPUT CHARACTER. Z SET IF NO CHARACTER AVAILABLE
* ALLOWED TO DESTROY CC
STATUS         PSHS A           PRESERVE
               LDA  UARTSTA     VDU/UART STATUS
               BITA #1          CHARACTER AVAILABLE?
               PULS A           RESTORE
               RTS              Z FLAG IF NO CHARACTER

*******************************************************************
* SUBROUTINE MONITOR
*
* TRANSFER CONTROL BACK TO ROM MONITOR. FOR MULTICOMP THIS COULD
* CHANGE THE PAGING AND PIVOT BACK TO THE ROM? FOR NOW, IT DOES
* NOTHING, THE VECTOR SIMPLY POINTS TO FLEX WARM BOOT.

*******************************************************************
* SUBROUTINES FOR INTERRRUPT-DRIVEN PRINTER SPOOLING.
*
* ALL OF THESE ARE DISABLED FOR NOW
TINT
TON
TOFF           RTS

IHND           RTI


*******************************************************************
* CONSOLE I/O DRIVER VECTOR TABLE
*
               ORG $D3E5        TABLE STARTS AT $D3E5
INCHNE         FDB INNECH       INPUT CHAR - NO ECHO
IHNDLR         FDB IHND         IRQ INTERRUPT HANDLER
SWIVEC         FDB $DFC2        SWI3 VECTOR LOCATION
IRQVEC         FDB $DFC8        IRQ VECTOR LOCATION
TMOFF          FDB TOFF         TIMER OFF ROUTINE
TMON           FDB TON          TIMER ON ROUTINE
TMINT          FDB TINT         TIMER INITIALIZE ROUTINE
MONITR         FDB FLEXWRM      MONITOR RETURN ADDRESS
TINIT          FDB INIT         TERMINAL INITIALIZATION
STAT           FDB STATUS       CHECK TERMINAL STATUS
OUTCH          FDB OUTPUT       TERMINAL CHAR OUTPUT
INCH           FDB INPUT        TERMINAL CHAR INPUT
*******************************************************************


*******************************************************************
* END STATEMENT HAS FLEX TRANSFER ADDRESS
*
               END $CD00
