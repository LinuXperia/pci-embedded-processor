Embedded Processor (PCI 2014.1 - POLI/UPE)
======================

Embedded Processor implementation on FPGA

### Machine code instruction set

|Command 		| Opcode (Binary) 	|
|---------------|-------------------|
| LOAD arg 		| 	0000 			|
| STORE arg 	| 	0001 			|
| ADD arg	 	| 	0010 			|
| NOT	 		| 	0011 			|
| AND arg 		| 	0100 			|
| OR arg	 	| 	0101 			|
| XOR arg 		| 	0110 			|
| INC 			| 	0111 			|
| SUB arg 		| 	1000 			|
| BRANCH arg 	| 	1001 			|


### Processor functions package

```VHDL
Library ieee;
Use ieee.std_logic_1164.all;

Package processor_functions is
	Type opcode is (load, store, add, not, and, or, 
		xor, inc, sub, branch);
	Function Decode (word : std_logic_vector) return 
		opcode;
	Constant n : integer := 16;
	Constant oplen : integer := 4;
	Type memory_array is array (0 to 2**(n-oplen-1) 
		of Std_logic_vector(n-1 downto 0);
	Constant reg_zero : unsigned (n-1 downto 0) :=
		(others => ‘0’);
End package processor_functions;

Package body processor_functions is
	Function Decode (word : std_logic_vector) return 
		opcode is
			Variable opcode_out : opcode;
	Begin
		Case word(n-1 downto n-oplen-1) is
			When “0000” => opcode_out : = load;
			When “0001” => opcode_out : = store;
			When “0010” => opcode_out : = add;
			When “0011” => opcode_out : = not;
			When “0100” => opcode_out : = and;
			When “0101” => opcode_out : = or;
			When “0110” => opcode_out : = xor;
			When “0111” => opcode_out : = inc;
			When “1000” => opcode_out : = sub;
			When “1001” => opcode_out : = branch;
			When others => null;
		End case;
		Return opcode_out;
	End function decode;
End package body processor_functions;
```

### The PC

```VHDL
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
	PC_bus <= std_logic_vector(counter)
				when PC_valid = ‘1’ else (others => 
					‘Z’);
	process (clk, nrst) is
	begin
		if nrst = ‘0’ then
			count <= 0;
		elsif rising_edge(clk) then
			if PC_inc = ‘1’ then
				count <= count + 1;
			else
				if PC_load = ‘1’ then
					count <= unsigned(PC_bus);
				end if;
			end if;
		end if;
	end process;
end architecture RTL;
```

### The IR

```VHDL
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
		when IR_valid = ‘1’ else (others => ‘Z’);
	IR_opcode <= Decode(IR_internal);
	process (clk, nrst) is
	begin
		if nrst = ‘0’ then
			IR_internal <= (others => ‘0’);
		elsif rising_edge(clk) then
			if IR_load = ‘1’ then
				IR_internal <= IR_bus;
			end if;
		end if;
	end process;
end architecture RTL;
```

### The Arithmetic and Logic Unit

```VHDL
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
		when ACC_valid  ‘1’ else (others => ‘Z’);
	ALU_zero <= ‘1’ when acc  reg_zero else ‘0’;
	process (clk, nrst) is
	begin
		if nrst = ‘0’ then
			ACC <= (others => ‘0’);
		elsif rising_edge(clk) then
			case ACC_cmd is
			-- Load the Bus value into the accumulator
			when “000” => ACC <= ALU_bus;
			-- Add the ACC to the Bus value
			When “001” => ACC <= add(ACC,ALU_bus);
			-- NOT the Bus value
			When “010” => ACC <= NOT ALU_bus;
			-- OR the ACC to the Bus value
			When “011” => ACC <= ACC or ALU_bus;
			-- AND the ACC to the Bus value
			When “100” => ACC <= ACC and ALU_bus;
			-- XOR the ACC to the Bus value
			When “101” => ACC <= ACC xor ALU_bus;
			-- Increment ACC
			When “110” => ACC <= ACC + 1;
			-- Store the ACC value
			When “111” => ALU_bus <= ACC;
		end if;
	end process;
end architecture RTL;
```

### The memory

```VHDL
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
	when MEM_valid = ‘1’ else (others => ‘Z’);
	process (clk, nrst) is
		variable contents : memory_array;
		constant program : contents :=
		(
		0 => “0000000000000011”,
		1 => “0010000000000100”,
		2 => “0001000000000101”,
		3 => “0000000000001100”,
		4 => “0000000000000011”,
		5 => “0000000000000000” ,
		Others => (others => ‘0’)
		);
	begin
		if nrst = ‘0’ then
			mdr <= (others => ‘0’);
			mdr <= (others => ‘0’);
			contents := program;
		elsif rising_edge(clk) then
			if MAR_load = ‘1’ then
				mar <= unsigned(MEM_bus(n-oplen-1 downto 0));
			elsif MDR_load = ‘1’ then
				mdr <= MEM_bus;
			elsif MEM_en = ‘1’ then
				if MEM_rw = ‘0’ then
					mdr <= contents(to_integer(mar));
				else
					mem(to_integer(mar)) := mdr;
				end if;
			end if;
		end if;
	end process;
end architecture RTL;
```

### Controller

![Basic Processor Controller State Machine](/controller-state-machine.png?raw=true "Basic Processor Controller State Machine")

```VHDL
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
		if nrst = ‘0’ then
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
		IR_load <= ‘0’;
		IR_valid <= ‘0’;
		IR_address <= ‘0’;
		PC_inc <= ‘0’;
		PC_load <= ‘0’;
		PC_valid <= ‘0’;
		MDR_load <= ‘0’;
		MAR_load <= ‘0’;
		MAR_valid <= ‘0’;
		M_en <= ‘0’;
		M_rw <= ‘0’;
		Case current_state is
		When s0 =>
			PC_valid <= ’1’; MAR_load <= ’1’;
			PC_inc <= ’1’; PC_load <= ’1’;
			Next_state <= s1;
		When s1 =>
			M_en <=’1’; M_rw <= ’1’;
			Next_state <= s2;
		When s2 =>
			MDR_valid <= ’1’; IR_load <= ’1’;
			Next_state <= s3;
		When s3 =>
			MAR_load <= ’1’; IR_address <= ’1’;
			If opcode = STORE then
				Next_state <= s4;
			else
				Next_state <=s6;
			End if;
		When s4 =>
			MDR_load <= ’1’; ACC_valid <= ’1’;
			Next_state <= s5;
		When s5 =>
			M_en <= ‘1’;
			Next_state <= s0;
		When s6 =>
			M_en <= ’1’; M_rw <= ’1’;
			If opcode = LOAD then
				Next_state <= s7;
			else
				Next_state <= s8;
			End if;
		When s7 =>
			MDR_valid <= ’1’; ACC_load <= ’1’;
			Next_state <= s0;
		When s8 =>
			M_en<=’1’; M_rw <= ’1’;
			If opcode = ADD then
				Next_state <= s9;
			else
				Next_state <= s10;
			End if;
		When s9 =>
			ALU_add <= ‘1’;
			Next_state <= s0;
		When s10 =>
			ALU_sub <= ‘1’;
			Next_state <= s0;
		End case;
	End process state_machine;
end architecture;
```