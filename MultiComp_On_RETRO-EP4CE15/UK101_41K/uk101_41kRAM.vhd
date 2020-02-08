-- OSI C1P (UK101)
-- 6502 CPU
--		1 MHz
--	XGA
--		Memory Mapped
--		64x32 characters
--		Blue background, white characters
-- External SRAM
--		40KB
--	USB-Serial
--		FT230XS FTDI
--		Hardware Handshake
--	I/O connections
--		N/A
--	SDRAM - Not used, pins reserved
--	SD Card  - Not used, pins reserved

library ieee;
use ieee.std_logic_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

entity uk101 is
	port(
		clk			: in std_logic;
		n_reset		: in std_logic := '1';
		
		sramData 	: inout	std_logic_vector(7 downto 0);
		sramAddress : out		std_logic_vector(19 downto 0);
		n_sRamWE 	: out		std_logic := '0';
		n_sRamCS 	: out		std_logic := '0';
		n_sRamOE 	: out		std_logic := '0';
		
		fpgaRx		: in		std_logic := '1';
		fpgaTx		: out		std_logic;
		fpgaCts		: in		std_logic := '1';
		fpgaRts		: out 	std_logic;
		
		vgaRedHi		: out		std_logic := '0';
		vgaRedLo		: out		std_logic := '0';
		vgaGrnHi		: out		std_logic := '0';
		vgaGrnLo		: out		std_logic := '0';
		vgaBluHi		: out		std_logic := '0';
		vgaBluLo		: out		std_logic := '0';
		vgaHsync		: out		std_logic := '0';
		vgaVsync		: out		std_logic := '0';
		
		-- Not using the SD RAM but reserving pins and making inactive
		n_sdRamCas	: out		std_logic := '1';		-- CAS on schematic
		n_sdRamRas	: out		std_logic := '1';		-- RAS
		n_sdRamWe	: out		std_logic := '1';		-- SDWE
		n_sdRamCe	: out		std_logic := '1';		-- SD_NCS0
		sdRamClk		: out		std_logic := '1';		-- SDCLK0
		sdRamClkEn	: out		std_logic := '1';		-- SDCKE0
		sdRamAddr	: out		std_logic_vector(14 downto 0) := "000"&x"000";
		sdRamData	: in		std_logic_vector(15 downto 0);
		
		-- Not using the SD Card but reserving pins and making inactive
		sdCS			: out		std_logic :='1';
		sdMOSI		: out		std_logic :='0';
		sdMISO		: in		std_logic;
		sdSCLK		: out		std_logic :='0';
		driveLED		: out		std_logic :='1';

		-- Keyboard
		ps2Clk		: in		std_logic := '1';
		ps2Data		: in		std_logic := '1'
	);
end uk101;

architecture struct of uk101 is

	signal n_WR					: std_logic := '0';
	signal cpuAddress			: std_logic_vector(15 downto 0);
	signal cpuDataOut			: std_logic_vector(7 downto 0);
	signal cpuDataIn			: std_logic_vector(7 downto 0);

	signal basRomData			: std_logic_vector(7 downto 0);
	signal ramDataOut			: std_logic_vector(7 downto 0);
	signal monitorRomData 	: std_logic_vector(7 downto 0);
	signal aciaData			: std_logic_vector(7 downto 0);

	signal n_memWR				: std_logic := '1';
	signal n_memRD 			: std_logic := '1';

	signal n_dispRamCS		: std_logic :='1';
	signal n_ramCS				: std_logic :='1';
	signal n_basRomCS			: std_logic :='1';
	signal n_monitorRomCS 	: std_logic :='1';
	signal n_aciaCS			: std_logic :='1';
	signal n_kbCS				: std_logic :='1';
	signal n_J6IOCS			: std_logic :='1';
	signal n_J8IOCS			: std_logic :='1';
	signal n_LEDCS				: std_logic :='1';
		
	signal Video_Clk_25p6	: std_ulogic;
	signal VoutVect			: std_logic_vector(2 downto 0);

	signal dispAddrB 			: std_logic_vector(9 downto 0);
	signal dispRamDataOutA 	: std_logic_vector(7 downto 0);
	signal dispRamDataOutB 	: std_logic_vector(7 downto 0);
	signal charAddr 			: std_logic_vector(10 downto 0);
	signal charData 			: std_logic_vector(7 downto 0);

	signal serialClkCount	: std_logic_vector(14 downto 0); 
	signal cpuClkCount		: std_logic_vector(5 downto 0); 
	signal cpuClock			: std_logic;
	signal serialClock		: std_logic;

	signal kbReadData 		: std_logic_vector(7 downto 0);
	signal kbRowSel 			: std_logic_vector(7 downto 0);

begin

	-- External SRAM
	sramAddress(15 downto 0)	<= cpuAddress(15 downto 0);
	sramAddress(19 downto 16)	<= "0000";
	sramData <= cpuDataOut when n_WR='0' else (others => 'Z');
	n_sRamWE <= n_memWR;
	n_sRamOE <= n_memRD;
	n_sRamCS <= n_ramCS;
	n_memRD <= not(cpuClock) nand n_WR;
	n_memWR <= not(cpuClock) nand (not n_WR);
	
	-- Chip Selects
	n_ramCS 			<= '0' when ((cpuAddress(15) = '0') or 											-- x0000-x7fff (32KB)	- External SRAM
										(cpuAddress(15 downto 13) 	= "100")) 				else '1';  	-- x8000-x9FFF (8KB)		- External SRAM
	n_basRomCS 		<= '0' when cpuAddress(15 downto 13) 	= "101" 					else '1'; 	-- xa000-xbFFF (8k)		- BASIC ROM
	n_dispRamCS 	<= '0' when cpuAddress(15 downto 11) 	= "11010" 				else '1';	-- xb000-xb7ff (2KB)		- Display RAM
	n_kbCS 			<= '0' when cpuAddress(15 downto 10) 	= "110111" 				else '1';	-- xbc00-0bfff (1KB)		- Keyboard
	n_aciaCS 		<= '0' when cpuAddress(15 downto 1) 	= "111100000000000" 	else '1';	-- xf000-f001 (2B)		- Serial Port
	n_monitorRomCS <= '0' when cpuAddress(15 downto 11) 	= "11111" 				else '1'; 	-- xf800-xffff (2K)		- Monitor in ROM
	
	-- Data buffer
	cpuDataIn <=
		basRomData when n_basRomCS = '0' else
		monitorRomData when n_monitorRomCS = '0' else
		aciaData when n_aciaCS = '0' else
		dispRamDataOutA when n_dispRamCS = '0' else
		kbReadData when n_kbCS='0' else
		sramData when n_ramCS = '0' else 
		x"FF";

	-- 6502 CPU
	u1 : entity work.T65
	port map(
		Enable => '1',
		Mode => "00",
		Res_n => n_reset,
		Clk => cpuClock,
		Rdy => '1',
		Abort_n => '1',
		IRQ_n => '1',
		NMI_n => '1',
		SO_n => '1',
		R_W_n => n_WR,
		A(15 downto 0) => cpuAddress,
		DI => cpuDataIn,
		DO => cpuDataOut);

	-- BASIC ROM
	u2 : entity work.BasicRom -- 8KB
	port map(
		address => cpuAddress(12 downto 0),
		clock => clk,
		q => basRomData
	);
	
	-- CEGMON ROM with display patches
	u4: entity work.CegmonRom_Patched_64x32
	port map
	(
		address => cpuAddress(10 downto 0),
		q => monitorRomData
	);

	-- UART
	u5: entity work.bufferedUART
	port map(
		n_wr => n_aciaCS or cpuClock or n_WR,
		n_rd => n_aciaCS or cpuClock or (not n_WR),
		regSel => cpuAddress(0),
		dataIn => cpuDataOut,
		dataOut => aciaData,
		rxClock => serialClock,
		txClock => serialClock,
		rxd => fpgaRx,
		txd => fpgaTx,
		n_cts => fpgaCts,
		n_dcd => '0',
		n_rts => fpgaRts
	);

	-- Baud rate clock 
	process (clk)
	begin
		if rising_edge(clk) then
			if cpuClkCount < 50 then
				cpuClkCount <= cpuClkCount + 1;
			else
				cpuClkCount <= (others=>'0');
			end if;
			if cpuClkCount < 25 then
				cpuClock <= '0';
			else
				cpuClock <= '1';
			end if;	
			
--			if serialClkCount < 10416 then -- 300 baud
			if serialClkCount < 325 then -- 9600 baud
				serialClkCount <= serialClkCount + 1;
			else
				serialClkCount <= (others => '0');
			end if;
--			if serialClkCount < 5208 then -- 300 baud
			if serialClkCount < 162 then -- 9600 baud
				serialClock <= '0';
			else
				serialClock <= '1';
			end if;	
		end if;
	end process;

	pll : work.VideoClk_XVGA_1024x768 PORT MAP (
		inclk0	 => clk,
		c0	 => Video_Clk_25p6		-- 25.600000
	);
	
	-- VGA has blue background and white characters
	vgaRedHi	<= VoutVect(2);	-- red upper bit
	vgaRedLo	<= VoutVect(2);
	vgaGrnHi	<= VoutVect(1);
	vgaGrnLo	<= VoutVect(1);
	vgaBluHi	<= VoutVect(0);
	vgaBluLo	<= VoutVect(0);
		
	vga : entity work.Mem_Mapped_XVGA
	port map (
		n_reset		=> n_reset,
		Video_Clk 	=> Video_Clk_25p6,
		CLK_50		=> clk,
		n_dispRamCS	=> n_dispRamCS,
		n_memWR		=> n_memWR,
		cpuAddress	=> cpuAddress(10 downto 0),
		cpuDataOut	=> cpuDataOut,
		dataOut		=> dispRamDataOutA,
		VoutVect		=> VoutVect,
		hSync			=> vgaHsync,
		vSync			=> vgaVsync
	);

	-- UK101 keyboard
	u9 : entity work.UK101keyboard
	port map(
		CLK		=> clk,
		nRESET	=> n_reset,
		PS2_CLK	=> ps2Clk,
		PS2_DATA	=> ps2Data,
		A			=> kbRowSel,
		KEYB		=> kbReadData
	);
	
	process (n_kbCS,n_memWR)
	begin
		if	n_kbCS='0' and n_memWR = '0' then
			kbRowSel <= cpuDataOut;
		end if;
	end process;
	
end;
