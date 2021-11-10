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
