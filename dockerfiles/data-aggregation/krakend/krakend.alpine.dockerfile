###########################################################################
#		  
#  Build the image:                                               		  
#    $ docker build -t krakend -f krakend-alpine.dockerfile --no-cache . 					# longer but more accurate
#    $ docker build -t krakend -f krakend-alpine.dockerfile . 								# faster but increase mistakes
#                                                                 		  
#  Run the container:                                             		  
#    $ docker run -it --rm -v $(pwd)/shared:/shared -p 4242:4242 krakend
#    $ docker run -d --name krakend -p 4242:4242 -v $(pwd)/shared:/shared krakend
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
ARG KRAKEND_VERSION=${KRAKEND_VERSION:-"head"}
ARG KRAKEND_VCS_URI=${KRAKEND_VCS_URI:-"github.com/devopsfaith/krakend"}
ARG KRAKEND_VCS_BRANCH=${KRAKEND_VCS_BRANCH:-"master"}
ARG KRAKEND_VCS_DEPTH=${KRAKEND_VCS_DEPTH:-"1"}
ARG KRAKEND_GOLANG_BUILD_BIN_SRC_DIR=${KRAKEND_GOLANG_BUILD_BIN_SRC_DIR:-"\$(glide novendor)"}
ENV KRAKEND_BASENAME=${KRAKEND_BASENAME:-"krakend"}

### build
ARG KRAKEND_BUILD_DATE=${KRAKEND_BUILD_DATE}

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
	&& ./install-${KRAKEND_BASENAME}.sh

# NSSwitch configuration file
COPY ./shared/conf.d/nsswitch.conf /etc/nsswitch.conf

# App configuration
WORKDIR /app

# env
# ENV KRAKEND_PATH "/shared/data/${KRAKEND_BASENAME}"

# Container configuration
# VOLUME ["/data", "/shared/data"]
EXPOSE 8096
# CMD ["/usr/local/sbin/gosu", "app", "/app/${KRAKEND_BASENAME}"]
ENTRYPOINT [""]
CMD [""]

# CMD ["jwt"]
# ENTRYPOINT [ "-d", "-p", "8096", "-c", "/shared/conf.d/default/${KRAKEND_BASENAME}.json", "-cors-origins", "http://127.0.0.1:8096,http://example.com,http://ssl.example.com,https://127.0.0.1:8096,https://example.com,https://ssl.example.com" ]

# CMD [ "-d", "-p", "8096", "-c", "/shared/conf.d/default/${KRAKEND_BASENAME}.json" ]
# ENTRYPOINT [ "gorilla" ]



