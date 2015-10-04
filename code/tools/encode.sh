#!/bin/bash
set -euo pipefail

bitrate=1024
defaultcrf=24
crf=
preset="-preset slow"
startt=""
stopt=""
rotate=""
deinterlace=""
directory=""
geometry=""
acodec="opus"
aquality="low"
vcodec="vp9"
options=""
ext="_rs"



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
	-A <audio codec> : Specify the audio quality (e.g low/high) (default: low). Note: the values depend on the codec
	-v <video codec> : Specify the video codec (e.g : x264, x265, copy)
	-x <extension> : Add an extension suffix to the output filename (default : $ext if the output extension is the same as the input file)
EOF
}

while getopts "hnq:cts:e:d:ig:a:A:v:x:" opt; do
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
		A) aquality=$OPTARG ;;
		v) vcodec=$OPTARG ;;
		x) ext=$OPTARG ;;
		h) usage ;;
	esac
done

[ -z $crf ] && crf=$defaultcrf

shift $(($OPTIND - 1))

if [[ $acodec == "aac" ]]; then
        if [[ $aquality == "low" ]]; then
            aquality=96k
        elif [[ $aquality == "high" ]]; then
            aquality=128k
        fi
	audio="-c:a libfdk_aac -b:a $aquality"
elif [[ $acodec == "copy" ]]; then
	audio="-c:a copy"
elif [[ $acodec == "opus" ]]; then
        if [[ $aquality == "low" ]]; then
            aquality=80k
        elif [[ $aquality == "high" ]]; then
            aquality=128k
        fi
	audio="-c:a libopus -b:a $aquality"
elif [[ $acodec == "vorbis" ]]; then
        if [[ $aquality == "low" ]]; then
            aquality=4
        elif [[ $aquality == "high" ]]; then
            aquality=3
        fi
	audio="-c:a libvorbis -aq $aquality"
fi



if [[ $vcodec == "copy" ]]; then
	video="-c:v copy"
elif [[ $vcodec == "x264" ]]; then
	video="-c:v libx264 -crf $crf"
elif [[ $vcodec == "x265" ]]; then
	video="-c:v libx265 -crf $crf"
elif [[ $vcodec == "vp9" ]]; then
	preset=""
	video="-c:v libvpx-vp9 -g 100 -threads 4 -tile-columns 6 -frame-parallel 0  -speed 2 -b:v 4M -crf $crf"
#	video="-c:v libvpx-vp9 -threads 4 -tile-columns 6  -b:v 3M -crf $crf"
fi

if [[ $acodec == "aac" ]]; then
    container=mp4
elif [[ $acodec != "aac" ]] && [[ $vcodec == "vp9" ]]; then
    container=webm
else
    container=mkv
fi

if [[ $container == "mkv" ]]; then
# 	duration=$(mediainfo --Inform="General;%Duration%" "$file")
	options="$options -reserve_index_space 2000"
elif [[ $container == "mp4" ]]; then
	options="$options -movflags +faststart"
fi

for file in "$@"; do

echo "Encoding $file"

# Use extension only if the output filename is the same as the input filename
if [ "$container" != "${file##*.}" ]; then
	ext=""
fi

if [ -z $directory ]; then
	newfile=${file%.*}$ext.$container
else
    newfile=$(basename "$file")
	newfile=$directory/${newfile%.*}.$container
fi

# http://linuxfr.org/users/elyotna/journaux/hevc-vp9-x265-vs-libvpx
# https://sites.google.com/a/webmproject.org/wiki/ffmpeg/vp9-encoding-guide

STARTTIME=$(date +%s)
set -x
ffmpeg -y -i "$file" $geometry $startt $stopt $deinterlace $rotate $audio $video $preset $options "${newfile}"
set +x
touch -r "$file" "${newfile}"
ELAPSEDTIMED=$(($(date +%s) - STARTTIME))

echo -e "${newfile} encoded in \033[01;32m$ELAPSEDTIMED s\033[00m"

done
