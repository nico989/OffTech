#!/bin/sh

# Install server
echo "Install server on Server Node"
ssh server.vinci-dos.offtech "/share/education/TCPSYNFlood_USC_ISI/install-server"

echo "-------------------------------------------------------------------"

# Install flooder
echo "Install flooder on Attacker Node"
ssh attacker.vinci-dos.offtech "/share/education/TCPSYNFlood_USC_ISI/install-flooder"
