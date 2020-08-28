#!/bin/bash

#Give message when starting the container
printf "\n \n \n ------------------------Starting container ------------------------ \n \n \n"

# Configure user nobody to match unRAID's settings
#export DEBIAN_FRONTEND="noninteractive"
usermod -u 99 nobody
usermod -g 100 nobody
usermod -d /home nobody
chown -R nobody:users /home

#chsh -s /bin/bash nobody

# install ffmpeg
cd /config
wget https://raw.githubusercontent.com/q3aql/ffmpeg-install/master/ffmpeg-install -O /config/ffmpeg-install
chmod a+x /config/ffmpeg-install
/config/ffmpeg-install --install
/config/ffmpeg-install --update

wget https://raw.githubusercontent.com/camjac251/container-change-docker/master/ffmpeg-container-change.sh -O /config/ffmpeg-container-change.sh
chmod a+x /config/ffmpeg-container-change.sh
chown -R nobody:users /config

echo "[Info] Entering work folder"
cd /work

echo "[Info] Starting script"
bash /config/ffmpeg-container-change.sh
#su - nobody -c /config/ffmpeg-container-change.sh

echo "Stopping Container, script finished.."
