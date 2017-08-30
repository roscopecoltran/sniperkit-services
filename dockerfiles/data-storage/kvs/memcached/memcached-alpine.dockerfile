
###########################################################################
#		  
#  Build the image:                                               		  
#    $ docker build -t memcached:1.4.36-alpine3.6 --no-cache -f memcached-alpine.dockerfile .   # longer but more accurate
#    $ docker build -t memcached:1.4.36-alpine3.6 -f memcached-alpine.dockerfile .    		 	 # faster but increase mistakes
#                                                                 		  
#  Run the container:                                             		  
#    $ docker run -it --rm -v $(pwd)/shared:/shared -p 9312:9312 -p 9306:9306 postgres:10.0-alpine3.6
#    $ docker run -it -p 9312:9312 -p 9306:9306 -v $(pwd)/shared:/shared --name sphinx postgres:10.0-alpine3.6
#                                                              		  
###########################################################################

FROM alpine:3.6
LABEL maintainer "Luc Michalski <michalski.luc@gmail.com>"

## Set Environment Variables
ARG MEMCACHED_VERSION=1.5.1
ARG MEMCACHED_SHA1=e5b7e4e562eb99fdfa67d71697cc6744d3e9663f
ENV ZABBIX_HOSTNAME=memcached-app

## Install
# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
	RUN adduser -D memcache && \

	    set -x && \
		apk add --no-cache --virtual .build-deps \
			ca-certificates \
			coreutils \
			cyrus-sasl-dev \
			dpkg-dev dpkg \
			gcc \
			libc-dev \
			libevent-dev \
			libressl \
			linux-headers \
			make \
			perl \
			tar \
	        && \
               
            apk add --no-cache \
                python \
                && \
		wget -O memcached.tar.gz "https://memcached.org/files/memcached-$MEMCACHED_VERSION.tar.gz" && \
		echo "$MEMCACHED_SHA1  memcached.tar.gz" | sha1sum -c - && \
		mkdir -p /usr/src/memcached && \
		tar -xzf memcached.tar.gz -C /usr/src/memcached --strip-components=1 && \
		rm memcached.tar.gz && \
		cd /usr/src/memcached && \
		./configure \
			--build="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
			--enable-sasl && \
		make -j "$(nproc)" && \
		make install && \
		cd / && rm -rf /usr/src/memcached && \
		runDeps="$( \
			scanelf --needed --nobanner --recursive /usr/local \
				| awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
				| sort -u \
				| xargs -r apk info --installed \
				| sort -u \
		)" && \
		apk add --virtual .memcached-rundeps $runDeps && \
		apk del .build-deps && \
        rm -rf /var/cache/apk/*	&& \
		memcached -V

   
### Add Folders
    ADD /install /

## Networking Setup
	EXPOSE 11211

## Entrypoint Configuration
    ENTRYPOINT ["/init"]

