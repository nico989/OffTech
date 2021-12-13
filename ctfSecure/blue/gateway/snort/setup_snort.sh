#!/bin/bash

# this scripts installs snort
# it must be run with privileges

# check if root privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# install snort
printf "Installing snort..."
apt-get install -y build-essential gcc libpcre3-dev zlib1g-dev libluajit-5.1-dev libpcap-dev openssl libssl-dev libnghttp2-dev libdumbnet-dev bison flex libdnet autoconf libtool liblzma-dev libnetfilter-queue-dev > /dev/null
mkdir ~/snort_src && cd ~/snort_src
tar -xvzf /users/otech2ah/blue/gateway/snort/daq-2.0.7.tar.gz > /dev/null
cd daq-2.0.7
autoreconf -f -i
./configure && make && sudo make install
cd ~/snort_src
tar -xvzf /users/otech2ah/blue/gateway/snort/snort-2.9.19.tar.gz > /dev/null
cd snort-2.9.19
./configure --enable-sourcefire && make && sudo make install
ldconfig
ln -s /usr/local/bin/snort /usr/sbin/snort
cd
groupadd snort
useradd snort -r -s /sbin/nologin -c SNORT_IDS -g snort
mkdir -p /etc/snort/rules
mkdir /var/log/snort
mkdir /usr/local/lib/snort_dynamicrules
chmod -R 5775 /etc/snort
chmod -R 5775 /var/log/snort
chmod -R 5775 /usr/local/lib/snort_dynamicrules
chown -R snort:snort /etc/snort
chown -R snort:snort /var/log/snort
chown -R snort:snort /usr/local/lib/snort_dynamicrules
touch /etc/snort/rules/local.rules
touch /etc/snort/rules/white_list.rules
touch /etc/snort/rules/black_list.rules
cp ~/snort_src/snort-2.9.19/etc/*.conf* /etc/snort
cp ~/snort_src/snort-2.9.19/etc/*.map /etc/snort
patch /etc/snort/snort.conf -i /users/otech2ah/blue/gateway/snort/snort.patch > /dev/null
iptables -A FORWARD -j NFQUEUE --queue-num=4
apt-get install iptables-persistent -y
systemctl enable netfilter-persistent.service
printf "Done!\n"
