CFLAGS = -g -Wall -ansi -pedantic

phase3: mini_l.lex mini_l.y
	bison -d -v mini_l.y
	flex mini_l.flex
	g++ $(CFLAGS) -std=c++11 lex.yy.c phase3.tab.c -lfl -o phase3
	rm -rf lex.yy.c *.output *.tab.c *.tab.h

test: phase3
	cat ./primes.min | ./phase3 > ./primes.mil
	cat ./fibonacci.min | ./phase3 > ./fibonacci.mil
	cat ./mytest.min | ./phase3 > ./mytest.mil
