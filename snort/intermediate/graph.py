#!/bin/python3
import argparse
import matplotlib.pyplot as plt

def main2(fileName1, fileName2):

    time1 = []
    ypackets1 = []

    with open(fileName1, "r") as f:
        for line in f.readlines():
            splitted = line.strip().split(" ")
            time1.append(float(splitted[0]))
            ypackets1.append(int(splitted[1]))
    
    xnewtime1 = []
    for i in time1:
        xnewtime1.append(i - time1[0])

    time2 = []
    ypackets2 = []

    with open(fileName2, "r") as f:
        for line in f.readlines():
            splitted = line.strip().split(" ")
            time2.append(float(splitted[0]))
            ypackets2.append(int(splitted[1]))
    
    xnewtime2 = []
    for i in time2:
        xnewtime2.append(i - time2[0])

    plt.get_current_fig_manager().window.state('zoomed')
    plt.xlabel('Time [s]')
    plt.ylabel('Number of Packets [pkts]')  
    plt.title(fileName1 + " " + fileName2) 
    f1 = str(fileName1).strip().split(".")[0]
    plt.plot(xnewtime1, ypackets1, color= 'black', label=f1, linewidth='1')
    f2 = str(fileName2).strip().split(".")[0]
    plt.plot(xnewtime2, ypackets2, color= 'blue', label=f2, linewidth='1')
    plt.legend()
    plt.show()
    

def main1(fileName1):

    time = []
    ypackets = []

    with open(fileName1, "r") as f:
        for line in f.readlines():
            splitted = line.strip().split(" ")
            time.append(float(splitted[0]))
            ypackets.append(int(splitted[1]))
    
    xnewtime = []
    for i in time:
        xnewtime.append(i - time[0])

    plt.get_current_fig_manager().window.state('zoomed')
    plt.xlabel('Time [s]')
    plt.ylabel('Number of Packets [pkts]')  
    plt.title(fileName1) 

    plt.plot(xnewtime, ypackets, color= 'black', linewidth='1')
    plt.axvline(x=xnewtime[0], color='red')
    plt.axvline(x=xnewtime[-1], color='red')
    plt.legend()
    plt.show()

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Graph generator")
    parser.add_argument("-f1", "--fileName1", help="File1 to retrieve data")
    parser.add_argument("-f2", "--fileName2", help="File2 to retrieve data")
    args = parser.parse_args()
    fileName1 = args.fileName1
    fileName2 = args.fileName2
    #main1(fileName1)
    main2(fileName1, fileName2)
