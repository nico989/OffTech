#!/bin/bash

iptables -A FORWARD -i eth3 -o eth2 -p tcp -d 10.1.5.2 --dport 80 --tcp-flags ALL SYN -j ACCEPT
iptables -A FORWARD -i eth2 -o eth3 -p tcp -s 10.1.5.2 --sport 80 --tcp-flags ALL SYN,ACK -j ACCEPT
iptables -A FORWARD -i eth3 -o eth2 -p tcp -d 10.1.5.2 --dport 80 --tcp-flags ALL ACK -j ACCEPT
iptables -A FORWARD -i eth3 -o eth2 -p tcp -d 10.1.5.2 --dport 80 --tcp-flags ALL PSH,ACK -j ACCEPT
iptables -A FORWARD -i eth2 -o eth3 -p tcp -s 10.1.5.2 --sport 80 --tcp-flags ALL PSH,ACK -j ACCEPT
iptables -A FORWARD -i eth2 -o eth3 -p tcp -s 10.1.5.2 --sport 80 --tcp-flags ALL ACK -j ACCEPT
iptables -A FORWARD -i eth2 -o eth3 -p tcp -s 10.1.5.2 --sport 80 --tcp-flags ALL FIN,ACK -j ACCEPT
iptables -A FORWARD -i eth3 -o eth2 -p tcp -d 10.1.5.2 --dport 80 --tcp-flags ALL FIN,ACK -j ACCEPT
