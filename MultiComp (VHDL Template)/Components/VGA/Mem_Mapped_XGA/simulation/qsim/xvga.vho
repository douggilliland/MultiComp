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

-- VENDOR "Altera"
-- PROGRAM "Quartus Prime"
-- VERSION "Version 18.1.0 Build 625 09/12/2018 SJ Lite Edition"

-- DATE "06/11/2019 05:15:38"

-- 
-- Device: Altera EP4CE6E22A7 Package TQFP144
-- 

-- 
-- This VHDL file should be used for ModelSim-Altera (VHDL) only
-- 

LIBRARY CYCLONEIVE;
LIBRARY IEEE;
USE CYCLONEIVE.CYCLONEIVE_COMPONENTS.ALL;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY 	hard_block IS
    PORT (
	devoe : IN std_logic;
	devclrn : IN std_logic;
	devpor : IN std_logic
	);
END hard_block;

-- Design Ports Information
-- ~ALTERA_ASDO_DATA1~	=>  Location: PIN_6,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- ~ALTERA_FLASH_nCE_nCSO~	=>  Location: PIN_8,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- ~ALTERA_DCLK~	=>  Location: PIN_12,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- ~ALTERA_DATA0~	=>  Location: PIN_13,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- ~ALTERA_nCEO~	=>  Location: PIN_101,	 I/O Standard: 2.5 V,	 Current Strength: 8mA


ARCHITECTURE structure OF hard_block IS
SIGNAL gnd : std_logic := '0';
SIGNAL vcc : std_logic := '1';
SIGNAL unknown : std_logic := 'X';
SIGNAL ww_devoe : std_logic;
SIGNAL ww_devclrn : std_logic;
SIGNAL ww_devpor : std_logic;
SIGNAL \~ALTERA_ASDO_DATA1~~padout\ : std_logic;
SIGNAL \~ALTERA_FLASH_nCE_nCSO~~padout\ : std_logic;
SIGNAL \~ALTERA_DATA0~~padout\ : std_logic;
SIGNAL \~ALTERA_ASDO_DATA1~~ibuf_o\ : std_logic;
SIGNAL \~ALTERA_FLASH_nCE_nCSO~~ibuf_o\ : std_logic;
SIGNAL \~ALTERA_DATA0~~ibuf_o\ : std_logic;

BEGIN

ww_devoe <= devoe;
ww_devclrn <= devclrn;
ww_devpor <= devpor;
END structure;


LIBRARY ALTERA;
LIBRARY CYCLONEIVE;
LIBRARY IEEE;
USE ALTERA.ALTERA_PRIMITIVES_COMPONENTS.ALL;
USE CYCLONEIVE.CYCLONEIVE_COMPONENTS.ALL;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY 	Video_XVGA_64x32 IS
    PORT (
	charAddr : OUT std_logic_vector(10 DOWNTO 0);
	charData : IN std_logic_vector(7 DOWNTO 0);
	dispAddr : OUT std_logic_vector(10 DOWNTO 0);
	dispData : IN std_logic_vector(7 DOWNTO 0);
	clk : IN std_logic;
	video : OUT std_logic;
	vSync : OUT std_logic;
	hSync : OUT std_logic;
	hAct : OUT std_logic
	);
END Video_XVGA_64x32;

-- Design Ports Information
-- charAddr[0]	=>  Location: PIN_73,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- charAddr[1]	=>  Location: PIN_72,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- charAddr[2]	=>  Location: PIN_84,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- charAddr[3]	=>  Location: PIN_28,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- charAddr[4]	=>  Location: PIN_30,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- charAddr[5]	=>  Location: PIN_49,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- charAddr[6]	=>  Location: PIN_120,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- charAddr[7]	=>  Location: PIN_141,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- charAddr[8]	=>  Location: PIN_124,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- charAddr[9]	=>  Location: PIN_44,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- charAddr[10]	=>  Location: PIN_136,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- dispAddr[0]	=>  Location: PIN_86,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- dispAddr[1]	=>  Location: PIN_85,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- dispAddr[2]	=>  Location: PIN_76,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- dispAddr[3]	=>  Location: PIN_67,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- dispAddr[4]	=>  Location: PIN_87,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- dispAddr[5]	=>  Location: PIN_80,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- dispAddr[6]	=>  Location: PIN_74,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- dispAddr[7]	=>  Location: PIN_70,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- dispAddr[8]	=>  Location: PIN_71,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- dispAddr[9]	=>  Location: PIN_83,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- dispAddr[10]	=>  Location: PIN_75,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- video	=>  Location: PIN_58,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- vSync	=>  Location: PIN_60,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- hSync	=>  Location: PIN_77,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- hAct	=>  Location: PIN_66,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- dispData[0]	=>  Location: PIN_24,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- dispData[1]	=>  Location: PIN_25,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- dispData[2]	=>  Location: PIN_50,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- dispData[3]	=>  Location: PIN_119,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- dispData[4]	=>  Location: PIN_138,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- dispData[5]	=>  Location: PIN_125,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- dispData[6]	=>  Location: PIN_43,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- dispData[7]	=>  Location: PIN_135,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- clk	=>  Location: PIN_23,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- charData[2]	=>  Location: PIN_54,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- charData[1]	=>  Location: PIN_69,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- charData[3]	=>  Location: PIN_98,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- charData[0]	=>  Location: PIN_64,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- charData[6]	=>  Location: PIN_65,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- charData[5]	=>  Location: PIN_55,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- charData[7]	=>  Location: PIN_68,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- charData[4]	=>  Location: PIN_59,	 I/O Standard: 2.5 V,	 Current Strength: Default


ARCHITECTURE structure OF Video_XVGA_64x32 IS
SIGNAL gnd : std_logic := '0';
SIGNAL vcc : std_logic := '1';
SIGNAL unknown : std_logic := 'X';
SIGNAL devoe : std_logic := '1';
SIGNAL devclrn : std_logic := '1';
SIGNAL devpor : std_logic := '1';
SIGNAL ww_devoe : std_logic;
SIGNAL ww_devclrn : std_logic;
SIGNAL ww_devpor : std_logic;
SIGNAL ww_charAddr : std_logic_vector(10 DOWNTO 0);
SIGNAL ww_charData : std_logic_vector(7 DOWNTO 0);
SIGNAL ww_dispAddr : std_logic_vector(10 DOWNTO 0);
SIGNAL ww_dispData : std_logic_vector(7 DOWNTO 0);
SIGNAL ww_clk : std_logic;
SIGNAL ww_video : std_logic;
SIGNAL ww_vSync : std_logic;
SIGNAL ww_hSync : std_logic;
SIGNAL ww_hAct : std_logic;
SIGNAL \clk~inputclkctrl_INCLK_bus\ : std_logic_vector(3 DOWNTO 0);
SIGNAL \charAddr[0]~output_o\ : std_logic;
SIGNAL \charAddr[1]~output_o\ : std_logic;
SIGNAL \charAddr[2]~output_o\ : std_logic;
SIGNAL \charAddr[3]~output_o\ : std_logic;
SIGNAL \charAddr[4]~output_o\ : std_logic;
SIGNAL \charAddr[5]~output_o\ : std_logic;
SIGNAL \charAddr[6]~output_o\ : std_logic;
SIGNAL \charAddr[7]~output_o\ : std_logic;
SIGNAL \charAddr[8]~output_o\ : std_logic;
SIGNAL \charAddr[9]~output_o\ : std_logic;
SIGNAL \charAddr[10]~output_o\ : std_logic;
SIGNAL \dispAddr[0]~output_o\ : std_logic;
SIGNAL \dispAddr[1]~output_o\ : std_logic;
SIGNAL \dispAddr[2]~output_o\ : std_logic;
SIGNAL \dispAddr[3]~output_o\ : std_logic;
SIGNAL \dispAddr[4]~output_o\ : std_logic;
SIGNAL \dispAddr[5]~output_o\ : std_logic;
SIGNAL \dispAddr[6]~output_o\ : std_logic;
SIGNAL \dispAddr[7]~output_o\ : std_logic;
SIGNAL \dispAddr[8]~output_o\ : std_logic;
SIGNAL \dispAddr[9]~output_o\ : std_logic;
SIGNAL \dispAddr[10]~output_o\ : std_logic;
SIGNAL \video~output_o\ : std_logic;
SIGNAL \vSync~output_o\ : std_logic;
SIGNAL \hSync~output_o\ : std_logic;
SIGNAL \hAct~output_o\ : std_logic;
SIGNAL \clk~input_o\ : std_logic;
SIGNAL \clk~inputclkctrl_outclk\ : std_logic;
SIGNAL \theCharRow[0]~8_combout\ : std_logic;
SIGNAL \horizCount[0]~11_combout\ : std_logic;
SIGNAL \horizCount[0]~12\ : std_logic;
SIGNAL \horizCount[1]~13_combout\ : std_logic;
SIGNAL \horizCount[1]~14\ : std_logic;
SIGNAL \horizCount[2]~15_combout\ : std_logic;
SIGNAL \horizCount[2]~16\ : std_logic;
SIGNAL \horizCount[3]~17_combout\ : std_logic;
SIGNAL \horizCount[3]~18\ : std_logic;
SIGNAL \horizCount[4]~19_combout\ : std_logic;
SIGNAL \horizCount[4]~20\ : std_logic;
SIGNAL \horizCount[5]~21_combout\ : std_logic;
SIGNAL \horizCount[5]~22\ : std_logic;
SIGNAL \horizCount[6]~23_combout\ : std_logic;
SIGNAL \horizCount[6]~24\ : std_logic;
SIGNAL \horizCount[7]~25_combout\ : std_logic;
SIGNAL \horizCount[7]~26\ : std_logic;
SIGNAL \horizCount[8]~27_combout\ : std_logic;
SIGNAL \horizCount[8]~28\ : std_logic;
SIGNAL \horizCount[9]~29_combout\ : std_logic;
SIGNAL \horizCount[9]~30\ : std_logic;
SIGNAL \horizCount[10]~31_combout\ : std_logic;
SIGNAL \LessThan0~0_combout\ : std_logic;
SIGNAL \LessThan0~1_combout\ : std_logic;
SIGNAL \prescaleRow~1_combout\ : std_logic;
SIGNAL \prescaleRow~0_combout\ : std_logic;
SIGNAL \theCharRow[0]~10_combout\ : std_logic;
SIGNAL \theCharRow[0]~9\ : std_logic;
SIGNAL \theCharRow[1]~11_combout\ : std_logic;
SIGNAL \theCharRow[1]~12\ : std_logic;
SIGNAL \theCharRow[2]~13_combout\ : std_logic;
SIGNAL \dispData[0]~input_o\ : std_logic;
SIGNAL \dispData[1]~input_o\ : std_logic;
SIGNAL \dispData[2]~input_o\ : std_logic;
SIGNAL \dispData[3]~input_o\ : std_logic;
SIGNAL \dispData[4]~input_o\ : std_logic;
SIGNAL \dispData[5]~input_o\ : std_logic;
SIGNAL \dispData[6]~input_o\ : std_logic;
SIGNAL \dispData[7]~input_o\ : std_logic;
SIGNAL \theCharRow[2]~14\ : std_logic;
SIGNAL \theCharRow[3]~15_combout\ : std_logic;
SIGNAL \theCharRow[3]~16\ : std_logic;
SIGNAL \theCharRow[4]~17_combout\ : std_logic;
SIGNAL \theCharRow[4]~18\ : std_logic;
SIGNAL \theCharRow[5]~19_combout\ : std_logic;
SIGNAL \theCharRow[5]~20\ : std_logic;
SIGNAL \theCharRow[6]~21_combout\ : std_logic;
SIGNAL \theCharRow[6]~22\ : std_logic;
SIGNAL \theCharRow[7]~23_combout\ : std_logic;
SIGNAL \vertLineCount[0]~10_combout\ : std_logic;
SIGNAL \LessThan1~0_combout\ : std_logic;
SIGNAL \LessThan1~1_combout\ : std_logic;
SIGNAL \LessThan1~2_combout\ : std_logic;
SIGNAL \vertLineCount[0]~11\ : std_logic;
SIGNAL \vertLineCount[1]~12_combout\ : std_logic;
SIGNAL \vertLineCount[1]~13\ : std_logic;
SIGNAL \vertLineCount[2]~14_combout\ : std_logic;
SIGNAL \vertLineCount[2]~15\ : std_logic;
SIGNAL \vertLineCount[3]~16_combout\ : std_logic;
SIGNAL \vertLineCount[3]~17\ : std_logic;
SIGNAL \vertLineCount[4]~18_combout\ : std_logic;
SIGNAL \vertLineCount[4]~19\ : std_logic;
SIGNAL \vertLineCount[5]~20_combout\ : std_logic;
SIGNAL \vertLineCount[5]~21\ : std_logic;
SIGNAL \vertLineCount[6]~22_combout\ : std_logic;
SIGNAL \vertLineCount[6]~23\ : std_logic;
SIGNAL \vertLineCount[7]~24_combout\ : std_logic;
SIGNAL \vertLineCount[7]~25\ : std_logic;
SIGNAL \vertLineCount[8]~26_combout\ : std_logic;
SIGNAL \vertLineCount[8]~27\ : std_logic;
SIGNAL \vertLineCount[9]~28_combout\ : std_logic;
SIGNAL \process_0~0_combout\ : std_logic;
SIGNAL \charData[0]~input_o\ : std_logic;
SIGNAL \charData[2]~input_o\ : std_logic;
SIGNAL \charData[1]~input_o\ : std_logic;
SIGNAL \charData[3]~input_o\ : std_logic;
SIGNAL \Mux0~0_combout\ : std_logic;
SIGNAL \Mux0~1_combout\ : std_logic;
SIGNAL \charData[6]~input_o\ : std_logic;
SIGNAL \charData[4]~input_o\ : std_logic;
SIGNAL \charData[7]~input_o\ : std_logic;
SIGNAL \charData[5]~input_o\ : std_logic;
SIGNAL \Mux0~2_combout\ : std_logic;
SIGNAL \Mux0~3_combout\ : std_logic;
SIGNAL \video~0_combout\ : std_logic;
SIGNAL \video~reg0_q\ : std_logic;
SIGNAL \process_0~2_combout\ : std_logic;
SIGNAL \process_0~1_combout\ : std_logic;
SIGNAL \process_0~3_combout\ : std_logic;
SIGNAL \n_vSync~q\ : std_logic;
SIGNAL \process_0~4_combout\ : std_logic;
SIGNAL \process_0~5_combout\ : std_logic;
SIGNAL \n_hSync~q\ : std_logic;
SIGNAL \hAct~reg0_q\ : std_logic;
SIGNAL theCharRow : std_logic_vector(7 DOWNTO 0);
SIGNAL horizCount : std_logic_vector(10 DOWNTO 0);
SIGNAL vertLineCount : std_logic_vector(9 DOWNTO 0);
SIGNAL prescaleRow : std_logic_vector(1 DOWNTO 0);
SIGNAL \ALT_INV_n_hSync~q\ : std_logic;
SIGNAL \ALT_INV_n_vSync~q\ : std_logic;

COMPONENT hard_block
    PORT (
	devoe : IN std_logic;
	devclrn : IN std_logic;
	devpor : IN std_logic);
END COMPONENT;

BEGIN

charAddr <= ww_charAddr;
ww_charData <= charData;
dispAddr <= ww_dispAddr;
ww_dispData <= dispData;
ww_clk <= clk;
video <= ww_video;
vSync <= ww_vSync;
hSync <= ww_hSync;
hAct <= ww_hAct;
ww_devoe <= devoe;
ww_devclrn <= devclrn;
ww_devpor <= devpor;

\clk~inputclkctrl_INCLK_bus\ <= (vcc & vcc & vcc & \clk~input_o\);
\ALT_INV_n_hSync~q\ <= NOT \n_hSync~q\;
\ALT_INV_n_vSync~q\ <= NOT \n_vSync~q\;
auto_generated_inst : hard_block
PORT MAP (
	devoe => ww_devoe,
	devclrn => ww_devclrn,
	devpor => ww_devpor);

-- Location: IOOBUF_X34_Y2_N23
\charAddr[0]~output\ : cycloneive_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => theCharRow(0),
	devoe => ww_devoe,
	o => \charAddr[0]~output_o\);

-- Location: IOOBUF_X32_Y0_N9
\charAddr[1]~output\ : cycloneive_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => theCharRow(1),
	devoe => ww_devoe,
	o => \charAddr[1]~output_o\);

-- Location: IOOBUF_X34_Y9_N16
\charAddr[2]~output\ : cycloneive_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => theCharRow(2),
	devoe => ww_devoe,
	o => \charAddr[2]~output_o\);

-- Location: IOOBUF_X0_Y9_N9
\charAddr[3]~output\ : cycloneive_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => \dispData[0]~input_o\,
	devoe => ww_devoe,
	o => \charAddr[3]~output_o\);

-- Location: IOOBUF_X0_Y8_N16
\charAddr[4]~output\ : cycloneive_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => \dispData[1]~input_o\,
	devoe => ww_devoe,
	o => \charAddr[4]~output_o\);

-- Location: IOOBUF_X13_Y0_N16
\charAddr[5]~output\ : cycloneive_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => \dispData[2]~input_o\,
	devoe => ww_devoe,
	o => \charAddr[5]~output_o\);

-- Location: IOOBUF_X23_Y24_N9
\charAddr[6]~output\ : cycloneive_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => \dispData[3]~input_o\,
	devoe => ww_devoe,
	o => \charAddr[6]~output_o\);

-- Location: IOOBUF_X5_Y24_N9
\charAddr[7]~output\ : cycloneive_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => \dispData[4]~input_o\,
	devoe => ww_devoe,
	o => \charAddr[7]~output_o\);

-- Location: IOOBUF_X18_Y24_N16
\charAddr[8]~output\ : cycloneive_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => \dispData[5]~input_o\,
	devoe => ww_devoe,
	o => \charAddr[8]~output_o\);

-- Location: IOOBUF_X5_Y0_N16
\charAddr[9]~output\ : cycloneive_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => \dispData[6]~input_o\,
	devoe => ww_devoe,
	o => \charAddr[9]~output_o\);

-- Location: IOOBUF_X9_Y24_N9
\charAddr[10]~output\ : cycloneive_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => \dispData[7]~input_o\,
	devoe => ww_devoe,
	o => \charAddr[10]~output_o\);

-- Location: IOOBUF_X34_Y9_N2
\dispAddr[0]~output\ : cycloneive_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => horizCount(4),
	devoe => ww_devoe,
	o => \dispAddr[0]~output_o\);

-- Location: IOOBUF_X34_Y9_N9
\dispAddr[1]~output\ : cycloneive_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => horizCount(5),
	devoe => ww_devoe,
	o => \dispAddr[1]~output_o\);

-- Location: IOOBUF_X34_Y4_N23
\dispAddr[2]~output\ : cycloneive_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => horizCount(6),
	devoe => ww_devoe,
	o => \dispAddr[2]~output_o\);

-- Location: IOOBUF_X30_Y0_N23
\dispAddr[3]~output\ : cycloneive_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => horizCount(7),
	devoe => ww_devoe,
	o => \dispAddr[3]~output_o\);

-- Location: IOOBUF_X34_Y10_N9
\dispAddr[4]~output\ : cycloneive_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => horizCount(8),
	devoe => ww_devoe,
	o => \dispAddr[4]~output_o\);

-- Location: IOOBUF_X34_Y7_N9
\dispAddr[5]~output\ : cycloneive_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => horizCount(9),
	devoe => ww_devoe,
	o => \dispAddr[5]~output_o\);

-- Location: IOOBUF_X34_Y2_N16
\dispAddr[6]~output\ : cycloneive_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => theCharRow(3),
	devoe => ww_devoe,
	o => \dispAddr[6]~output_o\);

-- Location: IOOBUF_X32_Y0_N23
\dispAddr[7]~output\ : cycloneive_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => theCharRow(4),
	devoe => ww_devoe,
	o => \dispAddr[7]~output_o\);

-- Location: IOOBUF_X32_Y0_N16
\dispAddr[8]~output\ : cycloneive_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => theCharRow(5),
	devoe => ww_devoe,
	o => \dispAddr[8]~output_o\);

-- Location: IOOBUF_X34_Y9_N23
\dispAddr[9]~output\ : cycloneive_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => theCharRow(6),
	devoe => ww_devoe,
	o => \dispAddr[9]~output_o\);

-- Location: IOOBUF_X34_Y3_N23
\dispAddr[10]~output\ : cycloneive_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => theCharRow(7),
	devoe => ww_devoe,
	o => \dispAddr[10]~output_o\);

-- Location: IOOBUF_X21_Y0_N9
\video~output\ : cycloneive_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => \video~reg0_q\,
	devoe => ww_devoe,
	o => \video~output_o\);

-- Location: IOOBUF_X23_Y0_N9
\vSync~output\ : cycloneive_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => \ALT_INV_n_vSync~q\,
	devoe => ww_devoe,
	o => \vSync~output_o\);

-- Location: IOOBUF_X34_Y4_N16
\hSync~output\ : cycloneive_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => \ALT_INV_n_hSync~q\,
	devoe => ww_devoe,
	o => \hSync~output_o\);

-- Location: IOOBUF_X28_Y0_N2
\hAct~output\ : cycloneive_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => \hAct~reg0_q\,
	devoe => ww_devoe,
	o => \hAct~output_o\);

-- Location: IOIBUF_X0_Y11_N8
\clk~input\ : cycloneive_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_clk,
	o => \clk~input_o\);

-- Location: CLKCTRL_G2
\clk~inputclkctrl\ : cycloneive_clkctrl
-- pragma translate_off
GENERIC MAP (
	clock_type => "global clock",
	ena_register_mode => "none")
-- pragma translate_on
PORT MAP (
	inclk => \clk~inputclkctrl_INCLK_bus\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	outclk => \clk~inputclkctrl_outclk\);

-- Location: LCCOMB_X32_Y4_N10
\theCharRow[0]~8\ : cycloneive_lcell_comb
-- Equation(s):
-- \theCharRow[0]~8_combout\ = theCharRow(0) $ (VCC)
-- \theCharRow[0]~9\ = CARRY(theCharRow(0))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0101010110101010",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => theCharRow(0),
	datad => VCC,
	combout => \theCharRow[0]~8_combout\,
	cout => \theCharRow[0]~9\);

-- Location: LCCOMB_X31_Y4_N2
\horizCount[0]~11\ : cycloneive_lcell_comb
-- Equation(s):
-- \horizCount[0]~11_combout\ = horizCount(0) $ (VCC)
-- \horizCount[0]~12\ = CARRY(horizCount(0))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0011001111001100",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	datab => horizCount(0),
	datad => VCC,
	combout => \horizCount[0]~11_combout\,
	cout => \horizCount[0]~12\);

-- Location: FF_X31_Y4_N3
\horizCount[0]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \horizCount[0]~11_combout\,
	sclr => \LessThan0~1_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => horizCount(0));

-- Location: LCCOMB_X31_Y4_N4
\horizCount[1]~13\ : cycloneive_lcell_comb
-- Equation(s):
-- \horizCount[1]~13_combout\ = (horizCount(1) & (!\horizCount[0]~12\)) # (!horizCount(1) & ((\horizCount[0]~12\) # (GND)))
-- \horizCount[1]~14\ = CARRY((!\horizCount[0]~12\) # (!horizCount(1)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0011110000111111",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	datab => horizCount(1),
	datad => VCC,
	cin => \horizCount[0]~12\,
	combout => \horizCount[1]~13_combout\,
	cout => \horizCount[1]~14\);

-- Location: FF_X31_Y4_N5
\horizCount[1]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \horizCount[1]~13_combout\,
	sclr => \LessThan0~1_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => horizCount(1));

-- Location: LCCOMB_X31_Y4_N6
\horizCount[2]~15\ : cycloneive_lcell_comb
-- Equation(s):
-- \horizCount[2]~15_combout\ = (horizCount(2) & (\horizCount[1]~14\ $ (GND))) # (!horizCount(2) & (!\horizCount[1]~14\ & VCC))
-- \horizCount[2]~16\ = CARRY((horizCount(2) & !\horizCount[1]~14\))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1010010100001010",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	dataa => horizCount(2),
	datad => VCC,
	cin => \horizCount[1]~14\,
	combout => \horizCount[2]~15_combout\,
	cout => \horizCount[2]~16\);

-- Location: FF_X31_Y4_N7
\horizCount[2]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \horizCount[2]~15_combout\,
	sclr => \LessThan0~1_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => horizCount(2));

-- Location: LCCOMB_X31_Y4_N8
\horizCount[3]~17\ : cycloneive_lcell_comb
-- Equation(s):
-- \horizCount[3]~17_combout\ = (horizCount(3) & (!\horizCount[2]~16\)) # (!horizCount(3) & ((\horizCount[2]~16\) # (GND)))
-- \horizCount[3]~18\ = CARRY((!\horizCount[2]~16\) # (!horizCount(3)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0011110000111111",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	datab => horizCount(3),
	datad => VCC,
	cin => \horizCount[2]~16\,
	combout => \horizCount[3]~17_combout\,
	cout => \horizCount[3]~18\);

-- Location: FF_X31_Y4_N9
\horizCount[3]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \horizCount[3]~17_combout\,
	sclr => \LessThan0~1_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => horizCount(3));

-- Location: LCCOMB_X31_Y4_N10
\horizCount[4]~19\ : cycloneive_lcell_comb
-- Equation(s):
-- \horizCount[4]~19_combout\ = (horizCount(4) & (\horizCount[3]~18\ $ (GND))) # (!horizCount(4) & (!\horizCount[3]~18\ & VCC))
-- \horizCount[4]~20\ = CARRY((horizCount(4) & !\horizCount[3]~18\))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1010010100001010",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	dataa => horizCount(4),
	datad => VCC,
	cin => \horizCount[3]~18\,
	combout => \horizCount[4]~19_combout\,
	cout => \horizCount[4]~20\);

-- Location: FF_X31_Y4_N11
\horizCount[4]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \horizCount[4]~19_combout\,
	sclr => \LessThan0~1_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => horizCount(4));

-- Location: LCCOMB_X31_Y4_N12
\horizCount[5]~21\ : cycloneive_lcell_comb
-- Equation(s):
-- \horizCount[5]~21_combout\ = (horizCount(5) & (!\horizCount[4]~20\)) # (!horizCount(5) & ((\horizCount[4]~20\) # (GND)))
-- \horizCount[5]~22\ = CARRY((!\horizCount[4]~20\) # (!horizCount(5)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0101101001011111",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	dataa => horizCount(5),
	datad => VCC,
	cin => \horizCount[4]~20\,
	combout => \horizCount[5]~21_combout\,
	cout => \horizCount[5]~22\);

-- Location: FF_X31_Y4_N13
\horizCount[5]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \horizCount[5]~21_combout\,
	sclr => \LessThan0~1_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => horizCount(5));

-- Location: LCCOMB_X31_Y4_N14
\horizCount[6]~23\ : cycloneive_lcell_comb
-- Equation(s):
-- \horizCount[6]~23_combout\ = (horizCount(6) & (\horizCount[5]~22\ $ (GND))) # (!horizCount(6) & (!\horizCount[5]~22\ & VCC))
-- \horizCount[6]~24\ = CARRY((horizCount(6) & !\horizCount[5]~22\))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1010010100001010",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	dataa => horizCount(6),
	datad => VCC,
	cin => \horizCount[5]~22\,
	combout => \horizCount[6]~23_combout\,
	cout => \horizCount[6]~24\);

-- Location: FF_X31_Y4_N15
\horizCount[6]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \horizCount[6]~23_combout\,
	sclr => \LessThan0~1_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => horizCount(6));

-- Location: LCCOMB_X31_Y4_N16
\horizCount[7]~25\ : cycloneive_lcell_comb
-- Equation(s):
-- \horizCount[7]~25_combout\ = (horizCount(7) & (!\horizCount[6]~24\)) # (!horizCount(7) & ((\horizCount[6]~24\) # (GND)))
-- \horizCount[7]~26\ = CARRY((!\horizCount[6]~24\) # (!horizCount(7)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0101101001011111",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	dataa => horizCount(7),
	datad => VCC,
	cin => \horizCount[6]~24\,
	combout => \horizCount[7]~25_combout\,
	cout => \horizCount[7]~26\);

-- Location: FF_X31_Y4_N17
\horizCount[7]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \horizCount[7]~25_combout\,
	sclr => \LessThan0~1_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => horizCount(7));

-- Location: LCCOMB_X31_Y4_N18
\horizCount[8]~27\ : cycloneive_lcell_comb
-- Equation(s):
-- \horizCount[8]~27_combout\ = (horizCount(8) & (\horizCount[7]~26\ $ (GND))) # (!horizCount(8) & (!\horizCount[7]~26\ & VCC))
-- \horizCount[8]~28\ = CARRY((horizCount(8) & !\horizCount[7]~26\))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1100001100001100",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	datab => horizCount(8),
	datad => VCC,
	cin => \horizCount[7]~26\,
	combout => \horizCount[8]~27_combout\,
	cout => \horizCount[8]~28\);

-- Location: FF_X31_Y4_N19
\horizCount[8]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \horizCount[8]~27_combout\,
	sclr => \LessThan0~1_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => horizCount(8));

-- Location: LCCOMB_X31_Y4_N20
\horizCount[9]~29\ : cycloneive_lcell_comb
-- Equation(s):
-- \horizCount[9]~29_combout\ = (horizCount(9) & (!\horizCount[8]~28\)) # (!horizCount(9) & ((\horizCount[8]~28\) # (GND)))
-- \horizCount[9]~30\ = CARRY((!\horizCount[8]~28\) # (!horizCount(9)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0101101001011111",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	dataa => horizCount(9),
	datad => VCC,
	cin => \horizCount[8]~28\,
	combout => \horizCount[9]~29_combout\,
	cout => \horizCount[9]~30\);

-- Location: FF_X31_Y4_N21
\horizCount[9]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \horizCount[9]~29_combout\,
	sclr => \LessThan0~1_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => horizCount(9));

-- Location: LCCOMB_X31_Y4_N22
\horizCount[10]~31\ : cycloneive_lcell_comb
-- Equation(s):
-- \horizCount[10]~31_combout\ = horizCount(10) $ (!\horizCount[9]~30\)

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1010010110100101",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	dataa => horizCount(10),
	cin => \horizCount[9]~30\,
	combout => \horizCount[10]~31_combout\);

-- Location: FF_X31_Y4_N23
\horizCount[10]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \horizCount[10]~31_combout\,
	sclr => \LessThan0~1_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => horizCount(10));

-- Location: LCCOMB_X31_Y4_N0
\LessThan0~0\ : cycloneive_lcell_comb
-- Equation(s):
-- \LessThan0~0_combout\ = (!horizCount(7) & (!horizCount(6) & !horizCount(9)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0000000000000011",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	datab => horizCount(7),
	datac => horizCount(6),
	datad => horizCount(9),
	combout => \LessThan0~0_combout\);

-- Location: LCCOMB_X31_Y4_N30
\LessThan0~1\ : cycloneive_lcell_comb
-- Equation(s):
-- \LessThan0~1_combout\ = (horizCount(10) & (!\LessThan0~0_combout\ & ((horizCount(8)) # (horizCount(9)))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0000000010101000",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => horizCount(10),
	datab => horizCount(8),
	datac => horizCount(9),
	datad => \LessThan0~0_combout\,
	combout => \LessThan0~1_combout\);

-- Location: LCCOMB_X32_Y4_N26
\prescaleRow~1\ : cycloneive_lcell_comb
-- Equation(s):
-- \prescaleRow~1_combout\ = (prescaleRow(0) & (!prescaleRow(1) & !\LessThan0~1_combout\))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0000000000001100",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	datab => prescaleRow(0),
	datac => prescaleRow(1),
	datad => \LessThan0~1_combout\,
	combout => \prescaleRow~1_combout\);

-- Location: FF_X32_Y4_N27
\prescaleRow[1]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \prescaleRow~1_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => prescaleRow(1));

-- Location: LCCOMB_X32_Y4_N28
\prescaleRow~0\ : cycloneive_lcell_comb
-- Equation(s):
-- \prescaleRow~0_combout\ = (!prescaleRow(1) & (!prescaleRow(0) & !\LessThan0~1_combout\))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0000000000000101",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => prescaleRow(1),
	datac => prescaleRow(0),
	datad => \LessThan0~1_combout\,
	combout => \prescaleRow~0_combout\);

-- Location: FF_X32_Y4_N29
\prescaleRow[0]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \prescaleRow~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => prescaleRow(0));

-- Location: LCCOMB_X32_Y4_N4
\theCharRow[0]~10\ : cycloneive_lcell_comb
-- Equation(s):
-- \theCharRow[0]~10_combout\ = (\LessThan0~1_combout\) # ((!prescaleRow(0) & prescaleRow(1)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1111111100110000",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	datab => prescaleRow(0),
	datac => prescaleRow(1),
	datad => \LessThan0~1_combout\,
	combout => \theCharRow[0]~10_combout\);

-- Location: FF_X32_Y4_N11
\theCharRow[0]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \theCharRow[0]~8_combout\,
	sclr => \LessThan0~1_combout\,
	ena => \theCharRow[0]~10_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => theCharRow(0));

-- Location: LCCOMB_X32_Y4_N12
\theCharRow[1]~11\ : cycloneive_lcell_comb
-- Equation(s):
-- \theCharRow[1]~11_combout\ = (theCharRow(1) & (!\theCharRow[0]~9\)) # (!theCharRow(1) & ((\theCharRow[0]~9\) # (GND)))
-- \theCharRow[1]~12\ = CARRY((!\theCharRow[0]~9\) # (!theCharRow(1)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0101101001011111",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	dataa => theCharRow(1),
	datad => VCC,
	cin => \theCharRow[0]~9\,
	combout => \theCharRow[1]~11_combout\,
	cout => \theCharRow[1]~12\);

-- Location: FF_X32_Y4_N13
\theCharRow[1]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \theCharRow[1]~11_combout\,
	sclr => \LessThan0~1_combout\,
	ena => \theCharRow[0]~10_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => theCharRow(1));

-- Location: LCCOMB_X32_Y4_N14
\theCharRow[2]~13\ : cycloneive_lcell_comb
-- Equation(s):
-- \theCharRow[2]~13_combout\ = (theCharRow(2) & (\theCharRow[1]~12\ $ (GND))) # (!theCharRow(2) & (!\theCharRow[1]~12\ & VCC))
-- \theCharRow[2]~14\ = CARRY((theCharRow(2) & !\theCharRow[1]~12\))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1100001100001100",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	datab => theCharRow(2),
	datad => VCC,
	cin => \theCharRow[1]~12\,
	combout => \theCharRow[2]~13_combout\,
	cout => \theCharRow[2]~14\);

-- Location: FF_X32_Y4_N15
\theCharRow[2]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \theCharRow[2]~13_combout\,
	sclr => \LessThan0~1_combout\,
	ena => \theCharRow[0]~10_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => theCharRow(2));

-- Location: IOIBUF_X0_Y11_N15
\dispData[0]~input\ : cycloneive_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_dispData(0),
	o => \dispData[0]~input_o\);

-- Location: IOIBUF_X0_Y11_N22
\dispData[1]~input\ : cycloneive_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_dispData(1),
	o => \dispData[1]~input_o\);

-- Location: IOIBUF_X13_Y0_N1
\dispData[2]~input\ : cycloneive_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_dispData(2),
	o => \dispData[2]~input_o\);

-- Location: IOIBUF_X23_Y24_N1
\dispData[3]~input\ : cycloneive_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_dispData(3),
	o => \dispData[3]~input_o\);

-- Location: IOIBUF_X7_Y24_N8
\dispData[4]~input\ : cycloneive_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_dispData(4),
	o => \dispData[4]~input_o\);

-- Location: IOIBUF_X18_Y24_N22
\dispData[5]~input\ : cycloneive_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_dispData(5),
	o => \dispData[5]~input_o\);

-- Location: IOIBUF_X5_Y0_N22
\dispData[6]~input\ : cycloneive_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_dispData(6),
	o => \dispData[6]~input_o\);

-- Location: IOIBUF_X11_Y24_N15
\dispData[7]~input\ : cycloneive_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_dispData(7),
	o => \dispData[7]~input_o\);

-- Location: LCCOMB_X32_Y4_N16
\theCharRow[3]~15\ : cycloneive_lcell_comb
-- Equation(s):
-- \theCharRow[3]~15_combout\ = (theCharRow(3) & (!\theCharRow[2]~14\)) # (!theCharRow(3) & ((\theCharRow[2]~14\) # (GND)))
-- \theCharRow[3]~16\ = CARRY((!\theCharRow[2]~14\) # (!theCharRow(3)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0011110000111111",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	datab => theCharRow(3),
	datad => VCC,
	cin => \theCharRow[2]~14\,
	combout => \theCharRow[3]~15_combout\,
	cout => \theCharRow[3]~16\);

-- Location: FF_X32_Y4_N17
\theCharRow[3]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \theCharRow[3]~15_combout\,
	sclr => \LessThan0~1_combout\,
	ena => \theCharRow[0]~10_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => theCharRow(3));

-- Location: LCCOMB_X32_Y4_N18
\theCharRow[4]~17\ : cycloneive_lcell_comb
-- Equation(s):
-- \theCharRow[4]~17_combout\ = (theCharRow(4) & (\theCharRow[3]~16\ $ (GND))) # (!theCharRow(4) & (!\theCharRow[3]~16\ & VCC))
-- \theCharRow[4]~18\ = CARRY((theCharRow(4) & !\theCharRow[3]~16\))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1100001100001100",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	datab => theCharRow(4),
	datad => VCC,
	cin => \theCharRow[3]~16\,
	combout => \theCharRow[4]~17_combout\,
	cout => \theCharRow[4]~18\);

-- Location: FF_X32_Y4_N19
\theCharRow[4]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \theCharRow[4]~17_combout\,
	sclr => \LessThan0~1_combout\,
	ena => \theCharRow[0]~10_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => theCharRow(4));

-- Location: LCCOMB_X32_Y4_N20
\theCharRow[5]~19\ : cycloneive_lcell_comb
-- Equation(s):
-- \theCharRow[5]~19_combout\ = (theCharRow(5) & (!\theCharRow[4]~18\)) # (!theCharRow(5) & ((\theCharRow[4]~18\) # (GND)))
-- \theCharRow[5]~20\ = CARRY((!\theCharRow[4]~18\) # (!theCharRow(5)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0011110000111111",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	datab => theCharRow(5),
	datad => VCC,
	cin => \theCharRow[4]~18\,
	combout => \theCharRow[5]~19_combout\,
	cout => \theCharRow[5]~20\);

-- Location: FF_X32_Y4_N21
\theCharRow[5]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \theCharRow[5]~19_combout\,
	sclr => \LessThan0~1_combout\,
	ena => \theCharRow[0]~10_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => theCharRow(5));

-- Location: LCCOMB_X32_Y4_N22
\theCharRow[6]~21\ : cycloneive_lcell_comb
-- Equation(s):
-- \theCharRow[6]~21_combout\ = (theCharRow(6) & (\theCharRow[5]~20\ $ (GND))) # (!theCharRow(6) & (!\theCharRow[5]~20\ & VCC))
-- \theCharRow[6]~22\ = CARRY((theCharRow(6) & !\theCharRow[5]~20\))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1010010100001010",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	dataa => theCharRow(6),
	datad => VCC,
	cin => \theCharRow[5]~20\,
	combout => \theCharRow[6]~21_combout\,
	cout => \theCharRow[6]~22\);

-- Location: FF_X32_Y4_N23
\theCharRow[6]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \theCharRow[6]~21_combout\,
	sclr => \LessThan0~1_combout\,
	ena => \theCharRow[0]~10_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => theCharRow(6));

-- Location: LCCOMB_X32_Y4_N24
\theCharRow[7]~23\ : cycloneive_lcell_comb
-- Equation(s):
-- \theCharRow[7]~23_combout\ = \theCharRow[6]~22\ $ (theCharRow(7))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0000111111110000",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	datad => theCharRow(7),
	cin => \theCharRow[6]~22\,
	combout => \theCharRow[7]~23_combout\);

-- Location: FF_X32_Y4_N25
\theCharRow[7]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \theCharRow[7]~23_combout\,
	sclr => \LessThan0~1_combout\,
	ena => \theCharRow[0]~10_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => theCharRow(7));

-- Location: LCCOMB_X30_Y4_N8
\vertLineCount[0]~10\ : cycloneive_lcell_comb
-- Equation(s):
-- \vertLineCount[0]~10_combout\ = vertLineCount(0) $ (VCC)
-- \vertLineCount[0]~11\ = CARRY(vertLineCount(0))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0011001111001100",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	datab => vertLineCount(0),
	datad => VCC,
	combout => \vertLineCount[0]~10_combout\,
	cout => \vertLineCount[0]~11\);

-- Location: LCCOMB_X30_Y4_N2
\LessThan1~0\ : cycloneive_lcell_comb
-- Equation(s):
-- \LessThan1~0_combout\ = (vertLineCount(4)) # ((vertLineCount(3)) # ((vertLineCount(2) & vertLineCount(1))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1111111011111100",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => vertLineCount(2),
	datab => vertLineCount(4),
	datac => vertLineCount(3),
	datad => vertLineCount(1),
	combout => \LessThan1~0_combout\);

-- Location: LCCOMB_X30_Y4_N0
\LessThan1~1\ : cycloneive_lcell_comb
-- Equation(s):
-- \LessThan1~1_combout\ = (vertLineCount(7)) # ((vertLineCount(6)) # ((vertLineCount(5) & \LessThan1~0_combout\)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1111111011111010",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => vertLineCount(7),
	datab => vertLineCount(5),
	datac => vertLineCount(6),
	datad => \LessThan1~0_combout\,
	combout => \LessThan1~1_combout\);

-- Location: LCCOMB_X30_Y4_N6
\LessThan1~2\ : cycloneive_lcell_comb
-- Equation(s):
-- \LessThan1~2_combout\ = (vertLineCount(8) & (vertLineCount(9) & \LessThan1~1_combout\))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1100000000000000",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	datab => vertLineCount(8),
	datac => vertLineCount(9),
	datad => \LessThan1~1_combout\,
	combout => \LessThan1~2_combout\);

-- Location: FF_X30_Y4_N9
\vertLineCount[0]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \vertLineCount[0]~10_combout\,
	sclr => \LessThan1~2_combout\,
	ena => \LessThan0~1_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => vertLineCount(0));

-- Location: LCCOMB_X30_Y4_N10
\vertLineCount[1]~12\ : cycloneive_lcell_comb
-- Equation(s):
-- \vertLineCount[1]~12_combout\ = (vertLineCount(1) & (!\vertLineCount[0]~11\)) # (!vertLineCount(1) & ((\vertLineCount[0]~11\) # (GND)))
-- \vertLineCount[1]~13\ = CARRY((!\vertLineCount[0]~11\) # (!vertLineCount(1)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0101101001011111",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	dataa => vertLineCount(1),
	datad => VCC,
	cin => \vertLineCount[0]~11\,
	combout => \vertLineCount[1]~12_combout\,
	cout => \vertLineCount[1]~13\);

-- Location: FF_X30_Y4_N11
\vertLineCount[1]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \vertLineCount[1]~12_combout\,
	sclr => \LessThan1~2_combout\,
	ena => \LessThan0~1_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => vertLineCount(1));

-- Location: LCCOMB_X30_Y4_N12
\vertLineCount[2]~14\ : cycloneive_lcell_comb
-- Equation(s):
-- \vertLineCount[2]~14_combout\ = (vertLineCount(2) & (\vertLineCount[1]~13\ $ (GND))) # (!vertLineCount(2) & (!\vertLineCount[1]~13\ & VCC))
-- \vertLineCount[2]~15\ = CARRY((vertLineCount(2) & !\vertLineCount[1]~13\))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1010010100001010",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	dataa => vertLineCount(2),
	datad => VCC,
	cin => \vertLineCount[1]~13\,
	combout => \vertLineCount[2]~14_combout\,
	cout => \vertLineCount[2]~15\);

-- Location: FF_X30_Y4_N13
\vertLineCount[2]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \vertLineCount[2]~14_combout\,
	sclr => \LessThan1~2_combout\,
	ena => \LessThan0~1_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => vertLineCount(2));

-- Location: LCCOMB_X30_Y4_N14
\vertLineCount[3]~16\ : cycloneive_lcell_comb
-- Equation(s):
-- \vertLineCount[3]~16_combout\ = (vertLineCount(3) & (!\vertLineCount[2]~15\)) # (!vertLineCount(3) & ((\vertLineCount[2]~15\) # (GND)))
-- \vertLineCount[3]~17\ = CARRY((!\vertLineCount[2]~15\) # (!vertLineCount(3)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0011110000111111",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	datab => vertLineCount(3),
	datad => VCC,
	cin => \vertLineCount[2]~15\,
	combout => \vertLineCount[3]~16_combout\,
	cout => \vertLineCount[3]~17\);

-- Location: FF_X30_Y4_N15
\vertLineCount[3]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \vertLineCount[3]~16_combout\,
	sclr => \LessThan1~2_combout\,
	ena => \LessThan0~1_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => vertLineCount(3));

-- Location: LCCOMB_X30_Y4_N16
\vertLineCount[4]~18\ : cycloneive_lcell_comb
-- Equation(s):
-- \vertLineCount[4]~18_combout\ = (vertLineCount(4) & (\vertLineCount[3]~17\ $ (GND))) # (!vertLineCount(4) & (!\vertLineCount[3]~17\ & VCC))
-- \vertLineCount[4]~19\ = CARRY((vertLineCount(4) & !\vertLineCount[3]~17\))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1100001100001100",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	datab => vertLineCount(4),
	datad => VCC,
	cin => \vertLineCount[3]~17\,
	combout => \vertLineCount[4]~18_combout\,
	cout => \vertLineCount[4]~19\);

-- Location: FF_X30_Y4_N17
\vertLineCount[4]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \vertLineCount[4]~18_combout\,
	sclr => \LessThan1~2_combout\,
	ena => \LessThan0~1_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => vertLineCount(4));

-- Location: LCCOMB_X30_Y4_N18
\vertLineCount[5]~20\ : cycloneive_lcell_comb
-- Equation(s):
-- \vertLineCount[5]~20_combout\ = (vertLineCount(5) & (!\vertLineCount[4]~19\)) # (!vertLineCount(5) & ((\vertLineCount[4]~19\) # (GND)))
-- \vertLineCount[5]~21\ = CARRY((!\vertLineCount[4]~19\) # (!vertLineCount(5)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0011110000111111",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	datab => vertLineCount(5),
	datad => VCC,
	cin => \vertLineCount[4]~19\,
	combout => \vertLineCount[5]~20_combout\,
	cout => \vertLineCount[5]~21\);

-- Location: FF_X30_Y4_N19
\vertLineCount[5]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \vertLineCount[5]~20_combout\,
	sclr => \LessThan1~2_combout\,
	ena => \LessThan0~1_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => vertLineCount(5));

-- Location: LCCOMB_X30_Y4_N20
\vertLineCount[6]~22\ : cycloneive_lcell_comb
-- Equation(s):
-- \vertLineCount[6]~22_combout\ = (vertLineCount(6) & (\vertLineCount[5]~21\ $ (GND))) # (!vertLineCount(6) & (!\vertLineCount[5]~21\ & VCC))
-- \vertLineCount[6]~23\ = CARRY((vertLineCount(6) & !\vertLineCount[5]~21\))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1100001100001100",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	datab => vertLineCount(6),
	datad => VCC,
	cin => \vertLineCount[5]~21\,
	combout => \vertLineCount[6]~22_combout\,
	cout => \vertLineCount[6]~23\);

-- Location: FF_X30_Y4_N21
\vertLineCount[6]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \vertLineCount[6]~22_combout\,
	sclr => \LessThan1~2_combout\,
	ena => \LessThan0~1_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => vertLineCount(6));

-- Location: LCCOMB_X30_Y4_N22
\vertLineCount[7]~24\ : cycloneive_lcell_comb
-- Equation(s):
-- \vertLineCount[7]~24_combout\ = (vertLineCount(7) & (!\vertLineCount[6]~23\)) # (!vertLineCount(7) & ((\vertLineCount[6]~23\) # (GND)))
-- \vertLineCount[7]~25\ = CARRY((!\vertLineCount[6]~23\) # (!vertLineCount(7)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0101101001011111",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	dataa => vertLineCount(7),
	datad => VCC,
	cin => \vertLineCount[6]~23\,
	combout => \vertLineCount[7]~24_combout\,
	cout => \vertLineCount[7]~25\);

-- Location: FF_X30_Y4_N23
\vertLineCount[7]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \vertLineCount[7]~24_combout\,
	sclr => \LessThan1~2_combout\,
	ena => \LessThan0~1_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => vertLineCount(7));

-- Location: LCCOMB_X30_Y4_N24
\vertLineCount[8]~26\ : cycloneive_lcell_comb
-- Equation(s):
-- \vertLineCount[8]~26_combout\ = (vertLineCount(8) & (\vertLineCount[7]~25\ $ (GND))) # (!vertLineCount(8) & (!\vertLineCount[7]~25\ & VCC))
-- \vertLineCount[8]~27\ = CARRY((vertLineCount(8) & !\vertLineCount[7]~25\))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1100001100001100",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	datab => vertLineCount(8),
	datad => VCC,
	cin => \vertLineCount[7]~25\,
	combout => \vertLineCount[8]~26_combout\,
	cout => \vertLineCount[8]~27\);

-- Location: FF_X30_Y4_N25
\vertLineCount[8]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \vertLineCount[8]~26_combout\,
	sclr => \LessThan1~2_combout\,
	ena => \LessThan0~1_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => vertLineCount(8));

-- Location: LCCOMB_X30_Y4_N26
\vertLineCount[9]~28\ : cycloneive_lcell_comb
-- Equation(s):
-- \vertLineCount[9]~28_combout\ = vertLineCount(9) $ (\vertLineCount[8]~27\)

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0101101001011010",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	dataa => vertLineCount(9),
	cin => \vertLineCount[8]~27\,
	combout => \vertLineCount[9]~28_combout\);

-- Location: FF_X30_Y4_N27
\vertLineCount[9]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \vertLineCount[9]~28_combout\,
	sclr => \LessThan1~2_combout\,
	ena => \LessThan0~1_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => vertLineCount(9));

-- Location: LCCOMB_X29_Y4_N20
\process_0~0\ : cycloneive_lcell_comb
-- Equation(s):
-- \process_0~0_combout\ = (!horizCount(10) & !vertLineCount(9))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0000000000001111",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	datac => horizCount(10),
	datad => vertLineCount(9),
	combout => \process_0~0_combout\);

-- Location: IOIBUF_X25_Y0_N1
\charData[0]~input\ : cycloneive_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_charData(0),
	o => \charData[0]~input_o\);

-- Location: IOIBUF_X18_Y0_N22
\charData[2]~input\ : cycloneive_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_charData(2),
	o => \charData[2]~input_o\);

-- Location: IOIBUF_X30_Y0_N1
\charData[1]~input\ : cycloneive_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_charData(1),
	o => \charData[1]~input_o\);

-- Location: IOIBUF_X34_Y17_N22
\charData[3]~input\ : cycloneive_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_charData(3),
	o => \charData[3]~input_o\);

-- Location: LCCOMB_X31_Y4_N28
\Mux0~0\ : cycloneive_lcell_comb
-- Equation(s):
-- \Mux0~0_combout\ = (horizCount(1) & (((horizCount(2))))) # (!horizCount(1) & ((horizCount(2) & (\charData[1]~input_o\)) # (!horizCount(2) & ((\charData[3]~input_o\)))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1111101000001100",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => \charData[1]~input_o\,
	datab => \charData[3]~input_o\,
	datac => horizCount(1),
	datad => horizCount(2),
	combout => \Mux0~0_combout\);

-- Location: LCCOMB_X29_Y4_N30
\Mux0~1\ : cycloneive_lcell_comb
-- Equation(s):
-- \Mux0~1_combout\ = (horizCount(1) & ((\Mux0~0_combout\ & (\charData[0]~input_o\)) # (!\Mux0~0_combout\ & ((\charData[2]~input_o\))))) # (!horizCount(1) & (((\Mux0~0_combout\))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1010111111000000",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => \charData[0]~input_o\,
	datab => \charData[2]~input_o\,
	datac => horizCount(1),
	datad => \Mux0~0_combout\,
	combout => \Mux0~1_combout\);

-- Location: IOIBUF_X28_Y0_N22
\charData[6]~input\ : cycloneive_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_charData(6),
	o => \charData[6]~input_o\);

-- Location: IOIBUF_X23_Y0_N15
\charData[4]~input\ : cycloneive_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_charData(4),
	o => \charData[4]~input_o\);

-- Location: IOIBUF_X30_Y0_N8
\charData[7]~input\ : cycloneive_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_charData(7),
	o => \charData[7]~input_o\);

-- Location: IOIBUF_X18_Y0_N15
\charData[5]~input\ : cycloneive_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_charData(5),
	o => \charData[5]~input_o\);

-- Location: LCCOMB_X30_Y4_N28
\Mux0~2\ : cycloneive_lcell_comb
-- Equation(s):
-- \Mux0~2_combout\ = (horizCount(1) & (((horizCount(2))))) # (!horizCount(1) & ((horizCount(2) & ((\charData[5]~input_o\))) # (!horizCount(2) & (\charData[7]~input_o\))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1111101001000100",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => horizCount(1),
	datab => \charData[7]~input_o\,
	datac => \charData[5]~input_o\,
	datad => horizCount(2),
	combout => \Mux0~2_combout\);

-- Location: LCCOMB_X29_Y4_N28
\Mux0~3\ : cycloneive_lcell_comb
-- Equation(s):
-- \Mux0~3_combout\ = (horizCount(1) & ((\Mux0~2_combout\ & ((\charData[4]~input_o\))) # (!\Mux0~2_combout\ & (\charData[6]~input_o\)))) # (!horizCount(1) & (((\Mux0~2_combout\))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1100111110100000",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => \charData[6]~input_o\,
	datab => \charData[4]~input_o\,
	datac => horizCount(1),
	datad => \Mux0~2_combout\,
	combout => \Mux0~3_combout\);

-- Location: LCCOMB_X29_Y4_N24
\video~0\ : cycloneive_lcell_comb
-- Equation(s):
-- \video~0_combout\ = (\process_0~0_combout\ & ((horizCount(3) & (\Mux0~1_combout\)) # (!horizCount(3) & ((\Mux0~3_combout\)))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1100010010000000",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => horizCount(3),
	datab => \process_0~0_combout\,
	datac => \Mux0~1_combout\,
	datad => \Mux0~3_combout\,
	combout => \video~0_combout\);

-- Location: FF_X29_Y4_N25
\video~reg0\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \video~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => \video~reg0_q\);

-- Location: LCCOMB_X30_Y4_N4
\process_0~2\ : cycloneive_lcell_comb
-- Equation(s):
-- \process_0~2_combout\ = ((vertLineCount(6)) # ((vertLineCount(7)) # (vertLineCount(1)))) # (!vertLineCount(2))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1111111111111101",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => vertLineCount(2),
	datab => vertLineCount(6),
	datac => vertLineCount(7),
	datad => vertLineCount(1),
	combout => \process_0~2_combout\);

-- Location: LCCOMB_X30_Y4_N30
\process_0~1\ : cycloneive_lcell_comb
-- Equation(s):
-- \process_0~1_combout\ = (((vertLineCount(3)) # (vertLineCount(4))) # (!vertLineCount(8))) # (!vertLineCount(9))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1111111111110111",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => vertLineCount(9),
	datab => vertLineCount(8),
	datac => vertLineCount(3),
	datad => vertLineCount(4),
	combout => \process_0~1_combout\);

-- Location: LCCOMB_X29_Y4_N14
\process_0~3\ : cycloneive_lcell_comb
-- Equation(s):
-- \process_0~3_combout\ = (!\process_0~2_combout\ & (!vertLineCount(5) & !\process_0~1_combout\))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0000000100000001",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => \process_0~2_combout\,
	datab => vertLineCount(5),
	datac => \process_0~1_combout\,
	combout => \process_0~3_combout\);

-- Location: FF_X29_Y4_N15
n_vSync : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \process_0~3_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => \n_vSync~q\);

-- Location: LCCOMB_X31_Y4_N26
\process_0~4\ : cycloneive_lcell_comb
-- Equation(s):
-- \process_0~4_combout\ = (horizCount(4) & (!horizCount(5) & ((horizCount(3)) # (horizCount(2))))) # (!horizCount(4) & (horizCount(5) & ((!horizCount(2)) # (!horizCount(3)))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0010011001100100",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => horizCount(4),
	datab => horizCount(5),
	datac => horizCount(3),
	datad => horizCount(2),
	combout => \process_0~4_combout\);

-- Location: LCCOMB_X31_Y4_N24
\process_0~5\ : cycloneive_lcell_comb
-- Equation(s):
-- \process_0~5_combout\ = (\process_0~4_combout\ & (!horizCount(8) & (horizCount(10) & \LessThan0~0_combout\)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0010000000000000",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => \process_0~4_combout\,
	datab => horizCount(8),
	datac => horizCount(10),
	datad => \LessThan0~0_combout\,
	combout => \process_0~5_combout\);

-- Location: FF_X31_Y4_N25
n_hSync : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \process_0~5_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => \n_hSync~q\);

-- Location: FF_X29_Y4_N21
\hAct~reg0\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \process_0~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => \hAct~reg0_q\);

ww_charAddr(0) <= \charAddr[0]~output_o\;

ww_charAddr(1) <= \charAddr[1]~output_o\;

ww_charAddr(2) <= \charAddr[2]~output_o\;

ww_charAddr(3) <= \charAddr[3]~output_o\;

ww_charAddr(4) <= \charAddr[4]~output_o\;

ww_charAddr(5) <= \charAddr[5]~output_o\;

ww_charAddr(6) <= \charAddr[6]~output_o\;

ww_charAddr(7) <= \charAddr[7]~output_o\;

ww_charAddr(8) <= \charAddr[8]~output_o\;

ww_charAddr(9) <= \charAddr[9]~output_o\;

ww_charAddr(10) <= \charAddr[10]~output_o\;

ww_dispAddr(0) <= \dispAddr[0]~output_o\;

ww_dispAddr(1) <= \dispAddr[1]~output_o\;

ww_dispAddr(2) <= \dispAddr[2]~output_o\;

ww_dispAddr(3) <= \dispAddr[3]~output_o\;

ww_dispAddr(4) <= \dispAddr[4]~output_o\;

ww_dispAddr(5) <= \dispAddr[5]~output_o\;

ww_dispAddr(6) <= \dispAddr[6]~output_o\;

ww_dispAddr(7) <= \dispAddr[7]~output_o\;

ww_dispAddr(8) <= \dispAddr[8]~output_o\;

ww_dispAddr(9) <= \dispAddr[9]~output_o\;

ww_dispAddr(10) <= \dispAddr[10]~output_o\;

ww_video <= \video~output_o\;

ww_vSync <= \vSync~output_o\;

ww_hSync <= \hSync~output_o\;

ww_hAct <= \hAct~output_o\;
END structure;


