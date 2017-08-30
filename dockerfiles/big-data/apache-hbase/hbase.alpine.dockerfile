###########################################################################
#		  
#  Build the image:                                               		  
#    $ docker build -t hbase -f hbase-alpine.dockerfile --no-cache . 					# longer but more accurate
#    $ docker build -t hbase -f hbase-alpine.dockerfile . 							# faster but increase mistakes
#                                                                 		  
#  Run the container:                                             		  
#    $ docker run -it --rm -v $(pwd)/shared:/shared -p 4242:4242 hbase
#    $ docker run -d --name hbase -p 4242:4242 -v $(pwd)/shared:/shared hbase
#                                                              		  
###########################################################################

## LEVEL1 ###############################################################################################################

FROM alpine:3.6
LABEL maintainer "Luc Michalski <michalski.luc@gmail.com>"

# ARG APP_USER=${APP_USER:-"app"}
ARG GOSU_VERSION=${GOSU_VERSION:-"1.10"}
ARG APACHE_HBASE_VERSION=${APACHE_HBASE_VERSION:-"2.7.3"}

# Install Gosu to /usr/local/sbin/gosu
ADD https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-amd64 /usr/local/sbin/gosu

# Copy source code to the container & build it
COPY ./docker/internal /scripts/
WORKDIR /scripts

# Install runtime dependencies & create runtime user
RUN chmod +x /usr/local/sbin/gosu \
	&& apk add --update --no-cache --no-progress file ca-certificates libssh2 openssl \
 	&& adduser -D app -h /data -s /bin/sh \
 	&& cd /scripts \
	&& ./install-hbase.sh \
    && rm -rf /var/cache/apk/*

# Copy source code for experimental data-aggregator/api gateways & build it
COPY ./shared /shared

# NSSwitch configuration file
COPY ./shared/conf.d/nsswitch.conf /etc/nsswitch.conf

# App configuration
WORKDIR /app

# Container configuration
# VOLUME ["/data", "/shared/data"]

# VOLUME ["/shared"]
EXPOSE 2379 2380

ENTRYPOINT ["hbase"]
CMD ["--listen-peer-urls", "http://0.0.0.0:2380", "--listen-client-urls", "http://0.0.0.0:2379"]

# with gosu
# CMD ["/usr/local/sbin/gosu", "app", "/app/hbase", "--listen-peer-urls", "http://0.0.0.0:2380", "--listen-client-urls", "http://0.0.0.0:2379"]

