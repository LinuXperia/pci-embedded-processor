Embedded Processor 
======================

PCI 2014.1 - POLI/UPE

> Based on: Design Recipes for FPGAs: Using Verilog and VHDL (Embedded Technology) 

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

![Structural Model of the Microprocessor](/structural-model.png?raw=true "Structural Model of the Microprocessor")

### Controller machine state

![Basic Processor Controller State Machine](/controller-state-machine.png?raw=true "Basic Processor Controller State Machine")

### PC

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


### IR

TODO


### ALU

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

| Comando 		| Operação |
|-------------|----------|
| 000 | Carrega o valor do barramento no ACC (ACC = 0 + BUS) |
| 001 | Soma o valor do barramento ao ACC (ACC = ACC + BUS) |
| 010 | NOT do valor do barramento (ACC = not BUS) |
| 011 | OR do valor do barramento com o ACC (ACC = ACC or BUS) |
| 100 | AND do valor do barramento com o ACC (ACC = ACC and BUS) |
| 101 | XOR do valor do barramento com o ACC (ACC = ACC xor BUS) |
| 110 | Incrementa o ACC (ACC = ACC + 1) |
| 111 | Armazena o valor do ACC no barramento (BUS = ACC) |

_Qual a necessidade do comando 111?_

### Memória

TODO


### Unidade de Controle

TODO
