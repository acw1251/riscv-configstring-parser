main: lex.yy.c configstring.tab.c
	g++ --std=c++11 lex.yy.c configstring.tab.c -lfl -o main

lex.yy.c: configstring.l configstring.tab.h
	flex configstring.l

configstring.tab.c configstring.tab.h: configstring.y
	bison -d configstring.y

clean:
	rm -f lex.yy.c configstring.tab.c configstring.tab.h main
