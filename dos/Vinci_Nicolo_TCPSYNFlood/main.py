import sys
import matplotlib.pyplot as plt
from scapy.all import *
from uniqueConn import UniqueConn

'''
{
    "uniqueConn": conn
    "packets": [packet] --> packet = [<Flag, time>]
}
'''

def insertConn(traces, conn, packet):
    try:
        i = next(index for index, dict in enumerate(traces) if dict["uniqueConn"] == conn)
        traces[i]["packets"].append((packet[TCP].flags, packet.time))
    except:
        traces.append({
            "uniqueConn": conn,
            "packets": [(packet[TCP].flags, packet.time)]
        })

def main():
    try:
        scapy_cap = rdpcap(sys.argv[1])
    except:
        print("No input file\n")
        exit()
    
    startTime = scapy_cap[0].time

    traces = []

    # Define TCP/IP connection
    for packet in scapy_cap:
        conn = UniqueConn(packet[IP].src, packet[IP].dst, packet[TCP].sport, packet[TCP].dport)
        insertConn(traces, conn, packet)
        
    xtime = []
    ydurations = []

    # Compute connection duration
    for trace in traces:
        if trace["packets"][0][0] == 'S' and ((trace["packets"][-2][0] == 'FA' and trace["packets"][-1][0] == 'A') or trace["packets"][-1][0] == 'R'):
            ydurations.append(trace["packets"][-1][1] - trace["packets"][0][1])
        else:
            ydurations.append(200)
        xtime.append(trace["packets"][0][1] - startTime)

    # Print full screen on Windows
    plt.get_current_fig_manager().window.state('zoomed')
    # x label
    plt.xlabel('Connections start')
    # y label
    plt.ylabel('Connections duration')  
    # graph title
    plt.title('TCP SYN Flood file: ' + str(sys.argv[1])) 

    plt.plot(xtime, ydurations, color= 'black', linewidth='1')

    # Start attack data
    plt.axvline(x=30, color='red')
    # End attack data
    plt.axvline(x=150, color='red')

    plt.show()
        

if __name__ == '__main__': 
    main()
