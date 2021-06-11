--	---------------------------------------------------------------------------------------------------------
-- Front Panel
-- I2C to Front Panel
--	Test code that loops back the pushbuttons to the LEDs
-- 
-- http://land-boards.com/blwiki/index.php?title=Front_Panel_For_8_Bit_Computers
-- Small controller for a Front Panel
-- 32 LEDs, 32 pushbuttons
--		16 - Address LEDS/pushbuttons
--		8  - Data LEDS/pushbuttons
--		8  - Status LEDs
--		8  - Control pusbuttons

-- R32V2020 assembly code example works with this same I2C controller
--		https://github.com/douggilliland/R32V2020/blob/master/Programs/Common/mcp23008.asm
--		https://github.com/douggilliland/R32V2020/blob/master/Programs/Common/i2c.asm
-- 
-- C code example I wrote for my 3 chip Z80 design (functionally similar, different i2c controller chips)
--		https://github.com/douggilliland/Retro-Computers/blob/master/Z80/PSOC/PSOC_Design_Files/Z80-PSoC-3-Chips_002/Z80_3Chip.cydsn/FrontPanel.c
--		https://github.com/douggilliland/Retro-Computers/blob/master/Z80/PSOC/PSOC_Design_Files/Z80-PSoC-3-Chips_002/Z80_3Chip.cydsn/FrontPanel.h
--	---------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

entity FrontPanel01_test is
	port
	(
		-- Clock and reset
		i_CLOCK_50					: in std_logic := '1';		-- Clock (50 MHz)
		i_n_reset					: in std_logic := '1';		-- Reset
		--
		i_key1						: in std_logic := '1';
		o_UsrLed						: out std_logic := '1';
		-- External I2C connections
		io_I2C_SCL					: inout std_logic := '1';	-- I2C clock to Front Panel card
		io_I2C_SDA					: inout std_logic := '1';	-- I2C data to/from Front Panel card
		i_I2C_INTn					: in std_logic := '1'		-- Interrupt input - active low
	);
	end FrontPanel01_test;

architecture struct of FrontPanel01_test is

	-- 
	signal i_DATA_LOOPBACK	 	:	std_logic_vector(31 downto 0);		-- wrap back Pushbuttons lines to LEDs
	signal w_resdebounced		:	std_logic;

begin

debouncePB : entity work.Debouncer
	port map
	(
		i_clk				=> i_CLOCK_50,
		i_PinIn			=> i_n_reset,
		o_PinOut			=> w_resdebounced
	);

-- Front Panel test
fp_test : work.FrontPanel01
	port map
	(
		-- Clock and reset
		i_CLOCK_50			=> i_CLOCK_50,				-- Clock (50 MHz)
		i_n_reset			=> w_resdebounced,			-- Reset
		-- 32 outs, 32 ins
		i_FPPushbuttons	=> i_DATA_LOOPBACK,		-- Pushbuttons (32)
		o_FPLEDs				=> i_DATA_LOOPBACK,		-- LEDs (32)
		--
		i_key1				=> i_key1,
		o_UsrLed				=> o_UsrLed,
		-- I2C interface
		io_I2C_SCL			=> io_I2C_SCL,				-- I2C clock to Front Panel card
		io_I2C_SDA			=> io_I2C_SDA,				-- I2C data to/from Front Panel card
		i_I2C_INTn			=> i_I2C_INTn				-- Interrupt input - active low
	);

end;
