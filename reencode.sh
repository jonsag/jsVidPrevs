#!/bin/bash

CONFFILEDIR=$1
TIME=$2
LOGFILE=$3
FILE=$4

# read conf file
source $CONFFILEDIR/shvidprevs.conf

# create reencode dir if necessary
if [ -d "$REENCODEDIR" ]; then
    echo "Trying to reencode $FILE" >> $REPORTSDIR/reenocoded-$TIME.txt
else
    echo
    echo "Creating the directory $REENCODEDIR"
    mkdir -p $REENCODEDIR
    echo "Trying to reencode $FILE" >> $REPORTSDIR/reenocoded-$TIME.txt
fi

echo

echo -e $YELLOW "Will renencode $FILE" $RESET 
echo
