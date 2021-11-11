#!/bin/bash

# this scripts installs apache2 and starts the server
# it must be run with privileges

# check if root privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# update repositories
printf "Updating repositories..."
apt-get update > /dev/null
printf " done! (1/5)\n"

# install apache2
printf "Installing apache2, python3-setuptools, ..."
apt-get install apache2 python3-setuptools -y > /dev/null
printf " done! (2/5)\n"

# create html files
printf "Creating html files..."
for i in {1..10}; 
do 
    sudo touch "/var/www/html/$i.html"; 
done;
printf " done! (3/5)\n"

# start the server
printf "Checking server status..."
service apache2 status > /dev/null
if [[ $? -ne 0 ]]
then	
	printf "\nServer is down! Starting again...\n"
	/etc/init.d/apache2 start
fi

service apache2 status > /dev/null
if [[ $? -ne 0 ]]
then	
	echo "\nCannot start server. Try:\n\tsudo service apache2 status"
fi
printf " done! (4/5)\n"

printf "Installing scapy from scapy-master..."
cd /users/otech2ac/lib/scapy-master/
python3 -W ignore setup.py install > /dev/null
cd 
printf " done! (5/5)\n"

printf "Securing apache2\n"
# Patch apache conf
printf "Patch apache2.conf..."
patch /etc/apache2/apache2.conf -i /users/otech2ah/setup_apache2/apache2.patch > /dev/null
printf " done! (1/3)\n"

# Install modsecurity
printf "Install modsecurity..."
apt-get install libapache2-mod-security2 -y > /dev/null
cp /etc/modsecurity/modsecurity.conf-recommended /etc/modsecurity/modsecurity.conf
patch /etc/modsecurity/modsecurity.conf -i /users/otech2ah/setup_apache2/modsecurity.patch > /dev/null
printf " done!(2/3)\n"

# Install modevasive
printf "Install modevasive..."
apt-get install libapache2-mod-evasive -y
patch /etc/apache2/mods-available/evasive.conf -i /users/otech2ah/setup_apache2/evasive.patch > /dev/null
printf "done!(3/3)\n"

# Restart apache2
service apache2 restart
