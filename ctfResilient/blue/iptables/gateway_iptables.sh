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

# Hashlimit to drop TCP traffic from source IP after it sends 5 packets per second
# Logs are in /var/log/kern.conf
sudo iptables --new-chain TCP-LIMIT
sudo iptables -A FORWARD -i $ROUTER_ETH -o $SERVER_ETH -p tcp -d 10.1.5.2 -s 10.1.2.2,10.1.3.2,10.1.4.2,10.1.1.2 --dport 80 -m conntrack --ctstate NEW  -m tcpmss --mss 1460 -j TCP-LIMIT
#sudo iptables -A FORWARD -i $ROUTER_ETH -o $SERVER_ETH -p tcp -d 10.1.5.2 -s 10.1.2.2,10.1.3.2,10.1.4.2,10.1.1.2 --dport 80 -m conntrack --ctstate NEW  -m tcpmss --mss 1460 --sack-perm --timestamp --wscale 7 -j TCP-LIMIT
sudo iptables -A FORWARD -i $ROUTER_ETH -o $SERVER_ETH -p tcp -d 10.1.5.2 -s 10.1.2.2,10.1.3.2,10.1.4.2,10.1.1.2 --dport 80 -m conntrack --ctstate ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i $SERVER_ETH -o $ROUTER_ETH -p tcp -s 10.1.5.2 -d 10.1.2.2,10.1.3.2,10.1.4.2,10.1.1.2 --sport 80 -m conntrack --ctstate ESTABLISHED -j ACCEPT
sudo iptables -A TCP-LIMIT --match hashlimit --hashlimit-mode srcip --hashlimit-upto 5/sec --hashlimit-burst 20 --hashlimit-name tcp_rate_limit -j ACCEPT
sudo iptables -A TCP-LIMIT  -m limit --limit 3/min -j LOG --log-prefix "DROPPED TCP IP-Tables connections: "
sudo iptables -A TCP-LIMIT -j DROP

# Drop policy default
sudo iptables -P INPUT DROP
sudo iptables -P FORWARD DROP
sudo iptables -P OUTPUT DROP

#sudo iptables -I FORWARD 1 -i eth2 -o eth1 -p tcp -d 10.1.5.2 -s 10.1.2.2, 10.1.3.2, 10.1.4.2 --dport 80 -m conntrack --ctstate NEW -j TCP-LIMIT
#sudo iptables -I FORWARD 2 -i eth2 -o eth1 -p tcp -d 10.1.5.2 -s 10.1.2.2, 10.1.3.2, 10.1.4.2 --dport 80 -m conntrack --ctstate ESTABLISHED -j ACCEPT

#sudo iptables -A TCP-LIMIT 1 --match hashlimit --hashlimit-mode srcip --hashlimit-upto 3/sec --hashlimit-burst 60 --hashlimit-name tcp_rate_limit -j ACCEPT

#sudo iptables -I FORWARD 4 -i eth2 -o eth1 -p tcp -d 10.1.5.2 -s 10.1.1.2 --dport 80 -m conntrack --ctstate NEW,ESTABLISHED -j TCP-LIMIT


#iptables -I FORWARD -i eth2 -o eth1 -p tcp -d 10.1.5.2 -s 10.1.2.2, 10.1.3.2, 10.1.4.2 --dport 80 -m connlimit --connlimit-above 10 --connlimit-mask 20 -j DROP
#iptables -I PREROUTING 1 -i eth1 -o eth2 -p tcp --tcp-flags ALL SYN,ACK --dport 80 -m connlimit --connlimit-above 10 --connlimit-mask 20 -j DROP

