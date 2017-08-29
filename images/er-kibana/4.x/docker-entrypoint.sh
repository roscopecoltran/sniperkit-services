#!/bin/bash

set -eux

if [ "$1" = 'kibana' ]; then
  if [ -z ${ELASTICSEARCH+x} ]; then
    echo "Environment variable 'ELASTICSEARCH' not defined."      
  else
    echo "kibana: Client of 'ELASTICSEARCH' instance $ELASTICSEARCH"
  fi

  sed -i -e "s/ELASTICSEARCH_IP_ADDRESS_MARKER/${ELASTICSEARCH:-"$(hostname -i | head -n 1 | cut -d " " -f1)"}/g" \
         -e "s/ELASTICSEARCH_PORT_MARKER/${ELASTICSEARCH_PORT:-"9200"}/g" ${KIBANA_HOME}/kibana4/config/kibana.yml
  (cd ${KIBANA_HOME}/kibana4 && bin/kibana)
else
    # As argument is not related to kibana,
    # then assume that user wants to run his own process,
    # for example a `bash` shell to explore this image
    exec "$@"
fi
