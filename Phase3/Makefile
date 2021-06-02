parse: mini_l.lex mini_l.y
	bison -v -d --file-prefix=y mini_l.y
	flex mini_l.lex
	gcc -o a.out y.tab.c lex.yy.c

clean:
	rm -rf lex.yy.c y.tab.* y.output *.o a.out
