library IEEE;
use IEEE.std_logic_1164.all;
entity mux4_3_1 is
port (d0,d1,d2:in STD_LOGIC_VECTOR(3 downto 0);
        sel :in STD_LOGIC_VECTOR(1 downto 0);
        dout:out STD_LOGIC_VECTOR(3 downto 0) );
        end mux4_3_1;
architecture rtl of mux4_3_1 is
begin
    dout <= 
	d0 when sel="00" else
	d1 when sel="01" else 
	d2;
end rtl;
        
        
