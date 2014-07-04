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
