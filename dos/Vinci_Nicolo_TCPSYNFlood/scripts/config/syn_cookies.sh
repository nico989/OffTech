#!/bin/bash

STATE=$1
if [[ $STATE == "enable" ]]
then

    # Turn on SYN cookies
    sysctl -w net.ipv4.tcp_syncookies=1
    sysctl -w net.ipv4.tcp_max_syn_backlog=128

elif [[ $STATE == "disable" ]]
then

    # Turn off SYN cookies
    sysctl -w net.ipv4.tcp_syncookies=0
    sysctl -w net.ipv4.tcp_max_syn_backlog=10000

else

    echo "Not valid input"
    exit 1

fi
