#!/bin/bash

THISDIR=$(dirname $0)

source $THISDIR/shvidprevs.conf

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

if [ -h $INSTALLDIR/shvidprevs ]; then
   echo "Removing link"
   rm -f $INSTALLDIR/shvidprevs
else
    echo "Link does not exist"
fi

if [ -e $INSTALLDIR/$SHVIDPREVSDIR/shvidprevs.sh ]; then
    echo "Removing scripts"
    rm -f $INSTALLDIR/$SHVIDPREVSDIR/*.sh
else
    echo "Script does not exist"
fi

if [ -d $INSTALLDIR/$SHVIDPREVSDIR ]; then
    echo "Removing directory"
    rmdir --ignore-fail-on-non-empty $INSTALLDIR/$SHVIDPREVSDIR
else
    echo "Directory does not exist"
fi

echo

if [ -h $INSTALLDIR/shvidprevs ] || [ -e $INSTALLDIR/$SHVIDPREVSDIR/shvidprevs.sh ] || [ -d $INSTALLDIR/$SHVIDPREVSDIR ]; then
    echo "Everything could not be uninstalled"
    echo "Exiting"
    exit 1
else
    echo "Uninstall successful"
fi