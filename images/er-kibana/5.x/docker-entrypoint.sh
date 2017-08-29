#!/bin/bash

set -eux

if [ "$1" = 'kibana' ]; then
  if [ ! -v ELASTICSEARCH_URL ]; then
    echo "Environment variable 'ELASTICSEARCH_URL' not defined."      
  else
    echo "kibana: Client of 'ELASTICSEARCH' instance $ELASTICSEARCH_URL"
    echo "elasticsearch.url: $ELASTICSEARCH_URL" >> ${KIBANA_HOME}/kibana5/config/kibana.yml
  fi
  if [ ! -v PASSWORD ]; then
    PASSWORD="changeme"
  fi

  sed -i -e "s#PASSWORD#${PASSWORD}#" ${KIBANA_HOME}/kibana5/config/kibana.yml
  (cd ${KIBANA_HOME}/kibana5 && bin/kibana)
else
    # As argument is not related to kibana,
    # then assume that user wants to run his own process,
    # for example a `bash` shell to explore this image
    exec "$@"
fi
