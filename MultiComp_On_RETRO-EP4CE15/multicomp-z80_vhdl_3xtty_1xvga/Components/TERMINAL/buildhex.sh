#!/bin/bash
#
# Build Intel-Hex Char-ROM File...

# Build CGABlkGrf.hex from CGABlkGrf.bin
# Start-adress: 0x0000H
#echo "processing CGABlkGrf.bin..."
#./bin2hex -o 0000 CGABlkGrf.bin CGABlkGrf.HEX
#echo

# Build CGABlkGrfReduced.hex from CGABlkGrfReduced.bin
# Start-adress: 0x0000H
echo "processing CGABlkGrf.bin..."
./bin2hex -o 0000 CGABlkGrfReduced.bin CGABlkGrfReduced.HEX

echo
echo ".....Fertig !"
echo
echo
