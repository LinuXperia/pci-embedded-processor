library ieee;
use ieee.std_logic_1164.all;
entity pc is
    Port (
        Clk : IN std_logic;
        Nrst : IN std_logic;
        PC_inc : IN std_logic;
        PC_load : IN std_logic;
        PC_valid : IN std_logic;
        PC_bus : INOUT std_logic_vector(n-1 downto 0)
    );
End entity PC;

architecture RTL of PC is
    signal counter : unsigned (n-1 downto 0);
begin
    PC_bus <= std_logic_vector(counter) when PC_valid = '1' else 
	 'Z';
    process (clk, nrst) is
    begin
        if nrst = '0' then
            count <= 0;
        elsif rising_edge(clk) then
            if PC_inc = '1' then
                count <= count + 1;
            else
                if PC_load = '1' then
                    count <= unsigned(PC_bus);
                end if;
            end if;
        end if;
    end process;
end architecture RTL;