#!/bin/sh

# Enable or disable SYN Cookies
STATE=$1

# Source IP
SOURCE=$2

# Dest IP
DEST=$3

# Spoof
SPOOF=$4

# SYN Cookies
echo "$STATE SYN Cookies"
ssh server.vinci-dos.offtech "sudo ./extra2_scripts/config/syn_cookies.sh $STATE"

# Discover Client eth
ETHC=$(ssh client.vinci-dos.offtech "sudo ip route" | grep 11.12.13.2 | awk -F " " '{print $3;}')

# Discover Attacker eth
ETHA=$(ssh attacker.vinci-dos.offtech "sudo ip route" | grep 22.23.24.2 | awk -F " " '{print $3;}')

# Discover Server-Client eth
ETHSC=$(ssh server.vinci-dos.offtech "sudo ip route" | grep 11.12.13.1 | awk -F " " '{print $3;}')

# Discover Server-Attacker eth
ETHSA=$(ssh server.vinci-dos.offtech "sudo ip route" | grep 22.23.24.1 | awk -F " " '{print $3;}')

# Start gathering data on Client
echo "Start tcpdump on Client towards Server" 
ssh client.vinci-dos.offtech "sudo ./extra2_scripts/sniffer/sniff.sh client.pcap $ETHC" &> /dev/null 

# Start gathering data on Attacker
echo "Start tcpdump on Attacker towards Server" 
ssh attacker.vinci-dos.offtech "sudo ./extra2_scripts/sniffer/sniff.sh attacker.pcap $ETHA" &> /dev/null 

# Start gathering data on Server-Client
echo "Start tcpdump on Server towards Client" 
ssh server.vinci-dos.offtech "sudo ./extra2_scripts/sniffer/sniff.sh server_client.pcap $ETHSC" &> /dev/null 

# Start gathering data on Server-Attacker
echo "Start tcpdump on Server towards Attacker" 
ssh server.vinci-dos.offtech "sudo ./extra2_scripts/sniffer/sniff.sh server_attacker.pcap $ETHSA" &> /dev/null 

# Start legitimate traffic
echo "Start legitimate traffic"
ssh client.vinci-dos.offtech "sudo timeout 180 ./extra2_scripts/traffic/leg_traffic.sh" &> /dev/null 

# Wait 30 seconds
echo "Wait 30 seconds"
sleep 30

# Start attack
echo "Start attack"
ssh attacker.vinci-dos.offtech "sudo ./extra2_scripts/traffic/attack_2.sh $SOURCE $DEST $SPOOF" &> /dev/null 

# Wait end
echo "Wait end"
sleep 150
