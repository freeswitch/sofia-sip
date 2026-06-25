#!/bin/bash

# All output will be collected here
TESTSUNITPATH=$PWD/tests/unit

failed_tests=$(find ./ -name *.trs | xargs grep FAIL -l)
if [[ -n $failed_tests ]]
then
    echo "FAILED TESTS $failed_tests"
    for test in $failed_tests
    do
        dir="$(dirname "${test}")"
        file="$(basename "${test}")"
        log="$TESTSUNITPATH/log_run-tests_${dir//\//!}!$file.html";
        cat $dir/test-suite.log | ansi2html > $log
    done
    exit 1
fi