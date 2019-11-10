#ifndef INCLUDE_TRACE_H
#define INCLUDE_TRACE_H

// trace.h
// Revision 12-apr-2008

#include <cstddef>
#include <string>


#ifndef NDEBUG
#include <sstream>
#endif


class TraceFunc {
public:
	TraceFunc (const char * funcname_n, const char * shortname_n= 0);
	~TraceFunc ();
	void message (const std::string & text);
	static void show (int);
private:
	const char * funcname;
	const char * shortname;
	TraceFunc * * previous;
	TraceFunc * next;
};


#ifndef NDEBUG


#define TRFUNC(tr,name) \
	TraceFunc tr (name, name)
#define TRMESSAGE(tr,text) \
	tr.message (text)
#define TRSTREAM(tr,tex) \
	{ \
		std::ostringstream oss; \
		oss << tex; \
		tr.message (oss.str () ); \
	}

#ifdef HAVE_FUNCTION

#ifdef HAVE_PRETTY_FUNCTION
#define TRF \
	TraceFunc tracefunc_obj (__PRETTY_FUNCTION__, __FUNCTION__)
#define TRFDEB(text) \
	TraceFunc tracefunc_obj (__PRETTY_FUNCTION__, __FUNCTION__); \
	tracefunc_obj.message (text)
#define TRFDEBS(tex) \
	TraceFunc tracefunc_obj (__PRETTY_FUNCTION__, __FUNCTION__); \
	{ \
		std::ostringstream oss; \
		oss << tex; \
		tracefunc_obj.message (oss.str () ); \
	}
#else
#define TRF \
	TraceFunc tracefunc_obj (__FUNCTION__)
#define TRFDEB(text) \
	TraceFunc tracefunc_obj (__FUNCTION__); \
	tracefunc_obj.message (text)
#define TRFDEBS(tex) \
	TraceFunc tracefunc_obj (__FUNCTION__); \
	{ \
		std::ostringstream oss; \
		oss << tex; \
		tracefunc_obj.message (oss.str () ); \
	}
#endif

#else

#define TRF \
	TraceFunc tracefunc_obj ("[unknown function name]")
#define TRFDEB(text) \
	TraceFunc tracefunc_obj ("[unknown function name]"); \
	tracefunc_obj.message (text)
#define TRFDEBS(tex) \
	TraceFunc tracefunc_obj ("[unknown function name]"); \
	{ \
		std::ostringstream oss; \
		oss << tex; \
		tracefunc_obj.message (oss.str () ); \
	}

#endif

#define TRDEB(text) \
	tracefunc_obj.message (text)

#define TRDEBS(tex) \
	{ \
		std::ostringstream oss; \
		oss << tex; \
		tracefunc_obj.message (oss.str () ); \
	}


void trace_assertion_failed (const char * a, const char * file, size_t line);

#define ASSERT(a) \
	if (a) ; \
	else trace_assertion_failed (#a, __FILE__, __LINE__)


#else


#define TRFUNC(tr,name)
#define TRMESSAGE(tr,text)
#define TRSTREAM(tr,text)

#define TRF
#define TRFDEB(text)
#define TRFDEBS(tex)
#define TRDEB(text)
#define TRDEBS(tex)

#define ASSERT(a)


#endif


#endif

// Fin de trace.h
