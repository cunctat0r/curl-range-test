#!/bin/bash
# vim: tabstop=8 expandtab shiftwidth=4 softtabstop=4
#
# test curl --range parameter
#
FUNCTION_LIST=(getRangeHTTPNormal 
    getRangeFTPNormal 
    getRangeHTTPDoesNotExist 
    getRangeHTTPDoesNotExist 
    getRangeHTTPNegative 
    getRangeFTPNegative)

LOGFILE="./curl_log.log"
HTTP_FILE="https://cdn.keycdn.com/img/cdn-stats.png"
HTTP_ERROR_MESSAGE="416 Requested Range Not Satisfiable"
HTTP_ERROR_MESSAGE="451 Requested Range Not Satisfiable"


getRangeHTTP () {
    MIN_RANGE=$1
    MAX_RANGE=$2
    curl -r $MIN_RANGE-$MAX_RANGE $HTTP_FILE > $LOGFILE 2>/dev/null
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

setup () {
    :
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
    getRangeHTTP -1 0
    RESPONSE=`cat $LOGFILE | grep "$HTTP_ERROR_MESSAGE"`
    if [ -n "$RESPONSE" ]
    then
        echo "getRangeHTTPNegative PASS!"
    else
        echo "getRangeHTTPNegative FAIL!"
    fi
}

getRangeFTPNegative () {
    local x=6
    echo "running $x"
}

setup

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
