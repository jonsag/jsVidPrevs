#!/bin/bash

FILE=$1

echo
echo "Information of $FILE"
echo

# mplayer section ---------------------------------------------------------------------------

SEC=`mplayer -benchmark -vc null -vo null -nosound -nolirc -nojoystick $FILE | gawk -v VAR=V: '$1 == VAR { print $2 }'`

VIDEOCODEC=`mplayer -benchmark -vc null -vo null -nosound -nolirc -nojoystick $FILE | gawk -v VAR=VIDEO: '$1 == VAR { print $2 }'| sed 's/\[//g' | sed 's/\]//g'`
VIDEOBITRATE=`mplayer -benchmark -vc null -vo null -nosound -nolirc -nojoystick $FILE | gawk -v VAR=VIDEO: '$1 == VAR { print $7" "$8 }'`

echo "mplayer reports:"
echo "Length: $SEC"
echo "Video codec: $VIDEOCODEC"
echo "Video bitrate: $VIDEOBITRATE"
echo

# mencoder section ---------------------------------------------------------------------------

SEC=`mencoder -oac copy -ovc copy -o /dev/null $FILE | gawk -v VAR=Pos: '$1 == VAR { print $2 }'`

echo "mencoder reports:"
echo "Length: $SEC"
echo

# ffmpeg section ---------------------------------------------------------------------------

DUR=`ffmpeg -i $FILE 2>&1 | grep "Duration" | cut -d ' ' -f 4 | sed s/,//`

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

FILEWIDTH=`ffprobe -show_streams $FILE 2>/dev/null | grep "width=" | cut -d'=' -f2`
FILEHEIGHT=`ffprobe -show_streams $FILE 2>/dev/null | grep "height=" | cut -d'=' -f2`

VIDEOCODEC=`ffprobe -show_streams $FILE 2>/dev/null | grep -B2 "codec_type=video" | head -1 | gawk -F= '{print $2 }'`
AUDIOCODEC=`ffprobe -show_streams $FILE 2>/dev/null | grep -B2 "codec_type=audio" | head -1 | gawk -F= '{print $2 }'`

echo "ffmpeg reports:"
echo "Duration: $DUR"
echo "Length: $SEC"
echo "Video codec: $VIDEOCODEC"
echo "Audio codec: $AUDIOCODEC"
echo

# avconv section ---------------------------------------------------------------------------

DUR=`avconv -i $FILE 2>&1 | grep "Duration" | cut -d ' ' -f 4 | sed s/,//`

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

FILEWIDTH=`avprobe -show_streams $FILE 2>/dev/null | grep "width=" | cut -d'=' -f2`
FILEHEIGHT=`avprobe -show_streams $FILE 2>/dev/null | grep "height=" | cut -d'=' -f2`

VIDEOCODEC=`avprobe -show_streams $FILE 2>/dev/null | grep -B2 "codec_type=video" | head -1 | gawk -F= '{print $2 }'`
AUDIOCODEC=`avprobe -show_streams $FILE 2>/dev/null | grep -B2 "codec_type=audio" | head -1 | gawk -F= '{print $2 }'`

echo "avconv reports:"
echo "Duration: $DUR"
echo "Length: $SEC"
echo "Video codec: $VIDEOCODEC"
echo "Audio codec: $AUDIOCODEC"
echo
