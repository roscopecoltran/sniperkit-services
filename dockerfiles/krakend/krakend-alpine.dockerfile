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

# ARG APP_USER=${APP_USER:-"app"}
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
	&& ./install-krakend.sh

# NSSwitch configuration file
COPY ./shared/conf.d/nsswitch.conf /etc/nsswitch.conf

# App configuration
WORKDIR /app

# env
# ENV KRAKEND_PATH "/shared/data/krakend"

# Container configuration
# VOLUME ["/data", "/shared/data"]
EXPOSE 4242
# CMD ["/usr/local/sbin/gosu", "app", "/app/krakend"]
ENTRYPOINT [""]
CMD [""]