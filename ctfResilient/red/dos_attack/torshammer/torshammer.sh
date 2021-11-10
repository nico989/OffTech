#!/bin/bash

if [ $# -ge 1 ]
then
    if [ "$1" ]
    then
        echo "START TORSHAMMER"
        sudo python torshammer.py -t 10.1.5.2 -r $1 > /dev/null
    fi
else
    echo "YOU NEED TO SPECIFY THREADS"
fi