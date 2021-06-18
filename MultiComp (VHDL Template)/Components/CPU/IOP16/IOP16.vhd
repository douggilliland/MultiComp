-- ---------------------------------------------------------------------------------------
-- IOP16 - I/O Processor with minimal instruction set
--	16-bit instruction code
--	12-bits address (up to 4096 instructions stored in FPGA ROM)
--	Useful for for polled I/O
--	8 registers (8-bits) (read/write) for parameters/data
--		Reserved space in instruction for 16 of 8-bit registers
--	8-bit data and address peripheral interface
--		Controls up to 256 peripherals
--
-- Opcodes
--	NOP - x0 - No Operation - Increments PC
--	LRI - x2 - Load register with immediate value
--	IOR - x6 - I/O Read into register
--	IOW - x7 - I/O Write from register
--	ARI - x8 - AND register with Immediate value and store back into register
--	ORI - x9 - OR register with Immediate value and store back into register
--	BEZ - xc - Branch by offset if equal to zero
--	BNZ - xd - Branch by offset if not equal to zero
--	JMP - xe - Jump to address (12-bits)
--
-- Fields
--		d15..d12 = opcode
--		d11..d0  = 12-bit offset (BEZ, BNZ)
--		d11..d0  = 12-bit address (JMP)
--		d7..d0   = 8-bit address (IOR, IOW)
--		d11..d8  = register number (LRI, IOR, IOW, ARI, ORI)
--		d7..d0   = Immediate value (LRI, ARI, ORI)
-- ---------------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY IOP16 IS
	generic 
	(
		constant INST_SRAM_SIZE_PASS 	: integer := 4096
	);
	PORT (
		clk			: IN std_logic;
		resetN		: IN std_logic;
		periphIn		: IN std_logic_vector(7 DOWNTO 0);				-- Data from peripheral
		periphWr		: OUT std_logic := '0';								-- I/O write strobe
		periphRd		: OUT std_logic := '0';								-- I/O read strobe
		periphOut	: OUT std_logic_vector(7 DOWNTO 0) := x"00";	-- Data to peripheral
		periphAdr	: OUT std_logic_vector(7 DOWNTO 0) := x"00"	-- Address to peripheral|FrontPanel01_test|FrontPanel01:fp_test	

	);
END IOP16;

ARCHITECTURE IOP16_beh OF IOP16 IS

	-- Grey code state counter
	signal w_lowCount : std_logic_vector(2 DOWNTO 0);		-- Grey code step counter
	-- Program Counter
	signal w_PC_out	: std_logic_vector(11 DOWNTO 0);		-- Program Couner output
	signal w_PC_in		: std_logic_vector(11 DOWNTO 0);		-- Program Couner input
	-- Program Counter controls
	signal w_incPC		: std_logic;		-- Increment PC
	signal w_ldPC		: std_logic;		-- Load PC
	-- ROM
	signal w_RomData	: std_logic_vector(15 DOWNTO 0);		-- Program data
	-- ALU
	signal w_AluInA	: std_logic_vector(7 DOWNTO 0);
	signal w_AluOut	: std_logic_vector(7 DOWNTO 0);
	signal w_zBit		: std_logic;		-- ALU Zero bit (latched)
	signal w_aluZero	: std_logic;		-- ALU zero value
	-- Register file controls/data
	signal w_wrRegF	: std_logic;
	signal w_regFileIn: std_logic_vector(7 DOWNTO 0);
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
	
	attribute syn_keep	: boolean;
	attribute syn_keep of w_lowCount			: signal is true;
	attribute syn_keep of w_PC_out			: signal is true;
	

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
	-- 000 > 001 > 011 > 010 > 110 > 11 > 101 > 100
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
	GEN_4KW_INST_ROM: if (INST_SRAM_SIZE_PASS=4096) generate
		begin
		IopRom : ENTITY work.IOP_ROM
		PORT map
		(
			address		=> w_PC_out,
			clock			=> clk,
			q				=> w_RomData
		);
	end generate GEN_4KW_INST_ROM;
	
	GEN_2KW_INST_ROM: if (INST_SRAM_SIZE_PASS=2048) generate
		begin
		IopRom : ENTITY work.IOP_ROM
		PORT map
		(
			address		=> w_PC_out(10 downto 0),
			clock			=> clk,
			q				=> w_RomData
		);
	end generate GEN_2KW_INST_ROM;
	
	GEN_1KW_INST_ROM: if (INST_SRAM_SIZE_PASS=1024) generate
		begin
		IopRom : ENTITY work.IOP_ROM
		PORT map
		(
			address		=> w_PC_out(9 downto 0),
			clock			=> clk,
			q				=> w_RomData
		);
	end generate GEN_1KW_INST_ROM;
	
	GEN_512W_INST_ROM: if (INST_SRAM_SIZE_PASS=512) generate
		begin
		IopRom : ENTITY work.IOP_ROM
		PORT map
		(
			address		=> w_PC_out(8 downto 0),
			clock			=> clk,
			q				=> w_RomData
		);
	end generate GEN_512W_INST_ROM;
	
	GEN_256W_INST_ROM: if (INST_SRAM_SIZE_PASS=256) generate
		begin
		IopRom : ENTITY work.IOP_ROM
		PORT map
		(
			address		=> w_PC_out(7 downto 0),
			clock			=> clk,
			q				=> w_RomData
		);
	end generate GEN_256W_INST_ROM;
	
	-- Program Counter (PC)
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
	
	-- Mux PC input
	w_PC_in <=  (w_PC_out + w_RomData(11 downto 0)) when ((w_OP_BEZ = '1') and (w_zBit = '1')) else
					(w_PC_out + w_RomData(11 downto 0)) when ((w_OP_BNZ = '1') and (w_zBit = '0')) else
					(w_RomData(11 downto 0)) when w_OP_JMP = '1' else
					w_PC_out;

	w_incPC	<= '1' when (w_lowCount = "100") and (w_OP_BEZ = '0') and (w_OP_BNZ = '0') and (w_OP_JMP = '0') else 
					'1' when (w_lowCount = "100") and (w_OP_BEZ = '1') and (w_zBit = '0') else
					'1' when (w_lowCount = "100") and (w_OP_BNZ = '1') and (w_zBit = '1') else
					'0';
					
	w_ldPC	<= '1' when (w_lowCount = "100") and (w_OP_BEZ = '1') and (w_zBit = '1') else
					'1' when (w_lowCount = "100") and (w_OP_BNZ = '1') and (w_zBit = '0') else
					'1' when (w_lowCount = "100") and (w_OP_JMP = '1') else
					'0';
	
	-- Register file input dats mux
	w_regFileIn <=	periphIn						when w_OP_IOR = '1' else
						w_AluOut 					when w_OP_ARI = '1' else
						w_AluOut 					when w_OP_ORI = '1' else
						w_RomData(7 downto 0)	when w_OP_LRI = '1' else
						x"00";
	
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
	periphWr <= '1' when (w_OP_IOW = '1') and (w_lowCount="111") else '0';
	periphRd <= '1' when (w_OP_IOR = '1') and (w_lowCount(2 DOWNTO 1)="11") else 
					'1' when (w_OP_IOR = '1') and (w_lowCount(2 DOWNTO 1)="11") else 
					'0';

	-- Peripheral output data bus
	periphOut <= 	w_AluInA when (w_OP_IOW = '1') else
						x"AA";
	
	periphAdr <= 	w_RomData(7 downto 0) when w_OP_IOW = '1' else
						w_RomData(7 downto 0) when w_OP_IOR = '1' else
						x"ff";
	
	
	-- Register file (8x8)
	RegFile : ENTITY work.RegFile8x8
	PORT map
	(
		i_clk			=> clk,
		i_resetN		=> resetN,
		i_wrReg		=> w_wrRegF,
		i_regNum		=> w_RomData(11 downto 8),
		i_DataIn		=> w_regFileIn,
		o_DataOut	=> w_AluInA
	);
	
	w_wrRegF <= '1' when (w_OP_ARI = '1') and (w_lowCount="110") else
					'1' when (w_OP_ORI = '1') and (w_lowCount="110") else
					'1' when (w_OP_LRI = '1') and (w_lowCount="110") else
					'1' when (w_OP_IOR = '1') and (w_lowCount="101") else
					'0';
					
END IOP16_beh;
