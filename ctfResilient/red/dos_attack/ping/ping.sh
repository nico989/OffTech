#!/bin/bash

# It works if at least 2 machines are pinging
echo "START PING"
sudo ping -f -s 65500 10.1.5.2
