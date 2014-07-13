-- The processor --
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.processor_functions.all;


ENTITY processor IS
	PORT (clk, nrst: IN std_logic;
			WAKE_SIGNAL: IN std_logic);
END ENTITY processor;

ARCHITECTURE processor OF processor IS
	SIGNAL CONTROL_bus: std_logic_vector(n-1 DOWNTO 0);

	-- IR
	SIGNAL IR_opcode: opcode;
	SIGNAL IR_load: std_logic;
	SIGNAL IR_valid: std_logic;
	SIGNAL IR_address : std_logic;

	-- PC
	SIGNAL PC_inc: std_logic;
	SIGNAL PC_load: std_logic;
	SIGNAL PC_valid: std_logic;

	-- Memory
	SIGNAL MDR_load: std_logic;
	SIGNAL MAR_load: std_logic;
	SIGNAL MEM_valid: std_logic;
	SIGNAL MEM_en: std_logic;
	SIGNAL MEM_rw: std_logic;

	-- ALU
	SIGNAL ALU_zero: std_logic;
	SIGNAL ALU_slt: std_logic;
	SIGNAL ALU_valid: std_logic;
	SIGNAL ALU_enable: std_logic;
	SIGNAL ALU_cmd: std_logic_vector(2 DOWNTO 0);
	
	-- IO
	SIGNAL IODR_load: std_logic;
	SIGNAL IOAR_load: std_logic;
	SIGNAL IO_valid: std_logic;
	SIGNAL IO_en: std_logic;
	SIGNAL IO_rw: std_logic;
	
BEGIN
	controller : entity work.controller port map(clk, nrst, CONTROL_bus, IR_opcode, IR_load, IR_valid, PC_inc, PC_load, PC_valid, MDR_load, MAR_load, MEM_valid, MEM_en, MEM_rw, ALU_zero, ALU_valid, ALU_slt, ALU_enable, ALU_cmd, IODR_load, IOAR_load, IO_valid, IO_en, IO_rw, WAKE_SIGNAL);
	memory : entity work.memory port map(clk, nrst, MDR_load, MAR_load, MEM_valid, MEM_en, MEM_rw, CONTROL_bus);
	alu : entity work.alu port map(clk, nrst, ALU_cmd, ALU_zero, ALU_slt, ALU_valid, ALU_enable, CONTROL_bus);
	ir : entity work.ir port map(clk, nrst, IR_load, IR_valid, IR_address, IR_opcode, CONTROL_bus);
	pc : entity work.pc port map(clk, nrst, PC_inc, PC_load, PC_valid, CONTROL_bus);
	io : entity work.io port map(clk, nrst, IODR_load, IOAR_load, IO_valid, IO_en, IO_rw);
END ARCHITECTURE;