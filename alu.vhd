library ieee;
use ieee.std_logic_1164.all;
use work.processor_functions.all;
entity alu is
    Port (
        Clk : IN std_logic;
        Nrst : IN std_logic;
        ALU_cmd : IN std_logic_vector(2 downto 0);
        ALU_zero : OUT std_logic;
        ALU_valid : IN std_logic;
        ALU_bus : INOUT std_logic_vector(n-1 downto 0)
    );
End entity alu;

architecture RTL of ALU is
    signal ACC : std_logic_vector (n-1 downto 0);
begin
    ALU_bus <= ACC
        when ACC_valid  '1' else (others => 'Z');
    ALU_zero <= '1' when acc  reg_zero else '0';
    process (clk, nrst) is
    begin
        if nrst = '0' then
            ACC <= (others => '0');
        elsif rising_edge(clk) then
            case ACC_cmd is
            -- Load the Bus value into the accumulator
            when "000" => ACC <= ALU_bus;
            -- Add the ACC to the Bus value
            When "001" => ACC <= add(ACC,ALU_bus);
            -- NOT the Bus value
            When "010" => ACC <= NOT ALU_bus;
            -- OR the ACC to the Bus value
            When "011" => ACC <= ACC or ALU_bus;
            -- AND the ACC to the Bus value
            When "100" => ACC <= ACC and ALU_bus;
            -- XOR the ACC to the Bus value
            When "101" => ACC <= ACC xor ALU_bus;
            -- Increment ACC
            When "110" => ACC <= ACC + 1;
            -- Store the ACC value
            When "111" => ALU_bus <= ACC;
        end if;
    end process;
end architecture RTL;