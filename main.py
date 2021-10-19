import sys
import matplotlib.pyplot as plot
from scapy.all import *

def main():
    try:
        scapy_cap = rdpcap(sys.argv[1])
    except:
        print("No input file\n")
        exit()

    for packet in scapy_cap:
        print(packet[IP])


if __name__ == '__main__': 
    main()
