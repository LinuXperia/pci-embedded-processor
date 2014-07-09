---- Controller --------------------------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.processor_functions.all;
------------------------------------------------------------------------------------------------------------------
ENTITY controller IS
	PORT (clk, nrst: IN std_logic;
			CONTROL_bus: INOUT std_logic_vector(n-1 DOWNTO 0);

			-- IR
			IR_opcode: IN opcode;
			IR_load: OUT std_logic;
			IR_valid: OUT std_logic;

			-- PC
			PC_inc: OUT std_logic;
			PC_load: OUT std_logic;
			PC_valid: OUT std_logic;

			-- Memory
			MDR_load: OUT std_logic;
			MAR_load: OUT std_logic;
			MEM_valid: OUT std_logic;
			MEM_en: OUT std_logic;
			MEM_rw: OUT std_logic;

			-- ALU
			ALU_valid : OUT std_logic;
			ALU_enable : OUT std_logic;
			ALU_cmd: OUT std_logic_vector(2 DOWNTO 0));
END ENTITY controller;
------------------------------------------------------------------------------------------------------------------
ARCHITECTURE RTL OF controller IS
	TYPE states IS (s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15);
	SIGNAL current_state, next_state: states;
BEGIN
	-- Processo que gerencia a transição do current_state para o next_state
	-- e a confição de reset
	state_sequence: PROCESS (clk, nrst) BEGIN
		IF nrst = '0' THEN -- reset assíncrono
			current_state <= s0;
		ELSE
			IF (clk'EVENT AND clk='1') THEN -- mudança de estado é síncrona
				current_state <= next_state;
			END IF;
		END IF;
	END PROCESS state_sequence;

	-- espera a mudança de estado ou opcode
	-- processo que de fato mudam os sinais de controle conforme a transição
	state_machine: PROCESS ( current_state, opcode ) IS
	begin
		-- Reset all the control SIGNALs
		IR_load <= '0';
		IR_valid <= '0';
		IR_address <= '0';
		PC_inc <= '0';
		PC_load <= '0';
		PC_valid <= '0';
		MDR_load <= '0';
		  MDR_valid <= '0';
		MAR_load <= '0';
		MAR_valid <= '0';
		MEM_en <= '0';
		MEM_rw <= '0';
		Case current_state IS
		WHEN s0 =>
			PC_valid <= '1'; MAR_load <= '1';
			PC_inc <= '1'; PC_load <= '1';
			Next_state <= s1;
		WHEN s1 =>
			MEM_en <='1'; MEM_rw <= '1';
			Next_state <= s2;
		WHEN s2 =>
			MDR_load <= '1'; IR_load <= '1';
			Next_state <= s3;
		WHEN s3 =>
			MAR_load <= '1'; IR_address <= '1';
			If (opcode = store) THEN
				Next_state <= s4;
			ELSE
				Next_state <= s6;
			END IF;
		WHEN s4 =>
			MDR_load <= '1'; ALU_valid <= '1';
			Next_state <= s5;
		WHEN s5 =>
			MEM_en <= '1';
			Next_state <= s0;
		WHEN s6 =>
			MEM_en <= '1'; MEM_rw <= '1';
			If opcode = LOAD THEN
				Next_state <= s7;
			ELSE
				Next_state <= s8;
			END IF;
		WHEN s7 =>
			MDR_valid <= '1'; ALU_load <= '1';
			Next_state <= s0;
		WHEN s8 =>
			MEM_en<='1'; MEM_rw <= '1';
			If opcode = ADD THEN
				Next_state <= s9;
			ELSE
				Next_state <= s10;
			END IF;
		WHEN s9 =>
			ALU_add <= '1';
			Next_state <= s0;
		WHEN s10 =>
			ALU_sub <= '1';
			Next_state <= s0;
		END CASE;
	END PROCESS state_machine;
END ARCHITECTURE;
------------------------------------------------------------------------------------------------------------------