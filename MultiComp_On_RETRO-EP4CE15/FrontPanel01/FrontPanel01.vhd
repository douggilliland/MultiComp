--	---------------------------------------------------------------------------------------------------------
-- Front Panel
-- I2C to Front Panel
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

entity FrontPanel01 is
	port
	(
		-- Clock and reset
		i_CLOCK_50					: in std_logic := '1';
		n_reset						: in std_logic := '1';
		-- 32 LEDs(outs), 32 Pushbuttons (ins)
		i_FPPushbuttons			: in std_logic_vector(31 downto 0) := x"deadbaba";
		o_FPLEDs				: out std_logic_vector(31 downto 0);
		-- Test
--		o_stateCounter				: out std_logic_vector(13 downto 0);
		-- External I2C connections
		io_I2C_SCL					: inout std_logic := '1';
		io_I2C_SDA					: inout std_logic := '1';
		io_I2C_INT					: in std_logic := '1'
	);
	end FrontPanel01;

architecture struct of FrontPanel01 is
	-- 
	signal w_i_ADRSEL		 		:	std_logic := '0';
	signal w_DATA_IN	 			:	std_logic_vector(7 downto 0);
	signal w_DATA_OUT	 			:	std_logic_vector(7 downto 0);
	signal w_I2C_RD_DATA 			:	std_logic_vector(7 downto 0);
	signal w_periphAdr 			:	std_logic_vector(7 downto 0);
	signal w_I2CWR			:	std_logic := '0';
	signal w_periphWr				:	std_logic := '0';
	signal w_periphRd				:	std_logic := '0';
	-- I2C Counter = 400 KHz
	signal w_i2cCount				: std_logic_vector(6 downto 0);
	signal w_i2c_400KHz			: std_logic;
	-- Strobe Pushbutton latch
	signal w_strPbDataUU			: std_logic;
	signal w_strPbDataUM			: std_logic;
	signal w_strPbDataLM			: std_logic;
	signal w_strPbDataLL			: std_logic;
	-- Strobe LEDs
	signal w_strLEDDataUU		: std_logic;
	signal w_strLEDDataUM		: std_logic;
	signal w_strLEDDataLM		: std_logic;
	signal w_strLEDDataLL		: std_logic;
	--
	signal w_wrI2C2_20			: std_logic;
	signal w_wrI2C2_21			: std_logic;
	signal w_wrI2C2_22			: std_logic;
	signal w_wrI2C2_23			: std_logic;
	--
	signal w_rdI2C2_20			: std_logic;
	signal w_rdI2C2_21			: std_logic;
	signal w_rdI2C2_22			: std_logic;
	signal w_rdI2C2_23			: std_logic;
	--
	signal w_zeros					: std_logic;
	signal w_allOnes				: std_logic;
	signal w_three					: std_logic;
	signal w_oneVal				: std_logic;
	-- State counters
	signal w_initState			: std_logic;
	signal w_highCount			: std_logic_vector(5 downto 0);
	signal w_midCount				: std_logic_vector(3 downto 0);
	-- Grey code counts 000 > 001 > 011 > 010 > 110 > 111 -> 101 > 100
	signal w_lowCount				: std_logic_vector(2 downto 0);
	signal w_stateVector			: std_logic_vector(13 downto 0);
	
	attribute syn_keep	: boolean;
	attribute syn_keep of w_lowCount			: signal is true;
	attribute syn_keep of w_stateVector		: signal is true;

begin

	-- w_stateVector <= w_initState&w_highCount&w_midCount&w_lowCount;
	
	-- o_stateCounter <= w_stateVector;
	
-	-- External I2c Interface
	i2cIF	: entity work.i2c
	port map (
		i_RESET			=> not n_reset,		-- Reset pushbutton switch
		CPU_CLK			=> i_CLOCK_50,			-- 50 MHz
		i_ENA				=> w_i2c_400KHz,		-- One CPU clock wide every 400 Khz
		i_ADRSEL			=> w_i_ADRSEL,			-- Command/Data address select line
		i_DATA_IN		=> w_DATA_OUT,			-- Data to I2C interface
		o_DATA_OUT		=> w_I2C_RD_DATA,			-- Data from I2C interface
		i_WR				=> w_I2CWR,		-- Write str
		io_I2C_SCL		=> io_I2C_SCL,			-- Clock to external I2C interface
		io_I2C_SDA		=> io_I2C_SDA			-- Data to/from external I2C interface
	);
	
	w_i_ADRSEL <= w_periphAdr(0);
	
	-- I/O Processor
	-- Memory Map
	-- Address, R/W, Descr
	-- x00, R, Pushbuttons(31..24)
	-- x01, R, Pushbuttons(23..16)
	-- x02, R, Pushbuttons(15..8)
	-- x03, R, Pushbuttons(7..0)
	-- x04-x5, R, I2C I/F
	-- 	x04 - I2C
	-- 	x05 - I2C
	-- x00, W, LEDs(31..24)
	-- x01, W, LEDs(23..16)
	-- x02, W, LEDs(15..8)
	-- x03, W, LEDs(7..0)
	-- x04-x5, W, I2C I/F
	-- 	x04 - I2C
	-- 	x05 - I2C
	iop16 : ENTITY work.IOP16
	PORT map (
		clk			=> not n_reset,
		resetN		=> i_CLOCK_50,			-- 50 MHz
		periphAdr	=> w_periphAdr,
		periphIn		=> w_DATA_IN,
		periphWr		=> w_periphWr,
		periphRd		=> w_periphRd,
		periphOut	=> w_DATA_OUT
	);

	-- Write from the IOP16 to the LEDs
	process (i_CLOCK_50)
	begin
		if rising_edge(i_CLOCK_50) then
			if w_strPbDataUU = '1' then
				o_FPLEDs(31 downto 24) <= w_DATA_OUT;
			end if;
			if w_strPbDataUM = '1' then
				o_FPLEDs(23 downto 16) <= w_DATA_OUT;
			end if;
			if w_strPbDataLM = '1' then
				o_FPLEDs(15 downto 8) <= w_DATA_OUT;
			end if;
			if w_strPbDataLL = '1' then
				o_FPLEDs(7 downto 00) <= w_DATA_OUT;
			end if;
		end if;
	end process;
	
	-- Write data strobes
	w_strPbDataUU 	<= '1' when ((w_periphWr = '1') and (w_periphAdr = x"00") else '0';
	w_strPbDataUM 	<= '1' when ((w_periphWr = '1') and (w_periphAdr = x"01") else '0';
	w_strPbDataLM 	<= '1' when ((w_periphWr = '1') and (w_periphAdr = x"02") else '0';
	w_strPbDataLL 	<= '1' when ((w_periphWr = '1') and (w_periphAdr = x"03") else '0';
	w_I2CWR 	<= '1' when ((w_periphWr = '1') and (w_periphAdr(7 downto 1) = "0000100") else '0';

	-- Read data mux
	w_DATA_IN <= 	i_FPPushbuttons(31 downto 24) when (w_periphAdr = x"00") else
					i_FPPushbuttons(23 downto 16) when (w_periphAdr = x"01") else
					i_FPPushbuttons(15 downto 8) when (w_periphAdr = x"02") else
					i_FPPushbuttons(7 downto 0) when (w_periphAdr = x"03") else
					w_I2C_RD_DATA when  (w_periphAdr(7 downto 1) = "0000100") else
					x"00";
	
	-- 400 KHz I2C clock
	-- 50.0 MHz / 400 KHz = 125 clocks
	process (i_CLOCK_50)
	begin
		if rising_edge(i_CLOCK_50) then
			if w_i2cCount = "1111101" then
				w_i2cCount <= "0000000";
				w_i2c_400KHz <= '1';
			else
				w_i2cCount <= w_i2cCount + 1;
				w_i2c_400KHz <= '0';
			end if;
		end if;
	end process;

end;
