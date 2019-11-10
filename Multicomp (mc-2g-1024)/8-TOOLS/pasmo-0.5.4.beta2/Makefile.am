# Makefile.am for Pasmo

bin_PROGRAMS = pasmo

pasmo_SOURCES = \
	asm.h \
	asm.cpp \
	asmfile.h \
	asmfile.cpp \
	cpc.h \
	cpc.cpp \
	pasmo.cpp \
	pasmotypes.h \
	pasmotypes.cpp \
	spectrum.h \
	spectrum.cpp \
	tap.h \
	tap.cpp \
	token.h \
	token.cpp \
	trace.h \
	trace.cpp \
	tzx.h \
	tzx.cpp

tgz: dist
	cp $(distdir).tar.gz $(distdir).tgz

rpm: dist
	rpm -ta $(distdir).tar.gz


EXAMPLE_ASM = \
	align.asm \
	all.asm \
	allb.asm \
	alocal.asm \
	bad.asm \
	black.asm \
	callvers.asm \
	defb.asm \
	echovers.asm \
	fill8k.asm \
	hellocpc.asm \
	hellocpm.asm \
	hellospec.asm \
	hilo.asm \
	hola.asm \
	if.asm \
	include.asm \
	indent.asm \
	jumptable.asm \
	lee.asm \
	limit64.asm \
	local.asm \
	macro.asm \
	mas.asm \
	protector.asm \
	rept.asm \
	reserv.asm \
	showfcb.asm \
	showkeys.asm \
	showline.asm \
	t86.asm \
	test.asm \
	tmacro.asm \
	undoc.asm


EXTRA_DIST = \
	bootstrap autogen.sh \
	pasmodoc.html \
	$(EXAMPLE_ASM)


ACLOCAL_AMFLAGS = -I .

# End of Makefile.am for Pasmo
