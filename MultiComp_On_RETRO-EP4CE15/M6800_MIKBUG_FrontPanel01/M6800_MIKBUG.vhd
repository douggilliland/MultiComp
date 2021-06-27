-- -------------------------------------------------------------------------------------------
-- Original file is copyright by Grant Searle 2014
-- Grant Searle's web site http://searle.hostei.com/grant/    
-- Grant Searle's "multicomp" page at http://searle.hostei.com/grant/Multicomp/index.html
--
-- Changes to this code by Doug Gilliland 2020-2021
--
-- MC6800 CPU running MIKBUG from back in the day
--	32K (internal) RAM version
-- MC6850 ACIA UART
-- VDU
--		XGA 80x25 character display
--		PS/2 keyboard
--	Front Panel
--		http://land-boards.com/blwiki/index.php?title=Front_Panel_For_8_Bit_Computers
-- -------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

entity M6800_MIKBUG is
	port(
		i_n_reset			: in std_logic := '1';
		i_CLOCK_50			: in std_logic;

		-- Video
		o_videoR0			: out std_logic := '1';
		o_videoR1			: out std_logic := '1';
		o_videoG0			: out std_logic := '1';
		o_videoG1			: out std_logic := '1';
		o_videoB0			: out std_logic := '1';
		o_videoB1			: out std_logic := '1';
		o_hSync				: out std_logic := '1';
		o_vSync				: out std_logic := '1';

		-- PS/2
		io_ps2Clk			: inout std_logic := '1';
		io_ps2Data			: inout std_logic := '1';
		
		-- USB Serial (Referenced to the USB side)
		usbtxd1				: in	std_logic := '1';
		usbrxd1				: out std_logic;
		usbrts1				: in	std_logic := '1';
		usbcts1				: out std_logic;
		serSelect			: in	std_logic := '1';
		
		-- I2C to Front Panel
		io_I2C_SCL			: inout	std_logic := '1';
		io_I2C_SDA			: inout	std_logic := '1';
		i_I2C_INTn			: in	std_logic := '1';
		
		-- SRAM not used but making sure that it's not active
		io_extSRamData		: inout std_logic_vector(7 downto 0) := (others=>'Z');
		io_extSRamAddress	: out std_logic_vector(19 downto 0) := x"00000";
		io_n_extSRamWE		: out std_logic := '1';
		io_n_extSRamCS		: out std_logic := '1';
		io_n_extSRamOE		: out std_logic := '1';

		-- Not using the SD RAM but making sure that it's not active
		n_sdRamCas			: out std_logic := '1';		-- CAS
		n_sdRamRas			: out std_logic := '1';		-- RAS
		n_sdRamWe			: out std_logic := '1';		-- SDWE
		n_sdRamCe			: out std_logic := '1';		-- SD_NCS0
		sdRamClk				: out std_logic := '1';		-- SDCLK0
		sdRamClkEn			: out std_logic := '1';		-- SDCKE0
		sdRamAddr			: out std_logic_vector(14 downto 0) := "000"&x"000";
		w_sdRamData			: in std_logic_vector(15 downto 0) := (others=>'Z')
	);
end M6800_MIKBUG;

architecture struct of M6800_MIKBUG is

	signal w_resetLow		: std_logic;
	signal wCPUResetHi	: std_logic := '1';

	-- CPU signals
	signal w_cpuAddress	: std_logic_vector(15 downto 0);
	signal w_cpuAddressB	: std_logic_vector(15 downto 0);
	signal w_cpuDataOut	: std_logic_vector(7 downto 0);
	signal w_cpuDataOutB	: std_logic_vector(7 downto 0);
	signal w_cpuDataIn	: std_logic_vector(7 downto 0);
	signal w_R1W0			: std_logic;
	signal w_R1W0B			: std_logic;
	signal w_vma			: std_logic;

	-- Data busses
	signal w_romData		: std_logic_vector(7 downto 0);
	signal w_ramData		: std_logic_vector(7 downto 0);
	signal w_if1DataOut	: std_logic_vector(7 downto 0);
	signal w_if2DataOut	: std_logic_vector(7 downto 0);

	-- Chip Selects
	signal n_int1			: std_logic :='1';	
	signal n_if1CS			: std_logic :='1';
	signal n_int2			: std_logic :='1';	
	signal n_if2CS			: std_logic :='1';

	-- CPU Clock block
	signal q_cpuClkCount	: std_logic_vector(5 downto 0); 
	signal w_cpuClock		: std_logic;

--   signal serialCount   : std_logic_vector(15 downto 0) := x"0000";
--   signal serialCount_d	: std_logic_vector(15 downto 0);
   signal serialEn      : std_logic;

	-- Pushbutton signals
	signal w_LEDsOut		:	std_logic_vector(31 downto 0);	-- Pushbutton loopback to LEDs
	signal w_PBsRaw		:	std_logic_vector(31 downto 0);	-- Pushbuttons raw input
	signal w_PBLatched	:	std_logic_vector(31 downto 0);	-- Pushbuttons latched input (de-bounced)
	signal w_PBsToggled	:	std_logic_vector(31 downto 0);	-- Pushbuttons toggled input
	signal run0Halt1		:	std_logic;
	signal resetD1			:	std_logic;
	signal w_FPAddress	:	std_logic_vector(15 downto 0);
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
	
	-- Debounce the reset line
	DebounceResetSwitch	: entity work.Debouncer
	port map (
		i_clk		=> w_cpuClock,
		i_PinIn	=> i_n_reset,
		o_PinOut	=> w_resetLow
	);
	
	-- Need CPU reset to be later and later than peripherals
	process (w_cpuClock)
		begin
			if rising_edge(w_cpuClock) then
				wCPUResetHi <= not w_resetLow;
			end if;
		end process;
		
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
			i_n_reset			=> w_resetLow,				-- Reset (from FGPGA KEY)
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
	cpuCnt :	PROCESS (w_cpuClock)
	BEGIN
		IF rising_edge(w_cpuClock) THEN
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
	
	syncPBsToCpuClk : PROCESS (w_cpuClock)
	BEGIN
		IF rising_edge(w_cpuClock) THEN
			run0Halt1	<= w_PBsToggled(31);							-- Run/Halt line (toggled)
			resetD1		<= w_PBLatched(30);							-- Reset (pulsed while btoon is pressed)
			w_clrPBD1	<= w_PBLatched(27);							-- Clear pusgbutton
			w_clrPBD2	<= w_clrPBD1;									-- Delayed Clear pushbutton
			w_clrPB		<= w_clrPBD1 and not w_clrPBD2;			-- Pulse clear pushbutton
			w_stepPBD1	<= w_PBLatched(29);							-- Step pushbutton
			w_stepPBD2	<= w_stepPBD1;									-- Delayed Step pushbutton
			w_stepPB		<=	w_stepPBD1 and not w_stepPBD2;	-- Pulse Step pushbutton
		END IF;
	END PROCESS;

--	w_FPAddress Latch/Counter
	w_FPAddressCounter : PROCESS (w_cpuClock)
	BEGIN
		IF rising_edge(w_cpuClock) THEN
			if ((run0Halt1 = '1') and (w_cntCpu = "100")) then
				w_FPAddress <= w_FPAddress+1;
			elsif ((run0Halt1 = '1') and (w_setAdrPB = '1')) then
				w_FPAddress <= w_PBsToggled(23 downto 8);
			elsif w_clrPB = '1' then
				w_FPAddress <= (others => '0');
			END IF;
		END IF;
	END PROCESS;
	
	w_cpuAddress <= 	w_cpuAddressB	when (run0Halt1 = '0') else
							w_FPAddress		when (run0Halt1 = '1');
							
	w_cpuDataOut	<= w_cpuDataOutB					when (run0Halt1 = '0') else
							w_PBsToggled(7 downto 0)	when (run0Halt1 = '1');

		
	w_R1W0 <= 	w_R1W0B	when (run0Halt1 = '0') else
					'1'		when (run0Halt1 = '1');
	
	incAdrLine : PROCESS (w_cpuClock)
	BEGIN
		IF rising_edge(w_cpuClock) THEN
			w_setAdrPB		<= w_PBsToggled(24);
			w_setDatPB		<= w_PBsToggled(25);
			w_incAdrPBD1	<= w_PBLatched(26);
			w_incAdrPBD2	<= w_incAdrPBD1;
			w_incAdrPB		<= w_incAdrPBD1 and (not w_incAdrPBD2);
		END IF;
	END PROCESS;

	w_LEDsOut(24) <= w_setAdrPB;
	w_LEDsOut(25) <= w_setDatPB;
		
	w_LEDsOut(31) 				<= not run0Halt1;								-- PB31 - Run/Halt toggle
	w_LEDsOut(30) 				<= resetD1 or (not w_resetLow);			-- PB30 -Reset debounced PB
	w_LEDsOut(29 downto 27)	<= "000";
	w_LEDsOut(23 downto 8)	<= w_cpuAddress	when (run0Halt1 = '0') else				-- Address lines
										w_FPAddress 	when (run0Halt1 = '1') else
										x"0000";
	w_LEDsOut(7 downto 0)	<= w_cpuDataIn						when ((w_R1W0 = '1') and (run0Halt1 = '0')) else	-- Data lines (read)
										w_cpuDataOut					when ((w_R1W0 = '0') and (run0Halt1 = '0')) else	-- Data lines (write)
										w_cpuDataIn						when 	(w_setDatPB='0') and  run0Halt1 = '1'   else	-- Memory data
										w_PBsToggled(7 downto 0)	when  (w_setDatPB='1') and  run0Halt1 = '1'   else	-- Front panel buttons
										x"00";

	-- Front Panel ends here
	-- -------------------------------------------------------------------------------------------------------

	-- ____________________________________________________________________________________
	-- I/O CHIP SELECTS
	n_if1CS	<= '0' 	when (serSelect = '1' and (w_cpuAddress(15 downto 1) = x"801"&"100")) else	-- VDU  $8018-$8019
					'0'	when (serSelect = '0' and (w_cpuAddress(15 downto 1) = x"802"&"100")) else	-- ACIA $8028-$8029
					'1';
	n_if2CS	<= '0' 	when (serSelect = '1' and (w_cpuAddress(15 downto 1) = x"802"&"100")) else	-- ACIA $8028-$8029
					'0'	when (serSelect = '0' and (w_cpuAddress(15 downto 1) = x"801"&"100")) else	-- VDU  $8018-$8019
					'1';
	
	-- ____________________________________________________________________________________
	-- CPU Read Data multiplexer
	w_cpuDataIn <=
		w_ramData		when w_cpuAddress(15) = '0'				else
		w_if1DataOut	when n_if1CS = '0'							else
		w_if2DataOut	when n_if2CS = '0'							else
		w_romData		when w_cpuAddress(15 downto 14) = "11"	else
		x"FF";
	
	-- ____________________________________________________________________________________
	-- 6800 CPU
	
	cpu1 : entity work.cpu68
		port map(
			clk		=> w_cpuClock,
			rst		=> wCPUResetHi,	-- resetD1 and not resetD2,
			rw			=> w_R1W0B,
			vma		=> w_vma,
			address	=> w_cpuAddressB,
			data_in	=> w_cpuDataIn,
			data_out	=> w_cpuDataOutB,
			hold		=> '0',
			halt		=> run0Halt1,
			irq		=> '0',
			nmi		=> '0'
		); 
	
	-- ____________________________________________________________________________________
	-- MIKBUG ROM
	-- 4KB MIKBUG ROM - repeats in memory 4 times
	rom1 : entity work.M6800_MIKBUG_32KB
		port map (
			address	=> w_cpuAddress(11 downto 0),
			clock 	=> i_CLOCK_50,
			q			=> w_romData
		);
		
	-- ____________________________________________________________________________________
	-- 32KB RAM	
	sram : entity work.InternalRam32K
		PORT map  (
			address	=> w_cpuAddress(14 downto 0),
			clock 	=> i_CLOCK_50,
			data 		=> w_cpuDataOut,
			wren		=> (((not w_R1W0) and (not w_cpuAddress(15)) and w_vma and (not w_cpuClock) and (not run0Halt1)) 
							or ((w_cntCpu(1) and run0Halt1) and w_setDatPB)),
			q			=> w_ramData
		);
	
	-- ____________________________________________________________________________________
	-- INPUT/OUTPUT DEVICES
	-- Grant's VGA driver
	vdu : entity work.SBCTextDisplayRGB
		port map (
			n_reset	=> w_resetLow,
			clk		=> i_CLOCK_50,
			n_WR		=> n_if1CS or      w_R1W0  or (not w_vma) or (not w_cpuClock),
			n_rd		=> n_if1CS or (not w_R1W0) or (not w_vma),
			n_int		=> n_int1,
			regSel	=> w_cpuAddress(0),
			dataIn	=> w_cpuDataOut,
			dataOut	=> w_if1DataOut,
			-- VGA video signals
			hSync		=> o_hSync,
			vSync		=> o_vSync,
			videoR0	=> o_videoR0,
			videoR1	=> o_videoR1,
			videoG0	=> o_videoG0,
			videoG1	=> o_videoG1,
			videoB0	=> o_videoB0,
			videoB1	=> o_videoB1,
			-- PS/2 keyboard
			ps2Clk	=> io_ps2Clk,
			ps2Data	=> io_ps2Data
		);
	
	-- ACIA UART serial interface
	acia: entity work.bufferedUART
		port map (
			clk		=> i_CLOCK_50,     
			n_WR		=> n_if2CS or      w_R1W0  or (not w_vma) or (not w_cpuClock),
			n_rd		=> n_if2CS or (not w_R1W0) or (not w_vma),
			regSel	=> w_cpuAddress(0),
			dataIn	=> w_cpuDataOut,
			dataOut	=> w_if2DataOut,
			n_int		=> n_int2,
						 -- these clock enables are asserted for one period of input clk,
						 -- at 16x the baud rate.
			rxClkEn	=> serialEn,
			txClkEn	=> serialEn,
			rxd		=> usbtxd1,
			txd		=> usbrxd1,
			n_cts		=> usbrts1,
			n_rts		=> usbcts1
		);
		
	-- ____________________________________________________________________________________
	-- CPU Clock
	process (i_CLOCK_50)
		begin
			if rising_edge(i_CLOCK_50) then
				if q_cpuClkCount < 4 then
					q_cpuClkCount <= q_cpuClkCount + 1;
				else
					q_cpuClkCount <= (others=>'0');
				end if;
				if q_cpuClkCount < 2 then
					w_cpuClock <= '0';
				else
					w_cpuClock <= '1';
				end if;
			end if;
		end process;

	-- ____________________________________________________________________________________
	-- Baud Rate Generator
	-- Legal BAUD_RATE values are 115200, 38400, 19200, 9600, 4800, 2400, 1200, 600, 300
	BaudRateGen : entity work.BaudRate6850
	GENERIC map (
		BAUD_RATE	=>  115200
	)
	PORT map (
		i_CLOCK_50	=> i_CLOCK_50,
		o_serialEn	=> serialEn
	);

end;
