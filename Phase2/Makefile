parse: [Cristina-Lawson]_[Mayur-Ryali].lex [Cristina-Lawson]_[Mayur-Ryali].y
	bison -v -d --file-prefix=y [Cristina-Lawson]_[Mayur-Ryali].y
	flex [Cristina-Lawson]_[Mayur-Ryali].lex
	gcc -o a.out y.tab.c lex.yy.c -lfl

clean:
	rm -rf lex.yy.c y.tab.* y.output *.o a.out 
