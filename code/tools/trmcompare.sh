#!/bin/sh

logfile=""
browseddir="."

while getopts "i:" option ; do
	case $option in
		i ) logfile=$OPTARG ;;
	esac

done

#echo $logfile

shift $((OPTIND - 1))

if [ $# -ne 0 ] ; then
	browseddir=""
fi

while [ $# -ne 0 ] ; do
	echo "Parametre en plus " $1
	browseddir=${browseddir}" $1"
	shift
done

#echo $browseddir
if [ "$logfile" == "" ] ; then
	logfile=/tmp/trmlog 
	find $browseddir -name '*.mp3' -exec trm '{}' ';' -print0 | tr '\n\000' ' \n' | sort > $logfile

else
	if [ ! -r $logfile ] ; then
		echo "Please specify a valid file"
		exit;
	fi

fi

cat $logfile | uniq -D -w 36 > /tmp/duplicates
/home/dalmat/comparetrmlist.pl /tmp/duplicates
