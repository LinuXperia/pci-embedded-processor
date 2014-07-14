-- Imprime o n-ésimo numero par
load 18 -- carrega 0
store 20 -- reseta contador
store 21 -- reseta resultado
load 17 -- carrega n
dec
store 20 -- contador = n - 1  (contador é iniciado com n - 1 pois o primeiro par é quando nosso contador = 0)
load 20 -- (INICIO)
be 14 -- acaba quando contador chega em 0
load 21 -- carrega resultado
add 19 --  resultado += 2
store 21 -- salva resultado
load 20 -- carrega contador
dec
jump 3 -- itera
load 21 -- (EXIT) carrega resultado
store 129 -- print
jump 0 -- reinicia
3 -- n
0 -- constante
2 -- constante
0 -- contador
0 -- resultado