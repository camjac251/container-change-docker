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

container="mkv"         # Choose output container (mkv; mp4 only)
forcefps="original"     # Choose 24, 25, 30, 60 etc (default "original")
vbitrate="auto"         # Video Bitrate Override (Valid options "K"; "M"; "G" eg. "10M" or "auto")
hw="cpu"                # Hardware Transcode Type (default "cpu", can use "vaapi" if available)
preset="medium"         # Preset for CPU encoding only. Disregarded if using vaapi
crf="22"                # CRF / QP for CPU encoding only. Disregarded if using vaapi (default "18")
tempdir="/tmp"          # Temporary directory for transcodes (required)
asamplerate="96000"     # Choose audio sample rate (default 44100)
overwrite="no"          # Overwrite original file (anything other than "yes" will result in a *.bak file)

####################################################
# You can set filetypes to parse here (remember to not use the same types as your container above)
####################################################

filetypes=("**/*.mp4" "**/*.mkv" "**/*.m4v" "**/*.avi" "**/*.3gp" "**/*.mpg" "**/*.mpeg" "**/*.flv" "**/*.webm" "**/*.ogv")

####################################################
# Don't change anything beyond this point!
####################################################

# Disable case sensativity

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

# Get and set video FPS

  if [ $forcefps = "original" ]
    then
      fps=""
    else
      fps=" -framerate "$forcefps
  fi

# Get video dimensions

  width=$( ffprobe -v error -select_streams v:0 -show_entries stream=width -of csv=s=x:p=0 "$i" )

  height=$( ffprobe -v error -select_streams v:0 -show_entries stream=height -of csv=s=x:p=0 "$i" )

# Set Video Bitrate

  if [ "$vbitrate" = "auto" ]
    then
      bitrate=$(( width * height ))
    else
      bitrate=$vbitrate
  fi

  echo "Bitrate (based on input resolution): " $bitrate

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

  if ffprobe -show_streams -loglevel quiet "$i" | grep "Rext" > /dev/null 2>&1
    then
      vcodec="rext"
  fi

  if ffprobe -show_streams -loglevel quiet "$i" | grep "Constrained Baseline" > /dev/null 2>&1
    then
      vcodec="constrained"
  fi

  if ffprobe -show_streams -loglevel quiet "$i" | grep "4:4:4" > /dev/null 2>&1
    then
      vcodec="444"
  fi

  if ffprobe -show_streams -loglevel quiet "$i" | grep "mpeg1video" > /dev/null 2>&1
    then
      vcodec="mpeg1video"
  fi

  if ffprobe -show_streams -loglevel quiet "$i" | grep "mpeg2video" > /dev/null 2>&1
    then
      vcodec="mpeg2video"
  fi

  if ffprobe -show_streams -loglevel quiet "$i" | grep "flv" > /dev/null 2>&1
    then
      vcodec="flv"
  fi

  if ffprobe -show_streams -loglevel quiet "$i" | grep "theora" > /dev/null 2>&1
    then
      vcodec="theora"
  fi

  if ffprobe -show_streams -loglevel quiet "$i" | grep "mpeg4" > /dev/null 2>&1
    then
      vcodec="mpeg4"
  fi

  if ffprobe -show_streams -loglevel quiet "$i" | grep "vp8" > /dev/null 2>&1
    then
      vcodec="vp8"
  fi

# Test input file for audio codec types

  if ffprobe -show_streams -loglevel quiet "$i" | grep "aac" > /dev/null 2>&1
    then
      acodec="aac"
  fi

  if ffprobe -show_streams -loglevel quiet "$i" | grep "ac3" > /dev/null 2>&1
    then
      acodec="ac3"
  fi

  if ffprobe -show_streams -loglevel quiet "$i" | grep "mp3" > /dev/null 2>&1
    then
      acodec="mp3"
  fi

  if ffprobe -show_streams -loglevel quiet "$i" | grep "vorbis" > /dev/null 2>&1
    then
      acodec="vorbis"
  fi

  if ffprobe -show_streams -loglevel quiet "$i" | grep "pcm_mulaw" > /dev/null 2>&1
    then
      acodec="pcm_mulaw"
  fi

# Set video conversion variables

  if [ "$hw" = "vaapi" ]

    then

      if [ "$vcodec" = "constrained" ]
        then
          vconvert='-vf '"format=p010,hwupload"' -c:v hevc_vaapi -b:v '"$bitrate"' -pix_fmt vaapi_vld'
      fi

      if [ "$vcodec" = "h263" ]
        then
          vconvert='-vf '"format=p010,hwupload"' -c:v hevc_vaapi -b:v '"$bitrate"' -pix_fmt vaapi_vld -force_key_frames 00:00:00.000 -q:v 6'
      fi

      if [ "$vcodec" = "rext" ]
        then
          vconvert='-vf '"format=p010,hwupload"' -c:v hevc_vaapi -b:v '"$bitrate"' -pix_fmt vaapi_vld'
      fi

      if [ "$vcodec" = "444" ]
        then
          vconvert='-vf '"format=p010,hwupload"' -c:v hevc_vaapi -b:v '"$bitrate"' -pix_fmt vaapi_vld'
      fi

      if [ "$vcodec" = "hevc" ]
        then
          vconvert='-vf '"format=p010,hwupload"' -c:v hevc_vaapi -b:v '"$bitrate"' -pix_fmt vaapi_vld'
      fi

      if [ "$vcodec" = "h264" ]
        then
          vconvert='-vf '"format=p010,hwupload"' -c:v hevc_vaapi -b:v '"$bitrate"' -pix_fmt vaapi_vld'
      fi

      if [ "$vcodec" = "mpeg1video" ]
        then
          vconvert='-vf '"format=p010,hwupload"' -c:v hevc_vaapi -b:v '"$bitrate"' -pix_fmt vaapi_vld'
      fi

      if [ "$vcodec" = "mpeg2video" ]
        then
          vconvert='-vf '"format=p010,hwupload"' -c:v hevc_vaapi -b:v '"$bitrate"' -pix_fmt vaapi_vld'
      fi

      if [ "$vcodec" = "flv" ]
        then
          vconvert='-vf '"format=p010,hwupload"' -c:v hevc_vaapi -b:v '"$bitrate"' -pix_fmt vaapi_vld -force_key_frames 00:00:00.000 -q:v 6'
      fi

      if [ "$vcodec" = "theora" ]
        then
          vconvert='-vf '"format=p010,hwupload"' -c:v hevc_vaapi -map 0:1 -b:v '"$bitrate"' -pix_fmt vaapi_vld'
	  fi

      if [ "$vcodec" = "mpeg4" ]
        then
          vconvert='-vf '"format=p010,hwupload"' -c:v hevc_vaapi -b:v '"$bitrate"' -pix_fmt vaapi_vld'
      fi

      if [ "$vcodec" = "vp8" ]
        then
          vconvert='-vf '"format=p010,hwupload"' -c:v hevc_vaapi -b:v '"$bitrate"' -pix_fmt vaapi_vld'
      fi

    else

      if [ "$vcodec" = "constrained" ]
        then
          vconvert='-c:v libx265 -b:v '"$bitrate"' -preset '"$preset"' -x265-params crf='"$crf"':qcomp=0.8:aq-mode=1:aq_strength=1.0:qg-size=16:psy-rd=0.7:psy-rdoq=5.0:rdoq-level=1:merange=44 -tune grain'
      fi

      if [ "$vcodec" = "h263" ]
        then
          vconvert='-c:v libx265 -b:v '"$bitrate"' -preset '"$preset"' -x265-params crf='"$crf"':qcomp=0.8:aq-mode=1:aq_strength=1.0:qg-size=16:psy-rd=0.7:psy-rdoq=5.0:rdoq-level=1:merange=44 -tune grain -force_key_frames 00:00:00.000 -q:v 6'
      fi

      if [ "$vcodec" = "rext" ]
        then
          vconvert='-c:v libx265 -b:v '"$bitrate"' -preset '"$preset"' -x265-params crf='"$crf"':qcomp=0.8:aq-mode=1:aq_strength=1.0:qg-size=16:psy-rd=0.7:psy-rdoq=5.0:rdoq-level=1:merange=44 -tune grain'
      fi

      if [ "$vcodec" = "444" ]
        then
          vconvert='-c:v libx265 -b:v '"$bitrate"' -preset '"$preset"' -x265-params crf='"$crf"':qcomp=0.8:aq-mode=1:aq_strength=1.0:qg-size=16:psy-rd=0.7:psy-rdoq=5.0:rdoq-level=1:merange=44 -tune grain'
      fi

      if [ "$vcodec" = "hevc" ]
        then
          vconvert='-c:v libx265 -b:v '"$bitrate"' -preset '"$preset"' -x265-params crf='"$crf"'qcomp=0.8:aq-mode=1:aq_strength=1.0:qg-size=16:psy-rd=0.7:psy-rdoq=5.0:rdoq-level=1:merange=44 -tune grain'
      fi

      if [ "$vcodec" = "h264" ]
        then
          vconvert='-c:v libx265 -b:v '"$bitrate"' -preset '"$preset"' -x265-params crf='"$crf"':qcomp=0.8:aq-mode=1:aq_strength=1.0:qg-size=16:psy-rd=0.7:psy-rdoq=5.0:rdoq-level=1:merange=44 -tune grain'
      fi

      if [ "$vcodec" = "mpeg1video" ]
        then
          vconvert='-c:v libx265 -b:v '"$bitrate"' -preset '"$preset"' -x265-params crf='"$crf"':qcomp=0.8:aq-mode=1:aq_strength=1.0:qg-size=16:psy-rd=0.7:psy-rdoq=5.0:rdoq-level=1:merange=44 -tune grain'
      fi

      if [ "$vcodec" = "mpeg2video" ]
        then
          vconvert='-c:v libx265 -b:v '"$bitrate"' -preset '"$preset"' -x265-params crf='"$crf"'qcomp=0.8:aq-mode=1:aq_strength=1.0:qg-size=16:psy-rd=0.7:psy-rdoq=5.0:rdoq-level=1:merange=44 -tune grain'
      fi

      if [ "$vcodec" = "flv" ]
        then
          vconvert='-c:v libx265 -b:v '"$bitrate"' -preset '"$preset"' -x265-params crf='"$crf"':qcomp=0.8:aq-mode=1:aq_strength=1.0:qg-size=16:psy-rd=0.7:psy-rdoq=5.0:rdoq-level=1:merange=44 -tune grain -force_key_frames 00:00:00.000 -q:v 6'
      fi

      if [ "$vcodec" = "theora" ]
        then
          vconvert='-c:v libx265 -map 0:1 -b:v '"$bitrate"' -preset '"$preset"' -x265-params crf='"$crf"':qcomp=0.8:aq-mode=1:aq_strength=1.0:qg-size=16:psy-rd=0.7:psy-rdoq=5.0:rdoq-level=1:merange=44 -tune grain'
	  fi

      if [ "$vcodec" = "mpeg4" ]
        then
          vconvert='-c:v libx265 -b:v '"$bitrate"' -preset '"$preset"' -x265-params crf='"$crf"':qcomp=0.8:aq-mode=1:aq_strength=1.0:qg-size=16:psy-rd=0.7:psy-rdoq=5.0:rdoq-level=1:merange=44 -tune grain'
      fi

      if [ "$vcodec" = "vp8" ]
        then
          vconvert='-c:v libx265 -b:v '"$bitrate"' -preset '"$preset"' -x265-params crf='"$crf"':qcomp=0.8:aq-mode=1:aq_strength=1.0:qg-size=16:psy-rd=0.7:psy-rdoq=5.0:rdoq-level=1:merange=44 -tune grain'
      fi
      
  fi

# Set audio conversion variables

  if [ "$acodec" = "aac" ]
    then
      aconvert='-c:a copy -strict experimental'
  fi

  if [ "$acodec" = "ac3" ]
    then
      aconvert='-c:a copy'
  fi

  if [ "$acodec" = "mp3" ]
    then
      aconvert='-c:a aac -ar '"$asamplerate"' -strict experimental'
  fi

  if [[ $i == *.ogv ]]
    then
      if [ "$acodec" = "vorbis" ]
        then
          aconvert='-c:a aac -ar '"$asamplerate"' -strict experimental -map 0:2'
      fi
    else
      if [ "$acodec" = "vorbis" ]
        then
          aconvert='-c:a aac -ar '"$asamplerate"' -strict experimental'
      fi
  fi

  if [ "$acodec" = "pcm_mulaw" ]
    then
      aconvert='-c:a aac -ar '"$asamplerate"' -strict experimental'
  fi

# Text Output

echo "Input File:" "$filename"
echo "Input Video Codec:" "$vcodec"
echo "Working..."

# Choose CPU or vaapi transcoding options

  if [ "$hw" = "vaapi" ]
    then
      transcode="ffmpeg -vaapi_device /dev/dri/renderD128" # -hide_banner -loglevel panic 
    else
      transcode="ffmpeg" # -hide_banner -loglevel panic
  fi

# Run transcode

$transcode -y -i "$i" $vconvert $fps $aconvert $tempdir/"${filename%%.*}".$container && \

# Overwrite logic

  if [ "$overwrite" = "yes" ]
    then
      mv $tempdir/"${filename%%.*}".$container "$dirpath"/"${filename%%.*}".$container
    else
      mv --backup --suffix=.bak $tempdir/"${filename%%.*}".$container "$dirpath"/"${filename%%.*}".$container
  fi

echo "Completed"

# Reset variables

  vcodec=""
  acodec=""
  vconvert=""
  aconvert=""
  transcode=""

  done
shopt -u nocaseglob
