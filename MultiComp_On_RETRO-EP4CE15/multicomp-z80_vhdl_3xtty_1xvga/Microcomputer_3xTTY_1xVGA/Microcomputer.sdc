## Generated SDC file "Microcomputer.out.sdc"

## Copyright (C) 1991-2013 Altera Corporation
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, Altera MegaCore Function License 
## Agreement, or other applicable license agreement, including, 
## without limitation, that your use is for the sole purpose of 
## programming logic devices manufactured by Altera and sold by 
## Altera or its authorized distributors.  Please refer to the 
## applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus II"
## VERSION "Version 13.0.1 Build 232 06/12/2013 Service Pack 1 SJ Web Edition"

## DATE    "Wed Jan 23 12:16:28 2019"

##
## DEVICE  "EP4CE6E22C8"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {clk25} -period 40.000 -waveform { 0.000 20.000 } [get_ports {clk25}]
create_clock -name {T80s:cpu1|IORQ_n} -period 1.000 -waveform { 0.000 0.500 } [get_registers {T80s:cpu1|IORQ_n}]
create_clock -name {cpuClock} -period 1.000 -waveform { 0.000 0.500 } [get_registers {cpuClock}]
create_clock -name {BRG:brg3|baud_clk} -period 1.000 -waveform { 0.000 0.500 } [get_registers {BRG:brg3|baud_clk}]
create_clock -name {BRG:brg1|baud_clk} -period 1.000 -waveform { 0.000 0.500 } [get_registers {BRG:brg1|baud_clk}]
create_clock -name {BRG:brg4|baud_clk} -period 1.000 -waveform { 0.000 0.500 } [get_registers {BRG:brg4|baud_clk}]
create_clock -name {BRG:brg2|baud_clk} -period 1.000 -waveform { 0.000 0.500 } [get_registers {BRG:brg2|baud_clk}]


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {pll|altpll_component|auto_generated|pll1|clk[0]} -source [get_pins {pll|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 2 -master_clock {clk25} [get_pins {pll|altpll_component|auto_generated|pll1|clk[0]}] 


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {BRG:brg2|baud_clk}] -rise_to [get_clocks {BRG:brg2|baud_clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {BRG:brg2|baud_clk}] -fall_to [get_clocks {BRG:brg2|baud_clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {BRG:brg2|baud_clk}] -rise_to [get_clocks {T80s:cpu1|IORQ_n}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {BRG:brg2|baud_clk}] -fall_to [get_clocks {T80s:cpu1|IORQ_n}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {BRG:brg2|baud_clk}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -rise_from [get_clocks {BRG:brg2|baud_clk}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {BRG:brg2|baud_clk}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -rise_from [get_clocks {BRG:brg2|baud_clk}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {BRG:brg2|baud_clk}] -rise_to [get_clocks {BRG:brg2|baud_clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {BRG:brg2|baud_clk}] -fall_to [get_clocks {BRG:brg2|baud_clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {BRG:brg2|baud_clk}] -rise_to [get_clocks {T80s:cpu1|IORQ_n}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {BRG:brg2|baud_clk}] -fall_to [get_clocks {T80s:cpu1|IORQ_n}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {BRG:brg2|baud_clk}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -fall_from [get_clocks {BRG:brg2|baud_clk}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {BRG:brg2|baud_clk}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -fall_from [get_clocks {BRG:brg2|baud_clk}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {BRG:brg4|baud_clk}] -rise_to [get_clocks {BRG:brg4|baud_clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {BRG:brg4|baud_clk}] -fall_to [get_clocks {BRG:brg4|baud_clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {BRG:brg4|baud_clk}] -rise_to [get_clocks {T80s:cpu1|IORQ_n}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {BRG:brg4|baud_clk}] -fall_to [get_clocks {T80s:cpu1|IORQ_n}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {BRG:brg4|baud_clk}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -rise_from [get_clocks {BRG:brg4|baud_clk}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {BRG:brg4|baud_clk}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -rise_from [get_clocks {BRG:brg4|baud_clk}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {BRG:brg4|baud_clk}] -rise_to [get_clocks {BRG:brg4|baud_clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {BRG:brg4|baud_clk}] -fall_to [get_clocks {BRG:brg4|baud_clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {BRG:brg4|baud_clk}] -rise_to [get_clocks {T80s:cpu1|IORQ_n}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {BRG:brg4|baud_clk}] -fall_to [get_clocks {T80s:cpu1|IORQ_n}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {BRG:brg4|baud_clk}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -fall_from [get_clocks {BRG:brg4|baud_clk}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {BRG:brg4|baud_clk}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -fall_from [get_clocks {BRG:brg4|baud_clk}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {BRG:brg1|baud_clk}] -rise_to [get_clocks {BRG:brg1|baud_clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {BRG:brg1|baud_clk}] -fall_to [get_clocks {BRG:brg1|baud_clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {BRG:brg1|baud_clk}] -rise_to [get_clocks {T80s:cpu1|IORQ_n}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {BRG:brg1|baud_clk}] -fall_to [get_clocks {T80s:cpu1|IORQ_n}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {BRG:brg1|baud_clk}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -rise_from [get_clocks {BRG:brg1|baud_clk}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {BRG:brg1|baud_clk}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -rise_from [get_clocks {BRG:brg1|baud_clk}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {BRG:brg1|baud_clk}] -rise_to [get_clocks {BRG:brg1|baud_clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {BRG:brg1|baud_clk}] -fall_to [get_clocks {BRG:brg1|baud_clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {BRG:brg1|baud_clk}] -rise_to [get_clocks {T80s:cpu1|IORQ_n}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {BRG:brg1|baud_clk}] -fall_to [get_clocks {T80s:cpu1|IORQ_n}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {BRG:brg1|baud_clk}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -fall_from [get_clocks {BRG:brg1|baud_clk}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {BRG:brg1|baud_clk}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -fall_from [get_clocks {BRG:brg1|baud_clk}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {BRG:brg3|baud_clk}] -rise_to [get_clocks {BRG:brg3|baud_clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {BRG:brg3|baud_clk}] -fall_to [get_clocks {BRG:brg3|baud_clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {BRG:brg3|baud_clk}] -rise_to [get_clocks {T80s:cpu1|IORQ_n}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {BRG:brg3|baud_clk}] -fall_to [get_clocks {T80s:cpu1|IORQ_n}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {BRG:brg3|baud_clk}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -rise_from [get_clocks {BRG:brg3|baud_clk}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {BRG:brg3|baud_clk}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -rise_from [get_clocks {BRG:brg3|baud_clk}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {BRG:brg3|baud_clk}] -rise_to [get_clocks {BRG:brg3|baud_clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {BRG:brg3|baud_clk}] -fall_to [get_clocks {BRG:brg3|baud_clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {BRG:brg3|baud_clk}] -rise_to [get_clocks {T80s:cpu1|IORQ_n}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {BRG:brg3|baud_clk}] -fall_to [get_clocks {T80s:cpu1|IORQ_n}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {BRG:brg3|baud_clk}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -fall_from [get_clocks {BRG:brg3|baud_clk}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {BRG:brg3|baud_clk}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -fall_from [get_clocks {BRG:brg3|baud_clk}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {cpuClock}] -rise_to [get_clocks {BRG:brg2|baud_clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {cpuClock}] -fall_to [get_clocks {BRG:brg2|baud_clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {cpuClock}] -rise_to [get_clocks {BRG:brg4|baud_clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {cpuClock}] -fall_to [get_clocks {BRG:brg4|baud_clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {cpuClock}] -rise_to [get_clocks {BRG:brg1|baud_clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {cpuClock}] -fall_to [get_clocks {BRG:brg1|baud_clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {cpuClock}] -rise_to [get_clocks {BRG:brg3|baud_clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {cpuClock}] -fall_to [get_clocks {BRG:brg3|baud_clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {cpuClock}] -rise_to [get_clocks {cpuClock}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {cpuClock}] -fall_to [get_clocks {cpuClock}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {cpuClock}] -rise_to [get_clocks {T80s:cpu1|IORQ_n}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {cpuClock}] -fall_to [get_clocks {T80s:cpu1|IORQ_n}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {cpuClock}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -rise_from [get_clocks {cpuClock}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {cpuClock}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -rise_from [get_clocks {cpuClock}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {cpuClock}] -rise_to [get_clocks {BRG:brg2|baud_clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {cpuClock}] -fall_to [get_clocks {BRG:brg2|baud_clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {cpuClock}] -rise_to [get_clocks {BRG:brg4|baud_clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {cpuClock}] -fall_to [get_clocks {BRG:brg4|baud_clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {cpuClock}] -rise_to [get_clocks {BRG:brg1|baud_clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {cpuClock}] -fall_to [get_clocks {BRG:brg1|baud_clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {cpuClock}] -rise_to [get_clocks {BRG:brg3|baud_clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {cpuClock}] -fall_to [get_clocks {BRG:brg3|baud_clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {cpuClock}] -rise_to [get_clocks {cpuClock}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {cpuClock}] -fall_to [get_clocks {cpuClock}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {cpuClock}] -rise_to [get_clocks {T80s:cpu1|IORQ_n}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {cpuClock}] -fall_to [get_clocks {T80s:cpu1|IORQ_n}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {cpuClock}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -fall_from [get_clocks {cpuClock}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {cpuClock}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -fall_from [get_clocks {cpuClock}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {T80s:cpu1|IORQ_n}] -rise_to [get_clocks {BRG:brg2|baud_clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {T80s:cpu1|IORQ_n}] -fall_to [get_clocks {BRG:brg2|baud_clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {T80s:cpu1|IORQ_n}] -rise_to [get_clocks {BRG:brg4|baud_clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {T80s:cpu1|IORQ_n}] -fall_to [get_clocks {BRG:brg4|baud_clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {T80s:cpu1|IORQ_n}] -rise_to [get_clocks {BRG:brg1|baud_clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {T80s:cpu1|IORQ_n}] -fall_to [get_clocks {BRG:brg1|baud_clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {T80s:cpu1|IORQ_n}] -rise_to [get_clocks {BRG:brg3|baud_clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {T80s:cpu1|IORQ_n}] -fall_to [get_clocks {BRG:brg3|baud_clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {T80s:cpu1|IORQ_n}] -rise_to [get_clocks {cpuClock}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {T80s:cpu1|IORQ_n}] -fall_to [get_clocks {cpuClock}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {T80s:cpu1|IORQ_n}] -rise_to [get_clocks {T80s:cpu1|IORQ_n}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {T80s:cpu1|IORQ_n}] -fall_to [get_clocks {T80s:cpu1|IORQ_n}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {T80s:cpu1|IORQ_n}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -rise_from [get_clocks {T80s:cpu1|IORQ_n}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {T80s:cpu1|IORQ_n}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -rise_from [get_clocks {T80s:cpu1|IORQ_n}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {T80s:cpu1|IORQ_n}] -rise_to [get_clocks {BRG:brg2|baud_clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {T80s:cpu1|IORQ_n}] -fall_to [get_clocks {BRG:brg2|baud_clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {T80s:cpu1|IORQ_n}] -rise_to [get_clocks {BRG:brg4|baud_clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {T80s:cpu1|IORQ_n}] -fall_to [get_clocks {BRG:brg4|baud_clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {T80s:cpu1|IORQ_n}] -rise_to [get_clocks {BRG:brg1|baud_clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {T80s:cpu1|IORQ_n}] -fall_to [get_clocks {BRG:brg1|baud_clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {T80s:cpu1|IORQ_n}] -rise_to [get_clocks {BRG:brg3|baud_clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {T80s:cpu1|IORQ_n}] -fall_to [get_clocks {BRG:brg3|baud_clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {T80s:cpu1|IORQ_n}] -rise_to [get_clocks {cpuClock}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {T80s:cpu1|IORQ_n}] -fall_to [get_clocks {cpuClock}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {T80s:cpu1|IORQ_n}] -rise_to [get_clocks {T80s:cpu1|IORQ_n}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {T80s:cpu1|IORQ_n}] -fall_to [get_clocks {T80s:cpu1|IORQ_n}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {T80s:cpu1|IORQ_n}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -fall_from [get_clocks {T80s:cpu1|IORQ_n}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {T80s:cpu1|IORQ_n}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -fall_from [get_clocks {T80s:cpu1|IORQ_n}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {BRG:brg2|baud_clk}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {BRG:brg2|baud_clk}] -hold 0.070  
set_clock_uncertainty -rise_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {BRG:brg2|baud_clk}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {BRG:brg2|baud_clk}] -hold 0.070  
set_clock_uncertainty -rise_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {BRG:brg4|baud_clk}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {BRG:brg4|baud_clk}] -hold 0.070  
set_clock_uncertainty -rise_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {BRG:brg4|baud_clk}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {BRG:brg4|baud_clk}] -hold 0.070  
set_clock_uncertainty -rise_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {BRG:brg1|baud_clk}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {BRG:brg1|baud_clk}] -hold 0.070  
set_clock_uncertainty -rise_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {BRG:brg1|baud_clk}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {BRG:brg1|baud_clk}] -hold 0.070  
set_clock_uncertainty -rise_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {BRG:brg3|baud_clk}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {BRG:brg3|baud_clk}] -hold 0.070  
set_clock_uncertainty -rise_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {BRG:brg3|baud_clk}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {BRG:brg3|baud_clk}] -hold 0.070  
set_clock_uncertainty -rise_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {cpuClock}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {cpuClock}] -hold 0.070  
set_clock_uncertainty -rise_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {cpuClock}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {cpuClock}] -hold 0.070  
set_clock_uncertainty -rise_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {T80s:cpu1|IORQ_n}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {T80s:cpu1|IORQ_n}] -hold 0.070  
set_clock_uncertainty -rise_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {T80s:cpu1|IORQ_n}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {T80s:cpu1|IORQ_n}] -hold 0.070  
set_clock_uncertainty -rise_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {BRG:brg2|baud_clk}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {BRG:brg2|baud_clk}] -hold 0.070  
set_clock_uncertainty -fall_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {BRG:brg2|baud_clk}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {BRG:brg2|baud_clk}] -hold 0.070  
set_clock_uncertainty -fall_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {BRG:brg4|baud_clk}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {BRG:brg4|baud_clk}] -hold 0.070  
set_clock_uncertainty -fall_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {BRG:brg4|baud_clk}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {BRG:brg4|baud_clk}] -hold 0.070  
set_clock_uncertainty -fall_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {BRG:brg1|baud_clk}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {BRG:brg1|baud_clk}] -hold 0.070  
set_clock_uncertainty -fall_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {BRG:brg1|baud_clk}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {BRG:brg1|baud_clk}] -hold 0.070  
set_clock_uncertainty -fall_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {BRG:brg3|baud_clk}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {BRG:brg3|baud_clk}] -hold 0.070  
set_clock_uncertainty -fall_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {BRG:brg3|baud_clk}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {BRG:brg3|baud_clk}] -hold 0.070  
set_clock_uncertainty -fall_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {cpuClock}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {cpuClock}] -hold 0.070  
set_clock_uncertainty -fall_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {cpuClock}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {cpuClock}] -hold 0.070  
set_clock_uncertainty -fall_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {T80s:cpu1|IORQ_n}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {T80s:cpu1|IORQ_n}] -hold 0.070  
set_clock_uncertainty -fall_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {T80s:cpu1|IORQ_n}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {T80s:cpu1|IORQ_n}] -hold 0.070  
set_clock_uncertainty -fall_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}]  0.020  


#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

