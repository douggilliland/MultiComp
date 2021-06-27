-- Debouncer
-- Active low input produces a single i_clk wide low pulse

library ieee;
use ieee.std_logic_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

entity Debouncer is
	port(
		i_clk				: in std_logic := '1';
		i_PinIn			: in std_logic := '1';
		o_PinOut			: out std_logic := '1'
	);

end Debouncer;

architecture struct of Debouncer is
	
	signal dig_counter	: std_logic_vector (19 downto 0) := (others => '0');
	signal pulse200ms		: std_logic;
	
	signal dly1		: std_logic;
	signal dly2		: std_logic;
	signal dly3		: std_logic;
	signal dly4		: std_logic;

begin

	----------------------------------------------------------------------------
	-- 50 mS counter
	-- 2^18 = 256,000, 50M/250K = 200 Hz = 50 mS ticks
	-- Used for prescaling pushbuttons
	-- pulse200ms = single 20 nS clock pulse every 200 mSecs
	----------------------------------------------------------------------------
	process (i_clk) begin
		if rising_edge(i_clk) then
			dig_counter <= dig_counter+1;
			if dig_counter(17 downto 0) = 0 then
				pulse200ms <= '1';
			else
				pulse200ms <= '0';
			end if;
			dly3 <= dly2;
			dly4 <= dly3;
			o_PinOut <= not(dly4 and (not dly3));
		end if;
	end process;

	process(i_clk, pulse200ms)
	begin
		if(rising_edge(i_clk)) then
			if pulse200ms = '1' then
				dly1 <= not i_PinIn;
				dly2 <= dly1;
			end if;
		end if;
	end process;

end;
