#!/bin/bash

WAIT=$1
MIN=1

echo "---------START CURL QOS---------"

while true
do
    TIME=$(echo $(curl --silent --output /dev/null --max-time $MIN --write-out '%{time_connect}' 10.1.5.2)*1000 | bc)
    if [[ "$TIME" == "0" ]]
    then
        echo "ALERT"
    else
        printf "Time: %.3fms\n" $TIME
    fi
    sleep $WAIT
done
