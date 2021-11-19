#!/bin/bash

# Default values
sudo sysctl -w net.ipv4.tcp_synack_retries=5
sudo sysctl -w net.ipv4.tcp_syn_retries=6
sudo sysctl -w net.ipv4.tcp_fin_timeout=60
sudo sysctl -w net.ipv4.tcp_keepalive_time=7200
sudo sysctl -w net.ipv4.tcp_keepalive_probes=9
sudo sysctl -w net.ipv4.tcp_keepalive_intvl=75
sudo sysctl -w net.ipv4.tcp_rfc1337=0
sudo sysctl -w net.ipv4.tcp_max_orphans=8192
sudo sysctl -w net.ipv4.tcp_orphan_retries=0
sudo sysctl -w net.ipv4.tcp_max_syn_backlog=128
sudo sysctl -w net.core.somaxconn=128 # both syn and ack queue
sudo sysctl -w net.ipv4.tcp_syncookies=1
sudo sysctl -w net.ipv4.tcp_timestamps=1
sudo sysctl -w net.ipv4.tcp_window_scaling=1
sudo sysctl -w net.core.netdev_max_backlog=1000
sudo sysctl -w net.ipv4.tcp_mem='22380 29843 44760'
sudo sysctl -w net.core.rmem_max=212992
#sudo ip route change 10.1.5.0/24 dev eth4 proto kernel scope link src 10.1.5.2
