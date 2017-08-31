###########################################################################
#		  
#  Build the image:                                               		  
#    $ docker build -t sphinxql:apk2.2.11-alpine3.6 --no-cache -f sphinx.dockerfile . # longer but more accurate
#    $ docker build -t sphinxql:apk2.2.11-alpine3.6 -f sphinx.dockerfile .    		  # faster but increase mistakes
#                                                                 		  
#  Run the container:                                             		  
#    $ docker run -it --rm -v $(pwd)/shared:/shared -p 9312:9312 -p 9306:9306 sphinxql:apk2.2.11-alpine3.6
#    $ docker run -it -p 9312:9312 -p 9306:9306 -v $(pwd)/shared:/shared --name sphinx sphinxql:apk2.2.11-alpine3.6
#                                                              		  
###########################################################################

FROM alpine:edge
LABEL maintainer "Luc Michalski <michalski.luc@gmail.com>"

# Set env variables
ARG DOCKER_SERVICES=${DOCKER_SERVICES:-""}
ARG DOCKER_SHARED_FOLDERS=${DOCKER_SHARED_FOLDERS:-"ssl,load,conf.d,logs,data,plugins"}

# Install Gosu to /usr/local/bin/gosu
ARG HELPER_GOSU_VERSION=${HELPER_GOSU_VERSION:-"1.10"}
ARG HELPER_GOSU_FILENAME=${HELPER_GOSU_FILENAME:-"gosu-amd64"}
ARG HELPER_GOSU_FILEPATH=${HELPER_GOSU_FILEPATH:-"/usr/local/sbin/gosu"}
ADD https://github.com/tianon/gosu/releases/download/${HELPER_GOSU_VERSION}/${HELPER_GOSU_FILENAME} /usr/local/sbin/gosu

# Define APK(s) packages to install
ARG APK_BUILD=${APK_BUILD:-"coreutils gcc g++ musl-dev make cmake openssl-dev autoconf automake"}
ARG APK_RUNTIME=${APK_RUNTIME:-"ca-certificates openssl sphinx sphinx-python"}
ARG APK_INTERACTIVE=${APK_INTERACTIVE:-"nano bash tree jq"}

# Copy the configuration file (with logs, data and config dir vars updated)
ADD ./shared/conf.d/sphinx.conf /shared/conf.d/sphinx.conf

# Copy the internal shell script(s) (eg. entrypoints, maintenance...)
COPY ./shared/ /shared/

COPY ./docker/internal/ /scripts
WORKDIR /scripts

# apk add --update --no-cache --no-progress --virtual interactive-deps ${APK_INTERACTIVE}
# apk add --update --no-cache --no-progress --virtual build-deps ${APK_BUILD}
# apk --no-cache --no-progress del build-deps
# if [ "${dockerlist}" != "" ]; then XXXXX ; fi
# for SERVICE in ${DOCKER_SERVICES}; do ; done
RUN chmod +x /usr/local/sbin/gosu \
 	&& echo "http://dl-5.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
	&& apk add --update --no-cache --no-progress ${RUNTIME_APK} \
	&& apk add --update --no-cache --no-progress --virtual interactive-deps ${APK_INTERACTIVE} \
	\
	&& chmod a+x /scripts/*.sh \
	\
	&& for SERVICE in ${DOCKER_SERVICES}; do ./install-${SERVICE}.sh ;mkdir -p ${DOCKER_SHARED_FOLDERS}/${SERVICE} ; done \
	\
	&& chmod a+x /scripts/*.sh \
	\
	&& rm -rf /var/cache/apk/*

# 9312 Sphinx Plain Port
# 9306 SphinxQL Port
EXPOSE 9312 9306

ENTRYPOINT ["./entrypoint.sh"]
# CMD ["./indexall.sh", "--nodetach", "--config", "/shared/conf.d/sphinx/sphinx.conf"]
# CMD ["./indexall.sh", "/shared/conf.d/sphinx.conf"]
# /usr/bin/searchd --config /shared/conf.d/sphinx.conf
# searchd --nodetach --config /shared/conf.d/sphinx.conf
