#!/bin/bash

DUR=$1
CONFFILEDIR=$2

# read conf file
source $CONFFILEDIR/shvidprevs.conf

HOURS=`echo $DUR | gawk -F: '{ print $1 }'`
if [ $HOURS != "00" ]; then
    HOURS=`echo $HOURS | sed 's/0*//'`
fi

MINUTES=`echo $DUR | gawk -F: '{ print $2 }'`
if [ $MINUTES != "00" ]; then
    MINUTES=`echo $MINUTES | sed 's/0*//'`
fi

SECONDS=`echo $DUR | gawk -F: '{ print $3 }' | gawk -F. '{ print $1 }'`
if [ $SECONDS != "00" ]; then
    SECONDS=`echo $SECONDS | sed 's/0*//'`
fi

let "SEC = $HOURS*3600+$MINUTES*60+$SECONDS"
echo "$SEC" > $TEMPDIR/$TEMPPREFIX.sec
