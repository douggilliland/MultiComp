onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {MEM MAPPER}
add wave -noupdate /microcomputer/mm1/n_reset
add wave -noupdate /microcomputer/mm1/clk
add wave -noupdate /microcomputer/mm1/hold
add wave -noupdate /microcomputer/mm1/n_wr
add wave -noupdate /microcomputer/mm1/dataIn
add wave -noupdate /microcomputer/mm1/regAddr
add wave -noupdate /microcomputer/mm1/cpuAddr
add wave -noupdate /microcomputer/mm1/ramAddr
add wave -noupdate /microcomputer/mm1/ramWrInhib
add wave -noupdate /microcomputer/mm1/romInhib
add wave -noupdate -divider {CPU CLK CONTROL}
add wave -noupdate /microcomputer/clk
add wave -noupdate -radix hexadecimal /microcomputer/state
add wave -noupdate /microcomputer/hold
add wave -noupdate /microcomputer/vma
add wave -noupdate /microcomputer/n_cpuWr
add wave -noupdate /microcomputer/n_sRamWE
add wave -noupdate /microcomputer/n_sRamOE
add wave -noupdate /microcomputer/n_WR
add wave -noupdate /microcomputer/n_RD
add wave -noupdate -divider {TOP LEVEL}
add wave -noupdate /microcomputer/n_reset
add wave -noupdate -radix hexadecimal /microcomputer/sRamData
add wave -noupdate -radix hexadecimal /microcomputer/sRamAddress
add wave -noupdate -radix hexadecimal /microcomputer/cpuAddress
add wave -noupdate -radix hexadecimal /microcomputer/cpuDataOut
add wave -noupdate -radix hexadecimal /microcomputer/cpuDataIn
add wave -noupdate -radix hexadecimal /microcomputer/basRomData
add wave -noupdate -radix hexadecimal /microcomputer/interface1DataOut
add wave -noupdate -radix hexadecimal /microcomputer/interface2DataOut
add wave -noupdate -radix hexadecimal /microcomputer/sdCardDataOut
add wave -noupdate /microcomputer/rxd1
add wave -noupdate /microcomputer/txd1
add wave -noupdate /microcomputer/rts1
add wave -noupdate /microcomputer/videoSync
add wave -noupdate /microcomputer/video
add wave -noupdate /microcomputer/videoR0
add wave -noupdate /microcomputer/videoG0
add wave -noupdate /microcomputer/videoB0
add wave -noupdate /microcomputer/videoR1
add wave -noupdate /microcomputer/videoG1
add wave -noupdate /microcomputer/videoB1
add wave -noupdate /microcomputer/hSync
add wave -noupdate /microcomputer/vSync
add wave -noupdate /microcomputer/ps2Clk
add wave -noupdate /microcomputer/ps2Data
add wave -noupdate /microcomputer/sdCS
add wave -noupdate /microcomputer/sdMOSI
add wave -noupdate /microcomputer/sdMISO
add wave -noupdate /microcomputer/sdSCLK
add wave -noupdate /microcomputer/driveLED
add wave -noupdate /microcomputer/n_int1
add wave -noupdate /microcomputer/n_int2
add wave -noupdate /microcomputer/n_sRamCS
add wave -noupdate /microcomputer/n_basRomCS
add wave -noupdate /microcomputer/n_interface1CS
add wave -noupdate /microcomputer/n_interface2CS
add wave -noupdate /microcomputer/n_sdCardCS
add wave -noupdate /microcomputer/serialClkCount
add wave -noupdate /microcomputer/n_WR_uart
add wave -noupdate /microcomputer/n_RD_uart
add wave -noupdate /microcomputer/n_WR_sd
add wave -noupdate /microcomputer/n_RD_sd
add wave -noupdate /microcomputer/n_WR_vdu
add wave -noupdate /microcomputer/n_RD_vdu
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {730024 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 254
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {606885 ps} {950688 ps}
