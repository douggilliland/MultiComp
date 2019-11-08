* Memory-resident monitor for kipper1 SBC
*
* Derived from Lennart Benschop's
* "Buggy machine language monitor and rudimentary O.S. version 1.0"
* by foofoobedoo@gmail.com
*
* After booting FLEX, load this program into memory thus:
* +++MON09
* The program will initialise and then return to the FLEX prompt.
* Once loaded and intialised in this way, you can enter it at
* any time from FLEX using the FLEX build-in command, MON:
* +++MON
* and return to FLEX using the monitor command: G CD03
*
*
* Entry/Exit points:
* RESET - Entry from reset. In this case, set sp, dp etc.
*   init workspace. Init I/O. Exit: nowhere to go back to
*   so do nothing.
* FLOAD - Entry from FLEX (load-time). In this case, set sp, dp
*   etc, init workspace. Don't init I/O. Tie in to FLEX MON vector.
*   Exit: restore dp, branch to FLEX warm start point (which
*   resets sp)
* MON - Entry from FLEX (run-time). Keep sp? load dp.
*   Exit: restore dp, branch to FLEX warm start point (which
*   resets sp)
* NMI - Entry from special key-press. State saved on existing
*   stack. Load dp. Honour Interactive flag.
*   Exit: ensure UART output idle (main program could have discerned
*   this just as NMI was serviced), Do rti.
* FIRQ - Entry from timer interrupt; either periodic timer or
*   single step. State saved in existing stack. Load dp. Check
*   sstep flag.
*   Exit: if timer, service and return through rti. If
*   sstep rti will return to cli [NAC HACK 2015Jul18] could have a trace
*   capability where we run for N single steps?
* SWI - Entry from breakpoint.
*
* .. in the NMI, FIRQ, SWI cases, buggy must already have been
* initialised.
*
* Use-case: load and start Buggy from FLEX. Load and start program
* from FLEX. Press key to NMI to Buggy. Set breakpoint then exit.
* Program resumes. Hits breakpoint and enters Buggy. At this point
* need to know that "Exit" from Buggy should take us back to the
* program. I think this will all happen based on the stacked register
* set which means, in the case of RESET, FLOAD and MON we simply need
* to stack the correct values then "Exit" and "Continue" (if such a
* thing exists) will resume in the same way.
* May also want an explicit FLEX warm start command, which only has
* effect in the case where we came in through FLEX.
*
* To tie in to FLEX MON command need to change the MONITR vector at
* $D3F3 to the value of MON then return to FLEX by doing a FLEX warm
* start.
*
* FLEX warm start (jump to $CD03) resets the stack pointer
*
* Memory Map:
* - Designed to be RAM-resident at D000-FFFF (loaded in when
*   the ROM is disabled).
* - Avoids address space $FFD0-FFDF, used for I/O in multicomp.
*
* I/O:
*
*
*
* Interrupts:
* multicomp timer interrupt is currently on irq. This expects firq.
*
*
*
* ** to delete?:
* xrecord step
* ** to add:
* sdcard load
* flags for timer interrupt and interactive mode
* exit to return to FLEX
* mmapping?
* memory compare
* TODO think about the impact of the SP messing on
* INT and NMI.. may need to rethink things? Or is it all
* safe?
*
*
* remove any messing with DP and any page-0 access.
* be careful of any messing with interrupt flags
*
* bug/todo
* 0. exec09 doesn't include LIST in help screen
* 1. why does exec09 complain about final line of .hex file?
*      line 222: invalid hex record information. (line 222 is the last line - a blank line)
*    might be due to file having DOS line endings (same problem does not occur with unix line
*    endings in 6809M.HEX)
* 2. d,1000,70 prints 70 the first time but afterwards d prints
*    a default of 40. Why not 70? Likewise U,
* 3. some commands *need* a comma (u 100,20 and d 100,69) some do not (e 400 "hello")
* 4. how does bytes argument work for E and F?
* 6. what do G vs I vs J do?
* 7. what does P do?
* 8. remove unusable commands??
* 9. add new commands
* 10. add new entry points and exit vectors
* 12. can go e"hello world" and it goes somewhere. Dangerous, and not
*     covered as legal syntax!
* 13. e accepts 00 but not 0 as legal input - change scanbyte to
*     accept 1 or 2 hex digits if delimited by space.
* 14. make - go back in assembler. Need to remember what address we started at.
* 15. Breakpoint (now) works but has restriction that you cannot interrupt a loop with a
*     single breakpoint. Reason is that, when you try to restart from the breakpoint
*     address, need to execute that instruction and so cannot insert breakpoint there.
*     Need to implement single step to fix that problem. Side-step it by inserting 2
*     breakpoints, eg at successive instructions.
* 16. To build for FLEX need to set wsstart to $e000. Cannot run like that in exec09
*     because there's no RAM there at load time. Make the startup code work this out
*     and choose a ws automatically based on environment.. can then run from ROM.
* 17. BUG if assemble errors-out, disflg is left in wrong state and subsequent
*     unassemble is mis-formatted.
* 18. BUG implicit ops (eg RTS) are disassembled with no trailing space so
*     when assembling the line indent is wrong. Should add 8 spaces
* 19. BUG when assembling leading whitespace causes an error.
* 20. (my bug) with separate DP between buggy and application, cannot call
*     any buggy routines if those routines use dp accesses.

* NEXT:
* put harness in place to allow entry to and exit from FLEX

* Memory map of SBC
* $0-$40 Zero page variables reserved by monitor and O.S.
* $40-$FF Zero page portion for user programs.
* $100-$17F Xmodem buffer 0, terminal input buffer,
* $180-$1FF Xmodem buffer 1, terminal output buffer.
* $200-$27F Terminal input line.
* $280-$2FF Variables reserved by monitor and O.S.
* $300-$400 System stack.
* $400-$7FFF RAM for user programs and data.
* $8000-$DFFF PROM for user programs.
* $E000-$E1FF I/O addresses.
* $E200-$E3FF Reserved.
* $E400-$FFFF Monitor ROM


* Define memory map
ramstart        equ $0000       ;RAM start of local storage
* TODO multicomp: set wsstart to $6000 for debug using exec09, $e000 for hardware.
* TODO kipper: set to $7000
wsstart         equ $7000       ;RAM start of workspace
rambufs         equ wsstart+$100
ramfree         equ wsstart+$400 ;free RAM after local storage
codestart       equ $e000

* KIPPER I/O port addresses
aciasta         equ $a000       ;RO Status  port of ACIA
aciactl         equ aciasta     ;WO Control port of ACIA
aciadat         equ $a001       ;RW Data port of ACIA

* FLEX vectors
flexwrm         equ $CD03
monitr          equ $D3F3


* Reserved direct page addresses
                org wsstart
* I/O routine vectors.
getchar         rmb 3           ;Jump to osgetc
putchar         rmb 3           ;Jump to osputc
getline         rmb 3           ;Jump to osgetl
putline         rmb 3           ;Jump to osputl
putcr           rmb 3           ;Jump to oscr
getpoll         rmb 3           ;Jump to osgetpoll
xopenin         rmb 3           ;Jump to xopin
xopenout        rmb 3           ;Jump to xopout
xabortin        rmb 3           ;Jump to xabtin
xclosein        rmb 3           ;Jump to xclsin
xcloseout       rmb 3           ;Jump to xclsout
delay           rmb 3           ;Jump to osdly

* System variables in the direct page.
temp            rmb 2           ;hex scanning/disasm
temp2           rmb 2           ;Hex scanning/disasm
temp3           rmb 2           ;Used in Srecords, H command
timer           rmb 3           ;3 byte timer, incremented every 20ms
xpacknum        rmb 1           ;Packet number for XMODEM block,
xsum            rmb 1           ;XMODEM checksum
lastok          rmb 1           ;flag to indicate last block was OK
xcount          rmb 1           ;Count of characters in buffer.
xmode           rmb 1           ;XMODEM mode, 0 none, 1 out, 2 in.
disflg          rmb 1           ;0: CRLF after disassembly 1: no CRLF

* I/O buffers.
buflen          equ 128         ;Length of input line buffer.

                org rambufs
buf0            rmb 128         ;Xmodem buffer 0, serial input buffer.
buf1            rmb 128         ;Xmodem buffer 1, serial output buffer.
linebuf         rmb buflen      ;Input line buffer.

* [NAC HACK 2015Jul16] since the buffer uses X to address it (ie, non ZP)
* move it elsewhere and use ZP for system variables! Likewise, the vectors
* need not be in the ZP.

* Interrupt vectors (start at $280)
* All interrupts except RESET are vectored through jumps.
* FIRQ is timer interrupt, IRQ is ACIA interrupt.
swi3vec         rmb 3
swi2vec         rmb 3
firqvec         rmb 3
irqvec          rmb 3
swivec          rmb 3
nmivec          rmb 3
xerrvec         rmb 3           ;Error handler for XMODEM error.
exprvec         rmb 3           ;Expression evaluator in assembler.
asmerrvec       rmb 3           ;Error handler for assembler errors.
pseudovec       rmb 3           ;Vector for asm pseudo instructions.

* Next the non zero page system variables.
oldpc           rmb 2           ;Saved pc value for J command.
addr            rmb 2           ;Address parameter.
length          rmb 2           ;Length parameter.

brkpoints       equ 8           ;Number of settable breakpoints.
bpaddr          rmb brkpoints*3 ;Address and byte for each break point.
stepbp          rmb 3           ;Address of P command break point.

sorg            rmb 2           ;Origin address of S record entry.
soffs           rmb 2           ;Offset load adrr-addr in record

oldgetc         rmb 2           ;Old getchar address.
oldputc         rmb 2           ;Old putchar address.
oldputcr        rmb 2           ;Old putcr address.
lastterm        rmb 1           ;Last terminating character.
filler          rmb 1           ;Filler at end of XMODEM file.
xmcr            rmb 1           ;end-of-line characters for XMODEM send.
savesp          rmb 2           ;Save sp to restore it on error.
nxtadd          rmb 2

* Variables used by assembler/disassembler.
prebyte         rmb 1
opc1            rmb 1
opcode          rmb 1
postbyte        rmb 1
amode           rmb 1
operand         rmb 2
mnembuf         rmb 5           ;Buffer to store capitalized mnemonic.
opsize          rmb 1           ;Size (in bytes) of extra operand (0--2)
uncert          rmb 1           ;Flag to indicate that op is unknown.
dpsetting       rmb 2

endvars         equ *


* ASCII control characters.
SOH             equ 1
EOT             equ 4
ACK             equ 6
BS              equ 8
TAB             equ 9
LF              equ 10
CR              equ 13
NAK             equ 21
CAN             equ 24
DEL             equ 127

CASEMASK        equ $DF         ;Mask to make lowercase into uppercase.

***************************************************************
* Monitor code starts here.
                org codestart

***************************************************************
* Entry point from FLEX after buggy is loaded from disk. FLEX
* patches its MON command in to buggy cold-start then
* returns through FLEX warm-start vector.
* TODO: in the future would like to leave buggy 'warm' so we
* could come here from a FLEX nmi.
fload           ldx #frmflx
                stx monitr
                jmp flexwrm

***************************************************************
* Entry point from reset
* TODO: currently assumes we've been loaded into RAM by some
* other agent (eg FLEX or Camelforth), and that the MMU has
* already been initialised. If we wanted to actually start from
* ROM would need to detect ROM and either copy to RAM and init
* MMU or make location of wsstart variable and change it
* accordingly.
frmflx
reset           orcc #$FF       ;Disable interrupts.
                lda #wsstart/256
                tfr a,dp        ;Set direct page register
                clr <disflg
                lds #ramfree    ;Stack grows down from here
                ldx #intvectbl  ;ROM location of exception vector table
                ldu #swi3vec    ;destination in RAM
                ldb #intvecend-intvectbl
                bsr blockmove   ;Initialize interrupt vectors from ROM.
                ldx #osvectbl   ;ROM location of I/O vector table
                ldu #getchar    ;destination in RAM
                ldb #osvecend-osvectbl
                bsr blockmove   ;Initialize I/O vectors from ROM.

                bsr initacia    ;Initialize serial port.
                andcc #$0       ;Enable interrupts
* Put the 'saved' registers of the program being monitored on top of the
* stack. There are 12 bytes on the stack: cc,a,b,dp,xh,xl,yh,yl,uh,ul,pch,pcl
* pc is initialized to ramstart, the rest to zero.
                ldx #0
                tfr x,y
                ldu #ramstart
                pshs x,u
                pshs x,y
                pshs x,y
                ldx #oldpc
                ldb #endvars-oldpc
clvar           clr ,x+
                decb
                bne clvar       ;Clear the variable area.
                ldd #$1A03
                std filler      ;Set XMODEM filler and end-of-line.
                ldx #welcome
                jsr outnts
                jsr <putcr      ;Print a welcome message.
                jmp cmdline

***************************************************************
* Block move routine, from X to U length B. Modifies them all and A.
blockmove       lda ,x+
                sta ,u+
                decb
                bne blockmove
                rts

***************************************************************
* Initialize serial communications port, buffers, interrupts.
*
* 7              0 }disable Rx int enable
* 6 TC2          0  }rts low, no tx interrupt
* 5 TC1          0  }
* 4 WS3          1   }8bit data, 1 stop bit
* 3 WS2          0   }
* 2 WS1          1   }
* 1 DIV2         1    }/64
* 0 DIV1         0    }

initacia        ldb #$03
                stb aciactl         * Master reset
                ldb #$16
                stb aciactl         * Setup as above
                ldb #%00110101
                rts

***************************************************************
* O.S. routine to read a character into B register.
osgetc          ldb aciasta
                bitb #$01
                beq osgetc
                ldb aciadat
                rts

***************************************************************
* O.S. routine to check if there is a character ready to be read.
osgetpoll       ldb aciasta
                bitb #$01
                bne poltrue
                clrb
                rts
poltrue         ldb #$ff
                rts

***************************************************************
* O.S. routine to write the character in the B register.
osputc          pshs a
putcloop        lda aciasta
                bita #$02
                beq putcloop
                stb aciadat
                puls a
                rts

***************************************************************
* O.S. routine to read a line into memory at address X, at most B chars
* long, return actual length in B. Permit backspace editing.
osgetl          pshs a,x
                stb <temp
                clra
osgetl1         jsr <getchar
                andb #$7F
                cmpb #BS
                beq backsp
                cmpb #DEL
                bne osgetl2
backsp          tsta                  ;Recognize BS and DEL as backspace key.
                beq osgetl1           ;ignore if line already zero length.
                ldb #BS
                jsr <putchar
                ldb #' '
                jsr <putchar
                ldb #BS               ;Send BS,space,BS. This erases last
                jsr <putchar          ;character on most terminals.
                leax -1,x             ;Decrement address.
                deca
                bra osgetl1
osgetl2         cmpb #CR
                beq newline
                cmpb #LF
                bne osgetl3           ;CR or LF character ends line.
                ldb lastterm
                cmpb #CR
                beq osgetl1           ;Ignore LF if it comes after CR
                ldb #LF
newline         stb lastterm
                jsr <putcr
                tfr a,b               ;Move length to B
                puls a,x              ;restore registers.
                rts                   ;<--- Here is the exit point.
osgetl3         cmpb #TAB
                beq dotab
                cmpb #' '
                blo osgetl1           ;Ignore control characters.
                cmpa <temp
                beq osgetl1           ;Ignore char if line full.
                jsr <putchar          ;Echo the character.
                stb ,x+               ;Store it in memory.
                inca
                bra osgetl1
dotab           ldb #' '
                cmpa <temp
                beq osgetl1
                jsr <putchar
                stb ,x+
                inca
                bita #7               ;Insert spaces until length mod 8=0
                bne dotab
                bra osgetl1

***************************************************************
* O.S. routine to write a line starting at address X, B chars long.
osputl          pshs a,b,x
                tfr b,a
                tsta
                beq osputl1
osputl2         ldb ,x+
                jsr <putchar
                deca
                bne osputl2
osputl1         puls a,b,x
                rts

***************************************************************
* O.S. routine to terminate a line.
oscr            pshs b
                ldb #CR
                jsr <putchar
                ldb #LF
                jsr <putchar          ;Send the CR and LF characters.
                puls b
                rts

***************************************************************
* Output a null-terminated string at addr X
outnts          pshs x,b
outnts1         ldb ,x+
                beq outnts2
                jsr <putchar
                bra outnts1
outnts2         puls x,b
                rts

***************************************************************
timerirq        inc <timer+2     ; [NAC HACK 2015Jul15] surely this is backwards? LSbyte s/b timer
                bne endirq
                inc <timer+1
                bne endirq
                inc <timer
                rti

***************************************************************
aciairq         nop
endirq          rti

***************************************************************
* Wait D times 20ms.
osdly           addd <timer+1
dlyloop         cmpd <timer+1
                bne dlyloop
                rts

***************************************************************
* The J command returns here.
stakregs        pshs x               ;Stack something where the pc comes
                pshs cc,b,a,dp,x,y,u ;Stack the normal registers.
                ldx oldpc
                stx 10,s             ;Stack the old pc value.
                bra unlaunch1
* The G and P commands return here through a breakpoint.
* Registers are already stacked.
unlaunch        ldd 10,s
                subd #1
                std 10,s             ;Decrement pc before breakpoint
unlaunch1       andcc #$0            ;reenable the interrupts.
                lda #wsstart/256
                tfr a,dp             ;Restore direct page register for buggy
                jsr disarm           ;Disarm the breakpoints.
                jsr dispregs
cmdline         jsr <xcloseout
                sts savesp
                ldb #'.'
                jsr <putchar
                ldx #linebuf
                ldb #buflen
                jsr <getline
                tstb
                beq cmdline          ;Ignore line if it is empty
                abx
                clr ,x               ;Make location after line zero.
                ldx #linebuf
                ldb ,x+
                andb #CASEMASK       ;Make 1st char uppercase.
                subb #'A'
                bcs unk
                cmpb #26
                bcc unk              ;Unknown cmd if it is not a letter.
                ldx #cmdtab
                aslb                 ;Index into command table.
                jmp [b,x]

***************************************************************
* Error: bad command arguments
argerr          jsr <xabortin
                ldx #badargs
                jsr outnts
                jsr <putcr
                jmp cmdline

***************************************************************
* Command: Unknown command handling routine.
unk             jsr <xabortin
                ldx #unknown
                jsr outnts
                jsr <putcr
                jmp cmdline

***************************************************************
* Command: H, help
help            ldx #mhelp           ;Print a help message.
                jsr outnts
                jmp cmdline

***************************************************************
* Output hex digit contained in A
hexdigit        adda #$90
                daa
                adca #$40
                daa             ;It's the standard conversion trick ascii
                tfr a,b         ;to hex without branching.
                jsr <putchar
                rts

***************************************************************
* Output contents of A as two hex digits
outbyte         pshs a
                lsra
                lsra
                lsra
                lsra
                bsr hexdigit
                puls a
                anda #$0f
                bra hexdigit

***************************************************************
* Output contents of d as four hex digits
outd            pshs b
                bsr outbyte
                puls a
                bsr outbyte
                rts

***************************************************************
* Skip X past spaces, B is first non-space character.
skipspace       ldb ,x+
                cmpb #' '
                beq skipspace
                rts

***************************************************************
* Convert ascii hex digit in B register to binary Z flag set if no hex digit.
convb           subb #'0'
                blo convexit
                cmpb #9
                bls cb2
                andb #CASEMASK ;Make uppercase.
                subb #7         ;If higher than digit 9 it must be a letter.
                cmpb #9
                bls convexit
                cmpb #15
                bhi convexit
cb2             andcc #$FB      ;clear zero
                rts
convexit        orcc #$04
                rts

***************************************************************
scanexit        ldd <temp
                leax -1,x
                tst <temp2
                rts             <-- exit point of scanhex

* Scan for hexadecimal number at address X return in D.
* Z flag is set if no number found.
scanhex         clr <temp
                clr <temp+1
                clr <temp2
                bsr skipspace
scloop          jsr convb
                beq scanexit
                pshs b
                ldd <temp
                aslb
                rola
                aslb
                rola
                aslb
                rola
                aslb
                rola
                addb ,s+
                std <temp
                inc <temp2
                ldb ,x+
                bra scloop

scan2parms      std length
                bsr scanhex
                beq sp2
                std addr
                bsr skipspace
                cmpb #','
                bne sp2
                bsr scanhex
                beq sp2
                std length
sp2             rts

***************************************************************
* Scan two hexdigits at X in and convert to byte into A, Z flag if error.
scanbyte        bsr skipspace
                bsr convb
                beq sb1
                tfr b,a
                ldb ,x+
                bsr convb
                beq sb1
                asla
                asla
                asla
                asla
                stb <temp
                adda <temp
                andcc #$fb      ;Clear zero flag
sb1             rts

***************************************************************
* Command: D hex/ascii dump of memory
* Syntax: D or Daddr or Daddr,length
dump            ldx #linebuf+1
                ldd #$40
                jsr scan2parms  ;Scan address and length, default length=64
                ldy addr
dh1             lda #16
                sta <temp+1
                tfr y,d
                jsr outd
                ldb #' '
                jsr <putchar
dh2             lda ,y+         ;display row of 16 mem locations as hex
                jsr outbyte
                ldb #' '
                lda <temp+1
                cmpa #9
                bne dh6
                ldb #'-'        ;Do a - after the eighth byte.
dh6             jsr <putchar
                dec <temp+1
                bne dh2
                leay -16,y      ;And now for the ascii dump.
                lda #16
dh3             ldb ,y+
                cmpb #' '
                bhs dh4
                ldb #'.'
dh4             cmpb #DEL
                blo dh5
                ldb #'.'        ;Convert all nonprintables to .
dh5             jsr <putchar
                deca
                bne dh3
                jsr <putcr
                ldd length
                subd #16
                std length
                bhi dh1
                sty addr
                jmp cmdline

***************************************************************
* Command: E, enter hex bytes or ascii string.
* Syntax E or E<addr> or E<addr> <bytes> or E<addr>"string"
* [NAC HACK 2015Jul12] bytes need to be 2 characters.
* . to exit, - to go back 1 location
enter           ldx #linebuf+1
                jsr scanhex
                beq ent1
                std addr
ent1            bsr entline
                lbne cmdline    ;No bytes, then enter interactively.
ent2            ldd addr
                jsr outd
                ldb #' '
                jsr <putchar    ;Display addr + space
                lda [addr]
                jsr outbyte
                ldb #' '
                jsr <putchar
                ldx #linebuf
                ldb #buflen
                jsr <getline    ;Get the line.
                tstb
                beq skipbyte
                abx
                clr ,x
                ldx #linebuf
                bsr entline
                bne ent2
                jmp cmdline
skipbyte        ldd addr
                addd #1
                std addr
                bra ent2

***************************************************************
* Enter a line of hex bytes or ASCII string at address X, Z if empty.
entline         jsr skipspace
                tstb
                beq entexit
                cmpb #'.'       ; . to exit
                beq entexit

                cmpb #'-'       ; - to go back 1 location
                bne entnbk
                ldy addr
                leay -1,y
                bra entdone

entnbk          cmpb #'"'       ; " to start string
                beq entasc
                leax -1,x
                ldy addr
entl2           jsr scanbyte    ; Enter hex digits.
                beq entdone
                sta ,y+
                bra entl2

entasc          ldy addr
entl3           lda ,x+
                tsta
                beq entdone
                cmpa #'"'       ; " to end string
                beq entdone
                sta ,y+
                bra entl3
entdone         sty addr
                andcc #$fb
                rts
entexit         orcc #$04
                rts

***************************************************************
* Command: I, inspect the contents of an address
* Syntax: Iaddr
inp             ldx #linebuf+1
                jsr scanhex
                tfr d,x
                lda ,x          ;Read the byte from memory.
                jsr outbyte     ;Display it in hex.
                jsr <putcr
                jmp cmdline

***************************************************************
* Command: C, calculate result of simple hex expression
*Syntax Chexnum{+|-hexnum}
calc            ldx #linebuf+1
                jsr scanhex
                std <temp3
hexloop         jsr skipspace
                cmpb #'+'
                bne hex1
                jsr scanhex
                addd <temp3
                std <temp3
                bra hexloop
hex1            cmpb #'-'
                bne hexend
                jsr scanhex
                comb
                coma
                addd #1
                addd <temp3
                std <temp3
                bra hexloop
hexend          ldd <temp3
                jsr outd
                jsr <putcr
                jmp cmdline

***************************************************************
* Command: G, jump (go) to the program
* Syntax G or G<addr>
go              ldx #linebuf+1
                jsr scanhex
                beq launch
                std 10,s        ;Store parameter in pc location.
launch          jsr arm         ;Arm the breakpoints.
                puls cc,b,a,dp,x,y,u,pc

***************************************************************
* Command: J, run a subroutine
* Syntax J<addr>
jump            ldx #linebuf+1
                ldd 10,s
                std oldpc       ;Save old pc
                jsr scanhex
                std 10,s        ;Store parameter in PC location
                tfr s,x
                leas -2,s
                tfr s,u
                ldb #12         ;Move the saved register set 2 addresses
                jsr blockmove   ;down on the stack.
                ldd #stakregs
                std 12,s        ;Prepare subroutine return address.
                bra launch      ;Jump to the routine.


***************************************************************
* Command: P, run instruction followed by breakpoint
* Syntax P
prog            ldy 10,s        ;Get program counter value.
                jsr disdecode   ;Find out location past current insn.
                sty stepbp
                bra launch

***************************************************************
* Command: T, single step trace an instruction.
* Syntax T

*[NAC HACK 2015Jul15] this should work with multicomp09, too. It expects
* a 50Hz timer, which I have. It expects the timer to be wired to FIRQ
* but mine is wired to IRQ (easy to change..)
* the timing below is tuned for clocks = processor cycles so needs
* adjustment for my divided clock with accelerated internal cycles.
* The idea of switching the interrupt vector seems to mean that the
* timer will run slow when single step is in use: the interrupt that
* goes through SYNC will not increment the timer and the single step
* interrupt will not increment the timer.
* might be nicer to have a flag in the ISR that determines whether a
* single step is in progress. Then, can do the timer stuff as well.
* Saves messing with the vector so might all take more or less the
* same amount of code and complexity.


trace           jsr traceone
                jsr dispregs
                jmp cmdline

traceone        orcc #$50       ;Disable the interrupts.
                ldd ,s++
                std oldpc       ;Remove saved pc from stack.
                ldd #traceret
                std firqvec+1   ;Adjust timer IRQ vector.
                sync            ;Synchronize on the next timer interrupt.
                                ;1 cycle
                ldx #4441       ;3 cycles
traceloop       leax -1,x       ;6 cycles\x4441= 39969 cycles.
                bne traceloop   ;3 cycles/
                nop             ;2 cycles.
                nop             ;2 cycles.
                nop             ;2 cycles.
                brn traceret    ;3 cycles.
                puls x,y,u,a,b,dp,cc,pc ;17 cycles, total=39999 20ms @ 2MHz
                                        ;Pull all registers and execute.
                                        ;Is timed such that next timer IRQ
                                        ;occurs right after it.
traceret        puls cc
                pshs x,y,u,a,b,dp,cc;Store full register set instead of cc.
                ldd #timerirq
                std firqvec+1   ;Restore timer IRQ vector.
                jmp [oldpc]

***************************************************************
* Display the contents of 8 bit register, name in B, contents in A
disp8           jsr <putchar
                ldb #'='
                jsr <putchar
                jsr outbyte
                ldb #' '
                jsr <putchar
                rts

***************************************************************
* Display the contents of 16 bit register, name in B, contents in Y
disp16          jsr <putchar
                ldb #'='
                jsr <putchar
                tfr y,d
                jsr outd
                ldb #' '
                jsr <putchar
                rts

***************************************************************
* Display the contents of the registers and disassemble instruction at
* PC location.
dispregs        ldb #'X'
                ldy 6,s         ;Note that there's one return address on
                bsr disp16      ;stack so saved register offsets are
                ldb #'Y'        ;inremented by 2.
                ldy 8,s
                bsr disp16
                ldb #'U'
                ldy 10,s
                bsr disp16
                ldb #'S'
                tfr s,y
                leay 14,y       ;S of the running program is 12 higher,
                                ;because regs are not stacked when running.
                bsr disp16
                ldb #'A'
                lda 3,s
                bsr disp8
                ldb #'B'
                lda 4,s
                bsr disp8
                ldb #'D'
                lda 5,s
                bsr disp8
                ldb #'C'
                lda 2,s
                bsr disp8
                ldb #'P'
                ldy 12,s
                bsr disp16
                jsr disdecode
                jsr disdisp       ;Disassemble instruction at PC
                jsr <putcr
                rts

***************************************************************
* Command: R, display or alter the registers.
* Syntax R or R<letter><hex>
regs            ldx #linebuf+1
                jsr skipspace
                tstb
                bne setreg
                bsr dispregs    ;Display regs if nothing follows.
                jmp cmdline
setreg          ldy #regtab
                clra
                andb #CASEMASK  ;Make letter uppercase.
sr1             tst ,y
                lbeq argerr     ;At end of register tab, unknown reg
                cmpb ,y+
                beq sr2         ;Found the register?
                inca
                bra sr1
sr2             pshs a
                jsr scanhex     ;Convert the hex argument.
                pshs d
                lda 2,s         ;Get register number.
                cmpa #4
                bcc sr3
                ldb 1,s         ;It's 8 bit.
                leas 3,s        ;Remove temp stuff from stack.
                stb a,s         ;Store it in the reg on stack.
                jmp cmdline
sr3             cmpa #8
                bcc sr4
                puls x          ;It's 16 bit.
                leas 1,s
                lsla
                suba #4         ;Convert reg no to stack offset.
                stx a,s
                jmp cmdline
sr4             puls u          ;It's the stack pointer.
                leas 1,s
                leau -12,u
                tfr s,x
                tfr u,s         ;Set new stack pointer.
                ldb #12
                jsr blockmove   ;Move register set to new stack location.
                jmp cmdline

regtab          FCC "CABDXYUPS "

***************************************************************
* Disarm the breakpoints, this is replace the SWI instructions with the
* original byte.
disarm          ldx #bpaddr
                lda #brkpoints+1
disarm1         ldu ,x++
                ldb ,x+         ;Get address in u, byte in b
                cmpu #0
                beq disarm2
                stb ,u
disarm2         deca
                bne disarm1
                ldu #0
                stu -3,x        ;Clear the step breakpoint.
                rts

***************************************************************
* Arm the breakpoints: replace the byte at each breakpoint address
* with an SWI instruction.
arm             ldx #brkpoints*3+bpaddr ; [NAC HACK 2015Aug23] portability: AS9 eval l->r
                lda #brkpoints+1  ;Arm them in reverse order of disarming.
arm1            ldu ,x       ;Get address in u.
                beq arm2
                ldb ,u
                stb 2,x
                cmpu 12,s      ;Compare to program counter location
                beq arm2
                ldb #$3F
                stb ,u         ;Store SWI instruction if not equal.
arm2            leax -3,x
                deca
                bne arm1
                rts

***************************************************************
* Command: B, set, clear display breakpoints.
* Syntax B or B<addr>. B displays, B<addr> sets or clears breakpoint.
break           lda #brkpoints
                sta <temp2+1    ;Store number of breakpoints to visit.
                ldx #linebuf+1
                jsr scanhex
                beq dispbp      ;No number then display breakpoints
                ldx #bpaddr
                ldu #0
                tfr u,y
bp1             cmpd ,x
                beq clearit     ;Found the breakpoint, so clear it,
                cmpu ,x         ;Is location zero
                bne bp2
                tfr x,y         ;Set free address to y
bp2             leax 3,x
                dec <temp2+1
                bne bp1
                cmpy #0         ;Address not found in list of breakpoints
                beq bpfull      ;Was free address found.
                std ,y          ;If so, store breakpoint there.
                ldx #brkmsg
bpexit          jsr outnts
                jsr <putcr
                jmp cmdline
clearit         clra
                clrb
                std ,x
                ldx #clrmsg
                bra bpexit
bpfull          ldx #fullmsg
                bra bpexit

dispbp          ldx #bpaddr
dbp1            ldd ,x
                beq dbp2
                jsr outd
                ldb #' '
                jsr <putchar
dbp2            leax 3,x
                dec <temp2+1
                bne dbp1
                jsr <putcr
                jmp cmdline

***************************************************************
* Scan hex byte into a and add it to check sum in temp2+1
addchk          jsr scanbyte
                lbeq srecerr
                tfr a,b
                addb <temp2+1
                stb <temp2+1
                rts

***************************************************************
* Command: S, load/dump memory using Motorola S record format
* Syntax SO<addr> or or S1<bytes> or S9<bytes> to load memory
* Syntax SS<addr>,<len> to dump memory
srec            ldx #linebuf+1
                ldb ,x+
                andb #CASEMASK
                cmpb #'O'
                beq setsorg
                cmpb #'S'
                beq sendrec
                ldb -1,x
                clr <temp3
                cmpb #'1'
                beq readrec
                cmpb #'9'
                bne srecerr
                inc <temp3
readrec         clr <temp2+1    ;clear checksum.
                bsr addchk
                suba #2         ;discount the address bytes from the count.
                sta <temp3+1    ;Read length byte.
                bsr addchk
                pshs a
                bsr addchk
                puls b
                exg a,b         ;Read address into d.
                ldu sorg
                beq rr1
                ldu soffs
                bne rr1
                pshs d          ;Sorg is nonzero and soffs is zero, now
                subd sorg       ;set soffs
                std soffs
                puls d
rr1             subd soffs      ;Subtract the address offset.
                tfr d,y
rr2             bsr addchk
                dec <temp3+1
                beq endrec
                sta ,y+
                bra rr2
endrec          inc <temp2+1    ;Check checksum.
                bne srecerr
                tst <temp3
                lbeq cmdline    ;Was it no S9 record?
                cmpy #0
                beq endrec1
                sty 10,s        ;Store address into program counter.
endrec1         clra
                clrb
                std sorg        ;Reset sorg, next S loads will be normal.
                std soffs
                jmp cmdline
srecerr         jsr <xabortin
                ldx #smsg       ;Error in srecord, display message.
                jsr outnts
                jsr <putcr
                jmp cmdline
setsorg         jsr scanhex     ;Set S record origin.
                std sorg
                clra
                clrb
                std soffs
                jmp cmdline
* Send a memory region as S-records.
sendrec         ldd #$100       ;Scan address and length parameter.
                jsr scan2parms
                ldd sorg
                beq ss1
                ldd addr
                subd sorg
                std soffs       ;Compute offset for origin.
ss1             ldd length
                beq endss       ;All bytes sent?
                cmpd #16
                blo ss2
                ldb #16         ;If more than 16 left, then send 16.
ss2             stb <temp
                negb
                ldu length
                leau b,u
                stu length      ;Discount line length from length.
                ldb #'S'
                jsr <putchar
                ldb #'1'
                jsr <putchar
                clr <temp+1     ;Clear check sum
                ldb <temp
                addb #3
                bsr checkout    ;Output byte b as hex and add to check sum.
                ldd addr
                tfr d,y
                subd soffs
                exg a,b
                bsr checkout
                exg a,b
                bsr checkout    ;Output address (add into check sum)
ss3             ldb ,y+
                bsr checkout
                dec <temp
                bne ss3
                sty addr
                ldb <temp+1
                comb
                bsr checkout    ;Output checksum byte.
                jsr <putcr
                bra ss1
endss           ldx #lastrec
                jsr outnts
                jsr <putcr
                jmp cmdline
* Output byte in register B and add it into check sum at temp+1
checkout        pshs a
                tfr b,a
                addb <temp+1
                stb <temp+1
                jsr outbyte
                puls a
                rts

***************************************************************
* Command: M, move memory region.
* Syntax: Maddr1,addr2,length
move            ldx #linebuf+1
                jsr scanhex
                lbeq argerr
                std <temp3
                jsr skipspace
                cmpb #','
                lbne argerr
                jsr scanhex
                lbeq argerr
                tfr d,u
                jsr skipspace
                cmpb #','
                lbne argerr
                jsr scanhex
                lbeq argerr
                tfr d,y         ;Read the argument separated by commas
                ldx <temp3      ;src addr to x, dest addr to u, length to y
                                ;Don't tolerate syntax deviations.
mvloop          lda ,x+
                sta ,u+
                leay -1,y
                bne mvloop      ;Perform the block move.
                jmp cmdline

***************************************************************
* Command: F, find byte/ascii string in memory.
* Syntax: Faddr bytes or Faddr "ascii"
find            ldx #linebuf+1
                jsr scanhex
                tfr d,y         ;Scan the start address.
                jsr skipspace
                cmpb #'"'
                bne findhex
                ldu #linebuf    ;Quote found, so scan for quoted string.
                clra
fstrloop        ldb ,x+
                beq startsrch   ;End of line without final quote.
                cmpb #'"'
                beq startsrch   ;End quote found
                stb ,u+
                inca
                bra fstrloop
findhex         ldu #linebuf    ;Convert string of hex bytes.
                leax -1,x       ;String will be stored at start of line
                clra            ;buffer and may overwrite part of the
fhexloop        pshs a          ;already converted string.
                jsr scanbyte
                tfr a,b
                puls a
                beq startsrch
                stb ,u+
                inca
                bra fhexloop
startsrch       tsta            ;Start searching, start addr in Y,
                                ;string starts at linebuf, length A
                lbeq cmdline    ;Quit with zero length string.
                clr <temp3
                sta <temp3+1
srchloop        tfr y,x
                lda <temp3+1
                cmpx #$e100
                bcc srch1
                leax a,x
                cmpx #$e000     ;Stop at I/O addresses.
                lbcc cmdline
srch1           tfr y,x
                ldu #linebuf
srch2           ldb ,x+
                cmpb ,u+
                bne srch3       ;Not equal, try next address.
                deca
                bne srch2
                tfr y,d
                jsr outd        ;String found
                jsr <putcr
                inc <temp3
                lda <temp3
                cmpa #$10
                lbeq cmdline    ;If 10 matches found, just stop.
srch3           leay 1,y
                bra srchloop

***************************************************************
* Send the contents of the xmodem buffer and get it acknowledged,
* zero flag is set if transfer aborted.
xsendbuf        ldb #SOH
                jsr osputc      ;Send SOH
                ldb <xpacknum
                jsr osputc      ;Send block number.
                comb
                jsr osputc      ;and its complement.
                clr <xsum
                lda #128
                ldx #buf0
xsloop          ldb ,x
                addb <xsum
                stb <xsum
                ldb ,x+
                jsr osputc
                deca
                bne xsloop      ;Send the buffer contents.
                ldb <xsum
                jsr osputc      ;Send the check sum
waitack         jsr osgetc
                cmpb #CAN
                beq xsabt       ;^X for abort.
                cmpb #NAK
                beq xsendbuf    ;Send again if NAK
                cmpb #ACK
                bne waitack
                inc <xpacknum
xsok            andcc #$fb      ;Clear zero flag after ACK
xsabt           rts

***************************************************************
* Start an XMODEM send session.
xsendinit       ldb #1
                stb <xpacknum    ;Initialize block number.
waitnak         jsr osgetc
                cmpb #CAN
                beq xsabt      ;If ^X exit with zero flag.
                cmpb #NAK
                beq xsok
                bra waitnak    ;Wait until NAK received.

***************************************************************
* Send ETX and wait for ack.
xsendeot        ldb #EOT
                jsr osputc
waitack2        jsr osgetc
                cmpb #CAN
                beq xsabt
                cmpb #NAK
                beq xsendeot
                cmpb #ACK
                beq xsok
                bra waitack2

***************************************************************
* Read character into B with a timeout of A seconds,  Carry set if timeout.
gettimeout      asla
                ldb #50
                mul
                tfr b,a
                adda <timer+2
gt1             jsr osgetpoll
                tstb
                bne gtexit
                cmpa <timer+2
                bne gt1
                orcc #$1
                rts
gtexit          jsr osgetc
                andcc #$fe
                rts

***************************************************************
* Wait until line becomes quiet.
purge           lda #3
                jsr gettimeout
                bcc purge
                rts

***************************************************************
* Receive an XMODEM block and wait till it is OK, Z set if etx.
xrcvbuf         lda #3
                tst <lastok
                beq sendnak
                ldb #ACK
                jsr osputc      ;Send an ack.
                lda #5
                bra startblock
sendnak         ldb #NAK
                jsr osputc      ;Send a NAK
startblock      clr <lastok
                bsr gettimeout
                lda #3
                bcs sendnak     ;Keep sending NAKs when timed out.
                cmpb #EOT
                beq xrcveot     ;End of file reached, acknowledge EOT.
                cmpb #SOH
                bne purgeit     ;Not, SOH, bad block.
                lda #1
                bsr gettimeout
                bcs purgeit
                cmpb <xpacknum   ;Is it the right block?
                beq xr1
                incb
                cmpb <xpacknum   ;Was it the previous block.
                bne purgeit
                inc <lastok
xr1             stb <xsum
                lda #1
                bsr gettimeout
                bcs purgeit
                comb
                cmpb <xsum       ;Is the complement of the block number OK
                bne purgeit
                ldx #buf0
                clr <xsum
xrloop          lda #1
                bsr gettimeout
                bcs purgeit
                stb ,x+
                addb <xsum
                stb <xsum
                cmpx #buf0+128
                bne xrloop       ;Get the data bytes.
                lda #1
                bsr gettimeout
                bcs purgeit
                cmpb <xsum
                bne purgeit     ;Check the check sum.
                tst <lastok
                bne xrcvbuf     ;Block was the previous block, get next one
                inc <lastok
                inc <xpacknum
                andcc #$fb
                rts
purgeit         jsr purge
                bra sendnak
xrcveot         lda #3          ;EOT was received.
                ldb #ACK
ackloop         jsr osputc
                deca
                bne ackloop     ;Send 3 acks in a row.
                rts

***************************************************************
savevecs        ldx <getchar+1  ;+1 takes you past the JMP to the address
                stx oldgetc
                ldx <putchar+1
                stx oldputc
                ldx <putcr+1
                stx oldputcr
                clr lastterm
                rts

***************************************************************
rstvecs         ldx oldgetc
                stx <getchar+1
                ldx oldputc
                stx <putchar+1
                ldx oldputcr
                stx <putcr+1
                clr lastterm
                rts

***************************************************************
* O.S. routine to open input through XMODEM transfer.
xopin           pshs x,a,b
                ldx #xsmsg
                jsr outnts
                jsr <putcr       ;Display message to start XMODEM send.
                bsr savevecs
                ldx #noop
                stx <putchar+1   ;Disable character output.
                ldx #xgetc
                stx <getchar+1   ;
                clr <lastok
                clr <xcount
                lda #1
                sta <xpacknum
                inca
                sta <xmode       ;set xmode to 2.
                puls x,a,b,pc

***************************************************************
* O.S. routine to open output through XMODEM transfer.
xopout          pshs x,a,b
                bsr savevecs
                ldx #xrmsg
                jsr outnts       ;Display message to start XMODEM receive
                jsr <putcr
                ldx #xputc
                stx <putchar+1
                ldx #xputcr
                stx <putcr+1
                jsr xsendinit
                lbeq xerror
                clr <xcount
                lda #1
                sta <xmode
                puls x,a,b,pc

***************************************************************
* O.S. routine to abort input through XMODEM transfer.
xabtin          lda <xmode
                cmpa #2
                bne xclsend
                jsr purge
                ldb #CAN
                lda #8
xabtloop        jsr osputc
                deca
                bne xabtloop    ;Send 8 CAN characters to kill transfer.
                bsr rstvecs
                clr <xmode
                ldx #xamsg
                jsr outnts
                jsr <putcr       ;Send diagnostic message.
                rts

***************************************************************
* O.S. routine to close output through XMODEM transfer.
xclsout         lda <xmode
                cmpa #1
                bne xclsend
                tst <xcount
                beq xclsdone
                lda #128
                suba <xcount
xclsloop        ldb filler
                bsr xputc
                deca
                bne xclsloop    ;Transfer filler chars to force block out.
xclsdone        jsr xsendeot    ;Send EOT
                lbeq xerror
                jsr rstvecs
                clr <xmode
xclsend         rts

***************************************************************
* O.S. routine to close input through XMODEM, by gobbling up
* the remaining bytes.
xclsin          ldb <xmode
                cmpb #2
                bne xclsend
                jsr <putchar
                bra xclsin

***************************************************************
* putchar routine for XMODEM
xputc           pshs x,a,b
                lda <xcount
                inc <xcount
                ldx #buf0
                stb a,x         ;Store character in XMODEM buffer.
                cmpa #127
                bne xputc1      ;is buffer full?
                clr <xcount
                pshs y,u
                jsr xsendbuf
                lbeq xerror
                puls y,u
xputc1          puls x,a,b,pc

***************************************************************
* putcr routine for XMODEM
xputcr          pshs b
                ldb xmcr
                bitb #2
                beq xputcr1
                ldb #CR
                bsr xputc
xputcr1         ldb xmcr
                bitb #1
                beq xputcr2
                ldb #LF
                bsr xputc
xputcr2         puls b
                rts

***************************************************************
* getchar routine for XMODEM
xgetc           pshs x,a
                tst <xcount     ;No characters left?
                bne xgetc1
                pshs y,u
                jsr xrcvbuf     ;Receive new block.
                puls y,u
                beq xgetcterm   ;End of input?
                lda #128
                sta <xcount
xgetc1          lda <xcount
                nega
                ldx #buf0+128
                ldb a,x         ;Get character from buffer
                dec <xcount
                puls x,a,pc
xgetcterm       jsr rstvecs
                clr <xmode
                ldb filler
                puls x,a,pc

xerror          jsr rstvecs     ;Restore I/O vectors
                clr <xmode
                ldx #xamsg
                jsr outnts
                jsr <putcr
                jmp xerrvec

xerrhand        lds savesp
                jmp cmdline

***************************************************************
* Command: X, various XMODEM related commands.
* Syntax: XSaddr,len XLaddr,len XX XOcrlf,filler, XSSaddr,len
xmodem          ldx #linebuf+1
                lda ,x+
                anda #CASEMASK  ;Convert to uppercase.
                cmpa #'X'
                beq xeq
                cmpa #'L'
                beq xload
                cmpa #'O'
                beq xopts
                cmpa #'S'
                lbne unk
                lda ,x
                anda #CASEMASK
                cmpa #'S'
                beq xss
                ldd #$100            ;XSaddr,len command.
                jsr scan2parms       ;Send binary through XMODEM
                jsr <xopenout
                ldu addr
                ldy length
xsbinloop       ldb ,u+
                jsr <putchar
                leay -1,y
                bne xsbinloop        ;Send all the bytes through XMODEM.
                jmp cmdline
xss             leax 1,x             ;XSSaddr,len command.
                jsr <xopenout        ;Send Srecords through XMODEM
                jmp sendrec
xload           jsr scanhex          ;XLaddr command
                tfr d,y              ;Load binary through XMODEM
                jsr <xopenin
xlodloop        jsr <getchar
                tst <xmode           ;File ended? then done
                lbeq cmdline
                stb ,y+
                bra xlodloop
xeq             jsr <xopenin          ;XX command
                jmp cmdline          ;Execute commands received from XMODEM
xopts           ldd #$1a
                jsr scan2parms
                lda addr+1
                sta xmcr
                lda length+1
                sta filler
                jmp cmdline

***************************************************************
* Decode instruction pointed to by Y for disassembly (and to
* find out how long it is). On return, U points to appropriate
* mnemonic table entry, Y points past instruction.
* It's rather clumsy code, but we want to reuse the same table
* as used with assembling.
disdecode       clr prebyte
                clr amode
                lda ,y+
                cmpa #$10
                beq ddec1
                cmpa #$11
                bne ddec2
ddec1           sta prebyte         ;Store $10 or $11 prebyte.
                lda ,y+             ;Get new opcode.
ddec2           sta opcode
                lsra
                lsra
                lsra
                lsra                ;Get high nibble.
                ldx #modetab
                ldb a,x
                stb amode
                ldx #opcoffs
                lda a,x
                adda opcode         ;Add opcode offset to opcode.
ddec4           sta opc1            ;Store the 'basis' opcode.
                ldu #mnemtab
                ldx #mnemsize
ddecloop        ldb #13
                cmpb 5,u            ;Compare category code with 13
                beq ddec3           ;13=pseudo op, no valid opcode
                ldd prebyte
                cmpd 6,u
                beq ddecfound       ;Opcode&prebyte agree, operation found.
ddec3           leau 8,u            ;point to next mnemonic
                leax -1,x
                bne ddecloop
                ldu #mnemfcb        ;mnemonic not found, use FCB byte.
                lda #3
                sta amode           ;Store mode 3, 8 bit address.
                lda opcode
                tst prebyte
                beq ddec5
                lda prebyte         ;if it was the combination prebyte
                clr prebyte         ;and opcode that was not found,
                leay -1,y           ;FCB just the prebyte
ddec5           sta operand+1       ;The byte must be stored as operand.
                rts
ddecfound       cmpu #mnembsr
                bne ddec6
                lda #$8d            ;Is it really the BSR opcode?
                cmpa opcode
                beq ddec6
                ldu #mnemjsr        ;We mistakenly found BSR instead of JSR
ddec6           lda amode
                anda #$FE
                bne ddec7
                lda 5,u             ;nibble-dependent mode was 0 or 1,
                ldx #modetab2       ;use category dependent mode instead.
                lda a,x
                sta amode
ddec7           lda amode
                asla
                ldx #disdectab
                jmp [a,x]           ;jump dependent on definitive mode.
disdectab       fdb noop,opdec1,opdec2,opdec1,opdec2,opdecidx
                fdb opdec1,opdec2,opdecpb,opdecpb
disdectab1      fdb noop,noop,noop,noop,noop,noop,noop,noop
                fdb opdec1,opdec2,noop,noop,opdec1,opdec2,noop,opdec2
opdec1          ldb ,y+
                sex
od1a            std operand
noop            rts
opdec2          ldd ,y++
                bra od1a
opdecpb         ldb ,y+
odpa            stb postbyte
                rts
opdecidx        ldb ,y+
                bpl odpa             ;postbytes <$80 have no extra operands.
                stb postbyte
                andb #$0f
                aslb
                ldx #disdectab1
                jmp [b,x]

***************************************************************
* Display disassembled instruction after the invocation of
* disdecode. U points to mnemonic table entry.
disdisp         tfr u,x
                ldb #5
                jsr <putline         ;Display the mnemonic.
                ldb #' '
                jsr <putchar
                lda amode
                asla
                ldx #disdisptab
                jmp [a,x]            ;Perform action dependent on mode.

disdisptab      fdb noop,disim8,disim16,disadr8,disadr16
                fdb disidx,disrel8,disrel16,distfr,dispush

disim8          bsr puthash
                bra disadr8
disim16         bsr puthash
disadr16        bsr putdol
                ldd operand
                jmp outd
disadr8         bsr putdol
                lda operand+1
                jmp outbyte
disrel8         bsr putdol
                ldb operand+1
                sex
dr8a            sty <temp
                addd <temp
                jmp outd
disrel16        bsr putdol
                ldd operand
                bra dr8a

***************************************************************
puthash         ldb #'#'
                jmp <putchar
putdol          ldb #'$'
                jmp <putchar
putcomma        ldb #','
                jmp <putchar
putspace        ldb #' '
                jmp <putchar

***************************************************************
dispush         ldb #12
                ldx #asmregtab       ;Walk through the register table.
                clr <temp
regloop         lda postbyte
                anda 4,x
                beq dispush1         ;Is bit corresponding to reg set in postbyte
                cmpx #aregu
                bne dispush3
                sta <temp+1
                lda opcode
                anda #2
                bne dispush1         ;no u register in pshu pulu.
                lda <temp+1
dispush3        cmpx #aregs
                bne dispush4
                sta <temp+1
                lda opcode
                anda #2
                beq dispush1         ;no s register in pshs puls.
                lda <temp+1
dispush4        coma
                anda postbyte        ;remove the bits from postbyte.
                sta postbyte
                pshs b
                tst <temp
                beq dispush2
                bsr putcomma         ;print comma after first register.
dispush2        bsr disregname
                inc <temp
                puls b
dispush1        leax 5,x
                decb
                bne regloop
                rts

***************************************************************
distfr          lda postbyte
                lsra
                lsra
                lsra
                lsra
                bsr distfrsub
                bsr putcomma
                lda postbyte
                anda #$0f
distfrsub       ldb #12
                ldx #asmregtab
distfrloop      cmpa 3,x
                beq distfrend
                leax 5,x
                decb
                bne distfrloop
distfrend       bsr disregname
                rts

***************************************************************
disregname      lda #3
                tfr x,u
drnloop         ldb ,u+
                cmpb #' '
                beq drnend
                jsr <putchar
                deca
                bne drnloop
drnend          rts

***************************************************************
disidxreg       lda postbyte
                lsra
                lsra
                lsra
                lsra
                lsra
                anda #3
                ldx #ixregs
                ldb a,x
                jmp <putchar

***************************************************************
disidx          clr <temp
                lda postbyte
                bmi disidx1
                anda #$1f
                bita #$10
                bne negoffs
                jsr outdecbyte
                bra discomma
negoffs         ldb #'-'
                jsr <putchar
                ora #$f0
                nega
                jsr outdecbyte
discomma        jsr putcomma         ;Display ,Xreg and terminating ]
disindex        bsr disidxreg
disindir        tst <temp            ;Display ] if indirect.
                beq disidxend
                ldb #']'
                jsr <putchar
disidxend       rts
disidx1         bita #$10
                beq disidx2
                ldb #'['
                jsr <putchar
                inc <temp
disidx2         lda postbyte
                anda #$0f
                asla
                ldx #disidxtab
                jmp [a,x]            ;Jump to routine for indexed mode
disadec2        lda #2
                bra disadeca
disadec1        lda #1
disadeca        jsr putcomma
disadloop       ldb #'-'
                jsr <putchar
                deca
                bne disadloop
                bra disindex
disainc2        lda #2
                bra disainca
disainc1        lda #1
disainca        sta <temp+1
                jsr putcomma
                jsr disidxreg
                lda <temp+1
disailoop       ldb #'+'
                jsr <putchar
                deca
                bne disailoop
                jmp disindir
disax           ldb #'A'
                jsr <putchar
                jmp discomma
disbx           ldb #'B'
                jsr <putchar
                jmp discomma
disdx           ldb #'D'
                jsr <putchar
                jmp discomma
disinval        ldb #'?'
                jsr <putchar
                jmp disindir
disnx           lda operand+1
                bmi disnxneg
disnx1          jsr putdol
                jsr outbyte
                jmp discomma
disnxneg        ldb #'-'
                jsr <putchar
                nega
                bra disnx1
disnnx          jsr putdol
                ldd operand
                jsr outd
                jmp discomma
disnpc          jsr putdol
                ldb operand+1
                sex
disnpca         sty <temp2
                addd <temp2
                jsr outd
                ldx #commapc
                ldb #4
                jsr <putline
                jmp disindir
disnnpc         jsr putdol
                ldd operand
                bra disnpca
disdirect       jsr putdol
                ldd operand
                jsr outd
                jmp disindir

commapc         fcc ",PCR"

disidxtab       fdb disainc1,disainc2,disadec1,disadec2
                fdb discomma,disbx,disax,disinval
                fdb disnx,disnnx,disinval,disdx
                fdb disnpc,disnnpc,disinval,disdirect

***************************************************************
* Display byte A in decimal (0<=A<20)
outdecbyte      cmpa #10
                blo odb1
                suba #10
                ldb #'1'
                jsr <putchar
odb1            adda #'0'
                tfr a,b
                jmp <putchar

***************************************************************
* Command: U, unassemble instructions in memory.
* Syntax: U or Uaddr or Uaddr,length
unasm           bsr disasm
                jmp cmdline
disasm          ldx #linebuf+1
                ldd #20
                jsr scan2parms ;Scan address,length parameters.
dis1            ldd addr
                addd length
                std length
                ldy addr
unasmloop       tfr y,d
                jsr outd       ;Display instruction address
                jsr putspace
                pshs y
                jsr disdecode
                puls x
                sty <temp
                clr <temp2
unadishex       lda ,x+
                jsr outbyte
                inc <temp2
                inc <temp2
                cmpx <temp
                bne unadishex  ;Display instruction bytes as hex.
unadisspc       ldb #' '
                jsr <putchar
                inc <temp2
                lda #11
                cmpa <temp2    ;Fill out with spaces to width 11.
                bne unadisspc
                bne unadishex
                jsr disdisp    ;Display disassembled instruction.
                tst <disflg
                bne skipcr     ;Assembling; stay on this line
                jsr <putcr
skipcr          cmpy length
                bls unasmloop
                sty addr
                rts

***************************************************************
* Simple 'expression evaluator' for assembler.
expr            ldb ,x
                cmpb #'-'
                bne pos
                clrb
                leax 1,x
pos             pshs b
                bsr scanfact
                beq exprend1
                tst ,s+
                bne exprend     ;Was the minus sign there.
                coma
                comb
                addd #1
                andcc #$fb      ;Clear Z flag for valid result.
exprend         rts
exprend1        puls b
                rts

***************************************************************
scanfact        ldb ,x+
                cmpb #'$'
                lbeq scanhex   ;Hex number if starting with dollar.
                cmpb #'''
                bne scandec    ;char if starting with ' else decimal
                ldb ,x+
                lda ,x
                cmpa #'''
                bne scanchar2
                leax 1,x       ;Increment past final quote if it's there.
scanchar2       clra
                andcc #$fb     ;Clear zero flag.
                rts
scandec         cmpb #'0'
                blo noexpr
                cmpb #'9'
                bhi noexpr
                clr <temp
                clr <temp+1
scandloop       subb #'0'
                bcs sdexit
                cmpb #10
                bcc sdexit
                pshs b
                ldd <temp
                aslb
                rola
                pshs d
                aslb
                rola
                aslb
                rola
                addd ,s++     ;Multiply number by 10.
                addb ,s+
                adca #0       ;Add digit to 10.
                std <temp
                ldb ,x+       ;Get next character.
                bra scandloop
sdexit          ldd <temp
                leax -1,x
                andcc #$fb
                rts
noexpr          orcc #$04
                rts

***************************************************************
* Assemble the instruction pointed to by X.
* Stage 1: copy mnemonic to mnemonic buffer.
asminstr        lda #5
                ldu #mnembuf
mncploop        ldb ,x+
                beq mncpexit
                cmpb #' '
                beq mncpexit    ;Mnemonic ends at first space or null
                andb #CASEMASK
                cmpb #'A'
                blo nolet
                cmpb #'Z'
                bls mnemcp1     ;Capitalize letters, but only letters.
nolet           ldb -1,x
mnemcp1         stb ,u+         ;Copy to mnemonic buffer.
                deca
                bne mncploop
mncpexit        tsta
                beq mncpdone
                ldb #' '
mnfilloop       stb ,u+
                deca
                bne mnfilloop   ;Fill the rest of mnem buffer with spaces.

* Stage 2: look mnemonic up using binary search.
mncpdone        stx <temp3
                clr <temp       ;Low index=0
                lda #mnemsize
                sta <temp+1     ;High index=mnemsize.
bsrchloop       ldb <temp+1
                cmpb #$ff
                beq invmnem     ;lower limit -1?
                cmpb <temp
                blo invmnem     ;hi index lower than low index?
                clra
                addb <temp      ;Add indexes.
                adca #0
                lsra
                rorb            ;Divide by 2 to get average
                stb <temp2
                aslb
                rola
                aslb
                rola
                aslb
                rola            ;Multiply by 8 to get offset.
                ldu #mnemtab
                leau d,u        ;Add offset to table base
                tfr u,y
                lda #5
                ldx #mnembuf
bscmploop       ldb ,x+
                cmpb ,y+
                bne bscmpexit   ;Characters don't match?
                deca
                bne bscmploop
                jmp mnemfound   ;We found the mnemonic.
bscmpexit       ldb <temp2
                bcc bscmplower
                decb
                stb <temp+1     ;mnembuf<table, adjust high limit.
                bra bsrchloop
bscmplower      incb
                stb <temp       ;mnembuf>table, adjust low limit.
                bra bsrchloop
invmnem         ldx #invmmsg
                jmp asmerrvec

* Stage 3: Perform routine depending on category code.
mnemfound       clr uncert
                ldy addr
                lda 5,u
                asla
                ldx #asmtab
                jsr [a,x]
                sty addr
                rts

asmtab          fdb onebyte,twobyte,immbyte,lea
                fdb sbranch,lbranch,lbra,acc8
                fdb dreg1,dreg2,oneaddr,tfrexg
                fdb pushpul,pseudovec

***************************************************************
putbyte         stb ,y+
                rts
putword         std ,y++
                rts

***************************************************************
onebyte         ldb 7,u         ;Cat 0, one byte opcode w/o operands RTS
                bra putbyte
twobyte         ldd 6,u         ;Cat 1, two byte opcode w/o operands SWI2
                bra putword
immbyte         ldb 7,u         ;Cat 2, opcode w/ immdiate operand ANDCC
                bsr putbyte
                jsr scanops
                ldb amode
                cmpb #1
                lbne moderr
                ldb operand+1
                bra putbyte
lea             ldb 7,u         ;Cat 3, LEA
                bsr putbyte
                jsr scanops
                lda amode
                cmpa #1
                lbeq moderr     ;No immediate w/ lea
                cmpa #3
                lbhs doaddr
                jsr set3
                lda #$8f
                sta postbyte
                lda #2
                sta opsize      ;Use 8F nn nn for direct mode.
                jmp doaddr
sbranch         ldb 7,u         ;Cat 4, short branch instructions
                bsr putbyte
                jsr startop
                leax -1,x
                jsr exprvec
                lbeq exprerr
                jmp shortrel
lbranch         ldd 6,u         ;Cat 5, long brach w/ two byte opcode
                bsr putword
lbra1           jsr startop
                leax -1,x
                jsr exprvec
                lbeq exprerr
                jmp longrel
lbra            ldb 7,u         ;Cat 6, long branch w/ one byte opcode.
                jsr putbyte
                bra lbra1
acc8            lda #1          ;Cat 7, 8-bit two operand instructions ADDA
                sta opsize
                jsr scanops
                jsr adjopc
                jsr putbyte
                jmp doaddr
dreg1           lda #2          ;Cat 8, 16-bit 2operand insns 1byte opc LDX
                sta opsize
                jsr scanops
                jsr adjopc
                jsr putbyte
                jmp doaddr
dreg2           lda #2          ;Cat 9, 16-bit 2operand insns 2byte opc LDY
                sta opsize
                jsr scanops
                jsr adjopc
                lda 6,u
                jsr putword
                jmp doaddr
oneaddr         jsr scanops     ;Cat 10, one-operand insns NEG..CLR
                ldb 7,u
                lda amode
                cmpa #1
                lbeq moderr     ;No immediate mode
                cmpa #3
                bhs oaind       ;indexed etc
                lda opsize
                deca
                beq oadir
                addb #$10       ;Add $70 for extended direct.
oaind           addb #$60       ;And $60 for indexed etc.
oadir           jsr putbyte     ;And nothing for direct8.
                jmp doaddr
tfrexg          jsr startop     ;Cat 11, TFR and EXG
                leax -1,x
                ldb 7,u
                jsr putbyte
                jsr findreg
                ldb ,u
                aslb
                aslb
                aslb
                aslb
                stb postbyte
                ldb ,x+
                cmpb #','
                lbne moderr
                jsr findreg
                ldb ,u
                orb postbyte
                jmp putbyte
pushpul         jsr startop     ;Cat 12, PSH and PUL
                leax -1,x
                ldb 7,u
                jsr putbyte
                clr postbyte
pploop          jsr findreg
                ldb 1,u
                orb postbyte
                stb postbyte
                ldb ,x+
                cmpb #','
                beq pploop
                leax -1,x
                ldb postbyte
                jmp putbyte
pseudo          ldb 7,u         ;Cat 13, pseudo oeprations
                aslb
                ldx #pseudotab
                jmp [b,x]

pseudotab       fdb pseudoend,dofcb,dofcc,dofdb
                fdb doorg,dormb,pseudoend,pseudoend

***************************************************************
dofcb           jsr startop
                leax -1,x
fcbloop         jsr exprvec
                lbeq exprerr
                jsr putbyte
                ldb ,x+
                cmpb #','
                beq fcbloop
pseudoend       rts

***************************************************************
dofcc           jsr startop
                tfr b,a ;Save delimiter.
fccloop         ldb ,x+
                beq pseudoend
                pshs a
                cmpb ,s+
                beq pseudoend
                jsr putbyte
                bra fccloop

***************************************************************
dofdb           jsr startop
                leax -1,x
fdbloop         jsr exprvec
                lbeq exprerr
                jsr putword
                ldb ,x+
                cmpb #','
                beq fdbloop
                rts

***************************************************************
doorg           jsr startop
                leax -1,x
                jsr exprvec
                lbeq exprerr
                tfr d,y
                rts

***************************************************************
dormb           jsr startop
                leax -1,x
                jsr exprvec
                lbeq exprerr
                leay d,y
                rts

***************************************************************
* Adjust opcode depending on mode (in $80-$FF range)
adjopc          ldb 7,u
                lda amode
                cmpa #2
                beq adjdir      ;Is it direct?
                cmpa #3
                bhs adjind      ;Indexed etc?
                rts             ;Not, then immediate, no adjust.
adjind          addb #$20       ;Add $20 to opcode for indexed etc modes.
                rts
adjdir          addb #$10       ;Add $10 to opcode for direct8
                lda opsize
                deca
                bne adjind      ;If opsize=2, add another $20 for extended16
                rts

***************************************************************
* Start scanning of operands.
startop         ldx <temp3
                clr amode
                jmp skipspace

***************************************************************
* amode settings in assembler: 1=immediate, 2=direct/extended, 3=indexed
* etc. 4=pc relative, 5=indirect, 6=pcrelative and indirect.

* Scan the assembler operands.
scanops         bsr startop
                cmpb #'['
                bne noindir
                lda #5          ;operand starts with [, then indirect.
                sta amode
                ldb ,x+
noindir         cmpb #'#'
                lbeq doimm
                cmpb #','
                lbeq dospecial
                andb #CASEMASK  ;Convert to uppercase.
                lda #$86
                cmpb #'A'
                beq scanacidx
                lda #$85
                cmpb #'B'
                beq scanacidx
                lda #$8B
                cmpb #'D'
                bne scanlab
scanacidx       ldb ,x+         ;Could it be A,X B,X or D,X
                cmpb #','
                bne nocomma
                sta postbyte
                clr opsize
                jsr set3
                jsr scanixreg
                bra scanend
nocomma         leax -1,x
scanlab         leax -1,x       ;Point to the start of the operand
                jsr exprvec
                lbeq exprerr
                std operand
                tst uncert
                bne opsz2       ;Go for extended if operand unknown.
                subd dpsetting
                tsta            ;Can we use 8-bit operand?
                bne opsz2
                inca
                bra opsz1
opsz2           lda #2
opsz1           sta opsize      ;Set opsize depending on magnitude of op.
                lda amode
                cmpa #5
                bne opsz3       ;Or was it indirect.
                lda #2          ;Then we have postbyte and opsize=2
                sta opsize
                lda #$8F
                sta postbyte
                bra opsz4
opsz3           lda #2
                sta amode       ;Assume direct or absolute addressing
opsz4           ldb ,x+
                cmpb #','
                lbeq doindex    ;If followed by, then indexed.
scanend         lda amode
                cmpa #5
                blo scanend2    ;Was it an indirect mode?
                lda postbyte
                ora #$10        ;Set indirect bit.
                sta postbyte
                ldb ,x+
                cmpb #']'       ;Check for the other ]
                lbeq moderr
scanend2        rts

***************************************************************
doimm           jsr exprvec     ;Immediate addressing.
                lbeq exprerr
                std operand
                lda amode
                cmpa #5
                lbeq moderr     ;Indirect mode w/ imm is illegal.
                lda #$01
                sta amode
                rts

***************************************************************
dospecial       jsr set3
                clr opsize
                clra
adecloop        ldb ,x+
                cmpb #'-'
                bne adecend
                inca            ;Count the - signs for autodecrement.
                bra adecloop
adecend         leax -1,x
                cmpa #2
                lbhi moderr
                tsta
                bne autodec
                clr postbyte
                jsr scanixreg
                clra
aincloop        ldb ,x+
                cmpb #'+'
                bne aincend
                inca
                bra aincloop    ;Count the + signs for autoincrement.
aincend         leax -1,x
                cmpa #2
                lbhi moderr
                tsta
                bne autoinc
                lda #$84
                ora postbyte
                sta postbyte
                bra scanend
autoinc         adda #$7f
                ora postbyte
                sta postbyte
                bra scanend
autodec         adda #$81
                sta postbyte
                jsr scanixreg
                lbra scanend
doindex         clr postbyte
                jsr set3
                ldb ,x+
                andb #CASEMASK  ;Convert to uppercase.
                cmpb #'P'
                lbeq dopcrel    ;Check for PC relative.
                leax -1,x
                clr opsize
                bsr scanixreg
                ldd operand
                tst uncert
                bne longindex   ;Go for long index if operand unknown.
                cmpd #-16
                blt shortindex
                cmpd #15
                bgt shortindex
                lda amode
                cmpa #5
                beq shortind1   ;Indirect may not be 5-bit index
                                ;It's a five-bit index.
                andb #$1f
                orb postbyte
                stb postbyte
                lbra scanend
shortindex      cmpd #-128
                blt longindex
                cmpd #127
                bgt longindex
shortind1       inc opsize
                ldb #$88
                orb postbyte
                stb postbyte
                lbra scanend
longindex       lda #$2
                sta opsize
                ldb #$89
                orb postbyte
                stb postbyte
                lbra scanend
dopcrel         ldb ,x+
                andb #CASEMASK  ;Convert to uppercase
                cmpb #'C'
                blo pcrelend
                cmpb #'R'
                bhi pcrelend
                bra dopcrel     ;Scan past the ,PCR
pcrelend        leax -1,x
                ldb #$8C
                orb postbyte    ;Set postbyte
                stb postbyte
                inc amode       ;Set addr mode to PCR
                lbra scanend

***************************************************************
* Scan for one of the 4 index registers and adjust postbyte.
scanixreg       ldb ,x+
                andb #CASEMASK  ;Convert to uppercase.
                pshs x
                ldx #ixregs
                clra
scidxloop       cmpb ,x+
                beq ixfound
                adda #$20
                bpl scidxloop
                jmp moderr      ;Index register not found where expected.
ixfound         ora postbyte
                sta postbyte    ;Set index reg bits in postbyte.
                puls x
                rts

***************************************************************
* Set amode to 3, if it was less.
set3            lda amode
                cmpa #3
                bhs set3a
                lda #3
                sta amode
set3a           rts

***************************************************************
* Lay down the address.
doaddr          lda amode
                cmpa #3
                blo doa1
                ldb postbyte
                jsr putbyte
                lda amode
                anda #1
                beq doapcrel    ;pc rel modes.
doa1            lda opsize
                tsta
                beq set3a
                deca
                beq doa2
                ldd operand
                jmp putword
doa2            ldb operand+1
                jmp putbyte
doapcrel        sty addr
                ldd operand
                subd addr
                subd #1
                tst uncert
                bne pcrlong
                cmpd #-128
                blt pcrlong
                cmpd #-127
                bgt pcrlong
                lda #1
                sta opsize
                jmp putbyte
pcrlong         subd #1
                leay -1,y
                inc postbyte
                pshs d
                ldb postbyte
                jsr putbyte
                lda #2
                sta opsize
                puls d
                jmp putword

***************************************************************
* Check and lay down short relative address.
shortrel        sty addr
                subd addr
                subd #1
                cmpd #-128
                blt brerr
                cmpd #127
                bgt brerr
                jsr putbyte
                lda #4
                sta amode
                lda #1
                sta opsize
                rts

***************************************************************
* Lay down long relative address.
longrel         sty addr
                subd addr
                subd #2
                jsr putword
                lda #4
                sta amode
                lda #2
                sta opsize
                rts

***************************************************************
brerr           ldx #brmsg
                jmp asmerrvec
exprerr         ldx #exprmsg
                jmp asmerrvec
moderr          ldx #modemsg
                jmp asmerrvec

***************************************************************
asmerr          pshs x
                jsr <xabortin
                puls x
                jsr outnts
                jsr <putcr
                lds savesp
                jmp cmdline

***************************************************************
* Find register for TFR and PSH instruction
findreg         ldb #12
                pshs y,b
                ldu #asmregtab
findregloop     tfr x,y
                lda #3
frcmps          ldb ,u
                cmpb #' '
                bne frcmps1
                ldb ,y
                cmpb #'A'
                blt frfound
frcmps1         ldb ,y+
                andb #CASEMASK
                cmpb ,u+
                bne frnextreg
                deca
                bne frcmps
                inca
                bra frfound
frnextreg       inca
                leau a,u
                dec ,s
                bne findregloop
                lbra moderr
frfound         leau a,u
                tfr y,x
                puls y,b
                rts

***************************************************************
* Command: A, assemble instructions.
* Syntax: Aaddr
asm             ldx #linebuf+1
                jsr scanhex
                std addr
                inc <disflg

asmloop         ldy #0
                sty length
                ldd addr
                pshs d
                jsr dis1        ;display unassembled line
                ldd addr
                std nxtadd

                puls d
                std addr

                ldb #TAB
                jsr <putchar    ;Print TAB
                ldx #linebuf
                ldb #128
                jsr <getline    ;Get new line
                tstb
                beq next

                abx
                clr ,x          ;Make line zero terminated.
                ldx #linebuf
                lda ,x
                cmpa #'.'       ;Terminate on "."
                beq asmend
                jsr asminstr
                bra asmloop

next            ldd nxtadd
                std addr
                bra asmloop

asmend          clr <disflg
                jmp cmdline

***************************************************************
* Data area.

* mnemonics table, ordered alphabetically.
* 5 bytes name, 1 byte category, 2 bytes opcode, 8 bytes total.
mnemtab         fcc "ABX  "
                fcb 0
                fdb $3a
                fcc "ADCA "
                fcb 7
                fdb $89
                fcc "ADCB "
                fcb 7
                fdb $c9
                fcc "ADDA "
                fcb 7
                fdb $8b
                fcc "ADDB "
                fcb 7
                fdb $cb
                fcc "ADDD "
                fcb 8
                fdb $c3
                fcc "ANDA "
                fcb 7
                fdb $84
                fcc "ANDB "
                fcb 7
                fdb $c4
                fcc "ANDCC"
                fcb 2
                fdb $1c
                fcc "ASL  "
                fcb 10
                fdb $08
                fcc "ASLA "
                fcb 0
                fdb $48
                fcc "ASLB "
                fcb 0
                fdb $58
                fcc "ASR  "
                fcb 10
                fdb $07
                fcc "ASRA "
                fcb 0
                fdb $47
                fcc "ASRB "
                fcb 0
                fdb $57
                fcc "BCC  "
                fcb 4
                fdb $24
                fcc "BCS  "
                fcb 4
                fdb $25
                fcc "BEQ  "
                fcb 4
                fdb $27
                fcc "BGE  "
                fcb 4
                fdb $2c
                fcc "BGT  "
                fcb 4
                fdb $2e
                fcc "BHI  "
                fcb 4
                fdb $22
                fcc "BHS  "
                fcb 4
                fdb $24
                fcc "BITA "
                fcb 7
                fdb $85
                fcc "BITB "
                fcb 7
                fdb $c5
                fcc "BLE  "
                fcb 4
                fdb $2f
                fcc "BLO  "
                fcb 4
                fdb $25
                fcc "BLS  "
                fcb 4
                fdb $23
                fcc "BLT  "
                fcb 4
                fdb $2d
                fcc "BMI  "
                fcb 4
                fdb $2b
                fcc "BNE  "
                fcb 4
                fdb $26
                fcc "BPL  "
                fcb 4
                fdb $2a
                fcc "BRA  "
                fcb 4
                fdb $20
                fcc "BRN  "
                fcb 4
                fdb $21
mnembsr         fcc "BSR  "
                fcb 4
                fdb $8d
                fcc "BVC  "
                fcb 4
                fdb $28
                fcc "BVS  "
                fcb 4
                fdb $29
                fcc "CLR  "
                fcb 10
                fdb $0f
                fcc "CLRA "
                fcb 0
                fdb $4f
                fcc "CLRB "
                fcb 0
                fdb $5f
                fcc "CMPA "
                fcb 7
                fdb $81
                fcc "CMPB "
                fcb 7
                fdb $c1
                fcc "CMPD "
                fcb 9
                fdb $1083
                fcc "CMPS "
                fcb 9
                fdb $118c
                fcc "CMPU "
                fcb 9
                fdb $1183
                fcc "CMPX "
                fcb 8
                fdb $8c
                fcc "CMPY "
                fcb 9
                fdb $108c
                fcc "COM  "
                fcb 10
                fdb $03
                fcc "COMA "
                fcb 0
                fdb $43
                fcc "COMB "
                fcb 0
                fdb $53
                fcc "CWAI "
                fcb 2
                fdb $3c
                fcc "DAA  "
                fcb 0
                fdb $19
                fcc "DEC  "
                fcb 10
                fdb $0a
                fcc "DECA "
                fcb 0
                fdb $4a
                fcc "DECB "
                fcb 0
                fdb $5a
                fcc "EORA "
                fcb 7
                fdb $88
                fcc "EORB "
                fcb 7
                fdb $c8
                fcc "EQU  "
                fcb 13
                fdb 0
                fcc "EXG  "
                fcb 11
                fdb $1e
mnemfcb         fcc "FCB  "
                fcb 13
                fdb 1
                fcc "FCC  "
                fcb 13
                fdb 2
                fcc "FDB  "
                fcb 13
                fdb 3
                fcc "INC  "
                fcb 10
                fdb $0c
                fcc "INCA "
                fcb 0
                fdb $4c
                fcc "INCB "
                fcb 0
                fdb $5c
                fcc "JMP  "
                fcb 10
                fdb $0e
mnemjsr         fcc "JSR  "
                fcb 8
                fdb $8d
                fcc "LBCC "
                fcb 5
                fdb $1024
                fcc "LBCS "
                fcb 5
                fdb $1025
                fcc "LBEQ "
                fcb 5
                fdb $1027
                fcc "LBGE "
                fcb 5
                fdb $102c
                fcc "LBGT "
                fcb 5
                fdb $102e
                fcc "LBHI "
                fcb 5
                fdb $1022
                fcc "LBHS "
                fcb 5
                fdb $1024
                fcc "LBLE "
                fcb 5
                fdb $102f
                fcc "LBLO "
                fcb 5
                fdb $1025
                fcc "LBLS "
                fcb 5
                fdb $1023
                fcc "LBLT "
                fcb 5
                fdb $102d
                fcc "LBMI "
                fcb 5
                fdb $102b
                fcc "LBNE "
                fcb 5
                fdb $1026
                fcc "LBPL "
                fcb 5
                fdb $102a
                fcc "LBRA "
                fcb 6
                fdb $16
                fcc "LBRN "
                fcb 5
                fdb $1021
                fcc "LBSR "
                fcb 6
                fdb $17
                fcc "LBVC "
                fcb 5
                fdb $1028
                fcc "LBVS "
                fcb 5
                fdb $1029
                fcc "LDA  "
                fcb 7
                fdb $86
                fcc "LDB  "
                fcb 7
                fdb $c6
                fcc "LDD  "
                fcb 8
                fdb $cc
                fcc "LDS  "
                fcb 9
                fdb $10ce
                fcc "LDU  "
                fcb 8
                fdb $ce
                fcc "LDX  "
                fcb 8
                fdb $8e
                fcc "LDY  "
                fcb 9
                fdb $108e
                fcc "LEAS "
                fcb 3
                fdb $32
                fcc "LEAU "
                fcb 3
                fdb $33
                fcc "LEAX "
                fcb 3
                fdb $30
                fcc "LEAY "
                fcb 3
                fdb $31
                fcc "LSL  "
                fcb 10
                fdb $08
                fcc "LSLA "
                fcb 0
                fdb $48
                fcc "LSLB "
                fcb 0
                fdb $58
                fcc "LSR  "
                fcb 10
                fdb $04
                fcc "LSRA "
                fcb 0
                fdb $44
                fcc "LSRB "
                fcb 0
                fdb $54
                fcc "MUL  "
                fcb 0
                fdb $3d
                fcc "NEG  "
                fcb 10
                fdb $00
                fcc "NEGA "
                fcb 0
                fdb $40
                fcc "NEGB "
                fcb 0
                fdb $50
                fcc "NOP  "
                fcb 0
                fdb $12
                fcc "ORA  "
                fcb 7
                fdb $8a
                fcc "ORB  "
                fcb 7
                fdb $ca
                fcc "ORCC "
                fcb 2
                fdb $1a
                fcc "ORG  "
                fcb 13
                fdb 4
                fcc "PSHS "
                fcb 12
                fdb $34
                fcc "PSHU "
                fcb 12
                fdb $36
                fcc "PULS "
                fcb 12
                fdb $35
                fcc "PULU "
                fcb 12
                fdb $37
                fcc "RMB  "
                fcb 13
                fdb 5
                fcc "ROL  "
                fcb 10
                fdb $09
                fcc "ROLA "
                fcb 0
                fdb $49
                fcc "ROLB "
                fcb 0
                fdb $59
                fcc "ROR  "
                fcb 10
                fdb $06
                fcc "RORA "
                fcb 0
                fdb $46
                fcc "RORB "
                fcb 0
                fdb $56
                fcc "RTI  "
                fcb 0
                fdb $3b
                fcc "RTS  "
                fcb 0
                fdb $39
                fcc "SBCA "
                fcb 7
                fdb $82
                fcc "SBCB "
                fcb 7
                fdb $c2
                fcc "SET  "
                fcb 13
                fdb 6
                fcc "SETDP"
                fcb 13
                fdb 7
                fcc "SEX  "
                fcb 0
                fdb $1d
                fcc "STA  "
                fcb 7
                fdb $87
                fcc "STB  "
                fcb 7
                fdb $c7
                fcc "STD  "
                fcb 8
                fdb $cd
                fcc "STS  "
                fcb 9
                fdb $10cf
                fcc "STU  "
                fcb 8
                fdb $cf
                fcc "STX  "
                fcb 8
                fdb $8f
                fcc "STY  "
                fcb 9
                fdb $108f
                fcc "SUBA "
                fcb 7
                fdb $80
                fcc "SUBB "
                fcb 7
                fdb $c0
                fcc "SUBD "
                fcb 8
                fdb $83
                fcc "SWI  "
                fcb 0
                fdb $3f
                fcc "SWI2 "     ;[NAC HACK 2015Jul14] bugfix! Was fcb instead of fcc
                fcb 1
                fdb $103f
                fcc "SWI3 "     ;[NAC HACK 2015Jul14] bugfix! Was fcb instead of fcc
                fcb 1
                fdb $113f
                fcc "SYNC "
                fcb 0
                fdb $13
                fcc "TFR  "
                fcb 11
                fdb $1f
                fcc "TST  "
                fcb 10
                fdb $0d
                fcc "TSTA "
                fcb 0
                fdb $4d
                fcc "TSTB "
                fcb 0
                fdb $5d

* [NAC HACK 2015Jul14] portability..
* NO whitespace allowed in expressions with AS9
* and NO braces, so need this 2-step computation.
mnemtmp         equ *-mnemtab
mnemsize        equ mnemtmp/8

* Register table for PUSH/PULL and TFR/EXG instructions.
* 3 bytes for name, 1 for tfr/exg, 1 for push/pull, 5 total
asmregtab       fcc "X  "
                fcb $01,$10
                fcc "Y  "
                fcb $02,$20
aregu           fcc "U  "
                fcb $03,$40
aregs           fcc "S  "
                fcb $04,$40
                fcc "PC "
                fcb $05,$80
                fcc "A  "
                fcb $08,$02
                fcc "B  "
                fcb $09,$04
                fcc "D  "
                fcb $00,$06
                fcc "CC "
                fcb $0a,$01
                fcc "CCR"
                fcb $0a,$01
                fcc "DP "
                fcb $0b,$08
                fcc "DPR"
                fcb $0b,$08
reginval        fcc "?  "

ixregs          fcc "XYUS"

* opcode offsets to basic opcode, depends on first nibble.
opcoffs         fcb 0,0,0,0,0,0,-$60,-$70
                fcb 0,-$10,-$20,-$30,0,-$10,-$20,-$30

* modes:
* 0 no operands,     1 8-bit immediate,  2 16 bit imm,
* 3 8-bit address,   4 16-bit address,   5 indexed with postbyte,
* 6 short relative,  7 long relative,    8 pushpul,
* 9 tftetx

* mode depending on first nibble of opcode.
modetab         fcb 3,0,0,0,0,0,5,4,1,3,5,4,1,3,5,4
* mode depending on category code stored in mnemtab
modetab2        fcb 0,0,1,5,6,7,7,1,2,2,0,8,9


* Message for 'help' command, as zero-terminated string
mhelp           fcb     CR,LF

                fcc     'Asm    '
                fcc     '{Aaddr}'
                fcb     CR,LF

                fcc     'Unasm  '
                fcc     '{U or Uaddr or Uaddr,length}'
                fcb     CR,LF

                fcc     'Calc   '
                fcc     '{Chexnum1{+|-hexnum2}}'
                fcb     CR,LF

                fcc     'Dump   '
                fcc     '{D or Daddr or Daddr,length}'
                fcb     CR,LF

                fcc     'Enter  '
                fcc     '{E or Eaddr or Eaddr bytes or Eaddr "string"}'
                fcb     CR,LF

                fcc     'Break  '
                fcc     '{B or Baddr. B displays, Baddr sets or clears breakpoint}'
                fcb     CR,LF

                fcc     'Find   '
                fcc     '{Faddr bytes or Faddr "string"}'
                fcb     CR,LF

                fcc     'Go     '
                fcc     '{G or Gaddr}'
                fcb     CR,LF

                fcc     'Inp    '
                fcc     '{Iaddr}'
                fcb     CR,LF

                fcc     'Jump   '
                fcc     '{Jaddr}'
                fcb     CR,LF

                fcc     'Move   '
                fcc     '{Maddr1,addr2,length}'
                fcb     CR,LF

                fcc     'Prog   '
                fcc     '{P}'
                fcb     CR,LF

                fcc     'Regs   '
                fcc     '{R or R<letter><hex>}'
                fcb     CR,LF

                fcc     'Srec   '
                fcc     '{SO<addr> or SS<addr>,<len> or S1<bytes> or S9<bytes>}'
                fcb     CR,LF

                fcc     'Trace  '
                fcc     '{T}'
                fcb     CR,LF

                fcc     'Xmodem '
                fcc     '{XSaddr,len XLaddr,len XX XOcrlf,filler, XSSaddr,len}'
                fcb     CR,LF

                fcc     'Help   '
                fcc     '{H}'
                fcb     CR,LF,CR,LF,0


* Other messages, as null-terminated strings.
welcome         fcc "BUGGY for Kipper SBC, 2015Sep17 (type h for help)"
                fcb 0
unknown         fcc "Unknown command"
                fcb 0
badargs         fcc "Bad arguments"
                fcb 0
brkmsg          fcc "Breakpoint set"
                fcb 0
clrmsg          fcc "Breakpoint cleared"
                fcb 0
fullmsg         fcc "Breakpoints full"
                fcb 0
smsg            fcc "Error in S record"
                fcb 0
lastrec         fcc "S9030000FC"
                fcb 0
xsmsg           fcc "Start XMODEM Send"
                fcb 0
xrmsg           fcc "Start XMODEM Receive"
                fcb 0
xamsg           fcc "XMODEM transfer aborted"
                fcb 0
invmmsg         fcc "Invalid mnemonic"
                fcb 0
exprmsg         fcc "Expression error"
                fcb 0
modemsg         fcc "Addressing mode error"
                fcb 0
brmsg           fcc "Branch too long"
                fcb 0

* This jump table will be copied to the interrupt jump table area in RAM.
intvectbl       jmp endirq
                jmp endirq
                jmp timerirq
                jmp aciairq
                jmp unlaunch
                jmp endirq
                jmp xerrhand
                jmp expr
                jmp asmerr   ; [NAC HACK 2015Aug23] bugfix! original was asmerrvec
                jmp pseudo
intvecend       equ *

* This jump table will be copied to the I/O jump table area in RAM.
osvectbl        jmp osgetc
                jmp osputc
                jmp osgetl
                jmp osputl
                jmp oscr
                jmp osgetpoll
                jmp xopin
                jmp xopout
                jmp xabtin
                jmp xclsin
                jmp xclsout
                jmp osdly
osvecend        equ *

* Vector table for commands: A-Z (unk for non-existent commands)
cmdtab          fdb asm,break,calc,dump
                fdb enter,find,go,help
                fdb inp,jump,unk,unk
                fdb move,unk,unk,prog
                fdb unk,regs,srec,trace
                fdb unasm,unk,unk,xmodem
                fdb unk,unk

* Vector table for monitor routines that are usable by other programs.
* These entries should be in a fixed place in memory. Jump through them.
                org $ffb0
                fdb outbyte
                fdb outd
                fdb scanbyte
                fdb scanhex
                fdb scanfact
                fdb asminstr

* Multicomp I/O is at address $ffd0-$ffdf

* Interrupt vector addresses at top of ROM. Most are vectored through jumps
* in RAM.
                org $fff2
                fdb swi3vec
                fdb swi2vec
                fdb firqvec
                fdb irqvec
                fdb swivec
                fdb nmivec
                fdb reset

                end
