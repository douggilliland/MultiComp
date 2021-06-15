-- Debouncer32
-- Active low input produces a single clock wide low pulse

library ieee;
use ieee.std_logic_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

entity Debouncer32 is
	port(
		i_slowClk		: in std_logic := '1';
		i_fastClk		: in std_logic := '1';
		i_PinsIn			: in std_logic_vector(31 downto 0);
		o_PinsOut		: out std_logic_vector(31 downto 0)
	);

end Debouncer32;

architecture struct of Debouncer32 is
	
	signal dig_counter	: std_logic_vector (5 downto 0) := (others => '0');
	signal termCount		: std_logic;
	
	signal w_pbPressed	: std_logic;

	signal dly1		: std_logic;
	signal dly2		: std_logic;
	signal dly3		: std_logic;

begin

	w_pbPressed <= i_PinsIn(31) or i_PinsIn(30) or i_PinsIn(29) or i_PinsIn(28) or i_PinsIn(27) or i_PinsIn(26) or i_PinsIn(25) or i_PinsIn(24) or 
						i_PinsIn(23) or i_PinsIn(22) or i_PinsIn(21) or i_PinsIn(20) or i_PinsIn(19) or i_PinsIn(18) or i_PinsIn(17) or i_PinsIn(16) or 
						i_PinsIn(15) or i_PinsIn(14) or i_PinsIn(13) or i_PinsIn(12) or i_PinsIn(11) or i_PinsIn(10) or i_PinsIn(9)  or i_PinsIn(8) or 
						i_PinsIn(7)  or i_PinsIn(6)  or i_PinsIn(5)  or i_PinsIn(4)  or i_PinsIn(3)  or i_PinsIn(2)  or i_PinsIn(1)  or i_PinsIn(0);
	
	----------------------------------------------------------------------------
	-- 64 mS counter
	-- 2^6 = 64 counts
	-- Used for prescaling pushbuttons
	-- pulse200ms = single 20 nS clock pulse every 200 mSecs
	----------------------------------------------------------------------------
	process (i_slowClk, w_pbPressed) begin
		if rising_edge(i_slowClk) then
			if w_pbPressed = '0' then
				dig_counter <= (others => '0');
			elsif dig_counter = "111111" then
				termCount <= '1';
			else
				dig_counter <= dig_counter+1;
			end if;
		end if;
	end process;

	-- edge detect the debounce count
	process(i_fastClk)
	begin
		if(rising_edge(i_fastClk)) then
			dly1 <= termCount;
			dly2 <= dly1;
		end if;
	end process;
	
	dly3 <= dly1 and not dly2;
	
	o_PinsOut <= i_PinsIn	when dly3 = '1' else		-- set
					x"00000000"	when w_pbPressed = '0';

end;
