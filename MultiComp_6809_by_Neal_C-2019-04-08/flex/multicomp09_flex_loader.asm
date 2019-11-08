* FLEX LOADER
* SITS ON SECTOR 1 OF A BOOTABLE SYSTEM DISK
* LOADED INTO MEMORY AT $C100 AND ENTERED AT THAT ADDRESS.
* PURPOSE IS TO LOAD AND START A BINARY IMAGE. THE START TRACK/SECTOR
* OF THE IMAGE IS PATCHED INTO TWO LOCATIONS IN THIS IMAGE - USUALLY
* THROUGH USE OF THE "LINK" COMMAND.
*
* ASSUMES DP SET TO 0 ON ENTRY
* ASSUMES RAM TO SUIT FLEX.
*
* NEAL CROOK MAY2015. BASED ON APPENDIX E OF 6809 FLEX ADAPTION GUIDE
*

*******************************************************************
* MULTICOMP I/O REGISTERS
*******************************************************************

* SDCARD CONTROL REGISTERS
SDDATA         EQU $FFD8
SDCTL          EQU $FFD9
SDLBA0         EQU $FFDA
SDLBA1         EQU $FFDB
SDLBA2         EQU $FFDC

* VDU DATA
UARTDAT        EQU $FFD1
UARTSTA        EQU $FFD0



STACK          EQU $C07F
SCTBUF         EQU $C300        DATA SECTOR BUFFER

* START OF UTILITY

               ORG $C100        LOAD AND ENTRY POINT
LOAD           BRA LOAD0

*                               MULTICOMP SPECIFIC: THE 24-BIT
LBA2           FCB $02          START BLOCK NUMBER FOR THIS DISK
LBA1           FCB $20          IMAGE ON SD-CARD. USED FOR EACH SECTOR LOAD
LBA0           FCB $00          SO MUST NOT BE MODIFIED BY THE CODE HERE!

TRK            FCB 37           FILE START TRACK  -- MUST BE AT $C105 - PATCHED
SCT            FCB 65           FILE START SECTOR -- BY "LINK" COMMAND.
DNS            FCB 0            DENSITY FLAG
TADR           FDB $C100        TRANSFER ADDRESS  -- FILLED IN BY IMAGE LOAD
LADR           FDB 0            LOAD ADDRESS      -- FILLED IN BY IMAGE LOAD


LOAD0          LDS #STACK       INDICATE TO USER THAT WE GOT HERE
               LDA #'F'
               BSR TOVDU
               LDA #'L'
               BSR TOVDU
               LDA #'E'
               BSR TOVDU
               LDA #'X'
               BSR TOVDU

               LDD TRK          SETUP STARTING TRK & SCT
               STD SCTBUF
               LDY #SCTBUF+256

* PERFORM ACTUAL FILE LOAD

LOAD1          BSR GETCH        GET A CHARACTER
               CMPA #$02        DATA RECORD HEADER?
               BEQ LOAD2        SKIP IF SO
               CMPA #$16        XFR ADDRESS HEADER?
               BNE LOAD1        LOOP IF NEITHER
               BSR GETCH        GET TRANSFER ADDRESS
               STA TADR
               BSR GETCH
               STA TADR+1
               BRA LOAD1        CONTINUE LOAD

LOAD2          BSR GETCH        GET LOAD ADDRESS
               STA LADR
               BSR GETCH
               STA LADR+1
               BSR GETCH        GET BYTE COUNT
               TFR A,B          PUT IN B (WAS "TAB" IN ORIGINAL
               TSTA             THIS EQUIVALENT FROM LEVENTHAL)
               BEQ LOAD1        LOOP IF COUNT=0
               LDX LADR         GET LOAD ADDRESS
LOAD3          PSHS B,X
               BSR GETCH        GET A DATA CHARACTER
               PULS B,X
               STA 0,X+         PUT CHARACTER
               DECB             END OF DATA IN RECORD?
               BNE LOAD3        LOOP IF NOT
               BRA LOAD1        GET ANOTHER RECORD

**************************************************************
* SUBROUTINE ENTRY POINT
* SEND CHARACTER TO VDU
* A: CHARACTER TO PRINT
* CAN DESTROY B,CC

TOVDU          PSHS B
VDUBIZ         LDB UARTSTA
               BITB #2
               BEQ VDUBIZ       BUSY

               STA UARTDAT      READY, SEND CHARACTER
               PULS B
               RTS

**************************************************************
* SUBROUTINE ENTRY POINT
* GET CHARACTER ROUTINE - READS A SECTOR IF NECESSARY

GETCH          CMPY #SCTBUF+256 OUT OF DATA?
               BNE GETCH4       GO READ CHARACTER IF NOT
GETCH2         LDX #SCTBUF      POINT TO BUFFER
               LDD 0,X          GET FORWARD LINK
               BEQ GO           IF ZERO, FILE IS LOADED
               BSR READ         READ NEXT SECTOR
               BNE LOAD0        START OVER IF ERROR
               LDY #SCTBUF+4    POINT PAST LINK
GETCH4         LDA 0,Y+         ELSE, GET A CHARACTER
               RTS

* FILE IS LOADED, JUMP TO IT

GO             JMP [TADR]       JUMP TO TRANSFER ADDRESS

**************************************************************
* SUBROUTINE ENTRY POINT
* READ SINGLE SECTOR
* A: TRACK
* B: SECTOR
* X: WHERE TO STORE THE DATA (256 BYTES)
* RETURN NE IF ERROR
* CAN DESTROY A,B,X,U MUST PRESERVE Y.
*
* DISK GEOMETRY IS HARD-CODED. ASSUMED TO USE 72 SECTORS PER TRACK
* AND TO HAVE THE SAME NUMBER ON TRACK 0.
* CONVERT FROM TRACK, SECTOR TO BLOCK AND ADD TO THE START BLOCK.
* COMPUTE LBA0 + 256*LBA1 + 256*256*LBA2 + A*72 + B - 1

READ
* ADD IN THE "+B - 1" PART TO THE IMAGE BASE AT LBA0..LBA2
               SUBB #1          SECTOR->OFFSET. EG: SECTOR 1 IS AT OFFSET 0
               ADDB LBA0        ADD SECTOR OFFSET TO IMAGE BASE
               STB  ,X+         USE BUFFER AS SCRATCH SPACE
               LDB  #0
               ADCB LBA1        RIPPLE CARRY TO NEXT
               STB  ,X+         AND STORE
               LDB  #0
               ADCB LBA2        RIPPLE CARRY TO LAST
               STB  ,X          AND STORE
               LEAX -2,X        X BACK TO START OF BUFFER

* ADD IN THE "A*72" PART AND STORE TO WRITE-ONLY HARDWARE REGISTERS
               LDB  #72
               MUL  A B
               ADDB ,X+         ADD LS BYTE IN B TO LBA0+SECTOR
               STB  SDLBA0      LS BYTE DONE
               ADCA ,X+         ADD MS BYTE IN A TO LBA1+CARRY
               STA  SDLBA1      AND STORE
               LDA  #0
               ADCA ,X          RIPPLE CARRY TO LAST BYTE
               STA  SDLBA2      AND STORE
               LEAX -2,X        X BACK TO START OF BUFFER

* ISSUE THE READ COMMAND TO THE SDCARD CONTROLLER
               CLRA
               STA  SDCTL
* NOW TRANSFER 512 BYTES, WAITING FOR EACH IN TURN. ONLY WANT 256
* OF THEM - DISCARD THE REST
               CLRB             ZERO IS LIKE 256
SDBIZ          LDA SDCTL
               CMPA #$E0
               BNE SDBIZ        BYTE NOT READY
               LDA SDDATA       GET BYTE
               STA ,X+          STORE IN SECTOR BUFFER
               DECB
               BNE SDBIZ        NEXT

               CLRB             ZERO IS LIKE 256
SDBIZ2         LDA SDCTL
               CMPA #$E0
               BNE SDBIZ2       BYTE NOT READY
               LDA SDDATA       GET BYTE (BUT DO NOTHING WITH IT)
               DECB
               BNE SDBIZ2       NEXT

               LDA  #'.'        INDICATE LOAD PROGRESS
               BSR TOVDU
               CLRA             SET Z TO INDICATE SUCCESSFUL COMPLETION
               RTS

* BY INSPECTION, PAD TO 256-BYTE BOUNDARY (NO NEED TO DO THIS BUT IT
* KEEPS THE SECTOR TIDY!)
               FCB 0,0,0,0, 0,0,0,0
               FCB 0,0,0,0, 0,0,0,0
               FCB 0,0,0,0, 0,0,0,0
               FCB 0,0,0,0, 0,0,0

               END
