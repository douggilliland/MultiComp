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
		-- 32 outs, 32 ins
		i_frontPanelData			: in std_logic_vector(31 downto 0) := x"deadbaba";
		o_frontPanelData			: out std_logic_vector(31 downto 0);
		-- External I2C connections
		io_I2C_SCL					: inout std_logic := '1';
		io_I2C_SDA					: inout std_logic := '1';
		io_I2C_INT					: in std_logic := '1'
	);
	end FrontPanel01;

architecture struct of FrontPanel01 is

	-- 
	signal w_i_ADRSEL		 		:	std_logic := '0';
	signal i_DATA_IN	 			:	std_logic_vector(7 downto 0);
	signal o_DATA_OUT	 			:	std_logic_vector(7 downto 0);
	signal w_i2cWr1Rd0			:	std_logic := '0';
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
	signal w_lowCount				: std_logic_vector(2 downto 0);
	signal w_stateVector			: std_logic_vector(13 downto 0);
	
	attribute syn_keep: boolean;
	attribute syn_keep of w_lowCount			: signal is true;
	attribute syn_keep of w_stateVector		: signal is true;

begin

	w_stateVector <= w_initState&w_highCount&w_midCount&w_lowCount;

--	-- External I2c Interface
	i2cIF	: entity work.i2c
	port map (
		i_RESET			=> not n_reset,		-- Reset pushbutton switch
		CPU_CLK			=> i_CLOCK_50,			-- 50 MHz
		i_ENA				=> w_i2c_400KHz,		-- One CPU clock wide every 400 Khz
		i_ADRSEL			=> w_i_ADRSEL,			-- Command/Data address select line
		i_DATA_IN		=> i_DATA_IN,			-- Data to I2C interface
		o_DATA_OUT		=> o_DATA_OUT,			-- Data from I2C interface
		i_WR				=> w_i2cWr1Rd0,		-- Write str
		io_I2C_SCL		=> io_I2C_SCL,			-- Clock to external I2C interface
		io_I2C_SDA		=> io_I2C_SDA			-- Data to/from external I2C interface
	);
	
	-- ____________________________________________________________________________________
	-- I2C Write Data multiplexer
	i_DATA_IN <=
		i_frontPanelData(31 downto 24)	when w_strLEDDataUU = '1'	else
		i_frontPanelData(23 downto 16)	when w_strLEDDataUM = '1'	else
		i_frontPanelData(15 downto 8)		when w_strLEDDataLM = '1'	else
		i_frontPanelData(7 downto 0)		when w_strLEDDataLL = '1'	else
		x"40"										when w_wrI2C2_20	 = '1'	else
		x"42"										when w_wrI2C2_21	 = '1'	else
		x"44"										when w_wrI2C2_22	 = '1'	else
		x"46"										when w_wrI2C2_23	 = '1'	else
		x"41"										when w_rdI2C2_20	 = '1'	else
		x"43"										when w_rdI2C2_21	 = '1'	else
		x"45"										when w_rdI2C2_22	 = '1'	else
		x"47"										when w_rdI2C2_23	 = '1'	else
		x"00"										when w_zeros		 = '1'	else
		x"ff"										when w_allOnes		 = '1'	else
		x"01"										when w_oneVal		 = '1'	else
		x"03"										when w_three		 = '1'	else
		x"00";
	
	-- Lower bits are grey code for glitch-free decoding
	-- Low 3 bits control the low level interface (strobes) to the I2C interface
	greyLow : ENTITY work.GrayCounter
	generic map
	(
		N => 3
	)
	PORT map
	(
		Clk		=> i_CLOCK_50,
		Rst		=> not n_reset,
		En			=> '1',
		output	=> w_lowCount
	);

	 -- Count states
	process (i_CLOCK_50)
	begin
		if rising_edge(i_CLOCK_50) then
			if n_reset = '0' then
				w_midCount	<= "0000";
				w_highCount	<= "000000";
				w_initState	<= '1';
			end if;
			if w_lowCount = "100" then
				w_midCount <= w_midCount +1;
				if w_midCount = "1111" then
					if ((w_highCount = "111111") and (w_initState = '1')) then
						w_initState	<= '0';
						w_highCount <= "000000";
					elsif ((w_highCount = "001111") and (w_initState = '0')) then
						w_highCount <= "000000";
					else
						w_highCount <= w_highCount + 1;
					end if;
				end if;
			end if;
		end if;
	end process;

	-- Put the pushbutton 8-bot vlues to o_frontPanelData 
	process (i_CLOCK_50)
	begin
		if rising_edge(i_CLOCK_50) then
			if w_strPbDataUU = '1' then
				o_frontPanelData(31 downto 24) <= o_DATA_OUT;
			end if;
			if w_strPbDataUM = '1' then
				o_frontPanelData(23 downto 16) <= o_DATA_OUT;
			end if;
			if w_strPbDataLM = '1' then
				o_frontPanelData(15 downto 8) <= o_DATA_OUT;
			end if;
			if w_strPbDataLL = '1' then
				o_frontPanelData(7 downto 00) <= o_DATA_OUT;
			end if;
		end if;
	end process;
	

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
