#!/bin/bash

FILE=$1

# Start gathering data on Client
echo "Start tcpdump on Client"
ssh client.vinci-dos.offtech "bash -s" -- < ../sniffer/sniff.sh "$FILE" &>/dev/null &

# Start legitimate traffic
echo "Start legitimate traffic"
ssh client.vinci-dos.offtech "bash -s" -- < leg_traffic.sh &>/dev/null &

# Wait 30 seconds
echo "Wait 30 seconds"
sleep 30

# Start attack
echo "Start attack"
ssh attacker.vinci-dos.offtech "bash -s" -- < attack.sh &>/dev/null &
