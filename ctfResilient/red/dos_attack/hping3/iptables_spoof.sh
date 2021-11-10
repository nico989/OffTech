#!/bin/bash

sudo iptables -A INPUT -s 10.1.5.2 -p tcp --tcp-flags URG,SYN,PSH,RST,FIN SYN -j DROP

sudo iptables -A INPUT -s 10.1.5.2 -p tcp --tcp-flags SYN,ACK SYN,ACK -j DROP

sudo iptables -A OUTPUT -d 10.1.5.2 -p tcp --tcp-flags RST RST -j DROP

sudo iptables -t nat -A POSTROUTING -o eth -s client_source -j SNAT --to client_spoof

