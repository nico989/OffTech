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
printf " done!\n"

# install apache2
printf "Installing apache2..."
apt-get install apache2 -y > /dev/null
printf " done!\n"

# create html files
printf "Creating html files..."
for i in {1..10}; 
do 
    sudo touch "/var/www/html/$i.html"; 
done;
printf " done!\n"

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
printf " done!\n"
