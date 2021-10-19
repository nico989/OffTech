#!/bin/bash

# Set up Server and Attacker
echo "Start Set up"
echo "-------------------------------------------------------------------"
./config/setup.sh

# Disable SYN Cookies
echo "Disable SYN Cookies"
./config/syn_cookies.sh 0

# Start gathering data on Client
echo "Start tcpdump on Client"
ssh client.vinci-dos.offtech "sudo -c ./sniffer/sniff.sh traffic_no_syn_cookies"

# Start legitimate traffic
echo "Start legitimate traffic"
ssh client.vinci-dos.offtech "sudo -c ./traffic/leg_traffic.sh"

# Wait 30 seconds
echo "Wait 30 seconds"
sleep 30

# Start attack
echo "Start attack"
ssh attacker.vinci-dos.offtech "sudo -c ./traffic/attack.sh"

# Disable SYN Cookies
echo "Enable SYN Cookies"
./config/syn_cookies.sh 1

# Start gathering data on Client
echo "Start tcpdump on Client"
ssh client.vinci-dos.offtech "sudo -c ./sniffer/sniff.sh traffic_yes_syn_cookies"

# Start legitimate traffic
echo "Start legitimate traffic"
ssh client.vinci-dos.offtech "sudo -c ./traffic/leg_traffic.sh"

# Wait 30 seconds
echo "Wait 30 seconds"
sleep 30

# Start attack
echo "Start attack"
ssh attacker.vinci-dos.offtech "sudo -c ./traffic/attack.sh"
