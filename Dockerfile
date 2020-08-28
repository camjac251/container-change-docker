FROM ubuntu

MAINTAINER camjac251

# install packages
RUN apt-get update && apt-get install -y curl wget aria2
 
#make config folder
RUN \
 mkdir /config 
 
#Add start script
ADD start.sh /start.sh
RUN chmod +x /start.sh

ADD ffmpeg-container-change.sh /ffmpeg-container-change.sh
RUN chmod +x /ffmpeg-container-change.sh

VOLUME ["/config"]
VOLUME ["/work"]

WORKDIR /work

ENTRYPOINT ["/start.sh"]
