#!/bin/bash

while true
do
    curl --silent --output /dev/null -x 5.6.7.8:80 index.html &
done
