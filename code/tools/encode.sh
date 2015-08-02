#!/bin/bash
set -euo pipefail

bitrate=1024
crf=25
preset=slow
startt=""
stopt=""
rotate=""
deinterlace=""
directory=""
geometry=""
acodec="opus"
vcodec="x264"
options=""


function usage
{
cat << EOF
$0 [options] <file(s) to encode>
Options:
	-h  Display the usage
	-q <video quality> (default $crf)>
	-c : Rotate the video 90° clockwise
	-p : Rotate the video 90° anti-clockwise (positive sense)
	-s <start time> : Start the encoded video at the given time (format for 5 minutes is 300, or 05:00)
	-e <end time> : Stop the video at the given time (format for 5 minutes is 300, or 05:00)
	-d <target directory> : Destination folder for the generated files
	-i : Deinterlace the video
	-g <XxY> : Resize the video (e.g 800x600)
	-a <audio codec> : Specify the audio codec (e.g : opus, vorbis, aac, copy)
	-v <video codec> : Specify the video codec (e.g : x264, x265, copy)
EOF
}

while getopts "hnq:cts:e:d:ig:a:v:" opt; do
	case "$opt" in 
		q) crf="$OPTARG" ;;
		c) # --rotate clockwise
		   rotate=-vf\ transpose=1
	   	   ;;
		p) # rotate anti clockwise
		   rotate=-vf\ transpose=2
		   ;;
		s) startt=-ss\ $OPTARG ;;
		e) stopt=-to\ $OPTARG ;;
		d) directory="$OPTARG" ;;
		i) deinterlace=-vf\ yadif ;;
		g) geometry=-vf\ scale=$OPTARG ;;
		a) acodec=$OPTARG ;;
		v) vcodec=$OPTARG ;;
		h) usage ;;
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

#vlc -I dummy $file $rotate --sout "#transcode{$rotatefilter vcodec=h264,fps=29.97, venc=x264{crf=$crf,preset=$preset,tune=film},acodec=mp4a,ab=96}:standard{mux=mp4,dst=\"$newfile\",access=file}" $stopvlc vlc://quit

# http://linuxfr.org/users/elyotna/journaux/hevc-vp9-x265-vs-libvpx
# https://sites.google.com/a/webmproject.org/wiki/ffmpeg/vp9-encoding-guide

STARTTIME=$(date +%s)
set -x
ffmpeg -y -i "$file" $geometry $startt $stopt $deinterlace $rotate $audio $video -preset $preset $options "${newfile}"
set +x
touch -r "$file" "${newfile}"
ELAPSEDTIMED=$(($(date +%s) - STARTTIME))

echo "${newfile} encoded in $ELAPSEDTIMED s"

done
