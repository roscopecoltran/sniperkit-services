#!/bin/sh

set -eo pipefail

if [ -z "$DOCKER_HOST" ]; then
  if [ -z "$DOCKER_SOCKET" ]; then
    REAL_CURL_OPTIONS="--unix-socket /var/run/docker.sock"
  else
    REAL_CURL_OPTIONS="--unix-socket $DOCKER_SOCKET"
  fi
    DOCKER_URL="http:"

else
  DOCKER_URL=`echo $DOCKER_HOST | sed -e s/tcp/https/g`
  REAL_CURL_OPTIONS="--insecure --cert /etc/docker/server.pem --key /etc/docker/server-key.pem"
fi

if [ ! -z "$DOCKER_CURL_OPTION" ]; then
  REAL_CURL_OPTIONS="$REAL_CURL_OPTIONS $DOCKER_CURL_OPTION"
fi

if [ -z "$1" ]; then
  echo >&2 'Docker API URI is not set. Please set by arg1'
  exit 1
fi

if [ -z "$2" ]; then
  JQ_ARG="."
else
  JQ_ARG="$2"
fi

curl -sSfk $REAL_CURL_OPTIONS "$DOCKER_URL$1" | jq "$JQ_ARG"