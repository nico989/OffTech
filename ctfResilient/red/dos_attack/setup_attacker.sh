#!/bin/bash

# Installing tools
printf "Installing tools..."
for i in {1..3}; 
do 
    ssh client$i.g2ctf.offtech "sudo apt install hping3 -y"; 
done;
printf " done!\n"

