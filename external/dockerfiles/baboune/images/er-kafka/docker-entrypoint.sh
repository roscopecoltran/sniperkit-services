#!/bin/bash

set -e
# debug
# set -eux

function check_env_variables () {

   if [[ ( -z "ZK_CONNECT" ) ]]; then
       echo "ZK_CONNECT must be configured"
       exit 1
   fi

   echo "KAFKA: Running with 'ZK_CONNECT' $ZK_CONNECT"

}

if [ "$1" = 'kafka' ]; then

    if [ -n "$ZOOKEEPER_PORT_2181_TCP_ADDR" ]; then
      echo "KAFKA: Running on developers local machine $ZOOKEEPER_PORT_2181_TCP_ADDR:$ZOOKEEPER_PORT_2181_TCP_PORT"
      ZK_CONNECT=$ZOOKEEPER_PORT_2181_TCP_ADDR:$ZOOKEEPER_PORT_2181_TCP_PORT
   fi

    check_env_variables

    echo "Using ZK_CONNECT: ${ZK_CONNECT}"        
    _host_ip=`echo $(hostname -i | head -n 1 | cut -d " " -f1)` 
    if [[ -v KAFKA_EXT_IP && "${KAFKA_EXT_IP}" != "" ]]; then
        _host_ip=${KAFKA_EXT_IP}
    fi
    echo "  HOST_IP: ${_host_ip}"
    
    sed -i "s/HOST_IP/${_host_ip}/g"      /opt/kafka/config/server.properties    
    sed -i "s/ZK_CONNECT/${ZK_CONNECT}/g" /opt/kafka/config/server.properties    
    
    sudo chown -R kafka:kafka /opt/kafka/logs

    /opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/server.properties

else
    # As argument is not related to kafka,
    # then assume that user wants to run his own process,
    # for example a `bash` shell to explore this image
    exec "$@"
fi



