#!/bin/bash

# this scripts installs scapy
# it must be run with privileges

# check if root privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# update repositories
printf "Updating repositories..."
apt-get update > /dev/null
printf " done! (1/2)\n"

# install scapy
printf "Installing scapy from scapy-master..."
apt-get install python3-setuptools -y > /dev/null
cd /users/otech2ac/lib/scapy-master/
python3 -W ignore setup.py install > /dev/null
cd
printf " done! (2/2)\n"
