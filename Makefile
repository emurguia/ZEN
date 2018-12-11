# "make test" Compiles everything and runs the regression tests

.PHONY : test
test : all test.sh
	./testall.sh

# "make all" builds the executable as well as the "printbig" library designed
# to test linking external code

.PHONY : all
all : zen.native printbig.o make_circle.o make_triangle.o make_window.o close_window.o keep_open.o

# "make zen.native" compiles the compiler

.PRECIOUS : zen.native
zen.native :
	opam config exec -- \
	ocamlbuild -use-ocamlfind -pkgs llvm,llvm.analysis -cflags -w,+a-4 \
		zen.native

# "make clean" removes all generated files

.PHONY : clean
clean :
	ocamlbuild -clean
	rm -rf testall.log *.diff printbig make_circle make_triangle keep_open close_window keep_open make_rectangle make_point make_line *.o *.ll *.exe

# # Testing the "printbig" example

printbig : printbig.c
	cc -o printbig -DBUILD_TEST printbig.c

make_circle : make_circle.c
	cc -o make_circle -DBUILD_TEST make_circle.c /usr/local/lib/libsigil.so

make_triangle: make_triangle.c
	cc -o make_triangle -DBUILD_TEST make_triangle.c /usr/local/lib/libsigil.so

make_window: make_window.c
	cc -o make_window -DBUILD_TEST make_window.c /usr/local/lib/libsigil.so

close_window: close_window.c
	cc -o close_window -DBUILD_TEST close_window.c /usr/local/lib/libsigil.so

keep_open: keep_open.c
	cc -o keep_open -DBUILD_TEST keep_open.c /usr/local/lib/libsigil.so

make_line: make_line.c
	cc -o make_line -DBUILD_TEST make_line.c /usr/local/lib/libsigil.so

make_point: make_point.c
	cc -o make_point -DBUILD_TEST make_point.c /usr/local/lib/libsigil.so
make_rectangle: make_rectangle.c
	cc -o make_rectangle -DBUILD_TEST make_rectangle.c /usr/local/lib/libsigil.so


# # Building the tarball

TESTS = \
  basic_binops bool1 bool2 bools equalities float1 float2 hello \
  int1 int2 int3 string1 string2 string3 tuples

FAILS = \
  assign1

TESTFILES = $(TESTS:%=test-%.zen) $(TESTS:%=test-%.out) \
	    $(FAILS:%=fail-%.zen) $(FAILS:%=fail-%.err)

TARFILES = ast.ml sast.ml codegen.ml Makefile _tags zen.ml parser.mly \
	README scanner.mll semant.ml testall.sh \
	printbig.c arcade-font.pbm font2c \
	Dockerfile \
	$(TESTFILES:%=tests/%) 

zen.tar.gz : $(TARFILES)
	cd .. && tar czf zen/zen.tar.gz \
		$(TARFILES:%=zen/%)
