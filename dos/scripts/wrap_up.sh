#!/bin/sh

# Set up Server and Attacker
echo "Start Set up"
echo "-------------------------------------------------------------------"
./config/setup.sh &>/dev/null

# Disable SYN Cookies
echo "Disable SYN Cookies"
ssh server.vinci-dos.offtech "bash -s" -- < config/syn_cookies.sh "disable"

# Collect data
./traffic/collect_data.sh traffic_no_syn_cookies.pcap

# Enable SYN Cookies
echo "Enable SYN Cookies"
ssh server.vinci-dos.offtech "bash -s" -- < config/syn_cookies.sh "enable"

# Collect data
./traffic/collect_data.sh traffic_yes_syn_cookies.pcap
