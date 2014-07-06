LIBRARY ieee;
USE ieee.numeric_std.all;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_signed.all;	
USE work.processor_functions.all;
ENTITY pc IS
	PORT (clk, nrst: IN STD_LOGIC; -- reset ativo em zero
				PC_inc: IN STD_LOGIC; -- sinal que indica que o PC deve ser incrementado
				PC_load: IN STD_LOGIC; -- sinal que indica que PC deve ser substitui­do pelo valor em PC_bus
				PC_valid: IN STD_LOGIC; -- sinal que indica que o valor de PC deve ser colocado em PC_bus (ou Z se 0)
				PC_bus: INOUT STD_LOGIC_VECTOR(n-1  DOWNTO 0)); -- barramento de entrada/saida
END ENTITY pc;

ARCHITECTURE rtl OF pc IS
	SIGNAL counter: INTEGER RANGE 0 to 2**n -1; -- contador em si
BEGIN
	-- Se o PC_valid = '1', manda o valor do PC pro barramento. Caso contrario, manda Z.
	PC_bus <= STD_LOGIC_VECTOR(to_unsigned(counter, PC_bus'length)) 
					WHEN PC_valid = '1' 
						ELSE (OTHERS => 'Z');
	
	PROCESS (clk, nrst) IS
	BEGIN
	
		-- De forma assincrona, se o reset ficar em ni­vel 0, volta o contador pra 0
		IF nrst = '0' THEN
			counter <= 0;
		-- Se teve uma borda de subida no clock, faz as outras coisas
		ELSIF (clk'EVENT AND clk='1') THEN
			-- A maior prioridade eh do incremento. Se esta em 1, incrementa o PC
			IF PC_inc = '1' THEN
				counter <= counter + 1;
			-- Caso contrario, verifica se eh pra carregar o valor do bus.
			ELSIF PC_load = '1' THEN
					counter <= to_integer(unsigned(PC_bus)); -- Cast de STD_LOGIC_VECTOR pra INTEGER
			END IF;
		END IF;
	END PROCESS;
END ARCHITECTURE rtl;