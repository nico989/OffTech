#!/bin/bash

TO=$1
MACHINE=$2

if [[ -d $TO ]]
then
    # Transfer directory
    echo "Copy $TO directory into $MACHINE"
    scp -r $TO /scripts 
    ssh $MACHINE.g2ctf.offtech "sudo chmod -R +x /scripts/$TO"
elif [[ $TO ]]
then
    # Transfer file
    echo "Copy $TO file into $MACHINE"
    scp $TO /scripts
    ssh $MACHINE.g2ctf.offtech "sudo chmod+x /scripts/$TO"
else
    echo "Usage: ./transfer_to_machine.sh <FILE/DIR> <MACHINE>"
fi
