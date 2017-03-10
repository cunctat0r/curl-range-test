#!/bin/bash
# vim: tabstop=8 expandtab shiftwidth=4 softtabstop=4
#
# test curl --range parameter
#
FUNCTION_LIST=(getRangeHTTPNormal getRangeFTPNormal getRangeHTTPZero getRangeFTPZero getRangeHTTPNegative getRangeFTPNegative)

getRangeHTTPNormal () {
    local x=1
    echo "running $x"
}

getRangeFTPNormal () {
    local x=2
    echo "running $x"
}

getRangeHTTPZero () {
    local x=3
    echo "running $x"
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

for fn in "${FUNCTION_LIST[@]}"
do
    "$fn"
done

