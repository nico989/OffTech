#!/bin/bash

for i in {0..255}
do
    DEST=5.6.7.$i
    if ping -c 1 $DEST | grep Unreachable &> /dev/null;
    then
        continue
    else
        echo "$DEST UP or DOWN"
    fi
done
