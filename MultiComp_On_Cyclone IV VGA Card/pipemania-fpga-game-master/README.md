# PIPE MANIA - GAME FOR FPGA

Pipe Mania is a simple game programmed in VHDL for FPGA, which was created as a study project at VUT Brno in 2014.
Now the game was released under the MIT license and will gradually be optimized for cheap FPGA board [EP4CE6 Starter Board](http://www.ebay.com/itm/111975895262) with Altera FPGA Cyclone IV EP4CE6E22C8 for $45.

![Start Screen](docs/start_screen.JPG?raw=true)

# Control game:

Pipe Mania game can be controlled using the keyboard with the PS/2. The control is used only five keys:

* "w" - move the cursor up
* "s" - move the cursor down / start a game or next level
* "a" - move the cursor left
* "d" - move the cursor right
* "space" - places the generated pipe

# Table of resource usage summary:

LE (LUT+FF) | LUT | FF | Memory bits | Fmax
:---:|:---:|:---:|:---:|:---:
 1176 | 1082 | 485 | 60988 | 60.7 MHz

*Synthesis was performed using Quartus Prime Lite Version 16.0 for device EP4CE6E22C8 with enable "Force use of synchronous clear".*

# License:

This game for FPGA is available under the MIT license (MIT). Please read [LICENSE file](LICENSE).
