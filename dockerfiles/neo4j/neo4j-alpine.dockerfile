
###########################################################################
#		  
#  Build the image:                                               		  
#    $ docker build -t neo4j:3.3-alpine3.6 --no-cache -f neo4j-alpine.dockerfile .   # longer but more accurate
#    $ docker build -t neo4j:3.3-alpine3.6 -f neo4j-alpine.dockerfile .    		 	 # faster but increase mistakes
#                                                                 		  
#  Run the container:                                             		  
#    $ docker run -it --rm -v $(pwd)/shared:/shared -p 7474:7474 -p 7473:7473 -p 7687:7687 neo4j:3.3-alpine3.6
#    $ docker run -it -p 7474:7474 -p 7473:7473 -p 7687:7687 -v $(pwd)/shared:/shared --name sphinx neo4j:3.3-alpine3.6
#                                                              		  
###########################################################################

FROM openjdk:8-jre-alpine
LABEL maintainer "Luc Michalski <michalski.luc@gmail.com>"

RUN apk add --no-cache --quiet  bash \
    curl

ENV NEO4J_VERSION=${NEO4J_VERSION:-"3.2.3"} \
	NEO4J_SHA256=${NEO4J_SHA:-"47317a5a60f72de3d1b4fae4693b5f15514838ff3650bf8f2a965d3ba117dfc2"} \
    NEO4J_TARBALL=${NEO4J_TARBALL:-"neo4j-community-$NEO4J_VERSION-unix.tar.gz"}

ARG NEO4J_URI=${NEO4J_URI:-"https://neo4j.com/artifact.php?name=neo4j-community-"$NEO4J_VERSION"-unix.tar.gz"}

COPY ./shared/conf.d/local-package/* /tmp/

RUN curl --fail --silent --show-error --location --remote-name ${NEO4J_URI} \
    && echo "${NEO4J_SHA256}  ${NEO4J_TARBALL}" | sha256sum -csw - \
    && tar --extract --file ${NEO4J_TARBALL} --directory /var/lib \
    && mv /var/lib/neo4j-* /var/lib/neo4j \
    && rm ${NEO4J_TARBALL} \
    && mv /var/lib/neo4j/data /data \
    && ln -s /data /var/lib/neo4j/data \
    && apk del curl

WORKDIR /var/lib/neo4j

VOLUME /data

COPY docker/internal/entrypoint.sh /script/entrypoint.sh

EXPOSE 7474 7473 7687

ENTRYPOINT ["/script/entrypoint.sh"]
CMD ["neo4j"]