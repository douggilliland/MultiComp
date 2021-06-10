-- IOP16 - I/O Processor
--
-- INSTRUCTIONS
--	NOP - x0 - Increments PC
--	LRI - x2 - Load register with immediate value
--	IOR - x6 - I/O Read
--	IOW - x7 - I/O Write
--	ARI - x8 - AND register with Immediate value and store back into register
--	ORI - x9 - OR register with Immediate value and store back into register
--	BEZ - xc - Branch by offset if equal to zero
--	BNZ - xd - Branch by offset if not equal to zero
--	JMP - xe - Jump to address (12-bits)
--
-- Fields
--		d15..d12 = opcode
--		d11..d0  = offset (BEZ, BNZ)
--		d11..d0  = address (JMP)
--		d11..d8  = register number (LRI, IOR, IOW, ARI, ORI)
--		d7..d0   = Immediate value (LRI, ARI, ORI)
--

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY IOP16 IS
	PORT
	(
		clk			: IN std_logic;
		resetN		: IN std_logic;
		periphIn		: IN std_logic_vector(7 DOWNTO 0);
		periphWr		: OUT std_logic := '0';
		periphRd		: OUT std_logic := '0';
		periphOut	: OUT std_logic_vector(7 DOWNTO 0) := x"00";
		periphAdr	: OUT std_logic_vector(7 DOWNTO 0) := x"00"
	);
END IOP16;

ARCHITECTURE IOP16_beh OF IOP16 IS

signal w_lowCount : std_logic_vector(2 DOWNTO 0);		-- Grey code step counter
signal w_PC_out	: std_logic_vector(11 DOWNTO 0);		-- Program Couner output
signal w_PC_in		: std_logic_vector(11 DOWNTO 0);		-- Program Couner input
signal w_RomData	: std_logic_vector(15 DOWNTO 0);		-- Program data
-- ALU
signal w_AluInA	: std_logic_vector(7 DOWNTO 0);
signal w_AluOut	: std_logic_vector(7 DOWNTO 0);
-- Register File
signal reg0			: std_logic_vector(7 DOWNTO 0);
signal reg1			: std_logic_vector(7 DOWNTO 0);
signal reg2			: std_logic_vector(7 DOWNTO 0);
signal reg3			: std_logic_vector(7 DOWNTO 0);
signal reg4			: std_logic_vector(7 DOWNTO 0);
signal reg5			: std_logic_vector(7 DOWNTO 0);
signal reg6			: std_logic_vector(7 DOWNTO 0);
signal reg7			: std_logic_vector(7 DOWNTO 0);
signal regFileIn	: std_logic_vector(7 DOWNTO 0);		-- Register file input
-- Opcode decodes
signal w_OP_NOP	: std_logic;
signal w_OP_LRI	: std_logic;
signal w_OP_IOR	: std_logic;
signal w_OP_IOW	: std_logic;
signal w_OP_ARI	: std_logic;
signal w_OP_ORI	: std_logic;
signal w_OP_BEZ	: std_logic;
signal w_OP_BNZ	: std_logic;
signal w_OP_JMP	: std_logic;
-- Prrogram Counter controls
signal w_incPC		: std_logic;		-- Increment PC
signal w_ldPC		: std_logic;		-- Load PC
signal w_zBit		: std_logic;		-- ALU Zero bit (latched)
signal w_aluZero	: std_logic;		-- ALU zero value
-- Register file load lines
signal ldReg0		: std_logic;
signal ldReg1		: std_logic;
signal ldReg2		: std_logic;
signal ldReg3		: std_logic;
signal ldReg4		: std_logic;
signal ldReg5		: std_logic;
signal ldReg6		: std_logic;
signal ldReg7		: std_logic;

BEGIN

	-- OPCODE Decoder
	w_OP_NOP <= '1' when w_RomData(15 downto 12) = x"0" else '0';
	w_OP_LRI <= '1' when w_RomData(15 downto 12) = x"2" else '0';
	w_OP_IOR <= '1' when w_RomData(15 downto 12) = x"6" else '0';
	w_OP_IOW <= '1' when w_RomData(15 downto 12) = x"7" else '0';
	w_OP_ARI <= '1' when w_RomData(15 downto 12) = x"8" else '0';
	w_OP_ORI <= '1' when w_RomData(15 downto 12) = x"9" else '0';
	w_OP_BEZ <= '1' when w_RomData(15 downto 12) = x"c" else '0';
	w_OP_BNZ <= '1' when w_RomData(15 downto 12) = x"d" else '0';
	w_OP_JMP <= '1' when w_RomData(15 downto 12) = x"e" else '0';

	-- Lower bits are grey code for glitch-free decoding
	-- 3-bits that control the low level interface (strobes) to the I2C interface
	greyLow : ENTITY work.GrayCounter
	generic map
	(
		N => 3
	)
	PORT map
	(
		Clk		=> clk,
		Rst		=> not resetN,
		En			=> '1',
		output	=> w_lowCount
	);
	
	-- IO Processor ROM
	IopRom : ENTITY work.IOP_ROM
	PORT map
	(
		address		=> w_PC_out,
		clock			=> clk,
		q				=> w_RomData
	);
	
	-- Program Counter
	StateReg: PROCESS (clk, resetN, w_incPC, w_ldPC)
	BEGIN
		IF rising_edge(clk) THEN
			IF resetN = '0' THEN
				w_PC_out <= x"000";
			ELSIF w_incPC = '1' THEN
				w_PC_out <= w_PC_out + 1;
			ELSIF w_ldPC = '1' THEN
				w_PC_out <= w_PC_in;
			END IF;
		END IF;
	END PROCESS;
	
	w_incPC		<= '1' when (w_lowCount = "100") and (w_OP_BEZ = '0') and (w_OP_BNZ = '0') else 
					'1' when (w_lowCount = "100") and (w_OP_BEZ = '1') and (w_zBit = '0') else
					'1' when (w_lowCount = "100") and (w_OP_BNZ = '1') and (w_zBit = '1') else
					'0';
	w_ldPC		<= '1' when (w_lowCount = "100") and (w_OP_BEZ = '1') and (w_zBit = '1') else
					'1' when (w_lowCount = "100") and (w_OP_BNZ = '1') and (w_zBit = '0') else
					'0';
					
	-- Mux PC input
	w_PC_in <=  (w_PC_out + w_RomData(11 downto 0)) when ((w_OP_BEZ = '1') and (w_zBit = '1')) else
					(w_PC_out + w_RomData(11 downto 0)) when ((w_OP_BNZ = '1') and (w_zBit = '0')) else
					w_PC_out;

	-- Register file
	regF0 : process (clk, ldReg0)
	BEGIN
		IF rising_edge(clk) THEN
			IF resetN = '0' THEN
				reg0 <= x"00";
			elsif ldReg0 = '1' then
				reg0 <= regFileIn;
			end if;
		end if;
	END process;
	
	regF1 : process (clk, ldReg1)
	BEGIN
		IF rising_edge(clk) THEN
			IF resetN = '0' THEN
				reg1 <= x"00";
			elsif ldReg1 = '1' then
				reg1 <= regFileIn;
			end if;
		end if;
	END process;
	
	regF2 : process (clk, ldReg2)
	BEGIN
		IF rising_edge(clk) THEN
			IF resetN = '0' THEN
				reg2 <= x"00";
			elsif ldReg2 = '1' then
				reg2 <= regFileIn;
			end if;
		end if;
	END process;
	
	regF3 : process (clk, ldReg3)
	BEGIN
		IF rising_edge(clk) THEN
			IF resetN = '0' THEN
				reg3 <= x"00";
			elsif ldReg3 = '1' then
				reg3 <= regFileIn;
			end if;
		end if;
	END process;
	
	regF4 : process (clk, ldReg4)
	BEGIN
		IF rising_edge(clk) THEN
			IF resetN = '0' THEN
				reg4 <= x"00";
			elsif ldReg4 = '1' then
				reg4 <= regFileIn;
			end if;
		end if;
	END process;
	
	regF5 : process (clk, ldReg5)
	BEGIN
		IF rising_edge(clk) THEN
			IF resetN = '0' THEN
				reg5 <= x"00";
			elsif ldReg5 = '1' then
				reg5 <= regFileIn;
			end if;
		end if;
	END process;
	
	regF6 : process (clk, ldReg6)
	BEGIN
		IF rising_edge(clk) THEN
			IF resetN = '0' THEN
				reg6 <= x"00";
			elsif ldReg6 = '1' then
				reg6 <= regFileIn;
			end if;
		end if;
	END process;
	
	regF7 : process (clk, ldReg7)
	BEGIN
		IF rising_edge(clk) THEN
			IF resetN = '0' THEN
				reg7 <= x"00";
			elsif ldReg7 = '1' then
				reg7 <= regFileIn;
			end if;
		end if;
	END process;
	
	-- ALU input multiplexer
	w_AluInA <=	reg0 when w_RomData(11 downto 8) = x"0" else
					reg1 when w_RomData(11 downto 8) = x"1" else
					reg2 when w_RomData(11 downto 8) = x"2" else
					reg3 when w_RomData(11 downto 8) = x"3" else
					reg4 when w_RomData(11 downto 8) = x"4" else
					reg5 when w_RomData(11 downto 8) = x"5" else
					reg6 when w_RomData(11 downto 8) = x"6" else
					reg7 when w_RomData(11 downto 8) = x"7";
	
	-- Register file input dats mux
	regFileIn <=	periphIn		when w_OP_IOR = '1' else
						w_AluOut 	when w_OP_ARI = '1' else
						w_AluOut 	when w_OP_ORI = '1' else
						w_RomData(7 downto 0);
	
	-- ALU result
	w_AluOut <= (w_AluInA and w_RomData(7 downto 0)) when w_OP_ARI = '1' else
					(w_AluInA or  w_RomData(7 downto 0)) when w_OP_ORI = '1' else
					x"00";
					
	-- ALU zero
	w_aluZero <= not (w_AluOut(7) or w_AluOut(6) or w_AluOut(5) or w_AluOut(4) or w_AluOut(3) or w_AluOut(2) or w_AluOut(1) or w_AluOut(0));
	w_zBit <=	'1' when (w_OP_ARI = '1') and (w_lowCount="101") and (w_aluZero = '1') else
					'1' when (w_OP_ORI = '1') and (w_lowCount="101") and (w_aluZero = '1') else
					'0' when (w_OP_ARI = '1') and (w_lowCount="101") and (w_aluZero = '0') else
					'0' when (w_OP_ORI = '1') and (w_lowCount="101") and (w_aluZero = '0');

	-- Controls
	periphWr <= '1' when (w_OP_IOW = '1') and (w_lowCount="010") else '0';
	periphRd <= '1' when (w_OP_IOR = '1') and (w_lowCount="010") else '0';

	-- Peripheral output data bus
	periphOut <= w_AluInA;
	
	
END IOP16_beh;
