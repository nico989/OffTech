#!/bin/bash

gateway_interface=$(ip a | grep 10.1.5.2 | cut -d ' ' -f 11)
deterlab_interface=$(ip a | grep 192.168 | cut -d ' ' -f 11)

# Clear iptables
sudo iptables -F

# Allow ssh connections 
sudo iptables -A INPUT -i $deterlab_interface -j ACCEPT
sudo iptables -A OUTPUT -o $deterlab_interface -j ACCEPT

# Allow loopback traffic
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A OUTPUT -o lo -j ACCEPT

# Allow traffic from/to server
sudo iptables -A INPUT -s 10.1.5.3 -j ACCEPT
sudo iptables -A OUTPUT -d 10.1.5.3 -j ACCEPT

# Block fragmented packet
sudo iptables -t mangle -A PREROUTING -f -j DROP

# Hashlimit to drop TCP traffic from source IP after it sends 5 packets per second
# Logs are in /var/log/kern.conf
sudo iptables --new-chain TCP-LIMIT
sudo iptables -A INPUT -i $gateway_interface -p tcp --dport 80 -s 10.1.2.2,10.1.3.2,10.1.4.2 --dport 80-m conntrack --ctstate NEW  -m tcpmss --mss 1460 -j TCP-LIMIT
sudo iptables -A INPUT -i $gateway_interface -p tcp --dport 80 -s 10.1.2.2,10.1.3.2,10.1.4.2 --dport 80 -m conntrack --ctstate ESTABLISHED -j ACCEPT
sudo iptables -A OUTPUT -p tcp -d 10.1.2.2,10.1.3.2,10.1.4.2 --sport 80 -m conntrack --ctstate ESTABLISHED -j ACCEPT
sudo iptables -A TCP-LIMIT --match hashlimit --hashlimit-mode srcip --hashlimit-upto 5/sec --hashlimit-burst 20 --hashlimit-name tcp_rate_limit -j ACCEPT
sudo iptables -A TCP-LIMIT  -m limit --limit 3/min -j LOG --log-prefix "DROPPED TCP IP-Tables connections: "
sudo iptables -A TCP-LIMIT -j DROP
 
# Drop policy default
sudo iptables -P INPUT DROP
sudo iptables -P FORWARD DROP
sudo iptables -P OUTPUT DROP
