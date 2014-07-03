library ieee;
use ieee.std_logic_1164.all;
use work.processor_functions.all;
entity memory is
    Port (
        Clk : IN std_logic;
        Nrst : IN std_logic;
        MDR_load : IN std_logic;
        MAR_load : IN std_logic;
        MAR_valid : IN std_logic;
        M_en : IN std_logic;
        M_rw : IN std_logic;
        MEM_bus : INOUT std_logic_vector(n-1
        downto 0)
    );
End entity memory;

architecture RTL of memory is
    signal mdr : std_logic_vector(wordlen-1 downto 0);
    signal mar : unsigned(wordlen-oplen-1 downto 0);
begin
    MEM_bus <= mdr
    when MEM_valid = '1' else (others => 'Z');
    process (clk, nrst) is
        variable contents : memory_array;
        constant program : contents :=
        (
        0 => "0000000000000011",
        1 => "0010000000000100",
        2 => "0001000000000101",
        3 => "0000000000001100",
        4 => "0000000000000011",
        5 => "0000000000000000" ,
        Others => (others => '0')
        );
    begin
        if nrst = '0' then
            mdr <= (others => '0');
            mdr <= (others => '0');
            contents := program;
        elsif rising_edge(clk) then
            if MAR_load = '1' then
                mar <= unsigned(MEM_bus(n-oplen-1 downto 0));
            elsif MDR_load = '1' then
                mdr <= MEM_bus;
            elsif MEM_en = '1' then
                if MEM_rw = '0' then
                    mdr <= contents(to_integer(mar));
                else
                    mem(to_integer(mar)) := mdr;
                end if;
            end if;
        end if;
    end process;
end architecture RTL;