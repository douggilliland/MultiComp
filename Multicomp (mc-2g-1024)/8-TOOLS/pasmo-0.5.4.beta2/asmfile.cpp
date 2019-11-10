// asmfile.cpp
// Revision 15-jan-2005

#include "asmfile.h"

#include <vector>
#include <stdexcept>

using std::runtime_error;

#include <assert.h>

#define ASSERT assert

namespace {


class FileNotFound : public runtime_error {
public:
	FileNotFound (const std::string & filename) :
		runtime_error ("File '" + filename + "' not found")
	{ }
};

class InvalidInclude : public runtime_error {
public:
	InvalidInclude (const Token & tok) :
		runtime_error ("Unexpected " + tok.str () +
			" after INCLUDE file name")
	{ }
};


class FileLine {
public:
	FileLine (const std::string & text_n, const Tokenizer & tkz_n,
		size_t linenum_n);
	bool empty () const;
	size_t numline () const;
	Tokenizer & gettkz ();
	const std::string & getstrline () const;
private:
	std::string text;
	Tokenizer tkz;
	size_t linenum;
};

FileLine::FileLine (const std::string & text_n, const Tokenizer & tkz_n,
		size_t linenum_n) :
	text (text_n),
	tkz (tkz_n),
	linenum (linenum_n)
{
}

bool FileLine::empty () const
{
	return tkz.empty ();
}

size_t FileLine::numline () const
{
	return linenum;
}

Tokenizer & FileLine::gettkz ()
{
	return tkz;
}

const std::string & FileLine::getstrline () const
{
	return text;
}


typedef std::vector <FileLine> filelines_t;


class FileRef {
public:
	FileRef (const std::string & name, size_t linebeg);
	void setend (size_t n);

	size_t linebegin () const;
	size_t lineend () const;
	std::string name () const;

	bool lineempty (size_t n) const;
	size_t numline (size_t n) const;
	Tokenizer & gettkz (size_t n);
	const std::string & getstrline (size_t n) const;

	void pushline (const std::string & text, const Tokenizer & tkz,
		size_t realnumline);
private:
	std::string filename;
	filelines_t line;
	size_t l_begin;
	size_t l_end;
};

FileRef::FileRef (const std::string & name, size_t linebeg) :
	filename (name),
	l_begin (linebeg)
{ }

void FileRef::setend (size_t n)
{
	l_end= n;
}

size_t FileRef::linebegin () const
{
	return l_begin;
}

size_t FileRef::lineend () const
{
	return l_end;
}

std::string FileRef::name () const
{
	return filename;
}

bool FileRef::lineempty (size_t n) const
{
	ASSERT (n < line.size () );

	return line [n].empty ();
}

size_t FileRef::numline (size_t n) const
{
	ASSERT (n < line.size () );

	return line [n].numline ();
}

Tokenizer & FileRef::gettkz (size_t n)
{
	ASSERT (n < line.size () );

	return line [n].gettkz ();
}

const std::string & FileRef::getstrline (size_t n) const
{
	ASSERT (n < line.size () );

	return line [n].getstrline ();
}

void FileRef::pushline (const std::string & text, const Tokenizer & tkz,
	size_t realnumline)
{
	//line.push_back (FileLine (text, tkz) );
	FileLine fl (text, tkz, realnumline);
	line.push_back (fl);
}


struct LineContent {
public:
	LineContent (size_t linenumn, size_t filenumn);
	size_t getfileline () const;
	size_t getfilenum () const;
private:
	size_t filenum;
	size_t linenum;
};

LineContent::LineContent (size_t filenumn, size_t linenumn) :
	filenum (filenumn),
	linenum (linenumn)
{ }

size_t LineContent::getfileline () const
{
	return linenum;
}

size_t LineContent::getfilenum () const
{
	return filenum;
}


} // namespace


class AsmFile::In {
public:
	In ();
	void addref ();
	void delref ();

	size_t numlines () const;
	size_t numfiles () const;

	bool lineempty (size_t n) const;
	Tokenizer & gettkz (size_t n);
	const std::string & getstrline (size_t n) const;

	void addincludedir (const std::string & dirname);
	void openis (std::ifstream & is, const std::string & filename,
		std::ios::openmode mode) const;
	void copyfile (FileRef & fr, std::ostream & outverb);
	void loadfile (const std::string & filename, bool nocase,
		std::ostream & outverb, std::ostream& outerr);
	void showlineinfo (std::ostream & os, size_t nline) const;
private:
	In (const In &); // Forbidden.
	In & operator = (const In &); // Forbidden.

	const FileRef & getfile (size_t n) const;
	FileRef & getfile (size_t n);

	const LineContent & getline (size_t n) const;
	LineContent & getline (size_t n);

	size_t numrefs;

	typedef std::vector <LineContent> vlinecont_t;
	vlinecont_t vlinecont;

	std::vector <FileRef> vfileref;

	void pushline (size_t linenum, size_t file);

	// ******** Paths for include ************

	std::vector <std::string> includepath;
};

AsmFile::In::In ()
{
	numrefs= 1;
}

void AsmFile::In::addref ()
{
	++numrefs;
}

void AsmFile::In::delref ()
{
	--numrefs;
	if (numrefs == 0)
		delete this;
}

size_t AsmFile::In::numlines () const
{
	return vlinecont.size ();
}

size_t AsmFile::In::numfiles () const
{
	return vfileref.size ();
}

const FileRef & AsmFile::In::getfile (size_t n) const
{
	ASSERT (n < numfiles () );
	return vfileref [n];
}

FileRef & AsmFile::In::getfile (size_t n)
{
	ASSERT (n < numfiles () );
	return vfileref [n];
}

const LineContent & AsmFile::In::getline (size_t n) const
{
	ASSERT (n < numlines () );
	return vlinecont [n];
}

LineContent & AsmFile::In::getline (size_t n)
{
	ASSERT (n < numlines () );
	return vlinecont [n];
}

bool AsmFile::In::lineempty (size_t n) const
{
	ASSERT (n < numlines () );

	//return vlinecont [n].empty ();
	const LineContent & lc= getline (n);
	return getfile (lc.getfilenum () ).lineempty (lc.getfileline () );
}

Tokenizer & AsmFile::In::gettkz (size_t n)
{
	ASSERT (n < numlines () );

	//return vlinecont [n].gettkz ();
	LineContent & lc= getline (n);
	return getfile (lc.getfilenum () ).gettkz (lc.getfileline () );
}

const std::string & AsmFile::In::getstrline (size_t n) const
{
	ASSERT (n < numlines () );

	//return vlinecont [n].getstrline ();
	const LineContent & lc= getline (n);
	return getfile (lc.getfilenum () ).getstrline (lc.getfileline () );
}

void AsmFile::In::addincludedir (const std::string & dirname)
{
	std::string aux (dirname);
	std::string::size_type l= aux.size ();
	if (l == 0)
		return;
	char c= aux [l - 1];
	if (c != '\\' && c != '/')
		aux+= '/';
	includepath.push_back (aux);
}

void AsmFile::In::openis (std::ifstream & is, const std::string & filename,
	std::ios::openmode mode) const
{
	ASSERT (! is.is_open () );
	is.open (filename.c_str (), mode);
	if (is.is_open () )
		return;
	for (size_t i= 0; i < includepath.size (); ++i)
	{
		std::string path (includepath [i] );
		path+= filename;
		is.clear ();
		is.open (path.c_str (), mode);
		if (is.is_open () )
			return;
	}
	throw FileNotFound (filename);
}

void AsmFile::In::pushline (size_t filenum, size_t linenum)
{
	ASSERT (filenum < vfileref.size () );

	vlinecont.push_back (LineContent (filenum, linenum) );
}

void AsmFile::In::copyfile (FileRef & fr, std::ostream & outverb)
{
	using std::endl;

	outverb << "Reloading file: " << fr.name () <<
		" in " << numlines () << endl;

	const size_t linebegin= fr.linebegin ();
	const size_t lineend= fr.lineend ();

	for (size_t i= linebegin; i < lineend; ++i)
	{
		LineContent l= getline (i);
		vlinecont.push_back (l);
	}

	outverb << "Finished reloading file: " << fr.name () <<
		" in " << numlines () << endl;
}

void AsmFile::In::loadfile (const std::string & filename, bool nocase,
	std::ostream & outverb, std::ostream& outerr)
{
	using std::endl;

	for (size_t i= 0; i < vfileref.size (); ++i)
	{
		if (vfileref [i].name () == filename)
		{
			copyfile (vfileref [i], outverb);
			return;
		}
	}

	// Load the file in memory.

	outverb << "Loading file: " << filename <<
		" in " << numlines () << endl;

	std::ifstream file;
	openis (file, filename, std::ios::in);

	vfileref.push_back (FileRef (filename, numlines () ) );
	const size_t filenum= vfileref.size () - 1;

	std::string line;
	size_t linenum;
	size_t realnum;

	try
	{	
		for (linenum= 0, realnum= 0;
			std::getline (file, line);
			++linenum, ++realnum)
		{
			Tokenizer tz (line, nocase);
			Token tok= tz.gettoken ();
			getfile (filenum).pushline (line, tz, realnum);
			pushline (filenum, linenum);
			if (tok.type () == TypeINCLUDE)
			{
				std::string includefile= tz.getincludefile ();
				tok= tz.gettoken ();
				if (tok.type () != TypeEndLine)
					throw InvalidInclude (tok);

				loadfile (includefile, nocase,
					outverb, outerr);

				Tokenizer tzaux (TypeEndOfInclude);
				getfile (filenum).pushline ("", tzaux, 0);
				++linenum;
				pushline (filenum, linenum);
			}
		}
		getfile (filenum).setend (numlines () );
	}
	catch (...)
	{
		outerr << "ERROR on line " << linenum + 1 <<
			" of file " << filename << endl;
		throw;
	}

	outverb << "Finished loading file: " << filename <<
		" in " << numlines () << endl;
}

void AsmFile::In::showlineinfo (std::ostream & os, size_t nline) const
{
	ASSERT (nline < numlines () );

	const LineContent & linf= getline (nline);
	const FileRef & fileref= getfile (linf.getfilenum () );

	os << " on line " << fileref.numline (linf.getfileline () ) + 1 <<
		" of file " << fileref.name ();
}


//*******************************************************************


AsmFile::AsmFile () :
	pin (new In)
{
}

AsmFile::AsmFile (const AsmFile & af) :
	pin (af.pin)
{
	pin->addref ();
}

AsmFile::~AsmFile ()
{
	pin->delref ();
}

// These functions are for propagate constness to the internal class.

inline AsmFile::In & AsmFile::in ()
{
	return * pin;
}

inline const AsmFile::In & AsmFile::in () const
{
	return * pin;
}

void AsmFile::addincludedir (const std::string & dirname)
{
	in ().addincludedir (dirname);
}

void AsmFile::openis (std::ifstream & is, const std::string & filename,
	std::ios::openmode mode) const
{
	in ().openis (is, filename, mode);
}

void AsmFile::loadfile (const std::string & filename, bool nocase,
	std::ostream & outverb, std::ostream& outerr)
{
	in ().loadfile (filename, nocase, outverb, outerr);
}

bool AsmFile::getvalidline ()
{
	for (;;)
	{
		if (currentline >= in ().numlines () )
			return false;
		//if (! in ().getlinecont (currentline).empty () )
		if (! in ().lineempty (currentline) )
			return true;
		++currentline;
	}
}

bool AsmFile::passeof () const
{
	return currentline >= in ().numlines ();
}

size_t AsmFile::getline () const
{
	return currentline;
}

Tokenizer & AsmFile::getcurrentline ()
{
	ASSERT (! passeof () );
	//Tokenizer & tz= in ().getlinecont (currentline).gettkz ();
	Tokenizer & tz= in ().gettkz (currentline);
	tz.reset ();
	return tz;
}

const std::string & AsmFile::getcurrenttext () const
{
	ASSERT (! passeof () );
	//return in ().getlinecont (currentline).getstrline ();
	return in ().getstrline (currentline);
}

void AsmFile::setline (size_t line)
{
	currentline= line;
}

void AsmFile::setendline ()
{
	currentline= in ().numlines ();
}

void AsmFile::beginline ()
{
	currentline= LINE_BEGIN;
}

bool AsmFile::nextline ()
{
	if (currentline == LINE_BEGIN)
		currentline= 0;
	else
	{
		if (passeof () )
			return false;
		++currentline;
	}
	if (! getvalidline () )
		return false;
	return true;
}

void AsmFile::prevline ()
{
	ASSERT (currentline > 0);
	--currentline;
}

void AsmFile::showlineinfo (std::ostream & os, size_t nline) const
{
	in ().showlineinfo (os, nline);
}

void AsmFile::showcurrentlineinfo (std::ostream & os) const
{
	if (passeof () )
		os << " detected after end of file";
	else
		in ().showlineinfo (os, getline () );
}

// End of asmfile.cpp
