library IEEE;
use IEEE.std_logic_1164.all;
library lpm;
use lpm.all;
entity wave_rom is
port( address : in std_logic_vector(9 downto 0);
			q : out std_logic_vector(7 downto 0));
end wave_rom;
architecture syn of wave_rom is
signal sub_wire0	:std_logic_vector(7 downto 0);
component lpm_rom
generic( 	intended_device_family		:string;
			lpm_address_control			:string;
			lpm_file					:string;
			lpm_outdata					:string;
			lpm_type					:string;
			lpm_width					:natural;
			lpm_widthad					:natural	);
port(	address	: in std_logic_vector(9 downto 0);
			q	: out std_logic_vector(7 downto 0)	);
end component;
begin
q <= sub_wire0(7 downto 0);
lpm_rom_component : lpm_rom
generic map( intended_device_family => "flex10k",
			 lpm_address_control	=> "unregistered",	
			 lpm_file				=> "myfile.mif",
			 lpm_outdata			=> "unregistered",
			 lpm_type				=> "lpm_rom",
			 lpm_width				=> 8,
			 lpm_widthad			=> 10    )
port map(address => address, q => sub_wire0	);
end syn;