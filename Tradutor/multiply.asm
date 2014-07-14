-- Realiza a operação z * y
load 17 -- carrega 0
store 20 -- reseta contador (x)
store 21 -- reseta resultado (k)
load 19 -- carrega y
store 20 -- x = y  escreve y no contador (pra decrementar)
load 20 -- carrega contador  (INICIO)
be 14 -- se contador for 0, exit
load 21 -- senao, realiza a soma
add 18 -- faz z + k
store 21 -- armazena k
load 20 -- decrementa o contador
dec
store 20
jump 5 -- (FIM)
load 21 -- carrega resultado
store 129 -- print
jump 0 -- reinicia código
0 -- sempre é zero
5 -- z (entrada)
3 -- y (entrada)
0 -- x (contador)
0 -- k (resultado)