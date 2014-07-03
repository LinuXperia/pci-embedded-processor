library ieee;
use ieee.std_logic_1164.all;
use work.processor_functions.all;
entity controller is
    generic (
        n : integer := 16
    );
    Port (
        Clk : IN std_logic;
        Nrst : IN std_logic;
        IR_load : OUT std_logic;
        IR_valid : OUT std_logic;
        IR_address : OUT std_logic;
        PC_inc : OUT std_logic;
        PC_load : OUT std_logic;
        PC_valid : OUT std_logic;
        MDR_load : OUT std_logic;
        MAR_load : OUT std_logic;
        MAR_valid : OUT std_logic;
        M_en : OUT std_logic;
        M_rw : OUT std_logic;
        ALU_cmd : OUT std_logic_vector(2 downto 0);
        CONTROL_bus : INOUT std_logic_vector(n-1 
        downto 0)
    );
End entity controller;

architecture RTL of controller is
    type states is 
        (s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10);
    signal current_state, next_state : states;
begin
    state_sequence: process (clk, nrst) is
        if nrst = '0' then
            current_state <= s0;
        else
            if rising_edge(clk) then
                current_state <= next_state;
            end if;
        end if;
    end process state_sequence;

    state_machine : process ( present_state, opcode ) is

    begin
        -- Reset all the control signals
        IR_load <= '0';
        IR_valid <= '0';
        IR_address <= '0';
        PC_inc <= '0';
        PC_load <= '0';
        PC_valid <= '0';
        MDR_load <= '0';
        MAR_load <= '0';
        MAR_valid <= '0';
        M_en <= '0';
        M_rw <= '0';
        Case current_state is
        When s0 =>
            PC_valid <= '1'; MAR_load <= '1';
            PC_inc <= '1'; PC_load <= '1';
            Next_state <= s1;
        When s1 =>
            M_en <='1'; M_rw <= '1';
            Next_state <= s2;
        When s2 =>
            MDR_valid <= '1'; IR_load <= '1';
            Next_state <= s3;
        When s3 =>
            MAR_load <= '1'; IR_address <= '1';
            If opcode = STORE then
                Next_state <= s4;
            else
                Next_state <=s6;
            End if;
        When s4 =>
            MDR_load <= '1'; ACC_valid <= '1';
            Next_state <= s5;
        When s5 =>
            M_en <= '1';
            Next_state <= s0;
        When s6 =>
            M_en <= '1'; M_rw <= '1';
            If opcode = LOAD then
                Next_state <= s7;
            else
                Next_state <= s8;
            End if;
        When s7 =>
            MDR_valid <= '1'; ACC_load <= '1';
            Next_state <= s0;
        When s8 =>
            M_en<='1'; M_rw <= '1';
            If opcode = ADD then
                Next_state <= s9;
            else
                Next_state <= s10;
            End if;
        When s9 =>
            ALU_add <= '1';
            Next_state <= s0;
        When s10 =>
            ALU_sub <= '1';
            Next_state <= s0;
        End case;
    End process state_machine;
end architecture;