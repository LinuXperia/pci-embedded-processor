pci-embedded-processor
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

(TODO)