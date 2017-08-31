###########################################################################
#		  
#  Build the image:                                               		  
#    $ docker build -t nut -f nut-alpine.dockerfile --no-cache . 					# longer but more accurate
#    $ docker build -t nut -f nut-alpine.dockerfile . 								# faster but increase mistakes
#                                                                 		  
#  Run the container:                                             		  
#    $ docker run -it --rm -v $(pwd)/shared:/shared -p 4242:4242 nut
#    $ docker run -d --name nut -p 4242:4242 -v $(pwd)/shared:/shared nut
#                                                              		  
###########################################################################

## LEVEL1 ###############################################################################################################

FROM alpine:3.6
LABEL maintainer "Luc Michalski <michalski.luc@gmail.com>"

# container
ARG BUILD_DATE=${BUILD_DATE}

# apk - golang
ARG APK_BUILD_GOLANG=${APK_BUILD_GOLANG}
ARG APK_BUILD_GOLANG_CGO=${APK_BUILD_GOLANG_CGO}
ARG APK_BUILD_GOLANG_TOOLS=${APK_BUILD_GOLANG_TOOLS}
ARG APK_BUILD_GOLANG_CROSS=${APK_BUILD_GOLANG_CROSS}

### kraken
ARG NUT_VERSION=${NUT_VERSION:-"master"}
ARG NUT_VCS_URI=${NUT_VCS_URI:-"github.com/matthieudelaro/nut"}
ARG NUT_VCS_BRANCH=${NUT_VCS_BRANCH:-"master"}
ARG NUT_VCS_DEPTH=${NUT_VCS_DEPTH:-"1"}
ARG NUT_GOLANG_BUILD_BIN_SRC_DIR=${NUT_GOLANG_BUILD_BIN_SRC_DIR:-"\$(glide novendor)"}
ENV NUT_BASENAME=${NUT_BASENAME:-"nut"}

### build
ARG NUT_BUILD_DATE=${NUT_BUILD_DATE}

### sec
ARG GOSU_VERSION=${GOSU_VERSION:-"1.10"}

# Install Gosu to /usr/local/bin/gosu
ADD https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-amd64 /usr/local/sbin/gosu

# Install runtime dependencies & create runtime user
RUN chmod +x /usr/local/sbin/gosu \
	&& apk add --update --no-cache --no-progress file ca-certificates libssh2 openssl \
 	&& adduser -D app -h /data -s /bin/sh

# Copy source code to the container & build it
COPY ./docker/internal /scripts

# Copy source code for experimental data-aggregator/api gateways & build it
COPY ./shared /shared

WORKDIR /scripts
RUN cd /scripts \
	&& ./install-nut.sh

# NSSwitch configuration file
COPY ./shared/conf.d/nsswitch.conf /etc/nsswitch.conf

# App configuration
WORKDIR /app

# Container configuration
# VOLUME ["/data", "/shared/data"]
# CMD ["/usr/local/sbin/gosu", "app", "/app/nut"]
ENTRYPOINT ["/usr/local/sbin/nut"]
CMD [""]

