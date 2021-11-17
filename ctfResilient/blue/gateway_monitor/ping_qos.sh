#!/bin/bash

WAIT=$1
MIN=1

if [ $# == 1 ]
then
    echo "---------START PING QOS---------"

    while true
    do
        TIME=$(ping -c 1 10.1.5.2 | awk -F " " 'FNR==2{print substr($7,6)}')
        MSG=""
        if [ -z $TIME ] || [ 1 -eq "$(echo "$TIME > $MIN" | bc)" ]
        then
            MSG=$(echo "Ping: ALERT")
        else
            MSG=$(echo "Ping Time:" $TIME "ms")
        fi
        echo $MSG
        echo $MSG >> log_ping_qos.txt
        sleep $WAIT
    done
else
    echo "Usage: ./ping_qos.sh <SLEEP TIME>"
fi
