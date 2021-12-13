#!/bin/bash

if [[ $EUID -ne 0 ]]
then
	echo "This script must be run as root"
	exit 1
fi

if [[ $# -eq 1 ]]
then
    # Start monitoring
    echo "START DATABASE MONITORING"
    while true
    do
        python3 db_monitor.py
        sleep $1
    done
else
	echo "Usage: ./start_db_monitor.sh <sleeptime>"
	exit 1
fi
