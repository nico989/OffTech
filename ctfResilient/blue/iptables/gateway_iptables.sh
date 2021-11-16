#!/bin/bash

ROUTER_ETH=$(ip add | grep 10.1.1.3 | cut -d ' ' -f 11)
SERVER_ETH=$(ip add | grep 10.1.5.3 | cut -d ' ' -f 11)
DETER_ETH=$(ip add | grep 192.168 | cut -d ' ' -f 11)

# Clear iptables
sudo iptables -F

# Allow ssh connections 
sudo iptables -A INPUT -i $DETER_ETH -j ACCEPT
sudo iptables -A OUTPUT -o $DETER_ETH -j ACCEPT

# Allow loopback traffic
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A OUTPUT -o lo -j ACCEPT

# Allow traffic from/to server
sudo iptables -A OUTPUT -d 10.1.5.2 -j ACCEPT 
sudo iptables -A INPUT -s 10.1.5.2 -j ACCEPT

# Allow traffic from/to router
sudo iptables -A INPUT -s 10.1.1.2 -j ACCEPT
sudo iptables -A OUTPUT -d 10.1.1.2 -j ACCEPT

# Hashlimit to drop TCP traffic from source IP after it sends 5 packets per second
# Logs are in /var/log/kern.conf
sudo iptables --new-chain TCP-LIMIT
sudo iptables -A FORWARD -i $ROUTER_ETH -o $SERVER_ETH -p tcp -d 10.1.5.2 -s 10.1.2.2,10.1.3.2,10.1.4.2 --dport 80 --tcp-flags ALL SYN -m conntrack --ctstate NEW  -j TCP-LIMIT
sudo iptables -A FORWARD -i $ROUTER_ETH -o $SERVER_ETH -p tcp -d 10.1.5.2 -s 10.1.2.2,10.1.3.2,10.1.4.2 --dport 80 -m conntrack --ctstate ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i $SERVER_ETH -o $ROUTER_ETH -p tcp -s 10.1.5.2 -d 10.1.2.2,10.1.3.2,10.1.4.2 --sport 80 -m conntrack --ctstate ESTABLISHED -j ACCEPT

# Check tcp options: mss, sack, TS/ecr, nop, wscale
sudo iptables -A TCP-LIMIT -p tcp ! --tcp-option 2 -m tcpmss ! --mss 1460 -j DROP
sudo iptables -A TCP-LIMIT -p tcp ! --tcp-option 4 -j DROP
sudo iptables -A TCP-LIMIT -p tcp ! --tcp-option 8 -j DROP
sudo iptables -A TCP-LIMIT -p tcp ! --tcp-option 1 -j DROP
sudo iptables -A TCP-LIMIT -p tcp ! --tcp-option 3 -j DROP

sudo iptables -A TCP-LIMIT --match hashlimit --hashlimit-mode srcip --hashlimit-upto 5/sec --hashlimit-burst 20 --hashlimit-name tcp_rate_limit -j ACCEPT
sudo iptables -A TCP-LIMIT  -m limit --limit 3/min -j LOG --log-prefix "DROPPED TCP IP-Tables connections: "
sudo iptables -A TCP-LIMIT -j DROP

# Drop policy default
sudo iptables -P INPUT DROP
sudo iptables -P FORWARD DROP
sudo iptables -P OUTPUT DROP
