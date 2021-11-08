#!/bin/bash

ETH=$1
HOST=$2
HTTP=$3

if [[ $HTTP == "http" ]]
then

    # Run tcpdump http filter
    sudo tcpdump -i $ETH -n -e dst $HOST -w $HOST.pcap tcp port 80

elif [[ $HTTP == "nohttp" ]]
then

    # Run tcpdump
    sudo tcpdump -i $ETH -n -e dst $HOST -w $HOST.pcap

else

    echo "Not valid input"
    exit 1

fi
