// tap.cpp
// Revision 13-dec-2004

#include "tap.h"

#include <algorithm>

using std::fill;

tap::CodeHeader::CodeHeader (address init, address size,
	const std::string & filename)
{
	//memset (block, 0, sizeof (block) );
	fill (block, block + sizeof (block), byte (0) );
	block [0]= 19; // Length of block: 17 bytes + flag  + checksum
	block [1]= 0;
	block [2]= 0;  // Flag: 00 -> header
	block [3]= 3;  // Type: code block.

	// File name.
	std::string::size_type l= filename.size ();
	if (l > 10)
		l= 10;
	for (std::string::size_type i= 0; i < 10; ++i)
		block [4 + i]= i < l ? filename [i] : ' ';

	// Length of the code block.
	block [14]= lobyte (size);
	block [15]= hibyte (size);

	// Start of the code block.
	block [16]= lobyte (init);
	block [17]= hibyte (init);

	// Parameter 2: 32768 in a code block.
	block [18]= 0x00;
	block [19]= 0x80;

	// Checksum
	byte check= block [2]; // Flag byte included.
	for (int i= 3; i < 20; ++i)
		check^= block [i];
	block [20]= check;
}

void tap::CodeHeader::write (std::ostream & out) const
{
	out.write (reinterpret_cast <const char *> (block), sizeof (block) );
}

tap::CodeBlock::CodeBlock (address sizen, const byte * datan) :
	datasize (sizen),
	data (datan)
{
	address blocksize= datasize + 2; // Code + flag + checksum.
	head [0]= lobyte (blocksize);
	head [1]= hibyte (blocksize);
	head [2]= 0xFF; // Flag: data block.

	// Compute the checksum.
	check= 0xFF; // Flag byte included.
	for (int i= 0; i < datasize; ++i)
		check^= data [i];
}

void tap::CodeBlock::write (std::ostream & out) const
{
	out.write (reinterpret_cast <const char *> (head), sizeof (head) );
	out.write (reinterpret_cast <const char *> (data), datasize);
	out.write (reinterpret_cast <const char *> (& check), 1);
}

address tap::CodeBlock::size () const
{
	return datasize + sizeof (head) + 1;
}


tap::BasicHeader::BasicHeader (const std::string & basic)
{
	block [0]= 19;
	block [1]= 0;
	block [2]= 0; // Flag: header.
	block [3]= 0; // Type: Basic block.
	for (int i= 0; i < 10; ++i)
		block [4 + i]= "loader    " [i];
	// Length of the basic block.
	const address basicsize= static_cast <address> (basic.size () );
	block [14]= lobyte (basicsize);
	block [15]= hibyte (basicsize);
	// Autostart in line 10.
	block [16]= '\x0A';
	block [17]= '\x00';
	// Start of variable area: at the end.
	block [18]= block [14];
	block [19]= block [15];
	// Checksum
	byte check= block [2]; // Flag byte included.
	for (int i= 3; i < 20; ++i)
		check^= block [i];
	block [20]= check;
}

void tap::BasicHeader::write (std::ostream & out) const
{
	out.write (reinterpret_cast <const char *> (block), sizeof (block) );
}

tap::BasicBlock::BasicBlock (const std::string & basicn) :
	basic (basicn),
	basicsize (static_cast <address> (basic.size () ) )
{
	address blocksize= basicsize + 2; // Code + flag + checksum.
	block [0]= blocksize & 0xFF;
	block [1]= blocksize >> 8;
	block [2]= 0xFF; // Flag: data block.
	// Compute the checksum.
	check= 0xFF; // Flag byte included.
	for (int i= 0; i < basicsize; ++i)
		check^= static_cast <unsigned char> (basic [i]);
}

void tap::BasicBlock::write (std::ostream & out) const
{
	out.write (reinterpret_cast <const char *> (block), sizeof (block) );
	out.write (basic.data (), basicsize);
	out.write (reinterpret_cast <const char *> (& check), 1);
}

// End of tap.cpp
