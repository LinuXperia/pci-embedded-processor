LIBRARY ieee;
USE ieee.numeric_std.all;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_signed.all;	
ENTITY pc IS
    GENERIC (
        n: INTEGER := 16
    );
    PORT (
        Clk: IN STD_LOGIC;
        Nrst: IN STD_LOGIC;
        PC_inc: IN STD_LOGIC;
        PC_load: IN STD_LOGIC;
        PC_valid: IN STD_LOGIC;
        PC_bus: INOUT STD_LOGIC_VECTOR(n-1  DOWNTO 0)
    );
END ENTITY PC;

ARCHITECTURE RTL OF PC IS
    SIGNAL counter: INTEGER RANGE 0 to 2**n -1;
BEGIN
    PC_bus <= STD_LOGIC_VECTOR(to_unsigned(counter, PC_bus'length)) WHEN PC_valid = '1' ELSE (OTHERS => 'Z');
    PROCESS (clk, nrst) IS
    BEGIN
        IF nrst = '0' THEN
            counter <= 0;
        ELSIF rising_edge(clk) THEN
            IF PC_inc = '1' THEN
                counter <= counter + 1;
            ELSE
                IF PC_load = '1' THEN
                    counter <= to_integer(unsigned(PC_bus));
                END IF;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE RTL;