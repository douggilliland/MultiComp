-- Jeff Tranter's TS2 in an FPGA
-- 68K CU Core Copyright (c) 2009-2013 Tobias Gubener        
--
-- Doug Gilliland 2020
--

library ieee;
use ieee.std_logic_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

entity TS2_68000_Top is
	port(
		n_reset		: in std_logic;
		i_CLOCK_50	: in std_logic;

		extSramData		: inout std_logic_vector(7 downto 0);
		extSramAddress	: out std_logic_vector(19 downto 0);
		n_extsRamWE		: out std_logic := '1';
		n_extsRamCS		: out std_logic := '1';
		n_extsRamOE		: out std_logic := '1';
		
		rxd1			: in std_logic := '1';
		txd1			: out std_logic;
		cts1			: in std_logic := '1';
		rts1			: out std_logic;
		serSelect	: in std_logic := '1';
		
		videoR0		: out std_logic := '1';
		videoG0		: out std_logic := '1';
		videoB0		: out std_logic := '1';
		videoR1		: out std_logic := '1';
		videoG1		: out std_logic := '1';
		videoB1		: out std_logic := '1';
		hSync			: out std_logic := '1';
		vSync			: out std_logic := '1';

		ps2Clk		: inout std_logic;
		ps2Data		: inout std_logic;
		
		-- Not using the SD RAM but making sure that it's not active
		n_sdRamCas	: out std_logic := '1';		-- CAS on schematic
		n_sdRamRas	: out std_logic := '1';		-- RAS
		n_sdRamWe	: out std_logic := '1';		-- SDWE
		n_sdRamCe	: out std_logic := '1';		-- SD_NCS0
		sdRamClk		: out std_logic := '1';		-- SDCLK0
		sdRamClkEn	: out std_logic := '1';		-- SDCKE0
		sdRamAddr	: out std_logic_vector(14 downto 0) := "000"&x"000";
		sdRamData	: in std_logic_vector(15 downto 0)
	);
end TS2_68000_Top;

architecture struct of TS2_68000_Top is

	signal n_WR							: std_logic;
	signal n_RD							: std_logic;
	signal cpuAddress					: std_logic_vector(31 downto 0);
	signal cpuDataOut					: std_logic_vector(15 downto 0);
	signal cpuDataIn					: std_logic_vector(15 downto 0);
	signal w_nUDS      				: std_logic;
	signal w_nLDS      				: std_logic;
	signal w_busstate      			: std_logic_vector(1 downto 0);
	signal w_nResetOut      		: std_logic;
	signal w_FC      					: std_logic_vector(2 downto 0);
	signal w_clr_berr      			: std_logic;

	signal MonROMData					: std_logic_vector(15 downto 0);
	signal w_sramData					: std_logic_vector(15 downto 0);
	signal interface1DataOut		: std_logic_vector(7 downto 0);
	signal interface2DataOut		: std_logic_vector(7 downto 0);

	signal w_n_IRQ5					: std_logic :='1';	
	signal w_n_IRQ6					: std_logic :='1';	
	
	signal w_n_RamCS					: std_logic :='1';
	signal w_WrRamByteEn				: std_logic_vector(1 downto 0) := "00";
	signal w_wrRamStrobe				: std_logic :='0';
	signal w_n_RomCS					: std_logic :='1';
	signal n_interface1CS			: std_logic :='1';
	signal n_interface2CS			: std_logic :='1';

	signal cpuCount					: std_logic_vector(5 downto 0); 
	signal cpuClock					: std_logic;
	signal resetLow					: std_logic := '1';

   signal serialCount         	: std_logic_vector(15 downto 0) := x"0000";
   signal serialCount_d       	: std_logic_vector(15 downto 0);
   signal serialEn            	: std_logic;
	
begin

	-- Debounce the reset line
	DebounceResetSwitch	: entity work.Debouncer
	port map (
		i_CLOCK_50	=> i_CLOCK_50,
		i_PinIn		=> n_reset,
		o_PinOut		=> resetLow
	);
	

	-- ____________________________________________________________________________________
	-- 68000 CPU
	CPU68K : entity work.TG68KdotC_Kernel
		port map (
			clk				=> cpuClock,
			nReset			=> resetLow,
			clkena_in		=> '1',
			data_in			=> cpuDataIn,
			IPL				=> "111",
			IPL_autovector => '0',
			berr				=> '0',
			CPU				=> "00",
			addr				=> cpuAddress,
			data_write		=> cpuDataOut,
			nWr				=> n_WR,
			nUDS				=> w_nUDS,			-- D8..15 select
			nLDS				=> w_nLDS,			-- D0..7 - select
			busstate			=> w_busstate,		-- 
			nResetOut		=> w_nResetOut,
			FC					=> w_FC,
			clr_berr			=> w_clr_berr
		); 
	
	-- ____________________________________________________________________________________
	-- BASIC ROM
	
	w_n_RomCS <=	'0' when ((cpuAddress(23 downto 12) = x"008")       and (w_busstate = "00"))	else 		-- x008000-x00BFFF (MAIN EPROM)
						'0' when ((cpuAddress(23 downto 3) =  x"00000"&'0') and (w_busstate = "00"))	else		-- X000000-X000007 (VECTORS)
						'1';
	
	rom1 : entity work.Monitor_68K_ROM -- Monitor
		port map (
			address 	=> cpuAddress(11 downto 1),
			clock		=> i_CLOCK_50,
			q			=> MonROMData
		);
	
	-- ____________________________________________________________________________________
	-- RAM
	
	w_n_RamCS 			<= '1' when w_n_RomCS = '1' 								else	-- Not vector table
								'0' when cpuAddress(23 downto 15) = x"00"&'0'	else	-- x000008-x007fff
								'1';
	w_wrRamStrobe		<= (not n_WR) and (not w_n_RamCS);
	w_WrRamByteEn(0)	<= (not n_WR) and (not w_nLDS) and (not w_n_RamCS);
	w_WrRamByteEn(1)	<= (not n_WR) and (not w_nUDS) and (not w_n_RamCS);
	
	ram1 : ENTITY work.RAM_16Kx16
		PORT map	(
			address		=> cpuAddress(14 downto 1),
			clock			=> i_CLOCK_50,
			data			=> cpuDataOut,
			byteena		=> w_WrRamByteEn,
			wren			=> w_wrRamStrobe and w_busstate(1) and w_busstate(0),
			q				=> w_sramData
		);
	
	-- ____________________________________________________________________________________
	-- INPUT/OUTPUT DEVICES
	-- Grant's VGA driver
	-- Removed the Composite video output
	
	n_interface1CS <= '0' when cpuAddress(23 downto 4) = x"01004" else -- x01004X - Based on monitor.lst file ACIA address
							'1';
	
	U29 : entity work.SBCTextDisplayRGB
		port map (
			n_reset => resetLow,
			clk => i_CLOCK_50,
			
			-- RGB CompVideo signals
			hSync		=> hSync,
			vSync		=> vSync,
			videoR0	=> videoR0,
			videoR1	=> videoR1,
			videoG0	=> videoG0,
			videoG1	=> videoG1,
			videoB0	=> videoB0,
			videoB1	=> videoB1,
			n_wr		=> n_interface1CS or      n_WR  or w_nUDS or (not w_busstate(1)) or (not w_busstate(0)),
			n_rd		=> n_interface1CS or (not n_WR) or w_nUDS or (not w_busstate(1)) or (w_busstate(0)),
			n_int		=> w_n_IRQ5,
			regSel	=> cpuAddress(1),
			dataIn	=> cpuDataOut(15 downto 8),
			dataOut	=> interface1DataOut,
			ps2clk	=> ps2Clk,
			ps2Data	=> ps2Data
		);
	
	n_interface2CS <= '0' when cpuAddress(23 downto 4) = x"01004" else -- x01004X - Based on monitor.lst file ACIA address
							'1';
							
	-- Replaced Grant's bufferedUART with Neal Crook's version which uses clock enables instead of clock
	U30 : entity work.bufferedUART
		port map(
			clk		=> i_CLOCK_50,
			n_wr		=> n_interface2CS or      n_WR  or w_nLDS or (not w_busstate(1)) or (not w_busstate(0)),
			n_rd		=> n_interface2CS or (not n_WR) or w_nLDS or (not w_busstate(1)) or (w_busstate(0)),
			n_int		=> w_n_IRQ6,
			regSel	=> cpuAddress(1),
			dataIn	=> cpuDataOut(7 downto 0),
			dataOut	=> interface2DataOut,
			rxClkEn	=> serialEn,
			txClkEn	=> serialEn,			
			rxd		=> rxd1,
			txd		=> txd1,
			n_cts		=> cts1,
			n_rts		=> rts1
		);
	

	-- ____________________________________________________________________________________
	-- CHIP SELECTS
	-- Jumper Pin_85 selects whether UART or VDU are default
	
	-- ____________________________________________________________________________________
	-- BUS ISOLATION
	-- Order matters since SRAM overlaps I/O chip selects
	cpuDataIn <=
		interface1DataOut & x"FF" when n_interface1CS = '0' else
		x"FF" & interface2DataOut  when n_interface2CS = '0' else
		MonROMData when w_n_RomCS = '0' else
		w_sramData when w_n_RamCS = '0' else
		x"FFFF";
	
	-- ____________________________________________________________________________________
	-- SYSTEM CLOCKS
	process (i_CLOCK_50)
		begin
			if rising_edge(i_CLOCK_50) then
				if cpuCount < 4 then -- 4 = 10MHz, 3 = 12.5MHz, 2=16.6MHz, 1=25MHz
					cpuCount <= cpuCount + 1;
				else
					cpuCount <= (others=>'0');
				end if;
				if cpuCount < 2 then -- 2 when 10MHz, 2 when 12.5MHz, 2 when 16.6MHz, 1 when 25MHz
					cpuClock <= '0';
				else
					cpuClock <= '1';
				end if;
			end if;
		end process;
	
	
	-- Baud Rate CLOCK SIGNALS
	
	baud_div: process (serialCount_d, serialCount)
		 begin
			  serialCount_d <= serialCount + 2416;
		 end process;

	process (i_CLOCK_50)
		begin
			if rising_edge(i_CLOCK_50) then
			  -- Enable for baud rate generator
			  serialCount <= serialCount_d;
			  if serialCount(15) = '0' and serialCount_d(15) = '1' then
					serialEn <= '1';
			  else
					serialEn <= '0';
			  end if;
			end if;
		end process;

end;
