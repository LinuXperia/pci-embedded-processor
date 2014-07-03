Library ieee;
Use ieee.std_logic_1164.all;

Package processor_functions is
    Type opcode is (load, store, add, nott, andd, orr, 
        xorr, inc, sub, branch);
    Function Decode (word : std_logic_vector) return 
        opcode;
    Constant n : integer := 16;
    Constant oplen : integer := 4;
    Type memory_array is array (0 to 2**(n-oplen-1) )
        of Std_logic_vector(n-1 downto 0);
    Constant reg_zero : unsigned (n-1 downto 0) :=
        (others => '0');
End package processor_functions;

Package body processor_functions is
    Function Decode (word : std_logic_vector) return 
        opcode is
            Variable opcode_out : opcode;
    Begin
        Case word(n-1 downto n-oplen-1) is
            When "0000" => opcode_out := load;
            When "0001" => opcode_out := store;
            When "0010" => opcode_out := add;
            When "0011" => opcode_out := nott;
            When "0100" => opcode_out := andd;
            When "0101" => opcode_out := orr;
            When "0110" => opcode_out := xorr;
            When "0111" => opcode_out := inc;
            When "1000" => opcode_out := sub;
            When "1001" => opcode_out := branch;
            When others => null;
        End case;
        Return opcode_out;
    End function decode;
End package body processor_functions;