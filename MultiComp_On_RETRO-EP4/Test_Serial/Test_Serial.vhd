library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

entity Test_Serial is
	Port (
	PB : in STD_LOGIC;
	CLK_IN: in STD_LOGIC;
	LED1 : out STD_LOGIC;
	LED2 : out STD_LOGIC;
	LED3 : out STD_LOGIC;
	LED4 : out STD_LOGIC;
	FPGA_RX	: in STD_LOGIC;
	FPGA_TX	: out STD_LOGIC
	);
end Test_Serial;

architecture Behavioral of Test_Serial is

	signal counterOut	: std_logic_vector(27 downto 0);
--	signal serial : std_logic;

begin

myCounter : entity work.counter
port map(
	clock => CLK_IN,
	clear => '0',
	count => '1',
	Q => counterOut
	);

	FPGA_TX <= FPGA_RX;
	
	LED4 <= counterOut(26);
	LED3 <= counterOut(25);
	LED2 <= counterOut(24);
	LED1 <= counterOut(23);
	
end behavioral;
