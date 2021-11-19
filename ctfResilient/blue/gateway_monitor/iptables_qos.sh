#!/bin/bash

WAIT=$1

if [ $# == 1 ]
then
    echo "---------START IPTABLES QOS---------"

    while true
    do
        NEWCLIENT1=$(sudo iptables -L -v | grep NEW | sed -n '1p' | head -c 5)
        NEWCLIENT2=$(sudo iptables -L -v | grep NEW | sed -n '2p' | head -c 5)
        NEWCLIENT3=$(sudo iptables -L -v | grep NEW | sed -n '3p' | head -c 5)
        ESTCLIENT1=$(sudo iptables -L -v | grep ESTABLISHED | sed -n '1p' | head -c 5)
        ESTCLIENT2=$(sudo iptables -L -v | grep ESTABLISHED | sed -n '2p' | head -c 5)
        ESTCLIENT3=$(sudo iptables -L -v | grep ESTABLISHED | sed -n '3p' | head -c 5)
        DEFAULTDROP=$(sudo iptables -L -v | grep DROP | sed -n '2p' | cut -d " " -f 5)
        MYDROP=$(sudo iptables -L -v | grep DROP | sed -n '10p' | head -c 5)
        printf "\n[packets] CLIENT 1: {NEW=$NEWCLIENT1, ESTABLISHED=$ESTCLIENT1}\n[packets] CLIENT 2: {NEW=$NEWCLIENT2, ESTABLISHED=$ESTCLIENT2}\n[packets] CLIENT 3: {NEW=$NEWCLIENT3, ESTABLISHED=$ESTCLIENT3}\n[packets] DROPPED:  {DEFAULT=$DEFAULTDROP, CUSTOM=$MYDROP}\n"
        printf "\n[packets] CLIENT 1: {NEW=$NEWCLIENT1, ESTABLISHED=$ESTCLIENT1}\n[packets] CLIENT 2: {NEW=$NEWCLIENT2, ESTABLISHED=$ESTCLIENT2}\n[packets] CLIENT 3: {NEW=$NEWCLIENT3, ESTABLISHED=$ESTCLIENT3}\n[packets] DROPPED:  {DEFAULT=$DEFAULTDROP, CUSTOM=$MYDROP}\n" >> log_iptables_qos.txt
        echo $v
        sleep $WAIT
    done
else
    echo "Usage: ./iptables_qos.sh <SLEEP TIME>"
fi
