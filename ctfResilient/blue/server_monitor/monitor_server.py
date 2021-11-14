#!/usr/bin/python3

import argparse
from time import timezone
from scapy.all import *
from scapy.layers.http import HTTPRequest # import HTTP packet
from colorama import init, Fore
from datetime import datetime

# initialize colorama
init()

# define colors
GREEN = Fore.GREEN
RED   = Fore.RED
BLUE  = Fore.BLUE
RESET = Fore.RESET

# actual date
now = datetime.now()

# metrics
metric = {
    "tcp": [0,0],
    "syn": [0,0],
    "icmp": [0,0],
    "udp": [0,0],
    "total": [0,0]
}

# client IP list
clients = []

def format_bytes(size):
    power = 2**10
    n = 0
    power_labels = {0 : '', 1: 'K', 2: 'M', 3: 'G', 4: 'T'}
    while size > power:
        size /= power
        n += 1
    return str(round(size))+power_labels[n]

def storePacket(packet):
    recv_bytes = len(packet)
    prot = packet.getlayer(2).name
    if (prot == 'TCP'):
        metric["tcp"][0] += 1
        metric["tcp"][1] += recv_bytes
        if (packet[TCP].flags == "S"):
            metric["syn"][0] += 1
            metric["syn"][1] += recv_bytes
    elif (prot == 'UDP'):
        metric["udp"][0] += 1
        metric["udp"][1] += recv_bytes
    elif (prot == 'ICMP'):
        metric["icmp"][0] += 1
        metric["icmp"][1] += recv_bytes
    metric["total"][0] = metric["tcp"][0] + metric["udp"][0] + metric["icmp"][0]
    metric["total"][1] = metric["tcp"][1] + metric["udp"][1] + metric["icmp"][1]

def storeClients(packet):
    try:
        recv_bytes = len(packet)
        i = next(index for index, dict in enumerate(clients) if dict["srcIP"] == packet[IP].src)
        clients[i]["packets"] += 1
        clients[i]["bytes"] += recv_bytes
    except:
        clients.append({
            "srcIP": packet[IP].src,
            "packets": 0,
            "bytes": 0
        })

def printall():
    print(f'[TCP SYN] packets:{format_bytes(metric["syn"][0])}, bytes:\t{format_bytes(metric["syn"][1])}')
    print(f'[TCP] packets:\t{format_bytes(metric["tcp"][0])}, bytes:\t{format_bytes(metric["tcp"][1])}')
    print(f'[UDP] packets:\t{format_bytes(metric["udp"][0])}, bytes:\t{format_bytes(metric["udp"][1])}')
    print(f'[ICMP] packets:\t{format_bytes(metric["icmp"][0])}, bytes:\t{format_bytes(metric["icmp"][1])}')
    print(f'[TOTAL] packets:{format_bytes(metric["total"][0])}, bytes:\t{format_bytes(metric["total"][1])}\n')

def logClients():
    log = open("logClients.txt", "a")
    log_time = datetime.now(timezone(timedelta(hours=+1))).strftime("%Y-%m-%d %H:%M:%S")
    for client in clients:
        log.write(f'{log_time} {client["srcIP"]}: [packets={format_bytes(client["packets"])}, bytes={format_bytes(client["bytes"])}]\n')
    log.close()

def process_packet(packet):
    ip = packet[IP].src
    if ip != "10.1.5.3":
        if packet.haslayer(HTTPRequest):
            time = datetime.fromtimestamp(packet[HTTPRequest].time, tz=timezone(timedelta(hours=+1))).strftime('%Y-%m-%d %H:%M:%S:%f')
            try:
                url = packet[HTTPRequest].Host.decode() + packet[HTTPRequest].Path.decode()
                method = packet[HTTPRequest].Method.decode()
                print(f"{GREEN}[+] {ip} Requested {url} with {method} at {time}{RESET}\n")
                if show_raw and packet.haslayer(Raw) and method == "POST":
                    print(f"{RED}[*] Some useful Raw data: {packet[Raw].load}{RESET}\n")
            except:
                print(f"[-] {ip} Malformed HTTP at {time}{RESET}\n")

        storePacket(packet)
        storeClients(packet)    

        global now
        delta = datetime.now() - now
        if delta.total_seconds() > 5:
            now = datetime.now()
            printall()
            logClients()

def sniff_packets(iface=None):
    if iface:
        sniff(filter="(tcp and dst host 10.1.5.2) or (icmp and dst host 10.1.5.2) or (udp and dst host 10.1.5.2)", prn=process_packet, iface=iface, store=False)
    else:
        sniff(filter="(tcp and dst host 10.1.5.2) or (icmp and dst host 10.1.5.2) or (udp and dst host 10.1.5.2)", prn=process_packet, store=False)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="HTTP Packet Sniffer")
    parser.add_argument("-i", "--iface", help="Interface to use, default is in conf.iface")
    parser.add_argument("--show-raw", dest="show_raw", action="store_true", help="Wheter to print POST raw data, such as passwords, search queries, etc.")
    args = parser.parse_args()
    iface = args.iface
    show_raw = args.show_raw
    sniff_packets(iface)
