#!/bin/bash

CONFFILEDIR=$1
TIME=$2
LOGFILE=$3

# read conf file
source $CONFFILEDIR/shvidprevs.conf

# these are the files that will be processed
FILES="$TEMPDIR/$TEMPPREFIX.files"

# count how we are doing
COUNTER=0

# count how many files to process
NO=`cat $FILES | wc -l`

echo -e $YELLOW "These are the files that will be processed" $RESET
echo "----------------------------------------------------------"
cat $FILES
echo "----------------------------------------------------------"
echo -e $GREEN "That's a total of $NO files" $RESET
echo

# calculate the number if screenshots
let "NOPICS = $WIDTH*$HEIGHT"
echo -e $YELLOW "Will create a $WIDTH by $HEIGHT grid, which will make a total of $NOPICS frames" $RESET
echo

# calculate middle of target width
let "HMIDDLE = $TARGETWIDTH/2"

# calculating text placement
let "FIRSTLINE = $TEXTHEIGHT/5-5"
let "SECONDLINE = 2*$TEXTHEIGHT/5-5"
let "THIRDLINE = 3*$TEXTHEIGHT/5-5"
let "FOURTHLINE = 4*$TEXTHEIGHT/5-5"
let "FIFTHLINE = $TEXTHEIGHT-5"

# doing the actual process
for FILE in `cat $FILES`
do

(( COUNTER++ ))

echo -e $YELLOW "Processing file no $COUNTER of $NO" $RESET

# check if there already is a screenshot
    if [ -e $CONTACTSDIR/$FILE.jpg ]; then
	echo -e $YELLOW "Screenshot $CONTACTSDIR/$FILE.jpg already exist" $RESET
	echo "-----------------------------------------------------------------------------------"
	echo
	echo "$CONTACTSDIR/$FILE.jpg" >> $REPORTSDIR/report-$TIME.txt
	echo "Already existed" >> $REPORTSDIR/report-$TIME.txt
	echo  >> $REPORTSDIR/report-$TIME.txt
    else 

# resetting variables
	PICS=""
	VIDEOBITRATE=""
	VIDEOCODEC=""
	AUDIOCODEC=""

# resetting possible errors
	CAPERR="0"
	CONTACTERR="0"

# finding out filesize, if not done already
	FILESIZE=`ls -lh $FILE | gawk '{ print $5 }'`

	echo -e $YELLOW "Looking up $FILE using $DURPREF ..." $RESET
	echo

	if [ $DURPREF == "mplayer" ]; then

# mplayer lookup
	    SEC=`mplayer -benchmark -vc null -vo null -nosound -nolirc -nojoystick $FILE | gawk -v VAR=V: '$1 == VAR { print $2 }'`

	    VIDEOCODEC=`mplayer -benchmark -vc null -vo null -nosound -nolirc -nojoystick $FILE | gawk -v VAR=VIDEO: '$1 == VAR { print $2 }'| sed 's/\[//g' | sed 's/\]//g'`
	    VIDEOBITRATE=`mplayer -benchmark -vc null -vo null -nosound -nolirc -nojoystick $FILE | gawk -v VAR=VIDEO: '$1 == VAR { print $7" "$8 }'`

	else
	    if [ $DURPREF == "mencoder" ]; then

# mencoder lookup
		SEC=`mencoder -oac copy -ovc copy -o /dev/null $FILE | gawk -v VAR=Pos: '$1 == VAR { print $2 }'`

	    else
		if [ $DURPREF == "ffmpeg" ]; then

# ffmpeg lookup
		    DUR=`ffmpeg -i $FILE 2>&1 | grep "Duration" | cut -d ' ' -f 4 | sed s/,//`

# converting duration to seconds
		    $INSTALLDIR/$SHVIDPREVSDIR/dur_to_sec.sh $DUR $CONFFILEDIR
		    SEC=`cat $TEMPDIR/$TEMPPREFIX.sec`
		    rm -f $TEMPDIR/$TEMPPREFIX.sec

		    FILEWIDTH=`ffprobe -show_streams $FILE 2>/dev/null | grep "width=" | cut -d'=' -f2`
		    FILEHEIGHT=`ffprobe -show_streams $FILE 2>/dev/null | grep "height=" | cut -d'=' -f2`

		    VIDEOCODEC=`ffprobe -show_streams $FILE 2>/dev/null | grep -B2 "codec_type=video" | head -1 | gawk -F= '{print $2 }'`
		    AUDIOCODEC=`ffprobe -show_streams $FILE 2>/dev/null | grep -B2 "codec_type=audio" | head -1 | gawk -F= '{print $2 }'`
		else
		    if [ $DURPREF == "avconv" ]; then

# avconv lookup
			DUR=`avconv -i $FILE 2>&1 | grep "Duration" | cut -d ' ' -f 4 | sed s/,//`

# converting duration to seconds
			$INSTALLDIR/$SHVIDPREVSDIR/dur_to_sec.sh $DUR $CONFFILEDIR
			SEC=`cat $TEMPDIR/$TEMPPREFIX.sec`
			rm -f $TEMPDIR/$TEMPPREFIX.sec

			FILEWIDTH=`avprobe -show_streams $FILE 2>/dev/null | grep "width=" | cut -d'=' -f2`
			FILEHEIGHT=`avprobe -show_streams $FILE 2>/dev/null | grep "height=" | cut -d'=' -f2`

			VIDEOCODEC=`avprobe -show_streams $FILE 2>/dev/null | grep -B2 "codec_type=video" | head -1 | gawk -F= '{print $2 }'`
			AUDIOCODEC=`avprobe -show_streams $FILE 2>/dev/null | grep -B2 "codec_type=audio" | head -1 | gawk -F= '{print $2 }'`
		    else
			if [ $DURPREF == "mediainfo" ]; then

# mediainfo lookup
			    DUR=`mediainfo '--Inform=General;%Duration/String3%' $FILE`

# converting duration to seconds
			    $INSTALLDIR/$SHVIDPREVSDIR/dur_to_sec.sh $DUR $CONFFILEDIR
			    SEC=`cat $TEMPDIR/$TEMPPREFIX.sec`
			    rm -f $TEMPDIR/$TEMPPREFIX.sec

			    FILESIZE=`mediainfo '--Inform=General;%FileSize/String%' $FILE`

			    FILEWIDTH=`mediainfo '--Inform=Video;%Width%' $FILE`
			    FILEHEIGHT=`mediainfo '--Inform=Video;%Height%' $FILE`

			    ASPECTRATIO=`mediainfo '--Inform=Video;%AspectRatio/String%' $FILE`

			    VIDEOCODEC=`mediainfo '--Inform=Video;%CodecID/Hint%' $FILE`
			    if [ -z "$VIDEOCODEC" ] || [ "$VIDEOCODEC" == "Microsoft" ]; then
				VIDEOCODEC=`mediainfo '--Inform=Video;%Format%' $FILE`
			    fi
			    VIDEOBITRATE=`mediainfo '--Inform=Video;%BitRate/String%' $FILE`

			    AUDIOCODEC=`mediainfo '--Inform=Audio;%CodecID/Hint%' $FILE`
			    if [ -z "$AUDIOCODEC" ]; then
				AUDIOCODEC=`mediainfo '--Inform=Audio;%Format%' $FILE`
			    fi
			    AUDIOBITRATE=`mediainfo '--Inform=Audio;%BitRate/String%' $FILE`

			    FRAMERATE=`mediainfo '--Inform=Video;%FrameRate/String%' $FILE`
			    BITRATE=`mediainfo '--Inform=General;%BitRate/String%' $FILE`
			else

# wrong option
			    echo "You have an illegal option for DURPREF in your configuration file"
			    echo "Please correct this!"
			    echo "Exiting.."
			    exit 1
			fi
		    fi
		fi
	    fi
	fi

# printing out the results
	echo -e $GREEN "$DUR or $SEC seconds long, and $FILESIZE big" $RESET
	echo -e $GREEN "$FILEWIDTH by $FILEHEIGHT pixels large, and the aspectratio is $ASPECTRATIO" $RESET
	echo -e $GREEN "The videocodec used is $VIDEOCODEC, and the video bitrate is $VIDEOBITRATE" $RESET
	echo -e $GREEN "The audiocodec used is $AUDIOCODEC, and the audio bitrate is $AUDIOBITRATE" $RESET
	echo -e $GREEN "The framerate is $FRAMERATE, and the overall bitrate is $BITRATE" $RESET
	echo

# how many loops will we run
	let "LOOPS = $NOPICS-1"

# what will be the increment for each capture
	let "INCREMENTS = ($SEC-$STARTOFFSET-$ENDOFFSET)/$LOOPS"

# what is the offset for the first screenshot
	STEP=$STARTOFFSET

# extraction of screenshots start here
	if [ $TESTMODE == "yes" ]; then
	    echo "Running in testmode, no screenshots will be made"
	    echo
	else
	    echo -e $YELLOW "Capturing frames using $ENCPREF ..." $RESET
	    for SHOT in $(eval echo {1..$NOPICS})
	    do
		if [ $ENCPREF == "mplayer" ]; then

# mplayer extraction
		    echo -e $YELLOW "mplayer taking screenshot number $SHOT at $STEP seconds"
		    mplayer -nosound -ss $STEP -frames 1 -vo jpeg $FILE >> $LOGFILE 2>&1
		    mv 00000001.jpg $CAPTURESDIR/$FILE-$SHOT.jpeg >> $LOGFILE 2>&1
		    CAPERR=$?

# check if there was an error
		    if [ $CAPERR != "0" ]; then
			echo -e $RED "There was an error capturing screenshot!" $RESET
		    fi
		    
		else
		    if [ $ENCPREF == "mencoder" ]; then

# mencoder extraction
			echo -e $RED "mencoder not available for this at the moment" $RESET
			exit 0

		    else
			if [ $ENCPREF == "ffmpeg" ]; then

# ffmpeg extraction
			    echo -e $YELLOW "ffmpeg taking screenshot number $SHOT at $STEP seconds" $RESET
			    ffmpeg  -itsoffset -$STEP -i $FILE -vframes 1 $CAPTURESDIR/$FILE-$SHOT.jpeg >> $LOGFILE 2>&1
			else
			    if [ $ENCPREF == "vlc" ]; then

# vlc extraction
				echo -e $RED "vlc not available for this at the moment" $RESET
				exit 0
			    else

# wrong option chosen
				echo -e $RED "You have an illegal option for DURPREF in your configuration file" $RESET
				echo -e $YELLOW "Please correct this!" $RESET
				echo -e $YELLOW "Exiting.." $RESET
				exit 1
			    fi
			fi
		    fi
		fi

# add capture to the list
		PICS="$PICS $CAPTURESDIR/$FILE-$SHOT.jpeg"

# do the inrementation
		let "STEP = $STEP+$INCREMENTS"

	    done

	    echo

# reencode if there was an error
	    if [ $CAPERR != "0" ]; then
		echo -e $YELLOW "Possibly a time error on the file" $RESET
		echo -e $GREEN "Trying to reencode..." $RESET
		$INSTALLDIR/$SHVIDPREVSDIR/reencode.sh $CONFFILEDIR $TIME $LOGFILE $FILE
	    fi

# do some calculations
	    echo -e $YELLOW "Doing some more calculations..." $RESET
	    RATIO=`echo "scale=2; $FILEWIDTH / $FILEHEIGHT" | bc`

	    let "SHOTWIDTH = ($TARGETWIDTH-(2*$SPACINGH*$WIDTH)-(2*$FRAME*$WIDTH))/$WIDTH"
	    let "SHOTHEIGHT = ($TARGETHEIGHT-(2*$SPACINGV*$HEIGHT)-(2*$FRAME*$HEIGHT)-$TEXTHEIGHT)/$HEIGHT"
	    echo -e $GREEN "Shotsize will be $SHOTWIDTH x $SHOTHEIGHT" $RESET
	    echo

            echo -e $YELLOW "Creating contactsheet from these images..." $RESET

# doing the actual contactsheet
	    montage -background $BACKGROUND -quality $QUALITY -frame $FRAME -tile ${WIDTH}x${HEIGHT} -geometry ${SHOTWIDTH}x${SHOTHEIGHT}+${SPACINGH}+${SPACINGV} $PICS $CONTACTSDIR/$FILE.jpg  >> $LOGFILE 2>&1
	    CONTACTERR=$?

# check if there was an error creating contactsheet
	    if [ $CONTACTERR != "0" ]; then
		echo -e $RED "There was an error creating the contactsheet!" $RESET
		echo "$FILE" >> $REPORTSDIR/faulty_sheets-$TIME.txt
	    else
		echo "$FILE" >> $REPORTSDIR/successful_sheets-$TIME.txt
	    fi

# if file was not created, do so now
	    if [ -a "$CONTACTSDIR/$FILE.jpg" ]; then
		echo -e $GREEN "File was created" $RESET
	    else
		echo -e $RED "File was not created, creating it now..."
		convert -size ${TARGETWIDTH}x${TARGETHEIGHT} canvas:$BACKGROUND $CONTACTSDIR/$FILE.jpg
	    fi

	    echo

# add empty space at top
	    convert $CONTACTSDIR/$FILE.jpg -background $BACKGROUND -gravity south -extent ${TARGETWIDTH}x${TARGETHEIGHT} $CONTACTSDIR/$FILE.jpg >> $LOGFILE 2>&1

# convert seconds to time again
	    LENGTH=`echo - | gawk -v "S=$SEC" '{printf "%dh:%dm:%ds",S/(60*60),S%(60*60)/60,S%60}'`

# add the text
	    convert $CONTACTSDIR/$FILE.jpg -fill $TEXTFILL -pointsize $POINTSIZE \
		-annotate +20+$FIRSTLINE "Filename: $FILE" \
		-annotate +20+$SECONDLINE "Length: $LENGTH" \
		-annotate +20+$THIRDLINE "Filesize: $FILESIZE" \
		-annotate +20+$FOURTHLINE "Resolution: $FILEWIDTH x $FILEHEIGHT" \
		-annotate +20+$FIFTHLINE "Aspectratio: $ASPECTRATIO - $RATIO" \
		-annotate +$HMIDDLE+$SECONDLINE "Video codec / bitrate: $VIDEOCODEC / $VIDEOBITRATE" \
		-annotate +$HMIDDLE+$THIRDLINE "Audio codec / bitrate: $AUDIOCODEC / $AUDIOBITRATE" \
		-annotate +$HMIDDLE+$FOURTHLINE "Overall bitrate: $BITRATE" \
		-annotate +$HMIDDLE+$FIFTHLINE "Framerate: $FRAMERATE" \
		$CONTACTSDIR/$FILE.jpg

# create report file
	    echo -e "$FILE\n$LENGTH\t$FILESIZE\t$FILEWIDTH x $FILEHEIGHT\t$ASPECTRATIO\t$RATIO\t$VIDEOCODEC\t$VIDEOBITRATE\t$AUDIOCODEC\t$AUDIOBITRATE\t$BITRATE\t$FRAMERATE" >> $REPORTSDIR/report-$TIME.txt

	    if [ $CAPERR != "0" ]; then
		echo "Error..." >> $REPORTSDIR/report-$TIME.txt
	    else
		echo "Successful!" >> $REPORTSDIR/report-$TIME.txt
	    fi

	    echo >> $REPORTSDIR/report-$TIME.txt

# put error on the sheet
	    if [ $CAPERR != "0" ]; then
		let "HERROR = $TARGETWIDTH-$SHOTWIDTH+$SPACINGH"
		let "VERROR = $TARGETHEIGHT-$SHOTHEIGHT+$SPACINGV"
		let "ERRORPOINTSIZE = $POINTSIZE+5"

		convert $CONTACTSDIR/$FILE.jpg -fill $ERRORTEXTFILL -pointsize $ERRORPOINTSIZE \
		    -annotate +$HERROR+$VERROR "There was an error\ncreating this\ncontactsheet" \
		    $CONTACTSDIR/$FILE.jpg
	    fi

	    echo -e $GREEN "Contactsheet created at $CONTACTSDIR/$FILE.jpg" $RESET
	    echo "-----------------------------------------------------------------------------------"
	    echo
	fi
    fi
done

echo
