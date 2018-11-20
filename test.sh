LLI="lli"
#LLI="/usr/local/opt/llvm/bin/lli"

# Path to the LLVM compiler
LLC="llc"

# Path to the C compiler
CC="cc"

# Path to the microc compiler.  Usually "./microc.native"
# Try "_build/microc.native" if ocamlbuild was unable to create a symbolic link.
ZEN="./zen.native"

# Run <args>
# Report the command, run it, and report any errors
Run() {
    echo $* 1>&2
    eval $* || {
    return 1
    }
}

basename=`echo $1 | sed 's/.*\\///
                         s/.zen//'`
reffile=`echo $1 | sed 's/.zen$//'`

echo -n "$basename..."

echo 1>&2
echo "###### Testing $basename" 1>&2

generatedfiles=""

generatedfiles="$generatedfiles ${basename}.ll ${basename}.s ${basename}.exe" &&
Run "$ZEN" "$1" ">" "${basename}.ll" &&
Run "$LLC" "-relocation-model=pic" "${basename}.ll" ">" "${basename}.s" &&
Run "$CC" "-o" "${basename}.exe" "${basename}.s" &&
Run "./${basename}.exe" > "${basename}.out" &&

# Report the status and clean up the generated files

rm -f $generatedfiles
echo "DONE"