#!/bin/bash
# Initiate reverse proxy
kiss-proxy --port 9222 --target http://127.0.0.1:9200 &
# Execute Entrypoint as Kibi user
/bin/su - kibi -c "/opt/entrypoint.sh"
