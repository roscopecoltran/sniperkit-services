#!/bin/bash

set -e
# debug
#set -eux

if [ "$1" = 'logstash' ]; then    
    exec "${LS_HOME}/bin/$@"
else
    # As argument is not related then assume that user wants to run 
    # his own process, for example a `bash` shell to explore this image
    exec "$@"
fi
