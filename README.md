# CS152_CompilerDesign

- flex exl.lex
- gcc lex.yy.c -lfl
- bison -v -d --file-prefix=y mini_l.y
- gcc -o parser y.tab.c lex.yy.c -lfl
- ./a.out
