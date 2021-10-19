#!/bin/bash

STATE=$1
if [[ -z $STATE ]]
then

    echo "Insert 1 or 0"
    exit 1

else

    # Turn on or off SYN cookies
    ssh server.vinci-dos.offtech "sudo sysctl -w net.ipv4.tcp_syncookies= $1 && sudo sysctl -w net.ipv4.tcp_max_syn_backlog=10000"

fi
