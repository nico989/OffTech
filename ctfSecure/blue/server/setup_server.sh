#!/bin/bash

# this scripts installs LAMP, some security mods and starts the server
# it must be run with privileges

# check if root privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# path to project repo - server
SPATH="/users/otech2ac/offtech-secure-server/blue/server"

printf "\n\t\t+++ Setting up server and monitoring tools +++\n\n"

# update repositories
printf "Updating repositories..."
apt-get update > /dev/null
printf " done! (1/3)\n"

# install apache2
printf "Installing LAMP, python3-setuptools, ..."
debconf-set-selections <<< 'mysql-server-5.7 mysql-server/root_password password GrY7i13vc3D6XrGqUfPQ'
debconf-set-selections <<< 'mysql-server-5.7 mysql-server/root_password_again password GrY7i13vc3D6XrGqUfPQ'
apt-get install lamp-server^ python3-setuptools python3-mysql.connector -y > /dev/null
cp $SPATH/php/*.php /var/www/html
rm /var/www/html/index.html
printf " done! (2/3)\n"

printf "Installing scapy from scapy-master..."
cd /users/otech2ac/lib/scapy-master/
python3 -W ignore setup.py install > /dev/null
cd
printf " done! (3/3)\n"


printf "\n\t\t+++ Securing apache2 +++\n\n"
# Patch apache conf
printf "Patching apache2.conf..."
patch /etc/apache2/apache2.conf -i $SPATH/patch/apache2.patch > /dev/null
printf " done! (1/5)\n"

#Install mod_qos
printf "Installing mod_qos..."
apt-get install libapache2-mod-qos -y > /dev/null
patch /etc/apache2/mods-available/qos.conf -i $SPATH/patch/modqos.patch > /dev/null
printf " done!(2/5)\n"

# Install modsecurity
printf "Installing modsecurity..."
apt-get install libapache2-mod-security2 -y > /dev/null
cp /etc/modsecurity/modsecurity.conf-recommended /etc/modsecurity/modsecurity.conf
patch /etc/modsecurity/modsecurity.conf -i $SPATH/patch/modsecurity.patch > /dev/null
printf " done!(3/5)\n"

# Install modevasive
printf "Installing modevasive..."
apt-get install libapache2-mod-evasive -y
patch /etc/apache2/mods-available/evasive.conf -i $SPATH/patch/evasive.patch > /dev/null
printf " done!(4/5)\n"

printf "Restarting server..."
service apache2 restart
printf " done!(5/5)\n"

printf "\n\t\t+++ Setting up mySQL... +++\n\n"
printf "Creating mySQL database..."
mysql -u"root" -p"GrY7i13vc3D6XrGqUfPQ" < $SPATH/sql/setup.sql
printf " done!(1/1)\n"
