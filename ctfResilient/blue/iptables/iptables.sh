#!/bin/bash

# TCP chain (log in/var/log/kern.log)
sudo iptables --new-chain TCP_CHAIN
sudo iptables -A FORWARD -i $ROUTER_ETH -o $SERVER_ETH -p tcp -d 10.1.5.2 --dport 80  -j TCP_CHAIN
sudo iptables -A TCP_CHAIN  -m limit --limit 2/min -j LOG --log-prefix "TCP TRAFFIC-Dropped: " --log-level 4 
sudo iptables -A TCP_CHAIN -p tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG NONE -j DROP
sudo iptables -A TCP_CHAIN -p tcp --tcp-flags FIN,SYN FIN,SYN -j DROP
sudo iptables -A TCP_CHAIN -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
sudo iptables -A TCP_CHAIN -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP
sudo iptables -A TCP_CHAIN -p tcp --tcp-flags FIN,RST FIN,RST -j DROP
sudo iptables -A TCP_CHAIN -p tcp --tcp-flags FIN,ACK FIN -j DROP
sudo iptables -A TCP_CHAIN -p tcp --tcp-flags ACK,URG URG -j DROP
sudo iptables -A TCP_CHAIN -p tcp --tcp-flags ACK,FIN FIN -j DROP
sudo iptables -A TCP_CHAIN -p tcp --tcp-flags ACK,PSH PSH -j DROP
sudo iptables -A TCP_CHAIN -p tcp --tcp-flags ALL ALL -j DROP
sudo iptables -A TCP_CHAIN -p tcp --tcp-flags ALL NONE -j DROP
sudo iptables -A TCP_CHAIN -p tcp --tcp-flags ALL FIN,PSH,URG -j DROP
sudo iptables -A TCP_CHAIN -p tcp --tcp-flags ALL SYN,FIN,PSH,URG -j DROP
sudo iptables -A TCP_CHAIN -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j DROP
sudo iptables -A TCP_CHAIN -p tcp --tcp-flags ACK ACK -m conntrack --ctstate NEW,RELATED,INVALID -j DROP
sudo iptables -A FORWARD -i $ROUTER_ETH -o $SERVER_ETH -p tcp -d 10.1.5.2 --dport 80  -j ACCEPT

# ICMP
#sudo iptables -A INPUT -i $ROUTER_ETH -p icmp -m hashlimit --hashlimit-name icmp --hashlimit-mode srcip --hashlimit 100/second --hashlimit-burst 5 -j ACCEPT
#sudo iptables -A OUTPUT -p icmp --icmp-type echo-reply -j ACCEPT
#sudo iptables -A FORWARD -i $ROUTER_ETH -o $SERVER_ETH -p icmp -m hashlimit --hashlimit-name icmp --hashlimit-mode srcip --hashlimit 3/second --hashlimit-burst 5 -j ACCEPT
#sudo iptables -A FORWARD -i $SERVER_ETH -o $ROUTER_ETH -p icmp --icmp-type echo-reply -j ACCEPT

#iptables -I FORWARD -i eth2 -o eth1 -p tcp -d 10.1.5.2 -s 10.1.2.2, 10.1.3.2, 10.1.4.2 --dport 80 -m connlimit --connlimit-above 10 --connlimit-mask 20 -j DROP
#iptables -I PREROUTING 1 -i eth1 -o eth2 -p tcp --tcp-flags ALL SYN,ACK --dport 80 -m connlimit --connlimit-above 10 --connlimit-mask 20 -j DROP

# Save Iptables
# iptables-save -c

# Live block incoming RST
# sudo iptables -I FORWARD 1 -i $ROUTER_ETH -o $SERVER_ETH -p tcp -d 10.1.5.2 -s 10.1.2.2,10.1.3.2,10.1.4.2 --dport 80 --tcp-flags RST RST -j DROP
# sudo iptables -I FORWARD 1 -i $ROUTER_ETH -o $SERVER_ETH -p tcp -d 10.1.5.2 -s 10.1.2.2,10.1.3.2,10.1.4.2 --dport 80 --tcp-flags RST RST -m limit --limit 2/second --limit-burst 2 -j ACCEPT

# Drop by string
# sudo iptables -A FORWARD -i $ROUTER_ETH -o $SERVER_ETH -s 10.1.2.2 -d 10.1.5.2 --dport 80 -p tcp -m string --string "GET /?" --algo bm -j DROP

# Check open sockets
# ss -ta
# ss -ita
# ss -K dst IP dst dport = port # only established
# netstat -altupn
# ss -n state syn-recv sport = :80 | wc -l # check syn_recv sockets
# check for half-open connections
# ss -n state time-wait | wc -l
# ss -n state established | wc -l

# Live limit connection
# sudo iptables -I FORWARD 1 -i $ROUTER_ETH -o $SERVER_ETH -p tcp -d 10.1.5.2 -s 10.1.2.2,10.1.3.2,10.1.4.2 --dport 80 -m connlimit --connlimit-above 10 --connlimit-mask 32 -j DROP
# sudo iptables -I FORWARD 1 -i $ROUTER_ETH -o $SERVER_ETH -p tcp -d 10.1.5.2 -s 10.1.2.2,10.1.3.2,10.1.4.2 --dport 80 -m connlimit --connlimit-upto 10 --connlimit-mask 32 -j ACCEPT

# Live drop connection by time 
# sudo iptables -I FORWARD 1 -i $ROUTER_ETH -o $SERVER_ETH -p tcp -d 10.1.5.2 -s 10.1.2.2,10.1.3.2,10.1.4.2 --dport 80 -m time --timestart HH:MM --timestop HH:MM -j DROP
# sudo iptables -I FORWARD 1 -i $ROUTER_ETH -o $SERVER_ETH -p tcp -d 10.1.5.2 -s 10.1.2.2,10.1.3.2,10.1.4.2 --dport 80 -m time --datestart YYYY-MM-DDThh:mm:ss --datestop YYYY-MM-DDThh:mm:ss -j DROP
