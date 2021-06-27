--	---------------------------------------------------------------------------------------------------------
-- Front Panel interface
-- Intercepts the CPU connections and connects to the Front Panel
-- PB31 (upper left switch/LED on the Front Panel) is the main control - Run / Halt
--	Front Panel
--		http://land-boards.com/blwiki/index.php?title=Front_Panel_For_8_Bit_Computers
--		Monitors Address/Data when in Run mode
--		PB31 - Upper left pushbutton - Run.Halt (Upper leftLED on for Run)
--		PB30 - Reset
--		PB29 - Step - Not yet implemented
--		PB27 - Clear - Clears address if in Set Address Mode control mode
--		PB26 - Increment address - Function depend on Enable Write Data and Set Address Mode controls
--			Ignored if Set Address is selected
--			If Enable Write Data is selected, Write data then Increment address
--			If Enable Write Data is not selectedrwise increment read address and read next location
--		PB25 - Enable Write Data control - Bottom row of pushbuttons controls write of data to memory
--		PB24 - Set Address Mode control - Middle two rows of pushbuttons control LEDs
--

library ieee;
use ieee.std_logic_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

entity MIKBUG_FRPNL is
	port
	(
	-- Clock and reset
	i_CLOCK_50					: in std_logic;								-- FPGA 50 MHz clock
	i_cpuClock					: in std_logic;								-- COU Clock (25 MHz)
	i_n_reset					: in std_logic;								-- Reset - debounced pushbutton (KEY1 on FPGA card)
	o_FPReset					: out std_logic;								-- Reset from pushbutton PB30
	-- CPU intercepts
	i_CPUAddress				: in std_logic_vector(15 downto 0);		-- Address lines from the CPU
	o_CPUAddress				: out std_logic_vector(15 downto 0);	-- Address lines from the Front panel
	i_CPUData					: in std_logic_vector(7 downto 0);		-- Data out from the CPU
	o_CPUData					: out std_logic_vector(7 downto 0);		-- Data to memory / peripherals
	i_CPURdData					: in std_logic_vector(7 downto 0);		-- Data from memory / peripherals
	io_run0Halt1				: inout std_logic;							-- Run / Halt from Front Panel 
	o_wrRamStr					: out std_logic;								-- Write strobe to SRAM
	i_R1W0						: in std_logic;								-- Read / Write from CPU
	o_R1W0						: out std_logic;								-- Read / Write to memory / peripherals
	-- External I2C connections
	io_I2C_SCL					: inout std_logic;
	io_I2C_SDA					: inout std_logic;
	i_I2C_INTn					: in std_logic
);
end MIKBUG_FRPNL;

architecture struct of MIKBUG_FRPNL is

	-- Pushbutton signals
	signal w_LEDsOut		:	std_logic_vector(31 downto 0);	-- Pushbutton loopback to LEDs
	signal w_PBsRaw		:	std_logic_vector(31 downto 0);	-- Pushbuttons raw input
	signal w_PBLatched	:	std_logic_vector(31 downto 0);	-- Pushbuttons latched input (de-bounced)
	signal w_PBsToggled	:	std_logic_vector(31 downto 0);	-- Pushbuttons toggled input
	signal w_FPAddress	:	std_logic_vector(15 downto 0);
	signal resetD1			:	std_logic;
	signal w_setAdrPB		:	std_logic;
	signal w_setDatPB		:	std_logic;
	signal w_incAdrPB		:	std_logic;
	signal w_incAdrPBD1	:	std_logic;
	signal w_incAdrPBD2	:	std_logic;
	signal w_clrPB			:	std_logic;
	signal w_clrPBD1		:	std_logic;
	signal w_clrPBD2		:	std_logic;
	signal w_stepPB		:	std_logic;
	signal w_stepPBD1		:	std_logic;
	signal w_stepPBD2		:	std_logic;
	signal w_cntCpu 		:	std_logic_vector(2 DOWNTO 0);		-- Grey code step counter
	
begin
-- -------------------------------------------------------------------------------------------------------
	-- Front Panel starts here
	-- Pass down the sizes
	fp01 : work.FrontPanel01
		generic	map ( 
			INST_SRAM_SIZE_IN	=> 1024,
			STACK_DEPTH_IN		=> 4
		)
		port map
		(
			-- Clock and reset
			i_CLOCK_50			=> i_CLOCK_50,				-- Clock (50 MHz)
			i_n_reset			=> i_n_reset,				-- Reset (from FGPGA KEY)
			-- 32 outs, 32 ins
			i_FPLEDs				=> w_LEDsOut,				-- Out to LEDs (32)
			o_PBRaw				=> w_PBsRaw,				-- Raw version of the  Pushbuttons (32)
			o_PBLatched			=> w_PBLatched,			-- Latched version of the  Pushbuttons (32)
			o_PBToggled			=> w_PBsToggled,			-- Toggle version of the  Pushbuttons (32)
			-- I2C interface
			io_I2C_SCL			=> io_I2C_SCL,				-- I2C clock to Front Panel card
			io_I2C_SDA			=> io_I2C_SDA,				-- I2C data to/from Front Panel card
			i_I2C_INTn			=> i_I2C_INTn				-- Interrupt input - active low
		);
	
	-- Grey code counter 
	-- 000 > 001 > 011 > 010 > 110 > 111 > 101 > 100
	cpuCnt :	PROCESS (i_cpuClock)
	BEGIN
		IF rising_edge(i_cpuClock) THEN
			w_cntCpu(0) <= ((not w_cntCpu(2)) and (not w_cntCpu(1)) and (not w_cntCpu(0)) and (w_incAdrPB)) or	-- 000 > 001
								((not w_cntCpu(2)) and (not w_cntCpu(1)) and (    w_cntCpu(0))) or						-- 001 > 011
								((    w_cntCpu(2)) and (    w_cntCpu(1)) and (not w_cntCpu(0))) or						-- 110 > 111
								((    w_cntCpu(2)) and (    w_cntCpu(1)) and (    w_cntCpu(0)));							-- 111 > 101
										
			w_cntCpu(1) <= ((not w_cntCpu(2)) and (not w_cntCpu(1)) and (    w_cntCpu(0))) or						-- 001 > 011
								((not w_cntCpu(2)) and (    w_cntCpu(1)) and (    w_cntCpu(0))) or						-- 011 > 010
								((not w_cntCpu(2)) and (    w_cntCpu(1)) and (not w_cntCpu(0))) or						-- 010 > 110
								((    w_cntCpu(2)) and (    w_cntCpu(1)) and (not w_cntCpu(0)));							-- 110 > 111
										
			w_cntCpu(2) <= ((not w_cntCpu(2)) and (    w_cntCpu(1)) and (not w_cntCpu(0))) or						-- 010 > 110
								((    w_cntCpu(2)) and (    w_cntCpu(1)) and (not w_cntCpu(0))) or						-- 110 > 111
								((    w_cntCpu(2)) and (    w_cntCpu(1)) and (    w_cntCpu(0))) or						-- 111 > 101
								((    w_cntCpu(2)) and (not w_cntCpu(1)) and (    w_cntCpu(0)));							-- 101 > 100
		END IF;
	END PROCESS;
	
	syncPBsToCpuClk : PROCESS (i_cpuClock)
	BEGIN
		IF rising_edge(i_cpuClock) THEN
			io_run0Halt1	<= w_PBsToggled(31);								-- Run/Halt line (toggled)
			resetD1			<= w_PBLatched(30);								-- Reset pushbutton
			o_FPReset		<= ((not resetD1) and  w_PBLatched(30));	-- Reset (pulsed while butoon is pressed)
			w_clrPBD1		<= w_PBLatched(27);								-- Clear pusgbutton
			w_clrPBD2		<= w_clrPBD1;										-- Delayed Clear pushbutton
			w_clrPB			<= w_clrPBD1 and not w_clrPBD2;				-- Pulse clear pushbutton
			w_stepPBD1		<= w_PBLatched(29);								-- Step pushbutton
			w_stepPBD2		<= w_stepPBD1;										-- Delayed Step pushbutton
			w_stepPB			<=	w_stepPBD1 and not w_stepPBD2;			-- Pulse Step pushbutton
		END IF;
	END PROCESS;

--	w_FPAddress Latch/Counter
	w_FPAddressCounter : PROCESS (i_cpuClock)
	BEGIN
		IF rising_edge(i_cpuClock) THEN
			if ((io_run0Halt1 = '1') and (w_cntCpu = "100")) then
				w_FPAddress <= w_FPAddress+1;
			elsif ((io_run0Halt1 = '1') and (w_setAdrPB = '1')) then
				w_FPAddress <= w_PBsToggled(23 downto 8);
			elsif w_clrPB = '1' then
				w_FPAddress <= (others => '0');
			END IF;
		END IF;
	END PROCESS;
	
	o_CPUAddress <= 	i_CPUAddress	when (io_run0Halt1 = '0') else
							w_FPAddress		when (io_run0Halt1 = '1');
							
	o_CPUData	<= i_CPUData						when (io_run0Halt1 = '0') else
						w_PBsToggled(7 downto 0)	when ((io_run0Halt1 = '1') and (w_setDatPB='1')) else
						i_CPUData						when ((io_run0Halt1 = '1') and (w_setDatPB='0'));

		
	o_R1W0 <= 	i_R1W0	when (io_run0Halt1 = '0') else
					'1'		when (io_run0Halt1 = '1');
	
	o_wrRamStr <= w_cntCpu(1) and io_run0Halt1 and w_setDatPB;
	
	incAdrLine : PROCESS (i_cpuClock)
	BEGIN
		IF rising_edge(i_cpuClock) THEN
			w_setAdrPB		<= w_PBsToggled(24);
			w_setDatPB		<= w_PBsToggled(25);
			w_incAdrPBD1	<= w_PBLatched(26);
			w_incAdrPBD2	<= w_incAdrPBD1;
			w_incAdrPB		<= w_incAdrPBD1 and (not w_incAdrPBD2);
		END IF;
	END PROCESS;

	w_LEDsOut(24) <= w_setAdrPB;
	w_LEDsOut(25) <= w_setDatPB;
		
	w_LEDsOut(31) 				<= not io_run0Halt1;								-- PB31 - Run/Halt toggle
	w_LEDsOut(30) 				<= resetD1 or (not i_n_reset);			-- PB30 -Reset debounced PB
	w_LEDsOut(29 downto 27)	<= "000";
	w_LEDsOut(23 downto 8)	<= i_cpuAddress	when (io_run0Halt1 = '0') else				-- Address lines
										w_FPAddress 	when (io_run0Halt1 = '1') else
										x"0000";
	w_LEDsOut(7 downto 0)	<= i_CPUData						when	((io_run0Halt1='0') and (i_R1W0='0'))		else	-- Data lines
										i_CPURdData						when	((io_run0Halt1='0') and (i_R1W0='1'))		else	-- Data lines
										i_CPURdData						when 	(w_setDatPB='0') and (io_run0Halt1='1')	else	-- Memory data
										w_PBsToggled(7 downto 0)	when  (w_setDatPB='1') and (io_run0Halt1='1')	else	-- Front panel buttons
										x"00";

	-- Front Panel ends here
	-- -------------------------------------------------------------------------------------------------------


end;
	
