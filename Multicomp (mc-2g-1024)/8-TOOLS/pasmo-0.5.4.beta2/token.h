#ifndef INCLUDE_TOKEN_H
#define INCLUDE_TOKEN_H

// token.h
// Revision 15-jan-2005

#include <string>
#include <deque>

#include "pasmotypes.h"


enum TypeToken {
	TypeUndef= 0,
	TypeEndLine= 1,

	// Single char operators.
	TypeComma= ',',
	TypeColon= ':',
	TypePlus= '+',
	TypeMinus= '-',
	TypeMult= '*',
	TypeDiv= '/',
	TypeEqOp= '=',
	TypeOpen= '(',
	TypeClose= ')',
	TypeOpenBracket= '[',
	TypeCloseBracket= ']',
	TypeDollar= '$',
	TypeMod= '%',
	TypeLtOp= '<',
	TypeGtOp= '>',
	TypeBitNotOp= '~',
	TypeBoolNotOp= '!',
	TypeBitAnd= '&',
	TypeBitOr= '|',
	TypeQuestion= '?',
	TypeSharp= '#',

	// Literals.
	TypeIdentifier= 0x100,
	TypeLiteral,
	TypeNumber,

	// Special tokens.
	TypeEndOfInclude,

	// Not single char operators.
	TypeMOD,
	TypeFirstName= TypeMOD,
	TypeSHL,
	TypeShlOp,
	TypeSHR,
	TypeShrOp,
	TypeNOT,
	// AND, OR and XOR are nemonics.
	TypeEQ,
	TypeLT,
	TypeLE,
	TypeLeOp,
	TypeGT,
	TypeGE,
	TypeGeOp,
	TypeNE,
	TypeNeOp,
	TypeNUL,
	TypeDEFINED,
	TypeHIGH,
	TypeLOW,
	TypeBoolAnd,
	TypeBoolOr,
	TypeSharpSharp,

	// Nemonics
	TypeADC,
	TypeADD,
	TypeAND,
	TypeBIT,
	TypeCALL,
	TypeCCF,
	TypeCP,
	TypeCPD,
	TypeCPDR,
	TypeCPI,
	TypeCPIR,
	TypeCPL,
	TypeDAA,
	TypeDEC,
	TypeDI,
	TypeDJNZ,
	TypeEI,
	TypeEX,
	TypeEXX,
	TypeHALT,
	TypeIM,
	TypeIN,
	TypeINC,
	TypeIND,
	TypeINDR,
	TypeINI,
	TypeINIR,
	TypeJP,
	TypeJR,
	TypeLD,
	TypeLDD,
	TypeLDDR,
	TypeLDI,
	TypeLDIR,
	TypeNEG,
	TypeNOP,
	TypeOR,
	TypeOTDR,
	TypeOTIR,
	TypeOUT,
	TypeOUTD,
	TypeOUTI,
	TypePOP,
	TypePUSH,
	TypeRES,
	TypeRET,
	TypeRETI,
	TypeRETN,
	TypeRL,
	TypeRLA,
	TypeRLC,
	TypeRLCA,
	TypeRLD,
	TypeRR,
	TypeRRA,
	TypeRRC,
	TypeRRCA,
	TypeRRD,
	TypeRST,
	TypeSBC,
	TypeSCF,
	TypeSET,
	TypeSLA,
	TypeSLL,
	TypeSRA,
	TypeSRL,
	TypeSUB,
	TypeXOR,

	// Registers
	// C is listed as flag.
	TypeA,
	TypeAF,
	TypeAFp, // AF'
	TypeB,
	TypeBC,
	TypeD,
	TypeE,
	TypeDE,
	TypeH,
	TypeL,
	TypeHL,
	TypeSP,
	TypeIX,
	TypeIXH,
	TypeIXL,
	TypeIY,
	TypeIYH,
	TypeIYL,
	TypeI,
	TypeR,

	// Flags
	TypeNZ,
	TypeZ,
	TypeNC,
	TypeC,
	TypePO,
	TypePE,
	TypeP,
	TypeM,

	// Directives
	TypeDEFB,
	TypeDB,
	TypeDEFM,
	TypeDEFW,
	TypeDW,
	TypeDEFS,
	TypeDS,
	TypeEQU,
	TypeDEFL,
	TypeORG,
	TypeINCLUDE,
	TypeINCBIN,
	TypeIF,
	TypeELSE,
	TypeENDIF,
	TypePUBLIC,
	TypeEND,
	TypeLOCAL,
	TypePROC,
	TypeENDP,
	TypeMACRO,
	TypeENDM,
	TypeEXITM,
	TypeREPT,
	TypeIRP,

	// Directives with .
	Type_ERROR,
	Type_WARNING,
	Type_SHIFT,

	// Last used type number.
	TypeLastName= Type_SHIFT
};

std::string gettokenname (TypeToken tt);


class Token {
public:
	Token ();
	Token (TypeToken ttn);
	Token (address n);
	Token (TypeToken ttn, const std::string & sn);
	TypeToken type () const;
	std::string str () const;
	address num () const;
private:
	TypeToken tt;
	std::string s;
	address number;
};

std::ostream & operator << (std::ostream & oss, const Token & tok);


class Tokenizer {
public:
	Tokenizer ();
	Tokenizer (bool nocase_n);
	Tokenizer (TypeToken ttok);
	Tokenizer (const Tokenizer & tz);
	Tokenizer (const std::string & line, bool nocase_n);
	~Tokenizer ();
	Tokenizer & operator = (const Tokenizer &);

	bool getnocase () const { return nocase; }
	void push_back (const Token & tok);

	bool empty () const;
	bool endswithparen () const;

	void reset ();
	Token gettoken ();
	void ungettoken ();
	std::string getincludefile ();

	friend std::ostream & operator << (std::ostream & oss,
		const Tokenizer & tz);
private:
	typedef std::deque <Token> tokenlist_t;
	tokenlist_t tokenlist;
	tokenlist_t::iterator current;

	size_t endpassed;
	bool nocase;
};


#endif

// End of token.h
