#!/bin/bash

# TCP hardening
sudo sysctl -w net.ipv4.tcp_synack_retries=0
sudo sysctl -w net.ipv4.tcp_syn_retries=1
sudo sysctl -w net.ipv4.tcp_fin_timeout=2
sudo sysctl -w net.ipv4.tcp_keepalive_time=10
sudo sysctl -w net.ipv4.tcp_keepalive_probes=1
sudo sysctl -w net.ipv4.tcp_keepalive_intvl=1
sudo sysctl -w net.ipv4.tcp_rfc1337=1
sudo sysctl -w net.ipv4.tcp_max_orphans=400000
sudo sysctl -w net.ipv4.tcp_orphan_retries=0
sudo sysctl -w net.ipv4.tcp_max_syn_backlog=16384
sudo sysctl -w net.core.somaxconn=16384
sudo sysctl -w net.ipv4.tcp_syncookies=1
sudo sysctl -w net.ipv4.tcp_timestamps=1
sudo sysctl -w net.ipv4.tcp_window_scaling=1
sudo sysctl -w net.core.netdev_max_backlog=262144
sudo sysctl -w net.ipv4.tcp_mem='65536 131072 262144'
sudo sysctl -w net.core.rmem_max=67108864
#sudo ip route change 10.1.5.0/24 dev eth4 proto kernel scope link src 10.1.5.2 rto_min 5ms
