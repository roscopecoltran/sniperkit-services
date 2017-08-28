FROM python:2.7-alpine

# core - args
ARG SQLMAP_VERSION=${SQLMAP_VERSION:-"1.1.8"}

# maintainer info
ARG CONTAINER_DESCRIPTION=${CONTAINER_DESCRIPTION:-"SQLMap Container"}
ARG CONTAINER_MAINTAINER=${CONTAINER_MAINTAINER:-"KikePuma"}
ARG CONTAINER_VERSION=${CONTAINER_VERSION:-"1.0"}
ARG CONTAINER_BUILD_DATE=${CONTAINER_BUILD_DATE:-"26-August-2017"}

# vcs info
ARG CONTAINER_VCS_PROVIDER=${CONTAINER_VCS_URI:-"github.com"}
ARG CONTAINER_VCS_USERNAME=${CONTAINER_VCS_USERNAME:-"sqlmapproject"}
ARG CONTAINER_VCS_REPONAME=${CONTAINER_VCS_REPONAME:-"sqlmap"}
ARG CONTAINER_VCS_PROTOCOL=${CONTAINER_VCS_PROTOCOL:-"https"}

# docker registry
ARG CONTAINER_HUB_USER_NAME=${CONTAINER_HUB_USER_NAME:-"CosasDePuma"}
ARG CONTAINER_HUB_IMAGE_NAME=${CONTAINER_HUB_IMAGE_NAME:-"sqlmap"}
ARG CONTAINER_HUB_IMAGE_TAG=${CONTAINER_HUB_IMAGE_TAG:-"sqlmap"}
ARG CONTAINER_HUB_IMAGE_URI=${CONTAINER_HUB_IMAGE_URI:-"$CONTAINER_HUB_USER_NAME/$CONTAINER_HUB_IMAGE_NAME"}
ARG CONTAINER_HUB_PROVIDER=${CONTAINER_HUB_PROVIDER:-"docker.io"}

# usage(s)
ARG CONTAINER_USAGE_RUN=${CONTAINER_USAGE_RUN:-"docker run -it --name $CONTAINER_HUB_IMAGE_NAME $CONTAINER_HUB_IMAGE_URI"}

# set docker image labels
LABEL maintainer="${CONTAINER_MAINTAINER}" \
	org.schema-version="${CONTAINER_VERSION}" \
	org.label-schema.name="${CONTAINER_MAINTAINER}" \
	org.label-schema.vendor="${CONTAINER_VCS_USERNAME}" \
	org.label-schema.description="${CONTAINER_DESCRIPTION}" \
	org.label-schema.version="${CONTAINER_VERSION}" \
	org.label-schema.url="${CONTAINER_VCS_URL}" \
	org.label-schema.build-date="${CONTAINER_BUILD_DATE}" \
	org.label-schema.docker.cmd="docker run -it --name sqlmap cosasdepuma/sqlmap"

# Define common APK(s) packages to install
ARG APK_BUILD_COMMON=${APK_BUILD_COMMON:-"openssl-dev tar ca-certificates git libssh2 openssl"}
ARG APK_RUNTIME=${APK_RUNTIME:-""}
ARG APK_INTERACTIVE=${APK_INTERACTIVE:-"nano bash tree jq"}

# combine arguments
ARG CONTAINER_VCS_URL=${CONTAINER_VCS_URL:-"$CONTAINER_VCS_PROTOCOL://$CONTAINER_VCS_URI/$CONTAINER_VCS_USERNAME/$CONTAINER_VCS_REPONAME"}

RUN set -xe\
    && mkdir -p /sqlmap \
    && apk add --no-cache --virtual .build-deps ${APK_BUILD_COMMON} \
    && wget https://github.com/sqlmapproject/sqlmap/archive/$SQLMAP_VERSION.tar.gz -O /tmp/sqlmap.tar.gz \
    && tar xfz /tmp/sqlmap.tar.gz --strip-components=1 -C /sqlmap \
    && apk del .build-deps \
    && rm -rf /tmp/sqlmap.tar.gz

WORKDIR ${APP_HOME_DIR}
VOLUME ${APP_DATA_DIR}

CMD ["-h"]
ENTRYPOINT ["./sqlmap.py", "--output-dir=${APP_DATA_DIR}"]