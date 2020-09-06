# Simple fixed-cycle SDRAM Controller

Additional information: <https://dnotq.io/sdram/sdram.html>

Status: FPGA tested, Xilinx Spartan-6, 100MHz

Target SDRAM: `Winbond W9825G6JH 4M x 4 Banks x 16-bit SDRAM`

The controller design goals:

1. Have a constant access time for any read or write to any memory location.
2. A refresh cycle cannot hold up a read or write request.
3. Provide an 8-bit data size.

Access time is 70ns for any read, write, or refresh cycle.  The input clock must
be 100MHz.  Refresh cycles are the responsibility of the host system and must be
issued at least once every 7us.

Works very well in SoC designs using retro 8-bit and 16-bit CPUs such as the
Z80, 6502, TMS-9900, etc.