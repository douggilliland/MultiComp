#ifndef INCLUDE_TAP_H
#define INCLUDE_TAP_H

// tap.h
// Revision 4-dec-2004

#include "pasmotypes.h"

#include <string>


namespace tap {

class CodeHeader {
public:
	CodeHeader (address init, address size, const std::string & filename);
	void write (std::ostream & out) const;
	address size () const { return sizeof (block); }
private:
	byte block [21];
};

class CodeBlock {
public:
	CodeBlock (address sizen, const byte * datan);
	void write (std::ostream & out) const;
	address size () const;
private:
	address datasize;
	const byte * data;
	byte head [3];
	byte check;
};

class BasicHeader {
public:
	BasicHeader (const std::string & basic);
	void write (std::ostream & out) const;
private:
	byte block [21];
};

class BasicBlock {
public:
	BasicBlock (const std::string & basicn);
	void write (std::ostream & out) const;
private:
	const std::string & basic;
	address basicsize;
	byte block [3];
	byte check;
};

} // namespace tap

#endif

// End of tap.h
