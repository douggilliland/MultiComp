#ifndef INCLUDE_PASMOTYPES_H
#define INCLUDE_PASMOTYPES_H

// pasmotypes.h
// Revision 8-dec-2004

#include <string>
#include <iostream>

#include <limits.h>
#include <stdlib.h>


#if USHRT_MAX == 65535

typedef unsigned short address;

#else

// Using the C99 types, hoping they will be available.

#include <stdint.h>

typedef uint16_t address:

#endif

#if UCHAR_MAX == 255

typedef unsigned char byte;
typedef signed char sbyte;

#else

#include <stdint.h>

typedef uint8_t byte;
typedef int8_t sbyte;

#endif

inline byte lobyte (address n)
{
	return static_cast <byte> (n & 0xFF);
}

inline byte hibyte (address n)
{
	return static_cast <byte> (n >> 8);
}

inline void putword (std::ostream & os, address word)
{
	os.put (lobyte (word) );
	os.put (hibyte (word) );
}

std::string hex2str (byte b);
std::string hex4str (address n);
std::string hex8str (size_t nn);

inline std::string hex2str (sbyte b)
{ return hex2str (static_cast <byte> (b) ); }
inline std::string hex2str (char b)
{ return hex2str (static_cast <byte> (b) ); }


class Hex2 {
public:
	Hex2 (byte b) : b (b)
	{ }
	byte getb () const
	{ return b; }
	std::string str () const;
private:
	byte b;
};

class Hex4 {
public:
	Hex4 (address n) : n (n)
	{ }
	address getn () const
	{ return n; }
	std::string str () const;
private:
	address n;
};

class Hex8 {
public:
	Hex8 (size_t nn) : nn (nn)
	{ }
	size_t getnn () const
	{ return nn; }
	std::string str () const;
private:
	size_t nn;
};

inline Hex2 hex2 (byte b) { return Hex2 (b); }
inline Hex2 hex2 (sbyte b) { return Hex2 (static_cast <byte> (b) ); }
inline Hex2 hex2 (char b) { return Hex2 (static_cast <byte> (b) ); }
inline Hex4 hex4 (address n) { return Hex4 (n); }
inline Hex8 hex8 (size_t nn) { return Hex8 (nn); }

std::ostream & operator << (std::ostream & os, const Hex2 & h2);
std::ostream & operator << (std::ostream & os, const Hex4 & h4);
std::ostream & operator << (std::ostream & os, const Hex8 & h8);


#endif

// End of pasmotypes.h
