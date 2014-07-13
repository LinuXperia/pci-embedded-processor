µPCI
======================

> Inspiração: Design Recipes for FPGAs: Using Verilog and VHDL (Embedded Technology) 

Projeto final da disciplina Prototipação de Circuitos Integrados. POLI/UPE, 2014-1.

## Introdução

O objetivo principal deste projeto é a construção de um µProcessador, que foi feita tendo como base a descrição de um processador no documento "Design Recipes for FPGAs: Using Verilog and VHDL (Embedded Technology)". Como o comportamento do processador desenvolvido é semelhante ao de um processador comum (como o que encontramos em nossos computadores, smartphones, etc), também será possível escrever programas (dado o conjunto de instruções existentes no processador) para serem executados pelo FPGA, claro, após passá-los por um tradutor que os converterá de um código MIPS para linguagem de máquina em binário.

## Implementação
### Modelo Estrutural

![Structural Model of the Microprocessor](/structural-model.png "Structural Model of the Microprocessor")

O modelo estrutural do processador implementado neste projeto segue o que está mostrado na imagem acima. Possui uma Unidade de Controle, um contador de programa, um acumulador, um registrador de dados, um de endereços e um de instruções, uma memória interna e um barramento que passam dados e endereços de memória. As seções abaixo descrevem, com mais detalhes, como foram implementados cada componente. 

### Conjunto de Instruções

	 	Comando		| 	Opcode (Binário)	
	 LOAD endereço	| 		0000				  
	 STORE endereço	| 		0001				  
	 ADD endereço	| 		0010				  
	 SUB endereço	| 		0011				  
	 INC			| 		0100				  
	 DEC			| 		0101				  
	 NOTT			| 		0110				  
	 ANDD endereço	| 		0111				  
	 ORR endereço	| 		1000				  
	 XORR endereço	| 		1001				  
	 J endereço		| 		1010				  
	 BE endereço	| 		1011				  
	 BG endereço	| 		1100				  
	 BL endereço	| 		1101				  
	 WAITT			| 		1110				  
	 NOP			| 		1111				

### Program Counter (PC)

O módulo do PC deve conter 6 'pinos':  
* Clock;  
* Reset ativo em 0;  
* Barramento de entrada e saída (PC_bus, barramento INOUT);  
* Incrementar (PC_inc);  
* Carregar (PC_load);  
* Ler (PC_valid, manda o valor do PC pro PC_bus quando ativo, ou Z quando inativo).

Todos devem ser std logic, com exceção do PC_bus, que é std logic vector.

Parte assíncrona: se a flag de valid for para 0, a saída no BUS deve ser colocada em Z imediatamente. Se reset for para 0, o valor do PC deve ir para 0.

Parte síncrona: na borda de subida, verifica-se as flags inc e load, em ordem de precedência. Isto é, se inc estiver em nível alto, não importa se load também está, deve ser realizado o incremento. Se inc estiver em nível baixo, verifica-se se load está em nível alto. Se estiver, carrega-se o valor do bus no PC. 


### Instruction Register

O módulo do IR deve conter 7 'pinos':  
* Clock;  
* Reset;  
* IR_load (flag para dizer se o IR está no modo load - carregar a instrução a ser executada pelo processador ou decodificada);  
* IR_valid (flag que indica se o IR está em operação);  
* IR_address (flag para dizer se o IR está address - carregar o endereço no barramento);  
* IR_opcode (saída com o opcode decodificado);  
* IR_bus (interface para o barramento interno);

A função do IR é decodificar o *opcode* em forma binária e então passá-lo para o bloco de controle.

Parte assíncrona: se a flag de valid for para 0, a saída no BUS deve ser colocada em Z imediatamente. Se reset for para 0, o valor do registrador interno deve ir para 0s.

Parte síncrona: na borda de subida, o valor do barramento deve ser enviado para o registrador interno e o opcode de saída deve ser decodificado assincronamente quando o valor no IR mudar.

### Arithmetic Logic Unit (ALU)

O módulo de ALU deve conter, também, 6 'pinos':  
* Clock;  
* Reset ativo em 0;  
* Barramento de entrada e saída (ALU_bus, barramento INOUT, mesma idéia do PC_bus);  
* Comando (função) a ser realizado (ALU_cmd, com 3 bits, sinais de controle que indicam a função (de 8 possíveis) a ser realizada pela ALU);  
* Ler (ALU_valid, manda o valor da ALU pro ALU_bus quando ativo, ou Z quando inativo);  
* Zero (ALU_zero, fica em nível alto quando o resultado da ALU é todo zero).

A ALU possui, como sinal interno, um acumulador ACC do tamanho do barramento do sistema. É ele quem guarda o valor a ser enviado para o barramento quando o sinal ALU_valid está ativo, e é quando este é inteiramente zero que o ALU_zero é ativo. Ao ativar o sinal de reset (colocando-o em 0), reseta-se o valor do registrador interno (ACC) para 0.

Na borda de subida do clock, decodifica-se o valor do comando e realiza-se a operação em cima do ACC.

Os comandos possíveis são:

	| Comando	| 		Operação 														|
	| 0000 		| LOAD - Carrega o valor do barramento no ACC (ACC = 0 + BUS) 			|
	| 0001 		| ADD - Soma o valor do barramento ao ACC (ACC = ACC + BUS) 			|
	| 0010 		| NOT - Carrega no ACC a negação do valor do barramento (ACC = not BUS)	|
	| 0011 		| OR - 'Ou' do valor do barramento com o ACC (ACC = ACC or BUS) 		|
	| 0100 		| AND - 'E' do valor do barramento com o ACC (ACC = ACC and BUS) 		|
	| 0101 		| XOR - 'Ou exclusivo' valor do barramento com o ACC (ACC = ACC xor BUS)|
	| 0110 		| INC - Incrementa o ACC (ACC = ACC + 1) 								|
	| 0111 		| SUB - Subtrai o valor do barramento do ACC (ACC = ACC - BUS) 			|
	| 1000		| DEC - Decrementa o ACC (ACC = ACC - 1)								|

### Memória de Programa/Dados

O módulo de memória deve conter 8 'pinos':  
* Clock;  
* Reset ativo em 0;  
* Ativação de carregamento do registrador MDR (MDR_load, MDR = Memory Data Register);  
* Ativação de carregamento do registrador MAR (MAR_load, MAR = Memory Address Register);  
* Ler (MEM_valid, manda o valor lido na memória (registrador MDR) para o MEM_bus quando ativo, ou Z quando inativo);  
* Barramento de entrada e saída (MEM_bus, barramento INOUT, mesma idéia do PC_bus);  
* Flag de ativação da memória (MEM_en);  
* Flag de indicação de escrita ou leituar (MEM_rw, onde '0' indica leitura e '1' escrita);
  
O bloco de memória tem 3 partes:  
* Carregamento do endereço a ser acessado (vem do BUS e é salvo no MAR);  
* Leitura ou escrita do dado presente no endereço indicado pelo MAR, utilizando o MDR;  
* Carregamento dos dados padrões na memória (simulando ROM), toda vez que a mesma é resetada.
 

### Unidade de Controle (UC)

A função da Unidade de Controle é acessar o PC, pegar a instrução da memória, mover os dados quando necessário, configurando todos os sinais de controle no momento certo e com os valores corretos.
Dessa forma, a Unidade de Controle deve ter um clock e reset, conexão com o barramento global e saídas com todos sinais de controle:

* Clock;
* Reset ativo em 0;
* Opcode;
* IR_load;
* IR_valid;
* IR_address;
* PC_inc;
* PC_load;
* PC_valid;
* MDR_load;
* MDR_valid;
* MAR_load;
* MAR_valid;
* MEM_en;
* MEM_rw;
* ALU_valid;
* ALU_load;
* ALU_cmd;
* CONTROL_bus;

A Unidade de controle pode ser implementada por uma máquina de estado que controla o fluxo de sinais no processador. O diagrama da máquina de estado pode ser conferido na imagem abaixo.

![Basic Processor Controller State Machine](/controller-state-machine_atual.png "Basic Processor Controller State Machine")

	|	Estado	| Descrição 																																																					|		Sinais Ativos 			|
	| 	s0 		| Busca de instrução: manda o valor do PC para o barramento e incrementa o PC. Além disso, carrega o endereço do barramento (valor do PC) no MAR.													 							| MAR_load, PC_valid, PC_inc	|
	| 	s1 		| Busca de instrução: ativa memória para R/W e configura para leitura (valor no endereço de memória que está em MAR é armazenado em MDR, isto é, carregamos a próxima linha de código a ser executada). 						| MEM_en 						|
	| 	s2 		| Busca de instrução/Decodificação: Carregamento do que foi lido na memória para o IR 																																			| MEM_valid, IR_load 			|
	|	s3 		| Envio do valor armazenado em IR para o barramento, carregando no MAR. Se a instrução for NOP, retorna ao estado inicial s0.																									| IR_valid, MAR_load 			|
	| 	s4 		| Se a instrução for de STORE, armazena o valor do acumulador no MDR 																																							| ALU_valid, MDR_load 			|
	| 	s5 		| Escreve o valor armazenado no MDR na posição de memória armazenada no MAR. Após isso, retorna ao estado inicial s0. 																											| MEM_en, MEM_rw 				|
	| 	s6 		| Se a instrução for diferente LOAD, carrega para MDR o valor da posição de memória armazenado no MAR. 																															| MEM_en 						|
	|	s7		| Habilita a memória para leitura e resgata o valor que está na posição indicada no MAR. Após isso, retorna ao estado inicial s0.																								| MEM_valid, ALU_enable, ALU_cmd|
	|	s8		| Se, no estado S3, a instrução for BLESS, BGREATER ou BZERO, e o BRANCH_Trigger estiver ativo, é carregado no PC a instrução da posição de memória indicada pelo IR.															| -								|
	|	s9		| Se, no estado S3, a instrução for JUMP, neste estado é carregado o valor do PC com a instrução que está na posição de memória indicada pelo IR. Após isso, retorna ao estado inicial s0.										| IR_valid, PC_load				|
	|	s10		| Se, no estado S3, a instrução for WAIT, o processador espera até que seja recebido um sinal de WAKE para que ele retorne ao estado 0, continuando o fluxo de buscas de instruções. Após isso, retorna ao estado inicial s0.	| -								|

Após o estado s6, cria-se um novo estado para cada operação possível que depende da ALU, ativando o flag que envia o valor armazenado no MDR para o barramento, e setando o comando da ALU para a operação correspondente. 

Isto é, para o estado de LOAD, ativa-se MDR_valid e define-se ALU_cmd <= 000. Para ADD, ativa-se MDR_valid e define-se ALU_cmd <= 001. Assim sucessivamente.

