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
    getRangeFTPNegative
    getRangeHTTPFileDoesntExist
    getRangeFTPFileDoesntExist
    )

LOGFILE="./curl_log.log"
ERRFILE="./curl_err.log"
HTTP_FILE="https://cdn.keycdn.com/img/cdn-stats.png"
HTTP_ERROR_MESSAGE="416 Requested Range Not Satisfiable"
FTP_FILE="ftp://speedtest.tele2.net/512KB.zip"
FTP_FILE_DOESNT_EXIST="ftp://speedtest.tele2.net/5KB.zip"
HTTP_FILE_DOESNT_EXIST="http://speedtest.tele2.net/5KB.zip"

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
    if [ -f $ERRFILE ]
    then
        rm $ERRFILE
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

getRangeFTPFileDoesntExist () {
    curl -r 0-100 $FTP_FILE_DOESNT_EXIST > $LOGFILE 2>$ERRFILE
    if [ -n $ERRFILE ]
    then
        RESPONSE=`cat $ERRFILE | grep "curl: (78)"`
        if [ -n "$RESPONSE" ]
        then
            echo "getRangeFTPFileDoesntExist PASS!"
            return 0
        fi
    fi
    echo "getRangeFTPFileDoesntExist FAIL!"
}

getRangeHTTPFileDoesntExist () {
    curl -r 0-100 $HTTP_FILE_DOESNT_EXIST > $LOGFILE 2>$ERRFILE
    if [ -n $LOGFILE ]
    then
        RESPONSE=`cat $LOGFILE | grep "404 Not Found"`
        if [ -n "$RESPONSE" ]
        then
            echo "getRangeHTTPFileDoesntExist PASS!"
            return 0
        fi
    fi
    echo "getRangeHTTPFileDoesntExist FAIL!"
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
