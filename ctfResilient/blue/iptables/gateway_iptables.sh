#!/bin/bash

ROUTER_ETH=$(ip add | grep 10.1.1.3 | cut -d ' ' -f 11)
SERVER_ETH=$(ip add | grep 10.1.5.3 | cut -d ' ' -f 11)
DETER_ETH=$(ip add | grep 192.168 | cut -d ' ' -f 11)

# Clear iptables
sudo iptables -F

# Drop policy default
sudo iptables -P INPUT DROP
sudo iptables -P FORWARD DROP
sudo iptables -P OUTPUT DROP

# Allow loopback traffic
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A OUTPUT -o lo -j ACCEPT

# Allow traffic from/to server
sudo iptables -A OUTPUT -d 10.1.5.2 -j ACCEPT 
sudo iptables -A INPUT -s 10.1.5.2 -j ACCEPT

# Allow ssh connections 
sudo iptables -A INPUT -i $DETER_ETH -j ACCEPT
sudo iptables -A OUTPUT -o $DETER_ETH -j ACCEPT

# Hashlimit to drop TCP traffic from source IP after it sends 5 packets per second
# Logs are in /var/log/kern.conf
sudo iptables --new-chain TCP-LIMIT
sudo iptables -A FORWARD -i $ROUTER_ETH -o $SERVER_ETH -p tcp -d 10.1.5.2 --dport 80 -m conntrack --ctstate NEW -j RATE-LIMIT
sudo iptables -A FORWARD -i $ROUTER_ETH -o $SERVER_ETH -p tcp -d 10.1.5.2 --dport 80 -m conntrack --ctstate ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i $SERVER_ETH -o $ROUTER_ETH -p tcp -s 10.1.5.2 --sport 80 -m conntrack --ctstate ESTABLISHED -j ACCEPT
sudo iptables -A RATE-LIMIT --match hashlimit --hashlimit-mode srcip --hashlimit-upto 10/sec --hashlimit-burst 30 --hashlimit-name tcp_rate_limit -j ACCEPT
sudo iptables -A RATE-LIMIT  -m limit --limit 3/min -j LOG --log-prefix "DROPPED TCP IP-Tables connections: "
sudo iptables -A RATE-LIMIT -j DROP
