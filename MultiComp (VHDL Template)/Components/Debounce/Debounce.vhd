-- Debouncer

library ieee;
use ieee.std_logic_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

entity Debouncer is
	port(
		i_CLOCK_50					: in std_logic := '1';
		i_PinIn						: in std_logic := '1';
		o_PinOut						: out std_logic := '1'
	);

end Debouncer;

architecture struct of Debouncer is
	
signal	q_debounce					: std_logic_vector(5 downto 0) := "000000";

begin

	process (i_PinIn, i_CLOCK_50)
	begin
		if(rising_edge(i_CLOCK_50)) then
			q_debounce(0) <= i_PinIn;
			q_debounce(1) <= q_debounce(0);
			q_debounce(2) <= q_debounce(1);
			q_debounce(3) <= q_debounce(2);
			q_debounce(4) <= q_debounce(3);
			q_debounce(5) <= q_debounce(4);
			if (q_debounce(0) = '1') and (q_debounce(1) = '1') and (q_debounce(2) = '1') and (q_debounce(3) = '1') and (q_debounce(4) = '1') and (q_debounce(5) = '1') then
				o_PinOut <= '1';
			elsif (q_debounce(0) = '0') and 
				(q_debounce(1) = '0') and 
				(q_debounce(2) = '0') and 
				(q_debounce(3) = '0') and 
				(q_debounce(4) = '0') and 
				(q_debounce(5) = '0') then
				o_PinOut <= '0';
			end if;
		end if;
	end process;
end;
