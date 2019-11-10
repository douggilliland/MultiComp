// asm.cpp
// Revision 17-apr-2008

#include "asm.h"
#include "token.h"
#include "asmfile.h"

#include "cpc.h"
#include "tap.h"
#include "tzx.h"

#include "spectrum.h"

#include "trace.h"


#include <iostream>
#include <fstream>
#include <sstream>
#include <iomanip>
#include <vector>
#include <map>
#include <stack>
#include <memory>
#include <iterator>
#include <stdexcept>
#include <algorithm>

#include <ctype.h>

using std::cout;
using std::cerr;
using std::endl;
using std::ostringstream;
using std::make_pair;
using std::runtime_error;
using std::logic_error;
using std::for_each;
using std::fill;


namespace {


//*********************************************************
//		Exceptions.
//*********************************************************


// Errors that must never happen, they are handled for diagnose
// Pasmo bugs.

logic_error UnexpectedError ("Unexpected error");
logic_error UnexistentMode ("Mode of code generation invalid");
logic_error UnexpectedPrefix ("Unexpected prefix");
logic_error UnexpectedRegisterCode ("Unexpected register code");
logic_error InvalidFlagConvert ("Inalid flag specified for conversion");
logic_error InvalidPrefixUsed ("Invalid use of prefix");
logic_error InvalidRegisterUsed ("Invalid register used");
logic_error InvalidInstructionType ("Invalid instruction type");
logic_error LocalNotExist ("Trying to use a non existent local level");
logic_error LocalNotExpected ("Unexpected local block encountered");
logic_error AutoLocalNotExpected ("Unexpected autolocal block encountered");
logic_error InvalidPassValue ("Invalid value of pass");
logic_error UnexpectedORG ("Unexpected ORG found");
logic_error UnexpectedMACRO ("Unexpected MACRO found");
logic_error MACROLostENDM ("Unexpected MACRO without ENDM");


// Errors in the code being assembled.

runtime_error ErrorReadingINCBIN ("Error reading INCBIN file");
runtime_error ErrorOutput ("Error writing object file");

runtime_error InvalidPredefine ("Can't predefine invalid identifier");
runtime_error InvalidPredefineValue ("Invalid value for predefined symbol");
runtime_error InvalidPredefineSyntax ("Syntax error in predefined symbol");
runtime_error RedefinedDEFL
	("Invalid definition, previously defined as DEFL");
runtime_error RedefinedEQU
	("Invalid definition, previously defined as EQU or label");

runtime_error InvalidInAutolocal ("Invalid use of name in autolocal mode");

runtime_error InvalidSharpSharp ("Invalid use of ##");

runtime_error EQUwithoutlabel ("EQU without label");
runtime_error DEFLwithoutlabel ("DEFL without label");

runtime_error Lenght1Required ("Invalid literal, length 1 required");

runtime_error DivisionByZero ("Division by zero");

runtime_error IFwithoutENDIF ("IF without ENDIF");
runtime_error ELSEwithoutIF ("ELSE without IF");
runtime_error ELSEwithoutENDIF ("ELSE without ENDIF");
runtime_error ENDIFwithoutIF ("ENDIF without IF");

runtime_error UnbalancedPROC ("Unbalanced PROC");
runtime_error UnbalancedENDP ("Unbalanced ENDP");

runtime_error MACROwithoutENDM ("MACRO without ENDM");
runtime_error REPTwithoutENDM ("REPT without ENDM");
runtime_error IRPWithoutParameters ("IRP without parameters");
runtime_error IRPwithoutENDM ("IRP without ENDM");
runtime_error ENDMOutOfMacro ("ENDM outside of macro");

runtime_error ShiftOutsideMacro (".SHIFT outside MACRO");
runtime_error InvalidBaseValue ("Invalid base value");

runtime_error ParenInsteadOfBracket ("Expected ] but ) found");
runtime_error BracketInsteadOfParen ("Expected ) but ] found");

runtime_error OffsetOutOfRange ("Offset out of range");
runtime_error RelativeOutOfRange ("Relative jump out of range");
runtime_error BitOutOfRange ("Bit position out of range");

runtime_error InvalidInstruction ("Invalid instruction");
runtime_error InvalidOperand ("Invalid operand");
runtime_error InvalidFlagJR ("Invalid flag for JR");
runtime_error InvalidValueRST ("Invalid RST value");
runtime_error InvalidValueIM ("Invalid IM value");

runtime_error NotValid86 ("Instruction not valid in 86 mode");

runtime_error IsPredefined ("Can't redefine, is predefined");

runtime_error OutOfSyncPRL ("PRL genration failed: out of sync");

class NoInstruction : public runtime_error {
public:
	NoInstruction (const Token & tok) :
		runtime_error ("Unexpected '" + tok.str () +
			"' used as instruction")
	{ }
};

class UndefinedVar : public runtime_error {
public:
	UndefinedVar (const std::string & varname) :
		runtime_error ("Symbol '" + varname + "' is undefined")
	{ }
};

class PhaseError : public runtime_error {
public:
	PhaseError (const std::string & varname) :
		runtime_error ("Phase error in '" + varname + "'")
	{ }
};

class EndLineExpected : public runtime_error {
public:
	EndLineExpected (const Token & tok) :
		runtime_error ("End line expected but '" +
			tok.str () + "'found")
	{ }
};

class IdentifierExpected : public runtime_error {
public:
	IdentifierExpected (const Token & tok) :
		runtime_error ("Identifier expected but '" +
			tok.str () + "'found")
	{ }
};

class MacroExpected : public runtime_error {
public:
	MacroExpected (const std::string & name) :
		runtime_error ("Macro name expected but '" +
			name + "'found")
	{ }
};

class ValueExpected : public runtime_error {
public:
	ValueExpected (const Token & tok) :
		runtime_error ("Value expected but '" +
			tok.str () + "'found")
	{ }
};


class SomeOpenExpected : public runtime_error {
public:
	SomeOpenExpected (const Token & tok) :
		runtime_error ("Expected ( or [ but '" +
			tok.str () + "' found")
	{ }
};


class TokenExpected : public runtime_error {
public:
	TokenExpected (TypeToken ttexpect, const Token & tokfound) :
		runtime_error ("Expected '" + gettokenname (ttexpect) +
			"' but '" + tokfound.str () + "' found")
	{ }
};

class OffsetExpected : public runtime_error {
public:
	OffsetExpected (const Token & tok) :
		runtime_error ("Offset expression expected but '" +
			tok.str () + "' found")
	{ }
};

class ErrorDirective : public runtime_error {
public:
	ErrorDirective (const Token & tok) :
		runtime_error (".ERROR directive: " + tok.str () )
	{ }
};

class UndefinedInPass1 : public runtime_error {
public:
	UndefinedInPass1 (const std::string & name) :
		runtime_error ("The symbol '" + name +
			"' must be defined in pass 1")
	{ }
};



void checktoken (TypeToken ttexpected, const Token & tok)
{
	if (tok.type () != ttexpected)
		throw TokenExpected (ttexpected, tok);
}


//*********************************************************
//		Auxiliary functions and constants.
//*********************************************************


const std::string emptystr;

enum GenCodeMode { gen80, gen86 };

const address addrTRUE= 0xFFFF;
const address addrFALSE= 0;

// Register codes used in some instructions.

enum regwCode {
	regBC= 0, regDE= 1, regHL= 2, regAF= 3, regSP= 3
};
// 8086 equivalents:
//	CX        DX        BX

enum regbCode {
	regB= 0,    regC= 1,    regD= 2,    regE= 3,
	regH= 4,    regL= 5,    reg_HL_= 6, regA= 7,

	reg86AL= 0, reg86CH= 5, reg86CL= 1, reg86DH= 6,
	reg86DL= 2, reg86BH= 7, reg86BL= 3,

	regbInvalid= 8
};

byte getregb86 (regbCode rb)
{
	switch (rb)
	{
	case regA: return reg86AL;
	case regB: return reg86CH;
	case regC: return reg86CL;
	case regD: return reg86DH;
	case regE: return reg86DL;
	case regH: return reg86BH;
	case regL: return reg86BL;
	default:
		ASSERT (false);
		throw UnexpectedRegisterCode;
	}
}

regbCode getregb (TypeToken tt)
{
	switch (tt)
	{
	case TypeA: return regA;
	case TypeB: return regB;
	case TypeC: return regC;
	case TypeD: return regD;
	case TypeE: return regE;
	case TypeH: return regH;
	case TypeL: return regL;
	default:    return regbInvalid;
	}
}

enum flagCode {
	flagNZ= 0, flagZ=  1,
	flagNC= 2, flagC=  3,
	flagPO= 4, flagPE= 5,
	flagP=  6, flagM=  7,

	flag86NZ= 0x05, flag86Z= 0x04,
	flag86NC= 0x03, flag86C= 0x02,
	flag86NP= 0x0B, flag86P= 0x0A,
	flag86NS= 0x09, flag86S= 0x08,

	flagInvalid= 8
};

flagCode getflag86 (flagCode fcode)
{
	switch (fcode)
	{
	case flagNZ: return flag86NZ;
	case flagZ:  return flag86Z;
	case flagNC: return flag86NC;
	case flagC:  return flag86C;
	case flagPO: return flag86NP;
	case flagPE: return flag86P;
	case flagP:  return flag86NS;
	case flagM:  return flag86S;
	default:
		throw InvalidFlagConvert;
	}
}

flagCode invertflag86 (flagCode fcode)
{
	return static_cast <flagCode>
		( (fcode & 1) ? fcode & ~ 1 : fcode | 1);
}

flagCode getflag (TypeToken tt)
{
	switch (tt)
	{
	case TypeNZ: return flagNZ;
	case TypeZ:  return flagZ;
	case TypeNC: return flagNC;
	case TypeC:  return flagC;
	case TypePO: return flagPO;
	case TypePE: return flagPE;
	case TypeP:  return flagP;
	case TypeM:  return flagM;
	default:     return flagInvalid;
	}
}

// Common prefixes and base codes for some operands.

const byte prefixIX= 0xDD;
const byte prefixIY= 0xFD;
const byte NoPrefix= 0;

std::string nameHLpref (byte prefix)
{
	switch (prefix)
	{
	case NoPrefix: return "HL";
	case prefixIX: return "IX";
	case prefixIY: return "IY";
	default:
		throw InvalidPrefixUsed;
	}
}

const bool nameSP= true;
const bool nameAF= false;

std::string regwName (regwCode code, bool useSP, byte prefix)
{
	ASSERT (code == regHL || prefix == NoPrefix);

	switch (code)
	{
	case regBC: return "BC";
	case regDE: return "DE";
	case regHL: return nameHLpref (prefix);
	case regAF: return useSP ? "SP" : "AF";
	default:
		throw InvalidRegisterUsed;
	}
}

const byte codeADDHL= 0x09;
const byte codeADCHL= 0x4A;
const byte codeSBCHL= 0x42;
const byte codeLDIA= 0x47;
const byte codeLDRA= 0x4F;

const byte codeRST00= 0xC7;

const byte codeDJNZ= 0x10;

enum TypeByteInst {
	tiADDA= 0,
	tiADCA= 1,
	tiSUB=  2,
	tiSBCA= 3,
	tiAND=  4,
	tiXOR=  5,
	tiOR=   6,
	tiCP=   7
};

std::string byteinstName (TypeByteInst ti)
{
	switch (ti)
	{
	case tiADDA: return "ADD A,";
	case tiADCA: return "ADC A,";
	case tiSUB:  return "SUB";
	case tiSBCA: return "SBC A,";
	case tiAND: return "AND";
	case tiXOR: return "XOR";
	case tiOR: return "OR";
	case tiCP: return "CP";
	default:
		throw InvalidInstructionType;
	}
}

byte getbaseByteInst (TypeByteInst ti, GenCodeMode genmode)
{
	static byte byte86 []=
		{ 0x00, 0x10, 0x28, 0x18, 0x20, 0x30, 0x08, 0x38 };
	switch (genmode)
	{
	case gen80:
		return 0x80 | (ti << 3);
	case gen86:
		return byte86 [ti];
	default:
		ASSERT (false);
		throw UnexistentMode;
	}
}

byte getByteInstInmediate (TypeByteInst ti, GenCodeMode genmode)
{
	static byte byte86 []=
		{ 0x04, 0x14, 0x2C, 0x1C, 0x24, 0x34, 0x0C, 0x3C };
	switch (genmode)
	{
	case gen80:
		return 0xC6 | (ti << 3);
	case gen86:
		return byte86 [ti];
	default:
		ASSERT (false);
		throw UnexistentMode;
	}
}

std::string nameIdesp (byte prefix, bool hasdesp, byte desp)
{
	std::string r (1, '(');
	r+= nameHLpref (prefix);
	if (hasdesp)
	{
		r+= '+';
		r+= hex2str (desp);
	}
	r+= ')';
	return r;
}

std::string getregbname (regbCode rb, byte prefix= NoPrefix,
	bool hasdesp= false, byte desp= 0)
{
	ASSERT (! hasdesp || (rb == reg_HL_ && prefix != NoPrefix) );

	switch (rb)
	{
	case regA: return "A";
	case regB: return "B";
	case regC: return "C";
	case regD: return "D";
	case regE: return "E";
	case regH:
		switch (prefix)
		{
		case NoPrefix: return "H";
		case prefixIX: return "IXH";
		case prefixIY: return "IYH";
		default:
			throw UnexpectedPrefix;
		}
	case regL:
		switch (prefix)
		{
		case NoPrefix: return "L";
		case prefixIX: return "IXL";
		case prefixIY: return "IYL";
		default:
			throw UnexpectedPrefix;
		}
	case reg_HL_:
		return nameIdesp (prefix, hasdesp, desp);
	default:
		ASSERT (false);
		throw UnexpectedRegisterCode;
	}
}


std::string tablabel (std::string str)
{
	const std::string::size_type l= str.size ();
	if (l < 8)
		str+= "\t\t";
	else
		if (l < 16)
			str+= '\t';
		else
			str+= ' ';
	return str;
}


//*********************************************************
//		Null ostream class.
//*********************************************************


class Nullbuff : public std::streambuf
{
public:
	Nullbuff ();
protected:
	int overflow (int);
	int sync ();
};

Nullbuff::Nullbuff ()
{
	setbuf (0, 0);
}

int Nullbuff::overflow (int)
{
	setp (pbase (), epptr () );
	return 0;
}

int Nullbuff::sync ()
{
	return 0;
}


class Nullostream : public std::ostream
{
public:
	Nullostream ();
private:
	Nullbuff buff;
};

Nullostream::Nullostream () :
	std::ostream (& buff)
{ }


//***********************************************
//		Auxiliary tables
//***********************************************


struct SimpleInst {
	byte code;
	bool edprefix;
	bool valid8080;
	address code86;
	SimpleInst (byte coden= 0,
			bool edprefixn= false,
			bool valid8080n= false,
			address code86n= 0) :
		code (coden),
		edprefix (edprefixn),
		valid8080 (valid8080n),
		code86 (code86n)
	{ }
};

typedef std::map <TypeToken, SimpleInst> simpleinst_t;
simpleinst_t simpleinst;

class InitSimple {
	InitSimple ();
	static InitSimple instance;
};

InitSimple InitSimple::instance;

InitSimple::InitSimple ()
{
	simpleinst [TypeCCF]=  SimpleInst (0x3F, false, true, 0x00F5);
	simpleinst [TypeCPD]=  SimpleInst (0xA9, true);
	simpleinst [TypeCPDR]= SimpleInst (0xB9, true);
	simpleinst [TypeCPI]=  SimpleInst (0xA1, true);
	simpleinst [TypeCPIR]= SimpleInst (0xB1, true);
	simpleinst [TypeCPL]=  SimpleInst (0x2F, false, true, 0xF6D0);
	simpleinst [TypeDAA]=  SimpleInst (0x27, false, true, 0x0027);
	simpleinst [TypeDI]=   SimpleInst (0xF3, false, true, 0x00FA);
	simpleinst [TypeEI]=   SimpleInst (0xFB, false, true, 0x00FB);
	simpleinst [TypeEXX]=  SimpleInst (0xD9);
	simpleinst [TypeHALT]= SimpleInst (0x76, false, true, 0x00F4);
	simpleinst [TypeIND]=  SimpleInst (0xAA, true);
	simpleinst [TypeINDR]= SimpleInst (0xBA, true);
	simpleinst [TypeINI]=  SimpleInst (0xA2, true);
	simpleinst [TypeINIR]= SimpleInst (0xB2, true);
	simpleinst [TypeLDD]=  SimpleInst (0xA8, true);
	simpleinst [TypeLDDR]= SimpleInst (0xB8, true);
	simpleinst [TypeLDI]=  SimpleInst (0xA0, true);
	simpleinst [TypeLDIR]= SimpleInst (0xB0, true);
	simpleinst [TypeNEG]=  SimpleInst (0x44, true);
	simpleinst [TypeNOP]=  SimpleInst (0x00, false, true, 0x0090);
	simpleinst [TypeOTDR]= SimpleInst (0xBB, true);
	simpleinst [TypeOTIR]= SimpleInst (0xB3, true);
	simpleinst [TypeOUTD]= SimpleInst (0xAB, true);
	simpleinst [TypeOUTI]= SimpleInst (0xA3, true);
	simpleinst [TypeSCF]=  SimpleInst (0x37, false, true, 0x00F9);
	simpleinst [TypeRETI]= SimpleInst (0x4D, true);
	simpleinst [TypeRETN]= SimpleInst (0x45, true);
	simpleinst [TypeRLA]=  SimpleInst (0x17, false, true, 0xD0D0);
	simpleinst [TypeRLCA]= SimpleInst (0x07, false, true, 0xD0C0);
	simpleinst [TypeRLD]=  SimpleInst (0x6F, true);
	simpleinst [TypeRRA]=  SimpleInst (0x1F, false, true, 0xD0D8);
	simpleinst [TypeRRCA]= SimpleInst (0x0F, false, true, 0xD0C8);
	simpleinst [TypeRRD]=  SimpleInst (0x67, true);
}


} // namespace


//*********************************************************
//			Macro class
//*********************************************************


namespace pasmo_impl {


class MacroBase {
protected:
	MacroBase ()
	{ }
	explicit MacroBase (std::vector <std::string> & param) :
		param (param)
	{ }
	explicit MacroBase (const std::string & sparam) :
		param (1)
	{
		param [0]= sparam;
	}
public:
	size_t getparam (const std::string & name) const;
	std::string getparam (size_t n) const;
	static const size_t noparam= size_t (-1);
private:
	std::vector <std::string> param;
};

size_t MacroBase::getparam (const std::string & name) const
{
	for (size_t i= 0; i < param.size (); ++i)
		if (name == param [i])
			return i;
	return noparam;
}

std::string MacroBase::getparam (size_t n) const
{
	if (n >= param.size () )
		return "(none)";
	return param [n];
}


class Macro : public MacroBase {
public:
	Macro (std::vector <std::string> & param,
			size_t linen, size_t endlinen) :
		MacroBase (param),
		line (linen),
		endline (endlinen)
	{ }
	size_t getline () const { return line; }
	size_t getendline () const { return endline; }
private:
	const size_t line;
	const size_t endline;
};


class MacroIrp : public MacroBase {
public:
	MacroIrp (const std::string & sparam) :
		MacroBase (sparam)
	{ }
};


class MacroRept : public MacroBase {
public:
	MacroRept () :
		MacroBase ()
	{ }
};


//*********************************************************
//		Local classes declarations.
//*********************************************************


enum Defined {
	NoDefined,
	DefinedDEFL,
	PreDefined, DefinedPass1, DefinedPass2
};

class VarData {
public:
	VarData (bool makelocal= false) :
		value (0),
		defined (NoDefined),
		local (makelocal)
	{ }
	VarData (address valuen, Defined definedn) :
		value (valuen),
		defined (definedn),
		local (false)
	{ }
	void set (address valuen, Defined definedn)
	{
		value= valuen;
		defined= definedn;
	}
	void clear ()
	{
		value= 0;
		defined= NoDefined;
	}
	address getvalue () const
	{
		return value;
	}
	Defined def () const
	{
		return defined;
	}
	bool islocal () const
	{
		return local;
	}
private:
	address value;
	Defined defined;
	bool local;
};


typedef std::map <std::string, VarData> mapvar_t;


class LocalLevel {
public:
	LocalLevel (Asm::In & asmin_n);
	virtual ~LocalLevel ();
	virtual bool is_auto () const;
	void add (const std::string & var);
private:
	Asm::In & asmin;
	mapvar_t saved;
	std::map <std::string, std::string> globalized;
};


class AutoLevel : public LocalLevel {
public:
	AutoLevel (Asm::In & asmin_n);
	bool is_auto () const;
};


class ProcLevel : public LocalLevel {
public:
	ProcLevel (Asm::In & asmin_n, size_t line);
	size_t getline () const;
private:
	size_t line;
};


class MacroLevel : public LocalLevel {
public:
	MacroLevel (Asm::In & asmin_n);
};


class LocalStack {
public:
	~LocalStack ();
	bool empty () const;
	void push (LocalLevel * level);
	LocalLevel * top ();
	void pop ();
private:
	typedef std::stack <LocalLevel *> st_t;
	st_t st;
};


class MacroFrameBase;


} // namespace pasmo_impl


using pasmo_impl::Macro;
using pasmo_impl::MacroIrp;
using pasmo_impl::MacroRept;

using pasmo_impl::Defined;
using pasmo_impl::NoDefined;
using pasmo_impl::DefinedDEFL;
using pasmo_impl::PreDefined;
using pasmo_impl::DefinedPass1;
using pasmo_impl::DefinedPass2;

using pasmo_impl::VarData;
using pasmo_impl::LocalLevel;
using pasmo_impl::AutoLevel;
using pasmo_impl::ProcLevel;
using pasmo_impl::LocalStack;


//*********************************************************
//		class Asm::In declaration
//*********************************************************


class Asm::In : public AsmFile {
public:
	In ();

	// This is not a copy constructor, it creates a new
	// instance copying the options and the AsmFile.
	explicit In (const Asm::In & in);

	~In ();

	void verbose ();
	void setdebugtype (DebugType type);
	void errtostdout ();
	void setbase (unsigned int addr);
	void caseinsensitive ();
	void autolocal ();
	void bracketonly ();
	void warn8080 ();
	void set86 ();
	void setpass3 ();

	void addpredef (const std::string & predef);
	void setheadername (const std::string & headername_n);

	void loadfile (const std::string & filename);
	void processfile ();

	int currentpass () const;

	// Object file generation.
	address getcodesize () const;
	void message_emit (const std::string & type);
	void writebincode (std::ostream & out);

	void emitobject (std::ostream & out);
	void emitplus3dos (std::ostream & out);
	void emittap (std::ostream & out);

	void writetzxcode (std::ostream & out);
	void emittzx (std::ostream & out);

	void writecdtcode (std::ostream & out);
	void emitcdt (std::ostream & out);

	std::string cpcbasicloader ();
	void emitcdtbas (std::ostream & out);

	std::string spectrumbasicloader ();

	void emittapbas (std::ostream & out);
	void emittzxbas (std::ostream & out);

	void emithex (std::ostream & out);
	void emitamsdos (std::ostream & out);

	void emitprl (std::ostream & out);
	void emitcmd (std::ostream & out);

	void emitmsx (std::ostream & out);
	void dumppublic (std::ostream & out);
	void dumpsymbol (std::ostream & out);
private:
	void operator = (const Asm::In &); // Forbidden.

	void setentrypoint (address addr);
	void checkendline (Tokenizer & tz);

	void gendata (byte data);
	void gendataword (address dataword);

	void showcode (const std::string & instruction);
	void gencode (byte code);
	void gencode (byte code1, byte code2);
	void gencode (byte code1, byte code2, byte code3);
	void gencode (byte code1, byte code2, byte code3, byte code4);
	void gencodeED (byte code);
	void gencodeword (address value);

	bool setvar (const std::string & varname,
		address value, Defined defined);
	address getvalue (const std::string & var,
		bool required, bool ignored);

	// Expression evaluation.

	bool isdefined (const std::string & varname);
	void parsevalue (Tokenizer & tz, address & result,
		bool required, bool ignored);
	void expectclose (Tokenizer & tz);
	void parseopen (Tokenizer & tz, address & result,
		bool required, bool ignored);

	void parsemuldiv (Tokenizer & tz, address & result,
		bool required, bool ignored);
	void parseplusmin (Tokenizer & tz, address & result,
		bool required, bool ignored);
	void parserelops (Tokenizer & tz, address & result,
		bool required, bool ignored);
	void parsenot (Tokenizer & tz, address & result,
		bool required, bool ignored);
	void parseand (Tokenizer & tz, address & result,
		bool required, bool ignored);
	void parseorxor (Tokenizer & tz, address & result,
		bool required, bool ignored);
	void parsebooland (Tokenizer & tz, address & result,
		bool required, bool ignored);
	void parseboolor (Tokenizer & tz, address & result,
		bool required, bool ignored);
	void parsehighlow (Tokenizer & tz, address & result,
		bool required, bool ignored);
	void parsecond (Tokenizer & tz, address & result,
		bool required, bool ignored);
	void parsebase (Tokenizer & tz, address & result,
		bool required, bool ignored);

	address parseexpr (bool required, const Token & tok, Tokenizer & tz);

	// Check required tokens.

	void expectcomma (Tokenizer & tz);
	void expectcloseindir (Tokenizer & tz, bool bracket);
	bool parseopenindir (Tokenizer & tz);
	void expectA (Tokenizer & tz);
	void expectC (Tokenizer & tz);

	void parseIF (Tokenizer & tz);
	void parseELSE (Tokenizer & tz);
	void parseENDIF (Tokenizer & tz);

	void parseline (Tokenizer & tz);
	void dopass ();

	bool parsesimple (Tokenizer & tz, Token tok);
	void parsegeneric (Tokenizer & tz, Token tok);

	void parseINCLUDE (Tokenizer & tz);
	void parseEndOfInclude (Tokenizer & tz);

	void parseORG (Tokenizer & tz,
		const std::string & label= std::string () );
	void parseEQU (Tokenizer & tz, const std::string & label);
	void parseDEFL (Tokenizer & tz, const std::string & label);

	bool setequorlabel (const std::string & name, address value);
	bool setdefl (const std::string & name, address value);
	void setlabel (const std::string & name);
	void parselabel (Tokenizer & tz, const std::string & name);

	void parseMACRO (Tokenizer & tz, const std::string & name,
		bool needcomma);
	byte parsedesp (Tokenizer & tz, bool bracket);

	// Aux error and warning functions.

	void emitwarning (const std::string & text);
	void no8080 ();
	void no86 ();

	// Z80 instructions.

	bool parsebyteparam (Tokenizer & tz, TypeToken tt,
		regbCode & regcode,
		byte & prefix, bool & hasdesp, byte & desp,
		byte prevprefix= NoPrefix);
	void dobyteinmediate (Tokenizer & tz, byte code,
		const std::string & instrname, byte prefix= NoPrefix);
	void dobyteparam (Tokenizer & tz, TypeByteInst ti);
	void dobyteparamCB (Tokenizer & tz, byte codereg,
		const std::string & instrname);
	void parseIM (Tokenizer & tz);
	void parseRST (Tokenizer & tz);

	void parseLDA_nn_ (Tokenizer & tz, bool bracket);
	void parseLDA_IrPlus_ (Tokenizer & tz, bool bracket, byte prefix);
	void parseLDA_ (Tokenizer & tz, bool bracket);
	void parseLDAr (regbCode rb);
	void parseLDA (Tokenizer & tz);

	void parseLDsimplen (Tokenizer & tz, regbCode regcode,
		byte prevprefix= NoPrefix);
	void parseLDsimple (Tokenizer & tz, regbCode regcode,
		byte prevprefix= NoPrefix);

	void parseLDdouble_nn_ (Tokenizer & tz, regwCode regcode,
		bool bracket, byte prefix= NoPrefix);
	void parseLDdoublenn (Tokenizer & tz,
		regwCode regcode, byte prefix= NoPrefix);
	void parseLDdouble (Tokenizer & tz, regwCode regcode,
		byte prefix= NoPrefix);
	void parseLDSP (Tokenizer & tz);

	void parseLD_IrPlus (Tokenizer & tz, bool bracket, byte prefix);
	void parseLD_nn_ (Tokenizer & tz, bool bracket);
	void parseLD_ (Tokenizer & tz, bool bracket);
	void parseLDIorR (Tokenizer & tz, byte code);
	void parseLD (Tokenizer & tz);

	void parseCP (Tokenizer & tz);
	void parseAND (Tokenizer & tz);
	void parseOR (Tokenizer & tz);
	void parseXOR (Tokenizer & tz);
	void parseRL (Tokenizer & tz);
	void parseRLC (Tokenizer & tz);
	void parseRR (Tokenizer & tz);
	void parseRRC (Tokenizer & tz);
	void parseSLA (Tokenizer & tz);
	void parseSRA (Tokenizer & tz);
	void parseSLL (Tokenizer & tz);
	void parseSRL (Tokenizer & tz);
	void parseSUB (Tokenizer & tz);
	void parseADDADCSBCHL (Tokenizer & tz, byte prefix, byte basecode);
	void parseADD (Tokenizer & tz);
	void parseADC (Tokenizer & tz);
	void parseSBC (Tokenizer & tz);

	void parsePUSHPOP (Tokenizer & tz, bool isPUSH);
	void parsePUSH (Tokenizer & tz);
	void parsePOP (Tokenizer & tz);

	void parseCALL (Tokenizer & tz);
	void parseRET (Tokenizer & tz);
	void parseJP_ (Tokenizer & tz, bool bracket);
	void parseJP (Tokenizer & tz);
	void parserelative (Tokenizer & tz, Token tok, byte code,
		const std::string instrname);
	void parseJR (Tokenizer & tz);
	void parseDJNZ (Tokenizer & tz);

	void parseINCDECdouble (Tokenizer & tz, bool isINC, regwCode reg,
		byte prefix= NoPrefix);
	void parseINCDECsimple (Tokenizer & tz, bool isINC, regbCode reg,
		byte prefix= NoPrefix, bool hasdesp= false, byte desp= 0);
	void parseINCDEC (Tokenizer & tz, bool isINC);
	void parseINC (Tokenizer & tz);
	void parseDEC (Tokenizer & tz);

	void parseEX (Tokenizer & tz);
	void parseIN (Tokenizer & tz);
	void parseOUT (Tokenizer & tz);
	void dobit (Tokenizer & tz, byte basecode, std::string instrname);
	void parseBIT (Tokenizer & tz);
	void parseRES (Tokenizer & tz);
	void parseSET (Tokenizer & tz);

	void parseDEFB (Tokenizer & tz);
	void parseDEFW (Tokenizer & tz);
	void parseDEFS (Tokenizer & tz);
	void parseINCBIN (Tokenizer & tz);
	void parsePUBLIC (Tokenizer & tz);
	void parseEND (Tokenizer & tz);
	void parseLOCAL (Tokenizer & tz);
	void parsePROC (Tokenizer & tz);
	void parseENDP (Tokenizer & tz);

	void parse_ERROR (Tokenizer & tz);
	void parse_WARNING (Tokenizer & tz);

	// Variables.

	std::string headername;

	bool nocase;
	bool autolocalmode;
	bool bracketonlymode;
	bool warn8080mode;
	GenCodeMode genmode;
	bool mode86;
	DebugType debugtype;

	byte mem [65536];
	address base;
	address current;
	address currentinstruction;
	address minused;
	address maxused;
	address entrypoint;
	bool hasentrypoint;
	int pass;
	int lastpass;
	size_t iflevel;

	// ********** Symbol tables ************

	typedef pasmo_impl::mapvar_t mapvar_t;
	mapvar_t mapvar;

	typedef std::set <std::string> setpublic_t;
	setpublic_t setpublic;

	// ********* Information streams ********

	Nullostream nullout;
	std::ostream * pout;
	std::ostream * perr;
	std::ostream * pverb;
	std::ostream * pwarn;

	// ********* Local **********

	friend class pasmo_impl::LocalLevel;

	size_t localcount;

	void initlocal ();
	std::string genlocalname ();

	LocalStack localstack;

	bool isautolocalname (const std::string & name);
	AutoLevel * enterautolocal ();
	void finishautolocal ();
	void checkautolocal (const std::string & varname);

	// ********* Macro **********

	typedef std::map <std::string, Macro> mapmacro_t;
	mapmacro_t mapmacro;

	Macro * getmacro (const std::string & name)
	{
		mapmacro_t::iterator it= mapmacro.find (name);
		if (it == mapmacro.end () )
			return NULL;
		else
			return & it->second;
	}

	bool gotoENDM ();
	void expandMACRO (const std::string & name,
		Macro macro, Tokenizer & tz);
	void parseREPT (Tokenizer & tz);
	void parseIRP (Tokenizer & tz);

	friend class pasmo_impl::MacroFrameBase;

	pasmo_impl::MacroFrameBase * pcurrentmframe;
	pasmo_impl::MacroFrameBase * getmframe () const
	{ return pcurrentmframe; }
	void setmframe (pasmo_impl::MacroFrameBase * pnew)
	{ pcurrentmframe= pnew; }

	// gencode control.

	bool firstcode;
};


//*********************************************************
//		Local classes definitions.
//*********************************************************


namespace pasmo_impl {


LocalLevel::LocalLevel (Asm::In & asmin_n) :
	asmin (asmin_n)
{ }

LocalLevel::~LocalLevel ()
{
	for (mapvar_t::iterator it= saved.begin ();
		it != saved.end ();
		++it)
	{
		const std::string locname= it->first;
		const std::string & globname= globalized [locname];
		asmin.mapvar [globname]= asmin.mapvar [locname];
		asmin.mapvar [locname]= it->second;
	}
}

bool LocalLevel::is_auto () const
{
	return false;
}

void LocalLevel::add (const std::string & var)
{
	// Ignore redeclarations as LOCAL
	// of the same identifier.
	if (saved.find (var) != saved.end () )
		return;

	saved [var]= asmin.mapvar [var];

	const std::string globname= asmin.genlocalname ();
	globalized [var]= globname;

	if (asmin.currentpass () == 1)
	{
		asmin.mapvar [var]= VarData (true);
	}
	else
	{
		asmin.mapvar [var]= asmin.mapvar [globname];
	}
}

AutoLevel::AutoLevel (Asm::In & asmin_n) :
	LocalLevel (asmin_n)
{ }

bool AutoLevel::is_auto () const
{
	return true;
}

ProcLevel::ProcLevel (Asm::In & asmin_n, size_t line) :
	LocalLevel (asmin_n),
	line (line)
{ }

size_t ProcLevel::getline () const
{
	return line;
}

MacroLevel::MacroLevel (Asm::In & asmin_n) :
	LocalLevel (asmin_n)
{ }

LocalStack::~LocalStack ()
{
	while (! st.empty () )
		pop ();
}

bool LocalStack::empty () const
{
	return st.empty ();
}

void LocalStack::push (LocalLevel * level)
{
	st.push (level);
}

LocalLevel * LocalStack::top ()
{
	if (st.empty () )
		throw LocalNotExist;
	return st.top ();
}

void LocalStack::pop ()
{
	if (st.empty () )
		throw LocalNotExist;
	delete st.top ();
	st.pop ();
}


} // namespace pasmo_impl


//*********************************************************
//		class Asm::In definitions
//*********************************************************


Asm::In::In () :
	AsmFile (),
	nocase (false),
	autolocalmode (false),
	bracketonlymode (false),
	warn8080mode (false),
	genmode (gen80),
	mode86 (false),
	debugtype (NoDebug),
	base (0),
	current (0),
	currentinstruction (0),
	minused (65535),
	maxused (0),
	hasentrypoint (false),
	pass (0),
	lastpass (2),
	pout (& cout),
	perr (& cerr),
	pverb (& nullout),
	pwarn (& cerr),
	localcount (0),
	pcurrentmframe (0)
{
}

Asm::In::In (const Asm::In & in) :
	AsmFile (in),
	headername (in.headername),
	nocase (in.nocase),
	autolocalmode (in.autolocalmode),
	bracketonlymode (in.bracketonlymode),
	warn8080mode (in.warn8080mode),
	genmode (in.genmode),
	mode86 (in.mode86),
	debugtype (in.debugtype),
	base (0),
	current (0),
	currentinstruction (0),
	minused (65535),
	maxused (0),
	hasentrypoint (false),
	pout (& cout),
	perr (in.perr),
	pverb (in.pverb),
	pwarn (in.pwarn),
	localcount (0),
	pcurrentmframe (0)
{
}

Asm::In::~In ()
{
}

void Asm::In::setheadername (const std::string & headername_n)
{
	headername= headername_n;
}

void Asm::In::verbose ()
{
	pverb= & cerr;
}

void Asm::In::setdebugtype (DebugType type)
{
	debugtype= type;
}

void Asm::In::errtostdout ()
{
	perr= & cout;
}

void Asm::In::setbase (unsigned int addr)
{
	if (addr > 65535)
		throw InvalidBaseValue;
	base= static_cast <address> (addr);
	current= base;
	currentinstruction= base;
}

void Asm::In::caseinsensitive ()
{
	nocase= true;
}

void Asm::In::autolocal ()
{
	autolocalmode= true;
}

void Asm::In::bracketonly ()
{
	bracketonlymode= true;
}

void Asm::In::warn8080 ()
{
	warn8080mode= true;
}

void Asm::In::set86 ()
{
	genmode= gen86;
	mode86= true;
}

void Asm::In::setpass3 ()
{
	lastpass= 3;
}

void Asm::In::addpredef (const std::string & predef)
{
	// Default value.
	address value= 0xFFFF;

	// Prepare the parsing of the argument.
	Tokenizer trdef (predef, nocase);

	// Get symbol name.
	Token tr (trdef.gettoken () );
	if (tr.type () != TypeIdentifier)
		throw InvalidPredefine;
	std::string varname= tr.str ();

	// Get the value, if any.
	tr= trdef.gettoken ();
	switch (tr.type () )
	{
	case TypeEqOp:
		tr= trdef.gettoken ();
		if (tr.type () != TypeNumber)
			throw InvalidPredefineValue;
		value= tr.num ();
		tr= trdef.gettoken ();
		if (tr.type () != TypeEndLine)
			throw InvalidPredefineValue;
		break;
	case TypeEndLine:
		break;
	default:
		throw InvalidPredefineSyntax;
	}

	* pverb << "Predefining: " << varname << "= " << value << endl;
	setequorlabel (varname, value);
}

void Asm::In::setentrypoint (address addr)
{
	if (pass < 2)
		return;
	if (hasentrypoint)
	{
		//* pwarn << "WARNING: Entry point redefined" << endl;
		emitwarning ("Entry point redefined");
	}
	hasentrypoint= true;
	entrypoint= addr;
}

void Asm::In::checkendline (Tokenizer & tz)
{
	Token tok= tz.gettoken ();
	if (tok.type () != TypeEndLine)
		throw EndLineExpected (tok);
}

void Asm::In::gendata (byte data)
{
	if (current < minused)
		minused= current;
	if (current > maxused)
		maxused= current;
	mem [current]= data;
	++current;
}

void Asm::In::gendataword (address dataword)
{
	gendata (lobyte (dataword) );
	gendata (hibyte (dataword) );
}

void Asm::In::showcode (const std::string & instruction)
{
	const address bytesperline= 4;

	address pos= currentinstruction;
	const address posend= current;
	bool instshowed= false;
	for (address i= 0; pos != posend; ++i, ++pos)
	{
		if ( (i % bytesperline) == 0)
		{
			if (i != 0)
			{
				if (! instshowed)
				{
					* pout << '\t' << instruction;
					instshowed= true;
				}
				* pout << '\n';
			}
			* pout << hex4 (pos) << ':';
		}
		* pout << hex2 (mem [pos] );
	}
	if (! instshowed)
	{
		if (posend == currentinstruction + 1)
			* pout << '\t';
		* pout << '\t' << instruction;
	}
	* pout << endl;

	// Check that the 64KB limit has not been exceeded in the
	// middle of an instruction.
	if (posend != 0 && posend < currentinstruction)
	{
		//* pwarn << "WARNING: 64KB limit passed inside instruction" <<
		//	endl;
		emitwarning ("64KB limit passed inside instruction");
	}
}

void Asm::In::gencode (byte code)
{
	gendata (code);
}

void Asm::In::gencode (byte code1, byte code2)
{
	gencode (code1);
	gencode (code2);
}

void Asm::In::gencode (byte code1, byte code2, byte code3)
{
	gencode (code1);
	gencode (code2);
	gencode (code3);
}

void Asm::In::gencode (byte code1, byte code2, byte code3, byte code4)
{
	gencode (code1);
	gencode (code2);
	gencode (code3);
	gencode (code4);
}

void Asm::In::gencodeED (byte code)
{
	gencode (0xED);
	gencode (code);
}

void Asm::In::gencodeword (address value)
{
	gencode (lobyte (value) );
	gencode (hibyte (value) );
}

bool Asm::In::setvar (const std::string & varname,
	address value, Defined defined)
{
	TRFDEBS ("Set '" << varname << "' to " << value);

	checkautolocal (varname);
	mapvar_t::iterator it= mapvar.find (varname);
	if (it != mapvar.end () )
	{
		// Testing detection of Phase error
		#if 1

		switch (defined)
		{
		case DefinedPass2:
			{
				address oldval= it->second.getvalue ();
				if (pass == lastpass && oldval != value)
				{
					if (pass == 2)
					{
						emitwarning ("Switching to 3 pass mode");
						lastpass= 3;
					}
					else
					{
					TRDEBS ("Phase change in '" <<
						varname << "' from " <<
						oldval << " to " <<
						value);
					throw PhaseError (varname);
					}
				}
			}
			break;
		default:
			/* Nothing */;
		}
		it->second.set (value, defined);

		#else

		it->second.set (value, defined);

		#endif
		return it->second.islocal ();
	}
	else
	{
		mapvar.insert (make_pair (varname,
			VarData (value, defined) ) );
		return false;
	}
}

address Asm::In::getvalue (const std::string & var,
	bool required, bool ignored)
{
	TRF;

	checkautolocal (var);

	VarData & vd= mapvar [var];
	if (vd.def () == NoDefined)
	{
		TRDEBS (var << " not yet defined");
		if ( (pass > 1 || required) && ! ignored)
			throw UndefinedVar (var);
		else
			return 0;
	}
	else
	{
		address r= vd.getvalue ();
		TRDEBS (var << " is " << r);
		return r;
	}
}

bool Asm::In::isdefined (const std::string & varname)
{
	bool result;
	checkautolocal (varname);

	Defined def= mapvar [varname].def ();
	if (def == NoDefined || (pass > 1 && def == DefinedPass1) )
		result= false;
	else
		result= true;

	return result;
}

void Asm::In::parsevalue (Tokenizer & tz, address & result,
	bool required, bool ignored)
{
	TRF;

	Token tok= tz.gettoken ();
	switch (tok.type () )
	{
	case TypeNumber:
		result= tok.num ();
		break;
	case TypeIdentifier:
		result= getvalue (tok.str (), required, ignored);
		break;
	case TypeDollar:
		result= currentinstruction;
		break;
	case TypeLiteral:
		if (tok.str ().size () != 1)
			throw Lenght1Required;
		result= tok.str () [0];
		break;
	case TypeNUL:
		tok= tz.gettoken ();
		if (tok.type () == TypeEndLine)
			result= addrTRUE;
		else
		{
			// Absorv the rest of the line.
			result= addrFALSE;
			do {
				tok= tz.gettoken ();
			} while (tok.type () != TypeEndLine);
		}
		break;
	case TypeDEFINED:
		tok= tz.gettoken ();
		if (tok.type () != TypeIdentifier)
			throw IdentifierExpected (tok);
		result= isdefined (tok.str () ) ? addrTRUE : addrFALSE;
		break;
	default:
		throw ValueExpected (tok);
	}
}

void Asm::In::expectclose (Tokenizer & tz)
{
	Token tok= tz.gettoken ();
	checktoken (TypeClose, tok);
}

void Asm::In::parseopen (Tokenizer & tz, address & result,
	bool required, bool ignored)
{
	Token tok= tz.gettoken ();
	if (tok.type () == TypeOpen)
	{
		parsebase (tz, result, required, ignored);
		expectclose (tz);
	}
	else
	{
		tz.ungettoken ();
		parsevalue (tz, result, required, ignored);
	}
}

void Asm::In::parsemuldiv (Tokenizer & tz, address & result,
	bool required, bool ignored)
{
	parseopen (tz, result, required, ignored);
	Token tok= tz.gettoken ();
	TypeToken tt= tok.type ();
	while (
		tt == TypeMult || tt == TypeDiv ||
		tt == TypeMOD || tt == TypeMod ||
		tt == TypeSHL || tt == TypeShlOp ||
		tt == TypeSHR || tt == TypeShrOp
		)
	{
		address guard;
		parseopen (tz, guard, required, ignored);
		switch (tt)
		{
		case TypeMult:
			result*= guard;
			break;
		case TypeDiv:
			if (guard == 0)
			{
				if ( (required || pass >= 2) && ! ignored)
					throw DivisionByZero;
				else
					result= 0;
			}
			else
				result/= guard;
			break;
		case TypeMOD:
		case TypeMod:
			if (guard == 0)
			{
				if ( (required || pass >= 2) && ! ignored)
					throw DivisionByZero;
				else
					result= 0;
			}
			else
				result%= guard;
			break;
		case TypeSHL:
		case TypeShlOp:
			result<<= guard;
			break;
		case TypeSHR:
		case TypeShrOp:
			result>>= guard;
			break;
		default:
			ASSERT (false);
			throw UnexpectedError;
		}
		tok= tz.gettoken ();
		tt= tok.type ();
	}
	tz.ungettoken ();
}

void Asm::In::parseplusmin (Tokenizer & tz, address & result,
	bool required, bool ignored)
{
	parsemuldiv (tz, result, required, ignored);
	Token tok= tz.gettoken ();
	TypeToken tt= tok.type ();
	while (tt == TypePlus || tt == TypeMinus)
	{
		address guard;
		parsemuldiv (tz, guard, required, ignored);
		switch (tt)
		{
		case TypePlus:
			result+= guard;
			break;
		case TypeMinus:
			result-= guard;
			break;
		default:
			ASSERT (false);
			throw UnexpectedError;
		}
		tok= tz.gettoken ();
		tt= tok.type ();
	}
	tz.ungettoken ();
}

void Asm::In::parserelops (Tokenizer & tz, address & result,
	bool required, bool ignored)
{
	parseplusmin (tz, result, required, ignored);
	Token tok= tz.gettoken ();
	TypeToken tt= tok.type ();
	while (
		tt == TypeEQ || tt == TypeEqOp ||
		tt == TypeLT || tt == TypeLtOp ||
		tt == TypeLE || tt == TypeLeOp ||
		tt == TypeGT || tt == TypeGtOp ||
		tt == TypeGE || tt == TypeGeOp ||
		tt == TypeNE || tt == TypeNeOp
		)
	{
		address guard;
		parseplusmin (tz, guard, required, ignored);
		switch (tt)
		{
		case TypeEQ:
		case TypeEqOp:
			result= (result == guard) ? addrTRUE : addrFALSE;
			break;
		case TypeLT:
		case TypeLtOp:
			result= (result < guard) ? addrTRUE : addrFALSE;
			break;
		case TypeLE:
		case TypeLeOp:
			result= (result <= guard) ? addrTRUE : addrFALSE;
			break;
		case TypeGT:
		case TypeGtOp:
			result= (result > guard) ? addrTRUE : addrFALSE;
			break;
		case TypeGE:
		case TypeGeOp:
			result= (result >= guard) ? addrTRUE : addrFALSE;
			break;
		case TypeNE:
		case TypeNeOp:
			result= (result != guard) ? addrTRUE : addrFALSE;
			break;
		default:
			ASSERT (false);
			throw UnexpectedError;
		}
		tok= tz.gettoken ();
		tt= tok.type ();
	}
	tz.ungettoken ();
}

void Asm::In::parsenot (Tokenizer & tz, address & result,
	bool required, bool ignored)
{
	Token tok= tz.gettoken ();
	TypeToken tt= tok.type ();
	// NOT and unary + and -.
	if (
		tt == TypeNOT || tt == TypeBitNotOp ||
		tt == TypeBoolNotOp ||
		tt == TypePlus || tt == TypeMinus
		)
	{
		parsenot (tz, result, required, ignored);
		switch (tt)
		{
		case TypeNOT:
		case TypeBitNotOp:
			result= ~ result;
			break;
		case TypeBoolNotOp:
			result= (result == 0) ? addrTRUE : addrFALSE;
			break;
		case TypePlus:
			break;
		case TypeMinus:
			result= - result;
			break;
		default:
			ASSERT (false);
			throw UnexpectedError;
		}
	}
	else
	{
		tz.ungettoken ();
		parserelops (tz, result, required, ignored);
	}
}

void Asm::In::parseand (Tokenizer & tz, address & result,
	bool required, bool ignored)
{
	parsenot (tz, result, required, ignored);
	Token tok= tz.gettoken ();
	TypeToken tt= tok.type ();
	while (tt == TypeAND || tt == TypeBitAnd)
	{
		address guard;
		parsenot (tz, guard, required, ignored);
		result&= guard;
		tok= tz.gettoken ();
		tt= tok.type ();
	}
	tz.ungettoken ();
}

void Asm::In::parseorxor (Tokenizer & tz, address & result,
	bool required, bool ignored)
{
	parseand (tz, result, required, ignored);
	Token tok= tz.gettoken ();
	TypeToken tt= tok.type ();
	while (tt == TypeOR || tt == TypeBitOr || tt == TypeXOR)
	{
		address guard;
		parseand (tz, guard, required, ignored);
		switch (tt)
		{
		case TypeOR:
		case TypeBitOr:
			result|= guard;
			break;
		case TypeXOR:
			result^= guard;
			break;
		default:
			ASSERT (false);
			throw UnexpectedError;
		}
		tok= tz.gettoken ();
		tt= tok.type ();
	}
	tz.ungettoken ();
}

void Asm::In::parsebooland (Tokenizer & tz, address & result,
	bool required, bool ignored)
{
	// Short-circuit evaluated boolean and operator.

	parseorxor (tz, result, required, ignored);
	Token tok= tz.gettoken ();
	if (tok.type () == TypeBoolAnd)
	{
		bool boolresult= result != 0;
		do
		{
			address guard;
			parseorxor (tz, guard, required,
				ignored || ! boolresult);
			boolresult&= guard != 0;
			tok= tz.gettoken ();
		} while (tok.type () == TypeBoolAnd);
		result= boolresult ? addrTRUE : addrFALSE;
	}
	tz.ungettoken ();
}

void Asm::In::parseboolor (Tokenizer & tz, address & result,
	bool required, bool ignored)
{
	// Short-circuit evaluated boolean or operator.

	parsebooland (tz, result, required, ignored);
	Token tok= tz.gettoken ();
	if (tok.type () == TypeBoolOr)
	{
		bool boolresult= result != 0;
		do
		{
			address guard;
			parsebooland (tz, guard, required,
				ignored || boolresult);
			boolresult|= guard != 0;
			tok= tz.gettoken ();
		} while (tok.type () == TypeBoolOr);
		result= boolresult ? addrTRUE : addrFALSE;
	}
	tz.ungettoken ();
}

void Asm::In::parsehighlow (Tokenizer & tz, address & result,
	bool required, bool ignored)
{
	Token tok= tz.gettoken ();
	switch (tok.type () )
	{
	case TypeHIGH:
		parsehighlow (tz, result, required, ignored);
		result= hibyte (result);
		break;
	case TypeLOW:
		parsehighlow (tz, result, required, ignored);
		result= lobyte (result);
		break;
	default:
		tz.ungettoken ();
		parseboolor (tz, result, required, ignored);
	}
}

void Asm::In::parsecond (Tokenizer & tz, address & result,
	bool required, bool ignored)
{
	parsehighlow (tz, result, required, ignored);
	Token tok= tz.gettoken ();
	if (tok.type () != TypeQuestion)
		tz.ungettoken ();
	else
	{
		bool usefirst= (result != 0);
		parsebase (tz, result, required, ignored || ! usefirst);

		tok= tz.gettoken ();
		checktoken (TypeColon, tok);

		address second;
		parsebase (tz, second, required, ignored || usefirst);
		if (! usefirst)
			result= second;
	}
}

void Asm::In::parsebase (Tokenizer & tz, address & result,
	bool required, bool ignored)
{
	// This funtions is just an auxiliar to minimize changes
	// when adding or modifying operators.

	parsecond (tz, result, required, ignored);
}

address Asm::In::parseexpr (bool required, const Token & /* tok */,
	Tokenizer & tz)
{
	TRF;

	tz.ungettoken ();
	address result;
	parsebase (tz, result, required, false);
	return result;
}

void Asm::In::expectcomma (Tokenizer & tz)
{
	Token tok= tz.gettoken ();
	checktoken (TypeComma, tok);
}

void Asm::In::expectcloseindir (Tokenizer & tz, bool bracket)
{
	Token tok= tz.gettoken ();
	if (bracket)
		checktoken (TypeCloseBracket, tok);
	else
		checktoken (TypeClose, tok);
}

bool Asm::In::parseopenindir (Tokenizer & tz)
{
	Token tok= tz.gettoken ();

	bool isbracket;
	if (bracketonlymode)
	{
		checktoken (TypeOpenBracket, tok);
		isbracket= true;
	}
	else
	{
		switch (tok.type () )
		{
		case TypeOpen:
			isbracket= false;
			break;
		case TypeOpenBracket:
			isbracket= true;
			break;
		default:
			throw SomeOpenExpected (tok);
		}
	}
	return isbracket;
}

void Asm::In::expectA (Tokenizer & tz)
{
	Token tok= tz.gettoken ();
	checktoken (TypeA, tok);
}

void Asm::In::expectC (Tokenizer & tz)
{
	Token tok= tz.gettoken ();
	checktoken (TypeC, tok);
}

void Asm::In::parseIF (Tokenizer & tz)
{
	address v;
	Token tok= tz.gettoken ();
	v= parseexpr (true, tok, tz);
	checkendline (tz);
	if (v != 0)
	{
		++iflevel;
		* pout << "\t\tIF (true)" << endl;
	}
	else
	{
		* pout << "\t\tIF (false)" << endl;
		size_t ifline= getline ();
		int level= 1;
		while (nextline () )
		{
			Tokenizer & tz (getcurrentline () );

			tok= tz.gettoken ();
			TypeToken tt= tok.type ();
			if (tt == TypeIdentifier)
			{
				tok= tz.gettoken ();
				tt= tok.type ();
			}
			switch (tt)
			{
			case TypeIF:
				++level;
				break;
			case TypeELSE:
				if (level == 1)
				{
					++iflevel;
					--level;
					* pout << "\t\tELSE (true)" << endl;
				}
				break;
			case TypeENDIF:
				--level;
				if (level == 0)
					* pout << "\t\tENDIF" << endl;
				break;
			case TypeENDM:
				// Let the current line be reexamined
				// for ending expandMACRO or emit an
				// error.
				prevline ();
				level= 0;
				break;
			case TypeMACRO:
			case TypeREPT:
			case TypeIRP:
				nextline ();
				gotoENDM ();
				break;
			default:
				* pout << "- " << getcurrenttext () << endl;
				break;
			}
			if (level == 0)
				break;
		}
		if (passeof () )
		{
			setline (ifline);
			throw IFwithoutENDIF;
		}
	}
}

void Asm::In::parseELSE (Tokenizer & tz)
{
	checkendline (tz);

	if (iflevel == 0)
		throw ELSEwithoutIF;

	* pout << "\t\tELSE (false)" << endl;

	size_t elseline= getline ();
	int level= 1;
	while (nextline () )
	{
		Tokenizer & tz (getcurrentline () );

		Token tok= tz.gettoken ();
		TypeToken tt= tok.type ();
		if (tt == TypeIdentifier)
		{
			tok= tz.gettoken ();
			tt= tok.type ();
		}
		switch (tt)
		{
		case TypeIF:
			++level;
			break;
		case TypeENDIF:
			--level;
			if (level == 0)
				* pout << "\t\tENDIF" << endl;
			break;
		case TypeENDM:
			// Let the current line be reexamined
			// for ending expandMACRO or emit an
			// error.
			prevline ();
			level= 0;
			break;
		case TypeMACRO:
		case TypeREPT:
		case TypeIRP:
			nextline ();
			gotoENDM ();
			break;
		default:
			* pout << "- " << getcurrenttext () << endl;
			break;
		}
		if (level == 0)
			break;
	}
	if (passeof () )
	{
		setline (elseline);
		throw ELSEwithoutENDIF;
	}
	--iflevel;
}

void Asm::In::parseENDIF (Tokenizer & tz)
{
	checkendline (tz);
	if (iflevel == 0)
		throw ENDIFwithoutIF;
	--iflevel;
	* pout << "\t\tENDIF" << endl;
}

void Asm::In::parseline (Tokenizer & tz)
{
	TRF;

	Token tok= tz.gettoken ();

	currentinstruction= current;
	switch (tok.type () )
	{
	case TypeINCLUDE:
		parseINCLUDE (tz);
		break;
	case TypeEndOfInclude:
		parseEndOfInclude (tz);
		break;
	case TypeORG:
		parseORG (tz);
		break;
	case TypeEQU:
		throw EQUwithoutlabel;
	case TypeDEFL:
		throw DEFLwithoutlabel;
	case TypeIdentifier:
		parselabel (tz, tok.str () );
		break;
	case TypeIF:
		parseIF (tz);
		break;
	case TypeELSE:
		parseELSE (tz);
		break;
	case TypeENDIF:
		parseENDIF (tz);
		break;
	case TypePUBLIC:
		parsePUBLIC (tz);
		break;
	case TypeMACRO:
		// Style: MACRO identifier, params
		tok= tz.gettoken ();
		if (tok.type () != TypeIdentifier)
			throw IdentifierExpected (tok);
		{
			const std::string & name= tok.str ();
			parseMACRO (tz, name, true); 
		}
		break;
	default:
		parsegeneric (tz, tok);
	}
}

void Asm::In::initlocal ()
{
	localcount= 0;
}

std::string Asm::In::genlocalname ()
{
	return hex8str (localcount++);
}

bool Asm::In::isautolocalname (const std::string & name)
{
	static const char AutoLocalPrefix= '_';
	ASSERT (! name.empty () );

	if (! autolocalmode)
		return false;
	return name [0] == AutoLocalPrefix;
}

AutoLevel * Asm::In::enterautolocal ()
{
	AutoLevel * pav;
	if (localstack.empty () || ! localstack.top ()->is_auto () )
	{
		* pout << "Enter autolocal level" << endl;
		pav= new AutoLevel (* this);
		localstack.push (pav);
	}
	else
	{
		pav= dynamic_cast <AutoLevel *> (localstack.top () );
		ASSERT (pav);
	}
	return pav;
}

void Asm::In::finishautolocal ()
{
	if (! localstack.empty () )
	{
		LocalLevel * plevel= localstack.top ();
		if (plevel->is_auto () )
		{
			if (autolocalmode)
			{
				* pout << "Exit autolocal level" << endl;
				localstack.pop ();
			}
			else
				throw AutoLocalNotExpected;
		}
	}
}

void Asm::In::checkautolocal (const std::string & varname)
{
	if (isautolocalname (varname) )
	{
		AutoLevel *pav= enterautolocal ();
		pav->add (varname);
	}
}


namespace pasmo_impl {


class ClearDefl {
public:
	void operator () (mapvar_t::value_type & vardef)
	{
		VarData & vd= vardef.second;
		if (vd.def () == DefinedDEFL)
			vd.clear ();
	}
};


} // namespace pasmo_impl


void Asm::In::dopass ()
{
	TRFDEBS ("Pass " << pass);

	* pverb << "Entering pass " << pass << endl;

	// Pass initializition.

	initlocal ();
	mapmacro.clear ();

	// Clear DEFL.
	std::for_each (mapvar.begin (), mapvar.end (),
		pasmo_impl::ClearDefl () );

	current= base;
	iflevel= 0;

	// Main loop.

	for (beginline (); nextline (); )
	{
		Tokenizer & tz (getcurrentline () );
		parseline (tz);
	}

	// Pass finalization.

	if (iflevel > 0)
		throw IFwithoutENDIF;

	finishautolocal ();

	if (! localstack.empty () )
	{
		ProcLevel * proc=
			dynamic_cast <ProcLevel *> (localstack.top () );
		if (proc == NULL)
			throw LocalNotExpected;
		setline (proc->getline () );
		throw UnbalancedPROC;
	}

	* pverb << "Pass " << pass << " finished" << endl;
}

void Asm::In::loadfile (const std::string & filename)
{
	AsmFile::loadfile (filename, nocase, * pverb, * perr);
}

void Asm::In::processfile ()
{
	TRF;

	try 
	{
		pass= 1;
		if (debugtype == DebugAll)
			pout= & cout;
		else
			pout= & nullout;
		dopass ();

		pass= 2;
		if (debugtype != NoDebug)
			pout= & cout;
		else
			pout= & nullout;
		dopass ();

		// Testing third pass
		if (lastpass > 2)
		{
			pass= 3;
			dopass ();
		}

		// Keep pout pointing to something valid.
		pout= & cout;
	}
	catch (...)
	{
		* perr << "ERROR";
		showcurrentlineinfo (* perr);
		* perr << endl;
		throw;
	}
}

int Asm::In::currentpass () const
{
	return pass;
}

bool Asm::In::parsesimple (Tokenizer & tz, Token tok)
{
	simpleinst_t::iterator it= simpleinst.find (tok.type () );
	if (it == simpleinst.end () )
		return false;

	checkendline (tz);

	const SimpleInst & si= it->second;
	if (mode86)
	{
		address code86= si.code86;
		if (code86 == 0)
			no86 ();
		byte code1= hibyte (code86);
		if (code1 != 0)
			gencode (code1);
		byte code2= lobyte (code86);
		gencode (code2);
	}
	else
	{
		if (si.edprefix)
			gencodeED (si.code);
		else
			gencode (si.code);
	}

	showcode (tok.str () );

	if (! si.valid8080)
		no8080 ();

	return true;
}

void Asm::In::parsegeneric (Tokenizer & tz, Token tok)
{
	TRF;

	firstcode= true;
	if (parsesimple (tz, tok) )
		return;

	TypeToken tt= tok.type ();
	switch (tt)
	{
	case TypeEndLine:
		// Do nothing.
		break;
	case TypeIdentifier:
		// Only come here legally when a line invoking
		// a macro contains a label.
		{
			std::string macroname= tok.str ();
			Macro * pmacro= getmacro (macroname);
			if (pmacro != NULL)
				expandMACRO (macroname, * pmacro, tz);
			else
				throw MacroExpected (macroname);
		}
		break;
	case TypeORG:
		ASSERT (false);
		throw UnexpectedORG;
	case TypeDEFB:
	case TypeDB:
	case TypeDEFM:
		parseDEFB (tz);
		break;
	case TypeDEFW:
	case TypeDW:
		parseDEFW (tz);
		break;
	case TypeDEFS:
	case TypeDS:
		parseDEFS (tz);
		break;
	case TypeINCBIN:
		parseINCBIN (tz);
		break;
	case TypeEND:
		parseEND (tz);
		break;
	case TypeLOCAL:
		parseLOCAL (tz);
		break;
	case TypePROC:
		parsePROC (tz);
		break;
	case TypeENDP:
		parseENDP (tz);
		break;
	case Type_ERROR:
		parse_ERROR (tz);
		break;
	case Type_WARNING:
		parse_WARNING (tz);
		break;
	case TypeMACRO:
		// Is processed previously.
		ASSERT (false);
		throw UnexpectedMACRO;
	case TypeREPT:
		parseREPT (tz);
		break;
	case TypeIRP:
		parseIRP (tz);
		break;
	case TypeENDM:
		throw ENDMOutOfMacro;
	case TypeIM:
		parseIM (tz);
		break;
	case TypeRST:
		parseRST (tz);
		break;
	case TypeLD:
		parseLD (tz);
		break;
	case TypeCP:
		parseCP (tz);
		break;
	case TypeAND:
		parseAND (tz);
		break;
	case TypeOR:
		parseOR (tz);
		break;
	case TypeXOR:
		parseXOR (tz);
		break;
	case TypeRL:
		parseRL (tz);
		break;
	case TypeRLC:
		parseRLC (tz);
		break;
	case TypeRR:
		parseRR (tz);
		break;
	case TypeRRC:
		parseRRC (tz);
		break;
	case TypeSLA:
		parseSLA (tz);
		break;
	case TypeSRA:
		parseSRA (tz);
		break;
	case TypeSRL:
		parseSRL (tz);
		break;
	case TypeSLL:
		parseSLL (tz);
		break;
	case TypeSUB:
		parseSUB (tz);
		break;
	case TypeADD:
		parseADD (tz);
		break;
	case TypeADC:
		parseADC (tz);
		break;
	case TypeSBC:
		parseSBC (tz);
		break;
	case TypePUSH:
		parsePUSH (tz);
		break;
	case TypePOP:
		parsePOP (tz);
		break;
	case TypeCALL:
		parseCALL (tz);
		break;
	case TypeRET:
		parseRET (tz);
		break;
	case TypeJP:
		parseJP (tz);
		break;
	case TypeJR:
		parseJR (tz);
		break;
	case TypeDJNZ:
		parseDJNZ (tz);
		break;
	case TypeDEC:
		parseDEC (tz);
		break;
	case TypeINC:
		parseINC (tz);
		break;
	case TypeEX:
		parseEX (tz);
		break;
	case TypeIN:
		parseIN (tz);
		break;
	case TypeOUT:
		parseOUT (tz);
		break;
	case TypeBIT:
		parseBIT (tz);
		break;
	case TypeRES:
		parseRES (tz);
		break;
	case TypeSET:
		parseSET (tz);
		break;
	case TypeEQU:
		throw EQUwithoutlabel;
	case TypeDEFL:
		throw DEFLwithoutlabel;
	case Type_SHIFT:
		throw ShiftOutsideMacro;
	default:
		throw NoInstruction (tok);
	}
}

void Asm::In::parseINCLUDE (Tokenizer & tz)
{
	std::string filename= tz.gettoken ().str ();
	* pout << "\t\tINCLUDE " << filename << endl;
}

void Asm::In::parseEndOfInclude (Tokenizer & /*tz*/)
{
	* pout << "\t\tEnd of INCLUDE" << endl;
}

void Asm::In::parseORG (Tokenizer & tz, const std::string & label)
{
	TRF;

	Token tok= tz.gettoken ();
	address org= parseexpr (true, tok, tz);
	current= org;

	* pout << "\t\tORG " << hex4 (org) << endl;

	if (! label.empty () )
		setlabel (label);
}

void Asm::In::parseEQU (Tokenizer & tz, const std::string & label)
{
	TRF;

	Token tok= tz.gettoken ();
	address value= parseexpr (false, tok, tz);
	checkendline (tz);
	bool islocal= setequorlabel (label, value);
	* pout << tablabel (label) << "EQU ";
	if (islocal)
		* pout << "local ";
	* pout << hex4 (value) << endl;
}

void Asm::In::parseDEFL (Tokenizer & tz, const std::string & label)
{
	Token tok= tz.gettoken ();
	address value= parseexpr (false, tok, tz);
	checkendline (tz);
	bool islocal= setdefl (label, value);
	* pout << label << "\t\tDEFL ";
	if (islocal)
		* pout << "local ";
	* pout << hex4 (value) << endl;
}

void Asm::In::parsePUBLIC (Tokenizer & tz)
{
	std::vector <std::string> varname;
	for (;;)
	{
		Token tok= tz.gettoken ();
		checktoken (TypeIdentifier, tok);

		std::string name= tok.str ();
		if (isautolocalname (name) )
			throw InvalidInAutolocal;

		setpublic.insert (name);
		varname.push_back (name);
		tok= tz.gettoken ();
		if (tok.type () == TypeEndLine)
			break;
		checktoken (TypeComma, tok);
	}
	* pout << "\t\tPUBLIC ";
	for (size_t i= 0, l= varname.size (); i < l; ++i)
	{
		* pout << varname [i];
		if (i < l - 1)
			* pout << ", ";
	}
	* pout << endl;
}

void Asm::In::parseEND (Tokenizer & tz)
{
	Token tok= tz.gettoken ();
	if (tok.type () == TypeEndLine)
		* pout << hex4 (current) << ":\t\tEND" << endl;
	else
	{
		address end= parseexpr (false, tok, tz);
		checkendline (tz);
		* pout << hex4 (current) << ":\t\tEND " << hex4 (end) << endl;
		setentrypoint (end);
	}
	setendline ();
}

void Asm::In::parseLOCAL (Tokenizer & tz)
{
	if (autolocalmode)
		finishautolocal ();

	LocalLevel * plocal= localstack.top ();
	std::vector <std::string> varname;
	for (;;)
	{
		Token tok= tz.gettoken ();
		checktoken (TypeIdentifier, tok);

		std::string name= tok.str ();
		if (isautolocalname (name) )
			throw InvalidInAutolocal;

		plocal->add (name);
		varname.push_back (name);
		tok= tz.gettoken ();
		TypeToken tt= tok.type ();
		if (tt == TypeEndLine)
			break;
		checktoken (TypeComma, tok);
	}
	* pout << "\t\tLOCAL ";
	for (size_t i= 0, l= varname.size (); i < l; ++i)
	{
		* pout << varname [i];
		if (i < l - 1)
			* pout << ", ";
	}
	* pout << endl;
}

void Asm::In::parsePROC (Tokenizer & tz)
{
	if (autolocalmode)
		finishautolocal ();

	checkendline (tz);
	ProcLevel * pproc= new ProcLevel (* this, getline () );
	localstack.push (pproc);

	* pout << "\t\tPROC" << endl;
}

void Asm::In::parseENDP (Tokenizer & tz)
{
	checkendline (tz);

	if (autolocalmode)
		finishautolocal ();

	if (localstack.empty () ||
		dynamic_cast <ProcLevel *> (localstack.top () ) == NULL)
	{
		throw UnbalancedENDP;
	}
	localstack.pop ();

	* pout << "\t\tENDP" << endl;
}

void Asm::In::parse_ERROR (Tokenizer & tz)
{
	Token tok= tz.gettoken ();
	ASSERT (tok.type () == TypeLiteral);
	throw ErrorDirective (tok);
}

void Asm::In::parse_WARNING (Tokenizer & tz)
{
	Token tok= tz.gettoken ();
	ASSERT (tok.type () == TypeLiteral);
	//* pwarn << "WARNING: " << tok.str () << endl;
	emitwarning (tok.str () );
}

bool Asm::In::setequorlabel (const std::string & name, address value)
{
	TRFDEBS ("Set '" << name << "' to " << value);

	if (autolocalmode)
	{
		if (isautolocalname (name) )
		{
			AutoLevel *pav= enterautolocal ();
			ASSERT (pav);
			pav->add (name);
		}
		else
			finishautolocal ();
	}

	switch (mapvar [name].def () )
	{
	case NoDefined:
		if (pass > 1)
			throw UndefinedInPass1 (name);
		// Else nothing to do.
		break;
	case DefinedDEFL:
		throw RedefinedDEFL;
	case PreDefined:
		throw IsPredefined;
	case DefinedPass1:
		if (pass == 1)
			throw RedefinedEQU;
		// Else nothing to do (this may chnage).
		break;
	case DefinedPass2:
		ASSERT (pass > 1);

		// Testing third pass
		#if 0
		throw RedefinedEQU;
		#else
		if (pass == 2)
			throw RedefinedEQU;
		#endif
	}
	Defined def;
	switch (pass)
	{
	case 0:
		def= PreDefined; break;
	case 1:
		def= DefinedPass1; break;
	case 2:
		def= DefinedPass2; break;
	case 3:
		// Testing third pass
		def= DefinedPass2; break;
	default:
		throw InvalidPassValue;
	}
	return setvar (name, value, def);
}

bool Asm::In::setdefl (const std::string & name, address value)
{
	if (autolocalmode)
	{
		if (isautolocalname (name) )
		{
			AutoLevel *pav= enterautolocal ();
			ASSERT (pav);
			pav->add (name);
		}
		else
			finishautolocal ();
	}

	switch (mapvar [name].def () )
	{
	case NoDefined:
		// Fine in this case.
		break;
	case DefinedDEFL:
		// Fine also.
		break;
	case PreDefined:
	case DefinedPass1:
	case DefinedPass2:
		throw RedefinedEQU;
	}
	return setvar (name, value, DefinedDEFL);
}

void Asm::In::setlabel (const std::string & name)
{
	bool islocal= setequorlabel (name, current);
	* pout << hex4 (current) << ":\t\t";
	if (islocal)
		* pout << "local ";
	* pout << "label " << name << endl;
}

void Asm::In::parselabel (Tokenizer & tz, const std::string & name)
{
	Token tok= tz.gettoken ();
	TypeToken tt= tok.type ();

	bool colon= tt == TypeColon;
	if (colon)
	{
		tok= tz.gettoken ();
		tt= tok.type ();
	}

	// Check required here to allow redefinition of macro.

	if (tt == TypeMACRO)
	{
		// Style: identifier MACRO params
		parseMACRO (tz, name, false);
		return;
	}

	if (! colon)
	{
		Macro * pmacro= getmacro (name);
		if (pmacro != NULL)
		{
			tz.ungettoken ();
			expandMACRO (name, * pmacro, tz);
			return;
		}
	}

	switch (tt)
	{
	case TypeORG:
		parseORG (tz, name);
		break;
	case TypeEQU:
		parseEQU (tz, name);
		break;
	case TypeDEFL:
		parseDEFL (tz, name);
		break;
	case TypeMACRO:
		// Style identifier MACRO params 
		//parseMACRO (tz, name);
		// Now can't come here.
		ASSERT (false);
		break;
	default:
		// In any other case, generic label. Assign the
		// current position to it and parse the rest
		// of the line.
		setlabel (name);
		parsegeneric (tz, tok);
	}
}

void Asm::In::parseMACRO (Tokenizer & tz, const std::string & name,
	bool needcomma)
{
	* pout << "Defining MACRO " << name << endl;
	ASSERT (! name.empty () );

	if (autolocalmode)
	{
		finishautolocal ();
		if (isautolocalname (name) )
			throw InvalidInAutolocal;
	}

	// Get parameter list.
	std::vector <std::string> param;
	Token tok= tz.gettoken ();
	TypeToken tt= tok.type ();
	if (tt != TypeEndLine)
	{
		if (needcomma)
		{
			checktoken (TypeComma, tok);
			tok= tz.gettoken ();
			tt= tok.type ();
		}
		for (;;)
		{
			checktoken (TypeIdentifier, tok);

			if (param.empty () )
				* pout << "Params: ";
			else
				* pout << ", ";
			* pout << tok.str ();

			param.push_back (tok.str () );
			tok= tz.gettoken ();
			tt= tok.type ();
			if (tt == TypeEndLine)
				break;
			tok= tz.gettoken ();
			tt= tok.type ();
		}
		* pout << endl;
	}
	else
		* pout << "No params." << endl;

	// Clear previous definition if exists.
	mapmacro_t::iterator it= mapmacro.find (name);
	if (it != mapmacro.end () )
		mapmacro.erase (it);

	// Skip macro body.
	size_t level= 1;
	size_t macroline= getline ();

	while (nextline () )
	{
		Tokenizer & tz (getcurrentline () );

		Token tok= tz.gettoken ();
		TypeToken tt= tok.type ();
		if (tt == TypeENDM)
		{
			if (--level == 0)
				break;
		}
		if (tt == TypeIdentifier)
		{
			tok= tz.gettoken ();
			tt= tok.type ();
		}
		if (tt == TypeMACRO || tt == TypeREPT || tt == TypeIRP)
			++level;
	}
	if (passeof () )
	{
		setline (macroline);
		throw MACROwithoutENDM;
	}

	// Store the macro definition.
	mapmacro.insert (make_pair (name,
		Macro (param, macroline, getline () ) ) );
}

byte Asm::In::parsedesp (Tokenizer & tz, bool bracket)
{
	byte desp= 0;
	Token tok= tz.gettoken ();
	switch (tok.type () )
	{
	case TypeClose:
		if (bracket)
			throw ParenInsteadOfBracket;
		break;
	case TypeCloseBracket:
		if (! bracket)
			throw BracketInsteadOfParen;
		break;
	case TypePlus:
		tok= tz.gettoken ();
		{
			address addr= parseexpr (false, tok, tz);
			// We allow positive greater than 127 just in
			// case someone uses hexadecimals such as 0FFh
			// as offsets.
			if (addr > 255)
				throw OffsetOutOfRange;
			desp= static_cast <byte> (addr);
			expectcloseindir (tz, bracket);
		}
		break;
	case TypeMinus:
		tok= tz.gettoken ();
		{
			address addr= parseexpr (false, tok, tz);
			if (addr > 128)
				throw OffsetOutOfRange;
			desp= static_cast <byte> (256 - addr);
			expectcloseindir (tz, bracket);
		}
		break;
	default:
		throw OffsetExpected (tok);
	}
	return desp;
}

void Asm::In::emitwarning (const std::string & text)
{
	* pwarn << "WARNING: " << text;
	showcurrentlineinfo (* pwarn);
	* pwarn << endl;
}

void Asm::In::no8080 ()
{
	if (warn8080mode)
	{
		//* pwarn << "WARNING: not a 8080 instruction";
		//showcurrentlineinfo (* pwarn);
		//* pwarn << endl;
		emitwarning ("not a 8080 instruction");
	}
}

void Asm::In::no86 ()
{
	if (mode86)
		throw NotValid86;
}

bool Asm::In::parsebyteparam (Tokenizer & tz, TypeToken tt,
	regbCode & regcode,
	byte & prefix, bool & hasdesp, byte & desp,
	byte prevprefix)
{
	// Used by dobyteparam, dobyteparamCB, parseLDsimple and
	// parseLD_IrPlus.

	ASSERT (prevprefix == NoPrefix ||
		prevprefix == prefixIX || prevprefix == prefixIY);

	prefix= NoPrefix;
	hasdesp= false;
	desp= 0;
	Token tok;
	switch (tt)
	{
	case TypeA:
		regcode= regA; break;
	case TypeB:
		regcode= regB; break;
	case TypeC:
		regcode= regC; break;
	case TypeD:
		regcode= regD; break;
	case TypeE:
		regcode= regE; break;
	case TypeH:
		regcode= regH; break;
	case TypeL:
		regcode= regL; break;
	case TypeIXH:
		if (prevprefix == prefixIY)
			throw InvalidInstruction;
		if (prevprefix == NoPrefix)
			prefix= prefixIX;
		regcode= regH;
		break;
	case TypeIYH:
		if (prevprefix == prefixIX)
			throw InvalidInstruction;
		if (prevprefix == NoPrefix)
			prefix= prefixIY;
		regcode= regH;
		break;
	case TypeIXL:
		if (prevprefix == prefixIY)
			throw InvalidInstruction;
		if (prevprefix == NoPrefix)
			prefix= prefixIX;
		regcode= regL;
		break;
	case TypeIYL:
		if (prevprefix == prefixIX)
			throw InvalidInstruction;
		if (prevprefix == NoPrefix)
			prefix= prefixIY;
		regcode= regL;
		break;
	case TypeOpen:
		if (bracketonlymode)
			return false;
	case TypeOpenBracket:
		{
			bool bracket= tt == TypeOpenBracket;
			tok= tz.gettoken ();
			switch (tok.type () )
			{
			case TypeHL:
				regcode= reg_HL_;
				expectcloseindir (tz, bracket);
				break;
			case TypeIX:
				regcode= reg_HL_;
				prefix= prefixIX;
				hasdesp= true;
				desp= parsedesp (tz, bracket);
				break;
			case TypeIY:
				regcode= reg_HL_;
				prefix= prefixIY;
				hasdesp= true;
				desp= parsedesp (tz, bracket);
				break;
			default:
				if (! bracket)
				{
					// Backtrack the parsing to the
					// beginning of the expression.
					tz.ungettoken ();
					return false;
				}
				else
					throw TokenExpected
						(TypeCloseBracket, tok);
			}
		}
		if (prevprefix != NoPrefix)
			throw InvalidInstruction;
		break;
	default:
		return false;
	}
	return true;
}

void Asm::In::dobyteinmediate (Tokenizer & tz, byte code,
	const std::string & instrname, byte prefix)
{
	// Used by dobyteparam and parseLDsimple.

	tz.ungettoken ();
	Token tok= tz.gettoken ();

	// Check for attempts to use inexistent instructions.
	// Thanks to Horace for the suggestion.

	bool check= (! bracketonlymode) && pass >= 2 &&
		tok.type () == TypeOpen;

	address value= parseexpr (false, tok, tz);
	checkendline (tz);

	if (check && tz.endswithparen () )
	{
		//* pwarn << "WARNING: looks like a non existent instruction";
		//showcurrentlineinfo (* pwarn);
		//* pwarn << endl;
		emitwarning ("looks like a non existent instruction");
	}

	if (prefix != NoPrefix)
	{
		if (prefix == prefixIX || prefix == prefixIY)
			no86 ();
		gencode (prefix);
	}

	byte bvalue= lobyte (value);
	gencode (code, bvalue);

	showcode (instrname + ' ' + hex2str (bvalue) );
}

void Asm::In::dobyteparam (Tokenizer & tz, TypeByteInst ti)
{
	// Used by CP, AND, OR, XOR, SUB, ADD A, ADC A and SBC A.

	Token tok= tz.gettoken ();
	regbCode reg;
	byte prefix= NoPrefix;
	bool hasdesp;
	byte desp;
	if (parsebyteparam (tz, tok.type (), reg, prefix, hasdesp, desp) )
	{
		checkendline (tz);
		if (prefix != NoPrefix)
		{
			no86 ();
			gencode (prefix);
		}
		if (mode86)
		{
			ASSERT (! hasdesp);
			byte basecode= getbaseByteInst (ti, gen86);
			byte code;
			if (reg == reg_HL_)
			{
				basecode+= 2;
				code= 7;
			}
			else
				code= 0xC0 |  (getregb86 (reg) << 3);
			gencode (basecode, code);
		}
		else
		{
			byte code= getbaseByteInst (ti, gen80) | reg;
			gencode (code);
		}
		if (hasdesp)
			gencode (desp);

		showcode (byteinstName (ti) + ' ' +
			getregbname (reg, prefix, hasdesp, desp) );
	}
	else
	{
		dobyteinmediate (tz, getByteInstInmediate (ti, genmode),
			byteinstName (ti) );
	}
	if (prefix != NoPrefix)
		no8080 ();
}

void Asm::In::dobyteparamCB (Tokenizer & tz, byte codereg,
	const std::string & instrname)
{
	// Used by RL, RLC, RR, RRC, SLA, SRA, SRL, SLL
	// and bit instructions.

	no86 ();
	Token tok= tz.gettoken ();
	regbCode reg;
	byte prefix;
	bool hasdesp;
	byte desp;
	if (parsebyteparam (tz, tok.type (), reg, prefix, hasdesp, desp) )
	{
		checkendline (tz);
		if (prefix != NoPrefix)
			gencode (prefix);
		gencode (0xCB);
		if (hasdesp)
			gencode (desp);
		byte code= codereg + reg;
		gencode (code);

		showcode (instrname + ' ' +
			getregbname (reg, prefix, hasdesp, desp) );
	}
	else
		throw InvalidOperand;
	no8080 ();
}

void Asm::In::parseIM (Tokenizer & tz)
{
	Token tok= tz.gettoken ();
	address v= parseexpr (true, tok, tz);
	byte code;
	switch (v)
	{
	case 0:
		code= 0x46; break;
	case 1:
		code= 0x56; break;
	case 2:
		code= 0x5E; break;
	default:
		throw InvalidValueIM;
	}
	checkendline (tz);

	no86 ();
	gencodeED (code);

	showcode (std::string ("IM ") + static_cast <char> ('0' + v) );

	no8080 ();
}

void Asm::In::parseRST (Tokenizer & tz)
{
	Token tok= tz.gettoken ();
	address addr= parseexpr (true, tok, tz);
	checkendline (tz);

	if (addr & ~ static_cast <address> (0x38) )
		throw InvalidValueRST;

	no86 ();

	byte baddr= lobyte (addr);
	byte code= codeRST00 + baddr;
	gencode (code);

	showcode ("RST " + hex2str (baddr) );
}

void Asm::In::parseLDA_nn_ (Tokenizer & tz, bool bracket)
{
	Token tok;
	address addr= parseexpr (false, tok, tz);
	expectcloseindir (tz, bracket);

	byte code= mode86 ? 0xA0 : 0x3A;
	gencode (code);
	gencodeword (addr);

	showcode ("LD A, (" + hex4str (addr) + ')');
}

void Asm::In::parseLDA_IrPlus_ (Tokenizer & tz, bool bracket, byte prefix)
{
	ASSERT (prefix == prefixIX || prefix == prefixIY);

	no86 ();
	byte desp= parsedesp (tz, bracket);
	gencode (prefix, 0x7E, desp);

	showcode ("LD A, (" + nameHLpref (prefix) + '+' +
		hex2str (desp) + ')');

	no8080 ();
}

void Asm::In::parseLDA_ (Tokenizer & tz, bool bracket)
{
	Token tok= tz.gettoken ();
	switch (tok.type () )
	{
	case TypeBC:
		expectcloseindir (tz, bracket);
		if (mode86)
		{
			// MOV SI,CX ; MOV AL,[SI]
			gencode (0x89, 0xCE, 0x8A, 0x04);
		}
		else
			gencode (0x0A);
		showcode ("LD A, (BC)");
		break;
	case TypeDE:
		expectcloseindir (tz, bracket);
		if (mode86)
		{
			// MOV SI,DX ; MOV AL,[SI]
			gencode (0x89, 0xD6, 0x8A, 0x04);
		}
		else
			gencode (0x1A);
		showcode ("LD A, (DE)");
		break;
	case TypeHL:
		expectcloseindir (tz, bracket);
		if (mode86)
			gencode (0x8A, 0x07);
		else
			gencode (0x7E);
		showcode ("LD A, (HL)");
		break;
	case TypeIX:
		parseLDA_IrPlus_ (tz, bracket, prefixIX);
		break;
	case TypeIY:
		parseLDA_IrPlus_ (tz, bracket, prefixIY);
		break;
	default:
		parseLDA_nn_ (tz, bracket);
	}
}

void Asm::In::parseLDAr (regbCode rb)
{
	if (mode86)
	{
		byte code= 0xC0 | (getregb86 (rb) << 3);
		gencode (0x88, code);
	}
	else
	{
		byte code= 0x78 + rb;
		gencode (code);
	}
	showcode ("LD A, " + getregbname (rb) );
}

void Asm::In::parseLDA (Tokenizer & tz)
{
	expectcomma (tz);
	Token tok= tz.gettoken ();
	TypeToken tt= tok.type ();
	regbCode rb= getregb (tt);
	if (rb != regbInvalid)
	{
		checkendline (tz);
		parseLDAr (rb);
		return;
	}

	bool valid8080= true;
	switch (tt)
	{
	case TypeI:
		no86 ();
		gencodeED (0x57);
		showcode ("LD A, I");
		valid8080= false;
		break;
	case TypeR:
		no86 ();
		gencodeED (0x5F);
		showcode ("LD A, R");
		valid8080= false;
		break;
	case TypeIXH:
		no86 ();
		gencode (prefixIX, 0x7C);
		showcode ("LD A, IXH");
		valid8080= false;
		break;
	case TypeIXL:
		no86 ();
		gencode (prefixIX, 0x7D);
		showcode ("LD A, IXL");
		valid8080= false;
		break;
	case TypeIYH:
		no86 ();
		gencode (prefixIY, 0x7C);
		showcode ("LD A, IYH");
		valid8080= false;
		break;
	case TypeIYL:
		no86 ();
		gencode (prefixIY, 0x7D);
		showcode ("LD A, IYL");
		valid8080= false;
		break;
	case TypeOpen:
		if (bracketonlymode)
		{
			parseLDsimplen (tz, regA);
			break;
		}
	case TypeOpenBracket:
		parseLDA_ (tz, tt == TypeOpenBracket);
		break;
	default:
		parseLDsimplen (tz, regA);
	}
	checkendline (tz);

	if (! valid8080)
		no8080 ();
}

void Asm::In::parseLDsimplen (Tokenizer & tz, regbCode regcode,
	byte prevprefix)
{
	if (prevprefix != NoPrefix)
		no86 ();
	byte code;
	if (mode86)
	{
		switch (regcode)
		{
		case reg_HL_:
			prevprefix= 0xC6;
			code= 0x07;
			break;
		default:
			code= 0xB0 + getregb86 (regcode);
		}
	}
	else
		code= (regcode << 3) + 0x06;
	std::string instrname= "LD " +
		getregbname (regcode, mode86 ? NoPrefix : prevprefix) + ',';
	dobyteinmediate (tz, code, instrname, prevprefix);
}

void Asm::In::parseLDsimple (Tokenizer & tz, regbCode regcode,
	byte prevprefix)
{
	ASSERT (prevprefix == NoPrefix ||
		prevprefix == prefixIX || prevprefix == prefixIY);

	expectcomma (tz);
	Token tok= tz.gettoken ();

	regbCode reg2;
	byte prefix= NoPrefix;
	bool hasdesp;
	byte desp;
	if (parsebyteparam
		(tz, tok.type (), reg2, prefix, hasdesp, desp, prevprefix) )
	{
		// LD r, (...) and LD r, r
		checkendline (tz);

		regbCode rr1= regcode;
		regbCode rr2= reg2;

		if (regcode == reg_HL_ && reg2 == reg_HL_)
			throw InvalidInstruction;
		if (prevprefix != NoPrefix && prefix != NoPrefix)
			throw InvalidInstruction;
		if (prefix)
		{
			no86 ();
			gencode (prefix);
		}
		if (prevprefix)
		{
			no86 ();
			gencode (prevprefix);
		}

		if (mode86)
		{
			ASSERT (! hasdesp);
			byte precode;
			byte code= 0xC0;
			if (reg2 == reg_HL_)
			{
				precode= 0x8A;
				code= 0x00;
				reg2= regH;
			}
			else if (regcode == reg_HL_)
			{
				precode= 0x88;
				code= 0x00;
				regcode= reg2;
				reg2= regH;
			}
			else
				precode= 0x8A;

			code+= (getregb86 (regcode) << 3) +
				getregb86 (reg2);
			gencode (precode, code);
		}
		else
		{
			byte code= 0x40 + (regcode << 3) + reg2;
			gencode (code);
		}

		if (hasdesp)
			gencode (desp);

		showcode ("LD " + getregbname (rr1, prevprefix) +
			", " + getregbname (rr2, prefix, hasdesp, desp) );
	}
	else
	{
		// LD r, n
		parseLDsimplen (tz, regcode, prevprefix);
	}
	if (prevprefix != NoPrefix || prefix != NoPrefix)
		no8080 ();
}

void Asm::In::parseLDdouble_nn_ (Tokenizer & tz, regwCode regcode,
	bool bracket, byte prefix)
{
	TRF;

	Token tok= tz.gettoken ();
	address value= parseexpr (false, tok, tz);
	expectcloseindir (tz, bracket);
	checkendline (tz);

	bool valid8080= false;
	switch (regcode)
	{
	case regBC:
		if (mode86)
			gencode (0x8B, 0x0E);
		else
			gencodeED (0x4B);
		gencodeword (value);
		break;
	case regDE:
		if (mode86)
			gencode (0x8B, 0x16);
		else
			gencodeED (0x5B);
		gencodeword (value);
		break;
	case regHL:
		if (prefix == NoPrefix)
			valid8080= true;
		else
		{
			no86 ();
			gencode (prefix);
		}
		if (mode86)
			gencode (0x8B, 0x1E);
		else
			gencode (0x2A);
		gencodeword (value);
		break;
	case regSP:
		if (mode86)
			gencode (0x8B, 0x26);
		else
			gencodeED (0x7B);
		gencodeword (value);
		break;
	default:
		ASSERT (false);
		throw UnexpectedRegisterCode;
	}

	showcode ("LD " + regwName (regcode, nameSP, prefix) +
		", (" + hex4str (value) + ')' );

	if (! valid8080)
		no8080 ();
}

void Asm::In::parseLDdoublenn (Tokenizer & tz,
	regwCode regcode, byte prefix)
{
	TRF;

	Token tok;
	address value= parseexpr (false, tok, tz);
	checkendline (tz);

	if (prefix != NoPrefix)
	{
		no86 ();
		gencode (prefix);
	}

	byte code;
	if (mode86)
		code= regcode + 0xB9;
	else
		code= regcode * 16 + 1;
	gencode (code);
	gencodeword (value);

	showcode ("LD " + regwName (regcode, nameSP, prefix) +
		", " + hex4str (value) );

	if (prefix != NoPrefix)
		no8080 ();
}

void Asm::In::parseLDdouble (Tokenizer & tz,
	regwCode regcode, byte prefix)
{
	TRF;

	ASSERT (regcode == regBC || regcode == regDE || regcode == regHL);
	ASSERT (regcode == regHL || prefix == NoPrefix);
	ASSERT (prefix == NoPrefix ||
		prefix == prefixIX || prefix == prefixIY);

	expectcomma (tz);
	Token tok= tz.gettoken ();
	TypeToken tt= tok.type ();

	if (tt == TypeOpenBracket ||
		(tt == TypeOpen && ! bracketonlymode) )
	{
		// LD rr,(nn)
		parseLDdouble_nn_ (tz, regcode, tt == TypeOpenBracket, prefix);
	}
	else
	{
		// LD rr,nn
		parseLDdoublenn (tz, regcode, prefix);
	}
}

void Asm::In::parseLDSP (Tokenizer & tz)
{
	expectcomma (tz);
	Token tok= tz.gettoken ();
	TypeToken tt= tok.type ();
	switch (tt)
	{
	case TypeHL:
		if (mode86)
			gencode (0x89, 0xDC);
		else
			gencode (0xF9);
		showcode ("LD SP, HL");
		break;
	case TypeIX:
		no86 ();
		gencode (prefixIX, 0xF9);
		showcode ("LD SP, IX");
		no8080 ();
		break;
	case TypeIY:
		no86 ();
		gencode (prefixIY, 0xF9);
		showcode ("LD SP, IY");
		no8080 ();
		break;
	case TypeOpen:
		if (bracketonlymode)
		{
			parseLDdoublenn (tz, regSP);
			break;
		}
	case TypeOpenBracket:
		parseLDdouble_nn_ (tz, regSP, tt == TypeOpenBracket);
		break;
	default:
		parseLDdoublenn (tz, regSP);
	}
	checkendline (tz);
}

void Asm::In::parseLD_IrPlus (Tokenizer & tz, bool bracket, byte prefix)
{
	ASSERT (prefix == prefixIX || prefix == prefixIY);

	byte desp= parsedesp (tz, bracket);
	expectcomma (tz);

	Token tok= tz.gettoken ();
	regbCode reg;
	byte secondprefix= NoPrefix;
	bool hasdesp;
	byte despnotused;
	if (parsebyteparam (tz, tok.type (), reg, secondprefix,
		hasdesp, despnotused) )
	{
		// LD (IX+des), r / LD (IY+des), r

		checkendline (tz);
		if (secondprefix != NoPrefix || hasdesp || reg == reg_HL_)
			throw InvalidOperand;
		no86 ();

		byte code= 0x70 + reg;
		gencode (prefix, code, desp);
		showcode ("LD " + nameIdesp (prefix, true, desp) + ", " +
			getregbname (reg) );
	}
	else
	{
		// LD (IX+des), n / LD (IY+des), n

		address addr= parseexpr (false, tok, tz);
		checkendline (tz);
		no86 ();

		byte n= lobyte (addr);
		gencode (prefix, 0x36, desp, n);
		showcode ("LD " + nameIdesp (prefix, true, desp) + ", " +
			hex2str (n) );
	}
	no8080 ();
}

void Asm::In::parseLD_nn_ (Tokenizer & tz, bool bracket)
{
	Token tok;
	address addr= parseexpr (false, tok, tz);
	expectcloseindir (tz, bracket);
	expectcomma (tz);
	tok= tz.gettoken ();
	byte code;
	byte prefix= NoPrefix;
	bool valid8080= true;
	switch (tok.type () )
	{
	case TypeA:
		code= mode86 ? 0xA2 : 0x32;
		break;
	case TypeBC:
		valid8080= false;
		if (mode86)
		{
			prefix= 0x89;
			code= 0x0E;
		}
		else
		{
			prefix= 0xED;
			code= 0x43;
		}
		break;
	case TypeDE:
		valid8080= false;
		if (mode86)
		{
			prefix= 0x89;
			code= 0x16;
		}
		else
		{
			prefix= 0xED;
			code= 0x53;
		}
		break;
	case TypeHL:
		if (mode86)
		{
			prefix= 0x89;
			code= 0x1E;
		}
		else
			code= 0x22;
		break;
	case TypeIX:
		no86 ();
		valid8080= false;
		prefix= prefixIX;
		code= 0x22;
		break;
	case TypeIY:
		no86 ();
		valid8080= false;
		prefix= prefixIY;
		code= 0x22;
		break;
	case TypeSP:
		valid8080= false;
		if (mode86)
		{
			prefix= 0x89;
			code= 0x26;
		}
		else
		{
			prefix= 0xED;
			code= 0x73;
		}
		break;
	default:
		throw InvalidOperand;
	}
	checkendline (tz);

	if (prefix != NoPrefix)
		gencode (prefix);
	gencode (code);
	gencodeword (addr);

	showcode ("LD (" + hex4str (addr) + "), " + tok.str () );

	if (! valid8080)
		no8080 ();
}

void Asm::In::parseLD_ (Tokenizer & tz, bool bracket)
{
	Token tok= tz.gettoken ();
	switch (tok.type () )
	{
	case TypeBC:
		expectcloseindir (tz, bracket);
		expectcomma (tz);
		expectA (tz);
		checkendline (tz);

		if (mode86)
		{
			// MOV SI,CX ; MOV [SI],AL
			gencode (0x89, 0xCE, 0x88, 0x04);
		}
		else
			gencode (0x02);
		showcode ("LD (BC), A");
		break;
	case TypeDE:
		expectcloseindir (tz, bracket);
		expectcomma (tz);
		expectA (tz);
		checkendline (tz);

		if (mode86)
		{
			// MOV SI,DX ; MOV [SI],AL
			gencode (0x89, 0xD6, 0x88, 0x04);
		}
		else
			gencode (0x12);
		showcode ("LD (DE), A");
		break;
	case TypeHL:
		expectcloseindir (tz, bracket);
		parseLDsimple (tz, reg_HL_);
		break;
	case TypeIX:
		parseLD_IrPlus (tz, bracket, prefixIX);
		break;
	case TypeIY:
		parseLD_IrPlus (tz, bracket, prefixIY);
		break;
	default:
		// LD (nn), ...
		parseLD_nn_ (tz, bracket);
	}
}

void Asm::In::parseLDIorR (Tokenizer & tz, byte code)
{
	ASSERT (code == codeLDIA || code == codeLDRA);

	expectcomma (tz);
	expectA (tz);
	checkendline (tz);

	no86 ();
	gencodeED (code);
	showcode (std::string ("LD ") +
		( (code == codeLDIA) ? 'I' : 'R' ) + ", A");
	no8080 ();
}

void Asm::In::parseLD (Tokenizer & tz)
{
	TRF;

	Token tok= tz.gettoken ();
	TypeToken tt= tok.type ();
	switch (tt)
	{
	case TypeA:
		parseLDA (tz);
		break;
	case TypeB:
		parseLDsimple (tz, regB);
		break;
	case TypeC:
		parseLDsimple (tz, regC);
		break;
	case TypeD:
		parseLDsimple (tz, regD);
		break;
	case TypeE:
		parseLDsimple (tz, regE);
		break;
	case TypeH:
		parseLDsimple (tz, regH);
		break;
	case TypeL:
		parseLDsimple (tz, regL);
		break;
	case TypeIXH:
		parseLDsimple (tz, regH, prefixIX);
		break;
	case TypeIYH:
		parseLDsimple (tz, regH, prefixIY);
		break;
	case TypeIXL:
		parseLDsimple (tz, regL, prefixIX);
		break;
	case TypeIYL:
		parseLDsimple (tz, regL, prefixIY);
		break;
	case TypeI:
		parseLDIorR (tz, codeLDIA);
		break;
	case TypeR:
		parseLDIorR (tz, codeLDRA);
		break;
	case TypeBC:
		parseLDdouble (tz, regBC);
		break;
	case TypeDE:
		parseLDdouble (tz, regDE);
		break;
	case TypeHL:
		parseLDdouble (tz, regHL);
		break;
	case TypeIX:
		parseLDdouble (tz, regHL, prefixIX);
		break;
	case TypeIY:
		parseLDdouble (tz, regHL, prefixIY);
		break;
	case TypeSP:
		parseLDSP (tz);
		break;
	case TypeOpen:
		if (bracketonlymode)
			throw InvalidOperand;
	case TypeOpenBracket:
		parseLD_ (tz, tt == TypeOpenBracket);
		break;
	default:
		throw InvalidOperand;
	}
}

void Asm::In::parseCP (Tokenizer & tz)
{
	dobyteparam (tz, tiCP);
}

void Asm::In::parseAND (Tokenizer & tz)
{
	dobyteparam (tz, tiAND);
}

void Asm::In::parseOR (Tokenizer & tz)
{
	dobyteparam (tz, tiOR);
}

void Asm::In::parseXOR (Tokenizer & tz)
{
	dobyteparam (tz, tiXOR);
}

void Asm::In::parseRL (Tokenizer & tz)
{
	dobyteparamCB (tz, 0x10, "RL");
}

void Asm::In::parseRLC (Tokenizer & tz)
{
	dobyteparamCB (tz, 0x00, "RLC");
}

void Asm::In::parseRR (Tokenizer & tz)
{
	dobyteparamCB (tz, 0x18, "RR");
}

void Asm::In::parseRRC (Tokenizer & tz)
{
	dobyteparamCB (tz, 0x08, "RRC");
}

void Asm::In::parseSLA (Tokenizer & tz)
{
	dobyteparamCB (tz, 0x20, "SLA");
}

void Asm::In::parseSRA (Tokenizer & tz)
{
	dobyteparamCB (tz, 0x28, "SRA");
}

void Asm::In::parseSRL (Tokenizer & tz)
{
	dobyteparamCB (tz, 0x38, "SRL");
}

void Asm::In::parseSLL (Tokenizer & tz)
{
	dobyteparamCB (tz, 0x30, "SLL");
}

void Asm::In::parseSUB (Tokenizer & tz)
{
	dobyteparam (tz, tiSUB);
}

void Asm::In::parseADDADCSBCHL (Tokenizer & tz, byte prefix, byte basecode)
{
	ASSERT (basecode == codeADDHL || basecode == codeADCHL ||
		basecode == codeSBCHL);
	ASSERT (basecode == codeADDHL || prefix == NoPrefix);
	ASSERT (prefix == NoPrefix ||
		prefix == prefixIX || prefix == prefixIY);

	expectcomma (tz);
	Token tok= tz.gettoken ();
	regwCode reg;
	switch (tok.type () )
	{
	case TypeBC:
		reg= regBC; break;
	case TypeDE:
		reg= regDE; break;
	case TypeHL:
		if (prefix != NoPrefix)
			throw InvalidOperand;
		reg= regHL; break;
	case TypeSP:
		reg= regSP; break;
	case TypeIX:
		if (prefix != prefixIX)
			throw InvalidOperand;
		reg= regHL;
		break;
	case TypeIY:
		if (prefix != prefixIY)
			throw InvalidOperand;
		reg= regHL;
		break;
	default:
		throw InvalidOperand;
	}
	checkendline (tz);
	if (prefix != NoPrefix)
	{
		no86 ();
		gencode (prefix);
	}
	if (mode86)
	{
		byte code;
		switch (basecode)
		{
		case codeADDHL:
			code= (reg << 3) + 0xCB;
			gencode (0x01, code);
			break;
		case codeADCHL:
			code= (reg << 3) + 0xCB;
			gencode (0x11, code);
			break;
		case codeSBCHL:
			code= (reg << 3) + 0xCB;
			gencode (0x19, code);
			break;
		default:
			ASSERT (false);
			throw UnexpectedRegisterCode;
		}
	}
	else
	{
		if (basecode == codeSBCHL || basecode == codeADCHL)
			gencode (0xED);
		byte code= (reg << 4) + basecode;
		gencode (code);
	}

	std::string aux;
	switch (basecode)
	{
	case codeADDHL: aux= "ADD"; break;
	case codeADCHL: aux= "ADC"; break;
	case codeSBCHL: aux= "SBC"; break;
	default:
		throw UnexpectedRegisterCode;
	}
	showcode (aux + ' ' + nameHLpref (prefix) + ", " +
		regwName (reg, nameSP, reg == regHL ? prefix : NoPrefix) );

	if (basecode == codeADCHL || basecode == codeSBCHL ||
		prefix != NoPrefix)
	{
		no8080 ();
	}
}

void Asm::In::parseADD (Tokenizer & tz)
{
	Token tok= tz.gettoken ();
	switch (tok.type () )
	{
	case TypeA:
		expectcomma (tz);
		dobyteparam (tz, tiADDA);
		break;
	case TypeHL:
		parseADDADCSBCHL (tz, NoPrefix, codeADDHL);
		return;
	case TypeIX:
		parseADDADCSBCHL (tz, prefixIX, codeADDHL);
		return;
	case TypeIY:
		parseADDADCSBCHL (tz, prefixIY, codeADDHL);
		return;
	default:
		throw InvalidOperand;
	}
}

void Asm::In::parseADC (Tokenizer & tz)
{
	Token tok= tz.gettoken ();
	switch (tok.type () )
	{
	case TypeA:
		expectcomma (tz);
		dobyteparam (tz, tiADCA);
		break;
	case TypeHL:
		parseADDADCSBCHL (tz, NoPrefix, codeADCHL);
		return;
	default:
		throw InvalidOperand;
	}
}

void Asm::In::parseSBC (Tokenizer & tz)
{
	Token tok= tz.gettoken ();
	switch (tok.type () )
	{
	case TypeA:
		expectcomma (tz);
		dobyteparam (tz, tiSBCA);
		break;
	case TypeHL:
		parseADDADCSBCHL (tz, NoPrefix, codeSBCHL);
		break;
	default:
		throw InvalidOperand;
	}
}

// Push and pop codes:
//	push bc -> C5
//	push de -> D5
//	push hl -> E5
//	push af -> F5
//	push ix -> DD E5
//	push iy -> FD E5
//	pop bc -> C1
//	pop de -> D1
//	pop hl -> E1
//	pop af -> F1
//	pop ix -> DD E1
//	pop iy -> FD E1

void Asm::In::parsePUSHPOP (Tokenizer & tz, bool isPUSH)
{
	Token tok= tz.gettoken ();
	byte code= 0;
	byte prefix= NoPrefix;

	switch (tok.type () )
	{
	case TypeBC:
		code= regBC;
		break;
	case TypeDE:
		code= regDE;
		break;
	case TypeHL:
		code= regHL;
		break;
	case TypeAF:
		code= regAF;
		break;
	case TypeIX:
		code= regHL;
		prefix= prefixIX;
		break;
	case TypeIY:
		code= regHL;
		prefix= prefixIY;
		break;
	default:
		throw InvalidOperand;
	}
	checkendline (tz);

	if (prefix != NoPrefix)
	{
		no86 ();
		gencode (prefix);
	}

	if (mode86)
		code= (code + 1) % 4;
	else
		code<<= 4;

	code+= mode86 ? (isPUSH ? 0x50 : 0x58 ) :
		isPUSH ? 0xC5 : 0xC1;

	if (code == 0x50) // PUSH AX
	{
		ASSERT (mode86 && isPUSH);
		// LAHF ; XCHG AL,AH
		gencode (0x9F, 0x86, 0xC4);
	}

	gencode (code);

	if (code == 0x50) // PUSH AX
	{
		ASSERT (mode86 && isPUSH);
		// XCHG AL,AH
		gencode (0x86, 0xC4);
	}
	if (code == 0x58) // POP AX
	{
		ASSERT (mode86 && ! isPUSH);
		// XCHG AL, AH ; SAHF
		gencode (0x86, 0xC4, 0x9E);
	}

	showcode (std::string (isPUSH ? "PUSH" : "POP") + ' ' + tok.str () );

	if (prefix != NoPrefix)
		no8080 ();
}

void Asm::In::parsePUSH (Tokenizer & tz)
{
	parsePUSHPOP (tz, true);
}

void Asm::In::parsePOP (Tokenizer & tz)
{
	parsePUSHPOP (tz, false);
}

// CALL codes
// call NN     -> CD
// call nz, NN -> C4
// call z, NN  -> CC
// call nc, NN -> D4
// call c, NN  -> DC
// call po, NN -> E4
// call pe, NN -> EC
// call p, NN  -> F4
// call m, NN  -> FC

void Asm::In::parseCALL (Tokenizer & tz)
{
	Token tok= tz.gettoken ();
	byte code;
	flagCode fcode= getflag (tok.type () );
	std::string flagname;
	if (fcode == flagInvalid)
	{
		if (mode86)
			code= 0xE8;
		else
			code= 0xCD;
	}
	else
	{
		flagname= tok.str ();
		if (mode86)
		{
			fcode= invertflag86 (getflag86 (fcode) );
			code= fcode | 0x70;
		}
		else
		{
			code= (fcode << 3) | 0xC4;
		}
		expectcomma (tz);
		tok= tz.gettoken ();
	}


	const address addr= parseexpr (false, tok, tz);
	checkendline (tz);

	if (mode86)
	{
		if (code == 0xE8)
		{
			address offset= addr - (currentinstruction + 3);
			gencode (0xE8);
			gencodeword (offset);
		}
		else
		{
			// Generate a conditional jump with the
			// opposite condition to the following
			// instruction, followed by a call to
			// the destination.
			address offset= addr - (currentinstruction + 5);
			gencode (code, 0x03, 0xE8);
			gencodeword (offset);
		}
	}
	else
	{
		gencode (code);
		gencodeword (addr);
	}

	showcode ("CALL " +
		(flagname.empty () ? emptystr : (flagname + ", ") ) +
		hex4str (addr) );
}

void Asm::In::parseRET (Tokenizer & tz)
{
	Token tok= tz.gettoken ();
	byte code;
	flagCode fcode= getflag (tok.type () );
	std::string flagname;
	if (fcode == flagInvalid)
	{
		code= mode86 ? 0xC3 : 0xC9;
	}
	else
	{
		flagname= tok.str ();
		if (mode86)
		{
			fcode= invertflag86 (getflag86 (fcode) );
			code= fcode | 0x70;
		}
		else
		{
			code= (fcode << 3) | 0xC0;
		}
	}
	checkendline (tz);


	if (mode86 && code != 0xC3)
	{
		// Generate a conditional jump with the opposite
		// condition to the following instruction,
		// followed by a RET.
		gencode (code, 0x01);
		code= 0xC3;
	}
	gencode (code);

	showcode ("RET" +
		(flagname.empty () ? emptystr : (" " + flagname) ) );
}

// JP codes
// jp NN     -> C3
// jp (hl)   -> E9
// jp nz, NN -> C2
// jp z,  NN -> CA
// jp nc, NN -> D2
// jp c, NN  -> DA
// jp po, NN -> E2
// jp pe, NN -> EA
// jp p, NN  -> F2
// jp m, NN  -> FA

void Asm::In::parseJP_ (Tokenizer & tz, bool bracket)
{
	Token tok= tz.gettoken ();
	byte prefix= NoPrefix;
	switch (tok.type () )
	{
	case TypeHL:
		break;
	case TypeIX:
		prefix= prefixIX;
		break;
	case TypeIY:
		prefix= prefixIY;
		break;
	default:
		throw InvalidOperand;
	}
	expectcloseindir (tz, bracket);
	checkendline (tz);
	if (prefix != NoPrefix)
	{
		no86 ();
		gencode (prefix);
	}
	if (mode86)
	{
		gencode (0xFF, 0xE3);
		showcode ("JP (HL)");
	}
	else
	{
		gencode (0xE9);
		showcode ("JP (" + nameHLpref (prefix) + ')');
	}

	if (prefix != NoPrefix)
		no8080 ();
}

void Asm::In::parseJP (Tokenizer & tz)
{
	Token tok= tz.gettoken ();
	TypeToken tt= tok.type ();
	if (tt == TypeOpenBracket)
	{
		parseJP_ (tz, true);
		return;
	}
	if (tt == TypeOpen && ! bracketonlymode)
	{
		parseJP_ (tz, false);
		return;
	}
	flagCode fcode= getflag (tt);
	byte code;
	std::string flagname;
	if (fcode == flagInvalid)
	{
		if (mode86)
			code= 0xE9;
		else
			code= 0xC3;
	}
	else
	{
		flagname= tok.str ();
		if (mode86)
		{
			fcode= invertflag86 (getflag86 (fcode) );
			code= fcode | 0x70;
		}
		else
			code= (fcode << 3) | 0xC2;
		expectcomma (tz);
		tok= tz.gettoken ();
	}

	const address addr= parseexpr (false, tok, tz);
	checkendline (tz);

	if (mode86)
	{
		if (code == 0xE9)
		{
			address offset= addr - (currentinstruction + 3);
			gencode (0xE9);
			gencodeword (offset);
		}
		else
		{
			// Generate a conditional jump with the
			// opposite condition to the following
			// instruction, followed by a jump to
			// the destination.
			// TODO: optimize this in cases that the
			// destination is known and is in range.
			address offset= addr - (currentinstruction + 5);
			gencode (code, 0x03, 0xE9);
			gencodeword (offset);
		}
	}
	else
	{
		gencode (code);
		gencodeword (addr);
	}

	showcode ("JP " + (flagname.empty () ? emptystr : flagname + ", ") +
		hex4str (addr) );
}

void Asm::In::parserelative (Tokenizer & tz, Token tok, byte code,
	const std::string instrname)
{
	// Use by JR and DJNZ.

	address addr= parseexpr (false, tok, tz);
	checkendline (tz);
	int dif= 0;
	if (pass >= 2)
	{
		dif= addr - (current + 2);
		if (dif > 127 || dif < -128)
		{
			* pout << "addr= " << addr <<
				" current= " << current <<
				" dif= " << dif << endl;
			throw RelativeOutOfRange;
		}
	}
	signed char reldesp = static_cast <signed char> (dif);

	gencode (code, reldesp);
	showcode (instrname + ' ' + hex4str (addr) );

	no8080 ();
}

void Asm::In::parseJR (Tokenizer & tz)
{
	Token tok= tz.gettoken ();
	byte code= 0;
	std::string instrname ("JR");
	flagCode fcode= getflag (tok.type () );
	if (fcode == flagInvalid)
	{
		code= mode86 ? 0xEB : 0x18;
	}
	else
	{
		instrname+= ' ';
		instrname+= tok.str ();
		instrname+= ',';
		if (fcode > flagC)
			throw InvalidFlagJR;
		if (mode86)
			code= 0x70 | getflag86 (fcode);
		else
			code= 0x20 | (fcode << 3);
		expectcomma (tz);
		tok= tz.gettoken ();
	}

	parserelative (tz, tok, code, instrname);
}

void Asm::In::parseDJNZ (Tokenizer & tz)
{
	Token tok= tz.gettoken ();
	if (! mode86)
	{
		parserelative (tz, tok, codeDJNZ, "DJNZ");
	}
	else
	{
		address addr= parseexpr (false, tok, tz);
		checkendline (tz);
		int dif= 0;
		if (pass >= 2)
		{
			dif= addr - (current + 4);
			if (dif > 127 || dif < -128)
			{
				* pout << "addr= " << addr <<
					" current= " << current <<
					" dif= " << dif << endl;
				throw RelativeOutOfRange;
			}
		}
		signed char reldesp = static_cast <signed char> (dif);

		// DEC CH ; JNZ  ...
		gencode (0xFE, 0xCD, 0x75, reldesp);

		showcode ("DJNZ" + hex4str (addr) );
	}
}

void Asm::In::parseINCDECsimple (Tokenizer & tz, bool isINC, regbCode reg,
	byte prefix, bool hasdesp, byte desp)
{
	ASSERT (prefix == NoPrefix ||
		prefix == prefixIX || prefix == prefixIY);

	byte code= mode86 ? (isINC ? 0xC0 : 0xC8) :
		isINC ? 04 : 05;
	if (mode86)
	{
		if (reg == reg_HL_)
			code= isINC ? 0x07 : 0x0F;
		else
			code+= getregb86 (reg);
	}
	else
		code+= reg << 3;
	
	checkendline (tz);

	if (prefix != NoPrefix)
	{
		no86 ();
		gencode (prefix);
	}
	if (mode86)
		gencode (0xFE);
	gencode (code);
	if (hasdesp)
		gencode (desp);

	showcode (std::string (isINC ? "INC" : "DEC") + ' ' +
		getregbname (reg, prefix, hasdesp, desp) );

	if (prefix != NoPrefix)
		no8080 ();
}

void Asm::In::parseINCDECdouble (Tokenizer & tz, bool isINC, regwCode reg,
	byte prefix)
{
	ASSERT (prefix == NoPrefix ||
		prefix == prefixIX || prefix == prefixIY);

	byte code= mode86 ? (isINC ? 0x41 : 0x49) :
		isINC ? 0x03 : 0x0B;
	if (mode86)
		code+= reg;
	else
		code+= reg << 4;
	
	checkendline (tz);

	if (prefix != NoPrefix)
	{
		no86 ();
		gencode (prefix);
	}
	gencode (code);
	showcode (std::string (isINC ? "INC" : "DEC") + ' ' +
		regwName (reg, nameSP, prefix) );

	if (prefix != NoPrefix)
		no8080 ();
}

void Asm::In::parseINCDEC (Tokenizer & tz, bool isINC)
{
	Token tok= tz.gettoken ();
	TypeToken tt= tok.type ();
	switch (tt)
	{
	case TypeA:
		parseINCDECsimple (tz, isINC, regA);
		break;
	case TypeB:
		parseINCDECsimple (tz, isINC, regB);
		break;
	case TypeC:
		parseINCDECsimple (tz, isINC, regC);
		break;
	case TypeD:
		parseINCDECsimple (tz, isINC, regD);
		break;
	case TypeE:
		parseINCDECsimple (tz, isINC, regE);
		break;
	case TypeH:
		parseINCDECsimple (tz, isINC, regH);
		break;
	case TypeL:
		parseINCDECsimple (tz, isINC, regL);
		break;
	case TypeIXH:
		parseINCDECsimple (tz, isINC, regH, prefixIX);
		break;
	case TypeIXL:
		parseINCDECsimple (tz, isINC, regL, prefixIX);
		break;
	case TypeIYH:
		parseINCDECsimple (tz, isINC, regH, prefixIY);
		break;
	case TypeIYL:
		parseINCDECsimple (tz, isINC, regL, prefixIY);
		break;
	case TypeBC:
		parseINCDECdouble (tz, isINC, regBC);
		break;
	case TypeDE:
		parseINCDECdouble (tz, isINC, regDE);
		break;
	case TypeHL:
		parseINCDECdouble (tz, isINC, regHL);
		break;
	case TypeIX:
		parseINCDECdouble (tz, isINC, regHL, prefixIX);
		break;
	case TypeIY:
		parseINCDECdouble (tz, isINC, regHL, prefixIY);
		break;
	case TypeSP:
		parseINCDECdouble (tz, isINC, regSP);
		break;
	case TypeOpen:
		if (bracketonlymode)
			throw InvalidOperand;
	case TypeOpenBracket:
		{
			bool bracket= tt == TypeOpenBracket;
			tok= tz.gettoken ();
			byte desp= 0;
			switch (tok.type () )
			{
			case TypeHL:
				expectcloseindir (tz, bracket);
				parseINCDECsimple (tz, isINC, reg_HL_);
				break;
			case TypeIX:
				desp= parsedesp (tz, bracket);
				parseINCDECsimple (tz, isINC, reg_HL_,
					prefixIX, true, desp);
				break;
			case TypeIY:
				desp= parsedesp (tz, bracket);
				parseINCDECsimple (tz, isINC, reg_HL_,
					prefixIY, true, desp);
				break;
			default:
				throw InvalidOperand;
			}
		}
		break;
	default:
		throw InvalidOperand;
	}
}

void Asm::In::parseINC (Tokenizer & tz)
{
	parseINCDEC (tz, true);
}

void Asm::In::parseDEC (Tokenizer & tz)
{
	parseINCDEC (tz, false);
}

void Asm::In::parseEX (Tokenizer & tz)
{
	Token tok= tz.gettoken ();
	TypeToken tt= tok.type ();
	switch (tt)
	{
	case TypeAF:
		expectcomma (tz);
		tok= tz.gettoken ();
		if (tok.type () != TypeAFp)
			throw InvalidOperand;
		no86 ();
		gencode (0x08);
		showcode ("EX AF, AF'");
		no8080 ();
		break;
	case TypeDE:
		expectcomma (tz);
		tok= tz.gettoken ();
		if (tok.type () != TypeHL)
			throw InvalidOperand;
		if (mode86)
			gencode (0x87, 0xD3);
		else
			gencode (0xEB);
		showcode ("EX DE, HL");
		break;
	case TypeOpen:
		if (bracketonlymode)
			throw InvalidOperand;
	case TypeOpenBracket:
		{
			bool bracket= tt == TypeOpenBracket;
			tok= tz.gettoken ();
			if (tok.type () != TypeSP)
				throw InvalidOperand;
			expectcloseindir (tz, bracket);
			expectcomma (tz);
			tok= tz.gettoken ();
			switch (tok.type () )
			{
			case TypeHL:
				// TODO: implement this for 8086
				no86 ();
				gencode (0xE3);
				showcode ("EX (SP), HL");
				break;
			case TypeIX:
				no86 ();
				gencode (prefixIX, 0xE3);
				showcode ("EX (SP), IX");
				no8080 ();
				break;
			case TypeIY:
				no86 ();
				gencode (prefixIY, 0xE3);
				showcode ("EX (SP), IY");
				no8080 ();
				break;
			default:
				throw InvalidOperand;
			}
		}
		break;
	default:
		throw InvalidOperand;
	}
	checkendline (tz);
}

void Asm::In::parseIN (Tokenizer & tz)
{
	Token tok= tz.gettoken ();
	byte code;
	switch (tok.type () )
	{
	case TypeB:
		code= 0x40; break;
	case TypeC:
		code= 0x48; break;
	case TypeD:
		code= 0x50; break;
	case TypeE:
		code= 0x58; break;
	case TypeH:
		code= 0x60; break;
	case TypeL:
		code= 0x68; break;
	case TypeA:
		expectcomma (tz);
		{
			bool bracket= parseopenindir (tz);
			tok= tz.gettoken ();
			if (tok.type () == TypeC)
			{
				no86 ();
				expectcloseindir (tz, bracket);
				gencodeED (0x78);
				showcode ("IN A, (C)");
				no8080 ();
			}
			else
			{
				address addr= parseexpr (false, tok, tz);
				byte b= static_cast <byte> (addr);
				code= mode86 ? 0xE4 : 0xDB;
				gencode (code, b);
				showcode ("IN A, (" + hex2str (b) + ')');
				expectcloseindir (tz, bracket);
			}
		}
		checkendline (tz);
		return;
	default:
		throw InvalidOperand;
	}

	std::string regname= tok.str ();
	expectcomma (tz);

	bool bracket= parseopenindir (tz);
	expectC (tz);
	expectcloseindir (tz, bracket);

	checkendline (tz);

	no86 ();

	gencodeED (code);
	showcode ("IN " + regname + ", (C)");

	no8080 ();
}

void Asm::In::parseOUT (Tokenizer & tz)
{
	bool bracket= parseopenindir (tz);
	Token tok= tz.gettoken ();
	if (tok.type () != TypeC)
	{
		address addr= parseexpr (false, tok, tz);
		byte b= static_cast <byte> (addr);
		expectcloseindir (tz, bracket);
		expectcomma (tz);
		expectA (tz);
		checkendline (tz);

		byte code= mode86 ? 0xE6 : 0xD3;
		gencode (code, b);
		showcode ("OUT (" + hex2str (b) + "), A");
		no8080 ();
		return;
	}

	expectcloseindir (tz, bracket);
	expectcomma (tz);
	tok= tz.gettoken ();
	byte code;
	switch (tok.type () )
	{
	case TypeA:
		code= 0x79; break;
	case TypeB:
		code= 0x41; break;
	case TypeC:
		code= 0x49; break;
	case TypeD:
		code= 0x51; break;
	case TypeE:
		code= 0x59; break;
	case TypeH:
		code= 0x61; break;
	case TypeL:
		code= 0x69; break;
	default:
		throw InvalidOperand;
	}
	std::string regname= tok.str ();
	checkendline (tz);

	no86 ();

	gencodeED (code);
	showcode ("OUT (C), " + regname);

	no8080 ();
}

void Asm::In::dobit (Tokenizer & tz, byte basecode, std::string instrname)
{
	Token tok= tz.gettoken ();
	address addr= parseexpr (false, tok, tz);
	if (addr > 7)
		throw BitOutOfRange;
	expectcomma (tz);
	instrname+= ' ';
	instrname+= '0' + addr;
	instrname+= ',';
	dobyteparamCB (tz, basecode + (addr << 3), instrname);
}

void Asm::In::parseBIT (Tokenizer & tz)
{
	dobit (tz, 0x40, "BIT");
}

void Asm::In::parseRES (Tokenizer & tz)
{
	dobit (tz, 0x80, "RES");
}

void Asm::In::parseSET (Tokenizer & tz)
{
	dobit (tz, 0xC0, "SET");
}

void Asm::In::parseDEFB (Tokenizer & tz)
{
	address count= 0;
	for (;;)
	{
		Token tok= tz.gettoken ();
		switch (tok.type () )
		{
		case TypeLiteral:
			{
				const std::string & str= tok.str ();
				const std::string::size_type l= str.size ();
				if (l == 1)
				{
					// Admit expressions like 'E' + 80H
					gendata (parseexpr (false, tok, tz) );
					++count;
					break;
				}
				for (std::string::size_type i= 0; i < l; ++i)
				{
					gendata (str [i] );
				}
				count= static_cast <address> (count + l);
			}
			break;
		default:
			gendata (parseexpr (false, tok, tz) );
			++count;
		}
		tok= tz.gettoken ();
		if (tok.type () == TypeEndLine)
			break;
		checktoken (TypeComma, tok);
	}

	ostringstream oss;
	oss << "DEFB of " << count << " bytes";
	showcode (oss.str () );
}

void Asm::In::parseDEFW (Tokenizer & tz)
{
	address count= 0;
	for (;;)
	{
		Token tok= tz.gettoken ();
		gendataword (parseexpr (false, tok, tz) );
		++count;
		tok= tz.gettoken ();
		if (tok.type () == TypeEndLine)
			break;
		checktoken (TypeComma, tok);
	}

	ostringstream oss;
	oss << "DEFW of " << count << " words";
	showcode (oss.str () );
}

void Asm::In::parseDEFS (Tokenizer & tz)
{
	Token tok= tz.gettoken ();
	address count= parseexpr (true, tok, tz);
	byte value= 0;
	tok= tz.gettoken ();
	if (tok.type () != TypeEndLine)
	{
		checktoken (TypeComma, tok);
		tok= tz.gettoken ();
		address calcvalue= parseexpr (false, tok, tz);
		checkendline (tz);
		value= static_cast <byte> (calcvalue);
	}
	for (address i= 0; i < count; ++i)
		gendata (value);

	ostringstream oss;
	oss << "DEFS of " << count << " bytes with value " << hex2 (value);
	showcode (oss.str () );
}

void Asm::In::parseINCBIN (Tokenizer & tz)
{
	std::string includefile= tz.getincludefile ();
	checkendline (tz);
	* pout << "\t\tINCBIN " << includefile << endl;

	std::ifstream f;
	openis (f, includefile, std::ios::in | std::ios::binary);

	char buffer [1024];
	for (;;)
	{
		f.read (buffer, sizeof (buffer) );
		for (std::streamsize i= 0, r= f.gcount (); i < r; ++i)
			gendata (static_cast <byte> (buffer [i] ) );
		if (! f)
		{
			if (f.eof () )
				break;
			else
				throw ErrorReadingINCBIN;
		}
	}
}


//*********************************************************
//		Macro expansions.
//*********************************************************


namespace pasmo_impl {


typedef std::vector <Token> MacroParam;
typedef std::vector <MacroParam> MacroParamList;

void getmacroparams (MacroParamList & params, Tokenizer & tz)
{
	for (;;)
	{
		Token tok= tz.gettoken ();
		TypeToken tt= tok.type ();
		if (tt == TypeEndLine)
			break;
		MacroParam param;
		while (tt != TypeEndLine && tt != TypeComma)
		{
			param.push_back (tok);
			tok= tz.gettoken ();
			tt= tok.type ();
		}
		params.push_back (param);
		if (tt == TypeEndLine)
			break;
	}
}

void substparam (Tokenizer & tz, const MacroParam & param)
{
	const size_t l= param.size ();
	for (size_t i= 0; i < l; ++i)
		tz.push_back (param [i] );
}

Tokenizer substmacroparams (const MacroBase & macro, Tokenizer & tz,
	const MacroParamList & params)
{
	Tokenizer r (tz.getnocase () );
	for (;;)
	{
		Token tok= tz.gettoken ();
		TypeToken tt= tok.type ();
		if (tt == TypeEndLine)
			break;
		if (tt != TypeIdentifier)
			r.push_back (tok);
		else
		{
			const std::string & name= tok.str ();
			size_t n= macro.getparam (name);
			if (n == Macro::noparam)
				r.push_back (tok);
			else
			{
				// If there are no sufficient parameters
				// expand to nothing.
				if (n < params.size () )
					substparam (r, params [n] );
			}
		}
	}
	return r;
}


} // namespace pasmo_impl


bool Asm::In::gotoENDM ()
{
	size_t level= 1;
	while (nextline () )
	{
		Tokenizer & tz (getcurrentline () );

		Token tok= tz.gettoken ();
		TypeToken tt= tok.type ();
		if (tt == TypeIdentifier)
		{
			tok= tz.gettoken ();
			tt= tok.type ();
		}
		if (tt == TypeENDM)
		{
			if (--level == 0)
				break;
		}
		if (tt == TypeMACRO || tt == TypeREPT || tt == TypeIRP)
			++level;
	}
	return true;
}



namespace pasmo_impl {


// Macro expansion control classes: create the MacroLevel, store some
// state info and restore things on destruction and do parameter
// substitutions.


class MacroFrameBase {
public:
	MacroFrameBase (Asm::In & asmin_n,
		const MacroBase & macro_n, MacroParamList & params_n);
	virtual ~MacroFrameBase ();
	size_t getexpline () const;
	virtual void shift ()= 0;
	virtual Tokenizer substparams (Tokenizer & tz);
	Tokenizer substparentparams (Tokenizer & tz);
protected:
	Asm::In & asmin;
	void do_shift ();
	void parentshift ();
private:
	const size_t expandline;
	const size_t previflevel;
	const MacroBase & macro;
	MacroParamList & params;
	MacroFrameBase * pprevmframe;
};

MacroFrameBase::MacroFrameBase (Asm::In & asmin_n,
		const MacroBase & macro_n, MacroParamList & params_n) :
	asmin (asmin_n),
	expandline (asmin.getline () ),
	previflevel (asmin.iflevel),
	macro (macro_n),
	params (params_n),
	pprevmframe (asmin.getmframe () )
{
	MacroLevel * pproc= new MacroLevel (asmin);
	asmin.localstack.push (pproc);

	// Ensure that an IF opened before is not closed
	// inside the macro expansion.
	asmin.iflevel= 0;

	asmin.setmframe (this);
}

MacroFrameBase::~MacroFrameBase ()
{
	// Clear the local frame, including unclosed PROCs and autolocals.
	while (dynamic_cast <MacroLevel *> (asmin.localstack.top () ) == NULL)
		asmin.localstack.pop ();
	asmin.localstack.pop ();

	// IF whitout ENDIF inside a macro are valid.
	asmin.iflevel= previflevel;

	asmin.setmframe (pprevmframe);
}


size_t MacroFrameBase::getexpline () const
{
	return expandline;
}

void MacroFrameBase::do_shift ()
{
	params.erase (params.begin () );
}

void MacroFrameBase::parentshift ()
{
	if (pprevmframe)
		pprevmframe->shift ();
	else
		throw ShiftOutsideMacro;
}

Tokenizer MacroFrameBase::substparams (Tokenizer & tz)
{
	return substmacroparams (macro, tz, params);
}

Tokenizer MacroFrameBase::substparentparams (Tokenizer & tz)
{
	if (pprevmframe)
		return pprevmframe->substparams (tz);
	else
		return tz;
}


class MacroFrameChild : public MacroFrameBase {
public:
	MacroFrameChild (Asm::In & asmin_n,
		const MacroBase & macro_n, MacroParamList & params_n);
	void shift ();
	Tokenizer substparams (Tokenizer & tz);
};

MacroFrameChild::MacroFrameChild (Asm::In & asmin_n,
		const MacroBase & macro_n, MacroParamList & params_n) :
	MacroFrameBase (asmin_n, macro_n, params_n)
{
}

void MacroFrameChild::shift ()
{
	parentshift ();
}

Tokenizer MacroFrameChild::substparams (Tokenizer & tz)
{
	//cerr << "Subst parent" << endl;
	Tokenizer tzaux (substparentparams (tz) );

	//cerr << "Subst this" << endl;
	return MacroFrameBase::substparams (tzaux);
}


class MacroFrameMacro : public MacroFrameBase {
public:
	MacroFrameMacro (Asm::In & asmin_n,
		const Macro & macro_n, MacroParamList & params_n);
	void shift ();
	Tokenizer substparams (Tokenizer & tz);
};

MacroFrameMacro::MacroFrameMacro (Asm::In & asmin_n,
		const Macro & macro_n, MacroParamList & params_n) :
	MacroFrameBase (asmin_n, macro_n, params_n)
{
}

void MacroFrameMacro::shift ()
{
	do_shift ();
}

Tokenizer MacroFrameMacro::substparams (Tokenizer & tz)
{
	// First do the parameter substitution.
	Tokenizer tzaux (MacroFrameBase::substparams (tz) );

	// Then look for ##.
	Tokenizer tzr;
	Token tok;
	TypeToken tt;
	Token last (TypeUndef);
	while ( (tt= (tok= tzaux.gettoken () ).type () ) != TypeEndLine)
	{
		if (tt == TypeSharpSharp)
		{
			if (last.type () == TypeUndef)
				throw InvalidSharpSharp;
			std::string str (last.str () );
			tok= tzaux.gettoken ();
			if (tok.type () == TypeEndLine)
				throw InvalidSharpSharp;
			str+= tok.str ();
			last= Token (TypeIdentifier, str);
		}
		else
		{
			if (last.type () != TypeUndef)
				tzr.push_back (last);
			last= tok;
		}
	}
	if (last.type () != TypeUndef)
		tzr.push_back (last);
	return tzr;
}

} // namespace pasmo_impl


using pasmo_impl::MacroParam;
using pasmo_impl::MacroParamList;
using pasmo_impl::getmacroparams;
using pasmo_impl::MacroFrameChild;
using pasmo_impl::MacroFrameMacro;



void Asm::In::expandMACRO (const std::string & name,
	Macro macro, Tokenizer & tz)
{
	* pout << "Expanding MACRO " << name << endl;

	// Get parameters.
	MacroParamList params;
	getmacroparams (params, tz);
	checkendline (tz); // Redundant, for debugging.

	for (size_t i= 0; i < params.size (); ++i)
	{
		* pout << macro.getparam (i) << "= ";
		const MacroParam & p= params [i];
		std::copy (p.begin (), p.end (),
			std::ostream_iterator <Token> (* pout, " ") );
		* pout << endl;
	}

	// Set the local frame.
	MacroFrameMacro mframe (* this, macro, params);

	// Do the expansion,
	try
	{
		bool noexit= true;
		for (setline (macro.getline () ); noexit && nextline (); )
		{
			Tokenizer & tz (getcurrentline () );
			* pout << tz << endl;

			Token tok= tz.gettoken ();
			TypeToken tt= tok.type ();
			switch (tt)
			{
			case TypeENDM:
			case TypeEXITM:
				noexit= false;
				* pout << "\t\t" << tok.str () << endl;
				break;
			case Type_SHIFT:
				checkendline (tz);
				mframe.shift ();
				break;
			default:
				tz.ungettoken ();

				Tokenizer tzsubst (mframe.substparams (tz) );
				//* pout << tzsubst << endl;

				parseline (tzsubst);
			}
		}
		if (passeof () )
			throw MACROLostENDM;
	}
	catch (...)
	{
		* perr << "ERROR expanding macro";
		showlineinfo (* perr, mframe.getexpline () );
		* perr << endl;
		throw;
	}

	setline (mframe.getexpline () );

	* pout << "End of MACRO " << name << endl;
}

void Asm::In::parseREPT (Tokenizer & tz)
{
	Token tok= tz.gettoken ();
	const address numrep= parseexpr (true, tok, tz);

	// Adding new option for counter variable.
	//checkendline (tz);

	std::string varcounter;
	address valuecounter= 0;
	address step= 1;

	tok= tz.gettoken ();
	if (tok.type () != TypeEndLine)
	{
		checktoken (TypeComma, tok);
		tok= tz.gettoken ();
		checktoken (TypeIdentifier, tok);
		varcounter= tok.str ();

		tok= tz.gettoken ();
		if (tok.type () != TypeEndLine)
		{
			checktoken (TypeComma, tok);
			tok= tz.gettoken ();
			valuecounter= parseexpr (true, tok, tz);
			tok= tz.gettoken ();
			if (tok.type () != TypeEndLine)
			{
				checktoken (TypeComma, tok);
				tok= tz.gettoken ();
				step= parseexpr (true, tok, tz);
				checkendline (tz);
			}
		}

		if (isautolocalname (varcounter) )
			throw InvalidInAutolocal;
	}

	* pout << "\t\tREPT " << numrep << endl;

	if (numrep == 0)
	{
		if (! gotoENDM () )
			throw REPTwithoutENDM;
		return;
	}

	// Set the local frame.
	MacroRept macro;
	MacroParamList params;
	MacroFrameChild mframe (* this, macro, params);

	// Create counter local var.
	if (! varcounter.empty () )
	{
		localstack.top ()->add (varcounter);
		setdefl (varcounter, valuecounter);
	}

	const address lastrep= numrep - 1;
	bool endrep= false;
	for (address i= 0; i < numrep; ++i)
	{
		bool noendblock= true;
		for (setline (mframe.getexpline () );
			noendblock && nextline (); )
		{
			Tokenizer & tz (getcurrentline () );

			tok= tz.gettoken ();
			TypeToken tt= tok.type ();
			switch (tt)
			{
			case TypeENDM:
				if (i == lastrep)
				{
					* pout << "\t\tENDM" << endl;
					endrep= true;
				}
				noendblock= false;
				break;
			case TypeEXITM:
				if (! gotoENDM () )
					throw REPTwithoutENDM;
				* pout << "\t\tEXITM" << endl;
				noendblock= false;
				endrep= true;
				break;
			case Type_SHIFT:
				checkendline (tz);
				mframe.shift ();
				break;
			default:
				tz.ungettoken ();

				Tokenizer tzsubst (mframe.substparams (tz) );
				//* pout << tzsubst << endl;

				parseline (tzsubst);
			}
		}
		if (passeof () )
		{
			setline (mframe.getexpline () );
			throw REPTwithoutENDM;
		}
		if (endrep)
			break;
		if (! varcounter.empty () )
		{
			valuecounter+= step;
			setdefl (varcounter, valuecounter);
		}
	}
}

void Asm::In::parseIRP (Tokenizer & tz)
{
	Token tok= tz.gettoken ();
	checktoken (TypeIdentifier, tok);
	const std::string arg= tok.str ();

	MacroIrp macroirp (arg);

	expectcomma (tz);
	MacroParamList params;
	getmacroparams (params, tz);
	checkendline (tz); // Redundant, for debugging.
	if (params.empty () )
		throw IRPWithoutParameters;

	* pout << "\t\tIRP" << endl;

	// Set the local frame.
	MacroParamList actualparam (1);
	MacroFrameChild mframe (* this, macroirp, actualparam);

	const size_t irpnlast= params.size () - 1;
	bool endirp= false;
	for (size_t irpn= 0; irpn < params.size (); ++irpn)
	{
		bool noendblock= true;
		actualparam [0]= params [irpn];
		for (setline (mframe.getexpline () );
			noendblock && nextline (); )
		{
			Tokenizer & tz (getcurrentline () );

			tok= tz.gettoken ();
			TypeToken tt= tok.type ();
			switch (tt)
			{
			case TypeENDM:
				if (irpn == irpnlast)
				{
					* pout << "\t\tENDM" << endl;
					endirp= true;
				}
				noendblock= false;
				break;
			case TypeEXITM:
				if (! gotoENDM () )
					throw IRPwithoutENDM;
				* pout << "\t\tEXITM" << endl;
				noendblock= false;
				endirp= true;
				break;
			case Type_SHIFT:
				checkendline (tz);
				mframe.shift ();
				break;
			default:
				tz.ungettoken ();

				Tokenizer tzsubst (mframe.substparams (tz) );
				* pout << tzsubst << endl;

				parseline (tzsubst);
			}
		}

		if (passeof () )
		{
			setline (mframe.getexpline () );
			throw IRPwithoutENDM;
		}
		if (endirp)
			break;
	}
}


//*********************************************************
//		Object file generation.
//*********************************************************


void Asm::In::message_emit (const std::string & type)
{
	if (debugtype != NoDebug)
		* pout << "Emiting " << type << " from " <<
			hex4 (minused) << " to " << hex4 (maxused) <<
			endl;
}

address Asm::In::getcodesize () const
{
	return maxused - minused + 1;
}

void Asm::In::writebincode (std::ostream & out)
{
	out.write (reinterpret_cast <char *> (mem + minused), getcodesize ());
}

void Asm::In::emitobject (std::ostream & out)
{
	message_emit ("raw binary");

	for (int i= minused; i <= maxused; ++i)
	{
		out.put (mem [i] );
	}
}

void Asm::In::emitplus3dos (std::ostream & out)
{
	message_emit ("PLUS3DOS");

	address codesize= getcodesize ();

	spectrum::Plus3Head head;
	head.setsize (codesize);
	head.setstart (minused);
	head.write (out);

	// Write code.
	writebincode (out);

	// Write rounding to 128 byte block.
	size_t round= 128 - (codesize % 128);
	if (round != 128)
	{
		char aux [128]= {};
		out.write (aux, round);
	}

	if (! out)
		throw ErrorOutput;
}

void Asm::In::emittap (std::ostream & out)
{
	message_emit ("TAP");

	// Pepare data needed.
	address codesize= getcodesize ();
	tap::CodeHeader headcodeblock (minused, codesize, headername);
	tap::CodeBlock codeblock (codesize, mem + minused);

	// Write the file.
	headcodeblock.write (out);
	codeblock.write (out);

	if (! out)
		throw ErrorOutput;
}

void Asm::In::writetzxcode (std::ostream & out)
{
	// Preapare data needed.

	address codesize= getcodesize ();
	tap::CodeHeader block1 (minused, codesize, headername);
	tap::CodeBlock block2 (codesize, mem + minused);

	// Write the data.

	tzx::writestandardblockhead (out);
	block1.write (out);

	tzx::writestandardblockhead (out);
	block2.write (out);
	if (! out)
		throw ErrorOutput;
}

void Asm::In::emittzx (std::ostream & out)
{
	message_emit ("TZX");

	tzx::writefilehead (out);

	writetzxcode (out);
}

void Asm::In::writecdtcode (std::ostream & out)
{
	const address codesize= getcodesize ();
	const address entry= hasentrypoint ? entrypoint : 0;

	cpc::Header head (headername);
	head.settype (cpc::Header::Binary);
	head.firstblock (true);
	head.lastblock (false);
	head.setlength (codesize);
	head.setloadaddress (minused);
	head.setentry (entry);

	address pos= minused;
	address pending= codesize;

	const address maxblock= 2048;
	const address maxsubblock= 256;
	byte blocknum= 1;

	while (pending > 0)
	{
		const address block= pending < maxblock ? pending : maxblock;

		head.setblock (blocknum);
		if (blocknum > 1)
			head.firstblock (false);
		if (pending <= maxblock)
			head.lastblock (true);
		head.setblocklength (block);

		// Size of the tzx data block: type byte, code, checksums,
		// filling of last subblock and final bytes.

		size_t tzxdatalen= static_cast <size_t> (block) +
			maxsubblock - 1;
		tzxdatalen/= maxsubblock;
		tzxdatalen*= maxsubblock + 2;
		tzxdatalen+= 5;
		
		// Write header.

		tzx::writeturboblockhead (out, 263);

		head.write (out);

		// Write code.

		tzx::writeturboblockhead (out, tzxdatalen);

		out.put (0x16);  // Data block identifier.

		address subpos= pos;
		address blockpending= block;
		while (blockpending > 0)
		{
			address subblock= blockpending < maxsubblock ?
				blockpending : maxsubblock;
			out.write (reinterpret_cast <const char *>
				(mem + subpos),
				subblock);
			for (size_t i= subblock; i < maxsubblock; ++i)
				out.put ('\0');
			address crc= cpc::crc (mem + subpos, subblock);
			out.put (hibyte (crc) ); // CRC in hi-lo format.
			out.put (lobyte (crc) );
			blockpending-= subblock;
			subpos+= subblock;
		}

		out.put (0xFF);
		out.put (0xFF);
		out.put (0xFF);
		out.put (0xFF);

		pos+= block;
		pending-= block;
		++blocknum;
	}

	if (! out)
		throw ErrorOutput;
}

void Asm::In::emitcdt (std::ostream & out)
{
	message_emit ("CDT");

	tzx::writefilehead (out);

	writecdtcode (out);
}

std::string Asm::In::cpcbasicloader ()
{
	using namespace cpc;

	std::string basic;

	// Line: 10 MEMORY before_min_used
	std::string line= tokMEMORY + hexnumber (minused - 1);
	basic+= basicline (10, line);

	// Line: 20 LOAD "!", minused
	line= tokLOAD + "\"!\"," + hexnumber (minused);
	basic+= basicline (20, line);

	if (hasentrypoint)
	{
		// Line: 30 CALL entry_point
		line= tokCALL + hexnumber (minused);
		basic+= basicline (30, line);
	}

	// A line length of 0 marks the end of program.
	basic+= '\0';
	basic+= '\0';

	return basic;
}

void Asm::In::emitcdtbas (std::ostream & out)
{
	message_emit ("CDT");

	const std::string basic= cpcbasicloader ();
	const address basicsize= static_cast <address> (basic.size () );

	cpc::Header head ("LOADER");
	head.settype (cpc::Header::Basic);
	head.firstblock (true);
	head.lastblock (true);
	head.setlength (basicsize);
	head.setblock (1);
	head.setblocklength (basicsize);

	tzx::writefilehead (out);

	// Write header.

	tzx::writeturboblockhead (out, 263);

	head.write (out);

	// Write Basic.

	const address maxsubblock= 256;
	size_t tzxdatalen= static_cast <size_t> (basicsize) + maxsubblock - 1;
	tzxdatalen/= maxsubblock;
	tzxdatalen*= maxsubblock + 2;
	tzxdatalen+= 5;

	tzx::writeturboblockhead (out, tzxdatalen);

	out.put (0x16);  // Data block identifier.

	out.write (basic.data (), basicsize);
	for (address n= basicsize ; (n % maxsubblock) != 0; ++n)
		out.put ('\0');
	address crc= cpc::crc
		(reinterpret_cast <const unsigned char *> (basic.data () ),
		basicsize);
	out.put (hibyte (crc) ); // CRC in hi-lo format.
	out.put (lobyte (crc) );

	out.put (0xFF);
	out.put (0xFF);
	out.put (0xFF);
	out.put (0xFF);

	writecdtcode (out);
}


std::string Asm::In::spectrumbasicloader ()
{
	using namespace spectrum;

	std::string basic;

	// Line: 10 CLEAR before_min_used
	std::string line= tokCLEAR + number (minused - 1);
	basic+= basicline (10, line);

	// Line: 20 POKE 23610, 255
	// To avoid a error message when using +3 loader.
	line= tokPOKE + number (23610) + ',' + number (255);
	basic+= basicline (20, line);

	// Line: 30 LOAD "" CODE
	line= tokLOAD + "\"\"" + tokCODE;
	basic+= basicline (30, line);

	if (hasentrypoint)
	{
		// Line: 40 RANDOMIZE USR entry_point
		line= tokRANDOMIZE + tokUSR + number (entrypoint);
		basic+= basicline (40, line);
	}

	return basic;
}

void Asm::In::emittapbas (std::ostream & out)
{
	if (debugtype != NoDebug)
		* pout << "Emiting TAP basic loader" << endl;

	// Prepare the data.

	std::string basic (spectrumbasicloader () );
	tap::BasicHeader basicheadblock (basic);
	tap::BasicBlock basicblock (basic);

	// Write the file.

	basicheadblock.write (out);
	basicblock.write (out);

	emittap (out);
}

void Asm::In::emittzxbas (std::ostream & out)
{
	if (debugtype != NoDebug)
		* pout << "Emiting TZX with basic loader" << endl;

	// Prepare the data.

	std::string basic (spectrumbasicloader () );
	tap::BasicHeader basicheadblock (basic);
	tap::BasicBlock basicblock (basic);

	// Write the file.

	tzx::writefilehead (out);

	tzx::writestandardblockhead (out);
	basicheadblock.write (out);

	tzx::writestandardblockhead (out);
	basicblock.write (out);

	writetzxcode (out);
}

void Asm::In::emithex (std::ostream & out)
{
	message_emit ("Intel HEX");

	address end= maxused + 1;
	for (address i= minused; i < end; i+= 16)
	{
		address len= end - i;
		if (len > 16)
			len= 16;
		out << ':' << hex2 (lobyte (len) ) << hex4 (i) << "00";
		byte sum= len + ( (i >> 8) & 0xFF) + i & 0xFF;
		for (address j= 0; j < len; ++j)
		{
			byte b= mem [i + j];
			out << hex2 (b);
			sum+= b;
		}
		out << hex2 (lobyte (0x100 - sum) );
		out << "\r\n";
	}
	out << ":00000001FF\r\n";

	if (! out)
		throw ErrorOutput;
}

void Asm::In::emitamsdos (std::ostream & out)
{
	message_emit ("Amsdos");

	address codesize= getcodesize ();

	cpc::AmsdosHeader head (headername);
	head.setlength (codesize);
	head.setloadaddress (minused);
	if (hasentrypoint)
		head.setentry (entrypoint);

	head.write (out);

	// Write code.
	writebincode (out);

	if (! out)
		throw ErrorOutput;
}

void Asm::In::emitmsx (std::ostream & out)
{
	message_emit ("MSX");

	// Header of an MSX BLOADable disk file.
	byte header [7]= { 0xFE }; // Header identification byte.
	// Start address.
	header [1]= minused & 0xFF;
	header [2]= minused >> 8;
	// End address.
	header [3]= maxused & 0xFF;
	header [4]= maxused >> 8;
	// Exec address.
	address entry= 0;
	if (hasentrypoint)
		entry= entrypoint;
	header [5]= entry & 0xFF;
	header [6]= entry >> 8;	

	// Write hader.
	out.write (reinterpret_cast <char *> (header), sizeof (header) );

	// Write code.
	writebincode (out);
}

void Asm::In::emitprl (std::ostream & out)
{
	message_emit ("PRL");

	// Assembly with 1 page offset to obtain the information needed
	// to create the prl relocation table.
	In asmoff (* this);
	asmoff.setbase (0x100);
	asmoff.processfile ();

	if (minused - base != asmoff.minused - asmoff.base)
		throw OutOfSyncPRL;
	if (maxused - base != asmoff.maxused - asmoff.base)
		throw OutOfSyncPRL;
	address len= getcodesize ();
	address off= asmoff.base - base;

	// PRL header.

	byte prlhead [256]= { 0 };
	prlhead [1]= len & 0xFF;
	prlhead [2]= len >> 8;
	out.write (reinterpret_cast <char *> (prlhead), sizeof (prlhead) );
	address reloclen= (len + 7) / 8;
	byte * reloc= new byte [reloclen];
	//memset (reloc, 0, reloclen);
	fill (reloc, reloc + reloclen, byte (0) );

	// Build relocation bitmap.
	for (address i= minused; i <= maxused; ++i)
	{
		byte b= mem [i];
		byte b2= asmoff.mem [i + off];
		if (b != b2)
		{
			if (b2 - b != off / 256)
			{
				* perr << "off= " << hex4 (off) <<
					", b= " << hex2 (b) <<
					", b2= " << hex2 (b2) <<
					endl;
				throw OutOfSyncPRL;
			}
			address pos= i - minused;
			static const byte mask [8]= {
				0x80, 0x40, 0x20, 0x10,
				0x08, 0x04, 0x02, 0x01
			};
			reloc [pos / 8]|= mask [pos % 8];
		}
	}

	// Write code in position 0x0100
	asmoff.writebincode (out);

	// Write relocation bitmap.
	out.write (reinterpret_cast <char *> (reloc), reloclen);

	if (! out)
		throw ErrorOutput;
}


namespace {


class CmdGroup {
public:
	CmdGroup ();			// Create empty group
	CmdGroup (address lengthn);	// Create Code group
	void put (std::ostream & out) const;
private:
	byte type;
	address length;
	address base;
	address minimum;
	address maximum;

	static address para (address n);
};

address CmdGroup::para (address n)
{
	return (n + 15) / 16;
}

CmdGroup::CmdGroup () :
	type (0),
	length (0),
	base (0),
	minimum (0),
	maximum (0)
{
}

CmdGroup::CmdGroup (address lengthn) :
	type (1),
	length (para (lengthn) + 0x0010),
	base (0),
	minimum (length),
	maximum (0x0FFF)
{
}

void CmdGroup::put (std::ostream & out) const
{
	out.put (type);
	putword (out, length);
	putword (out, base);
	putword (out, minimum);
	putword (out, maximum);
}


} // namespace


void Asm::In::emitcmd (std::ostream & out)
{
	message_emit ("CMD");

	address codesize= getcodesize ();
	CmdGroup code (codesize);
	CmdGroup empty;

	// CMD header.

	// 8 group descriptors: 72 bytes in total.
	code.put (out);
	for (size_t i= 1; i < 8; ++i)
		empty.put (out);

	// Until 128 bytes: filled with zeroes (in this case).
	char fillhead [128 - 72]= { };
	out.write (fillhead, sizeof (fillhead) );

	// First 256 bytes of prefix in 8080 model.
	char prefix [256]= { };
	out.write (prefix, sizeof (prefix) );

	// Binary image.
	writebincode (out);

	if (! out)
		throw ErrorOutput;
}


//*********************************************************
//		Symbol table generation.
//*********************************************************


void Asm::In::dumppublic (std::ostream & out)
{
	for (setpublic_t::iterator pit= setpublic.begin ();
		pit != setpublic.end ();
		++pit)
	{
		mapvar_t::iterator it= mapvar.find (* pit);
		if (it != mapvar.end () )
		{
			out << tablabel (it->first) << "EQU 0" <<
				hex4 (it->second.getvalue () ) << 'H' << endl;
		}
	}
}

void Asm::In::dumpsymbol (std::ostream & out)
{
	for (mapvar_t::iterator it= mapvar.begin ();
		it != mapvar.end ();
		++it)
	{
		const VarData & vd= it->second;
		// Dump only EQU and label valid symbols.
		if (vd.def () != DefinedPass2)
			continue;

		out << tablabel (it->first) << "EQU 0" <<
			hex4 (vd.getvalue () ) << 'H'
			<< endl;
	}
}


//*********************************************************
//			class Asm
//*********************************************************


Asm::Asm () :
	pin (new In)
{
}

Asm::~Asm ()
{
	delete pin;
}

void Asm::setheadername (const std::string & headername_n)
{
	pin->setheadername (headername_n);
}

void Asm::verbose ()
{
	pin->verbose ();
}

void Asm::setdebugtype (DebugType type)
{
	pin->setdebugtype (type);
}

void Asm::errtostdout ()
{
	pin->errtostdout ();
}

void Asm::setbase (unsigned int addr)
{
	pin->setbase (addr);
}

void Asm::caseinsensitive ()
{
	pin->caseinsensitive ();
}

void Asm::autolocal ()
{
	pin->autolocal ();
}

void Asm::bracketonly ()
{
	pin->bracketonly ();
}

void Asm::warn8080 ()
{
	pin->warn8080 ();
}

void Asm::set86 ()
{
	pin->set86 ();
}

void Asm::setpass3 ()
{
	pin->setpass3 ();
}

void Asm::addincludedir (const std::string & dirname)
{
	pin->addincludedir (dirname);
}

void Asm::addpredef (const std::string & predef)
{
	pin->addpredef (predef);
}

void Asm::loadfile (const std::string & filename)
{
	pin->loadfile (filename);
}

void Asm::processfile ()
{
	TRF;

	pin->processfile ();
}

void Asm::emitobject (std::ostream & out)
{
	pin->emitobject (out);
}

void Asm::emitplus3dos (std::ostream & out)
{
	pin->emitplus3dos (out);
}

void Asm::emittap (std::ostream & out)
{
	pin->emittap (out);
}

void Asm::emittzx (std::ostream & out)
{
	pin->emittzx (out);
}

void Asm::emitcdt (std::ostream & out)
{
	pin->emitcdt (out);
}

void Asm::emitcdtbas (std::ostream & out)
{
	pin->emitcdtbas (out);
}

void Asm::emittapbas (std::ostream & out)
{
	pin->emittapbas (out);
}

void Asm::emittzxbas (std::ostream & out)
{
	pin->emittzxbas (out);
}

void Asm::emithex (std::ostream & out)
{
	pin->emithex (out);
}

void Asm::emitamsdos (std::ostream & out)
{
	pin->emitamsdos (out);
}

void Asm::emitprl (std::ostream & out)
{
	pin->emitprl (out);
}

void Asm::emitcmd (std::ostream & out)
{
	pin->emitcmd (out);
}

void Asm::emitmsx (std::ostream & out)
{
	pin->emitmsx (out);
}

void Asm::dumppublic (std::ostream & out)
{
	pin->dumppublic (out);
}

void Asm::dumpsymbol (std::ostream & out)
{
	pin->dumpsymbol (out);
}

// End of asm.cpp
