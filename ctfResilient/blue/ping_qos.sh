#!/bin/bash

WAIT=$1
MIN=1

echo "---------START PING QOS---------"

while true
do
    TIME=$(ping -c 1 10.1.5.2 | awk -F " " 'FNR==2{print substr($7,6)}')
    if [ -z $TIME ] || [ 1 -eq "$(echo "$TIME > $MIN" | bc)" ]
    then
        echo "ALERT"
    else
        echo "Time:" $TIME "ms"
    fi
    sleep $WAIT
done
