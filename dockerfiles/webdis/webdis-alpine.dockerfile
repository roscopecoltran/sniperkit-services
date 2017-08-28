###########################################################################
#		  
#  Build the image:                                               		  
#    $ docker build -t webdis --no-cache . 									# longer but more accurate
#    $ docker build -t webdis . 											# faster but increase mistakes
#                                                                 		  
#  Run the container:                                             		  
#    $ docker run -ti --rm --env-file .env -v $(pwd)/shared:/shared webdis
#
#                                                              		  
###########################################################################

FROM alpine:3.6
LABEL maintainer "Luc Michalski <michalski.luc@gmail.com>"

ARG WEBDIS_VCS_REPO=${WEBDIS_REPO:-"https://github.com/nicolasff/webdis.git"}
ARG WEBDIS_VCS_BRANCH=${WEBDIS_VCS_BRANCH:-"master"}
ARG WEBDIS_VCS_CLONE_DEPTH=${WEBDIS_VCS_CLONE_DEPTH:-"1"}
ARG WEBDIS_VCS_CLONE_DIR=${WEBDIS_VCS_CLONE_DIR:-"/usr/local/src/webdis"}

RUN \
    apk add --no-cache --update --virtual .build-deps \
        alpine-sdk \
        libevent-dev \
        bsd-compat-headers \
        git patch \
        \
    && set -xe \
    && mkdir -p /usr/local/src \
    && git clone -b ${WEBDIS_VCS_BRANCH} --depth ${WEBDIS_VCS_CLONE_DEPTH} ${WEBDIS_VCS_REPO} ${WEBDIS_VCS_CLONE_DIR} \
    && cd ${WEBDIS_VCS_CLONE_DIR} \
    && make clean all \
    && sed -i '/redis_host/s/"127.*"/"redis"/g' webdis.json \
    && cp webdis /usr/local/bin/ \
    && mkdir -p /shared/conf.d \
    && mkdir -p /shared/logs/webdis \
    && mkdir -p /shared/data/webdis \
    && cp webdis.json /shared/conf.d \
    && mkdir -p /usr/share/doc/webdis \
    && cp README.markdown /usr/share/doc/webdis/README \
    && rm -rf /usr/local/src \
    && runDeps="$( \
        scanelf --needed --nobanner --recursive /usr/local \
            | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
            | sort -u \
            | xargs -r apk info --installed \
            | sort -u \
        )" \
    && apk add --no-cache --virtual .rundeps $runDeps \
    && apk del --no-cache .build-deps

# ADD ./docker/internal/entrypoint.sh /scripts/docker/entrypoint.sh
COPY ./docker/internal/ /scripts
COPY ./shared/ /shared/

ENTRYPOINT ["/scripts/entrypoint.sh"]

EXPOSE 7379
