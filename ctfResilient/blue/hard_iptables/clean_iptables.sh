#!/bin/bash

# Drop policy default
sudo iptables -P INPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -P OUTPUT ACCEPT

# Clear iptables
sudo iptables -F
