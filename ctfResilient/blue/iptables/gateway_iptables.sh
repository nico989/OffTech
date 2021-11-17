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
sudo iptables -A FORWARD -i $ROUTER_ETH -o $SERVER_ETH -d 10.1.5.2 -s 10.1.1.2 -j ACCEPT
sudo iptables -A FORWARD -i $SERVER_ETH -o $ROUTER_ETH -s 10.1.5.2 -d 10.1.1.2 -j ACCEPT

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

# Rate limiter
sudo iptables -A TCP-LIMIT --match hashlimit --hashlimit-mode srcip --hashlimit-upto 5/sec --hashlimit-burst 20 --hashlimit-name tcp_rate_limit -j ACCEPT
sudo iptables -A TCP-LIMIT  -m limit --limit 3/min -j LOG --log-prefix "DROPPED TCP IP-Tables connections: "
sudo iptables -A TCP-LIMIT -j DROP

# Drop policy default
sudo iptables -P INPUT DROP
sudo iptables -P FORWARD DROP
sudo iptables -P OUTPUT DROP


02:06:41.837905 IP 10.1.2.2.57176 > 10.1.5.2.80: Flags [S], seq 2432753229, win 64240, options [mss 1460,sackOK,TS val 2751115967 ecr 0,nop,wscale 7], length 0
02:06:41.837963 IP 10.1.5.2.80 > 10.1.2.2.57176: Flags [S.], seq 1416320643, ack 2432753230, win 65160, options [mss 1460,sackOK,TS val 1790118987 ecr 2751115967,nop,wscale 7], length 0
02:06:41.838656 IP 10.1.2.2.57176 > 10.1.5.2.80: Flags [.], ack 1, win 502, options [nop,nop,TS val 2751115967 ecr 1790118987], length 0
02:06:41.838906 IP 10.1.2.2.57176 > 10.1.5.2.80: Flags [P.], seq 1:73, ack 1, win 502, options [nop,nop,TS val 2751115968 ecr 1790118987], length 72: HTTP: GET / HTTP/1.1
02:06:41.838966 IP 10.1.5.2.80 > 10.1.2.2.57176: Flags [.], ack 73, win 509, options [nop,nop,TS val 1790118988 ecr 2751115968], length 0
02:06:41.840050 IP 10.1.5.2.80 > 10.1.2.2.57176: Flags [.], seq 1:7241, ack 73, win 509, options [nop,nop,TS val 1790118990 ecr 2751115968], length 7240: HTTP: HTTP/1.1 200 OK
02:06:41.840075 IP 10.1.5.2.80 > 10.1.2.2.57176: Flags [P.], seq 7241:11174, ack 73, win 509, options [nop,nop,TS val 1790118990 ecr 2751115968], length 3933: HTTP
02:06:41.841151 IP 10.1.2.2.57176 > 10.1.5.2.80: Flags [.], ack 1449, win 501, options [nop,nop,TS val 2751115970 ecr 1790118990], length 0
02:06:41.841403 IP 10.1.2.2.57176 > 10.1.5.2.80: Flags [.], ack 4345, win 496, options [nop,nop,TS val 2751115970 ecr 1790118990], length 0
02:06:41.841652 IP 10.1.2.2.57176 > 10.1.5.2.80: Flags [.], ack 7241, win 496, options [nop,nop,TS val 2751115970 ecr 1790118990], length 0
02:06:41.841903 IP 10.1.2.2.57176 > 10.1.5.2.80: Flags [.], ack 10137, win 481, options [nop,nop,TS val 2751115971 ecr 1790118990], length 0
02:06:41.842152 IP 10.1.2.2.57176 > 10.1.5.2.80: Flags [.], ack 11174, win 501, options [nop,nop,TS val 2751115971 ecr 1790118990], length 0
02:06:41.842904 IP 10.1.2.2.57176 > 10.1.5.2.80: Flags [F.], seq 73, ack 11174, win 501, options [nop,nop,TS val 2751115972 ecr 1790118990], length 0
02:06:41.843033 IP 10.1.5.2.80 > 10.1.2.2.57176: Flags [F.], seq 11174, ack 74, win 509, options [nop,nop,TS val 1790118993 ecr 2751115972], length 0
02:06:41.843652 IP 10.1.2.2.57176 > 10.1.5.2.80: Flags [.], ack 11175, win 501, options [nop,nop,TS val 2751115972 ecr 1790118993], length 0


02:07:01.349858 IP 10.1.2.2.42958 > 10.1.5.2.80: Flags [S], seq 1039428817, win 64240, options [mss 1460,sackOK,TS val 4173767578 ecr 0,nop,wscale 7], length 0
02:07:01.349904 IP 10.1.5.2.80 > 10.1.2.2.42958: Flags [S.], seq 2797340733, ack 1039428818, win 65160, options [mss 1460,sackOK,TS val 1790138499 ecr 4173767578,nop,wscale 7], length 0
02:07:01.350609 IP 10.1.2.2.42958 > 10.1.5.2.80: Flags [R], seq 1039428818, win 0, length 0

seq 2976142489