#-------------------------------------------------------------------------------
# PROJECT: PIPE MANIA - GAME FOR FPGA
#-------------------------------------------------------------------------------
# NAME:    TIMING CONSTRAINTS
# AUTHORS: Jakub Cabal <xcabal05@stud.feec.vutbr.cz>
# LICENSE: The MIT License, please read LICENSE file
# WEBSITE: https://github.com/jakubcabal/pipemania-fpga-game
#-------------------------------------------------------------------------------

create_clock -name CLK50 -period 20.000 [get_ports {CLK}]

set_false_path -from [get_ports {ASYNC_RST}] -to [all_registers]
