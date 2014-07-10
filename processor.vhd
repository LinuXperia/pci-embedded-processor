-- The processor --
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.processor_functions.all;


ENTITY processor IS
	PORT (clk, nrst: IN std_logic;
			portA, portB, portC: OUT std_logic_vector(n-1 DOWNTO 0));
END ENTITY processor;

ARCHITECTURE processor OF processor IS
	SIGNAL CONTROL_bus: std_logic_vector(n-1 DOWNTO 0);

	-- IR
	SIGNAL IR_opcode: opcode;
	SIGNAL IR_load: std_logic;
	SIGNAL IR_valid: std_logic;

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
	SIGNAL ALU_valid: std_logic;
	SIGNAL ALU_enable: std_logic;
	SIGNAL ALU_cmd: std_logic_vector(2 DOWNTO 0);
BEGIN
	controller : entity work.controller port map(clk, nrst, CONTROL_bus, IR_opcode, IR_load, IR_valid, PC_inc, PC_load, PC_valid, MDR_load, MAR_load, MEM_valid, MEM_en, MEM_rw, ALU_zero, ALU_valid, ALU_enable, ALU_cmd); 
	memory : entity work.memory port map(clk, nrst, MDR_load, MAR_load, MEM_valid, MEM_en, MEM_rw, MEM_bus);
	alu : entity work.alu port map(clk, nrst, ALU_cmd, ALU_zero, ALU_valid, ALU_enable, ALU_bus);
END ARCHITECTURE;