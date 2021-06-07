CFLAGS = -g -Wall -ansi -pedantic

phase3: mini_l.lex mini_l.y
	bison -v -d --file-prefix=y mini_l.y
	flex mini_l.lex
	g++ $(CFLAGS) -std=c++11 lex.yy.c y.tab.c main.c -o phase3 -lfl

clean:
	rm -rf lex.yy.c *.output *.tab.c *.tab.h y.output *.o a.out *.mil phase3.dSYM phase3

test: phase3
	cat ./primes.min | ./phase3 > ./primes.mil
	cat ./fibonacci.min | ./phase3 > ./fibonacci.mil
	cat ./mytest.min | ./phase3 > ./mytest.mil
