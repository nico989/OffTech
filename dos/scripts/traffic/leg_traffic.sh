#!/bin/bash

TIMEOUT=180
END=$((SECONDS+$TIMEOUT))

echo "Start legitimate traffic"

while [ $SECONDS -lt $END ]; 
do
    curl --silent --output /dev/null -x 5.6.7.8:80 index.html &
done

echo "Stop legitimate traffic"
