#!/bin/sh

# Set rule
echo "Setting rule"
ssh attacker.vinci-dos.offtech "sudo iptables -I INPUT -s 5.6.7.8 -p tcp --tcp-flags URG,SYN,PSH,RST,FIN SYN -j DROP" &> /dev/null 
