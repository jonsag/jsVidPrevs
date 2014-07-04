#!/bin/bash

echo "Renaming files, if necessary"
echo

for FILE in *
do

# check if it is a directory
    if [ -d "$FILE" ]; then
	echo "$FILE is a directory"
    else
	if [ -s "$FILE" ]; then

# removing spaces
	    if [ "$FILE" != `echo "$FILE" | sed -e 's/  */_/g' -e 's/_-_/-/g'` ]; then
		echo "Removing spaces from $FILE"
		mv "$FILE" `echo "$FILE" | sed -e 's/  */_/g' -e 's/_-_/-/g'`
		echo
	    fi

# removing åäö
	    if [ "$FILE" != `echo "$FILE" | sed -e 's/å/a/g' -e 's/Å/A/g' -e 's/ä/a/g' -e 's/Ä/A/g' -e 's/ö/o/g' -e 's/Ö/O/g'` ]; then
		echo "Removing åäö from $FILE"
		mv "$FILE" `echo "$FILE" | sed -e 's/å/a/g' -e 's/Å/A/g' -e 's/ä/a/g' -e 's/Ä/A/g' -e 's/ö/o/g' -e 's/Ö/O/g'`
		echo
	    fi

# remove capitals
#	    if [ `echo $FILE | grep [ABCDEFGHIJKLMNOPQRSTUVWXYZ]` ]; then
#		echo "Removing capitals from $FILE"
#		NEWFILE=$(echo $FILE | tr A-Z a-z )
#		[ ! -f $NEWFILE ] && mv "$FILE" $NEWFILE
#		echo
#	    fi
	fi
    fi
done

echo
