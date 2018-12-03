# compilers
CC = gcc
CXX = g++

# additional flags
INCLUDES = 
CFLAGS = -g -Wall $(INCLUDES)
CXXFLAGS = -g -Wall $(INCLUDES)
LDFLAGS = -g

tiler-test: tiler-caller.o libtiler.a
	gcc -o tiler-test tiler-caller.o libtiler.a `sdl2-config --libs`

tiler-caller.o: tiler-caller.c tiler.h

libtiler.a: tiler-main.o tiler-functs.o tiler-grid.o tiler-object.o tiler-mouse.o
	ar rc libtiler.a tiler-main.o tiler-functs.o tiler-grid.o tiler-object.o tiler-mouse.o
	ranlib libtiler.a

tiler-main.o: tiler-main.c tiler-main.h tiler-grid.h tiler-object.h tiler-mouse.h TileGame.h
	gcc -c tiler-main.c `sdl2-config --cflags`

tiler-functs.o: tiler-functs.c tiler-functs.h TileGame.h

tiler-grid.o: tiler-grid.c tiler-grid.h tiler-object.h TileGame.h
	gcc -c tiler-grid.c `sdl2-config --cflags`

tiler-object.o: tiler-object.c tiler-object.h TileGame.h
	gcc -c tiler-object.c `sdl2-config --cflags`

tiler-mouse.o: tiler-mouse.c tiler-mouse.h TileGame.h

.PHONY: clean
clean:
	rm -f tiler-test *.o *.a

.PHONY: all
all: clean tiler-test
