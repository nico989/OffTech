#!/bin/bash

SEC=$1

while true
do
    curl --silent --output /dev/null --write-out '%{time_connect}\n' 10.1.5.2 
    sleep $SEC
done