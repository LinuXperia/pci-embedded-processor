LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.processor_functions.all;
ENTITY memory IS
    PORT (
        Clk : IN STD_LOGIC;
        Nrst : IN STD_LOGIC;
        MDR_load : IN STD_LOGIC;
        MAR_load : IN STD_LOGIC;
        MEM_valid : IN STD_LOGIC;
        MEM_en : IN STD_LOGIC;
        MEM_rw : IN STD_LOGIC;
        MEM_bus : INOUT STD_LOGIC_VECTOR(n-1 DOWNTO 0)
    );
END ENTITY memory;

ARCHITECTURE RTL OF memory IS
    SIGNAL mdr : STD_LOGIC_VECTOR(wordlen-1 DOWNTO 0);
    SIGNAL mar : UNSIGNED(wordlen-oplen-1 DOWNTO 0);
BEGIN
    MEM_bus <= mdr WHEN MEM_valid = '1' ELSE (others => 'Z');
    process (clk, nrst) IS
        variable contents : memory_array;
        constant program : memory_array :=
        (
        0 => "0000000000000011",
        1 => "0010000000000100",
        2 => "0001000000000101",
        3 => "0000000000001100",
        4 => "0000000000000011",
        5 => "0000000000000000" ,
        Others => (others => '0')
        );
    BEGIN
        IF nrst = '0' THEN
            mdr <= (others => '0');
            mdr <= (others => '0');
            contents := program;
        ELSIF rising_edge(clk) THEN
            IF MAR_load = '1' THEN
                mar <= UNSIGNED(MEM_bus(n-oplen-1 DOWNTO 0));
            ELSIF MDR_load = '1' THEN
                mdr <= MEM_bus;
            ELSIF MEM_en = '1' THEN
                IF MEM_rw = '0' THEN
                    mdr <= contents(to_integer(mar));
                ELSE
                    contents(to_integer(mar)) := mdr;
                END IF;
            END IF;
        END IF;
    END process;
END ARCHITECTURE RTL;