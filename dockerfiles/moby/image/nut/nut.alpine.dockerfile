###########################################################################
#		  
#  Build the image:                                               		  
#    $ docker build -t crane -f crane-alpine.dockerfile --no-cache . 					# longer but more accurate
#    $ docker build -t crane -f crane-alpine.dockerfile . 								# faster but increase mistakes
#                                                                 		  
#  Run the container:                                             		  
#    $ docker run -it --rm -v $(pwd)/shared:/shared -p 4242:4242 crane
#    $ docker run -d --name crane -p 4242:4242 -v $(pwd)/shared:/shared crane
#                                                              		  
###########################################################################

## LEVEL1 ###############################################################################################################

FROM golang:1.9-alpine3.6

ARG GOSU_VERSION=${GOSU_VERSION:-"1.10"}
ARG KRAKEND_VERSION=${KRAKEND_VERSION:-"head"}
ARG BUILD_DATE=${BUILD_DATE:-"2017-08-30T00:00:00Z"}

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
	&& ./install-crane.sh

# NSSwitch configuration file
COPY ./shared/conf.d/nsswitch.conf /etc/nsswitch.conf

# App configuration
WORKDIR /app

# Container configuration
# VOLUME ["/data", "/shared/data"]
# CMD ["/usr/local/sbin/gosu", "app", "/app/crane"]
ENTRYPOINT ["/usr/local/sbin/crane"]
CMD [""]

