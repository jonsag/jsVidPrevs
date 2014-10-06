#!/bin/bash

##############################################################################
# created by Jon Sagebrand
# 120218
##############################################################################

CLEAN=$1

if [ -z $CLEAN ]; then
    CLEAN="noclean"
fi

# location of configuration file
# this must correlate to line in configurationfile at install time
CONFFILEDIR="/etc/jsvidprevs"

# version of this script
VERSION="0.1"

# checking for config and reading it
if [ -e $CONFFILEDIR/jsvidprevs.conf ]; then
    source $CONFFILEDIR/jsvidprevs.conf
else
    echo "###################################################################"
    echo "You do not have a config file at $CONFFILEDIR/jsvidprevs.conf."
    echo "Make sure it's in it's right place, and the try again!"
    echo "Exiting..."
    echo "###################################################################"
    exit 1
fi

# starting up some variables
TIME=$(date +%y%m%d-%H%M%S)
LOGFILE=$LOGDIR/$LOGNAME-$TIME.log
THISDIR=$(dirname $0)

# check for temporary directory
if [ -d $TEMPDIR ]; then
    echo "##########################################################################"
    echo -e $GREEN"Temporary directory $TEMPDIR exists" $RESET
    echo -e $YELLOW"Cleaning out old temp files..." $RESET
    rm $TEMPDIR/jsvidprevs*
    echo "##########################################################################"
else
    echo "##########################################################################"
    echo -e $RED"Temporary directory $TEMPDIR does not exist" $RESET
    echo -e $YELLOW"Creating it..." $RESET
    mkdir -p $TEMPDIR
    echo "##########################################################################"
fi

echo

# check if logdirectory exists
if [ -d $LOGDIR ]; then
    echo "###################################################################"
    echo -e $GREEN"Logdirectory exists" $RESET
    echo "###################################################################"
else
    echo "###################################################################"
    echo -e $RED"Logdirectory doesn't exist." $RESET
    echo -e $YELLOW"Creating it" $RESET
    echo "###################################################################"
    mkdir -p $LOGDIR
fi

echo

# creating log file and creating symbolic link
touch $LOGFILE
if [ $MAKELINK == 1 ]; then
    ln -sf $LOGFILE $LOGDIR/$LOGPREFIX-latest.log
    echo "###################################################################"
    echo -e $YELLOW"Symbolic link created," $RESET
    echo -e $YELLOW"pointing to $LOGFILE" $RESET
    echo -e $YELLOW"Location is $LOGDIR/$LOGPREFIX-latest.log" $RESET
    echo "###################################################################"
else
    echo "###################################################################"
    echo -e $YELLOW"No symbolic link created" $RESET
    echo "###################################################################"
fi

echo

if [ $CLEAN == "clean" ]; then
    echo "###################################################################"
    echo -e $RED "Deleting old stuff..." $RESET
    echo "###################################################################"
    rm -f $SAMPLESDIR/*.jpg >> $LOGFILE 2>&1
#    rm -Rf $REPORTSDIR >> $LOGFILE 2>&1
    rm -Rf $CONTACTSDIR/*.jpg >> $LOGFILE 2>&1
#    rm -Rf $REENCODEDIR >> $LOGFILE 2>&1
    echo
fi

# create sampledir if necessary
if [ "$COPY" == "true" ]; then
    if [ -d "$SAMPLESDIR" ]; then
        echo "The directory $SAMPLESDIR already exists"
    else
        echo "Creating the directory $SAMPLESDIR"
        mkdir -p $SAMPLESDIR
    fi
fi

echo

# create contacts dir if necessary
if [ -d "$CONTACTSDIR" ]; then
    echo "The directory $CONTACTSDIR already exists"
else
    echo "Creating the directory $CONTACTSDIR"
    mkdir -p $CONTACTSDIR
fi

echo

# create captures dir if necessary
if [ -d "$CAPTURESDIR" ]; then
    echo "The directory $CAPTURESDIR already exists"
else
    echo "Creating the directory $CAPTURESDIR"
    mkdir -p $CAPTURESDIR
fi

echo

# create reports dir if necessary
if [ -d "$REPORTSDIR" ]; then
    echo "The directory $REPORTDIR already exists"
else
    echo "Creating the directory $REPORTSDIR"
    mkdir -p $REPORTSDIR
fi

echo

# check if copies will be made
if [ "$KEEP" == "yes" ]; then
    echo "You have chosen to keep the captures in $CAPTURESDIR"
else
    echo "You have chosen not to keep the captures in $CAPTURESDIR"
fi

echo

# starting the clock
STARTUPTIME=$(date +%s)

# remove spaces in filenames
$INSTALLDIR/$JSVIDPREVSDIR/rename.sh

# find videofiles and removing characters in the beginning
for TYPE in $TYPES
do
    find . -maxdepth 1 -iname "*.$TYPE" >> $TEMPDIR/$TEMPPREFIX.files1
    sed 's/^..//' $TEMPDIR/$TEMPPREFIX.files1 > $TEMPDIR/$TEMPPREFIX.files
done

# running the script to make captures and contactsheets
$INSTALLDIR/$JSVIDPREVSDIR/contactsheets.sh $CONFFILEDIR $TIME $LOGFILE

# will we keep the captures and the reencoded files
if [ $KEEP != "yes" ]; then
    echo "Deleting the captures..."
    rm -Rf $CAPTURESDIR >> $LOGFILE 2>&1
    echo
    echo "Deleting the reencoded files..."
    rm -Rf $REENCODEDIR >> $LOGFILE 2>&1
    echo
fi

# calculating the time it took
ENDTIME=$(date +%s)
DIFFTIME=$(( $ENDTIME - $STARTUPTIME ))
echo "##########################################################################"
echo -e $YELLOW"Whole operation took $DIFFTIME seconds" $RESET
#echo "Whole operation took $DIFFTIME seconds" >> $LOGFILE
echo "##########################################################################"
