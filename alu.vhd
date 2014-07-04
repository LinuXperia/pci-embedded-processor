LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_signed.all;	
USE work.processor_functions.all;
ENTITY alu IS
    PORT (
        Clk : IN std_logic;
        Nrst : IN std_logic;
        ALU_cmd : IN std_logic_vector(2 DOWNTO 0);
        ALU_zero : OUT std_logic;
        ALU_valid : IN std_logic;
        ALU_bus : INOUT std_logic_vector(n-1 DOWNTO 0)
    );
END ENTITY alu;

ARCHITECTURE RTL OF ALU IS
    SIGNAL ACC : std_logic_vector (n-1 DOWNTO 0);
BEGIN
    ALU_bus <= ACC WHEN ALU_valid = '1' ELSE (others => 'Z');
    ALU_zero <= '1' WHEN unsigned(ACC) = reg_zero ELSE '0';
    PROCESS (clk, nrst) IS
    BEGIN
        IF nrst = '0' THEN
            ACC <= (others => '0');
        ELSIF rising_edge(clk) THEN
            CASE ALU_cmd IS
					-- Load the Bus value into the accumulator
					WHEN "000" => ACC <= ALU_bus;
					-- Add the ACC to the Bus value
					WHEN "001" => ACC <= add(ACC,ALU_bus);
					-- NOT the Bus value
					WHEN "010" => ACC <= NOT ALU_bus;
					-- OR the ACC to the Bus value
					WHEN "011" => ACC <= ACC or ALU_bus;
					-- AND the ACC to the Bus value
					WHEN "100" => ACC <= ACC and ALU_bus;
					-- XOR the ACC to the Bus value
					WHEN "101" => ACC <= ACC xor ALU_bus;
					-- Increment ACC
					WHEN "110" => ACC <= ACC + 1;
					-- Store the ACC value
					WHEN "111" => ALU_bus <= ACC;
				END CASE;
        END IF;
    END PROCESS;
END ARCHITECTURE RTL;