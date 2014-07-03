library ieee;
use ieee.std_logic_1164.all;
use work.processor_functions.all;
entity ir is
    Port (
        Clk : IN std_logic;
        Nrst : IN std_logic;
        IR_load : IN std_logic;
        IR_valid : IN std_logic;
        IR_address : IN std_logic;
        IR_opcode : OUT opcode;
        IR_bus : INOUT std_logic_vector(n-1 downto 0)
    );
End entity IR;

architecture RTL of IR is
    signal IR_internal : std_logic_vector (n-1 downto 0);
begin
    IR_bus <= IR_internal
        when IR_valid = '1' else (others => 'Z');
    IR_opcode <= Decode(IR_internal);
    process (clk, nrst) is
    begin
        if nrst = '0' then
            IR_internal <= (others => '0');
        elsif rising_edge(clk) then
            if IR_load = '1' then
                IR_internal <= IR_bus;
            end if;
        end if;
    end process;
end architecture RTL;