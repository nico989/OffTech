#!/bin/bash

FILE=$1
ETH=$2

# Gather traffic
TIMEOUT=180
timeout $TIMEOUT tcpdump -nn -i $ETH -w $FILE tcp port 80 2> /dev/null
