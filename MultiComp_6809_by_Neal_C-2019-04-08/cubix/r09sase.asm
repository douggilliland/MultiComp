* Original was: fpga/m6809/s09ase.ASM by Dan Werner, based
* on the ROM by Andrew Lynch, modifications for 6809 FPGA
* by August Treubig -- June 2014
*
* This version created from the binary thus:
* f9dasm -noconv -offset f800 r09sase.bin -out r09sase.asm
*
* then hand-edited to add comments.
* Rebuilt with AS9 and verified to match the original binary.
*
* This is used as the CUBIX boot "ROM" for Multicomp09. It
* is actually loaded from SDcard into RAM.
* It needs to stay resident after CUBIX has loaded - I'm
* not sure whether it acts as a "bios" (eg providing disk
* read/write routines) or simply provides the exception
* vectors (eg SWIs) to CUBIX code.
*
* In its original form this provides a simple monitor - commands
* are:
* l - load
* m - modify
* p - print
* g - go
* b - boot
*


* SDCARD control registers
SDDATA    EQU $FFD8
SDCTL     EQU $FFD9
SDLBA0    EQU $FFDA
SDLBA1    EQU $FFDB
SDLBA2    EQU $FFDC

* UART
UART1D    EQU $FFD3
UART1S    EQU $FFD2
* VDU
UART2D    EQU $FFD1
UART2S    EQU $FFD0

* SDCARD block size 512 = $200.
BLKBYTE   EQU $200


* Other labels
M0108   EQU     $0108
M010A   EQU     $010A
M010B   EQU     $010B
M010C   EQU     $010C
M010D   EQU     $010D
M1000   EQU     $1000
M2100   EQU     $2100
MC700   EQU     $C700
GOCUBIX EQU     $C808
MF000   EQU     $F000
ZFAE9   EQU     $FAE9
ZFAF2   EQU     $FAF2
ZFB09   EQU     $FB09
ZFB0A   EQU     $FB0A
ZFB16   EQU     $FB16
ZFB1D   EQU     $FB1D
ZFB2F   EQU     $FB2F

*****************************************************
** Program Code / Data Areas                        *
*****************************************************

        ORG     $F800

ENTRY   LDS     #M2100                   *F800: 10 CE 21 00    '..!.'
        CLRA                             *F804: 4F             'O'
        JSR     ZFA7B                    * UART init? Not needed.

        LDX     #MSG1                    *F808: 8E FA A3       '...'
        JSR     PUTMSG                   *F80B: BD F9 FA       '...'

* Command loop
ZF80E   JSR     PUTCR                    *F80E: BD F9 EF       '...'
        LDA     #$3E                     *F811: 86 3E          '.>'
        JSR     PUTCH                    * print ">"
        JSR     ZFA06                    *F816: BD FA 06       '...'
        JSR     PUTCH                    *F819: BD FA 81       '...'
        CMPA    #$64                     *F81C: 81 64          '.d'
        BEQ     CMD_D                    *F81E: 27 2A          ''*'
        CMPA    #$6C                     *F820: 81 6C          '.l'
        BEQ     CMD_L                    *F822: 27 1A          ''.'
        CMPA    #$6D                     *F824: 81 6D          '.m'
        BEQ     CMD_M                    *F826: 27 4A          ''J'
        CMPA    #$70                     *F828: 81 70          '.p'
        BEQ     CMD_P                    *F82A: 27 5D          '']'
        CMPA    #$67                     *F82C: 81 67          '.g'
        BEQ     CMD_G                    *F82E: 27 37          ''7'
        CMPA    #$62                     *F830: 81 62          '.b'
        BEQ     CMD_B                    *F832: 27 0D          ''.'
        LDA     #$3F                     *F834: 86 3F          '.?'
        JSR     PUTCH                    * print "?"
        JSR     PUTCR                    *F839: BD F9 EF       '...'
        BRA     ZF80E                    *F83C: 20 D0          ' .'
CMD_L   JMP     ZF89B                    *F83E: 7E F8 9B       '~..'
CMD_B   LDX     #MSG2                    *F841: 8E FA CC       '...'
        JSR     PUTMSG                   *F844: BD F9 FA       '...'
        JMP     ZF99A                    *F847: 7E F9 9A       '~..'

CMD_D   JSR     ZF995                    *F84A: BD F9 95       '...'
        JSR     ZF937                    *F84D: BD F9 37       '..7'
        PSHS    X                        *F850: 34 10          '4.'
        JSR     ZF995                    *F852: BD F9 95       '...'
        JSR     ZF937                    *F855: BD F9 37       '..7'
        PULS    X                        *F858: 35 10          '5.'
        JSR     PUTCR                    *F85A: BD F9 EF       '...'
ZF85D   JSR     ZF8D5                    *F85D: BD F8 D5       '...'
        CMPX    M010C                    *F860: BC 01 0C       '...'
        BMI     ZF85D                    *F863: 2B F8          '+.'
        BRA     ZF80E                    *F865: 20 A7          ' .'
CMD_G   JSR     ZF937                    *F867: BD F9 37       '..7'
        JSR     ZF995                    *F86A: BD F9 95       '...'
        LDX     M010C                    *F86D: BE 01 0C       '...'
        JMP     ,X                       *F870: 6E 84          'n.'
CMD_M   JSR     ZF937                    *F872: BD F9 37       '..7'
        JSR     ZF995                    *F875: BD F9 95       '...'
        JSR     ZF993                    *F878: BD F9 93       '...'
        JSR     ZF945                    *F87B: BD F9 45       '..E'
        LEAX    -$01,X                   *F87E: 30 1F          '0.'
        STA     ,X                       *F880: A7 84          '..'
        CMPA    ,X                       *F882: A1 84          '..'
        BNE     ZF8CD                    *F884: 26 47          '&G'
        JMP     ZF80E                    *F886: 7E F8 0E       '~..'
CMD_P   STS     M0108                    *F889: 10 FF 01 08    '....'
        LDX     M0108                    *F88D: BE 01 08       '...'
        LDB     #$09                     *F890: C6 09          '..'
ZF892   JSR     ZF993                    *F892: BD F9 93       '...'
        DECB                             *F895: 5A             'Z'
        BNE     ZF892                    *F896: 26 FA          '&.'
        JMP     ZF80E                    *F898: 7E F8 0E       '~..'
ZF89B   JSR     ZFA06                    *F89B: BD FA 06       '...'
        CMPA    #$53                     *F89E: 81 53          '.S'
        BNE     ZF89B                    *F8A0: 26 F9          '&.'
        JSR     ZFA06                    *F8A2: BD FA 06       '...'
        CMPA    #$39                     *F8A5: 81 39          '.9'
        BEQ     ZF8D2                    *F8A7: 27 29          '')'
        CMPA    #$31                     *F8A9: 81 31          '.1'
        BNE     ZF89B                    *F8AB: 26 EE          '&.'
        CLR     M010A                    *F8AD: 7F 01 0A       '...'
        JSR     ZF945                    *F8B0: BD F9 45       '..E'
        SUBA    #$02                     *F8B3: 80 02          '..'
        STA     M010B                    *F8B5: B7 01 0B       '...'
        BSR     ZF937                    *F8B8: 8D 7D          '.}'
ZF8BA   JSR     ZF945                    *F8BA: BD F9 45       '..E'
        DEC     M010B                    *F8BD: 7A 01 0B       'z..'
        BEQ     ZF8C8                    *F8C0: 27 06          ''.'
        STA     ,X                       *F8C2: A7 84          '..'
        LEAX    $01,X                    *F8C4: 30 01          '0.'
        BRA     ZF8BA                    *F8C6: 20 F2          ' .'
ZF8C8   INC     M010A                    *F8C8: 7C 01 0A       '|..'
        BEQ     ZF89B                    *F8CB: 27 CE          ''.'
ZF8CD   LDA     #$3F                     *F8CD: 86 3F          '.?'
        JSR     PUTCH                    * print "?"
ZF8D2   JMP     ZF80E                    *F8D2: 7E F8 0E       '~..'
ZF8D5   JSR     ZF97C                    *F8D5: BD F9 7C       '..|'
        JSR     ZF995                    *F8D8: BD F9 95       '...'
        PSHS    X                        *F8DB: 34 10          '4.'
        LDB     #$10                     *F8DD: C6 10          '..'
ZF8DF   JSR     ZF993                    *F8DF: BD F9 93       '...'
        DECB                             *F8E2: 5A             'Z'
        BNE     ZF8DF                    *F8E3: 26 FA          '&.'
        PULS    X                        *F8E5: 35 10          '5.'
        JSR     ZF995                    *F8E7: BD F9 95       '...'
        LDA     #$3A                     *F8EA: 86 3A          '.:'
        JSR     PUTCH                    * print ":"
        LDB     #$10                     *F8EF: C6 10          '..'
ZF8F1   LDA     ,X                       *F8F1: A6 84          '..'
        CMPA    #$20                     *F8F3: 81 20          '. '
        BMI     ZF901                    *F8F5: 2B 0A          '+.'
        CMPA    #$7F                     *F8F7: 81 7F          '..'
        BPL     ZF901                    *F8F9: 2A 06          '*.'
        JSR     PUTCH                    *F8FB: BD FA 81       '...'
        JMP     ZF906                    *F8FE: 7E F9 06       '~..'
ZF901   LDA     #$2E                     *F901: 86 2E          '..'
        JSR     PUTCH                    * print "."
ZF906   LEAX    $01,X                    *F906: 30 01          '0.'
        DECB                             *F908: 5A             'Z'
        BNE     ZF8F1                    *F909: 26 E6          '&.'
        JSR     PUTCR                    *F90B: BD F9 EF       '...'
        RTS                              *F90E: 39             '9'

ZF90F   JSR     ZFA06                    *F90F: BD FA 06       '...'
        PSHS    A                        *F912: 34 02          '4.'
        JSR     PUTCH                    *F914: BD FA 81       '...'
        PULS    A                        *F917: 35 02          '5.'
        CMPA    #$30                     *F919: 81 30          '.0'
        BMI     ZF8D2                    *F91B: 2B B5          '+.'
        CMPA    #$39                     *F91D: 81 39          '.9'
        BLE     ZF92F                    *F91F: 2F 0E          '/.'
        CMPA    #$60                     *F921: 81 60          '.`'
        BGT     ZF930                    *F923: 2E 0B          '..'
        CMPA    #$41                     *F925: 81 41          '.A'
        BMI     ZF8D2                    *F927: 2B A9          '+.'
        CMPA    #$46                     *F929: 81 46          '.F'
        BGT     ZF8D2                    *F92B: 2E A5          '..'
        SUBA    #$07                     *F92D: 80 07          '..'
ZF92F   RTS                              *F92F: 39             '9'

ZF930   CMPA    #$66                     *F930: 81 66          '.f'
        BGT     ZF8D2                    *F932: 2E 9E          '..'
        SUBA    #$27                     *F934: 80 27          '.''
        RTS                              *F936: 39             '9'

ZF937   BSR     ZF945                    *F937: 8D 0C          '..'
        STA     M010C                    *F939: B7 01 0C       '...'
        BSR     ZF945                    *F93C: 8D 07          '..'
        STA     M010D                    *F93E: B7 01 0D       '...'
        LDX     M010C                    *F941: BE 01 0C       '...'
        RTS                              *F944: 39             '9'

ZF945   BSR     ZF90F                    *F945: 8D C8          '..'
        ASLA                             *F947: 48             'H'
        ASLA                             *F948: 48             'H'
        ASLA                             *F949: 48             'H'
        ASLA                             *F94A: 48             'H'
        TFR     A,B                      *F94B: 1F 89          '..'
        TSTA                             *F94D: 4D             'M'
        BSR     ZF90F                    *F94E: 8D BF          '..'
        ANDA    #$0F                     *F950: 84 0F          '..'
        PSHS    B                        *F952: 34 04          '4.'
        ADDA    ,S+                      *F954: AB E0          '..'
        TFR     A,B                      *F956: 1F 89          '..'
        TSTA                             *F958: 4D             'M'
        ADDB    M010A                    *F959: FB 01 0A       '...'
        STB     M010A                    *F95C: F7 01 0A       '...'
        RTS                              *F95F: 39             '9'

ZF960   LSRA                             *F960: 44             'D'
        LSRA                             *F961: 44             'D'
        LSRA                             *F962: 44             'D'
        LSRA                             *F963: 44             'D'
ZF964   ANDA    #$0F                     *F964: 84 0F          '..'
        ADDA    #$30                     *F966: 8B 30          '.0'
        CMPA    #$39                     *F968: 81 39          '.9'
        BLS     ZF96E                    *F96A: 23 02          '#.'
        ADDA    #$07                     *F96C: 8B 07          '..'
ZF96E   JMP     PUTCH                    *F96E: 7E FA 81       '~..'
ZF971   LDA     ,X                       *F971: A6 84          '..'
        BSR     ZF960                    *F973: 8D EB          '..'
        LDA     ,X                       *F975: A6 84          '..'
        BSR     ZF964                    *F977: 8D EB          '..'
        LEAX    $01,X                    *F979: 30 01          '0.'
        RTS                              *F97B: 39             '9'

ZF97C   PSHS    X                        *F97C: 34 10          '4.'
        PULS    A                        *F97E: 35 02          '5.'
        PSHS    A                        *F980: 34 02          '4.'
        BSR     ZF960                    *F982: 8D DC          '..'
        PULS    A                        *F984: 35 02          '5.'
        BSR     ZF964                    *F986: 8D DC          '..'
        PULS    A                        *F988: 35 02          '5.'
        PSHS    A                        *F98A: 34 02          '4.'
        BSR     ZF960                    *F98C: 8D D2          '..'
        PULS    A                        *F98E: 35 02          '5.'
        BSR     ZF964                    *F990: 8D D2          '..'
        RTS                              *F992: 39             '9'

ZF993   BSR     ZF971                    *F993: 8D DC          '..'
ZF995   LDA     #$20                     *F995: 86 20          '. '
        JMP     PUTCH                    * print " "
ZF99A   JSR     ZFA58                    *F99A: BD FA 58       '..X'
        LDU     #M1000                   *F99D: CE 10 00       '...'
        LDA     #$00                     *F9A0: 86 00          '..'
        STA     ,U                       *F9A2: A7 C4          '..'
        LDA     #$01                     *F9A4: 86 01          '..'
        STA     $02,U                    *F9A6: A7 42          '.B'
        LDA     #$FF                     *F9A8: 86 FF          '..'
        STA     $03,U                    *F9AA: A7 43          '.C'
        LDA     #$22                     *F9AC: 86 22          '."'
        STA     $01,U                    *F9AE: A7 41          '.A'
        LDA     #$21                     *F9B0: 86 21          '.!'
        STA     $04,U                    *F9B2: A7 44          '.D'
        CLRA                             *F9B4: 4F             'O'
        STA     $05,U                    *F9B5: A7 45          '.E'
        STA     $06,U                    *F9B7: A7 46          '.F'
        LDX     #MC700                   *F9B9: 8E C7 00       '...'
        JMP     ZF9BF                    *F9BC: 7E F9 BF       '~..'
ZF9BF   LDA     ,U                       *F9BF: A6 C4          '..'
        JSR     SDRD                     *F9C1: BD FA 0E       '...'
        CMPX    #MF000                   *F9C4: 8C F0 00       '...'
        BCC     LOADED                   *F9C7: 24 23          '$#'
        LDA     $06,U                    *F9C9: A6 46          '.F'
        INCA                             *F9CB: 4C             'L'
        STA     $06,U                    *F9CC: A7 46          '.F'
        CMPA    $03,U                    *F9CE: A1 43          '.C'
        BNE     ZF9BF                    *F9D0: 26 ED          '&.'
        CLRA                             *F9D2: 4F             'O'
        STA     $06,U                    *F9D3: A7 46          '.F'
        LDA     $05,U                    *F9D5: A6 45          '.E'
        INCA                             *F9D7: 4C             'L'
        STA     $05,U                    *F9D8: A7 45          '.E'
        CMPA    $02,U                    *F9DA: A1 42          '.B'
        BNE     ZF9BF                    *F9DC: 26 E1          '&.'
        CLRA                             *F9DE: 4F             'O'
        STA     $06,U                    *F9DF: A7 46          '.F'
        STA     $05,U                    *F9E1: A7 45          '.E'
        LDA     $04,U                    *F9E3: A6 44          '.D'
        INCA                             *F9E5: 4C             'L'
        STA     $04,U                    *F9E6: A7 44          '.D'
        CMPA    $01,U                    *F9E8: A1 41          '.A'
        BNE     ZF9BF                    *F9EA: 26 D3          '&.'
LOADED  JMP     GOCUBIX                  *F9EC: 7E C8 08       '~..'

* Print CR/LF. Destroys A.
PUTCR   LDA     #$0D
        JSR     PUTCH
        LDA     #$0A
        JSR     PUTCH
        RTS

* Print string at address X. String is 0-terminated.
* Destroys A,X
PUTMSG  LDA     ,X                       *F9FA: A6 84          '..'
        BEQ     ZFA05                    *F9FC: 27 07          ''.'
        JSR     PUTCH                    *F9FE: BD FA 81       '...'
        LEAX    $01,X                    *FA01: 30 01          '0.'
        BRA     PUTMSG                   *FA03: 20 F5          ' .'
ZFA05   RTS                              *FA05: 39             '9'

ZFA06   JSR     ZFA93                    *FA06: BD FA 93       '...'
        CMPA    #$FF                     *FA09: 81 FF          '..'
        BEQ     ZFA06                    *FA0B: 27 F9          ''.'
        RTS                              *FA0D: 39             '9'

SDRD    LDA     SDCTL
        CMPA    #$80
        BNE     SDRD                     * Wait until SD init complete
        JSR     ZFA64                    *FA15: BD FA 64       '..d'
        LDA     #$00
        STA     SDCTL                    * Issue SD READ command
        LDY     #BLKBYTE                 *FA1D: 10 8E 02 00    '....'
SDBIZ   LDA     SDCTL                    *FA21: B6 FF D9       '...'
        CMPA    #$E0                     *FA24: 81 E0          '..'
        BNE     SDBIZ                    *FA26: 26 F9          '&.'
        LDA     SDDATA                   *FA28: B6 FF D8       '...'
        STA     ,X+                      *FA2B: A7 80          '..'
        LEAY    -$01,Y                   *FA2D: 31 3F          '1?'
        BNE     SDBIZ                    *FA2F: 26 F0          '&.'
        CLRA                             *FA31: 4F             'O'
        RTS                              *FA32: 39             '9'

* Not used here.. but may be used by CUBIX
SDWR    LDA     SDCTL                    *FA33: B6 FF D9       '...'
        CMPA    #$80                     *FA36: 81 80          '..'
        BNE     SDWR                     * Wait intil SD init complete
        JSR     ZFA64                    *FA3A: BD FA 64       '..d'
        LDA     #$01
        STA     SDCTL                    * Issue SD WRITE command
        LDY     #BLKBYTE                 *FA42: 10 8E 02 00    '....'
SDBIZ2  LDA     SDCTL                    *FA46: B6 FF D9       '...'
        CMPA    #$A0                     *FA49: 81 A0          '..'
        BNE     SDBIZ2                   *FA4B: 26 F9          '&.'
        LDA     ,X+                      *FA4D: A6 80          '..'
        STA     SDDATA                   *FA4F: B7 FF D8       '...'
        LEAY    -$01,Y                   *FA52: 31 3F          '1?'
        BNE     SDBIZ2                   *FA54: 26 F0          '&.'
        CLRA                             *FA56: 4F             'O'
        RTS                              *FA57: 39             '9'

ZFA58   LDA     #$00                     *FA58: 86 00          '..'
        STA     SDLBA0                   *FA5A: B7 FF DA       '...'
        STA     SDLBA1                   *FA5D: B7 FF DB       '...'
        STA     SDLBA2                   *FA60: B7 FF DC       '...'
        RTS                              *FA63: 39             '9'

ZFA64   LDA     $06,U                    *FA64: A6 46          '.F'
        STA     SDLBA0                   *FA66: B7 FF DA       '...'
        LDA     ,U                       *FA69: A6 C4          '..'
        ANDCC   #$FE                     *FA6B: 1C FE          '..'
        RORA                             *FA6D: 46             'F'
        RORA                             *FA6E: 46             'F'
        RORA                             *FA6F: 46             'F'
        ADDA    $04,U                    *FA70: AB 44          '.D'
        STA     SDLBA1                   *FA72: B7 FF DB       '...'
        LDA     #$00                     *FA75: 86 00          '..'
        STA     SDLBA2                   *FA77: B7 FF DC       '...'
        RTS                              *FA7A: 39             '9'

ZFA7B   LDA     #$95                     *FA7B: 86 95          '..'
        STA     UART2S                   *FA7D: B7 FF D0       '...'
        RTS                              *FA80: 39             '9'

* Print character in A
PUTCH   BSR     UARTBIZ                  *FA81: 8D 04          '..'
        STA     UART2D                   *FA83: B7 FF D1       '...'
        RTS                              *FA86: 39             '9'

* Wait while UART busy
UARTBIZ PSHS    A                        *FA87: 34 02          '4.'
ZFA89   LDA     UART2S                   *FA89: B6 FF D0       '...'
        BITA    #$02                     *FA8C: 85 02          '..'
        BEQ     ZFA89                    *FA8E: 27 F9          ''.'
        PULS    A                        *FA90: 35 02          '5.'
        RTS                              *FA92: 39             '9'

ZFA93   LDA     UART2S                   *FA93: B6 FF D0       '...'
        BITA    #$01                     *FA96: 85 01          '..'
        BEQ     ZFAA0                    *FA98: 27 06          ''.'
        LDA     UART2D                   *FA9A: B6 FF D1       '...'
        ORCC    #$04                     *FA9D: 1A 04          '..'
        RTS                              *FA9F: 39             '9'
ZFAA0   LDA     #$FF                     *FAA0: 86 FF          '..'
        RTS                              *FAA2: 39             '9'

MSG1    FCB $0D, $0A, $0D, $0A
        FCC "AG5AT DISK 6809"
        FCC " ROM MONITOR READY."
        FCB $0D, $0A, $00

MSG2    FCB $0D, $0A
        FCC "BOOTING FROM SD"
        FCB $0D, $0A, $00

        FCB $03, $00, $02, $00, $00, $03, $04, $01, $3B

* Exception vectors
        ORG     $FFF2

        FDB     $DE5C
        FDB     $DE58
        FDB     $DE64
        FDB     $DE60
        FDB     $DE54
        FDB     $DE68
        FDB     ENTRY                    * Reset vector -> entry point

        END
