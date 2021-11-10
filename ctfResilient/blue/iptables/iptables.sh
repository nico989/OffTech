#!/bin/bash

# Clear iptables
sudo iptables -F

# Drop policy default
sudo iptables -P INPUT DROP
sudo iptables -P FORWARD DROP
sudo iptables -P OUTPUT DROP

# Accept loopback traffic (interface lo)
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A OUTPUT -o lo -j 

# Block incoming SYN 
sudo iptables -A PREROUTING -p tcp ! --syn -m conntrack --ctstate NEW -j DROP

# Block fragment packets
sudo iptables -A PREROUTING -f -j DROP

# Drop TCP packet
sudo iptables -A PREROUTING -p tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG NONE -j DROP
sudo iptables -A PREROUTING -p tcp --tcp-flags FIN,SYN FIN,SYN -j DROP
sudo iptables -A PREROUTING -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
sudo iptables -A PREROUTING -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP
sudo iptables -A PREROUTING -p tcp --tcp-flags FIN,RST FIN,RST -j DROP
sudo iptables -A PREROUTING -p tcp --tcp-flags FIN,ACK FIN -j DROP
sudo iptables -A PREROUTING -p tcp --tcp-flags ACK,URG URG -j DROP
sudo iptables -A PREROUTING -p tcp --tcp-flags ACK,FIN FIN -j DROP
sudo iptables -A PREROUTING -p tcp --tcp-flags ACK,PSH PSH -j DROP
sudo iptables -A PREROUTING -p tcp --tcp-flags ALL ALL -j DROP
sudo iptables -A PREROUTING -p tcp --tcp-flags ALL NONE -j DROP
sudo iptables -A PREROUTING -p tcp --tcp-flags ALL FIN,PSH,URG -j DROP
sudo iptables -A PREROUTING -p tcp --tcp-flags ALL SYN,FIN,PSH,URG -j DROP
sudo iptables -A PREROUTING -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j DROP

# Allow SSH
sudo iptables -A INPUT -p tcp -m tcp -s 10.1.0.0/16 --dport 22 -m conntrack --ctstate NEW -j DROP
sudo iptables -A INPUT -p tcp -m tcp --dport 22 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
sudo iptables -A OUTPUT -p tcp -m tcp --sport 22 -m conntrack --ctstate ESTABLISHED -j ACCEPT

# Restrict the number of connections (to 20) per single IP address
sudo iptables -A FORWARD -i ETH_TO_ROUTER -o ETH_TO_SERVER -p tcp --syn --dport 80 -m connlimit --connlimit-above 20 --connlimit-mask 32 -j DROP
##--reject-with tcp-reset

# Limit NEW TCP connections per seconds
sudo iptables -A INPUT -p tcp -m conntrack --ctstate NEW -m limit --limit 60/s --limit-burst 20 -j ACCEPT

# Drop excessive RST packets to avoid smurf attacks
sudo iptables -A INPUT -p tcp -m tcp --tcp-flags RST RST -m limit --limit 2/second --limit-burst 2 -j ACCEPT

# Restrict input - only the client1 with tcp can pass
sudo iptables -A FORWARD -s 10.1.2.2 -j ACCEPT
sudo iptables -A FORWARD -s 10.1.3.2 -j ACCEPT
sudo iptables -A FORWARD -s 10.1.4.2 -j ACCEPT
sudo iptables -A FORWARD -d 10.1.2.2 -j ACCEPT
sudo iptables -A FORWARD -d 10.1.3.2 -j ACCEPT
sudo iptables -A FORWARD -d 10.1.4.2 -j ACCEPT

# Allow outbound DHCP request
sudo iptables -A OUTPUT -p udp --dport 67:68 --sport 67:68 -j ACCEPT

# Outbound HTTP only on port 80
sudo iptables -A OUTPUT -p tcp -m tcp --dport 80 -m conntrack --ctstate NEW -j ACCEPT

# Drop any ACK with connection not established

