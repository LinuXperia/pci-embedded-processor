-- Realiza a operação z * y
load 15 -- carrega y
store 13 -- x = y  escreve y no contador (pra decrementar)
load 13 -- contador
be 13 -- se contador for 0, exit
load 16 -- senao, vamo fazer a soma
add 14 -- faz z + k
store 16 -- armazena k
load 13 -- decrementa o contador
dec
store 13
jump 2
jump 14
jump 13
0 -- x (contador)
5 -- z (entrada)
3 -- y (entrada)
0 -- k (resultado)