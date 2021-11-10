#!/bin/bash

echo "Installing Apache"
sudo apt-get update > /dev/null
sudo apt-get install apache2 -y > /dev/null

echo "Creating html files"
for i in {1..10}; 
do 
    sudo touch "/var/www/html/$i.html"; 
done;
