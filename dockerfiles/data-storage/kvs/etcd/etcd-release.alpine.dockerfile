###########################################################################
#		  
#  Build the image:                                               		  
#    $ docker build -t etcd -f etcd-alpine.dockerfile --no-cache . 					# longer but more accurate
#    $ docker build -t etcd -f etcd-alpine.dockerfile . 								# faster but increase mistakes
#                                                                 		  
#  Run the container:                                             		  
#    $ docker run -it --rm -v $(pwd)/shared:/shared -p 4242:4242 etcd
#    $ docker run -d --name etcd -p 4242:4242 -v $(pwd)/shared:/shared etcd
#                                                              		  
###########################################################################

## LEVEL1 ###############################################################################################################

FROM alpine:3.6
LABEL maintainer "Luc Michalski <michalski.luc@gmail.com>"

ARG ETCD_VERSION=${ETCD_VERSION:-"3.2.6"}
ARG GOSU_VERSION=${GOSU_VERSION:-"1.10"}

# Install Gosu to /usr/local/bin/gosu
ADD https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-amd64 /usr/local/sbin/gosu

# install etcd
RUN chmod +x /usr/local/sbin/gosu && \
	apk add --update --no-cache ca-certificates openssl tar && \
    wget https://github.com/coreos/etcd/releases/download/${ETCD_VERSION}/etcd-${ETCD_VERSION}-linux-amd64.tar.gz && \
    tar zxvf etcd-${ETCD_VERSION}-linux-amd64.tar.gz && \
    mv etcd-${ETCD_VERSION}-linux-amd64/etcd* /bin/ && \
    apk del --purge --no-cache tar openssl && \
    mkdir -p /shared/data && \
 	adduser -D app -h /data -s /bin/sh && \
    rm -Rf etcd-${ETCD_VERSION}-linux-amd64* /var/cache/apk/*

# Copy source code to the container & build it
COPY ./docker/internal /scripts

# Copy source code for experimental data-aggregator/api gateways & build it
COPY ./shared /shared

# NSSwitch configuration file
COPY ./shared/conf.d/nsswitch.conf /etc/nsswitch.conf

# App configuration
WORKDIR /app

VOLUME ["/shared"]
EXPOSE 2379 2380

ENTRYPOINT ["etcd"]
CMD ["--listen-peer-urls", "http://0.0.0.0:2380", "--listen-client-urls", "http://0.0.0.0:2379"]

# with gosu
# CMD ["/usr/local/sbin/gosu", "app", "/app/etcd", "--listen-peer-urls", "http://0.0.0.0:2380", "--listen-client-urls", "http://0.0.0.0:2379"]

