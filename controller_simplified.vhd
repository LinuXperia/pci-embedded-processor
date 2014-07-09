---- Controller_simplified --------------------------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.processor_functions.all;
------------------------------------------------------------------------------------------------------------------
ENTITY controller_simplified IS
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
			ALU_zero: IN std_logic;
			ALU_valid: OUT std_logic;
			ALU_enable: OUT std_logic;
			ALU_cmd: OUT std_logic_vector(2 DOWNTO 0));
END ENTITY controller_simplified;
------------------------------------------------------------------------------------------------------------------
ARCHITECTURE RTL OF controller_simplified IS
	TYPE states IS (s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10);
	SIGNAL current_state, next_state: states;
BEGIN
	-- Processo que gerencia a transicao do current_state para o next_state
	-- e a configuracao de reset
	state_sequence: PROCESS (clk, nrst) BEGIN
		IF nrst = '0' THEN -- reset assÃƒÆ’Ã‚Â­ncrono
			current_state <= s0;
		ELSE
			IF (clk'EVENT AND clk='1') THEN -- mudanca de estado eh sincrona
				current_state <= next_state;
			END IF;
		END IF;
	END PROCESS state_sequence;

	-- espera a mudanca de estado ou opcode
	-- processo que de fato mudam os sinais de controle conforme a transicao
	state_machine: PROCESS ( current_state, IR_opcode ) IS
	BEGIN
		-- Reset all the control SIGNALs
		IR_load <= '0';
		IR_valid <= '0';
		PC_inc <= '0';
		PC_load <= '0';
		PC_valid <= '0';
		MDR_load <= '0';
		MAR_load <= '0';
		MEM_valid <= '0';
		MEM_en <= '0';
		MEM_rw <= '0';
		ALU_valid <= '0';
		ALU_enable <= '0';
		ALU_cmd <= "000";

		CASE current_state IS
			WHEN s0 =>
				MAR_load <= '1';
				PC_valid <= '1';
				PC_inc <= '1';
				next_state <= s1;

			WHEN s1 =>
				MEM_en <='1';
				next_state <= s2;

			WHEN s2 =>
				MEM_valid <= '1';
				IR_load <= '1';
				IF (IR_opcode = INC) THEN
					next_state <= s8;
				ELSIF (IR_opcode = JUMP) THEN
					next_state <= s10;
				ELSIF (IR_opcode = JZERO) THEN
					next_state <= s9;
				ELSE
					next_state <= s3;
				END IF;

			WHEN s3 =>
				IR_valid <= '1';
				MAR_load <= '1';
				If (IR_opcode = STORE) THEN
					next_state <= s4;
				ELSE
					next_state <= s6;
				END IF;

			WHEN s4 =>
				ALU_valid <= '1';
				MDR_load <= '1';
				next_state <= s5;

			WHEN s5 =>
				MEM_en <= '1';
				MEM_rw <= '1';
				next_state <= s0;

			WHEN s6 =>
				MEM_en <= '1';
				next_state <= s7;

			WHEN s7 =>
				MEM_valid <= '1';
				ALU_enable <= '1';
				ALU_cmd <= cmdDecode(IR_opcode);
				next_state <= s0;

			WHEN s9 =>
				IF (ALU_zero = '1') THEN
					next_state <= s10;
				ELSE
					next_state <= s0;
				END IF;

			WHEN s10 =>
				PC_load <= '1';
				IR_valid <= '1';
				next_state <= s0;
				
		END CASE;
	END PROCESS state_machine;
END ARCHITECTURE;
------------------------------------------------------------------------------------------------------------------