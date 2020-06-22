-- Grant Searle's Multicomp as described here:
-- http://searle.x10host.com/Multicomp/index.html
-- 
-- z80 CPU
--	25 MHz
--	16 KB SRAM
--	Microsoft Z80 NASCOM BASIC in ROM
--		16,051 bytes free
--	USB-Serial Interface
--		CH340G chip
--		Requires RTS/CTS rework for hardware handshake
-- ANsI Video Display Unit
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


library ieee;
use ieee.std_logic_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

entity Z80_VGA is
	port (
		i_n_reset	: in std_logic;
		i_clk_50		: in std_logic;
		-- Serial port
		i_rxd			: in std_logic;
		o_txd			: out std_logic;
		i_cts			: in std_logic;
		o_rts			: out std_logic;
		-- Video
		o_vid_red	: out std_logic;
		o_vid_grn	: out std_logic;
		o_vid_blu	: out std_logic;
		o_vid_hSync	: out std_logic;
		o_vid_vSync	: out std_logic;
		-- Pushbutton switches
		i_switch0		: in std_logic;
		i_switch1		: in std_logic;
		i_switch2		: in std_logic;
		-- LEDs
		LED1			: out std_logic;
		LED2			: out std_logic;
		LED3			: out std_logic;
		LED4			: out std_logic;
		-- Buzzer
		BUZZER		: out std_logic;
		-- PS/2 keyboard
		i_ps2Clk		: inout std_logic;
		i_ps2Data	: inout std_logic
	);
end Z80_VGA;

architecture struct of Z80_VGA is

	signal w_n_WR				: std_logic;
	signal w_n_RD				: std_logic;
	signal w_cpuAddress		: std_logic_vector(15 downto 0);
	signal w_cpuDataOut		: std_logic_vector(7 downto 0);
	signal w_cpuDataIn		: std_logic_vector(7 downto 0);
	
	signal w_counterOut		: std_logic_vector(27 downto 0);
	signal w_buzz				: std_logic;

	signal w_basRomData		: std_logic_vector(7 downto 0);
	signal w_IF1DataOut		: std_logic_vector(7 downto 0);
	signal w_IF2DataOut		: std_logic_vector(7 downto 0);
	signal w_ramDataOut		: std_logic_vector(7 downto 0);
	
	signal w_n_memWR			: std_logic;
	signal w_n_memRD 			: std_logic :='1';
	
	signal w_n_basRomCS		: std_logic :='1';
	signal w_n_IF1CS			: std_logic :='1';
	signal w_n_IF2CS			: std_logic :='1';
	signal w_n_intlRam1CS	: std_logic :='1';
	signal w_n_Latch_CS		: std_logic :='1';
	
	signal w_n_ioWR			: std_logic :='1';
	signal w_n_ioRD 			: std_logic :='1';

	signal w_n_MREQ			: std_logic :='1';
	signal w_n_IORQ			: std_logic :='1';	

	signal w_n_int1			: std_logic :='1';	
	signal w_n_int2			: std_logic :='1';	
	
	signal w_serialCount		: std_logic_vector(15 downto 0);
	signal w_serClkCt_d		: std_logic_vector(15 downto 0);
	signal w_serialClkEn		: std_logic;

	signal w_cpuClkCount		: std_logic_vector(5 downto 0); 
	signal w_cpuClock		: std_logic;
	signal w_serialClock	: std_logic;
	
	signal w_n_LatchCS		: std_logic :='1';
	signal w_latchedBits	: std_logic_vector(7 downto 0);
	signal swDataOut		: std_logic_vector(7 downto 0);

	signal w_txdBuff		: std_logic;
	signal w_funKeys			: std_logic_vector(12 downto 0);
	signal w_fKey1			: std_logic :='0';
	signal w_fKey2			: std_logic :='0';
	
	signal w_Video_Red0	: std_logic :='0';
	signal w_Video_Red1	: std_logic :='0';
	signal w_Video_Grn0	: std_logic :='0';
	signal w_Video_Grn1	: std_logic :='0';
	signal w_Video_Blu0	: std_logic :='0';
	signal w_Video_Blu1	: std_logic :='0';

	signal n_RomActive	: std_logic := '0';

begin

	o_vid_red <= w_Video_Red0 or w_Video_Red1;
	o_vid_grn <= w_Video_Grn0 or w_Video_Grn1;
	o_vid_blu <= w_Video_Blu0 or w_Video_Blu1;
	
	LED1 <= w_latchedBits(0);
	LED2 <= w_fKey1;
	LED3 <= not w_txdBuff;
	LED4 <= not i_rxd;
	o_txd <= w_txdBuff;
	
	swDataOut(0) <= i_switch0;
	swDataOut(1) <= i_switch1;
	swDataOut(2) <= i_switch2;
	swDataOut(3) <= '0';
	swDataOut(4) <= '0';
	swDataOut(5) <= '0';
	swDataOut(6) <= '0';
	swDataOut(7) <= '0';

-- ____________________________________________________________________________________
-- CPU CHOICE GOES HERE
	cpu1 : entity work.t80s
	generic map(mode => 1, t2write => 1, iowait => 0)
	port map(
		reset_n => i_n_reset,
		clk_n => w_cpuClock,
		wait_n => '1',
		int_n => '1',
		nmi_n => '1',
		busrq_n => '1',
		mreq_n => w_n_MREQ,
		iorq_n => w_n_IORQ,
		rd_n => w_n_RD,
		wr_n => w_n_WR,
		a => w_cpuAddress,
		di => w_cpuDataIn,
		do => w_cpuDataOut
	);

	rom : entity work.Z80_BASIC_ROM -- 8KB
	port map(
		address => w_cpuAddress(12 downto 0),
		clock => i_clk_50,
		q => w_basRomData
	);

	u3: entity work.InternalRam16K 
	port map
	(
		address => w_cpuAddress(13 downto 0),
		clock => i_clk_50,
		data => w_cpuDataOut,
		wren => not(w_n_memWR or w_n_intlRam1CS),
		q => w_ramDataOut
	);

	io1 : entity work.SBCTextDisplayRGB
	generic map ( 
		EXTENDED_CHARSET => 0
	)
		port map (
		n_reset => i_n_reset,
		clk => i_clk_50,

		-- RGB video signals
		hSync => o_vid_hSync,
		vSync => o_vid_vSync,
		videoR0 => w_Video_Red0,		-- Most significant bits (different from Grant's)
		videoR1 => w_Video_Red1,
		videoG0 => w_Video_Grn0,
		videoG1 => w_Video_Grn1,
		videoB0 => w_Video_Blu0,
		videoB1 => w_Video_Blu1,

		n_WR => w_n_IF1CS or w_n_ioWR,
		n_RD => w_n_IF1CS or w_n_ioRD,
		n_int => w_n_int1,
		regSel => w_cpuAddress(0),
		dataIn => w_cpuDataOut,
		dataOut => w_IF1DataOut,
		ps2Clk => i_ps2Clk,
		ps2Data => i_ps2Data,
		FNkeys => w_funKeys			-- Brought out to use as port select/baud rate selects
	);

	UART : entity work.bufferedUART
		port map(
			clk => i_clk_50,
			n_WR => w_n_IF2CS or w_n_ioWR,
			n_RD => w_n_IF2CS or w_n_ioRD,
			n_int => w_n_int2,
			regSel => w_cpuAddress(0),
			dataIn => w_cpuDataOut,
			dataOut => w_IF2DataOut,
			rxClkEn => w_serialClkEn,		-- Improved UART clocking by Neal Crook
			txClkEn => w_serialClkEn,
			rxd => i_rxd,
			txd => w_txdBuff,
			n_cts => i_cts,
			n_dcd => '0',
			n_rts => o_rts
		);
	
	FNKey1Toggle: entity work.Toggle_On_FN_Key	
		port map (		
			FNKey => w_funKeys(1),
			clock => i_clk_50,
			n_res => i_n_reset,
			latchFNKey => w_fKey1
		);	

	FNKey2Toggle: entity work.Toggle_On_FN_Key	
		port map (		
			FNKey => w_funKeys(2),
			clock => i_clk_50,
			n_res => i_n_reset,
			latchFNKey => w_fKey2
		);	
		
	io3: entity work.OutLatch
		port map (
			dataIn8 => w_cpuDataOut,
			clock => i_clk_50,
			load => w_n_Latch_CS or w_n_ioWR,
			clear => i_n_reset,
			latchOut => w_latchedBits
			);
	
	myCounter : entity work.counter
	port map(
		clock => i_clk_50,
		clear => '0',
		count => '1',
		Q => w_counterOut
		);

--	w_buzz <= w_latchedBits(4) and w_counterOut(16);
	BUZZER <= not (
		(w_latchedBits(4) and w_counterOut(13)) or 
		(w_latchedBits(5) and w_counterOut(14)) or 
		(w_latchedBits(6) and w_counterOut(15)) or 
		(w_latchedBits(7) and w_counterOut(16)));

-- MEMORY READ/WRITE LOGIC GOES HERE
	w_n_ioWR <= w_n_WR or w_n_IORQ;
	w_n_memWR <= w_n_WR or w_n_MREQ;
	w_n_ioRD <= w_n_RD or w_n_IORQ;
	w_n_memRD <= w_n_RD or w_n_MREQ;
	
	-- Chip Selects
	w_n_basRomCS       <= '0' when   w_cpuAddress(15 downto 13) = "000" else '1'; --8K from $0000-1FFF
	w_n_intlRam1CS <= '0' when ((w_cpuAddress(15 downto 13) = "001") or (w_cpuAddress(15 downto 13) = "010"))  else '1';		-- x2000-x5FFF (16KB)
	-- I/O accesses are via IN/OUT in Z80 NASCOM BASIC
	-- The address decoders get swapped when the F1 key is pressed
	w_n_IF1CS <= '0' when 
		((w_fKey1 = '0' and w_cpuAddress(7 downto 1) = X"8"&"000" and (w_n_ioWR='0' or w_n_ioRD = '0')) or	-- 2 Bytes $80-$81
		 (w_fKey1 = '1' and w_cpuAddress(7 downto 1) = X"8"&"001" and (w_n_ioWR='0' or w_n_ioRD = '0')))	-- 2 Bytes $82-$83
		else '1';
	w_n_IF2CS <= '0' when   
		((w_fKey1 = '0' and w_cpuAddress(7 downto 1) = X"8"&"001" and (w_n_ioWR='0' or w_n_ioRD = '0'))	or	-- 2 Bytes $82-$83
		 (w_fKey1 = '1' and w_cpuAddress(7 downto 1) = X"8"&"000" and (w_n_ioWR='0' or w_n_ioRD = '0')))	-- 2 Bytes $80-$81
		else '1';
	w_n_Latch_CS <= '0' when w_cpuAddress(7 downto 1) = X"8"&"010" and (w_n_ioWR='0' or w_n_ioRD = '0') else '1';  -- $84-$85 (132-133 dec)
	
	w_cpuDataIn <=
		w_IF1DataOut when w_n_IF1CS = '0' else	-- UART 1
		w_IF2DataOut when w_n_IF2CS = '0' else	-- UART 2
		swDataOut when w_n_Latch_CS = '0' else
		w_basRomData when w_n_basRomCS = '0' else
		w_ramDataOut when w_n_intlRam1CS = '0' else
		x"FF";
		

-- SUB-CIRCUIT CLOCK SIGNALS 
	process (i_clk_50)
	begin
		if rising_edge(i_clk_50) then

			if w_cpuClkCount < 1 then -- 4 = 10MHz, 3 = 12.5MHz, 2=16.6MHz, 1=25MHz
				w_cpuClkCount <= w_cpuClkCount + 1;
			else
				w_cpuClkCount <= (others=>'0');
			end if;
			if w_cpuClkCount < 1 then -- 2 when 10MHz, 2 when 12.5MHz, 2 when 16.6MHz, 1 when 25MHz
				w_cpuClock <= '0';
			else
				w_cpuClock <= '1';
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

	baud_div: process (w_serClkCt_d, w_serialCount)
		begin
			if w_fKey2 = '0' then
				w_serClkCt_d <= w_serialCount + 2416;	-- 115,200 baud
			else
				w_serClkCt_d <= w_serialCount + 6;		-- 300 baud
				end if;
		end process;

	--Single clock wide baud rate enable
	baud_i_clk_50: process(i_clk_50)
		begin
			if rising_edge(i_clk_50) then
					w_serialCount <= w_serClkCt_d;
				if w_serialCount(15) = '0' and w_serClkCt_d(15) = '1' then
					w_serialClkEn <= '1';
				else
					w_serialClkEn <= '0';
				end if;
       end if;
    end process;
	 
end;
