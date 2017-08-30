
###########################################################################
#		  
#  Build the image:                                               		  
#    $ docker build -t neo4j:3.2.3-alpine3.6 --no-cache -f neo4j-alpine.dockerfile .   	 # longer but more accurate
#    $ docker build -t neo4j:3.2.3-alpine3.6 -f neo4j-alpine.dockerfile .    		 	 # faster but increase mistakes
#                                                                 		  
#  Run the container:                                             		  
#    $ docker run -it --rm -v $(pwd)/shared:/shared -p 7474:7474 -p 7473:7473 -p 7687:7687 neo4j:3.2.3-alpine3.6
#    $ docker run -it -p 7474:7474 -p 7473:7473 -p 7687:7687 -v $(pwd)/shared:/shared --name sphinx neo4j:3.2.3-alpine3.6
#                                                              		  
###########################################################################

FROM openjdk:8-jre-alpine
LABEL maintainer "Luc Michalski <michalski.luc@gmail.com>"

ARG NEO4J_VERSION=${NEO4J_VERSION:-"3.2.3"}
ARG	NEO4J_SHA256=${NEO4J_SHA256:-"47317a5a60f72de3d1b4fae4693b5f15514838ff3650bf8f2a965d3ba117dfc2"}
ARG NEO4J_TARBALL=${NEO4J_TARBALL:-"neo4j-community-$NEO4J_VERSION-unix.tar.gz"}
ARG GOSU_VERSION=${GOSU_VERSION:-"1.10"}
ARG APK_BUILD_COMMON=${APK_BUILD_COMMON:-"curl"}

# Install Gosu to /usr/local/bin/gosu
ADD https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-amd64 /usr/local/sbin/gosu

# NSSwitch configuration file
COPY ./shared/conf.d/nsswitch.conf /etc/nsswitch.conf

# Sentinel files
COPY ./shared/conf.d/local-package/* /tmp/

# Install runtime dependencies, create runtime user, Copy source code to the container & build it
RUN chmod +x /usr/local/sbin/gosu \
	&& adduser -D app -h /data -s /bin/sh \
	&& apk add --no-cache --update --no-progress --virtual build-deps ${APK_BUILD_COMMON} \
	&& curl --fail --silent --show-error --location --remote-name http://dist.neo4j.org/neo4j-community-$NEO4J_VERSION-unix.tar.gz \
    && tar --extract --file ${NEO4J_TARBALL} --directory /var/lib \
    && mv /var/lib/neo4j-* /var/lib/neo4j \
    && rm ${NEO4J_TARBALL} \
    && mv /var/lib/neo4j/data /data \
    && ln -s /data /var/lib/neo4j/data \
    && apk del --no-cache build-deps


# Entrypoint switch cases
COPY docker/internal/entrypoint.sh /script/entrypoint.sh

# Container configuration
WORKDIR /var/lib/neo4j
VOLUME ["/data","/shared/data/neo4j"]
EXPOSE 7474 7473 7687

ENTRYPOINT ["/script/entrypoint.sh"]
CMD ["neo4j"]