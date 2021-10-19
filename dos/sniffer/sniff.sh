#!/bin/bash

FILE=$1

# Discover eth
ROUTE=$(ip route get 5.6.7.8)
ETH=$(echo $ROUTE | awk -F " " '{print $5;}')

# Gather traffic
TIMEOUT=185
timeout $TIMEOUT tcpdump -nn -s 0 -i $ETH -w $FILE port 80
