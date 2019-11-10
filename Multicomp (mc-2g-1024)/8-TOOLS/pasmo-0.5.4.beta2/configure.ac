# configure.ac for Pasmo
# Process this file with autoconf to produce a configure script.


AC_PREREQ(2.57)

AC_INIT(pasmo, 0.5.4.beta2, julian.notfound@gmail.com)

AM_INIT_AUTOMAKE

AC_CANONICAL_BUILD
AC_CANONICAL_HOST

########################################################################
#		Options
########################################################################


AC_ARG_ENABLE(debug, AC_HELP_STRING(
	[--enable-debug], [Debug version [[no]]] ) )

if test "$enable_debug" = "yes" ; then
	AC_MSG_RESULT([Configured for debug version])
else
	AC_MSG_RESULT([Configured for release version])
	AC_DEFINE([NDEBUG], [], [Using debug mode])
fi


########################################################################
# Check for programs.


AC_PROG_CXX

AC_LANG_PUSH([C++])


# Check for macros __FUNCTION__ and __PRETTY_FUNCTION__
# for use in trace debugging system.
if test "$enable_debug" = "yes" ; then

	AC_MSG_CHECKING(wheter the C++ compiler(${CXX}) supports __FUNCTION__)
	AC_TRY_LINK([#include <stdio.h>],[puts(__FUNCTION__);],
		have_function=yes,have_function=no)
	AC_MSG_RESULT($have_function)

	if test "$have_function" = "yes" ; then
		AC_DEFINE(HAVE_FUNCTION, [1], [Compiler has __FUNCTION__])
		AC_MSG_CHECKING(wheter the C++ compiler(${CXX}) supports __PRETTY_FUNCTION__)
		AC_TRY_LINK([#include <stdio.h>],[puts(__PRETTY_FUNCTION__);],
			have_pretty_function=yes,have_pretty_function=no)
		AC_MSG_RESULT($have_pretty_function)
		if test "$have_pretty_function" = "yes" ; then
			AC_DEFINE(HAVE_PRETTY_FUNCTION, [1], [Compiler has __PRETTY_FUNCTION__])
		fi
	fi

fi

AC_LANG_POP


########################################################################
# Generate files


AC_CONFIG_FILES([Makefile])

AC_OUTPUT


# End of configure.ac for Pasmo
