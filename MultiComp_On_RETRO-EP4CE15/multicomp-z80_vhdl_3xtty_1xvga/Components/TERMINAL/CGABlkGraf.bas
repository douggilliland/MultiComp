' =======================
' == Block Graphic ROM ==
' =======================
'
dim ROM(256,8)

maskL% = $F0
maskH% = $0F
komma$ = ","

' Jede Char-Zelle besteht aus 8 Byte.
' Jedes Block-Pixel selbst wird aus 4x2
' Pixeln aufgebaut. Die fertige Char-Zelle
' hat dann nachfolgendes aussehen:
' =========================================
    ' Byte1: nibble01% OR nibble02%
    '     2: nibble01% OR nibble02%
    ' Byte3: nibble04% OR nibble08%
    '     4: nibble04% OR nibble08%
    ' Byte5: nibble10% OR nibble20%
    '     6: nibble10% OR nibble20%
    ' Byte7: nibble40% OR nibble80%
    '     8: nibble40% OR nibble80%
'
byteHL% = $F0
byteLH% = $0F
byteLL% = $00
'
' Generate 256 Block-Graphic Characters a' la' TRS-80
'
filename$="CGABlkGrf.bin"

open "O",#1,filename$

' Erstelle das Block-Grafik ROM...
for ch%=0 to 255 step 1
   @generate(ch%,ROM())
next ch%

' Schreibe ROM-Daten in File
' File-Size muss am Ende 2048 Byte sein !
for ch%=0 to 255 step 1
   for j% = 0 to 7 step 1
      byte% = ROM(ch%,j%)
      out #1,byte%
   next j%
next ch%

' Fertig und Schluss...
close #1

end
exit
quit

' #####################################################
' ################## Unterprogramme ###################
' #####################################################

Procedure generate(ch%,VAR ROM())
   local i%

   for i%=0 to 6 step 2
      byte% = $00

      if btst(ch%,i%) then
         byte% = byte% OR byteHL%
      endif

      byte% = byte% AND $FF
'      ? "====> ch% =";ch%;"   ====> i% = ";i%
      rom(ch%,i%+0) = byte%
      rom(ch%,i%+1) = byte%

      if btst(ch%,i%+1) then
         byte% = byte% OR byteLH%
      endif

      byte% = byte% AND $FF
'      ? "====> ch% =";ch%;"   ====> i% = ";i%
      rom(ch%,i%+0) = byte%
      rom(ch%,i%+1) = byte%
   next i%

return
