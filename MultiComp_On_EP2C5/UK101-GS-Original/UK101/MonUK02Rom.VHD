-- Copyright of the original ROM contents respectfully acknowleged

-- This file was created and maintaned by Grant Searle 2014
-- You are free to use this file in your own projects but must never charge for it nor use it without
-- acknowledgement.
-- Please ask permission from Grant Searle before republishing elsewhere.
-- If you use this file or any part of it, please add an acknowledgement to myself and
-- a link back to my main web site http://searle.hostei.com/grant/    
-- and to the UK101 page at http://searle.hostei.com/grant/uk101FPGA/index.html
--
-- Please check on the above web pages to see if there are any updates before using this file.
-- If for some reason the page is no longer available, please search for "Grant Searle"
-- on the internet to see if I have moved to another web hosting service.
--
-- Grant Searle
-- eMail address available on my main web page link above.

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
	use ieee.std_logic_unsigned.all;

ENTITY MonUK02Rom IS

	PORT
	(
		address : in std_logic_vector(10 downto 0);
		q : out std_logic_vector(7 downto 0)
	);
END MonUK02Rom;

architecture behavior of MonUK02Rom is
type romtable is array (0 to 2047) of std_logic_vector(7 downto 0);
constant romdata : romtable :=
(
x"0B",x"F8",x"0B",x"0B",x"0A",x"0A",x"0A",x"0D",x"20",x"20",x"0B",x"8A",x"48",x"98",x"48",x"A5",x"E3",x"48",x"A5",x"E4",x"48",x"AD",x"07",x"02",x"8D",x"09",x"02",x"AD",x"08",x"02",x"8D",x"0A",
x"02",x"A2",x"08",x"BD",x"02",x"F8",x"20",x"57",x"FA",x"CA",x"10",x"F7",x"20",x"E7",x"F9",x"D0",x"FB",x"CA",x"D0",x"FD",x"20",x"A5",x"F9",x"29",x"FF",x"30",x"F9",x"C9",x"0C",x"F0",x"F5",x"C9",
x"1C",x"D0",x"05",x"20",x"24",x"F9",x"10",x"EC",x"C9",x"0D",x"F0",x"0F",x"10",x"05",x"20",x"57",x"FA",x"10",x"E1",x"20",x"03",x"F9",x"20",x"57",x"FA",x"10",x"D9",x"20",x"17",x"FB",x"CE",x"08",
x"02",x"8C",x"07",x"02",x"20",x"8D",x"FB",x"B1",x"E3",x"C9",x"20",x"D0",x"08",x"C8",x"C0",x"30",x"D0",x"F5",x"EE",x"08",x"02",x"A0",x"00",x"20",x"8D",x"FB",x"B1",x"E3",x"C9",x"20",x"F0",x"16",
x"EE",x"08",x"02",x"A9",x"2E",x"8D",x"07",x"02",x"A2",x"60",x"20",x"ED",x"F8",x"CA",x"D0",x"FA",x"20",x"F2",x"F9",x"20",x"F2",x"F9",x"20",x"F2",x"F9",x"AD",x"07",x"02",x"48",x"AD",x"08",x"02",
x"48",x"EE",x"08",x"02",x"A9",x"2F",x"8D",x"07",x"02",x"A2",x"5F",x"20",x"8D",x"FB",x"B1",x"E3",x"C9",x"20",x"D0",x"07",x"20",x"05",x"FA",x"CA",x"D0",x"F1",x"E8",x"E0",x"48",x"30",x"02",x"A2",
x"47",x"8E",x"0B",x"02",x"68",x"8D",x"08",x"02",x"68",x"8D",x"07",x"02",x"20",x"8D",x"FB",x"B1",x"E3",x"8D",x"01",x"02",x"A2",x"03",x"BD",x"67",x"FF",x"9D",x"18",x"02",x"CA",x"10",x"F7",x"68",
x"85",x"E4",x"68",x"85",x"E3",x"68",x"A8",x"68",x"AA",x"AD",x"01",x"02",x"60",x"20",x"8D",x"FB",x"B1",x"E3",x"48",x"20",x"F2",x"F9",x"20",x"8D",x"FB",x"68",x"91",x"E3",x"20",x"05",x"FA",x"20",
x"05",x"FA",x"60",x"48",x"20",x"17",x"FB",x"A2",x"47",x"20",x"F2",x"F9",x"CA",x"D0",x"FA",x"A2",x"47",x"20",x"ED",x"F8",x"CA",x"10",x"FA",x"20",x"F2",x"F9",x"20",x"8D",x"FB",x"B1",x"E3",x"8D",
x"01",x"02",x"68",x"60",x"AD",x"07",x"02",x"48",x"AD",x"08",x"02",x"48",x"20",x"17",x"FB",x"A2",x"47",x"20",x"F2",x"F9",x"20",x"8D",x"FB",x"B1",x"E3",x"48",x"20",x"05",x"FA",x"20",x"8D",x"FB",
x"68",x"91",x"E3",x"20",x"F2",x"F9",x"CA",x"10",x"E8",x"68",x"8D",x"08",x"02",x"68",x"8D",x"07",x"02",x"48",x"4C",x"1A",x"F9",x"EC",x"0B",x"02",x"F0",x"25",x"8A",x"48",x"98",x"48",x"A5",x"E3",
x"48",x"A5",x"E4",x"48",x"20",x"F2",x"F9",x"20",x"8D",x"FB",x"A0",x"00",x"B1",x"E3",x"8D",x"00",x"02",x"68",x"85",x"E4",x"68",x"85",x"E3",x"68",x"A8",x"68",x"AA",x"AD",x"00",x"02",x"60",x"98",
x"48",x"AD",x"09",x"02",x"8D",x"07",x"02",x"AD",x"0A",x"02",x"8D",x"08",x"02",x"CE",x"08",x"02",x"A9",x"20",x"8D",x"01",x"02",x"A0",x"03",x"B9",x"F0",x"FE",x"99",x"18",x"02",x"88",x"10",x"F7",
x"68",x"A8",x"A9",x"0D",x"60",x"A0",x"01",x"84",x"E3",x"AC",x"10",x"02",x"A2",x"50",x"20",x"E7",x"F9",x"D0",x"1D",x"CA",x"D0",x"F8",x"88",x"D0",x"F3",x"A5",x"E3",x"D0",x"0E",x"20",x"8D",x"FB",
x"B1",x"E3",x"8D",x"01",x"02",x"A9",x"9A",x"91",x"E3",x"D0",x"DA",x"20",x"17",x"FB",x"F0",x"D7",x"20",x"E0",x"F9",x"48",x"20",x"E7",x"F9",x"D0",x"FB",x"A2",x"00",x"CA",x"D0",x"FD",x"68",x"60",
x"8A",x"48",x"98",x"48",x"4C",x"66",x"FD",x"A9",x"01",x"8D",x"00",x"DF",x"AD",x"00",x"DF",x"49",x"FF",x"60",x"EE",x"07",x"02",x"AD",x"07",x"02",x"C9",x"30",x"30",x"08",x"EE",x"08",x"02",x"A9",
x"00",x"8D",x"07",x"02",x"60",x"CE",x"07",x"02",x"10",x"08",x"CE",x"08",x"02",x"A9",x"2F",x"8D",x"07",x"02",x"60",x"20",x"BA",x"FF",x"C9",x"05",x"D0",x"03",x"4C",x"53",x"FF",x"C9",x"1C",x"F0",
x"09",x"C9",x"0C",x"D0",x"09",x"20",x"57",x"FA",x"10",x"E9",x"CA",x"10",x"02",x"E8",x"60",x"C6",x"0E",x"98",x"48",x"A5",x"E3",x"48",x"A5",x"E4",x"48",x"20",x"8D",x"FB",x"A9",x"20",x"20",x"1D",
x"FB",x"20",x"05",x"FA",x"20",x"8D",x"FB",x"A9",x"9A",x"20",x"1D",x"FB",x"68",x"85",x"E4",x"68",x"85",x"E3",x"68",x"A8",x"18",x"90",x"BC",x"8D",x"02",x"02",x"8A",x"48",x"98",x"48",x"A2",x"04",
x"B5",x"E2",x"48",x"CA",x"D0",x"FA",x"AD",x"02",x"02",x"D0",x"03",x"4C",x"05",x"FB",x"AC",x"06",x"02",x"F0",x"08",x"A2",x"40",x"CA",x"D0",x"FD",x"88",x"D0",x"F8",x"C9",x"09",x"D0",x"0F",x"20",
x"17",x"FB",x"A9",x"2F",x"CD",x"07",x"02",x"F0",x"03",x"EE",x"07",x"02",x"10",x"69",x"C9",x"08",x"D0",x"0D",x"20",x"17",x"FB",x"AD",x"07",x"02",x"F0",x"03",x"CE",x"07",x"02",x"10",x"58",x"C9",
x"0B",x"D0",x"0D",x"20",x"17",x"FB",x"AD",x"08",x"02",x"F0",x"03",x"CE",x"08",x"02",x"10",x"47",x"C9",x"0D",x"D0",x"08",x"20",x"17",x"FB",x"20",x"FF",x"F9",x"10",x"3B",x"C9",x"0A",x"D0",x"12",
x"20",x"17",x"FB",x"EE",x"08",x"02",x"AE",x"08",x"02",x"E0",x"10",x"30",x"2A",x"20",x"3A",x"FB",x"F0",x"25",x"C9",x"0C",x"D0",x"0B",x"20",x"22",x"FB",x"20",x"FF",x"F9",x"8D",x"08",x"02",x"F0",
x"16",x"20",x"8D",x"FB",x"AD",x"02",x"02",x"20",x"1D",x"FB",x"20",x"F2",x"F9",x"AE",x"08",x"02",x"E0",x"10",x"30",x"03",x"20",x"3A",x"FB",x"20",x"8D",x"FB",x"A0",x"00",x"B1",x"E3",x"8D",x"01",
x"02",x"A9",x"9A",x"91",x"E3",x"A2",x"01",x"68",x"95",x"E2",x"E8",x"E0",x"05",x"D0",x"F8",x"68",x"A8",x"68",x"AA",x"AD",x"02",x"02",x"60",x"20",x"8D",x"FB",x"AD",x"01",x"02",x"A0",x"00",x"91",
x"E3",x"60",x"A0",x"00",x"84",x"E3",x"A9",x"D0",x"85",x"E4",x"A9",x"20",x"A2",x"D4",x"91",x"E3",x"C8",x"D0",x"FB",x"E6",x"E4",x"E4",x"E4",x"D0",x"F5",x"60",x"20",x"60",x"FB",x"20",x"4C",x"FB",
x"AC",x"08",x"02",x"C0",x"00",x"F0",x"04",x"CA",x"E8",x"D0",x"EF",x"60",x"A2",x"00",x"BD",x"00",x"D0",x"C9",x"20",x"D0",x"08",x"E8",x"E0",x"40",x"D0",x"F4",x"A2",x"FF",x"60",x"A2",x"00",x"60",
x"A2",x"D4",x"A0",x"00",x"84",x"E3",x"A9",x"D0",x"85",x"E4",x"85",x"E6",x"A9",x"40",x"85",x"E5",x"B1",x"E5",x"91",x"E3",x"C8",x"D0",x"F9",x"E6",x"E4",x"E6",x"E6",x"E4",x"E6",x"D0",x"F1",x"A2",
x"40",x"A9",x"20",x"9D",x"BF",x"D3",x"CA",x"D0",x"FA",x"CE",x"08",x"02",x"60",x"A9",x"00",x"85",x"E4",x"AD",x"08",x"02",x"0A",x"0A",x"0A",x"0A",x"0A",x"26",x"E4",x"0A",x"26",x"E4",x"6D",x"07",
x"02",x"69",x"0D",x"85",x"E3",x"A5",x"E4",x"69",x"D0",x"85",x"E4",x"60",x"AD",x"0E",x"02",x"D0",x"12",x"AD",x"0D",x"02",x"D0",x"03",x"4C",x"13",x"FA",x"EE",x"0E",x"02",x"20",x"6D",x"FE",x"C9",
x"02",x"D0",x"F9",x"20",x"6D",x"FE",x"C9",x"03",x"F0",x"01",x"60",x"A9",x"0D",x"CE",x"0E",x"02",x"CE",x"0D",x"02",x"60",x"C9",x"0D",x"F0",x"2B",x"C9",x"01",x"F0",x"47",x"C9",x"02",x"D0",x"1D",
x"48",x"8A",x"48",x"BA",x"BD",x"04",x"01",x"C9",x"A8",x"D0",x"0F",x"A5",x"0E",x"D0",x"0B",x"EE",x"05",x"02",x"EE",x"0C",x"02",x"68",x"AA",x"68",x"D0",x"06",x"68",x"AA",x"68",x"20",x"57",x"FA",
x"4C",x"6C",x"FF",x"48",x"AD",x"0C",x"02",x"D0",x"02",x"F0",x"F1",x"CE",x"05",x"02",x"CE",x"0C",x"02",x"A9",x"03",x"20",x"B1",x"FC",x"68",x"20",x"73",x"FF",x"48",x"A9",x"0A",x"20",x"B1",x"FC",
x"68",x"D0",x"DA",x"48",x"8A",x"48",x"BA",x"BD",x"04",x"01",x"C9",x"A8",x"D0",x"CC",x"A5",x"0E",x"D0",x"C8",x"EE",x"0D",x"02",x"68",x"AA",x"68",x"60",x"BD",x"AC",x"FC",x"F0",x"05",x"95",x"13",
x"E8",x"D0",x"F6",x"20",x"EB",x"FF",x"C9",x"0D",x"F0",x"10",x"20",x"EE",x"FF",x"95",x"13",x"C9",x"30",x"30",x"20",x"C9",x"3A",x"10",x"1C",x"E8",x"D0",x"E9",x"E0",x"04",x"F0",x"15",x"AD",x"00",
x"F8",x"8D",x"18",x"02",x"AD",x"01",x"F8",x"8D",x"19",x"02",x"68",x"A9",x"20",x"8D",x"10",x"02",x"A9",x"0D",x"60",x"A2",x"00",x"F0",x"F3",x"0A",x"0A",x"0A",x"20",x"20",x"28",x"4D",x"29",x"6F",
x"6E",x"69",x"74",x"6F",x"72",x"20",x"20",x"28",x"43",x"29",x"6F",x"6C",x"64",x"20",x"53",x"74",x"61",x"72",x"74",x"20",x"20",x"28",x"57",x"29",x"61",x"72",x"6D",x"20",x"53",x"74",x"61",x"72",
x"74",x"0D",x"0A",x"0A",x"0A",x"53",x"65",x"6C",x"65",x"63",x"74",x"00",x"4C",x"49",x"53",x"54",x"00",x"48",x"AD",x"00",x"F0",x"4A",x"4A",x"90",x"F9",x"68",x"8D",x"01",x"F0",x"60",x"49",x"FF",
x"8D",x"00",x"DF",x"49",x"FF",x"60",x"48",x"20",x"CF",x"FC",x"AA",x"68",x"CA",x"E8",x"60",x"AD",x"00",x"DF",x"49",x"FF",x"60",x"C9",x"1C",x"F0",x"03",x"4C",x"74",x"A3",x"4C",x"59",x"A3",x"A9",
x"03",x"8D",x"00",x"F0",x"A9",x"11",x"8D",x"00",x"F0",x"60",x"8A",x"48",x"98",x"48",x"A5",x"E3",x"48",x"A5",x"E4",x"48",x"20",x"D3",x"F9",x"20",x"A5",x"F9",x"8D",x"00",x"02",x"4C",x"71",x"F9",
x"8A",x"48",x"98",x"48",x"A9",x"01",x"20",x"BE",x"FC",x"20",x"C6",x"FC",x"D0",x"05",x"0A",x"D0",x"F5",x"F0",x"53",x"4A",x"90",x"09",x"2A",x"E0",x"21",x"D0",x"F3",x"A9",x"1B",x"D0",x"21",x"20",
x"C8",x"FD",x"98",x"8D",x"13",x"02",x"0A",x"0A",x"0A",x"38",x"ED",x"13",x"02",x"8D",x"13",x"02",x"8A",x"4A",x"20",x"C8",x"FD",x"D0",x"2F",x"18",x"98",x"6D",x"13",x"02",x"A8",x"B9",x"CF",x"FD",
x"CD",x"15",x"02",x"D0",x"26",x"CE",x"14",x"02",x"F0",x"2B",x"A0",x"05",x"A2",x"C8",x"CA",x"D0",x"FD",x"88",x"D0",x"F8",x"F0",x"AE",x"C9",x"01",x"F0",x"35",x"A0",x"00",x"C9",x"02",x"F0",x"47",
x"A0",x"C0",x"C9",x"20",x"F0",x"41",x"A9",x"00",x"8D",x"16",x"02",x"8D",x"15",x"02",x"A9",x"02",x"8D",x"14",x"02",x"D0",x"8F",x"A2",x"96",x"CD",x"16",x"02",x"D0",x"02",x"A2",x"14",x"8E",x"14",
x"02",x"8D",x"16",x"02",x"A9",x"01",x"20",x"BE",x"FC",x"20",x"CF",x"FC",x"4A",x"90",x"33",x"AA",x"29",x"03",x"F0",x"0B",x"A0",x"10",x"AD",x"15",x"02",x"10",x"0C",x"A0",x"F0",x"D0",x"08",x"A0",
x"00",x"E0",x"20",x"D0",x"02",x"A0",x"C0",x"AD",x"15",x"02",x"29",x"7F",x"C9",x"20",x"F0",x"07",x"8C",x"13",x"02",x"18",x"6D",x"13",x"02",x"8D",x"13",x"02",x"68",x"A8",x"68",x"AA",x"AD",x"13",
x"02",x"60",x"D0",x"92",x"A0",x"20",x"D0",x"DF",x"A0",x"08",x"88",x"0A",x"90",x"FC",x"60",x"D0",x"BB",x"2F",x"20",x"5A",x"41",x"51",x"2C",x"4D",x"4E",x"42",x"56",x"43",x"58",x"4B",x"4A",x"48",
x"47",x"46",x"44",x"53",x"49",x"55",x"59",x"54",x"52",x"45",x"57",x"00",x"00",x"0D",x"5E",x"4F",x"4C",x"2E",x"00",x"1C",x"2D",x"BA",x"30",x"B9",x"B8",x"B7",x"B6",x"B5",x"B4",x"B3",x"B2",x"B1",
x"A2",x"FF",x"9A",x"D8",x"EA",x"20",x"4E",x"FF",x"A9",x"20",x"8D",x"0D",x"D0",x"A0",x"00",x"84",x"FB",x"84",x"FE",x"84",x"FF",x"F0",x"19",x"20",x"E9",x"FE",x"C9",x"2F",x"F0",x"1E",x"C9",x"47",
x"F0",x"17",x"C9",x"4C",x"F0",x"43",x"20",x"93",x"FE",x"30",x"EC",x"A2",x"02",x"20",x"DA",x"FE",x"B1",x"FE",x"85",x"FC",x"20",x"AC",x"FE",x"D0",x"DE",x"4C",x"79",x"FE",x"20",x"E9",x"FE",x"C9",
x"2E",x"F0",x"D4",x"C9",x"0D",x"D0",x"0F",x"E6",x"FE",x"D0",x"02",x"E6",x"FF",x"A0",x"00",x"B1",x"FE",x"85",x"FC",x"4C",x"64",x"FE",x"20",x"93",x"FE",x"30",x"E1",x"A2",x"00",x"20",x"DA",x"FE",
x"A5",x"FC",x"91",x"FE",x"20",x"AC",x"FE",x"D0",x"D3",x"85",x"FB",x"F0",x"CF",x"AD",x"00",x"F0",x"4A",x"90",x"FA",x"AD",x"01",x"F0",x"29",x"7F",x"60",x"20",x"4E",x"FF",x"6C",x"FE",x"00",x"BD",
x"8A",x"FE",x"20",x"EE",x"FF",x"CA",x"D0",x"F7",x"4C",x"39",x"FC",x"20",x"54",x"49",x"44",x"45",x"FF",x"FF",x"FF",x"C9",x"30",x"30",x"12",x"C9",x"3A",x"30",x"0B",x"C9",x"41",x"30",x"0A",x"C9",
x"47",x"10",x"06",x"38",x"E9",x"07",x"29",x"0F",x"60",x"A9",x"80",x"60",x"A2",x"03",x"A0",x"00",x"B5",x"FC",x"4A",x"4A",x"4A",x"4A",x"20",x"CA",x"FE",x"B5",x"FC",x"20",x"CA",x"FE",x"CA",x"10",
x"EF",x"A9",x"20",x"8D",x"62",x"D1",x"8D",x"63",x"D1",x"60",x"29",x"0F",x"09",x"30",x"C9",x"3A",x"30",x"03",x"18",x"69",x"07",x"99",x"5E",x"D1",x"C8",x"60",x"A0",x"04",x"0A",x"0A",x"0A",x"0A",
x"2A",x"36",x"FC",x"36",x"FD",x"88",x"D0",x"F8",x"60",x"A5",x"FB",x"D0",x"80",x"4C",x"00",x"FD",x"AC",x"FB",x"D4",x"FB",x"9B",x"FF",x"8B",x"FF",x"96",x"FF",x"4C",x"30",x"01",x"4C",x"C0",x"01",
x"D8",x"A2",x"FF",x"9A",x"A0",x"10",x"B9",x"EF",x"FE",x"99",x"17",x"02",x"88",x"D0",x"F7",x"20",x"DF",x"FC",x"A2",x"17",x"A9",x"00",x"9D",x"00",x"02",x"CA",x"10",x"FA",x"20",x"4E",x"FF",x"B9",
x"77",x"FC",x"F0",x"06",x"20",x"57",x"FA",x"C8",x"D0",x"F5",x"20",x"EB",x"FF",x"C9",x"43",x"D0",x"06",x"20",x"4E",x"FF",x"4C",x"11",x"BD",x"C9",x"57",x"D0",x"06",x"20",x"4E",x"FF",x"4C",x"00",
x"00",x"C9",x"4D",x"D0",x"06",x"20",x"4E",x"FF",x"4C",x"00",x"FE",x"4C",x"00",x"FF",x"A9",x"0C",x"4C",x"57",x"FA",x"8A",x"48",x"BA",x"BD",x"03",x"01",x"C9",x"A3",x"F0",x"05",x"68",x"AA",x"4C",
x"EB",x"FF",x"A2",x"05",x"4C",x"7F",x"FE",x"55",x"F9",x"7E",x"F9",x"FF",x"48",x"AD",x"05",x"02",x"F0",x"22",x"68",x"20",x"B1",x"FC",x"C9",x"0D",x"D0",x"1B",x"48",x"8A",x"48",x"A2",x"0A",x"A9",
x"00",x"20",x"B1",x"FC",x"CA",x"D0",x"FA",x"68",x"AA",x"68",x"60",x"48",x"CE",x"03",x"02",x"A9",x"00",x"8D",x"05",x"02",x"68",x"60",x"48",x"A9",x"01",x"D0",x"F6",x"AD",x"12",x"02",x"D0",x"19",
x"A9",x"FE",x"8D",x"00",x"DF",x"2C",x"00",x"DF",x"70",x"0F",x"A9",x"FB",x"8D",x"00",x"DF",x"2C",x"00",x"DF",x"70",x"05",x"A9",x"03",x"4C",x"36",x"A6",x"60",x"2C",x"03",x"02",x"10",x"19",x"A9",
x"FD",x"8D",x"00",x"DF",x"A9",x"10",x"2C",x"00",x"DF",x"F0",x"0A",x"AD",x"00",x"F0",x"4A",x"90",x"EE",x"AD",x"01",x"F0",x"60",x"EE",x"03",x"02",x"AD",x"0F",x"02",x"F0",x"03",x"4C",x"00",x"FD",
x"A9",x"50",x"8D",x"10",x"02",x"4C",x"EA",x"FC",x"FF",x"FF",x"FF",x"6C",x"18",x"02",x"6C",x"1A",x"02",x"6C",x"1C",x"02",x"6C",x"1E",x"02",x"6C",x"20",x"02",x"22",x"02",x"00",x"FF",x"25",x"02"
);
begin
process (address)
begin
q <= romdata (to_integer(unsigned(address)));
end process;
end behavior;

