--	---------------------------------------------------------------------------------------------------------
-- ANSI Terminal
-- IOP16 mEMORY mAP
-- 0X00 - UART (c/S) (r/w)
-- 0X01 - UART (Data) (r/w)
-- 0X02 - DISPLAY (c/S) (w)
-- 0X03 - DISPLAY (Data) (w)
-- 0X04 - KBD (c/S) (r)
-- 0X05 - KBD (Data) (r)

--	---------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

entity ANSITerm1 is
	port
	(
		-- Clock and reset
		i_CLOCK_50					: in std_logic := '1';		-- Clock (50 MHz)
		i_n_reset					: in std_logic := '1';		-- Reset from Pushbutton on FPGA card
		-- Test points for debug?
--		o_testPts					: out std_logic_vector(5 downto 0);
		urxd1							: in	std_logic := '1';
		utxd1							: out std_logic;
		ucts1							: in	std_logic := '1';
		urts1							: out std_logic;
		serSelect					: in	std_logic := '1';
		--
		o_videoR0					: out std_logic;
		o_videoR1					: out std_logic;
		o_videoG0					: out std_logic;
		o_videoG1					: out std_logic;
		o_videoB0					: out std_logic;
		o_videoB1					: out std_logic;
		o_hSync						: out std_logic;
		o_vSync						: out std_logic;
		--
		io_PS2_CLK					: inout std_logic;
		io_PS2_DAT					: inout std_logic;
		-- The key and LED on the FPGA card
		i_key1						: in std_logic := '1';		-- KEY1 on the FPGA card
		o_UsrLed						: out std_logic := '1'		-- USR LED on the FPGA card
	);
	end ANSITerm1;

architecture struct of ANSITerm1 is
	-- 
	signal w_resetClean_n		:	std_logic;								-- De-bounced reset button
	
	--  IOP16
	signal w_periphAdr			:	std_logic_vector(7 downto 0);
	signal w_periphIn				:	std_logic_vector(7 downto 0);
	signal w_periphOut			:	std_logic_vector(7 downto 0);
	signal w_periphWr				:	std_logic;
	signal w_periphRd				:	std_logic;
	
	-- Decodes
	signal w_wrUart				:	std_logic;
	signal w_rdUart				:	std_logic;
	signal w_UartDataOut			:	std_logic_vector(7 downto 0);
   signal serialCount   		: std_logic_vector(15 downto 0) := x"0000";
   signal serialCount_d			: std_logic_vector(15 downto 0);
   signal serialEn      		: std_logic;
	
	signal w_wrTerm				:	std_logic;
	signal w_rdTerm				:	std_logic;
	signal w_TermDataOut			:	std_logic_vector(7 downto 0);
	
	-- Keyboard
	signal W_kbcs					:	std_logic;
	signal w_latKBDData			:	std_logic_vector(7 downto 0);
	signal w_KbdData				:	std_logic_vector(7 downto 0);

	attribute syn_keep	: boolean;
	attribute syn_keep of W_kbcs			: signal is true;
	attribute syn_keep of w_periphIn			: signal is true;
	attribute syn_keep of w_periphWr			: signal is true;
	attribute syn_keep of w_periphRd			: signal is true;
	
begin

--	o_testPts(5) <= w_PBDelay(0);
--	o_testPts(4) <= w_debouncedPBs(0);
--	o_testPts(3) <= w_togglePinValues(0);
--	o_testPts(2) <= w_ldStrobe2;
--	o_testPts(1) <= w_loadStrobe;
--	o_testPts(0) <= '0';

	w_periphIn <=	w_UartDataOut		when (w_periphAdr(7 downto 1)="000"&x"0")	else
						w_TermDataOut		when (w_periphAdr(7 downto 1)="000"&x"1")	else
						w_KbdData			when (w_periphAdr(7 downto 1)="000"&x"2")	else
						x"00";
						
	w_wrUart		<= '1' when ((w_periphAdr(7 downto 1)="000"&x"0") and (w_periphWr = '1')) else '0';
	w_rdUart		<= '1' when ((w_periphAdr(7 downto 1)="000"&x"0") and (w_periphRd = '1')) else '0';
	
	w_wrTerm		<= '1' when ((w_periphAdr(7 downto 1)="000"&x"1") and (w_periphWr = '1')) else '0';
	w_rdTerm		<= '1' when ((w_periphAdr(7 downto 1)="000"&x"1") and (w_periphRd = '1')) else '0';

	W_kbcs		<= '1' when  (w_periphAdr(7 downto 1)="000"&x"2") else '0';
	
	-- Loopback values
	debounceReset : entity work.Debouncer
		port map
		(
			i_clk				=> i_CLOCK_50,
			i_PinIn			=> i_n_reset,
			o_PinOut			=> w_resetClean_n
		);

	-- I/O Processor
	IOP16: ENTITY work.IOP16
		PORT map
		(
			clk				=> i_CLOCK_50,
			resetN			=> w_resetClean_n,
			periphIn			=> w_periphIn,
			periphWr			=> w_periphWr,
			periphRd			=> w_periphRd,
			periphOut		=> w_periphOut,
			periphAdr		=> w_periphAdr
		);
	
	-- ANSI Display
	ANSIDisplay: entity work.ANSIDisplayVGA	
	--	generic(
	--		constant EXTENDED_CHARSET : integer := 1; -- 1 = 256 chars, 0 = 128 chars
	--		constant COLOUR_ATTS_ENABLED : integer := 1; -- 1=Colour for each character, 0=Colour applied to whole display
	--		-- VGA 640x480 Default values
	--		constant VERT_CHARS : integer := 25;
	--		constant HORIZ_CHARS : integer := 80;
	--		constant CLOCKS_PER_SCANLINE : integer := 1600; -- NTSC/PAL = 3200
	--		constant DISPLAY_TOP_SCANLINE : integer := 35+40;
	--		constant DISPLAY_LEFT_CLOCK : integer := 288; -- NTSC/PAL = 600+
	--		constant VERT_SCANLINES : integer := 525; -- NTSC=262, PAL=312
	--		constant VSYNC_SCANLINES : integer := 2; -- NTSC/PAL = 4
	--		constant HSYNC_CLOCKS : integer := 192;  -- NTSC/PAL = 235
	--		constant VERT_PIXEL_SCANLINES : integer := 2;
	--		constant CLOCKS_PER_PIXEL : integer := 2; -- min = 2
	--		constant H_SYNC_ACTIVE : std_logic := '0';
	--		constant V_SYNC_ACTIVE : std_logic := '0';
	--
	--		constant DEFAULT_ATT : std_logic_vector(7 downto 0) := "00001111"; -- background iBGR | foreground iBGR (i=intensity)
	--		constant ANSI_DEFAULT_ATT : std_logic_vector(7 downto 0) := "00000111"; -- background iBGR | foreground iBGR (i=intensity)
	--		constant SANS_SERIF_FONT : integer := 1 -- 0 => use conventional CGA font, 1 => use san serif font
	--	);
		port map (
			n_reset		=> w_resetClean_n,
			clk			=> i_CLOCK_50,
			n_wr			=> w_wrTerm,
			n_rd			=> w_rdTerm,
			regSel		=> w_periphAdr(0),
			dataIn		=> w_periphOut,
			dataOut		=> w_TermDataOut,
--			n_int			=> ,

			-- RGB video signals
			videoR0		=> o_videoR0,
			videoR1		=> o_videoR1,
			videoG0		=> o_videoG0,
			videoG1		=> o_videoG1,
			videoB0		=> o_videoB0,
			videoB1		=> o_videoB1,
--			o_hActive	=> ,
			hSync  		=> o_hSync,
			vSync  		=> o_vSync
	 );


	KEYBOARD : ENTITY  WORK.Wrap_Keyboard
		port MAP (
			i_CLOCK_50		=> i_CLOCK_50,
			i_n_reset		=> w_resetClean_n,
			i_kbCS			=> W_kbcs,
			i_RegSel			=> w_periphAdr(0),
			i_rd_Kbd			=> W_kbcs and w_periphRd,
			i_ps2_clk		=> io_PS2_CLK,
			i_ps2_data		=> io_PS2_DAT,
			o_kbdDat			=> w_KbdData
		);

	UART: entity work.bufferedUART
		port map (
			clk     			=> i_CLOCK_50,
			n_wr				=> not w_wrUart,
			n_rd    			=> not w_rdUart,
			regSel  			=> w_periphAdr(0),
			dataIn  			=> w_periphOut,
			dataOut 			=> w_UartDataOut,
	--		n_int   			=> ,
						 -- these clock enables are asserted for one period of input clk,
						 -- at 16x the baud rate.
			rxClkEn 			=> serialEn,
			txClkEn 			=> serialEn,
			rxd     			=> urxd1,
			txd     			=> utxd1,
			n_rts   			=> urts1,
			n_cts   			=> ucts1
   );

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
