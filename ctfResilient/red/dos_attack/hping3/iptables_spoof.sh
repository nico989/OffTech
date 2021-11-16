#!/bin/bash

# Iptables for TCP SYN flood

ssh client$1.g2ctf.offtech "ssh sudo iptables -A OUTPUT -d 10.1.5.2 -p tcp --tcp-flags RST RST -j DROP"

sudo iptables -t nat -A POSTROUTING -o client_eth -s client_ip -j SNAT --to leg_client
