#!/bin/sh

# ICMP scan
sudo nmap -sn -PE 5.6.7.0/24

# ACK scan
sudo nmap -sn -PA 5.6.7.0/24

# Multiple probes
# Sends ICMP request, TCP SYN packet to 443, TCP ACK packet to 80, ICMP timestamp query
# 5.6.7.8 responds with TCP RST from port 80
sudo nmap -sn 5.6.7.0/24

# TCP half open scan (scan 1000 common ports)
sudo nmap -sS 5.6.7.8
# TCP half open scan (scan first 1500 ports)
# Found 1212 open port
sudo nmap -sS -p1-1500 5.6.7.8

# Xmas scan (set FIN, PSH, URG flags)
sudo nmap -sX -T4 5.6.7.8

# ACK scan
# Firewall type: stateless or stateful?
sudo nmap -sA -T4 5.6.7.8

# OS and services detection
sudo nmap -A -T4 5.6.7.8
