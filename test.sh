#!/bin/bash
# vim: tabstop=8 expandtab shiftwidth=4 softtabstop=4
#
# test curl --range parameter
#
FUNCTION_LIST=(getRangeHTTPNormal getRangeFTPNormal getRangeHTTPZero getRangeFTPZero getRangeHTTPNegative getRangeFTPNegative)

LOGFILE="./curl_log.log"

getRangeHTTP () {
    MIN_RANGE=$1
    MAX_RANGE=$2
    curl -r 0-$MAX_RANGE https://cdn.keycdn.com/img/cdn-stats.png > $LOGFILE 2>/dev/null
    FILESIZE=$(stat -c%s "$LOGFILE")
}

makeDecision () {
    if [ $FILESIZE = $2 ]
    then
        echo "$1 PASS!"
    else
        echo "$1 FAIL!"
    fi
}

cleanup () {
    if [ -f $LOGFILE ]
    then
        rm $LOGFILE
    fi
}

getRangeHTTPNormal () {
    getRangeHTTP 0 99
    makeDecision "getRangeHTTPNormal" 100
}

getRangeFTPNormal () {
    local x=2
    echo "running $x"
}

getRangeHTTPZero () {
    getRangeHTTP 0 0
    makeDecision "getRangeHTTPZero" 1
}

getRangeFTPZero () {
    local x=4
    echo "running $x"
}

getRangeHTTPNegative () {
    local x=5
    echo "running $x"
}

getRangeFTPNegative () {
    local x=6
    echo "running $x"
}

if [ $# -eq 0 ]
then
    # run all tests
    for fn in "${FUNCTION_LIST[@]}"
    do
        "$fn"
    done
elif [ $1 = "-l" ]
then
    # list available tests
    echo "Available tests:"
    for fn in "${FUNCTION_LIST[@]}"
    do
        echo "$fn"
    done
else
    # execute tests from command line arguments
    for fn in $*
    do
        if [[ " ${FUNCTION_LIST[@]} " =~ " ${fn} " ]]
        then
            "$fn"
        else
            echo "$fn is not a valid test name"
        fi
    done
fi

cleanup
