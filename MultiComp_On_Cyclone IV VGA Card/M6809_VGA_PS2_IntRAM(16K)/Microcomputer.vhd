-- Original file is copyright by Grant Searle 2014
-- Grant Searle's "multicomp" page at http://searle.hostei.com/grant/Multicomp/index.html
--
-- Changes to this code by Doug Gilliland 2019
--	16K (internal) RAM version
--

library ieee;
use ieee.std_logic_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

entity Microcomputer is
	port(
		n_reset		: in std_logic;
		clk			: in std_logic;

		videoR0		: out std_logic;
		videoR1		: out std_logic;
		videoR2		: out std_logic;
		videoR3		: out std_logic;
		videoR4		: out std_logic;
		videoG0		: out std_logic;
		videoG1		: out std_logic;
		videoG2		: out std_logic;
		videoG3		: out std_logic;
		videoG4		: out std_logic;
		videoG5		: out std_logic;
		videoB0		: out std_logic;
		videoB1		: out std_logic;
		videoB2		: out std_logic;
		videoB3		: out std_logic;
		videoB4		: out std_logic;
		hSync		: out std_logic;
		vSync		: out std_logic;

		ps2Clk		: inout std_logic;
		ps2Data		: inout std_logic
	);
end Microcomputer;

architecture struct of Microcomputer is

	signal n_WR							: std_logic;
	signal cpuAddress					: std_logic_vector(15 downto 0);
	signal cpuDataOut					: std_logic_vector(7 downto 0);
	signal cpuDataIn					: std_logic_vector(7 downto 0);

	signal basRomData					: std_logic_vector(7 downto 0);
	signal interface1DataOut		: std_logic_vector(7 downto 0);
	signal internalRam1DataOut		: std_logic_vector(7 downto 0);

	signal n_memWR						: std_logic :='1';
	signal n_basRomCS					: std_logic :='1';
	signal n_videoInterfaceCS		: std_logic :='1';
	signal n_internalRamCS			: std_logic :='1';

	signal cpuClkCount				: std_logic_vector(5 downto 0); 
	signal cpuClock					: std_logic;

begin
	-- ____________________________________________________________________________________
	-- Card has 16 bits of RGB digital data
	-- Drive the least significant bits with 0's since Multi-Comp only has 6 bits of RGB digital data
	videoR0 <= '0';
	videoR1 <= '0';
	videoR2 <= '0';
	videoG0 <= '0';
	videoG1 <= '0';
	videoG2 <= '0';
	videoG3 <= '0'; 
	videoB0 <= '0';
	videoB1 <= '0';
	videoB2 <= '0';
	
	-- ____________________________________________________________________________________
	-- CPU CHOICE GOES HERE
	cpu1 : entity work.cpu09
		port map(
			clk => not(cpuClock),
			rst => not n_reset,
			rw => n_WR,
			addr => cpuAddress,
			data_in => cpuDataIn,
			data_out => cpuDataOut,
			halt => '0',
			hold => '0',
			irq => '0',
			firq => '0',
			nmi => '0'
		); 
	
	-- ____________________________________________________________________________________
	-- ROM GOES HERE	
	rom1 : entity work.M6809_EXT_BASIC_ROM -- 8KB BASIC
		port map(
			address => cpuAddress(12 downto 0),
			clock => clk,
			q => basRomData
		);
	
	-- ____________________________________________________________________________________
	-- RAM GOES HERE
	
 	ram1: entity work.InternalRam16K
		port map
		(
			address => cpuAddress(13 downto 0),
			clock => clk,
			data => cpuDataOut,
			wren => not(n_memWR or n_internalRamCS),
			q => internalRam1DataOut
		);
	
	-- ____________________________________________________________________________________
	-- Display GOES HERE

	io1 : entity work.SBCTextDisplayRGB
		port map (
			n_reset => n_reset,
			clk => clk,
			
			-- RGB CompVideo signals
			hSync => hSync,
			vSync => vSync,
			videoR0 => videoR3,
			videoR1 => videoR4,
			videoG0 => videoG4,
			videoG1 => videoG5,
			videoB0 => videoB3,
			videoB1 => videoB4,
			
			n_wr => n_videoInterfaceCS or cpuClock or n_WR,
			n_rd => n_videoInterfaceCS or cpuClock or (not n_WR),
			regSel => cpuAddress(0),
			dataIn => cpuDataOut,
			dataOut => interface1DataOut,
			ps2Clk => ps2Clk,
			ps2Data => ps2Data
		);
	
	-- ____________________________________________________________________________________
	-- MEMORY READ/WRITE LOGIC GOES HERE
	n_memWR <= not(cpuClock) nand (not n_WR);
	
	-- ____________________________________________________________________________________
	-- CHIP SELECTS GO HERE
	n_basRomCS <= '0' when cpuAddress(15 downto 13) = "111" else '1'; --8K at top of memory
	n_videoInterfaceCS <= '0' when cpuAddress(15 downto 1) = "111111111101000" else '1'; -- 2 bytes FFD0-FFD1
	n_internalRamCS <= '0' when cpuAddress(15 downto 14) = "00" else '1';
	
	-- ____________________________________________________________________________________
	-- BUS ISOLATION GOES HERE
	-- Order matters since SRAM overlaps I/O chip selects
	cpuDataIn <=
	interface1DataOut when n_videoInterfaceCS = '0' else
	basRomData when n_basRomCS = '0' else
	internalRam1DataOut when n_internalRamCS= '0' else
	x"FF";
	
	-- ____________________________________________________________________________________
	-- SYSTEM CLOCKS GO HERE
	-- SUB-CIRCUIT CLOCK SIGNALS
process (clk)
begin
if rising_edge(clk) then

if cpuClkCount < 4 then -- 4 = 10MHz, 3 = 12.5MHz, 2=16.6MHz, 1=25MHz
cpuClkCount <= cpuClkCount + 1;
else
cpuClkCount <= (others=>'0');
end if;
if cpuClkCount < 2 then -- 2 when 10MHz, 2 when 12.5MHz, 2 when 16.6MHz, 1 when 25MHz
cpuClock <= '0';
else
cpuClock <= '1';
end if;

end if;
end process;
end;
