* Cut-down from r09sase.asm to auto-boot CUBIX
*
*

* SDCARD control registers
SDDATA    EQU $FFD8
SDCTL     EQU $FFD9
SDLBA0    EQU $FFDA
SDLBA1    EQU $FFDB
SDLBA2    EQU $FFDC


* SDCARD block size 512 = $200.
BLKBYTE   EQU $200

* Other labels
M1000   EQU     $1000
M2100   EQU     $2100
MC700   EQU     $C700
GOCUBIX EQU     $C808
MF000   EQU     $F000

*****************************************************
** Program Code / Data Areas                        *
*****************************************************

        ORG     $F800

ENTRY   LDS     #M2100                   *F800: 10 CE 21 00    '..!.'
        JSR     CLRLBA                   *F99A: BD FA 58       '..X'
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
        JMP     BOOTLOP                  *F9BC: 7E F9 BF       '~..'

BOOTLOP LDA     ,U                       *F9BF: A6 C4          '..'
        JSR     SDRD                     *F9C1: BD FA 0E       '...'
        CMPX    #MF000                   *F9C4: 8C F0 00       '...'
        BCC     LOADED                   *F9C7: 24 23          '$#'
        LDA     $06,U                    *F9C9: A6 46          '.F'
        INCA                             *F9CB: 4C             'L'
        STA     $06,U                    *F9CC: A7 46          '.F'
        CMPA    $03,U                    *F9CE: A1 43          '.C'
        BNE     BOOTLOP                  *F9D0: 26 ED          '&.'
        CLRA                             *F9D2: 4F             'O'
        STA     $06,U                    *F9D3: A7 46          '.F'
        LDA     $05,U                    *F9D5: A6 45          '.E'
        INCA                             *F9D7: 4C             'L'
        STA     $05,U                    *F9D8: A7 45          '.E'
        CMPA    $02,U                    *F9DA: A1 42          '.B'
        BNE     BOOTLOP                  *F9DC: 26 E1          '&.'
        CLRA                             *F9DE: 4F             'O'
        STA     $06,U                    *F9DF: A7 46          '.F'
        STA     $05,U                    *F9E1: A7 45          '.E'
        LDA     $04,U                    *F9E3: A6 44          '.D'
        INCA                             *F9E5: 4C             'L'
        STA     $04,U                    *F9E6: A7 44          '.D'
        CMPA    $01,U                    *F9E8: A1 41          '.A'
        BNE     BOOTLOP                  *F9EA: 26 D3          '&.'

LOADED  JMP     GOCUBIX                  *F9EC: 7E C8 08       '~..'




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

CLRLBA  LDA     #$00                     *FA58: 86 00          '..'
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


