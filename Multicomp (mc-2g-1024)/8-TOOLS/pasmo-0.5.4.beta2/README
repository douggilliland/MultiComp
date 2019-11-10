
	See english version below.



	ESPAÑOL.


	Pasmo, ensablador Z80 cruzado multiplataforma.
	(C) 2004-2008 Julián Albo
	Utilización y distribución permitida bajo la licencia GPL.

	Para descargar actualizaciones o obtener más información:
	http://www.arrakis.es/~ninsesabe/pasmo/

	Para compilar:
		./configure
		make

	Para instalar:
		make install

	Para compilar con otras opciones:
		./configure --help

	Documentación: Disponible solamente en inglés, en el fichero
	pasmodoc.html incluido en este paquete o en el sitio web de
	Pasmo. Ver también los ficheros .asm de ejemplo incluidos en
	el paquete de los fuentes.

	Para ensamblar:
		pasmo [ opciones ] fichero.asm fichero.bin
			[ fichero.simbolos [fichero.publicos] ]

	Opciones:

		-d         -->	Mostrar información de depuración
				durante el ensamblado.

		-1         -->	Mostrar información de depuración
				durante el ensamblado, también en
				el primer paso.

		-v         -->	Verboso. Muestra información de
				progreso del ensamblado.

		-I         -->	Añadir directorio a la lista de
				directorios en los que se buscarán
				ficheros para INCLUDE e INCBIN.

		--bin      -->	Generar el fichero objeto en binario
				puro sin cabecera.

		--hex      -->	Generar el fichero objeto en formato
				Intel HEX.

		--prl      -->	Generar el fichero objeto en formato
				PRL. Adecuado para RSX de CP/M Plus.

		--cmd      -->	Generar el fichero objeto en formato
				CMD de CP/M 86.

		--plus3dos -->	Generar el fichero objeto con cabecera
				PLUS3DOS (Spectrum disco).

		--tap      -->	Generar un fichero .tap para emuladores
				de Spectrum (imagen de cinta).

		--tzx      -->	Generar un fichero .tzx para emuladores
				de Spectrum (imagen de cinta).

		--cdt      -->	Generar un fichero .cdt para emuladores
				de Amstrad CPC (imagen de cinta).

		--tapbas   -->	Igual que que la opción --tap pero
				añadiendo un cargador Basic.

		--tzxbas   -->	Igual que que la opción --tzx pero
				añadiendo un cargador Basic.

		--cdtbas   -->	Igual que que la opción --cdt pero
				añadiendo un cargador Basic.

		--amsdos   -->	Generar el fichero objeto con cabecera
				Amsdos (Amstrad CPC disco).

		--msx      -->	Generar el fichero objeto con cabecera
				para usarse con BLOAD en MSX Basic.

		--public   -->	El listado de símbolos incluirá sólo los
				declarados PUBLIC.

		--name     -->	Nombre para la cabecera en los formatos
				que lo usan (si no se especifica se usa
				el nombre del fichero objeto).

		--err      -->	Dirige los mensajes de error a la salida
				estándar en vez de a la salida de error
				(excepto los errores en las opciones).

		--nocase   -->	Hace que los identificadores no distingan
				mayúsculas de minúsculas.

		--alocal   -->	Modo autolocal: las etiquetas que comienzan
				por un '_' son locales y su ámbito termina
				en la sigiente etiqueta no local o en la
				siguiente directiva PROC, LOCAL o MACRO.

		-B
		--bracket  -->	Modo sólo corchetes: los paréntesis quedan
				reservados para expresiones.

		-E
		--equ	   -->	Predefine una etiqueta.

		-8         
		--w8080    -->	Mostrar warning cuando se usan instrucciones
				del z80 que no exsiten en el 8080.

		--86       -->	Generar código 8086.

		-          -->	Fin de opciones, todo lo que siga se
				consideran nombres de fichero aunque
				comience por -.


	Si no hay ninguna opción de formato de objeto se asume --bin.

	La información de depuración va a la salida estándar, los errores
a la salida de error.


Comentarios y críticas a: julian.notfound@gmail.com


		*		*		*



	ENGLISH.


	Pasmo, multiplatform Z80 cross-assembler.
	(C) 2004-2008 Julián Albo
	Use and distribution allowed under the terms of the GPL license.

	To download updates or obtain more information:
	http://www.arrakis.es/~ninsesabe/pasmo/

	To compile:
		./configure
		make

	To install:
		make install

	To compile with other options:
		./configure --help

	Documentation: See the file pasmodoc.html, included in this
	package or in the Pasmo web site. See also the .asm sample
	files included with the souce package.

	To assemble:
		pasmo [ options ] file.asm file.bin
			[ file.symbol [ file.publics ] ]

	Options:

		-d         -->	Show debug info during assembly.

		-1         -->	Show debug info during assembly,
				also in first pass.

		-v         -->	Verbose. Show progress information
				during assembly.

		-I         -->	Add directory to the list for
				searching files in INCLUDE and INCBIN.

		--bin      -->	Generate the object file in pure binary
				format without headers.

		--hex      -->	Generate the object file in Intel HEX
				format.

		--prl      -->	Generate the object file in the PRL
				format. Useful for CP/M Plus RSX.

		--cmd      -->	Generate the object file in CP/M 86
				CMD format.

		--plus3dos -->	Generate the object file with PLUS3DOS
				header (Spectrum disk).

		--tap      -->	Generate a .tap file for Spectrum
				emulators (tape image).

		--tzx      -->	Generate a .tzx file for Spectrum
				emulators (tape image).

		--cdt      -->	Generate a .cdt file for Spectrum
				emulators (tape image).

		--tapbas   -->	Same as --tap option but adding a
				Basic loader.

		--tzxbas   -->	Same as --tzx option but adding a
				Basic loader.

		--cdtbas   -->	Same as --cdt option but adding a
				Basic loader.

		--amsdos   -->	Generate the object file with Amsdos
				header (Amstrad CPC disk).

		--msx      -->	Generate the object file with header
				for use with BLOAD in MSX Basic.

		--public   -->	The symbol table listing will include
				only symbols declared as PUBLIC.

		--name     -->	Name for the header in the formats that
				use it. If unspecified the object file
				name will be used.

		--err      -->	Direct error messages to standard ouptut
				instead of error output (except for errors
				in options).

		--nocase   -->	Make identifiers case insensitive.

		--alocal   -->	Autolocal mode: the labels than begins with
				a '_' are locals, and his ambit finishes in
				the next no local label or in the next PROC,
				LOCAL or MACRO directive.

		-B
		--bracket  -->	Bracket only mode: parenthesis are reserved
				for expressions.

		-E
		--equ	   -->	Predefine a label.

		-8
		-w8080     -->	Show warnings when using Z80 instructions
				that does not exist in 8080.

		--86       -->	Generate 8086 code.


	If no code generation options are specified --bin is assumed.

	Debug info goes to standard output, error messages to error
output.


Comments and criticisms to: julian.notfound@gmail.com
