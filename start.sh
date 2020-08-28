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

cp /convert2mkv.sh /config/convert2mkv.sh
chown -R nobody:users /config

echo "[Info] Starting script"
bash /config/convert2mkv.sh
#su - nobody -c /config/convert2mkv.sh

echo "Stopping Container, script finished.."
