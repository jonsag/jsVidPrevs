#!/bin/bash

THISDIR=$(dirname $0)

source $THISDIR/jsvidprevs.conf

echo

EXIT=""

if [ $(whoami) = "root" ]; then
  echo "You are root, and can run this script"
  echo
else
  echo "You are not root, but we will check if there is another way..."
  EXIT="yes"
fi

echo

if [ "$EXIT" == "yes" ]; then
    SYSTEM=`cat /proc/version | gawk -F_ '{ print $1 }'`
    if [ $SYSTEM == "CYGWIN" ]; then
        echo "You are lucky, you are on a CYGWIN system, so we will go right ahead."
        EXIT="no"
    fi
fi

if [ "$EXIT" == "yes" ]; then
    echo "Sorry, no luck"
    echo "Exiting..."
    exit 0
fi

echo

echo "Uninstalling..."
echo

if [ -h $INSTALLDIR/jsvidprevs ]; then
   echo "Removing link"
   rm -f $INSTALLDIR/jsvidprevs
else
    echo "Link does not exist"
fi

if [ -e $INSTALLDIR/$JSVIDPREVSDIR/jsvidprevs.sh ]; then
    echo "Removing scripts"
    rm -f $INSTALLDIR/$JSVIDPREVSDIR/*.sh
else
    echo "Script does not exist"
fi

if [ -d $INSTALLDIR/$JSVIDPREVSDIR ]; then
    echo "Removing directory"
    rmdir --ignore-fail-on-non-empty $INSTALLDIR/$JSVIDPREVSDIR
else
    echo "Directory does not exist"
fi

echo

if [ -h $INSTALLDIR/jsvidprevs ] || [ -e $INSTALLDIR/$JSVIDPREVSDIR/jsvidprevs.sh ] || [ -d $INSTALLDIR/$JSVIDPREVSDIR ]; then
    echo "Everything could not be uninstalled"
    echo "Exiting"
    exit 1
else
    echo "Uninstall successful"
fi