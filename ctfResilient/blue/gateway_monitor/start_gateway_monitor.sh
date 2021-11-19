#!/bin/bash

# this scripts starts the monitoring of the machine
# it listens to port 80 for HTTP request and prints them
# along with the total number of packets and bytes received
# NOTE: it must be run as root

# check if root privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# get used interface
ETH=$(ip addr | grep 10.1.1.3 | cut -d " " -f 11)

# start monitoring
python3 gateway_monitor.py -i $ETH --show-raw
