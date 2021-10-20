#!/bin/bash

while true
do
    curl --silent --output /dev/null -x 11.12.13.1:80 index.html &
    sleep 1
done
