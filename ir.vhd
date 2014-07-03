LIBRARY ieee;
USE ieee.std_logic_1164.all;
ENTITY ir IS
    PORT (
        Clk : IN STD_LOGIC;
        Nrst : IN STD_LOGIC;
        IR_load : IN STD_LOGIC;
        IR_valid : IN STD_LOGIC;
        IR_address : IN STD_LOGIC;
        IR_opcode : OUT opcode;
        IR_bus : INOUT STD_LOGIC_VECTOR(n-1 DOWNTO 0)
    );
END ENTITY IR;

ARCHITECTURE RTL OF IR IS
    SIGNAL IR_internal : STD_LOGIC_VECTOR (n-1 DOWNTO 0);
BEGIN
    IR_bus <= IR_internal
        WHEN IR_valid = '1' ELSE (OTHERS => 'Z');
    IR_opcode <= Decode(IR_internal);
    PROCESS (clk, nrst) IS
    BEGIN
        IF nrst = '0' THEN
            IR_internal <= (OTHERS => '0');
        ELSIF rising_edge(clk) THEN
            IF IR_load = '1' THEN
                IR_internal <= IR_bus;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE RTL;