-- Original file is copyright by Grant Searle 2014
-- Grant Searle's web site http://searle.hostei.com/grant/    
-- Grant Searle's "multicomp" page at http://searle.hostei.com/grant/Multicomp/index.html
--
-- Changes to this code by Doug Gilliland 2020
--
-- MC6800 CPU running MIKBUG from back in the day
--	3K (internal) RAM version
-- MC6850 ACIA UART
-- VDU
--		XGA 80x25 character display
--		PS/2 keyboard
--
-- The Memory Map is:
--	$0000-$07FF - 2KB SRAM (internal RAM in the EPCE15)
--	$7C00-$7FFF - 1KB SRAM (internal RAM in the EPCE15)
--	$8000-$8001 - ACIA
--	$C000-$CFFF - MIKBUG ROM (repeats 4 times from 0xC000-0xFFFF)
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
		
		i_USB_txd			: in	std_logic := '1';
		o_USB_rxd			: out std_logic;
--		urts1					: in	std_logic := '1';
		i_USB_cts			: out std_logic;
		i_SerSelect			: in	std_logic := '1';
		
		Pin25					: out std_logic;
		Pin31					: out std_logic;
		Pin41					: out std_logic;
		Pin40					: out std_logic;
		Pin43					: out std_logic;
		Pin42					: out std_logic;
		Pin45					: out std_logic;
		Pin44					: out std_logic;
		
		-- SRAM not used but making sure that it's not active
		io_extSRamData		: inout std_logic_vector(7 downto 0) := (others=>'Z');
		io_extSRamAddress	: out std_logic_vector(16 downto 0);
		io_n_extSRamWE		: out std_logic := '1';
		io_n_extSRamCS		: out std_logic := '1';
		io_n_extSRamOE		: out std_logic := '1'
	);
end M6800_MIKBUG;

architecture struct of M6800_MIKBUG is

	signal w_resetLow		: std_logic := '1';

	signal w_cpuAddress	: std_logic_vector(15 downto 0);
	signal w_cpuDataOut	: std_logic_vector(7 downto 0);
	signal w_cpuDataIn	: std_logic_vector(7 downto 0);
	signal w_R1W0			: std_logic;
	signal w_vma			: std_logic;
	signal w_memWR			: std_logic;
	signal w_memRD			: std_logic;

	signal w_romData		: std_logic_vector(7 downto 0);
	signal w_ramData1		: std_logic_vector(7 downto 0);
	signal w_ramData2		: std_logic_vector(7 downto 0);
	signal w_if1DataOut	: std_logic_vector(7 downto 0);
	signal w_if2DataOut	: std_logic_vector(7 downto 0);
	
	signal w_RAM_CS_1		: std_logic;
	signal w_RAM_CS_2		: std_logic;

	signal n_int1			: std_logic :='1';	
	signal n_if1CS			: std_logic :='1';
	signal n_int2			: std_logic :='1';	
	signal n_if2CS			: std_logic :='1';

	signal w_cpuClkCt	: std_logic_vector(5 downto 0); 
	signal w_cpuClk		: std_logic;

   signal serialCount   : std_logic_vector(15 downto 0) := x"0000";
   signal serialCount_d	: std_logic_vector(15 downto 0);
   signal serialEn      : std_logic;
	
begin
	
	-- Debug
	Pin25 <= w_cpuClk;
	Pin31 <= w_RAM_CS_1;
	Pin41 <= w_memWR;
	Pin40 <= i_CLOCK_50;
	
	-- Debounce the reset line
	DebounceResetSwitch	: entity work.Debouncer
	port map (
		i_CLOCK_50	=> i_CLOCK_50,
		i_PinIn		=> i_n_reset,
		o_PinOut		=> w_resetLow
	);
	
	w_memWR <= (not w_R1W0) and w_vma and w_cpuClk;
	w_memRD <=      w_R1W0  and w_vma and w_cpuClk;
	
	w_RAM_CS_1 <= (not w_cpuAddress(15)) and (not w_cpuAddress(14)) and (not w_cpuAddress(13)) and (not w_cpuAddress(12)) and (not w_cpuAddress(11));
	w_RAM_CS_2 <= (not w_cpuAddress(15)) and      w_cpuAddress(14)  and      w_cpuAddress(13)  and      w_cpuAddress(12)  and      w_cpuAddress(11)  and      w_cpuAddress(10);
	
	-- ____________________________________________________________________________________
	-- I/O CHIP SELECTS
	n_if1CS	<= '0' 	when (i_SerSelect = '1' and (w_cpuAddress(15 downto 1) = x"801"&"100")) else	-- VDU  $8018-$8019
					'0'	when (i_SerSelect = '0' and (w_cpuAddress(15 downto 1) = x"802"&"100")) else	-- ACIA $8028-$8029
							'1';
	n_if2CS	<= '0' 	when (i_SerSelect = '1' and (w_cpuAddress(15 downto 1) = x"802"&"100")) else	-- ACIA $8028-$8029
					'0'	when (i_SerSelect = '0' and (w_cpuAddress(15 downto 1) = x"801"&"100")) else	-- VDU  $8018-$8019
							'1';
	
	-- ____________________________________________________________________________________
	-- CPU Read Data multiplexer
	w_cpuDataIn <=
		w_ramData1		when w_RAM_CS_1 = '1'							else
		w_ramData2		when w_RAM_CS_2 = '1'							else
		w_if1DataOut	when (n_if1CS = '0')								else
		w_if2DataOut	when (n_if2CS = '0')								else
		w_romData		when w_cpuAddress(15 downto 14) = "11"		else
		x"FF";
	
	-- ____________________________________________________________________________________
	-- 6800 CPU
	cpu1 : entity work.cpu68
		port map(
			clk		=> w_cpuClk,
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
	-- 2KB RAM	
	sram1 : entity work.InternalRam2K
		PORT map  (
			address	=> w_cpuAddress(10 downto 0),
			clock 	=> i_CLOCK_50,
			data 		=> w_cpuDataOut,
			wren		=> w_RAM_CS_1 and w_memWR,
			q			=> w_ramData1
		);
	
	-- ____________________________________________________________________________________
	-- 1KB RAM	
	sram2 : entity work.InternalRam1K
		PORT map  (
			address	=> w_cpuAddress(9 downto 0),
			clock 	=> i_CLOCK_50,
			data 		=> w_cpuDataOut,
			wren		=> w_RAM_CS_2 and w_memWR,
			q			=> w_ramData2
		);
	
	-- ____________________________________________________________________________________
	-- INPUT/OUTPUT DEVICES
	-- Grant's VGA driver
	vdu : entity work.SBCTextDisplayRGB
		generic map ( 
--			COLOUR_ATTS_ENABLED => 0,
			SANS_SERIF_FONT => 1,
			EXTENDED_CHARSET => 0
		)
		port map (
			clk		=> i_CLOCK_50,
			n_WR		=> n_if1CS or      w_R1W0  or (not w_vma) or (not w_cpuClk),
			n_rd		=> n_if1CS or (not w_R1W0) or (not w_vma),
			n_reset	=> w_resetLow,
			-- RGB Compo_video signals
			hSync		=> o_hSync,
			vSync		=> o_vSync,
			videoR0	=> o_videoR0,
			videoR1	=> o_videoR1,
			videoG0	=> o_videoG0,
			videoG1	=> o_videoG1,
			videoB0	=> o_videoB0,
			videoB1	=> o_videoB1,
			n_int		=> n_int1,
			regSel	=> w_cpuAddress(0),
			dataIn	=> w_cpuDataOut,
			dataOut	=> w_if1DataOut,
			ps2Clk	=> io_ps2Clk,
			ps2Data	=> io_ps2Data
	);
	
	-- ACIA UART serial interface
	acia: entity work.bufferedUART
		port map (
			clk		=> i_CLOCK_50,     
			n_WR		=> n_if2CS or      w_R1W0  or (not w_vma) or (not w_cpuClk),
			n_rd		=> n_if2CS or (not w_R1W0) or (not w_vma),
			regSel	=> w_cpuAddress(0),
			dataIn	=> w_cpuDataOut,
			dataOut	=> w_if2DataOut,
			n_int		=> n_int2,
						 -- these clock enables are asserted for one period of input clk,
						 -- at 16x the baud rate.
			rxClkEn	=> serialEn,
			txClkEn	=> serialEn,
			rxd		=> i_USB_txd,
			txd		=> o_USB_rxd,
--			n_cts		=> urts1,
			n_rts		=> i_USB_cts
		);
	
	-- ____________________________________________________________________________________
	-- CPU Clock
process (i_CLOCK_50)
	begin
		if rising_edge(i_CLOCK_50) then
			if w_cpuClkCt < 3 then -- 4 = 10MHz, 3 = 12.5MHz, 2=16.6MHz, 1=25MHz
				w_cpuClkCt <= w_cpuClkCt + 1;
			else
				w_cpuClkCt <= (others=>'0');
			end if;
			if w_cpuClkCt < 2 then -- 2 when 10MHz, 2 when 12.5MHz, 2 when 16.6MHz, 1 when 25MHz
				w_cpuClk <= '0';
			else
				w_cpuClk <= '1';
			end if;
		end if;
	end process;
	
	-- ____________________________________________________________________________________
	-- Baud Rate Clock Signals
	-- Serial clock DDS
	-- 50MHz master input clock:
	-- f = (increment x 50,000,000) / 65,536 = 16X baud rate
	-- Baud Increment
	-- 115200 2416
	-- 38400 805
	-- 19200 403
	-- 9600 201
	-- 4800 101
	-- 2400 50

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