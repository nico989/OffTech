#!/usr/bin/python

from scapy.all import *
from scapy.layers.http import HTTPRequest # import HTTP packet
from colorama import init, Fore

# initialize colorama
init()

# define colors
GREEN = Fore.GREEN
RED =   Fore.RED
RESET = Fore.RESET

# function for sniffing
def sniff_packets(iface=None):
    """
    Sniff 80 port packets with 'iface', if None (default), then the Scapy's
    default interface is used
    """

    if iface:
        # port 80 for http
        # 'process_packet' is the callback

        sniff(filter="port 80", prn=process_packet, iface=iface, store=False)
    else:
        # sniff with default interface
        sniff(filter="port 80", prn=process_packet, store=False)

def process_packet(packet):
    """
    This function is executed whenever a packet is sniffed
    """

    if packet.haslayer(HTTPRequest):
        # if this packet is an HTTP Request 
        # get the request URL
        url = packet[HTTPRequest].Host.decode() + packet[HTTPRequest].Path.decode()

        #get the requester's IP Address
        ip = packet[IP].src

        # get the request method
        method = packet[HTTPRequest].Method.decode()

        print(f"\n{GREEN}[+] {ip} Requested {url} with {method}{RESET}")
        if show_raw and packet.haslayer(Raw) and method == "POST":
            # if show_raw flag is enabled, has raw data, and the requested
            # method is "POST", then show raw
            print(f"\n{RED}[*] Some useful Raw data: {packet[Raw].load}{RESET}")

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="HTTP Packet Sniffer")
    parser.add_argument("-i", "--iface", help="Interface to use, default is in conf.iface")
    parser.add_argument("--show-raw", dest="show_raw", action="store_true", help="Wheter to print POST raw data, such as passwords, search queries, etc.")

    # partse arguments
    args = parser.parse_args()
    iface = args.iface
    show_raw = args.show_raw
    sniff_packets(iface)
