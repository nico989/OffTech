#!/usr/bin/bash

# transfer file or directory to deterlab
USER=otech2ah
FULL_PATH=$(realpath $1)

if [[ -d $FULL_PATH ]]
then
    echo "Copying" $FULL_PATH "to deterlab" $USER "lib"
    scp -r $FULL_PATH $USER@users.deterlab.net:/users/$USER/lib/
elif [[ $FULL_PATH ]]
then
    echo "Copying" $FULL_PATH "to deterlab" $USER "lib"
    scp $FULL_PATH $USER@users.deterlab.net:/users/$USER/lib/
else
    echo "Usage: ./transfer_to_deter.sh <file_or_dir_name>"
fi
