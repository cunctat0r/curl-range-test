#!/bin/bash
# vim: tabstop=8 expandtab shiftwidth=4 softtabstop=4
#
# test curl --range parameter
#
# usage: ./test.sh <-l>|<functions>
#
#   -l              list available tests
#   <functions>     list of testing functions
#
FUNCTION_LIST=(getRangeHTTPNormal 
    getRangeFTPNormal 
    getRangeHTTPZero 
    getRangeFTPZero 
    getRangeHTTPNegative 
    getRangeFTPNegative)

LOGFILE="./curl_log.log"
HTTP_FILE="https://cdn.keycdn.com/img/cdn-stats.png"
HTTP_ERROR_MESSAGE="416 Requested Range Not Satisfiable"
FTP_FILE="ftp://speedtest.tele2.net/512KB.zip"

getRange () {
    MIN_RANGE=$1
    MAX_RANGE=$2
    FILE=$3
    curl -r $MIN_RANGE-$MAX_RANGE $FILE > $LOGFILE 2>/dev/null
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
    NOT_INSTALLED=`rpm -q curl | grep "not installed"`
    if [ -n "$NOT_INSTALLED" ]
    then
        sudo yum install curl || echo "Please ask your administrator to install cURL" && exit -1
    fi 
}

getRangeHTTPNormal () {
    getRange 0 99 $HTTP_FILE
    makeDecision "getRangeHTTPNormal" 100
}

getRangeFTPNormal () {
    getRange 0 99 $FTP_FILE
    makeDecision "getRangeFTPNormal" 100
}

getRangeHTTPZero () {
    getRange 0 0 $HTTP_FILE
    makeDecision "getRangeHTTPZero" 1
}

getRangeFTPZero () {
    getRange 0 0 $FTP_FILE
    makeDecision "getRangeFTPZero" 1
}

getRangeHTTPNegative () {
    getRange -1 0 $HTTP_FILE
    RESPONSE=`cat $LOGFILE | grep "$HTTP_ERROR_MESSAGE"`
    if [ -n "$RESPONSE" ]
    then
        echo "getRangeHTTPNegative PASS!"
    else
        echo "getRangeHTTPNegative FAIL!"
    fi
}

getRangeFTPNegative () {
    getRange -1 0 $FTP_FILE
    makeDecision "getRangeFTPNegative" 1
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
