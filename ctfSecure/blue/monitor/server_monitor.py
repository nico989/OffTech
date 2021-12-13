#!/usr/bin/python3

import argparse
from scapy.all import *
from scapy.layers.http import HTTPRequest
from colorama import init, Fore
from datetime import datetime, timezone, timedelta

# initialize colorama
init()

# define colors
GREEN = Fore.GREEN
RED   = Fore.RED
RESET = Fore.RESET

def logMessage(message):
    log = open("/tmp/logHTTPRequests.txt", "a")
    log.write(f"{message}\n")
    log.close()

def process_packet(packet):
    message = ""
    ip = packet[IP].src
    if packet.haslayer(HTTPRequest):
        time = datetime.fromtimestamp(packet[HTTPRequest].time, tz=timezone(timedelta(hours=+1))).strftime('%Y-%m-%d %H:%M:%S:%f')
        try:
            url = packet[HTTPRequest].Host.decode() + packet[HTTPRequest].Path.decode()
            method = packet[HTTPRequest].Method.decode()
            message = f"[{time}] {ip} Requested {url} with {method}"
            print(f"{GREEN} {message} {RESET}\n")
            if show_raw and packet.haslayer(Raw) and method == "POST":
                message = message + f" and data {packet[Raw].load}"
                print(f"{RED}[*] Some useful Raw data: {packet[Raw].load}{RESET}\n")
        except:
            message = f"[{time}] {ip} Malformed HTTP"
            print(f"{message}\n")

    if message != "":
        logMessage(message)

def sniff_packets(iface=None):
    if iface:
        sniff(filter="tcp and dst host 10.1.5.2 and dst port 80", prn=process_packet, iface=iface, store=False)
    else:
        sniff(filter="tcp and dst host 10.1.5.2 and dst port 80", prn=process_packet, store=False)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="HTTP Packet Sniffer")
    parser.add_argument("-i", "--iface", help="Interface to use, default is in conf.iface")
    parser.add_argument("--show-raw", dest="show_raw", action="store_true", help="Wheter to print POST raw data, such as passwords, search queries, etc.")
    args = parser.parse_args()
    iface = args.iface
    show_raw = args.show_raw
    sniff_packets(iface)
