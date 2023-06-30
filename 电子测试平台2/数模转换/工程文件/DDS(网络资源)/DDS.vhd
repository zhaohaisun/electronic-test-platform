library IEEE;
use IEEE.std_logic_1164.all;
library work;
entity DDS is
generic(fwords_width : integer := 20;
		pwords_width : integer :=10 );
port (fclk : in std_logic;
	  fwords : in std_logic_vector(19 downto 0);
	  pwords : in std_logic_vector(9 downto 0);
	  ddsout : out std_logic_vector(7 downto 0));
end DDS;
architecture arc of DDS is
component addrreg
generic(addr_width : integer;
		fadder_width:integer;
		fwords_width:integer;
		padder_width:integer;
		pwords_width:integer );
port( 	Clk:in std_logic;
		fwords:in std_logic_vector(19 downto 0);
		pwords : in std_logic_vector(9 downto 0);
		addressout : out std_logic_vector(9 downto 0));
end component;

component wave_ROM
port(address: in std_logic_vector(9 downto 0);
			q: out std_logic_vector(7 downto 0));
end component;

signal wire_0 : std_logic_vector(9 downto 0);
begin 
inst:addrreg
generic map(addr_width =>10,
			fadder_width =>24,
			fwords_width =>20,
			padder_width =>10,
			pwords_width =>10)
port map(Clk => fclk, fwords => fwords, pwords=>pwords,addressout => wire_0);
inst1 : wave_rom port map(address => wire_0, q => ddsout);
end arc; 