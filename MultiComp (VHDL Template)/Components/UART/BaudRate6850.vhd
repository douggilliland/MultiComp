-- Baud Rate Generator for buffered UART
-- Assumes 50 MHz clock
-- Pass Baud Rate in BAUD_RATE generic as integer value (300, 9600, 115,200)

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use ieee.std_logic_unsigned.all;

ENTITY BaudRate6850 IS
	GENERIC (
		BAUD_RATE	: integer := 115200
	);
	PORT (
		i_CLOCK_50	: IN std_logic;
		o_serialEn	: OUT std_logic
	);
END BaudRate6850;

ARCHITECTURE BaudRate6850_beh OF BaudRate6850 IS

   signal serialCount   		: std_logic_vector(15 downto 0) := x"0000";
   signal serialCount_d			: std_logic_vector(15 downto 0);
   signal serialEn      		: std_logic;

BEGIN

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
	-- 1200 25
	-- 600 13
	-- 300 6
	
	BAUD_115200: if (BAUD_RATE=115200) generate
		begin	
		baud_div: process (serialCount_d, serialCount)
			 begin
				  serialCount_d <= serialCount + 2416;
			 end process;
	end generate BAUD_115200;
		 
	BAUD_9600: if (BAUD_RATE=9600) generate
		begin	
		baud_div: process (serialCount_d, serialCount)
			 begin
				  serialCount_d <= serialCount + 201;
			 end process;
	end generate BAUD_9600;
		 
	BAUD_300: if (BAUD_RATE=300) generate
		begin	
		baud_div: process (serialCount_d, serialCount)
			 begin
				  serialCount_d <= serialCount + 6;
			 end process;
	end generate BAUD_300;
		 
	process (i_CLOCK_50)
		begin
			if rising_edge(i_CLOCK_50) then
			  -- Enable for baud rate generator
			  serialCount <= serialCount_d;
			  if serialCount(15) = '0' and serialCount_d(15) = '1' then
					o_serialEn <= '1';
			  else
					o_serialEn <= '0';
			  end if;
			end if;
		end process;

END BaudRate6850_beh;
