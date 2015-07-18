#!/bin/bash
set -euo pipefail

bitrate=1024
crf=26
audio="-c:a libfdk_aac -b:a 96k"
#audio=-c:a libvorbis -aq 3
preset=slow
x265=0
stopt=""
rotateff=""
deinterlace=""
directory=""
# set -x
# --rotate clockwise
	while getopts "nq:cts:d:i" opt; do
	case "$opt" in 
		n) x265=1 ;;
		q) crf="$OPTARG" ;;
		c) 
		   rotateff=-vf\ transpose=1
		   rotate=--transform-type=90 
		   rotatefilter=vfilter=\"transform\",
	   	   ;;
		t) 
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
	esac
done

shift $(($OPTIND - 1))

for file in "$@"; do

echo "Encoding $file"

if [ -z $directory ]; then
	newfile=${file%.*}_rs.mp4
else
    newfile=$(basename "$file")
	newfile=$directory/${newfile%.*}_rs.mp4
fi

#vlc -I dummy -vv $file $rotate --sout "#transcode{$rotatefilter vcodec=h264,vb=$bitrate,acodec=mp4a,ab=96}:standard{mux=mp4,dst=\"/tmp/$newfile\",access=file}" $stop vlc://quit
#vlc -I dummy $file $rotate --sout "#transcode{$rotatefilter vcodec=h264,fps=29.97, venc=x264{crf=$crf,preset=$preset,tune=film},acodec=mp4a,ab=96}:standard{mux=mp4,dst=\"$newfile\",access=file}" $stopvlc vlc://quit

# ffmpeg -i INPUT -f yuv4mpegpipe -pix_fmt yuv420p - | x265 --y4m -o encoded.265 -
# ffmpeg -i encoded.265 -i INPUT -map 0 -map 1:a -c copy out.mp4

if [[ ${x265} -eq 1 ]]; then
#http://linuxfr.org/users/elyotna/journaux/hevc-vp9-x265-vs-libvpx
#The above command will copy over the audio as is. If that doesn't work, convert the audio to AAC by replacing copy with libfdk_aac, libfaac or arc (ordered quality-wise)
#x265 --input $file --pass 1 --bitrate <bitrate> --preset slower --stats <input>.stats /dev/null
#x265 --input $file --pass 2 --bitrate <bitrate> --preset slower --stats <input>.stats out.hevc
#ffmpeg -y -i $file -c:v libx265 -crf $crf $newfile_x265.mp4
STARTTIME265=$(date +%s)
ffmpeg -y -i "$file" $stopt $deinterlace $rotateff $audio -c:v libx265 -preset $preset -crf $crf "${newfile}_x265.mp4"
ELAPSEDTIMED265=$(($(date +%s) - $STARTTIME265))
fi

STARTTIME264=$(date +%s)
# ffmpeg -y -i $file -vcodec libx264 -b:v ${bitrate}k -pass 1 -preset slower -f h264 /dev/null
# ffmpeg -y -i $file -c:v libx264 -b:v ${bitrate}k -pass 2 -preset slower ${newfile}_x264.mkv
set -x
ffmpeg -y -i "$file" $stopt $deinterlace $rotateff $audio -c:v libx264 -preset $preset -crf $crf -tune film -movflags +faststart "${newfile}"
set +x
ELAPSEDTIMED264=$(($(date +%s) - $STARTTIME264))

if [ $x265 -eq 1 ]; then
	echo "x265 : ${newfile}_x265.mp4 - $ELAPSEDTIMED265 s"
fi
echo "${newfile} encoded in $ELAPSEDTIMED264 s"

done
