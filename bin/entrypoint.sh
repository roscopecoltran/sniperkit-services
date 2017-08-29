#!/bin/bash

set -eo pipefail

wait_until() {
    local hostname=${1?}
    local port=${2?}
    local retry=${3:-100}
    local sleep_secs=${4:-2}
    
    local address_up=0
    
    while [ ${retry} -gt 0 ] ; do
        echo  "Waiting until ${hostname}:${port} is up ... with retry count: ${retry}"
        if nc -z ${hostname} ${port}; then
            address_up=1
            break
        fi        
        retry=$((retry-1))
        sleep ${sleep_secs}
    done 
    
    if [ $address_up -eq 0 ]; then
        echo "GIVE UP waiting until ${hostname}:${port} is up! "
        exit 1
    fi       
}

# apply template
for template in $(ls ${OPENTSDB_CONF_DIR}/*.mustache)
do
    conf_file=${template%.mustache}
    cat ${conf_file}.mustache | mustache.sh > ${conf_file}
done

if [ "$1" == "tsdb" ]; then
    shift
    
    if [[ "$1" == "version" ]]; then
        exec su-exec tsdb tsdb version
    fi

    wait_until ${HBASE_HMASTER1_HOSTNAME} 16000 
    
    if [[ "$1" == "tsd" && "$2" == "" ]]; then
        env COMPRESSION=NONE tools/create_table.sh
        exec su-exec tsdb tsdb tsd --config=${OPENTSDB_CONF_DIR}/opentsdb.conf  
    fi 
    
    exec su-exec tsdb tsdb "$@" 
     
fi
 
 exec "$@"