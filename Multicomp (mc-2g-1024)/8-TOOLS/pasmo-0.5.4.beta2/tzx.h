#ifndef INCLUDE_TZX_H
#define INCLUDE_TZX_H

// tzx.h
// Revision 8-dec-2004

#include <iostream>

#include <stdlib.h>


namespace tzx {

void writefilehead (std::ostream & out);

void writestandardblockhead (std::ostream & out);

void writeturboblockhead (std::ostream & out, size_t len);

} // namespace tzx

#endif

// End of tzx.h
