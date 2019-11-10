;			MAS
;

;	Revista "El Ordenador Personal" num 57, marzo 1987
;	Autor: L. Suárez

; Adaptación para posibilitar su ensamblado para CP/M 86
; con pasmo por Julian Albo.

;El programa funciona como la orden TYPE de CPM, excepto que se
;detiene cada vez que se escriben 24 líneas de pantalla, esperando por la
;pulsación de cualqier tecla.
;La sintaxis correcta es: MAS d:FILENAME.TYP, en la que d es la
;identificación del drive en el que se encuentra el archivo
;FILENAME.TYP.
;			VALORES UTILIZABLES
NULO	EQU 00H	; Caracter nulo.
BACK	EQU 08H	; Cursor un lugar a la izquierda.
LF	EQU 0AH	; Cursor una línea abajo.
UP	EQU 0BH	; Cursor una línea arriba.
CLS	EQU 0CH	; Cursor a la página siguiente.
CR	EQU 0DH	; Cursor al comienzo de la línea.
EOF	EQU 1AH	; Señala el final de un archivo ASCII.
FIL	EQU 24	; Número de filas de pantalla.
COL	EQU 80	; Número de columnas de pantalla.

TASEC	EQU 128	; Tamaño de un sector.

	if ! defined CPM86
TAPILA	EQU 50	; Tamaño de la pila, o stack.
	endif

CMDBUF	EQU 0080H	; Buffer del CP/M para órdenes.
DFTFCB12	EQU 0068H
DFTFCB	EQU 005CH	; Dirección del FCB por defecto.
BDOS	EQU 5	; Punto de entrada de las rutinas BDOS.
PRBYT	EQU 2	; Envia un caracter a la pantalla.
INOUT	EQU 6	; Enviar/Recibir un byte pant/teclado.
OPEN	EQU 15	; Abrir un archivo.
READSE	EQU 20	; Leer sectores de forma secuencial.
SETDMA	EQU 26	; Lugar para dejar sector leído.
RECIB	EQU 0FFH	; Para indicar recibir desde teclado.

	ORG 100H

	if ! defined CPM86
	LD (STACK), SP	; Resguardo del stack.
	LD SP, PILA	; nuevo stack para programa.
	else
	; Install a call to bdos in the cp/m bdos call address
	ld a,0CDh
	ld (5),a
	ld a,0E0h
	ld (6),a
	ld a,0C3h
	ld (7),a
	endif

	CALL PANCR	; Cursor a nueva línea.
	LD A, (CMDBUF)	; Num. de caracteres de la
	CP 2		; orden inicial
	JP C, ERROR
	LD HL, DFTFCB12	; Lugar siguiente al nombre.
	LD B, 24	; Resto del FCB.
INI1:	LD (HL), NULO	; relleno con ceros.
	INC HL

	DJNZ INI1

	LD DE, DFTFCB	; Dirección del FCB del
	LD A, OPEN	; archivo a abrir.
	CALL CPM	; Sale con A=0FFH si no
	INC A		; existe el archivo buscado.
	JP Z, ERROR	; No existe.
	LD C, FIL	; Inicia la cuenta de filas,
	LD B, COL	; y de columnas.
LEER:	LD DE, DMASRC	; Donde colocar el sector.
	LD A, SETDMA	; que se va a leer y,
	CALL CPM
	LD DE, DFTFCB	; desde que archivo se lee.
	LD A, READSE	; Leer sector secuencialmente.
	CALL CPM	; Sale con A=0 si pudo leer.
	OR A		; ¿Final archivo?
	JP NZ, FINAL	; Sí, ya no hay más.
	LD HL, DMASRC	; Apunta a comienzo de sector.
ESC1:	LD A, (HL)	; Toma un caracter.
	CP EOF		; ¿Es el final del archivo?
	JP Z, FINAL	; Sí, no hay más.
	OR A		; ¿Otro tipo de final?
	JP Z, FINAL	; Sí, no hay más.
	CP CLS		; ¿Cursor a página nueva?
	JR NZ, ESC2	; No.
	LD C, FIL	; Sí, reinciar filas,
	LD B, COL	; y columnas.
	JR ESPERA
ESC2:	CP LF		; ¿A la línea inferior?
	JR NZ, ESC4	; No.
ESC3:	DEC C		; Sí, una fila menos.
	LD A, C
	OR A		; ¿Era la última?
	JR NZ, ESCRIB	; No.
	LD C, FIL	; Sí, reinicia filas.
	JR ESPERA
ESC4:	CP CR		; ¿A comienzo de línea?
	JR NZ, ESC5	; No.
	LD B, COL	; Sí, reinicia columnas.
	JR ESCRIB
ESC5:	CP UP		; ¿A la línea superior?
	JR NZ, ESC7	; No.
ESC6:	INC C		; Sí, una fila más.
	LD A, FIL
	CP C		; ¿Era ya C el valor máximo?
	JR NC, ESCRIB	; No.
	LD C, A		; FIL como máximo.
	JR ESCRIB
ESC7:	CP BACK		; ¿Cursor un lugar atrás?
	JR NZ, ESC8	; No.
	INC B		; Sí, una columna más.
	LD A, COL
	CP B		; ¿Era B ya el valor máximo?
	JR NC, ESCRIB	; No.
	LD B, 1		; Sí, último de la anterior,
	JR ESC6		; y aumentar el num. de filas.
ESC8:	DEC B		; En cualquier otro caso, una
	LD A, B		; columna menos, salvo que ya
	OR A		; fuese la última.
	JR NZ, ESCRIB	; No.
	LD B, COL	; Sí, reinicia columnas,
	JR ESC3		; y reduce el num. de filas.
ESPERA:	LD E, RECIB	; Espera a que se pulse una
	LD A, INOUT	; tecla cualquiera.
	CALL CPM
	OR A		; ¿Se ha pulsado alguna?
	JR Z, ESPERA	; No.
ESCRIB:	LD E, (HL)	; Sí, tomar de nuevo el mismo
	CALL SALPAN	; carc. y enviarlo a pantalla.
	LD DE, FINDMA
	INC HL
	LD A, H		; ¿Es el final del sector?
	CP D
	JR C, ESC1	; No, ya que HL<DE.
	JP NZ, LEER	; Sí, es HL>DE.
	LD A, L		; Puesto que H=D ver L y E.
	CP E
	;JR C, ESC1	; No, ya que HL<DE.
	JP C, ESC1	; No, ya que HL<DE.
	JP LEER		; Como HL>=DE, leer otro
			; sector del archivo.

CPM	PUSH HL		; Resguardar HL.
	PUSH BC		; Resguardar BC.
	LD C, A		; Índice de rutina a C.
	CALL BDOS
	POP BC		; Recuperar BC.
	POP HL		; Recuperar HL.
	RET

PANCR:	LD E, LF	; Una línea más abajo.
	CALL SALPAN
	LD E, CR	; y al comienzo de la misma.
SALPAN:	LD A, PRBYT	; Enviar el caracter en E a la
	CALL CPM	; pantalla.
	RET

ERROR:	LD HL, CMDBUF	; CP/M deja allí la orden.
	LD A, (HL)	; inicial, con A caracteres.
	OR A
	JR Z, FINAL0	; No hay ninguno tras MAS.
	INC HL		; Si los hay, pasa el número
	LD B, A		; al registro B,
ESORD1:	LD E, (HL)	; los toma uno a uno, y los
	CALL SALPAN	; saca a pantalla.
	INC HL

	DJNZ ESORD1

FINAL0:	LD E, '?'	; Más una interrogación, y
	CALL SALPAN
FINAL:	CALL PANCR	; pasa a una línea más abajo.

	if ! defined CPM86
	LD SP, (STACK)	; Recupera el stack original,
	RET		; y termina el programa.
	else
	ld c, 0
	call BDOS
	endif

	if ! defined CPM86
STACK:	DS 2		; Para guardar el stack.
PILA	EQU $ + TAPILA	; Comienzo stack propio.
DMASRC	EQU PILA + 1	; Comienzo almacén sector.

	else

DMASRC	EQU $

	endif

FINDMA	EQU DMASRC + TASEC	; Siguiente a último lugar
				; del almacén del sector.

this_is_the_end:	END
