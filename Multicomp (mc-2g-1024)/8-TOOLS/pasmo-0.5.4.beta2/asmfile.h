#ifndef INCLUDE_ASMFILE_H
#define INCLUDE_ASMFILE_H

// asmfile.h
// Revision 12-dec-2004

#include "token.h"

#include <iostream>
#include <fstream>
#include <string>

class AsmFile {
public:
	AsmFile ();
	AsmFile (const AsmFile & af);
	~AsmFile ();
	void addincludedir (const std::string & dirname);
	void loadfile (const std::string & filename, bool nocase,
		std::ostream & outverb, std::ostream& outerr);
	size_t getline () const;
protected:
	void openis (std::ifstream & is, const std::string & filename,
		std::ios::openmode mode) const;
	void showlineinfo (std::ostream & os, size_t nline) const;
	void showcurrentlineinfo (std::ostream & os) const;
	bool getvalidline ();
	bool passeof () const;
	Tokenizer & getcurrentline ();
	const std::string & getcurrenttext () const;

	void setline (size_t line);
	void setendline ();
	void beginline ();
	bool nextline ();
	void prevline ();
private:
	class In;
	In * pin;
	In & in ();
	const In & in () const;

	static const size_t LINE_BEGIN= static_cast <size_t> (-1);
	size_t currentline;
};


#endif

// End of asmfile.h
