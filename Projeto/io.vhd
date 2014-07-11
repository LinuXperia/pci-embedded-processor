---- IO ------------------------------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.processor_functions.all;
------------------------------------------------------------------------------------------------------------------
ENTITY io IS
	PORT (clk, nrst: IN STD_LOGIC; -- reset ativo em zero
				IODR_load: IN STD_LOGIC; -- sinal de carregamento do BUS para IODR
				IOAR_load: IN STD_LOGIC; -- sinal de carregamento do BUS para IOAR
				IO_valid: IN STD_LOGIC; -- sinal que indica que o resultado da IODR deve ser colocado em IO_bus (ou Z se 0)
				IO_en: IN STD_LOGIC; -- ativacao do componente para operacoes de leitura e escrita
				IO_rw: IN STD_LOGIC; -- flag que indica se a operacao a ser realizada eh de leitura ou escrita
				IO_bus: INOUT STD_LOGIC_VECTOR(n-1 DOWNTO 0)); -- barramento de entrada/saida
END ENTITY io;

ARCHITECTURE processor_io OF io IS
	SIGNAL iodr: STD_LOGIC_VECTOR(wordlen-1 DOWNTO 0); -- registrador de dados
	SIGNAL ioar: UNSIGNED(wordlen-oplen-1 DOWNTO 0); -- registrador de enderecos
BEGIN
	-- Se o IO_valid = '1', manda o valor do resultado do iodr pro barramento. Caso contrario, manda Z.
	IO_bus <= iodr 
					WHEN IO_valid = '1' 
						ELSE (others => 'Z');
END ARCHITECTURE processor_io;