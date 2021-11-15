#!/bin/bash

WAIT=$1
MIN=1

if [ $# == 1 ]
then
    echo "---------START PING QOS---------"

    while true
    do
        TIME=$(ping -c 1 10.1.5.2 | awk -F " " 'FNR==2{print substr($7,6)}')
        if [ -z $TIME ] || [ 1 -eq "$(echo "$TIME > $MIN" | bc)" ]
        then
            echo "Ping: ALERT"
        else
            echo "Ping Time:" $TIME "ms"
        fi
        sleep $WAIT
    done
else
    echo "Usage: ./ping_qos.sh <SLEEP TIME>"
fi
