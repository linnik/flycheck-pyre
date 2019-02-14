#!/bin/bash
# TODO: discuss more consistent output with Pyre maintainers
# Eval given arguments and display STDERR when STDOUT is empty and exit code is non-zero
STDERR=$(mktemp)
STDOUT=`eval "$@" 2> $STDERR`
EXITCODE=$?
if [ -z "$STDOUT" ] && [ $EXITCODE -ne 0]; then
    ERR=$(cat "$STDERR")
    (>&2 echo $ERR)
else
    EXITCODE=0
    echo $STDOUT
fi
rm $STDERR
exit $EXITCODE
