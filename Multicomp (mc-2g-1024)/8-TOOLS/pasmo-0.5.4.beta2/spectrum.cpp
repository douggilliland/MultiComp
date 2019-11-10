// spectrum.cpp
// Revision 13-dec-2004


#include "spectrum.h"

#include <sstream>
#include <algorithm>

using std::fill;
using std::copy;


spectrum::Plus3Head::Plus3Head ()
{
	static const byte ident []= {
		'P', 'L', 'U', 'S', '3', 'D', 'O', 'S', // Identifier.
		0x1A, // CP/M EOF.
		1,    // Issue number.
		0,    // Version number.
	};
	//memset (plus3, 0, headsize);
	fill (plus3, plus3 + headsize, byte (0) );
	//memcpy (plus3, ident, sizeof (ident) );
	copy (ident, ident + sizeof (ident), plus3);

	plus3 [15]= 3; // Type: code.

	plus3 [20]= 0x80; // Don't know if used for something.
	plus3 [21]= 0x80;
}

void spectrum::Plus3Head::setsize (address size)
{
	size_t filesize= size + 128;

	// Size of file including code and header.
	plus3 [11]= filesize & 0xFF;
	plus3 [12]= (filesize >> 8) & 0xFF;
	plus3 [13]= (filesize >> 16) & 0xFF;
	plus3 [14]= (filesize >> 24) & 0xFF;

	// Size of code.
	plus3 [16]= lobyte (size);
	plus3 [17]= hibyte (size);
}

void spectrum::Plus3Head::setstart (address start)
{
	// Start address.
	plus3 [18]= lobyte (start);
	plus3 [19]= hibyte (start);
}

void spectrum::Plus3Head::write (std::ostream & out)
{
	// Checksum
	byte check= 0;
	for (int i= 0; i < 127; ++i)
		check+= plus3 [i];
	plus3 [127]= check;

	// Write the header.
	out.write (reinterpret_cast <char *> (plus3), headsize);
}

// Spectrum Basic generation.


const std::string spectrum::tokNumPrefix (1, '\x0E');
const std::string spectrum::tokEndLine   (1, '\x0D');
const std::string spectrum::tokCODE      (1, '\xAF');
const std::string spectrum::tokUSR       (1, '\xC0');
const std::string spectrum::tokLOAD      (1, '\xEF');
const std::string spectrum::tokPOKE      (1, '\xF4');
const std::string spectrum::tokRANDOMIZE (1, '\xF9');
const std::string spectrum::tokCLEAR     (1, '\xFD');

std::string spectrum::number (address n)
{
	std::ostringstream oss;
	oss << n;
	std::string str (oss.str () );
	str+= tokNumPrefix;

	// Special format of Spectrum numbers for integers.
	str+= '\x00';
	str+= '\x00';
	//str+= static_cast <unsigned char> (n & 0xFF);
	//str+= static_cast <unsigned char> (n >> 8);
	str+= static_cast <unsigned char> (lobyte (n) );
	str+= static_cast <unsigned char> (hibyte (n) );
	str+= '\x00';
	return str;
}

std::string spectrum::linenumber (address n)
{
	std::string str (1, hibyte (n) );
	str+= lobyte (n);
	return str;
}

std::string spectrum::linelength (address n)
{
	std::string str (1, lobyte (n) );
	str+= hibyte (n);
	return str;
}

std::string spectrum::basicline (address linenum, const std::string & line)
{
	std::string result (linenumber (linenum) );
	result+= linelength (static_cast <address> (line.size () ) + 1);
	result+= line;
	result+= tokEndLine;
	return result;
}


// End of spectrum.cpp
