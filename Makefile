# "make test" Compiles everything and runs the regression tests

.PHONY : test
       	 test : all test.sh
	./test.sh

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
	rm -rf testall.log *.diff get_num printbig *.o

get_num : get_num.c
	gcc -o get_num -DBUILD_TEST get_num.c
TESTS = \
	getnumtest


# # Testing the "printbig" example

printbig : printbig.c
	cc -o printbig -DBUILD_TEST printbig.c

# # Building the tarball

# TESTS = \
#   add1 arith1 arith2 arith3 fib float1 float2 float3 for1 for2 func1 \
#   func2 func3 func4 func5 func6 func7 func8 func9 gcd2 gcd global1 \
#   global2 global3 hello if1 if2 if3 if4 if5 if6 local1 local2 ops1 \
#   ops2 printbig var1 var2 while1 while2

# FAILS = \
#   assign1 assign2 assign3 dead1 dead2 expr1 expr2 expr3 float1 float2 \
#   for1 for2 for3 for4 for5 func1 func2 func3 func4 func5 func6 func7 \
#   func8 func9 global1 global2 if1 if2 if3 nomain printbig printb print \
#   return1 return2 while1 while2

# TESTFILES = $(TESTS:%=test-%.mc) $(TESTS:%=test-%.out) \
# 	    $(FAILS:%=fail-%.mc) $(FAILS:%=fail-%.err)

# TARFILES = ast.ml sast.ml codegen.ml Makefile _tags microc.ml parser.mly \
# 	README scanner.mll semant.ml testall.sh \
# 	printbig.c arcade-font.pbm font2c \
# 	Dockerfile \
# 	$(TESTFILES:%=tests/%) 

# microc.tar.gz : $(TARFILES)
# 	cd .. && tar czf microc/microc.tar.gz \
# 		$(TARFILES:%=microc/%)
