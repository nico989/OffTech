#!/bin/sh

# Set up Server and Attacker
echo "Start Set up"
echo "-------------------------------------------------------------------"
./config/setup.sh

# Disable SYN Cookies
echo "Disable SYN Cookies"
ssh server.vinci-dos.offtech "./config/syn_cookies.sh disable"

# Start gathering data on Client
ssh client.vinci-dos.offtech "./sniffer/sniff.sh traffic_no_syn_cookies"

# Start legitimate traffic
ssh client.vinci-dos.offtech "./traffic/leg_traffic.sh"

# Wait 30 seconds
echo "Wait 30 seconds"
sleep 30

# Start attack
ssh attacker.vinci-dos.offtech "./traffic/attack.sh"

# Enable SYN Cookies
echo "Enable SYN Cookies"
ssh server.vinci-dos.offtech "./config/syn_cookies.sh enable"

# Start gathering data on Client
ssh client.vinci-dos.offtech "./sniffer/sniff.sh traffic_yes_syn_cookies"

# Start legitimate traffic
ssh client.vinci-dos.offtech "./traffic/leg_traffic.sh"

# Wait 30 seconds
echo "Wait 30 seconds"
sleep 30

# Start attack
ssh attacker.vinci-dos.offtech "./traffic/attack.sh"
