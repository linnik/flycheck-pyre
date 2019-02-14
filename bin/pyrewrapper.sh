#!/bin/bash
# Eval given arguments and ignore STDERR output
eval "$@" 2> /dev/null

# TODO: discuss more consistent output with Pyre maintainers
# Eval given arguments and display STDERR only on failure
# TMP=$(mktemp)
# eval "$@" 2> "$TMP"
# EXITCODE=$?
# if [ $EXITCODE -ne 0 ]; then
#     ERR=$(cat "$TMP")
#     (>&2 echo $ERR)
# fi
# rm $TMP
# exit $EXITCODE
