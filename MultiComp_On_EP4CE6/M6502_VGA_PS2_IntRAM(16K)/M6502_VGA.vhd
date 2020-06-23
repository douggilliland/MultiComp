-- Grant Searle's Multicomp as described here:
-- http://searle.x10host.com/Multicomp/index.html
-- 
-- http://land-boards.com/blwiki/index.php?title=A-C4E6_Cyclone_IV_FPGA_EP4CE6E22C8N_Development_Board
--
-- 6502 CPU
--	25 MHz
--	16 KB SRAM
--	Microsoft BASIC in ROM
--		15,781 bytes free
--	USB-Serial Interface
--		CH340G chip
--		Requires RTS/CTS rework for hardware handshake
-- ANSI Video Display Unit
--		16KB SRAM causes this to be limited to 128 characters
--		80x25 character display
--		1/1/1 - R/G/B output
-- PS/2 Keyboard
--		F1 key switches between VDU and Serial port
--			Default is VDU
--		F2 key switches baud rate between 300 and 115,200
--			Default is 115,200 baud
--	(10) LEDs
--	(3) Pushbutton Switches
--	(8) DIP Switch
--	Buzzer
--
-- Memory Map
--		x0000-x1FFF - 8KB BASIC in ROM
--		X2000-x9FFF - 32KB SRAM
--	I/O Map
--		x80-x81 (128-129 dec) - VDU or ACIA
--		x82-x83 (13- ACIA or VDU
--		x84 - (Read) Pushbuttons (d0-d2)
--		x84 - (Write) Buzzer Tone
--		x85 - DIP Switch
--		$88 (136 dec) - Seven Segment LEDs - upper 2 digits
--		$89 (137 dec) - Seven Segment LEDs - upper middle 2 digits
--		$8a (138 dec) - Seven Segment LEDs - lower middle 2 digits
--		$8b (139 dec) - Seven Segment LEDs - lower 2 digits


library ieee;
use ieee.std_logic_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

entity M6502_VGA is
	port(
		i_n_reset		: in std_logic;
		i_clk_50			: in std_logic;
		
		i_rxd			: in std_logic;
		o_txd			: out std_logic;
		i_n_cts			: in std_logic;
		o_n_rts			: out std_logic;
		
		o_vid_red		: out std_logic;
		o_vid_grn		: out std_logic;
		o_vid_blu		: out std_logic;
		o_vid_hSync		: out std_logic;
		o_vid_vSync		: out std_logic;
		
		i_switch		: in std_logic_vector(2 downto 0);

		o_LED1		: out std_logic;
		o_LED2		: out std_logic;
		o_LED3		: out std_logic;
		o_LED4		: out std_logic;

		o_BUZZER		: out std_logic;

		io_ps2Clk		: inout std_logic;
		io_ps2Data		: inout std_logic
	);
end M6502_VGA;

architecture struct of M6502_VGA is

	signal n_WR					: std_logic;
	signal n_RD					: std_logic;
	signal cpuAddress			: std_logic_vector(15 downto 0);
	signal cpuDataOut			: std_logic_vector(7 downto 0);
	signal cpuDataIn			: std_logic_vector(7 downto 0);
	
	signal counterOut			: std_logic_vector(27 downto 0);
	signal buzz					: std_logic;

	signal basRomData			: std_logic_vector(7 downto 0);
	signal W_VDUDataOut	: std_logic_vector(7 downto 0);
	signal aciaDataOut			: std_logic_vector(7 downto 0);
	signal ramDataOut			: std_logic_vector(7 downto 0);
	
	signal n_memWR				: std_logic;
	
	signal n_basRomCS					: std_logic :='1';
	signal n_VDUCS		: std_logic :='1';
	signal n_ramCS						: std_logic :='1';
	signal n_aciaCS					: std_logic :='1';
	signal n_IOCS						: std_logic :='1';
	signal n_IOCS_Write				: std_logic :='1';
	signal n_IOCS_Read 				: std_logic :='1';
	
	signal serialClkCount			: std_logic_vector(15 downto 0);
	signal serialClkCount_d       : std_logic_vector(15 downto 0);
	signal serialClkEn            : std_logic;
	signal serialClock				: std_logic;

	signal cpuClkCount				: std_logic_vector(5 downto 0); 
	signal cpuClock					: std_logic;
	
	signal latchedBits				: std_logic_vector(7 downto 0);
	signal switchesRead			 	: std_logic_vector(7 downto 0);
	signal fKey1						: std_logic;
	signal fKey2						: std_logic;
	signal funKeys						: std_logic_vector(12 downto 0);

	signal txdBuff						: std_logic;
	
	signal videoVec					: std_logic_vector(5 downto 0);

begin
	-- ____________________________________________________________________________________
	-- Card has 16 bits of RGB digital data
	o_vid_red <= videoVec(5) or videoVec(4);
	o_vid_grn <= videoVec(3) or videoVec(2);
	o_vid_blu <= videoVec(1) or videoVec(0);

	o_LED1 <= latchedBits(0);
	o_LED2 <= fKey1;
	o_LED3 <= txdBuff;
	o_LED4 <= i_rxd;
	o_txd <= txdBuff;
	
	switchesRead(7 downto 0) <= "00000" & i_switch(2) & i_switch(1) & i_switch(0);
	
	-- Chip Selects
	n_ramCS 		<= '0' when  cpuAddress(15 downto 14)="00" else '1';					-- x0000-x3FFF (16KB)
	n_basRomCS 	<= '0' when  cpuAddress(15 downto 13) = "111" else '1'; 		-- xA000-xBFFF (8KB)
	n_VDUCS 		<= '0' when ((cpuAddress(15 downto 1) = x"FFD"&"000" and fKey1 = '0') 
							or		 (cpuAddress(15 downto 1) = x"FFD"&"001" and fKey1 = '1')) 
							else '1';
	n_aciaCS 	<= '0' when ((cpuAddress(15 downto 1) = X"FFD"&"001" and fKey1 = '0') 
							or  (cpuAddress(15 downto 1) = X"FFD"&"000" and fKey1 = '1'))
							else '1';
	n_IOCS 		<= '0' when   cpuAddress(15 downto 0) = X"FFD4"  -- 1 byte FFD4 (65492 dec)
							else '1';
	--n_IOCS_Write	<= n_memWR or n_IOCS;
	n_IOCS_Read 	<= not n_memWR or n_IOCS;
	n_memWR 			<= not(cpuClock) nand (not n_WR);
 
	cpuDataIn <=
		W_VDUDataOut	when n_VDUCS 		= '0'	else
		aciaDataOut		when n_aciaCS 		= '0'	else
		switchesRead	when n_IOCS_Read	= '0'	else
		basRomData		when n_basRomCS	= '0' else
		ramDataOut 		when n_ramCS 		= '0'	else
		x"FF";
		
	cpu : entity work.T65
	port map(
		Enable			=> '1',
		Mode				=> "00",
		Res_n				=> i_n_reset,
		clk				=> cpuClock,
		Rdy				=> '1',
		Abort_n			=> '1',
		IRQ_n				=> '1',
		NMI_n				=> '1',
		SO_n				=> '1',
		R_W_n				=> n_WR,
		A(15 downto 0)	=> cpuAddress,
		DI 				=> cpuDataIn,
		DO 				=> cpuDataOut);
			

	rom : entity work.M6502_BASIC_ROM -- 8KB
	port map(
		address	=> cpuAddress(12 downto 0),
		clock		=> i_clk_50,
		q			=> basRomData
	);

	sram : entity work.InternalRam16K 
	port map
	(
		address	=> cpuAddress(13 downto 0),
		clock		=> i_clk_50,
		data		=> cpuDataOut,
		wren		=> not(n_memWR or n_ramCS),
		q			=> ramDataOut
	);

	UART : entity work.bufferedUART
		port map(
			clk		=> i_clk_50,
			n_wr		=> n_aciaCS or cpuClock or n_WR,
			n_rd		=> n_aciaCS or cpuClock or (not n_WR),
			regSel	=> cpuAddress(0),
			dataIn	=> cpuDataOut,
			dataOut	=> aciaDataOut,
			rxClkEn	=> serialClkEn,
			txClkEn	=> serialClkEn,
			rxd		=> i_rxd,
			txd		=> txdBuff,
			n_cts		=> i_n_cts,
			n_rts		=> o_n_rts,
			n_dcd		=> '0'
		);
	
	VDU : entity work.SBCTextDisplayRGB
	generic map ( 
		EXTENDED_CHARSET => 0
	)
		port map (
		n_reset => i_n_reset,
		clk => i_clk_50,

		-- RGB video signals
		hSync => o_vid_hSync,
		vSync => o_vid_vSync,
		videoR1 => videoVec(5),
		videoR0 => videoVec(4),
		videoG1 => videoVec(3),
		videoG0 => videoVec(2),
		videoB1 => videoVec(1),
		videoB0 => videoVec(0),

		n_wr => n_VDUCS or cpuClock or n_WR,
		n_rd => n_VDUCS or cpuClock or (not n_WR),
--		n_int => n_int1,
		regSel => cpuAddress(0),
		dataIn => cpuDataOut,
		dataOut => W_VDUDataOut,
		ps2Clk => io_ps2Clk,
		ps2Data => io_ps2Data,
		FNkeys => funKeys
	);

	FNKey1Toggle: entity work.Toggle_On_FN_Key	
		port map (		
			FNKey => funKeys(1),
			clock => i_clk_50,
			n_res => i_n_reset,
			latchFNKey => fKey1
		);	

	FNKey2Toggle: entity work.Toggle_On_FN_Key	
		port map (		
			FNKey => funKeys(2),
			clock => i_clk_50,
			n_res => i_n_reset,
			latchFNKey => fKey2
		);
		
	io3: entity work.OutLatch
		port map (
			dataIn8 => cpuDataOut,
			clock => i_clk_50,
			load => n_memWR or n_IOCS,
			clear => i_n_reset,
			latchOut => latchedBits
			);
	
	myCounter : entity work.counter
	port map(
		clock => i_clk_50,
		clear => '0',
		count => '1',
		Q => counterOut
		);

--	buzz <= latchedBits(4) and counterOut(16);
	o_BUZZER <= NOT (
		(latchedBits(4) and counterOut(13)) or 
		(latchedBits(5) and counterOut(14)) or 
		(latchedBits(6) and counterOut(15)) or 
		(latchedBits(7) and counterOut(16)));

-- SUB-CIRCUIT CLOCK SIGNALS 
	process (i_clk_50)
	begin
		if rising_edge(i_clk_50) then

			if cpuClkCount < 1 then -- 4 = 10MHz, 3 = 12.5MHz, 2=16.6MHz, 1=25MHz
				cpuClkCount <= cpuClkCount + 1;
			else
				cpuClkCount <= (others=>'0');
			end if;
			if cpuClkCount < 1 then -- 2 when 10MHz, 2 when 12.5MHz, 2 when 16.6MHz, 1 when 25MHz
				cpuClock <= '0';
			else
				cpuClock <= '1';
			end if; 
		end if; 
    end process;

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

	baud_div: process (serialClkCount_d, serialClkCount, fKey2)
		begin
			if fKey2 = '0' then
				serialClkCount_d <= serialClkCount + 2416;	-- 115,200 baud
			else
				serialClkCount_d <= serialClkCount + 6;		-- 300 baud
				end if;
		end process;

	--Single clock wide baud rate enable
	baud_clk: process(i_clk_50)
		begin
			if rising_edge(i_clk_50) then
					serialClkCount <= serialClkCount_d;
				if serialClkCount(15) = '0' and serialClkCount_d(15) = '1' then
					serialClkEn <= '1';
				else
					serialClkEn <= '0';
				end if;
       end if;
    end process;
	 
end;
