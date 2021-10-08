#!/bin/sh
FILE=eth.txt

# Redirect the new output into FILE
/share/shared/Internetworking/showcabling intranetworking-vn offtech | sed 's/ <- is "wired" to -> /^/' | tr '^' '\n' > $FILE

# Check if file exists
if [ -f "$FILE" ]; then
	
	# Retrieve interfaces
	NWworkstation1Eth=$(sed -n '2p' $FILE | cut -d ' ' -f2)
	NWrouterEthUp=$(sed -n '3p' $FILE | cut -d ' ' -f2)
	NWrouterEthDown=$(sed -n '4p' $FILE | cut -d ' ' -f2)
	ISrouterEthUp=$(sed -n '5p' $FILE | cut -d ' ' -f2)
	ISrouterEthDown=$(sed -n '6p' $FILE | cut -d ' ' -f2)
	SWrouterEthUp=$(sed -n '7p' $FILE | cut -d ' ' -f2)
	SWrouterEthDown=$(sed -n '9p' $FILE | cut -d ' ' -f2)
	SWworkstation1Eth=$(sed -n '8p' $FILE | cut -d ' ' -f2)
	
	printf 'NWworkstation1Eth=%s\nNWrouterEthUp=%s\nNWrouterEthDown=%s\nISrouterEthUp=%s\nISrouterEthDown=%s\nSWrouterEthUp=%s\nSWrouterEthDown=%s\nSWworkstation1Eth=%s\n' \
		"$NWworkstation1Eth" "$NWrouterEthUp" "$NWrouterEthDown" "$ISrouterEthUp" "$ISrouterEthDown" "$SWrouterEthUp" "$SWrouterEthDown" "$SWworkstation1Eth" \
	
	# Wait
	read REPLY
	
	echo "Start script for NWworkstation1"
	echo "#!/bin/sh
	
	# Assign IP
	ifconfig $NWworkstation1Eth 10.10.1.2 netmask 255.255.255.0
	
	# Define routes
	route add -net 93.94.95.0 netmask 255.255.255.0 gw 10.10.1.1
	route add -net 83.84.85.0 netmask 255.255.255.0 gw 10.10.1.1
	route add -net 172.16.1.0 netmask 255.255.255.0 gw 10.10.1.1" > NWworkstation1.sh
	chmod +x NWworkstation1.sh
	ssh NWworkstation1.intranetworking-vn.offtech "sudo su -c ./NWworkstation1.sh"
	
	# Wait
	read REPLY
	
	echo "Start script for NWrouter"
	echo "#!/bin/sh
	
	# Assign IP
	ifconfig $NWrouterEthUp 10.10.1.1 netmask 255.255.255.0
	ifconfig $NWrouterEthDown 93.94.95.3 netmask 255.255.255.0
	
	# Define routes
	route add -net 83.84.85.0 netmask 255.255.255.0 gw 93.94.95.2
	route add -net 172.16.1.0 netmask 255.255.255.0 gw 93.94.95.2
	
	# Define NAT
	iptables -t nat -A POSTROUTING -o $NWrouterEthDown -s 10.10.1.0/24 -j SNAT --to 93.94.95.3" > NWrouter.sh
	chmod +x NWrouter.sh
	ssh NWrouter.intranetworking-vn.offtech "sudo su -c ./NWrouter.sh"
	
	# Wait
	read REPLY
	
	echo "Start script for ISrouter"
	echo "#!/bin/sh
	
	# Assign IP
	ifconfig $ISrouterEthUp 93.94.95.2 netmask 255.255.255.0
	ifconfig $ISrouterEthDown 83.84.85.2 netmask 255.255.255.0
	
	# Define routes
	route add -net 10.10.1.0 netmask 255.255.255.0 gw 93.94.95.3
	route add -net 172.16.1.0 netmask 255.255.255.0 gw 83.84.85.3
	
	# Block private IPs
	iptables -I FORWARD -d 192.168.0.0/16 -j DROP
	iptables -I FORWARD -d 172.16.0.0/12 -j DROP
	iptables -I FORWARD -d 10.0.0.0/8 -j DROP
	iptables -I FORWARD -s 192.168.0.0/16 -j DROP
	iptables -I FORWARD -s 172.16.0.0/12 -j DROP
	iptables -I FORWARD -s 10.0.0.0/8 -j DROP" > ISrouter.sh
	chmod +x ISrouter.sh
	ssh ISrouter.intranetworking-vn.offtech "sudo su -c ./ISrouter.sh"
	
	# Wait
	read REPLY
	
	echo "Start script for SWrouter"
	echo "#!/bin/sh
	
	# Assign IP
	ifconfig $SWrouterEthUp 83.84.85.3 netmask 255.255.255.0
	ifconfig $SWrouterEthDown 172.16.1.1 netmask 255.255.255.0
	
	# Define routes
	route add -net 93.94.95.0 netmask 255.255.255.0 gw 83.84.85.2
	route add -net 10.10.1.0 netmask 255.255.255.0 gw 83.84.85.2
	
	# Define NAT
	iptables -t nat -A POSTROUTING -o $SWrouterEthUp -s 172.16.1.0/24 -j SNAT --to 83.84.85.3
	
	# Define port forwarding
	iptables -t nat -A PREROUTING -i $SWrouterEthUp -d 83.84.85.3/24 -p tcp --dport 80 -j DNAT --to 172.16.1.2" > SWrouter.sh
	chmod +x SWrouter.sh
	ssh SWrouter.intranetworking-vn.offtech "sudo su -c ./SWrouter.sh"
	
	# Wait
	read REPLY
	
	echo "Start script for SWworkstation1"
	echo "#!/bin/sh
	
	# Assign IP
	ifconfig $SWworkstation1Eth 172.16.1.2 netmask 255.255.255.0
	
	# Define routes
	route add -net 83.84.85.0 netmask 255.255.255.0 gw 172.16.1.1
	route add -net 93.94.95.0 netmask 255.255.255.0 gw 172.16.1.1
	route add -net 10.10.1.0 netmask 255.255.255.0 gw 172.16.1.1" > SWworkstation1.sh
	chmod +x SWworkstation1.sh
	ssh SWworkstation1.intranetworking-vn.offtech "sudo su -c ./SWworkstation1.sh"
else 
    echo "$FILE has not been created, exit!"
fi
