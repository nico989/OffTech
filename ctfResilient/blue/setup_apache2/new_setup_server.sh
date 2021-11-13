#!/bin/bash

# this scripts installs apache2 FROM SOURCE and starts the server
# it must be run with privileges

# check if root privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

printf "\n\t\t+++ Setting up server and monitoring tools +++\n\n"

# update repositories
printf "Updating repositories..."
apt-get update > /dev/null
printf " done! (1/5)\n"

# install dependencies
printf "Installing libpcre3-dev, python3-setuptools, ..."
apt-get install libpcre3 libpcre3-dev python3-setuptools libapr1 libapr1-dev libaprutil1 libaprutil1-dev -y > /dev/null
printf " done! (2/5)\n"

# install apache2
printf "Installing apache2..."
cd /users/otech2ac/lib/httpd-2.4.51
make install > /dev/null
printf " done! (3/5)\n"

# create html files
printf "Creating html files..."
for i in {1..10};
do
    sudo touch "/usr/local/apache2/htdocs/$i.html";
done
cd
printf " done! (4/5)\n"

# Install scapy
printf "Installing scapy from scapy-master..."
cd /users/otech2ac/lib/scapy-master/
python3 -W ignore setup.py install > /dev/null
cd
printf " done! (5/5)\n"

printf "\n\t\t+++ Securing apache2 +++\n\n"
# Patch apache conf
printf "Patch httpd.conf..."
patch /usr/local/apache2/conf/httpd.conf -i /users/otech2ac/lib/httpd.conf.patch > /dev/null
printf " done! (1/1)\n"

# Install modsecurity
#printf "Install modsecurity..."
#apt-get install libapache2-mod-security2 -y > /dev/null
#cp /etc/modsecurity/modsecurity.conf-recommended /etc/modsecurity/modsecurity.conf
#patch /etc/modsecurity/modsecurity.conf -i /users/otech2ah/setup_apache2/modsecurity.patch > /dev/null
#printf " done!(2/3)\n"

# Install modevasive
#printf "Install modevasive..."
#apt-get install libapache2-mod-evasive -y
#patch /etc/apache2/mods-available/evasive.conf -i /users/otech2ah/setup_apache2/evasive.patch > /dev/null
#printf "done!(3/3)\n"

# start the server
printf "Starting server..."
/usr/local/apache2/bin/apachectl -k start > /dev/null
printf " done!\n All done!\n