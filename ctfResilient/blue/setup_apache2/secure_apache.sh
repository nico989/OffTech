#!/bin/bash

# Patch apache conf
sudo patch /etc/apache2/apache2.conf -i apache2.patch

# Install modsecurity
printf "Install modsecurity..."
sudo apt install libapache2-mod-security2 -y > /dev/null
printf " done!\n"
sudo cp /etc/modsecurity/modsecurity.conf-recommended /etc/modsecurity/modsecurity.conf
sudo patch /etc/modsecurity/modsecurity.conf -i modsecurity.patch

# Install modevasive
printf "Install modevasive..."
sudo apt install libapache2-mod-evasive -y
sudo patch /etc/apache2/mods-available/evasive.conf -i evasive.patch

# Restart apache2
sudo service apache2 restart
