#!/bin/bash
set -euo pipefail

bitrate=1024
crf=25
preset=slow
stopt=""
rotateff=""
deinterlace=""
directory=""
geometry=""
acodec="opus"
vcodec="x264"
options=""

while getopts "nq:cts:d:ig:a:v:" opt; do
	case "$opt" in 
		q) crf="$OPTARG" ;;
		c) # --rotate clockwise
		   rotateff=-vf\ transpose=1
		   rotate=--transform-type=90 
		   rotatefilter=vfilter=\"transform\",
	   	   ;;
		t) # rotate anti clockwise
		   rotateff=-vf\ transpose=2
		   rotate=--transform-type=270
		   rotatefilter=vfilter=\"transform\",
		   ;;

		s)
		   stopt=-to\ $OPTARG
		   stopvlc="--stop-time=$OPTARG"
		   ;;

		d) directory="$OPTARG" ;;
		i) deinterlace=-vf\ yadif ;;
		g) geometry=-vf\ scale=$OPTARG ;;
		a) acodec=$OPTARG ;;
		v) vcodec=$OPTARG ;;
	esac
done



shift $(($OPTIND - 1))

if [[ $acodec == "aac" ]]; then
	audio="-c:a libfdk_aac -b:a 96k"
	container=mp4
	options="$options -movflags +faststart"
elif [[ $acodec == "copy" ]]; then
	audio="-c:a copy"
	container=mkv
elif [[ $acodec == "opus" ]]; then
	audio="-c:a libopus -b:a 64k"
	container=mkv
elif [[ $acodec == "vorbis" ]]; then
	audio="-c:a libvorbis -aq 3"
	container=mkv	
fi

if [[ $container == "mkv" ]]; then
# 	duration=$(mediainfo --Inform="General;%Duration%" "$file")
	options="$options -reserve_index_space 2000"
fi

if [[ $vcodec == "copy" ]]; then
	video="-c:v copy"
elif [[ $vcodec == "x264" ]]; then
	video="-c:v libx264 -crf $crf"
elif [[ $vcodec == "x265" ]]; then
	video="-c:v libx265 -crf $crf"
fi

for file in "$@"; do

echo "Encoding $file"

if [ -z $directory ]; then
	newfile=${file%.*}_rs.$container
else
    newfile=$(basename "$file")
	newfile=$directory/${newfile%.*}_rs.$container
fi

#vlc -I dummy -vv $file $rotate --sout "#transcode{$rotatefilter vcodec=h264,vb=$bitrate,acodec=mp4a,ab=96}:standard{mux=mp4,dst=\"/tmp/$newfile\",access=file}" $stop vlc://quit
#vlc -I dummy $file $rotate --sout "#transcode{$rotatefilter vcodec=h264,fps=29.97, venc=x264{crf=$crf,preset=$preset,tune=film},acodec=mp4a,ab=96}:standard{mux=mp4,dst=\"$newfile\",access=file}" $stopvlc vlc://quit

# http://linuxfr.org/users/elyotna/journaux/hevc-vp9-x265-vs-libvpx
# https://sites.google.com/a/webmproject.org/wiki/ffmpeg/vp9-encoding-guide

STARTTIME=$(date +%s)
set -x
ffmpeg -y -i "$file" $geometry $stopt $deinterlace $rotateff $audio $video -preset $preset $options "${newfile}"
set +x
touch -r "$file" "${newfile}"
ELAPSEDTIMED=$(($(date +%s) - STARTTIME))

echo "${newfile} encoded in $ELAPSEDTIMED s"

done
