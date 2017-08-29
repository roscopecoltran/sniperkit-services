#!/bin/bash
set -eux

if [ "$1" = 'elasticsearch' ]; then
  
  if [ ! -v HOST ]; then 
    HOST="$(hostname -i | head -n 1 | cut -d ' ' -f1)"
  fi
  echo "Starting elasticsearch with conf=${ES_CONFIG_DIR}, name=${CLUSTER_NAME}, num_master=${MINIMUM_MASTER_NODES}, host=${HOST}"

  export ES_NETWORK_HOST=${HOST}

  ${ES_HOME}/bin/elasticsearch \
          -Djavax.net.debug=ssl \
          -Des.default.path.conf=${ES_CONFIG_DIR} \
          -Dcluster.name=${CLUSTER_NAME} \
          -Dzen.minimum_master_nodes=${MINIMUM_MASTER_NODES} \
          -Dnetwork.host=${ES_NETWORK_HOST}
          
else
    # As argument is not related to elasticsearch,
    # then assume that user wants to run his own process,
    # for example a `bash` shell to explore this image
    exec "$@"
fi