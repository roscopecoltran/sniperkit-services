#!/bin/sh

set -e
# debug
#set -eux


if [ "$1" = 'etcd' ]; then
  ETCD_CMD="${ETCD_BIN_DIR}/etcd "
  
  echo "Available environment variables:"
  printenv | grep ETCD
  echo " "
  
  if [ ! -z "$ETCD_INITIAL_CLUSTER" ]; then
    echo "Clustered mode."
    ETCD_CMD="${ETCD_CMD} --name=${ETCD_NAME}"
    ETCD_CMD="${ETCD_CMD} --data-dir=${ETCD_DATA_VOLUME_DIR}"
    ETCD_CMD="${ETCD_CMD} --listen-peer-urls=${ETCD_LISTEN_PEER_URLS}"
    ETCD_CMD="${ETCD_CMD} --listen-client-urls=${ETCD_LISTEN_CLIENT_URLS}"
    ETCD_CMD="${ETCD_CMD} --advertise-client-urls=${ETCD_ADVERTISE_CLIENT_URLS}"
    ETCD_CMD="${ETCD_CMD} --initial-cluster-state=${ETCD_INITIAL_CLUSTER_STATE}"     
    ETCD_CMD="${ETCD_CMD} --initial-cluster-token=${ETCD_INITIAL_CLUSTER_TOKEN}" 
    ETCD_CMD="${ETCD_CMD} --initial-cluster=${ETCD_INITIAL_CLUSTER}"
    ETCD_CMD="${ETCD_CMD} --initial-advertise-peer-urls=${ETCD_INITIAL_ADVERTISE_PEER_URLS}"
    ETCD_CMD="${ETCD_CMD} --initial-advertise-peer-urls=${ETCD_INITIAL_ADVERTISE_PEER_URLS}"
  else
    echo "Standalone mode."
  fi

  echo "'$ETCD_CMD'"
  exec $ETCD_CMD
else
    # As argument is not related to kafka,
    # then assume that user wants to run his own process,
    # for example a `bash` shell to explore this image
    exec "$@"
fi

# # If we are not running in cluster, then just execute the etcd binary
# if [[ -z "${ETCD_DISCOVERY_TOKEN-}" ]]; then
#   echo "non clustered start"
#   exec ${ETCD_BIN_DIR}/etcd "$@"
# fi

# # Check for $CLIENT_URLS
# if [ -z ${CLIENT_URLS+x} ]; then
#   CLIENT_URLS="http://0.0.0.0:4001,http://0.0.0.0:2379"
#   echo "Using default CLIENT_URLS ($CLIENT_URLS)"
# else
#   echo "Detected new CLIENT_URLS value of $CLIENT_URLS"
# fi

# # Check for $PEER_URLS
# if [ -z ${PEER_URLS+x} ]; then
#   PEER_URLS="http://0.0.0.0:7001,http://0.0.0.0:2380"
#   echo "Using default PEER_URLS ($PEER_URLS)"
# else
#   echo "Detected new PEER_URLS value of $PEER_URLS"
# fi

#ETCD_CMD="/${ETCD_BIN_DIR}/etcd -data-dir=${ETCD_DATA_DIR} -listen-peer-urls=${PEER_URLS} -listen-client-urls=${CLIENT_URLS} $*"
#ETCD_CMD="/${ETCD_BIN_DIR}/etcd $*"
#echo -e "Running '$ETCD_CMD'\nBEGIN ETCD OUTPUT\n"

#exec $ETCD_CMD
# if [ "$1" = 'etcd' ]; then
#   # check for $CLIENT_URLS
#   echo "Using CLIENT_URLS ($CLIENT_URLS)"

#   # check for $PEER_URLS
#   echo "Using PEER_URLS ($PEER_URLS)"
#   ETCD_CMD="/opt/etcd/etcd -data-dir=/data -listen-peer-urls=${PEER_URLS} -listen-client-urls=${CLIENT_URLS}"
#   echo -e "Running '$ETCD_CMD'\nBEGIN ETCD OUTPUT\n"
#   exec $ETCD_CMD
# else
#     # As argument is not related to kafka,
#     # then assume that user wants to run his own process,
#     # for example a `bash` shell to explore this image
#     exec "$@"
# fi