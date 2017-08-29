#!/bin/bash

set -e
# debug
#set -eux

if [ "$1" = 'zookeeper' ]; then

  # Persists the ID of the current instance of Zookeeper
  echo "Using ZK_ID: ${ZK_ID}"
  echo ${ZK_ID} > /opt/zookeeper/data/myid
  
  for VAR in `env`
  do
    if [[ $VAR =~ ^ZK_SERVER_[0-9]+= ]]; then
      echo "  VAR: ${VAR}"
      _id=`echo "$VAR" | sed -r "s/ZK_SERVER_(.*)=.*/\1/"`
      _ip=`echo "$VAR" | sed 's/.*=//'`
      echo "  _id: ${_id}"
      echo "  _ip: ${_ip}"
      if [ "${_id}" = "${ZK_ID}" ]; then
        echo "server.${_id}=0.0.0.0:${ZK_FOLLOWERS_PORT}:${ZK_ELECTION_PORT}" >> /opt/zookeeper/conf/zoo-template.cfg
        echo "server.${_id}=0.0.0.0:${ZK_FOLLOWERS_PORT}:${ZK_ELECTION_PORT}"
      else
        echo "server.${_id}=${_ip}:${ZK_FOLLOWERS_PORT}:${ZK_ELECTION_PORT}" >> /opt/zookeeper/conf/zoo-template.cfg
        echo "server.${_id}=${_ip}:${ZK_FOLLOWERS_PORT}:${ZK_ELECTION_PORT}"
      fi
    fi
  done

  # Substitute vars in configuration file
  cp /opt/zookeeper/conf/zoo-template.cfg /opt/zookeeper/conf/zoo.cfg
  sed -i -e "s#ZK_CLIENT_PORT#${ZK_CLIENT_PORT}#" /opt/zookeeper/conf/zoo.cfg
  
  exec /opt/zookeeper/bin/zkServer.sh start-foreground

else
    # As argument is not related to zookeeper,
    # then assume that user wants to run his own process,
    # for example a `bash` shell to explore this image
    exec "$@"
fi