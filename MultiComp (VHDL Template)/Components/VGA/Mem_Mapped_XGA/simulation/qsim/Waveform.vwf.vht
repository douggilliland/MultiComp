-- Copyright (C) 2018  Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License 
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel FPGA IP License Agreement, or other applicable license
-- agreement, including, without limitation, that your use is for
-- the sole purpose of programming logic devices manufactured by
-- Intel and sold by Intel or its authorized distributors.  Please
-- refer to the applicable agreement for further details.

-- *****************************************************************************
-- This file contains a Vhdl test bench with test vectors .The test vectors     
-- are exported from a vector file in the Quartus Waveform Editor and apply to  
-- the top level entity of the current Quartus project .The user can use this   
-- testbench to simulate his design using a third-party simulation tool .       
-- *****************************************************************************
-- Generated on "06/11/2019 05:15:36"
                                                             
-- Vhdl Test Bench(with test vectors) for design  :          Video_XVGA_64x32
-- 
-- Simulation tool : 3rd Party
-- 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                

ENTITY Video_XVGA_64x32_vhd_vec_tst IS
END Video_XVGA_64x32_vhd_vec_tst;
ARCHITECTURE Video_XVGA_64x32_arch OF Video_XVGA_64x32_vhd_vec_tst IS
-- constants                                                 
-- signals                                                   
SIGNAL charAddr : STD_LOGIC_VECTOR(10 DOWNTO 0);
SIGNAL charData : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL clk : STD_LOGIC;
SIGNAL dispAddr : STD_LOGIC_VECTOR(10 DOWNTO 0);
SIGNAL dispData : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL hAct : STD_LOGIC;
SIGNAL hSync : STD_LOGIC;
SIGNAL video : STD_LOGIC;
SIGNAL vSync : STD_LOGIC;
COMPONENT Video_XVGA_64x32
	PORT (
	charAddr : OUT STD_LOGIC_VECTOR(10 DOWNTO 0);
	charData : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
	clk : IN STD_LOGIC;
	dispAddr : OUT STD_LOGIC_VECTOR(10 DOWNTO 0);
	dispData : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
	hAct : OUT STD_LOGIC;
	hSync : OUT STD_LOGIC;
	video : OUT STD_LOGIC;
	vSync : OUT STD_LOGIC
	);
END COMPONENT;
BEGIN
	i1 : Video_XVGA_64x32
	PORT MAP (
-- list connections between master ports and signals
	charAddr => charAddr,
	charData => charData,
	clk => clk,
	dispAddr => dispAddr,
	dispData => dispData,
	hAct => hAct,
	hSync => hSync,
	video => video,
	vSync => vSync
	);
-- charData[7]
t_prcs_charData_7: PROCESS
BEGIN
	charData(7) <= '0';
WAIT;
END PROCESS t_prcs_charData_7;
-- charData[6]
t_prcs_charData_6: PROCESS
BEGIN
	charData(6) <= '0';
WAIT;
END PROCESS t_prcs_charData_6;
-- charData[5]
t_prcs_charData_5: PROCESS
BEGIN
	charData(5) <= '0';
WAIT;
END PROCESS t_prcs_charData_5;
-- charData[4]
t_prcs_charData_4: PROCESS
BEGIN
	charData(4) <= '0';
WAIT;
END PROCESS t_prcs_charData_4;
-- charData[3]
t_prcs_charData_3: PROCESS
BEGIN
	charData(3) <= '0';
WAIT;
END PROCESS t_prcs_charData_3;
-- charData[2]
t_prcs_charData_2: PROCESS
BEGIN
	charData(2) <= '0';
WAIT;
END PROCESS t_prcs_charData_2;
-- charData[1]
t_prcs_charData_1: PROCESS
BEGIN
	charData(1) <= '0';
WAIT;
END PROCESS t_prcs_charData_1;
-- charData[0]
t_prcs_charData_0: PROCESS
BEGIN
	charData(0) <= '0';
WAIT;
END PROCESS t_prcs_charData_0;

-- clk
t_prcs_clk: PROCESS
BEGIN
LOOP
	clk <= '0';
	WAIT FOR 1000 ps;
	clk <= '1';
	WAIT FOR 1000 ps;
	IF (NOW >= 1000000 ps) THEN WAIT; END IF;
END LOOP;
END PROCESS t_prcs_clk;
-- dispData[7]
t_prcs_dispData_7: PROCESS
BEGIN
	dispData(7) <= '0';
WAIT;
END PROCESS t_prcs_dispData_7;
-- dispData[6]
t_prcs_dispData_6: PROCESS
BEGIN
	dispData(6) <= '0';
WAIT;
END PROCESS t_prcs_dispData_6;
-- dispData[5]
t_prcs_dispData_5: PROCESS
BEGIN
	dispData(5) <= '0';
WAIT;
END PROCESS t_prcs_dispData_5;
-- dispData[4]
t_prcs_dispData_4: PROCESS
BEGIN
	dispData(4) <= '0';
WAIT;
END PROCESS t_prcs_dispData_4;
-- dispData[3]
t_prcs_dispData_3: PROCESS
BEGIN
	dispData(3) <= '0';
WAIT;
END PROCESS t_prcs_dispData_3;
-- dispData[2]
t_prcs_dispData_2: PROCESS
BEGIN
	dispData(2) <= '0';
WAIT;
END PROCESS t_prcs_dispData_2;
-- dispData[1]
t_prcs_dispData_1: PROCESS
BEGIN
	dispData(1) <= '0';
WAIT;
END PROCESS t_prcs_dispData_1;
-- dispData[0]
t_prcs_dispData_0: PROCESS
BEGIN
	dispData(0) <= '0';
WAIT;
END PROCESS t_prcs_dispData_0;
END Video_XVGA_64x32_arch;
