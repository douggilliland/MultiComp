--	---------------------------------------------------------------------------------------------------------
-- Simple IOP16B CPU Example Code
--		Run software that reads the pushbutton and writes to LED on the FPGA card.
--	
-- IOP16 CPU
--		Custom 16 bit I/O Processor
--		Minimal Intruction set (enough for basic I/O)
--		8 Clocks per instruction at 50 MHz = 6.25 MIPS
--
-- IOP16 MEMORY mAP
--		0X00 - KEY1 Pushbutton (R)
--		0X00 - User LED (W)
--	---------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

entity TestIOP16B is
	port
	(
		-- Clock and reset
		i_clk							: in std_logic := '1';		-- Clock (50 MHz)
		i_n_reset					: in std_logic := '1';
		-- The key and LED on the FPGA card - helpful for debugging
		i_key1						: in std_logic := '1';		-- KEY1 on the FPGA card
		o_UsrLed						: out std_logic := '1'		-- USR LED on the FPGA card
	);
	end TestIOP16B;

architecture struct of TestIOP16B is
	-- 
	signal w_resetClean_n		:	std_logic;								-- De-bounced reset button
	
	--  IOP16 Peripheral bus
	signal w_periphAdr			:	std_logic_vector(7 downto 0);
	signal w_periphIn				:	std_logic_vector(7 downto 0);
	signal w_periphOut			:	std_logic_vector(7 downto 0);
	signal w_periphWr				:	std_logic;
	signal w_periphRd				:	std_logic;
	
	-- Decodes/Strobes
	signal w_wrLED					:	std_logic;		-- Write strobe - LED
	
	-- Serial clock enable
   signal serialEn      		: std_logic;		-- 16x baud rate clock

	-- Signal Tap Logic Analyzer signals
--	attribute syn_keep	: boolean;
--	attribute syn_keep of W_kbcs			: signal is true;
--	attribute syn_keep of w_periphIn			: signal is true;
--	attribute syn_keep of w_periphWr			: signal is true;
--	attribute syn_keep of w_periphRd			: signal is true;
	
begin

	-- Debounce/sync reset FPGA KEY0 pushbutton to 50 MHz FPGA clock
	debounceReset : entity work.Debouncer
		port map
		(
			i_clk				=> i_clk,
			i_PinIn			=> i_n_reset,
			o_PinOut			=> w_resetClean_n
		);

	-- Peripheral bus read mux
	w_periphIn <=	"0000000"&i_key1	when (w_periphAdr=x"00")	else
						x"00";

	-- Strobes/Selects
	w_wrLED	<= '1' when ((w_periphAdr=x"00") and (w_periphWr = '1')) else '0';

	-- Latch up the LED bit
	latchLEDOut : PROCESS (i_clk)
	BEGIN
		IF rising_edge(i_clk) THEN
			if w_wrLED = '1' then
				o_UsrLed <= w_periphOut(0);
			END IF;
		END IF;
	END PROCESS;
	
	-- I/O Processor
	-- Set ROM size in generic INST_SRAM_SIZE_PASS (512W uses 1 of 1K Blocks in EP4CE15 FPGA)
	-- Set stack size in STACK_DEPTH generic
	IOP16: ENTITY work.IOP16
	-- Need to pass down instruction RAM and stack sizes
		generic map 	( 
			INST_SRAM_SIZE_PASS	=> 512,	-- Small code size since program is "simple"
			STACK_DEPTH_PASS		=> 1		-- Single level subroutine (not nested)
		)
		PORT map
		(
			i_clk					=> i_clk,
			i_resetN				=> w_resetClean_n,
			-- Peripheral bus signals
			i_periphDataIn		=> w_periphIn,
			o_periphWr			=> w_periphWr,
			o_periphRd			=> w_periphRd,
			o_periphDataOut	=> w_periphOut,
			o_periphAdr			=> w_periphAdr
		);

end;
