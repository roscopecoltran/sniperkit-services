#!/bin/bash

DOCKER_FLAG="-idt"

# Uncomment to enable privileged mode
#DOCKER_PRIV="--privileged=true"

# Uncomment to add PID mapping
#DOCKER_PID="--pid=host -u root"
#DOCKER_PID="--pid=host -u root -v /usr/lib/nvidia-352:/usr/lib/nvidia-352"

# Uncomment for MPS sharing
#DOCKER_MPS="-v /tmp/nvidia-mps:/tmp/nvidia-mps -v /dev/shm:/dev/shm"
#DOCKER_MPS="-v /dev/shm:/dev/shm"

DOCKER_DISK="-v /:/localdisk"
DOCKER_DNS="--dns 9.0.148.50 --dns 9.0.146.50 --dns 9.181.2.176 --dns-search crl.ibm.com"
DOCKER_ENTRY='--entrypoint /bin/bash'
DOCKER_IMAGE=$1
DOCKER_NAME="--name $2"
#DOCKER_PORT="-p 8080:8000"

DOCKER_COMMAND=""

docker run $DOCKER_FLAG $DOCKER_PRIV $DOCKER_DEVICES $DOCKER_PID $DOCKER_MPS $DOCKER_DISK $DOCKER_DNS $DOCKER_NAME $DOCKER_ENTRY $DOCKER_PORT $DOCKER_IMAGE $DOCKER_COMMAND