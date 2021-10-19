#!/bin/sh

# Set up Server and Attacker
echo "Start Set up"
echo "-------------------------------------------------------------------"

# Install server
echo "Install server on Server Node"
ssh server.vinci-dos.offtech "/share/education/TCPSYNFlood_USC_ISI/install-server" > /dev/null

# Install flooder
echo "Install flooder on Attacker Node"
ssh attacker.vinci-dos.offtech "/share/education/TCPSYNFlood_USC_ISI/install-flooder" > /dev/null

echo "-------------------------------------------------------------------"
