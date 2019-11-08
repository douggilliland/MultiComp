\ load camelforth blocks file and compile it
\ from gforth:
\ include gforth_shim.fs

\ TODO in screen 120, valueof #INIT does not account for HP and 0 , for HP is
\ NOT needed. Removed from my code.

\ coded and tested hex dump in ans_hex.fs and ported it into the chromium_ans source.
\
\ todo: fix comments in col 63 properly/cleanly
\ todo: in my source, delete duplicate >< word in assembler.
\ todo: review 28/29 (image to target machine)
\        and    3/27 (image to disk)
\ to make sure they look symmetric

\ DEFINED is used but is not a standard word.
\ F83 and gforth definitions differ -- gforth has it as an immediate word that
\ returns a flag. F83 is not immediate and has more compex effect. Get F83
\ behaviour..
\ : DEFINED ( -- here 0 | cfa [ -1 | 1 ] ) BL WORD FIND ;

\
\ TODO DUMP screen 24 should be renamed IDUMP (in code and documentation)




\ F83 and gforth have different entries in Root. The absence of DEFINITIONS causes the
\ loading to fail. Is gforth right or over-pessimistic? For now I just add them
\ to Root. Might lobby for the addition of these for F83 compat and add bye for convenience.
\ F83 has    ALSO ONLY SEAL PREVIOUS FORTH DEFINITIONS ORDER VOCS WORDS
\ gforth has                         FORTH             ORDER      WORDS SET-ORDER FORTH-WORDLIST
\ Root definitions
\ ' definitions Alias definitions
\ ' also        Alias also
\ ' only        Alias only
\ ' bye         Alias bye
\
\ Forth definitions



\ in F83 but not in ANS or gforth
\ : 2+ 2 + ;

\ in F83 it's a variable that defines the width of the name field
\ Original Camelforth has limit of 128. With my mods to put other bits
\ in the name file, it is less. Chromium is restricted to lesser of host
\ limit and camelforth limit. gforth has no limit so this could be higher
\ TODO should be in early source screen and porting guide.
VARIABLE WIDTH
31 WIDTH !

\ TODO no ANS way to do this nor gforth way (that I can see). Code it out to
\ avoid straggly output.
\ now only used in DUMP, screen 24.
VARIABLE #OUT
0 #OUT !

\ F83 END? is a variable that is true when the input source has been exhausted
\ make it always false. Should be an ANS word to replace this..
VARIABLE END?
0 END? !

\ F83 DONE? copied from F83 source..
: DONE? ( n -- f)
    STATE @ <> END? @ OR END? OFF ;

\ Need NEST which was a constant in camelsource
: WHAT ." This is NEST executing. BAD!" ;
' WHAT CONSTANT NEST

\ Need \S copied from F83
\ TODO I don't think this is needed in the chromium source.
: \S END? ON ; IMMEDIATE

\ ON and OFF are non-ANS but found in gforth.


\ gforth standard version doesn't cope with unidentified words
\ TODO: rename it .XTID and include the >NAME part.
\ make it pad to n-char width then eliminate TAB which is not implemented.

\ Given an XT, report the name of the word in a field at least n characters wide,
\ right-padded with spaces.
\ delete TAB and #OUT. >NAME and NAME>STRING are gforth
\ : .XTID ( xt n -- ) >R >NAME DUP 0= IF DROP S" <noname>" ELSE NAME>STRING THEN DUP >R TYPE R> R> SWAP - 1 MAX SPACES ;



use chromium_ans.scr

\ for multicomp. Do "1 load" for vanilla (sm2) system
45 load


\ Portability bug in IMMED: it used "2 +" where it should have used CELL +. A real
\ Brad bug!! Fixed!!


\ NUMBER? not a standard word
\
\ F83 ( adr -- d flag)
\
\ ie leaves a DOUBLE, but gforth leaves a single-cell.
\
\ "fix" is simply to remove the DROP at 014:07 and turn 2DROP to DROP at 014:10
\ but this needs further investigation for a proper portable fix.


\ barfs "unstructured" on EMULATE:    ;EMULATE
\
\ problem there is a non-portability:
\ : foo: :noname [ .s ] ;
\ shows that there are 4 values underneath the xt. Usually, ";" consumes them. But they
\ also block access to the xt -- the ! was consuming the wrong value.
\ the "fix" is also non-portable: move those values to the return stack and grab them
\ back later.


\ got an overflow error. FULL? checks *after* a store. After the store to 0xffff
\ an overflow is reported because the DP is incremented to 0x10000, even though
\ there is no attempt to store beyond that address. In F83, a 16-bit host, there
\ was a bug because the store to 0xffff caused the address to wrap to 0. This
\ avoided an error being reported but, on the other hand, allowed the image to
\ overwrite to non-dictionary space. Similarly, the checking is simplistic because
\ it only tests one limit of the TDP; it ought to do a "within" check.
\
\ Simple fix is to do the overflow check BEFORE doing a store, instead of AFTER
\ updating the address. This is a good fix for 32-bit FORTH host but will fail for
\ 16-bit FORTH host because the address will wrap from ffff->0 and so remain legal
\ (less than the limit)


\ now runs to completion AND the resultant image matches the F83 binary, but 2
\ problems remain:

\ when setting EVERYONE=1 on scr 23, Should show all mirror words but fails on
\ the final word because exec is invalid memory address instead of .UNDEF .. seems
\ to be a consequence of a CREATE..DOES> sequence, so may be related to the next
\ problem..
\
\ MDOES> cannot be being used because it's still coding a bogus value for "nest".
\
\ .MIRRORS cannot work as coded with EVERYONE=1 because exec can have a headerless
\ word and then ">NAME .ID" will fail with "Invalid memory address"
\ .. what does this do in F83?

\ .ID in .MIRRORS is in F83 and gforth but not ANS.
\ F83 version is benign to bogus addresses; gforth one is not. 
\ .ID should check for 0 and print "<NONAME>"
