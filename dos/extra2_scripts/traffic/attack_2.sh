#!/bin/bash

# Source Ip
SOURCE=$1

# Destination Ip
DEST=$1

# Timeout
TIMEOUT=120

timeout $TIMEOUT flooder --dst $DEST --highrate 200 --proto 6 --dportmin 80 --dportmax 80 --src $SOURCE --srcmask 255.255.255.255
