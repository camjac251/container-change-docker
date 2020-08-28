FROM ubuntu

MAINTAINER camjac251

# install packages
RUN apt-get update && apt-get install -y curl wget
 
#make config folder
RUN \
 mkdir /config 
 
#Add start script
ADD start.sh /start.sh
RUN chmod +x /start.sh

VOLUME ["/config"]

WORKDIR /config

ENTRYPOINT ["/start.sh"]
