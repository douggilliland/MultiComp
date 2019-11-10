// pasmotypes.cpp
// Revision 8-dec-2004

#include "pasmotypes.h"


namespace {


const char hexdigit []= { '0', '1', '2', '3', '4', '5', '6', '7',
	'8', '9', 'A', 'B', 'C', 'D', 'E', 'F' };

} // namespace

std::string hex2str (byte b)
{
	return std::string (1, hexdigit [ (b >> 4) & 0x0F] ) +
		hexdigit [b & 0x0F];
}

std::string hex4str (address n)
{
	return hex2str (hibyte (n) ) + hex2str (lobyte (n) );
}

std::string hex8str (size_t nn)
{
	return hex4str ( (nn >> 16) & 0xFFFF) + hex4str (nn & 0xFFFF);
}

std::string Hex2::str () const
{
	return hex2str (b);
}

std::string Hex4::str () const
{
	return hex4str (n);
}

std::string Hex8::str () const
{
	return hex8str (nn);
}

std::ostream & operator << (std::ostream & os, const Hex2 & h2)
{
	os << h2.str ();
	return os;
}

std::ostream & operator << (std::ostream & os, const Hex4 & h4)
{
	os << h4.str ();
	return os;
}

std::ostream & operator << (std::ostream & os, const Hex8 & h8)
{
	os << h8.str ();
	return os;
}


// End of pasmotypes.cpp
