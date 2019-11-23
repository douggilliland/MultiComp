M65C02 Microprocessor Core
=======================

Copyright (C) 2012-2013, Michael A. Morris <morrisma@mchsi.com>.
All Rights Reserved.

Released under LGPL.

News
----

Recently completed tests have verified the M65C02 soft-
processor to operate as designed at a frequency of 73.728 MHz in an XC3S50A-
4VQG100I FPGA. See below for a more complete description of Release 2.7.2. 
with which this milestone was achieved.

General Description
-------------------

This project provides a microprogrammed synthesizable IP core compatible with 
the WDC and Rockwell 65C02 microprocessors. 

It is provided as a core. Several external components are required to form a 
functioning processor: (1) memory, (2) interrupt controller, and (3) I/O 
interface buffers. The Verilog testbench provided demonstrates a simple 
configuration for a functioning processor implemented with the M65C02 core: 
M65C02_Core. The M65C02 core supports the full instruction set of the W65C02. 

The core accepts an interrupt signal from an external interrupt controller. 
The core provides the interrupt mask bit to the external interrupt controller, 
and expects the controller to handle the detection of the NMI edge, the 
prioritization of the interrupt sources, and to provide the interrupt and 
exception vectors. The core also provides an indication of whether the BRK 
instruction is being executed. With this additional information, the external 
interrupt controller is expected to provide the same vector for the BRK 
exception as the vector for the IRQ interrupt request, or another suitable 
vector. This approach to interrupt handling can be used to support a vectored 
interrupt structure with more interrupt sources than the original processor 
implementation supported: NMI, RST, and IRQ.

With Release 2.x, the core now provides a microcycle length controller as an 
integral component of the M65C02 Microprogram Controller (MPC). The M65C02 
core microprogram can now inform the external memory controller, on a cycle by 
cycle basis, of the memory cycle type. Logic external to the core can use this 
output to map the memory cycle to whatever memory is appropriate, and to drive 
the microcycle length inputs of the core to extend each microcycle if 
necessary. Thus, the Release 2.x core no longer assumes that the external 
memory is implemented as an asynchronous memory device, and as a result, the 
core no longer expects that the memory will accept an address and return the 
read data at that address in the same cycle. With the built-in microcycle 
length controller, single cycle LUT-based zero page memory, 2 cycle internal 
block RAM memory, and 4 cycle external memory can easily be supported. A Wait 
input can also be used to extend, i.e. add wait states, to the 4 cycle 
microcycles, so a wide variety of memories can be easily supported; the only 
limitation being the memory types supported by the user-supplied external 
memory controller.

The core provides a large number of status and control signals that external 
logic may use. It also provides access to many internal signals such as all of 
the registers, A, X, Y, S, and P. The *Mode*, *Done*, *SC*, and *RMW* status 
outputs may be used to provide additional signals to external devices.

*Mode* provides an indication of the kind of instruction being executed:

    0 - STP - stop processor instruction executed,
    1 - INV - invalid instruction (uniformly treated a single cycle NOPs),
    2 - BRK - break instruction being executed
    3 - JMP - branch/jump/return (Bcc, BBRx/BBSx, JMP/JSR, RTS/RTI),
    4 - STK - stack access (PHA/PLA, PHX/PLX, PHY/PLY),
    5 - INT - single cycle instruction (INC/DEC A, TAX/TXA, SEI/CLI, etc.),
    6 - MEM - multi-cycle instruction with memory access for operands,
    7 - WAI - wait for interrupt instruction being executed.

*Done* is asserted during the instruction fetch of the next instruction. 
During that fetch cycle, all instructions complete execution. Thus, the M65C02 
is pipelined, and executes many instructions in fewer cycles than the 65C02. 

*SC* is used to indicate a single cycle instruction.

*RMW* indicates that a read-modify-write instruction will be performed. External
logic can use this signal to lock memory.

*IO_Op* indicates the I/O cycle required. *IO_Op* signals data memory writes, 
data memory reads, and instruction memory reads. Therefore, external logic may 
implement separate data and instruction memories and potentially double the 
amount of memory that an implementation may access. 

Implementation
--------------

The implementation of the core provided consists of five Verilog source files 
and several memory initialization files:

    M65C02_Core.v           - Top level module
        M65C02_MPCv3.v      - M65C02 MPC with microcycle length controller
        M65C02_AddrGen.v    - M65C02 Address Generator module
        M65C02_ALU.v        - M65C02 ALU module
            M65C02_BIN.v    - M65C02 Binary Mode Adder module
            M65C02_BCD.v    - M65C02 Decimal Mode Adder module
    
    M65C02_Decoder_ROM.coe  - M65C02 core microprogram ALU control fields
    M65C02_uPgm_V3a.coe     - M65C02 core microprogram (sequence control)

    M65C02_Core.ucf         - User Constraints File: period and pin LOCs
    M65C02.tcl              - Project settings file
    
    tb_M65C02_Core.v        - Completed core testbench with test RAM
    
    M65C02_Tst3.txt         - Memory configuration file of M65C02 "ROM" program
        M65C02_Tst3.a65     - Kingswood A65 assembler source code test program

    tb_M65C02_ALU.v         - testbench for the ALU module
    tb_M65C02_BCD.v         - testbench for the BCD adder module

Synthesis
---------

The objective for the core is to synthesize such that the FF-FF speed is 100 MHz
or higher in a Xilinx XC3S200AN-5FGG256 FPGA using Xilinx ISE 10.1i SP3. In that
regard, the core provided meets and exceeds that objective. Using the settings
provided in the M65C02.tcl file, ISE 10.1i tool implements the design and
reports that the 10.000 ns period (100 MHz) constraint is satisfied.

The ISE 10.1i SP3 implementation results are as follows:

    Number of Slice FFs:            191
    Number of 4-input LUTs:         747
    Number of Occupied Slices:      459
    Total Number of 4-input LUTs:   760 (13 used as route-throughs)

    Number of BUFGMUXs:             1
    Number of RAMB16BWEs            2   (M65C02_Decoder_ROM, M65C02_uPgm_V3a)

    Best Case Achievable:           9.962 ns (0.038 ns Setup, 1.028 ns Hold)

Status
------

Design and verification is complete.

Release Notes
-------------

###Release 1

Release 1 of the M65C02 had an issue in that addressing wrapping of zero page 
addressing was not properly implemented. Unlike the W65C02 and MOS6502, the 
M65C02 synthesizable core implemented the addressing modes, but allowed page 
boundaries to be crossed for all addressing modes. This initial behavior is 
more like that of the WDC 65C802/816 microprocessors in native mode. With this 
release, Release 2, the zero page addressing modes of the M65C02 core behave 
like those of the WDC W65C02.

Following Release 1, a couple of quick patches were made to the zero page 
addressing, but these failed to address all of the issues. Release 2 uses the 
same basic next address generation logic, except that it now allows the 
microcode to control when addresses are computed modulo 256. With this change, 
all outstanding issues with respect to zero page addressing have been 
corrected.

###Release 2

Release 2 has reworked the Microprogram Controller (MPC) to include a 
microcycle length controller directly. With this new MPC, it is expected that 
it will be easier to adapt the core to use LUT RAM for page 0 (data page) and 
page 1 (stack page), and to attach a external memory controller with variable 
length access cycles. The microcycle length controller allows 1, 2, or 4 cycle 
microcycles. Neither the 1 and 2 cycle microcyles support wait state 
insertion, but the 4 cycle microcycle allows the insertion of wait states. 
With this architecture, LUT and internal Block RAMs can be used to provide 
high speed operation. The 4 cycle external memory microcycle should easily 
allow the core to support asynchronous or synchronous external memory. Release 
1 allowed variable length microcycles, but the address-based mechanism 
implemented was difficult to use in practice. Release 1 targeted a single 
cycle memory like that provided by the distributed LUT RAMs of the target 
FPGAs. The approach used in Release 2 should make it much easier to adapt the 
M65C02 core.

####Release 2.1

Release 2.1 has modified the core to export signals to an external memory
controller that would allow the memory controller to drive the core logic with
the required microcycle length value for the next microcycle. The test bench for
the core is running in parallel with the original Release 1 (with zero page
adressing corrected) core (M65C02_Base.v) so that a self-checking configuration
is achieved between the two cores and the common test program. Release 2.1 also
includes a modified memory model module, M65C02_RAM,v, that supports all three
types of memory that is expected to be used with the core: LUT (page 0), BRAM
(page 1 and internal program/data memory), and external pipelined SynchRAM.

####Release 2.2

Release 2.2 has been tested using microcycles of 1, 2, or 4 cycles in length. 
During testing, some old issues returned when multi-cycle microcycles were 
used. With single cycle microcycles there were no problems with either of the 
two cores: M65C02_Core.v or M65C02_Base.v. For example, with 2 and 4 cycle 
microcycles, the modification of the PSW before the first instruction of the 
ISR was found to be taking place several microcycles before it should. This 
issue was tracked down to the fact that the microprogram ROMs and the PSW 
update logic were not being qualified by the internal Rdy signal, or end-of-
microcycle. In the single cycle microcycle case, previous corrections applied 
to address this issue still worked, but the single cycle solutions applied did 
not generalize to the multi-cycle cases. Thus, several modules were modified 
so that ISR, BCD, and zero page addressing modes now behave correctly for 
single and multi-cycle microcycles.

####Release 2.3

Release 2.3 implements the standard 6502/65C02 vector fetch operations and 
adds the WAI and STP instructions. Both versions are updated to incorporate 
these features. The testbench has been modified to include another M6502_RAM 
module, and to separate the two modules into "ROM" at high memory and "RAM" at 
low memory. The test program has been updated to include initialization of 
"RAM" by the test program running from "ROM". Initialization of the stack 
pointer is still part of the core logic, and the test program expects that S 
is initialized to 0xFF on reset, and that the reset vector fetch sequence does 
not modify the stack. In other words, the Release 2.3 core does not write to 
the stack before fetching the vector and starting execution at that address.

####Release 2.4

Release 2.4 incorporates the 32 Rockwell instruction opcodes and the WAI and STP 
instructions.

####Release 2.5

Release 2.5 makes some minor modifications to the M65C02 core module to allow 
the output of some signals that allow the generation of interface signals such 
as the active low Vector Pull output of the W65C02S microprocessor. In 
addition to bringing out of these signals, Release 2.5 also provides an 
implementation of a standalone microprocessor, or system-on-chip, which 
demonstrates how the M65C02 can be used to provide a stand-alone 
implementation of a 65C02 processor. This implementation is composed of the 
following files:

    M65C02.v                - M65C02 microprocessor demonstration
        ClkGen.xaw          - Xilinx Architecture Wizard clock generator file

    M65C02.ucf              - User Constraints File: period and pin LOCs
    M65C02.tcl              - Project settings file
    
    tb_M65C02.v             - M65C02 testbench with RAM/ROM and interrupt sources

The header of the M65C02.v module provides details of the differences between 
the 65C02 microprocessor implementation represented by the M65C02.v and a 
65C02 processor implementation as represented by the WDC W65C02S microprocessor. 

The M65C02 implementation is targeted at an XC3S50A-4VQG100I FPGA. The User 
Constraints File (ucf) has been developed so that the resulting implementation 
can be used as a fully functional microprocessor when attached to external I/O 
devices, external SRAM device(s) (25ns or faster), and external an NOR Flash 
device (4kB, 45ns or faster). A development board is presently being developed 
to demonstrate the M65C02, and to provide a suitable platform for further 
development of the remaining FPGA resources into a more complete system-on-
chip based on the M65C02 core.

The Xilinx ISE 10.1i SP3 synthesis results for the M65C02 are as follows:

                                           Used Avail  %
    Number of Slice Flip Flops              200 1408  14%   
    Number of 4 input LUTs                  736 1408  52%   
    Logic Distribution          

    Number of occupied Slices               426  704  60%   
        Number of Slices related logic      426  426 100%   
        Number of Slices unrelated logic      0  426   0%   
    Total Number of 4 input LUTs            745 1408  52%   
        Number used as logic                735       
        Number used as a route-thru           9       
        Number used as Shift registers        1       
    Number of bonded IOBs 
        Number of bonded pads                53   68  77%   
        IOB Flip Flops                       79       
    Number of BUFGMUXs                        4   24  16%   
    Number of DCMs                            1    2  50%   
    Number of RAMB16BWEs                      2    3  66% 

    Best Case Achievable:                13.213ns (0.037ns Setup, 1.023ns Hold)

Please read the header and other comments for more details on the M65C02
processor implementation. In particular, read and understand the discussion
regarding the use of an FPGA-specific clock multiplexer to manage the memory
cycle length in lieu of supporting wait state generation/insertion.

#####Release 2.6

Modified the M65C02 processor to use the last available block RAM in the 
XC3S50A-xVQG100I device as a 2kB Boot/Monitor ROM. Added an external pin to 
inhibit writes into this block RAM. The UCF file includes a PULLUP on the pin 
which enables writes. Also modified the clock stretch logic to only apply when 
system ROM, CE[2], or User ROM, CE[1], are addressed. The Boot/Monitor 
ROM/RAM, IO (CE[3]), and User RAM, CE[0], do not use the clock stretching 
logic and therefore require devices able to respond in a single memory cycle of
the M65C02, ~25ns.

Adding the additional (internal) device select and data multiplexer to the 
M65C02 caused a drop in performance. External memory operating frequency 
decreased from ~20 MHz (max) to ~16 MHz for a -5 speed grade part. There was 
also an increase in the size of the implementation, but that was expected and 
did use a reasonable number of additional resources.

The following table summarizes PAR results for the new release of the M65C02
processor:

                                           Used Avail  %
    Number of Slice Flip Flops              205 1408  14%   
    Number of 4 input LUTs                  724 1408  51%   
    Logic Distribution          

    Number of occupied Slices               443  704  62%   
        Number of Slices related logic      443  443 100%   
        Number of Slices unrelated logic      0  426   0%   
    Total Number of 4 input LUTs            732 1408  51%   
        Number used as logic                723       
        Number used as a route-thru           8       
        Number used as Shift registers        1       
    Number of bonded IOBs 
        Number of bonded pads                54   68  79%   
        IOB Flip Flops                       80       
    Number of BUFGMUXs                        4   24  16%   
    Number of DCMs                            1    2  50%   
    Number of RAMB16BWEs                      3    3 100% 

    Best Case Achievable:                15.147ns (0.003ns Setup, 0.817ns Hold)

The modified files are:

    M65C02.v                - M65C02 microprocessor demonstration
    M65C02.ucf              - User Constraints File: period and pin LOCs
    tb_M65C02.v             - M65C02 testbench with RAM/ROM and interrupt sources

Additional work is needed for verification, but this release successfully
executes the same test program as the previous release of the M65C02 processor
and the M65C02 core.

#####Release 2.7

Modified the Release 2.6 M65C02 processor to use a newly released version of the
microprogram controller. The new microprogram controller, M65C02_MPCv4.v,
modifies the behavior of the built-in microcycle length controller. It fixes the
microcycle length to 4, and adds four additional states by which external
devices can request wait states. The new microprogram controller adds wait
states in integer multiples of the memory cycle. In this way, the clock stretch
logic built using a FF and a BUFGMUX clock multiplexer can be removed, and the
external Phi1O and Phi2O signals will maintain their natural 50% DC signal
characteristic.

The change to the microprogram controller required a change to the core and to
the interface between the core and the M65C02 processor. Within the core, the
change in the microprogram controller removed the need for the cycle extension
logic used to insert an extra state in the microcycle whenever a BCD instruction
is executed. That extra cycle is only needed when the core is operating with
single memory. Since the microcycle is fixed to 4 with the new microprogram
controller, the BCD mode microcycle extension logic was removed.

The interface change refers to the need to increase the width of the microstate
signal, MC, from 2 to 3 bits. Within the M65C02 processor, the additional states
supported by the larger MC port required that the clock enable for the external
memory data input register be modified. The nominal external input data sampling
point is cycle 3, falling edge of Phi2O. With wait states, the data sampling
point becomed cycle 3 or cycle 7. For data sampling, the external Rdy input
signal must also be asserted. A final change to the M65C02 processor is that the
Phi1O and Phi2O signals are now set and reset using four microstate decode
signals rather than two.

The incorporation of the last block memory into the design resulted in a loss 
of performance. The M65C02 processor is unable to maintain an external memory 
cycle rate of 18.432 MHz when the internal block RAM is included. The 
additional decode and input data multiplexer impose a path delay that lowers 
the memory interface operating speed to 16 MHz. Thus, the nearest baud rate 
frequency is 14.7456 MHz.

Operating at 14.7456 MHz requires external devices to request a wait state if 
they are unable to accept or supply data within 33.908ns. (At 16 MHz 
operation, the access time requirement is 31.25ns.) A single wait state 
extends the memory access time to 101.725ns. At 14.7456 MHz or 16 MHz, the 
memory cycle characteristics of the M65C02 processor allow the use of low-cost 
high-speed asynchronous SRAMs, and with one wait state, low-cost NOR Flash 
EEPROMs in 45, 55, 70, or 90ns speed grades.

The following table summarizes PAR results for Release 2.7 of the M65C02
processor:

                                           Used Avail  %
    Number of Slice Flip Flops              205 1408  14%   
    Number of 4 input LUTs                  720 1408  51%   

    Number of occupied Slices               401  704  56%   
        Number of Slices related logic      401  401 100%   
        Number of Slices unrelated logic      0  401   0%   
    Total Number of 4 input LUTs            728 1408  51%   
        Number used as logic                719       
        Number used as a route-thru           8       
        Number used as Shift registers        1       
    Number of bonded IOBs 
        Number of bonded pads                54   68  79%   
        IOB Flip Flops                       79       
    Number of BUFGMUXs                        4   24  16%   
    Number of DCMs                            1    2  50%   
    Number of RAMB16BWEs                      3    3 100% 

    Best Case Achievable:                15.625ns (0.000ns Setup, 0.961ns Hold)

The files modified in this release are:

    M65C02.v                - M65C02 microprocessor demonstration
      M65C02_Core.v         - M65C02 core logic
        M65C02_MPCv4.v      - M65C02 core microprogram controller
      M65C02.ucf            - User Constraints File: period and pin LOCs
    M65C02.tcl              - M65C02 ISE tool configurations/settings
    tb_M65C02.v             - M65C02 testbench with RAM/ROM and interrupt sources

Testing with the current testbench demonstrates that the M65C02 processor 
correctly executes the 65C02 test program, M65C02_Tst3.a65, used in previous 
testing of the M65C02 core with tb_M65C02_Core.v. That provides confidence 
that the integration of the core logic with the memory interface, interrupt 
handler, reset controller, and internal block RAM did not introduce any errors 
related to the core. However, the circuits in the wrapper around the core 
logic have not been extensively tested. The testing that has been performed to 
date indicate these circuits are operating correctly, but the tests performed 
to date only test the nominal cases and not those cases on the margins.

For example, the interrupt handler has demonstrated that it is able to handle 
vector generation for RST, IRQ, and BRK; NMI vector processing has not yet 
been tested. Another signal not yet tested is the reset logic's characteristic 
that requires the external nRst signal to be asserted for four cycle of the 
input clock before it is recognized. This behavior has not yet been tested, nor 
has the related behavior that a loss of lock of the internal clock generator
will assert reset to the M65C02 processor.

#####Release 2.71

Corrected logic for generating an internal reset signal, Rst, based on an 
external reset, nRst, and the state of the DCM_Locked signal. The vector 
reduction operator applied, '&', is incorrect. The correct vector reduction 
operator is '|', or logic OR. The correction has been made, and the FPGA 
correctly drives the nRstO output with the complement of the internal reset 
signal, Rst.

The changes have been made to the M65C02.v module, and only that module has 
been loaded into the MAM65C02 GitHUB repository.

#####Release 2.72

Improved the timing of the soft-core microprocessor, M65C02, by using a more 
efficient scheme for the internal bus multiplexers. Previous releases of the 
core, M65C02_Core, and the soft-core microprocessor used multiplexers 
generated using _switch/case select_ constructs.

Although these constructs are an effective and fast means for generating bus 
multiplexers, there are some penalties. This latest release has resorted to 
using one-hot decode ROMs tied to the various bus selects in the 
implementation, and then forcing the various data sources to connect to the 
busses as gated signals. When not gated, a logic 0 is driven onto the bus. At 
the terminal end, a simple OR gate is used to collect all of the desired gated 
signals.

The result of this effort has been a significant improvement in the 
combinatorial path delays. Prior to this optimization, the synthesizer 
reported a clock period performance of ~55 MHz. After the OR bus optimization 
was fully incorporated, the synthesizer reports a minimum period of ~74 MHz. 
This is nearly a 35% improvement in the combinatorial path delays.

The resulting improvement is sufficient to allow the soft-core processor to 
support an operating speed of **73.728 MHz** which corresponds to a single 
instruction cycle time of **18.432 MHz** given this core's 4 cycle microcycle. 
In addition to the improved combinatorial path delays, the improvement in path 
delays has allowed the core to be synthesized, Mapped, and PARed for minimum 
area. The result is a significant reduction in the resource utilization in the 
target XC3S50A-4VQG100I FPGA.

The following table summarizes PAR results for Release 2.7 of the M65C02
processor: **XC3S50A-4VQG100I**

                                           Used Avail  %
    Number of Slice Flip Flops              248 1408  17%   
    Number of 4 input LUTs                  647 1408  45%   

    Number of occupied Slices               400  704  56%   
        Number of Slices related logic      400  400 100%   
        Number of Slices unrelated logic      0  400   0%   
    Total Number of 4 input LUTs            661 1408  46%   
        Number used as logic                646       
        Number used as a route-thru          14       
        Number used as Shift registers        1       
    Number of bonded IOBs 
        Number of bonded pads                54   68  79%   
        IOB Flip Flops                       79       
    Number of BUFGMUXs                        3   24  16%   
    Number of DCMs                            1    2  50%   
    Number of RAMB16BWEs                      3    3 100% 

    Best Case Achievable:                13.516ns (0.047ns Setup, 1.021ns Hold)

The files modified in this release are:

    M65C02.v                - M65C02 microprocessor demonstration
      M65C02_Core.v         - M65C02 core logic
        M65C02_AddrGen.v    - M65C02 core microprogram controller
        M65C02_ALU.v        - M65C02 core ALU
          M65C02_BIN.v      - M65C02 ALU Binary mode adder
          M65C02_BCD.v      - M65C02 ALU Decimal mode adder
      M65C02.ucf            - User Constraints File: period and pin LOCs
    M65C02.tcl              - M65C02 ISE tool configurations/settings

Additional optimizations in the ALU can be applied, but with the improvements 
made with this release, a -5 speed grade part can be made to operate at 90+ 
MHz. If higher speeds are needed, then further optimization, including adding 
pipeline registers to the ALU, can be made. Some pipelining can be easily 
added because of the 4 clock microcycle around which the soft-core processor 
is built.

#####Release 2.73

Improved the modularity of the M65C02 top level module by creating modules for 
clock generation and interrupt handling. Updated the design document, and 
deleted unnecessary files.