#!/bin/bash
set -euo pipefail

# TODO Manage subtitle addition
# ffmpeg -y -i video.mkv -f srt -i subtitle.srt -map 0:0 -map 0:1 -map 0:2  -map 1:0 -c copy -c:s srt -metadata:s:s:0 title=standard -metadata:s:s:0 language=eng video.mkv

bitrate=1024
declare -A defaultcrf
crf=
preset="-preset slow"
startt=""
stopt=""
rotate=""
deinterlace=""
directory=""
geometry=""
acodec="opus"
aquality="mid"
vcodec="vp9"
options=""
ext="_rs"
passes=("")

defaultcrf[x264]=23
defaultcrf[x265]=23
defaultcrf[vp9]=31
defaultcrf[x265]=23

function usage
{
cat << EOF
$0 [options] <file(s) to encode>
Options:
	-h  Display the usage
	-q <video quality> (default ${defaultcrf[x265]})>
	-c : Rotate the video 90° clockwise
	-p : Rotate the video 90° anti-clockwise (positive sense)
	-s <start time> : Start the encoded video at the given time (format for 5 minutes is 300, or 05:00)
	-e <end time> : Stop the video at the given time (format for 5 minutes is 300, or 05:00)
	-d <target directory> : Destination folder for the generated files
	-i : Deinterlace the video
	-g <XxY> : Resize the video (e.g 800x600)
	-a <audio codec> : Specify the audio codec (e.g : opus, vorbis, aac, copy)
	-A <audio quality> : Specify the audio quality (e.g low/mid/high) (default: mid). Note: the values depend on the codec
	-v <video codec> : Specify the video codec (e.g : x264, x265, copy, hevc_vaapi, none)
	-x <extension> : Add an extension suffix to the output filename (default : $ext if the output extension is the same as the input file)
EOF
exit 0
}

while getopts "hq:cps:e:d:ig:a:A:v:x:" opt; do
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


shift $(($OPTIND - 1))

if [[ $acodec == "aac" ]]; then
        if [[ $aquality == "low" ]]; then
            aquality=80k
        elif [[ $aquality == "mid" ]]; then
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
        elif [[ $aquality == "mid" ]]; then
            aquality=96k
        elif [[ $aquality == "high" ]]; then
            aquality=128k
        fi
	audio="-c:a libopus -b:a $aquality -af aformat=channel_layouts='stereo'"
elif [[ $acodec == "vorbis" ]]; then
        if [[ $aquality == "low" ]]; then
            aquality=3
        elif [[ $aquality == "mid" ]]; then
            aquality=4
        elif [[ $aquality == "high" ]]; then
            aquality=5
        fi
	audio="-c:a libvorbis -aq $aquality"
fi


hwaccel=""
if [[ $vcodec == "copy" ]]; then
	video="-c:v copy"
elif [[ $vcodec == "none" ]]; then
	video="-vn"
else
	[ -z $crf ] && crf=${defaultcrf[$vcodec]}
	
	if [[ $vcodec == "x264" ]]; then
		video="-c:v libx264 -crf $crf"
		preset="-preset slower"
	elif [[ $vcodec == "x265" ]]; then
		video="-c:v libx265 -crf $crf"
	elif [[ $vcodec == "hevc_vaapi" ]]; then
		video="-vaapi_device /dev/dri/renderD128 -c:v hevc_vaapi -vf format=nv12,hwupload -qp $crf"
		hwaccel="-hwaccel vaapi"
		preset=""
	elif [[ $vcodec == "vp9" ]]; then
		preset=""
		video="-c:v libvpx-vp9 -g 200 -threads 4 -tile-columns 2 -quality good -speed 1 -b:v 0 -crf $crf"
	#	video="-c:v libvpx-vp9 -threads 4 -tile-columns 6  -b:v 4M -crf $crf"
		passes=("-pass 1" "-pass 2")
	fi
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
	if ! [ -f "$file" ]; then echo "File $file does not exist"; exit 1; fi
done

for file in "$@"; do

echo "Encoding $file"

# Auto guess container for an audio extraction
if [[ $vcodec == "none" ]] && [[ $acodec == "copy" ]]; then
	container=$(ffprobe -v error -select_streams a:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 "$file")
fi

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
for pass in "${passes[@]}"; do
set -x
ffmpeg -y $hwaccel -i "$file" $geometry $startt $stopt $deinterlace $rotate $audio $video $preset $options $pass "${newfile}" < /dev/null
set +x
done
touch -r "$file" "${newfile}"
ELAPSEDTIMED=$(($(date +%s) - STARTTIME))

echo -e "${newfile} encoded in \033[01;32m$ELAPSEDTIMED s\033[00m"

done

