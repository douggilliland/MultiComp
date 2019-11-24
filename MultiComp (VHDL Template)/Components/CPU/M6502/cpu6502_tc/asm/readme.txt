(July, 31th 2013)
It weas a heavy task to create/find an appropriate test bench on assembler level
useable by the end-user.
In 2012 Klaus Dormann creates and publish his amazing 6502 test suite written
in assembler. Thanks again to Klaus!
It uses the a65 assembler created by Frank A. Kingswood
   (http://www.kingswood-consulting.co.uk/assemblers/)
   
If you generate the HEX/BIN files for your project, please aware of the offset
of #10/$a bytes.
   
I made a little change in both attached source files to allow running the
programs on systems without any os or monitor direcly from RAM.

Klaus implemented an UNEXPECTED RESET TRAP which prevent the start of program
after RESET in default configuration. Default is now "RESET -> start".

In both programs the lines
  dw  res_trap
  dw  start
should activated/deactivated by your requirements.

(Sptember, 08th 2018)
I added the interrupt vector table to Bruce's decimal test.

(Sptember, 11th 2018)
Line 938 as remark because r6502_tc works like a real r6502
; =>     trap_ne         ;unexpected B-flag! - this may fail on a real 6502
                         ;due to a hardware bug on concurrent BRK & NMI

All three tests: SUCCESS with v1.4

