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
* Reset;
* PC_bus (barramento INOUT);
* Incrementar (PC_inc);
* Carregar (PC_load);
* Ler (PC_valid, manda o valor do PC pro PC_bus quando ativo, ou Z quando inativo).

Todos devem ser std logic, com exceção do PC_bus, que é std logic vector.

Parte assíncrona: se a flag de valid for para 0, a saída no BUS deve ser colocada em Z imediatamente. Se reset for para 0, o valor do PC deve ir para 0.

Parte síncrona: na borda de subida, verifica-se as flags inc e load, em ordem de precedência. Isto é, se inc estiver em nível alto, não importa se load também está, deve ser realizado o incremento. Se inc estiver em nível baixo, verifica-se se load está em nível alto. Se estiver, carrega-se o valor do bus no PC. 


### IR

O módulo do PC deve conter 7 'pinos':
* Clock;
* Reset;
* IR_load (flag para dizer se o IR está no modo load - carregar a instrução a ser executada pelo processador ou decodificada);
* IR_valid
* IR_address (flag para dizer se o IR está address - carregar o endereço no barramento);
* IR_opcode
* IR_bus (interface para o barramento interno);

A função do IR é decodificar o *opcode* em forma binária e então passá-lo para o bloco de controle.

Parte assíncrona: se a flag de valid for para 0, a saída no BUS deve ser colocada em Z imediatamente. Se reset for para 0, o valor do registrador interno deve ir para 0s.

Parte síncrona: na borda de subida, o valor do barramento deve ser enviado para o registrador interno e o opcode de saída deve ser decodificado assincronamente quando o valor no IR mudar.

### ALU

TODO


### Memória

TODO


### Unidade de Controle

TODO
