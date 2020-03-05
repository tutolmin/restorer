BASE=restorer
EXEC=restorer
LIBS=-lfl -lm -lcrypto -L/usr/local/lib -lreflex 
INCLUDE=-std=gnu99 -I/usr/local/include/reflex
CC=c++

DEBUGINFO=-g

# These flags are particularly severe on checking warnings.
# It may be that they are not all appropriate to your environment.
# For instance, not all environments have prototypes available for
# the standard library functions.

# Linux users might need to add -D__linux__ to these in order to
# use strcasecmp instead of strcmpi (cf output.c)

# Mac OS X users might need to add -D__unix__ to CFLAGS
# and use CC=cc or CC=gcc

OPTIMISE=-O3

CFLAGS+=-c -pedantic -Wall -Wshadow -Wformat -Wpointer-arith \
	-Wwrite-strings \
	-Wsign-compare $(DEBUGINFO) \
	-I/usr/local/lib/ansi-include \
	-D__linux__ \
        $(OPTIMISE)
	 
LEX=reflex
BYACC=byacc
$(EXEC)		: y.tab.o lex.yy.o
			$(CC) $(DEBUGINFO) -o $(EXEC) lex.yy.o y.tab.o $(LIBS)
lex.yy.o	: lex.yy.cpp
			$(CC) $(CFLAGS) -c lex.yy.cpp
lex.yy.cpp	: $(BASE).l
			$(LEX) $(BASE).l
y.tab.o		: y.tab.c
			$(CC) $(CFLAGS) -c y.tab.c
y.tab.c		: $(BASE).y
			$(BYACC) -v -d $(BASE).y
clean		:
			rm -f ./lex.yy.cpp ./y.tab.c ./y.output ./y.tab.h ./*.o ./*.core ./*~ ./*.out

