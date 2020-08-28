#!/bin/bash
# A simple script to convert all files in a given folder to a playable MKV format

####################################################
# Workarounds for known issues
####################################################
#
# If it fails with a "No Interpreter" error, try running: sed -i -e 's/\r$//' convert2mkv.sh
#
####################################################
# Edit these variables as required (do not work yet)
####################################################

container="m2ts"         # Choose output container
preset="medium"         # Preset for CPU encoding only.
crf="1"                # CRF / QP for CPU encoding only.
tempdir="/tmp"          # Temporary directory for transcodes (required)
overwrite="no"          # Overwrite original file (anything other than "yes" will result in a *.bak file)

####################################################
# You can set filetypes to parse here (remember to not use the same types as your container above)
####################################################

filetypes=("**/*.mkv")

####################################################
# Don't change anything beyond this point!
####################################################

# Disable case sensitivity

shopt -s nocaseglob
shopt -s globstar

# Set variables to ""

  vcodec=""
  vconvert=""

# Search file type

  for i in ${filetypes[*]}; do
  path=$(readlink -m "$i")
  filename="${path##*/}"
  dirpath=${path%/*}
  echo "Currently Testing File: " "$filename"

# Test input file for video codec types

  if ffprobe -show_streams -loglevel quiet "$i" | grep "h264" > /dev/null 2>&1
    then
      vcodec="h264"
  fi

  if ffprobe -show_streams -loglevel quiet "$i" | grep "h263" > /dev/null 2>&1
    then
      vcodec="h263"
  fi

  if ffprobe -show_streams -loglevel quiet "$i" | grep "h265" > /dev/null 2>&1
    then
      vcodec="hevc"
  fi

  if ffprobe -show_streams -loglevel quiet "$i" | grep "hevc" > /dev/null 2>&1
    then
      vcodec="hevc"
  fi

  if ffprobe -show_streams -loglevel quiet "$i" | grep "mpeg4" > /dev/null 2>&1
    then
      vcodec="mpeg4"
  fi

  if ffprobe -show_streams -loglevel quiet "$i" | grep "vc1" > /dev/null 2>&1
    then
      vcodec="vc1"
  fi

# Set video conversion variables

      if [ "$vcodec" = "h263" ]
        then
          vconvert='-c:v copy -sn -an'
      fi

      if [ "$vcodec" = "h264" ]
        then
          vconvert='-c:v copy -sn -an'
      fi

      if [ "$vcodec" = "hevc" ]
        then
          vconvert='-c:v copy -sn -an'
      fi

      if [ "$vcodec" = "mpeg4" ]
        then
          vconvert='-c:v libx264 -intra -crf '"$crf"' -preset '"$preset"' -sn -an'
      fi

      if [ "$vcodec" = "vc1" ]
        then
          vconvert='-c:v libx264 -intra -crf '"$crf"' -preset '"$preset"' -sn -an'
      fi

# Text Output

echo "Input File:" "$filename"
echo "Input Video Codec:" "$vcodec"
echo "Working..."

# Run transcode

ffmpeg -y -i "$i" $vconvert $tempdir/"${filename%.*}".$container && \
ffmpeg -y -i "$i" $tempdir/"${filename%.*}"_audio.wav && \

# Overwrite logic

  if [ "$overwrite" = "yes" ]
    then
      mv $tempdir/"${filename%.*}".$container "$dirpath"/"${filename%.*}".$container
      mv $tempdir/"${filename%.*}"_audio.wav "$dirpath"/"${filename%.*}"_audio.wav
    else
      mv --backup --suffix=.bak $tempdir/"${filename%.*}".$container "$dirpath"/"${filename%.*}".$container
      mv --backup --suffix=.bak $tempdir/"${filename%.*}"_audio.wav "$dirpath"/"${filename%.*}"_audio.wav
  fi

echo "Completed"

# Reset variables

  vcodec=""
  acodec=""
  vconvert=""

  done
shopt -u nocaseglob
