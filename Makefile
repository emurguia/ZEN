# "make test" Compiles everything and runs the regression tests

.PHONY : test
test : all test.sh
	./testall.sh

# "make all" builds the executable as well as the "printbig" library designed
# to test linking external code

.PHONY : all
all : zen.native printbig.o

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
	rm -rf testall.log *.diff

# # Testing the "printbig" example

printbig : printbig.c
	cc -o printbig -DBUILD_TEST printbig.c

# # Building the tarball

TESTS = \
  hello_world

TESTFILES = $(TESTS:%=test-%.zen) $(TESTS:%=test-%.out)

TARFILES = ast.ml sast.ml codegen.ml Makefile _tags zen.ml parser.mly \
	README scanner.mll semant.ml testall.sh \
	printbig.c arcade-font.pbm font2c \
	Dockerfile \
	$(TESTFILES:%=tests/%) 

zen.tar.gz : $(TARFILES)
	cd .. && tar czf zen/zen.tar.gz \
		$(TARFILES:%=zen/%)
