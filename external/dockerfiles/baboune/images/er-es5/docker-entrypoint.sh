#!/bin/bash
set -eux

if [ "$1" = 'elasticsearch' ]; then
  
  if [ ! -v HOST ]; then 
    HOST="$(hostname -i | head -n 1 | cut -d ' ' -f1)"
  fi
  echo "Starting elasticsearch with conf=${ES_CONFIG_DIR}, name=${CLUSTER_NAME}, num_master=${MINIMUM_MASTER_NODES}, host=${HOST}"

  export ES_JAVA_OPTS="${ES_JAVA_OPTS} -Djavax.net.debug=ssl "
  export ES_NETWORK_HOST=${HOST}

  elasticsearch -Epath.conf=${ES_CONFIG_DIR}
          
else
    # As argument is not related to elasticsearch,
    # then assume that user wants to run his own process,
    # for example a `bash` shell to explore this image
    exec "$@"
fi