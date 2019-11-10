// cpc.cpp
// Revision 13-dec-2004


#include "cpc.h"

#include <algorithm>
#include <stdexcept>

#include <stdlib.h>

using std::fill;
using std::logic_error;


// This routine is adapted from 2CDT from Kevin Thacker
// (at his time taken from Pierre Guerrier's AIFF decoder).

unsigned short cpc::crc (const unsigned char * data, size_t size)
{
	typedef unsigned short word;
	typedef unsigned char byte;

	const word crcinitial= 0xFFFF;
	const word crcpoly= 0x1021;
	const word crcfinalxor= 0xFFFF;
	const size_t cpcchunksize= 256;

	word crc= crcinitial;
	for (size_t n= 0; n < cpcchunksize; ++n)
	{
		char c= n < size ? data [n] : 0;
		crc^= (static_cast <word> (c) << 8);
		for (size_t i= 0; i < 8; ++i)
		{
			if (crc & 0x8000)
				crc= (crc << 1) ^ crcpoly;
			else
				crc<<= 1;
		}
	}
	crc^= crcfinalxor;
	return crc;
}


cpc::Header::Header ()
{
	clear ();
}

cpc::Header::Header (const std::string & filename)
{
	clear ();
	setfilename (filename);
}

void cpc::Header::clear ()
{
	//memset (data, 0, headsize);
	fill (data, data + headsize, byte (0) );
}

void cpc::Header::setfilename (const std::string & filename)
{
	std::string::size_type l= filename.size ();
	if (l > 16)
		l= 16;
	for (std::string::size_type i= 0; i < l; ++i)
		data [i]= filename [i];
	for (std::string::size_type i= l; i < 16; ++i)
		data [i]= '\0';
}

void cpc::Header::settype (Type type)
{
	byte b;
	switch (type)
	{
	case Basic:
		b= 0; break;
	case Binary:
		b= 2; break;
	default:
		throw logic_error ("Unexpected CPC file type");
	}
	data [0x12]= b;
}

void cpc::Header::setblock (byte n)
{
	data [0x010]= n;
}

void cpc::Header::firstblock (bool isfirst)
{
	data [0x17]= isfirst ? 0xFF : 0x00;
}

void cpc::Header::lastblock (bool islast)
{
	data [0x11]= islast ? 0xFF : 0x00;
}

void cpc::Header::setlength (address len)
{
	data [0x18]= lobyte (len);
	data [0x19]= hibyte (len);
}

void cpc::Header::setblocklength (address blen)
{
	data [0x13]= lobyte (blen);
	data [0x14]= hibyte (blen);
}

void cpc::Header::setloadaddress (address load)
{
	data [0x15]= lobyte (load);
	data [0x16]= hibyte (load);
}

void cpc::Header::setentry (address entry)
{
	data [0x1A]= lobyte (entry);
	data [0x1B]= hibyte (entry);
}

void cpc::Header::write (std::ostream & out)
{
	out.put (0x2C);  // Header identifier.

	out.write (reinterpret_cast <const char *> (data), headsize);
	for (size_t i= headsize; i < 256; ++i)
		out.put ('\x00');

	address crcword= crc (data, headsize);
	out.put (hibyte (crcword) ); // CRC in hi-lo format.
	out.put (lobyte (crcword) );

	out.put (0xFF);
	out.put (0xFF);
	out.put (0xFF);
	out.put (0xFF);
}

cpc::AmsdosHeader::AmsdosHeader ()
{
	clear ();
}

cpc::AmsdosHeader::AmsdosHeader (const std::string & filename)
{
	clear ();
	setfilename (filename);
}

void cpc::AmsdosHeader::clear ()
{
	//memset (amsdos, 0, headsize);
	fill (amsdos, amsdos + headsize, byte (0) );
	amsdos [0x12]= 2; // File type: binary.
}

void cpc::AmsdosHeader::setfilename (const std::string & filename)
{
	amsdos [0]= 0; // User number.
	// 01-0F: filename, padded with 0.
	std::string::size_type l= filename.size ();
	if (l > 15)
		l= 15;
	for (std::string::size_type i= 0; i < l; ++i)
		amsdos [i + 1]= filename [i];
	for (std::string::size_type i= l; i < 15; ++i)
		amsdos [i + 1]= '\0';
}

void cpc::AmsdosHeader::setlength (address len)
{
	// 18-19: logical length.
	amsdos [0x18]= lobyte (len);
	amsdos [0x19]= hibyte (len);
	// 40-42: real length of file.
	amsdos [0x40]= lobyte (len);
	amsdos [0x41]= hibyte (len);
	amsdos [0x42]= 0;
}

void cpc::AmsdosHeader::setloadaddress (address load)
{
	// 15-16: Load address.
	amsdos [0x15]= lobyte (load);
	amsdos [0x16]= hibyte (load);
}

void cpc::AmsdosHeader::setentry (address entry)
{
	// 1A-1B: Entry address.
	amsdos [0x1A]= lobyte (entry);
	amsdos [0x1B]= hibyte (entry);
}

void cpc::AmsdosHeader::write (std::ostream & out)
{
	// 43-44 checksum of bytes 00-42
	address check= 0;
	for (int i= 0; i < 0x43; ++i)
		check+= amsdos [i];
	amsdos [0x43]= lobyte (check);
	amsdos [0x44]= hibyte (check);

	// Write header.
	out.write (reinterpret_cast <char *> (amsdos), headsize);
}


// CPC Locomotive Basic generation.

const std::string cpc::tokHexNumber (1, '\x1C');

const std::string cpc::tokCALL      (1, '\x83');
const std::string cpc::tokLOAD      (1, '\xA8');
const std::string cpc::tokMEMORY    (1, '\xAA');


std::string cpc::number (address n)
{
	std::string r (1, lobyte (n) );
	r+= hibyte (n);
	return r;
}

std::string cpc::hexnumber (address n)
{
	return tokHexNumber + number (n);
}

std::string cpc::basicline (address linenum, const std::string & line)
{
	address linelen= static_cast <address> (line.size () + 5);
	return number (linelen) + number (linenum) + line + '\0';
}

// End of cpc.cpp
