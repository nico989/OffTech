#!/bin/sh

# Set up Server and Attacker
echo "Start Set up"
echo "-------------------------------------------------------------------"
./config/setup.sh
echo "-------------------------------------------------------------------"

# Disable SYN Cookies
echo "Disable SYN Cookies"
ssh server.vinci-dos.offtech "sudo ./scripts/config/syn_cookies.sh disable"

# Collect data
./collect_data.sh traffic_no_syn_cookies.pcap

# Enable SYN Cookies
echo "Enable SYN Cookies"
ssh server.vinci-dos.offtech "sudo ./scripts/config/syn_cookies.sh disable"

# Collect data
./collect_data.sh traffic_yes_syn_cookies.pcap
