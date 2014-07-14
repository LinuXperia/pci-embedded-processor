-- Imprime o n-ésimo numero par
load 19 -- carrega 0
store 21 -- reseta contador
store 22 -- reseta resultado
load 18 -- carrega n
dec
store 21 -- contador = n - 1  (contador é iniciado com n - 1 pois o primeiro par é quando nosso contador = 0)
load 21 -- carrega contador (INICIO)
be 15 -- acaba quando contador chega em 0
load 22 -- carrega resultado
add 20 --  resultado += 2
store 22 -- salva resultado
load 21 -- carrega contador
dec
store 21
jump 6 -- itera
load 22 -- (EXIT) carrega resultado
store 129 -- print
jump 0 -- reinicia
3 -- n
0 -- constante
2 -- constante
0 -- contador
0 -- resultado