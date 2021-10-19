#!/bin/sh

# File
FILE=$1

# Enable or disable SYN Cookies
STATE=$2

# SYN Cookies
echo "$STATE SYN Cookies"
ssh server.vinci-dos.offtech "sudo ./scripts/config/syn_cookies.sh $STATE"

# Discover Client eth
ETH=$(ssh client.vinci-dos.offtech "sudo ip route get 5.6.7.8" | awk -F " " '{print $5;}')

# Start gathering data on Client
echo "Start tcpdump on Client" &
ssh client.vinci-dos.offtech "sudo ./scripts/sniffer/sniff.sh $FILE $ETH" &> /dev/null &

# Start legitimate traffic
echo "Start legitimate traffic"
ssh client.vinci-dos.offtech "sudo ./scripts/traffic/leg_traffic.sh" &> /dev/null &

# Wait 30 seconds
echo "Wait 30 seconds"
sleep 30

# Start attack
echo "Start attack"
ssh attacker.vinci-dos.offtech "sudo ./scripts/traffic/attack.sh" &> /dev/null &

# Wait end
echo "Wait end"
sleep 150
