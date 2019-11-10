// trace.cpp
// Revision 25-apr-2006

#include "trace.h"


#include <iostream>
#include <fstream>
#include <string>
#include <sstream>
#include <algorithm>
#include <stdexcept>

#include <stdlib.h>
#include <string.h>


using std::cerr;
using std::endl;
using std::ostream;
using std::ofstream;
using std::string;
using std::find;


namespace {


ostream * pout= 0;
bool flag= true;
size_t indent= 0;

TraceFunc * initial= NULL;
TraceFunc * * lastpos= & initial;

ostream * opentracefile (const char * filename)
{
	std::ofstream * pof=
		new ofstream (filename, std::ios::app | std::ios::out);
	if (! pof->is_open () )
	{
		cerr << "Error opening " << filename << endl;
		delete pof;
		pof= 0;
	}
	return pof;
}

string traceindent ()
{
	//return string (indent / 8, '\t') + string (indent % 8, ' ');
	return string (indent, ' ');
}

void showinfo (const char * enterexit, const char * funcname)
{
	if (pout)
	{
		* pout << traceindent () << enterexit << ' ';

		if (std::uncaught_exception () )
			* pout << "(throwing) ";

		* pout << funcname << endl;
	}
}

const char BAD_USE []= "Bad use of TraceFunc";


} // namespace


TraceFunc::TraceFunc (const char * funcname_n, const char * shortname_n) :
	funcname (funcname_n),
	shortname (shortname_n ? shortname_n : funcname_n),
	next (NULL)
{
	if (flag)
	{
		flag= false;
		char * aux= getenv ("TRFILE");
		if (aux)
		{
			if (strcmp (aux, "-") == 0)
				pout= & std::cerr;
			else
				pout= opentracefile (aux);
		}
	}

	previous= lastpos;
	* lastpos= this;
	lastpos= & next;

	showinfo ("Enter", funcname);
	++indent;
}

TraceFunc::~TraceFunc ()
{
	--indent;

	showinfo ("Exit", funcname);

	if (next != NULL)
	{
		cerr << BAD_USE << endl;
		abort ();
	}
	if (lastpos != & next)
	{
		cerr << BAD_USE << endl;
		abort ();
	}
	lastpos= previous;
	if (* lastpos != this)
	{
		cerr << BAD_USE << endl;
		abort ();
	}
	* lastpos= NULL;
}

void TraceFunc::message (const std::string & text)
{
	if (pout)
	{
		* pout << traceindent () << shortname;

		if (std::uncaught_exception () )
			* pout << "(throwing) ";

		* pout << ": " << text << endl;
	}
}

void TraceFunc::show (int)
{
	cerr << "\r\n";

	if (initial == NULL)
		cerr << "TraceFunc: no calls.";
	else
	{
		cerr << "TraceFunc dump of calls: \r\n";
		for (TraceFunc * act= initial; act != NULL; act= act->next)
			cerr << act->funcname << "\r\n";
		cerr << "TraceFunc dump ended.";
	}
	cerr << "\r\n";
}

void trace_assertion_failed (const char * a, const char * file, size_t line)
{
	std::ostringstream oss;
	oss << "Assertion failed: '" << a << "' in file " << file <<
		" line " << line;
	throw std::logic_error (oss.str () );
}


// Fin de trace.cpp
