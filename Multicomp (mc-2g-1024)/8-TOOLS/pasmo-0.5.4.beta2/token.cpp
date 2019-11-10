// token.cpp
// Revision 15-jan-2005

#include "token.h"

#include <iostream>
#include <fstream>
#include <sstream>
#include <iomanip>
#include <iterator>
#include <algorithm>
#include <map>
#include <stdexcept>

#include <ctype.h>

#include <assert.h>
#define ASSERT assert

using std::cout;
using std::cerr;
using std::endl;
using std::istringstream;
using std::ostringstream;
using std::for_each;
using std::runtime_error;
using std::logic_error;


//*********************************************************
//		Auxiliary functions and constants.
//*********************************************************


namespace {


std::string upper (const std::string & str)
{
	std::string r;
	const std::string::size_type l= str.size ();
	for (std::string::size_type i= 0; i < l; ++i)
		r+= toupper (str [i] );
	return r;
}

typedef std::map <std::string, TypeToken> tmap_t;

tmap_t tmap;

typedef std::map <TypeToken, std::string> invmap_t;

invmap_t invmap;

struct NameType {
	const char * const str;
	const TypeToken type;
	NameType (const char * str, TypeToken type) :
		str (str), type (type)
	{ }
};

#define NT(n) NameType (#n, Type ## n)

#define NT_(n) NameType ("." #n, Type_ ## n)

const NameType nt []= {
	// Operators
	NT (MOD),
	NT (SHL),
	NameType ("<<", TypeShlOp),
	NT (SHR),
	NameType (">>", TypeShrOp),
	NT (NOT),
	NT (EQ),
	NT (LT),
	NT (LE),
	NameType ("<=", TypeLeOp),
	NT (GT),
	NT (GE),
	NameType (">=", TypeGeOp),
	NT (NE),
	NameType ("!=", TypeNeOp),
	NT (NUL),
	NT (DEFINED),
	NT (HIGH),
	NT (LOW),
	NameType ("&&", TypeBoolAnd),
	NameType ("||", TypeBoolOr),
	NameType ("##", TypeSharpSharp),

	// Nemonics
	NT (ADC),
	NT (ADD),
	NT (AND),
	NT (BIT),
	NT (CALL),
	NT (CCF),
	NT (CP),
	NT (CPD),
	NT (CPDR),
	NT (CPI),
	NT (CPIR),
	NT (CPL),
	NT (DAA),
	NT (DEC),
	NT (DI),
	NT (DJNZ),
	NT (EI),
	NT (EX),
	NT (EXX),
	NT (HALT),
	NT (IM),
	NT (IN),
	NT (INC),
	NT (IND),
	NT (INDR),
	NT (INI),
	NT (INIR),
	NT (JP),
	NT (JR),
	NT (LD),
	NT (LDD),
	NT (LDDR),
	NT (LDI),
	NT (LDIR),
	NT (NEG),
	NT (NOP),
	NT (OR),
	NT (OTDR),
	NT (OTIR),
	NT (OUT),
	NT (OUTD),
	NT (OUTI),
	NT (POP),
	NT (PUSH),
	NT (RES),
	NT (RET),
	NT (RETI),
	NT (RETN),
	NT (RL),
	NT (RLA),
	NT (RLC),
	NT (RLCA),
	NT (RLD),
	NT (RR),
	NT (RRA),
	NT (RRC),
	NT (RRCA),
	NT (RRD),
	NT (RST),
	NT (SBC),
	NT (SCF),
	NT (SET),
	NT (SLA),
	NT (SLL),
	NT (SRA),
	NT (SRL),
	NT (SUB),
	NT (XOR),

	// Registers.
	// C is listed as flag.
	NT (A),
	NT (AF),
	NameType ("AF'", TypeAFp),
	NT (B),
	NT (BC),
	NT (D),
	NT (E),
	NT (DE),
	NT (H),
	NT (L),
	NT (HL),
	NT (SP),
	NT (IX),
	NT (IXH),
	NT (IXL),
	NT (IY),
	NT (IYH),
	NT (IYL),
	NT (I),
	NT (R),

	// Flags
	NT (NZ),
	NT (Z),
	NT (NC),
	NT (C),
	NT (PO),
	NT (PE),
	NT (P),
	NT (M),

	// Directives
	NT (DEFB),
	NT (DB),
	NT (DEFM),
	NT (DEFW),
	NT (DW),
	NT (DEFS),
	NT (DS),
	NT (EQU),
	NT (DEFL),
	NT (ORG),
	NT (INCLUDE),
	NT (INCBIN),
	NT (IF),
	NT (ELSE),
	NT (ENDIF),
	NT (PUBLIC),
	NT (END),
	NT (LOCAL),
	NT (PROC),
	NT (ENDP),
	NT (MACRO),
	NT (ENDM),
	NT (EXITM),
	NT (REPT),
	NT (IRP),

	// Directives with .
	NT_ (ERROR),
	NT_ (WARNING),
	NT_ (SHIFT)
};

class mapiniter {
	mapiniter ();
	static mapiniter instance;
};

mapiniter mapiniter::instance;

mapiniter::mapiniter ()
{
	#ifndef NDEBUG
	bool typeused [TypeLastName + 1]= { false };
	bool checkfailed= false;
	#endif

	for (const NameType * p= nt;
		p != nt + (sizeof (nt) / sizeof (nt [0] ) );
		++p)
	{
		TypeToken tt= p->type;
		#ifndef NDEBUG
		ASSERT (tt >= TypeFirstName);
		ASSERT (tt <= TypeLastName);
		if (typeused [tt] )
		{
			cerr << "Type " << tt << " duplicated" << endl;
			checkfailed= true;
		}
		typeused [tt]= true;
		#endif
		tmap [p->str]= tt;
		invmap [tt]= p->str;
	}

	#ifndef NDEBUG
	for (TypeToken tt= TypeFirstName; tt <= TypeLastName;
			tt= TypeToken (tt + 1) )
	{
		if (! typeused [tt] )
		{
			cerr << "Type " << tt << " unasigned" << endl;
			checkfailed= true;
		}
	}
	ASSERT (! checkfailed);
	#endif
}

TypeToken getliteraltoken (const std::string & str)
{
	tmap_t::iterator it= tmap.find (upper (str) );
	if (it != tmap.end () )
		return it->second;
	else
		return TypeUndef;
}

} // namespace


std::string gettokenname (TypeToken tt)
{
	invmap_t::iterator it= invmap.find (tt);
	if (it != invmap.end () )
		return it->second;
	else
		return std::string (1, static_cast <char> (tt) );
}



//*********************************************************
//			class Token
//*********************************************************

Token::Token () :
	tt (TypeUndef)
{
}

Token::Token (TypeToken ttn) :
	tt (ttn)
{
}

Token::Token (address n) :
	tt (TypeNumber),
	number (n)
{
}

Token::Token (TypeToken ttn, const std::string & sn) :
	tt (ttn),
	s (sn)
{
}

TypeToken Token::type () const
{
	return tt;
}

namespace {

class addescaped {
public:
	addescaped (std::string & str) : str (str)
	{ }
	void operator () (char c);
private:
	std::string & str;
};

void addescaped::operator () (char c)
{
	unsigned char c1= c;
	if (c1 >= ' ' && c1 < 128)
		str+= c;
	else
	{
		str+= "\\x";
		str+= hex2str (c1);
	}
}

std::string escapestr (const std::string & str)
{
	std::string result;
	for_each (str.begin (), str.end (), addescaped (result) );
	return result;
}

} // namespace

std::string Token::str () const
{
	switch (tt)
	{
	case TypeUndef:
		return "(undef)";
	case TypeEndLine:
		return "(eol)";
	case TypeIdentifier:
		return s;
	case TypeLiteral:
		return s;
	case TypeNumber:
		return hex4str (number);
	default:
		return gettokenname (tt);
	}
}

address Token::num () const
{
	ASSERT (tt == TypeNumber);
	return number;
}

std::ostream & operator << (std::ostream & oss, const Token & tok)
{
	oss << tok.str ();
	return oss;
}

//*********************************************************
//		Tokenizer auxiliary functions.
//*********************************************************

namespace {


logic_error tokenizerunderflow ("Tokenizer underflowed");
logic_error missingfilename ("Missing filename");


runtime_error unclosed ("Unclosed literal");
runtime_error invalidhex ("Invalid hexadecimal number");
runtime_error invalidnumber ("Inavlid numeric format");
runtime_error outofrange ("Number out of range");
runtime_error needfilename ("Filename required");
runtime_error invalidfilename ("Invalid file name");


class UnexpectedChar : public runtime_error {
public:
	UnexpectedChar (char c) :
		runtime_error ("Unexpected character: " + chartostr (c) )
	{ }
private:
	static std::string chartostr (char c)
	{
		std::string r;
		if (c < 32 || c >= 127)
			r= '&' + hex2str (c);
		else
		{
			r= '\'';
			r+= c;
			r+= '\'';
		}
		return r;
	}
};

Token parseless (std::istream & iss)
{
	char c= iss.get ();
	if (iss)
	{
		switch (c)
		{
		case '=':
			return Token (TypeLeOp);
		case '<':
			return Token (TypeShlOp);
		default:
			iss.unget ();
			return Token (TypeLtOp);
		}
	}
	else
		return Token (TypeLtOp);
}

Token parsegreat (std::istream & iss)
{
	char c= iss.get ();
	if (iss)
	{
		switch (c)
		{
		case '=':
			return Token (TypeGeOp);
		case '>':
			return Token (TypeShrOp);
		default:
			iss.unget ();
			return Token (TypeGtOp);
		}
	}
	else
		return Token (TypeGtOp);
}

Token parsenot (std::istream & iss)
{
	char c= iss.get ();
	if (iss)
	{
		switch (c)
		{
		case '=':
			return Token (TypeNeOp);
		default:
			iss.unget ();
			return Token (TypeBoolNotOp);
		}
	}
	else
		return Token (TypeBoolNotOp);
}

Token parsestringc (std::istream & iss)
{
	std::string str;
	for (;;)
	{
		char c= iss.get ();
		if (! iss)
			throw unclosed;
		if (c == '"')
			return Token (TypeLiteral, str);
		if (c == '\\')
		{
			c= iss.get ();
			if (! iss)
				throw unclosed;
			switch (c)
			{
			case '\\':
				break;
			case 'n':
				c= '\n'; break;
			case 'r':
				c= '\r'; break;
			case 't':
				c= '\t'; break;
			case 'a':
				c= '\a'; break;
			case '0': case '1': case '2': case '3':
			case '4': case '5': case '6': case '7':
				{
					c-= '0';
					char c2= iss.get ();
					if (! iss)
						throw unclosed;
					if (c2 < '0' || c2 > '7')
						iss.unget ();
					else
					{
						c*= 8;
						c+= c2 - '0';
						c2= iss.get ();
						if (! iss)
							throw unclosed;
						if (c2 < '0' || c2 > '7')
							iss.unget ();
						else
						{
							c*= 8;
							c+= c2 - '0';
						}
					}
				}
				break;
			case 'x': case 'X':
				{
					char x [3]= { 0 };
					c= iss.get ();
					if (! iss)
						throw unclosed;
					if (! isxdigit (c) )
						iss.unget ();
					else
					{
						x [0]= c;
						c= iss.get ();
						if (! iss)
							throw unclosed;
						if (! isxdigit (c) )
							iss.unget ();
						else
							x [1]= c;
					}
					c= strtoul (x, NULL, 16);
				}
				break;
			}
			str+= c;
		}
		else
			str+= c;
	}
}

Token parsestringasm (std::istream & iss)
{
	std::string str;
	for (;;)
	{
		char c= iss.get ();
		if (! iss)
			throw unclosed;
		if (c == '\'')
		{
			c= iss.get ();
			if (! iss)
				return Token
					(TypeLiteral, str);
			if (c != '\'')
			{
				iss.unget ();
				return Token
					(TypeLiteral, str);
			}
		}
		str+= c;
	}
}

Token parsedollar (std::istream & iss)
{
	char c;
	c= iss.get ();
	if (iss && isxdigit (c) )
	{
		std::string str;
		do
		{
			if (c != '$')
				str+= c;
			c= iss.get ();
		} while (iss && (isxdigit (c) || c == '$') );
		if (str.empty () )
			throw invalidhex;
		if (iss)
			iss.unget ();

		unsigned long n;
		char * aux;
		n= strtoul (str.c_str (), & aux, 16);
		if (* aux != '\0')
			throw invalidnumber;
		if (n > 0xFFFFUL)
			throw outofrange;
		return Token (static_cast <address> (n) );
	}
	else
	{
		if (iss)
			iss.unget ();
		return Token (TypeDollar);
	}
}

Token parsesharp (std::istream & iss)
{
	std::string str;
	char c= iss.get ();
	if (c == '#')
		return Token (TypeSharpSharp);
	while (iss && (isxdigit (c) || c == '$') )
	{
		if (c != '$')
			str+= c;
		c= iss.get ();
	}
	if (str.empty () )
		return Token (TypeSharp);

	if (iss)
		iss.unget ();

	unsigned long n;
	char * aux;
	n= strtoul (str.c_str (), & aux, 16);
	if (* aux != '\0')
		throw invalidnumber;
	if (n > 0xFFFFUL)
		throw outofrange;
	return Token (static_cast <address> (n) );
}

Token parseampersand (std::istream & iss)
{
	char c= iss.get ();

	if (! iss)
		return Token (TypeBitAnd);

	std::string str;
	int base= 16;
	switch (c)
	{
	case '&':
		return Token (TypeBoolAnd);
	case 'h': case 'H':
		break;
	case 'o': case 'O':
		base= 8;
		break;
	case 'x': case 'X':
		base= 2;
		break;
	default:
		if (isxdigit (c) )
			str= c;
		else
		{
			iss.unget ();
			return Token (TypeBitAnd);
		}
	}
	c= iss.get ();
	while (iss && (isxdigit (c) || c == '$') )
	{
		if (c != '$')
			str+= c;
		c= iss.get ();
	}
	if (str.empty () )
		throw invalidnumber;
	if (iss)
		iss.unget ();

	char * aux;
	unsigned long n= strtoul (str.c_str (), & aux, base);
	if (* aux != '\0')
		throw invalidnumber;
	if (n > 0xFFFFUL)
		throw outofrange;
	return Token (static_cast <address> (n) );
}

Token parseor (std::istream & iss)
{
	char c= iss.get ();
	if (iss && c == '|')
		return Token (TypeBoolOr);
	else
	{
		if (iss)
			iss.unget ();
		return Token (TypeBitOr);
	}
}

Token parsepercent (std::istream & iss)
{
	char c= iss.get ();
	if (! iss || (c != '0' && c != '1') )
	{
		// Mod operator.
		if (iss)
			iss.unget ();
		return Token (TypeMod);
	}

	// Binary number.

	std::string str;
	do {
		if (c != '$')
			str+= c;
		c= iss.get ();
	} while (iss && (c == '0' || c == '1' || c == '$') );
	if (iss)
		iss.unget ();

	unsigned long n;
	char * aux;
	n= strtoul (str.c_str (), & aux, 2);
	if (* aux != '\0')
		throw invalidnumber;
	if (n > 0xFFFFUL)
		throw outofrange;
	return Token (static_cast <address> (n) );
}

Token parsedigit (std::istream & iss, char c)
{
	std::string str;
	do {
		if (c != '$')
			str+= c;
		c= iss.get ();
		if (! iss)
			c= 0;
	} while (isalnum (c) || c == '$');
	if (iss)
		iss.unget ();

	const std::string::size_type l= str.size ();
	unsigned long n;
	char * aux;

	// Hexadecimal with 0x prefix.
	if (str [0] == '0' && l > 1 &&
		(str [1] == 'x' || str [1] == 'X') )
	{
		str.erase (0, 2);
		if (str.empty () )
			throw invalidhex;
		n= strtoul (str.c_str (), & aux, 16);
	}
	else
	{
		// Decimal, hexadecimal, octal and binary
		// with or without suffix.
		switch (toupper (str [l - 1]) )
		{
		case 'H': // Hexadecimal.
			str.erase (l - 1);
			n= strtoul (str.c_str (), & aux, 16);
			break;
		case 'O': // Octal.
		case 'Q': // Octal.
			str.erase (l - 1);
			n= strtoul (str.c_str (), & aux, 8);
			break;
		case 'B': // Binary.
			str.erase (l - 1);
			n= strtoul (str.c_str (), & aux, 2);
			break;
		case 'D': // Decimal
			str.erase (l - 1);
			n= strtoul (str.c_str (), & aux, 10);
			break;
		default: // Decimal
			n= strtoul (str.c_str (), & aux, 10);
		}
	}
	if (* aux != '\0')
		throw invalidnumber;

	// Testing: do not forbid numbers out of 16 bits range,
	// just truncate it.
	//if (n > 0xFFFFUL)
	//	throw outofrange;

	return Token (static_cast <address> (n) );
}

void stripdollar (std::string & str)
{
	std::string::size_type n;
	while ( (n= str.find ('$') ) != std::string::npos)
		str.erase (1, n);
}

bool ischarbeginidentifier (char c)
{
	return isalpha (static_cast <unsigned char> (c) ) ||
		c == '_' || c == '?' || c == '@' || c == '.';
}

bool ischaridentifier (char c)
{
	return isalnum (static_cast <unsigned char> (c) ) ||
		c == '_' || c == '$' || c == '?' || c == '@' || c == '.';
}

Token parseidentifier (std::istream & iss, char c, bool nocase)
{
	std::string str;

	// Check conditional operator.
	if (c == '?')
	{
		str+= '?';
		c= iss.get ();
		if (! ischaridentifier (c) )
		{
			iss.unget ();
			return Token (TypeQuestion);
		}
	}

	do
	{
		// Changed this. Now a $ can be used to create
		// an identifier with the same name of a
		// reserved word.
		//if (c != '$')
		//	str+= c;
		str+= c;
		c= iss.get ();
	} while (iss && ischaridentifier (c) );
	if (iss)
		iss.unget ();

	TypeToken tt= getliteraltoken (str);

	if (tt == TypeUndef)
	{
		stripdollar (str);
		if (nocase)
			str= upper (str);
		return Token (TypeIdentifier, str);
	}
	else
	{
		if (tt == TypeAF && c == '\'')
		 {
		 	iss.get ();
			tt= TypeAFp;
		 }
		return Token (tt);
	}
}

Token parsetoken (std::istream & iss, bool nocase)
{
	char c;
	if (! (iss >> c) )
		return Token (TypeEndLine);
	switch (c)
	{
	case ';':
		return Token (TypeEndLine);
	case ',':
		return Token (TypeComma);
	case ':':
		return Token (TypeColon);
	case '+':
		return Token (TypePlus);
	case '-':
		return Token (TypeMinus);
	case '*':
		return Token (TypeMult);
	case '/':
		return Token (TypeDiv);
	case '=':
		return Token (TypeEqOp);
	case '<':
		// Less or less equal.
		return parseless (iss);
	case '>':
		// Greater or greter equal.
		return parsegreat (iss);
	case '~':
		return Token (TypeBitNotOp);
	case '!':
		// Not or not equal.
		return parsenot (iss);
	case '(':
		return Token (TypeOpen);
	case ')':
		return Token (TypeClose);
	case '[':
		return Token (TypeOpenBracket);
	case ']':
		return Token (TypeCloseBracket);
	case '$':
		// Hexadecimal number.
		return parsedollar (iss);
	case '\'':
		// Classic assembler string literal.
		return parsestringasm (iss);
	case '"':
		// C style string literal.
		return parsestringc (iss);
	case '#':
		// Hexadecimal number.
		return parsesharp (iss);
	case '&':
		// Hexadecimal, octal or binary number,
		// or and operators.
		return parseampersand (iss);
	case '|':
		// Or operators.
		return parseor (iss);
	case '%':
		// Binary number or mod operator.
		return parsepercent (iss);
	default:
		; // Nothing
	}

	if (isdigit (c) )
		return parsedigit (iss, c);

	if (ischarbeginidentifier (c) )
		return parseidentifier (iss, c, nocase);

	// Any other case, invalid character.

	throw UnexpectedChar (c);
}

std::string parseincludefile (std::istream & iss)
{
	char c;
	iss >> c;
	if (! iss)
		throw needfilename;
	std::string r;
	switch (c)
	{
	case '"':
		do
		{
			c= iss.get ();
			if (! iss)
				throw invalidfilename;
			if (c != '"')
				r+= c;
		} while (c != '"');
		break;
	case '\'':
		do
		{
			c= iss.get ();
			if (! iss)
				throw invalidfilename;
			if (c != '\'')
				r+= c;
		} while (c != '\'');
		break;
	default:
		do
		{
			r+= c;
			c= iss.get ();
		} while (iss && ! isspace (c) );
		if (iss)
			iss.unget ();
	}
	return r;
}

std::string parsemessage (std::istream & iss)
{
	char c;
	std::string result;
	// Message can be empty.
	if (iss >> c)
	{
		do {
			result+= c;
			c= iss.get ();
		} while (iss);
	}
	return result;
}

} // namespace


//*********************************************************
//			class Tokenizer
//*********************************************************


Tokenizer::Tokenizer () :
	current (tokenlist.begin () ),
	endpassed (0),
	nocase (false)
{
}

Tokenizer::Tokenizer (bool nocase_n) :
	current (tokenlist.begin () ),
	endpassed (0),
	nocase (nocase_n)
{
}

Tokenizer::Tokenizer (TypeToken ttok) :
	endpassed (0)
{
	tokenlist.push_back (Token (ttok) );
	current= tokenlist.begin ();
}

Tokenizer::Tokenizer (const Tokenizer & tz) :
	tokenlist (tz.tokenlist),
	current (tokenlist.begin () ),
	endpassed (0),
	nocase (tz.nocase)
{
}

Tokenizer::Tokenizer (const std::string & line, bool nocase_n) :
	current (tokenlist.begin () ),
	endpassed (0),
	nocase (nocase_n)
{
	istringstream iss (line);

	// Optional line number ignored.
	char c;
	do {
		c= iss.get ();
	} while (iss && isdigit (c) );
	if (iss)
		iss.unget ();

	Token tok;
	while ( (tok= parsetoken (iss, nocase) ).type () != TypeEndLine)
	{
		tokenlist.push_back (tok);
		switch (tok.type () )
		{
		case TypeINCLUDE:
		case TypeINCBIN:
			tokenlist.push_back
				(Token (TypeLiteral,
					parseincludefile (iss) ) );
			break;
		case Type_ERROR:
		case Type_WARNING:
			tokenlist.push_back
				(Token (TypeLiteral, parsemessage (iss) ) );
			break;
		default:
			// Nothing special.
			break;
		}
	}
	current= tokenlist.begin ();
}

Tokenizer::~Tokenizer ()
{
}

Tokenizer & Tokenizer::operator = (const Tokenizer & tz)
{
	tokenlist= tz.tokenlist;
	current= tokenlist.begin ();
	endpassed= 0;
	nocase= tz.nocase;
	return * this;
}

std::ostream & operator << (std::ostream & oss, const Tokenizer & tz)
{
	std::copy (tz.tokenlist.begin (), tz.tokenlist.end (),
		std::ostream_iterator <Token> (oss, " ") );
	return oss;
}

void Tokenizer::push_back (const Token & tok)
{
	tokenlist.push_back (tok);
	current= tokenlist.begin ();
}

bool Tokenizer::empty () const
{
	return tokenlist.empty ();
}

bool Tokenizer::endswithparen () const
{
	ASSERT (! tokenlist.empty () );
	return tokenlist.back ().type () == TypeClose;
}


void Tokenizer::reset ()
{
	current= tokenlist.begin ();
	endpassed= 0;
}

Token Tokenizer::gettoken ()
{
	if (current == tokenlist.end () )
	{
		++endpassed;
		return Token (TypeEndLine);
	}
	else
	{
		Token tok= * current;
		++current;
		return tok;
	}
}

void Tokenizer::ungettoken ()
{
	if (endpassed > 0)
	{
		ASSERT (current == tokenlist.end () );
		--endpassed;
	}
	else
	{
		if (current == tokenlist.begin () )
			throw tokenizerunderflow;
		--current;
	}
}

std::string Tokenizer::getincludefile ()
{
	Token tok= gettoken ();
	if (tok.type () != TypeLiteral)
		throw missingfilename;
	return tok.str ();
}


// End of token.cpp
