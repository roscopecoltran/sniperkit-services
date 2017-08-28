
###########################################################################
#		  
#  Build the image:                                               		  
#    $ docker build -t postgres:9.5-alpine --no-cache -f postgres9.5-alpine.dockerfile .   # longer but more accurate
#    $ docker build -t postgres:9.5-alpine -f postgres9.5-alpine.dockerfile .    		  # faster but increase mistakes
#                                                                 		  
#  Run the container:                                             		  
#    $ docker run -it --rm -v $(pwd)/shared:/shared -p 5432:5432 postgres:9.5-alpine
#    $ docker run -it -p 5432:5432 -v $(pwd)/shared:/shared --name sphinx postgres:9.5-alpine
#                                                              		  
###########################################################################

FROM postgres:9.5-alpine
LABEL maintainer "Luc Michalski <michalski.luc@gmail.com>"

EXPOSE 5432
VOLUME ["/shared", "/etc/postgres"]

# CMD [""]
# ENTRYPOINT [""]

# app configuration
ARG APP_CONF_FILENAME=${APP_CONF_FILENAME:-"postgres.conf"}
ARG APP_CONF_FILEPATH=${APP_CONF_FILEPATH:-"$APP_DIR_SHARED/conf.d/$APP_CONF_FILENAME"}

# Define app specific APK(s) packages to install
ARG APK_BUILD_CUSTOM=${APK_BUILD_CUSTOM:-"tree postgresql-dev"}
ARG APK_RUNTIME_CUSTOM=${APK_RUNTIME_CUSTOM:-"postgresql-contrib lua-sql-postgres"}
ARG APK_INTERACTIVE_CUSTOM=${APK_INTERACTIVE_CUSTOM:-"jq"}

# Set import status for apk based packages
ARG IS_INTERACTIVE=${IS_INTERACTIVE:-"TRUE"}
ARG IS_RUNTIME=${IS_RUNTIME:-"TRUE"}
ARG IS_BUILD=${IS_BUILD:-"TRUE"}
ARG HAS_USER=${HAS_USER:-"TRUE"}

# Set env variables
ARG DOCKER_SERVICES=${DOCKER_SERVICES:-"postgres/9.5"}
ARG DOCKER_SHARED_FOLDERS=${DOCKER_SHARED_FOLDERS:-"ssl,load,conf.d,logs,data"}

# Install Gosu to /usr/local/bin/gosu
ARG HELPER_GOSU_VERSION=${HELPER_GOSU_VERSION:-"1.10"}
ARG HELPER_GOSU_FILENAME=${HELPER_GOSU_FILENAME:-"gosu-amd64"}
ARG HELPER_GOSU_FILEPATH=${HELPER_GOSU_FILEPATH:-"/usr/local/sbin/gosu"}
ADD https://github.com/tianon/gosu/releases/download/${HELPER_GOSU_VERSION}/${HELPER_GOSU_FILENAME} /usr/local/sbin/gosu

# Define common APK(s) packages to install
ARG APK_BUILD_COMMON=${APK_BUILD_COMMON:-"coreutils gcc g++ musl-dev make cmake openssl-dev libssh2-dev autoconf automake"}
ARG APK_RUNTIME=${APK_RUNTIME:-"ca-certificates git libssh2 openssl"}
ARG APK_INTERACTIVE=${APK_INTERACTIVE:-"nano bash tree"}

# restricted user
ARG APP_USER=${APP_USER:-"app"}
ARG APP_HOME=${APP_HOME:-"/app"}

# key dirs
ARG APP_DIR_SHARED=${APP_DIR_SHARED:-"/shared"}
ARG APP_DIR_CONFS=${APP_DIR_CONFS:-"/shared/conf.d"}
ARG APP_DIR_CERTS=${APP_DIR_CERTS:-"/shared/ssl"}
ARG APP_DIR_DATA=${APP_DIR_DATA:-"/shared/data"}
ARG APP_DIR_DICTS=${APP_DIR_DICTS:-"/shared/dicts"}
ARG APP_DIR_LOAD=${APP_DIR_LOAD:-"/shared/load"}
ARG APP_DIR_LOGS=${APP_DIR_LOGS:-"/shared/logs"}
ARG APP_DIR_PLUGINS=${APP_DIR_PLUGINS:-"/shared/plugins"}


# Copy the configuration file (with logs, data and config dir vars updated)
# ADD ./shared/conf.d/${APP_CONF} ${APP_SHARED}/conf.d/${APP_CONF}
COPY ./docker/internal/ /scripts
COPY ./shared/ /shared/

RUN \
    set -x \
    && set -e \
    && chmod +x ${HELPER_GOSU_FILEPATH} \
    \
    && if [ "${HAS_USER}" == "TRUE" ]; then \
        adduser -D ${APP_USER} -h ${APP_HOME} -s /bin/sh ; fi \
	\
	&& if [ "${IS_RUNTIME}" == "TRUE" ]; then \
	apk add --no-cache --no-progress --update ${APK_RUNTIME} ${APK_RUNTIME_CUSTOM} ; fi \
 	\
	&& if [ "${IS_BUILD}" == "TRUE" ]; then \
	apk add --update --no-cache --no-progress --virtual build-deps ${APK_BUILD} ${APK_BUILD_CUSTOM} ; fi \
	\
	&& if [ "${IS_INTERACTIVE}" == "TRUE" ]; then \
	apk add --update --no-cache --no-progress --virtual interactive-deps ${APK_INTERACTIVE} ${APK_INTERACTIVE_CUSTOM} ; fi \
	\
    && for SERVICE in ${DOCKER_SERVICES}; do \
        echo -e "  *** SERVICE: ${SERVICE}" \
        && /bin/bash -c "mkdir -pv ${APP_DIR_SHARED}/{${DOCKER_SHARED_FOLDERS}}/${SERVICE}" ; \
        done \
        && tree ${APP_DIR_SHARED} \
	\
	&& if [ "${IS_BUILD}" == "TRUE" ]; then \
	apk --no-cache --no-progress del build-deps ; fi \
    \
    && rm -rf /var/cache/apk/*
