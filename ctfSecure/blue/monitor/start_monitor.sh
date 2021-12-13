#!/bin/bash

if [[ $EUID -ne 0 ]]
then
	echo "This script must be run as root"
	exit 1
fi

USAGE="Usage: ./start_monitor.sh <server,gateway>"

if [[ $# -eq 1 ]]
then
	if [[ "$1" == "server" ]]
	then
		# Get server interface
		ETH=$(ip addr | grep 10.1.5.2 | cut -d " " -f 11)
	elif [[ "$1" == "gateway" ]]
	then
		# Get gateway interface
		ETH=$(ip addr | grep 10.1.1.3 | cut -d " " -f 11)
	else
		echo "Wrong machine selected!"
		echo $USAGE
		exit 1
	fi
else
	echo $USAGE
	exit 1
fi

# Start monitoring
echo "START LISTENING ON $ETH"
python3 server_monitor.py -i $ETH --show-raw
