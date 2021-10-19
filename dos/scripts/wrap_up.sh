#!/bin/sh

# Set up Server and Attacker
echo "Start Set up"
echo "-------------------------------------------------------------------"
./config/setup.sh

# Disable SYN Cookies
echo "Disable SYN Cookies"
ssh server.vinci-dos.offtech "./config/syn_cookies.sh disable"

# Collect data
./traffic/collect_data.sh

# Enable SYN Cookies
echo "Enable SYN Cookies"
ssh server.vinci-dos.offtech "./config/syn_cookies.sh enable"

# Collect data
./traffic/collect_data.sh
