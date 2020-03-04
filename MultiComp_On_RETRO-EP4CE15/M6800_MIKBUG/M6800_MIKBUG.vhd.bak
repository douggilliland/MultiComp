-- Original file is copyright by Grant Searle 2014
-- Grant Searle's web site http://searle.hostei.com/grant/    
-- Grant Searle's "multicomp" page at http://searle.hostei.com/grant/Multicomp/index.html
--
-- MC6800 CPU running MIKBUG from back in the day
-- Changes to this code by Doug Gilliland 2020
--	32K (internal) RAM version
--
--

library ieee;
use ieee.std_logic_1164.all;
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
		
		-- SRAM not used
		io_extSRamData		: inout std_logic_vector(7 downto 0);
		io_extSRamAddress	: out std_logic_vector(19 downto 0);
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
		w_sdRamData			: in std_logic_vector(15 downto 0)
	);
end M6800_MIKBUG;

architecture struct of M6800_MIKBUG is

	signal w_resetLow		: std_logic := '1';

	signal w_cpuAddress	: std_logic_vector(15 downto 0);
	signal w_cpuDataOut	: std_logic_vector(7 downto 0);
	signal w_cpuDataIn	: std_logic_vector(7 downto 0);
	signal w_R1W0			: std_logic;
	signal w_vma			: std_logic;

	signal w_romData		: std_logic_vector(7 downto 0);
	signal w_ramData		: std_logic_vector(7 downto 0);
	signal w_if1DataOut	: std_logic_vector(7 downto 0);

	signal n_int1			: std_logic :='1';	
	signal n_if1CS			: std_logic :='1';

	signal q_cpuClkCount	: std_logic_vector(5 downto 0); 
	signal w_cpuClock		: std_logic;
	
begin

	-- Debounce the reset line
	DebounceResetSwitch	: entity work.Debouncer
	port map (
		i_CLOCK_50	=> i_CLOCK_50,
		i_PinIn		=> i_n_reset,
		o_PinOut		=> w_resetLow
	);
		
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
		port map(
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
		wren		=> (not w_R1W0) and (not w_cpuAddress(15)) and w_vma and (not w_cpuClock),
		q			=> w_ramData
	);
	
	-- ____________________________________________________________________________________
	-- CHIP SELECTS
	n_if1CS	<= '0' when (w_cpuAddress(15 downto 1) = x"801"&"100")	 	-- $8018-$8019
		else '1';
	
	-- ____________________________________________________________________________________
	-- INPUT/OUTPUT DEVICES
	-- Grant's VGA driver
	io1 : entity work.SBCTextDisplayRGB
		port map (
			n_reset	=> w_resetLow,
			clk		=> i_CLOCK_50,
			
			-- RGB Compo_video signals
			hSync		=> o_hSync,
			vSync		=> o_vSync,
			videoR0	=> o_videoR0,
			videoR1	=> o_videoR1,
			videoG0	=> o_videoG0,
			videoG1	=> o_videoG1,
			videoB0	=> o_videoB0,
			videoB1	=> o_videoB1,
			n_WR		=> n_if1CS or      w_R1W0  or (not w_vma) or (not w_cpuClock),
			n_rd		=> n_if1CS or (not w_R1W0) or (not w_vma),
			n_int		=> n_int1,
			regSel	=> w_cpuAddress(0),
			dataIn	=> w_cpuDataOut,
			dataOut	=> w_if1DataOut,
			ps2Clk	=> io_ps2Clk,
			ps2Data	=> io_ps2Data
		);
	
	-- ____________________________________________________________________________________
	-- CPU Read Data multiplexer
	w_cpuDataIn <=
		w_ramData		when w_cpuAddress(15) = '0'				else
		w_if1DataOut	when w_cpuAddress(15 downto 14) = "10"	else
		w_romData		when w_cpuAddress(15 downto 14) = "11"	else
		x"FF";
	
	-- ____________________________________________________________________________________
	-- CPU Clock
process (i_CLOCK_50)
	begin
		if rising_edge(i_CLOCK_50) then
			if q_cpuClkCount < 50 then
				q_cpuClkCount <= q_cpuClkCount + 1;
			else
				q_cpuClkCount <= (others=>'0');
			end if;
			if q_cpuClkCount < 25 then
				w_cpuClock <= '0';
			else
				w_cpuClock <= '1';
			end if;
		end if;
	end process;
	
end;