#!/bin/bash

while true
do
    SEC=$((1 + $RANDOM % 10))
    PAGE=$((1 + $RANDOM % 10))
    curl --silent --output /dev/null --write-out '%{time_connect}\n' 10.1.5.2:80/$PAGE.html
    sleep $SEC
done
