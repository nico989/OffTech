#!/bin/bash

WAIT=$1
MIN=1

if [ $# == 1 ]
then
    echo "---------START CURL QOS---------"

    while true
    do
        TIME=$(echo $(curl --silent --output /dev/null --max-time $MIN --write-out '%{time_connect}' 10.1.5.2)*1000 | bc)
        if [[ "$TIME" == "0" ]] || [ 1 -eq "$(echo "$TIME > $MIN" | bc)" ]
        then
            echo "Curl: ALERT"
        else
            printf "Curl Time: %.3f ms\n" $TIME
        fi
        sleep $WAIT
    done
else
    echo "Usage: ./curl_qos.sh <SLEEP TIME>"
fi
