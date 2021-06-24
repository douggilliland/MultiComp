-- Original file is copyright by Grant Searle 2014
-- Grant Searle's web site http://searle.hostei.com/grant/    
-- Grant Searle's "multicomp" page at http://searle.hostei.com/grant/Multicomp/index.html
--
-- Changes to this code by Doug Gilliland 2020
--
-- MC6800 CPU running MIKBUG from back in the day
--	16.67 MHz
--	32K+8+4 = 44KB (internal) SRAM
--	64 banks of 16KB of external SRAM (1MB total)
-- Bank Select register (7 bits)
-- MIKBUG ROM - 60 KB version
--		http://www.retrotechnology.com/restore/smithbug.html
-- MC6850 ACIA UART
-- VDU
--		XGA 80x25 character display
--		PS/2 keyboard
-- Select Jumper (J3-1) switches between
--		VDU (Video Display Unit) VGA + PS/2 keyboard (jumper out)
--		External Serial Port (jumper in)
--	Memory Map
--		x0000-x7fff - 32KB Internal SRAM
--		x8000-xbfff - 16Kb SRAM bank (64 banks)
--		xc000-xefff - 12KB Internal SRAM
--		xf000-xffff - 4 KB ROM
--		xfc00-xfcff - I/O space
--			xfc18-xfc19 - VDU/UART (6850 Interface)
--			xfc28-xfc29 - UART.VDU (6850 Interface)
--			xfc30 - Bank Select register (r/w)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

entity M6800_MIKBUG is
	port(
		i_n_reset			: in std_logic := '1';
		i_CLOCK_50			: in std_logic;

		o_videoR0			: out std_logic := '1';
		o_videoR1			: out std_logic := '1';
		o_videoG0			: out std_logic := '1';
		o_videoG1			: out std_logic := '1';
		o_videoB0			: out std_logic := '1';
		o_videoB1			: out std_logic := '1';
		o_hSync				: out std_logic := '1';
		o_vSync				: out std_logic := '1';

		io_ps2Clk			: inout std_logic := '1';
		io_ps2Data			: inout std_logic := '1';
		
		utxd1					: in	std_logic := '1';
		urxd1					: out std_logic;
		urts1					: in	std_logic := '1';
		ucts1					: out std_logic;
		serSelect			: in	std_logic := '1';
		
		-- SRAM banked space
		io_extSRamData		: inout std_logic_vector(7 downto 0) := (others=>'Z');
		o_extSRamAddress	: out std_logic_vector(19 downto 0) := x"00000";
		o_n_extSRamWE		: out std_logic := '1';
		o_n_extSRamCS		: out std_logic := '1';
		o_n_extSRamOE		: out std_logic := '1';
		
		testPt1				: out std_logic := '1';
		testPt2				: out std_logic := '1';

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

	signal w_resetLow		: std_logic := '1';

	-- CPU Signals
	signal w_cpuAddress	: std_logic_vector(15 downto 0);
	signal w_cpuDataOut	: std_logic_vector(7 downto 0);
	signal w_cpuDataIn	: std_logic_vector(7 downto 0);
	signal w_R1W0			: std_logic;
	signal w_vma			: std_logic;

	-- Memory and Peripheral Data
	signal w_romData		: std_logic_vector(7 downto 0);
	signal w_ramData32K	: std_logic_vector(7 downto 0);
	signal w_ramData8K	: std_logic_vector(7 downto 0);
	signal w_ramData4K	: std_logic_vector(7 downto 0);
	signal w_if1DataOut	: std_logic_vector(7 downto 0);
	signal w_if2DataOut	: std_logic_vector(7 downto 0);

	-- Memory controls
	signal w_n_SRAMCE		: std_logic;
	signal w_bankAdr		: std_logic;
	signal w_ldAdrVal		: std_logic;
	signal adrLatVal		: std_logic_vector(7 downto 0);

	-- Interface control lines
	signal n_int1			: std_logic :='1';	
	signal n_if1CS			: std_logic :='1';
	signal n_int2			: std_logic :='1';	
	signal n_if2CS			: std_logic :='1';

	-- CPU Clock
	signal q_cpuClkCount	: std_logic_vector(5 downto 0); 
	signal w_cpuClock		: std_logic;

   -- External Serial Port Cloc
   signal serialCount   : std_logic_vector(15 downto 0) := x"0000";
   signal serialCount_d	: std_logic_vector(15 downto 0);
   signal serialEn      : std_logic;
	
begin



	testPt1 <= w_cpuClock;
	testPt2 <= w_n_SRAMCE or (not w_R1W0) or (not w_vma);
	
	-- Debounce the reset line
	DebounceResetSwitch	: entity work.Debouncer
	port map (
		i_clk		=> w_cpuClock,
		i_PinIn	=> i_n_reset,
		o_PinOut	=> w_resetLow
	);
		
	-- External SRAM
	w_n_SRAMCE	<= '0'   when w_cpuAddress(15 downto 14) = "10" else		-- 16KB SRAM $8000-$BFFF
						'1';
	w_bankAdr	<= '1' when w_cpuAddress(15 downto 14) = "10" else '0';
	o_n_extSRamCS <= w_n_SRAMCE                 or (not w_vma);
	o_n_extSRamWE <= w_n_SRAMCE or      w_R1W0  or (not w_vma)  or (w_cpuClock);
	o_n_extSRamOE <= w_n_SRAMCE or (not w_R1W0) or (not w_vma);
	o_extSRamAddress(19 downto 14) 	<= adrLatVal(5 downto 0);
	o_extSRamAddress(13 downto 0) 	<= w_cpuAddress(13 downto 0);
	io_extSRamData <= w_cpuDataOut when ((w_n_SRAMCE = '0') and (w_R1W0 = '0')) else (others => 'Z');

	addrLatch : entity work.OutLatch
		port map
		(
			dataIn	=> w_cpuDataOut,
			clock		=> i_CLOCK_50,
			load		=> w_ldAdrVal or w_R1W0 or (not w_vma) or (not w_cpuClock),
			clear		=> w_resetLow,
			latchOut	=> adrLatVal
		);
		
		
	-- ____________________________________________________________________________________
	-- I/O CHIP SELECTS
	n_if1CS	<= '0' 	when (serSelect = '1' and (w_cpuAddress(15 downto 1) = x"FC1"&"100")) else	-- VDU  $8018-$8019
					'0'	when (serSelect = '0' and (w_cpuAddress(15 downto 1) = x"FC2"&"100")) else	-- ACIA $8028-$8029
					'1';
	n_if2CS	<= '0' 	when (serSelect = '1' and (w_cpuAddress(15 downto 1) = x"FC2"&"100")) else	-- ACIA $8028-$8029
					'0'	when (serSelect = '0' and (w_cpuAddress(15 downto 1) = x"FC1"&"100")) else	-- VDU  $8018-$8019
					'1';
	w_ldAdrVal <= '0' when (w_cpuAddress = x"FC30") else '1';
		
	-- ____________________________________________________________________________________
	-- CPU Read Data multiplexer
	w_cpuDataIn <=
		w_ramData32K	when w_cpuAddress(15) = '0'																												else	-- 32 KB
		w_ramData8K		when (w_cpuAddress(15) = '1' and w_cpuAddress(14) = '1' and w_cpuAddress(13) = '0')										else	-- 8KB
		w_ramData4K		when (w_cpuAddress(15) = '1' and w_cpuAddress(14) = '1' and w_cpuAddress(13) = '1' and w_cpuAddress(12) = '0')	else	-- 4 KB
		io_extSRamData	when (w_n_SRAMCE = '0')																														else
		w_if1DataOut	when n_if1CS = '0'																															else
		w_if2DataOut	when n_if2CS = '0'																															else
		adrLatVal		when (w_ldAdrVal = '0') 																													else
		w_romData		when w_cpuAddress(15 downto 14) = "11"																									else -- Must be last
		x"FF";
	
	-- ____________________________________________________________________________________
	-- 6800 CPU
	cpu1 : entity work.cpu68
		port map(
			clk		=> w_cpuClock,
			rst		=> not w_resetLow,
			rw			=> w_R1W0,
			vma		=> w_vma,
			address	=> w_cpuAddress,
			data_in	=> w_cpuDataIn,
			data_out	=> w_cpuDataOut,
			hold		=> '0',
			halt		=> '0',
			irq		=> '0',
			nmi		=> '0'
		); 
	
	-- ____________________________________________________________________________________
	-- MIKBUG ROM
	-- 4KB MIKBUG ROM - repeats in memory 4 times
	rom1 : entity work.MIKBUG
		port map (
			address	=> w_cpuAddress(11 downto 0),
			clock 	=> i_CLOCK_50,
			q			=> w_romData
		);
		
	-- ____________________________________________________________________________________
	-- 32KB RAM	x0000-x7fff
	sram32K : entity work.InternalRam32K
		PORT map  (
			address	=> w_cpuAddress(14 downto 0),
			clock 	=> i_CLOCK_50,
			data 		=> w_cpuDataOut,
			wren		=> (not w_R1W0) and (not w_cpuAddress(15)) and w_vma and (not w_cpuClock),
			q			=> w_ramData32K
		);
	
	-- ____________________________________________________________________________________
	-- 8KB RAM xc000-dfff
	sram8K : entity work.InternalRam8K
		PORT map  (
			address	=> w_cpuAddress(12 downto 0),
			clock 	=> i_CLOCK_50,
			data 		=> w_cpuDataOut,
			wren		=> (not w_R1W0) and w_cpuAddress(15) and (w_cpuAddress(14)) and (not w_cpuAddress(13)) and w_vma and (not w_cpuClock),
			q			=> w_ramData8K
		);
	
	-- ____________________________________________________________________________________
	-- 4KB RAM xe000-xefff
	sram4K : entity work.InternalRam4K
		PORT map  (
			address	=> w_cpuAddress(11 downto 0),
			clock 	=> i_CLOCK_50,
			data 		=> w_cpuDataOut,
			wren		=> (not w_R1W0) and w_cpuAddress(15) and w_cpuAddress(14) and w_cpuAddress(13) and (not w_cpuAddress(12)) and w_vma and (not w_cpuClock),
			q			=> w_ramData4K
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
			rxd		=> utxd1,
			txd		=> urxd1,
			n_cts		=> urts1,
			n_rts		=> ucts1
		);
	
	-- ____________________________________________________________________________________
	-- CPU Clock
	-- Need 2 clocks high for externl SRAM can get by with 1 clock low
	-- Produces a 40 nS wide wriye strobe - 45 nS SRAMs need a 35 nS write pulse, so this works
	process (i_CLOCK_50, w_n_SRAMCE)
		begin
			if rising_edge(i_CLOCK_50) then
				if w_n_SRAMCE = '0' then
					if q_cpuClkCount < 2 then						-- 50 MHz / 3 = 16.7 MHz 
						q_cpuClkCount <= q_cpuClkCount + 1;
					else
						q_cpuClkCount <= (others=>'0');
					end if;
				else
					if q_cpuClkCount < 1 then						-- 50 MHz / 2 = 25 MHz
						q_cpuClkCount <= q_cpuClkCount + 1;
					else
						q_cpuClkCount <= (others=>'0');
					end if;
				end if;
				if q_cpuClkCount < 1 then						-- 2 clocks high, one low
					w_cpuClock <= '0';
				else
					w_cpuClock <= '1';
				end if;
			end if;
		end process;
	
	-- ____________________________________________________________________________________
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
