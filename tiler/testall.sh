# Regression testing script for Tiler
# Modified from the MicroC testall.sh

# Time limit for all operations:
ulimit -t 30

globallog=testall.log
rm -f $globallog
error=0
globalerror=0

keep=0

# How to use testall.sh:
Usage() {
	echo "Usage: testall.sh [options] [.tile files]"
	echo "-k    Keep intermediate files"
	echo "-h 	Print this help"
	exit 1
} 

# Report any errors
SignalError() {
    if [ $error -eq 0 ] ; then
	echo "FAILED"
	error=1
    fi
    echo "  $1"
}

# Compare <outfile> <reffile> <difffile>
# Compares the outfile with reffile.  Differences, if any, are written to difffile
Compare() {
    generatedfiles="$generatedfiles $3"
    echo diff -b $1 $2 ">" $3 1>&2
    diff -b "$1" "$2" > "$3" 2>&1 || {
	SignalError "$1 differs"
	echo "FAILED $1 differs from $2" 1>&2
    }
}

# Run <args>
# Report the command, run it, and reports any errors
Run() {
    echo $* 1>&2
    eval $* || {
	SignalError "$1 failed on $*"
	return 1
    }
}

# RunFail <args>
# Report the command, run it, and expect an error
RunFail() {
    echo $* 1>&2
    eval $* && {
	SignalError "failed: $* did not report an error"
	return 1
    }
    return 0
}

Check() {
    error=0
    basename=`echo $1 | sed 's/.*\\///
                             s/.mc//'`
    relPath=`echo $1 | sed 's/.tile//'`
    reffile=`echo $1 | sed 's/.tile$//'`
    basedir="`echo $1 | sed 's/\/[^\/]*$//'`/."

    echo -n "$basename..."

    echo 1>&2
    echo "###### Testing $basename" 1>&2
    generatedfiles=""

    generatedfiles="$generatedfiles ${relPath}.ll ${relPath}.o ${relPath}.exe ${relPath}.gen ${relPath}.diff" &&
    
    # Intermediate files are placed in tests directory

    Run "make ${relPath}.test > /dev/null" &&
    Run "./${relPath}.exe" > "${relPath}.gen" &&
    Compare ${relPath}.gen ${reffile}.out ${relPath}.diff

    # Report the status and clean up the generated files

    if [ $error -eq 0 ] ; then
	if [ $keep -eq 0 ] ; then
	    rm -f $generatedfiles
	fi
	echo "OK"
	echo "###### SUCCESS" 1>&2
    else
	echo "###### FAILED" 1>&2
	globalerror=$error
    fi
}

CheckFail() {
    error=0
    basename=`echo $1 | sed 's/.*\\///
                             s/.mc//'`
    relPath=`echo $1 | sed 's/.tile//'`
    reffile=`echo $1 | sed 's/.tile$//'`
    basedir="`echo $1 | sed 's/\/[^\/]*$//'`/."

    echo -n "$basename..."

    echo 1>&2
    echo "###### Testing $basename" 1>&2

    generatedfiles=""

    generatedfiles="$generatedfiles ${relPath}.ll ${relPath}.gen ${relPath}.diff" &&
    RunFail "make ${relPath}.test 2> ${relPath}.gen 1> /dev/null" &&
    Compare ${relPath}.gen ${reffile}.err ${relPath}.diff

    # Report the status and clean up the generated files

    if [ $error -eq 0 ] ; then
	if [ $keep -eq 0 ] ; then
	    rm -f $generatedfiles
	fi
	echo "OK"
	echo "###### SUCCESS" 1>&2
    else
	echo "###### FAILED" 1>&2
	globalerror=$error
    fi
}

while getopts kdpsh c; do
    case $c in
	k) # Keep intermediate files
	    keep=1
	    ;;
	h) # Help
	    Usage
	    ;;
    esac
done

shift `expr $OPTIND - 1`

if [ $# -ge 1 ]
then
    files=$@
else
    files="tests/test-*.tile tests/fail-*.tile"
fi

for file in $files
do
    case $file in
	*test-*)
	    Check $file 2>> $globallog
	    ;;
	 *fail-*)
	    CheckFail $file 2>> $globallog
	    ;;
	*)
	    echo "unknown file type $file"
	    globalerror=1
	    ;;
    esac
done

exit $globalerror