-- This file is copyright by Grant Searle 2014
-- Grant Searle's web site http://searle.hostei.com/grant/    
-- Grant Searle's "multicomp" page at http://searle.hostei.com/grant/Multicomp/index.html
--
-- MC6800 CPU running MIKBUG from back in the day
-- Changes to this code by Doug Gilliland 2020
--	32K (internal) RAM version
--
-- Jumper in pin B22 to ground (adjacent pin) of the FPGA selects the VDU/Serial port
-- Install to make serial port default
-- Remove jumper to make the VDU default
--
-- 115,200 baud serial port
-- Hardware handshake RTS/CTS
--

library ieee;
use ieee.std_logic_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

entity M6800_MIKBUG is
	port(
		n_reset		: in std_logic;
		i_CLOCK_50	: in std_logic;

		sramData		: inout std_logic_vector(7 downto 0);
		sramAddress	: out std_logic_vector(19 downto 0);
		n_sRamWE		: out std_logic := '1';
		n_sRamCS		: out std_logic := '1';
		n_sRamOE		: out std_logic := '1';
		
		rxd1			: in std_logic := '1';
		txd1			: out std_logic;
		cts1			: in std_logic := '1';
		rts1			: out std_logic;
		
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
		sdRamData	: in std_logic_vector(15 downto 0);

		serSelect	: in std_logic := '1'
	);
end M6800_MIKBUG;

architecture struct of M6800_MIKBUG is

	signal n_WR							: std_logic;
	signal n_RD							: std_logic;
	signal vma							: std_logic;
	signal cpuAddress					: std_logic_vector(15 downto 0);
	signal cpuDataOut					: std_logic_vector(7 downto 0);
	signal cpuDataIn					: std_logic_vector(7 downto 0);
	signal romData						: std_logic_vector(7 downto 0);

	signal interface1DataOut		: std_logic_vector(7 downto 0);
	signal interface2DataOut		: std_logic_vector(7 downto 0);

	signal n_memWR						: std_logic :='1';
	signal n_memRD 					: std_logic :='1';

	signal n_int1						: std_logic :='1';	
	signal n_int2						: std_logic :='1';	
	
	signal n_RomCS					: std_logic :='1';
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
	-- 6800 CPU
	cpu1 : entity work.cpu68
		port map(
			clk => not(cpuClock),
			rst => not resetLow,
			rw => n_WR,
			vma => vma,
			address => cpuAddress,
			data_in => cpuDataIn,
			data_out => cpuDataOut,
			hold => '0',
			halt => '0',
			irq => '0',
			nmi => '0'
		); 
	
	-- ____________________________________________________________________________________
	-- MIKBUG ROM	
	rom1 : entity work.MIKBUG -- 2KB MIKBUG ROM
		port map(
			address => cpuAddress(10 downto 0),
			clock => i_CLOCK_50,
			q => romData
		);
	
	-- ____________________________________________________________________________________
	-- INPUT/OUTPUT DEVICES
	-- Grant's VGA driver
	-- Removed the Composite video output
	io1 : entity work.SBCTextDisplayRGB
		port map (
			n_reset => resetLow,
			clk => i_CLOCK_50,
			
			-- RGB CompVideo signals
			hSync => hSync,
			vSync => vSync,
			videoR0 => videoR0,
			videoR1 => videoR1,
			videoG0 => videoG0,
			videoG1 => videoG1,
			videoB0 => videoB0,
			videoB1 => videoB1,
			n_wr => n_interface1CS or cpuClock or n_WR,
			n_rd => n_interface1CS or cpuClock or (not n_WR),
			n_int => n_int1,
			regSel => cpuAddress(0),
			dataIn => cpuDataOut,
			dataOut => interface1DataOut,
			ps2clk => ps2Clk,
			ps2Data => ps2Data
		);
	
	-- Replaced Grant's bufferedUART with Neal Crook's version which uses clock enables instead of clock
	io2 : entity work.bufferedUART
		port map(
			clk => i_CLOCK_50,
			n_wr => n_interface2CS or cpuClock or n_WR,
			n_rd => n_interface2CS or cpuClock or (not n_WR),
			n_int => n_int2,
			regSel => cpuAddress(0),
			dataIn => cpuDataOut,
			dataOut => interface2DataOut,
			rxClkEn  => serialEn,
			txClkEn => serialEn,			
			rxd => rxd1,
			txd => txd1,
			n_cts => cts1,
			n_rts => rts1
		);
	
	-- ____________________________________________________________________________________
	-- MEMORY READ/WRITE LOGIC
	n_memRD <= (not(cpuClock) nand n_WR) and vma;
	n_memWR <= (not(cpuClock) nand (not n_WR)) and vma;
	
	-- ____________________________________________________________________________________
	-- CHIP SELECTS
	-- Jumper Pin_85 selects whether UART or VDU are default
	n_RomCS 		<= '0' when cpuAddress(15 downto 14) = "11" else '1'; 													-- 4K at top of memory (repeats)
	n_interface1CS <= '0' when ((cpuAddress(15 downto 1) = "100000000000000" and serSelect = '1') or 
										 (cpuAddress(15 downto 1) = "100000000000001" and serSelect = '0')) else '1'; -- 2 bytes FFD0-FFD1
	n_interface2CS <= '0' when ((cpuAddress(15 downto 1) = "100000000000001" and serSelect = '1') or 
										 (cpuAddress(15 downto 1) = "100000000000000" and serSelect = '0')) else '1'; -- 2 bytes FFD2-FFD3
	
	-- ____________________________________________________________________________________
	-- BUS ISOLATION
	-- Order matters since SRAM overlaps I/O chip selects
	cpuDataIn <=
		interface1DataOut when n_interface1CS = '0' else
		interface2DataOut when n_interface2CS = '0' else
		romData when n_RomCS = '0' else
		x"FF";
	
	-- ____________________________________________________________________________________
	-- SYSTEM CLOCKS
process (i_CLOCK_50)
	begin
		if rising_edge(i_CLOCK_50) then
			if cpuCount < 4 then -- 4 = 10MHz, 3 = 12.5MHz, 2=16.6MHz, 1=25MHz
				cpuCount <= cpuCount + 4;
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
