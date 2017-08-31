
###########################################################################
#		  
#  Build the image:                                               		  
#    $ docker build -t nut -f nut-alpine.dockerfile --no-cache . 					# longer but more accurate
#    $ docker build -t nut -f nut-alpine.dockerfile . 								# faster but increase mistakes
#                                                                 		  
#  Run the container:                                             		  
#    $ docker run -it --rm -v $(pwd)/shared:/shared -v /var/run/docker.sock:/var/run/docker.sock -p 8842:8842 nut
#    $ docker run -d --name nut -p 8842:8842 -v /var/run/docker.sock:/var/run/docker.sock -v $(pwd)/shared:/shared nut
#                                                              		  
###########################################################################

FROM alpine:3.6

## LEVEL1 ###############################################################################################################

ARG GOSU_VERSION=${GOSU_VERSION:-"1.10"}
ARG NUT_VERSION=${NUT_VERSION:-"master"}
ARG BUILD_DATE=${BUILD_DATE:-"2017-08-30T00:00:00Z"}

# Install Gosu to /usr/local/bin/gosu
ADD https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-amd64 /usr/local/sbin/gosu

## LEVEL2 ###############################################################################################################

# Install runtime dependencies & create runtime user
RUN chmod +x /usr/local/sbin/gosu \
 	&& apk --no-cache --no-progress add ca-certificates git libssh2 openssl \
 	&& adduser -D app -h /data -s /bin/sh

# Copy source code to the container & build it
COPY . /app
WORKDIR /app
RUN ./docker/internal/install-nut.sh

## LEVEL3 ###############################################################################################################

# NSSwitch configuration file
COPY ./shared/conf.d/nsswitch.conf /etc/nsswitch.conf

## LEVEL4 ###############################################################################################################

# Container configuration
VOLUME ["/data"]
EXPOSE 8842
CMD ["/usr/local/sbin/gosu", "app", "/app/git2etcd"]