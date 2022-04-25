-- -------------------------------------------------------------------------------------------
-- Original MultiComp design is copyright by Grant Searle 2014
-- Grant Searle's web site http://searle.hostei.com/grant/
-- Grant Searle's "multicomp" page at http://searle.hostei.com/grant/Multicomp/index.html
--	Grant did not have a 6800 ROM, so I picked a MIKBUG variant monitor as the ROM
--
-- Changes to this code by Doug Gilliland 2020-2022
--
-- MC6800 CPU
--		Runs at 25 NHz for internal SRAM and Peripherals
--	ROM - running MIKBUG from back in the day
--		SmithBug variant adds ACIA support and an S-record loader
--		https://github.com/douggilliland/MultiComp/tree/master/MultiComp%20(VHDL%20Template)/Components/ROMs/MIKBUG_6800/DGG_MIKBUG_60KB
--		Up to 60K (internal) RAM version  (this build has 40KB SRAM)
--		1KB RAM scratchpad for MIKBUG
-- J3 jumper selects either built-in VDU or Serial port
-- 	VDU - ANSI terminal (default)
--			XGA 80x25 character display
--			PS/2 keyboard
-- 	MC6850 ACIA UART
--	1MB External SRAM
--		MMU1, MMU2 Memory management register control window
--	
--	Front Panel
--		Wiki page
--			http://land-boards.com/blwiki/index.php?title=Front_Panel_for_8_Bit_Computers_V2
--		Monitors Address/Data when in Run mode
--		PB31 - RUN - (Upper left pushbutton) - Run/Halt (Upper left LED on for Run)
--		PB30 - RESET CPU
--		PB29 - STEP - Not yet implemented
--		PB28 - Not used
--		PB27 - CLEAR - Clears address if in Set Address Mode control mode
--		PB26 - INCADR - Increment address - Function depend on Enable Write Data and Set Address Mode controls
--			Ignored if Set Address is selected
--			If Enable Write Data is selected, Write data then Increment address
--			If Enable Write Data is not selectedrwise increment read address and read next location
--		PB25 - SETDAT - Enable Write Data control - Bottom row of pushbuttons controls write of data to memory
--		PB24 - SETADR - Set Address Mode control - Middle two rows of pushbuttons control LEDs
--	
--	Memory Map
--		0x0000-0x7FFF	- 32KB Internal SRAM
--		0x8000-0x9FFF	- 8KB Internal SRAM
--		0xA000-0xBFFF	- 512KB External SRAM
--			8KB Window, 64 frames
--			MMU1 provides additional address bits
--			MMU1 initialized to 0
--				Set to first frame allowing memory to appear as part of Tiny BASIC contiguous space
--		0xC000-0xDFFF	- 512KB External SRAM
--			8KB Window, 64 frames
--			MMU2 provides additional address bits
--			MMU2 initialized to 0
--				Set to first frame allowing memory to appear as part of Tiny BASIC contiguous space
--		0xE000-0xEBFF	- Deliberately left open to  
--		0XEC00-0xEFFF	- 1KB Internal SRAM (SCRATCHPAD SRAM USED BY MIKBUG)
--		0xFC18-0xFC19	- VDU (serSelect J3 JUMPER REMOVED)
--		0xFC28-0xFC19	- ACIA
--		0xFC30			- MMU1 Latch 7-bits
--		0xFC31			- MMU2 Latch 7-bits
--		0xF000-0xFFFF	- MIKBUG (Actually SMITHBUG) ROM
-- -------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

entity M6800_MIKBUG is
	port(
		i_n_reset			: in std_logic := '1';
		i_CLOCK_50			: in std_logic;

		-- Video
		o_videoR0			: out std_logic := '1';
		o_videoR1			: out std_logic := '1';
		o_videoG0			: out std_logic := '1';
		o_videoG1			: out std_logic := '1';
		o_videoB0			: out std_logic := '1';
		o_videoB1			: out std_logic := '1';
		o_hSync				: out std_logic := '1';
		o_vSync				: out std_logic := '1';

		-- PS/2
		io_ps2Clk			: inout std_logic := '1';
		io_ps2Data			: inout std_logic := '1';
		
		-- USB Serial (Referenced to the USB side)
		rxd1					: in	std_logic := '1';
		txd1					: out std_logic;
		cts1					: in	std_logic := '1';
		rts1					: out std_logic;
		serSelect			: in	std_logic := '1';
		
		-- I2C to Front Panel
		io_I2C_SCL			: inout	std_logic := '1';
		io_I2C_SDA			: inout	std_logic := '1';
		i_I2C_INTn			: in	std_logic := '1';
		
		-- SRAM not used but making sure that it's not active
		io_extSRamData		: inout std_logic_vector(7 downto 0) := (others=>'Z');
		io_extSRamAddress	: out std_logic_vector(19 downto 0) := x"00000";
		io_n_extSRamWE		: out std_logic := '1';
		io_n_extSRamCS		: out std_logic := '1';
		io_n_extSRamOE		: out std_logic := '1';

		-- Not using the SD RAM but making sure that it's not active
		n_sdRamCas			: out std_logic := '1';		-- CAS
		n_sdRamRas			: out std_logic := '1';		-- RAS
		n_sdRamWe			: out std_logic := '1';		-- SDWE
		n_sdRamCe			: out std_logic := '1';		-- SD_NCS0
		sdRamClk				: out std_logic := '1';		-- SDCLK0
		sdRamClkEn			: out std_logic := '1';		-- SDCKE0
		sdRamAddr			: out std_logic_vector(14 downto 0) := "000"&x"000";
		w_sdRamData			: in std_logic_vector(15 downto 0) := (others=>'Z')
	);
end M6800_MIKBUG;

architecture struct of M6800_MIKBUG is

	signal w_resetLow		: std_logic;								-- Reset from debouncer
	signal w_CPUResetHi	: std_logic;
	signal w_FPReset		: std_logic;								-- Front Panel IOP reset

	-- CPU signals
	signal w_cpuDataIn	: std_logic_vector(7 downto 0);		-- Data into the CPU
	signal w_R1W0B			: std_logic;								-- Read / Write from the CPU
	signal w_R1W0			: std_logic;								-- ead / Write to the Memory
	signal w_vma			: std_logic;								-- Valid Memory Address

	-- Front Panel intercepts
	signal w_cpuAddress	: std_logic_vector(15 downto 0);		-- Address from the Front Panel
	signal w_cpuAddressB	: std_logic_vector(15 downto 0);		-- Address out of the CPU
	signal w_cpuDataOut	: std_logic_vector(7 downto 0);		-- DAta to Memory / Peripherals
	signal w_cpuDataOutB	: std_logic_vector(7 downto 0);		-- Data out of the CPU
	signal w_run0Halt1	:	std_logic;								-- Run / Halt from the Front Panel (PB31)
	signal w_wrRamStr		:	std_logic;								-- Write Strobe to SRAM from  IOP
		
	-- Data busses
	signal w_romData		: std_logic_vector(7 downto 0);		-- Data from the ROM
	signal w_ramData		: std_logic_vector(7 downto 0);		-- Data from the 32KB SRAM
	signal w_ramData2		: std_logic_vector(7 downto 0);		-- Data from the 1KB scratchpad SRAM
	signal w_ramData3		: std_logic_vector(7 downto 0);		-- Data from the 8KB SRAM
	signal w_if1DataOut	: std_logic_vector(7 downto 0);		-- Data from the VDU
	signal w_if2DataOut	: std_logic_vector(7 downto 0);		-- Data from the ACIA
	signal w_MMUReg1		: std_logic_vector(7 downto 0);		-- MMU1
	signal w_MMUReg2		: std_logic_vector(7 downto 0);		-- MMU2

	-- Chip Selects
	signal n_if1CS			: std_logic :='1';						-- VDU Chip Select
	signal n_if2CS			: std_logic :='1';						-- ACIA Chip Select
	signal w_MMU1			:	std_logic;								-- Write MMU1
	signal w_MMU2			:	std_logic;								-- Write MMU2
	signal w_extSRAM		:	std_logic;								-- External SRAM

	-- CPU Clock block
	signal q_cpuClkCount	: std_logic_vector(5 downto 0); 		-- CPU speed counter
	signal w_cpuClock		: std_logic;								-- CPU Clock

   signal serialEn      : std_logic;								-- 16x Serial Clock

begin
	
	-- Debounce the reset line
	DebounceFPGAResetPB	: entity work.Debouncer
	port map (
		i_clk		=> w_cpuClock,
		i_PinIn	=> i_n_reset,
		o_PinOut	=> w_resetLow
	);
	
	-- Need CPU reset to be later than peripherals
	process (w_cpuClock)
		begin
			if rising_edge(w_cpuClock) then
				w_CPUResetHi <= ((not w_resetLow) or (not w_FPReset));
			end if;
		end process;
		
	-- ____________________________________________________________________________________
	-- Front Panel
	MIKBUG_FRPNL : entity work.MIKBUG_FRPNL
		port map
		(
		-- Clock and reset
		i_CLOCK_50			=> i_CLOCK_50,
		i_cpuClock			=> w_cpuClock,
		i_n_reset			=> w_resetLow,
		o_FPReset			=> w_FPReset,
		-- CPU intercepts
		-- Front Panel loops back signals when in Front Panel switch is in Run Mode
		i_CPUAddress		=> w_cpuAddressB,
		o_CPUAddress		=> w_cpuAddress,
		i_cpuData			=> w_cpuDataOutB,
		o_cpuData			=> w_cpuDataOut,
		i_CPURdData			=> w_cpuDataIn,
		io_run0Halt1		=> w_run0Halt1,
		o_wrRamStr			=> w_wrRamStr,
		i_R1W0				=> w_R1W0B,
		o_R1W0				=> w_R1W0,
		-- External I2C connections
		io_I2C_SCL			=> io_I2C_SCL,
		io_I2C_SDA			=> io_I2C_SDA,
		i_I2C_INTn			=> i_I2C_INTn
	);
	
	-- ____________________________________________________________________________________
	-- 6800 CPU
	cpu1 : entity work.cpu68
		port map(
			clk		=> w_cpuClock,
			rst		=> w_CPUResetHi,	-- resetD1 and not resetD2,
			rw			=> w_R1W0B,
			vma		=> w_vma,
			address	=> w_cpuAddressB,
			data_in	=> w_cpuDataIn,
			data_out	=> w_cpuDataOutB,
			hold		=> '0',
			halt		=> w_run0Halt1,
			irq		=> '0',
			nmi		=> '0'
		); 
	
	-- ____________________________________________________________________________________
	-- CPU Read Data multiplexer
	w_cpuDataIn <=
		io_extSRamData	when (w_extSRAM = '1')								else	-- External SRAM (0xA000-0xDFFF)
		w_ramData		when w_cpuAddress(15) = '0'						else	-- 32KB SRAM (0x0000-0x7FFF)
		w_ramData2		when w_cpuAddress(15 downto 10) = x"E"&"11"	else	-- 1KB SRAM (0xEC00-0xEFFF) 
		w_ramData3		when w_cpuAddress(15 downto 13) = "100"		else	-- 8KB SRAM (0x8000-0x9FFF) 
		w_if1DataOut	when n_if1CS = '0'									else	-- VDU
		w_if2DataOut	when n_if2CS = '0'									else	-- ACIA
		w_MMUReg1		when w_MMU1 = '1'										else	-- MMU1
		w_MMUReg2		when w_MMU2 = '1'										else	-- MMU2
		w_romData		when w_cpuAddress(15 downto 12) = x"F"			else	-- ROM
		x"DE";
	
	-- External SRAM
	-- 
	w_extSRAM <= 
		'1' when w_cpuAddress(15 downto 13) = "101" else								-- 0xA000-0xBFFF
		'1' when w_cpuAddress(15 downto 13) = "110" else								-- 0xC000-oxDFFF
		'0';
--	io_extSRamAddress(19) <= w_cpuAddress(15) and w_cpuAddress(14) and (not w_cpuAddress(13));	-- 0xC000-oxDFFF
	io_extSRamAddress(19) <=
		'0' when w_cpuAddress(15 downto 13) = "101" else
		'1';
	io_extSRamAddress(18 downto 13) <= 
		w_MMUReg1(5 downto 0) 	when w_cpuAddress(15 downto 13) = "101" else		-- 0xA000-0xBFFF
		w_MMUReg2(5 downto 0) 	when w_cpuAddress(15 downto 13) = "110" else		-- 0xC000-oxDFFF
		"000000";
	io_extSRamAddress(12 downto 0) <= w_cpuAddress(12 downto 0);
	io_extSRamData <= w_cpuDataOut when (w_R1W0 = '0') else (others => 'Z');
	io_n_extSRamWE <= not (w_extSRAM and w_vma and (not w_R1W0) and (not w_cpuClock));
	io_n_extSRamOE <= not w_R1W0;
	io_n_extSRamCS <= not(w_extSRAM and w_vma);

	-- ____________________________________________________________________________________
	-- I/O CHIP SELECTS
	n_if1CS	<= '0' 	when (serSelect = '1' and (w_cpuAddress(15 downto 1) = x"FC1"&"100")) else	-- VDU  $C018-$C019
					'0'	when (serSelect = '0' and (w_cpuAddress(15 downto 1) = x"FC2"&"100")) else	-- ACIA $C028-$C029
					'1';
	n_if2CS	<= '0' 	when (serSelect = '1' and (w_cpuAddress(15 downto 1) = x"FC2"&"100")) else	-- ACIA $C028-$C029
					'0'	when (serSelect = '0' and (w_cpuAddress(15 downto 1) = x"FC1"&"100")) else	-- VDU  $C018-$C019
					'1';
	w_MMU1 	<= '1'	when w_cpuAddress = x"FC30" else 														-- MMU1 $FC30
					'0';
	w_MMU2 	<= '1'	when w_cpuAddress = x"FC31" else 														-- MMU2 $FC31
					'0';

	-- ____________________________________________________________________________________
	-- MIKBUG ROM
	-- 4KB MIKBUG ROM
	rom1 : entity work.MIKBUG
		port map (
			address	=> w_cpuAddress(11 downto 0),
			clock 	=> i_CLOCK_50,
			q			=> w_romData
		);
		
	-- ____________________________________________________________________________________
	-- 32KB RAM	
	sram32kb : entity work.InternalRam32K
		PORT map  (
			address	=> w_cpuAddress(14 downto 0),
			clock 	=> i_CLOCK_50,
			data 		=> w_cpuDataOut,
			wren		=> (((not w_R1W0) and (not w_cpuAddress(15)) and w_vma and (not w_cpuClock) and (not w_run0Halt1))
							or (w_wrRamStr and w_run0Halt1 and (not w_cpuAddress(15)))),
			q			=> w_ramData
		);
	
	-- ____________________________________________________________________________________
	-- 8KB RAM
	sram8kb : entity work.InternalRam8K
		PORT map  (
			address	=> w_cpuAddress(12 downto 0),
			clock 	=> i_CLOCK_50,
			data 		=> w_cpuDataOut,
			wren		=> (((not w_R1W0) and w_cpuAddress(15) and (not w_cpuAddress(14)) and (not w_cpuAddress(13)) and w_vma and (not w_cpuClock) and (not w_run0Halt1))
							or (w_wrRamStr and w_run0Halt1 and w_cpuAddress(15) and (not w_cpuAddress(14)) and (not w_cpuAddress(13)))),
			q			=> w_ramData3
		);
	
	-- ____________________________________________________________________________________
	-- 1KB RAM SMITHBUG SCRATCHPAD
	sram1kb : entity work.InternalRam1K
		PORT map  (
			address	=> w_cpuAddress(9 downto 0),
			clock 	=> i_CLOCK_50,
			data 		=> w_cpuDataOut,
			wren		=> ((not w_R1W0) and w_cpuAddress(15) and w_cpuAddress(14) and w_cpuAddress(13) and (not w_cpuAddress(12)) and w_cpuAddress(11) and w_cpuAddress(10) and w_vma and (not w_cpuClock) and (not w_run0Halt1)),
--							or (w_wrRamStr and w_run0Halt1)),
			q			=> w_ramData2
		);
	
	-- ____________________________________________________________________________________
	-- INPUT/OUTPUT DEVICES
	-- Grant's VGA driver
	vdu : entity work.SBCTextDisplayRGB
		GENERIC map (
			EXTENDED_CHARSET    => 1,	-- 1 = 256 chars
												-- 0 = 128 chars
			COLOUR_ATTS_ENABLED => 0,	-- 1 = Color for each character
												-- 0 = Color applied to whole display
			SANS_SERIF_FONT     => 0	-- 0 => use conventional CGA font
												-- 1 => use san serif font
		)
		port map (
			clk		=> i_CLOCK_50,
			n_reset	=> w_resetLow,
			-- CPU interface
			n_WR		=> n_if1CS or      w_R1W0  or (not w_vma) or (not w_cpuClock),
			n_rd		=> n_if1CS or (not w_R1W0) or (not w_vma),
			regSel	=> w_cpuAddress(0),
			dataIn	=> w_cpuDataOut,
			dataOut	=> w_if1DataOut,
			-- VGA video signals
			hSync		=> o_hSync,
			vSync		=> o_vSync,
			videoR0	=> o_videoR0,
			videoR1	=> o_videoR1,
			videoG0	=> o_videoG0,
			videoG1	=> o_videoG1,
			videoB0	=> o_videoB0,
			videoB1	=> o_videoB1,
			-- PS/2 keyboard
			ps2Clk	=> io_ps2Clk,
			ps2Data	=> io_ps2Data
		);
	
	-- ACIA UART serial interface
	acia: entity work.bufferedUART
		port map (
			clk		=> i_CLOCK_50,     
			n_WR		=> n_if2CS or      w_R1W0  or (not w_vma) or (not w_cpuClock),
			n_rd		=> n_if2CS or (not w_R1W0) or (not w_vma),
			regSel	=> w_cpuAddress(0),
			dataIn	=> w_cpuDataOut,
			dataOut	=> w_if2DataOut,
			rxClkEn	=> serialEn,
			txClkEn	=> serialEn,
			rxd		=> rxd1,
			txd		=> txd1,
			n_cts		=> cts1,
			n_rts		=> rts1
		);
		
	MMU1 : entity work.OutLatch
	generic map (n => 8)
		port map (
			dataIn		=> w_cpuDataOut,
			clock			=> i_CLOCK_50,
			load			=> not(w_MMU1 and (not w_R1W0) and w_vma and w_cpuClock),
			clear			=> w_resetLow,
			latchOut		=> w_MMUReg1
			);	
	
	MMU2 : entity work.OutLatch
	generic map (n => 8)
		port map (
			dataIn		=> w_cpuDataOut,
			clock			=> i_CLOCK_50,
			load			=> not(w_MMU2 and (not w_R1W0) and w_vma and w_cpuClock),
			clear			=> w_resetLow,
			latchOut		=> w_MMUReg2
			);	
	
	-- ____________________________________________________________________________________
	-- CPU Clock - 25 MHz for internal accesses
	-- w_extSRAM - 16.7 MHz for external SRAM accesses
	process (i_CLOCK_50, w_extSRAM)
		begin
			if rising_edge(i_CLOCK_50) then
				if w_extSRAM = '1' then
					if q_cpuClkCount < 2 then						-- 50 MHz / 3 = 16.7 MHz 
						q_cpuClkCount <= q_cpuClkCount + 1;
					else
						q_cpuClkCount <= (others=>'0');
					end if;
				else
					if q_cpuClkCount < 1 then						-- 50 MHz / 2 = 25 MHz
						q_cpuClkCount <= q_cpuClkCount + 1;
					else
						q_cpuClkCount <= (others=>'0');
					end if;
				end if;
				if q_cpuClkCount < 1 then							-- one clock low
					w_cpuClock <= '0';
				else
					w_cpuClock <= '1';
				end if;
			end if;
		end process;

	-- ____________________________________________________________________________________
	-- Baud Rate Generator
	-- Legal BAUD_RATE values are 115200, 38400, 19200, 9600, 4800, 2400, 1200, 600, 300
	BaudRateGen : entity work.BaudRate6850
	GENERIC map (
		BAUD_RATE	=>  115200
	)
	PORT map (
		i_CLOCK_50	=> i_CLOCK_50,
		o_serialEn	=> serialEn
	);

end;
