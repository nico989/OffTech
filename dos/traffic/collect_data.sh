#!/bin/bash

# Start gathering data on Client
ssh client.vinci-dos.offtech "./sniffer/sniff.sh traffic_no_syn_cookies"

# Start legitimate traffic
ssh client.vinci-dos.offtech "./traffic/leg_traffic.sh"

# Wait 30 seconds
echo "Wait 30 seconds"
sleep 30

# Start attack
ssh attacker.vinci-dos.offtech "./traffic/attack.sh"
