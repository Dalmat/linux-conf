#!/bin/bash
# -*- coding: UTF8 -*-
mpc="mpc -h athena"

# Script to launch a web m3u or pls playlist (web radio) on mpd using mpc
# Provide pls/m3u file as input parameter

# Extract file extension
EXT=`echo "${1##*.}" | tr A-Z a-z`

case "$EXT" in
          "pls"   ) 
          PL=`grep '^File[0-9]*' $1 | sed -e 's/^File[0-9]*=//'`
          ;;

          "m3u" )
          PL=`cat $1 | sed -e '/^#/D'`
          ;;

          * )
          echo "Filename without a valid extension"
          exit 1;;
  esac

# Launch mpd daemon if needed
#if ! [ -e ~/.mpd/pid ]; then
#        mpd
#fi

# Clear old playlist, add new playlist and play
$mpc clear
$mpc add "$PL"
$mpc play
